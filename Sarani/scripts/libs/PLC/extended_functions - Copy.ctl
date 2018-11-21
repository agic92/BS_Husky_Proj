

kernel()
{
  string dp1="grupa_1.clock",dp2="grupa_2.clock"; 
  dyn_dyn_string ventilatori_cijev,ventilatori_evakuacija_cijev,semafor;
  
  ventilatori_cijev[1]=makeDynString("V01_1-1D","V02_2-1D","V03_3-1D","V04_4-1D","V05_4-2D","V06_3-2D","V07_2-2D","V08_1-2D");
  ventilatori_cijev[2]=makeDynString("V15_1-1L","V16_2-1L","V17_3-1L","V18_4-1L","V19_4-2L","V20_3-2L","V21_2-2L","V22_1-2L");
  ventilatori_evakuacija_cijev[1]=makeDynString("V09_1D-2","V10_2D-2","V11_1D-4","V12_2D-4","V13_1D-6","V14_2D-6");
  ventilatori_evakuacija_cijev[2]=makeDynString("V23_1L-2","V24_2L-2","V25_1L-4","V26_2L-4","V27_1L-6","V28_2L-6");
  semafor[1]=makeDynString("S1-TKD1","S2-TKD1","S3-TKD1","S4-TKD1","S1-D4","S2-D4","S1-TKD3","S2-TKD3","treptacD");
  semafor[2]=makeDynString("S1-PS2","S2-PS2","S1-TKL2","S2-TKL2","S1-L4","S2-L4","S1-TKL1","S2-TKL1","treptacL");
 
  while(1)
  { 
      dpSet(dp1,true,dp2,true);
      for (int j=1;j<=2;j++)
      {
          for(int i=1;i<=8;i++)
          {
              dpSet(ventilatori_cijev[j][i]+".function.clock",true);
              if(i<=6)
                 dpSet(ventilatori_evakuacija_cijev[j][i]+".function.clock",true);
          }
      }
      for(int j=1;j<=2;j++)
      {
          for(int i=1;i<=dynlen(semafor[j]);i++)
          {
               dpSet(semafor[j][i]+".function.clock",true);    
          }
      }      
      delay(0,450);
      dpSet(dp1,false,dp2,false);
      for (int j=1;j<=2;j++)
      {
          for(int i=1;i<=8;i++)
          {
              dpSet(ventilatori_cijev[j][i]+".function.clock",false);
              if(i<=6)
                 dpSet(ventilatori_evakuacija_cijev[j][i]+".function.clock",false);
          }
      }
      for(int j=1;j<=2;j++)
      {
          for(int i=1;i<=dynlen(semafor[j]);i++)
          {
               dpSet(semafor[j][i]+".function.clock",false);    
          }
      }        
      delay(0,450);
  }


}
clock_semafor()
{
    dyn_dyn_string semafor;
    
    semafor[1]=makeDynString("S1-TKD1","S2-TKD1","S3-TKD1","S4-TKD1","S1-D4","S2-D4","S1-TKD3","S2-TKD3","treptacD");
    semafor[2]=makeDynString("S1-PS2","S2-PS2","S1-TKL2","S2-TKL2","S1-L4","S2-L4","S1-TKL1","S2-TKL1","treptacL");
    while(1)
    {
      for(int j=1;j<=2;j++)
      {
          for(int i=1;i<=dynlen(semafor[j]);i++)
          {
               //dpSet(semafor[j][i]+".function.clock",0);
                Semafor_run(semafor[j][i]+".function.clock",0);    
          }
      }      
      delay(0,500);     
      for(int j=1;j<=2;j++)
      {
          for(int i=1;i<=dynlen(semafor[j]);i++)
          {
               //dpSet(semafor[j][i]+".function.clock",1);  
               Semafor_run(semafor[j][i]+".function.clock",0);  
          }
      }        
      delay(0,500);
      
      for(int j=1;j<=2;j++)
      {
          for(int i=1;i<=dynlen(semafor[j]);i++)
          {
               //dpSet(semafor[j][i]+".function.clock",2);
              Semafor_run(semafor[j][i]+".function.clock",0);    
          }
      }        
      delay(0,500);
    
    
    }


}
