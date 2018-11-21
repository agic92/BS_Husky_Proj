#uses "CtrlXmlRpc"

//-dbg 1 - prikaz komandi za prikaz kamere na odredjeni alarm monitor

main()
{
  DebugTN("Start skripte milestone_rpc_client.ctl!");
  DebugTN("pretplacuje se na: SELECT '_online.._value' FROM 'AlarmMonitor*.commands.cameraIP' WHERE _DPT = \"Milestone\"");

  dpQueryConnectSingle("cbSendToMilestoneClient", true, "simulIdent", 
//                       "SELECT '_online.._value' FROM 'AlarmMonitor*.commands.cameraIP' WHERE _DPT = \"Milestone\"");  
                                              "SELECT '_online.._value' FROM 'AlarmMonitor*.commands.cameraIP' WHERE _DPT = \"Milestone\"");    
}


cbSendToMilestoneClient(anytype ident, dyn_dyn_anytype list)
{  
  if(!isReduActive())
     return;

  float   actualValue, setPoint;
  string dpe;
  int i;
  string id = "servID";
  string func = "Notificator.notify";
  string host = "localhost";
  //string host = "10.111.9.153";
  //string host = "10.111.0.202";
  int port = "8189";
  bool secure = FALSE;
  string value;  
  xmlrpcClient();
  xmlrpcConnectToServer(id, host, port, secure);
  
  for(i=2; i<=dynlen(list); i++)  //starta sa 2 zato sto liste pocinju od 1, a sql upit vraca u prvoj liniji header pa treba i njega preskociti
  {
    setPoint = list[i][2];  //list[name][value]
    value = list[i][2];
    dpe = list[i][1];
    dpe = dpSubStr(dpe, DPSUB_DP);  //DPSUB_DP - 

    //dpGet(dpe + ".response.opening", actualValue);
    //DebugTN("radi li: " + dpe + ", value: " + value);
    
    dyn_mixed args = makeDynMixed(dpe,value);
    DebugFTN(1, "MilestoneClient.ctl - args: " + args);
    mixed res;
    
    xmlrpcCall(id, func, args, res);
    DebugFTN(1, "res = " + res);  
    //DebugN(res);
  }  
  
   xmlrpcCloseServer(id);     
}

