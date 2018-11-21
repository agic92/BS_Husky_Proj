#uses "SharedFunc.ctl"

int iDur = 20;
int iXbgr2_Petlja = 176;
int iXR_Petlja = 175;

int main() 
{
  DebugTN("STart Znakovi.ctl!");
  dpQueryConnectSingle("sendToSign", true, "Identi", 
                       "SELECT '_online.._value' FROM '*.command.izbor_znaka' WHERE _DPT = \"Sign\"");
  
  dpQueryConnectSingle("sendToSignLuminosity", true, "Identi",
                       "SELECT '_online.._value' FROM '*.command.intezitet' WHERE _DPT = \"Sign\""); 
}

mapping map;

string xmlRpcMethodWriteSettings = "bstelecom.sign.SignProtocolAdapter.writeSignPanel";
string xmlRpcMethodWriteBrightness = "bstelecom.sign.SignProtocolAdapter.writeSignBrightness";
string xmlRpcMethodWriteMatrixSettings = "bstelecom.sign.SignProtocolAdapter.writeMatrixSignPanel";
string xmlRpcMethodWritePortalSettings = "bstelecom.sign.SignProtocolAdapter.writePortalSignPanel";
string xmlRpcMethodWriteTwoPannelsPortal_PetljaSettings = "bstelecom.sign.SignProtocolAdapter.writePortal_PetljaSignTwoPanels";
string xmlRpcMethodWriteTwoPannelsPortalSettings = "bstelecom.sign.SignProtocolAdapter.writePortalSignTwoPanels";
string xmlRpcMethodWriteVangabaritni_Sign = "bstelecom.sign.SignProtocolAdapter.writeVangabaritni_Sign";

bool initSign = false;
bool initLumin = false;

sendToSign(anytype ident, dyn_dyn_anytype list){
  DebugFTN("level1", "sendToSign  - isReduActive() = ", isReduActive());
  if(!isReduActive())
    return;
  
  if(!initSign)
  {
    initSign = true;
    return;
  }
  
  DebugFTN("level1", "sendToSign start"); 
  
  string dpe;
  dyn_int value;
   
  for(int i = 2; i <= dynlen(list); i++)  //starta sa 2 zato sto liste pocinju od 1, a sql upit vraca u prvoj liniji header pa treba i njega preskociti
  {    
    value = list[i][2];
    dpe = list[i][1];
    dpe = dpSubStr(dpe, DPSUB_DP);  //DPSUB_DP - 
    dpSet(dpe + ".status", 1);      
    startThread("sendToSignSingle", dpe, value);
  }
  
  DebugFTN("level1", "sendToSign end");
}

sendToSignSingle(string dpe, dyn_int value){
  
  //delay(0,300);
  mapping map;
  int tip = 0;  
  string ip_adresa;
  //int iSignSymbol;
  
  //tip znaka i ip adresa
  dpGet(dpe + ".tip_znaka", tip); 
  dpGet(dpe + ".IP", ip_adresa);

  //dobijamo mapirane vrijednosti znakova koje treba poslati na adapter
  dyn_int getSignSymbols = getMappingValueArray(value, dpe);
  //dyn_mixed args = makeDynMixed(tip, ip_adresa, getSignSymbols);
  //DebugTN("getSignSymbols - ", getSignSymbols);
  //DebugTN("getSignSymbols.len - ", dynlen(getSignSymbols));
  dyn_mixed args;
  string xmlRpcMethod = "";
  
  DebugFTN("level1", "tip: ", tip);
  switch(tip)
  {
    case 4:  //portalni znak
      //doraditi sta se bude slalo na znak
      args = generateArgumentsForPortalSign(ip_adresa, tip, getSignSymbols[1]);      
      xmlRpcMethod = xmlRpcMethodWriteTwoPannelsPortalSettings;
      break;
    case 6:  //matricni znak
     if(dynlen(getSignSymbols) == 1)  
         args = generateArgumenstForMatrixSign(ip_adresa, tip, getSignSymbols[1], -1);
      else
         args = generateArgumenstForMatrixSign(ip_adresa, tip, getSignSymbols[1], getSignSymbols[2]);
      
      xmlRpcMethod = xmlRpcMethodWriteMatrixSettings;
    break;
    case 8:  //portalni znak na petljama
      //doraditi sta se bude slalo na znak
      args = generateArgumentsForPortal_PetljaSign(ip_adresa, tip, getSignSymbols[1]);      
      xmlRpcMethod = xmlRpcMethodWriteTwoPannelsPortal_PetljaSettings;
      break;
    case 10:  //vangabaritni znak
      args = makeDynMixed(tip, ip_adresa, getSignSymbols[1]);  
      xmlRpcMethod = xmlRpcMethodWriteVangabaritni_Sign;
      break;
    default:  //ostali znakovi
     if(dynlen(getSignSymbols) == 1)  
         args = makeDynMixed(tip, ip_adresa, getSignSymbols[1]);
      else
         args = makeDynMixed(tip, ip_adresa, getSignSymbols);
     xmlRpcMethod = xmlRpcMethodWriteSettings;
  } 
   
  //dobijamo niz mapiranih panela al u slucaju da da nema panela vrati -1
  if(getSignSymbols[1] == -1)
  {
     DebugFTN("level1", "SendToSign " + dpe + " Not sent.");
     dpSet(dpe + ".status", -1);
     return;
  }

  //tip znaka na protokolu treba da se podudara sa tipom na scada-i
  //DebugTN("getSignSymbols: " + getSignSymbols);
    
  DebugFTN("level1", "SendToSign: " + dpe + "; Args: " + args);
  
  //int res = xmlRpcSendToSign(args, xmlRpcMethodWriteSettings, false);
  int res = xmlRpcSendToSign(args, xmlRpcMethod, false);
    
  DebugFTN("level1", "SendToSign " + dpe + " Response: " + res);
    
  if (res == 0){
    DebugFTN("level1", "sendToSign " + dpe + " OK.");
    dpSet(dpe + ".status", 0);       
  }
  else{
    DebugFTN("level1", "SendToSign "+ dpe + " Not sent. Pokusava ponovo");
    delay(1);    
    res = xmlRpcSendToSign(args, xmlRpcMethod, false);
    
    DebugFTN("level1", "SendToSign " + dpe + " Response2: " + res);
    
  if (res == 0){
    DebugFTN("level1", "sendToSign " + dpe + " OK2.");
    dpSet(dpe + ".status", 0);       
  }
  else{
    DebugFTN("level1", "SendToSign "+ dpe + " Not sent2.");
    dpSet(dpe + ".status", -1);
  } 
  } 
 
}

sendToSignLuminosity(anytype ident, dyn_dyn_anytype list){
  if(!isReduActive())
    return;
    
  if(!initLumin)
  {
    initLumin = true;
    return;
  }
  
  DebugFTN("level1", "sendToSignLuminosity start");
  
  string dpe;
  string value;

  for(int i = 2; i <= dynlen(list); i++)  //starta sa 2 zato sto liste pocinju od 1, a sql upit vraca u prvoj liniji header pa treba i njega preskociti
  {    
    value = list[i][2];
    dpe = list[i][1];
    dpe = dpSubStr(dpe, DPSUB_DP);  //DPSUB_DP -
    startThread("sendToSignLuminositySingle", dpe, value);  
   }
  
  DebugFTN("level1", "sendToSignLuminosity end");
  
}

sendToSignLuminositySingle(string dpe, string value){
  
   int tip;  
   string ip_adresa;
   
   //tip znaka i ip adresa
   dpGet(dpe + ".tip_znaka", tip);    
   dpGet(dpe + ".IP", ip_adresa);
   
   int iFix_Brightness, iFix_brightness_priority, iDaytime_depedence_priority, iLight_sensor_priority;
   
   if(value == "0"){//time day time
       iFix_Brightness = -1;
       iFix_brightness_priority = 0;
       iDaytime_depedence_priority = 2; 
       iLight_sensor_priority = 1;
   }
   else if(value == "1"){ //light sensor
       iFix_Brightness = -1;
       iFix_brightness_priority = 0;
       iDaytime_depedence_priority = 1; 
       iLight_sensor_priority = 2;
   }
   else{ //fix brightness
       iFix_Brightness = (int)value;
       iFix_brightness_priority = 2;
       iDaytime_depedence_priority = 0; 
       iLight_sensor_priority = 1;
   }
 
    
   dyn_mixed args = makeDynMixed(tip, ip_adresa, iFix_Brightness, iFix_brightness_priority, iDaytime_depedence_priority, iLight_sensor_priority);
   DebugFTN("level1", "SendToLuminosity: " + dpe + "; Args: " + args);
    
   int res = xmlRpcSendToSign(args, xmlRpcMethodWriteBrightness, false);

   DebugFTN("level1", "SendToSignLuminosity " + dpe + " Response: " + res);
    
   if (res != 0){
      DebugFTN("level1", "SendToSignLuminosity "+ dpe + " Not sent.");
      dpSet(dpe + ".status", -1);
   }
   else{
      DebugFTN("level1", "sendToSignLuminosity " + dpe + " OK;");
      //dpSet(dpe + ".status", 0);
   }    
}

mapping getMapping(int tip){
  
  dyn_string mapiranje;
  mapping map;
  string dp = "Tip" + tip + ".mapirane_vrijednosti";
  string vrijednost;
  string mapirana_vrijednost;
  dpGet(dp, mapiranje);
  
  for(int i=1; i <= dynlen(mapiranje); i++)
  {  
     vrijednost = substr(mapiranje[i], 0, strpos(mapiranje[i], "|", 0));
     mapirana_vrijednost = substr(mapiranje[i], strpos(mapiranje[i], "|", 1) + 1);   
     map[vrijednost] = mapirana_vrijednost;
  }  
  
  return map;  
}

//vraca mapipranu vrijednost za samo jedan znak
int getMappingValue(dyn_int value, string dpe){

  int tip;
  int stanje_na_znaku;
  dpGet(dpe + ".tip_znaka", tip);
  
  //uzmi mapirane vrijednosti
  mapping map = getMapping(tip);

  string vrijednost = value[1];

  if (!mappingHasKey(map, vrijednost)) {
      DebugFTN("level1", "Error: Mapping does not contain value. Map: " + map + "; Value" + vrijednost);
      return -1;
  }
    
  stanje_na_znaku = map[vrijednost];

  return stanje_na_znaku;    
}

//vraca mapiranu vrijednost za jedan ili vise znakova
dyn_int getMappingValueArray(dyn_int value, string dpe){

  int tip;
  dyn_int stanje_na_znaku;
  
  dpGet(dpe + ".tip_znaka", tip);
  
  //uzmi mapirane vrijednosti
  mapping map = getMapping(tip);
  
  for(int i=1;i<=dynlen(value);i++){
    string vrijednost = value[i];
    
    if (!mappingHasKey(map, vrijednost)){
      DebugFTN("level1", "Error: Mapping does not contain value. Map: " + map + "; Value " + vrijednost);
      stanje_na_znaku[1] = -1;
      return stanje_na_znaku;
    }
      
    stanje_na_znaku[i] = map[vrijednost];
  
  }

  return stanje_na_znaku;    
}

//generise argumente za komandu za promjenu slike na Matricnom znaku
//Bgr1 - id slike na znaku
//Bgr2 - id druge slike (panela) na znaku, ako je vrijednost -1 treba prikazivati samo prvu sliku
dyn_mixed generateArgumenstForMatrixSign(string sIP_addr, int iSign_Type_ID, int Bgr1, int Bgr2)
{  
   dyn_mixed args;			
			//string sIP_addr = "10.101.0.108";
			//int iSign_Type_ID = 6; 
			int Active = 1;
      int Duration = 0; 		
      if(Bgr2 >= 0)	
  			Duration = 30;      
			//int Bgr1 = 2;			
			int Fn1 = 0; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 0; int XL1 = 0; int XR1 = 47; 
			int Fn2 = 0; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 0; int XL2 = 0; int XR2 = 47; 
			int Fn3 = 0; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 0; int XL3 = 0; int XR3 = 47;
     	string sText = "";	 
           
			args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, Bgr1, Bgr2,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3, 
                          sText);		
      DebugFTN("level2", "generateArgumenstForMatrixSign - args: ", args);
      return args;  
}


dyn_mixed generateArgumenstForPortalSign(string signIP, int signType, int Bgr1, int Bgr2)
{  
   dyn_mixed args;			
			//int signType = 4; 
			int Active = 1;
   int Duration = 0; 		
   
   if(Bgr2 >= 0)	
  			Duration = 30;      
			//int Bgr1 = 2;			
			int Fn1 = 0; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 0; int XL1 = 0; int XR1 = 47; 
			int Fn2 = 0; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 0; int XL2 = 0; int XR2 = 47; 
			int Fn3 = 0; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 0; int XL3 = 0; int XR3 = 47;
     	string sText = "";	 
           
			args = makeDynMixed(signType, signIP, 
                          Active, Duration, Bgr1, Bgr2,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3, 
                          sText);		
      DebugFTN("level2", "generateArgumenstForMatrixSign - args: ", args);
      return args;  
}



//generise argumente za komandu za promjenu slike na Portalnom znaku
//iValue
dyn_mixed generateArgumentsForPortalSign(string sIP_addr, int iSign_Type_ID, int iValue)
{  
   dyn_mixed args;
  
   switch(iValue)
   {
     //normalni uslovi
     case 1:
       args = portal_normalni_uslovi_Sarani(iSign_Type_ID, sIP_addr);
       break;
     case 22:
       args = portal_normalni_uslovi_Savinac(iSign_Type_ID, sIP_addr);
       break;
     case 23:
       args = portal_normalni_uslovi_Brdjani(iSign_Type_ID, sIP_addr);
       break;
     case 2:
       args = portal_kolona_vozila_60(iSign_Type_ID, sIP_addr);
       break;
     case 3:
       args = portal_kolona_vozila_40(iSign_Type_ID, sIP_addr);
       break;
     case 4:
       args = portal_vjetar_60(iSign_Type_ID, sIP_addr);
       break;
     case 5:
       args = portal_vjetar_40(iSign_Type_ID, sIP_addr);
       break;
     case 6:
       args = portal_magla_60(iSign_Type_ID, sIP_addr);
       break;
     case 7:
       args = portal_magla_40(iSign_Type_ID, sIP_addr);
       break;
     case 8:
       args = portal_klizavo_60(iSign_Type_ID, sIP_addr);
       break;
     case 9:
       args = portal_klizavo_40(iSign_Type_ID, sIP_addr);
       break;
     case 10:
       args = portal_poledica_40(iSign_Type_ID, sIP_addr);
       break;
     case 11:
       args = portal_snijeg_40(iSign_Type_ID, sIP_addr);
       break;
     case 12:
       args = portal_snijeg_60(iSign_Type_ID, sIP_addr);
       break;
     //case 13:
       //args = portal_nezgoda_60(iSign_Type_ID, sIP_addr);
       //break;
     case 14:
       args = portal_nezgoda_u_desnoj_traci_60(iSign_Type_ID, sIP_addr);
       break;
     case 15:
       args = portal_nezgoda_u_lijevoj_traci_60(iSign_Type_ID, sIP_addr);
       break;
     case 16:
       args = portal_suprotan_smjer_40(iSign_Type_ID, sIP_addr);
       break;
     case 17:
       args = portal_radovi_u_desnoj_traci_60(iSign_Type_ID, sIP_addr);
       break;
     case 18:
       args = portal_radovi_u_lijevoj_traci_60(iSign_Type_ID, sIP_addr);
       break;
     case 19:
       args = portal_zatvorena_tunelska_cijev_40(iSign_Type_ID, sIP_addr);
       break;
     case 20:
       args = portal_dvosmjerni_saobracaj_40(iSign_Type_ID, sIP_addr);
       break;
     case 21:
       args = portal_pozar_zatvoren_tunel(iSign_Type_ID, sIP_addr);
       break;
     
     default: break;
   }       
      DebugFTN("level2", "generateArgumenstForMatrixSign - args: ", args);
      return args;  
}



dyn_mixed portal_sign_arguments(int iSign_Type_ID, string sIP_addr,
                                int Active,		                          			
                          			int Bgr1,                          			
                          			int Bgr2,                          					
                          			int Fn1, int Y1, 
                          			int Fn2, int Y2, 
                          			int Fn3, int Y3, 
                          			int Pict1, int Pict2, int Pict3, int Pict4, 
                          			string sText,
                                int Active_2,
                                int Bgr1_2,
                                int Bgr2_2,
                                int Fn1_2, int Y1_2,
                                int Fn2_2, int Y2_2, 
                          			int Fn3_2, int Y3_2, 
                          			int Pict1_2, int Pict2_2, int Pict3_2, int Pict4_2, 
                          			string sText_2)
{
  dyn_mixed args;
  int Duration = iDur;
			int Xbgr1 = 0;
			int Xbgr2 = 136;			
			int Xbgr1 = 0;			
			int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int XL1 = 40; int XR1 = 135; 
			int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2;; int XL2 = 40; int XR2 = 135; 
			int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int XL3 = 40; int XR3 = 135; 
      
			int Xbgr1_2 = 0;
			int Xbgr2_2 = 136;
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2, 136, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3, 
                          Pict1, Pict2, Pict3, Pict4,
                          sText,
                          Active_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2, 136, 0,
                          Fn1_2, Cl1, Alig1, MaxSp1, Y1_2, XL1, XR1, 
                          Fn2_2, Cl2, Alig2, MaxSp2, Y2_2, XL2, XR2, 
                          Fn3_2, Cl3, Alig3, MaxSp3, Y3_2, XL3, XR3, 
                          Pict1_2, Pict2_2, Pict3_2, Pict4_2,
                          sText_2);		
      DebugFTN("level1","portal_sign_arguments - args: ", args);
      return args;
}

dyn_mixed portal_normalni_uslovi_Sarani(int iSign_Type_ID, string sIP_addr)
{
//   float fTemp;
//   if(sIP_addr == "10.101.0.110")
//     dpGet("SysSarani:MS1.response.state.Temperatura_Zraka", fTemp);
//   else
//     dpGet("SysSarani:MS2.response.state.Temperatura_Zraka", fTemp);
  
   float fTemp = 0, fTemp1, fTemp2;
  time ms1t, ms2t, tCurTime = getCurrentTime();
 dpGet("SysSarani:MS1.response.state.Temperatura_Zraka", fTemp1, "SysSarani:MS1.response.state.Temperatura_Zraka:_original.._stime", ms1t); 
 dpGet("SysSarani:MS2.response.state.Temperatura_Zraka", fTemp2, "SysSarani:MS2.response.state.Temperatura_Zraka:_original.._stime", ms2t); 
 
 if(sIP_addr == "10.101.0.11")
 {
   //ako su ocitanja temperature azurna posalji ih na znak
   if((tCurTime - ms1t) < 600)  //10min
     fTemp = fTemp1;
   else if((tCurTime - ms2t) < 600)  //10min
     fTemp = fTemp2;
   else
       fTemp = 99;       
 }
 else
 {
   //ako su ocitanja temperature azurna posalji ih na znak
   if((tCurTime - ms2t) < 600)  //10min
     fTemp = fTemp2;
   else if((tCurTime - ms1t) < 600)  //10min
     fTemp = fTemp1;
   else
       fTemp = 99;       
 }
     
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
      string sText;
      if(fTemp == 99)
        sText = "ТУНЕЛ'nl'ШАРАНИ'nl''TIME''nl'"; // + iTemp + "'nl'";
      else
        sText = "ТУНЕЛ'nl'ШАРАНИ'nl''TIME'  "+ sTemp +"C'nl'"; // + iTemp + "'nl'";
      
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
      //string sText_2 = "'TIME'"; // + iTemp + "'nl'";
      string sText_2;
      if(fTemp == 99)
        sText_2 = "TUNNEL'nl'ŠARANI'nl''TIME''nl'"; // + iTemp + "'nl'";
      else
        sText_2 = "TUNNEL'nl'ŠARANI'nl''TIME'  "+ sTemp +"C'nl'"; // + iTemp + "'nl'";
      
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

dyn_mixed portal_normalni_uslovi_Savinac(int iSign_Type_ID, string sIP_addr)
{  
   float fTemp = 0, fTemp1;
  time ms1t, ms2t, tCurTime = getCurrentTime();
 dpGet("SysSavinac:MS1.response.state.Temperatura_Zraka", fTemp1, "SysSavinac:MS1.response.state.Temperatura_Zraka:_original.._stime", ms1t);  
 
   //ako su ocitanja temperature azurna posalji ih na znak
   if((tCurTime - ms1t) < 600)  //10min
     fTemp = fTemp1;
   else
       fTemp = 99;            
 
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
			//string sText = "Đ˘ĐŁĐťĐ•Đ›'nl'Đ¨ĐĐ ĐĐťĐ'nl''TIME'  "+ sTemp +"C'nl' "; // + iTemp + "'nl'";
      string sText;
      if(fTemp == 99)
        sText = "ТУНЕЛ'nl'САВИНАЦ'nl''TIME''nl'"; // + iTemp + "'nl'";
      else
        sText = "ТУНЕЛ'nl'САВИНАЦ'nl''TIME'  "+ sTemp +"C'nl'"; // + iTemp + "'nl'";
      
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
			//string sText_2 = "TUNNEL'nl'BrÄ‘ani'nl''TIME'  "+ sTemp +"C'nl'"; // + iTemp + "'nl'";
      //string sText_2 = "'TIME'"; // + iTemp + "'nl'";
      string sText_2;
      if(fTemp == 99)
        sText_2 = "TUNNEL'nl'SAVINAC'nl''TIME''nl'"; // + iTemp + "'nl'";
      else
        sText_2 = "TUNNEL'nl'SAVINAC'nl''TIME'  "+ sTemp +"C'nl'"; // + iTemp + "'nl'";
      
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
      DebugFTN("level1","portal_normalni_uslovi_Savinac - args: ", args);
      return args;
}

dyn_mixed portal_normalni_uslovi_Brdjani(int iSign_Type_ID, string sIP_addr)
{  
   float fTemp = 0, fTemp1;
  time ms1t, ms2t, tCurTime = getCurrentTime();
 dpGet("SysBrdjani:MS1.response.state.Temperatura_Zraka", fTemp1, "SysBrdjani:MS1.response.state.Temperatura_Zraka:_original.._stime", ms1t);  
 
   //ako su ocitanja temperature azurna posalji ih na znak
   if((tCurTime - ms1t) < 600)  //10min
     fTemp = fTemp1;
   else
       fTemp = 99;            
 
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
      string sText;
      if(fTemp == 99)
        sText = "ТУНЕЛ'nl'БРЂАНИ'nl''TIME''nl'"; // + iTemp + "'nl'";
      else
        sText = "ТУНЕЛ'nl'БРЂАНИ'nl''TIME'  "+ sTemp +"C'nl'"; // + iTemp + "'nl'";
      
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
      string sText_2;
      if(fTemp == 99)
        sText_2 = "TUNNEL'nl'BRDJANI'nl''TIME''nl'"; // + iTemp + "'nl'";
      else
        sText_2 = "TUNNEL'nl'BRDJANI'nl''TIME'  "+ sTemp +"C'nl'"; // + iTemp + "'nl'";
      
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
      DebugFTN("level1","portal_normalni_uslovi_Brdjani - args: ", args);
      return args;
}

dyn_mixed portal_kolona_vozila_60(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  /*
  args = portal_sign_arguments(iSign_Type_ID, sIP_addr,
                                1, //int Active,		                          			
                          			30, //int Bgr1,                          			
                          			30, //int Bgr2,                          			                          					
                          			3, 4, //int Fn1, int Y1, 
                          			2, 24, //int Fn2, int Y2, 
                          			2, 500, //int Fn3, int Y3, 
                          			2, 0, 0, 8, //int Pict1, int Pict2, int Pict3, int Pict4, 
                          			"ОПРЕЗ'nl'КОЛОНА ВОЗИЛА'nl''nl'", //string sText,
                                1, //int Active_2,
                                16, //int Bgr1_2,
                                16, //int Bgr2_2,
                                1, 4, //int Fn1_2, int Y1_2,
                                1, 24, //int Fn2_2, int Y2_2, 
                          			1, 500, //int Fn3_2, int Y3_2, 
                          			2, 0, 0, 8, //int Pict1_2, int Pict2_2, int Pict3_2, int Pict4_2, 
                          			"ATTENTION'nl'TRAFFIC JAM'nl''nl'" //string sText_2
                                );
         
*/         
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 30;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 30;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 3; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 4; int XL1 = 40; int XR1 = 135; 
			int Fn2 = 2; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 24; int XL2 = 40; int XR2 = 135; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 40; int XR3 = 135; 
			int Pict1 = 2; int Pict2 = 0; int Pict3 = 0; int Pict4 = 8; 
			string sText = "ОПРЕЗ'nl'КОЛОНА ВОЗИЛА'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 16;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 16;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 1; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 4; int XL1_2 = 40; int XR1_2 = 135; 
			int Fn2_2 = 0; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 24; int XL2_2 = 40; int XR2_2 = 135; 
			int Fn3_2 = 0; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 40; int XR3_2 = 135; 
			int Pict1_2 = 2; int Pict2_2 = 0; int Pict3_2 = 0; int Pict4_2 = 8; 
			string sText_2 = "ATTENTION'nl'TRAFFIC JAM'nl''nl'";
      
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
      DebugFTN("level1","portal_guzva_60 - args: ", args);
      
      return args;
}

dyn_mixed portal_kolona_vozila_40(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 28;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 28;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 3; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 4; int XL1 = 40; int XR1 = 135; 
			int Fn2 = 2; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 24; int XL2 = 40; int XR2 = 135; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 40; int XR3 = 135; 
			int Pict1 = 2; int Pict2 = 0; int Pict3 = 0; int Pict4 = 8; 
			string sText = "ОПРЕЗ'nl'КОЛОНА ВОЗИЛА'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 16;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 16;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 1; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 4; int XL1_2 = 40; int XR1_2 = 135; 
			int Fn2_2 = 0; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 24; int XL2_2 = 40; int XR2_2 = 135; 
			int Fn3_2 = 0; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 40; int XR3_2 = 135; 
			int Pict1_2 = 2; int Pict2_2 = 0; int Pict3_2 = 0; int Pict4_2 = 8; 
			string sText_2 = "ATTENTION'nl'TRAFFIC JAM'nl''nl'";
      
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
      DebugFTN("level1","portal_guzva_40 - args: ", args);
      return args;	
}

dyn_mixed portal_vjetar_60(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 30;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 30;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 3; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 4; int XL1 = 40; int XR1 = 135; 
			int Fn2 = 3; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 24; int XL2 = 40; int XR2 = 135; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 40; int XR3 = 135; 
			int Pict1 = 2; int Pict2 = 0; int Pict3 = 0; int Pict4 = 8; 
			string sText = "ОПРЕЗ'nl'ЈАК ВЕТАР'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 11;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 11;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 1; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 4; int XL1_2 = 40; int XR1_2 = 135; 
			int Fn2_2 = 0; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 24; int XL2_2 = 40; int XR2_2 = 135; 
			int Fn3_2 = 0; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 40; int XR3_2 = 135; 
			int Pict1_2 = 2; int Pict2_2 = 0; int Pict3_2 = 0; int Pict4_2 = 8; 
			string sText_2 = "ATTENTION'nl'STRONG WIND'nl''nl'";
      
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
      DebugFTN("level1","portal_vjetar_60 - args: ", args);
      return args;
}

dyn_mixed portal_vjetar_40(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 28;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 28;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 3; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 4; int XL1 = 40; int XR1 = 135; 
			int Fn2 = 3; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 24; int XL2 = 40; int XR2 = 135; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 40; int XR3 = 135; 
			int Pict1 = 2; int Pict2 = 0; int Pict3 = 0; int Pict4 = 8; 
			string sText = "ОПРЕЗ'nl'ЈАК ВЕТАР'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 11;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 11;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 1; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 4; int XL1_2 = 40; int XR1_2 = 135; 
			int Fn2_2 = 0; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 24; int XL2_2 = 40; int XR2_2 = 135; 
			int Fn3_2 = 0; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 40; int XR3_2 = 135; 
			int Pict1_2 = 2; int Pict2_2 = 0; int Pict3_2 = 0; int Pict4_2 = 8; 
			string sText_2 = "ATTENTION'nl'STRONG WIND'nl''nl'";
      
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
      DebugFTN("level1","portal_vjetar_40 - args: ", args);
      return args;
}

dyn_mixed portal_magla_60(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 30;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 30;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 3; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 4; int XL1 = 40; int XR1 = 135; 
			int Fn2 = 3; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 24; int XL2 = 40; int XR2 = 135; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 40; int XR3 = 135; 
			int Pict1 = 2; int Pict2 = 0; int Pict3 = 0; int Pict4 = 8; 
			string sText = "ОПРЕЗ'nl'МАГЛА'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 14;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 14;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 1; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 4; int XL1_2 = 40; int XR1_2 = 135; 
			int Fn2_2 = 1; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 24; int XL2_2 = 40; int XR2_2 = 135; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 40; int XR3_2 = 135; 
			int Pict1_2 = 2; int Pict2_2 = 0; int Pict3_2 = 0; int Pict4_2 = 8; 
			string sText_2 = "ATTENTION'nl'FOG'nl''nl'";
      
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
      DebugFTN("level1","portal_magla_60 - args: ", args);
      return args;
}

dyn_mixed portal_magla_40(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 28;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 28;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 3; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 4; int XL1 = 40; int XR1 = 135; 
			int Fn2 = 3; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 24; int XL2 = 40; int XR2 = 135; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 40; int XR3 = 135; 
			int Pict1 = 2; int Pict2 = 0; int Pict3 = 0; int Pict4 = 8; 
			string sText = "ОПРЕЗ'nl'МАГЛА'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 14;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 14;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 1; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 4; int XL1_2 = 40; int XR1_2 = 135; 
			int Fn2_2 = 1; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 24; int XL2_2 = 40; int XR2_2 = 135; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 40; int XR3_2 = 135; 
			int Pict1_2 = 2; int Pict2_2 = 0; int Pict3_2 = 0; int Pict4_2 = 8; 
			string sText_2 = "ATTENTION'nl'FOG'nl''nl'";
      
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
      DebugFTN("level1","portal_magla_40 - args: ", args);
      return args;
}

dyn_mixed portal_klizavo_60(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 30;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 30;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 3; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 4; int XL1 = 40; int XR1 = 135; 
			int Fn2 = 2; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 24; int XL2 = 40; int XR2 = 135; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 40; int XR3 = 135; 
			int Pict1 = 2; int Pict2 = 0; int Pict3 = 0; int Pict4 = 8; 
			string sText = "ОПРЕЗ'nl'КЛИЗАВ КОЛОВОЗ'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 7;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 14;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 7;			
			int Fn1_2 = 1; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 4; int XL1_2 = 40; int XR1_2 = 135; 
			int Fn2_2 = 0; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 24; int XL2_2 = 40; int XR2_2 = 135; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 40; int XR3_2 = 135; 
			int Pict1_2 = 2; int Pict2_2 = 0; int Pict3_2 = 0; int Pict4_2 = 8; 
			string sText_2 = "ATTENTION'nl'SLIPPERY ROAD'nl''nl'";
      
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
      DebugFTN("level1","portal_klizavo_60 - args: ", args);
      return args;
}

dyn_mixed portal_klizavo_40(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 28;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 28;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 3; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 4; int XL1 = 40; int XR1 = 135; 
			int Fn2 = 2; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 24; int XL2 = 40; int XR2 = 135; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 40; int XR3 = 135; 
			int Pict1 = 2; int Pict2 = 0; int Pict3 = 0; int Pict4 = 8; 
			string sText = "ОПРЕЗ'nl'КЛИЗАВ КОЛОВОЗ'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 7;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 7;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			

			int Fn1_2 = 1; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 4; int XL1_2 = 40; int XR1_2 = 135; 
			int Fn2_2 = 0; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 24; int XL2_2 = 40; int XR2_2 = 135; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 40; int XR3_2 = 135; 
			int Pict1_2 = 2; int Pict2_2 = 0; int Pict3_2 = 0; int Pict4_2 = 8; 
			string sText_2 = "ATTENTION'nl'SLIPPERY ROAD'nl''nl'";
      
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
      DebugFTN("level1","portal_klizavo_40 - args: ", args);
      return args;
}

dyn_mixed portal_poledica_40(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 28;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 28;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 3; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 4; int XL1 = 40; int XR1 = 135; 
			int Fn2 = 3; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 24; int XL2 = 40; int XR2 = 135; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 40; int XR3 = 135; 
			int Pict1 = 2; int Pict2 = 0; int Pict3 = 0; int Pict4 = 8; 
			string sText = "ОПРЕЗ'nl'ПОЛЕДИЦА'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 7;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 7;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 1; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 4; int XL1_2 = 40; int XR1_2 = 135; 
			int Fn2_2 = 1; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 24; int XL2_2 = 40; int XR2_2 = 135; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 40; int XR3_2 = 135; 
			int Pict1_2 = 2; int Pict2_2 = 0; int Pict3_2 = 0; int Pict4_2 = 8; 
			string sText_2 = "ATTENTION'nl'ICE'nl''nl'";
      
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
      DebugFTN("level1","portal_poledica_40 - args: ", args);
      return args;
}

dyn_mixed portal_snijeg_60(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 30;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 30;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 3; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 4; int XL1 = 40; int XR1 = 135; 
			int Fn2 = 3; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 24; int XL2 = 40; int XR2 = 135; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 40; int XR3 = 135; 
			int Pict1 = 2; int Pict2 = 0; int Pict3 = 0; int Pict4 = 8; 
			string sText = "ОПРЕЗ'nl'СНЕГ'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 7;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 7;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 1; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 4; int XL1_2 = 40; int XR1_2 = 135; 
			int Fn2_2 = 1; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 24; int XL2_2 = 40; int XR2_2 = 135; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 40; int XR3_2 = 135; 
			int Pict1_2 = 2; int Pict2_2 = 0; int Pict3_2 = 0; int Pict4_2 = 8; 
			string sText_2 = "ATTENTION'nl'SNOW'nl''nl'";
      
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
      DebugFTN("level1","portal_snijeg_60 - args: ", args);
      return args;
}

dyn_mixed portal_snijeg_40(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 28;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 28;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 3; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 4; int XL1 = 40; int XR1 = 135; 
			int Fn2 = 3; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 24; int XL2 = 40; int XR2 = 135; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 40; int XR3 = 135; 
			int Pict1 = 2; int Pict2 = 0; int Pict3 = 0; int Pict4 = 8; 
			string sText = "ОПРЕЗ'nl'СНЕГ'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 7;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 7;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 1; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 4; int XL1_2 = 40; int XR1_2 = 135; 
			int Fn2_2 = 1; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 24; int XL2_2 = 40; int XR2_2 = 135; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 40; int XR3_2 = 135; 
			int Pict1_2 = 2; int Pict2_2 = 0; int Pict3_2 = 0; int Pict4_2 = 8; 
			string sText_2 = "ATTENTION'nl'SNOW'nl''nl'";
      
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
      DebugFTN("level1","portal_snijeg_40 - args: ", args);
      return args;
}

dyn_mixed portal_zatvoren_tunel(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 18;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 18;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 3; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 4; int XL1 = 40; int XR1 = 135; 
			int Fn2 = 2; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 24; int XL2 = 40; int XR2 = 135; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 40; int XR3 = 135; 
			int Pict1 = 1; int Pict2 = 0; int Pict3 = 0; int Pict4 = 7; 
			string sText = "ОПРЕЗ'nl'ТУНЕЛ ЗАТВОРЕН'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 18;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 18;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 1; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 4; int XL1_2 = 40; int XR1_2 = 135; 
			int Fn2_2 = 0; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 24; int XL2_2 = 40; int XR2_2 = 135; 
			int Fn3_2 = 0; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 40; int XR3_2 = 135; 
			int Pict1_2 = 1; int Pict2_2 = 0; int Pict3_2 = 0; int Pict4_2 = 7; 
			string sText_2 = "ATTENTION'nl'TUNNEL CLOSED'nl''nl'";
      
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
      DebugFTN("level1","portal_zatvoren_tunel - args: ", args);
      return args;
}


dyn_mixed portal_pozar_zatvoren_tunel(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 18;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 18;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 3; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 4; int XL1 = 40; int XR1 = 135; 
			int Fn2 = 2; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 24; int XL2 = 40; int XR2 = 135; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 40; int XR3 = 135; 
			int Pict1 = 1; int Pict2 = 0; int Pict3 = 0; int Pict4 = 7; 
			string sText = "ОПРЕЗ'nl'ТУНЕЛ ЗАТВОРЕН'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 16;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 16;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 1; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 4; int XL1_2 = 40; int XR1_2 = 135; 
			int Fn2_2 = 0; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 24; int XL2_2 = 40; int XR2_2 = 135; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 40; int XR3_2 = 135; 
			int Pict1_2 = 1; int Pict2_2 = 0; int Pict3_2 = 0; int Pict4_2 = 7; 
			string sText_2 = "ATTENTION'nl'TUNNEL CLOSED'nl''nl'";
      
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
      DebugFTN("level1","portal_zatvoren_tunel - args: ", args);
      return args;
}

dyn_mixed portal_nezgoda_u_desnoj_traci_60(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 30;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 30;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 0; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 0; int XL1 = 40; int XR1 = 135; 
			int Fn2 = 0; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 13; int XL2 = 40; int XR2 = 135; 
			int Fn3 = 0; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 26; int XL3 = 40; int XR3 = 135; 
			int Pict1 = 2; int Pict2 = 0; int Pict3 = 5; int Pict4 = 0; 
			string sText = "ОПРЕЗ'nl'САОБРАЋАЈНА'nl'НЕЗГОДА'nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 14;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 14;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 3; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 1; int XL1_2 = 40; int XR1_2 = 135; 
			int Fn2_2 = 3; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 27; int XL2_2 = 40; int XR2_2 = 135; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 40; int XR3_2 = 135; 
			int Pict1_2 = 2; int Pict2_2 = 0; int Pict3_2 = 5; int Pict4_2 = 0; 
			string sText_2 = "ATTENTION'nl'TRAFFIC ACCIDENT'nl''nl'";
      
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
      DebugFTN("level1","portal_nezgoda_u_desnoj_traci_60 - args: ", args);
      return args;
}

dyn_mixed portal_nezgoda_u_lijevoj_traci_60(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 30;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 30;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 0; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 0; int XL1 = 40; int XR1 = 135; 
			int Fn2 = 0; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 15; int XL2 = 40; int XR2 = 135; 
			int Fn3 = 0; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 30; int XL3 = 40; int XR3 = 135; 
			int Pict1 = 0; int Pict2 = 4; int Pict3 = 0; int Pict4 = 8; 
			string sText = "ОПРЕЗ'nl'САОБРАЋАЈНА'nl'НЕЗГОДА'nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 14;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 14;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 3; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 4; int XL1_2 = 40; int XR1_2 = 135; 
			int Fn2_2 = 3; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 24; int XL2_2 = 40; int XR2_2 = 135; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 40; int XR3_2 = 135; 
			int Pict1_2 = 0; int Pict2_2 = 4; int Pict3_2 = 0; int Pict4_2 = 8; 
			string sText_2 = "ATTENTION'nl'TRAFFIC ACCIDENT'nl''nl'";
      
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
      DebugFTN("level1","portal_nezgoda_u_lijevoj_traci_60 - args: ", args);
      return args;
}

dyn_mixed portal_suprotan_smjer_40(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 28;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 28;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 2; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 4; int XL1 = 40; int XR1 = 135; 
			int Fn2 = 2; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 24; int XL2 = 40; int XR2 = 135; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 40; int XR3 = 135; 
			int Pict1 = 0; int Pict2 = 4; int Pict3 = 0; int Pict4 = 8; 
			string sText = "КОРИСТИТЕ'nl'ДЕСНУ ТРАКУ'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 14;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 14;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 1; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 4; int XL1_2 = 40; int XR1_2 = 135; 
			int Fn2_2 = 1; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 24; int XL2_2 = 40; int XR2_2 = 135; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 40; int XR3_2 = 135; 
			int Pict1_2 = 0; int Pict2_2 = 4; int Pict3_2 = 0; int Pict4_2 = 8; 
			string sText_2 = "USE RIGHT'nl'LANE'nl''nl'";
      
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
      DebugFTN("level1","portal_suprotan_smjer - args: ", args);
      return args;
}

dyn_mixed portal_radovi_u_desnoj_traci_60(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 30;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 30;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 3; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 4; int XL1 = 40; int XR1 = 135; 
			int Fn2 = 2; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 24; int XL2 = 40; int XR2 = 135; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 40; int XR3 = 135; 
			int Pict1 = 2; int Pict2 = 0; int Pict3 = 5; int Pict4 = 0; 
			string sText = "ОПРЕЗ'nl'РАДОВИ НА ПУТУ'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 10;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 10;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 1; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 4; int XL1_2 = 40; int XR1_2 = 135; 
			int Fn2_2 = 0; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 24; int XL2_2 = 40; int XR2_2 = 135; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 40; int XR3_2 = 135; 
			int Pict1_2 = 2; int Pict2_2 = 0; int Pict3_2 = 5; int Pict4_2 = 0; 
			string sText_2 = "ATTENTION'nl'ROAD WORKS'nl''nl'";
      
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
      DebugFTN("level1","portal_radovi_u_desnoj_traci_60 - args: ", args);
      return args;
}

dyn_mixed portal_radovi_u_lijevoj_traci_60(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 30;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 30;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 3; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 4; int XL1 = 40; int XR1 = 135; 
			int Fn2 = 2; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 24; int XL2 = 40; int XR2 = 135; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 40; int XR3 = 135; 
			int Pict1 = 0; int Pict2 = 4; int Pict3 = 0; int Pict4 = 8; 
			string sText = "ОПРЕЗ'nl'РАДОВИ НА ПУТУ'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 10;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 10;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 1; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 4; int XL1_2 = 40; int XR1_2 = 135; 
			int Fn2_2 = 0; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 24; int XL2_2 = 40; int XR2_2 = 135; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 40; int XR3_2 = 135; 
			int Pict1_2 = 0; int Pict2_2 = 4; int Pict3_2 = 0; int Pict4_2 = 8; 
			string sText_2 = "ATTENTION'nl'ROAD WORKS'nl''nl'";
      
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
      DebugFTN("level1","portal_radovi_u_lijevoj_traci_60 - args: ", args);
      return args;
}

dyn_mixed portal_zatvorena_tunelska_cijev_40(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 28;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 10;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 2; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 4; int XL1 = 40; int XR1 = 135; 
			int Fn2 = 2; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 24; int XL2 = 40; int XR2 = 135; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 40; int XR3 = 135; 
			int Pict1 = 2; int Pict2 = 0; int Pict3 = 5; int Pict4 = 0; 
			string sText = "КОРИСТИТЕ'nl'ЛЕВУ ТРАКУ'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 28;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 23;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 1; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 4; int XL1_2 = 40; int XR1_2 = 135; 
			int Fn2_2 = 1; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 24; int XL2_2 = 40; int XR2_2 = 135; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 40; int XR3_2 = 135; 
			int Pict1_2 = 2; int Pict2_2 = 0; int Pict3_2 = 5; int Pict4_2 = 0; 
			string sText_2 = "USE LEFT'nl'LANE'nl''nl'";
      
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
      DebugFTN("level1","portal_zatvorena_tunelska_cijev_40 - args: ", args);
      return args;
}

dyn_mixed portal_dvosmjerni_saobracaj_40(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 28;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 13;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 2; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 0; int XL1 = 40; int XR1 = 135; 
			int Fn2 = 2; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 13; int XL2 = 40; int XR2 = 135; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 26; int XL3 = 40; int XR3 = 135; 
			int Pict1 = 0; int Pict2 = 4; int Pict3 = 0; int Pict4 = 8; 
			string sText = "ОПРЕЗ'nl'ДВОСМЕРНИ'nl'САОБРАЋАЈ'nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 28;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 23;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 0; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 0; int XL1_2 = 40; int XR1_2 = 135; 
			int Fn2_2 = 0; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 13; int XL2_2 = 40; int XR2_2 = 135; 
			int Fn3_2 = 0; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 26; int XL3_2 = 40; int XR3_2 = 135; 
			int Pict1_2 = 0; int Pict2_2 = 4; int Pict3_2 = 0; int Pict4_2 = 8; 
			string sText_2 = "ATTENTION'nl'TWO-WAY'nl'TRAFFIC'nl'";
      
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
      DebugFTN("level1","portal_dvosmjerni_saobracaj_40 - args: ", args);
      return args;
}



//generise argumente za komandu za promjenu slike na Portalnom znaku
//iValue
dyn_mixed generateArgumentsForPortal_PetljaSign(string sIP_addr, int iSign_Type_ID, int iValue)
{  
   dyn_mixed args;
  
   switch(iValue)
   {
     case 40:
       args = portal_petlja_ugasen(iSign_Type_ID, sIP_addr);
       break;
     //normalni uslovi
     case 41:
       args = portal_petlja_normalni_uslovi_120(iSign_Type_ID, sIP_addr);
       break;
     case 42:
       args = portal_petlja_kolona_vozila_40(iSign_Type_ID, sIP_addr);       
       break;
     case 43:       
       args = portal_petlja_kolona_vozila_60(iSign_Type_ID, sIP_addr);
       break;
     case 44:       
       args = portal_petlja_kolona_vozila_80(iSign_Type_ID, sIP_addr);
       break;     
     case 45:
       args = portal_petlja_vjetar_40(iSign_Type_ID, sIP_addr);
       break;
     case 46:
       args = portal_petlja_vjetar_60(iSign_Type_ID, sIP_addr);
       break;
     case 47:
       args = portal_petlja_vjetar_80(iSign_Type_ID, sIP_addr);
       break;
     case 49:
       args = portal_petlja_magla_40(iSign_Type_ID, sIP_addr);
       break;
     case 50:
       args = portal_petlja_magla_60(iSign_Type_ID, sIP_addr);
       break;
     case 51:
       args = portal_petlja_magla_80(iSign_Type_ID, sIP_addr);
       break;
     case 53:
       args = portal_petlja_klizavo_40(iSign_Type_ID, sIP_addr);
       break;
     case 54:
       args = portal_petlja_klizavo_60(iSign_Type_ID, sIP_addr);
       break; 
     case 55:
       args = portal_petlja_klizavo_80(iSign_Type_ID, sIP_addr);
       break;      
     case 57:
       args = portal_petlja_poledica_40(iSign_Type_ID, sIP_addr);
       break;
     case 58:
       args = portal_petlja_poledica_60(iSign_Type_ID, sIP_addr);
       break;
     case 59:
       args = portal_petlja_poledica_80(iSign_Type_ID, sIP_addr);
       break;       
     case 61:
       args = portal_petlja_snijeg_40(iSign_Type_ID, sIP_addr);
       break;
     case 62:
       args = portal_petlja_snijeg_60(iSign_Type_ID, sIP_addr);
       break;
     case 63:
       args = portal_petlja_snijeg_80(iSign_Type_ID, sIP_addr);
       break;
     case 65:
       args = portal_petlja_nezgoda_u_desnoj_traci_60(iSign_Type_ID, sIP_addr);
       break;
     case 66:
       args = portal_petlja_nezgoda_u_lijevoj_traci_60(iSign_Type_ID, sIP_addr);
       break;
     case 67:
       args = portal_petlja_suprotan_smjer_40(iSign_Type_ID, sIP_addr);
       break;
    // case 68:
      // args = portal_petlja_radovi_u_desnoj_lijevoj_60(iSign_Type_ID, sIP_addr);
      // break;
     case 69:
       args = portal_petlja_radovi_na_putu_60(iSign_Type_ID, sIP_addr);
       break;
     case 70:
       args = portal_petlja_radovi_na_putu_80(iSign_Type_ID, sIP_addr);
       break;
     case 71:
       args = portal_petlja_dvosmjerni_saobracaj_40(iSign_Type_ID, sIP_addr);
       break;
     case 72:
       args = portal_petlja_pozar_zatvoren_tunel(iSign_Type_ID, sIP_addr);
       break;
     
     default: break;
   }       
      DebugFTN("level2", "generateArgumenstForMatrixSign - args: ", args);
      return args;  
}

dyn_mixed portal_petlja_ugasen(int iSign_Type_ID, string sIP_addr)
{      
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 0;		
			int Duration = iDur;
			int Bgr1 = 36;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 36;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 2; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 5; int Y1 = 1; int XL1 = 48; int XR1 =  iXR_Petlja; 
			int Fn2 = 2; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 5; int Y2 = 27; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 5; int Y3 = 500; int XL3 = 48; int XR3 = iXR_Petlja;  
			//string sText = "ТУНЕЛ'nl'ШАРАНИ'nl''TIME'  "+ sTemp +"C'nl' "; // + iTemp + "'nl'";
      string sText;
        sText = "СРЕЋАН'nl'ПУТ'nl''nl'"; // + iTemp + "'nl'";
      
      int Active_2 = 0;		
			int Duration_2 = iDur;
			int Bgr1_2 =36;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 36;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 5; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 5; int Y1_2 = 1; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 5; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 5; int Y2_2 = 27; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 5; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 5; int Y3_2 = 500; int XL3_2 = 48; int XR3_2 = iXR_Petlja;  
			//string sText_2 = "TUNNEL'nl'ŠARANI'nl''TIME'  "+ sTemp +"C'nl'"; // + iTemp + "'nl'";
      //string sText_2 = "'TIME'"; // + iTemp + "'nl'";
      string sText_2;
        sText_2 = "ENJOY'nl'SERBIA'nl''nl'"; // + iTemp + "'nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3,
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2, 
                          sText_2);		
      DebugFTN("level1","portal_petlja_ugasen - args: ", args);
      return args;
}

dyn_mixed portal_petlja_normalni_uslovi_120(int iSign_Type_ID, string sIP_addr)
{      
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 0;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 0;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 2; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 5; int Y1 = 1; int XL1 = 48; int XR1 =  iXR_Petlja; 
			int Fn2 = 2; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 5; int Y2 = 27; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 5; int Y3 = 500; int XL3 = 48; int XR3 = iXR_Petlja;  
			//string sText = "ТУНЕЛ'nl'ШАРАНИ'nl''TIME'  "+ sTemp +"C'nl' "; // + iTemp + "'nl'";
      string sText;
        sText = "СРЕЋАН'nl'ПУТ'nl''nl'"; // + iTemp + "'nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 =36;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 36;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 5; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 5; int Y1_2 = 1; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 5; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 5; int Y2_2 = 27; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 5; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 5; int Y3_2 = 500; int XL3_2 = 48; int XR3_2 = iXR_Petlja;  
			//string sText_2 = "TUNNEL'nl'ŠARANI'nl''TIME'  "+ sTemp +"C'nl'"; // + iTemp + "'nl'";
      //string sText_2 = "'TIME'"; // + iTemp + "'nl'";
      string sText_2;
        sText_2 = "ENJOY'nl'SERBIA'nl''nl'"; // + iTemp + "'nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3,                           
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2, 
                          sText_2);		
      DebugFTN("level1","portal_petlja_normalni_uslovi_120 - args: ", args);
      return args;
}

dyn_mixed portal_petlja_normalni_uslovi_100(int iSign_Type_ID, string sIP_addr)
{      
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 34;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 34;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 2; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 5; int Y1 = 1; int XL1 = 48; int XR1 =  iXR_Petlja; 
			int Fn2 = 2; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 5; int Y2 = 27; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 5; int Y3 = 500; int XL3 = 48; int XR3 = iXR_Petlja;  
			//string sText = "ТУНЕЛ'nl'ШАРАНИ'nl''TIME'  "+ sTemp +"C'nl' "; // + iTemp + "'nl'";
      string sText;
        sText = "СРЕЋАН'nl'ПУТ'nl''nl'"; // + iTemp + "'nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 =34;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 34;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 5; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 5; int Y1_2 = 1; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 5; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 5; int Y2_2 = 27; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 5; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 5; int Y3_2 = 500; int XL3_2 = 48; int XR3_2 = iXR_Petlja;  
			//string sText_2 = "TUNNEL'nl'ŠARANI'nl''TIME'  "+ sTemp +"C'nl'"; // + iTemp + "'nl'";
      //string sText_2 = "'TIME'"; // + iTemp + "'nl'";
      string sText_2;
        sText_2 = "ENJOY'nl'SERBIA'nl''nl'"; // + iTemp + "'nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3,                           
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2, 
                          sText_2);		
      DebugFTN("level1","portal_petlja_normalni_uslovi_100 - args: ", args);
      return args;
}



dyn_mixed portal_petlja_kolona_vozila_80(int iSign_Type_ID, string sIP_addr)
{
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
			int Fn1 = 1; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 1; int XL1 = 48; int XR1 = iXR_Petlja; 
			int Fn2 = 1; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 27; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 48; int XR3 = iXR_Petlja; 
			string sText = "ОПРЕЗ'nl'КОЛОНА ВОЗИЛА'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 16;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 16;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 4; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 1; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 4; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 27; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 0; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 48; int XR3_2 = iXR_Petlja; 
			string sText_2 = "ATTENTION'nl'TRAFFIC JAM'nl''nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3, 
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2, 
                          sText_2);		
      DebugFTN("level1","portal_petlja_guzva_80 - args: ", args);
      
      return args;
}

dyn_mixed portal_petlja_kolona_vozila_60(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
                  
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 30;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 30;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 1; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 1; int XL1 = 48; int XR1 = iXR_Petlja; 
			int Fn2 = 1; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 27; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 48; int XR3 = iXR_Petlja; 
			string sText = "ОПРЕЗ'nl'КОЛОНА ВОЗИЛА'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 16;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 16;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 4; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 1; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 4; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 27; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 0; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 48; int XR3_2 = iXR_Petlja; 
			string sText_2 = "ATTENTION'nl'TRAFFIC JAM'nl''nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3, 
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2, 
                          sText_2);		
      DebugFTN("level1","portal_petlja_guzva_60 - args: ", args);
      
      return args;
}

dyn_mixed portal_petlja_kolona_vozila_40(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 28;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 28;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 1; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 1; int XL1 = 48; int XR1 = iXR_Petlja; 
			int Fn2 = 1; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 27; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 48; int XR3 = iXR_Petlja;  
			string sText = "ОПРЕЗ'nl'КОЛОНА ВОЗИЛА'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 16;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 16;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 4; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 1; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 4; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 27; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 0; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 48; int XR3_2 = iXR_Petlja; 
      string sText_2 = "ATTENTION'nl'TRAFFIC JAM'nl''nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3, 
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2, 
                          sText_2);		
      DebugFTN("level1","portal_petlja_guzva_40 - args: ", args);
      return args;	
}

dyn_mixed portal_petlja_vjetar_80(int iSign_Type_ID, string sIP_addr)
{
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
			int Fn1 = 1; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 1; int XL1 = 48; int XR1 = iXR_Petlja; 
			int Fn2 = 1; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 27; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 48; int XR3 = iXR_Petlja; 
			string sText = "ОПРЕЗ'nl'ЈАК ВЕТАР'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 11;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 11;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 4; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 1; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 4; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 27; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 0; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 48; int XR3_2 = iXR_Petlja;       
			string sText_2 = "ATTENTION'nl'STRONG WIND'nl''nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3, 
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2, 
                          sText_2);		
      DebugFTN("level1","portal_petlja_vjetar_80 - args: ", args);
      return args;
}
dyn_mixed portal_petlja_vjetar_60(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 30;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 30;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 1; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 1; int XL1 = 48; int XR1 = iXR_Petlja; 
			int Fn2 = 1; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 27; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 48; int XR3 = iXR_Petlja; 
			string sText = "ОПРЕЗ'nl'ЈАК ВЕТАР'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 11;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 11;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 4; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 1; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 4; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 27; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 0; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 48; int XR3_2 = iXR_Petlja;       
			string sText_2 = "ATTENTION'nl'STRONG WIND'nl''nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3, 
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2, 
                          sText_2);		
      DebugFTN("level1","portal_petlja_vjetar_60 - args: ", args);
      return args;
}

dyn_mixed portal_petlja_vjetar_40(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 28;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 28;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 1; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 1; int XL1 = 48; int XR1 = iXR_Petlja; 
			int Fn2 = 1; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 27; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 48; int XR3 = iXR_Petlja; 
			string sText = "ОПРЕЗ'nl'ЈАК ВЕТАР'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 11;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 11;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 4; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 1; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 4; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 27; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 0; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 48; int XR3_2 = iXR_Petlja; 
			string sText_2 = "ATTENTION'nl'STRONG WIND'nl''nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3,
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2,
                          sText_2);		
      DebugFTN("level1","portal_petlja_vjetar_40 - args: ", args);
      return args;
}

dyn_mixed portal_petlja_magla_80(int iSign_Type_ID, string sIP_addr)
{
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
			int Fn1 = 1; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 1; int XL1 = 48; int XR1 = iXR_Petlja; 
			int Fn2 = 1; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 27; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 48; int XR3 = iXR_Petlja; 
			string sText = "ОПРЕЗ'nl'МАГЛА'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 14;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 14;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 4; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 1; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 4; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 27; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 48; int XR3_2 = iXR_Petlja; 
			string sText_2 = "ATTENTION'nl'FOG'nl''nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3,
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2,
                          sText_2);		
      DebugFTN("level1","portal_petlja_magla_80 - args: ", args);
      return args;
}


dyn_mixed portal_petlja_magla_60(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 30;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 30;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 1; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 1; int XL1 = 48; int XR1 = iXR_Petlja; 
			int Fn2 = 1; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 27; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 48; int XR3 = iXR_Petlja; 
			string sText = "ОПРЕЗ'nl'МАГЛА'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 14;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 14;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 4; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 1; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 4; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 27; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 48; int XR3_2 = iXR_Petlja; 
			string sText_2 = "ATTENTION'nl'FOG'nl''nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3,
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2,
                          sText_2);		
      DebugFTN("level1","portal_petlja_magla_60 - args: ", args);
      return args;
}

dyn_mixed portal_petlja_magla_40(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 28;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 28;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 1; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 1; int XL1 = 48; int XR1 = iXR_Petlja; 
			int Fn2 = 1; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 27; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 48; int XR3 = iXR_Petlja; 
			string sText = "ОПРЕЗ'nl'МАГЛА'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 14;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 14;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 4; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 1; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 4; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 27; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 48; int XR3_2 = iXR_Petlja; 
			string sText_2 = "ATTENTION'nl'FOG'nl''nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3,
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2,
                          sText_2);		
      DebugFTN("level1","portal_petlja_magla_40 - args: ", args);
      return args;
}

dyn_mixed portal_petlja_klizavo_80(int iSign_Type_ID, string sIP_addr)
{
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
			int Fn1 = 1; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 1; int XL1 = 48; int XR1 = iXR_Petlja; 
			int Fn2 = 1; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 27; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 48; int XR3 = iXR_Petlja; 
			string sText = "ОПРЕЗ'nl'КЛИЗАВ КОЛОВОЗ'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 7;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 14;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 7;			
			int Fn1_2 = 4; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 1; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 4; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 27; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 48; int XR3_2 = iXR_Petlja; 
			string sText_2 = "ATTENTION'nl'SLIPPERY ROAD'nl''nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3, 
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2, 
                          sText_2);		
      DebugFTN("level1","portal_petlja_klizavo_80 - args: ", args);
      return args;
}
dyn_mixed portal_petlja_klizavo_60(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 30;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 30;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 1; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 1; int XL1 = 48; int XR1 = iXR_Petlja; 
			int Fn2 = 1; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 27; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 48; int XR3 = iXR_Petlja; 
			string sText = "ОПРЕЗ'nl'КЛИЗАВ КОЛОВОЗ'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 7;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 14;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 7;			
			int Fn1_2 = 4; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 1; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 4; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 27; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 48; int XR3_2 = iXR_Petlja; 
			string sText_2 = "ATTENTION'nl'SLIPPERY ROAD'nl''nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3, 
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2, 
                          sText_2);		
      DebugFTN("level1","portal_petlja_klizavo_60 - args: ", args);
      return args;
}

dyn_mixed portal_petlja_klizavo_40(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 28;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 28;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 1; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 1; int XL1 = 48; int XR1 = iXR_Petlja; 
			int Fn2 = 1; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 27; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 48; int XR3 = iXR_Petlja; 
			string sText = "ОПРЕЗ'nl'КЛИЗАВ КОЛОВОЗ'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 7;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 7;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 4; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 4; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 4; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 24; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 48; int XR3_2 = iXR_Petlja; 
			string sText_2 = "ATTENTION'nl'SLIPPERY ROAD'nl''nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3, 
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2, 
                          sText_2);		
      DebugFTN("level1","portal_petlja_klizavo_40 - args: ", args);
      return args;
}

dyn_mixed portal_petlja_poledica_80(int iSign_Type_ID, string sIP_addr)
{
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
			int Fn1 = 1; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 1; int XL1 = 48; int XR1 = iXR_Petlja; 
			int Fn2 = 1; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 27; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 48; int XR3 = iXR_Petlja;  
			string sText = "ОПРЕЗ'nl'ПОЛЕДИЦА'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 7;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 7;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 4; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 1; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 4; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 27; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 48; int XR3_2 = iXR_Petlja; 
			int Pict1_2 = 2; int Pict2_2 = 0; int Pict3_2 = 0; int Pict4_2 = 8; 
			string sText_2 = "ATTENTION'nl'ICE'nl''nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3, 
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2, 
                          sText_2);		
      DebugFTN("level1","portal_petlja_poledica_80 - args: ", args);
      return args;
}

dyn_mixed portal_petlja_poledica_60(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 30;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 30;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 1; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 1; int XL1 = 48; int XR1 = iXR_Petlja; 
			int Fn2 = 1; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 27; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 48; int XR3 = iXR_Petlja;  
			string sText = "ОПРЕЗ'nl'ПОЛЕДИЦА'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 7;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 7;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 4; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 1; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 4; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 27; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 48; int XR3_2 = iXR_Petlja; 
			int Pict1_2 = 2; int Pict2_2 = 0; int Pict3_2 = 0; int Pict4_2 = 8; 
			string sText_2 = "ATTENTION'nl'ICE'nl''nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3, 
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2, 
                          sText_2);		
      DebugFTN("level1","portal_petlja_poledica_60 - args: ", args);
      return args;
}

dyn_mixed portal_petlja_poledica_40(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 28;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 28;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 1; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 1; int XL1 = 48; int XR1 = iXR_Petlja; 
			int Fn2 = 1; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 27; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 48; int XR3 = iXR_Petlja;  
			string sText = "ОПРЕЗ'nl'ПОЛЕДИЦА'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 7;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 7;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 4; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 1; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 4; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 27; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 48; int XR3_2 = iXR_Petlja; 
			int Pict1_2 = 2; int Pict2_2 = 0; int Pict3_2 = 0; int Pict4_2 = 8; 
			string sText_2 = "ATTENTION'nl'ICE'nl''nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3, 
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2, 
                          sText_2);		
      DebugFTN("level1","portal_petlja_poledica_40 - args: ", args);
      return args;
}

dyn_mixed portal_petlja_snijeg_80(int iSign_Type_ID, string sIP_addr)
{
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
			int Fn1 = 1; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 1; int XL1 = 48; int XR1 = iXR_Petlja; 
			int Fn2 = 1; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 27; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 48; int XR3 = iXR_Petlja; 
			string sText = "ОПРЕЗ'nl'СНЕГ'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 7;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 7;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 4; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 1; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 4; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 27; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 48; int XR3_2 = iXR_Petlja;  
			string sText_2 = "ATTENTION'nl'SNOW'nl''nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3, 
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2, 
                          sText_2);		
      DebugFTN("level1","portal_petlja_snijeg_80 - args: ", args);
      return args;
}
dyn_mixed portal_petlja_snijeg_60(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 30;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 30;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 1; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 1; int XL1 = 48; int XR1 = iXR_Petlja; 
			int Fn2 = 1; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 27; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 48; int XR3 = iXR_Petlja; 
			string sText = "ОПРЕЗ'nl'СНЕГ'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 7;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 7;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 4; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 1; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 4; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 27; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 48; int XR3_2 = iXR_Petlja;  
			string sText_2 = "ATTENTION'nl'SNOW'nl''nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3, 
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2, 
                          sText_2);		
      DebugFTN("level1","portal_petlja_snijeg_60 - args: ", args);
      return args;
}

dyn_mixed portal_petlja_snijeg_40(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 28;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 28;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 1; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 1; int XL1 = 48; int XR1 = iXR_Petlja; 
			int Fn2 = 1; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 27; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 48; int XR3 = iXR_Petlja; 
			string sText = "ОПРЕЗ'nl'СНЕГ'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 7;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 7;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 4; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 1; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 4; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 27; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 48; int XR3_2 = iXR_Petlja;  
			string sText_2 = "ATTENTION'nl'SNOW'nl''nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3, 
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2, 
                          sText_2);		
      DebugFTN("level1","portal_petlja_snijeg_40 - args: ", args);
      return args;
}

dyn_mixed portal_petlja_zatvoren_tunel(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 18;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 18;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 1; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 1; int XL1 = 48; int XR1 = iXR_Petlja; 
			int Fn2 = 1; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 27; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 48; int XR3 = iXR_Petlja;  
			string sText = "ОПРЕЗ'nl'ТУНЕЛ ЗАТВОРЕН'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 18;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 18;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 4; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 1; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 4; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 27; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 0; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 48; int XR3_2 = iXR_Petlja; 
			string sText_2 = "ATTENTION'nl'TUNNEL CLOSED'nl''nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3,
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2, 
                          sText_2);		
      DebugFTN("level1","portal_petlja_zatvoren_tunel - args: ", args);
      return args;
}


dyn_mixed portal_petlja_pozar_zatvoren_tunel(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 18;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 18;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 1; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 1; int XL1 = 48; int XR1 = iXR_Petlja; 
			int Fn2 = 1; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 27; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 48; int XR3 = iXR_Petlja; 
			string sText = "ОПРЕЗ'nl'ТУНЕЛ ЗАТВОРЕН'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 16;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 16;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 4; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 1; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 4; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 27; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 48; int XR3_2 = iXR_Petlja; 
			string sText_2 = "ATTENTION'nl'TUNNEL CLOSED'nl''nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3,
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2,
                          sText_2);		
      DebugFTN("level1","portal_petlja_zatvoren_tunel - args: ", args);
      return args;
}

dyn_mixed portal_petlja_nezgoda_u_desnoj_traci_60(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 30;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 30;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 0; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 0; int XL1 = 48; int XR1 = iXR_Petlja; 
			int Fn2 = 0; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 15; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 0; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 30; int XL3 = 48; int XR3 = iXR_Petlja; 
			int Pict1 = 2; int Pict2 = 0; int Pict3 = 5; int Pict4 = 0; 
			string sText = "ОПРЕЗ'nl'САОБРАЋАЈНА'nl'НЕЗГОДА'nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 14;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 14;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 3; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 4; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 3; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 24; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 48; int XR3_2 = iXR_Petlja; 
			int Pict1_2 = 2; int Pict2_2 = 0; int Pict3_2 = 5; int Pict4_2 = 0; 
			string sText_2 = "ATTENTION'nl'TRAFFIC ACCIDENT'nl''nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3, 
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2, 
                          sText_2);		
      DebugFTN("level1","portal_nezgoda_u_desnoj_traci_60 - args: ", args);
      return args;
}

dyn_mixed portal_petlja_nezgoda_u_lijevoj_traci_60(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 30;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 30;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 0; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 0; int XL1 = 48; int XR1 = iXR_Petlja; 
			int Fn2 = 0; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 15; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 0; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 30; int XL3 = 48; int XR3 = iXR_Petlja; 
			int Pict1 = 0; int Pict2 = 4; int Pict3 = 0; int Pict4 = 8; 
			string sText = "ОПРЕЗ'nl'САОБРАЋАЈНА'nl'НЕЗГОДА'nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 14;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 14;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 3; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 4; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 3; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 24; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 48; int XR3_2 = iXR_Petlja; 
			int Pict1_2 = 0; int Pict2_2 = 4; int Pict3_2 = 0; int Pict4_2 = 8; 
			string sText_2 = "ATTENTION'nl'TRAFFIC ACCIDENT'nl''nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3, 
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2, 
                          sText_2);		
      DebugFTN("level1","portal_nezgoda_u_lijevoj_traci_60 - args: ", args);
      return args;
}

dyn_mixed portal_petlja_suprotan_smjer_40(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 28;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 28;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 0; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 4; int XL1 = 48; int XR1 = iXR_Petlja; 
			int Fn2 = 0; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 24; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 48; int XR3 = iXR_Petlja; 
			string sText = "КОРИСТИТЕ'nl'ДЕСНУ ТРАКУ'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 14;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 14;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 3; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 4; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 3; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 24; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 3; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 48; int XR3_2 = iXR_Petlja; 
			string sText_2 = "USE RIGHT'nl'LANE'nl''nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3, 
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2, 
                          sText_2);		
      DebugFTN("level1","portal_petlja_suprotan_smjer - args: ", args);
      return args;
}

dyn_mixed portal_petlja_radovi_u_desnoj_traci_60(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 30;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 30;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 3; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 4; int XL1 = 48; int XR1 = iXR_Petlja; 
			int Fn2 = 2; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 24; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 48; int XR3 = iXR_Petlja; 
			int Pict1 = 2; int Pict2 = 0; int Pict3 = 5; int Pict4 = 0; 
			string sText = "ОПРЕЗ'nl'РАДОВИ НА ПУТУ'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 10;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 10;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 1; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 4; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 0; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 24; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 48; int XR3_2 = iXR_Petlja; 
			int Pict1_2 = 2; int Pict2_2 = 0; int Pict3_2 = 5; int Pict4_2 = 0; 
			string sText_2 = "ATTENTION'nl'ROAD WORKS'nl''nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3, 
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2, 
                          sText_2);		
      DebugFTN("level1","portal_radovi_u_desnoj_traci_60 - args: ", args);
      return args;
}

dyn_mixed portal_petlja_radovi_na_putu_60(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 30;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 30;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 0; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 1; int XL1 = 48; int XR1 = iXR_Petlja; 
			int Fn2 = 0; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 27; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 48; int XR3 = iXR_Petlja; 
			string sText = "ОПРЕЗ'nl'РАДОВИ НА ПУТУ'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 10;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 10;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 3; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 1; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 3; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 27; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 3; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 48; int XR3_2 = iXR_Petlja; 
			string sText_2 = "ATTENTION'nl'ROAD WORKS'nl''nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3, 
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2, 
                          sText_2);		
      DebugFTN("level1","portal_radovi_na_putu_60 - args: ", args);
      return args;
}

dyn_mixed portal_petlja_radovi_na_putu_80(int iSign_Type_ID, string sIP_addr)
{
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
			int Fn1 = 0; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 1; int XL1 = 48; int XR1 = iXR_Petlja; 
			int Fn2 = 0; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 27; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 48; int XR3 = iXR_Petlja; 
			string sText = "ОПРЕЗ'nl'РАДОВИ НА ПУТУ'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 10;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 10;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 3; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 1; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 3; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 27; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 48; int XR3_2 = iXR_Petlja; 
			string sText_2 = "ATTENTION'nl'ROAD WORKS'nl''nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3, 
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2, 
                          sText_2);		
      DebugFTN("level1","portal_radovi_na_putu_80 - args: ", args);
      return args;
}

dyn_mixed portal_petlja_zatvorena_tunelska_cijev_40(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 28;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 10;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 2; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 4; int XL1 = 48; int XR1 = iXR_Petlja; 
			int Fn2 = 2; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 24; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 2; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 500; int XL3 = 48; int XR3 = iXR_Petlja; 
			int Pict1 = 2; int Pict2 = 0; int Pict3 = 5; int Pict4 = 0; 
			string sText = "КОРИСТИТЕ'nl'ЛЕВУ ТРАКУ'nl''nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 28;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 23;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 1; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 4; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 1; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 24; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 1; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 500; int XL3_2 = 48; int XR3_2 = iXR_Petlja; 
			int Pict1_2 = 2; int Pict2_2 = 0; int Pict3_2 = 5; int Pict4_2 = 0; 
			string sText_2 = "USE LEFT'nl'LANE'nl''nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3, 
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2, 
                          sText_2);		
      DebugFTN("level1","portal_zatvorena_tunelska_cijev_40 - args: ", args);
      return args;
}

dyn_mixed portal_petlja_dvosmjerni_saobracaj_80(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 32;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 13;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 0; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 0; int XL1 = 48; int XR1 = iXR_Petlja; 
			int Fn2 = 0; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 15; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 0; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 30; int XL3 = 48; int XR3 = iXR_Petlja; 
			string sText = "ОПРЕЗ'nl'ДВОСМЕРНИ'nl'САОБРАЋАЈ'nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 32;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 23;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 3; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 0; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 3; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 15; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 3; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 30; int XL3_2 = 48; int XR3_2 = iXR_Petlja;  
			string sText_2 = "ATTENTION'nl'TWO-WAY'nl'TRAFFIC'nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3, 
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2, 
                          sText_2);		
      DebugFTN("level1","portal_dvosmjerni_saobracaj_80 - args: ", args);
      return args;
}

dyn_mixed portal_petlja_dvosmjerni_saobracaj_60(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 30;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 13;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 0; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 0; int XL1 = 48; int XR1 = iXR_Petlja; 
			int Fn2 = 0; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 15; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 0; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 30; int XL3 = 48; int XR3 = iXR_Petlja; 
			string sText = "ОПРЕЗ'nl'ДВОСМЕРНИ'nl'САОБРАЋАЈ'nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 30;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 23;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 3; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 0; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 3; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 15; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 3; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 30; int XL3_2 = 48; int XR3_2 = iXR_Petlja;  
			string sText_2 = "ATTENTION'nl'TWO-WAY'nl'TRAFFIC'nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3, 
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2, 
                          sText_2);		
      DebugFTN("level1","portal_dvosmjerni_saobracaj_60 - args: ", args);
      return args;
}

dyn_mixed portal_petlja_dvosmjerni_saobracaj_40(int iSign_Type_ID, string sIP_addr)
{
  dyn_mixed args;
  string sDateTime = "";
  int iTemp = 0;
  int Active = 1;		
			int Duration = iDur;
			int Bgr1 = 28;
			int Xbgr1 = 0;
			int Ybgr1 = 0;
			int Bgr2 = 13;
			int Xbgr2 = 136;
			int Ybgr2 = 0;			
			int Fn1 = 0; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 0; int XL1 = 48; int XR1 = iXR_Petlja; 
			int Fn2 = 0; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 15; int XL2 = 48; int XR2 = iXR_Petlja; 
			int Fn3 = 0; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 30; int XL3 = 48; int XR3 = iXR_Petlja; 
			string sText = "ОПРЕЗ'nl'ДВОСМЕРНИ'nl'САОБРАЋАЈ'nl'";
      
      int Active_2 = 1;		
			int Duration_2 = iDur;
			int Bgr1_2 = 28;
			int Xbgr1_2 = 0;
			int Ybgr1_2 = 0;
			int Bgr2_2 = 23;
			int Xbgr2_2 = 136;
			int Ybgr2_2 = 0;			
			int Fn1_2 = 3; int Cl1_2 = 0; int Alig1_2 = 1; int MaxSp1_2 = 2; int Y1_2 = 0; int XL1_2 = 48; int XR1_2 = iXR_Petlja; 
			int Fn2_2 = 3; int Cl2_2 = 0; int Alig2_2 = 1; int MaxSp2_2 = 2; int Y2_2 = 15; int XL2_2 = 48; int XR2_2 = iXR_Petlja; 
			int Fn3_2 = 3; int Cl3_2 = 0; int Alig3_2 = 1; int MaxSp3_2 = 2; int Y3_2 = 30; int XL3_2 = 48; int XR3_2 = iXR_Petlja;  
			string sText_2 = "ATTENTION'nl'TWO-WAY'nl'TRAFFIC'nl'";
      
      args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, 
                          Bgr1, 0, 0,
                          Bgr2,  iXbgr2_Petlja, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3, 
                          sText,
                          Active_2, Duration_2, 
                          Bgr1_2, 0, 0,
                          Bgr2_2,  iXbgr2_Petlja, 0,
                          Fn1_2, Cl1_2, Alig1_2, MaxSp1_2, Y1_2, XL1_2, XR1_2, 
                          Fn2_2, Cl2_2, Alig2_2, MaxSp2_2, Y2_2, XL2_2, XR2_2, 
                          Fn3_2, Cl3_2, Alig3_2, MaxSp3_2, Y3_2, XL3_2, XR3_2, 
                          sText_2);		
      DebugFTN("level1","portal_dvosmjerni_saobracaj_40 - args: ", args);
      return args;
}
