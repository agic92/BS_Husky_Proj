//-dbg "level1" za debugiranje
#uses "CtrlHTTP"
#uses "CtrlXmlRpc"
#uses "xmlrpcHandlerCommon.ctl"
#uses "CtrlZlib"

int HTTP_PORT = 8006;

const int HTTPS_PORT = 0; // To enable https, set this to 443

 

main()
{
  //Start the HTTP Server
  int id = httpServer(false, HTTP_PORT, HTTPS_PORT);
  if (id < 0)
  {
   DebugFTN("level1", "ERROR: HTTP-server can't start. --- Check license");
   return;
  }

   httpRunPassive(true);

  //Start the XmlRpc Handler
  httpConnect("xmlrpcHandler", "/RPC2");
  DebugFTN("level1", "HTTP Server installed",id);/* check if the function  httpServer was executed correctly */ 
  
  dyn_errClass err; 
  err = getLastError(); /* check possible errors */ 
  
  if(dynlen(err) > 0) 
  { 
    DebugFTN("level1", err);
    errorDialog(err); 
    throwError(err);
  }
  else 
  {
    DebugFTN("level1", "Server started at port " + HTTP_PORT); //No errors 
  } 

}

 

mixed xmlrpcHandler(const mixed content, string user, string ip, dyn_string ds1, dyn_string ds2, int connIdx)
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
  if (ret < 0 || dynlen(derr)>=1)
  {
    DebugFTN("level1", derr);
    throwError(derr);
    //Output Error
    derr = xmlRpcMakeError(PRIO_SEVERE, ERR_SYSTEM, ERR_PARAMETER, "Error parsing xml-rpc stream", "Method: "+sMethod);

    throwError(derr);
    return xmlrpcReturnFault(derr);

  }

   //Start own method handler
   methodResult = methodHandlerOwn(sMethod, daArgs, user,cookie);
   derr = xmlRpcGetErrorFromResult(methodResult); /* Get error
   from result if error occurred */

   if (dynlen(derr) > 0) //Error occurred
   {
      DebugFTN("level1", derr);
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
  switch (sMethod)
  {
    case "setDP" :
        if (dynlen(asValues) != 2)
          return xmlRpcMakeError(PRIO_SEVERE, ERR_CONTROL, ERR_INVALID_ARGUMENT, sMethod, "" + asValues);
        DebugFTN("level1","Setting data point " + asValues[1] +" value to " + asValues[2]);
        int last_dot_postion = strpos(asValues[1], ".", strlen("System1:K"));
        if (last_dot_postion == -1) {
          DebugFTN("level1","ERROR: nemogu naci dali je kamera aktivna.");
          return;
        }
        string camera_name = substr(asValues[1], 0, last_dot_postion);
        bool active;
        dpGet(camera_name + ".active", active);
        if (!active) {
          DebugFTN("level1","Kamera " + camera_name + " nije aktivna");
          return;
        }
        rc=dpSet(asValues[1], asValues[2]);
        return "Setting data point " + asValues[1] +" value to " + asValues[2];
   case "scada.bstelecom.ba.IScada.iamAlive":
        DebugFTN("level1", "I am alive " + asValues[1]);
        time t = getCurrentTime();
        dpSet(asValues[1] + ":_original.._value", t);
        return "You are alive.";
   case "getTimestamp":
        DebugFTN("level1", "asValues: " + asValues);
        DebugFTN("level1","GETTIMESTAMP");
        string incident;
        if (dynlen(asValues) < 1) return xmlRpcMakeError(PRIO_SEVERE, ERR_CONTROL, ERR_INVALID_ARGUMENT, sMethod, "" + asValues);
        DebugFTN("level1", "Setting data point " + asValues[1]);
        int dot_position = strpos(asValues[1], ".", 1); //vraca poziciju tacke u stringu
        
        if (dot_position == -1) {
          DebugFTN("level1", "ERROR: dot_position");
          return;
        }
        
        string camera_name = substr(asValues[1], 0, dot_position);
        string timestamp = substr(asValues[1], dot_position + 1, strlen(asValues[1])- strlen(camera_name));
        incident = getIncident(timestamp);
        
        
        
        if (strpos(asValues[1], "VehicleStatistics")>=0) {
          dyn_string params = strsplit(asValues[1], "_");
          string lane = params[3];
          string speed = params[4];
          string category = params[5];
          
          dpSet(camera_name + ".lane", lane,
                camera_name + ".speed", speed,
                camera_name + ".category", category,
                camera_name + ".params", makeDynString(lane, speed, category));
          
        }
        
        
        
        
        
        
        //rc = dpSet(camera_name + ".Imena_slika." + incident, timestamp);
        DebugFTN("level1", "Setting data point " + camera_name + ".Imena_slika." + incident);
        dyn_errClass derr;
        derr = getLastError();
        if (rc < 0 || dynlen(derr)>=1) DebugFTN("level1", derr);
		    return "Setting data point " + asValues[1];
    default:
        return methodHandlerCommon(sMethod, asValues, user, cookie);
   }
}
/*
  <Value>SmokeDetector_Alarm</Value>
		<Value>ghost</Value>
		<Value>false</Value>
		<Value>Stop-0</Value>
		<Value>Stop-1</Value>
		<Value>TrafficJam-0</Value>
		<Value>TrafficJam-1</Value>
		<Value>Movement-0</Value>
		<Value>Movement-1</Value>
		<Value>Obstacle</Value>
		<Value>Pedestrian</Value>
*/
string getIncident(string timestamp){

  mapping map;
  map["Pedestrian"] = "pedestrian";
  map["ghost"] = "wrongDirection";
  map["false"] = "stoppedVehicle";
  map["Stop-0"] = "Stopped_vehicle";
  map["Stop-1"] = "Stopped_vehicle";
  map["TrafficJam-0"] = "Traffic_jam";
  map["TrafficJam-1"] = "Traffic_jam";
  map["Movement-0"] = "Movement_in_non-traffic_area";
  map["Movement-1"] = "Movement_in_non-traffic_area";
  map["Obstacle"] = "Lost_cargo";
  map["SmokeDetector_Alarm"] = "Smoke";
  
  string key;
                   
  for(int i=1;i<=mappinglen(map);i++){
     key = mappingGetKey(map, i);
     if(strpos(timestamp, key, 1) >= 0) {
       return map[key]; }   
  }
  return "";
}
