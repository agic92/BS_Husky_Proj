#uses "SharedFunc.ctl"
int iDur = 20;
float fOld_Temp1, fOld_Temp2;

main()
{
  //SysSarani:MS1.response.state.Temperatura_Zraka
  //dpConnect(
  dyn_errClass err;
  DebugFTN("level1", "temperatura_na_znakovima.ctl -- start!"); 
//  dpConnect("ms1", "SysSarani:MS1.response.state.Temperatura_Zraka");
  dpConnect("ms1", "SysSarani:MS1.response.state.Temperatura_Zraka", "SysSarani:MS2.response.state.Temperatura_Zraka");
  err = getLastError();
  if(dynlen(err) > 0)
  {
    DebugFTN("level1", "An error has occurred:", err);
  }
/*
  dpConnect("ms2", "SysSarani:MS2.response.state.Temperatura_Zraka");
  err = getLastError();
  if(dynlen(err) > 0)
  {
    DebugFTN("level1", "An error has occurred on:", err);
    //further measures
  }
  */
}

ms1(string dpe_ms1, float fTemp1, string dpe_ms1, float fTemp2) 
{      
  DebugFTN("level1", "sendToSign  - isReduActive() = ", isReduActive());
  if(!isReduActive())
    return;
     
  float fNew_Temp1, fNew_Temp2, fTemp = 0;
  int tip, status;
  bool iTemperature1_changed;
  bool iTemperature2_changed;
  string ip_adresa;
  dyn_int naZnaku;
  time ms1t, ms2t, tCurTime = getCurrentTime();
 dpGet("SysSarani:MS1.response.state.Temperatura_Zraka:_original.._stime", ms1t); 
 dpGet("SysSarani:MS2.response.state.Temperatura_Zraka:_original.._stime", ms2t); 
 
 //ako su ocitanja temperature azurna posalji ih na znak
 if(((tCurTime - ms1t) < 600) && ((tCurTime - ms2t) < 600))  //10min
   ;
 else if((tCurTime - ms2t) < 600)  //10min
   fTemp1 = fTemp2;
 else if((tCurTime - ms1t) < 600)  //10min
   fTemp2 = fTemp1;
 else{ 
     fTemp2 = 99;
     fTemp1 = fTemp2;
   }

  fNew_Temp1 = Round_to_First_Decimal(fTemp1);
  fNew_Temp2 = Round_to_First_Decimal(fTemp2);
  DebugFTN("level2", "ms1(): fNew_Temp1: " + fNew_Temp1, "fOld_Temp1: " + fOld_Temp1, (fNew_Temp1 - fOld_Temp1), (fOld_Temp1 - fNew_Temp1)); 
  if((fNew_Temp1 - fOld_Temp1 >= 0.1) || (fOld_Temp1 - fNew_Temp1 >= 0.1))
  {
	  iTemperature1_changed = true;
	  fOld_Temp1 = fNew_Temp1;
  }
  if((fNew_Temp2 - fOld_Temp2 >= 0.1) || (fOld_Temp2 - fNew_Temp2 >= 0.1))
  {
	  iTemperature2_changed = true;
	  fOld_Temp2 = fNew_Temp2;
  } 
  DebugFTN("level2", "send to sign new temp");    


  if(iTemperature1_changed)
  {
	 dpGet("SysSarani:VMS1-OAD.command.izbor_znaka", naZnaku); 
	 dpGet("VMS1-OAD.status", status);
	 dpGet("SysSarani:VMS1-OAD.IP", ip_adresa);
	 dpGet("SysSarani:VMS1-OAD.tip_znaka", tip);
	 DebugFTN("level1","status: ", status, "naZnaku: ", naZnaku[1]);
	 if(naZnaku[1] == 1)
	   sendToSign("SysSarani:VMS1-OAD", tip, ip_adresa, fTemp1);
  }

  if(iTemperature2_changed)
  { 
	 dpGet("SysSarani:VMS1-OAL.command.izbor_znaka", naZnaku); 
	 dpGet("VMS1-OAL.status", status);
	 dpGet("SysSarani:VMS1-OAL.IP", ip_adresa);
	 dpGet("SysSarani:VMS1-OAL.tip_znaka", tip);
	 if(naZnaku[1] == 1)
	   sendToSign("SysSarani:VMS1-OAL", tip, ip_adresa, fTemp2);
  }
 
}

ms2(string dpe, float fTemp) 
{ 
  int tip, status;
  string ip_adresa;
  dyn_int naZnaku;
  
 dpGet("SysSarani:VMS1-OAL.command.izbor_znaka", naZnaku); 
 dpGet("VMS1-OAL.status", status);
 dpGet("SysSarani:VMS1-OAL.IP", ip_adresa);
 dpGet("SysSarani:VMS1-OAL.tip_znaka", tip);
 if(naZnaku[1] == 1)
   sendToSign("SysSarani:VMS1-OAL", tip, ip_adresa, fTemp);
 
}

dyn_mixed portal_normalni_uslovi(int iSign_Type_ID, string sIP_addr, float fTemp)
{
  string sTemp = "";
  sprintf(sTemp,"%+5.1f", fTemp);  
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 32;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 32;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 2; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 0; int XL1 = 40; int XR1 = 135; 
			int Fn2 = 2; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 13; int XL2 = 40; int XR2 = 135; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 26; int XL3 = 40; int XR3 = 135; 
			int Pict1 = 2; int Pict2 = 0; int Pict3 = 0; int Pict4 = 8;
      //string sText = "ТУНЕЛ'nl'ШАРАНИ'nl''TIME'  "+ sTemp +"C'nl' "; // + iTemp + "'nl'";
      string sText = "";
      if(fTemp == 99) 
         sText = "ТУНЕЛ'nl'ШАРАНИ'nl''TIME'nl' "; // + iTemp + "'nl'";
      else
         sText = "ТУНЕЛ'nl'ШАРАНИ'nl''TIME'  "+ sTemp +"C'nl' "; // + iTemp + "'nl'";			
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 =32;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 32;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 0; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 0; int XL1_2 = 40; int XR1_2 = 135; 
			int Fn2_2 = 0; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 13; int XL2_2 = 40; int XR2_2 = 135; 
			int Fn3_2 = 0; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 26; int XL3_2 = 40; int XR3_2 = 135; 
			int Pict1_2 = 2; int Pict2_2 = 0; int Pict3_2 = 0; int Pict4_2 = 8;
      //string sText_2 = "TUNNEL'nl'ŠARANI'nl''TIME'  "+ sTemp +"C'nl'"; // + iTemp + "'nl'";
      string sText_2 = "";
      if(fTemp == 99) 
			  sText_2 = "TUNNEL'nl'ŠARANI'nl''TIME'nl'"; // + iTemp + "'nl'";
      else
        sText_2 = "TUNNEL'nl'ŠARANI'nl''TIME'  "+ sTemp +"C'nl'"; // + iTemp + "'nl'";
      //string sText_2 = "'TIME'"; // + iTemp + "'nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2, 136, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3, 
                          Pict1, Pict2, Pict3, Pict4,
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2, 136, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2, 
                          Pict1_2, Pict2_2, Pict3_2, Pict4_2,
                          sText_2);		
      DebugFTN("level1","portal_normalni_uslovi - args: ", args);
      return args;
}


sendToSign(string dpe, int tip, string ip_adresa,  float temp){  

  dyn_mixed args;
  string xmlRpcMethod = "bstelecom.sign.SignProtocolAdapter.writePortalSignTwoPanels";
  
   DebugFTN("level1", "tip: ", tip, "IP:", ip_adresa, "temperatura:", temp);
 
  args = portal_normalni_uslovi(tip, ip_adresa, temp);             
    
  DebugFTN("level1", "SendToSign: " + dpe + "; Args: " + args);
  
  //int res = xmlRpcSendToSign(args, xmlRpcMethodWriteSettings, false);
  int res = xmlRpcSendToSign(args, xmlRpcMethod, false);
    
  DebugFTN("level1", "SendToSign " + dpe + " Response: " + res);
    
  if (res == 0){
    DebugFTN("level1", "sendToSign " + dpe + " OK.");
    dpSet(dpe + ".status", 0);       
  }
  else{
    DebugFTN("level1", "SendToSign "+ dpe + " Not sent.");
    dpSet(dpe + ".status", -1);
  } 
 
}

float Round_to_First_Decimal (float fValue)
{  
  int iTemp10 = 10 * fValue;
  float fRounded = iTemp10;
  fRounded = fRounded / 10;
  DebugFTN("level2", "Round_to_First_Decimal - fValue: " + fValue, ", iTemp10: " + iTemp10, ", fRounded:" + fRounded);
  return fRounded;
}
