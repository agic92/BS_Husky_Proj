#uses "PLC/extended_functions.ctl"
#uses "PLC/ventilacija.ctl"

main()
{
  dyn_dyn_string ventilatori_cijev,ventilatori_grupa,ventilatori_evakuacija_cijev,vazduh_senzori,CO_VI_senzori,klapne;
  dyn_dyn_bool enable;
  string OA_V1_glavni_prekidac_D="grupa_1.glavni_prekidac_D",OA_V1_glavni_prekidac_L="grupa_1.glavni_prekidac_L",
         OA_V2_glavni_prekidac_D="grupa_2.glavni_prekidac_D",OA_V2_glavni_prekidac_L="grupa_2.glavni_prekidac_L",
         PGS1_UPS="grupa_1.UPS_aktivan",PGS2_UPS="grupa_2.UPS_aktivan";
  
  
  ventilatori_cijev[1]=makeDynString("V01_1-1D","V02_2-1D","V03_3-1D","V04_4-1D","V05_4-2D","V06_3-2D","V07_2-2D","V08_1-2D");
  //ventilatori_cijev[2]=makeDynString("V15_1-1L","V16_2-1L","V17_3-1L","V18_4-1L","V19_4-2L","V20_3-2L","V21_2-2L","V22_1-2L");
  ventilatori_cijev[2]=makeDynString("V22_1-2L","V21_2-2L","V20_3-2L","V19_4-2L","V18_4-1L","V17_3-1L","V16_2-1L","V15_1-1L");
  ventilatori_grupa[1]=makeDynString("V01_1-1D","V02_2-1D","V03_3-1D","V04_4-1D","V15_1-1L","V16_2-1L","V17_3-1L","V18_4-1L");
  ventilatori_grupa[2]=makeDynString("V05_4-2D","V06_3-2D","V07_2-2D","V08_1-2D","V19_4-2L","V20_3-2L","V21_2-2L","V22_1-2L"); 
  ventilatori_evakuacija_cijev[1]=makeDynString("V09_1D-2","V10_2D-2","V11_1D-4","V12_2D-4","V13_1D-6","V14_2D-6");
  ventilatori_evakuacija_cijev[2]=makeDynString("V23_1L-2","V24_2L-2","V25_1L-4","V26_2L-4","V27_1L-6","V28_2L-6");
  vazduh_senzori[1]=makeDynString("VAZ09-SOS-D1","VAZ10-SOS-D7");
  vazduh_senzori[2]=makeDynString("VAZ11-SOS-L1","VAZ12-SOS-L7");
  CO_VI_senzori[1]=makeDynString("CO01-SOS-D1","CO02-SOS-D7","VID05-SOS-D1","VID06-SOS-D7");
  CO_VI_senzori[2]=makeDynString("CO03-SOS-L1","CO04-SOS-L7","VID07-SOS-L1","VID08-SOS-L7");
  klapne[1]=makeDynString("Klapna01_1D-2","Klapna02_2D-2","Klapna03_1D-4","Klapna04_2D-4","Klapna05_1D-6","Klapna06_2D-6");
  klapne[2]=makeDynString("Klapna07_1L-2","Klapna08_2L-2","Klapna09_1L-4","Klapna10_2L-4","Klapna11_1L-6","Klapna12_2L-6");
  
  
    
    for(int j=1;j<=2;j++)
    {
        for(int i=1;i<=8;i++)
        {
           
            if(j==1 && i<=4)
            {
               dpConnect("ventilator",ventilatori_cijev[j][i]+".function.clock",OA_V1_glavni_prekidac_D,PGS1_UPS);
            }
            else if(j==1 && i>4)
            {
               dpConnect("ventilator",ventilatori_cijev[j][i]+".function.clock",OA_V2_glavni_prekidac_D,PGS2_UPS);
            }
            else if(j==2 && i<=4)
            {
               dpConnect("ventilator",ventilatori_cijev[j][i]+".function.clock",OA_V2_glavni_prekidac_L,PGS2_UPS);
            }
            else if(j==2 && i>4)
            {
               dpConnect("ventilator",ventilatori_cijev[j][i]+".function.clock",OA_V1_glavni_prekidac_L,PGS1_UPS);
            }
             
          
           if(i<=6)
           {
               if(j==1 && i<=4)
               {
                  dpConnect("ventilator",ventilatori_evakuacija_cijev[j][i]+".function.clock",OA_V1_glavni_prekidac_D,PGS1_UPS);
               }
               else if(j==1 && i>4)
               {
                  dpConnect("ventilator",ventilatori_evakuacija_cijev[j][i]+".function.clock",OA_V1_glavni_prekidac_D,PGS2_UPS);
               }
               else if(j==2 && i<=2)
               {
                  dpConnect("ventilator",ventilatori_evakuacija_cijev[j][i]+".function.clock",OA_V1_glavni_prekidac_D,PGS1_UPS);
               }
               else if(j==2 && i>2)
               {
                  dpConnect("ventilator",ventilatori_evakuacija_cijev[j][i]+".function.clock",OA_V1_glavni_prekidac_D,PGS2_UPS);
               }
               
               dpConnect("klapna_alarm",klapne[j][i]+".function.clock");
           }
        }
    
    }
    startThread("sistem_start",ventilatori_grupa[1],1);
    startThread("sistem_start",ventilatori_grupa[2],2);
    startThread("kernel");
    startThread("incidentni_rezim",ventilatori_cijev,ventilatori_evakuacija_cijev,vazduh_senzori);
    startThread("normalni_rezim_CO_VI",ventilatori_cijev[1],CO_VI_senzori[1],vazduh_senzori[1]);
    startThread("normalni_rezim_CO_VI",ventilatori_cijev[2],CO_VI_senzori[2],vazduh_senzori[2]);
    startThread("normalni_rezim_24h",ventilatori_cijev,ventilatori_evakuacija_cijev);
   
  

}


