int TCP_PORT = 12347;
int open;
string sSelectAlerts = "SELECT ALERT '_alert_hdl.._value' FROM '{SysSarani:Takovo_vozilo1.visina,SysSarani:Preljina_vozilo1.visina}' WHERE (_DPT = \"senzor_vangab_vozila\")";
int iMaxHeight = 4500;

main() {
  startThread("kontrolaGabarita");
  startThread("prikaz_na_vangabaritnom_znaku");
}

void kontrolaGabarita() {
  string data;
  
  time maxTime = 100;
  
  open = tcpOpen("10.101.0.7", TCP_PORT);
  DebugTN("Pokrenuta skripta:" + open);
  if (open != -1) {
    DebugFTN("level1", "Otvoren port:" + open);
  }
  else {
      DebugFTN("level1", "Greska otvaranja porta: " + getLastError());
  }
        
  while(1) {
     int res = tcpRead(open, data, maxTime);
     DebugFTN("level1", "Res: " + res);
     if (res != -1) {
       if (data != "") {
         mapping podaci = jsonDecode(data);
         DebugFTN("level1", "Broj parametara:" + mappinglen(podaci));
         if (mappingHasKey(podaci, "sensor_id")) {
           //Dodano 21.11.2017 - na Takovu se stalno upisivali isti podaci
           string senzor_id = podaci["sensor_id"];
           string senzor = (podaci["sensor_id"]==1) ? "Takovo" : "Preljina";
           int id = podaci["id"];
           int trenutni_id;
           dpGet("SysSarani:" + senzor + "_vozilo1.id", trenutni_id);
           DebugFTN("level1", "senzor, id, trenutni_id: ", senzor, id, trenutni_id);
           
           if (trenutni_id != id) {//-------------------------------------------------Ranije nije postojao ovaj if uslov--------------------------------
             popuniRanijaVozila(senzor_id, 3);
             popuniRanijaVozila(senzor_id, 2);
             popuniNovoVozilo(senzor_id, podaci);
           }
         }
       }
     } 
     
     //DODANO 02.08.2017
    bool gubitakKomunikacijePreljina, gubitakKomunikacijeTakovo;
    dpGet("SysSarani:Preljina_vozilo1.gubitak_komunikacije", gubitakKomunikacijePreljina);
    dpGet("SysSarani:Takovo_vozilo1.gubitak_komunikacije", gubitakKomunikacijeTakovo);
  
 
    if (gubitakKomunikacijeTakovo && gubitakKomunikacijePreljina) {
      open = tcpOpen("10.101.0.7", TCP_PORT);
      delay(10);
    }
  }
  
   
}

void popuniNovoVozilo(string senzor, mapping podaci) {
  string petlja;
  if (senzor == 1) petlja = "Takovo";
  else if (senzor == 2) petlja = "Preljina";
  
  string id, sirina, visina, vrijeme_ocitanja, klasa_vozila,
         tip_vozila, pogresan_smjer, transit_id, alarm_visina,
         pozicija, smjer, klasifikacija, gap, refl_pos, refl_idx, brzina;
  
  
  if (mappingHasKey(podaci, "id")) {
     id = podaci["id"];
  }
  
  if (mappingHasKey(podaci, "speed_end")) {
     brzina = podaci["speed_end"];
  }
  
  if (mappingHasKey(podaci, "widht")) {
     sirina = podaci["widht"];
  }
  
  if (mappingHasKey(podaci, "height")) {
     visina = podaci["height"];
  }
  
  if (mappingHasKey(podaci, "time_iso_begin")) {
     vrijeme_ocitanja = podaci["time_iso_begin"];
  }
  
  if (mappingHasKey(podaci, "class_id")) {
     klasa_vozila = podaci["class_id"];
  }
  
  if (mappingHasKey(podaci, "class_name")) {
     tip_vozila = podaci["class_name"];
  }
  
  if (mappingHasKey(podaci, "wrong_way")) {
     pogresan_smjer = podaci["wrong_way"];
  }
  
  if (mappingHasKey(podaci, "transit_id")) {
     transit_id = podaci["transit_id"];
  }
  
  if (mappingHasKey(podaci, "height_alarm")) {
     alarm_visina = podaci["height_alarm"];
  }
  
  if (mappingHasKey(podaci, "position")) {
     pozicija = podaci["position"];
  }
  
  if (mappingHasKey(podaci, "direction")) {
     smjer = podaci["direction"];
  }
  
  if (mappingHasKey(podaci, "classification")) {
     klasifikacija = podaci["classification"];
  }
  
  if (mappingHasKey(podaci, "gap")) {
     gap = podaci["gap"];
  }
  
  if (mappingHasKey(podaci, "refl_pos")) {
     refl_pos = podaci["refl_pos"];
  }
  
  if (mappingHasKey(podaci, "refl_idx")) {
     refl_idx = podaci["refl_idx"];
  }
  
  
  
  
  if (petlja != "") {
    dpSet("SysSarani:" + petlja + "_vozilo1.id", id);
    dpSet("SysSarani:" + petlja + "_vozilo1.sirina", sirina);
    dpSet("SysSarani:" + petlja + "_vozilo1.visina", visina);
    dpSet("SysSarani:" + petlja + "_vozilo1.vrijeme_ocitanja", formatTime("%H:%M:%S", getCurrentTime()));
    dpSet("SysSarani:" + petlja + "_vozilo1.klasa_vozila", klasa_vozila);
    dpSet("SysSarani:" + petlja + "_vozilo1.tip_vozila", tip_vozila);
    dpSet("SysSarani:" + petlja + "_vozilo1.pogresan_smjer", pogresan_smjer);
    dpSet("SysSarani:" + petlja + "_vozilo1.transit_id", transit_id);
    dpSet("SysSarani:" + petlja + "_vozilo1.alarm_visina", alarm_visina);
    dpSet("SysSarani:" + petlja + "_vozilo1.pozicija", pozicija);
    dpSet("SysSarani:" + petlja + "_vozilo1.smjer", smjer);
    dpSet("SysSarani:" + petlja + "_vozilo1.klasifikacija", klasifikacija);
    dpSet("SysSarani:" + petlja + "_vozilo1.gap", gap);
    dpSet("SysSarani:" + petlja + "_vozilo1.refl_pos", refl_pos);
    dpSet("SysSarani:" + petlja + "_vozilo1.refl_idx", refl_idx);
    dpSet("SysSarani:" + petlja + "_vozilo1.brzina", brzina);
  }
}


void popuniRanijaVozila (string senzor, int vozilo) {
  string id, sirina, visina, vrijeme_ocitanja, klasa_vozila,
         tip_vozila, pogresan_smjer, transit_id, alarm_visina,
         pozicija, smjer, klasifikacija, gap, refl_pos, refl_idx, brzina;
  
  string broj_vozila;
  if (vozilo == 2)   broj_vozila = 1;
  else if (vozilo == 3)   broj_vozila = 2;
  
  string petlja;
  if (senzor == 1) petlja = "Takovo";
  else if (senzor == 2) petlja = "Preljina";
  
  if (petlja != "") {
    dpGet("SysSarani:" + petlja + "_vozilo" + broj_vozila + ".id", id);
    dpGet("SysSarani:" + petlja + "_vozilo" + broj_vozila + ".sirina", sirina);
    dpGet("SysSarani:" + petlja + "_vozilo" + broj_vozila + ".visina", visina);
    dpGet("SysSarani:" + petlja + "_vozilo" + broj_vozila + ".vrijeme_ocitanja", vrijeme_ocitanja);
    dpGet("SysSarani:" + petlja + "_vozilo" + broj_vozila + ".klasa_vozila", klasa_vozila);
    dpGet("SysSarani:" + petlja + "_vozilo" + broj_vozila + ".tip_vozila", tip_vozila);
    dpGet("SysSarani:" + petlja + "_vozilo" + broj_vozila + ".pogresan_smjer", pogresan_smjer);
    dpGet("SysSarani:" + petlja + "_vozilo" + broj_vozila + ".transit_id", transit_id);
    dpGet("SysSarani:" + petlja + "_vozilo" + broj_vozila + ".alarm_visina", alarm_visina);
    dpGet("SysSarani:" + petlja + "_vozilo" + broj_vozila + ".pozicija", pozicija);
    dpGet("SysSarani:" + petlja + "_vozilo" + broj_vozila + ".smjer", smjer);
    dpGet("SysSarani:" + petlja + "_vozilo" + broj_vozila + ".klasifikacija", klasifikacija);
    dpGet("SysSarani:" + petlja + "_vozilo" + broj_vozila + ".gap", gap);
    dpGet("SysSarani:" + petlja + "_vozilo" + broj_vozila + ".refl_pos", refl_pos);
    dpGet("SysSarani:" + petlja + "_vozilo" + broj_vozila + ".refl_idx", refl_idx);
    dpGet("SysSarani:" + petlja + "_vozilo" + broj_vozila + ".brzina", brzina);
    
    dpSet("SysSarani:" + petlja + "_vozilo" + vozilo + ".id", id);
    dpSet("SysSarani:" + petlja + "_vozilo" + vozilo + ".sirina", sirina);
    dpSet("SysSarani:" + petlja + "_vozilo" + vozilo + ".visina", visina);
    dpSet("SysSarani:" + petlja + "_vozilo" + vozilo + ".vrijeme_ocitanja", vrijeme_ocitanja);
    dpSet("SysSarani:" + petlja + "_vozilo" + vozilo + ".klasa_vozila", klasa_vozila);
    dpSet("SysSarani:" + petlja + "_vozilo" + vozilo + ".tip_vozila", tip_vozila);
    dpSet("SysSarani:" + petlja + "_vozilo" + vozilo + ".pogresan_smjer", pogresan_smjer);
    dpSet("SysSarani:" + petlja + "_vozilo" + vozilo + ".transit_id", transit_id);
    dpSet("SysSarani:" + petlja + "_vozilo" + vozilo + ".alarm_visina", alarm_visina);
    dpSet("SysSarani:" + petlja + "_vozilo" + vozilo + ".pozicija", pozicija);
    dpSet("SysSarani:" + petlja + "_vozilo" + vozilo + ".smjer", smjer);
    dpSet("SysSarani:" + petlja + "_vozilo" + vozilo + ".klasifikacija", klasifikacija);
    dpSet("SysSarani:" + petlja + "_vozilo" + vozilo + ".gap", gap);
    dpSet("SysSarani:" + petlja + "_vozilo" + vozilo + ".refl_pos", refl_pos);
    dpSet("SysSarani:" + petlja + "_vozilo" + vozilo + ".refl_idx", refl_idx);
    dpSet("SysSarani:" + petlja + "_vozilo" + vozilo + ".brzina", brzina);
  }
}

void prikaz_na_vangabaritnom_znaku()
{
  delay(5);
  int rc; 

  DebugFTN("level1","sSelectAlerts: " + sSelectAlerts);
  
  anytype userData = getUserName();

  //Pretplacuje se na sve alerte sa camera
  rc = dpQueryConnectSingle("work", true, userData, sSelectAlerts); 
   dyn_errClass d_err;
  d_err = getLastError();
  if(dynlen(d_err)>0)
  {
    DebugTN("An error has occurred - prikaz_na_vangabaritnom_znaku:", err);
      throwError(d_err);
    }
/*  
  //dpConnect("work", "SysSarani:Takovo_vozilo1.visina:_alert_hdl", "SysSarani:Takovo_vozilo1.visina:_alert_hdl.._value", "SysSarani:Preljina_vozilo1.visina:_alert_hdl");
  //dpConnect("work", "SysSarani:Takovo_vozilo1.visina:_alert_hdl.._value");
  dyn_errClass err = getLastError();
  if(dynlen(err) > 0)
    {
      DebugTN("An error has occurred - prikaz_na_vangabaritnom_znaku:", err);
      //further measures
    }
    */
}

/*
//work(string dpTakovo_visina, float a, string dpTakovo_visina_av, int iTV, string dpPreljina_visina, float b) 
work(string dpTakovo_visina, int iTV) 
{ 
  DebugTN("prikaz_na_vangabaritnom_znaku: iTV" + iTV);
}
*/
work(anytype userData, dyn_dyn_anytype val)
{
  int i;
  DebugFTN("level1","Callback:", dynlen(val), userData);
    int iFirstOne = 2;
    
    DebugTN("val ", val);
    string sDPE = val[iFirstOne][1];
    string sDPName = dpSubStr(sDPE, DPSUB_DP_EL);  //DPSUB_DP - 
    string sDP = dpSubStr(sDPE, DPSUB_DP);  //DPSUB_DP - 
    string sSys_DP = dpSubStr(sDPE, DPSUB_SYS_DP);  //DPSUB_DP - 
    int iAlertValue = val[iFirstOne][3];
    DebugFTN("level1", sSys_DP, iAlertValue);
    
    //samo za provjeru sta dobavlja
    DebugFTN("level2", "DPName: " + sDPName); 
    DebugFTN("level2", "DP: " + sDP); 
    DebugFTN("level2", "DPE: " + sDPE); 
    DebugFTN("level2", "SYS_DP: " + sSys_DP); 
    
    setVangabaritni_Znak(sSys_DP, iAlertValue);           
}

void setVangabaritni_Znak(string sDP, int iAlertValue)
{  
  int iPreljina = strpos(sDP, "Preljina_vozilo1");
  int iTakovo = strpos(sDP, "Takovo_vozilo1");
  DebugFTN("level1", "setVangabaritni_Znak: ", sDP, iAlertValue, "iPreljina: " + iPreljina, "iTakovo: " + iTakovo, "iMaxHeight: " + iMaxHeight);
  if(iTakovo >= 0)
  {
    if(iAlertValue > iMaxHeight)
      dpSet("SysSarani:VMS1-OA4-TAKOVO.command.izbor_znaka", 1);
    else
      dpSet("SysSarani:VMS1-OA4-TAKOVO.command.izbor_znaka", 0);
  }
  else if(iPreljina >= 0)
  {
    if(iAlertValue > iMaxHeight)
      dpSet("SysSarani:VMS1-OA4-PRELJINA.command.izbor_znaka", 1);
    else
      dpSet("SysSarani:VMS1-OA4-PRELJINA.command.izbor_znaka", 0);
  }
}
