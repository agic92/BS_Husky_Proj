
#uses "PLC/base_functions.ctl"




Semafor_alarm(string dp1,bool alarm_kvar,
         string dp2,bool cmd_sdv_iskljuci)
{
string dp;
dyn_bool s_mem;


dp=substr(dp1,0,strlen(dp1)-26);

dpGet(dp+"function.s_mem",s_mem);

if(cmd_sdv_iskljuci || alarm_kvar)
{
    
   ResetCoil_BF(s_mem,1,9);
    
}
dpSet(dp+"function.s_mem",s_mem);  

}

Semafor_run(string dp1,int clock)
{
    startThread("Semafor_run_thread", dp1, clock);
}

Semafor_run_thread(string dp1,int clock)
{

dyn_dyn_string  dp_timer;
string dp;
dyn_bool timer_Q,s_mem=makeDynBool(false,false,false,false,false,false,false,false,false);
bool cmd_sdv_crveno,cmd_sdv_zuto,cmd_sdv_zeleno,cmd_sdv_iskljuci,
     cmd_run_crveno,cmd_run_zuto,cmd_run_zeleno,
     state_crveno,state_zuto,state_zeleno,alarm_kvar;

//dp=substr(dp1,0,strlen(dp1)-30);
dp=substr(dp1,0,strlen(dp1)-14);







for (int i=1;i<=8;i++)
{
   
    dp_timer[i][1]=makeDynString(dp+"function.timer.T"+i+".IN");
    dp_timer[i][2]=makeDynString(dp+"function.timer.T"+i+".Q");
    dpGet(dp_timer[i][2],timer_Q[i]);
 
    

}



dpGet(dp+"command.sdv.crveno",cmd_sdv_crveno,
      dp+"command.sdv.zuto.on",cmd_sdv_zuto,
      dp+"command.sdv.zeleno",cmd_sdv_zeleno,
      dp+"command.sdv.iskljuci",cmd_sdv_iskljuci,
      dp+"command.run.crveno",cmd_run_crveno,
      dp+"command.run.zuto",cmd_run_zuto,
      dp+"command.run.zeleno",cmd_run_zeleno,
      dp+"response.crveno",state_crveno,
      dp+"response.zuto",state_zuto,
      dp+"response.zeleno",state_zeleno,
      dp+"alarm.kvar",alarm_kvar,
      dp+"function.s_mem",s_mem);

//DebugN(s_mem);


  if(cmd_sdv_iskljuci || alarm_kvar)
  {   
       ResetCoil_BF(s_mem,1,9);    
  }
  

  else if(!cmd_sdv_iskljuci && !s_mem[1] && !s_mem[2] && !s_mem[3] & !s_mem[4] &&
          !s_mem[5] && !s_mem[6] && !s_mem[7] && !s_mem[8] && !s_mem[9] && !alarm_kvar)
  {
      if(!state_crveno && !state_zuto && !state_zeleno)
      {
         SetCoil(s_mem[4]);
      }
      else if(state_crveno)
      {
         SetCoil(s_mem[1]);
      }
      else if(state_zeleno)
      {
         SetCoil(s_mem[4]);
      }
      else if(state_zuto)
      {
         SetCoil(s_mem[8]);
      }
  }

 


  if(s_mem[1])
  {
    if(cmd_sdv_zeleno)
    {
        SetCoil(s_mem[3]);
        ResetCoil(s_mem[1]);
        ResetCoil(cmd_sdv_zeleno);
    }
    else if(cmd_sdv_zuto)
    {
        SetCoil(s_mem[8]);
        ResetCoil(s_mem[1]);
        ResetCoil(cmd_sdv_zuto);    
    }
    if(cmd_sdv_crveno)
    {
        ResetCoil(cmd_sdv_crveno);
    }     
  }
  if(s_mem[2])
  {
      if(timer_Q[1])
      {
          SetCoil(s_mem[3]);
          ResetCoil(s_mem[2]);
      }      
      
      
  }
  if(s_mem[3])
  {
      if(timer_Q[2])
      {
          SetCoil(s_mem[4]);
          ResetCoil(s_mem[3]);
      }      
      
      
  }
  if(s_mem[4])
  {
      if(cmd_sdv_crveno)
      {
          SetCoil(s_mem[7]);
          ResetCoil(s_mem[4]);
          ResetCoil(cmd_sdv_crveno);
          dpSet(dp+"command.sdv.crveno",cmd_sdv_crveno);
      }
      else if(cmd_sdv_zuto)
      {
          SetCoil(s_mem[8]);
          ResetCoil(s_mem[4]);
          ResetCoil(cmd_sdv_zuto); 
          dpSet(dp+"command.sdv.zuto.on",cmd_sdv_zuto);   
      }    
      if(cmd_sdv_zeleno)
      {
          ResetCoil(cmd_sdv_zeleno);
          dpSet(dp+"command.sdv.zeleno",cmd_sdv_zeleno);
      }    
      
  }
  if(s_mem[5])
  {
      if(timer_Q[3])
      {
          SetCoil(s_mem[6]);
          ResetCoil(s_mem[5]);
      }
                 
  }
  if(s_mem[6])
  {
      if(timer_Q[4])
      {
          SetCoil(s_mem[5]);
          ResetCoil(s_mem[6]);
      }      
      if(timer_Q[5])
      {
          SetCoil(s_mem[7]);
          ResetCoil(s_mem[5]);
      }    
      
  }
  if(s_mem[7])
  {
      if(timer_Q[6])
      {
          SetCoil(s_mem[1]);
          ResetCoil(s_mem[7]);
      }      
      if(cmd_sdv_crveno)
      {
          SetCoil(s_mem[1]);
          ResetCoil(s_mem[7]);
          ResetCoil(cmd_sdv_crveno);
          dpSet(dp+"command.sdv.crveno",cmd_sdv_crveno);
      }
      else if(cmd_sdv_zeleno)
      {
          SetCoil(s_mem[4]);
          ResetCoil(s_mem[7]);
          ResetCoil(cmd_sdv_zeleno);
          dpSet(dp+"command.sdv.zeleno",cmd_sdv_zeleno);
      }
     
      
  }
  if(s_mem[8])
  {  
     
      if(clock==2)
      {
          SetCoil(s_mem[9]);
          ResetCoil(s_mem[8]);
      }      
      else if(cmd_sdv_crveno)
      {
          SetCoil(s_mem[1]);
          ResetCoil(s_mem[8]);
          ResetCoil(cmd_sdv_crveno);
          dpSet(dp+"command.sdv.crveno",cmd_sdv_crveno);
      }
      else if(cmd_sdv_zeleno)
      {
          SetCoil(s_mem[4]);
          ResetCoil(s_mem[8]);
          ResetCoil(cmd_sdv_zeleno);
          dpSet(dp+"command.sdv.zeleno",cmd_sdv_zeleno);
      }
      if(cmd_sdv_zuto)
      {
          ResetCoil(cmd_sdv_zuto);
          dpSet(dp+"command.sdv.zuto.on",cmd_sdv_zuto);
      }    
          
      
  }
  if(s_mem[9])
  {
      if(clock<2)
      {
          SetCoil(s_mem[8]);
          ResetCoil(s_mem[9]);
      }      
      else if(cmd_sdv_crveno)
      {
          SetCoil(s_mem[1]);
          ResetCoil(s_mem[9]);
          ResetCoil(cmd_sdv_crveno);
          dpSet(dp+"command.sdv.crveno",cmd_sdv_crveno);
      }
      else if(cmd_sdv_zeleno)
      {
          SetCoil(s_mem[4]);
          ResetCoil(s_mem[9]);
          ResetCoil(cmd_sdv_zeleno);
          dpSet(dp+"command.sdv.zeleno",cmd_sdv_zeleno);
      }    
      
  }


  if(s_mem[1] || s_mem[2] || s_mem[3])
  {
      SetCoil(cmd_run_crveno);
  }
  else
  {
      ResetCoil(cmd_run_crveno);
  }
  if(s_mem[3] || s_mem[7] || s_mem[8])
  {   
      SetCoil(cmd_run_zuto);
  }
  else
  {
      ResetCoil(cmd_run_zuto);
  }
if(s_mem[4] || s_mem[5])
{
    SetCoil(cmd_run_zeleno);
}
else
{
    ResetCoil(cmd_run_zeleno);
}


if(s_mem[2])
{
    TimerTON(dp_timer[1][1],true,500);
}
else
{
  
  TimerTON(dp_timer[1][1],false);
                 
}

if(s_mem[3])
{
    TimerTON(dp_timer[2][1],true,1000);
}
else
{
    TimerTON(dp_timer[2][1],false);
                 
}
if(s_mem[5])
{
    TimerTON(dp_timer[3][1],true,1000);
}
else
{
    TimerTON(dp_timer[3][1],false);
                 
}
if(s_mem[6])
{
    TimerTON(dp_timer[4][1],true,500);
}
else
{
    TimerTON(dp_timer[4][1],false);
                 
}
if(s_mem[5] || s_mem[6])
{
    TimerTON(dp_timer[5][1],true,2,true);
}
else
{
    TimerTON(dp_timer[5][1],false);
                 
}
if(s_mem[7])
{
    TimerTON(dp_timer[6][1],true,1000);
}
else
{
    TimerTON(dp_timer[6][1],false);
                 
}
if(s_mem[8])
{
    TimerTON(dp_timer[7][1],true,1000);
}
else
{
    TimerTON(dp_timer[7][1],false);
                 
}
if(s_mem[9])
{
    TimerTON(dp_timer[8][1],true,500);
}
else
{
    TimerTON(dp_timer[8][1],false);
                 
}


dpSet(dp+"command.run.crveno",cmd_run_crveno,
      dp+"command.run.zuto",cmd_run_zuto,
      dp+"command.run.zeleno",cmd_run_zeleno,
      dp+"function.s_mem",s_mem);

if(dp[strlen(dp)-2]=="D" || dp[strlen(dp)-2]=="L")
{
    dpSet(dp+"response.zuto",cmd_run_zuto);

}


}

