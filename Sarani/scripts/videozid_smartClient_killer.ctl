string sDPname = "SysSarani:Veliki_videozid";
main()
{
   //DebugTN("ERROR: HTTP-server can't start. --- Check license");
  dpConnect("SC_Killer", sDPname + ".command.restart");
}

SC_Killer(string sDP, bool sDPValue)
{
  if(sDPValue)
    kill_exe("Client.exe");
}


void kill_exe(string sName)
{
  string result;  
  
  result = system("taskkill /IM " + sName + " /F");
  DebugFTN(1, "kill_exe - killing " + sName + " result: " + result);  
  dpSet(sDPname + ".command.restart", false, sDPname + ".response.last_restart_time", getCurrentTime());
}
