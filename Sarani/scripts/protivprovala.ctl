#uses "CtrlHTTP"
#uses "CtrlXmlRpc"
#uses "xmlrpcHandlerCommon.ctl"
#uses "CtrlZlib"

int HTTP_PORT = 7070;

const int HTTPS_PORT = 0; // To enable https, set this to 443


main()
{
 
  //Start the HTTP Server
  int id = httpServer(false, HTTP_PORT, HTTPS_PORT);
  // Passive server mode
  //httpRunPassive(true);

  if (id < 0)
  {
   DebugTN("ERROR: HTTP-server can't start. --- Check license");
   return;
  }

  //Start the XmlRpc Handler
  httpConnect("xmlrpcHandler", "/RPC2");
  DebugTN("HTTP Server installed",id);/* check if the function  httpServer was executed correctly */ 
  
  dyn_errClass err; 
  err = getLastError(); /* check possible errors */ 
  
  if(dynlen(err) > 0) 
  { 
    DebugTN(err);
    errorDialog(err); 
    throwError(err);
  }
  else 
  {
    DebugTN("Server started at port " + HTTP_PORT); //No errors 
  } 

}

mixed xmlrpcHandler(const mixed content, string user, string ip, dyn_string ds1, dyn_string ds2, int connIdx)
{
//  DebugFTN("xmlrpcHandler: xmlrpcHandler"); //No errors 
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
  if (ret < 0 || dynlen(derr)>=1)
  {
    DebugTN(derr);
    throwError(derr);
    //Output Error
    derr = xmlRpcMakeError(PRIO_SEVERE, ERR_SYSTEM, ERR_PARAMETER, "Error parsing xml-rpc stream", "Method: "+sMethod);

    throwError(derr);
    return xmlrpcReturnFault(derr);

  }

   //Start own method handler
   methodResult = methodHandlerOwn(sMethod, daArgs, user, cookie);
   derr = xmlRpcGetErrorFromResult(methodResult); /* Get error
   from result if error occurred */

   if (dynlen(derr) > 0) //Error occurred
   {
      DebugTN(derr);
      throwError(derr);
      // return fault

      //Encode Error
      return makeDynString(xmlrpcReturnFault(derr), "Content-Type: text/xml");
    }

    sRet = xmlrpcReturnSuccess(methodResult); //Encode result
    //Compress the result if the other side allows it
    if ( strlen(sRet) > 1024 && strpos(httpGetHeader(connIdx, "Accept-Encoding"),"gzip") >= 0)
    {
      //Return compressed content
      blob b;
      gzip(sRet, b);
      xmlResult = makeDynMixed(b, "Content-Type: text/xml", "Content-Encoding: gzip");
    }
    else
    {
      //Return plain content
      xmlResult = makeDynString( sRet, "Content-Type: text/xml");
    }
    return xmlResult;
}

mixed methodHandlerOwn(string sMethod, dyn_mixed &asValues, string user, string cookie)
{
  int rc; // return code
  DebugFTN("level1","Calling method " + sMethod );  
  DebugFTN("level1","as method " + asValues[1]);  
  
  time t;
    
  switch (sMethod)
  {
    case "setDP" :
        if (dynlen(asValues) != 2)
          return xmlRpcMakeError(PRIO_SEVERE, ERR_CONTROL, ERR_INVALID_ARGUMENT, sMethod, "" + asValues);
        DebugFTN("level1","Setting data point " + asValues[1] +" value to " + asValues[2]);
        int last_dot_postion = strpos(asValues[1], ".", strlen("SysGrabosjec:K"));
        if (last_dot_postion == -1) {
          DebugTN("ERROR: ne mogu naci da li je kamera aktivna.");
          return;
        }
        string camera_name = substr(asValues[1], 0, last_dot_postion);
        bool active;
        dpGet(camera_name + ".active", active);
        if (!active) {
          DebugN("Kamera " + camera_name + " nije aktivna");
          return;
        }
        rc=dpSet(asValues[1], asValues[2]);
         dyn_errClass derr;
      derr = getLastError();
      if (rc < 0 || dynlen(derr)>=1)
		 {
		DebugTN(derr);
		}
    return "Setting data point " + asValues[1] +" value to " + asValues[2];
    
    case "bstelecom.ppa.scada.IScada.iamAlive":    
          
          //dpSet("SysSarani:protivprovala.isAlive", true); 
          DebugFTN("level1","I am alive  " + asValues[1]);
          time t = getCurrentTime();
          dpSet(asValues[1] + ":_original.._value", t);
          //DebugTN("Method iAmAlive was called");
          return "iAmAlive";
    
    case "scada.bstelecom.ba.IScada.iamAlive":
          DebugFTN("level1", "Method iAmAlive was called");
          return "You are alive.";
          
    case "bstelecom.ppa.scada.IScada.zoneWentIntoAlarmState":
//         if (dynlen(asValues) != 1)
//           return xmlRpcMakeError(PRIO_SEVERE, ERR_CONTROL, ERR_INVALID_ARGUMENT, sMethod, "" + asValues);
//         DebugTN("I am alive " + asValues[1]);
//         time t = getCurrentTime();
//         dpSet(asValues[1] + ":_original.._value", t);
//         return "You are alive.";
          dpSet("SysSarani:test.partition" + asValues[1] + "." + "zone" + asValues[2], true);
          DebugFTN("level1", "Particija " + asValues[1] + ", zona " + asValues[2] + "je u alarmu!");
          return "Particija " + asValues[1] + ", zona " + asValues[2] + "je u alarmu!"; 
    
    case "bstelecom.ppa.scada.IScada.zoneWentOutOfAlarmState":
          dpSet("SysSarani:test.partition" + asValues[1] + "." + "zone" + asValues[2], false);
          DebugFTN("level1", "Particija " + asValues[1] + ", zona " + asValues[2] + "nije više u alarmu!");
          return "Particija " + asValues[1] + ", zona " + asValues[2] + "nije više u alarmu!";
    
    case "bstelecom.ppa.scada.IScada.porukaProtivprovalneCentrale":
         DebugFTN("level1", "Poruka od centrale: " + asValues[1]);
         return "Poruka od centrale primljena!";
    
    case "bstelecom.ppa.scada.IScada.statusZoneOpened":
         DebugFTN("level1", "Zona " + asValues[1] + " otvorena.");
         startThread("setujPokret", asValues[1], asValues[2]);
//          dpSet("SysSarani:protivprovala.zona" +  asValues[1], true);
         DebugFTN("level1", "Zona " + asValues[1] + " opened.");
         return "Zona " + asValues[1] + " opened.";
         
    case "bstelecom.ppa.scada.IScada.statusZoneRestored":
         DebugFTN("level1", "Zona " + asValues[1] + " restored.");
         return "Zona " + asValues[1] + " restored.";
         
    case "bstelecom.ppa.scada.IScada.partitionInAlarm":
         dpSet("SysSarani:test.partition" + asValues[1] + ".inAlarm", true);
         DebugFTN("level1", "SysSarani:test.partition" + asValues[1] + " in alarm state");
         return "Particija " + asValues[1] + " u alarmu!";
              
    default:
        return methodHandlerCommon(sMethod, asValues, user, cookie);
   }
   
}

setujPokret(int zona,int pogonskaStanica) {
  dpSet("SysSarani:PS" + pogonskaStanica + ".zona" +  zona, true);
  delay(15);
  dpSet("SysSarani:PS" + pogonskaStanica + ".zona" +  zona, false);
}
