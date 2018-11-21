#uses "log"
#uses "basicMethods.ctl"

string systemName = getSystemName();
int delayTime = 3; //seconds
bool initTrafficLight = false;
bool initTrafficBlinker = false;

main()
{
  int queryTrafficLight = dpQueryConnectSingle("checkCommandLight", true, "",
                       "SELECT '_online.._value' FROM '" + systemName + "*.command.*' WHERE _DPT = \"TrafficLight\"");

  int queryTrafficBlinker = dpQueryConnectSingle("checkCommandBlinker", true, "",
                       "SELECT '_online.._value' FROM '" + systemName + "*.command.yellow' WHERE _DPT = \"TrafficBlinker\"");

  if ( sdGetLastError() < 0 || queryTrafficLight != 0  || queryTrafficBlinker != 0)
  {
    Log::error("dpQueryConnectSingle", "Failed to connect to dp <%s>.", "Query for checking status and command for traffic light");
    return;
  }
}

checkCommandLight(anytype ident, dyn_dyn_anytype list)
{
  if(!isReduActive())
    return;

  if(!initTrafficLight)
  {
    initTrafficLight = true;
    return;
  }

  string dpe;
  bool value;
  for (int i = 2; i <= dynlen(list); i++)
  {
    dpe = list[i][1];
    value = list[i][2];
    //if a red / yellow / green command is sent to a traffic light, check response from the PLC
    if(value) startThread("checkCommandThread", dpe, value);
  }
}

checkCommandBlinker(anytype ident, dyn_dyn_anytype list)
{
  if(!isReduActive())
    return;

  if(!initTrafficBlinker)
  {
    initTrafficBlinker = true;
    return;
  }

  string dpe;
  bool value;
  for (int i = 2; i <= dynlen(list); i++)
  {
    dpe = list[i][1];
    value = list[i][2];
    //if a yellow command is sent to a traffic light blinker, check response from the PLC
    startThread("checkCommandBlinkerThread", dpe, value);
  }
}

checkCommandThread(string dpe, bool value)
{
  delay(delayTime);

  string dpNameElement = "";
  bool valueAfterDelay, returnState;

  if(value == false)
    return;

  string dpName = dpSubStr(dpe, DPSUB_DP);  //DPSUB_DP -
  //check the command, is it returned to false
  if(!getDP(dpe, valueAfterDelay))
  {
      Log::error("checkCommandThread", "Failed to get datapoint " + dpe);
      return;
  }

  if(!valueAfterDelay)
  {
    //received confirmation from the PLC that the command had passed, the command reset was executed
    dpSet(dpName + ".alarm.commandCheck", false);
    Log::info("checkCommandThread", "Reset komande izvrsen, komanda prosla na PLC  DPE: " + dpe);
  }
  else
  {
    //there was no confirmation from the PLC that the command had passed
    dpSet(dpName + ".alarm.commandCheck", true);
    Log::info("checkCommandThread", "Nije prosla komanda sa SCADA-e, PLC nije resetovo komandu na FALSE, DPE: " + dpe);
  }

  //check for red light
  returnState = checkStatusForEveryLight(dpe, dpName, "red");
  if(returnState) return;
  //check for green light
  returnState = checkStatusForEveryLight(dpe, dpName, "green");
  if(returnState) return;
  //check for yellow light
  returnState = checkStatusForEveryLight(dpe, dpName, "yellow");
  if(returnState) return;

  //check if traffic light is turned off
  returnState = checkAllLights(dpe, dpName, "turnOff");
  if(returnState) return;
}

checkCommandBlinkerThread(string dpe, bool value)
{
  delay(delayTime);

  bool trafficLightState;
  string dpName = dpSubStr(dpe, DPSUB_DP);  //DPSUB_DP -
  if(!getDP(systemName + dpName + ".state.yellowOn", trafficLightState))
  {
     Log::error("checkStatusForTrafficBlinker", "Failed to get datapoint " + systemName + dpName + ".state.yellowOn");
     return;
  }

  if(trafficLightState == value)
  {
     Log::info("checkStatusForTrafficBlinker", "Poslano " + value + " dosao odgovor od PLC-a da je " + value + "  :" + dpe);
     dpSet(dpName + ".alarm.statusCheck", false);
     return;
  }
  else
  {
     Log::info("checkStatusForTrafficBlinker", "Razlicite vrijednosti slanje i ocitanje " + dpe);
     dpSet(dpName + ".alarm.statusCheck", true);
     return;
  }
}

bool checkStatusForEveryLight(string dpe, string dpName, string light)
{
  bool trafficLightState;
  if(strpos(dpe, light, 0) >= 0)
  {
    if(strpos(dpe, "yellow", 0) >= 0) light = "yellowOn";
    if(!getDP(systemName + dpName + ".state." + light, trafficLightState))
    {
      Log::error("checkStatusForEveryLight", "Failed to get datapoint " + systemName + dpName + ".state." + light);
      return false;
    }

    if(trafficLightState)
    {
      Log::info("checkStatusForEveryLight", "Poslano " + light + " dosao odgovor od PLC-a da je " + light + " - - DPE: " + dpe);
      dpSet(dpName + ".alarm.statusCheck", false);
      return true;
    }
    else
    {
      Log::info("checkStatusForEveryLight", "Nije dosao odgovor sa PLC-a DPE: " + dpe);
      dpSet(dpName + ".alarm.statusCheck", true);
      return false;
    }
  }
  else return false;
}

bool checkAllLights(string dpe, string dpName, string light)
{
  bool red, yellow, green;
  if(strpos(dpe, light, 0) >= 0)
  {
     if(!getDP(systemName + dpName + ".state.red", red)) return false;
     if(!getDP(systemName + dpName + ".state.green", green)) return false;
     if(!getDP(systemName + dpName + ".state.yellow", yellow)) return false;

     if(!red && !yellow && !green)
     {
        Log::info("checkAllLights", "Poslano " + light + " dosao odgovor od PLC-a da je " + light + " - - DPE: " + dpe);
        dpSet(dpName + ".alarm.statusCheck", false);
        return true;
     }
     else
     {
        Log::info("checkAllLights", "Jedno od svjetala nije ugaseno, red, green or yellow DPE: " + dpe);
        dpSet(dpName + ".alarm.statusCheck", true);
        return false;
     }
  }
  else return false;
}
