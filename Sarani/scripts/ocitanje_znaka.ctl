//-dbg "level1" - za debugiranje
#uses "CtrlXmlRpc"

int main() 
{
  // readSignPanelSingle(); 
  //readSignBrightnessSingle(); 
  
    dpQueryConnectSingle("readSignPanel", true, "Identi", 
                     //  "SELECT '_online.._value' FROM '*.command.izbor_znaka' WHERE _DPT = \"Sign\""); 
    "SELECT '_online.._value' FROM 'VMS6-L1.command.izbor_znaka' WHERE _DPT = \"Sign\"");
}
string sys_name = "SysSarani:";
string xmlRpcMethodReadSettings = "bstelecom.sign.SignProtocolAdapter.readCurrentSignPanel";
string xmlRpcMethodReadBrightness = "bstelecom.sign.SignProtocolAdapter.readSignBrightness";

//funkcija koja se proziva kada se promjeni stanje na znaku
readSignPanel(anytype ident, dyn_dyn_anytype list)
{
  string dpe;
  dyn_int value;
   
  for(int i = 2; i <= dynlen(list); i++)  //starta sa 2 zato sto liste pocinju od 1, a sql upit vraca u prvoj liniji header pa treba i njega preskociti
  {    
    value = list[i][2];
    dpe = list[i][1];
    dpe = dpSubStr(dpe, DPSUB_DP);  //DPSUB_DP - 
    
    int thId = startThread("readSignPanelSingle", dpe);
    waitThread(thId);
  }       
}

void readSignPanelSingle(string nazivZnaka)
{
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

  string ip_adresa, status;//, tipZnaka;
  int tipZnaka = 5;
  ip_adresa = "10.101.0.82";
    
 
  
  //vrijednosti koje dobijemo kad procitamo sa znaka
  mapping readCurrentSign;
  //tip znaka je prvi parametar koji prosljedjujemo funkciji
 // dyn_mixed argsSign = makeDynMixed(5, "10.101.0.82");
  dyn_mixed argsSign = makeDynMixed(tipZnaka, ip_adresa);

  xmlrpcCall(id, xmlRpcMethodReadSettings, argsSign, readCurrentSign);
  DebugTN("readCurrentSign: ", readCurrentSign);
  /*
  //panelId1 je zapravo panel/znak koji je postavljen
  //panelId2 je drugi panel, ako ih ima vise koji se smjenjuju
  dyn_int niz_panela;
  int duration, duration2;
  dyn_int poslani_znakovi;
  dpGet(sys_name + nazivZnaka + ".command.izbor_znaka", poslani_znakovi);

  niz_panela[1] = readCurrentSign["PanelId1"];
  duration = readCurrentSign["Duration1"];
  
  DebugTN("level1", "znak: " + nazivZnaka + " -- na znaku: " + getImageMappingValue(niz_panela[1], nazivZnaka) + " -- scada: " + poslani_znakovi[1]);
  
  //ako postoji vise znakova koji se smjenjuju, tada je velicina mape 6
  if(mappinglen(readCurrentSign) > 3){
     niz_panela[2] = readCurrentSign["PanelId2"];
     duration2 = readCurrentSign["Duration2"];
     DebugTN("level1", "znak: " + nazivZnaka + " -- na znaku: " + getImageMappingValue(niz_panela[2], nazivZnaka) + " -- scada: " +  poslani_znakovi[2]);
  }

  dyn_errClass err = getLastError();
  
  if (dynlen(err) > 0){
    DebugTN("Error: " + err + "; sign: " + nazivZnaka);
    dpSet(sys_name + nazivZnaka + ".status", -9);
    return;
  }
  
  //provjeri broj panela poslanioh na znak i ocitanih sa znaka
  if(dynlen(niz_panela) != dynlen(poslani_znakovi)) {
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
  */
  xmlrpcCloseServer(id);  
}

void readSignBrightnessSingle()
{
  string id = "servID" + rand();
  string host = "localhost";
  int port = "8087";
  bool secure = FALSE;
  
  xmlrpcClient();
  xmlrpcConnectToServer(id, host, port, secure);

  string ip_adresa, status, tipZnaka;
    
  
  //vrijednosti koje dobijemo kad procitamo sa znaka
  mapping readCurrentSign;
  //tip znaka je prvi parametar koji prosljedjujemo funkciji
  dyn_mixed argsSign = makeDynMixed(5, "10.101.0.82");
  
  xmlrpcCall(id, xmlRpcMethodReadBrightness, argsSign, readCurrentSign);
  DebugTN("readCurrentSign: ", readCurrentSign);

  dyn_errClass err = getLastError();
  
  
  xmlrpcCloseServer(id);  
}
