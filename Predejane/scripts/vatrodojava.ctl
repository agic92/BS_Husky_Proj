//-dbg "level1" za debugiranje
#uses "CtrlHTTP"
#uses "CtrlXmlRpc"
#uses "xmlrpcHandlerCommon.ctl"
#uses "CtrlZlib"
#uses "log.ctl"
#uses "basicMethods.ctl"
#uses "XmlRpcMethods.ctl"

int HTTP_PORT = 8081;

const int HTTPS_PORT = 0; // To enable https, set this to 443

mapping settings;
dyn_string incidents;
string systemName = getSystemName();
string scriptName = "Firedetection";

main()
{
  if (!loadSettings())
  {
    Log::error("main", "Could not load settings for script " + scriptName);
  }

  if (httpServer(false, settings["HTTP_PORT"], settings["HTTPS_PORT"]) < 0)
  {
    Log::exception("main", "HTTP server did not start");
  }
  httpRunPassive(true);

  if(!httpConnect("xmlrpcHandler", "/RPC2") < 0)
  {
    Log::exception("main", "httpConnect method did not start successfully");
  }

  Log::info("main", "HTTP server started successfully at port " + settings["HTTP_PORT"]);

}

mixed xmlrpcHandler(const mixed content, string user, string ip, dyn_string ds1, dyn_string ds2, int connIdx)
{
  string methodName;
  dyn_mixed methodArguments;
  mixed methodResult;
  dyn_errClass derr;
  string cookie = httpGetHeader(connIdx, "Cookie");

   //Decoding content
  if (xmlrpcDecodeRequest(content, methodName, methodArguments) < 0)
  {
    derr = getLastError();
    throwError(derr);
    derr = xmlRpcMakeError(PRIO_SEVERE, ERR_SYSTEM, ERR_PARAMETER, "Error parsing xml-rpc stream", "Method: " + methodName);
    throwError(derr);
    Log::error("xmlrpcHandler", "Error in calling xmlrpcDecodeRequest() method");
    return xmlrpcReturnFault(derr);

  }

  //Start own method handler - this is where the script logic is done, the rest of the code is same for all scripts using xmlrpc
  methodResult = methodHandlerOwn(methodName, methodArguments, user, cookie);

  return encodeMethodResult(methodResult, connIdx);
}


mixed methodHandlerOwn(string sMethod, dyn_mixed &asValues, string user, string cookie)
{
  int rc; // return code
  switch (sMethod)
  {
    case "bstelecom.edp.scada.IScada.reportStatus" :
        DebugFTN("level1","vatrodojava reportStatus");
        int objectStatus = asValues[1];
        int eventType = asValues[2];
        int objectType = asValues[3];
        int panel = asValues[4];
        int subset = asValues[5];
        int detektor = asValues[6];
        DebugFTN("level1","ObjectStatus : "       + objectStatus);
        DebugFTN("level1","EventType : "          + eventType);
        DebugFTN("level1","ObjectType : "         + objectType);
        DebugFTN("level1","Panel : "              + panel);
        DebugFTN("level1","Subset : "             + subset);
        DebugFTN("level1","Detector : "           + detektor);
        DebugFTN("level1","Parameter : "          + asValues[7]);
        DebugFTN("level1","Minute : "             + asValues[8]);
        DebugFTN("level1","Hour : "               + asValues[9]);
        DebugFTN("level1","Day : "                + asValues[10]);
        DebugFTN("level1","Month : "              + asValues[11]);
        DebugFTN("level1","Year : "               + asValues[12]);
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
            setPanelStatus("Short_circuit_right", "Drivusa", panel, subset, detektor, eventType);
          else if (objectStatus == -15)
            setPanelStatus("Short_circuit_left", "Drivusa", panel, subset, detektor, eventType);
          else if(objectStatus == 31 || objectStatus == 32 || objectStatus == 54 || objectStatus == 55 || objectStatus == 57 || objectStatus == 76){
            if(panel == 1) setCentralaStatus(objectStatus, "VDC_1", panel, subset, detektor, eventType);//object status, centrala, panel, subset, detektor, eventType
            if(panel == 2) setCentralaStatus(objectStatus, "VDC_2", panel, subset, detektor, eventType);//object status, centrala, panel, subset, detektor, eventType
          }
          else
            DebugTN("Error : Panel status update " + objectStatus);
        }
        else if (objectType == 9) { // loop
          if (objectStatus == -100)
            setLoopStatus("Fault", "Drivusa", panel, subset, detektor, eventType);
          else if (objectStatus == -90)
            setLoopStatus("Switch_off", "Drivusa", panel, subset, detektor, eventType);
          else
            DebugTN("Error : Loop status update " + objectStatus);
        }
        // TODO handle petlji i panela
        return "Ack reportStatus";
    case "bstelecom.edp.scada.IScada.ackOperatingTelegram":
        DebugFTN("level1","Acknowledgement : "       + asValues[1]);
        DebugFTN("level1","OperatingTelegramNum : "  + asValues[2]);
        DebugFTN("level1","errorType : "             + asValues[3]);
        return "Ack ackOperatingTelegram";
    case "bstelecom.edp.scada.IScada.iamAlive":
        DebugFTN("level1","I am alive  " + asValues[1]);
        time t = getCurrentTime();
        dpSet(asValues[1] + ":_original.._value", t);
        return "You are alive.";
    case "bstelecom.edp.scada.IScada.alarmsReset":
        DebugFTN("level1","Reset alarm centrala : " + asValues[1]);
        mixed result = resetDetectorStatus(asValues[1]);
        return "Resetovanje alarma zavrseno " + result;
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
  string query = "SELECT '_online.._value' FROM '{E*Mart.Status.Fire,Izlaz*Mart.Status.Fire,Ulaz*Mart.Status.Fire,Prolaz_za*Mart.Status.Fire,TS*Mart.Status.Fire,Zona*Mart.Status.Fire}'";
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
      //podstring koji trazi vrata nise i smjesta u novi datapoint 1 ako je pronasao
      //datapoint sa istim nazivom samo drugi datapoint type
      dp = dp_name + ".Status.Fault";
      dpSet(dp, 1);
      counter += 1;
    }
  }
  return "" + counter + " resetovano";
}

mixed setDetectorStatus(string objectStatus, int p_panel, int p_subset, int p_detektor, int p_eventType) {
  DebugTN("Detector status update");
  dyn_dyn_anytype tab;

  int z;
  string query = "SELECT '_online.._value' FROM '{E*Mart.Status." + objectStatus + ",Izlaz*Mart.Status." + objectStatus + ",Ulaz*Mart.Status." + objectStatus + ",Prolaz_za*Mart.Status." + objectStatus + ",TS*Mart.Status." + objectStatus + ",Zona*Mart.Status." + objectStatus + "}' ";
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
    if (/*panel == p_panel &&*/ subset == p_subset  && detektor == p_detektor) {
      string dp = dp_name + ".Status." + objectStatus;
      DebugTN("dpSet: " + dp + " eventType: " + p_eventType);
      //dodati da smjeta i u novi datapoint tip samo provjerimo subset
      //upit na subset
      dpSet(dp, p_eventType);
    }

  }
  DebugTN("Nije pronađen detektor: panel=" + p_panel+ " subset="+ p_subset+ " detektor="+ p_detektor);
}


//centrala: Centrala Drivusa
mixed setCentralaStatus(int objectStatus, string p_centrala, int p_panel, int p_subset, int p_detektor, int p_eventType) {
  DebugTN("Centrala Drivusa status update, centrala" + p_centrala);

  switch(objectStatus){
    case 31: dpSet(p_centrala + ".status.key_unlocked", p_eventType); break;
    case 32: dpSet(p_centrala + ".status.cover_contact_open",p_eventType); break;
    case 54: dpSet(p_centrala + ".status.accu_fault", p_eventType); break;
    case 55: dpSet(p_centrala + ".status.power_fault", p_eventType); break;
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

bool loadSettings()
{
  if(!getDP(systemName + scriptName + ".settings.HTTP_PORT",
   settings["HTTP_PORT"])) return false;
  if(!getDP(systemName + scriptName + ".settings.HTTPS_PORT",
   settings["HTTPS_PORT"])) return false;

  return true;
}
