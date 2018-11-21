#uses "ventilacija_komande.ctl"

main() {
  dpConnect("pratiSenzore", "SysSarani:ventilacija_desna_cijev.state.upravljanje_sa_ormara", 
                            "SysSarani:ventilacija_desna_cijev.state.upravljanje_sa_csnu",
                            "SysSarani:ventilacija_lijeva_cijev.state.upravljanje_sa_ormara", 
                            "SysSarani:ventilacija_lijeva_cijev.state.upravljanje_sa_csnu",
                            "SysSarani:ventilacija_desna_cijev.state.automatsko_upravljanje"); //dovoljno, posto ne moze jedna cijev biti
                                                                                               //na automatici, a druga na rucnom
}
/*----------------------------------------------------------------------------------------------*/
void pratiSenzore(string dp1, bool desna_sa_ormara, string dp2, bool desna_sa_csnu,
                  string dp3, bool lijeva_sa_ormara, string dp4, bool lijeva_sa_csnu,
                  string dp5, bool automatsko_upravljanje) {
  
  if (desna_sa_csnu && lijeva_sa_csnu && automatsko_upravljanje) {
    dpConnect("automatikaVentilatoraLijevaCijev", "SysSarani:CO03-SOS-L1.value.mjerenje", "SysSarani:CO04-SOS-L7.value.mjerenje",
                                               "SysSarani:VAZ11-SOS-L1.value.mjerenje", "SysSarani:VAZ12-SOS-L7.value.mjerenje");
    
    dpConnect("automatikaVentilatoraDesnaCijev", "SysSarani:CO01-SOS-D1.value.mjerenje", "SysSarani:CO02-SOS-D7.value.mjerenje",
                                               "SysSarani:VAZ09-SOS-D1.value.mjerenje", "SysSarani:VAZ10-SOS-D7.value.mjerenje");
  }
  else {
    dpSet("SysSarani:ventilacija_desna_cijev.state.pokrenutaCetiriVentilatora", 0);
    dpSet("SysSarani:ventilacija_desna_cijev.state.pokrenutoSestVentilatora", 0);
    dpSet("SysSarani:ventilacija_desna_cijev.state.pokrenutiSviVentilatori", 0);
  }
}
/*----------------------------------------------------------------------------------------------*/
automatikaVentilatoraDesnaCijev(string dp1, float nivo1_CO, string dp2, float nivo2_CO, 
                                string dp3, float vidljivost1, string dp4, float vidljivost2) {
  
  bool pokrenutaCetiriVentilatora, pokrenutoSestVentilatora, pokrenutiSviVentilatori;
  
  dpSet("SysSarani:ventilacija_desna_cijev.state.pokrenutaCetiriVentilatora", pokrenutaCetiriVentilatora);
  dpSet("SysSarani:ventilacija_desna_cijev.state.pokrenutoSestVentilatora", pokrenutoSestVentilatora);
  dpSet("SysSarani:ventilacija_desna_cijev.state.pokrenutiSviVentilatori", pokrenutiSviVentilatori);  
  
  if (nivo1_CO >= 100 || nivo2_CO >= 100) {
    pokreniSveVentilatoreDesnaCijev();
  }
  
  else if (((nivo1_CO >= 75 && nivo1_CO < 100) || (nivo2_CO >= 75 && nivo2_CO < 100)) && !pokrenutiSviVentilatori && !pokrenutoSestVentilatora) {
    pokreniSestVentilatoraDesnaCijev();
  }
  
  else if (((nivo1_CO >= 50 && nivo1_CO < 75) || (nivo2_CO >= 50 && nivo2_CO < 75) 
           || vidljivost1 >= 0.009 || vidljivost2 >= 0.009) && !pokrenutiSviVentilatori && !pokrenutoSestVentilatora && !pokrenutaCetiriVentilatora)  {
    pokreniCetiriVentilatoraDesnaCijev();
  }
  
  else if (nivo1_CO < 35 && nivo2_CO < 35 && vidljivost1 < 0.006 && vidljivost2 < 0.006) {
    zaustaviSveVentilatoreDesnaCijev();
  }
}
/*----------------------------------------------------------------------------------------------*/
automatikaVentilatoraLijevaCijev(string dp1, float nivo1_CO, string dp2, float nivo2_CO, 
                                string dp3, float vidljivost1, string dp4, float vidljivost2) {
  
  bool pokrenutaCetiriVentilatora, pokrenutoSestVentilatora, pokrenutiSviVentilatori;
  
  dpSet("SysSarani:ventilacija_desna_cijev.state.pokrenutaCetiriVentilatora", pokrenutaCetiriVentilatora);
  dpSet("SysSarani:ventilacija_desna_cijev.state.pokrenutoSestVentilatora", pokrenutoSestVentilatora);
  dpSet("SysSarani:ventilacija_desna_cijev.state.pokrenutiSviVentilatori", pokrenutiSviVentilatori);    
  
  if (nivo1_CO >= 100 || nivo2_CO >= 100) {
    pokreniSveVentilatoreLijevaCijev();
  }
  
  else if (((nivo1_CO >= 75 && nivo1_CO < 100) || (nivo2_CO >= 75 && nivo2_CO < 100)) && !pokrenutiSviVentilatori && !pokrenutoSestVentilatora) {
    pokreniSestVentilatoraLijevaCijev();
  }
  
  else if (((nivo1_CO >= 50 && nivo1_CO < 75) || (nivo2_CO >= 50 && nivo2_CO < 75) 
           || vidljivost1 >= 0.009 || vidljivost2 >= 0.009) && !pokrenutiSviVentilatori && !pokrenutoSestVentilatora && !pokrenutaCetiriVentilatora)  {
    pokreniCetiriVentilatoraLijevaCijev();
  }
  
  else if (nivo1_CO < 35 && nivo2_CO < 35 && vidljivost1 < 0.006 && vidljivost2 < 0.006) {
    zaustaviSveVentilatoreLijevaCijev();
  }
}
