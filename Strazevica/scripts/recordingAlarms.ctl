main() {
  anytype userData="";
  string query = "SELECT ALERT '_alert_hdl.._value' FROM 'K*.*' WHERE _DPT = \"Camera\"";
  dpQueryConnectSingle("recording", 1, userData, query);
}

void recording (anytype userData, dyn_dyn_anytype data) {
  dyn_string alarms = makeDynString("wrongDirection", "stoppedVehicle", "pedestrian");
  string camera, cameraDp, request, triggerAlarmCommand = "triggeralarm", clearAlarmCommand = "clearalarm", getStreamCommand = "getstreamtimeline", value, alarmTime;
  bool isRecording;  
  
  for (int i=2; i<=dynlen(data); i++) {    
    camera = dpSubStr(data[i][1], DPSUB_DP);
    alarmTime = data[i][2];
    value = data[i][3];    
    DebugTN(camera, alarmTime, value);
    dpGet(camera + ".cameraDp", cameraDp);
    dpGet(cameraDp + ".object.command.request", request);
    DebugTN(cameraDp, request);
    /*Ako je alarm prvi aktivni na kameri, pokreće se snimanje. Ako je alarm bio zadnji aktivni, zaustavlja se snimanje*/
    
    if (value==true && (strpos(request, clearAlarmCommand)>=0 || strpos(request, getStreamCommand)>=0)) {
      dpSet(cameraDp + ".object.command.request" , "cmd=triggeralarm;streamIndex=1");
    }
    else if (value==false && strpos(request, triggerAlarmCommand)>=0) {
      bool lastAlarm = true;
      
      for (int j=1; j<=dynlen(alarms); j++) {
        bool alarm;
        dpGet(camera + "." + alarms[i], alarm);
        if (alarm) {
          lastAlarm=false;
        }
      }
      if (lastAlarm) {
        dpSet(cameraDp + ".object.command.request" , "cmd=clearalarm;streamIndex=1");
      }
    }
  
  }
}
