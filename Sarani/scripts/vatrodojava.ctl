//-dbg "level1" - za debugiranje
#uses "CtrlXmlRpc"

int main() 
{
   dpQueryConnectSingle("work", true, "Identi", 
                       "SELECT '_original.._value' FROM '*.Status.vrijednost_sa_centrale' WHERE _DPT = \"fire_detector\"");       
  
}



work (anytype ident, dyn_dyn_anytype list) {
  string dpe;
  dyn_int value;
  
  for(int i = 2; i <= dynlen(list); i++)  //starta sa 2 zato sto liste pocinju od 1, a sql upit vraca u prvoj liniji header pa treba i njega preskociti
  {    
    value = list[i][2];
    dpe = list[i][1];
    dpe = dpSubStr(dpe, DPSUB_DP);  //DPSUB_DP - 
    
    int thId = startThread("pratiDetektor", dpe);
   
    waitThread(thId);
  } 
}

void pratiDetektor (string detektor)
{
  bool status, greska;
  int stanje;
  string sys_name = "SysSarani:";
  dpGet(sys_name + detektor + ".Status.Fault", greska);
  dpGet(sys_name + detektor + ".Status.vrijednost_sa_centrale", stanje);
  if (!greska) {
    switch(stanje) {
      case 32768:
          dpSet(sys_name + detektor + ".Status.Fire", 1);
          dpSet(sys_name + detektor + ".Status.Prealarm", 0);
          dpSet(sys_name + detektor + ".Status.SwitchOff", 0);
          break;
      case 16384:
          dpSet(sys_name + detektor + ".Status.Fire", 0);
          dpSet(sys_name + detektor + ".Status.Prealarm", 1);
          dpSet(sys_name + detektor + ".Status.SwitchOff", 0);
          break;  
      case 128:
          dpSet(sys_name + detektor + ".Status.Fire", 0);
          dpSet(sys_name + detektor + ".Status.Prealarm", 0);
          dpSet(sys_name + detektor + ".Status.SwitchOff", 1);
          break;
      default:
          dpSet(sys_name + detektor + ".Status.Fire", 0);
          dpSet(sys_name + detektor + ".Status.Prealarm", 0);
          dpSet(sys_name + detektor + ".Status.SwitchOff", 0);
          break;
    }
  }
}
