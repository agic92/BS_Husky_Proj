main()
{
  
  dpQueryConnectSingle("setSemaforStatus", true, "Identi", 
                       "SELECT '_online.._value' FROM '*.command.sdv.*' WHERE _DPT = \"semafor\"");

}
bool initSemafor = false;

setSemaforStatus(anytype ident, dyn_dyn_anytype list)
{
  if(!initSemafor)
  {
    initSemafor = true;
    return;
  }
  
  string dpe;
  int value;
  int zeleno, crveno, zuto;

  for(int i = 2; i <= dynlen(list); i++)  //starta sa 2 zato sto liste pocinju od 1, a sql upit vraca u prvoj liniji header pa treba i njega preskociti
  { 
    value = list[i][2];
    delay(0.5);
    
    if(value == true){
      dpe = list[i][1];
      zeleno = strpos(dpe, "zeleno", 0);
      crveno = strpos(dpe, "crveno", 0);
      zuto = strpos(dpe, "zuto", 0);
      dpe = dpSubStr(dpe, DPSUB_DP);  //DPSUB_DP - 
      DebugTN("dpe", dpe);
      DebugTN("value", value);
      DebugTN("zeleno", zeleno);
      DebugTN("crveno", crveno);
      DebugTN("zuto", zuto);
          
      if(zeleno > 0){ 
        dpSet(dpe + ".response.zeleno", true,
              dpe + ".response.crveno", false,
              dpe + ".response.zuto", false,
              dpe + ".command.sdv.zeleno", false,
              dpe + ".command.sdv.crveno", false,
              dpe + ".command.sdv.zuto.on", false  
              );
      }
      else if(crveno > 0){ 
        dpSet(dpe + ".response.zeleno", false,
              dpe + ".response.crveno", true,
              dpe + ".response.zuto", false,
              dpe + ".command.sdv.zeleno", false,
              dpe + ".command.sdv.crveno", false,
              dpe + ".command.sdv.zuto.on", false  
              );
      }
      else if(zuto > 0){ 
        dpSet(dpe + ".response.zeleno", false,
              dpe + ".response.crveno", false,
              dpe + ".response.zuto", true,
              dpe + ".command.sdv.zeleno", false,
              dpe + ".command.sdv.crveno", false,
              dpe + ".command.sdv.zuto.on", false  
              );
      }
    }
  } 
}
