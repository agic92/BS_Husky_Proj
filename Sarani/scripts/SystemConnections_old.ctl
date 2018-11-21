main()
{
timedFunc("blink","CheckSystems");
}

blink(string Blinker,time t1, time t2)
{
  dyn_dyn_anytype tab;
  int z;
  bool alive;  
  time currentTime = getCurrentTime();
  time timestamp;
  bool state;
  
  //tab[x] = makeDynString("System1:Videodetekcija.IntegrClient");
  //tab[1] = makeDynString("System1:Asterisk.IntegrClient");
  tab[1] = makeDynString("SysGaj:Vatrodojava_Gaj.IntegrClient");
  tab[2] = makeDynString("SysGaj:Vatrodojava_Gaj.IntegrServer");
  tab[3] = makeDynString("SysGaj:Vatrodojava_Tulica.IntegrClient");
  tab[4] = makeDynString("SysGaj:Vatrodojava_Tulica.IntegrServer");
  tab[5] = makeDynString("SysGaj:Signalizacija.IntegrClient");
  tab[6] = makeDynString("SysGaj:Meteostanica1.IntegrClient");
  tab[7] = makeDynString("SysGaj:Meteostanica2.IntegrClient");
  tab[8] = makeDynString("SysGaj:Meteostanica3.IntegrClient");
  tab[9] = makeDynString("SysGaj:Meteostanica4.IntegrClient");
  tab[10] = makeDynString("SysGaj:Videodetekcija_ts013.IntegrClient");
  tab[11] = makeDynString("SysGaj:Videodetekcija_ts014.IntegrClient");
  tab[12] = makeDynString("SysGaj:Videodetekcija_ts015.IntegrClient");
  tab[13] = makeDynString("SysGaj:BrojacPrometa.IntegrClient");
//  tab[8] = makeDynString("SysGaj:ZvucniAlarmVlakovoTarcin.IntegrClient");

//  tab[14] = makeDynString("SysGaj:Vatrodojava_Gaj_2.IntegrClient");
//  tab[15] = makeDynString("SysGaj:Vatrodojava_Gaj_2.IntegrServer");
//  tab[16] = makeDynString("SysGaj:Vatrodojava_Tulica_2.IntegrClient");
//  tab[17] = makeDynString("SysGaj:Vatrodojava_Tulica_2.IntegrServer");
  tab[14] = makeDynString("SysGaj:Signalizacija_2.IntegrClient");
  tab[15] = makeDynString("SysGaj:Meteostanica1_2.IntegrClient");
  tab[16] = makeDynString("SysGaj:Meteostanica2_2.IntegrClient");
  tab[17] = makeDynString("SysGaj:Meteostanica3_2.IntegrClient");
  tab[18] = makeDynString("SysGaj:Meteostanica4_2.IntegrClient");
  tab[19] = makeDynString("SysGaj:Videodetekcija_ts013_2.IntegrClient");
  tab[20] = makeDynString("SysGaj:Videodetekcija_ts014_2.IntegrClient");
  tab[21] = makeDynString("SysGaj:Videodetekcija_ts015_2.IntegrClient");
  tab[22] = makeDynString("SysGaj:BrojacPrometa_2.IntegrClient");


  for(z=1;z<=dynlen(tab);z++) {
    dpGet(tab[z] + ".timestamp:_original.._value", timestamp, tab[z] + ".alive:_original.._value", alive);
    int d = currentTime - timestamp; // ova razlika je u sekundama
//    DebugTN("razlika: ",d);
    if (d > 10 && alive) {
      dpGet(tab[z] + ".alive:_original.._value", state);
      DebugTN("Alive : " + alive + " --> FALSE : " + tab[z]);
      dpSet(tab[z] + ".alive:_original.._value", false);
    }
    else if (d < 10 && !alive) {
      dpGet(tab[z] + ".alive:_original.._value", state);
      DebugTN("Alive : " + alive + " --> TRUE : " + tab[z]);
      dpSet(tab[z] + ".alive:_original.._value", true); 
    }
  }
}
