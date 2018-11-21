main()
{
  
  dpQueryConnectSingle("resetStatusSPZ", true, "Identi", 
                       "SELECT '_online.._value' FROM '*.gornji.status' WHERE _DPT = \"ComboSign\"");
  dpQueryConnectSingle("resetStatusSPT", true, "Identi", 
                       "SELECT '_online.._value' FROM '*.status' WHERE _DPT = \"VS_Ispred\"");
  
}

resetStatusSPZ(anytype ident, dyn_dyn_anytype list)
{
  string dpe;
  int value;
  delay(1);
  for(int i = 2; i <= dynlen(list); i++)  //starta sa 2 zato sto liste pocinju od 1, a sql upit vraca u prvoj liniji header pa treba i njega preskociti
  { 
    value = list[i][2];
    dpe = list[i][1];
    dpe = dpSubStr(dpe, DPSUB_DP);  //DPSUB_DP - 
    if(value != 0){
      dpSet(dpe + ".gornji.status", 0);
      dpSet(dpe + ".donji.status", 0);
    } 
  }
}

resetStatusSPT(anytype ident, dyn_dyn_anytype list)
{
  string dpe;
  int value;
  delay(1);
  for(int i = 2; i <= dynlen(list); i++)  //starta sa 2 zato sto liste pocinju od 1, a sql upit vraca u prvoj liniji header pa treba i njega preskociti
  { 
    value = list[i][2];
    dpe = list[i][1];
    dpe = dpSubStr(dpe, DPSUB_DP);  //DPSUB_DP - 
    if(value != 0){
      dpSet(dpe + ".status", 0);   
    } 
  }
}

