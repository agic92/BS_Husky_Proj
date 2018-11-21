main()
{

startThread("Logiranje");	// pokreni tred za javljanje skripte izvornom serveru svakih 10s
  
string upit, dpElement,SoundFile;
int i,actState,alarmi;
int zvuk=0;
dyn_dyn_anytype ispis;
SoundFile = getPath(DATA_REL_PATH,"sounds/police.wav"); 

while(TRUE)
{
  alarmi=0;
   upit=" SELECT ALERT '_alert_hdl.._value' FROM '*' REMOTE 'SysVijenac'" ;
  
      if (dpQuery(upit,ispis)==-1)   //ako je server nedostupan, query nije moguce izvrsiti, alarmi nisu vidljivi u tabeli pa cemo zaustaviti zvucni alarm
	  stopSound();
	  
      for (i = 2; i <= dynlen(ispis); i++ )                                   //This section creates the alert list.
  {                                                                     //Alerts with state "came" will be appended,
    dpElement = dpSubStr(ispis[i][1], DPSUB_ALL);
    dpGet(dpElement+":_alert_hdl.._act_state",actState);

    if(actState==1 || actState==3)
    {
        alarmi++;	//predstavlja broj nepotvrdjenih alarma
    }

  }
      
      if(alarmi>0 && zvuk==0)	//ako imamo nepotvrdjenih alarma i zvuk nije pokrenut
      {
        startSound(SoundFile,1);
        zvuk=1;
		DebugTN("alarm i stanje alarma", dpElement, actState);
        DebugTN("pokrenuo zvuk");
      }
      else if(alarmi==0 && zvuk==1)	//ako nema nepotvrdjenih alarma a zvuk je vec pokrenut
      {
        stopSound();
		DebugTN("alarm i stanje alarma", dpElement, actState);
        DebugTN("zaustavio zvuk");
        zvuk=0;
      }
  delay(1);
 }
}

void Logiranje()
{
 while(TRUE)
  {
  	if (dpSet("SysVijenac:ZvucniAlarm.IntegrClient.alive",TRUE)==0)
	  {
		//DebugTN("ziva skripta ");
	  }
	else
	{
		DebugTN("trenutno nedostupan server ");
	}
	
	delay(10);
  }
}
