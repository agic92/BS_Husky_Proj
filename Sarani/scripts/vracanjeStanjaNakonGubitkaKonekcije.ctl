//-dbg "level1" - za debugiranje
#uses "CtrlXmlRpc"
main() 
{
   dpQueryConnectSingle("work", true, "Identi", 
                       "SELECT '_original.._value' FROM '*.state.gubitak_komunikacije' WHERE _DPT = \"Nisa\"");       
  
}
string sys_name = "SysSarani:";


work (anytype ident, dyn_dyn_anytype list) {
  string dpe;
  dyn_int value;
  
  for(int i = 2; i <= dynlen(list); i++)  //starta sa 2 zato sto liste pocinju od 1, a sql upit vraca u prvoj liniji header pa treba i njega preskociti
  {    
    value = list[i][2];
    dpe = list[i][1];
    dpe = dpSubStr(dpe, DPSUB_DP);  //DPSUB_DP - 
    //DebugTN("pozvana je metoda work za " + dpe);
    int thId = startThread("pratiOsigurac", dpe);
   
    waitThread(thId);
  } 
}

void pratiOsigurac (string nazivNise)
{
  bool status;
  dyn_int trkaci;
  
  dpGet(sys_name + nazivNise + ".state.gubitak_komunikacije", status);
  if (!status) {
    vratiStanjePrijeGubitkaKomunikacije(nazivNise);    
  }
}

vratiStanjePrijeGubitkaKomunikacije (string nazivNise) {
  dyn_int izlazne_kartice;
  bool stanje;
  string s;  
  bool timer_15_min;
  time t;
  dpGet(sys_name + nazivNise + ".timer_15_min:_original.._stime", t);
  if ((int)getCurrentTime() - (int)t > 900) {
     dpSet(sys_name + nazivNise + "SysSarani:RO-SOS-D1.state.timer_15_min", 0);   
  }
  
  dpGet (sys_name + nazivNise + ".izlazne_kartice", izlazne_kartice);
  strreplace(nazivNise, "RO", "OA");
  
  for (int i=1; i<=dynlen(izlazne_kartice); i++) {
    for (int j=0; j<=3; j++) {
      dpGet(sys_name + nazivNise + ".A" + izlazne_kartice[i] + ".cmd.bit.b" + j, stanje);
      dpSet(sys_name + nazivNise + ".A" + izlazne_kartice[i] + ".cmd.bit.b" + j, stanje);
      //DebugTN("\n" + sys_name + nazivNise + ".A" + izlazne_kartice[i] +  ".cmd.bit.b" + j + ", " + stanje);
    }
  }
}
