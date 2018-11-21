#uses "log"
#uses "CtrlXmlRpc"
#uses "basicMethods.ctl"
#uses "SignLibrary.ctl"

bool initSignWrite = false;
bool initSignRead = false;

string systemName = getSystemName();
main()
{

  int queryValueWrite = dpQueryConnectSingle("sendToSignContent", true, "Identi",
                       "SELECT '_online.._value' FROM '*.command.value' WHERE _DPT = \"Sign\"");

  int queryValueRead = dpQueryConnectSingle("readSignContentContent", true, "Identi",
                       "SELECT '_online.._value' FROM '*.response.plcValue' WHERE _DPT = \"Sign\"");

  if ( sdGetLastError() < 0 || queryValueWrite != 0 || queryValueRead != 0)
  {
    Log::error("dpQueryConnectSingle", "Failed to connect to dp <%s>.", "Query for reading values from signs");
    return;
  }
}

void sendToSignContent(anytype ident, dyn_dyn_anytype list)
{
  if(!isReduActive())
    return;

  if(!initSignWrite)
  {
    initSignWrite = true;
    return;
  }

  string signName;
  dyn_int value;

  for(int i = 2; i <= dynlen(list); i++)  //starta sa 2 zato sto liste pocinju od 1, a sql upit vraca u prvoj liniji header pa treba i njega preskociti
  {
    value = list[i][2];
    signName = dpSubStr(list[i][1], DPSUB_DP);  //DPSUB_DP -
    dpSet(signName + ".response.signStatus", 1);
    startThread("convertToPlcValue", signName, value);
  }
}

void readSignContentContent(anytype ident, dyn_dyn_anytype list)
{
  if(!isReduActive())
    return;

  if(!initSignRead)
  {
    initSignRead = true;
    return;
  }

  string signName;
  dyn_int value;

  for(int i = 2; i <= dynlen(list); i++)  //starta sa 2 zato sto liste pocinju od 1, a sql upit vraca u prvoj liniji header pa treba i njega preskociti
  {
    value = list[i][2];
    signName = dpSubStr(list[i][1], DPSUB_DP);  //DPSUB_DP -
    dpSet(signName + ".response.signStatus", 1);
    startThread("convertToScadaValue", signName, value);
  }
}

void convertToScadaValue(string signName, dyn_int value)
{
   int getSignSymbol = getMappingValueArrayRead(value, signName);

   if(getSignSymbol == -1)
   {
      Log::error("convertToScadaValue", "MappedValues is undefined " + signName);
      dpSet(systemName + signName + ".response.signStatus", -1);
      return;
   }

   Log::info("convertToScadaValue", "Znak: " + signName + " -- Args: " + getSignSymbol);
   dpSet(systemName + signName + ".response.value", getSignSymbol);
}

void convertToPlcValue(string signName, dyn_int value)
{
   dyn_int getSignSymbols = getMappingValueArrayWrite(value, signName);

   if(getSignSymbols[1] == -1)
   {
      Log::error("convertToPlcValue", "MappedValues is undefined " + signName);
      dpSet(systemName + signName + ".response.signStatus", -1);
      return;
   }

   Log::info("convertToPlcValue", "Znak: " + signName + " -- Args: " + getSignSymbols);
   dpSet(systemName + signName + ".command.plcValue", getSignSymbols[1]);
}

mapping getMappingPlcValues(string signGroup)
{
  dyn_string mappingSignType;
  mapping map;
  string dp = systemName + "Type" + signGroup + ".settings.mappedValues";
  string value, idPicture;

  if(signGroup == ""){
    Log::error("getMappingPlcValues", "Sign type is not defined " + signGroup);
    return map;
  }
  dpGet(dp, mappingSignType);

  for(int i=1; i <= dynlen(mappingSignType); i++)
  {
     idPicture = substr(mappingSignType[i], 0, strpos(mappingSignType[i], "|", 0));
     value = substr(mappingSignType[i], strpos(mappingSignType[i], "|", 1) + 1);
     map[idPicture] = value;   //get id of value based on image id
  }
  return map;
}

dyn_int getMappingValueArrayWrite(dyn_int value, string dpe)
{
  string signGroup;

  signGroup = getSignGroup(value);
  mapping map = getMappingPlcValues(signGroup);

  return getValueFromMapping(map, value);
}

int getMappingValueArrayRead(dyn_int value, string dpe)
{
  dyn_string signGroups;
  int idPicture;
  dyn_string signGroupSplit;

  if(!getDP(systemName + "_mp_SignSettings.settings.signGroups", signGroups)) return -1;

  if(dynlen(signGroups) == 0)
  {
     Log::error("main for sign group", "DP is empty, signGroups" + signGroups);
     return -1;
  }

  for(int i=1; i <= dynlen(signGroups); i++)
  {
    signGroupSplit = strsplit(signGroups[i], "|");
    idPicture = getMappingScadaValues(signGroupSplit[2], value);
    if(idPicture != -1) return idPicture;
  }
}

int getMappingScadaValues(string signGroup, dyn_int value)
{
  dyn_string mappingSignType;
  dyn_int signValues;
  string dp = systemName + "Type" + signGroup + ".settings.mappedValues";
  string plcValue, idPicture;

  if(signGroup == ""){
    Log::error("getMappingScadaValues", "Sign group is not defined " + signGroup);
    return -1;
  }
  dpGet(dp, mappingSignType);

  for(int i=1; i <= dynlen(mappingSignType); i++)
  {
     idPicture = substr(mappingSignType[i], 0, strpos(mappingSignType[i], "|", 0));
     plcValue = substr(mappingSignType[i], strpos(mappingSignType[i], "|", 1) + 1);
     if(plcValue == value[1]) return idPicture;
  }
  return -1;
}

dyn_int getValueFromMapping(mapping map, dyn_int value)
{
  dyn_int signValues;
  if(mappinglen(map) == 0)
  {
      Log::error("getValueFromMapping", "Mapping is empty for SignType " + map);
      return -1;
  }

  for(int i=1;i<=dynlen(value);i++)
  {
    if (!mappingHasKey(map, (string)value[i])){
      Log::error("getValueFromMapping", "Mapping does not contain value. Map: " + map);
      signValues[1] = -1;
      return signValues;
    }
    signValues[i] = map[(string)value[i]];
  }

  return signValues;
}

string getSignGroup(dyn_int value)
{
  dyn_string groupConfiguration;
  dyn_string splitArray;

  if(!getDP(systemName + "_mp_SignSettings.settings.signGroupConfiguration", groupConfiguration))
      Log::error("getSignGroup", "MappedValues is undefined signGroupConfiguration");


  for(int i=1;i<=dynlen(groupConfiguration);i++)
  {
    splitArray = strsplit(groupConfiguration[i], "|");
    if(dynlen(splitArray) < 2)
    {
          Log::error("getDeviceType", "splitArray is < 2" + splitArray);
          return "Error";
    }
    if(splitArray[1] == value[1]) {
      return splitArray[2];
      break;
    }
  }
}
