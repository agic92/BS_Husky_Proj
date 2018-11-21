//-dbg "level1" - za debugiranje
#uses "CtrlXmlRpc"

int main() 
{
   readFromSigns();  
}
string sys_name = "SysSarani:";
string xmlRpcMethodReadSettings = "bstelecom.sign.SignProtocolAdapter.readCurrentSignPanel";
string xmlRpcMethodReadBrightness = "bstelecom.sign.SignProtocolAdapter.readSignBrightness";

readFromSigns(){  
  //while(true)
  //{ 
  dpQueryConnectSingle("readSignPanel", true, "Identi", 
                       "SELECT '_online.._value' FROM '*.command.izbor_znaka' WHERE _DPT = \"Sign\""); 
  dpQueryConnectSingle("readSignBrightness", true, "Identi", 
                      "SELECT '_online.._value' FROM '*.command.intezitet' WHERE _DPT = \"Sign\"");   
    //repeatReadSign();       
   // delay(1200); 
  //} 
}
//funkcija koja se proziva kada se promjeni stanje na znaku
readSignPanel(anytype ident, dyn_dyn_anytype list)
{
  string dpe;
  dyn_int value;
  delay(10);
   
  for(int i = 2; i <= dynlen(list); i++)  //starta sa 2 zato sto liste pocinju od 1, a sql upit vraca u prvoj liniji header pa treba i njega preskociti
  {    
    value = list[i][2];
    dpe = list[i][1];
    dpe = dpSubStr(dpe, DPSUB_DP);  //DPSUB_DP - 
    
    int thId = startThread("readSignPanelSingle", dpe);
    waitThread(thId);
  }       
}
//funkcija koja se poziva kad se inteziet promjeni na znaku
readSignBrightness(anytype ident, dyn_dyn_anytype list)
{
  string dpe;
  dyn_int value;
  delay(10);
  
  for(int i = 2; i <= dynlen(list); i++)  //starta sa 2 zato sto liste pocinju od 1, a sql upit vraca u prvoj liniji header pa treba i njega preskociti
  {    
    value = list[i][2];
    dpe = list[i][1];
    dpe = dpSubStr(dpe, DPSUB_DP);  //DPSUB_DP - 
    
    int thId = startThread("readSignBrightnessSingle", dpe);
    waitThread(thId);
  }       
}

void readSignPanelSingle(string nazivZnaka)
{
  DebugTN("readSignPanelSingle before delay");
  delay(0.5); 
  DebugTN("readSignPanelSingle after delay");
  
  string id = "servID" + rand();
  string host = "localhost";
  int port = "8087";
  bool secure = FALSE;
  
  xmlrpcClient();
  xmlrpcConnectToServer(id, host, port, secure);

  string ip_adresa, status;//, tipZnaka;
  int tipZnaka;
    
  dpGet(sys_name + nazivZnaka + ".status", status);
  dpGet(sys_name + nazivZnaka + ".IP", ip_adresa);
  dpGet(sys_name + nazivZnaka + ".tip_znaka", tipZnaka);
  
  //trenutno se salje na znak
  if(status == 1)
  {
    DebugFTN("level1", "znak: " + nazivZnaka + " -- status: " + status);
    return; //trenutno se salje na znak
  }
  
  //vrijednosti koje dobijemo kad procitamo sa znaka
  mapping readCurrentSign;
  //tip znaka je prvi parametar koji prosljedjujemo funkciji
  dyn_mixed argsSign = makeDynMixed(tipZnaka, ip_adresa);
  
  //u slucaju gubitka komunikacije sta vraca
  xmlrpcCall(id, xmlRpcMethodReadSettings, argsSign, readCurrentSign);
  
  //panelId0 je zapravo panel/znak koji je postavljen
  //panelId1 je drugi panel, ako ih ima vise koji se smjenjuju
  dyn_int niz_panela;
  int duration, duration2;
  dyn_int poslani_znakovi;
  dpGet(sys_name + nazivZnaka + ".command.izbor_znaka", poslani_znakovi);
  
  //smjesti u varijablu vrijednost piktograma
  niz_panela[1] = readCurrentSign["PanelId0"];
  duration = readCurrentSign["Duration0"];
  
  DebugFTN("level1", "znak: " + nazivZnaka + " -- na znaku: " + getImageMappingValue(niz_panela[1], nazivZnaka) + " -- scada: " + poslani_znakovi[1]);
  
  //ako postoji vise znakova koji se smjenjuju, tada je velicina mape 6
  if(mappinglen(readCurrentSign) > 3){
     niz_panela[2] = readCurrentSign["PanelId0"];
     duration2 = readCurrentSign["Duration0"];
     DebugFTN("level1", "znak: " + nazivZnaka + " -- na znaku: " + getImageMappingValue(niz_panela[2], nazivZnaka) + " -- scada: " +  poslani_znakovi[2]);
  }
  
  //provjeri broj panela poslanioh na znak i ocitanih sa znaka
  if(dynlen(niz_panela) != dynlen(poslani_znakovi)) {
    DebugFTN("level", "Panel ID0: " + niz_panela[1] + "  Panel ID1: " + niz_panela[1] + 
                      "Duration0: " + duration + "  Duration1: " + duration2 + 
                      "Broj procitanih panela: " + dynlen(niz_panela));
    DebugTN("Error: Razlicite velicine: " + nazivZnaka + "; Broj poslanih panela: " + dynlen(niz_panela) + "; Broj procitanih panela: " + dynlen(poslani_znakovi));
    dpSet(nazivZnaka + ".status", -10);
  }
  else{
    for(int i=1; i <= dynlen(poslani_znakovi); i++){
    int panelId = getImageMappingValue(niz_panela[i], nazivZnaka);
    
    //provjeri da li ima znakova koji se razlikuju
    if(poslani_znakovi[i] != panelId){
       DebugTN("Error: Different signs: " + nazivZnaka + "; trenutna vrijednost: " + poslani_znakovi[i] + "; na znaku: " + panelId); 
       dpSet(nazivZnaka + ".status", -10);
     }
   }
  }
 
  //postavi status tako da operateri imaju indikaciju da je uspostavljena komunikacija sa znakom
  if (status == -8 || status == -9 || status == -1){
     DebugFTN("level1", "Resetting status: " + status + "; znak: " + nazivZnaka);
     dpSet(sys_name + nazivZnaka + ".status", -2);
  }

  setDatapoint(niz_panela, tipZnaka, nazivZnaka);
  xmlrpcCloseServer(id);  
}

void readSignBrightnessSingle(string nazivZnaka)
{
  DebugTN("readSignBrihtness before delay");
  delay(0.5); 
  DebugTN("readSignBrihtness after delay");
  
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
  
  //u slucaju gubitka komunikacije sta vraca
  xmlrpcCall(id, xmlRpcMethodReadBrightness, argsSign, readCurrentSign);
  
  int brightness_value = readCurrentSign["CurrentBrightness"];
  int brightness_value_depedence = readCurrentSign["Brightness_depedence_Value"];
  
  //u postotcima (%)
  dpSet(sys_name + nazivZnaka + ".response.intezitet", izborZnaka);
  //0 = Fix mode; 1 = Brightness depends on day time; 2 = Brightness depends on light sensor(s)
  dpSet(sys_name + nazivZnaka + ".response.rezim_osvetljenja", izborZnaka);

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
      DebugTN("Error: Mapping does not contain value. Map: " + map + "; Value" + vrijednost);
      return -1;
  }
    
  stanje_na_znaku = map[vrijednost];

  return stanje_na_znaku;    
}

setDatapoint(dyn_int panelIds, int tip_znaka, string nazivZnaka){
  
  mapping map = getMapping(tip_znaka);  
  dyn_int izborZnaka;  
  
  for(int i=1; i <= dynlen(panelIds); i++){  
      string vrijednosti = panelIds[i];
      izborZnaka[i] = map[vrijednosti];
      DebugTN("DMV Value: " + vrijednosti);
  }
  
  //DebugFTN("level1", "DMV Value: " + vrijednosti);          
  dpSet(sys_name + nazivZnaka + ".response.izbor_znaka", izborZnaka);

}
