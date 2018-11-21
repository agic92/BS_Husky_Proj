#uses "log"
#uses "basicMethods.ctl"

string systemName = getSystemName();

main()
{

  int queryValue = dpQueryConnectSingle("setWorkingTimeForTunnelFan", true, "",
                       "SELECT '_online.._value' FROM '" + systemName + "*.state.*Direction*' WHERE _DPT = \"TunnelFan\"");

  if ( sdGetLastError() < 0 || queryValue != 0)
  {
    Log::error("dpQueryConnectSingle", "Failed to connect to dp <%s>.", "Query for setting working time for Ventilation system");
    return;
  }
}

setWorkingTimeForTunnelFan(anytype ident, dyn_dyn_anytype list)
{
  if(!isReduActive())
    return;

  string dpe;
  bool state;
  for(int i = 2; i <= dynlen(list); i++)
  {
    dpe = list[i][1];
    state = list[i][2];
    startThread("setWorkingTimeForTunnelFanSingle", dpe, state);
  }
}

void setWorkingTimeForTunnelFanSingle(string dpe, bool state)
{
  string fanName = dpSubStr(dpe, DPSUB_DP);
  int timeElapsed, oldWorkingTime;

  //fan is not running
  if(!state) return;

  if(!getDP(systemName + fanName + ".state.timeElapsed", timeElapsed))
  {
      Log::error("setWorkingTimeForTunnelFanSingle", "Failed to get datapoint " + systemName + fanName + ".state.timeElapsed");
      return;
  }

  //fan is already running
  if(timeElapsed > 0) return;

  time t1 = getCurrentTime();
  //if state is true and fan is not running
  while(state)
  {
     dpGet(dpe, state);

     if(!state && timeElapsed > 0)
     {
       if(!getDP(systemName + fanName + ".state.workingTime", oldWorkingTime))
       {
         Log::error("setWorkingTimeForTunnelFanSingle", "Failed to get datapoint " + systemName + fanName + ".state.workingTime");
         return;
       }

       if(!setDP(systemName + fanName + ".state.workingTime", oldWorkingTime + timeElapsed -1)) return;
       if(!setDP(systemName + fanName + ".state.timeElapsed", 0)) return;

       return;
     }

     delay(1);
     timeElapsed = getCurrentTime() - t1;
     if(!setDP(systemName + fanName + ".state.timeElapsed", timeElapsed)) return;
  }
}
