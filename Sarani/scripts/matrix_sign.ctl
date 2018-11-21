#uses "SharedFunc.ctl"

int main() 
{
  sendToSignSingle();
}

mapping map;

string xmlRpcMethodWriteMatrixSettings = "bstelecom.sign.SignProtocolAdapter.writeMatrixSignPanel";

bool initSign = false;


sendToSignSingle(){
 /* 
  mapping map;
  int tip;  
  string ip_adresa;
  //int iSignSymbol;
  
  //tip znaka i ip adresa
*/

  //dobijamo mapirane vrijednosti znakova koje treba poslati na adapter
//  dyn_int getSignSymbols = getMappingValueArray(value, dpe);
  //dyn_mixed args = makeDynMixed(tip, ip_adresa, getSignSymbols);
  //DebugTN("getSignSymbols - ", getSignSymbols);
  //DebugTN("getSignSymbols.len - ", dynlen(getSignSymbols));
  dyn_mixed args;
     
     //samo slika
			
			string sIP_addr = "10.101.0.108";
      
      //samo slika
			int iSign_Type_ID = 6; 
			int Active = 1;			
			int Duration = 40;
			int Bgr1 = 2;			
			int Fn1 = 0; int Cl1 = 0; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 0; int XL1 = 0; int XR1 = 47; 
			int Fn2 = 0; int Cl2 = 0; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 0; int XL2 = 0; int XR2 = 47; 
			int Fn3 = 0; int Cl3 = 0; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 0; int XL3 = 0; int XR3 = 47;
     	string sText = "";	 
      
      /*
        //samo teks
			int iSign_Type_ID = 6; 
			int Active = 1;			
			int Duration = 40;
			int Bgr1 = 0;			
			int Fn1 = 0; int Cl1 = 4; int Alig1 = 1; int MaxSp1 = 2; int Y1 = 0; int XL1 = 0; int XR1 = 47; 
			int Fn2 = 0; int Cl2 = 4; int Alig2 = 1; int MaxSp2 = 2; int Y2 = 13; int XL2 = 0; int XR2 = 47; 
			int Fn3 = 0; int Cl3 = 4; int Alig3 = 1; int MaxSp3 = 2; int Y3 = 26; int XL3 = 0; int XR3 = 47; 
			string sText = "TEST\0dva\0tri\0";
			//string sText = "ЉЖЂШЋЧЊЏ\0\0\0";
      */		
			args = makeDynMixed(iSign_Type_ID, sIP_addr, 
                          Active, Duration, Bgr1, 
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1, 
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2, 
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3, 
                          sText);		
  
  //tip znaka na protokolu treba da se podudara sa tipom na scada-i
  //DebugTN("getSignSymbols: " + getSignSymbols);
    
  DebugTN("SendToSign: " + sIP_addr + "; Args: " + args);
  
  int res = xmlRpcSendToSign(args, xmlRpcMethodWriteMatrixSettings, false);
    
  DebugTN("SendToSign " + sIP_addr + " Response: " + res);
    
  if (res == 0){
    DebugTN("sendToSign " + sIP_addr + " OK.");
    dpSet(dpe + ".status", 0);       
  }
  else{
    DebugTN("SendToSign "+ dpe + " Not sent.");
    dpSet(dpe + ".status", -1);
  } 
 
}

sendToSignLuminosity(anytype ident, dyn_dyn_anytype list){
  
  if(!initLumin)
  {
    initLumin = true;
    return;
  }
  
  DebugTN("sendToSignLuminosity start");
  
  string dpe;
  string value;

  for(int i = 2; i <= dynlen(list); i++)  //starta sa 2 zato sto liste pocinju od 1, a sql upit vraca u prvoj liniji header pa treba i njega preskociti
  {    
    value = list[i][2];
    dpe = list[i][1];
    dpe = dpSubStr(dpe, DPSUB_DP);  //DPSUB_DP -
    startThread("sendToSignLuminositySingle", dpe, value);  
   }
  
  DebugTN("sendToSignLuminosity end");
  
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
   DebugTN("SendToLuminosity: " + dpe + "; Args: " + args);
    
   int res = xmlRpcSendToSign(args, xmlRpcMethodWriteBrightness, false);

   DebugTN("SendToSignLuminosity " + dpe + " Response: " + res);
    
   if (res != 0){
      DebugTN("SendToSignLuminosity "+ dpe + " Not sent.");
      dpSet(dpe + ".status", -1);
   }
   else{
      DebugTN("sendToSignLuminosity " + dpe + " OK;");
      dpSet(dpe + ".status", 0);
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
      DebugTN("Error: Mapping does not contain value. Map: " + map + "; Value" + vrijednost);
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
      DebugTN("Error: Mapping does not contain value. Map: " + map + "; Value " + vrijednost);
      stanje_na_znaku[1] = -1;
      return stanje_na_znaku;
    }
      
    stanje_na_znaku[i] = map[vrijednost];
  
  }

  return stanje_na_znaku;    
}

