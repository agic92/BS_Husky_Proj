#uses "rasvjeta_komande.ctl"
main() {
    dpConnect("upravljanjeRedukcijom", "SysSarani:bazna.state.blokirana_redukcija", "SysSarani:RO-A1-1D.value.aktivni_nivo", "SysSarani:bazna.state.nocni_rezim");
    dpConnect("upravljanjeBaznomRasvjetom", "SysSarani:bazna.state.OS1.bazna", "SysSarani:bazna.state.OS2.bazna", 
                                            "SysSarani:bazna.state.B-1D.bazna", "SysSarani:bazna.state.B-2L.bazna");
}


upravljanjeRedukcijom(string dp1, bool blokiranaRedukcija, string dp2, float aktivniNivo, string dp3, bool nocniRezim) {
  dyn_string dp = makeDynString("OS1", "OS1/UPS", "B-1D", "B-1D/UPS", "OS2", "OS2/UPS", "B-2L", "B-2L/UPS");
  
  if (!blokiranaRedukcija) { //Provjera da li je uklopni sat u rezimu 17h-22h
    if (nocniRezim || aktivniNivo<=12.5) {//Ako je uklopni sat u nocnom rezimu, ili ako fotometar javlja slabu svjetlost(
                                          //(adaptivna <= 12.5%), pali se redukcija
      for (int i=1; i<=dynlen(dp); i++) {
        ukljuciRedukciju(dp[i]);
      }
    }
    else {
      for (int i=1; i<=dynlen(dp); i++) {
        iskljuciRedukciju(dp[i]);
      }
    }
  }
  else { //u periodu 17h-22h redukcija je uvijek ugasena
    for (int i=1; i<=dynlen(dp); i++) {
      iskljuciRedukciju(dp[i]);
    }
  }
}
//U slucaju da je neka rasvjeta ugasena, potrebno ju je opet upalitit, posto je bazna uvijek upaljena
upravljanjeBaznomRasvjetom(string dp1, bool os1, string dp2, bool os2, string dp3, bool b1d, string dp4, bool b2l) {
  bool rasvjeta_bila_ugasena = false; //parametar koji ce sluziti za blokiranje paljenja redukcije 10min nakon paljenja bazne
  if(!os1) {
    bool os1_status;
    ukljuciBaznuOS1();
    dpGet("SysSarani:bazna.state.OS1.bazna", os1_status);
    if (!os1_status) { //Ako se status ne promijeni nakon slanja komande, izbacuje se obavijest o tome
      greskaKomandaNijePrimljena("OS1");
    }
    else //U suprotnom, biljezi se da je rasvjeta upaljenja nakon sto je bila ugasena
      rasvjeta_bila_ugasena=true;
  }
  if(!os2) {
    bool os2_status;
    ukljuciBaznuOS2();
    dpGet("SysSarani:bazna.state.OS2.bazna", os2_status);
    if (!os2_status) {
      greskaKomandaNijePrimljena("OS2");
    }
    else
      rasvjeta_bila_ugasena=true;
  }
  if(!b1d) {
    bool b1d_status;
    ukljuciBaznuB1D();
    dpGet("SysSarani:bazna.state.B-1D.bazna", b1d_status);
    if (!b1d_status) {
      greskaKomandaNijePrimljena("B-1D");
    }
    else
      rasvjeta_bila_ugasena=true;
  }
  if(!b2l) {
    bool b2l_status;
    ukljuciBaznuB2L();
    dpGet("SysSarani:bazna.state.B-2L.bazna", b2l_status);
    if (!b2l_status) {
      greskaKomandaNijePrimljena("B-2L");
    }
    else 
      rasvjeta_bila_ugasena=true;
  }
  
  if(rasvjeta_bila_ugasena) {
    bool staro_stanje; //sluzi kako bi se parametar blokirana_redukcija vratio u zateknuto stanje nakon sto istekne 10min od paljenja bazne
    dpGet("SysSarani:bazna.state.blokirana_redukcija", staro_stanje);
    dpSet("SysSarani:bazna.state.blokirana_redukcija", 1); //redukcija se blokira
    dpSetDelayed(600, "SysSarani:bazna.state.blokirana_redukcija", staro_stanje);//nakon 10 min(600s) parametar blokirana_redukcija se vraca u zateknuto stanje
  }
}
