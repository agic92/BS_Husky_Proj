string systemName = "SysSozina:";
string scriptName = "SoundAlarmNotification";
main()
{
  string query="SELECT ALERT '_alert_hdl.._value' FROM '**'";
  dpQueryConnectSingle("handleAlarmSounds", 0, "userData", query);

  startThread("sendAliveSignal");
}

void handleAlarmSounds(dyn_dyn_string userData, dyn_dyn_anytype data)
{
  for (int i = 2; i <= dynlen(data); i++)
  {
    string dpElement = data[i][1];
    string alertText, text;
    int actState, actRange;
    bool alarmDirection;

    atime aLastAlarmTime = makeATime(data[i][2], 0, dpElement);

    dpGet(dpElement + ":_alert_hdl.._act_range", actRange);
    dpGet(dpElement + ":_alert_hdl." + actRange + "._text", alertText);
    dpGet(dpElement + ":_alert_hdl.._act_state",actState);
    alertGet(aLastAlarmTime, getACount(aLastAlarmTime), dpElement + ":_alert_hdl." + actRange + "._direction", alarmDirection);

    if ((actState == 1 || actState == 3) && alarmDirection)
    {
      string soundFileName = getPath(DATA_REL_PATH, "alarmSounds/" + getSoundFileName(alertText));
      startSound(soundFileName);
    }
  }
}

string getSoundFileName(string alertText)
{
  dyn_dyn_string alarmSoundFilesMapping;
  dpGet("SysSozina:_mp_AlarmTableParameters.settings.alarmSoundFilesMapping", alarmSoundFilesMapping);

  for (int i = 1; i <= dynlen(alarmSoundFilesMapping); i++)
  {
    dyn_string array = strsplit(alarmSoundFilesMapping[i], "|");
    if (array[1] == alertText) return array[2];
  }

  return "defaultSound.wav";
}

void sendAliveSignal()
{
  while (1)
  {
    if (dpSet(systemName + scriptName + ".scriptState.isAlive", 1) == 0) {}
    else
    {
      DebugTN("Server currently unavailable");
    }
    delay(10);
  }
}
