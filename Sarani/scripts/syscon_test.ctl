
//Version v1.0.3
//----------------

int min_time_between_reset = 30; //30sec
int max_time_between_reset = 1200; //20min
int iDiff = 10; //vrijeme u sekundama u kojem se klijeti moraju javiti
string sSelect = "SELECT '_original.._stime', '_original.._value' FROM '{V*.cmd.run.nazad_motor,V*.cmd.run.naprijed_motor,V*.cmd.run.pozar}' SORT BY 1 FIRST 1";


main()
{
  delay(5);
  DebugTN("Start script SystemConnections.ctl");
  DebugTN("Ova skripta kontrolise da li se redovno javljaju klijenti. Ako se neki od njih ne javi u " + iDiff + "sec prijavljuje se alarm za njega");
  timedFunc("Check_Ventilators_ctl","CheckVentilators");  
}


check_Max_time_between_reset(time tClientNextRestart, time tManagerNextRestart, string sName)    
{
  time tCurrent_time = getCurrentTime();
  if(tCurrent_time + max_time_between_reset < tManagerNextRestart)
  {    
    time tNextRestart = tCurrent_time + max_time_between_reset;
    dpSet(sName + ".controlManager_nextRestart", tNextRestart);
    DebugFTN("level1", "check_Max_time_between_reset - dpSet() ", sName + ".controlManager_nextRestart = ", tNextRestart);
  }
  
  if(tCurrent_time + max_time_between_reset < tClientNextRestart)
  {
    time tNextRestart = tCurrent_time + max_time_between_reset;
    dpSet(sName + ".client_nextRestart", tNextRestart);
    DebugFTN("level1", "check_Max_time_between_reset - dpSet() ", sName + ".client_nextRestart = ", tNextRestart);
  }
}


Check_Ventilators_ctl(string Blinker,time t1, time t2)
{
  //ako nije aktivan ovaj server, ne radi nista
  DebugTN("Check_Ventilators_ctl 1");
 // if(!isReduActive())
  //  return;
  DebugTN("Check_Ventilators_ctl 2");
  
  bool alive;  
  time currentTime = getCurrentTime();
//  time tTimestamp;
  bool state;
    
  dyn_int diControlScript_Number;
  int iControlManager_Number;
  bool bControlManager_ResetAllowed;
  int iTryCount;
  time tLastRestart;
  time tNextRestart;
  
  bool bClient_ResetAllowed;
  time tClient_LastRestart;
  time tClient_NextRestart;
  int iClient_TryCount;
  dyn_string dsClient_Name;
  
  dyn_errClass err;
  
  string sSysName = getSystemName();
    
  dyn_dyn_anytype list;
  int i;
  bool bVal;
  time tTime;
  int iRes = dpQuery(sSelect, list);
  DebugFTN("level2", "Check_Ventilators_ctl -- sSelect: ", sSelect, "iRes" + iRes, "length(list) = " + dynlen(list));
  string dpe;
  
  err = getLastError();
  if(dynlen(err) > 0)
    DebugTN("SystemConnections.ctl - Check_Ventilators_ctl, dpQuerry err: ", err);

  if(iRes < 0)
    return;
      
  for(i = 2; i<=dynlen(list); i++)
  {
    dpe = list[i][1];
    tTime = list[i][2];
    bVal = list[i][3];
    //logiranje za debagiranje  
    DebugFTN("level2",dpe + "  -- " + bVal, tTime);    
  }
    
  string sVentilator_name = sSysName + "Ventilator.IntegrClient";
  

  dpGet(sVentilator_name + ".alive:_original.._value", alive,
        sVentilator_name + ".controlManager_restartAllowed", bControlManager_ResetAllowed,
        sVentilator_name + ".controlManager_lastRestart", tLastRestart,
        sVentilator_name + ".controlManager_nextRestart", tNextRestart,
        sVentilator_name + ".controlManager_restart_TryCount", iTryCount,
        sVentilator_name + ".control_Script_Number", diControlScript_Number,
          
        sVentilator_name + ".client_restartAllowed", bClient_ResetAllowed,
        sVentilator_name + ".client_lastRestart", tClient_LastRestart,
        sVentilator_name + ".client_nextRestart", tClient_NextRestart,
        sVentilator_name + ".client_restart_TryCount", iClient_TryCount,
        sVentilator_name + ".client_Name", dsClient_Name
        );
  
    
  //int d = currentTime - tTimestamp; // ova razlika je u sekundama
  int d = currentTime - tTime; // ova razlika je u sekundama
    
  if (d > iDiff) 
  {
    //ako se vodi da je ziv promjeni stanje
    if(alive)
    {
      DebugTN("Alive : " + alive + " --> FALSE : " + sVentilator_name);
      //dpSet(sVentilator_name + ".alive:_original.._value", false);
    }
    check_Max_time_between_reset(tClient_NextRestart, tNextRestart, sVentilator_name);
    //startThread("resetControlManager", sVentilator_name, diControlScript_Number, bControlManager_ResetAllowed, iTryCount, tLastRestart, tNextRestart);    
    DebugTN("resetControlManager - ", sVentilator_name,  diControlScript_Number, bControlManager_ResetAllowed, iTryCount, tLastRestart, tNextRestart); 
  }   
  else if (d < iDiff && !alive) {
    DebugTN("Alive : " + alive + " --> TRUE : " + sVentilator_name);
    //kad klijent alive prelazi iz stanja FALSE = > TRUE resetuj brojace i nextRestart vremena 
    dpSet(sVentilator_name + ".alive:_original.._value", true, 
          sVentilator_name + ".controlManager_restart_TryCount",0,
          sVentilator_name + ".controlManager_nextRestart", makeTime(1970,1,2),
          sVentilator_name + ".client_nextRestart", makeTime(1970,1,2),
          sVentilator_name + ".client_restart_TryCount",0); 
  }  
} 



