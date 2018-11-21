main()
{
  
  dpQueryConnectSingle("switchUser", true, "User", 
                       "SELECT '_online.._value' FROM '*.UserName' WHERE _DPT = \"_Ui\"");
}

//mijenja user-a za alarmne tabele, da bude user kao na glavnim panelima a ne root
switchUser(anytype ident, dyn_dyn_anytype list)
{
  
  string dpe;
  string user;

  for(int i = 2; i <= dynlen(list); i++)  //starta sa 2 zato sto liste pocinju od 1, a sql upit vraca u prvoj liniji header pa treba i njega preskociti
  { 
    user = list[i][2];
    dpe = list[i][1];
    dpe = dpSubStr(dpe, DPSUB_DP);  //DPSUB_DP - 
    //1. Mart
    if(dpe == "_Ui_2") {
         dpSet("_Ui_3.UserName:_original.._user", setUserId(getUserId(user)));
         dpSet("_Ui_3.UserName", user);
    }
  }
    
}
