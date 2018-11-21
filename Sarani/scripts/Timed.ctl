main()
{
  dyn_int times = makeDynInt(34680, 34740);
  dpSet("SysSarani:test.time", times);
  //dpConnect("pratiOkidac", "SysSarani:test01.okidac");
  timedFunc("blink","test");
}
 
pratiOkidac(string dp, bool on) {
  if (on) 
    timedFunc("blink","test");
  
}

blink(string Blinker,time t1, time t2)
{
  bool x;
  DebugTN("before: ", t1);
  DebugTN("now: ", t2);
  dpGet("SysSarani:test01.state",x);
  dpSet("SysSarani:test01.state",!x);
}
