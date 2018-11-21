#uses "CtrlHTTP"
#uses "CtrlXmlRpc"
#uses "xmlrpcHandlerCommon.ctl"
#uses "CtrlZlib"

int HTTP_PORT = 8083;

const int HTTPS_PORT = 0; // To enable https, set this to 443

main()
{
  //Start the HTTP Server
  if (httpServer(false, HTTP_PORT, HTTPS_PORT) < 0)
  {
   DebugTN("ERROR: HTTP-server can't start. --- Check license");
   return;
  }
  
  //Passive server mode
  httpRunPassive(true);
  //Start the XmlRpc Handler
  httpConnect("vatrodojavaHandler", "/xmlrpc");
}
 
mixed vatrodojavaHandler(const mixed content, string user, string ip, dyn_string ds1, dyn_string ds2, int connIdx)
{
   string sMethod, sRet;
   dyn_mixed daArgs;
   mixed methodResult;
   mixed xmlResult;
   string cookie = httpGetHeader(connIdx, "Cookie");
   int ret;
   dyn_errClass derr;

    //Decode content
   ret = xmlrpcDecodeRequest(content, sMethod, daArgs);
   derr = getLastError();
  
   if (ret < 0 || dynlen(derr)>=1){
      throwError(derr);
      //Output Error
      derr = xmlRpcMakeError(PRIO_SEVERE, ERR_SYSTEM, ERR_PARAMETER, "Error parsing xml-rpc stream", "Method: " + sMethod);
      throwError(derr);
      return xmlrpcReturnFault(derr);
   }

   //Start own method handler
   methodResult = methodHandlerOwn(sMethod, daArgs, user,cookie);
   derr = xmlRpcGetErrorFromResult(methodResult); /* Get error from result if error occurred */

   if (dynlen(derr) > 0) {   //Error occurred  
      throwError(derr);
      // return fault
      
      //Encode Error
      return makeDynString(xmlrpcReturnFault(derr), "Content-Type: text/xml");
   }

    sRet = xmlrpcReturnSuccess(methodResult); //Encode result
    //Compress the result if the other side allows it
    if ( strlen(sRet) > 1024 && strpos(httpGetHeader(connIdx, "Accept-Encoding"),"gzip") >= 0){
      //Return compressed content
      blob b;
      gzip(sRet, b);
      xmlResult = makeDynMixed(b, "Content-Type: text/xml", "Content-Encoding: gzip");
    }
    else{
      //Return plain content
      xmlResult = makeDynString( sRet, "Content-Type: text/xml");
    }
    
    return xmlResult;

}

mixed methodHandlerOwn(string sMethod, dyn_mixed &asValues, string user, string cookie)
{
  int rc; // return code
  switch (sMethod)
  {
    case "bstelecom.edp.scada.IScada.reportStatus" :
        DebugTN("vatrodojava reportStatus");
        int objectStatus = asValues[1];
        int eventType = asValues[2];
        int objectType = asValues[3];
        int panel = asValues[4];
        int subset = asValues[5];
        int detektor = asValues[6];
        DebugTN("ObjectStatus : "       + objectStatus);
        DebugTN("EventType : "          + eventType);
        DebugTN("ObjectType : "         + objectType);
        DebugTN("Panel : "              + panel);
        DebugTN("Subset : "             + subset);
        DebugTN("Detector : "           + detektor);
        DebugTN("Parameter : "          + asValues[7]);
        DebugTN("Minute : "             + asValues[8]);
        DebugTN("Hour : "               + asValues[9]);
        DebugTN("Day : "                + asValues[10]);
        DebugTN("Month : "              + asValues[11]);
        DebugTN("Year : "               + asValues[12]);
        if (objectType == 2  || objectType == -124) { // detektori
          if (objectStatus == -106)
            setDetectorStatus("Fire", panel, subset, detektor, eventType);
          else if (objectStatus == -100)
            setDetectorStatus("Fault", panel, subset, detektor, eventType);
			       else if (objectStatus == -90)
            setDetectorStatus("SwitchOff", panel, subset, detektor, eventType);
          else 
            DebugTN("Error : Detector status update " + objectStatus);
        }
        else if (objectType == 10) { // paneli
          if (objectStatus == -14)
            setPanelStatus("Short_circuit_right", "Gaj", panel, subset, detektor, eventType);
          else if (objectStatus == -15)
            setPanelStatus("Short_circuit_left", "Gaj", panel, subset, detektor, eventType);
          else if(objectStatus == 31  || objectStatus == 32  || objectStatus == 54  || objectStatus == 57  || objectStatus == 76)
            setCentralaStatus(objectStatus, "VDC_1", panel, subset, detektor, eventType);//object status, centrala, panel, subset, detektor, eventType
          else
            DebugTN("Error : Panel status update " + objectStatus);
        }
        else if (objectType == 9) { // loop
          if (objectStatus == -100)
            setLoopStatus("Fault", "Gaj", panel, subset, detektor, eventType);
          else if (objectStatus == -90)
            setLoopStatus("Switch_off", "Gaj", panel, subset, detektor, eventType);
          else 
            DebugTN("Error : Loop status update " + objectStatus);
        }
        // TODO handle petlji i panela
        return "Ack reportStatus";
    case "bstelecom.edp.scada.IScada.ackOperatingTelegram":
        DebugTN("Acknowledgement : "       + asValues[1]);
        DebugTN("OperatingTelegramNum : "  + asValues[2]);
        DebugTN("errorType : "             + asValues[3]);
        return "Ack ackOperatingTelegram";
    case "bstelecom.edp.scada.IScada.iamAlive":
        DebugTN("I am alive  " + asValues[1]);
        time t = getCurrentTime();
        dpSet(asValues[1] + ":_original.._value", t);
        return "You are alive.";
    case "bstelecom.edp.scada.IScada.alarmsReset":
        DebugTN("Reset alarm centrala : " + asValues[1]);
        mixed result = resetDetectorStatus(asValues[1]);
        return "Resetovanje alarma zavrseno" + result;
    default:
        return methodHandlerCommon(sMethod, asValues, user, cookie);
   }
}

int strcmp(string s_1, string s_2) {
  int len_1 = strlen(s_1);
  int len_2 = strlen(s_2);
  if ( len_1 != len_2) return -1;
  for (int i = 0; i<len_1; i++)
    if (s_1[i] != s_2[i]) 
      return -1;
  return 0;
}


mixed resetDetectorStatus(string p_centrala) {
  DebugTN("Reset centrala " + p_centrala);
  dyn_dyn_anytype tab;

  int z;
  string query = "SELECT '_online.._value' FROM '{E*Gaj.Status.Fire,Izlaz*Gaj.Status.Fire,Ulaz*Gaj.Status.Fire,Zona*Gaj.Status.Fire,Prolaz_za_Pjesake*Gaj.Status.Fire,TS*Gaj.Status.Fire}'";
  dpQuery(query, tab);
  int counter = 0;
  
  for(z=2;z<=dynlen(tab);z++) {
    string full_name = tab[z][1];
    //DebugTN(full_name);
    string dp_name = substr(full_name, 0, strlen(full_name) - strlen(".Status.Fire"));
    DebugTN("dp_name : " + dp_name);
    string centrala;
    dpGet(dp_name + ".ID.centrala", centrala);
    if (strcmp(centrala, p_centrala) == 0) {
      string dp = dp_name + ".Status.Fire";
      dpSet(dp, 1);
      
      dp = dp_name + ".Status.Fault";
      dpSet(dp, 1);
      counter += 1;
    }
  }
  return " " + counter + " resetovano";
}

mixed setDetectorStatus(string objectStatus, int p_panel, int p_subset, int p_detektor, int p_eventType) {
  DebugTN("Detector status update");
  dyn_dyn_anytype tab;

  int z;
  string query = "SELECT '_online.._value' FROM '{E*Gaj.Status." + objectStatus + ",Izlaz*Gaj.Status." + objectStatus + ",Ulaz*Gaj.Status." + objectStatus + ",Zona*Gaj.Status." + objectStatus + ",Prolaz_za_Pjesake*Gaj.Status." + objectStatus + ",TS*Gaj.Status." + objectStatus + "}' ";
  dpQuery(query, tab);

  DebugTN("Ukupan broj detektora: " + dynlen(tab)); // "System1:fire_detector1.Status.Fire"
  
  for(z=2;z<=dynlen(tab);z++) {
    string full_name = tab[z][1];
    //DebugTN(full_name);
    string dp_name = substr(full_name, 0, strlen(full_name) - strlen(".Status." + objectStatus));
    //DebugTN("dp_name : " + dp_name);
    int panel, subset, detektor;
    dpGet(dp_name + ".ID.panel", panel);
    dpGet(dp_name + ".ID.subset", subset);
    dpGet(dp_name + ".ID.detektor", detektor);
    if (/*panel == p_panel &&*/ subset == p_subset  /*&& detektor == p_detektor*/) {
      string dp = dp_name + ".Status." + objectStatus;
      DebugTN("dpSet: " + dp + " eventType: " + p_eventType);
      dpSet(dp, p_eventType);
    }
	
  }
  DebugTN("Nije pronađen detektor: panel=" + p_panel+ " subset="+ p_subset+ " detektor="+ p_detektor);
}

//centrala: Centrala Gaj
mixed setCentralaStatus(int objectStatus, string p_centrala, int p_panel, int p_subset, int p_detektor, int p_eventType) {
  DebugTN("Centrala Gaj status update, centrala" + p_centrala);

  switch(objectStatus){
    case 31: dpSet(p_centrala + ".status.key_unlocked", p_eventType); break;
    case 32: dpSet(p_centrala + ".status.cover_contact_open",p_eventType); break;
    case 54: dpSet(p_centrala + ".status.accu_fault", p_eventType); break;
    case 57: dpSet(p_centrala + ".status.power_suply_fault", p_eventType); break;
    case 76: dpSet(p_centrala + ".status.cpu_fault", p_eventType); break;
  }
  DebugTN("Uspjesno setovano: centrala=" + p_centrala + " status=" + objectStatus);
}


mixed setPanelStatus(string objectStatus, string p_centrala, int p_panel, int p_subset, int p_detektor, int p_eventType) {
  DebugTN("Panel status update");
  dyn_dyn_anytype tab;

  int z;
  string query = "SELECT '_original.._value' FROM '*_fd_panel_*." + objectStatus + "' ";
  dpQuery(query, tab);

  DebugTN("Ukupan broj panela: " + dynlen(tab)); // "System1:fire_detector1.Status.Fire"
  
  for(z=2;z<=dynlen(tab);z++) {
    string full_name = tab[z][1];
    //DebugTN(full_name);
    string dp_name = substr(full_name, 0, strlen(full_name) - strlen("." + objectStatus));
    DebugTN("dp_name : " + dp_name);
    int panel_id;
    dpGet(dp_name + ".ID", panel_id);
    string centrala_id;
    dpGet(dp_name + ".centrala", centrala_id);
    if (panel_id == p_panel && strcmp(centrala, p_centrala) == 0) {
      string dp = dp_name + "." + objectStatus;
      DebugTN("dpSet: " + dp + " eventType: " + p_eventType);
      dpSet(dp, p_eventType);
	  return;
    }
  }
  DebugTN("Nije pronađen panel: panel=" + p_panel+ " centrala="+ centrala);
}

mixed setLoopStatus(string objectStatus, string p_centrala, int p_panel, int p_subset, int p_detektor, int p_eventType) {
  DebugTN("Loop status update");
  dyn_dyn_anytype tab;

  int z;
  string query = "SELECT '_original.._value' FROM '*_fd_loop_*." + objectStatus + "' ";
  dpQuery(query, tab);

  DebugTN("Ukupan broj petlji: " + dynlen(tab)); // "System1:fire_detector1.Status.Fire"
  
  for(z=2;z<=dynlen(tab);z++) {
    string full_name = tab[z][1];
    //DebugTN(full_name);
    string dp_name = substr(full_name, 0, strlen(full_name) - strlen("." + objectStatus));
    DebugTN("dp_name : " + dp_name);
    int panel_id;
    dpGet(dp_name + ".ID", panel_id);
    string centrala_id;
    dpGet(dp_name + ".centrala", centrala_id);
    if (panel_id == p_panel && strcmp(centrala, p_centrala) == 0) {
      string dp = dp_name + "." + objectStatus;
      DebugTN("dpSet: " + dp + " eventType: " + p_eventType);
      dpSet(dp, p_eventType);
	  return;
    }
  }
  DebugTN("Nije pronađena petlja: panel=" + p_panel+ " centrala="+ centrala);
}
