#uses "PLC/extended_functions.ctl"
#uses "PLC/signalizacija.ctl"

main()
{

  dyn_dyn_string semafor;
  dyn_dyn_bool enable;
  semafor[1]=makeDynString("S1-TKD1","S2-TKD1","S3-TKD1","S4-TKD1","S1-D4","S2-D4","S1-TKD3","S2-TKD3","treptacD");
  semafor[2]=makeDynString("S1-PS2","S2-PS2","S1-TKL2","S2-TKL2","S1-L4","S2-L4","S1-TKL1","S2-TKL1","treptacL");
  
  
  startThread("clock_semafor");
  
  for(int j=1;j<=2;j++)
    {
      for(int i=1;i<=dynlen(semafor[j]);i++)
      {
        dpConnect("Semafor_alarm",semafor[j][i]+".alarm.kvar",semafor[j][i]+".command.sdv.iskljuci");
        dpConnect("Semafor_run",semafor[j][i]+".function.clock");
      }
    }
  
                           

}



