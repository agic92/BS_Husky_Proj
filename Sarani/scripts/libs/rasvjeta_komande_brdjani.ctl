#uses "latin_to_cyrillic.ctl"
/*---------------------------------------------------------------------------------*
 *                   PODEŠAVANJE NIVOA ADAPTIVNE RASVJETE                          * 
 *---------------------------------------------------------------------------------*/
bool podesiNivoAdaptivne2 (string cijev, float nivo) {
  dyn_bool vrijednosti;  
  
  int level;

  switch (nivo) {
    case 100:
      level = 31;
      vrijednosti = makeDynInt(1, 1, 1, 1, 1);
      break;
    case 75:
      level = 15;
      vrijednosti = makeDynInt(0, 1, 1, 1, 1);
      break;
    case 50:
      level = 7;
      vrijednosti = makeDynInt(0, 0, 1, 1, 1);
      break;
    case 25:
      level = 3;
      vrijednosti = makeDynInt(0, 0, 0, 1, 1);
      break;
    case 12.5:
      level = 1;
      vrijednosti = makeDynInt(0, 0, 0, 0, 1);
      break;
    case 0:
      level = 0;
      vrijednosti = makeDynInt(0, 0, 0, 0, 0);
      break;
  }
//   
//   dpSet("SysBrdjani:rasvjeta_" + cijev + "_cijev.adaptivna.cmd.100%", vrijednosti[1]);
//   dpSet("SysBrdjani:rasvjeta_" + cijev + "_cijev.adaptivna.cmd.75%", vrijednosti[2]);
//   dpSet("SysBrdjani:rasvjeta_" + cijev + "_cijev.adaptivna.cmd.50%", vrijednosti[3]);
//   dpSet("SysBrdjani:rasvjeta_" + cijev + "_cijev.adaptivna.cmd.25%", vrijednosti[4]);
  if (cijev=="lijeva") {
     bool prilazna;
     dpGet("SysBrdjani:rasvjeta_lijeva_cijev.prilazna_zona.state.on", prilazna);
     level += 32*prilazna;
  } 
  dpSet("SysBrdjani:rasvjeta_" + cijev + "_cijev.adaptivna.cmd.ukljucenje_int", level);
  
  logujPostavljanjeKomande(cijev, nivo + "%");
  
  delay(15);
  if (provjeriStatusAdaptivne1 (cijev, vrijednosti) == 0) {
      //dpSet("SysSarani:" + ormar + ".value.aktivni_nivo", nivo);
      logujUspjesnoPaljenjeRasvete(cijev, nivo + "%");
      return true;
  }
  else {
    bool a12, a25, a50, a75, a100;
  
    dpGet("SysBrdjani:rasvjeta_" + cijev +  "_cijev.adaptivna.state.12_5%_R", a12);
    dpGet("SysBrdjani:rasvjeta_" + cijev +  "_cijev.adaptivna.state.25%_R", a25);
    dpGet("SysBrdjani:rasvjeta_" + cijev +  "_cijev.adaptivna.state.50%_R", a50);
    dpGet("SysBrdjani:rasvjeta_" + cijev +  "_cijev.adaptivna.state.75%_R", a75);
    dpGet("SysBrdjani:rasvjeta_" + cijev +  "_cijev.adaptivna.state.100%_R", a100);
  
    int dodatak = 1*a12 + 2*a25 + 4*a50 + 8*a75 + 16*a100;
    
    dpSet("SysBrdjani:rasvjeta_" + cijev + "_cijev.adaptivna.cmd.ukljucenje_int", dodatak);
  }
  return false;
}

/*---------------------------------------------------------------------------------*
 *                   PODEŠAVANJE NIVOA BAZNE RASVJETE                              * 
 *---------------------------------------------------------------------------------*/
// bool ukljuciSvuDesnu() {
//   DebugTN("ukljuciSvuDesnu() pozvana");
//   dyn_string ormari_bazne = makeDynString("OS1", "OS1/UPS", "B-1D", "B-1D/UPS", "B-2L", "B-2L/UPS", "OS2", "OS2/UPS");
//   
//   for (int i=1; i<= dynlen(ormari_bazne); i++) {
//     podesiNivoBazne(ormari_bazne[i], 1);
//   }
//   
//   ukljuciPrilaznuOS1();
// }
/*---------------------------------------------------------------------------------*/

// bool ukljuciSvuLijevu() {
//   DebugTN("ukljuciSvuLijevu() pozvana");
//   dyn_string ormari_bazne = makeDynString("OS1", "OS1/UPS", "B-1D", "B-1D/UPS", "B-2L", "B-2L/UPS", "OS2", "OS2/UPS");
//   
//   for (int i=1; i<= dynlen(ormari_bazne); i++) {
//     podesiNivoBazne(ormari_bazne[i], 1);
//   }
//   
//   ukljuciPrilaznuOS2();
// }
/*---------------------------------------------------------------------------------*/

// bool ukljuciSvuRasvjetu() {
//   DebugTN("ukljuciSvuLijevu() pozvana");
//   dyn_string ormari_bazne = makeDynString("OS1", "OS1/UPS", "B-1D", "B-1D/UPS", "B-2L", "B-2L/UPS", "OS2", "OS2/UPS");
//   
//   for (int i=1; i<= dynlen(ormari_bazne); i++) {
//     podesiNivoBazne(ormari_bazne[i], 1);
//   }
//   
//   ukljuciPrilaznuOS1();
//   ukljuciPrilaznuOS2();
// }
/*---------------------------------------------------------------------------------*/

void podesiNivoBazne2 (string cijev, float nivo) {
  int vrijednost;
  
  switch (nivo) {
    case 0: //iskljucena bazna
      vrijednost = 0;
      break;
    case 1: //ukljucena bazna bez prigusenja
      vrijednost = 1;
      break;
    case 2: //ukljucena bazna sa prigusenjem
      vrijednost = 3;
      break;
  }
  
  dpSet("SysBrdjani:rasvjeta_" + cijev + "_cijev.bazna.cmd.on", vrijednost);
  
  logujPostavljanjeKomandeBazna(cijev, vrijednost);
}
/*---------------------------------------------------------------------------------*
 *                   PROVJERA POSTAVLJANJA BAZNE RASVJETE                          * 
 *---------------------------------------------------------------------------------*/
// bool provjeriDozvoluPaljenjaAdaptivne(string ormar, string nivo) {
//   bool dozvoljeno;
//   dpGet("SysSarani:" + ormar + ".dozvola_paljenja." + nivo, dozvoljeno);
//   return dozvoljeno;
// }

/*---------------------------------------------------------------------------------*
 *                   PROVJERA POSTAVLJANJA BAZNE RASVJETE                          * 
 *---------------------------------------------------------------------------------*/
// bool provjeriPostavljanjeBazne(string ormar, float nivo) {
//   dyn_bool vrijednosti1; //statusi 
//   dyn_bool vrijednosti2; //komande
//   
//   switch (nivo) {
//     case 0: //iskljucena bazna
//       vrijednosti1 = makeDynInt(0, 0);
//       break;
//     case 1: //ukljucena bazna bez prigusenja
//       vrijednosti1 = makeDynInt(1, 0);
//       break;
//     case 2: //ukljucena bazna sa prigusenjem
//       vrijednosti1 = makeDynInt(1, 1);
//       break;
//   }
//   vrijednosti2 = vrijednosti1;
//   
//   dpGet("SysSarani:bazna.state." + ormar + ".bazna", vrijednosti2[1]);
//   dpGet("SysSarani:bazna.state." + ormar + ".bazna_redukcija", vrijednosti2[2]);
//   
//   if (vrijednosti1[1] == vrijednosti2[1] && vrijednosti1[2] == vrijednosti2[2])
//     return true;
//   
//   return false;
// }

/*---------------------------------------------------------------------------------*
 *                   PODEŠAVANJE RASVJETE U PRILAZNOJ ZONI                         * 
 *---------------------------------------------------------------------------------*/
bool ukljuciPrilaznuOS21() {
  
  bool a12, a25, a50, a75, a100;
  
  dpGet("SysBrdjani:rasvjeta_lijeva_cijev.adaptivna.state.12_5%_R", a12);
  dpGet("SysBrdjani:rasvjeta_lijeva_cijev.adaptivna.state.25%_R", a25);
  dpGet("SysBrdjani:rasvjeta_lijeva_cijev.adaptivna.state.50%_R", a50);
  dpGet("SysBrdjani:rasvjeta_lijeva_cijev.adaptivna.state.75%_R", a75);
  dpGet("SysBrdjani:rasvjeta_lijeva_cijev.adaptivna.state.100%_R", a100);
  
  int dodatak = 1*a12 + 2*a25 + 4*a50 + 8*a75 + 16*a100;
  int vrijednost = 32 + dodatak;  
  
  
  bool prilazna1;
  DebugTN("ukljuciPrilaznuOS2() pozvana");
  dpSet("SysBrdjani:rasvjeta_lijeva_cijev.adaptivna.cmd.ukljucenje_int", vrijednost);
  delay(7);
  dpGet("SysBrdjani:rasvjeta_lijeva_cijev.prilazna_zona.state.on", prilazna1);
  
  if (!prilazna1) {
    dpSet("SysBrdjani:rasvjeta_lijeva_cijev.adaptivna.cmd.ukljucenje_int", dodatak);
    return false;
  }
  return true;
}
//---------------------------------------------------------------------------------
bool iskljuciPrilaznuOS21() {
  bool a12, a25, a50, a75, a100;
  
  dpGet("SysBrdjani:rasvjeta_lijeva_cijev.adaptivna.state.12_5%_R", a12);
  dpGet("SysBrdjani:rasvjeta_lijeva_cijev.adaptivna.state.25%_R", a25);
  dpGet("SysBrdjani:rasvjeta_lijeva_cijev.adaptivna.state.50%_R", a50);
  dpGet("SysBrdjani:rasvjeta_lijeva_cijev.adaptivna.state.75%_R", a75);
  dpGet("SysBrdjani:rasvjeta_lijeva_cijev.adaptivna.state.100%_R", a100);
  
  int dodatak = 1*a12 + 2*a25 + 4*a50 + 8*a75 + 16*a100;
  int vrijednost = 32 + dodatak;  
  
  
  bool prilazna1;
  DebugTN("ukljuciPrilaznuOS2() pozvana");
  dpSet("SysBrdjani:rasvjeta_lijeva_cijev.adaptivna.cmd.ukljucenje_int", dodatak);
  delay(10);
  dpGet("SysBrdjani:rasvjeta_lijeva_cijev.prilazna_zona.state.on", prilazna1);
  
  if (prilazna1) {
    dpSet("SysBrdjani:rasvjeta_lijeva_cijev.adaptivna.cmd.ukljucenje_int", vrijednost);
    return false;
  }
  return true;
}
/*---------------------------------------------------------------------------------*/
bool ukljuciPrilaznuOS11() {
  bool prilazna2;
  DebugTN("ukljuciPrilaznuOS1() pozvana");
  dpSet("SysBrdjani:rasvjeta_desna_cijev.prilazna_zona.cmd.on", 1);
  delay(7);
  dpGet("SysBrdjani:rasvjeta_desna_cijev.prilazna_zona.state.on", prilazna2);
  
  if (!prilazna2) {
    //dpSet("SysBrdjani:rasvjeta_desna_cijev.prilazna_zona.cmd.on", 0);
    return false;
  }
  return true;
}
//---------------------------------------------------------------------------------
bool iskljuciPrilaznuOS11() {
  bool prilazna2;
  DebugTN("iskljuciPrilaznuOS1() pozvana");
  dpSet("SysBrdjani:rasvjeta_desna_cijev.prilazna_zona.cmd.on", 0);
  delay(7);
  dpGet("SysBrdjani:rasvjeta_desna_cijev.prilazna_zona.state.on", prilazna2);
  
  if (prilazna2) {
    //dpSet("SysBrdjani:rasvjeta_desna_cijev.prilazna_zona.cmd.on", 1);
    return false;
  }
  return true;
}
/*---------------------------------------------------------------------------------*
 *                   UKLJUČIVANJE REDUKCIJE                                        * 
 *---------------------------------------------------------------------------------*/
// bool ukljuciRedukciju(string dp) {  //ne treba koristiti, ima metoda podesiNivoBazne()
//   
//   bool stari_status_bazne, stari_status_bazne_redukcija;
//   
//   dpGet("SysSarani:bazna.state." + dp + ".bazna", stari_status_bazne);
//   dpGet("SysSarani:bazna.state." + dp + ".bazna_redukcija", stari_status_bazne_redukcija);
//   
//   bool status_bazne, status_bazne_redukcija;
// 
//   dpSet("SysSarani:bazna.cmd.run." + dp + ".bazna", 1);  
//   dpSet("SysSarani:bazna.cmd.run." + dp + ".bazna_redukcija", 1);
//   
//   delay(1);
//   
//   dpGet("SysSarani:bazna.state." + dp + ".bazna", status_bazne);
//   dpGet("SysSarani:bazna.state." + dp + ".bazna_redukcija", status_bazne_redukcija);
//   
  //redukcija se moze paliti tek ako je upaljena bazna
//   if (!status_bazne || !status_bazne_redukcija) {
//     dpSet("SysSarani:bazna.cmd.run." + dp + ".bazna", stari_status_bazne);  
//     dpSet("SysSarani:bazna.cmd.run." + dp + ".bazna_redukcija", stari_status_bazne_redukcija);
//     return false;
//   }
//   return true;
// }
// 
/*---------------------------------------------------------------------------------*
 *                   ISKLJUČIVANJE REDUKCIJE                                       * 
 *---------------------------------------------------------------------------------*/
// bool iskljuciRedukciju(string dp) { //ne treba koristiti, ima metoda podesiNivoBazne()
//   
//   bool stari_status_bazne, stari_status_bazne_redukcija;
//   
//   dpGet("SysSarani:bazna.state." + dp + ".bazna", stari_status_bazne);
//   dpGet("SysSarani:bazna.state." + dp + ".bazna_redukcija", stari_status_bazne_redukcija);
//   
//    
//   bool status_bazne, status_bazne_redukcija;
// 
  //redukcija se moze paliti tek ako je upaljena bazna
//   if (status_bazne)
//     dpSet("SysSarani:bazna.cmd.run." + dp + ".bazna_redukcija", 0);
//   
//   dpGet("SysSarani:bazna.state." + dp + ".bazna_redukcija", status_bazne_redukcija);
//   
//   if (status_bazne_redukcija) {
//     dpSet("SysSarani:bazna.cmd.run." + dp + ".bazna_redukcija", stari_status_bazne_redukcija);
//     return false;
//   }
//   return true;
// }

/*---------------------------------------------------------------------------------*
 *                   PROVJERA GREŠAKA                                              * 
 *---------------------------------------------------------------------------------*/
dyn_string provjeriRezimSvihOrmara2() {
  dyn_string tipovi_bazne = makeDynString("bazna", "prilazna_zona");
  dyn_string nivoi_adaptivne = makeDynString("100%", "75%", "50%", "25%", "12_5%");
  
  dyn_string dps = makeDynString ("rasvjeta_desna_cijev", "rasvjeta_lijeva_cijev");
  
  
  dyn_string tipovi_bazne_za_ispis = makeDynString("baznu rasvetu", "prilaznu zonu");
  
  dyn_string dps_za_ispis = makeDynString("desna cev", "leva cev");
  bool status;
  
  dyn_string neispravni_rezimi;
  
  
  
  
  
  for (int i=1; i<=dynlen(dps); i++) {    
    for (int j=1; j<=dynlen(tipovi_bazne); j++) {
      dpGet("SysBrdjani:" + dps[i] + "." + tipovi_bazne[j] + ".upravljanje.daljinski", status);
      
      if(!status) {
        dynAppend(neispravni_rezimi, dps_za_ispis[i] + ", komanda uključi " + tipovi_bazne_za_ispis[j]);
      }
    }
    
    for (int j=1; j<=dynlen(nivoi_adaptivne); j++) {
      dpGet("SysBrdjani:" + dps[i] + ".adaptivna.state." + nivoi_adaptivne[j], status);
      
      if(!status) {
        dynAppend(neispravni_rezimi, dps_za_ispis[i] + ", komanda uključi adaptivnu - nivo " + nivoi_adaptivne[j]);
      }
    }

  }
  DebugTN("Neispravni rezimi:\n" + neispravni_rezimi);
  return neispravni_rezimi;
}
/*---------------------------------------------------------------------------------*/
dyn_string provjeriRezimJednogOrmaraBazne1(string cijev) {
  dyn_string neispravni_rezimi;
  dyn_string nivoi_bazne = makeDynString("bazna");
  dyn_string nivoi_bazne_za_ispis = makeDynString("baznu", "baznu (ups)");
  bool status;
  for (int i=1; i<=dynlen(nivoi_bazne); i++) {
    dpGet("SysBrdjani:rasvjeta_" + cijev + "_cijev." + nivoi_bazne[i] + ".upravljanje.daljinski", status);
      if(!status) 
        dynAppend(neispravni_rezimi, "* komanda uključi " + nivoi_bazne_za_ispis[i]);
  }
  return neispravni_rezimi;
}
/*---------------------------------------------------------------------------------*/
dyn_string provjeriRezimJednogOrmaraAdaptivne1(string cijev) {
  dyn_string neispravni_rezimi;
  dyn_string nivoi_adaptivne = makeDynString("100%", "75%", "50%", "25%", "12_5%");
  
  bool status;
  for (int i=1; i<=dynlen(nivoi_adaptivne); i++) {
    dpGet("SysBrdjani:rasvjeta_" + cijev + "_cijev.adaptivna.state." + nivoi_adaptivne[i], status);
      if(!status) 
        dynAppend(neispravni_rezimi, "* komanda uključi " + nivoi_adaptivne[i]);
  }

  return neispravni_rezimi;
}
/*---------------------------------------------------------------------------------*/
dyn_string provjeriRezimPrilazneZone1(int zona) {
  dyn_string neispravni_rezimi;
  string cijev = (zona==1) ? "desna" : "lijeva";
  bool status;
  dpGet("SysBrdjani:rasvjeta_" + cijev + "_cijev.prilazna_zona.upravljanje.daljinski", status);
  if(!status) 
    dynAppend(neispravni_rezimi, "* komanda uključi prilaznu zonu" + zona);
  
  return neispravni_rezimi;
}
/*---------------------------------------------------------------------------------*/
// string provjeriAdaptivnu(string ormar, string nivo){
  //Provjera da li je upravljanje bilo kojim nivoom manjim ili jednakim zeljenom nivou podeseno na rucno upravljanje.
  //Ako jest, vraca se string koji pokazuje na kojim je to nivoima tako podeseno
//   bool b1=true, b2=true, b3=true, b4=true, b5=true;
//   string s;
//   
//   dpGet("SysSarani:" + ormar + ".cmd.ror.daljinski.100%", b1);
//   dpGet("SysSarani:" + ormar + ".cmd.ror.daljinski.75%", b2);
//   dpGet("SysSarani:" + ormar + ".cmd.ror.daljinski.50%", b3);
//   dpGet("SysSarani:" + ormar + ".cmd.ror.daljinski.25%", b4);
//   dpGet("SysSarani:" + ormar + ".cmd.ror.daljinski.12_5%", b5);
//   
//   if (!b1) 
//     s += "100%\n";
//   if (!b2) 
//     s += "75%\n";
//   if (!b3) 
//     s += "50%\n";
//   if (!b4) 
//     s += "25%\n";
//   if (!b5) 
//     s += "12.5%\n";
//      
//   return s; 
// }

//---------------------------------------------------------------------------------

void izbaciGresku1(string greska) {
  dyn_float df;
  dyn_string ds;

  ChildPanelOnReturn("ROR_brdjani/info.pnl", latinToCyrillic("Obavest"), makeDynString(latinToCyrillic("$OBAVIJEST:" + greska)), 300, 200, df,ds);
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
int provjeriStatusAdaptivne1(string cijev, dyn_bool vrijednosti) {
  bool A100, A75, A50, A25, A12_5;
  dpGet("SysBrdjani:rasvjeta_" + cijev + "_cijev.adaptivna.state.100%_R", A100);
  
  if (A100 != vrijednosti[1]) {
    //greskaKomandaAdaptivnaNijePrimljena(ormar, "100");
    return -1;
  }
  
  dpGet("SysBrdjani:rasvjeta_" + cijev + "_cijev.adaptivna.state.75%_R", A75);
  if (A75 != vrijednosti[2]) {
    //greskaKomandaAdaptivnaNijePrimljena(ormar, "75");
    return -1;
  }
  
  dpGet("SysBrdjani:rasvjeta_" + cijev + "_cijev.adaptivna.state.50%_R", A50);
  if (A50 != vrijednosti[3]) {
    //greskaKomandaAdaptivnaNijePrimljena(ormar, "50");
    return -1;
  }
  
  dpGet("SysBrdjani:rasvjeta_" + cijev + "_cijev.adaptivna.state.25%_R", A25);
  if (A25 != vrijednosti[4]) {
    //greskaKomandaAdaptivnaNijePrimljena(ormar, "25");
    return -1;
  }
  
  dpGet("SysBrdjani:rasvjeta_" + cijev + "_cijev.adaptivna.state.12_5%_R", A12_5);
  if (A12_5 != vrijednosti[5]) {
    //greskaKomandaAdaptivnaNijePrimljena(ormar, "12.5");
    return -1;
  }
  return 0;
}

/*---------------------------------------------------------------------------------*
 *                               LOGIRANJE                                         * 
 *---------------------------------------------------------------------------------*/
void logujPostavljanjeKomande (string cijev, string vrijednost) {
  DebugTN("Poslana je komanda za paljenje adaptivne rasvjete za " + cijev + " cijev - nivo " + vrijednost);
}
/*---------------------------------------------------------------------------------*/

void logujUspjesnoPaljenjeRasvete (string cijev, string vrijednost) {
        DebugTN("Dobiven je status o uspjesnom postavljanju adaptivne rasvjete u  " + cijev 
                + " cijevi na nivo " + vrijednost + ". Aktivni nivo postavljen na nivo " + vrijednost);
}
/*---------------------------------------------------------------------------------*/

void logujPostavljanjeKomandeBazna (string ormar, bool vrijednost) {
  DebugTN("Poslana je komanda za paljenje bazne rasvjete za " + ormar + " cijev na vrijednost " + vrijednost);
}
/*---------------------------------------------------------------------------------*/

void logujUspjesnoPaljenjeBazneRasvjete (string ormar, bool vrijednost) {
        DebugTN("Dobiven je status o uspjesnom postavljanju bazne rasvjete sa ormara " + ormar 
                + " na vrijednost " + vrijednost);
}
/*---------------------------------------------------------------------------------*/

void logujBezuspjesnoPaljenjeBazneRasvjete (string ormar, bool vrijednost) {
        DebugTN("Dobiven je status o bezuspjesnom postavljanju bazne rasvjete sa ormara " + ormar 
                + " na vrijednost " + vrijednost);
}
/*---------------------------------------------------------------------------------*/

void logujPostavljanjeKomandeBaznaRedukcija (string ormar, bool vrijednost) {
  DebugTN("Poslana je komanda za paljenje redukcije bazne rasvjete sa ormara " + ormar + " na vrijednost " + vrijednost);
}
/*---------------------------------------------------------------------------------*/

void logujUspjesnoPaljenjeBazneRasvjeteRedukcija (string ormar, bool vrijednost) {
  DebugTN("Dobiven je status o uspjesnom postavljanju redukcije bazne rasvjete sa ormara " + ormar 
                + " na vrijednost " + vrijednost);
}
/*---------------------------------------------------------------------------------*/
