#uses "dp_set_delay.ctl"

main() {
   dyn_int timeList;

   int start=0, end=86399;
   
   while (start<=end) {
     dynAppend(timeList, start);
     start+=300;
   }

   dpSet("SysSarani:BaznaRasvjeta.time", timeList);

   timedFunc("blokirajRedukciju", "BaznaRasvjeta");
}

blokirajRedukciju (string dp, time before, time now) {
  
  
  bool blokirano;
  
  DebugFTN("level1","Pozvana je timedFunc blokirajRedukciju sa parametrima: ");
  DebugFTN("level1","\nbefore: " + formatTime("%H:%M:%S", before) + "\nnow: " + formatTime("%H:%M:%S",now) + "\nsat: " + hour(now));
  
  if(hour(now) >= 17 && hour(now) <=21) {
    dpSet("SysSarani:bazna.state.blokirana_redukcija", 1);
    DebugFTN("level1","Redukcija blokirana");
  }
  else  {
    dpSet("SysSarani:bazna.state.blokirana_redukcija", 0);
    DebugFTN("level1","Redukcija deblokirana");
  }

    
}
