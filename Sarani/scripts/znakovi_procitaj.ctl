//-dbg "level1" - za debugiranje
#uses "CtrlXmlRpc"

int main() 
{
   readFromSigns();  
}

string sys_name = "SysSarani:";
string xmlRpcMethodReadSettings = "bstelecom.sign.SignProtocolAdapter.readCurrentSignPanel";
string xmlRpcMethodReadDisplaySettings = "bstelecom.sign.SignProtocolAdapter.readCurrentPortalSignPanel";
string xmlRpcMethodReadMatrixSettings = "bstelecom.sign.SignProtocolAdapter.readCurrentMatrixSignPanel";
string xmlRpcMethodReadBrightness = "bstelecom.sign.SignProtocolAdapter.readSignBrightness";
string xmlRpcMethodReadOversizeVehicleSettings = "bstelecom.sign.SignProtocolAdapter.readVangabaritni_Sign";

readFromSigns(){  
 
  while(true){    
    repeatReadSign();
    repeatReadSignBrightness();
    delay(120);   
  }
  
}

void repeatReadSign()
{
  dyn_dyn_anytype xx;
  
  dpQuery("SELECT '_online.._value' FROM '" + sys_name + "V*.command.izbor_znaka' WHERE _DPT = \"Sign\"", xx);  
        
  dyn_int threads;
    
  for(int i = 2; i <= dynlen(xx); i++){
     int thId = startThread("readSignPanelSingle", dpSubStr(xx[i][1], DPSUB_DP));
     waitThread(thId);
  }

}

void repeatReadSignBrightness()
{
  dyn_dyn_anytype xx;
 
  dpQuery("SELECT '_online.._value' FROM '" + sys_name + "V*.command.intezitet' WHERE _DPT = \"Sign\"", xx);  
        
  dyn_int threads;
    
  for(int i = 2; i <= dynlen(xx); i++){
     int thId = startThread("readSignBrightnessSingle", dpSubStr(xx[i][1], DPSUB_DP));
     waitThread(thId);
  }

}

void readSignPanelSingle(string nazivZnaka)
{
  delay(0.5); 
  
  string id = "servID" + rand();
  string host = "localhost";
  int port = "8087";
  bool secure = FALSE;
  
  xmlrpcClient();
  xmlrpcConnectToServer(id, host, port, secure);

  string ip_adresa, status;
  int tipZnaka; 
  
  dpGet(sys_name + nazivZnaka + ".status", status);
  dpGet(sys_name + nazivZnaka + ".IP", ip_adresa);
  dpGet(sys_name + nazivZnaka + ".tip_znaka", tipZnaka);
  
  //trenutno se salje na znak
  if(status == 1){
    DebugFTN("level1", "znak: " + nazivZnaka + " -- status: " + status);
    //delay(1);   
    //return; //trenutno se salje na znak
  }
  
  //vrijednosti koje dobijemo kad procitamo sa znaka
  mapping readCurrentSign;
  //za vangabaritno vozilo vraca int
  int readCurentSignOversizeVehicle;
  //tip znaka je prvi parametar koji prosljedjujemo funkciji
  dyn_mixed argsSign = makeDynMixed(tipZnaka, ip_adresa);
  int Active, Duration;
 
  //pokusaj ocitanje sa znaka max 3 puta, ako prodje odmah ocitanje, nece pokusavati dalje jer je uspio ocitati
  for(int x = 1; x <= 3; x++)
  {
    if(tipZnaka == 4) xmlrpcCall(id, xmlRpcMethodReadDisplaySettings, argsSign, readCurrentSign);
    else if(tipZnaka == 6) xmlrpcCall(id, xmlRpcMethodReadMatrixSettings, argsSign, readCurrentSign);
    else if(tipZnaka == 10) xmlrpcCall(id, xmlRpcMethodReadOversizeVehicleSettings, argsSign, readCurentSignOversizeVehicle); 
    else xmlrpcCall(id, xmlRpcMethodReadSettings, argsSign, readCurrentSign);      
    
    if(tipZnaka != 10){    
      
      Active = readCurrentSign["Active0"];
      Duration = readCurrentSign["Duration0"];
      
      if(x == 1) DebugFTN("level1", "Prvo ocitanje na znaku:  " + nazivZnaka + " Active:" + Active + " Duration:" + Duration);
      else if(x == 2) DebugFTN("level1", "Drugo ocitanje na znaku:  " + nazivZnaka + " Active:" + Active + " Duration:" + Duration);
      else if(x == 3) DebugFTN("level1", "Trece ocitanje na znaku:  " + nazivZnaka + " Active:" + Active + " Duration:" + Duration);
      
      //u slucaju da nije dobro ocitao sa znaka vrijednosti, vrati se na pocetak i pokusaj ponovo u suprotnom zavrsi for petlju
      if(Active == -1 || Duration == -1){
          delay(2);
          
      } 
      else x = 3; 
    }
    else x = 3;  
  }
     
  switch(tipZnaka){
    case 4:  //portalni znak
      //doraditi sta se bude slalo na znak
      setPortalDatapoint(tipZnaka, nazivZnaka, readCurrentSign, status);      
      break;
    case 6:  //matricni znak
      setMatrxSingDatapoint(tipZnaka, nazivZnaka, readCurrentSign, status);   
      break;
    case 10:  //vangabaritni znakovi
      setOversizeVehicleSignDatapoint(tipZnaka, nazivZnaka, readCurentSignOversizeVehicle, status);   
      break;
    default:  //ostali znakovi
      setDatapoint(tipZnaka, nazivZnaka, readCurrentSign, status);
  }

  xmlrpcCloseServer(id);  
  
}

void readSignBrightnessSingle(string nazivZnaka)
{
  delay(0.5); 
  
  string id = "servID" + rand();
  string host = "localhost";
  int port = "8087";
  bool secure = FALSE;
  
  xmlrpcClient();
  xmlrpcConnectToServer(id, host, port, secure);

  string ip_adresa, status;
  int tipZnaka;
  
  dpGet(sys_name + nazivZnaka + ".status", status);
  dpGet(sys_name + nazivZnaka + ".IP", ip_adresa);
  dpGet(sys_name + nazivZnaka + ".tip_znaka", tipZnaka);
  
  //vrijednosti koje dobijemo kad procitamo sa znaka
  mapping readCurrentSign;
  //tip znaka je prvi parametar koji prosljedjujemo funkciji
  dyn_mixed argsSign = makeDynMixed(tipZnaka, ip_adresa);
  int brightness_value;
  int brightness_value_depedence;  
  
  //pokusaj ocitanje sa znaka max 3 puta, ako prodje odmah ocitanje, nece pokusavati dalje jer je uspio ocitati
  for(int x = 1; x <= 3; x++)
  {
     //ocitaj intenzitet sa znaka
     xmlrpcCall(id, xmlRpcMethodReadBrightness, argsSign, readCurrentSign);
  
     brightness_value = readCurrentSign["CurrentBrightness"];
     brightness_value_depedence = readCurrentSign["Brightness_depedence_Value"];
        
     if(x == 1) DebugFTN("level1", "Prvo ocitanje intenziteta na znaku:  " + nazivZnaka + " CurrentBrightness:" + brightness_value);
     else if(x == 2) DebugFTN("level1", "Drugo ocitanje intenziteta na znaku:  " + nazivZnaka + " CurrentBrightness:" + brightness_value);
     else if(x == 3) DebugFTN("level1", "Trece ocitanje intenziteta na znaku:  " + nazivZnaka + " CurrentBrightness:" + brightness_value);
      
     //ako nema komunikacije sa znakom ponovo pokusaj ocitati
     if(brightness_value == -1 || brightness_value_depedence == -1){
         delay(2);
     }
     else x = 3;  
  }

  //ako nema komunikacije sa znakom postavi status -1
  if(brightness_value == -1 || brightness_value_depedence == -1){
     dpSet(sys_name + nazivZnaka + ".status", -1);
  }
  else{
    //u postotcima (%)
    dpSet(sys_name + nazivZnaka + ".response.intezitet", brightness_value);
    //0 = Fix mode; 1 = Brightness depends on day time; 2 = Brightness depends on light sensor(s)
    dpSet(sys_name + nazivZnaka + ".response.rezim_osvetljenja", brightness_value_depedence);
  }
  
  xmlrpcCloseServer(id);  
}

mapping getMapping(int tip){
  
  dyn_string mapiranje;
  mapping map;
  string dp = "Tip" + tip + ".mapirane_vrijednosti";
  string vrijednost;
  string mapirana_vrijednost;
  dpGet(dp, mapiranje);
  
  for(int i=1; i <= dynlen(mapiranje); i++){  
     vrijednost = substr(mapiranje[i], 0, strpos(mapiranje[i], "|", 0));
     mapirana_vrijednost = substr(mapiranje[i], strpos(mapiranje[i], "|", 1) + 1);   
     //dobijamo id slike na osnovu vrijednosti koju dobijemo sa znaka
     map[mapirana_vrijednost] = vrijednost;
  }  
  
  return map;  
}

int getImageMappingValue(int value, string dpe){

  int tip;
  int stanje_na_znaku;
  dpGet(dpe + ".tip_znaka", tip);
  
  //uzmi mapirane vrijednosti
  mapping map = getMapping(tip);

  string vrijednost = value;
  
  if (!mappingHasKey(map, vrijednost)){
      DebugFTN("level1", "Error: Mapping does not contain value. Map: " + map + "; Value" + vrijednost);
      return -1;
  }
    
  stanje_na_znaku = map[vrijednost];

  return stanje_na_znaku;    
}

setDatapoint(int tip_znaka, string nazivZnaka, mapping readCurrentSign, int status){
  
  //panelId0 je zapravo panel/znak koji je postavljen
  dyn_int niz_panela;
  int duration;
  dyn_int poslani_znakovi;
  dpGet(sys_name + nazivZnaka + ".command.izbor_znaka", poslani_znakovi);
  
  //smjesti u varijablu vrijednost piktograma
  niz_panela[1] = readCurrentSign["PanelId0"];
  duration = readCurrentSign["Duration0"];
  
  DebugFTN("level1", "znak: " + nazivZnaka + " -- na znaku: " + getImageMappingValue(niz_panela[1], nazivZnaka) + " -- scada: " + poslani_znakovi[1]);
  
  //ako nema komunikacije sa znakom vrati postavi status -1
  if(niz_panela[1] == -1 || duration == -1){
     dpSet(sys_name + nazivZnaka + ".status", -1);  
  }
  else {
    
    //kad uspije procitati postavi status na 0
    dpSet(sys_name + nazivZnaka + ".status", 0);
    int panelId = getImageMappingValue(niz_panela[1], nazivZnaka);
    
    //provjeri da li ima znakova koji se razlikuju
    if(poslani_znakovi[1] != panelId){
       DebugFTN("level1", "Error: Different signs: " + nazivZnaka + "; trenutna vrijednost: " + poslani_znakovi[i] + "; na znaku: " + panelId); 
       dpSet(nazivZnaka + ".status", -10);
     }
    
    /*
    //postavi status tako da operateri imaju indikaciju da je uspostavljena komunikacija sa znakom
    if (status == -8 || status == -9 || status == -1 || status == -10 || status == 1){
       DebugFTN("level1", "Resetting status: " + status + "; znak: " + nazivZnaka);
       dpSet(sys_name + nazivZnaka + ".status", -2);    
    }
    */
    
    mapping map = getMapping(tip_znaka);  
    dyn_int izborZnaka;  
    string vrijednost = niz_panela[1];
    izborZnaka[1] = map[vrijednost];
    DebugFTN("level1", "DMV Value: " + vrijednost);
  
    //DebugFTN("level1", "DMV Value: " + vrijednosti);          
    dpSet(sys_name + nazivZnaka + ".response.izbor_znaka", izborZnaka);    
  }
}


setOversizeVehicleSignDatapoint(int tip_znaka, string nazivZnaka, int readCurentSignOversizeVehicle, int status){
  
  dyn_int poslani_znakovi;
  dpGet(sys_name + nazivZnaka + ".command.izbor_znaka", poslani_znakovi);
  
  //0 -ugasen
  //1 - previsoko vozilo
  //2 - presiroko vozilo
  //-1 - greska ili nepoznato
  
  DebugFTN("level1", "znak: " + nazivZnaka + " -- na znaku: " + getImageMappingValue(readCurentSignOversizeVehicle, nazivZnaka) + " -- scada: " + poslani_znakovi[1]);
  
  //ako nema komunikacije sa znakom vrati postavi status -1
  if(readCurentSignOversizeVehicle == -1){
     dpSet(sys_name + nazivZnaka + ".status", -1);  
  }
  else{
    
    //kad uspije procitati postavi status na 0
    dpSet(sys_name + nazivZnaka + ".status", 0);
    //vrati -1 ako ne sadrzi vrijednost ili mapiranu vrijednost
    int panelId = getImageMappingValue(readCurentSignOversizeVehicle, nazivZnaka);
    
    //provjeri da li se stanje na znaku razlikuje od onoga sto je poslano
    if(poslani_znakovi[1] != panelId){
       DebugFTN("level1", "Error: Different signs: " + nazivZnaka + "; trenutna vrijednost: " + poslani_znakovi[i] + "; na znaku: " + panelId); 
       dpSet(nazivZnaka + ".status", -10);
    }
    
    mapping map = getMapping(tip_znaka);  
    dyn_int izborZnaka;  
    string vrijednost = readCurentSignOversizeVehicle;
    izborZnaka[1] = map[vrijednost];
    DebugFTN("level1", "Value: " + vrijednost);
  
    //DebugFTN("level1", "DMV Value: " + vrijednosti);          
    dpSet(sys_name + nazivZnaka + ".response.izbor_znaka", izborZnaka);    
  }
}


setMatrxSingDatapoint(int tip_znaka, string nazivZnaka, mapping readCurrentSign, int status){
  
  int Active, Duration, Bgr1;
  int Active_2, Duration_2, Bgr1_2;
		string sText, sText_2;
  
  dyn_int procitani_znakovi;
  dyn_int poslani_znakovi;
  dpGet(sys_name + nazivZnaka + ".command.izbor_znaka", poslani_znakovi);
  
  Active = readCurrentSign["Active0"];
  Duration = readCurrentSign["Duration0"];
  
  //ako nema komunikacije sa znakom vrati postavi status -1
  if(Active == -1 || Duration == -1){
    dpSet(sys_name + nazivZnaka + ".status", -1);  
  }
  else{
    
    //kad uspije procitati postavi status na 0
    dpSet(sys_name + nazivZnaka + ".status", 0);
    //smjesti u varijablu vrijednost piktograma
    procitani_znakovi[1] = readCurrentSign["Bgr10"]; 
    //procitaj text u slucaju da je text postavljen
    sText = readCurrentSign["sText0"]; 
    //ako postoje dva panela koja se smjenjuju
    if(mappingHasKey(readCurrentSign, "Active1")) Active_2 = readCurrentSign["Active1"];
    if(mappingHasKey(readCurrentSign, "Bgr11")) procitani_znakovi[2] = readCurrentSign["Bgr11"];
    if(mappingHasKey(readCurrentSign, "Duration1")) Duration_2 = readCurrentSign["Duration1"];
    if(mappingHasKey(readCurrentSign, "sText1")) sText_2 = readCurrentSign["sText1"];
  
    DebugFTN("level1", "znak: " + nazivZnaka + " -- na panelu: " + getImageMappingValue(procitani_znakovi[1], nazivZnaka) + " -- scada: " + poslani_znakovi[1]);
    
    /*
    //postavi status tako da operateri imaju indikaciju da je uspostavljena komunikacija sa znakom
    if (status == -8 || status == -9 || status == -1 || status == -10 || status == 1){
       DebugFTN("level1", "Resetting status: " + status + "; znak: " + nazivZnaka);
       dpSet(sys_name + nazivZnaka + ".status", -2); 
    }
    */
    
    for(int i=1; i <= dynlen(procitani_znakovi); i++){
      int panelId;
      if(procitani_znakovi[i] != -1){
         panelId = getImageMappingValue(procitani_znakovi[i], nazivZnaka);
        //provjeri da li ima znakova koji se razlikuju
      
        if(dynlen(poslani_znakovi) != dynlen(procitani_znakovi)) {
           DebugFTN("level1", "Razlicite velicine");
           dpSet(nazivZnaka + ".status", -10); 
        }
        else {        
          if(poslani_znakovi[i] != panelId){
           DebugFTN("level1", "Error: Different signs: " + nazivZnaka + "; trenutna vrijednost: " + poslani_znakovi[i] + "; na znaku: " + panelId); 
           dpSet(nazivZnaka + ".status", -10);
        } 
       }    
      }   
    }
  
    mapping map = getMapping(tip_znaka);  
    dyn_int izborZnaka;  
  
    for(int i=1; i <= dynlen(procitani_znakovi); i++){  
      if(procitani_znakovi[i] != -1){ 
          string vrijednosti = procitani_znakovi[i];     
          izborZnaka[i] = map[vrijednosti];
          DebugFTN("level1", "DMV Value: " + vrijednosti);
      }
    }
  
    //DebugFTN("level1", "DMV Value: " + vrijednosti);          
    dpSet(sys_name + nazivZnaka + ".response.izbor_znaka", izborZnaka);
  }
}

setPortalDatapoint(int tip_znaka, string nazivZnaka, mapping readCurrentSign, int status){
     
  int Active, Duration, Bgr1, Bgr2, Fn1, Fn2, Fn3, Pict1, Pict2, Pict3, Pict4;
  int Active_2, Duration_2, Bgr1_2, Bgr2_2, Fn1_2, Fn2_2, Fn3_2, Pict1_2, Pict2_2, Pict3_2, Pict4_2;
		string sText, sText_2;
  
  //smjesti u varijablu vrijednost piktograma
  Active = readCurrentSign["Active0"];
  Duration = readCurrentSign["Duration0"];
  
  //ako nema komunikacije sa znakom vrati postavi status -1
  if(Active == -1 || Duration == -1){
    dpSet(sys_name + nazivZnaka + ".status", -1);  
  }
  else if (Active == 0){  
    
    //kad uspije procitati postavi status na 0
    dpSet(sys_name + nazivZnaka + ".status", 0); 
    Bgr1 = 0;
    Bgr2 = 0;
    Pict1 = 0;
    Pict2 = 0;
    Pict3 = 0;
    Pict4 = 0;
    sText = "";
  
    //smjesti u varijablu vrijednost piktograma
    Active_2 = 0;
    Duration_2 = 0;
    Bgr1_2 = 0;
    Bgr2_2 = 0;
    Pict1_2 = 0;
    Pict2_2 = 0;
    Pict3_2 = 0;
    Pict4_2 = 0;
    sText_2 = "";
  
    dyn_int izborZnaka = makeDynInt(Active, Duration, Bgr1, Bgr2, Pict1, Pict2, Pict3, Pict4,
                            Active_2, Duration_2, Bgr1_2, Bgr2_2, Pict1_2, Pict2_2, Pict3_2, Pict4_2
                            );
  
    DebugFTN("level1", "Portal Values: " + izborZnaka, "  TEXT PANEL1: " + sText + "  TEXT PANEL2: " + sText_2); 
    dpSet(sys_name + nazivZnaka + ".response.izbor_znaka", izborZnaka);
    
    //dodati varijablu text_portal
    dpSet(sys_name + nazivZnaka + ".response.text_portal", sText);
    dpSet(sys_name + nazivZnaka + ".response.text_portal_2", sText_2);
   
  }
  else{  
    
    //kad uspije procitati postavi status na 0
    dpSet(sys_name + nazivZnaka + ".status", 0); 
    Bgr1 = readCurrentSign["Bgr10"];
    Bgr2 = readCurrentSign["Bgr20"];
    Pict1 = readCurrentSign["Pict10"];
    Pict2 = readCurrentSign["Pict20"];
    Pict3 = readCurrentSign["Pict30"];
    Pict4 = readCurrentSign["Pict40"];
    sText = readCurrentSign["sText0"];
  
    //smjesti u varijablu vrijednost piktograma
    Active_2 = readCurrentSign["Active1"];
    Duration_2 = readCurrentSign["Duration1"];
    Bgr1_2 = readCurrentSign["Bgr11"];
    Bgr2_2 = readCurrentSign["Bgr21"];
    Pict1_2 = readCurrentSign["Pict11"];
    Pict2_2 = readCurrentSign["Pict21"];
    Pict3_2 = readCurrentSign["Pict31"];
    Pict4_2 = readCurrentSign["Pict41"];
    sText_2 = readCurrentSign["sText1"];
  
    dyn_int izborZnaka = makeDynInt(Active, Duration, Bgr1, Bgr2, Pict1, Pict2, Pict3, Pict4,
                            Active_2, Duration_2, Bgr1_2, Bgr2_2, Pict1_2, Pict2_2, Pict3_2, Pict4_2
                            );
  
    DebugFTN("level1", "Portal Values: " + izborZnaka, "  TEXT PANEL1: " + sText + "  TEXT PANEL2: " + sText_2);
  
    strreplace(sText, "'nl'", "-NL-"); 
    strreplace(sText_2, "'nl'", "-NL-");  
    dpSet(sys_name + nazivZnaka + ".response.izbor_znaka", izborZnaka);
    
    //dodati varijablu text_portal
    dpSet(sys_name + nazivZnaka + ".response.text_portal", sText);
    dpSet(sys_name + nazivZnaka + ".response.text_portal_2", sText_2);
   
  }
}
