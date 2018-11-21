//-dbg "level1" - za debugiranje
#uses "CtrlXmlRpc"

int main() 
{
   dpQueryConnectSingle("work", true, "Identi", 
                       "SELECT '_original.._value' FROM '*.state.gubitak_komunikacije' WHERE _DPT = \"Nisa\"");       
  
}



work (anytype ident, dyn_dyn_anytype list) {
  string dpe;
  dyn_int value;
  
  for(int i = 2; i <= dynlen(list); i++)  //starta sa 2 zato sto liste pocinju od 1, a sql upit vraca u prvoj liniji header pa treba i njega preskociti
  {    
    value = list[i][2];
    dpe = list[i][1];
    dpe = dpSubStr(dpe, DPSUB_DP);  //DPSUB_DP - 
    
    int thId = startThread("pratiOsigurac", dpe);
   
    waitThread(thId);
  } 
}

void pratiOsigurac (string nazivNise)
{
  bool status;
  dyn_int trkaci;
  string sys_name = "SysSarani:";
  dpGet(sys_name + nazivNise + ".trkaci", trkaci);
  
  dpGet(sys_name + nazivNise + ".state.gubitak_komunikacije", status);
  string prefiks;
  if (strpos(nazivNise, "SOS-D")>=0 || strpos(nazivNise, "TK-D")>=0) 
    prefiks = "D";
  else 
    prefiks = "L";
  //DebugTN("\ndpe: " + sys_name + nazivNise + ", status: " + status + "\n\n");
  if (!status) {
    for (int i=1; i<=dynlen(trkaci);i++) {
      dpSet(sys_name + "Oznaka_puta_evakuacije_E" + trkaci[i]+"-1" + prefiks + ".cmd.ukljucenje_oznake", 1);
      //DebugTN("Trkaci: " + trkaci[i]);
      delay(0,100);
      dpSet(sys_name + "Oznaka_puta_evakuacije_E"+ trkaci[i] +"-2" + prefiks +  ".cmd.ukljucenje_oznake", 1);
      delay(0,100);
    }
  }
}
