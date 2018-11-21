#uses "rasvjeta_komande.ctl"
#uses "dp_set_delay.ctl"

main() {
    dpConnect("upravljanjeRedukcijom", "SysSarani:bazna.automatsko_upravljanje", "SysSarani:bazna.state.blokirana_redukcija", 
                                       "SysSarani:RO-A1-1D.value.aktivni_nivo", "SysSarani:bazna.state.nocni_rezim", 
                                       "SysSarani:bazna.state.blokirana_redukcija_10min", "SysSarani:aktivni_algoritam.scenarij_rasvjete");
    
    dpConnect("upravljanjeBaznomRasvjetom", "SysSarani:bazna.state.OS1.bazna", "SysSarani:bazna.state.OS2.bazna", 
                                            "SysSarani:bazna.state.OS1/UPS.bazna", "SysSarani:bazna.state.OS2/UPS.bazna", 
                                            "SysSarani:bazna.state.B-1D.bazna", "SysSarani:bazna.state.B-2L.bazna",
                                            "SysSarani:bazna.state.B-1D/UPS.bazna", "SysSarani:bazna.state.B-2L/UPS.bazna",
                                            "SysSarani:bazna.automatsko_upravljanje", "SysSarani:aktivni_algoritam.scenarij_rasvjete");
}


upravljanjeRedukcijom(string d1, bool auto_upravljanje, string dp2, bool blokiranaRedukcija, string dp3, float aktivniNivo, 
                      string dp4, bool nocniRezim, string dp5, bool blokirana_redukcija_10min, string dp6, int scenarij) {
  
  DebugFTN("level1", "Pozvana je metoda upravljanjeRedukcijom sa parametrima: \nautomatsko_upravljanje: " + auto_upravljanje
          + "\nblokiranaRedukcija: " + blokiranaRedukcija
          + "\naktivniNivo: " + aktivniNivo
          + "\nnocniRezim: " + nocniRezim
          + "\nScenarij: " + scenarij);
  switch (scenarij) {
    
    case 0:
      DebugFTN("level1", "Case 0");
      if (auto_upravljanje) { 
        dyn_string dp = makeDynString("OS1", "OS1/UPS", "B-1D", "B-1D/UPS", "OS2", "OS2/UPS", "B-2L", "B-2L/UPS");
        bool bazna, prigusenje;
        
        if (!blokiranaRedukcija && !blokirana_redukcija_10min) { //Provjera da li je uklopni sat u rezimu 17h-22h ili je rasvjeta tek upaljena
          if (nocniRezim) {//Ako je uklopni sat u nocnom rezimu, ili ako fotometar javlja slabu svjetlost(
                                                //(adaptivna <= 12.5%), pali se redukcija
            for (int i=1; i<=dynlen(dp); i++) {
              dpGet("SysSarani:bazna.state." + dp[i] + ".bazna", bazna);
              dpGet("SysSarani:bazna.state." + dp[i] + ".bazna_redukcija", prigusenje);
              if (!(bazna && prigusenje))
                podesiNivoBazne(dp[i], 2); //bazna sa prigusenjem
            }
          }
          else {
            for (int i=1; i<=dynlen(dp); i++) {
              dpGet("SysSarani:bazna.state." + dp[i] + ".bazna", bazna);
              dpGet("SysSarani:bazna.state." + dp[i] + ".bazna_redukcija", prigusenje);
              if (!(bazna && !prigusenje))
                podesiNivoBazne(dp[i], 1); //bazna bez prigusenja
            }
          }
        }
        else { //u periodu 17h-22h redukcija je uvijek ugasena
          for (int i=1; i<=dynlen(dp); i++) {
            dpGet("SysSarani:bazna.state." + dp[i] + ".bazna", bazna);
            dpGet("SysSarani:bazna.state." + dp[i] + ".bazna_redukcija", prigusenje);
            if (!(bazna && !prigusenje))
              podesiNivoBazne(dp[i], 1); //bazna bez prigusenja
          }
        }
      }
      break;
      
    case 1: 
      DebugFTN("level1", "Case 1");
      ukljuciSvuDesnu();
      break;
    case 2:
      DebugFTN("level1", "Case 2");
      ukljuciSvuLijevu();
      break;
    case 3:
      DebugFTN("level1", "Case 3");
      ukljuciSvuRasvjetu();
      break;
  }
  
}
//U slucaju da je neka rasvjeta ugasena, potrebno ju je opet upaliti, posto bazna uvijek treba biti upaljena
upravljanjeBaznomRasvjetom(string dp1, bool os1, string dp2, bool os2, string dp3, bool os1_ups, string dp4, bool os2_ups,
                           string dp5, bool b1d, string dp6, bool b2l, string dp7, bool b1d_ups, string dp8, bool b2l_ups, 
                           string dp9, bool auto_upravljanje, string dp10, int scenarij) {
  if (auto_upravljanje) {
    DebugFTN("level1", "Pozvana je metoda upravljanjeBaznomRasvjetom sa parametrima: \nos1: " + os1
            + "\nos1_ups" + os1_ups
            + "\nos2: " + os2
            + "\nos2_ups" + os2_ups
            + "\nb1d: " + b1d
            + "\nb1d_ups: " + b1d_ups
            + "\nb2l: " + b2l
            + "\nb2l_ups: " + b2l_ups);  
  
  
    bool broj_ormara_sa_ugasenom_rasvjetom; //parametar koji ce sluziti za blokiranje paljenja redukcije 10min nakon paljenja bazne
  
    if(!os1) {
      if(!podesiBaznu("OS1")) 
          broj_ormara_sa_ugasenom_rasvjetom++;
    }
    
    if(!os1_ups){
      if(!podesiBaznu("OS1/UPS")) 
          broj_ormara_sa_ugasenom_rasvjetom++;
    }
    
    if(!os2) {
      if(!podesiBaznu("OS2")) 
          broj_ormara_sa_ugasenom_rasvjetom++;
    }
    
    if(!os2_ups) {
      if(!podesiBaznu("OS2/UPS")) 
          broj_ormara_sa_ugasenom_rasvjetom++;
    }
    
    if(!b1d) {
      if(!podesiBaznu("B1D")) 
          broj_ormara_sa_ugasenom_rasvjetom++;
    }
    
    if(!b1d_ups) {
      if(!podesiBaznu("B1D/UPS")) 
          broj_ormara_sa_ugasenom_rasvjetom++;
    }
      
    if(!b2l) {
      if(!podesiBaznu("B2L")) 
          broj_ormara_sa_ugasenom_rasvjetom++;
    }
    
    if(!b2l_ups) {
      if(!podesiBaznu("B2L/UPS")) 
          broj_ormara_sa_ugasenom_rasvjetom++;
    }
  
  
    if(broj_ormara_sa_ugasenom_rasvjetom > 0) {
    
      dpSet("SysSarani:bazna.state.blokirana_redukcija_10min", 1); //redukcija se blokira
      dpSetDelayed(600, "SysSarani:bazna.state.blokirana_redukcija_10min", 0);//nakon 10 min(600s) redukcija se odblokira
    }
  }
}

bool podesiBaznu(string ormar) {
  bool status;
    podesiNivoBazne(ormar, 1);  //nivoi: 0-iskljucena bazna, 1-uklj. bazna bez prigusenja, 2-uklj.bazna sa prigusenjem
    dpGet("SysSarani:bazna.state." + ormar + ".bazna", status);
    
    if (!status) {  //Ako se status ne promijeni nakon slanja komande, izbacuje se obavijest o tome u alarmnoj tabeli
      dpSet("SysSarani:bazna.state." + ormar + ".greska_slanja_komande", 1);
      dpSetDelayed(15, "SysSarani:bazna.state." + ormar + ".greska_slanja_komande", 0);  
      logujBezuspjesnoPaljenjeBazneRasvjete(ormar, 1);
      return false;
    }
    else { //U suprotnom, biljezi se da je rasvjeta upaljena nakon sto je bila ugasena
      logujUspjesnoPaljenjeBazneRasvjete(ormar, 1);
      return true;
    }
}
