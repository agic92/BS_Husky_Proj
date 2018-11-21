#uses "mapiranjeBrojevaScenarija.ctl"
#uses "mapiranje_scenarija.ctl"
#uses "rcp.ctc"

main() {
  addGlobal("sys_name", STRING_VAR);
  sys_name = "SysSarani:";
  
  
  dpConnect("signalizacija", false, "SysSarani:aktivni_algoritam.scenarij_signalizacije");
  
  dpConnect("ups1", "SysSarani:UPS_PS1.on_battery", "SysSarani:AgregatPS1.state.GeneratingSetStabilised");
  dpConnect("ups2", "SysSarani:UPS_PS2.on_battery", "SysSarani:AgregatPS2.state.GeneratingSetStabilised");
  
  dpConnect("upravljanjeOzvucenjem", "SysSarani:aktivni_algoritam.scenarij_ozvucenja");
  
    dpQueryConnectSingle("pozar1", true, "Identi", 
                        "SELECT '_original.._value' FROM '*.Status.Fire' WHERE _DPT = \"fire_detector\"");  

     dpQueryConnectSingle("pozar1", true, "Identi", 
                       "SELECT '_original.._value' FROM '*.state.Fire' WHERE _DPT = \"Linijski_javljaci\"");      
}




pozar1(anytype ident, dyn_dyn_anytype list) {
  //DebugTN("Uradjen dpConnect");
  startThread("alarmSaPozarnihDetektora", ident, list);
}

string pokretac;

alarmSaPozarnihDetektora (anytype ident, dyn_dyn_anytype list) {
  int aktivni_algoritam;
   /*Ako je već pokrenut neki od požarnih algoritama, ignorišu se novi alarmi. */
  dpGet("SysSarani:aktivni_algoritam.pokrenuti_algoritam", aktivni_algoritam);
  
  if (aktivni_algoritam >= 1 && aktivni_algoritam <=17) {
    DebugTN("Vec pokrenut jedan pozarni algoritam, nista se ne radi...");
    return;
  }
  
  

  string dpe;
  dyn_int value;
  
  
  /*Prvo se traži alarm sa ručnog javljača, jer on ima prioritet*/
  for(int i = 2; i <= dynlen(list); i++)  //starta sa 2 zato sto liste pocinju od 1, a sql upit vraca u prvoj liniji header pa treba i njega preskociti
  {    
    //DebugTN("Alarm sa rucnog javljaca...");
    value = list[i][2];
    dpe = list[i][1];
    string dpe2 = dpSubStr(dpe, DPSUB_DP);  //DPSUB_DP -
    int nivoAutomatike;
    dpGet(sys_name + dpe2 + ".nivoAutomatike", nivoAutomatike);
    
    //alarm sa rucnog javljaca
    if(nivoAutomatike == 1) { 
      int zona;
      bool alarm;
      dpGet(sys_name + dpe2 + ".Status.Fire", alarm);
      
      if (alarm) {
        
        //ako je odbrojavanje zapocelo prije alarma, automatski se pokrece pozarni scenarij, 
        //ali za zonu javljaca koji je zapoceo odbrojavanje, a ne za zonu rucnog javljaca koji je javio alarm
        
        bool postoji_raniji_alarm, izvidjanje;
        dpGet("SysSarani:aktivni_algoritam.automatski_javljac_parametri.provjera_prisustva_start", postoji_raniji_alarm);
        dpGet("SysSarani:aktivni_algoritam.automatski_javljac_parametri.izvidjanje", izvidjanje);
        
        if (postoji_raniji_alarm || izvidjanje) {
          dpGet("SysSarani:aktivni_algoritam.automatski_javljac_parametri.zona_pod_alarmom", zona); 
        }
        //ako nema aktivnog odbrojavanja, pokrece se algoritam za zonu rucnog javljaca koji je javio alarm
        else {
          dpGet(sys_name + dpe2 + ".zona", zona);
        }

        //*****************************************************************************************************
        DebugTN("AKTIVIAN ALARM: dpe: " + dpe + ", alarm: " + alarm);
        DebugTN("Pokretanje algoritma...");
        pokretac = dpe2;
        pokreniPozarniAlgoritam(zona);
        dpSet("SysSarani:aktivni_algoritam.rucni_javljac_parametri.automatski_start", 1);
        dpSet("SysSarani:aktivni_algoritam.rucni_javljac_parametri.zabranjen_prekid_algoritma", 1);
        return;
      }    
    }
  }
  /*Ako je ručni javljač pokrenuo algoritam, nema potrebe provjeravati ostale alarme, jer ručni ima prednost*/
  dpGet("SysSarani:aktivni_algoritam.pokrenuti_algoritam", aktivni_algoritam);
  
  if (aktivni_algoritam >= 1 && aktivni_algoritam <=17) {
    DebugTN("Vec pokrenut jedan pozarni algoritam, nista se ne radi...");
    return;
  }
  
  /*Provjera alarma sa automatskih i linijskih javljača*/
  for(int i = 2; i <= dynlen(list); i++)  //starta sa 2 zato sto liste pocinju od 1, a sql upit vraca u prvoj liniji header pa treba i njega preskociti
  {    
    //DebugTN("Alarm sa automatskog ili linijskog javljaca...");
    value = list[i][2];
    dpe = list[i][1];
    string dpe2 = dpSubStr(dpe, DPSUB_DP);  //DPSUB_DP -
    int nivoAutomatike;
    dpGet(sys_name + dpe2 + ".nivoAutomatike", nivoAutomatike);
    //alarm sa automatskog javljaca
    if(nivoAutomatike == 2) {
      int zona;
      dpGet(sys_name + dpe2 + ".zona", zona);
      
      bool alarm;
      dpGet(sys_name + dpe2 + ".Status.Fire", alarm);

      if (alarm) {
        //Ako je već započet proces ispitivanja prisustva i potvrde alarma, novi alarm se ne analizira
        bool postoji_raniji_alarm, izvidjanje;
        dpGet("SysSarani:aktivni_algoritam.automatski_javljac_parametri.provjera_prisustva_start", postoji_raniji_alarm);
        dpGet("SysSarani:aktivni_algoritam.automatski_javljac_parametri.izvidjanje", izvidjanje);
        if (!postoji_raniji_alarm && !izvidjanje) {
          DebugTN("AKTIVIRAN ALARM: dpe: " + dpe + ", alarm: " + alarm);
          DebugTN("Pokretanje procedure za aktivaciju algoritma...");
          pokreniProceduruZaAutomatskiJavljac(zona, dpe2);
        }
        break;
      }    
    }
    
    //alarm sa linijskog javljaca
    else if(nivoAutomatike == 3) {
      
      int zona;
      dpGet(sys_name + dpe2 + ".zona", zona);
      
      bool alarm;
      dpGet(sys_name + dpe2 + ".state.Fire", alarm);

      if (alarm) {
        
        bool postoji_raniji_alarm, izvidjanje;
        dpGet("SysSarani:aktivni_algoritam.automatski_javljac_parametri.provjera_prisustva_start", postoji_raniji_alarm);
        dpGet("SysSarani:aktivni_algoritam.automatski_javljac_parametri.izvidjanje", izvidjanje);
        if (!postoji_raniji_alarm && !izvidjanje) {
          DebugTN("AKTIVIRAN ALARM: dpe: " + dpe + ", alarm: " + alarm);
          DebugTN("Pokretanje procedure za aktivaciju algoritma...");
          pokreniProceduruZaAutomatskiJavljac(zona, dpe2);
        }
        break;
      }    
    } 
  } 
}

pokreniProceduruZaAutomatskiJavljac(int zona, string dpe2) {
   resetParametara();
   dpSet("SysSarani:aktivni_algoritam.automatski_javljac_parametri.provjera_prisustva_start", 1); 
   dpSet("SysSarani:aktivni_algoritam.automatski_javljac_parametri.zona_pod_alarmom", zona);  
    int aktivni_algoritam;
   int timer1 = 30;
   bool potvrda_prisustva;
   while(timer1>=0) {
     //ako se u medjuvremenu pokrene neki požarni algoritam, prekini sve.
     dpGet("SysSarani:aktivni_algoritam.pokrenuti_algoritam", aktivni_algoritam);
     if (aktivni_algoritam >=  1 && aktivni_algoritam <= 17) {
       resetParametara();
       return;
     }
      dpGet("SysSarani:aktivni_algoritam.automatski_javljac_parametri.potvrdjeno_prisustvo", potvrda_prisustva);
      dpSet("SysSarani:aktivni_algoritam.automatski_javljac_parametri.timer1", timer1);
      
      //sve dok se ne potvrdi prisustvo, prvi timer odbrojava
      if (!potvrda_prisustva) {
        timer1--;
        delay(1);
      }
      
      //Kada se potvrdi prisustvo, kreće period izvidjanja i drugi timer pocinje odbrojavati
      else {
        zapocniPeriodIzvidjanja(zona, dpe2);
        break;
      }
   } 
   //ako nakon isteka prvog timera nije potvrdjeno prisustvo, automatski se pokrece algoritam
   if (!potvrda_prisustva) {
    dpSet("SysSarani:aktivni_algoritam.automatski_javljac_parametri.automatski_start", 1);
    pokretac = dpe2;
    pokreniPozarniAlgoritam(zona); 
    resetParametara();
   }                                          
}

zapocniPeriodIzvidjanja(int zona, string dpe2) {
  dpSet("SysSarani:aktivni_algoritam.automatski_javljac_parametri.izvidjanje", 1);
  int timer2 = 1200;
  int aktivni_algoritam;
  bool lazni_alarm, hitno;
  
  //sve dok traje period izvidjanja, timer 2 odbrojava
  while(timer2>=0) {
    
    //ako se potvrdi da je alarm stvaran, klikom se pokreće algoritam bez cekanja da istekne timer 2
    dpGet("SysSarani:aktivni_algoritam.automatski_javljac_parametri.hitno_pokretanje", hitno);
    if(hitno) {
      pokretac = dpe2;
      pokreniPozarniAlgoritam(zona); 
      resetParametara();
      return;
    }
    dpGet("SysSarani:aktivni_algoritam.automatski_javljac_parametri.lazni_alarm", lazni_alarm);
    dpSet("SysSarani:aktivni_algoritam.automatski_javljac_parametri.timer2", timer2);
    DebugTN("Lazni alarm: " + lazni_alarm);
    
    dpGet("SysSarani:aktivni_algoritam.pokrenuti_algoritam", aktivni_algoritam);
    
     if (aktivni_algoritam >=  1 && aktivni_algoritam <= 17) {
       resetParametara();
       return;
     }
    if (!lazni_alarm) {
      timer2--;
      delay(1);
    }
    
    //ako se alarm označi kao lažni, timer 2 prestaje odbrojavati i prekida se procedura izvidjanja
    else {
      resetParametara();
      return;
    } 
  }
  dpGet("SysSarani:aktivni_algoritam.pokrenuti_algoritam", aktivni_algoritam);
     if (aktivni_algoritam >=  1 && aktivni_algoritam <= 17) {
       resetParametara();
       return;
     }
  //ako korisnik nije nista kliknuo,a timer 2 je istekao, automatski se pokrece algoritam
  if (!lazni_alarm) {
    pokretac = dpe2;
    pokreniPozarniAlgoritam(zona); 
    dpSet("SysSarani:aktivni_algoritam.automatski_javljac_parametri.automatski_start", 1);
    resetParametara();
  }
}



resetParametara() {
  dpSet("SysSarani:aktivni_algoritam.automatski_javljac_parametri.provjera_prisustva_start", 0); 
  dpSet("SysSarani:aktivni_algoritam.automatski_javljac_parametri.potvrdjeno_prisustvo", 0); 
  dpSet("SysSarani:aktivni_algoritam.automatski_javljac_parametri.timer1", 30);
  dpSet("SysSarani:aktivni_algoritam.automatski_javljac_parametri.timer2", 1200);
  dpSet("SysSarani:aktivni_algoritam.automatski_javljac_parametri.lazni_alarm", 0);
  dpSet("SysSarani:aktivni_algoritam.automatski_javljac_parametri.hitno_pokretanje", 0);
  dpSet("SysSarani:aktivni_algoritam.automatski_javljac_parametri.izvidjanje", 0);
  dpSet("SysSarani:aktivni_algoritam.automatski_javljac_parametri.zona_pod_alarmom", 0);  
}

ups1 (string dp1, bool ups1_on_battery, string dp2, bool pokrenut_agregat1) {
  
  int sekunde1;
  while (ups1_on_battery && !pokrenut_agregat1) {
    sekunde1 += 1;
    dpSet("SysSarani:UPS_PS1.timer", sekunde1);
    delay(1);
    dpGet("SysSarani:AgregatPS1.state.GeneratingSetStabilised", pokrenut_agregat1,
          "SysSarani:UPS_PS1.on_battery", ups1_on_battery);
  }
  dpSet("SysSarani:UPS_PS1.timer", 0);
}

ups2 (string dp1, bool ups2_on_battery, string dp2, bool pokrenut_agregat2) {
  
  int sekunde2;
  while (ups2_on_battery && !pokrenut_agregat2) {
    sekunde2 += 1;
    dpSet("SysSarani:UPS_PS2.timer", sekunde2);
    delay(1);
    dpGet("SysSarani:AgregatPS2.state.GeneratingSetStabilised", pokrenut_agregat2,
          "SysSarani:UPS_PS2.on_battery", ups2_on_battery);
  }
  dpSet("SysSarani:UPS_PS2.timer", 0);
}

pokreniPozarniAlgoritam(int zona) {
  //dpGet("SysSarani:aktivni_algoritam.pokrenuti_algoritam", broj_scenarija);
  dpSet("SysSarani:bazna.automatsko_upravljanje", 1);  
  
  dpSet("SysSarani:ventilacija_desna_cijev.state.automatsko_upravljanje", 1);
  dpSet("SysSarani:ventilacija_lijeva_cijev.state.automatsko_upravljanje", 1);
    
    
    
  string query = "SELECT '_original.._value' FROM '*.cmd.sdv.manuelno.rezim' WHERE _DPT = \"VENTILATOR\"";
  dyn_dyn_anytype list;
  dpQuery(query, list);
  
  string sys_name = "SysSarani:";
  string value, dpe;
    
  for(int i = 2; i <= dynlen(list); i++) 
  {    
    value = list[i][2];
    dpe = list[i][1];
    dpe = dpSubStr(dpe, DPSUB_DP);  
    dpSet(sys_name + dpe + ".cmd.sdv.manuelno.rezim", 0);
  }
    
  dyn_string naziviScenarija = getNaziviScenarija(makeDynInt(zona));
  bool pozar_sa_kolonom = 1;
  
  int broj_scenarija = zona;
  string naziv_scenarija = naziviScenarija[1];
  
  int broj_vatrodojavne_zone = zona;                    
  int broj_algoritma_rasvjete = getAlgoritamRasvjete(broj_scenarija);   
  
  dpSet("SysSarani:aktivni_algoritam.pozar_sa_kolonom_ispred", pozar_sa_kolonom);
  dpSet("SysSarani:aktivni_algoritam.pokrenuti_algoritam", broj_scenarija);
  dpSet("SysSarani:aktivni_algoritam.vatrodojavna_zona_alarma", broj_vatrodojavne_zone);
  dpSet("SysSarani:aktivni_algoritam.predlozeni_algoritmi", makeDynInt(broj_vatrodojavne_zone));
  dpSet("SysSarani:aktivni_algoritam.scenarij_signalizacije", broj_scenarija);
  dpSet("SysSarani:aktivni_algoritam.naziv_pokrenutog_algoritma", naziv_scenarija);  
  dpSet("SysSarani:aktivni_algoritam.scenarij_rasvjete", broj_algoritma_rasvjete);
  dpSet("SysSarani:aktivni_algoritam.naziv_pokrenutog_saobracajnog_scenarija", naziv_scenarija);  
  dpSet("SysSarani:aktivni_algoritam.pokretac_algoritma", pokretac);  
  dpSet("SysSarani:aktivni_algoritam.scenarij_ozvucenja", broj_vatrodojavne_zone); 

  dpSet("SysSarani:CLC.incidentni_rezim.zagusenje", 1);
  dpSet("SysSarani:CLC.incidentni_rezim.normalno", 0);

  
  DebugTN("Setovani su sljedeci parametri: ");
  DebugTN("pozar_sa_kolonom_ispred: " + pozar_sa_kolonom + 
            "\npokrenuti_algoritam: " + broj_scenarija + 
            "\nvatrodojavna_zona_alarma: " + broj_vatrodojavne_zone + 
            "\nscenarij_signalizacije: " + broj_scenarija +
            "\nnaziv_pokrenutog_algoritma: " + naziv_scenarija + 
            "\nscenarij_rasvjete: " + broj_algoritma_rasvjete + 
            "\nincidentni_rezim.zagusenje: 1" + 
            "\nincidentni_rezim.normalno: 0");
  
  
  podesiStanjeNaVentilatoru(broj_vatrodojavne_zone);
  
}

void podesiStanjeNaVentilatoru(int zona) {
  if (zona == 9)
    zona = 8;
  dyn_string svi_ventilatori = makeDynString("V01_1-1D", "V02_2-1D", "V03_3-1D", "V04_4-1D", "V05_4-2D", "V06_3-2D", "V07_2-2D", "V08_1-2D", "V08_1-2D",
                                             "V22_1-2L", "V21_2-2L", "V20_3-2L", "V19_4-2L", "V18_4-1L", "V17_3-1L", "V16_2-1L", "V15_1-1L");
  
  for (int i=1; i<=dynlen(svi_ventilatori); i++) {
    if (i == zona) {
      DebugTN("Ventilator na kojem je aktiviran alarm.pozarna_zona_aktivna: " + svi_ventilatori[i]);
      dpSet("SysSarani:" + svi_ventilatori[i] + ".alarm.pozarna_zona_aktivna", 1);
    }
    else {
      dpSet("SysSarani:" + svi_ventilatori[i] + ".alarm.pozarna_zona_aktivna", 0);
    }
  }  
  
}


signalizacija (string dp, int scenarij_signalizacije)
{
  dyn_string naziv_scenarija = getNaziviScenarija(makeDynInt(scenarij_signalizacije));
  
  DebugFTN("level1", "signalizacija - naziv_scenarija: " + naziv_scenarija);
  
  string scenarij = mapiranjeScenarijaReverse(naziv_scenarija[1]);
  DebugFTN("level1", "signalizacija - scenarij: " + scenarij);
  
  string datapoint;
  dyn_string recipes;  
  dpGet("SysSarani:CeliTunel.recipes", recipes);
  
  for(int i=1; i<=dynlen(recipes); i++){
   if(strpos(recipes[i], scenarij, 0) >= 0){  
         datapoint = recipes[i];
        DebugFTN("level1", "signalizacija - datapoint: " + datapoint);         
   } 
  }    
  activateRecipe("CeliTunel", datapoint);
  
  if (scenarij_signalizacije >= 1 && scenarij_signalizacije <= 17) {
    
    dpSet("SysSavinac:aktivni_algoritam.meteouslovi.automatsko_upravljanje", 0);
    dpSet("SysBrdjani:aktivni_algoritam.meteouslovi.automatsko_upravljanje", 0);
    
    dpSet("SysBrdjani:aktivni_algoritam.pokrenuti_algoritam", 34); //kolona lijeva cijev, ogranicenje 60
    dpSet("SysSavinac:aktivni_algoritam.pokrenuti_algoritam", 32); //kolona lijeva cijev, ogranicenje 60
    dpSet("SysSavinac:VMS1-OA2.command.izbor_znaka", makeDynInt(44)); //kolona, ogranicenje 80
    dpSet("SysBrdjani:VMS1-OA1.command.izbor_znaka", makeDynInt(44)); //kolona, ogranicenje 80
  }
  
}



void activateRecipe(string rct, string rcp) { 

  // This activates a selected recipe, in case of validity.
  string  lastUseOfType,lastActUser,lastUsage,err,validRecipe,validType;
  dyn_float	 df;
  dyn_string ds,elementValues,elements;
  

  if (rct == ""){
    string sMessageText=getCatStr("Recipe","rct_select");
    //ChildPanelOnCentralReturn("vision/MessageInfo1",getCatStr("general","information"),makeDynString(sMessageText),df,ds);
    return;
  }
  
  if (rcp == ""){
    string sMessageText=getCatStr("Recipe","rcp_select");
    //ChildPanelOnCentralReturn("vision/MessageInfo1",getCatStr("general","information"),makeDynString(sMessageText),df,ds);
    return;
  }
  /*
  if (!getUserPermission(4)){
    string sMessageText=getCatStr("STD_Symbols","Text20");
    ChildPanelOnCentralReturn("vision/MessageWarning",getCatStr("general","warning"),makeDynString(sMessageText),df,ds);
    return;
  }
  */
  
  dpGet(rct +".elements:_online.._value",		 elements,
  		rct +".valid:_online.._value",			 validType,
  		rcp +".elementValues:_online.._value",	 elementValues,
  		rcp +".valid:_online.._value",		 	 validRecipe);
 
  if (validType == "FALSE"){
     err = "-1";
  }
  if(validRecipe == "FALSE"){
     err = "-2";
  }  
  if (dynlen(elements) != dynlen(elementValues)){
    err = "-3";
  } 
  
 /* 
  // Check if the selected rct is still valid.
  // If it is not- set all values to empty.
  if (!dpExists(rct)){
    string 		sMessageText=getCatStr("Recipe","recipeType_not_exists");
  	 int 		i; 
  	 dyn_string 	ds,ds_rcpName;
  
    dpGet(rct+".recipes:_online.._value", ds_rcpName);
    setValue("cmbRcp","items", ds_rcpName);
    ds=dpNames("*","_Rct");
    for(i=1;i<=dynlen(ds);i++){
      ds[i]=dpSubStr(ds[i],DPSUB_DP_EL);
    }
    cmbRct.items = ds;
    
    //ovo bi trebalo izbaciti    
    setMultiValue("cmbRct","text",			"",
    			  "cmbRcp","text",			"",
    			  "txtLastUseOfType","text","",
  				   "txtLastUsage","text",	"",
  				   "txtUser","text",			"",
  				   "elpRcp","backCol",		"_3DFace",
  				   "txtRcp","text",			"",
  				   "txtUserAct","text",		"");	
	   ChildPanelOnCentralReturn("vision/MessageWarning",getCatStr("general","warning"),makeDynString(sMessageText),df,ds);
      return;
  }  
  */
  
  // Check if the selected rcp is still valid
  if (!dpExists(rcp))
  {
    string sMessageText=getCatStr("Recipe","recipe_not_exists");
    dyn_string ds_rcpName;
  
    dpGet(rct + ".recipes:_online.._value",	ds_rcpName);
    
    /*
     setValue("cmbRcp","items", ds_rcpName);
   
    setMultiValue("cmbRcp","text",			"",
  				   "elpRcp","backCol",		"_3DFace",
  				   "txtRcp","text",			"",
  				   "txtUserAct","text",		"");	
    */
    
	   //ChildPanelOnCentralReturn("vision/MessageWarning",getCatStr("general","warning"),makeDynString(sMessageText),df,ds);
      return;
  }
  
  // Open progress bar, activate the recipe and check possible errors.
  //if (err == "") openProgressBar("Rezepte","",getCatStr("Recipe","rcp_activation1")+"\""+ rcp +"\""+getCatStr("Recipe","rcp_activation2"), "", "", 1);
  
  //Ovdje aktivira scenarij
  rcp_activateRecipe(rcp,rct,err);

  if (err == -1){
    string sMessageText=getCatStr("Recipe","rct_error_act");
//     closeProgressBar();
//     ChildPanelOnCentralReturn("vision/MessageWarning",getCatStr("general","warning"),makeDynString(sMessageText),df,ds);
    return;
  } 
  if (err == -2){
    string sMessageText=getCatStr("Recipe","rcp_error_act");
//     closeProgressBar();
//     ChildPanelOnCentralReturn("vision/MessageWarning",getCatStr("general","warning"),makeDynString(sMessageText),df,ds);
    return;
  }
  if (err == -3){
    string sMessageText=getCatStr("Recipe","rcp_number_rct");
//     closeProgressBar();
//     ChildPanelOnCentralReturn("vision/MessageWarning",getCatStr("general","warning"),makeDynString(sMessageText),df,ds);
    return;
  }
  if (err == -5){
    string sMessageText=getCatStr("va","action.fileSwitch.progress_1");
//     closeProgressBar();
//     ChildPanelOnCentralReturn("vision/MessageWarning",getCatStr("general","warning"),makeDynString(sMessageText),df,ds);
    return;
  }
  if (err == -6){
    string sMessageText=getCatStr("sim","no_sims_to_delete");
//     closeProgressBar();
//     ChildPanelOnCentralReturn("vision/MessageWarning",getCatStr("general","warning"),makeDynString(sMessageText),df,ds);
    return;
  }
 
  // Case OK: Set all fields with the new values
  if (err == 0 || err == "")
  {
    string sMessageText=getCatStr("Recipe","rcp_activated");
//     closeProgressBar();
//     ChildPanelOnCentralReturn("vision/MessageInfo1",getCatStr("general","information"),makeDynString(latinToCyrillic("Scenarij pokrenut")),df,ds);
    /*
    dpGet(rct+".lastActivatedOfThisType:_online.._value",	lastUseOfType,
  		  rct+".lastActivated:_online.._value",				lastUsage,
  		  rct+".lastActivatedUser:_online.._value",			lastActUser);

    if (lastUsage == "1970.01.01 01:00:00.000")lastUsage = "";
    
    setMultiValue("txtLastUseOfType","text",lastUseOfType,
  				  "txtLastUsage","text",	lastUsage,
  				  "txtUser","text",			lastActUser);
    return;
    */
  }
}

upravljanjeOzvucenjem (string dp, int scenarij_ozvucenja) {
  string zone, cijev, call, poz_stanica;
  
  if (scenarij_ozvucenja >=1 && scenarij_ozvucenja <=17) {
    dyn_string mapirane_zone = getAlgoritamOzvucenja (scenarij_ozvucenja);
    
    cijev = (scenarij_ozvucenja >=1 && scenarij_ozvucenja <=9) ? "desna" : "lijeva";
    call = (scenarij_ozvucenja >=1 && scenarij_ozvucenja <=9) ? "Call_0" : "Call_8";
    poz_stanica = (scenarij_ozvucenja >=1 && scenarij_ozvucenja <=9) ? "PozSt 1_AI1" : "PozSt 2_AI1";
    for (int i=1; i<= dynlen(mapirane_zone)-1; i++) {
      zone += mapirane_zone[i] + ",";
    }
    zone += mapirane_zone[dynlen(mapirane_zone)];
    
    posaljiKomanduNaOPC(zone, "", "Da", 1, cijev, call, poz_stanica);
  }
}




posaljiKomanduNaOPC(string zona, string poruke, string govor2, string ponavljanja, string cijev, string call, string poz_stanica) {
  
  string speech = (govor2=="Da") ? "1" : "0";
  
  string s = "<nsPV:Command Name=\"Start\" Description=\"Starts a call\" Adresse=\"" + call + "\" xmlns:nsPV=\"file:///S3K/Proxyverwalter\" OPCServerKlasse=\"BoschPraesideoProxy30\" " + "Anzeigename=\"Start\">" + 
               "<nsPV:Parameters>" + 
                 "<nsPV:Parameter Name=\"Routing\" ValueType=\"string\" Description=\"Routing\" Anzeigename=\"Routing\">" + zona + "</nsPV:Parameter>" + 
                 "<nsPV:Parameter Name=\"Priority\" ValueType=\"long\" Description=\"Priority\" Anzeigename=\"Priority\">" + 220 + "</nsPV:Parameter>" + 
                 "<nsPV:Parameter Name=\"Partial\" ValueType=\"bool\" Description=\"Partial:1, not Partial:0\" Anzeigename=\"Partial\"></nsPV:Parameter>" + 
                 "<nsPV:Parameter Name=\"StartChime\" ValueType=\"string\" Description=\"Start chime\" Anzeigename=\"StartChime\">1-tone chime</nsPV:Parameter>" + 
                 "<nsPV:Parameter Name=\"EndChime\" ValueType=\"string\" Description=\"End chime\" Anzeigename=\"EndChime\">1-tone chime</nsPV:Parameter>" + 
                 "<nsPV:Parameter Name=\"LiveSpeech\" ValueType=\"bool\" Description=\"LiveSpeech:1, not LiveSpeech:0\" Anzeigename=\"LiveSpeech\">" + speech +"</nsPV:Parameter>" + 
                 "<nsPV:Parameter Name=\"AudioInput\" ValueType=\"string\" Description=\"Audio input source of Praesideo system\" Anzeigename=\"AudioInput\">" + poz_stanica + "</nsPV:Parameter>" + 
                 "<nsPV:Parameter Name=\"Messages\" ValueType=\"string\" Description=\"Messages\" Anzeigename=\"Messages\">" + poruke + "</nsPV:Parameter>" + 
                 "<nsPV:Parameter Name=\"Repeat\" ValueType=\"long\" Description=\"Repeat\" Anzeigename=\"Repeat\">" + ponavljanja + "</nsPV:Parameter>" + 
               "</nsPV:Parameters>" + 
             "</nsPV:Command>";
  
  
  dpSet("SysSarani:ozvucenje_" + cijev + "_cijev.cmd", s);
  
  dpSet("SysSarani:ozvucenje_" + cijev + "_cijev.odabrana_zona", zona);
  
  bool status_govor = (govor2=="Da") ? 1 : 0;
  
  dpSet("SysSarani:ozvucenje_" + cijev + "_cijev.govor", status_govor);
}


