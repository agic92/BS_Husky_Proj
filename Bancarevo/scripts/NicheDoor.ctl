#uses "log.ctl"
#uses "basicMethods.ctl"

mapping settings, threadIds;
string systemName = getSystemName();
string scriptName = "NicheDoor";


int main()
{
  if (!loadSettings())
  {
    Log::error("main", "Could not load settings from niche " + nicheName);
  }

  if (dpQueryConnectSingle("trackNicheDoorStatus", true, "", "SELECT '_original.._value' FROM '*.state.isNicheDoorOpen' WHERE _DPT = \"Niche\"") == -1)
  {
    Log::error("main", "Error in calling dpQeueryConnectSingle for checking the door state");
  }

  if (dpQueryConnectSingle("trackTimerStatus", true, "", "SELECT '_original.._value' FROM '*.state.isTimerActive' WHERE _DPT = \"Niche\"") == -1)
  {
    Log::error("main", "Error in calling dpQeueryConnectSingle for checking the timer state");
  }
}

void trackNicheDoorStatus (anytype userData, dyn_dyn_anytype data) {

  for(int i = 2; i <= dynlen(data); i++)
  {
    string nicheName =  dpSubStr(data[i][1], DPSUB_DP);
    if (nicheName == "_mp_Niche") break;
    startThread("handleNicheLightStatus", nicheName);
    startThread("handleNicheFlashlightStatus", nicheName);
  }
}

void handleNicheLightStatus (string nicheName)
{
  bool isDoorOpen, isTimerActive;
  getDP(systemName + nicheName + ".state.isNicheDoorOpen", isDoorOpen,
        systemName + nicheName + ".state.isTimerActive", isTimerActive);

  /*Light was turned off when opening a door - turning the light on and keeping it turned on as long as the door is open*/
  if (isDoorOpen)
  {
    setDP(systemName + nicheName + ".command.turnOnNicheLight", 1);

    resetTimer(nicheName);

    if (mappingHasKey(threadIds, nicheName))
    {
      if (stopThread(threadIds[nicheName]) == -1)
      {
        Log::error("handleNicheLightStatus", "Error in stopping the thread for keeping the light on for " + settings["SecondsToKeepLightOn"] + " seconds");
      }
    }
  }
  /*After closing a door keep the light on for settings["SecondsToKeepLightOn"] seconds and than turn it off*/
  else if (!isDoorOpen)
  {
    threadIds[nicheName] = startThread("turnTheLigthOffAfterDelay", settings["SecondsToKeepLightOn"], nicheName);
  }
}

void resetTimer(string nicheName)
{
  setDP(systemName + nicheName + ".state.timerSecondsCount", 0);
  setDP(systemName + nicheName + ".state.isTimerActive", 0);
}

void turnTheLigthOffAfterDelay(int secondsToKeepLightOn, string nicheName)
{
  setDP(systemName + nicheName + ".state.isTimerActive", 1);

  for (int i = 1; i <= secondsToKeepLightOn; i++)
  {
    setDP(systemName + nicheName + ".state.timerSecondsCount", i);
    delay(1);
  }

  setDP(systemName + nicheName + ".state.isTimerActive", 0);
}

void handleNicheFlashlightStatus (string nicheName)
{
  bool isNicheDoorOpen;
  getDP(systemName + nicheName + ".state.isNicheDoorOpen", isNicheDoorOpen);

  if (isNicheDoorOpen) {
    setDP(systemName + nicheName + ".state.isFlashlightActive", 1);
    setDP(systemName + nicheName + ".command.turnOnNicheFlashlight", 1);
    delay(1);
    setDP(systemName + nicheName + ".command.turnOnNicheFlashlight", 0);
    delay(1);
    handleNicheFlashlightStatus(nicheName);
  }
  else {
    setDP(systemName + nicheName + ".command.turnOnNicheFlashlight", 0);
    setDP(systemName + nicheName + ".state.isFlashlightActive", 0);
  }
}

void trackTimerStatus(anytype userData, dyn_dyn_anytype data)
{
  for(int i = 2; i <= dynlen(data); i++)
  {
    string nicheName =  dpSubStr(data[i][1], DPSUB_DP);
    if (nicheName == "_mp_Niche") break;

    bool isTimerActive = data[i][2];
    startThread("trackNicheTimerStatus", nicheName, isTimerActive);
  }
}

void trackNicheTimerStatus(string nicheName, bool isTimerActive)
{
  bool isDoorOpen;
  getDP(systemName + nicheName + ".state.isNicheDoorOpen", isDoorOpen);

  /*settings["SecondsToKeepLightOn"] seconds passed, turn the light off*/
  if (!isTimerActive && !isDoorOpen)
  {
    if (!isDoorOpen)
    {
      setDP(systemName + nicheName + ".command.turnOnNicheLight", 0);
    }
    resetTimer(nicheName);
  }
}

bool loadSettings()
{
  if (!getDP(systemName  + "_mp_Niche.settings.secondsToKeepLightOn", settings["SecondsToKeepLightOn"])) return false;
  return true;
}





