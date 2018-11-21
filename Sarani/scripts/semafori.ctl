//string sSelect = "SELECT '_online.._value' FROM 'S*.command.scada_command' WHERE _DPT = \"semafor\"";
string sSelect = "SELECT '_online.._value' FROM '{S*.command.sdv.crveno,S*.command.sdv.zeleno,*.command.sdv.zuto.on,*.command.sdv.iskljuci}' WHERE _DPT = \"semafor\"";
string sdv_zeleno = ".command.sdv.zeleno";
string sdv_crveno = ".command.sdv.crveno";
string sdv_zuto = ".command.sdv.zuto.on";
string sdv_iskljuci = ".command.sdv.iskljuci";
int iYellowTime = 1500; //milisekundi

main()
{
  int rc;
  anytype userData = getUserName();  
  //setValue("Text1","backCol","Red");
  rc = dpQueryConnectSingle("work", false, userData, sSelect);
  DebugTN("QueryConnectSingle: ", rc);

}
 

work(anytype userData, dyn_dyn_anytype val) 
{
  int i;
  DebugFTN("level3", "Callback - dynLen:", dynlen(val));
  string sDPE = "";
  bool bVal;
  for (i = 2; i <= dynlen(val); i++)
  {
    //DebugTN("Rezultat: ", i, val[i][1], val[i][2], "Korisnik: ", userData);
    sDPE = val[i][1];
    string sDPName = dpSubStr(sDPE, DPSUB_DP_EL);  //DPSUB_DP - 
    string sDP = dpSubStr(sDPE, DPSUB_DP);  //DPSUB_DP - 
    string sSys_DP = dpSubStr(sDPE, DPSUB_SYS_DP);  //DPSUB_DP - 
    string sDPName_EL = dpSubStr(sDPE, DPSUB_DP_EL);
    bVal = val[i][2];
    //DebugTN("sDPName", sDPName, "sDP", sDP, "sSys_DP",sSys_DP, "sDPName_EL", sDPName_EL, bVal);
    DebugFTN("level3","sDPName", sDPName, "bVal:", bVal);
    //idi dalje samo ako je dosla pozitivna komanda
    if(bVal)      
      startThread("semafor",sDPE, bVal);
  }  
}

semafor(string sDPE, bool bCommand)
{
  DebugFTN("level2", "semafor - sDPE: " + sDPE + ", bCommand:", bCommand);
  //ako je ponistenje neke komande ne radi nista 
  if(bCommand == false)
    return;
  
  //stanja na semaforu
  bool run_zuto, cmd_zuto, cmd_zuto_blink, run_zeleno, run_crveno;
  //komande
  bool bsZuto, bsCrveno, bsZeleno, bsIskljuci;
  string sSys_DP = dpSubStr(sDPE, DPSUB_SYS_DP);  //DPSUB_DP - 
  string sRun_Crveno = sSys_DP + ".command.run.crveno";
  string sRun_Zuto = sSys_DP + ".command.run.zuto";
  string sCmd_Zuto = sSys_DP + ".command.sdv.zuto.LightOn";
  //string sCmd_Zuto = sSys_DP + ".command.sdv.zuto.on";  
  //string sCmd_Zuto_Blink = sSys_DP + ".command.sdv.zuto.Blink";
  string sCmd_Zuto_Blink = sSys_DP + ".command.sdv.zuto.on";
  string sRun_Zeleno = sSys_DP + ".command.run.zeleno";
  string sSys_DP = dpSubStr(sDPE, DPSUB_SYS_DP);  //DPSUB_DP -
  int iPos = -1;
  
  //iPos = strpos(sDPE, sdv_crveno,0);
  if(strpos(sDPE, sdv_crveno,0) >= 0)
    bsCrveno = true;
  else if(strpos(sDPE, sdv_zeleno,0) >= 0)
    bsZeleno = true;
  else if(strpos(sDPE, sdv_zuto,0) >= 0)
    bsZuto = true;
  else if(strpos(sDPE, sdv_iskljuci,0) >= 0)
    bsIskljuci = true;
  
    
  dpGet(sRun_Crveno, run_crveno, 
        sCmd_Zuto, cmd_zuto,
        sRun_Zuto, run_zuto,
        sCmd_Zuto_Blink, cmd_zuto_blink,
        sRun_Zeleno, run_zeleno);

  DebugFTN("level1", "Semafor - SCADA komande za znak - bsCrveno: ", bsCrveno, "bsZuto: ", bsZuto, "bsZeleno: ", bsZeleno,  "bsIskljuci: ", bsIskljuci);
  DebugFTN("level1", "Semafor - Stvarne komande na znak - run_crveno: ", run_crveno, "cmd_zuto: ", cmd_zuto, "cmd_zuto_blink: ", cmd_zuto_blink, "run_zeleno:", run_zeleno);

  //resetuj ostale komande sa SCADA-e, a ostavi novu
  resetCommands(sSys_DP, bsCrveno, bsZuto, bsZeleno, bsIskljuci);

  //ugasi semafor
    if(bsIskljuci)
      dpSet(sRun_Crveno, false, sCmd_Zuto, false, sCmd_Zuto_Blink, false, sRun_Zeleno, false);   
      
    //upali zeleno
    else if(bsZeleno){
      //bilo nista
      //if(!(cmd_zuto || run_zeleno || run_crveno))
      if(!(run_zuto || run_zeleno || run_crveno))
      {        
        dpSet(sRun_Crveno, false, sCmd_Zuto, true, sCmd_Zuto_Blink, false, sRun_Zeleno, false);
        delay(0, iYellowTime);        
        dpSet(sRun_Crveno, false, sCmd_Zuto, false, sCmd_Zuto_Blink, false, sRun_Zeleno, true);
      }
      //bilo zuto
      else if(run_zuto)        
        dpSet(sRun_Crveno, false, sCmd_Zuto, false, sCmd_Zuto_Blink, false, sRun_Zeleno, true);
      //bilo crveno
      else if(run_crveno){        
        dpSet(sRun_Crveno, true, sCmd_Zuto, true, sCmd_Zuto_Blink, false, sRun_Zeleno, false);
        delay(0, iYellowTime);
        dpSet(sRun_Crveno, false, sCmd_Zuto, false, sCmd_Zuto_Blink, false, sRun_Zeleno, true);
      }        
    }
    
    //upali zuto blinkajuce
    else if(bsZuto)
      //sta god da je bilo postavi zuto
      //dpSet(sRun_Crveno, false, sCmd_Zuto, false, sCmd_Zuto_Blink, true, sRun_Zeleno, false); 
      dpSet(sRun_Crveno, false, sCmd_Zuto, false, sRun_Zeleno, false); 
    
    //upali crveno
    else if(bsCrveno){
      //bilo nista
      //if(!(cmd_zuto || run_zeleno || run_crveno))
      if(!(run_zuto || run_zeleno || run_crveno))
      {        
        dpSet(sRun_Crveno, false, sCmd_Zuto, true, sCmd_Zuto_Blink, false, sRun_Zeleno, false); 
        delay(0, iYellowTime);        
        dpSet(sRun_Crveno, true, sCmd_Zuto, false, sCmd_Zuto_Blink, false, sRun_Zeleno, false); 
      }
      //bilo zuto
      //else if(cmd_zuto)
      else if(run_zuto)
      {
        dpSet(sRun_Crveno, false, sCmd_Zuto, true, sCmd_Zuto_Blink, false, sRun_Zeleno, false); 
        delay(0, iYellowTime); 
        dpSet(sRun_Crveno, true, sCmd_Zuto, false, sCmd_Zuto_Blink, false, sRun_Zeleno, false);
      }
      //bilo zeleno
      else if(run_zeleno)
        dpSet(sRun_Crveno, false, sCmd_Zuto, true, sCmd_Zuto_Blink, false, sRun_Zeleno, false);
        delay(0, iYellowTime);
        dpSet(sRun_Crveno, true, sCmd_Zuto, false, sCmd_Zuto_Blink, false, sRun_Zeleno, false);        
    }
}

resetCommands(string sDPE_DP, bool bsCrveno, bool bsZuto, bool bsZeleno, bool bsIskljuci)
{
  if(bsIskljuci)
    dpSet(sDPE_DP + sdv_crveno, bsCrveno,
          sDPE_DP + sdv_zuto, bsZuto,
          sDPE_DP + sdv_zeleno, bsZeleno);
  else if(bsCrveno)
    dpSet(sDPE_DP + sdv_zuto, bsZuto,
          sDPE_DP + sdv_zeleno, bsZeleno,
          sDPE_DP + sdv_iskljuci, bsIskljuci);
  else if(bsZuto)
    dpSet(sDPE_DP + sdv_crveno, bsCrveno,
          sDPE_DP + sdv_zeleno, bsZeleno,
          sDPE_DP + sdv_iskljuci, bsIskljuci);
  else if(bsCrveno)
    dpSet(sDPE_DP + sdv_zuto, bsZuto,
          sDPE_DP + sdv_zeleno, bsZeleno,
          sDPE_DP + sdv_iskljuci, bsIskljuci);     
}
