// $License: NOLICENSE
/*
  
  
  -----timer functions-------
  
  
  
  
  
  */
TimerTON2(string dp1, bool IN,
         string dp2, int PT,
         string dp3, bool Q,
         string dp4, int ET,
         string dp5, time ST,
         string dp6, bool M)
{
  
   time now;
  
   if (IN & !M)
   {
     ST=getCurrentTime();
   }
   else if(IN & M)
   {
     now=getCurrentTime();
     ET=(1000 * (second(now - ST)) + (milliSecond(now - ST)));
     if (ET>=PT)
     {
        dpSet(dp3);     
     }
   
   }
  
  
}

TimerTON1(bool &IN, bool &M, time &ST, int &PT, bool &Q, int &ET)
{
   time now;
  
   if (IN && !M)
   {
     ST=getCurrentTime();
     M=true;
   }
   else if(IN && M && !Q)
   {
     now=getCurrentTime();
     ET=(1000 * (second(now - ST)) + (milliSecond(now - ST)));
     if (ET>=PT)
     {
        Q=true;     
     }
   
   }
   else if(!IN)
   {
     M=false;
     Q=false;
     ET=0;
   }
  
}
TimerTON(string dp1, bool IN,int PT=0, bool PT_S=false, bool PT_H=false)
{
    string dp, dp_M="M", dp_ST="ST", dp_PT="PT", dp_Q="Q", dp_ET="ET";
    time now;
    bool Q,M;
    int ET;
    time ST;
    
    
    dpSet(dp1,IN);
    
    
    dp=substr(dp1,0,strlen(dp1)-2);
    dpSet(dp+dp_PT,PT);
    dpGet(dp+dp_M,M);
    dpGet(dp+dp_ST,ST);
    dpGet(dp+dp_PT,PT);
    dpGet(dp+dp_Q,Q);
    dpGet(dp+dp_ET,ET);
    
    if (PT > 0 && IN)
    {
        if (IN && !M)
        {
            ST=getCurrentTime();
            M=true;
        }
        else if(IN && M && !Q)
        {
            if (!PT_S && !PT_H)
            {
                now=getCurrentTime();
                ET=(1000 * (second(now - ST)) + (milliSecond(now - ST)));
                if (ET>=PT)
                {
                    Q=true;     
                }
            }
            else if(PT_S && !PT_H)
            {
                now=getCurrentTime();
                ET= ET=(60 * (minute(now - ST)) + (second(now - ST)));
                if (ET>=PT)
                {
                    Q=true;     
                }
            
            }
            else if(PT_H)
            {
                now=getCurrentTime();
                ET= ET=(24 * (day(now - ST)) + (hour(now - ST)));
                if (ET>=PT)
                {
                    Q=true;     
                }
            
            }
   
        }
      }
   if(!IN)
   {
      M=false;
      Q=false;
      PT=0;
      ET=0;
    }
   
   dpSet(dp+dp_M,M);
   dpSet(dp+dp_ST,ST);
   dpSet(dp+dp_PT,PT);
   dpSet(dp+dp_Q,Q);
   dpSet(dp+dp_ET,ET);
   
   
    
    
    
    
}

bool TimerTON3(bool IN,time ST,int PT,bool PT_S=false)
{
     
     time now;
     bool Q;
     
     if (IN)
     {
         if (PT>0)
         {
             if (!PT_S)
             {
                now=getCurrentTime();
                ET=(1000 * (second(now - ST)) + (milliSecond(now - ST)));
                if (ET>=PT)
                {
                    Q=true;     
                }
                else Q=false;
             }
             else if(PT_S)
             {
                now=getCurrentTime();
                ET=second(now - ST);
                if (ET>=PT)
                {
                    Q=true;     
                }
                else Q=false;
            
             }
   
         
         }
     
     }
     else Q=false;
     
     return Q;

}
TimerDelayON(string dp1,bool IN,string dp2,int PT)
{
     string dp;
     dpSet(dp1,IN,dp2,PT);
     if(IN && PT>0)
     {
       delay(0,PT);
       dp=substr(dp1,0,strlen(dp1)-2);
       dpSet(dp+"Q",true);
     }
     else
     {
       dpSet(dp+"Q",false);    
     }
}
/*
  
  
  -----coil functions-------
  
  
  
  
  
  */
SetCoil_BF(dyn_bool &coil, int start=1, int stop=1)
{
   
   for (int i=start;i<=stop;i++)
   {
      coil[i]=true; 
   }
   
}
SetCoil(bool &coil)
{
   coil=true;    
}
ResetCoil_BF(dyn_bool &coil, int start=1, int stop=1)
{
   
   for (int i=start;i<=stop;i++)
   {
      coil[i]=false; 
   }
   
}

ResetCoil(bool &coil)
{
   coil=false;    
}
