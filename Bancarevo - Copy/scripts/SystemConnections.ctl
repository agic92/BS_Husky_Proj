#uses "log.ctl"
#uses "basicMethods.ctl"
//Version v1.0.4
//----------------

int min_time_between_reset = 30; //30sec
int max_time_between_reset = 1200; //20min
int iDiff = 10; //vrijeme u sekundama u kojem se klijeti moraju javiti
int iDiff_Ventilator_thread = 120; //vrijeme u sekundama u kojem se threadovi za ventilaciju moraju javiti

string sCopy1 = "cp /home/sarani/BS_Husky_projects/TakovoPreljina/log/PVSS_II.log /home/sarani/logovi/dpConnect_problem/`date +%Y_%m_%d_%H:%M:%S`.log &";
string sCopy2 = "cp /home/sarani/BS_Husky_projects/TakovoPreljina/log/PVSS_II.log.bak /home/sarani/logovi/dpConnect_problem/`date +%Y_%m_%d_%H:%M:%S`.log.bak &";

mapping settings;
string systemName = getSystemName();

main()
{
  delay(5);

  Log::info("main", "Starting script SystemConnections.ctl");

  timedFunc("checkSystemConnections","CheckSystems");
}

void checkSystemConnections(string Blinker,time t1, time t2)
{
  /*Get all script names from datapoint type ControlScriptParameters*/
  dyn_string controlScripts = dpNames("*.settings.scriptNumber");
  for (int i = 1; i <= dynlen(controlScripts); i++)
  {
    controlScripts[i] = dpSubStr(controlScripts[i], DPSUB_DP);
  }

  for (int i = 1; i <= dynlen(controlScripts); i++)
  {
    if (strpos(controlScripts[i], "_") > 0)
    {
      dynRemove(controlScripts, i);
    }
  }
  /*-------------*/
  for (int i = 1; i <= dynlen(controlScripts); i++)
  {
    string datapoint = systemName + controlScripts[i];

    if(myReduHostNum() == 1) datapoint = datapoint + "_2";

    if (!loadSettings(datapoint, controlScripts[i]))
    {
      Log::error("main", "Could not load settings for script " + controlScripts[i]);
      return;
    }

    int timeDifference = getCurrentTime() - settings[controlScripts[i]]["Script"]["Timestamp"];

    if (timeDifference > settings[controlScripts[i]]["SecondsToAnswer"])
    {
      if (settings[controlScripts[i]]["Script"]["IsAlive"])
      {
        Log::info("checkSystemConnections", "Script " + controlScripts[i] + ":  Changing script state from active to passive");
        setDP(datapoint + ".scriptState.isAlive", 0);
      }

      checkMaxTimeBetweenReset(settings[controlScripts[i]]["Client"]["NextRestartTime"], settings[controlScripts[i]]["Script"]["NextRestartTime"], controlScripts[i]);

      startThread("resetControlManager", controlScripts[i], settings[controlScripts[i]]["ScriptNumber"], settings[controlScripts[i]]["Script"]["RestartAllowed"],
                  settings[controlScripts[i]]["Script"]["RestartTryCount"], settings[controlScripts[i]]["Script"]["LastRestartTime"], settings[controlScripts[i]]["Script"]["NextRestartTime"]);

      startThread("resetClient", controlScripts[i], settings[controlScripts[i]]["ClientName"], settings[controlScripts[i]]["Client"]["RestartAllowed"],
                  settings[controlScripts[i]]["Client"]["RestartTryCount"], settings[controlScripts[i]]["Client"]["LastRestartTime"], settings[controlScripts[i]]["Client"]["NextRestartTime"]);
    }
    else if (timeDifference <= settings[script]["SecondsToAnswer"] && !settings[script]["Script"]["IsAlive"])
    {
      setDP(datapoint + ".scriptState.isAlive", true,
            datapoint + ".scriptState.restartTryCount", 0,
            datapoint + ".scriptState.nextRestartTime",makeTime(1970,1,2),
            datapoint + ".clientState.restartTryCount", 0,
            datapoint + ".clientState.nextRestartTime",makeTime(1970,1,2));

    }
    /*---------------------------------------------------------------------------------------------------------------------------------*/
  }
}

bool loadSettings(string datapoint, string script)
{
  settings[script] = makeMapping();
  settings[script]["Client"] = makeMapping();
  settings[script]["Script"] = makeMapping();

  if (!getDP(datapoint + ".settings.clientName", settings[script]["ClientName"])) return false;
  if (!getDP(datapoint + ".settings.scriptNumber", settings[script]["ScriptNumber"])) return false;
  if (!getDP(datapoint + ".settings.minTimeBetweenReset", settings[script]["MinTimeBetweenReset"])) return false;
  if (!getDP(datapoint + ".settings.maxTimeBetweenReset", settings[script]["MaxTimeBetweenReset"])) return false;
  if (!getDP(datapoint + ".settings.secondsToAnswer", settings[script]["SecondsToAnswer"])) return false;

  if (!getDP(datapoint + ".scriptState.lastRestartTime", settings[script]["Script"]["LastRestartTime"])) return false;
  if (!getDP(datapoint + ".scriptState.nextRestartTime", settings[script]["Script"]["NextRestartTime"])) return false;
  if (!getDP(datapoint + ".scriptState.isRestartAllowed", settings[script]["Script"]["RestartAllowed"])) return false;
  if (!getDP(datapoint + ".scriptState.restartTryCount", settings[script]["Script"]["RestartTryCount"])) return false;
  if (!getDP(datapoint + ".scriptState.timestamp", settings[script]["Script"]["Timestamp"])) return false;
  if (!getDP(datapoint + ".scriptState.isAlive", settings[script]["Script"]["IsAlive"])) return false;

  if (!getDP(datapoint + ".clientState.lastRestartTime", settings[script]["Client"]["LastRestartTime"])) return false;
  if (!getDP(datapoint + ".clientState.nextRestartTime", settings[script]["Client"]["NextRestartTime"])) return false;
  if (!getDP(datapoint + ".clientState.isRestartAllowed", settings[script]["Client"]["RestartAllowed"])) return false;
  if (!getDP(datapoint + ".clientState.restartTryCount", settings[script]["Client"]["RestartTryCount"])) return false;

  return true;
}

resetControlManager(string datapoint, dyn_int scriptNumbers, bool isRestartAllowed, int tryCount, time lastRestartTime, time nextRestartTime)
{
   Log::info("resetControlManager", "Reseting control script: " + datapoint, ", tryCount: " + tryCount, ", lastRestartTime", lastRestartTime, ", nextRestartTime: ", nextRestartTime, ", isRestartAllowed: ", isRestartAllowed);
   //If restart is not allowed, do nothing
   if(!isRestartAllowed)
     return;

   if(dynlen(scriptNumbers) == 0)
   {
     Log::exception("resetControlManager", "scriptNumber parameter empty!");
     return;
   }

   //This script number must be 100. If the scriptNumber for restart is <= 100, the script should not be restarted
   for(int i = 1 ; i <= dynlen(scriptNumbers); i++)
   {
     if(scriptNumbers[i] <= 100)
       	return;
   }

   time currentTime = getCurrentTime();

   if((nextRestartTime < currentTime) && (currentTime - lastRestartTime  > settings[script]["MinTimeBetweenReset"]))
   {
     tryCount++;
     nextRestartTime = calculateNextResetTime(tryCount, currentTime, datapoint);

     setDP(systemName + datapoint + ".scriptState.lastRestartTime", currentTime,
           systemName + datapoint + ".scriptState.nextRestartTime", nextRestartTime,
           systemName + datapoint + ".scriptState.restartTryCount", tryCount);

     Log::info("resetControlManager", systemName + datapoint + ".scriptState.lastRestartTime", currentTime,
                                      systemName + datapoint + ".scriptState.nextRestartTime", nextRestartTime,
                                      systemName + datapoint + ".scriptState.restartTryCount", tryCount);

     for(i = 1 ; i <= dynlen(scriptNumbers); i++)
     {
       killControlScriptByNumber(scriptNumbers[i]);
     }
   }
}

//ubija skriptu sa zadatim brojem managera
void killControlScriptByNumber(int scriptNumber)
{
  int managerId = convManIdToInt(CTRL_MAN, scriptNumber);

  string datapoint = (myReduHostNum() == 1) ? systemName + "_Managers.Exit" : systemName + "_Managers_2.Exit";
  setDP(datapoint, managerID);

  Log::info("killControlScriptByNumber", "Killing manager " + managerID + " (control script " + scriptNumber + ")");
  //setDP(systemName + "_Managers_.Refresh", managerID);  //if script doesn't start, uncomment this line
}

resetClient(string datapoint, dyn_string clientNames, bool isRestartAllowed, int tryCount, time lastRestartTime, time nextRestartTime)
{

   Log::info("resetClient", "Reseting SCADA clients: ", clientNames + ", tryCount: " + tryCount, ", lastRestartTime: ", lastRestartTime, ", nextRestartTime: ", nextRestartTime, ", isRestartAllowed: ", isRestartAllowed);
   //If restart is not allowed, do nothing
   if(!isRestartAllowed)
     return;

   if(dynlen(clientNames) == 0)
   {
     Log::exception("resetClient", "clientNames parameter empty!");
     return;
   }

   time currentTime = getCurrentTime();

   if((nextRestartTime < currentTime) && (currentTime - lastRestartTime  > settings[datapoint]["MinTimeBetweenReset"]))
   {
     tryCount++;
     nextRestartTime = calculateNextResetTime(tryCount, currentTime, datapoint);

     setDP(systemName + datapoint + ".clientState.lastRestartTime", currentTime,
           systemName + datapoint + ".clientState.nextRestartTime", nextRestartTime,
           systemName + datapoint + ".clientState.restartTryCount", tryCount);

     Log::info("resetClient", systemName + datapoint + ".clientState.lastRestartTime", currentTime,
                              systemName + datapoint + ".clientState.nextRestartTime", nextRestartTime,
                              systemName + datapoint + ".clientState.restartTryCount", tryCount);


     for(int i = 1 ; i <= dynlen(clientNames); i++)
     {
       killClientByName(clientNames[i]);
     }
   }
}

void killClientByName(string clientName)
{
  if (system("pkill -f " + clientName) != -1)
  {
    Log::info("killClientByName", "Killing SCADA client " + clientName);
  }
  else
  {
    Log::error("killClientByName", "Failed to kill SCADA client " + clientName);
  }
}

//racuna odgodjeno resetovanje
//iTryCount x e2 x min_time_between_reset
// 0   min
// 0,5 min
// 1,5 min
// 4,5 min
// 8,0 min
//12,0 min - ovo je maximalno vrijme odgodjenog resetovanje
time calculateNextResetTime(int tryCount, time currentTime, string script)
{
   if(tryCount > 5)
     tryCount = 5 ;
   float tDiff = pow(tryCount, 2) * settings[script]["MinTimeBetweenReset"];
   time nextResetTime = currentTime + tDiff;
   Log::info("currentTime: ", currentTime +  ", tDiff: " + tDiff + ", nextResetTime: " + nextResetTime);
   return nextResetTime;
}

checkMaxTimeBetweenReset(time clientNextRestartTime, time scriptNextRestartTime, string scriptName)
{
  time currentTime = getCurrentTime();
  time nextRestart = currentTime + settings[scriptName]["MaxTimeBetweenReset"];

  if(nextRestart < scriptNextRestartTime)
  {
    setDP(systemName + scriptName + ".scriptState.nextRestartTime", nextRestart);
    Log::info("checkMaxTimeBetweenReset", scriptName + ".scriptState.nextRestartTime parameter set to " + (string)nextRestart);
  }

  if(nextRestart < clientNextRestartTime)
  {
    setDP(systemName + scriptName + ".clientState.nextRestartTime", nextRestart);
    Log::info("checkMaxTimeBetweenReset", scriptName + ".clientState.nextRestartTime parameter set to " + (string)nextRestart);
  }
}


