#uses "rasvjeta_komande.ctl"
#uses "dp_set_delay.ctl"

main () {
  startThread("desnaCijev");
  startThread("lijevaCijev");
  //startThread("kupiStatuseUKomande");
  //startThread("pratiDesniFotometar");
  
  
  startThread("prelaznoStanje");
  startThread("postavljanjeAktivnogNivoaRasvjete");
 
 
  //dpConnect("pratiLijevuCijev", "SysSarani:fotometar_l.value", "SysSarani:bazna.state.automatsko_upravljanje");
}

void prelaznoStanje() {
  dpConnect("pratiPrelaznoStanjeD", "SysSarani:RO-A1-1D.cmd.ror.daljinski.100%", "SysSarani:RO-A1-1D.cmd.ror.daljinski.75%",
                                   "SysSarani:RO-A1-1D.cmd.ror.daljinski.50%", "SysSarani:RO-A1-1D.cmd.ror.daljinski.25%",
                                   "SysSarani:RO-A1-1D.cmd.ror.daljinski.12_5%", 
                                   "SysSarani:bazna.cmd.ror.daljinski.OS1.prilazna_zona1", "SysSarani:bazna.cmd.ror.daljinski.OS1.bazna", "SysSarani:bazna.cmd.ror.daljinski.OS1.bazna_redukcija",
                                   "SysSarani:bazna.cmd.ror.daljinski.OS1/UPS.bazna", "SysSarani:bazna.cmd.ror.daljinski.OS1/UPS.bazna_redukcija",
                                   "SysSarani:bazna.cmd.ror.daljinski.B-1D.bazna", "SysSarani:bazna.cmd.ror.daljinski.B-1D.bazna_redukcija",
                                   "SysSarani:bazna.cmd.ror.daljinski.B-1D/UPS.bazna", "SysSarani:bazna.cmd.ror.daljinski.B-1D/UPS.bazna_redukcija");
  
  
   dpConnect("pratiPrelaznoStanjeL", "SysSarani:RO-A1-2L.cmd.ror.daljinski.100%", "SysSarani:RO-A1-2L.cmd.ror.daljinski.75%",
                                   "SysSarani:RO-A1-2L.cmd.ror.daljinski.50%", "SysSarani:RO-A1-2L.cmd.ror.daljinski.25%",
                                   "SysSarani:RO-A1-2L.cmd.ror.daljinski.12_5%", 
                                   "SysSarani:bazna.cmd.ror.daljinski.OS2.prilazna_zona2", "SysSarani:bazna.cmd.ror.daljinski.OS2.bazna", "SysSarani:bazna.cmd.ror.daljinski.OS2.bazna_redukcija",
                                   "SysSarani:bazna.cmd.ror.daljinski.OS2/UPS.bazna", "SysSarani:bazna.cmd.ror.daljinski.OS2/UPS.bazna_redukcija",
                                   "SysSarani:bazna.cmd.ror.daljinski.B-2L.bazna", "SysSarani:bazna.cmd.ror.daljinski.B-2L.bazna_redukcija",
                                   "SysSarani:bazna.cmd.ror.daljinski.B-2L/UPS.bazna", "SysSarani:bazna.cmd.ror.daljinski.B-2L/UPS.bazna_redukcija");
}

 
void pratiPrelaznoStanjeD (string dp1, bool a100, string dp2, bool a75, string dp3, bool a50, string dp4, bool a25, string dp5, bool a12,
                           string dp6, bool prilazna, string dp7, bool bazna, string dp8, bool redukcija, 
                           string dp10, bool bazna_ups, string dp11, bool redukcija_ups,
                           string dp12, bool bazna2, string dp13, bool redukcija2,
                           string dp14, bool bazna_ups2, string dp15, bool redukcija_ups2) {
  
  bool value100, value75, value50, value25, value12, automatika1, v_prilazna, v_bazna, v_redukcija, v_bazna_ups, v_redukcija_ups, v_bazna2, v_redukcija2, v_bazna_ups2, v_redukcija_ups2;
  
  dpGet("SysSarani:bazna.automatsko_upravljanje", automatika1); 
  
  if (automatika1) {
    dpSet("SysSarani:bazna.automatsko_upravljanje", automatika1); 
  }
  else {
    if (a100) {
      dpGet("SysSarani:RO-A1-1D.cmd.run.100%", value100);
      dpSet("SysSarani:RO-A1-1D.cmd.run.100%", value100);
    }
  
    if (a75) {
      dpGet("SysSarani:RO-A1-1D.cmd.run.75%", value75);
      dpSet("SysSarani:RO-A1-1D.cmd.run.75%", value75);
    }
  
    if (a50) {
      dpGet("SysSarani:RO-A1-1D.cmd.run.50%", value50);
      dpSet("SysSarani:RO-A1-1D.cmd.run.50%", value50);
    }
  
    if (a25) {
      dpGet("SysSarani:RO-A1-1D.cmd.run.25%", value25);
      dpSet("SysSarani:RO-A1-1D.cmd.run.25%", value25);
    }
  
    if (a12) {
      dpGet("SysSarani:RO-A1-1D.cmd.run.12_5%", value12);
      dpSet("SysSarani:RO-A1-1D.cmd.run.12_5%", value12);
    }
    
    if (prilazna) {
       dpGet("SysSarani:bazna.cmd.run.OS1.prilazna_zona1", v_prilazna); 
       dpSet("SysSarani:bazna.cmd.run.OS1.prilazna_zona1", v_prilazna); 
    }
    
    if (bazna) {
       dpGet("SysSarani:bazna.cmd.run.OS1.bazna", v_bazna); 
       dpSet("SysSarani:bazna.cmd.run.OS1.bazna", v_bazna); 
    }
    
    if (redukcija) {
       dpGet("SysSarani:bazna.cmd.run.OS1.bazna_redukcija", v_redukcija); 
       dpSet("SysSarani:bazna.cmd.run.OS1.bazna_redukcija", v_redukcija); 
    }
    
    
    if (bazna_ups) {
       dpGet("SysSarani:bazna.cmd.run.OS1/UPS.bazna", v_bazna_ups); 
       dpSet("SysSarani:bazna.cmd.run.OS1/UPS.bazna", v_bazna_ups); 
    }
    
    if (redukcija_ups) {
       dpGet("SysSarani:bazna.cmd.run.OS1/UPS.bazna_redukcija", v_redukcija_ups); 
       dpSet("SysSarani:bazna.cmd.run.OS1/UPS.bazna_redukcija", v_redukcija_ups); 
    }
    
    if (bazna2) {
       dpGet("SysSarani:bazna.cmd.run.B-1D.bazna", v_bazna2); 
       dpSet("SysSarani:bazna.cmd.run.B-1D.bazna", v_bazna2); 
    }
    
    if (redukcija2) {
       dpGet("SysSarani:bazna.cmd.run.B-1D.bazna_redukcija", v_redukcija2); 
       dpSet("SysSarani:bazna.cmd.run.B-1D.bazna_redukcija", v_redukcija2); 
    }
    
    if (bazna_ups2) {
       dpGet("SysSarani:bazna.cmd.run.B-1D/UPS.bazna", v_bazna_ups2); 
       dpSet("SysSarani:bazna.cmd.run.B-1D/UPS.bazna", v_bazna_ups2); 
    }
    
    if (redukcija_ups2) {
       dpGet("SysSarani:bazna.cmd.run.B-1D/UPS.bazna_redukcija", v_redukcija_ups2); 
       dpSet("SysSarani:bazna.cmd.run.B-1D/UPS.bazna_redukcija", v_redukcija_ups2); 
    }
  }
}



void pratiPrelaznoStanjeL (string dp1, bool a100, string dp2, bool a75, string dp3, bool a50, string dp4, bool a25, string dp5, bool a12,
                           string dp6, bool prilazna, string dp7, bool bazna, string dp8, bool redukcija, 
                           string dp10, bool bazna_ups, string dp11, bool redukcija_ups,
                           string dp12, bool bazna2, string dp13, bool redukcija2,
                           string dp14, bool bazna_ups2, string dp15, bool redukcija_ups2) {
  
  bool value100, value75, value50, value25, value12, automatika1, v_prilazna, v_bazna, v_redukcija, v_bazna_ups, v_redukcija_ups, v_bazna2, v_redukcija2, v_bazna_ups2, v_redukcija_ups2;
  
  dpGet("SysSarani:bazna.automatsko_upravljanje", automatika1);  
  if (automatika1) {
    dpSet("SysSarani:bazna.automatsko_upravljanje", automatika1);  
  }
  else {
    if (a100) {
      dpGet("SysSarani:RO-A1-2L.cmd.run.100%", value100);
      dpSet("SysSarani:RO-A1-2L.cmd.run.100%", value100);
    }
  
    if (a75) {
      dpGet("SysSarani:RO-A1-2L.cmd.run.75%", value75);
      dpSet("SysSarani:RO-A1-2L.cmd.run.75%", value75);
    }
  
    if (a50) {
      dpGet("SysSarani:RO-A1-2L.cmd.run.50%", value50);
      dpSet("SysSarani:RO-A1-2L.cmd.run.50%", value50);
    }
  
    if (a25) {
      dpGet("SysSarani:RO-A1-2L.cmd.run.25%", value25);
      dpSet("SysSarani:RO-A1-2L.cmd.run.25%", value25);
    }
  
    if (a12) {
      dpGet("SysSarani:RO-A1-2L.cmd.run.12_5%", value12);
      dpSet("SysSarani:RO-A1-2L.cmd.run.12_5%", value12);
    }
    
    if (prilazna) {
       dpGet("SysSarani:bazna.cmd.run.OS2.prilazna_zona2", v_prilazna); 
       dpSet("SysSarani:bazna.cmd.run.OS2.prilazna_zona2", v_prilazna); 
    }
    
    if (bazna) {
       dpGet("SysSarani:bazna.cmd.run.OS2.bazna", v_bazna); 
       dpSet("SysSarani:bazna.cmd.run.OS2.bazna", v_bazna); 
    }
    
    if (redukcija) {
       dpGet("SysSarani:bazna.cmd.run.OS2.bazna_redukcija", v_redukcija); 
       dpSet("SysSarani:bazna.cmd.run.OS2.bazna_redukcija", v_redukcija); 
    }
    
    if (bazna_ups) {
       dpGet("SysSarani:bazna.cmd.run.OS2.bazna", v_bazna_ups); 
       dpSet("SysSarani:bazna.cmd.run.OS2.bazna", v_bazna_ups); 
    }
    
    
    if (bazna2) {
       dpGet("SysSarani:bazna.cmd.run.B-2L.bazna", v_bazna2); 
       dpSet("SysSarani:bazna.cmd.run.B-2L.bazna", v_bazna2); 
    }
    
    if (redukcija2) {
       dpGet("SysSarani:bazna.cmd.run.B-2L.bazna_redukcija", v_redukcija2); 
       dpSet("SysSarani:bazna.cmd.run.B-2L.bazna_redukcija", v_redukcija2); 
    }
    
    if (bazna_ups2) {
       dpGet("SysSarani:bazna.cmd.run.B-2L/UPS.bazna", v_bazna_ups2); 
       dpSet("SysSarani:bazna.cmd.run.B-2L/UPS.bazna", v_bazna_ups2); 
    }
    
    if (redukcija_ups2) {
       dpGet("SysSarani:bazna.cmd.run.B-2L/UPS.bazna_redukcija", v_redukcija_ups2); 
       dpSet("SysSarani:bazna.cmd.run.B-2L/UPS.bazna_redukcija", v_redukcija_ups2); 
    }
  }
}

void postavljanjeAktivnogNivoaRasvjete() {
  dpConnect("podesiAktivniNivoAdaptivne", "SysSarani:RO-A1-1D.state.100%", "SysSarani:RO-A1-1D.state.75%", 
                            "SysSarani:RO-A1-1D.state.50%", "SysSarani:RO-A1-1D.state.25%",
                            "SysSarani:RO-A1-1D.state.12_5%", "SysSarani:RO-A1-2L.state.100%",
                            "SysSarani:RO-A1-2L.state.75%", "SysSarani:RO-A1-2L.state.50%",
                            "SysSarani:RO-A1-2L.state.25%", "SysSarani:RO-A1-2L.state.12_5%");
}

void desnaCijev() {
  dpConnect("pratiDesnuCijev", "SysSarani:fotometar_d.value", "SysSarani:bazna.automatsko_upravljanje", 
            "SysSarani:aktivni_algoritam.scenarij_rasvjete", "SysSarani:bazna.state.nocni_rezim");
}
 

void lijevaCijev() {
  dpConnect("pratiLijevuCijev", "SysSarani:fotometar_l.value", "SysSarani:bazna.automatsko_upravljanje",
            "SysSarani:aktivni_algoritam.scenarij_rasvjete", "SysSarani:bazna.state.nocni_rezim");
}

void pratiDesnuCijev(string dp, float nivo_osvjetljenja, string dp2, bool auto_upravljanje, 
                     string dp3, int scenarij, string dp4, bool nocniRezim) {
  
  if (nivo_osvjetljenja < 0 || nivo_osvjetljenja > 10000) {
              dpGet("SysSarani:fotometar_l.value", nivo_osvjetljenja);
            }        
  
  float aktivni_nivo;  
  dpGet("SysSarani:RO-A1-1D.value.aktivni_nivo", aktivni_nivo);  
  dyn_bool stara_stanja;
  nivo_osvjetljenja = nivo_osvjetljenja*1.5;
  if (dynlen(provjeriRezimJednogOrmaraAdaptivne("RO-A1-1D")) == 0) {
    switch(scenarij) {
      case 0:
      case 2:
        if (auto_upravljanje) {
          DebugFTN("level1", "Pokrenuto automatsko upravljanje adaptivnom nakon povratka u normalan scenarij");
          
            if (nivo_osvjetljenja <= 20/* && hour(getCurrentTime()) >= 14 && hour(getCurrentTime()) <= 23) || (nocniRezim)*/) {
                ukljuciPrilaznuOS1();
            }      
            else  {
                DebugFTN("level1", "Pozvana iskljuciPrilaznuOS1() nakon povratka u normalan scenarij");
                iskljuciPrilaznuOS1();
            }   
       
          
          DebugFTN("level1", "Pozvana je metoda pratiDesnuCijev sa parametrom: \nnivo_osvjetljenja: " + nivo_osvjetljenja); 
          
    
          if (nivo_osvjetljenja > 2700 && aktivni_nivo!=100)
            podesiAdaptivnu("desna", 100);
          else if (nivo_osvjetljenja <= 2700 && nivo_osvjetljenja > 1800 && aktivni_nivo!=75) 
            podesiAdaptivnu("desna", 75);
          else if (nivo_osvjetljenja <= 1800 && nivo_osvjetljenja > 900 && aktivni_nivo!=50) 
            podesiAdaptivnu("desna", 50);
          else if (nivo_osvjetljenja <= 900 && nivo_osvjetljenja > 450 && aktivni_nivo!=25)
            podesiAdaptivnu("desna", 25);
          else if (nivo_osvjetljenja <= 450 && nivo_osvjetljenja > 40 && aktivni_nivo!=12.5)
            podesiAdaptivnu("desna", 12.5);
          else if (nivo_osvjetljenja <= 40 && aktivni_nivo!=0) {
            podesiAdaptivnu("desna", 0);
          }
        }
        break;
      case 1:
      case 3:
        if (aktivni_nivo!=100)
          podesiAdaptivnu("desna", 100);
        ukljuciPrilaznuOS1();
      break;
    
    }  
  }
  else {
    dpSet("SysSarani:RO-A1-1D.state.greska_slanja_komande", 1);
    dpSetDelayed(15, "SysSarani:RO-A1-1D.state.greska_slanja_komande", 0);
  }
  
}

void kupiStatuseUKomande() {
  dyn_string nivoi_rasvjete = makeDynString("100%", "75%", "50%", "25%", "12_5%");
  
  while (1) {
    for (int i=1; i<=dynlen(nivoi_rasvjete); i++) {
      bool desna, lijeva;
      dpGet("SysSarani:RO-A1-1D.state." + nivoi_rasvjete[i], desna);
      dpSet("SysSarani:RO-A1-1D.cmd.run." + nivoi_rasvjete[i], desna);
      dpGet("SysSarani:RO-A1-2L.state." + nivoi_rasvjete[i], lijeva);
      dpSet("SysSarani:RO-A1-2L.cmd.run." + nivoi_rasvjete[i], lijeva);
    }
    delay(0, 400);
  }
}

void pratiLijevuCijev(string dp, float nivo_osvjetljenja, string dp2, bool auto_upravljanje, string dp3, int scenarij, string dp4, bool nocniRezim) {
  
  if (nivo_osvjetljenja < 0 || nivo_osvjetljenja > 10000) {
    dpGet("SysSarani:fotometar_d.value", nivo_osvjetljenja);
  }
  float aktivni_nivo;  
  dpGet("SysSarani:RO-A1-2L.value.aktivni_nivo", aktivni_nivo);  
  
  nivo_osvjetljenja = nivo_osvjetljenja*1.5;
  if (dynlen(provjeriRezimJednogOrmaraAdaptivne("RO-A1-2L")) == 0) {  
    
    switch(scenarij) {
      case 0:
      case 1:
        if(auto_upravljanje) {
          if (nivo_osvjetljenja <= 20/* &&  hour(getCurrentTime()) >= 14 && hour(getCurrentTime()) <= 23) || (nocniRezim)*/) {
              ukljuciPrilaznuOS2();
          }      
          else {
              iskljuciPrilaznuOS2();
          }            
   
          
          DebugFTN("level1", "Pozvana je metoda pratiLijevuCijev sa parametrom: \nnivo_osvjetljenja: " + nivo_osvjetljenja);   
          
          dyn_bool stara_stanja;   
  
          if (nivo_osvjetljenja > 2700 && aktivni_nivo!=100) 
            podesiAdaptivnu("lijeva", 100);
          else if (nivo_osvjetljenja <= 2700 && nivo_osvjetljenja > 1800 && aktivni_nivo!=75) 
            podesiAdaptivnu("lijeva", 75);
          else if (nivo_osvjetljenja <= 1800 && nivo_osvjetljenja > 900 && aktivni_nivo!=50) 
            podesiAdaptivnu("lijeva", 50);
          else if (nivo_osvjetljenja <= 900 && nivo_osvjetljenja > 450 && aktivni_nivo!=25)
            podesiAdaptivnu("lijeva", 25);
          else if (nivo_osvjetljenja <= 450 && nivo_osvjetljenja > 40 && aktivni_nivo!=12.5)
            podesiAdaptivnu("lijeva", 12.5);
          else if (nivo_osvjetljenja <= 40 && aktivni_nivo!=0) {
            podesiAdaptivnu("lijeva", 0);
          }
        }
        break;
      case 2:
      case 3:
        if (aktivni_nivo!=100)
          podesiAdaptivnu("lijeva", 100);
        ukljuciPrilaznuOS2();
      break;
    }
  }
  else {
    dpSet("SysSarani:RO-A1-2L.state.greska_slanja_komande", 1);
    dpSetDelayed(15, "SysSarani:RO-A1-2L.state.greska_slanja_komande", 0);
  }
}


void podesiAdaptivnu(string cijev, float nivo) {
  string ormar = (cijev=="desna") ? "RO-A1-1D" : "RO-A1-2L";
  
  if (!podesiNivoAdaptivne(cijev, nivo)) {
      vratiStaraStanja(ormar, uzmiStaraStanja(ormar));
      
      dpSet("SysSarani:" + ormar + ".state.greska_slanja_komande", 1);
      dpSetDelayed(15, "SysSarani:" + ormar + ".state.greska_slanja_komande", 0);
      
      DebugFTN("level1", "Bezuspjesno postavljanje novog statusa adaptivne rasvjete");
    }
  else
    DebugFTN("level1", "Završeno podesavanje adaptivne rasvjete u ovom krugu");
}

dyn_bool uzmiStaraStanja(string ormar) {
  bool status;
  dyn_string nivoi = makeDynString("100%", "75%", "50%", "25%", "12_5%");
  dyn_string stara_stanja;
  
  for (int i=1; i<=dynlen(nivoi); i++) {
    dpGet("SysSarani:" + ormar + ".state." + nivoi[i], status);
    dynAppend(stara_stanja, status);
  }
  
  return stara_stanja;
}


void vratiStaraStanja(string ormar, dyn_bool stara_stanja) {
  dyn_string nivoi = makeDynString("100%", "75%", "50%", "25%", "12_5%");
  
  for (int i=1; i<=dynlen(nivoi); i++) {
    dpSet("SysSarani:" + ormar + ".cmd.run." + nivoi[i], stara_stanja[i]);
  }
}


podesiAktivniNivoAdaptivne(string dp1, bool d100, string dp2, bool d75,
                           string dp3, bool d50, string dp4, bool d25,
                           string dp5, bool d12, string dp6, bool l100,
                           string dp7, bool l75, string dp8, bool l50,
                           string dp9, bool l25, string dp10, bool l12) {
  
  if (d12) {
    if (d25) {
      if (d50) {
        if (d75) {
          if (d100) {
            dpSet("SysSarani:RO-A1-1D.value.aktivni_nivo", 100);
          }
          else  {
            dpSet("SysSarani:RO-A1-1D.value.aktivni_nivo", 75);
          }
        }
        else {
          dpSet("SysSarani:RO-A1-1D.value.aktivni_nivo", 50);
        }
      }
      else {
        dpSet("SysSarani:RO-A1-1D.value.aktivni_nivo", 25);
      }
    }
    else {
      dpSet("SysSarani:RO-A1-1D.value.aktivni_nivo", 12.5);
    }
  }
  else {
    dpSet("SysSarani:RO-A1-1D.value.aktivni_nivo", 0);
  }
  
  
  if (l12) {
    if (l25) {
      if (l50) {
        if (l75) {
          if (l100) {
            dpSet("SysSarani:RO-A1-2L.value.aktivni_nivo", 100);
          }
          else  {
            dpSet("SysSarani:RO-A1-2L.value.aktivni_nivo", 75);
          }
        }
        else {
          dpSet("SysSarani:RO-A1-2L.value.aktivni_nivo", 50);
        }
      }
      else {
        dpSet("SysSarani:RO-A1-2L.value.aktivni_nivo", 25);
      }
    }
    else {
      dpSet("SysSarani:RO-A1-2L.value.aktivni_nivo", 12.5);
    }
  }
  else {
    dpSet("SysSarani:RO-A1-2L.value.aktivni_nivo", 0);
  }
}
