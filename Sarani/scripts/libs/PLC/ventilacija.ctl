#uses "PLC/base_functions.ctl"

incidentni_rezim(dyn_dyn_string ventilatori,dyn_dyn_string ventilatori_evakuacija,dyn_dyn_string senzori)
{
     dyn_dyn_string  dp_timer;

     bool pozarna_zona_aktivna,pozarni_rezim_zagusenje,pozarni_rezim_normalno,odimljavanje_ulazni_portal,odimljavanje_izlazni_portal,
          V1_kvar,V1_servis,V2_kvar,V2_servis,V3_kvar,V3_servis,V4_kvar,V4_servis,
          status_v1,kvar_v1,servis_v1,cmd_v2,
          status_v3,kvar_v3,servis_v3,cmd_v4,
          status_v5,kvar_v5,servis_v5,cmd_v6;
     
     int pozarna_cijev=1,zdrava_cijev=2,pozarni_ventilator,broj_senzora;
     
     float Vsr,V1_mjerenje,V2_mjerenje,V3_mjerenje,V4_mjerenje;
     
     dyn_bool mem_pozar=makeDynBool(true,false,false,false,false,false,false,false,false,false),
              mem_24h=makeDynBool(false,false,false,false,false,false,false,false,false,false),
              mem_sedmica=makeDynBool(false,false,false,false,false,false,false,false,false,false),
              co_mem_desna=makeDynBool(false,false,false,false,false,false,false,false,false,false),
              co_mem_lijeva=makeDynBool(false,false,false,false,false,false,false,false,false,false),
              timer_Q;
              
     dpSet("CLC.incidentni_rezim.mem",mem_pozar); 
     
     for (int i=1;i<=4;i++)
     {  
          dp_timer[i][1]=makeDynString("CLC.incidentni_rezim.timer.T"+i+".IN");
          dp_timer[i][2]=makeDynString("CLC.incidentni_rezim.timer.T"+i+".Q");
          
          dpGet(dp_timer[i][2],timer_Q[i]);
          TimerTON(dp_timer[i][1],false); 
     }

     
     
     while(1)
     {
           
       
           
           dpGet("CLC.incidentni_rezim.zagusenje",pozarni_rezim_zagusenje,
                 "CLC.incidentni_rezim.normalno",pozarni_rezim_normalno,
                 "CLC.incidentni_rezim.mem",mem_pozar,
                 "CLC.incidentni_rezim.odimljavanje_ulazni_portal",odimljavanje_ulazni_portal,
                 "CLC.incidentni_rezim.odimljavanje_izlazni_portal",odimljavanje_izlazni_portal);
           
           dpGet(senzori[1][1]+".value.mjerenje",V1_mjerenje,
                 senzori[1][1]+".state.servis",V1_servis,
                 senzori[1][1]+".alarm.kvar",V1_kvar,
                 senzori[1][2]+".value.mjerenje",V2_mjerenje,
                 senzori[1][2]+".state.servis",V2_servis,
                 senzori[1][2]+".alarm.kvar",V2_kvar,
                 senzori[2][1]+".value.mjerenje",V3_mjerenje,
                 senzori[2][1]+".state.servis",V3_servis,
                 senzori[2][1]+".alarm.kvar",V3_kvar,
                 senzori[2][2]+".value.mjerenje",V4_mjerenje,
                 senzori[2][2]+".state.servis",V4_servis,
                 senzori[2][2]+".alarm.kvar",V4_kvar);
           
           for (int i=1;i<=4;i++)
           {                
               dpGet(dp_timer[i][2],timer_Q[i]);
           }
           
                       
           
       
           if(mem_pozar[1])
           {
                if(pozarni_rezim_zagusenje || pozarni_rezim_normalno)
                {
                     SetCoil(mem_pozar[2]);
                     ResetCoil(mem_pozar[1]);
                                                                                                                                                 
                     
                     for(int j=1;j<=2;j++)
                     {
                         for(int i=1;i<=8;i++)
                         {
                             dpGet(ventilatori[j][i]+".alarm.pozarna_zona_aktivna",pozarna_zona_aktivna);
   
                             if(pozarna_zona_aktivna)
                             {
                                pozarna_cijev=j;
                                pozarni_ventilator=i;
                                
                                if(pozarna_cijev==1)
                                {
                                   zdrava_cijev=2;
                                }
                                else if(pozarna_cijev==2)
                                {
                                   zdrava_cijev=1;                               
                                }
                                dpSet(ventilatori[j][i]+".cmd.sdv.automatski.naprijed",false,
                                      ventilatori[j][i]+".cmd.sdv.automatski.nazad",false);
                                
                                break;
                             }
                         
                         }
                                                     
                     
                     }
                
                
                
                }             
           
           }
           if(mem_pozar[2])
           {
                if(timer_Q[1])
                { 
                    bool state;
                    
                    
                    
                    dpSet(ventilatori_evakuacija[zdrava_cijev][1]+".cmd.sdv.automatski.naprijed",true,
                          ventilatori_evakuacija[zdrava_cijev][3]+".cmd.sdv.automatski.naprijed",true,
                          ventilatori_evakuacija[zdrava_cijev][5]+".cmd.sdv.automatski.naprijed",true);
                    
                    
                    
                    if(pozarni_rezim_normalno)
                    {
                         
                         for(int i=8;i>=1;i--)
                         {
                            if(i!=pozarni_ventilator)
                            {                                                                                    
                                dpSet(ventilatori[pozarna_cijev][i]+".cmd.sdv.automatski.naprijed",true); 
                                delay(10);
                               
                            }
                                                  
                         
                         }
                                      
                  
                    }
                  //  DebugN("string",ventilatori_evakuacija[zdrava_cijev][5]);
                   
                    for(int i=1;i<=8;i++)
                    {
                          dpGet(ventilatori[zdrava_cijev][i]+".cmd.led.naprijed",state);
                          if(state)
                          {
                             dpSet(ventilatori[zdrava_cijev][i]+".cmd.sdv.automatski.naprijed",false,
                                   ventilatori[zdrava_cijev][i]+".cmd.sdv.automatski.nazad",false);
                             
                             state=false;
                          
                          }  
                               
                    }
                   
                   
                    dpSet(ventilatori[zdrava_cijev][1]+".cmd.sdv.automatski.nazad",true,
                          ventilatori[zdrava_cijev][3]+".cmd.sdv.automatski.nazad",true,
                          ventilatori[zdrava_cijev][5]+".cmd.sdv.automatski.nazad",true,
                          ventilatori[zdrava_cijev][7]+".cmd.sdv.automatski.nazad",true);
                          
                          
                                                                          
                       
                    
                       
                    delay(0,200);
                    SetCoil(mem_pozar[3]);
                    ResetCoil(mem_pozar[2]);
                 
                    
                 }
           
           }
           if(mem_pozar[3])
           {
                
                
                if(pozarni_rezim_zagusenje && !odimljavanje_izlazni_portal && !odimljavanje_ulazni_portal)
                {
                        if(pozarna_cijev==1)
                        {
                            
                            if(!V1_kvar && !V1_servis && V1_mjerenje>=-20 && V1_mjerenje<=20)
                            {
                                 broj_senzora++;
                                 Vsr=Vsr+V1_mjerenje;
                            
                            }
                            if(!V2_kvar && !V2_servis && V2_mjerenje>=-20 && V2_mjerenje<=20)
                            {
                                 broj_senzora++;
                                 Vsr=Vsr+V2_mjerenje;
                            
                            }
                            
                            if(broj_senzora>0)
                            {
                              Vsr=Vsr/broj_senzora;
                            }                       
                        
                        }
                        else if(pozarna_cijev==2)
                        {
                            
                            if(!V3_kvar && !V3_servis && V3_mjerenje>=-20 && V3_mjerenje<=20)
                            {
                                 broj_senzora++;
                                 Vsr=Vsr+V3_mjerenje;
                            
                            }
                            if(!V4_kvar && !V4_servis && V4_mjerenje>=-20 && V4_mjerenje<=20)
                            {
                                 broj_senzora++;
                                 Vsr=Vsr+V4_mjerenje;
                            
                            }
                            
                            if(broj_senzora>0)
                            {
                              Vsr=Vsr/broj_senzora;
                            }      
                                                   
                        
                        }
                        
                        if(Vsr>=0 && Vsr<=0.5 && pozarni_ventilator!=8)
                        {
                             dpSet(ventilatori[pozarna_cijev][8]+".cmd.sdv.automatski.naprijed",true);
                        
                        }
                        else if(Vsr<0 && Vsr>=-0.5 && pozarni_ventilator!=1)
                        {
                             dpSet(ventilatori[pozarna_cijev][1]+".cmd.sdv.automatski.nazad",true);
                        
                        }
                        else if(Vsr>1.5 || Vsr<-1.5)
                        {
                             dpSet(ventilatori[pozarna_cijev][8]+".cmd.sdv.automatski.naprijed",false,
                                   ventilatori[pozarna_cijev][1]+".cmd.sdv.automatski.nazad",false);
                        }
                          
                        broj_senzora=0;
                        Vsr=0;
                  
                 }
             
                
             
                
             
                if(timer_Q[2])
                { 
                     dpSet("CLC.incidentni_rezim.odimljavanje_dozvoljeno",true);
                                   
                     
                     if(odimljavanje_izlazni_portal || odimljavanje_ulazni_portal)
                     {
                          dpSet("CLC.incidentni_rezim.odimljavanje_dozvoljeno",false);
                          
                          if(odimljavanje_izlazni_portal)
                          {
                                  if(pozarni_rezim_zagusenje)
                                  {
                                      bool status_ventilatora;
                              
                                      dpGet(ventilatori[pozarna_cijev][1]+".cmd.led.nazad",status_ventilatora);
                                      if(status_ventilatora)
                                      {
                                          dpSet(ventilatori[pozarna_cijev][1]+".cmd.sdv.automatski.nazad",false);
                                                                                                     
                                      }
                                                                   
                         
                                   }
                          }
                          else if(odimljavanje_ulazni_portal)
                          {
                                  
                                     bool status_ventilatora;
                                     for(int i=2;i<=8;i++)
                                     {
                                            
                                         dpSet(ventilatori[pozarna_cijev][i]+".cmd.sdv.automatski.nazad",false,
                                               ventilatori[pozarna_cijev][i]+".cmd.sdv.automatski.naprijed",false); 
                                                                                         
                                                
                                     }
                                     
                                      dpGet(ventilatori[pozarna_cijev][1]+".state.naprijed",status_ventilatora);
                                      if(status_ventilatora)
                                      {
                                          dpSet(ventilatori[pozarna_cijev][1]+".cmd.sdv.automatski.naprijed",false);
                                                                                                     
                                      }
                                      
                                      dpSet(ventilatori[zdrava_cijev][1]+".cmd.sdv.automatski.nazad",false,
                                            ventilatori[zdrava_cijev][3]+".cmd.sdv.automatski.nazad",false,
                                            ventilatori[zdrava_cijev][5]+".cmd.sdv.automatski.nazad",false,
                                            ventilatori[zdrava_cijev][7]+".cmd.sdv.automatski.nazad",false);
                                     
                         
                                  
                                   
                                                            
                                  
                          }
                          
                          
                          
                          SetCoil(mem_pozar[4]);
                          ResetCoil(mem_pozar[3]);
    
                          
                     
                     }
                  
                  
                  
                  
                
                }
                
                
           }
           if(mem_pozar[4])
           {
                
                    if(odimljavanje_izlazni_portal)
                    {                                            
                        
                        for(int i=1;i<=8;i++)
                        {
                            dpSet(ventilatori[pozarna_cijev][i]+".cmd.sdv.automatski.naprijed",true,
                                  ventilatori[zdrava_cijev][i]+".cmd.sdv.automatski.nazad",true);                           
                         }
                        
                       
                        
                        SetCoil(mem_pozar[5]);
                        ResetCoil(mem_pozar[4]);
                        
                    
                    }
                    else if(odimljavanje_ulazni_portal)
                    {
                                                                   
                        if(timer_Q[3])
                        { 
                      
                              for(int i=1;i<=8;i++)
                              {
                                  dpSet(ventilatori[pozarna_cijev][i]+".cmd.sdv.automatski.nazad",true,
                                        ventilatori[zdrava_cijev][i]+".cmd.sdv.automatski.naprijed",true);                           
                               }
                        
                              SetCoil(mem_pozar[5]);
                              ResetCoil(mem_pozar[4]);
                        }
                      
                        
                    }
                   
                    
                
                
                
             
             
                
           }
           if(mem_pozar[5])
           {
               if(!pozarni_rezim_zagusenje && !pozarni_rezim_normalno)
               {
                  SetCoil(mem_pozar[6]);
                  ResetCoil(mem_pozar[5]);
                  dpSet("CLC.incidentni_rezim.odimljavanje_dozvoljeno",false);
                  
                  for(int j=1;j<=2;j++)
                  {
                     for(int i=1;i<=8;i++)
                     {
                        dpSet(ventilatori[j][i]+".cmd.sdv.automatski.nazad",false,
                              ventilatori[j][i]+".cmd.sdv.automatski.naprijed",false);
                          
                        if(i<=6) 
                        {
                           dpSet(ventilatori_evakuacija[j][i]+".cmd.sdv.automatski.naprijed",false);                           
                        }           
                     }         
    
                  } 
               
               }
             
             
           }
           if(mem_pozar[6])
           {
               if(timer_Q[4])
               {
                   SetCoil(mem_pozar[1]);
                   ResetCoil_BF(mem_pozar,2,6);
                   
                   SetCoil(co_mem_desna[5]);
                   SetCoil(co_mem_lijeva[5]);
                   broj_senzora=0;
                   Vsr=0;
                   pozarna_cijev=0;
                   pozarni_ventilator=0;
                   dpSet("CLC.normalni_rezim.CO_VI.desna_cijev.mem",co_mem_desna,
                         "CLC.normalni_rezim.CO_VI.lijeva_cijev.mem",co_mem_lijeva);
                         
               }
             
             
           }
           
           if((mem_pozar[2] || mem_pozar[3] || mem_pozar[4]) && !pozarni_rezim_zagusenje && !pozarni_rezim_normalno)
           {
                SetCoil(mem_pozar[5]);
                ResetCoil(mem_pozar[2]);
                ResetCoil(mem_pozar[3]);
                ResetCoil(mem_pozar[4]);                                                
           }
           
           
           
           if((mem_pozar[3] || mem_pozar[4] || mem_pozar[5]) && (pozarni_rezim_zagusenje || pozarni_rezim_normalno))
           {
              
                   dpGet(ventilatori_evakuacija[zdrava_cijev][1]+".cmd.led.naprijed",status_v1,                        
                         ventilatori_evakuacija[zdrava_cijev][3]+".cmd.led.naprijed",status_v3,                                                
                         ventilatori_evakuacija[zdrava_cijev][5]+".cmd.led.naprijed",status_v5);
                        
                         
                         
                         
                         
                   
                   if(!status_v1)
                   {
                      dpSet(ventilatori_evakuacija[zdrava_cijev][2]+".cmd.sdv.automatski.naprijed",true);
                                             
                   }
                   else if(status_v1)
                   {
                      dpSet(ventilatori_evakuacija[zdrava_cijev][2]+".cmd.sdv.automatski.naprijed",false);
                                             
                   }
                   
                   if(!status_v3)
                   {
                      dpSet(ventilatori_evakuacija[zdrava_cijev][4]+".cmd.sdv.automatski.naprijed",true);
                            
                   }
                   else if(status_v3)
                   {
                      dpSet(ventilatori_evakuacija[zdrava_cijev][4]+".cmd.sdv.automatski.naprijed",false);
                            
                                     
                   }
                   if(!status_v5)
                   {
                      dpSet(ventilatori_evakuacija[zdrava_cijev][6]+".cmd.sdv.automatski.naprijed",true);
                            
                   }
                   else if(status_v5)
                   {
                      dpSet(ventilatori_evakuacija[zdrava_cijev][6]+".cmd.sdv.automatski.naprijed",false);
                            
                                     
                   }
                   
              
               
               
               
               
           }
           
          
           
          
           
           if(mem_pozar[2])
           {
               TimerTON(dp_timer[1][1],true,5,true);
           }
           else
           {
               TimerTON(dp_timer[1][1],false);               
           }
           if(mem_pozar[3])
           {
               TimerTON(dp_timer[2][1],true,60,true);
           }
           else
           {
               TimerTON(dp_timer[2][1],false);               
           }
           if(mem_pozar[4])
           {
               TimerTON(dp_timer[3][1],true,60,true);
           }
           else
           {
               TimerTON(dp_timer[3][1],false);               
           }
           if(mem_pozar[6])
           {
               TimerTON(dp_timer[4][1],true,15,true);
           }
           else
           {
               TimerTON(dp_timer[4][1],false);               
           }
           
           dpSet("CLC.incidentni_rezim.mem",mem_pozar); 
           
           delay(0,500);
           
     
     
     }









}
normalni_rezim_24h(dyn_dyn_string ventilatori,dyn_dyn_string ventilatori_evakuacija)
{
     dyn_dyn_string  dp_timer_24h,dp_timer_sedmica;
     string dp;
     dyn_bool timer_Q_24h,timer_Q_sedmica,mem_24h=makeDynBool(true,false,false,false,false,false,false,false,false,false),
     mem_sedmica=makeDynBool(true,false,false,false,false,false,false,false,false,false);
     bool akt_sekv_24h,akt_sekv_sedmica,akt_sekv_desna,akt_sekv_lijeva,pozarni_rezim_zagusenje,pozarni_rezim_normalno,smjer_24h,smjer;
     
     time now,ST;
     
     int Day,Hour,Minute,Hour_24h,Minute_24h,Hour_sedmica,Minute_sedmica;
     
     dpSet("CLC.normalni_rezim.vrijeme.24h.mem",mem_24h,
           "CLC.normalni_rezim.vrijeme.sedmica.mem",mem_sedmica);
           
     for (int i=1;i<=4;i++)
     {
   
              dp_timer_24h[i][1]=makeDynString("CLC.normalni_rezim.vrijeme.24h.timer.T"+i+".IN");
              dp_timer_24h[i][2]=makeDynString("CLC.normalni_rezim.vrijeme.24h.timer.T"+i+".Q");
              dp_timer_sedmica[i][1]=makeDynString("CLC.normalni_rezim.vrijeme.sedmica.timer.T"+i+".IN");
              dp_timer_sedmica[i][2]=makeDynString("CLC.normalni_rezim.vrijeme.sedmica.timer.T"+i+".Q");
              
              dpGet(dp_timer_24h[i][2],timer_Q_24h[i],
                    dp_timer_sedmica[i][2],timer_Q_sedmica[i]);
              
              TimerTON(dp_timer_24h[i][1],false);
              TimerTON(dp_timer_sedmica[i][1],false);
              
                          
 
      }
     
    
     
     while(1)
     {
       
       
           
           dpGet("CLC.normalni_rezim.vrijeme.24h.mem",mem_24h,
                 "CLC.normalni_rezim.vrijeme.24h.sat",Hour_24h,
                 "CLC.normalni_rezim.vrijeme.24h.minuta",Minute_24h,
                 "CLC.normalni_rezim.vrijeme.24h.smjer",smjer,
                 "CLC.normalni_rezim.vrijeme.sedmica.mem",mem_sedmica,
                 "CLC.normalni_rezim.vrijeme.sedmica.sat",Hour_sedmica,
                 "CLC.normalni_rezim.vrijeme.sedmica.minuta",Minute_sedmica,
                 "CLC.normalni_rezim.CO_VI.desna_cijev.akt_sekv",akt_sekv_desna,
                 "CLC.normalni_rezim.CO_VI.lijeva_cijev.akt_sekv",akt_sekv_lijeva,
                 "CLC.incidentni_rezim.zagusenje",pozarni_rezim_zagusenje,
                 "CLC.incidentni_rezim.normalno",pozarni_rezim_normalno);
           
           for (int i=1;i<=4;i++)
           {
                   dpGet(dp_timer_24h[i][2],timer_Q_24h[i],
                         dp_timer_sedmica[i][2],timer_Q_sedmica[i]);                       
           }
                 
           now=getCurrentTime();
           Day=day(now);
           Hour=hour(now);
           Minute=minute(now);
       
           if(mem_24h[1] && !pozarni_rezim_zagusenje && !pozarni_rezim_normalno)
           {
                
                
                
                if(Day%2==0 && Hour==Hour_24h && Minute==Minute_24h && !akt_sekv_desna && !akt_sekv_lijeva)
                {
                     SetCoil(mem_24h[2]);
                     ResetCoil(mem_24h[1]);
                     
                     if(smjer)
                     {
                         dpSet(ventilatori[1][2]+".cmd.sdv.automatski.naprijed",true,
                               ventilatori[1][4]+".cmd.sdv.automatski.naprijed",true,
                               ventilatori[1][6]+".cmd.sdv.automatski.naprijed",true,
                               ventilatori[1][8]+".cmd.sdv.automatski.naprijed",true,
                               ventilatori[2][2]+".cmd.sdv.automatski.naprijed",true,
                               ventilatori[2][4]+".cmd.sdv.automatski.naprijed",true,
                               ventilatori[2][6]+".cmd.sdv.automatski.naprijed",true,
                               ventilatori[2][8]+".cmd.sdv.automatski.naprijed",true);
                     }
                     else 
                     {
                         dpSet(ventilatori[1][2]+".cmd.sdv.automatski.nazad",true,
                               ventilatori[1][4]+".cmd.sdv.automatski.nazad",true,
                               ventilatori[1][6]+".cmd.sdv.automatski.nazad",true,
                               ventilatori[1][8]+".cmd.sdv.automatski.nazad",true,
                               ventilatori[2][2]+".cmd.sdv.automatski.nazad",true,
                               ventilatori[2][4]+".cmd.sdv.automatski.nazad",true,
                               ventilatori[2][6]+".cmd.sdv.automatski.nazad",true,
                               ventilatori[2][8]+".cmd.sdv.automatski.nazad",true);
                     
                     
                     
                     }                    
                }
           
           }
           if(mem_24h[2] && !pozarni_rezim_zagusenje && !pozarni_rezim_normalno)
           {
                if(timer_Q_24h[1])
                {
                     SetCoil(mem_24h[5]);
                     ResetCoil(mem_24h[2]);
                     
                     if(smjer)
                     {
                         dpSet(ventilatori[1][2]+".cmd.sdv.automatski.naprijed",false,
                               ventilatori[1][4]+".cmd.sdv.automatski.naprijed",false,
                               ventilatori[1][6]+".cmd.sdv.automatski.naprijed",false,
                               ventilatori[1][8]+".cmd.sdv.automatski.naprijed",false,
                               ventilatori[2][2]+".cmd.sdv.automatski.naprijed",false,
                               ventilatori[2][4]+".cmd.sdv.automatski.naprijed",false,
                               ventilatori[2][6]+".cmd.sdv.automatski.naprijed",false,
                               ventilatori[2][8]+".cmd.sdv.automatski.naprijed",false);
                     }
                     else 
                     {
                         dpSet(ventilatori[1][2]+".cmd.sdv.automatski.nazad",false,
                               ventilatori[1][4]+".cmd.sdv.automatski.nazad",false,
                               ventilatori[1][6]+".cmd.sdv.automatski.nazad",false,
                               ventilatori[1][8]+".cmd.sdv.automatski.nazad",false,
                               ventilatori[2][2]+".cmd.sdv.automatski.nazad",false,
                               ventilatori[2][4]+".cmd.sdv.automatski.nazad",false,
                               ventilatori[2][6]+".cmd.sdv.automatski.nazad",false,
                               ventilatori[2][8]+".cmd.sdv.automatski.nazad",false);
                       }
                                                                                   
                }
           
           }
           if(mem_24h[1] && !pozarni_rezim_zagusenje && !pozarni_rezim_normalno)
           {
                if(Day%2==1 && Hour==Hour_24h && Minute==Minute_24h && !akt_sekv_desna && !akt_sekv_lijeva)
                {
                     SetCoil(mem_24h[4]);
                     ResetCoil(mem_24h[1]);
                     
                     if(smjer)
                     {
                         dpSet(ventilatori[1][1]+".cmd.sdv.automatski.naprijed",true,
                               ventilatori[1][3]+".cmd.sdv.automatski.naprijed",true,
                               ventilatori[1][5]+".cmd.sdv.automatski.naprijed",true,
                               ventilatori[1][7]+".cmd.sdv.automatski.naprijed",true,
                               ventilatori[2][1]+".cmd.sdv.automatski.naprijed",true,
                               ventilatori[2][3]+".cmd.sdv.automatski.naprijed",true,
                               ventilatori[2][5]+".cmd.sdv.automatski.naprijed",true,
                               ventilatori[2][7]+".cmd.sdv.automatski.naprijed",true);
                     }
                     else 
                     {
                         dpSet(ventilatori[1][1]+".cmd.sdv.automatski.nazad",true,
                               ventilatori[1][3]+".cmd.sdv.automatski.nazad",true,
                               ventilatori[1][5]+".cmd.sdv.automatski.nazad",true,
                               ventilatori[1][7]+".cmd.sdv.automatski.nazad",true,
                               ventilatori[2][1]+".cmd.sdv.automatski.nazad",true,
                               ventilatori[2][3]+".cmd.sdv.automatski.nazad",true,
                               ventilatori[2][5]+".cmd.sdv.automatski.nazad",true,
                               ventilatori[2][7]+".cmd.sdv.automatski.nazad",true);
                                        
                     
                     }                    
                     
                
                }
           
           }
           
           if(mem_24h[4] && !pozarni_rezim_zagusenje && !pozarni_rezim_normalno)
           {
                if(timer_Q_24h[2])
                {
                     SetCoil(mem_24h[5]);
                     ResetCoil(mem_24h[4]);
                     
                     if(smjer)
                     {
                         dpSet(ventilatori[1][1]+".cmd.sdv.automatski.naprijed",false,
                               ventilatori[1][3]+".cmd.sdv.automatski.naprijed",false,
                               ventilatori[1][5]+".cmd.sdv.automatski.naprijed",false,
                               ventilatori[1][7]+".cmd.sdv.automatski.naprijed",false,
                               ventilatori[2][1]+".cmd.sdv.automatski.naprijed",false,
                               ventilatori[2][3]+".cmd.sdv.automatski.naprijed",false,
                               ventilatori[2][5]+".cmd.sdv.automatski.naprijed",false,
                               ventilatori[2][7]+".cmd.sdv.automatski.naprijed",false);
                     }
                     else 
                     {
                         dpSet(ventilatori[1][1]+".cmd.sdv.automatski.nazad",false,
                               ventilatori[1][3]+".cmd.sdv.automatski.nazad",false,
                               ventilatori[1][5]+".cmd.sdv.automatski.nazad",false,
                               ventilatori[1][7]+".cmd.sdv.automatski.nazad",false,
                               ventilatori[2][1]+".cmd.sdv.automatski.nazad",false,
                               ventilatori[2][3]+".cmd.sdv.automatski.nazad",false,
                               ventilatori[2][5]+".cmd.sdv.automatski.nazad",false,
                               ventilatori[2][7]+".cmd.sdv.automatski.nazad",false);
                                        
                     
                     }               
                
                }
           
           }
           if(mem_24h[5] && !pozarni_rezim_zagusenje && !pozarni_rezim_normalno)
           {
                
                if(!smjer)
                {
                  SetCoil(smjer);
                }
                else
                  ResetCoil(smjer);
                
                
                SetCoil(mem_24h[1]);
                ResetCoil_BF(mem_24h,2,5);
             
             
           }
           
           if(mem_24h[2] || mem_24h[4] || mem_24h[5])
           {
                SetCoil(akt_sekv_24h);   
           }
           else
           {
                ResetCoil(akt_sekv_24h);
           }
           
           
           if(mem_24h[2])
           {
                TimerTON(dp_timer_24h[1][1],true,300,true);
           }
           else
           {
                TimerTON(dp_timer_24h[1][1],false);
                 
           }
           if(mem_24h[4])
           {
                TimerTON(dp_timer_24h[2][1],true,300,true);
           }
           else
           {
                TimerTON(dp_timer_24h[2][1],false);
                 
           }
           
       
           
           if(mem_sedmica[1] && !pozarni_rezim_zagusenje && !pozarni_rezim_normalno)
           {
                if(Day%7==0 && Hour==Hour_sedmica && Minute==Minute_sedmica)
                {
                     SetCoil(mem_sedmica[2]);
                     ResetCoil(mem_sedmica[1]);
                     
                     dpSet(ventilatori_evakuacija[1][1]+".cmd.sdv.automatski.naprijed",true,
                           ventilatori_evakuacija[1][2]+".cmd.sdv.automatski.naprijed",true,
                           ventilatori_evakuacija[1][3]+".cmd.sdv.automatski.naprijed",true,
                           ventilatori_evakuacija[1][4]+".cmd.sdv.automatski.naprijed",true,
                           ventilatori_evakuacija[1][5]+".cmd.sdv.automatski.naprijed",true,
                           ventilatori_evakuacija[1][6]+".cmd.sdv.automatski.naprijed",true);
                                                                                        
                }
           
           }
           if(mem_sedmica[2] && !pozarni_rezim_zagusenje && !pozarni_rezim_normalno)
           {
                if(timer_Q_sedmica[1])
                {
                     SetCoil(mem_sedmica[3]);
                     ResetCoil(mem_sedmica[2]);
                     
                     dpSet(ventilatori_evakuacija[1][1]+".cmd.sdv.automatski.naprijed",false,
                           ventilatori_evakuacija[1][2]+".cmd.sdv.automatski.naprijed",false,
                           ventilatori_evakuacija[1][3]+".cmd.sdv.automatski.naprijed",false,
                           ventilatori_evakuacija[1][4]+".cmd.sdv.automatski.naprijed",false,
                           ventilatori_evakuacija[1][5]+".cmd.sdv.automatski.naprijed",false,
                           ventilatori_evakuacija[1][6]+".cmd.sdv.automatski.naprijed",false);                    
                                                                                  
                }
           
           }
           if(mem_sedmica[3] && !pozarni_rezim_zagusenje && !pozarni_rezim_normalno)
           {
                if(timer_Q_sedmica[2])
                {
                     SetCoil(mem_sedmica[4]);
                     ResetCoil(mem_sedmica[3]);                   
                                                                                        
                }
           
           }
           if(mem_sedmica[4] && !pozarni_rezim_zagusenje && !pozarni_rezim_normalno)
           {
                
                SetCoil(mem_sedmica[5]);
                ResetCoil(mem_sedmica[4]);                   
                     
                dpSet(ventilatori_evakuacija[2][1]+".cmd.sdv.automatski.naprijed",true,
                      ventilatori_evakuacija[2][2]+".cmd.sdv.automatski.naprijed",true,
                      ventilatori_evakuacija[2][3]+".cmd.sdv.automatski.naprijed",true,
                      ventilatori_evakuacija[2][4]+".cmd.sdv.automatski.naprijed",true,
                      ventilatori_evakuacija[2][5]+".cmd.sdv.automatski.naprijed",true,
                      ventilatori_evakuacija[2][6]+".cmd.sdv.automatski.naprijed",true);
                
           
           }
           if(mem_sedmica[5] && !pozarni_rezim_zagusenje && !pozarni_rezim_normalno)
           {
                if(timer_Q_sedmica[3])
                {
                     SetCoil(mem_sedmica[6]);
                     ResetCoil(mem_sedmica[5]);                   
                     
                     dpSet(ventilatori_evakuacija[2][1]+".cmd.sdv.automatski.naprijed",false,
                           ventilatori_evakuacija[2][2]+".cmd.sdv.automatski.naprijed",false,
                           ventilatori_evakuacija[2][3]+".cmd.sdv.automatski.naprijed",false,
                           ventilatori_evakuacija[2][4]+".cmd.sdv.automatski.naprijed",false,
                           ventilatori_evakuacija[2][5]+".cmd.sdv.automatski.naprijed",false,
                           ventilatori_evakuacija[2][6]+".cmd.sdv.automatski.naprijed",false);
                }
           
           }
           if(mem_sedmica[6] && !pozarni_rezim_zagusenje && !pozarni_rezim_normalno)
           {
                if(Day%7!=0)
                {
                   SetCoil(mem_sedmica[1]);
                   ResetCoil_BF(mem_sedmica,2,6);
                }
                
           }
           
           if(mem_sedmica[2] || mem_sedmica[3] || mem_sedmica[4] || mem_sedmica[5])
           {
                SetCoil(akt_sekv_sedmica);   
           }
           else
           {
                ResetCoil(akt_sekv_sedmica);
           }
           
           
           
           if(mem_sedmica[2])
           {
                TimerTON(dp_timer_sedmica[1][1],true,300,true);
           }
           else
           {
                TimerTON(dp_timer_sedmica[1][1],false);
                 
           }
           if(mem_sedmica[3])
           {
                TimerTON(dp_timer_sedmica[2][1],true,180,true);
           }
           else
           {
                TimerTON(dp_timer_sedmica[2][1],false);
                 
           }
           if(mem_sedmica[5])
           {
                TimerTON(dp_timer_sedmica[3][1],true,300,true);
           }
           else
           {
                TimerTON(dp_timer_sedmica[3][1],false);
                 
           }
           
           
                
               
               
           dpSet("CLC.normalni_rezim.vrijeme.24h.mem",mem_24h,
                 "CLC.normalni_rezim.vrijeme.24h.smjer",smjer,
                 "CLC.normalni_rezim.vrijeme.24h.akt_sekv",akt_sekv_24h,
                 "CLC.normalni_rezim.vrijeme.sedmica.mem",mem_sedmica,
                 "CLC.normalni_rezim.vrijeme.sedmica.akt_sekv",akt_sekv_sedmica);
                      
           delay(0,500);      
               
       
       
     
     
     }
  
     
     
     
  
}
normalni_rezim_CO_VI(dyn_string ventilatori,dyn_string senzori_co,dyn_string senzori_v)
{
     dyn_dyn_string  dp_timer,dp_timer_15min;
     string dp=ventilatori[1];
     dyn_bool timer_Q,timer_Q_15min,co_mem=makeDynBool(true,false,false,false,false,false,false,false,false,false),
                                    mem_24h=makeDynBool(false,false,false,false,false,false,false,false,false,false),
                                    mem_sedmica=makeDynBool(false,false,false,false,false,false,false,false,false,false);
     
     bool CO1_servis,CO1_kvar,CO1_150ppm_alarm,CO2_servis,CO2_kvar,CO2_150ppm_alarm,
          VI1_servis,VI1_kvar,VI1_3km_alarm,VI2_servis,VI2_kvar,VI2_3km_alarm,
          V1_kvar,V1_servis,V2_kvar,V2_servis,akt_sekv,v_akt_sekv,pozarni_rezim_zagusenje,pozarni_rezim_normalno;
     
     float CO1_mjerenje,CO2_mjerenje,VI1_mjerenje,VI2_mjerenje,Vsr,V1_mjerenje,V2_mjerenje,CO_sr,VI_sr;
     
     int broj_senzora,broj_senzora_co,broj_senzora_vi;
         
     
      if(dp[strlen(dp)-1]=="D")
      { 
         dpSet("CLC.normalni_rezim.CO_VI.desna_cijev.mem",co_mem);
         for (int i=1;i<=4;i++)
         {
   
              dp_timer[i][1]=makeDynString("CLC.normalni_rezim.CO_VI.desna_cijev.timer.T"+i+".IN");
              dp_timer[i][2]=makeDynString("CLC.normalni_rezim.CO_VI.desna_cijev.timer.T"+i+".Q");
              dp_timer_15min[i][1]=makeDynString("CLC.normalni_rezim.CO_VI.desna_cijev.15min_max_timer.T"+i+".IN");
              dp_timer_15min[i][2]=makeDynString("CLC.normalni_rezim.CO_VI.desna_cijev.15min_max_timer.T"+i+".Q");
              
              dpGet(dp_timer[i][2],timer_Q[i],
                    dp_timer_15min[i][2],timer_Q_15min[i]);
              
              TimerTON(dp_timer[i][1],false);
              TimerTON(dp_timer_15min[i][1],false);
              
                          
 
         }
      }
      else if(dp[strlen(dp)-1]=="L")
      { 
         dpSet("CLC.normalni_rezim.CO_VI.lijeva_cijev.mem",co_mem);
         
         for (int i=1;i<=4;i++)
         {    
           
              dp_timer[i][1]=makeDynString("CLC.normalni_rezim.CO_VI.lijeva_cijev.timer.T"+i+".IN");
              dp_timer[i][2]=makeDynString("CLC.normalni_rezim.CO_VI.lijeva_cijev.timer.T"+i+".Q");
              dp_timer_15min[i][1]=makeDynString("CLC.normalni_rezim.CO_VI.lijeva_cijev.15min_max_timer.T"+i+".IN");
              dp_timer_15min[i][2]=makeDynString("CLC.normalni_rezim.CO_VI.lijeva_cijev.15min_max_timer.T"+i+".Q");
              
              dpGet(dp_timer[i][2],timer_Q[i],
                    dp_timer_15min[i][2],timer_Q_15min[i]);
              
              TimerTON(dp_timer[i][1],false);
              TimerTON(dp_timer_15min[i][1],false);
              
          }
         
         
      }
     
     
      
      
     
     while(1)
     {
     
               dpGet(senzori_co[1]+".value.mjerenje",CO1_mjerenje,
                     senzori_co[1]+".state.servis",CO1_servis,
                     senzori_co[1]+".alarm.kvar",CO1_kvar,
                     senzori_co[1]+".alarm.150ppm_3km_15min",CO1_150ppm_alarm,
                     senzori_co[2]+".value.mjerenje",CO2_mjerenje,
                     senzori_co[2]+".state.servis",CO2_servis,
                     senzori_co[2]+".alarm.kvar",CO2_kvar,
                     senzori_co[2]+".alarm.150ppm_3km_15min",CO2_150ppm_alarm,
                     senzori_co[3]+".value.mjerenje",VI1_mjerenje,
                     senzori_co[3]+".state.servis",VI1_servis,
                     senzori_co[3]+".alarm.kvar",VI1_kvar,
                     senzori_co[3]+".alarm.150ppm_3km_15min",VI1_3km_alarm,
                     senzori_co[4]+".value.mjerenje",VI2_mjerenje,
                     senzori_co[4]+".state.servis",VI2_servis,
                     senzori_co[4]+".alarm.kvar",VI2_kvar,
                     senzori_co[4]+".alarm.150ppm_3km_15min",VI2_3km_alarm,
                     senzori_v[1]+".value.mjerenje",V1_mjerenje,
                     senzori_v[1]+".state.servis",V1_servis,
                     senzori_v[1]+".alarm.kvar",V1_kvar,
                     senzori_v[2]+".value.mjerenje",V2_mjerenje,
                     senzori_v[2]+".state.servis",V2_servis,
                     senzori_v[2]+".alarm.kvar",V2_kvar,
                     "CLC.incidentni_rezim.zagusenje",pozarni_rezim_zagusenje,
                     "CLC.incidentni_rezim.normalno",pozarni_rezim_normalno);
                                 
               
               
               if(dp[strlen(dp)-1]=="D")
               { 
                 
                   for (int i=1;i<=4;i++)
                   {
   
                        
                        dpGet(dp_timer[i][2],timer_Q[i],
                              dp_timer_15min[i][2],timer_Q_15min[i]);
                          
 
                   }
                   dpGet("CLC.normalni_rezim.CO_VI.desna_cijev.mem",co_mem);
                   
                }
               else if(dp[strlen(dp)-1]=="L")
               { 
                 
                   for (int i=1;i<=4;i++)
                   {
   
                        
                        dpGet(dp_timer[i][2],timer_Q[i],
                              dp_timer_15min[i][2],timer_Q_15min[i]);
                          
 
                   }
                   dpGet("CLC.normalni_rezim.CO_VI.lijeva_cijev.mem",co_mem);
                   
                }
               
               broj_senzora_co=0;
               broj_senzora_vi=0;
               CO_sr=0;
               VI_sr=0;
               
               if(!CO1_kvar && !CO1_servis && CO1_mjerenje>=0 && CO1_mjerenje<=300)
               {
                   broj_senzora_co++; 
                   CO_sr=CO_sr+CO1_mjerenje;             
               }
               if(!CO2_kvar && !CO2_servis && CO2_mjerenje>=0 && CO2_mjerenje<=300)
               {
                   broj_senzora_co++; 
                   CO_sr=CO_sr+CO2_mjerenje;             
               }
               
               if(!VI1_kvar && !VI1_servis && VI1_mjerenje>=0 && VI1_mjerenje<=15)
               {
                   broj_senzora_vi++; 
                   VI_sr=VI_sr+VI1_mjerenje;             
               }
               
               if(!VI2_kvar && !VI2_servis && VI2_mjerenje>=0 && VI1_mjerenje<=15)
               {
                   broj_senzora_vi++; 
                   VI_sr=VI_sr+VI2_mjerenje;             
               }
               
               if(broj_senzora_co>0)
               {
                    CO_sr=CO_sr/broj_senzora_co;
               }
               else
               {
                    CO_sr=0; 
               }
               if(broj_senzora_vi>0)
               {
                    VI_sr=VI_sr/broj_senzora_vi;
               }
               else
               {
                    VI_sr=15;
               }
               
               
               
               
               if(co_mem[1] && !pozarni_rezim_zagusenje && !pozarni_rezim_normalno)
               {
                  if((CO1_mjerenje>=50 && !CO1_kvar && !CO1_servis && CO1_mjerenje>=0 && CO1_mjerenje<=300) || (CO2_mjerenje>=50 && !CO2_kvar && !CO2_servis && CO2_mjerenje>=0 && CO2_mjerenje<=300) ||
                     (VI1_mjerenje<=8 && !VI1_kvar && !VI1_servis && VI1_mjerenje>=0 && VI1_mjerenje<=15) || (VI2_mjerenje<=8 && !VI2_kvar && !VI2_servis && VI2_mjerenje>=0 && VI2_mjerenje<=15))
                  {
                    
                        TimerTON(dp_timer[1][1],true,60,true);
                        
                        if(timer_Q[1] && !v_akt_sekv)
                        {
                           SetCoil(co_mem[2]);
                           ResetCoil(co_mem[1]);
                           TimerTON(dp_timer[1][1],false);                                                
                           
                           for(int i=1;i<=8;i++)
                           {
                               if(i<=4)
                               {
                                  dpSet(ventilatori[i]+".cmd.sdv.automatski.naprijed",true,
                                        ventilatori[i]+".cmd.sdv.automatski.nazad",false);
                               }
                               else
                               {
                                  dpSet(ventilatori[i]+".cmd.sdv.automatski.naprijed",false,
                                        ventilatori[i]+".cmd.sdv.automatski.nazad",false);
                               
                               }
                                 
                           }                           
                                
                        }
                        
                  }
                  else
                  {
                   
                     TimerTON(dp_timer[1][1],false);
                   
                  }
                  
                  
                }
               if(co_mem[2] && !pozarni_rezim_zagusenje && !pozarni_rezim_normalno)
               {
                  if((CO1_mjerenje>=75 && !CO1_kvar && !CO1_servis && CO1_mjerenje>=0 && CO1_mjerenje<=300) || (CO2_mjerenje>=75 && !CO2_kvar && !CO2_servis && CO2_mjerenje>=0 && CO2_mjerenje<=300) ||
                     (VI1_mjerenje<=6 && !VI1_kvar && !VI1_servis && VI1_mjerenje>=0 && VI1_mjerenje<=15) || (VI2_mjerenje<=6 && !VI2_kvar && !VI2_servis && VI2_mjerenje>=0 && VI2_mjerenje<=15))
                  {
                         
                        TimerTON(dp_timer[2][1],true,60,true);
                        
                        if(timer_Q[2])
                        {
                           SetCoil(co_mem[3]);
                           ResetCoil(co_mem[2]);
                           TimerTON(dp_timer[2][1],false);
                           
                           for(int i=1;i<=8;i++)
                           {
                               if(i<=6)
                               {
                                  dpSet(ventilatori[i]+".cmd.sdv.automatski.naprijed",true,
                                        ventilatori[i]+".cmd.sdv.automatski.nazad",false);
                               }
                               else
                               {
                                  dpSet(ventilatori[i]+".cmd.sdv.automatski.naprijed",false,
                                        ventilatori[i]+".cmd.sdv.automatski.nazad",false);
                               
                               }
                                 
                           }      
                                 
                        }
                        
                   }
                  
                  else if(CO_sr<=35 || VI_sr>=9)
                  {
                         
                         TimerTON(dp_timer[2][1],true,300,true);
                         
                         if(timer_Q[2])
                         {
                            SetCoil(co_mem[5]);
                            ResetCoil(co_mem[2]);
                            TimerTON(dp_timer[2][1],false);
                        }
        
                  }
                  else
                  {
                         TimerTON(dp_timer[2][1],false);
                  
                  }                  
     
               }
               if(co_mem[3] && !pozarni_rezim_zagusenje && !pozarni_rezim_normalno)
               {
                  if((CO1_mjerenje>=100 && !CO1_kvar && !CO1_servis && CO1_mjerenje>=0 && CO1_mjerenje<=300) || (CO2_mjerenje>=100 && !CO2_kvar && !CO2_servis && CO2_mjerenje>=0 && CO2_mjerenje<=300) ||
                     (VI1_mjerenje<=6 && !VI1_kvar && !VI1_servis && VI1_mjerenje>=0 && VI1_mjerenje<=15) || (VI2_mjerenje<=6 && !VI2_kvar && !VI2_servis && VI2_mjerenje>=0 && VI2_mjerenje<=15))
                  {
                        TimerTON(dp_timer[3][1],true,60,true);
                        
                        if(timer_Q[3])
                        {
                           SetCoil(co_mem[4]);
                           ResetCoil(co_mem[3]);
                           TimerTON(dp_timer[3][1],false);
                           for(int i=1;i<=8;i++)
                           {
                               
                               dpSet(ventilatori[i]+".cmd.sdv.automatski.naprijed",true,
                                     ventilatori[i]+".cmd.sdv.automatski.nazad",false);                            
                                
                           }      
                                 
                        }
                  }
                  else if(CO_sr<=35 || VI_sr>=9)
                  {
                         TimerTON(dp_timer[3][1],true,300,true);
                         
                         if(timer_Q[3])
                         {
                             SetCoil(co_mem[5]);
                             ResetCoil(co_mem[3]);
                             TimerTON(dp_timer[3][1],false);
                         }
        
                  }
                  else
                  {
                         TimerTON(dp_timer[3][1],false);                  
                  }
        
        
     
               }
               if(co_mem[4])
               {
        
                  
                  
                  
                  if(CO_sr<=35 && VI_sr>=9)
                  {
                        TimerTON(dp_timer[4][1],true,60,true);
                        
                        if(timer_Q[4])
                        {
                           SetCoil(co_mem[5]);
                           ResetCoil(co_mem[4]);
                           TimerTON(dp_timer[4][1],false); 
                                 
                        }
        
                  }
                  else
                  {
                       TimerTON(dp_timer[4][1],false);                
                  }
                  
        
        
     
               }
               if(co_mem[5] && !pozarni_rezim_zagusenje && !pozarni_rezim_normalno)
               {
                  SetCoil(co_mem[1]);
                  ResetCoil_BF(co_mem,2,5);
                  
                  for(int i=1;i<=8;i++)
                  {
                               
                      dpSet(ventilatori[i]+".cmd.sdv.automatski.naprijed",false,
                            ventilatori[i]+".cmd.sdv.automatski.nazad",false);                            
                                
                  }   
              
               }
               if(co_mem[2] || co_mem[3] || co_mem[4] || co_mem[5] || co_mem[6] || co_mem[7] || co_mem[8])
               {
                  SetCoil(akt_sekv);   
               }
               else
               {
                  ResetCoil(akt_sekv);
               }

              
               
               
               if(CO1_mjerenje>=150 && !CO1_kvar && !CO1_servis && CO1_mjerenje>=0 && CO1_mjerenje<=300)
               {
                     TimerTON(dp_timer_15min[1][1],true,900,true);
                     dpGet(dp_timer_15min[1][2],timer_Q_15min[1]);
                     if(timer_Q_15min[1])
                     {
                        dpSet(senzori_co[1]+".alarm.150ppm_3km_15min",true);
                     
                     }
                 
               }
               else 
               {
                     TimerTON(dp_timer_15min[1][1],false);
                     
                     if(CO1_150ppm_alarm && (CO1_mjerenje<=75 && !CO1_kvar && !CO1_servis && CO1_mjerenje>=0 && CO1_mjerenje<=300))
                     {
                        dpSet(senzori_co[1]+".alarm.150ppm_3km_15min",false);
                     }
               
               }
               
               if(CO2_mjerenje>=150 && !CO2_kvar && !CO2_servis && CO2_mjerenje>=0 && CO2_mjerenje<=300)
               {
                     TimerTON(dp_timer_15min[2][1],true,900,true);
                     dpGet(dp_timer_15min[2][2],timer_Q_15min[2]);
                     if(timer_Q_15min[2])
                     {
                        dpSet(senzori_co[2]+".alarm.150ppm_3km_15min",true);
                     
                     }
                 
               }
               else
               {
                     TimerTON(dp_timer_15min[2][1],false);
                     
                     if(CO2_150ppm_alarm && (CO2_mjerenje<=75 && !CO2_kvar && !CO2_servis && CO2_mjerenje>=0 && CO2_mjerenje<=300))
                     {
                        dpSet(senzori_co[2]+".alarm.150ppm_3km_15min",false);
                     }
               
               }
               
               if (VI1_mjerenje<=3 && !VI1_kvar && !VI1_servis && VI1_mjerenje>=0 && VI1_mjerenje<=15)
               {
                     TimerTON(dp_timer_15min[3][1],true,900,true);
                     dpGet(dp_timer_15min[3][2],timer_Q_15min[3]);
                     if(timer_Q_15min[3])
                     {
                        dpSet(senzori_co[3]+".alarm.150ppm_3km_15min",true);
                     
                     }
                 
               }
               else
               {
                     TimerTON(dp_timer_15min[3][1],false);
                     
                     if(VI1_3km_alarm && (VI1_mjerenje>=6 && !VI1_kvar && !VI1_servis && VI1_mjerenje>=0 && VI1_mjerenje<=15))
                     {
                        dpSet(senzori_co[3]+".alarm.150ppm_3km_15min",false);
                     }
               
               }
               
               if (VI2_mjerenje<=3 && !VI2_kvar && !VI2_servis && VI2_mjerenje>=0 && VI2_mjerenje<=15)
               {
                     TimerTON(dp_timer_15min[4][1],true,900,true);
                     dpGet(dp_timer_15min[4][2],timer_Q_15min[4]);
                     if(timer_Q_15min[4])
                     {
                        dpSet(senzori_co[4]+".alarm.150ppm_3km_15min",true);
                     
                     }
                 
               }
               else
               {
                     TimerTON(dp_timer_15min[4][1],false);
                     
                     if(VI2_3km_alarm && (VI2_mjerenje>=6 && !VI2_kvar && !VI2_servis && VI2_mjerenje>=0 && VI2_mjerenje<=15))
                     {
                        dpSet(senzori_co[4]+".alarm.150ppm_3km_15min",false);
                     }
               
               }
               
               
                   if(!V1_kvar && !V1_servis && V1_mjerenje>=-20 && V1_mjerenje<=20)
                   {
                         broj_senzora++;
                         Vsr=Vsr+V1_mjerenje;
                            
                   }
                   if(!V2_kvar && !V2_servis && V2_mjerenje>=-20 && V2_mjerenje<=20)
                   {
                         broj_senzora++;
                         Vsr=Vsr+V2_mjerenje;
                            
                   }
                   if(broj_senzora>0)
                   {        
                     Vsr=Vsr/broj_senzora; 
                   }
                  
                   if(Vsr>=8 && !v_akt_sekv)
                   {
                       SetCoil(v_akt_sekv);                      
                       ResetCoil_BF(co_mem,2,5);
                       
                       dpSet("CLC.normalni_rezim.vrijeme.24h.mem",mem_24h,                             
                             "CLC.normalni_rezim.vrijeme.sedmica.mem",mem_sedmica);
                       
                       for(int i=1;i<=8;i++)
                       {
                          dpSet(ventilatori[i]+".cmd.sdv.automatski.nazad",false,
                                ventilatori[i]+".cmd.sdv.automatski.naprijed",false);                                                   
                       } 
                       delay(2);
                       
                       for(int i=1;i<=8;i++)
                       {
                          dpSet(ventilatori[i]+".cmd.sdv.automatski.nazad",true);                                                   
                       } 
                       
                          
    
                   } 
                   
                   else if(Vsr<=-8 && !v_akt_sekv)
                   {
                       SetCoil(v_akt_sekv);
                       ResetCoil_BF(co_mem,2,5);
                       
                       dpSet("CLC.normalni_rezim.vrijeme.24h.mem",mem_24h,                             
                             "CLC.normalni_rezim.vrijeme.sedmica.mem",mem_sedmica);
                       
                       for(int i=1;i<=8;i++)
                       {
                          dpSet(ventilatori[i]+".cmd.sdv.automatski.nazad",false,
                                ventilatori[i]+".cmd.sdv.automatski.naprijed",false);                                                   
                       } 
                       delay(2);
                       
                       for(int i=1;i<=8;i++)
                       {
                          dpSet(ventilatori[i]+".cmd.sdv.automatski.naprijed",true);                                                   
                       } 
                   
                   }
                   else if(Vsr<=4 && Vsr>=-4 && v_akt_sekv)
                   {
                       ResetCoil(v_akt_sekv);
                       SetCoil(co_mem[1]);
                       SetCoil(mem_24h[1]);
                       SetCoil(mem_sedmica[1]);
                       dpSet("CLC.normalni_rezim.vrijeme.24h.mem",mem_24h,                             
                             "CLC.normalni_rezim.vrijeme.sedmica.mem",mem_sedmica);
                       
                       for(int i=1;i<=8;i++)
                       {
                          dpSet(ventilatori[i]+".cmd.sdv.automatski.nazad",false,
                                ventilatori[i]+".cmd.sdv.automatski.naprijed",false);
                       }
                            
                   
                   }
                   
                   broj_senzora=0;
                   Vsr=0;
               
               
               
               if(dp[strlen(dp)-1]=="D")
               { 
                   dpSet("CLC.normalni_rezim.CO_VI.desna_cijev.mem",co_mem,
                         "CLC.normalni_rezim.CO_VI.desna_cijev.akt_sekv",akt_sekv);
                        
               
               }
               else if(dp[strlen(dp)-1]=="L")
               { 
                   dpSet("CLC.normalni_rezim.CO_VI.lijeva_cijev.mem",co_mem,
                         "CLC.normalni_rezim.CO_VI.lijeva_cijev.akt_sekv",akt_sekv);
               
               } 
               
               delay(0,200);
       
       
       
       
       
       
     }
     
     
     
     
     



}

//iControl je varijabla da znamo o kojem threadu se radi
sistem_start(dyn_string ventilatori_grupa, int iControl)
{
  
  int sekvenca;
  bool cmd_rov_pgs1_rezim,cmd_rov_pgs1_desno,cmd_rov_pgs1_lijevo,
       cmd_rov_pgs2_rezim,cmd_rov_pgs2_desno,cmd_rov_pgs2_lijevo,
       cmd_sdv_aut_rezim,cmd_sdv_aut_desno,cmd_sdv_aut_lijevo,
       cmd_sdv_man_rezim,cmd_sdv_man_desno,cmd_sdv_man_lijevo;
  
  int brojac = 0;  
  
  
  
  while(1)
  {
      
    
     
    
      for(int i=1;i<=8;i++)
      { 
         
       
           dpGet(ventilatori_grupa[i]+".cmd.rov.manuelno.pgs1.rezim",cmd_rov_pgs1_rezim,
                 ventilatori_grupa[i]+".cmd.rov.manuelno.pgs1.naprijed",cmd_rov_pgs1_desno,
                 ventilatori_grupa[i]+".cmd.rov.manuelno.pgs1.nazad",cmd_rov_pgs1_lijevo,                
                 ventilatori_grupa[i]+".cmd.rov.manuelno.pgs2.rezim",cmd_rov_pgs2_rezim,
                 ventilatori_grupa[i]+".cmd.rov.manuelno.pgs2.naprijed",cmd_rov_pgs2_desno,
                 ventilatori_grupa[i]+".cmd.rov.manuelno.pgs2.nazad",cmd_rov_pgs2_lijevo,
                 ventilatori_grupa[i]+".cmd.sdv.automatski.rezim",cmd_sdv_aut_rezim,
                 ventilatori_grupa[i]+".cmd.sdv.automatski.naprijed",cmd_sdv_aut_desno,
                 ventilatori_grupa[i]+".cmd.sdv.automatski.nazad",cmd_sdv_aut_lijevo,
                 ventilatori_grupa[i]+".cmd.sdv.manuelno.rezim",cmd_sdv_man_rezim,
                 ventilatori_grupa[i]+".cmd.sdv.manuelno.naprijed",cmd_sdv_man_desno,
                 ventilatori_grupa[i]+".cmd.sdv.manuelno.nazad",cmd_sdv_man_lijevo,
                 ventilatori_grupa[i]+".state.sekvenca",sekvenca);
                                
           
           if (((cmd_rov_pgs1_rezim && (cmd_rov_pgs1_desno || cmd_rov_pgs1_lijevo))||
              (cmd_rov_pgs2_rezim && (cmd_rov_pgs2_desno || cmd_rov_pgs2_lijevo))||
              (cmd_sdv_aut_rezim && (cmd_sdv_aut_desno || cmd_sdv_aut_lijevo))||
              (cmd_sdv_man_rezim && (cmd_sdv_man_desno || cmd_sdv_man_lijevo))) && (sekvenca==0 || sekvenca==1 || sekvenca==2))
           {
                           
                dpSet(ventilatori_grupa[i]+".function.aktivan",true);
                thread_alive(iControl);
                delay(9);
                
                dpSet(ventilatori_grupa[i]+".function.aktivan",false);
             
           }
           
           
           
           
           
      }   
           
      //samo za logiranje    
      brojac++;
      if(brojac == 30) {
        DebugFTN("level1", "Thread sistem start izvrsen ", iControl); 
        brojac = 0;        
       thread_alive(iControl);
      }
      //end samo za logiranje
      
      delay(0,100);
     // DebugN("state:",ventilatori_grupa); 
    }
}

//fc za upis u varijalblu SysSarani:grupa_x.control_thread_X"
//ako se redovno upisuje u ovu varijablu smatramo da thread radi, ako ne thread ne radi i ne moze se upravljati ventilatorima
thread_alive(int iControl)
{
   if(myReduHostNum() == 1)
        { 
          if(iControl == 1)
            dpSet("SysSarani:grupa_1.control_thread", 1);
          else if(iControl == 2)
            dpSet("SysSarani:grupa_2.control_thread", 2);
        }
        else
        { 
          if(iControl == 1)
            dpSet("SysSarani:grupa_1.control_thread_2", 1);
          else if(iControl == 2)
            dpSet("SysSarani:grupa_2.control_thread_2", 2);
        }
}

ventilator(string dp1,bool clock_state, string dp2,bool glavni_prekidac, string dp3, bool ups_aktivan)

{ 
   // DebugN("state:",getCurrentTime());  
     
     
     dyn_dyn_string  dp_timer;
     string dp,OA_V1_test="OA-V1.A5.state.bit.b2",OA_V2_test="OA-V2.A5.state.bit.b2";
     dyn_bool timer_Q, pgs1_mem=makeDynBool(false,false,false,false,false,false,false,false,false,false);
     dyn_string klapna=makeDynString("Klapna01_1D-2","Klapna02_2D-2",
                                     "Klapna03_1D-4","Klapna04_2D-4",
                                     "Klapna05_1D-6","Klapna06_2D-6",
                                     "Klapna07_1L-2","Klapna08_2L-2",
                                     "Klapna09_1L-4","Klapna10_2L-4",
                                     "Klapna11_1L-6","Klapna12_2L-6");                            
     int sekvenca,prioritet=0,grupa_prioritet=0,vrijeme_zaustavljanja=90;
     float vibracije_mjerenje;
     bool cmd_rov_pgs1_rezim,cmd_rov_pgs1_desno,cmd_rov_pgs1_lijevo,pgs1_akt_sekv,
          cmd_rov_pgs2_rezim,cmd_rov_pgs2_desno,cmd_rov_pgs2_lijevo,pgs2_akt_sekv,
          cmd_sdv_aut_rezim,cmd_sdv_aut_desno,cmd_sdv_aut_lijevo,sdv_aut_akt_sekv,
          cmd_sdv_man_rezim,cmd_sdv_man_desno,cmd_sdv_man_lijevo,sdv_man_akt_sekv,
          state_desno,state_lijevo,kvar,servis,kvar_state,vibracije_aktiv,
          cmd_run_naprijed,cmd_run_nazad,cmd_run_pozarni_rezim,pozarni_rezim_zagusenje,pozarni_rezim_normalno,          
          cmd_led_naprijed,cmd_led_naprijed_pgs1,cmd_led_naprijed_pgs2,cmd_rov_aut_rezim,     
          cmd_led_nazad,cmd_led_nazad_pgs1,cmd_led_nazad_pgs2,aktivan_start,cmd_lijevo,cmd_desno,vent_aktivan,
          klapna_otvorena,klapna_zatvorena,ups_aktiviran,zbirni_kvar,test_v1,test_v2,driver_not_active,driver_iskljucen;
     
     dp=substr(dp1,0,strlen(dp1)-30);
     
    // DebugN("string:",dp); 
     
     for (int i=1;i<=7;i++)
     {
   
        dp_timer[i][1]=makeDynString(dp+"function.T"+i+".IN");
        dp_timer[i][2]=makeDynString(dp+"function.T"+i+".Q");
        dpGet(dp_timer[i][2],timer_Q[i]);
 
     }
     dpGet(OA_V1_test,test_v1,OA_V2_test,test_v2);
     
     dpGet(dp+"cmd.rov.automatski.rezim",cmd_rov_aut_rezim,          
           dp+"cmd.rov.manuelno.pgs1.rezim",cmd_rov_pgs1_rezim,
           dp+"cmd.rov.manuelno.pgs1.naprijed",cmd_rov_pgs1_desno,
           dp+"cmd.rov.manuelno.pgs1.nazad",cmd_rov_pgs1_lijevo,
           dp+"function.pgs1",pgs1_akt_sekv,
           dp+"cmd.rov.manuelno.pgs2.rezim",cmd_rov_pgs2_rezim,
           dp+"cmd.rov.manuelno.pgs2.naprijed",cmd_rov_pgs2_desno,
           dp+"cmd.rov.manuelno.pgs2.nazad",cmd_rov_pgs2_lijevo,
           dp+"function.pgs2",pgs2_akt_sekv,
           dp+"cmd.sdv.automatski.rezim",cmd_sdv_aut_rezim,
           dp+"cmd.sdv.automatski.naprijed",cmd_sdv_aut_desno,
           dp+"cmd.sdv.automatski.nazad",cmd_sdv_aut_lijevo,
           dp+"function.aut_sdv",sdv_aut_akt_sekv,
           dp+"cmd.sdv.manuelno.rezim",cmd_sdv_man_rezim,
           dp+"cmd.sdv.manuelno.naprijed",cmd_sdv_man_desno,
           dp+"cmd.sdv.manuelno.nazad",cmd_sdv_man_lijevo,
           dp+"function.man_sdv",sdv_man_akt_sekv,
           dp+"cmd.run.naprijed_motor",cmd_run_naprijed,
           dp+"cmd.run.nazad_motor",cmd_run_nazad,
           dp+"cmd.run.pozar",cmd_run_pozarni_rezim,
           dp+"function.man_sdv",sdv_man_akt_sekv,
           dp+"function.v_mem",pgs1_mem,
           dp+"function.aktivan",vent_aktivan,
           dp+"state.naprijed",state_desno,
           dp+"state.nazad",state_lijevo,
           dp+"state.sekvenca",sekvenca,
           dp+"alarm.kvar",kvar,
           dp+"alarm.servis",servis,
           dp+"alarm.kvar_state",kvar_state,
           dp+"alarm.vibracije.aktiv",vibracije_aktiv,
           dp+"alarm.vibracije.value",vibracije_mjerenje,
           dp+"alarm.ups_aktiviran",ups_aktiviran,
           dp+"cmd.led.kvar",zbirni_kvar);
     
     dpGet("CLC.incidentni_rezim.zagusenje",pozarni_rezim_zagusenje,
           "CLC.incidentni_rezim.normalno",pozarni_rezim_normalno);
           
     servis=!servis;
     
     if(!pgs1_mem[1] && !pgs1_mem[2] && !pgs1_mem[3] && !pgs1_mem[4] && !pgs1_mem[5] && 
        !pgs1_mem[6] && !pgs1_mem[7] && !pgs1_mem[8] && !driver_iskljucen && !driver_not_active)
     {
          SetCoil(pgs1_mem[1]);   
     }
     if(dp[strlen(dp)-3]=="1")
     {
          dpGet("grupa_1.aktivan_start",aktivan_start,
                "RO-V1.state.gubitak_komunikacije",driver_not_active,
                "grupa_1.driver_iskljucen",driver_iskljucen);
          
     }
     
    // dpGet("grupa_1.aktivan_start",aktivan_start);
      if(dp[strlen(dp)-3]=="2")
     {
          dpGet("grupa_2.aktivan_start",aktivan_start,
                "RO-V2.state.gubitak_komunikacije",driver_not_active,
                "grupa_2.driver_iskljucen",driver_iskljucen);
     }
     
     /*
     if(pozarni_rezim_zagusenje || pozarni_rezim_normalno)
     {
          vrijeme_zaustavljanja=20;
                     
     }
     else if(!pozarni_rezim_zagusenje && !pozarni_rezim_normalno)
     {
          vrijeme_zaustavljanja=90; 
     }
     */ 
     
     /* 
     if(kvar || !servis)
     {
        SetCoil(pgs1_mem[1]);
        ResetCoil_BF(pgs1_mem,2,10);
        if(prioritet>0)
        {
           prioritet=0; 
           grupa_prioritet--;
        } 
     }
     */
     
     
     if (cmd_rov_pgs1_rezim && !pgs2_akt_sekv)
     {
         SetCoil(pgs1_akt_sekv);
         cmd_lijevo=cmd_rov_pgs1_lijevo;
         cmd_desno=cmd_rov_pgs1_desno;
          dpSet(dp+"cmd.sdv.manuelno.naprijed",false,
                dp+"cmd.sdv.manuelno.nazad",false,
                dp+"cmd.sdv.automatski.naprijed",false,
                dp+"cmd.sdv.automatski.nazad",false);
               
       
     }
     else
     {
         ResetCoil(pgs1_akt_sekv);    
     
     }
     
     if (cmd_rov_pgs2_rezim && !pgs1_akt_sekv)
     {
         SetCoil(pgs2_akt_sekv);
         cmd_lijevo=cmd_rov_pgs2_lijevo;
         cmd_desno=cmd_rov_pgs2_desno;
         
         dpSet(dp+"cmd.sdv.manuelno.naprijed",false,
                dp+"cmd.sdv.manuelno.nazad",false,
                dp+"cmd.sdv.automatski.naprijed",false,
                dp+"cmd.sdv.automatski.nazad",false);
       
     }
     else
     {
         ResetCoil(pgs2_akt_sekv);       
     
     }
     
     if (cmd_sdv_aut_rezim && !cmd_rov_pgs1_rezim && !cmd_rov_pgs2_rezim && cmd_rov_aut_rezim)
     {
         SetCoil(sdv_aut_akt_sekv);
         cmd_lijevo=cmd_sdv_aut_lijevo;
         cmd_desno=cmd_sdv_aut_desno;
         
         dpSet(dp+"cmd.sdv.manuelno.naprijed",false,
               dp+"cmd.sdv.manuelno.nazad",false);
       
     }
     else
     {
         ResetCoil(sdv_aut_akt_sekv);        
     
     }
     
     if (cmd_sdv_man_rezim && !cmd_rov_pgs1_rezim && !cmd_rov_pgs2_rezim && cmd_rov_aut_rezim)
     {
         SetCoil(sdv_man_akt_sekv);
         cmd_lijevo=cmd_sdv_man_lijevo;
         cmd_desno=cmd_sdv_man_desno;
         
         dpSet(dp+"cmd.sdv.automatski.naprijed",false,
               dp+"cmd.sdv.automatski.nazad",false);
       
     }
     else
     {
         ResetCoil(sdv_man_akt_sekv);        
     
     }
     
     if(vibracije_mjerenje>=17)
     {
        SetCoil(vibracije_aktiv);
        //ResetCoil_BF(pgs1_mem,1,8); 
     }
     else
     {
         //SetCoil(pgs1_mem[1]); 
         ResetCoil(vibracije_aktiv);
     }
     /*
     if(kvar_state || glavni_prekidac || kvar || servis)
     {
         dpSet(dp+"cmd.sdv.automatski.naprijed",false,
               dp+"cmd.sdv.automatski.nazad",false,
               dp+"cmd.sdv.manuelno.naprijed",false,
               dp+"cmd.sdv.manuelno.nazad",false);
     }
     
     */
     
     if(ups_aktivan)
     {
        SetCoil(ups_aktiviran);  
        
        
            
     }
     else if(!ups_aktivan && ups_aktiviran)
     {
        TimerTON(dp_timer[7][1],true,90,true);
        
              
        if (timer_Q[7])
        {                      
            ResetCoil(ups_aktiviran); 
            TimerTON(dp_timer[7][1],false);      
        }
        
        
     }
     
     else if(driver_not_active)
     {
        if(dp[strlen(dp)-3]=="1")
        {
           dpSet("grupa_1.driver_iskljucen",true);                       
        }        
        if(dp[strlen(dp)-3]=="2")
        {
           dpSet("grupa_2.driver_iskljucen",true);  
        }
        
        
          
     
     }
     else if(!driver_not_active && driver_iskljucen)
     {
         
        TimerTON(dp_timer[7][1],true,90,true);
                   
        if (timer_Q[7])
        {                      
            if(dp[strlen(dp)-3]=="1")
            {
               dpSet("grupa_1.driver_iskljucen",false);                       
            }        
            if(dp[strlen(dp)-3]=="2")
            {
               dpSet("grupa_2.driver_iskljucen",false);  
            }  
            TimerTON(dp_timer[7][1],false);      
        }
     
     }
     else
     {
        TimerTON(dp_timer[7][1],false);
     }
     
     
     
     
       
                      if(dp[strlen(dp)-4]=="D")
                      {
                           
                           
                           if(dp[strlen(dp)-2]=="2")
                           {
                               if(dp[strlen(dp)-5]=="1")
                               {
                                   //DebugN("string",strlen(dp));
                                  // DebugN("char",dp[strlen(dp)-1]);
                                   
                                   dpGet(klapna[1]+".state.otvorena",klapna_otvorena,
                                         klapna[1]+".state.zatvorena",klapna_zatvorena);
                                   
                                  
                               }
                               else if(dp[strlen(dp)-5]=="2")
                               {
                                   dpGet(klapna[2]+".state.otvorena",klapna_otvorena,
                                         klapna[2]+".state.zatvorena",klapna_zatvorena);
                                   
                                   
                               }
                           }
                           else if(dp[strlen(dp)-2]=="4")
                           {
                               if(dp[strlen(dp)-5]=="1")
                               {
                                   dpGet(klapna[3]+".state.otvorena",klapna_otvorena,
                                         klapna[3]+".state.zatvorena",klapna_zatvorena);
                                   
                                   
                               }
                               else if(dp[strlen(dp)-5]=="2")
                               {
                                   dpGet(klapna[4]+".state.otvorena",klapna_otvorena,
                                         klapna[4]+".state.zatvorena",klapna_zatvorena);
                                   
                                   
                               }   
                           }
                           else if(dp[strlen(dp)-2]=="6")
                           {
                               if(dp[strlen(dp)-5]=="1")
                               {
                                   dpGet(klapna[5]+".state.otvorena",klapna_otvorena,
                                         klapna[5]+".state.zatvorena",klapna_zatvorena);
                                   
                                   
                               }
                               else if(dp[strlen(dp)-5]=="2")
                               {
                                   dpGet(klapna[6]+".state.otvorena",klapna_otvorena,
                                         klapna[6]+".state.zatvorena",klapna_zatvorena);
                                   
                                   
                               }    
                           }
                          
                      }
                      
                      else if(dp[strlen(dp)-4]=="L")
                      {
                           if(dp[strlen(dp)-2]=="2")
                           {
                               if(dp[strlen(dp)-5]=="1")
                               {
                                   dpGet(klapna[7]+".state.otvorena",klapna_otvorena,
                                         klapna[7]+".state.zatvorena",klapna_zatvorena);
                                        
                                   
                               }
                               else if(dp[strlen(dp)-5]=="2")
                               {
                                   dpGet(klapna[8]+".state.otvorena",klapna_otvorena,
                                         klapna[8]+".state.zatvorena",klapna_zatvorena);
                                   
                                   
                               }
                           }
                           else if(dp[strlen(dp)-2]=="4")
                           {
                               if(dp[strlen(dp)-5]=="1")
                               {
                                   dpGet(klapna[9]+".state.otvorena",klapna_otvorena,
                                         klapna[9]+".state.zatvorena",klapna_zatvorena);
                                   
                                   
                               }
                               else if(dp[strlen(dp)-5]=="2")
                               {
                                   dpGet(klapna[10]+".state.otvorena",klapna_otvorena,
                                         klapna[10]+".state.zatvorena",klapna_zatvorena);
                                   
                                   
                               }   
                           }
                           else if(dp[strlen(dp)-2]=="6")
                           {
                               if(dp[strlen(dp)-5]=="1")
                               {
                                   dpGet(klapna[11]+".state.otvorena",klapna_otvorena,
                                         klapna[11]+".state.zatvorena",klapna_zatvorena);
                                   
                                   
                               }
                               else if(dp[strlen(dp)-5]=="2")
                               {
                                   dpGet(klapna[12]+".state.otvorena",klapna_otvorena,
                                         klapna[12]+".state.zatvorena",klapna_zatvorena);
                                   
                                   
                               }    
                           }
                          
                      }
       
       
       //  DebugN("mem:",pgs1_mem[1]);          
                              
             
                 if(pgs1_mem[1])
                 {
                        
                      if((cmd_lijevo && !cmd_desno)||(!cmd_lijevo && cmd_desno))
                      { 
                          
                          if(dp[strlen(dp)-4]=="D" || dp[strlen(dp)-4]=="L")
                          {
                             SetCoil(pgs1_mem[2]);
                             ResetCoil(pgs1_mem[1]);
                          }
                          else if(!driver_iskljucen)
                          {
                             SetCoil(pgs1_mem[2]);
                             ResetCoil(pgs1_mem[1]);
                          }
                        
                          /*
                          if(dp[strlen(dp)-4]=="D" || dp[strlen(dp)-4]=="L")
                          {
                             SetCoil(pgs1_mem[2]);
                             ResetCoil(pgs1_mem[1]);
                          }
                          else if(!state_lijevo && !state_desno)     
                          {  
                             SetCoil(pgs1_mem[2]);
                             ResetCoil(pgs1_mem[1]);
                          }
                          else if(!cmd_run_pozarni_rezim && (state_lijevo || state_desno))
                          {
                             SetCoil(pgs1_mem[5]);
                             ResetCoil(pgs1_mem[1]);
                          }
                          else if(cmd_run_pozarni_rezim && (state_lijevo || state_desno))
                          {
                             SetCoil(pgs1_mem[8]);
                             ResetCoil(pgs1_mem[1]);
                          }
                          */
                                                  
                        
                      }
                 
                 }
                 
             //    dp[strlen(dp)-2]=="2" || dp[strlen(dp)-2]=="4" || dp[strlen(dp)-2]=="6"
                 
                 
                 
                 if(pgs1_mem[2])
                 {
                 
                     
                      
                     if(dp[strlen(dp)-4]=="D" || dp[strlen(dp)-4]=="L")
                     {
                       
                           if(prioritet==0 && (!kvar && !servis) && (klapna_otvorena && !klapna_zatvorena))
                           {
                               SetCoil(pgs1_mem[4]);
                               ResetCoil(pgs1_mem[2]);
                      
                           }
                           else 
                           {
                               SetCoil(pgs1_mem[8]);
                               ResetCoil(pgs1_mem[2]);
                           }


                           
                           
                     }
                    else
                    {
                           if(prioritet==0 && (!kvar && !servis && glavni_prekidac && !vibracije_aktiv))
                           {
                                                                                          
                               SetCoil(pgs1_mem[3]);
                               ResetCoil(pgs1_mem[2]);
                      
                           }
                          
                           else 
                           {
                               SetCoil(pgs1_mem[8]);
                               ResetCoil(pgs1_mem[2]);
                           }
                           
                           
                    
                    
                    
                    } 
                 
                 }
                 
                 if(pgs1_mem[3])
                 {
                         
                      
                      
                       if(vent_aktivan)
                      {                                                                     
                         SetCoil(pgs1_mem[4]);
                         ResetCoil(pgs1_mem[3]);                                                
                      }
                      
                                           
                 
                 
                    
                    
                 }
                 if(pgs1_mem[4])
                 {
                 
                      
                    if (timer_Q[2])
                    { 
                       if(state_lijevo || state_desno)
                       {
                          SetCoil(pgs1_mem[5]);
                          ResetCoil(pgs1_mem[4]);
                          ResetCoil(kvar_state);
                       }
                       else
                       {
                          
                         
                          SetCoil(kvar_state);
                          
                          if(cmd_lijevo==0 && cmd_desno==0)
                          {
                             SetCoil(pgs1_mem[8]);
                             ResetCoil(pgs1_mem[4]);
                          }
                          
                       }
                    }
                    
                             
                 }
                 if(pgs1_mem[5])
                 {
                 
                      
                    if (timer_Q[3])
                    { 
                       SetCoil(pgs1_mem[6]);
                       ResetCoil(pgs1_mem[5]);
                       
                    }
                    
                    
                             
                 }
                 
                 if(pgs1_mem[6])
                 {
                 
                     if((cmd_desno && !state_desno) || (cmd_lijevo && !state_lijevo) || driver_not_active)
                     {
                       
                           SetCoil(pgs1_mem[7]);
                           ResetCoil(pgs1_mem[6]);
                           
                           
                     
                     }                    
                     else
                     {
                     
                               if(dp[strlen(dp)-4]=="D" || dp[strlen(dp)-4]=="L")
                               {
                                     if(klapna_zatvorena ||((!cmd_lijevo && !cmd_desno)) || kvar || servis)
                                     {
                                           SetCoil(pgs1_mem[8]);
                                           ResetCoil(pgs1_mem[6]); 
                                     }
                           
                               }
                               else
                               { 
                   
                   
                                             if(!glavni_prekidac || kvar || servis || (vibracije_aktiv && !cmd_run_pozarni_rezim))
                                             {
                                                       SetCoil(pgs1_mem[7]);
                                                       ResetCoil(pgs1_mem[6]);
                       
                                             }
                                             else if(cmd_run_pozarni_rezim && !pozarni_rezim_zagusenje && !pozarni_rezim_normalno)
                                             {
                                                       SetCoil(pgs1_mem[7]);
                                                       ResetCoil(pgs1_mem[6]);
                     
                                             }
                                             else if(!cmd_run_pozarni_rezim && (pozarni_rezim_zagusenje || pozarni_rezim_normalno))
                                             {
                             
                                                       SetCoil(pgs1_mem[7]);
                                                       ResetCoil(pgs1_mem[6]);
                                             }
                                             else if(cmd_run_pozarni_rezim)
                                             {
                                                  if (!cmd_lijevo && !cmd_desno)
                                                  { 
                           
                                                       SetCoil(pgs1_mem[7]);
                                                       ResetCoil(pgs1_mem[6]);
                                                       
                                                  }
                                                  /*
                                                  else if((cmd_lijevo && !state_lijevo && !cmd_run_pozarni_rezim) || (cmd_desno && !state_desno && !cmd_run_pozarni_rezim))
                                                  {
                                                       SetCoil(kvar_state);
                                                       SetCoil(pgs1_mem[8]);
                                                       ResetCoil(pgs1_mem[6]);
                                                  }
                                                 */
                   
                                             }
                                             else if(timer_Q[4] && !cmd_run_pozarni_rezim)
                                             {
                      
                                                  if (!cmd_lijevo && !cmd_desno)
                                                  { 
                           
                                                       SetCoil(pgs1_mem[7]);
                                                       ResetCoil(pgs1_mem[6]);
                                                       
                                                  }
                                  /*
                                                  else if((cmd_lijevo && !state_lijevo && !cmd_run_pozarni_rezim) || (cmd_desno && !state_desno && !cmd_run_pozarni_rezim))
                                                  {
                                                       SetCoil(kvar_state);
                                                       SetCoil(pgs1_mem[7]);
                                                       ResetCoil(pgs1_mem[6]);
                                                  }
                                                */  
                                        
                        
                                              }
                   
                              }
                     
                              if(timer_Q[5] && !cmd_run_pozarni_rezim)
                              {
                                 SetCoil(pgs1_mem[7]);
                                 ResetCoil(pgs1_mem[6]);
                              }
                              
                     }
                    
                             
                 }
                 
                 
                 
                 if(pgs1_mem[7])
                 {
                 
                      
                    if (timer_Q[6] || pozarni_rezim_zagusenje || pozarni_rezim_normalno)
                    { 
                       SetCoil(pgs1_mem[8]);
                       ResetCoil(pgs1_mem[7]);
                    }
                    
                    
                    
                             
                 }
                 if(pgs1_mem[8])
                 {
                   
                    
                        SetCoil(pgs1_mem[1]);
                        ResetCoil_BF(pgs1_mem,2,8);
                        ResetCoil(kvar_state);
                                       
                             
                 }
                 
                 if(pgs1_mem[1] || pgs1_mem[2])
                 {
                     sekvenca=0;
                     
                 }
                 if(pgs1_mem[3])
                 {   
                     sekvenca=1;
                 }
                 if(pgs1_mem[4])
                 {   
                     sekvenca=2;
                     /*
                     if(cmd_desno && !cmd_lijevo)
                     {
                         SetCoil(cmd_run_naprijed);                                            
                     }
                     else if(cmd_lijevo && !cmd_desno)
                     {
                         SetCoil(cmd_run_nazad);
                         
                     }
                     */
                 }                 
                 if(pgs1_mem[5])
                 {   
                     sekvenca=3;
                 }
                 if(pgs1_mem[6])
                 {   
                     sekvenca=4;
                 }
                 if(pgs1_mem[7])
                 {   
                     sekvenca=5;
                 }
                 if(pgs1_mem[8])
                 {   
                     sekvenca=6;
                 }
                 if(pgs1_mem[4] || pgs1_mem[5] || pgs1_mem[6])
                 {
                     if(cmd_desno || cmd_run_naprijed)
                     {
                         SetCoil(cmd_run_naprijed);
                         if(state_desno)
                         {
                            SetCoil(cmd_led_naprijed);
                            SetCoil(cmd_led_naprijed_pgs1);
                            SetCoil(cmd_led_naprijed_pgs2);
                         }
                        
                     }
                     else if(cmd_lijevo || cmd_run_nazad)
                     {
                         SetCoil(cmd_run_nazad);
                         if(state_lijevo)
                         {
                            SetCoil(cmd_led_nazad);
                            SetCoil(cmd_led_nazad_pgs1);
                            SetCoil(cmd_led_nazad_pgs2);
                         }
                     }
                     TimerTON(dp_timer[5][1],true,3600,true);
                 }
                 else
                 {
                      ResetCoil(cmd_run_naprijed);
                      ResetCoil(cmd_run_nazad);
                      ResetCoil(cmd_led_naprijed);
                      ResetCoil(cmd_led_naprijed_pgs1);
                      ResetCoil(cmd_led_naprijed_pgs2);
                      ResetCoil(cmd_led_nazad);
                      ResetCoil(cmd_led_nazad_pgs1);
                      ResetCoil(cmd_led_nazad_pgs2);
                      TimerTON(dp_timer[5][1],false);
                 }
                 
                 
                 
                 
                 
                 
                 
                 
                 if(pgs1_mem[3])
                 {
                     TimerTON(dp_timer[1][1],true,5000*prioritet);
                 }
                 else
                 {
                     TimerTON(dp_timer[1][1],false);
                 
                 }
                 if(pgs1_mem[4])
                 {
                     TimerTON(dp_timer[2][1],true,800);
                 }
                 else
                 {
                     TimerTON(dp_timer[2][1],false);
                 
                 }
                 if(pgs1_mem[5])
                 {
                     TimerTON(dp_timer[3][1],true,10,true);
                 }
                 else
                 {
                     TimerTON(dp_timer[3][1],false);
                 
                 }
                 if(pgs1_mem[6])
                 {
                     TimerTON(dp_timer[4][1],true,60,true);
                 }
                 else
                 {
                     TimerTON(dp_timer[4][1],false);
                 
                 }
                 if(pgs1_mem[7])
                 {
                     TimerTON(dp_timer[6][1],true,vrijeme_zaustavljanja,true);
                 }
                 else
                 {
                     TimerTON(dp_timer[6][1],false);
                 
                 }
                 
                 if(pozarni_rezim_zagusenje || pozarni_rezim_normalno)
                 {
                     SetCoil(cmd_run_pozarni_rezim);
                     
                 }
                 else if(!pozarni_rezim_zagusenje && !pozarni_rezim_normalno)
                 {
                     ResetCoil(cmd_run_pozarni_rezim);
                 }
                 
                 if(dp[strlen(dp)-4]=="D" || dp[strlen(dp)-4]=="L")
                 {
                      zbirni_kvar=kvar || kvar_state || ups_aktiviran;
                 }
                 else
                 {
                      zbirni_kvar=kvar ||kvar_state || !glavni_prekidac || ups_aktiviran;
                 }
                               
                /*
                 if(test_v1 && dp[strlen(dp)-3]=="1")
                 {
                   
                      for(int i=11;i<=19;i++)
                      {
                         if(i!=15)
                         {  
                               dpSet("OA-V1.A"+i+".cmd.bit.b0",true,
                                     "OA-V1.A"+i+".cmd.bit.b1",true,
                                     "OA-V1.A"+i+".cmd.bit.b2",true,
                                     "OA-V1.A"+i+".cmd.bit.b3",true);                                                     
                         }
                       }
                       dpSet("OA-V1.A20.cmd.bit.b0",true,
                             "OA-V1.A20.cmd.bit.b1",true);
                             
                                 
                 }               
                 else if(test_v2 && dp[strlen(dp)-3]=="2")
                 {
                   
                      for(int i=11;i<=19;i++)
                      {
                         if(i!=15)
                         {  
                               dpSet("OA-V2.A"+i+".cmd.bit.b0",true,
                                     "OA-V2.A"+i+".cmd.bit.b1",true,
                                     "OA-V2.A"+i+".cmd.bit.b2",true,
                                     "OA-V2.A"+i+".cmd.bit.b3",true);                                                     
                         }
                       }
                       dpSet("OA-V2.A20.cmd.bit.b0",true,
                             "OA-V2.A20.cmd.bit.b1",true);
                             
                                 
                 }
                 else
                 {
                          
                 }
*/
                 
                                  
                 dpSet(dp+"cmd.led.naprijed",cmd_led_naprijed,
                       dp+"cmd.led.nazad",cmd_led_nazad,                            
                       dp+"cmd.led.kvar",zbirni_kvar,
                       dp+"cmd.led.servis",servis,
                       dp+"cmd.run.naprijed_motor",cmd_run_naprijed,
                       dp+"cmd.run.nazad_motor",cmd_run_nazad,
                       dp+"cmd.run.pozar",cmd_run_pozarni_rezim,    
                       dp+"cmd.led.naprijed_pgs1",cmd_led_naprijed_pgs1,
                       dp+"cmd.led.naprijed_pgs2",cmd_led_naprijed_pgs2,      
                       dp+"cmd.led.nazad_pgs1",cmd_led_nazad_pgs1,
                       dp+"cmd.led.nazad_pgs2",cmd_led_nazad_pgs2,    
                       dp+"state.sekvenca",sekvenca,
                       dp+"function.v_mem",pgs1_mem,
                       dp+"function.pgs1",pgs1_akt_sekv,
                       dp+"function.pgs2",pgs2_akt_sekv,
                       dp+"function.aut_sdv",sdv_aut_akt_sekv,
                       dp+"function.man_sdv",sdv_man_akt_sekv,
                       dp+"alarm.kvar_state",kvar_state,
                       dp+"alarm.vibracije.aktiv",vibracije_aktiv,
                       dp+"alarm.ups_aktiviran",ups_aktiviran);
                 
              

     

}



klapna_alarm(string dp1, bool clock)
{
   
   dyn_dyn_string  dp_timer;
   string dp;
   dyn_bool timer_Q,mem=makeDynBool(false,false,false,false);
   
   bool zatvori,otvorena,zatvorena;
   
   dp=substr(dp1,0,strlen(dp1)-30);
   
   for (int i=1;i<=2;i++)
   {
   
      dp_timer[i][1]=makeDynString(dp+"function.T"+i+".IN");
      dp_timer[i][2]=makeDynString(dp+"function.T"+i+".Q");
      dpGet(dp_timer[i][2],timer_Q[i]);
 
   }
   dpGet(dp+"cmd.run.zatvori",zatvori,
         dp+"state.otvorena",otvorena,
         dp+"state.zatvorena",zatvorena,
         dp+"function.mem",mem);
   
   
   if(!mem[1] && !mem[2] && !mem[3] && !mem[4])
   {
     SetCoil(mem[1]);
   }
   
   
   if(mem[1])
   {
   
       if(zatvori)
       {
   
            TimerTON(dp_timer[1][1],true,20,true);
                   
            if(timer_Q[1])
            {
                if(!zatvorena)
                {
                   dpSet(dp+"alarm.neuspjesno_zatvaranje",true); 
                }
                else
                {
                   dpSet(dp+"alarm.neuspjesno_zatvaranje",false);
                   
               
                }
                
                TimerTON(dp_timer[1][1],false);
                SetCoil(mem[2]);
                ResetCoil(mem[1]); 
                
            }
        
       }
   
   
   }
   else if(mem[2])
   {
   
       if(!zatvori)
       {
   
            TimerTON(dp_timer[2][1],true,120,true);
                   
            if(timer_Q[2])
            {
                if(!otvorena)
                {
                   dpSet(dp+"alarm.neuspjesno_otvaranje",true); 
                }
                else
                {
                   dpSet(dp+"alarm.neuspjesno_otvaranje",false,
                         dp+"alarm.neuspjesno_zatvaranje",false);
                   
                   TimerTON(dp_timer[2][1],false);
                   SetCoil(mem[1]);
                   ResetCoil(mem[2]);               
                }
                
                
            }
        
       }
   
   
   }
   
   dpSet(dp+"function.mem",mem);
   
}


