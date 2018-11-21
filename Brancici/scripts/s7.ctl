main()
{
  timedFunc("valueSet", "s7");
}

valueSet(string s7,time t1, time t2)
{
  //nemoj se izvrsiti nakon reseta
  //DebugTN("Izvršavanje skripte za reset brojača...t1 = " + formatTime("%H:%M:%S", t1) + ", t2 = " + formatTime("%H:%M:%S", t2));
//   if(t1 == 0)
//     return;
  bool value;
  dpGet("SysBrancici:s7+.state", value);
  dpSet("SysBrancici:s7+.command", !value);
  /*
  time currentTime = getCurrentTime();
  time timestamp;
  DebugTN("Test: ", currentTime);
  */
}
