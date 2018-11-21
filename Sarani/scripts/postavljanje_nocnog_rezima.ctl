#uses "dp_set_delay.ctl"

main() {
   dyn_int timeList;

   int start=5, end=86399;
   
   while (start<=end) {
     dynAppend(timeList, start);
     start+=300;
   }

   dpSet("SysSarani:NocniRezim.time", timeList); 
   
   timedFunc("postaviNocniRezim", "NocniRezim");
}

postaviNocniRezim (string dp, time before, time now) {
  int start_hour = (daylightsaving(getCurrentTime())) ? 21 : 20;
  int end_hour = (daylightsaving(getCurrentTime())) ? 6 : 7;
  
  
  DebugFTN("level1","Pozvana je timedFunc postaviNocniRezim sa parametrima: ");
  DebugFTN("level1","\nbefore: " + formatTime("%H:%M:%S", before) + "\nnow: " + formatTime("%H:%M:%S",now) 
          + "\nsat: " + hour(now) + "\nstart_hour:" + start_hour + "\nend_hour:" + end_hour);
  
  if ((hour(now) >= start_hour && hour(now) < 24) || (hour(now) >= 0 && hour(now) < end_hour)) {
    bool prelaz_u_nocni_rezim;
    dpGet("SysSarani:bazna.state.prelaz_u_nocni_rezim", prelaz_u_nocni_rezim);
    dpSet("SysSarani:bazna.state.nocni_rezim", 1); 
    DebugFTN("level1","Nocni rezim aktiviran");
    
    dpSet("SysSarani:bazna.state.prelaz_iz_nocnog_rezima", 0);
    
  }
  else {
    bool prelaz_iz_nocnog_rezima;   
    int aktivni_scenarij;
    
    dpGet("SysSarani:aktivni_algoritam.scenarij_rasvjete", aktivni_scenarij);   
   
      dpGet("SysSarani:bazna.state.prelaz_iz_nocnog_rezima", prelaz_iz_nocnog_rezima);
    
      if (!prelaz_iz_nocnog_rezima) {
        dpSet("SysSarani:bazna.state.prelaz_iz_nocnog_rezima", 1);
    }
    dpSet("SysSarani:bazna.state.nocni_rezim", 0); 
    DebugFTN("level1","Nocni rezim deaktiviran");
  }
}
