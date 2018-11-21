
//Version v1.0.4
//----------------

int min_time_between_reset = 30; //30sec
int max_time_between_reset = 1200; //20min
int iDiff = 10; //vrijeme u sekundama u kojem se klijeti moraju javiti
int iDiff_Ventilator_thread = 120; //vrijeme u sekundama u kojem se threadovi za ventilaciju moraju javiti
string sSelect = "SELECT '_original.._stime', '_original.._value' FROM '{V*.cmd.run.nazad_motor,V*.cmd.run.naprijed_motor,V*.cmd.run.pozar}' SORT BY 1 FIRST 1";
string sCopy1 = "cp /home/sarani/BS_Husky_projects/TakovoPreljina/log/PVSS_II.log /home/sarani/logovi/dpConnect_problem/`date +%Y_%m_%d_%H:%M:%S`.log &";
string sCopy2 = "cp /home/sarani/BS_Husky_projects/TakovoPreljina/log/PVSS_II.log.bak /home/sarani/logovi/dpConnect_problem/`date +%Y_%m_%d_%H:%M:%S`.log.bak &";

main()
{
  delay(5);
  DebugTN("Start script SystemConnections.ctl");
  DebugTN("Ova skripta kontrolise da li se redovno javljaju klijenti. Ako se neki od njih ne javi u " + iDiff + "sec prijavljuje se alarm za njega");
  timedFunc("blink","CheckSystems");
  timedFunc("Check_Ventilators_ctl","CheckVentilators");
  timedFunc("ProvjeraSenzoraGabarita_ctl", "provjeraSenzoraGabarita");
  timedFunc("Check_Ventilator_threads_ctl", "CheckVentilator_threads");
}

blink(string Blinker,time t1, time t2)
{
  dyn_dyn_anytype tab;
  int z;
  bool alive;  
  time currentTime = getCurrentTime();
  time tTimestamp;
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
  
  string sSysName = getSystemName();
    
  if(myReduHostNum() == 1)
  {
     tab[1] = makeDynString(sSysName + "SIP_Centrala.IntegrClient");
     tab[2] = makeDynString(sSysName + "Milestone.IntegrClient");
     tab[3] = makeDynString(sSysName + "BrojacPrometa.IntegrClient");
     tab[4] = makeDynString(sSysName + "Meteostanica1.IntegrClient");
     tab[5] = makeDynString(sSysName + "Meteostanica2.IntegrClient");
     tab[6] = makeDynString(sSysName + "Signalizacija.IntegrClient");
     tab[7] = makeDynString(sSysName + "Videodetekcija1.IntegrClient");
     tab[8] = makeDynString(sSysName + "Videodetekcija2.IntegrClient");
     tab[9] = makeDynString(sSysName + "BrojacPrometa.IntegrClient");
     tab[10] = makeDynString(sSysName + "KontrolaPristupa_PS1.IntegrClient");
     tab[11] = makeDynString(sSysName + "KontrolaPristupa_PS2.IntegrClient");
  }
  else
  {
     tab[1] = makeDynString(sSysName + "SIP_Centrala_2.IntegrClient");
     tab[2] = makeDynString(sSysName + "Milestone_2.IntegrClient");
     tab[3] = makeDynString(sSysName + "BrojacPrometa_2.IntegrClient");
     tab[4] = makeDynString(sSysName + "Meteostanica1_2.IntegrClient");
     tab[5] = makeDynString(sSysName + "Meteostanica2_2.IntegrClient");
     tab[6] = makeDynString(sSysName + "Signalizacija_2.IntegrClient");
     tab[7] = makeDynString(sSysName + "Videodetekcija1_2.IntegrClient");
     tab[8] = makeDynString(sSysName + "Videodetekcija2_2.IntegrClient");
     tab[9] = makeDynString(sSysName + "BrojacPrometa_2.IntegrClient");
     tab[10] = makeDynString(sSysName + "KontrolaPristupa_PS1_2.IntegrClient");
     tab[11] = makeDynString(sSysName + "KontrolaPristupa_PS2_2.IntegrClient");
  }
  

  for(z=1;z<=dynlen(tab);z++) {
    dpGet(tab[z] + ".timestamp:_original.._value", tTimestamp, 
          tab[z] + ".alive:_original.._value", alive,
          tab[z] + ".controlManager_restartAllowed", bControlManager_ResetAllowed,
          tab[z] + ".controlManager_lastRestart", tLastRestart,
          tab[z] + ".controlManager_nextRestart", tNextRestart,
          tab[z] + ".controlManager_restart_TryCount", iTryCount,
          tab[z] + ".control_Script_Number", diControlScript_Number,
          
          tab[z] + ".client_restartAllowed", bClient_ResetAllowed,
          tab[z] + ".client_lastRestart", tClient_LastRestart,
          tab[z] + ".client_nextRestart", tClient_NextRestart,
          tab[z] + ".client_restart_TryCount", iClient_TryCount,
          tab[z] + ".client_Name", dsClient_Name
          );
    
    int d = currentTime - tTimestamp; // ova razlika je u sekundama
    
    if (d > iDiff) 
    {
      //ako se vodi da je ziv promjeni stanje
      if(alive)
      {
        DebugTN("Alive : " + alive + " --> FALSE : " + tab[z]);
        dpSet(tab[z] + ".alive:_original.._value", false);
      }
      check_Max_time_between_reset(tClient_NextRestart, tNextRestart, tab[z]);
      startThread("resetControlManager", tab[z], diControlScript_Number, bControlManager_ResetAllowed, iTryCount, tLastRestart, tNextRestart);
      startThread("resetClient", tab[z], dsClient_Name, bClient_ResetAllowed, iClient_TryCount, tClient_LastRestart, tClient_NextRestart);
    }   
    else if (d < iDiff && !alive) {
      DebugTN("Alive : " + alive + " --> TRUE : " + tab[z]);
      //kad klijent alive prelazi iz stanja FALSE = > TRUE resetuj brojace i nextRestart vremena 
      dpSet(tab[z] + ".alive:_original.._value", true, 
            tab[z] + ".controlManager_restart_TryCount",0,
            tab[z] + ".controlManager_nextRestart", makeTime(1970,1,2),
            tab[z] + ".client_nextRestart", makeTime(1970,1,2),
            tab[z] + ".client_restart_TryCount",0); 
    }
  }
}

//provjerava da li je dozvoljeno resetovanje kontrolne skripte
//ako jeste poziva fc za resetovanje
resetControlManager(string sdpName, dyn_int diControlManager_Number, bool bControlManager_ResetAllowed, int iTryCount, time tLastRestart, time tNextRestart)
{  
   DebugFTN("level1", "resetControlManager: " + sdpName, ", iTryCount: " + iTryCount, ", tLastRestart", tLastRestart, ", tNextRestart: ", tNextRestart, ", bControlManager_ResetAllowed: ", bControlManager_ResetAllowed);
   //ako nije dozvoljeno restovanje izadji
   if(!bControlManager_ResetAllowed) 
     return;
   //ako je broj managera manji ili jednak 100 ne radi se o nasoj kontrolnoj skripti, nemoj resetovati 
   //ne restuj niposto sama sebe - broj ove kripte treba da je 100
   int diLen = dynlen(diControlManager_Number);
   if(diLen == 0)
   {
     DebugTN("resetControlManager - diControlManager_Number je prazan!");
     return;
   }
   int i;
   for(i = 1 ; i <= diLen; i++)
   {
     if(diControlManager_Number[i] <= 100)
     return;
   }
               
//   if(iControlManager_Number <= 100)
  //   return;
      
   time currentTime = getCurrentTime();
   time nextResetTime;
   if((tNextRestart < currentTime) && (currentTime - tLastRestart  > min_time_between_reset))
   {     
     iTryCount++;
     nextResetTime = calculate_nextResetTime(iTryCount, currentTime);
     
     //podigni nextRestart i postavi lastRestart     
     dpSet(sdpName + ".controlManager_lastRestart", currentTime, sdpName + ".controlManager_nextRestart", nextResetTime, sdpName + ".controlManager_restart_TryCount", iTryCount);
     DebugFTN("level1", "dpSet() ", sdpName + ".controlManager_lastRestart = ", currentTime, ", " + sdpName + ".controlManager_nextRestart = ", nextResetTime,  ", " + sdpName + ".controlManager_restart_TryCount = " + iTryCount);
     for(i = 1 ; i <= diLen; i++)
     {
       killControlScript_by_number(diControlManager_Number[i]);
     }
     //killControlScript_by_number(iControlManager_Number);
   }   
}


//ubija skriptu sa zadatim brojem managera
killControlScript_by_number(int iControlManagerNum)
{    
  DebugTN("killControlScript_Number: " + iControlManagerNum);
  string sSysName = getSystemName();  
  int imanID = convManIdToInt(CTRL_MAN, iControlManagerNum);
  DebugFTN("level1", "iManNum: " + iControlManagerNum, "imanID: " + imanID);
  
  if(myReduHostNum() == 1)
  {
    dpSet(sSysName + "_Managers.Exit", imanID);  //ubija kontrolnu skriptu  
    DebugTN("set " + sSysName + "_Managers_.Exit: " + imanID);      
  // DebugTN("set " + sSysName + "_Managers_.Exit: " + imanID, "set " + sSysName + "_Managers_.Refresh: " + imanID);      
  //dpSet(sSysName + "_Managers_.Refresh", imanID);  //ako ne bude htjela startati skripta odkomentarisati ovu liniju
  }
  else	//ako je desni redundantni server
  {
    dpSet(sSysName + "_Managers_2.Exit", imanID);  //ubija kontrolnu skriptu  
    DebugTN("set " + sSysName + "_Managers_2.Exit: " + imanID);      
  }
}


//provjerava da li je dozvljeno resetovanje klijenta (obicno je java *.jar app)
//ako jeste poziva fc za resetovanje
resetClient(string sdpName, dyn_string dsClient_Name, bool bClient_ResetAllowed, int iTryCount, time tLastRestart, time tNextRestart)
{  
   DebugFTN("level1", "resetClient: " + sdpName, ", dsClient_Name", dsClient_Name + ", iTryCount: " + iTryCount, ", tLastRestart", tLastRestart, ", tNextRestart: ", tNextRestart);
   //ako nije dozvoljeno restovanje izadji
   if(!bClient_ResetAllowed) 
     return;
   
   int iDynLen = dynlen(dsClient_Name);
   if(iDynLen == 0)
   {
     DebugTN("resetClient - dsClient_Name - client_Name je prazan!");
     return;
   }   
      
   time currentTime = getCurrentTime();
   time nextResetTime;   
   if((tNextRestart < currentTime) && (currentTime - tLastRestart  > min_time_between_reset))   
   {     
     iTryCount++;
     nextResetTime = calculate_nextResetTime(iTryCount, currentTime);

     //podigni nextRestart i postavi lastRestart     
     dpSet(sdpName + ".client_lastRestart", currentTime, sdpName + ".client_nextRestart", nextResetTime, sdpName + ".client_restart_TryCount", iTryCount);
     DebugFTN("level1", "dpSet() ", sdpName + ".client_lastRestart = ", currentTime, ", " + sdpName + ".client_nextRestart = ", nextResetTime, ", " + sdpName + ".client_restart_TryCount = " + iTryCount);
     
     int i;
     for(i = 1 ; i <= iDynLen; i++)
     {
       killClient_by_Name(dsClient_Name[i]);
     }
   }   
}

//ubija klijenta sa zadatim imenom
killClient_by_Name(string sClient_Name)
{
  DebugTN("killClient_by_Name: " + sClient_Name);
  int iRes;
  iRes = system("pkill -f " + sClient_Name);
  DebugTN("killClient_by_Name(" + sClient_Name + ") = " + iRes);
}

//racuna odgodjeno resetovanje
//iTryCount x e2 x min_time_between_reset
// 0   min
// 0,5 min
// 1,5 min
// 4,5 min
// 8,0 min
//12,0 min - ovo je maximalno vrijme odgodjenog resetovanje
time calculate_nextResetTime(int iTryCount, time currentTime)
{  
   if(iTryCount > 5)
     iTryCount = 5 ;
   float tDiff = pow(iTryCount, 2) * min_time_between_reset;
   time nextResetTime = currentTime + tDiff;
   DebugTN("currentTime: ", currentTime, ", tDiff: ", tDiff, ", nextResetTime: ", nextResetTime);
   return nextResetTime;
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
  if(!isReduActive())
    return;
  
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
        
  int d = currentTime - tTime; // ova razlika je u sekundama
    
  if (d > iDiff) 
  {
    //ako se vodi da je ziv promjeni stanje
    if(alive)
    {
      DebugTN("Alive : " + alive + " --> FALSE : " + sVentilator_name);
      dpSet(sVentilator_name + ".alive:_original.._value", false);
    }
    check_Max_time_between_reset(tClient_NextRestart, tNextRestart, sVentilator_name);  
    startThread("resetControlManager", sVentilator_name, diControlScript_Number, bControlManager_ResetAllowed, iTryCount, tLastRestart, tNextRestart);   
    //system(sCopy1); ne treba vise kopiranje logova, jer su logovi cisci
    //system(sCopy2);
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


Check_Ventilator_threads_ctl(string Blinker,time t1, time t2)
{    
  bool alive;  
  time currentTime = getCurrentTime();
  time tTime1; time tTime2;
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
  string sVentilator_Thread_1_name = "grupa_1.control_thread";
  string sVentilator_Thread_2_name = "grupa_2.control_thread";
  string sReduSide = "";
  if(myReduHostNum() != 1)
    sReduSide = "_2";
  dpGet(sSysName + sVentilator_Thread_1_name + sReduSide + ":_original.._stime", tTime1,
        sSysName + sVentilator_Thread_2_name + sReduSide + ":_original.._stime", tTime2);
 
  string sVentilator_name = sSysName + "Ventilator_thread" + sReduSide + ".IntegrClient";
  
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
        
  int d1 = currentTime - tTime1; // ova razlika je u sekundama
  int d2 = currentTime - tTime2; // ova razlika je u sekundama
  int d;
  if(d1 > d2)
    d = d1;
  else
    d = d2;
          
  if (d > iDiff_Ventilator_thread) 
  {
    //ako se vodi da je ziv promjeni stanje
    if(alive)
    {
      DebugTN("Alive : " + alive + " --> FALSE : " + sVentilator_name);
      dpSet(sVentilator_name + ".alive:_original.._value", false);
      dpSet(sSysName + "grupa_1.control_thread_stopped" + sReduSide, currentTime);
    }
    check_Max_time_between_reset(tClient_NextRestart, tNextRestart, sVentilator_name);  
    startThread("resetControlManager", sVentilator_name, diControlScript_Number, bControlManager_ResetAllowed, iTryCount, tLastRestart, tNextRestart);   
    startThread("clear_all_ventilators_flags");   

  }   
  else if (d < iDiff_Ventilator_thread && !alive) {
    DebugTN("Alive : " + alive + " --> TRUE : " + sVentilator_name);
    //kad klijent alive prelazi iz stanja FALSE = > TRUE resetuj brojace i nextRestart vremena 
    dpSet(sVentilator_name + ".alive:_original.._value", true, 
          sVentilator_name + ".controlManager_restart_TryCount",0,
          sVentilator_name + ".controlManager_nextRestart", makeTime(1970,1,2),
          sVentilator_name + ".client_nextRestart", makeTime(1970,1,2),
          sVentilator_name + ".client_restart_TryCount",0); 
  }  
}  

//postavlja ventilatore u rezim rucnog upravljanja i nakon minutu vraca na automatsko
//ovim se ciste flagovi i zaustavljaju ventilatori ako su ostali upaljeni a thread za ventilatore zablokirao
clear_all_ventilators_flags()
{ 
  promijeniRezimUpravljanja(false);
  delay(60);
  promijeniRezimUpravljanja(true);
}

//mijenja Rezim upravljanja svih ventilatorima (true - automastko, false - rucno)
promijeniRezimUpravljanja(bool rezim) {
  string sys_name = getSystemName();
  dpSet(sys_name + "ventilacija_desna_cijev.state.automatsko_upravljanje", rezim);
  dpSet(sys_name + "ventilacija_lijeva_cijev.state.automatsko_upravljanje", rezim);
    
    string query = "SELECT '_original.._value','_online.._stime'  FROM '*.cmd.sdv.manuelno.rezim' WHERE _DPT = \"VENTILATOR\"";
    dyn_dyn_anytype list;
    dpQuery(query, list);
      
    string value, dpe;
    bool bValue;
    time tTime;
    time currentTime = getCurrentTime();
    
    for(int i = 2; i <= dynlen(list); i++) 
    {    
      value = list[i][2];
      bValue = list[i][2];
      tTime =  list[i][3];
      int d1 = currentTime - tTime; // ova razlika je u sekundama
      //slijedece je samo da ne ponistimo rucni rezim ako je bio u njemu prethodno
      //promjeni rezim ako je ventilator u automatskom rezimu i komanda je za manuelni rezim
      if(!bValue && !rezim)
      {
        dpe = list[i][1];
        dpe = dpSubStr(dpe, DPSUB_DP);  
        dpSet(sys_name + dpe + ".cmd.sdv.manuelno.rezim", !rezim);
        continue;
      }
      //promjeni rezim ako je ventilator u manuelnom rezimu krace od 70sec (samo ako smo mi napravili izmjenu kroz ovu skriptu - nadam se da semo mi)
      else if(bValue && (d1 < 70) && rezim)
      {
        dpe = list[i][1];
        dpe = dpSubStr(dpe, DPSUB_DP);  
        dpSet(sys_name + dpe + ".cmd.sdv.manuelno.rezim", !rezim);
        continue;
      }
    }        
}

ProvjeraSenzoraGabarita_ctl(string Blinker,time t1, time t2)
{
  //ako nije aktivan ovaj server, ne radi nista
  if(!isReduActive())
    return;
  
  bool alive;  
  time currentTime = getCurrentTime();


  time timePreljina, timeTakovo;
  dpGet("SysSarani:Preljina_vozilo1.id:_original.._stime", timePreljina);
  dpGet("SysSarani:Takovo_vozilo1.id:_original.._stime", timeTakovo);
  
  DebugFTN("level3", "ProvjeraSenzoraGabarita_ctl");
  

  
   //---------------------------------PRELJINA---------------------------------------------- 
  
  dpGet("SysSarani:SenzorGabarita_Preljina.IntegrClient.alive", alive);
  int razlikaPreljina = currentTime - timePreljina; // ova razlika je u sekundama
    
  if (razlikaPreljina > 43200)   //ako nista nije upisano pola dana
  {
    //ako se vodi da je ziv promjeni stanje
    if(alive)
    {
      DebugTN("Alive : " + alive + " --> FALSE : " + "SenzorGabarita_Preljina");
      dpSet("SysSarani:SenzorGabarita_Preljina.IntegrClient.alive", false);
    }
   }   
  else if (razlikaPreljina < 43200 && !alive) {
    DebugTN("Alive : " + alive + " --> TRUE : " + "SenzorGabarita_Preljina");
    //kad klijent alive prelazi iz stanja FALSE = > TRUE resetuj brojace i nextRestart vremena 
    dpSet("SysSarani:SenzorGabarita_Preljina.IntegrClient.alive", true); 
  }  
  
  
  //---------------------------------TAKOVO----------------------------------------------
    
  dpGet("SysSarani:SenzorGabarita_Takovo.IntegrClient.alive", alive);
  int razlikaTakovo = currentTime - timeTakovo; // ova razlika je u sekundama
    
  if (razlikaTakovo > 43200)   //ako nista nije upisano pola dana
  {
    //ako se vodi da je ziv promjeni stanje
    if(alive)
    {
      DebugTN("Alive : " + alive + " --> FALSE : " + "SenzorGabarita_Takovo");
      dpSet("SysSarani:SenzorGabarita_Takovo.IntegrClient.alive", false);
    }
   }   
  else if (razlikaTakovo < 43200 && !alive) {
    DebugTN("Alive : " + alive + " --> TRUE : " + "SenzorGabarita_Takovo");
    //kad klijent alive prelazi iz stanja FALSE = > TRUE resetuj brojace i nextRestart vremena 
    dpSet("SysSarani:SenzorGabarita_Takovo.IntegrClient.alive", true); 
  }  
}    


