//-dbg "level1" - za debugiranje
#uses "CtrlXmlRpc"
#uses "dp_set_delay.ctl"

int main() 
{
   dpQueryConnectSingle("work", true, "Identi", 
                       "SELECT '_original.._value' FROM '*.state.vrata' WHERE _DPT = \"Nisa\"");   

    dpQueryConnectSingle("timer", true, "Identi", 
                      "SELECT '_original.._value' FROM '*.state.timer_15_min' WHERE _DPT = \"Nisa\"");    
  
    dpConnect("kolskiProlazDesni", "SysSarani:EP2-D.state.pokrenuto_otvaranje", "SysSarani:EP2-D.state.pokrenuto_zatvaranje",
                              "SysSarani:EP2-D.state.vrata_otvorena", "SysSarani:EP2-D.state.vrata_zatvorena", "SysSarani:EP2-D.state.prelazno_stanje");//,
                              //"SysSarani:EP2-L.state.vrata_u_otvaranju", "SysSarani:EP2-L.state.vrata_u_zatvaranju");  
    
    dpConnect("kolskiProlazLijevi", "SysSarani:EP2-L.state.pokrenuto_otvaranje", "SysSarani:EP2-L.state.pokrenuto_zatvaranje",
                              "SysSarani:EP2-L.state.vrata_otvorena", "SysSarani:EP2-L.state.vrata_zatvorena", "SysSarani:EP2-L.state.prelazno_stanje");
}

kolskiProlazDesni(string dp1, bool desna_u_otvaranju, string dp2, bool desna_u_zatvaranju,
             string dp3, bool desna_otvorena, string dp4, bool desna_zatvorena, string dp5, bool prelazno_stanje) {
  
  if (desna_u_otvaranju && !desna_otvorena) {
      dpSet("SysSarani:EP2-D.state.vrata_u_otvaranju", 1);
  }
  else if (desna_otvorena && !prelazno_stanje) {
    dpSet("SysSarani:EP2-D.state.vrata_u_otvaranju", 0);
  }
  
  if (desna_u_zatvaranju && !desna_zatvorena) {
      dpSet("SysSarani:EP2-D.state.vrata_u_zatvaranju", 1);
  }
  else if (desna_zatvorena && !prelazno_stanje) {
    dpSet("SysSarani:EP2-D.state.vrata_u_zatvaranju", 0);
  }
}

kolskiProlazLijevi(string dp1, bool lijeva_u_otvaranju, string dp2, bool lijeva_u_zatvaranju,
             string dp3, bool lijeva_otvorena, string dp4, bool lijeva_zatvorena, string dp5, bool prelazno_stanje) {
  
  if (lijeva_u_otvaranju && !lijeva_otvorena) {
      dpSet("SysSarani:EP2-L.state.vrata_u_otvaranju", 1);
  }
  else if (lijeva_otvorena && !prelazno_stanje) {
    dpSet("SysSarani:EP2-L.state.vrata_u_otvaranju", 0);
  }
  
  if (lijeva_u_zatvaranju && !lijeva_zatvorena) {
      dpSet("SysSarani:EP2-L.state.vrata_u_zatvaranju", 1);
  }
  else if (lijeva_zatvorena && !prelazno_stanje) {
    dpSet("SysSarani:EP2-L.state.vrata_u_zatvaranju", 0);
  }
}


work (anytype ident, dyn_dyn_anytype list) {
  string dpe;
  dyn_int value;
  
  for(int i = 2; i <= dynlen(list); i++)  //starta sa 2 zato sto liste pocinju od 1, a sql upit vraca u prvoj liniji header pa treba i njega preskociti
  {    
    value = list[i][2];
    dpe = list[i][1];
    dpe = dpSubStr(dpe, DPSUB_DP);  //DPSUB_DP - 
    int thId = startThread("pratiVrata", dpe);
    int thId2 = startThread("podesiBljeskalicu", dpe);
//     waitThread(thId);
//     waitThread(thId2);
  } 
}

podesiBljeskalicu (string nazivNise) {
  bool status;
  string sys_name = "SysSarani:";
  
  dpGet(sys_name + nazivNise + ".state.vrata", status);
  
  if (!status) {
    dpSet(sys_name + nazivNise + ".cmd.run.osvjetljenje_bljeskalica", 1);
    //DebugTN(nazivNise + ": Vrata otvorena, bljeskalica ukljucena");
    delay(1);
    dpSet(sys_name + nazivNise + ".cmd.run.osvjetljenje_bljeskalica", 0);
    //DebugTN(nazivNise + ": Vrata otvorena, bljeskalica iskljucena");
    delay(1);
    podesiBljeskalicu(nazivNise);
  }
  else if (status) {
    //DebugTN(nazivNise + ": Vrata zatvorena, bljeskalica iskljucena");
    dpSet(sys_name + nazivNise + ".cmd.run.osvjetljenje_bljeskalica", 0);
  }
  
  
}

void pratiVrata (string nazivNise)
{
  bool status, timer_15_min;
  string sys_name = "SysSarani:";
  dpGet(sys_name + nazivNise + ".state.vrata", status, sys_name + nazivNise + ".state.timer_15_min", timer_15_min);
//   DebugTN("\ndpe: " + sys_name + nazivNise + ", status: " + status + "\n\n");
  
  if (!status && !timer_15_min) {
    //DebugTN(nazivNise + ": Vrata otvorena, timer ugasen - paljenje svjetla i postavljanje timera na 15 minuta..");
    dpSet(sys_name + nazivNise + ".cmd.sdv.manuelno.ON", 1);
    dpSet(sys_name + nazivNise + ".state.timer_15_min", 1);
    dpSetDelayed(900, sys_name + nazivNise + ".state.timer_15_min", 0);
  }
  
  else if (status && !timer_15_min) {
    //DebugTN(nazivNise + ": Vrata zatvorena, timer ugasen - gasenje svjetla");
    bool svjetlo;
    dpGet(sys_name + nazivNise + ".cmd.sdv.manuelno.ON", svjetlo); 
    if (svjetlo) 
      dpSet(sys_name + nazivNise + ".cmd.sdv.manuelno.ON", 0); 
  }
  
  else if (status && timer_15_min) {
    time t;
    dpGet(sys_name + nazivNise + ".state.timer_15_min:_original.._stime", t);
    
    if ((int)getCurrentTime() - (int)t > 900) {
      dpSet(sys_name + nazivNise + ".state.timer_15_min", 0);
    }
    //Vrata zatvorena, timer aktivan - svjetlo ostaje upaljeno
  }
  
  else if (!status && timer_15_min) {
    time t;
    dpGet(sys_name + nazivNise + ".state.timer_15_min:_original.._stime", t);
    if ((int)getCurrentTime() - (int)t > 900) {
      dpSet(sys_name + nazivNise + ".state.timer_15_min", 1);
      dpSetDelayed(900, sys_name + nazivNise + ".state.timer_15_min", 0);
    }
    dpSet(sys_name + nazivNise + ".cmd.sdv.manuelno.ON", 1); 
   //Vrata otvorena, timer aktivan - svjetlo od ranije upaljeno    
  }
}

timer (anytype ident, dyn_dyn_anytype list) {
  string dpe;
  dyn_int value;
  
  for(int i = 2; i <= dynlen(list); i++)  //starta sa 2 zato sto liste pocinju od 1, a sql upit vraca u prvoj liniji header pa treba i njega preskociti
  {    
    value = list[i][2];
    dpe = list[i][1];
    dpe = dpSubStr(dpe, DPSUB_DP);  //DPSUB_DP - 
    int thId = startThread("pratiTimer", dpe);
    waitThread(thId);
  } 
}

void pratiTimer(string nazivNise) {
  
  bool status, timer_15_min;
  string sys_name = "SysSarani:";
  dpGet(sys_name + nazivNise + ".state.vrata", status, sys_name + nazivNise + ".state.timer_15_min", timer_15_min);
  
  if (!status && !timer_15_min) {
    dpSet(sys_name + nazivNise + ".cmd.sdv.manuelno.ON", 1); 
    //DebugTN(nazivNise + ": Timer istekao, vrata otvorena - svjetlo ostaje upaljeno");    
  }
  
  else if (status && !timer_15_min) {
    dpSet(sys_name + nazivNise + ".cmd.sdv.manuelno.ON", 0); 
    //DebugTN(nazivNise + ": Timer istekao, vrata zatvorena - gasenje svjetla");    
  }
  
  else if (status && timer_15_min) {
    //DebugTN("Timer aktiviran, vrata zatvorena - nemoguce");
  }
  
  else if (!status && timer_15_min) {
    //DebugTN("Timer aktiviran nakon otvaranja vrata");    
  }
}
