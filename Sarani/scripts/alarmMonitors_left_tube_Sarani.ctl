// VAZNA NAPOMENA:
//Globalne varijable se ne mogu sabirati van funkcija, tj ovdje. Zato su upiti podjeljeni
int iNumber_of_AlarmMonitors_to_reserve_for_wrongWay = 3;
int iNumber_of_AlarmMonitors_inFront_of_Alarm = 2;
dyn_dyn_anytype camera_list;
string sSystemName = "SysSarani"; //ime sistema
//string sCameras = "KL*.*:,K1,K4,K5";
string sCameras = "KL*";
string sAlarmMonitors = "AlarmMonitor1,AlarmMonitor2,AlarmMonitor3";


//string sSelectAlerts = "SELECT ALERT '_alert_hdl.._visible' FROM 'KL*.*:' WHERE (_DPT = \"camera\")";
//string sSelectAlerts = "SELECT ALERT '_alert_hdl.._visible' FROM '{KL*,K1,K4,K5}' WHERE (_DPT = \"camera\")";
// select mora sadrzavati "FROM '{}"
string sSelectAlerts = "SELECT ALERT '_alert_hdl.._visible' FROM '{}' WHERE (_DPT = \"camera\")";
//string sSelectAlarmMonitors = "SELECT '_original.._value' FROM 'AlarmMonitor3*.commands.cameraIP' WHERE (_DPT = \"Milestone\") & (_DP != \"AlarmMonitor3\")";
string sSelectAlarmMonitors = "SELECT '_original.._value' FROM 'AlarmMonitor*.commands.cameraIP' WHERE (_DPT = \"Milestone\")";
//string sAlarmMonitorsDetailedList = "SELECT '.commands.cameraIP:_original.._value', '.commands.index:_original.._value', '.commands.reserved:_original.._value','.commands.cameraIP:_original.._stime'  FROM '{AlarmMonitor7,AlarmMonitor8,AlarmMonitor3,AlarmMonitor4,AlarmMonitor5,AlarmMonitor6}' WHERE _DPT = \"Milestone\" SORT BY 2";
//string sAlarmMonitorsDetailedList = "SELECT '.commands.cameraIP:_original.._value', '.commands.index:_original.._value', '.commands.reserved:_original.._value','.commands.cameraIP:_original.._stime'  FROM '{AlarmMonitor31,AlarmMonitor32,AlarmMonitor33}' WHERE _DPT = \"Milestone\" SORT BY 2";
string sAlarmMonitorsDetailedList = "SELECT '.commands.cameraIP:_original.._value', '.commands.index:_original.._value', '.commands.reserved:_original.._value','.commands.cameraIP:_original.._stime'  FROM '{}' WHERE _DPT = \"Milestone\" SORT BY 2";
//string sAlarmMonitorsDetailedList_order_by_time= "SELECT '.commands.cameraIP:_original.._value', '.commands.index:_original.._value', '.commands.reserved:_original.._value','.commands.cameraIP:_original.._stime'  FROM '{AlarmMonitor7,AlarmMonitor8,AlarmMonitor3,AlarmMonitor4,AlarmMonitor5,AlarmMonitor6}' WHERE _DPT = \"Milestone\" SORT BY 4";
//string sAlarmMonitorsDetailedList_order_by_time= "SELECT '.commands.cameraIP:_original.._value', '.commands.index:_original.._value', '.commands.reserved:_original.._value','.commands.cameraIP:_original.._stime'  FROM '{AlarmMonitor31,AlarmMonitor32,AlarmMonitor33}' WHERE _DPT = \"Milestone\" SORT BY 4";
string sAlarmMonitorsDetailedList_order_by_time= "SELECT '.commands.cameraIP:_original.._value', '.commands.index:_original.._value', '.commands.reserved:_original.._value','.commands.cameraIP:_original.._stime'  FROM '{}' WHERE _DPT = \"Milestone\" SORT BY 4";
//string sAllActiveAllerts = "SELECT ALERT '_alert_hdl.._visible' FROM '(KL*,K1,K4,K5)' WHERE (_DPT = \"camera\")";
//string sAllActiveAllerts = "SELECT ALERT '_alert_hdl.._visible' FROM '{KL*,K1,K4,K5}' WHERE (_DPT = \"camera\")";
string sAllActiveAllerts = "SELECT ALERT '_alert_hdl.._visible' FROM '{}' WHERE (_DPT = \"camera\")";
//string sDetailedListOfCameras = "SELECT 'ip:_original.._value', 'index:_original.._value' FROM '{KL*.*:,K1,K4,K5}' WHERE _DPT = \"camera\" SORT BY 2";  
string sDetailedListOfCameras = "SELECT 'ip:_original.._value', 'index:_original.._value' FROM '{}' WHERE _DPT = \"camera\" SORT BY 2";  
string sIP_base = "10.102.0.";
bool bFIFO = false;


main()
{ 
  delay(5);
  initialize();
  
  camera_list = get_detailed_list_of_cameras();    
  int rc; 

  //string sSelect = "SELECT ALERT '_alert_hdl.._visible' FROM 'K*.*:' WHERE (_DPT = \"camera\")";
  string sSelect = sSelectAlerts;
  DebugFTN("level1","sSelectAlerts: " + sSelectAlerts);
  
  anytype userData = getUserName();

  //Pretplacuje se na sve alerte sa camera
  rc = dpQueryConnectSingle("work", true, userData, sSelect); 

/*  
  // za debugiranje
  dyn_errClass d_err;
  d_err = getLastError();
  if(dynlen(d_err)>0)
      throwError(d_err); 
  */

}

//podesava globalne varijable
initialize()
{
  sSelectAlerts = insert_Remote_SystemName_into_global_variable(sSelectAlerts);
  sAllActiveAllerts = insert_Remote_SystemName_into_global_variable(sAllActiveAllerts);
  sDetailedListOfCameras = insert_Remote_SystemName_into_global_variable(sDetailedListOfCameras);
  
  sSelectAlerts = insert_cameras_into_select_string(sSelectAlerts);
  sAllActiveAllerts = insert_cameras_into_select_string(sAllActiveAllerts);
  sDetailedListOfCameras = insert_cameras_into_select_string(sDetailedListOfCameras);
  
  sAlarmMonitorsDetailedList = insert_alarmMonitors_into_select_string(sAlarmMonitorsDetailedList);
  sAlarmMonitorsDetailedList_order_by_time = insert_alarmMonitors_into_select_string(sAlarmMonitorsDetailedList_order_by_time);  
}

//ubacuje globalnu varijablu (sql upit npr REMOTE 'SysVijenac'), ovo je potrebno za kad se vrsi upit u datapointe udaljenog sistema
string insert_Remote_SystemName_into_global_variable(string sSelect)
{
  //ako nema sysName (sSystemName) ne ubacuj djaba "REMOTE ''"
  if(strlen(sSystemName) <= 1)
    return "";
  
  int iPos = strpos(sSelect, "WHERE", 0);
  DebugFTN("level2", "before insert: " + sSelect);
  string sInsert = "REMOTE '" + sSystemName + "' ";
  DebugFTN("level2", "sInsert: " + sInsert);
  strchange(sSelect, iPos, 0, sInsert);
  DebugFTN("level2", "after insert", sSelect);
  return sSelect;
}

string insert_cameras_into_select_string(string sSelect)
{
  DebugFTN("level2", "sSelect before: ", sSelect);
  int iPoss = strpos(sSelect, "FROM '{}'", 0);
  strchange(sSelect, iPoss + strlen("FROM '{"), 0, sCameras);
  DebugFTN("level2", "sSelect after: ", sSelect);
  return sSelect;
}

string insert_alarmMonitors_into_select_string(string sSelect)
{
  DebugFTN("level2", "sSelect before: ", sSelect);
  int iPoss = strpos(sSelect, "FROM '{}'", 0);
  strchange(sSelect, iPoss + strlen("FROM '{"), 0, sAlarmMonitors);
  DebugFTN("level2", "sSelect after: ", sSelect);
  return sSelect;
}

work(anytype userData, dyn_dyn_anytype val)
{
  int i;
  DebugFTN("level1","Callback:", dynlen(val), userData);

  // uzima samo zadnji iz liste zato sto u nekim slucajevima posalje vise alerta za istu promjenu jednog DP-a sto pravi lazne alerte
    int iLastInArray = dynlen(val);
    //kad pukne veza prema distribuiranom sistemu dobije odgovor kao da je doslo do promjene neke od vrijednosti, ali lista tih vrijednosti dodje prazna. U ovom slucaju ne radi nista.
    if(iLastInArray == 0)
      return;
    
    string sDPE = val[iLastInArray][1];
    string sDPName = dpSubStr(sDPE, DPSUB_DP_EL);  //DPSUB_DP - 
    string sDP = dpSubStr(sDPE, DPSUB_DP);  //DPSUB_DP - 
    string sSys_DP = dpSubStr(sDPE, DPSUB_SYS_DP);  //DPSUB_DP - 
    
    //samo za provjeru sta dobavlja
    DebugFTN("level2", "DPName: " + sDPName); 
    DebugFTN("level2", "DP: " + sDP); 
    DebugFTN("level2", "DPE: " + sDPE); 
    DebugFTN("level2", "SYS_DP: " + sSys_DP); 
        
    
    atime At; 
    time ti;
    int PriorRange;
    bool visible;
  
    //Provjera da li je stavrno bila promjena stanja Alerta
    int iRet1 = dpGet(sDPE+":_online.._stime", ti, sDPE+":_alert_hdl.._act_range", PriorRange);  
    At= makeATime(ti, 0, sDPE);    
    int iRet2 = alertGet(At, getACount(At), sDPE+":_alert_hdl."+PriorRange+"._visible", visible);
    DebugFTN("level2", "dpGet(" + sDPE+":_online.._stime", sDPE+":_alert_hdl.._act_range" + ")", "iRest1 = " + iRet1);   
    DebugFTN("level2", "alertGet(" + At, getACount(At), sDPE+":_alert_hdl."+PriorRange+"._visible" + ")", "iRest2 = " + iRet2);
    
    
    DebugFTN("level1","DPEName: " + sDPE + ", Visible = " + visible); 
    
    dyn_dyn_anytype lAlarmMonitors = get_detailed_list_of_AlarmMonitors();
    
    string sAlert_Camera_Ip = get_camera_IP_by_DP(sSys_DP);
        
    //ako se pojavio Alert postavi na Alarmni monitor kameru
    if(visible)
    {
      bool bState;
      int rc = dpGet(sDPE, bState);
       if(bState)
      {
        //ako je vec postavljena kamera na Alarmni Monitor ne radi nista
        bool bAllready_on_AM = is_camera_on_Alarm_Monitor(sAlert_Camera_Ip, lAlarmMonitors);    
        DebugFTN("level1","Camera is allready on Alarm Monitor = " + bAllready_on_AM);
        if(bAllready_on_AM)
          return;
      
        bool bWrongWay = is_wrongWay(sDPE);
        if(bWrongWay)
          set_cameras_for_wrongWay(sAlert_Camera_Ip, lAlarmMonitors);
        else
          set_camera_on_first_empty_Alarm_Monitor(sAlert_Camera_Ip, lAlarmMonitors);
      }
    }
    //skini sa alarmnog monitora kameru
    else
    {      
      bool bWrongWay = is_wrongWay(sDPE);
      alert_cleared(lAlarmMonitors, sAlert_Camera_Ip, sSys_DP, bWrongWay);
    }
    
    get_list_of_AlarmMonitors();
}


//returns list of AlarmMonitors along with its camera Ips that they should show.
dyn_dyn_anytype get_list_of_AlarmMonitors()
{
  //string sSelect = "SELECT '_original.._value' FROM 'AlarmMonitor2*.commands.cameraIP' WHERE (_DPT = \"Milestone\") & (_DP != \"AlarmMonitor2\")";
  string sSelect = sSelectAlarmMonitors;
  dyn_dyn_anytype list;
  int i, iVal;
  string sVal;
  int iRes = dpQuery(sSelect, list);
  DebugFTN("level2", "get_list_of_AlarmMonitors -- sSelect: ", sSelect, "iRes" + iRes, "length(list) = " + dynlen(list));
  string dpe;

   //logiranje za debagiranje    
  
  for(i = 2; i<=dynlen(list); i++)
  {
    dpe = list[i][1];
//    iVal = list[i][2];
    sVal = list[i][2];
    DebugFTN("level1",dpe + "  -- " + sVal);    
  }
  return list;  
}

//returns list of AlarmMonitors along with its camera Ips that they should show.
dyn_dyn_anytype get_detailed_list_of_AlarmMonitors()
{
//  string sSelect = "SELECT '.commands.cameraIP:_original.._value','.commands.index:_original.._value','.commands.reserved:_original.._value' FROM 'AlarmMonitor2*' WHERE (_DPT = \"Milestone\") & (_DP != \"AlarmMonitor2\") SORT BY 2";  
  string sSelect = sAlarmMonitorsDetailedList;
  dyn_dyn_anytype list;
  int i, iIP, iIndex;
  string sIP;
  int iRes = dpQuery(sSelect, list);
  DebugFTN("level2", "get_detailed_list_of_AlarmMonitors -- sSelect: ", sSelect, "iRes" + iRes, "length(list) = " + dynlen(list));
  bool bReserved;
  
  /*
  dyn_errClass d_err;
  d_err = getLastError();
  if(dynlen(d_err)>0)
      throwError(d_err);  
    */  
  
  string dpe;

  
   //logiranje za debagiranje    
  //DebugFTN("level2", list);
  for(i = 2; i<=dynlen(list); i++)
  {
    dpe = list[i][1];
    //iIP = list[i][2];
    sIP = list[i][2];
    iIndex = list[i][3];
    bReserved = list[i][4];   
    DebugFTN("level1",dpe + "  - index = "+ iIndex + ", resrved = " + bReserved + ", iIP = " + sIP);    
  }
  
  return list;  
}

//retruns true if specific camera Ip is allready on AlarmMonitor
bool is_camera_on_Alarm_Monitor(string sAlertCameraIp, dyn_dyn_anytype lAlarmMonitors)
{
  int i;     
  for(i = 2; i<=dynlen(lAlarmMonitors); i++)
  {
    string dpe;
    string sIp;
    dpe = lAlarmMonitors[i][1];    
    sIp = lAlarmMonitors[i][2];
        
    if(sIp == sAlertCameraIp)
      return true;
  }
  return false;
}

string get_camera_IP_by_DP(string sSysDP)
{
  DebugFTN("level1", "get_camera_IP_by_DP -- sSysDP: " + sSysDP);
  int iCameraIp;  
  string sCameraIp;
  string x;
  int rc = dpGet(sSysDP + ".ip", sCameraIp);
  x=substr(sCameraIp, 9);
  iCameraIp = (int)x;  
  
  DebugFTN("level1", "rc = " + rc + ", Ip = " + sCameraIp);
  return sCameraIp;
  
}

void set_camera_on_first_empty_Alarm_Monitor(string sCamera_IP, dyn_dyn_anytype lAlarmMonitors)
{
  int i;     
  bool bFound_empty_AlarmMonitor = false;
  //ovdje se moze dodati umjesto donje petlje upit u bazu da vrati AlarmMonitore koji imaju camareIP == 0
  for(i = 2; i<=dynlen(lAlarmMonitors); i++)
  {
    string dpe = lAlarmMonitors[i][1];
    string sIp = lAlarmMonitors[i][2];
    bool bReserved = lAlarmMonitors[i][4];
      
    DebugFTN("level2", "sIP = " + sIp + ", bReserved = " + bReserved);  
    if((strlen(sIp) <= 1) && (bReserved == false))    
    {
      set_AlarmMonitorDP_by_name(dpe, sCamera_IP, false);
      bFound_empty_AlarmMonitor = true;
      //return;
      break;
    }
  }
  //svi alarmni monitori su zauzeti pocni FIFO da rotiras
  if(!bFound_empty_AlarmMonitor)
  {
    if(bFIFO)
      insert_last_Alert_FIFO(sCamera_IP, lAlarmMonitors);  //izbaci najstariji alarm zarotiraj sve kamere prema njemu i na zadnje mjesto ubaci zadnji alarm
    else
      insert_last_Alert_on_oldest_alert_AlarmMonitor(sCamera_IP); //stavi na mjesto najstarijeg alarma;
  }
}


//void set_AlarmMonitorDP_by_ID(int iAlarmMonitorId, int iIP)
void set_AlarmMonitorDP_by_ID(int iAlarmMonitorId, string sIP)
{
//  string sDP = "System1:" + sAlarmMonitor_base_Name + iAlarmMonitorId + ".commands.cameraIP" ;
  string sDP = sSystemName + ":" + sAlarmMonitor_base_Name + iAlarmMonitorId + ".commands.cameraIP" ;
  
  //dpSet("System1:AlarmMonitor21.commands.cameraIP",iIP);
  DebugFTN("level1","IP za " + sAlarmMonitor_base_Name + iAlarmMonitorId + " postavljen na: ",sIP);
  dpSet(sDP,sIP);  
}

//set Alarm Monitor to show CameraIP
//void set_AlarmMonitorDP_by_name(string sAlarmMonitor_Name, int iIP, bool bReserve)
void set_AlarmMonitorDP_by_name(string sAlarmMonitor_Name, string sIP, bool bReserve)
{  
  DebugFTN("level1","set_AlarmMonitorDP_by_name -- sAlarmMonitor_Name: ", sAlarmMonitor_Name, ", sIP: " + sIP, ", bReserve: " + bReserve);
  string sAlarmMonitor_Name_IP = sAlarmMonitor_Name + ".commands.cameraIP";
  string sAlarmMonitor_Name_Reserved = sAlarmMonitor_Name + ".commands.reserved";
  DebugFTN("level1","IP za " + sAlarmMonitor_Name + " postavljen na: ",sIP);
  dpSet(sAlarmMonitor_Name_IP,sIP,sAlarmMonitor_Name_Reserved,bReserve);  
}


// sIP - full IP address of camera whose Alert was cleared
// alarmMonitorList - list of alarmMonitors and cameras that they are showing
void alert_cleared(dyn_dyn_anytype alarmMonitorList, string sIP, string sAlert_Sys_DP, bool bWrongWay)
{

  DebugFTN("level1","alert_cleared: -- sIP: " + sIP);

  dyn_dyn_anytype list_of_alerts;
  //ova lista ce trebati ako se budu cistili alarmniDisplay-i od pogresnog smjera
  if(bWrongWay)
  {
    list_of_alerts = get_all_active_Alerts();
  }
  
  //prvo provjeri imali jos alarma na istoj kameri, ako ima nista ne mijenjaj
  bool more_Alerts_on_this_Camera = is_there_more_alerts_on_this_camera(sAlert_Sys_DP);  
  if(more_Alerts_on_this_Camera)
  {
    if(bWrongWay)
    {
      dyn_dyn_anytype wrongWay_List = check_if_there_is_wrongWay();
      if(dynlen(wrongWay_List) < 2)  //nema vise wrongWay alarma
      {
        clear_wrongWay_AlarmMonitors(alarmMonitorList, list_of_alerts);
        alarmMonitorList = get_detailed_list_of_AlarmMonitors();
        //set_camera_on_first_empty_Alarm_Monitor(iIP, alarmMonitorList);
      }
    }
     return; 
  }        
  
  int i;
  for(i = 2; i <= dynlen(alarmMonitorList); i++)
  {
    if(alarmMonitorList[i][2] == sIP)
    {
      string dpe = alarmMonitorList[i][1];
      //set_AlarmMonitorDP_by_name(dpe, 0);         
      
      if(bWrongWay)
      {
          clear_wrongWay_AlarmMonitors(alarmMonitorList, list_of_alerts);
          alarmMonitorList = get_detailed_list_of_AlarmMonitors();
      }
     //ovaj dio postavlja na mjesto obrisanog alarma neki od starih alarma
      if(!bFIFO)
      {
      //to smo zamjenili sa FIFO metodom    
        //dyn_dyn_anytype list_of_alerts = get_all_active_Alerts();
        string sCamera_IP = get_active_Alert_not_on_AlarmMonitors(alarmMonitorList, list_of_alerts);
        set_AlarmMonitorDP_by_name(dpe, sCamera_IP, false);
      }
      else      
      //zarotiraj kamere ulijevo da popune prazno mjesto na AlarmomMonitoru
        defragment_AlarmMonitors(alarmMonitorList, i);      
      
      return;
    }
  }
}


//returns IP of first (looking by camera name) active Alert that is not shown on any of AlarmMonitors
string get_active_Alert_not_on_AlarmMonitors(dyn_dyn_anytype alarmMonitor_list, dyn_dyn_anytype list_of_Alerts)
{
  int i,k, iIP = 0;
  string dpe;
  string sIP;
  bool bIp_on_AlarmMonitors = false;
      
  for(i=2; i <= dynlen(list_of_Alerts); i++)
  {
    bIp_on_AlarmMonitors = false;
    for(k=2; k <= dynlen(alarmMonitor_list); k++)
    {
      dpe = list_of_Alerts[i][1];
      dpe = dpSubStr(dpe, DPSUB_SYS_DP);  //DPSUB_DP - 

      /*
      dpGet(dpe + ".ip", sIP);
      string sTempIP;
      sTempIP = substr(sIP, 9);
      iIP = (int) sTempIP;
      */
      sIP = get_camera_IP_by_DP(dpe);
      
      DebugFTN("level1",dpe + ", iIP: " + sIP + ", AM_IP: " + alarmMonitor_list[k][2]);
      if(sIP == alarmMonitor_list[k][2])
      {
        bIp_on_AlarmMonitors = true;
        break;
      }
    }
    if(bIp_on_AlarmMonitors == false)
      return sIP;
    else
      sIP = 0;
  }
  return sIP;
}

//returns list of all active Alerts
// Paznja!!! - Zasad ovo prikazuje sve alarme i u Vijencu i na Zaobilaznici - ako se vide ti systemi
dyn_dyn_anytype get_all_active_Alerts()
{
  string dpe;
  time ti;
  int iVal2;
  int i;
  //string sSelect = "SELECT '_alert_hdl.._visible' FROM 'K*.' WHERE (_DPT = \"camera\") && ('_alert_hdl.._visible' ==1)";
  //string sSelect = "SELECT ALERT '_alert_hdl.._visible' FROM 'K*.*:' REMOTE '" + sSystemName + "' WHERE (_DPT = \"camera\")";
  string sSelect = "SELECT ALERT '_alert_hdl.._visible' FROM '{" + sCameras + "}' REMOTE '" + sSystemName + "' WHERE (_DPT = \"camera\")";
  
  dyn_dyn_anytype list;
  int iRes = dpQuery(sSelect, list);
  DebugFTN("level2", "get_all_active_Alerts -- sSelect: ", sSelect, "iRes" + iRes, "length(list) = " + dynlen(list));

   //logiranje za debagiranje  
  for(i = 2; i<=dynlen(list); i++)
  {
    dpe = list[i][1];
    ti = list[i][2];
    iVal2 = list[i][3];
    DebugFTN("level1", dpe + "  -- " + iVal2);    
  }
  
  return list;
}

bool is_there_more_alerts_on_this_camera(string sSys_DP)
{
  string dpe;
  time ti;
  int iVal2;
  int i;
  bool bResult = false;
  //string sSelect = "SELECT '_alert_hdl.._visible' FROM 'K*.' WHERE (_DPT = \"camera\") && ('_alert_hdl.._visible' ==1)";
  //string sSelect = "SELECT ALERT '_alert_hdl.._visible' FROM 'K*.*:' WHERE (_DPT = \"camera\")";
  string sSelect = "SELECT ALERT '_alert_hdl.._visible' FROM '" + sSys_DP + ".*:' REMOTE '" + sSystemName + "'WHERE (_DPT = \"camera\")";  
  
  dyn_dyn_anytype list;
  int iRes = dpQuery(sSelect, list);
  DebugFTN("level2", "is_there_more_alerts_on_this_camera -- sSelect: ", sSelect, "iRes" + iRes, "length(list) = " + dynlen(list));

   //logiranje za debagiranje    
  for(i = 2; i<=dynlen(list); i++)
  {
    dpe = list[i][1];
    ti = list[i][2];
    iVal2 = list[i][3];
    DebugFTN("level1", dpe + "  -- " + iVal2);       
  }
  
  if(dynlen(list)>1)
    bResult = true;
  else
    bResult = false;
    
  DebugFTN("level1", "is_there_more_alerts_on_this_camera: " + bResult);
  return bResult;
}

//prebaci ulijevo sve kamere prema upraznjenom mjestu
void defragment_AlarmMonitors(dyn_dyn_anytype alarmMonitor_list, int iIndex_of_cleared_AlamMonitor)    
{  
  if(iIndex_of_cleared_AlamMonitor > dynlen(alarmMonitor_list))
  {
    throwError("iIndex_of_cleared_AlamMonitor = " + iIndex_of_cleared_AlamMonitor + " >  dynlen(alarmMonitor_list) = " + dynlen(alarmMonitor_list));
    return;
  }
  
  /*  //ovo ce trebati vratiti ali prije toga provjeriti ima li jos WronWay alarma - ako nema ponistiti rezervaciju
  //ako je rezervisan Alarm moitor nista ne radi
  bool bAlarmMonitor_reserved = alarmMonitor_list[iIndex_of_cleared_AlamMonitor][4];
  if(bAlarmMonitor_reserved)
    return;
    */

  int k;  
  for(k = iIndex_of_cleared_AlamMonitor; k <= dynlen(alarmMonitor_list); k++)
  {
    if(k<dynlen(alarmMonitor_list))
    {
      //ne radi nista ako su oba AlarmMonitora prazna 
      if((alarmMonitor_list[k][2] == 0) && (alarmMonitor_list[k+1][2] ==0))
        continue;
      set_AlarmMonitorDP_by_name(alarmMonitor_list[k][1],alarmMonitor_list[k+1][2], false);   
    }
    else
      set_AlarmMonitorDP_by_name(alarmMonitor_list[k][1], 0, false);    
  }    
}

//izbaci najstariji alarm zarotiraj sve kamere prema njemu i na zadnje mjesto ubaci zadnji alarm
void insert_last_Alert_FIFO(string sCamera_IP, dyn_dyn_anytype alarmMonitor_list)
{
  int k;  
  for(k = 2; k <= dynlen(alarmMonitor_list); k++)
  {
    if(k<dynlen(alarmMonitor_list))
    {
      //ne radi nista ako je AlarmMonitor rezervisan 
      if(alarmMonitor_list[k][4] == true)
        continue;
      set_AlarmMonitorDP_by_name(alarmMonitor_list[k][1],alarmMonitor_list[k+1][2], false);   
    }
    else  
      set_AlarmMonitorDP_by_name(alarmMonitor_list[k][1], sCamera_IP, false);    
  }
}

//stavi na mjesto najstarijeg alarma;
void insert_last_Alert_on_oldest_alert_AlarmMonitor(string sCamera_IP)
{
  int i,k;  
  dyn_dyn_anytype alarmMonitor_list;
  string sSelect = sAlarmMonitorsDetailedList_order_by_time;
  string dpe;
  int iIP, iIndex;
  time ti;
  int iRes = dpQuery(sSelect, alarmMonitor_list);


 /*  //logiranje za debagiranje  
  DebugTN("is_there_more_alerts_on_this_camera - iRes = " + iRes);  
  for(i = 2; i<=dynlen(alarmMonitor_list); i++)
  {
    dpe = alarmMonitor_list[i][1];
    iIP = alarmMonitor_list[i][2];
    iIndex = alarmMonitor_list[i][3];
    bReserved = alarmMonitor_list[i][4];   
    ti = alarmMonitor_list[i][5]; 
    DebugTN(dpe + "  - index = "+ iIndex + ", resrved = " + bReserved + ", iIP = " + iIP); 
    DebugTN(ti);    
  }
  */
        
  for(k = 2; k <= dynlen(alarmMonitor_list); k++)
  {
    if(k<dynlen(alarmMonitor_list))
    {
      //ne radi nista ako je AlarmMonitor rezervisan 
      if(alarmMonitor_list[k][4] == true)
        continue;
      set_AlarmMonitorDP_by_name(alarmMonitor_list[k][1], sCamera_IP, false);    
      return;
    }        
  }
}


bool is_wrongWay(string sAlert)
{
  int pos = -1;  
  string sGhost_driver = "Ghost_driver";
  bool bResult = false;
 
  pos = strpos(sAlert, sGhost_driver);
  if (pos > -1)
    bResult =  true;
  DebugFTN("level2", "is_wrongWay: " + bResult);
  return bResult;
}

//void set_cameras_for_wrongWay(int iAlert_Camera_Ip, dyn_dyn_anytype lAlarmMonitors) 
void set_cameras_for_wrongWay(string sAlert_Camera_Ip, dyn_dyn_anytype lAlarmMonitors) 
{
  int i,k;
  if(dynlen(lAlarmMonitors) < iNumber_of_AlarmMonitors_to_reserve_for_wrongWay)
  {
    throwError("Veci je broj monitora za rezervaciju od broja raspolozivih alarmnih monitora");
    return;
  }
  int iAlert_Camera_index = getCamera_index_by_IP(sAlert_Camera_Ip);
  string sIP;
  for(i=0; i < iNumber_of_AlarmMonitors_to_reserve_for_wrongWay; i++)
  {
    string sAlarmMonitorName = lAlarmMonitors[i+2][1];  //name
    
    if(i < iNumber_of_AlarmMonitors_inFront_of_Alarm)
    {
      //postavi sliku prije alarma
      int iIndex = iAlert_Camera_index - iNumber_of_AlarmMonitors_inFront_of_Alarm + i;
      sIP = getCamera_IP_by_index(iIndex);
      set_AlarmMonitorDP_by_name(sAlarmMonitorName, sIP, true);
      
    }
    else if(i == iNumber_of_AlarmMonitors_inFront_of_Alarm)
    {
    //postavi sliku od alarma
      set_AlarmMonitorDP_by_name(sAlarmMonitorName, sAlert_Camera_Ip, true);      
    }
    else if(i > iNumber_of_AlarmMonitors_inFront_of_Alarm)
    {
//      postavi sliku poslije alarma
      int iIndex = iAlert_Camera_index - iNumber_of_AlarmMonitors_inFront_of_Alarm + i;
      sIP = getCamera_IP_by_index(iIndex);
      set_AlarmMonitorDP_by_name(sAlarmMonitorName, sIP, true);       
    }
    
    /*     //ovo bi trebalo da radi umjesto onih If i ELSE if iznad
    //postavi sliku prije alarma
      int iIndex = iAlert_Camera_index - iNumber_of_AlarmMonitors_inFront_of_Alarm + i;
      iIP = getCamera_IP_by_index(iIndex);
      set_AlarmMonitorDP_by_name(sAlarmMonitorName, iIP, true);
      */
  }
  
}


dyn_dyn_anytype get_detailed_list_of_cameras()
{
  string sSelect = "SELECT 'ip:_original.._value', 'index:_original.._value' FROM '{" + sCameras + "}' REMOTE '" + sSystemName + "' WHERE _DPT = \"camera\" SORT BY 2";  
  dyn_dyn_anytype list;
  int i, iIndex;
  int iRes = dpQuery(sSelect, list);  
  DebugFTN("level2", "get_detailed_list_of_cameras -- sSelect: ", sSelect, "iRes" + iRes, "length(list) = " + dynlen(list));
  string sIP;
  
  /*
  dyn_errClass d_err;
  d_err = getLastError();
  if(dynlen(d_err)>0)
      throwError(d_err);  
    */  
  
  string dpe;

  
   //logiranje za debagiranje  
  DebugFTN("level1","iRes = " + iRes);  
  //DebugTN(list);
  for(i = 2; i<=dynlen(list); i++)
  {
    dpe = list[i][1];
    sIP = list[i][2];
    iIndex = list[i][3];
    DebugFTN("level1",dpe + "  - index = "+ iIndex + ", iIP = " + sIP);    
  }
  
  return list;  
}


string getCamera_IP_by_index(int iIndex)
{
  //string sSelect = "SELECT 'ip:_original.._value', 'index:_original.._value' FROM '{K1,K2,K3,K4,K5,K6}' WHERE _DPT = \"camera\" AND  'index:_original.._value' == 2";
  string sSelect = "SELECT 'ip:_original.._value', 'index:_original.._value' FROM '{" + sCameras + "}' REMOTE '" + sSystemName + "' WHERE _DPT = \"camera\" AND  'index:_original.._value' == " + iIndex;    
  dyn_dyn_anytype list;
  int iRes = dpQuery(sSelect, list);
  DebugFTN("level2", "getCamera_IP_by_index -- sSelect: ", sDetailedListOfCameras, "iRes" + iRes, "length(list) = " + dynlen(list));
  string dpe, x, sIP;
  int iCameraIp ;
  
  /*  //za debugiranje
  int i, iIndex;
  for(i = 2; i<=dynlen(list); i++)
  {
    dpe = list[i][1];
    sIP = list[i][2];
    iIndex = list[i][3];
    DebugTN(dpe +  " - iIP = " + sIP + ", index = " + iIndex);    
  }
  */
  
  if(dynlen(list) >= 2)
  {  //vrati prvi iz liste, ako oh slucajno dobavi vise od jednog
    sIP = list[2][2];  
  }
  //return iCameraIp;
  DebugFTN("level1", "getCamera_IP_by_index -- sIP: " + sIP, "iIndex: " + iIndex);
  return sIP;
}

int getCamera_index_by_IP(string sIP)
{  
//  string sSelect = "SELECT 'ip:_original.._value', 'index:_original.._value' FROM '{" + sCameras + "}' WHERE _DPT = \"camera\" AND  'ip:_original.._value' == \"" + sIP_base + iIP + "\"";
    string sSelect = "SELECT 'ip:_original.._value', 'index:_original.._value' FROM '{" + sCameras + "}' REMOTE '" + sSystemName + "' WHERE _DPT = \"camera\" AND  'ip:_original.._value' == \"" + sIP + "\"";
  dyn_dyn_anytype list;
  int iRes = dpQuery(sSelect, list);
  string dpe, x, sIPaddress;
  int iCameraIp, iIndex;
  DebugFTN("level2", "sSelect: " + sSelect);
  DebugFTN("level2", "iRes = "+ iRes);
  
  /*  //za debugiranje
  int i;
  for(i = 2; i<=dynlen(list); i++)
  {
    dpe = list[i][1];
    sIPaddress = list[i][2];
    iIndex = list[i][3];
    DebugTN(dpe +  " - iIP = " + sIP + ", index = " + iIndex);    
  }
  */

  //vrati prvi iz liste, ako oh slucajno dobavi vise od jednog  
  if(dynlen(list) >= 2)
    iIndex = list[2][3]; 

  DebugFTN("level1", "getCamera_index_by_IP -- sIP: " + sIP + ", index: " + iIndex);
  
  return iIndex;
}

dyn_dyn_anytype check_if_there_is_wrongWay()
{
  //string sSelect = "SELECT 'ip:_original.._value', 'index:_original.._value' FROM '{" + sCameras + "}' WHERE _DPT = \"camera\" AND  'ip:_original.._value' == \"" + sIP_base + iIP + "\"";  
  string sSelect = "SELECT 'Ghost_driver:_original.._value', 'ip:_original.._value' FROM '{" + sCameras + "}' REMOTE '" + sSystemName + "'WHERE _DPT = \"camera\" AND  'Ghost_driver:_original.._value' == 1";  
  dyn_dyn_anytype list;
  int iRes = dpQuery(sSelect, list);
  DebugFTN("level2", "check_if_there_is_wrongWay -- sSelect: ", sSelect, "iRes" + iRes, "length(list) = " + dynlen(list));
  string dpe, x, sIP;
  int iCameraIp, iIndex;
  
  /*  //za debugiranje
  int i;
  for(i = 2; i<=dynlen(list); i++)
  {
    dpe = list[i][1];
    sIP = list[i][2];
    iIndex = list[i][3];
    DebugTN(dpe +  " - iIP = " + sIP + ", index = " + iIndex);    
  }
  */   
  
  return list;
}

//ako ima neki drugi aktivan alarm postavlja ga na mjesto gdje je bio ocisceni alarm, ako ne cisti alarmni Monitor
void clear_wrongWay_AlarmMonitors(dyn_dyn_anytype lAlarmMonitors, dyn_dyn_anytype list_of_alerts)
{
  int k;  
  if(iNumber_of_AlarmMonitors_to_reserve_for_wrongWay <= dynlen(lAlarmMonitors))
  for(k = 2; k <= iNumber_of_AlarmMonitors_to_reserve_for_wrongWay; k++)
  {
      string sIP = get_active_Alert_not_on_AlarmMonitors(lAlarmMonitors, list_of_alerts);
      //set_AlarmMonitorDP_by_name(lAlarmMonitors[k][1], 0, false);    
      set_AlarmMonitorDP_by_name(lAlarmMonitors[k][1], sIP, false);  
      lAlarmMonitors = get_detailed_list_of_AlarmMonitors();  
  }
}
