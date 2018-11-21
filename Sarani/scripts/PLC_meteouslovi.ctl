#uses "mapiranjeBrojevaScenarija.ctl"

main() {
  string sys_name1 = "SysSarani:";
  dpConnect("work", sys_name1 + "MS1.response.alarm.Poledica", sys_name1 + "MS2.response.alarm.Poledica",
                    sys_name1 + "MS1.response.alarm.Magla", sys_name1 + "MS2.response.alarm.Magla",
                    sys_name1 + "MS1.response.alarm.Sklizak_Kolovoz", sys_name1 + "MS2.response.alarm.Sklizak_Kolovoz",
                    sys_name1 + "MS1.response.alarm.Snijeg", sys_name1 + "MS2.response.alarm.Snijeg",
                    sys_name1 + "MS1.response.alarm.Vjetar", sys_name1 + "MS2.response.alarm.Vjetar",
                    sys_name1 + "MS1.response.alarm.Status_Nema_Komunikacije", sys_name1 + "MS2.response.alarm.Status_Nema_Komunikacije",
                    sys_name1 + "MS1.response.alarm.Status_Meteoroloska_Stanica_Prisutna", sys_name1 + "MS2.response.alarm.Status_Meteoroloska_Stanica_Prisutna",
                    sys_name1 + "MS1.response.alarm.Status_Prisutan_Senzor_Ceste", sys_name1 + "MS2.response.alarm.Status_Prisutan_Senzor_Ceste",
                    sys_name1 + "MS1.response.alarm.Status_Prisutan_Senzor_Ceste2", sys_name1 + "MS2.response.alarm.Status_Prisutan_Senzor_Ceste2",
                    sys_name1 + "MS1.response.alarm.Status_Senzor_Vidljivosti_Prisutan", sys_name1 + "MS2.response.alarm.Status_Senzor_Vidljivosti_Prisutan",
                    sys_name1 + "MS1.response.alarm.Poledica_2", sys_name1 + "MS2.response.alarm.Poledica_2",
                    sys_name1 + "MS1.response.alarm.Sklizak_Kolovoz_2", sys_name1 + "MS2.response.alarm.Sklizak_Kolovoz_2",
                    sys_name1 + "MS1.response.alarm.Snijeg_2", sys_name1 + "MS2.response.alarm.Snijeg_2");
}


work (string dp1, int poledica1, string dp2, int poledica2,
      string dp3, int magla1, string dp4, int magla2,
      string dp5, int klizavo1, string dp6, int klizavo2,
      string dp7, int snijeg1, string dp8, int snijeg2,
      string dp9, int vjetar1, string dp10, int vjetar2,
      string dp11, bool komunikacija1, string dp12, bool komunikacija1,
      string dp13, bool meteo1_prisutna, string dp14, bool meteo2_prisutna,
      string dp15, bool senzor_Ceste1_1, string dp16, bool senzor_Ceste2_1,
      string dp17, bool senzor_Ceste1_2, string dp18, bool senzor_Ceste2_2,
      string dp19, bool senzor_vidljivosti1, string dp20, bool senzor_vidljivosti2,
      string dp21, int poledica1_2, string dp22, int poledica2_2,
      string dp23, int klizavo1_2, string dp24, int klizavo2_2,
      string dp25, int snijeg1_2, string dp26, int snijeg2_2) {
  
  
  
  
  bool automatsko_upravljanje, automatsko_upravljanje_ms2;
    
  dpGet("SysSarani:aktivni_algoritam.meteouslovi.automatsko_upravljanje", automatsko_upravljanje);
  dpGet("SysSarani:aktivni_algoritam.meteouslovi.automatsko_upravljanje_ms2", automatsko_upravljanje_ms2);  
  
  
  if (automatsko_upravljanje || automatsko_upravljanje_ms2) {
    int pokrenuti_algoritam, saobracajni_scenarij;
    dpGet("SysSarani:aktivni_algoritam.pokrenuti_algoritam", pokrenuti_algoritam);
    
    dpGet("SysSarani:aktivni_algoritam.scenarij_signalizacije", saobracajni_scenarij);
  
    if (provjeriPoledica(pokrenuti_algoritam) && ((poledica1 == 1 && senzor_Ceste1_1 && automatsko_upravljanje) || (poledica1_2 == 1 && senzor_Ceste1_2 && automatsko_upravljanje) ||
                                                  (poledica2 == 1 && senzor_Ceste2_1 && automatsko_upravljanje_ms2) || (poledica2_2 == 1 && senzor_Ceste2_2 && automatsko_upravljanje_ms2))) { //Scenarij - poledica 
      
    
    
      //dpSet("SysSavinac:aktivni_algoritam.aktivni_algoritam", 26); 
      if (pokrenuti_algoritam!=26 && !(saobracajni_scenarij>=1 && saobracajni_scenarij <= 17))   {
        postaviParametreAlgoritma(makeDynInt(26, getAlgoritamRasvjete(26)));
        DebugTN("Pokrenut scenarij 'Poledica'");
      }
    }
  
    else if (provjeriKlizavo2(pokrenuti_algoritam) && ((klizavo1 >= 3000 && senzor_Ceste1_1 && automatsko_upravljanje) || (klizavo1_2 >= 3000 && senzor_Ceste1_2 && automatsko_upravljanje) ||
                                                       (klizavo2 >= 3000 && senzor_Ceste2_1 && automatsko_upravljanje_ms2) || (klizavo2_2 >= 3000 && senzor_Ceste2_2 && automatsko_upravljanje_ms2))) {//Scenarij - klizavo 2 
    
    
      //dpSet("SysSavinac:aktivni_algoritam.aktivni_algoritam", 23);
      if (pokrenuti_algoritam!=23 && !(saobracajni_scenarij>=1 && saobracajni_scenarij <= 17)) {
        postaviParametreAlgoritma(makeDynInt(23, getAlgoritamRasvjete(23)));
        DebugTN("Pokrenut scenarij 'Klizavo 2'");
      }
    }
  
  
  
    else if (provjeriVidljivost2(pokrenuti_algoritam) && ((magla1 <= 60 && senzor_vidljivosti1 && magla1 != 0 && automatsko_upravljanje) 
                                                           || (magla2 <= 60 && senzor_vidljivosti2 && magla2 != 0 && automatsko_upravljanje_ms2))) {//Scenarij - magla 2 
    
  //     DebugTN("Pokrenut scenarij 'Magla 2'");
      //dpSet("SysSavinac:aktivni_algoritam.aktivni_algoritam", 25);
      if (pokrenuti_algoritam!=25 && !(saobracajni_scenarij>=1 && saobracajni_scenarij <= 17)) {
        postaviParametreAlgoritma(makeDynInt(25, getAlgoritamRasvjete(25)));
        DebugTN("Pokrenut scenarij 'Magla 2'");
      }
    }
  
  
  
    else if (provjeriVjetar2(pokrenuti_algoritam) && ((vjetar1 >= 22 && automatsko_upravljanje) || (vjetar2 >= 22 && automatsko_upravljanje_ms2))) {//Scenarij - vjetar 2 
    
  //     
  //     DebugTN("Pokrenut scenarij 'Vjetar 2'");
      //dpSet("SysSavinac:aktivni_algoritam.aktivni_algoritam", 30);
      if (pokrenuti_algoritam!=30 && !(saobracajni_scenarij>=1 && saobracajni_scenarij <= 17)) {
        postaviParametreAlgoritma(makeDynInt(30, getAlgoritamRasvjete(30)));
        DebugTN("Pokrenut scenarij 'Vjetar 2'");
      }
    }
  
  
  
    else if(provjeriSnijeg1(pokrenuti_algoritam) && ((snijeg1 > 0 && senzor_Ceste1_1 && automatsko_upravljanje) || (snijeg2 > 0 && senzor_Ceste2_1 && automatsko_upravljanje_ms2) ||
                                                     (snijeg1_2 > 0 && senzor_Ceste1_2 && automatsko_upravljanje) || (snijeg2_2 > 0 && senzor_Ceste2_2 && automatsko_upravljanje_ms2))) { //Scenarij - snijeg 1
    
  //     DebugTN("Pokrenut scenarij 'Snijeg 1'");
      //dpSet("SysSavinac:aktivni_algoritam.aktivni_algoritam", 27);
      if (pokrenuti_algoritam!=27 && !(saobracajni_scenarij>=1 && saobracajni_scenarij <= 17)) {
        postaviParametreAlgoritma(makeDynInt(27, getAlgoritamRasvjete(27)));
        DebugTN("Pokrenut scenarij 'Snijeg 1'");
      }
    }
  
  
  
    else if (provjeriKlizavo1(pokrenuti_algoritam) && ((klizavo1 >= 1500 && klizavo1 < 3000 && senzor_Ceste1_1 && automatsko_upravljanje) || (klizavo1_2 >= 1500 && klizavo1_2 < 3000 && senzor_Ceste1_2 && automatsko_upravljanje) ||
                                                       (klizavo2 >= 1500 && klizavo2 < 3000 && senzor_Ceste2_1 && automatsko_upravljanje_ms2) || (klizavo2_2 >= 1500 && klizavo2_2 < 3000 && senzor_Ceste2_2 && automatsko_upravljanje_ms2))) { //Scenarij - klizavo 1 
    
  //     DebugTN("Pokrenut scenarij 'Klizavo 1'");
      //dpSet("SysSavinac:aktivni_algoritam.aktivni_algoritam", 22);
      if (pokrenuti_algoritam!=22 && !(saobracajni_scenarij>=1 && saobracajni_scenarij <= 17)) {
        postaviParametreAlgoritma(makeDynInt(22, getAlgoritamRasvjete(22)));
        DebugTN("Pokrenut scenarij 'Klizavo 1'");
      }
    }
  
  
  
  
    else if (provjeriVidljivost1(pokrenuti_algoritam) && ((magla1 > 60 && magla1 <=100 && senzor_vidljivosti1 && automatsko_upravljanje) || (magla2 > 60 && magla2 <=100 && senzor_vidljivosti2 && automatsko_upravljanje_ms2))) { //Scenarij - magla 1 
    
    
      //dpSet("SysSavinac:aktivni_algoritam.aktivni_algoritam", 24);
      if (pokrenuti_algoritam!=24 && !(saobracajni_scenarij>=1 && saobracajni_scenarij <= 17)) {
        postaviParametreAlgoritma(makeDynInt(24, getAlgoritamRasvjete(24)));
        DebugTN("Pokrenut scenarij 'Magla 1'");
      }
    }
  
  
  
    else if (provjeriVjetar1(pokrenuti_algoritam) && ((vjetar1 >= 18 && vjetar1 < 22 && automatsko_upravljanje) || (vjetar2 >= 18 && vjetar2 < 22 && automatsko_upravljanje_ms2))) { //Scenarij - vjetar 1 
    
    
      //dpSet("SysSavinac:aktivni_algoritam.aktivni_algoritam", 29);
      if (pokrenuti_algoritam!=29 && !(saobracajni_scenarij>=1 && saobracajni_scenarij <= 17)) {
        postaviParametreAlgoritma(makeDynInt(29, getAlgoritamRasvjete(29)));
        DebugTN("Pokrenut scenarij 'Vjetar 1'");
      }
    }
  
  
  
    else if (provjeriPovratakUNormalneUslove(pokrenuti_algoritam)) {
    
      DebugTN("Pokrenut scenarij 'Normalni uslovi'");
      //dpSet("SysSavinac:aktivni_algoritam.aktivni_algoritam", 0);
      if (!(saobracajni_scenarij>=1 && saobracajni_scenarij <= 17)) {
        postaviParametreAlgoritma(makeDynInt(0, getAlgoritamRasvjete(0)));
      }
    }
    else {
    
      //DebugTN("Zadržava se staro stanje");
    }
  }
}

void postaviParametreAlgoritma(dyn_int parametri) {
  
  dpSet("SysSarani:bazna.automatsko_upravljanje", 1);  //rasvjeta se prabacuje u automatsko upravljanje
  
  dyn_string naziviScenarija = getNaziviScenarija(parametri[1]); //prvi parametar je broj algoritma (i saobracajnog scenarija)
  
  dpSet("SysSarani:aktivni_algoritam.pozar_sa_kolonom_ispred", 0);
  dpSet("SysSarani:aktivni_algoritam.pokrenuti_algoritam", parametri[1]);
  dpSet("SysSarani:aktivni_algoritam.vatrodojavna_zona_alarma", 0); //ne aktivira se nijedna vatrodojavna zona
  dpSet("SysSarani:aktivni_algoritam.scenarij_signalizacije", parametri[1]);
  dpSet("SysSarani:aktivni_algoritam.naziv_pokrenutog_algoritma", naziviScenarija[1]);  
  dpSet("SysSarani:aktivni_algoritam.naziv_pokrenutog_saobracajnog_scenarija", naziviScenarija[1]);  
  dpSet("SysSarani:aktivni_algoritam.scenarij_rasvjete", parametri[2]); //drugi parametar je broj scenarija za rasvjetu
}

bool provjeriSnijeg2(int pokrenuti_algoritam) {
  
  dyn_int dozvoljeni_scenariji = makeDynInt(0, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34);
  
  for (int i=1; i<=dynlen(dozvoljeni_scenariji); i++) {
    if (dozvoljeni_scenariji[i] == pokrenuti_algoritam)
      return true;
  }
  
  return false;
}

bool provjeriPoledica(int pokrenuti_algoritam) {
  
  dyn_int dozvoljeni_scenariji = makeDynInt(0, 22, 23, 24, 25, 26, 27, 29, 30, 31, 32, 33, 34);
  
  for (int i=1; i<=dynlen(dozvoljeni_scenariji); i++) {
    if (dozvoljeni_scenariji[i] == pokrenuti_algoritam)
      return true;
  }
  
  return false;
}

bool provjeriKlizavo2(int pokrenuti_algoritam) {
  
  dyn_int dozvoljeni_scenariji = makeDynInt(0, 22, 23, 24, 25, 26, 27, 29, 30, 31, 32, 33, 34);
  
  for (int i=1; i<=dynlen(dozvoljeni_scenariji); i++) {
    if (dozvoljeni_scenariji[i] == pokrenuti_algoritam)
      return true;
  }
  
  return false;
}

bool provjeriVidljivost2(int pokrenuti_algoritam) {
  
  dyn_int dozvoljeni_scenariji = makeDynInt(0, 22, 23, 24, 25, 26, 27, 29, 30, 31, 32, 33, 34);
  
  for (int i=1; i<=dynlen(dozvoljeni_scenariji); i++) {
    if (dozvoljeni_scenariji[i] == pokrenuti_algoritam)
      return true;
  }
  
  return false;
}

bool provjeriVjetar2(int pokrenuti_algoritam) {
  
  dyn_int dozvoljeni_scenariji = makeDynInt(0, 22, 23, 24, 25, 26, 27, 29, 30, 31, 32, 33, 34);
  
  for (int i=1; i<=dynlen(dozvoljeni_scenariji); i++) {
    if (dozvoljeni_scenariji[i] == pokrenuti_algoritam)
      return true;
  }
  
  return false;
}

bool provjeriSnijeg1(int pokrenuti_algoritam) {
  
  dyn_int dozvoljeni_scenariji = makeDynInt(0, 22, 23, 24, 25, 26, 27, 29, 30, 31, 32, 33, 34);
  
  for (int i=1; i<=dynlen(dozvoljeni_scenariji); i++) {
    if (dozvoljeni_scenariji[i] == pokrenuti_algoritam)
      return true;
  }
  
  return false;
}

bool provjeriKlizavo1(int pokrenuti_algoritam) {
  
  dyn_int dozvoljeni_scenariji = makeDynInt(0, 22, 23, 24, 25, 26, 27, 29, 30, 31, 32, 33, 34);
  
  for (int i=1; i<=dynlen(dozvoljeni_scenariji); i++) {
    if (dozvoljeni_scenariji[i] == pokrenuti_algoritam)
      return true;
  }
  
  return false;
}

bool provjeriVidljivost1(int pokrenuti_algoritam) {
  
  dyn_int dozvoljeni_scenariji = makeDynInt(0, 22, 23, 24, 25, 26, 27, 29, 30, 31, 32, 33, 34);
  
  for (int i=1; i<=dynlen(dozvoljeni_scenariji); i++) {
    if (dozvoljeni_scenariji[i] == pokrenuti_algoritam)
      return true;
  }
  
  return false;
}

bool provjeriVjetar1(int pokrenuti_algoritam) {
  
  dyn_int dozvoljeni_scenariji = makeDynInt(0, 22, 23, 24, 25, 26, 27, 29, 30, 31, 32, 33, 34);
  
  for (int i=1; i<=dynlen(dozvoljeni_scenariji); i++) {
    if (dozvoljeni_scenariji[i] == pokrenuti_algoritam)
      return true;
  }
  
  return false;
}

bool provjeriPovratakUNormalneUslove(int pokrenuti_algoritam) {
  dyn_int dozvoljeni_scenariji = makeDynInt(22, 23, 24, 25, 26, 27, 28, 29, 30);
  for (int i=1; i<=dynlen(dozvoljeni_scenariji); i++) {
    if (dozvoljeni_scenariji[i] == pokrenuti_algoritam)
      return true;
  }
  
  
  return false;
}




// workBP(string dp1, int alarmd11, string dp2, int alarmd12,
//        string dp3, int alarmd21, string dp4, int alarmd22,
//        string dp5, int alarmd31, string dp6, int alarmd32,
//        string dp7, int alarmd41, string dp8, int alarmd42) {
//  
//   int pokrenuti_algoritam;
//   dpGet("SysSarani:aktivni_algoritam.pokrenuti_algoritam", pokrenuti_algoritam); 
//   
//   if (pokrenuti_algoritam == 0) {
//     if (alarmd11 == 3 || alarmd12==3 || alarmd21==3 || alarmd22==3) {
//       postaviParametreAlgoritma(makeDynInt(32, getAlgoritamRasvjete(32)));
//     }
//     
//     if (alarmd31 == 3 || alarmd32==3 || alarmd41==3 || alarmd42==3) {
//       postaviParametreAlgoritma(makeDynInt(34, getAlgoritamRasvjete(34)));
//     }
//   }
// }



