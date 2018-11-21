main()
{
  
  dpQueryConnectSingle("work", true, "Identi", 
                       "SELECT '_original.._value' FROM '*.cmd.run.*motor' WHERE _DPT = \"VENTILATOR\"");
}

work (anytype ident, dyn_dyn_anytype list) {
  string dpe;
  dyn_int value;
  string s;
  for(int i = 2; i <= dynlen(list); i++)  //starta sa 2 zato sto liste pocinju od 1, a sql upit vraca u prvoj liniji header pa treba i njega preskociti
  {    
    value = list[i][2];
    dpe = list[i][1];
    dpe = dpSubStr(dpe, DPSUB_DP);
    if (value[1]==1) {
      float co1, co2, vid1, vid2, brz1, brz2;
      bool za_postavljanje = false; 
      
      if (substr(dpe,strlen(dpe)-1) == "D") {
       dpGet("SysSarani:CO01-SOS-D1.value.mjerenje", co1);
       dpGet("SysSarani:CO02-SOS-D7.value.mjerenje", co2);
       
       dpGet("SysSarani:VID05-SOS-D1.value.mjerenje", vid1);
       dpGet("SysSarani:VID06-SOS-D7.value.mjerenje", vid2);
       
       dpGet("SysSarani:VAZ09-SOS-D1.value.mjerenje", brz1);
       dpGet("SysSarani:VAZ10-SOS-D7.value.mjerenje", brz2);
       
       za_postavljanje = true;
      } 
      else if (substr(dpe,strlen(dpe)-1) == "L") {
       dpGet("SysSarani:CO03-SOS-L1.value.mjerenje", co1);
       dpGet("SysSarani:CO04-SOS-L7.value.mjerenje", co2);
       
       dpGet("SysSarani:VID07-SOS-L1.value.mjerenje", vid1);
       dpGet("SysSarani:VID08-SOS-L7.value.mjerenje", vid2);
       
       dpGet("SysSarani:VAZ11-SOS-L1.value.mjerenje", brz1);
       dpGet("SysSarani:VAZ12-SOS-L7.value.mjerenje", brz2);
       
       za_postavljanje = true;
      }
      
      DebugTN("dpe: " + dpe);
      if (za_postavljanje) {
        dpSet("SysSarani:" + dpe + ".mjerenja_senzora.co_1", co1);
        dpSet("SysSarani:" + dpe + ".mjerenja_senzora.co_2", co2);
      
        dpSet("SysSarani:" + dpe + ".mjerenja_senzora.brzina_1", brz1);
        dpSet("SysSarani:" + dpe + ".mjerenja_senzora.brzina_2", brz2);
      
        dpSet("SysSarani:" + dpe + ".mjerenja_senzora.vidljivost_1", vid1);
        dpSet("SysSarani:" + dpe + ".mjerenja_senzora.vidljivost_2", vid2);
      }
    }
  } 
}
