bool bFirstPass = true;

main()
{ 
   timedFunc("PingOzvucenje", "CheckSoundSystem");   
}


PingOzvucenje(string Blinker, time t1, time t2)
{  
  int iOnline = 1;
  int iOnline_Centrala =  PingOzvucenjePodsistem("10.111.1.35");
  int iOnline_Vijenac_Lijeva_Cijev =  PingOzvucenjePodsistem("10.111.1.37");
  int iOnline_Vijenac_Desna_Cijev =  PingOzvucenjePodsistem("10.111.1.36");
  int iOnline_Suhodol_Lijeva_Cijev =  PingOzvucenjePodsistem("10.111.1.39");
  int iOnline_Suhosol_Desna_Cijev =  PingOzvucenjePodsistem("10.111.1.38");
    
  if((iOnline_Centrala == 0) && (iOnline_Vijenac_Lijeva_Cijev == 0) && (iOnline_Vijenac_Desna_Cijev == 0))
    dpSet("SysVijenac:Ozvucenje.IntegrClient.alive", true);    
  else
    dpSet("SysVijenac:Ozvucenje.IntegrClient.alive", false);
    
  if(iOnline_Centrala == 0 && iOnline_Suhodol_Lijeva_Cijev == 0 && iOnline_Suhosol_Desna_Cijev == 0)
    dpSet("SysSuhodol:Ozvucenje.IntegrClient.alive", true);
  else
    dpSet("SysSuhodol:Ozvucenje.IntegrClient.alive", false);
  
}


int PingOzvucenjePodsistem(string sIPAddr)
{
  string result;  
  
  result = system("ping -c 4 " + sIPAddr);
  DebugFTN(1, "ping result - ping " + sIPAddr + ": " + result);
  int iOnline;
  if(result == 0)
    iOnline = 0;  //online
  else if (result == 1)
    iOnline = 1;  //offline
  else 
    iOnline = 4; //unknown state
  return iOnline;
}


