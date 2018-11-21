#uses "latin_to_cyrillic.ctl"
/*---------------------------------------------------------------------------------*
 *                   PODEŠAVANJE NIVOA ADAPTIVNE RASVJETE                          * 
 *---------------------------------------------------------------------------------*/
bool podesiNivoAdaptivne (string cijev, float nivo) {
  dyn_bool vrijednosti;  
  string ormar;
  
  if (cijev == "desna")
    ormar = "RO-A1-1D";
  else if (cijev == "lijeva")
    ormar = "RO-A1-2L";
  
  switch (nivo) {
    case 100:
      vrijednosti = makeDynInt(1, 1, 1, 1, 1);
      break;
    case 75:
      vrijednosti = makeDynInt(0, 1, 1, 1, 1);
      break;
    case 50:
      vrijednosti = makeDynInt(0, 0, 1, 1, 1);
      break;
    case 25:
      vrijednosti = makeDynInt(0, 0, 0, 1, 1);
      break;
    case 12.5:
      vrijednosti = makeDynInt(0, 0, 0, 0, 1);
      break;
    case 0:
      vrijednosti = makeDynInt(0, 0, 0, 0, 0);
      break;
  }
  
  dpSet("SysSarani:" + ormar + ".cmd.run.100%", vrijednosti[1]);
  dpSet("SysSarani:" + ormar + ".cmd.run.75%", vrijednosti[2]);
  dpSet("SysSarani:" + ormar + ".cmd.run.50%", vrijednosti[3]);
  dpSet("SysSarani:" + ormar + ".cmd.run.25%", vrijednosti[4]);
  dpSet("SysSarani:" + ormar + ".cmd.run.12_5%", vrijednosti[5]);
  
  logujPostavljanjeKomande(ormar, nivo + "%");
  //21.11.2017 - Čekanje na odgovor pomjereno sa jedne na tri sekunde
  delay(3);
  //----------------
  if (provjeriStatusAdaptivne (ormar, vrijednosti) == 0) {
      //dpSet("SysSarani:" + ormar + ".value.aktivni_nivo", nivo);
      logujUspjesnoPaljenjeRasvete(ormar, nivo + "%");
      return true;
  }
  return false;
}

/*---------------------------------------------------------------------------------*
 *                   PODEŠAVANJE NIVOA BAZNE RASVJETE                              * 
 *---------------------------------------------------------------------------------*/
bool ukljuciSvuDesnu() {
  DebugFTN("level1", "ukljuciSvuDesnu() pozvana");
  dyn_string ormari_bazne = makeDynString("OS1", "OS1/UPS", "B-1D", "B-1D/UPS", "B-2L", "B-2L/UPS", "OS2", "OS2/UPS");
  
  for (int i=1; i<= dynlen(ormari_bazne); i++) {
    bool bazna, prigusenje;
    dpGet("SysSarani:bazna.state." + ormari_bazne[i] + ".bazna", bazna);
    dpGet("SysSarani:bazna.state." + ormari_bazne[i] + ".bazna_redukcija", prigusenje);
     if (!(bazna && !prigusenje))
       podesiNivoBazne(ormari_bazne[i], 1); 
  }
  
  
}
/*---------------------------------------------------------------------------------*/

bool ukljuciSvuLijevu() {
  DebugFTN("level1", "ukljuciSvuLijevu() pozvana");
  dyn_string ormari_bazne = makeDynString("OS1", "OS1/UPS", "B-1D", "B-1D/UPS", "B-2L", "B-2L/UPS", "OS2", "OS2/UPS");
  
  for (int i=1; i<= dynlen(ormari_bazne); i++) {
    bool bazna, prigusenje;
    dpGet("SysSarani:bazna.state." + ormari_bazne[i] + ".bazna", bazna);
    dpGet("SysSarani:bazna.state." + ormari_bazne[i] + ".bazna_redukcija", prigusenje);
     if (!(bazna && !prigusenje))
       podesiNivoBazne(ormari_bazne[i], 1); 
  }
  
}
/*---------------------------------------------------------------------------------*/

bool ukljuciSvuRasvjetu() {
  DebugFTN("level1", "ukljuciSvuLijevu() pozvana");
  dyn_string ormari_bazne = makeDynString("OS1", "OS1/UPS", "B-1D", "B-1D/UPS", "B-2L", "B-2L/UPS", "OS2", "OS2/UPS");
  
  for (int i=1; i<= dynlen(ormari_bazne); i++) {
    bool bazna, prigusenje;
    dpGet("SysSarani:bazna.state." + ormari_bazne[i] + ".bazna", bazna);
    dpGet("SysSarani:bazna.state." + ormari_bazne[i] + ".bazna_redukcija", prigusenje);
     if (!(bazna && !prigusenje))
       podesiNivoBazne(ormari_bazne[i], 1); 
  }
  
}
/*---------------------------------------------------------------------------------*/

void podesiNivoBazne (string ormar, float nivo) {
  dyn_bool vrijednosti;
  
  switch (nivo) {
    case 0: //iskljucena bazna
      vrijednosti = makeDynInt(0, 0);
      break;
    case 1: //ukljucena bazna bez prigusenja
      vrijednosti = makeDynInt(1, 0);
      break;
    case 2: //ukljucena bazna sa prigusenjem
      vrijednosti = makeDynInt(1, 1);
      break;
  }
  
  dpSet("SysSarani:bazna.cmd.run." + ormar + ".bazna", vrijednosti[1]);
  dpSet("SysSarani:bazna.cmd.run." + ormar + ".bazna_redukcija", vrijednosti[2]);
  
  logujPostavljanjeKomandeBazna(ormar, vrijednosti[1]);
  logujPostavljanjeKomandeBaznaRedukcija(ormar, vrijednosti[2]);
}
/*---------------------------------------------------------------------------------*
 *                   PROVJERA POSTAVLJANJA BAZNE RASVJETE                          * 
 *---------------------------------------------------------------------------------*/
bool provjeriDozvoluPaljenjaAdaptivne(string ormar, string nivo) {
  bool dozvoljeno;
  dpGet("SysSarani:" + ormar + ".dozvola_paljenja." + nivo, dozvoljeno);
  return dozvoljeno;
}

/*---------------------------------------------------------------------------------*
 *                   PROVJERA POSTAVLJANJA BAZNE RASVJETE                          * 
 *---------------------------------------------------------------------------------*/
bool provjeriPostavljanjeBazne(string ormar, float nivo) {
  dyn_bool vrijednosti1; //statusi 
  dyn_bool vrijednosti2; //komande
  
  switch (nivo) {
    case 0: //iskljucena bazna
      vrijednosti1 = makeDynInt(0, 0);
      break;
    case 1: //ukljucena bazna bez prigusenja
      vrijednosti1 = makeDynInt(1, 0);
      break;
    case 2: //ukljucena bazna sa prigusenjem
      vrijednosti1 = makeDynInt(1, 1);
      break;
  }
  vrijednosti2 = vrijednosti1;
  
  dpGet("SysSarani:bazna.state." + ormar + ".bazna", vrijednosti2[1]);
  dpGet("SysSarani:bazna.state." + ormar + ".bazna_redukcija", vrijednosti2[2]);
  
  if (vrijednosti1[1] == vrijednosti2[1] && vrijednosti1[2] == vrijednosti2[2])
    return true;
  
  return false;
}

/*---------------------------------------------------------------------------------*
 *                   PODEŠAVANJE RASVJETE U PRILAZNOJ ZONI                         * 
 *---------------------------------------------------------------------------------*/
bool ukljuciPrilaznuOS1() {
  bool prilazna1;
  DebugFTN("level1", "ukljuciPrilaznuOS1() pozvana");
  dpSet("SysSarani:bazna.cmd.run.OS1.prilazna_zona1", 1);
  delay(2);
  dpGet("SysSarani:bazna.state.OS1.prilazna_zona1", prilazna1);
  
  if (!prilazna1) {
    dpSet("SysSarani:bazna.cmd.run.OS1.prilazna_zona1", 0);
    return false;
  }
  return true;
}
//---------------------------------------------------------------------------------
bool iskljuciPrilaznuOS1() {
  DebugFTN("level1", "iskljuciPrilaznuOS1() pozvana");
   bool prilazna1;
  dpSet("SysSarani:bazna.cmd.run.OS1.prilazna_zona1", 0);
  delay(2);
  dpGet("SysSarani:bazna.state.OS1.prilazna_zona1", prilazna1);
  
  if (prilazna1) {
    dpSet("SysSarani:bazna.cmd.run.OS1.prilazna_zona1", 1);
    return false;
  }
  return true;
}
/*---------------------------------------------------------------------------------*/
bool ukljuciPrilaznuOS2() {
  bool prilazna2;
  dpSet("SysSarani:bazna.cmd.run.OS2.prilazna_zona2", 1);
  delay(1);
  dpGet("SysSarani:bazna.state.OS2.prilazna_zona2", prilazna2);
  
  if (!prilazna2) {
    dpSet("SysSarani:bazna.cmd.run.OS2.prilazna_zona2", 0);
    return false;
  }
  return true;
}
//---------------------------------------------------------------------------------
bool iskljuciPrilaznuOS2() {
  bool prilazna2;
  dpSet("SysSarani:bazna.cmd.run.OS2.prilazna_zona2", 0);
  delay(1);
  dpGet("SysSarani:bazna.state.OS2.prilazna_zona2", prilazna2);
  
  if (prilazna2) {
    dpSet("SysSarani:bazna.cmd.run.OS2.prilazna_zona2", 1);
    return false;
  }
  return true;
}
/*---------------------------------------------------------------------------------*
 *                   UKLJUČIVANJE REDUKCIJE                                        * 
 *---------------------------------------------------------------------------------*/
bool ukljuciRedukciju(string dp) {  //ne treba koristiti, ima metoda podesiNivoBazne()
  
  bool stari_status_bazne, stari_status_bazne_redukcija;
  
  dpGet("SysSarani:bazna.state." + dp + ".bazna", stari_status_bazne);
  dpGet("SysSarani:bazna.state." + dp + ".bazna_redukcija", stari_status_bazne_redukcija);
  
  bool status_bazne, status_bazne_redukcija;

  dpSet("SysSarani:bazna.cmd.run." + dp + ".bazna", 1);  
  dpSet("SysSarani:bazna.cmd.run." + dp + ".bazna_redukcija", 1);
  
  delay(1);
  
  dpGet("SysSarani:bazna.state." + dp + ".bazna", status_bazne);
  dpGet("SysSarani:bazna.state." + dp + ".bazna_redukcija", status_bazne_redukcija);
  
  //redukcija se moze paliti tek ako je upaljena bazna
  if (!status_bazne || !status_bazne_redukcija) {
    dpSet("SysSarani:bazna.cmd.run." + dp + ".bazna", stari_status_bazne);  
    dpSet("SysSarani:bazna.cmd.run." + dp + ".bazna_redukcija", stari_status_bazne_redukcija);
    return false;
  }
  return true;
}

/*---------------------------------------------------------------------------------*
 *                   ISKLJUČIVANJE REDUKCIJE                                       * 
 *---------------------------------------------------------------------------------*/
bool iskljuciRedukciju(string dp) { //ne treba koristiti, ima metoda podesiNivoBazne()
  
  bool stari_status_bazne, stari_status_bazne_redukcija;
  
  dpGet("SysSarani:bazna.state." + dp + ".bazna", stari_status_bazne);
  dpGet("SysSarani:bazna.state." + dp + ".bazna_redukcija", stari_status_bazne_redukcija);
  
  
  bool status_bazne, status_bazne_redukcija;

  //redukcija se moze paliti tek ako je upaljena bazna
  if (status_bazne)
    dpSet("SysSarani:bazna.cmd.run." + dp + ".bazna_redukcija", 0);
  
  dpGet("SysSarani:bazna.state." + dp + ".bazna_redukcija", status_bazne_redukcija);
  
  if (status_bazne_redukcija) {
    dpSet("SysSarani:bazna.cmd.run." + dp + ".bazna_redukcija", stari_status_bazne_redukcija);
    return false;
  }
  return true;
}

/*---------------------------------------------------------------------------------*
 *                   PROVJERA GREŠAKA                                              * 
 *---------------------------------------------------------------------------------*/
dyn_string provjeriRezimSvihOrmara() {
  dyn_string ormari_bazne = makeDynString("OS1", "OS1/UPS", "B-1D", "B-1D/UPS", "B-2L", "B-2L/UPS", "OS2", "OS2/UPS");
  dyn_string ormari_adaptivne = makeDynString("RO-A1-1D", "RO-A1-2L");
  dyn_string nivoi_adaptivne = makeDynString("100%", "75%", "50%", "25%", "12_5%");
  dyn_string nivoi_bazne = makeDynString("bazna", "bazna_redukcija");
  dyn_string nivoi_bazne_za_ispis = makeDynString("baznu", "baznu (redukcija)");
  bool status;
  
  dyn_string neispravni_rezimi;
  dyn_string neispravni_ormari;
  
  for (int i=1; i<=dynlen(ormari_bazne); i++) {    
    for (int j=1; j<=dynlen(nivoi_bazne); j++) {
      dpGet("SysSarani:bazna.cmd.ror.daljinski." + ormari_bazne[i] + "." + nivoi_bazne[j], status);
      if(!status) {
        dynAppend(neispravni_rezimi, "orman " + ormari_bazne[i] + ", komanda uključi " + nivoi_bazne_za_ispis[j]);
        
      }
    }
    
    if (ormari_bazne[i] == "OS1")
      dpGet("SysSarani:bazna.cmd.ror.daljinski." + ormari_bazne[i] + ".prilazna_zona1", status);
      if(!status) 
        dynAppend(neispravni_rezimi, "orman " + ormari_bazne[i] + ", komanda uključi prilaznu zonu 1");
    else if (ormari_bazne[i] == "OS2") {
      dpGet("SysSarani:bazna.cmd.ror.daljinski." + ormari_bazne[i] + ".prilazna_zona2", status);
      if(!status) 
        dynAppend(neispravni_rezimi, "orman " + ormari_bazne[i] + ", komanda uključi prilaznu zonu 2");
    }
  }
  
  for (int i=1; i<=dynlen(ormari_adaptivne); i++) {
    for (int j=1; j<=dynlen(nivoi_adaptivne); j++) {
      dpGet("SysSarani:" + ormari_adaptivne[i] + ".cmd.ror.daljinski." + nivoi_adaptivne[j], status);
      if(!status) {
        dynAppend(neispravni_rezimi, "* orman " + ormari_adaptivne[i] + ", komanda uključi " + nivoi_adaptivne[j]);
        
      }
    }
  }
  
  //dpSet("SysSarani:svi_ormari.zadnja_greska", neispravni_rezimi);
  return neispravni_rezimi;
}
/*---------------------------------------------------------------------------------*/
dyn_string provjeriRezimJednogOrmaraBazne(string ormar) {
  dyn_string neispravni_rezimi;
  dyn_string nivoi_bazne = makeDynString("bazna", "bazna_redukcija");
  dyn_string nivoi_bazne_za_ispis = makeDynString("baznu", "baznu (redukcija)");
  bool status;
  for (int i=1; i<=dynlen(nivoi_bazne); i++) {
    dpGet("SysSarani:bazna.cmd.ror.daljinski." + ormar + "." + nivoi_bazne[i], status);
      if(!status) 
        dynAppend(neispravni_rezimi, "* komanda uključi " + nivoi_bazne_za_ispis[i]);
  }
  //dpSet("SysSarani:svi_ormari.zadnja_greska", neispravni_rezimi);
  return neispravni_rezimi;
}
/*---------------------------------------------------------------------------------*/
dyn_string provjeriRezimJednogOrmaraAdaptivne(string ormar) {
  dyn_string neispravni_rezimi;
  dyn_string nivoi_adaptivne = makeDynString("100%", "75%", "50%", "25%", "12_5%");
  
  bool status;
  for (int i=1; i<=dynlen(nivoi_adaptivne); i++) {
    dpGet("SysSarani:" + ormar+ ".cmd.ror.daljinski." + nivoi_adaptivne[i], status);
      if(!status) 
        dynAppend(neispravni_rezimi, "* komanda uključi " + nivoi_adaptivne[i]);
  }
  //dpSet("SysSarani:svi_ormari.zadnja_greska", neispravni_rezimi);
  return neispravni_rezimi;
}
/*---------------------------------------------------------------------------------*/
dyn_string provjeriRezimPrilazneZone(int zona) {
  dyn_string neispravni_rezimi;
  string ormar = (zona==1) ? "OS1" : "OS2";
  bool status;
  dpGet("SysSarani:bazna.cmd.ror.daljinski." + ormar + ".prilazna_zona" + zona, status);
  if(!status) 
    dynAppend(neispravni_rezimi, "* komanda uključi prilaznu zonu" + zona);
  
  //dpSet("SysSarani:svi_ormari.zadnja_greska", neispravni_rezimi);
  return neispravni_rezimi;
}
/*---------------------------------------------------------------------------------*/
string provjeriAdaptivnu(string ormar, string nivo){
  //Provjera da li je upravljanje bilo kojim nivoom manjim ili jednakim zeljenom nivou podeseno na rucno upravljanje.
  //Ako jest, vraca se string koji pokazuje na kojim je to nivoima tako podeseno
  bool b1=true, b2=true, b3=true, b4=true, b5=true;
  string s;
  
  dpGet("SysSarani:" + ormar + ".cmd.ror.daljinski.100%", b1);
  dpGet("SysSarani:" + ormar + ".cmd.ror.daljinski.75%", b2);
  dpGet("SysSarani:" + ormar + ".cmd.ror.daljinski.50%", b3);
  dpGet("SysSarani:" + ormar + ".cmd.ror.daljinski.25%", b4);
  dpGet("SysSarani:" + ormar + ".cmd.ror.daljinski.12_5%", b5);
  
  if (!b1) 
    s += "100%\n";
  if (!b2) 
    s += "75%\n";
  if (!b3) 
    s += "50%\n";
  if (!b4) 
    s += "25%\n";
  if (!b5) 
    s += "12.5%\n";
     
  return s; 
}

//---------------------------------------------------------------------------------

void izbaciGresku(string greska) {
  dyn_float df;
  dyn_string ds;

  ChildPanelOnReturn("ROR/info.pnl", latinToCyrillic("Obavest"), makeDynString(latinToCyrillic("$OBAVIJEST:" + greska)), 300, 200, df,ds);
  return;
}
//---------------------------------------------------------------------------------
void greskaKomandaNijePrimljena(string dp) {
  dyn_float df;
  dyn_string ds;
  string s = "Poslana komanda sa ormana " + dp + " nije registrovana.\n";
  ChildPanelOnReturn("vision/MessageInfo1", latinToCyrillic("Greška"), makeDynString(latinToCyrillic("$1:" + s)), 300, 200, df,ds);
  return;
}
//---------------------------------------------------------------------------------
void greskaKomandaAdaptivnaNijePrimljena(string dp, string nivo) {
  dyn_float df;
  dyn_string ds;
  string s = "Poslana komanda sa ormana " + dp + " \nza nivo rasvete " + nivo +"% \nnije registrovana.\n";
  ChildPanelOnReturn("vision/MessageInfo2", latinToCyrillic("Greška"), makeDynString(latinToCyrillic("$1:" + s)), 300, 200, df,ds);
  return;
}
//---------------------------------------------------------------------------------
int provjeriStatusAdaptivne(string ormar, dyn_bool vrijednosti) {
  bool A100, A75, A50, A25, A12_5;
  dpGet("SysSarani:" + ormar + ".state.100%", A100);
  
  if (A100 != vrijednosti[1]) {
    //greskaKomandaAdaptivnaNijePrimljena(ormar, "100");
    return -1;
  }
  
  dpGet("SysSarani:" + ormar + ".state.75%", A75);
  if (A75 != vrijednosti[2]) {
    //greskaKomandaAdaptivnaNijePrimljena(ormar, "75");
    return -1;
  }
  
  dpGet("SysSarani:" + ormar + ".state.50%", A50);
  if (A50 != vrijednosti[3]) {
    //greskaKomandaAdaptivnaNijePrimljena(ormar, "50");
    return -1;
  }
  
  dpGet("SysSarani:" + ormar + ".state.25%", A25);
  if (A25 != vrijednosti[4]) {
    //greskaKomandaAdaptivnaNijePrimljena(ormar, "25");
    return -1;
  }
  
  dpGet("SysSarani:" + ormar + ".state.12_5%", A12_5);
  if (A12_5 != vrijednosti[5]) {
    //greskaKomandaAdaptivnaNijePrimljena(ormar, "12.5");
    return -1;
  }
  return 0;
}

/*---------------------------------------------------------------------------------*
 *                               LOGIRANJE                                         * 
 *---------------------------------------------------------------------------------*/
void logujPostavljanjeKomande (string ormar, string vrijednost) {
  DebugFTN("level1", "Poslana je komanda za paljenje adaptivne rasvjete sa ormara " + ormar + " - nivo " + vrijednost);
}
/*---------------------------------------------------------------------------------*/

void logujUspjesnoPaljenjeRasvete (string ormar, string vrijednost) {
        DebugFTN("level1", "Dobiven je status o uspjesnom postavljanju adaptivne rasvjete u ormaru " + ormar 
                + " na nivo " + vrijednost + ". Aktivni nivo postavljen na nivo " + vrijednost);
}
/*---------------------------------------------------------------------------------*/

void logujPostavljanjeKomandeBazna (string ormar, bool vrijednost) {
  DebugFTN("level1", "Poslana je komanda za paljenje bazne rasvjete sa ormara " + ormar + " na vrijednost " + vrijednost);
}
/*---------------------------------------------------------------------------------*/

void logujUspjesnoPaljenjeBazneRasvjete (string ormar, bool vrijednost) {
        DebugFTN("level1", "Dobiven je status o uspjesnom postavljanju bazne rasvjete sa ormara " + ormar 
                + " na vrijednost " + vrijednost);
}
/*---------------------------------------------------------------------------------*/

void logujBezuspjesnoPaljenjeBazneRasvjete (string ormar, bool vrijednost) {
        DebugFTN("level1", "Dobiven je status o bezuspjesnom postavljanju bazne rasvjete sa ormara " + ormar 
                + " na vrijednost " + vrijednost);
}
/*---------------------------------------------------------------------------------*/

void logujPostavljanjeKomandeBaznaRedukcija (string ormar, bool vrijednost) {
  DebugFTN("level1", "Poslana je komanda za paljenje redukcije bazne rasvjete sa ormara " + ormar + " na vrijednost " + vrijednost);
}
/*---------------------------------------------------------------------------------*/

void logujUspjesnoPaljenjeBazneRasvjeteRedukcija (string ormar, bool vrijednost) {
  DebugFTN("level1", "Dobiven je status o uspjesnom postavljanju redukcije bazne rasvjete sa ormara " + ormar 
                + " na vrijednost " + vrijednost);
}
/*---------------------------------------------------------------------------------*/
