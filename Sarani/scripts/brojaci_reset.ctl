main()
{
  dyn_int timeList;

   int start=0, end=86399;
   
   dynAppend(timeList, 0);
   dynAppend(timeList, 1);
   dpSet("SysSarani:brojaci_reset.time", timeList);
   
   timedFunc("blink", "brojaci_reset"); 
}

blink(string Blinker,time t1, time t2)
{
  //nemoj se izvrsiti nakon reseta
  //DebugTN("Izvršavanje skripte za reset brojača...t1 = " + formatTime("%H:%M:%S", t1) + ", t2 = " + formatTime("%H:%M:%S", t2));
//   if(t1 == 0) 
//     return;
  
  dyn_dyn_anytype tab;
  dpQuery("SELECT '_original.._value' FROM 'BS*.VehicleCounter.Module*.Sums.direction*.*'", tab);
  int i;
  string pokupi;
  DebugTN("Izvršavanje skripte za reset brojača...");
  for (i = 2; i <= dynlen(tab); i++)
  { 
      string element = dpSubStr(tab[i][1], DPSUB_ALL);
      dpGet(element, pokupi);      
            
      strreplace(element, "direction1", "direction1.cut");
      strreplace(element, "direction2", "direction2.cut");
      dpSet(element, pokupi);
      
      
  } 
 
  /*
  time currentTime = getCurrentTime();
  time timestamp;
  DebugTN("Test: ", currentTime);
  */
}
