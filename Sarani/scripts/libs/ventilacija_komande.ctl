
#uses "dp_set_delay.ctl"

dyn_string ventilatori_desna_cijev = makeDynString("V08_1-2D", "V07_2-2D", "V06_3-2D", "V05_4-2D", "V04_4-1D", "V03_3-1D", "V02_2-1D", "V01_1-1D");
dyn_string ventilatori_lijeva_cijev = makeDynString("V15_1-1L", "V16_2-1L", "V17_3-1L", "V18_4-1L", "V19_4-2L", "V20_3-2L", "V21_2-2L","V22_1-2L");

/*----------------------------------------------------*
 *          POKRETANJE VENTILATORA NAPRIJED           *
 *--------------------------------------------------- */

bool pokreniVentilatorNaprijed (string ventilator) {
  bool kvar, servis, status_naprijed;
  dpGet("SysSarani:" + ventilator + ".alarm.kvar", kvar);
  dpGet("SysSarani:" + ventilator + ".alarm.servis", servis);
  
  if (kvar || servis) {
    return false;
  }
  
  dpSet("SysSarani:" + ventilator + ".cmd.run.naprijed_motor", 1);
  delay(1);
  dpGet("SysSarani:" + ventilator + ".state.naprijed", status_naprijed);
  
  if (!status_naprijed) {
    dpSet("SysSarani:" + ventilator + ".cmd.run.naprijed_motor", 0); //vrati komandu na stanje u kojem je bila
    dpSet("SysSarani:" + ventilator + ".state.greska_komande_naprijed", 1); //u alarmnoj tabeli ce se pojaviti alarm koji ce trajati pola minute
    dpSetDelayed(30, "SysSarani:" + ventilator + ".state.greska_komande_naprijed", 0); 
    return false;
  }

  return true;
}

/*-------------------------------------------------------*
 *          ZAUSTAVLJANJE VENTILATORA NAPRIJED           *
 *-------------------------------------------------------*/

bool zaustaviVentilatorNaprijed (string ventilator) {
  bool kvar, servis, status_naprijed;
  dpGet("SysSarani:" + ventilator + ".alarm.kvar", kvar);
  dpGet("SysSarani:" + ventilator + ".alarm.servis", servis);
  
  if (kvar || servis) {
    return false;
  }
  
  dpSet("SysSarani:" + ventilator + ".cmd.run.naprijed_motor", 0);
  delay(1);
  dpGet("SysSarani:" + ventilator + ".state.naprijed", status_naprijed);
  
  if (status_naprijed) {
    dpSet("SysSarani:" + ventilator + ".cmd.run.naprijed_motor", 1);
    dpSet("SysSarani:" + ventilator + ".state.greska_komande_naprijed", 1); //u alarmnoj tabeli ce se pojaviti alarm koji ce trajati pola minute
    dpSetDelayed(30, "SysSarani:" + ventilator + ".state.greska_komande_naprijed", 0); 
    return false;
  }
 
  postaviZabranuPokretanja(ventilator);
  
  return true;
}

/*----------------------------------------------------*
 *          POKRETANJE VENTILATORA NAZAD              *
 *--------------------------------------------------- */

bool pokreniVentilatorNazad (string ventilator) {
  bool kvar, servis, status_nazad;
  dpGet("SysSarani:" + ventilator + ".alarm.kvar", kvar);
  dpGet("SysSarani:" + ventilator + ".alarm.servis", servis);
  
  if (kvar || servis) {
    return false;
  }
  
  dpSet("SysSarani:" + ventilator + ".cmd.run.nazad_motor", 1);
  delay(1);
  dpGet("SysSarani:" + ventilator + ".state.nazad", status_nazad);
  
  if (!status_nazad) {
    dpSet("SysSarani:" + ventilator + ".cmd.run.nazad_motor", 0);
    dpSet("SysSarani:" + ventilator + ".state.greska_komande_nazad", 1); //u alarmnoj tabeli ce se pojaviti alarm koji ce trajati pola minute
    dpSetDelayed(30, "SysSarani:" + ventilator + ".state.greska_komande_nazad", 0); 
    return false;
  }
  
  return true;
}

/*-------------------------------------------------------*
 *          ZAUSTAVLJANJE VENTILATORA NAZAD              *
 *------------------------------------------------------ */

bool zaustaviVentilatorNazad (string ventilator) {
  bool kvar, servis, status_nazad;
  dpGet("SysSarani:" + ventilator + ".alarm.kvar", kvar);
  dpGet("SysSarani:" + ventilator + ".alarm.servis", servis);
  
  if (kvar || servis) {
    return false;
  }
  
  dpSet("SysSarani:" + ventilator + ".cmd.run.nazad_motor", 0);
  delay(1);
  dpGet("SysSarani:" + ventilator + ".state.nazad", status_nazad);
  
  if (status_nazad) {
    dpSet("SysSarani:" + ventilator + ".cmd.run.nazad_motor", 1);
    dpSet("SysSarani:" + ventilator + ".state.greska_komande_nazad", 1); //u alarmnoj tabeli ce se pojaviti alarm koji ce trajati pola minute
    dpSetDelayed(30, "SysSarani:" + ventilator + ".state.greska_komande_nazad", 0); 
    return false;
  }
  
  postaviZabranuPokretanja(ventilator);
  return true;
}

/*-------------------------------------------------------------------------------*
 *  POSTAVLJANJE ZABRANE POKRETANJA VENTILATORA 120 SEKUNDI OD NJEGOVOG GAŠENJA  *
 *-------------------------------------------------------------------------------*/

void postaviZabranuPokretanja(string ventilator) {
  dpSet("SysSarani:" + ventilator + ".state.zabrana_pokretanja_ventilatora",1);
  dpSetDelayed(120, "SysSarani:" + ventilator + ".state.zabrana_pokretanja_ventilatora",0);
}

/*---------------------------------------------------------------*
 *  PROVJERA DA LI JE PROŠLO 120 SEKUNDI OD GAŠENJA VENTILATORA  *
 *---------------------------------------------------------------*/

bool provjeriDozvoluPaljenja(string ventilator) {
  bool zabrana;
  dpGet("SysSarani:" + ventilator + ".state.zabrana_pokretanja_ventilatora", zabrana);
  
  if(zabrana)
    return false;
  
  return true;
}

/*------------------------------------------------------------------*
 *          POKRETANJE SCENARIJA NA OSNOVU BROJA SCENARIJA          *
 *------------------------------------------------------------------*/

bool pokreniScenarij (int vatrodojavnaZona) {
  
  if (vatrodojavnaZona == 9)
    vatrodojavnaZona = 8;  
  
  int pauza = 5; //vrijeme izmedju paljenja 2 uzastopna ventilatora
  string cijev = mapirajScenarijNaCijev(vatrodojavnaZona);  
  
  dyn_string ventilatori = (cijev=="desna") ? ventilatori_desna_cijev : ventilatori_lijeva_cijev;
  
  for (int i=1; i<=dynlen(ventilatori); i++) {    
        
    if (i!=vatrodojavnaZona) {
      pokreniVentilatorNaprijed(ventilatori[i]);
      delay(pauza);
      DebugTN("Pokrece se ventilator " + ventilatori[i]);
    }
  }
  DebugTN("Svi ventilatori pokrenuti");
  
}

/*------------------------------------------------------------------*
 *          POKRETANJE SCENARIJA SA KOLONOM ISPRED POŽARA           *
 *------------------------------------------------------------------*/

bool pokreniScenarijSaKolonomIspred (int vatrodojavnaZona) {
  
  if (vatrodojavnaZona == 9)
    vatrodojavnaZona = 8;  
  
  string cijev = mapirajScenarijNaCijev(vatrodojavnaZona);  
  
  dyn_string ventilator = (cijev=="desna") ? "V01_1-1D" : "V15_1-1L";
  
  if (vatrodojavnaZona != 0 && vatrodojavnaZona != 17) {
    pokreniVentilatorNaprijed(ventilator);
    delay(pauza);
    DebugTN("Pokrece se ventilator " + ventilator);
  }
  
}

/*----------------------------------------------------*
 *          MAPIRANJE SCENARIJA SA CIJEVIMA           *
 *--------------------------------------------------- */
string mapirajScenarijNaCijev(int vatrodojavnaZona) {
  
  if (vatrodojavnaZona >= 1 && vatrodojavnaZona <=9)
    return "desna";
  else if (vatrodojavnaZona >= 10 && vatrodojavnaZona <= 17) 
    return "lijeva";
  else
    return "nepoznat scenarij";
}

/*------------------------------------------------------------------------*
 *          IZBACIVANJE OBAVIJESTI O USPJEŠNOSTI SLANJA KOMANDE           *
 *------------------------------------------------------------------------*/
string izbaciObavijest (int kod) {
  
  string obavijest;
  switch(kod) {
    case 0:
      obavijest = "INFO\nStatus ventilatora uspešno promenjen"; //Kada se status uspjesno promijeni nakon slanja komande
      break;
    case 1:
      obavijest = "GREŠKA\nStatus ventilatora nije promenjen"; //kad se posalje komande, ali se status ne promijeni
      break;
    case 2:
      obavijest = "GREŠKA\nNije dozvoljeno paljenje ventilatora. \nPeriod od 2 minute od gašenja ventilatora nije istekao.";
      break;
    case 3:
      obavijest = "GREŠKA\nVentilator je već pokrenut u suprotnom smeru.";
      break;
  }
  dyn_float df;
  dyn_string ds;

  ChildPanelOnReturn("VENTILACIJA/info.pnl", latinToCyrillic("Obavest"), makeDynString(latinToCyrillic("$OBAVIJEST:" + obavijest)), 300, 200, df,ds);
    
}

/*---------------------------------------------------------------------------------------------*
 *          POKRETANJE VENTILATORA ZA PRVU GRANICNU VRIJEDNOST CO i SENZORA VIDLJIVOSTI        *
 *                        ((50ppm <= CO < 75 ppm) || vidljivost > 0.009 m^-1)                  *
 *---------------------------------------------------------------------------------------------*/

pokreniCetiriVentilatoraDesnaCijev() {
  int broj_neuspjelih_pokretanja;
  for (int i=1; i<=4; i++) {
    if (!pokreniVentilatorNaprijed(ventilatori_desna_cijev[i]))
      broj_neuspjelih_pokretanja++;
    delay(5);
  }
  
  if (broj_neuspjelih_pokretanja>0) {
    dpSet("SysSarani:ventilacija_desna_cijev.greske.greskaPokretanjaCetiriVentilatora" , 1);
    dpSetDelayed(30, "SysSarani:ventilacija_desna_cijev.greske.greskaPokretanjaCetiriVentilatora" , 0);
  }
  else {
    dpSet("SysSarani:ventilacija_desna_cijev.state.pokrenutaCetiriVentilatora", 1);
    dpSet("SysSarani:ventilacija_desna_cijev.state.pokrenutoSestVentilatora", 0);
    dpSet("SysSarani:ventilacija_desna_cijev.state.pokrenutiSviVentilatori", 0);
  }
}
/*---------------------------------------------------------------------------------------------*/

pokreniCetiriVentilatoraLijevaCijev() {
  int broj_neuspjelih_pokretanja;
  for (int i=1; i<=4; i++) {
    if (!pokreniVentilatorNaprijed(ventilatori_lijeva_cijev[i]))
      broj_neuspjelih_pokretanja++;
    delay(5);
  }
  
  if (broj_neuspjelih_pokretanja>0) {
    dpSet("SysSarani:ventilacija_lijeva_cijev.greske.greskaPokretanjaCetiriVentilatora" , 1);
    dpSetDelayed(30, "SysSarani:ventilacija_lijeva_cijev.greske.greskaPokretanjaCetiriVentilatora" , 0);
  }
  else {
    dpSet("SysSarani:ventilacija_lijeva_cijev.state.pokrenutaCetiriVentilatora", 1);
    dpSet("SysSarani:ventilacija_lijeva_cijev.state.pokrenutoSestVentilatora", 0);
    dpSet("SysSarani:ventilacija_lijeva_cijev.state.pokrenutiSviVentilatori", 0);
  }
}
/*---------------------------------------------------------------------------------------------*
 *          POKRETANJE VENTILATORA ZA DRUGU GRANICNU VRIJEDNOST CO i SENZORA VIDLJIVOSTI       *
 *                                    (75ppm <= CO < 100 ppm)                                  *
 *---------------------------------------------------------------------------------------------*/

pokreniSestVentilatoraDesnaCijev() {
  int broj_neuspjelih_pokretanja;
  for (int i=1; i<=6; i++) {
    if (!pokreniVentilatorNaprijed(ventilatori_desna_cijev[i]))
      broj_neuspjelih_pokretanja++;
    delay(5);
  }
  
  if (broj_neuspjelih_pokretanja>0) {
    dpSet("SysSarani:ventilacija_desna_cijev.greske.greskaPokretanjaSestVentilatora" , 1);
    dpSetDelayed(30, "SysSarani:ventilacija_desna_cijev.greske.greskaPokretanjaSestVentilatora" , 0);
  }
  else {
    dpSet("SysSarani:ventilacija_desna_cijev.state.pokrenutaCetiriVentilatora", 0);
    dpSet("SysSarani:ventilacija_desna_cijev.state.pokrenutoSestVentilatora", 1);
    dpSet("SysSarani:ventilacija_desna_cijev.state.pokrenutiSviVentilatori", 0);
  }
}
/*---------------------------------------------------------------------------------------------*/
pokreniSestVentilatoraLijevaCijev() {
  int broj_neuspjelih_pokretanja;
  for (int i=1; i<=6; i++) {
    if (!pokreniVentilatorNaprijed(ventilatori_lijeva_cijev[i]))
      broj_neuspjelih_pokretanja++;
    delay(5);
  }
  
  if (broj_neuspjelih_pokretanja>0) {
    dpSet("SysSarani:ventilacija_lijeva_cijev.greske.greskaPokretanjaSestVentilatora" , 1);
    dpSetDelayed(30, "SysSarani:ventilacija_lijeva_cijev.greske.greskaPokretanjaSestVentilatora" , 0);
  }
  else {
    dpSet("SysSarani:ventilacija_lijeva_cijev.state.pokrenutaCetiriVentilatora", 0);
    dpSet("SysSarani:ventilacija_lijeva_cijev.state.pokrenutoSestVentilatora", 1);
    dpSet("SysSarani:ventilacija_lijeva_cijev.state.pokrenutiSviVentilatori", 0);
  }
}
/*---------------------------------------------------------------------------------------------*
 *          POKRETANJE VENTILATORA ZA TREĆU GRANICNU VRIJEDNOST CO i SENZORA VIDLJIVOSTI       *
 *                                    (CO >= 100 ppm)                                          *
 *---------------------------------------------------------------------------------------------*/

pokreniSveVentilatoreDesnaCijev() {
  int broj_neuspjelih_pokretanja;
  for (int i=1; i<=8; i++) {
    if (!pokreniVentilatorNaprijed(ventilatori_desna_cijev[i]))
      broj_neuspjelih_pokretanja++;
    delay(5);
  }
  
  if (broj_neuspjelih_pokretanja>0) {
    dpSet("SysSarani:ventilacija_desna_cijev.greske.greskaPokretanjaSvihVentilatora" , 1);
    dpSetDelayed(30, "SysSarani:ventilacija_desna_cijev.greske.greskaPokretanjaSvihVentilatora" , 0);
  }
  else {
    dpSet("SysSarani:ventilacija_desna_cijev.state.pokrenutaCetiriVentilatora", 0);
    dpSet("SysSarani:ventilacija_desna_cijev.state.pokrenutoSestVentilatora", 0);
    dpSet("SysSarani:ventilacija_desna_cijev.state.pokrenutiSviVentilatori", 1);
  }
}
/*---------------------------------------------------------------------------------------------*/

pokreniSveVentilatoreLijevaCijev() {
  int broj_neuspjelih_pokretanja;
  for (int i=1; i<=8; i++) {
    if (!pokreniVentilatorNaprijed(ventilatori_lijeva_cijev[i]))
      broj_neuspjelih_pokretanja++;
    delay(5);
  }
  
  if (broj_neuspjelih_pokretanja>0) {
    dpSet("SysSarani:ventilacija_lijeva_cijev.greske.greskaPokretanjaSvihVentilatora" , 1);
    dpSetDelayed(30, "SysSarani:ventilacija_lijeva_cijev.greske.greskaPokretanjaSvihVentilatora" , 0);
  }
  else {
    dpSet("SysSarani:ventilacija_lijeva_cijev.state.pokrenutaCetiriVentilatora", 0);
    dpSet("SysSarani:ventilacija_lijeva_cijev.state.pokrenutoSestVentilatora", 0);
    dpSet("SysSarani:ventilacija_lijeva_cijev.state.pokrenutiSviVentilatori", 1);
  }
}

/*---------------------------------------------------------------------------------------------*
 *          ZAUSTAVLJANJE VENTILATORA ZA DONJU GRANICNU VRIJEDNOST CO i SENZORA VIDLJIVOSTI       *
 *                                    (CO < 35 ppm && vidljivost < 0.006 m^-1)                                          *
 *---------------------------------------------------------------------------------------------*/

zaustaviSveVentilatoreDesnaCijev() {
  int broj_neuspjelih_zaustavljanja;
  for (int i=8; i>=1; i--) {
    if (!zaustaviVentilatorNaprijed(ventilatori_desna_cijev[i]))
      broj_neuspjelih_pokretanja++;
    delay(5); //provjeriti hoce li se koristiti i ova pauza izmedju gasenja pojedinih ventilatora
  }
  
  if (broj_neuspjelih_pokretanja>0) {
    dpSet("SysSarani:ventilacija_desna_cijev.greske.greskaZaustavljanjaSvihVentilatora" , 1);
    dpSetDelayed(30, "SysSarani:ventilacija_desna_cijev.greske.greskaZaustavljanjaSvihVentilatora" , 0);
  }
  else {
    dpSet("SysSarani:ventilacija_desna_cijev.state.pokrenutaCetiriVentilatora", 0);
    dpSet("SysSarani:ventilacija_desna_cijev.state.pokrenutoSestVentilatora", 0);
    dpSet("SysSarani:ventilacija_desna_cijev.state.pokrenutiSviVentilatori", 0);
  }
}
/*---------------------------------------------------------------------------------------------*/

zaustaviSveVentilatoreLijevaCijev() {
  int broj_neuspjelih_zaustavljanja;
  for (int i=8; i>=1; i--) {
    if (!zaustaviVentilatorNaprijed(ventilatori_lijeva_cijev[i]))
      broj_neuspjelih_pokretanja++;
    delay(5); //provjeriti hoce li se koristiti i ova pauza izmedju gasenja pojedinih ventilatora
  }
  
  if (broj_neuspjelih_pokretanja>0) {
    dpSet("SysSarani:ventilacija_lijeva_cijev.greske.greskaZaustavljanjaSvihVentilatora" , 1);
    dpSetDelayed(30, "SysSarani:ventilacija_lijeva_cijev.greske.greskaZaustavljanjaSvihVentilatora" , 0);
  }
  else {
    dpSet("SysSarani:ventilacija_lijeva_cijev.state.pokrenutaCetiriVentilatora", 0);
    dpSet("SysSarani:ventilacija_lijeva_cijev.state.pokrenutoSestVentilatora", 0);
    dpSet("SysSarani:ventilacija_lijeva_cijev.state.pokrenutiSviVentilatori", 0);
  }
}
