#uses "log"
#uses "CtrlXmlRpc"
#uses "basicMethods.ctl"
#uses "SignLibrary.ctl"

main()
{

  int queryValue = dpQueryConnectSingle("sendToSignContent", true, "Identi",
                       "SELECT '_online.._value' FROM '*.command.value' WHERE _DPT = \"Sign\"");
  int queryBrightness = dpQueryConnectSingle("sendToSignLuminosity", true, "Identi",
                       "SELECT '_online.._value' FROM '*.command.intensity' WHERE _DPT = \"Sign\"");

  if ( sdGetLastError() < 0 || queryValue != 0 || queryBrightness != 0)
  {
    Log::error("dpQueryConnectSingle", "Failed to connect to dp <%s>.", "Query for reading values from signs");
    return;
  }
}

string meteoStation = "MS-OAL";
mapping settings;
string systemName = getSystemName();
string xmlRpcMethodWriteSettings = "bstelecom.sign.SignProtocolAdapter.writeSignPanel";
string xmlRpcMethodWriteBrightness = "bstelecom.sign.SignProtocolAdapter.writeSignBrightness";
string xmlRpcMethodWriteMatrixSettings = "bstelecom.sign.SignProtocolAdapter.writeMatrixSignPanel";
string xmlRpcMethodWritePortalSettings = "bstelecom.sign.SignProtocolAdapter.writePortalSignPanel";
string xmlRpcMethodWriteTwoPannelsDisplayLoopSettings = "bstelecom.sign.SignProtocolAdapter.writePortal_PetljaSignTwoPanels";
string xmlRpcMethodWriteTwoPannelsDisplaySettings = "bstelecom.sign.SignProtocolAdapter.writePortalSignTwoPanels";
string xmlRpcMethodWriteOversizedSign = "bstelecom.sign.SignProtocolAdapter.writeVangabaritni_Sign";
bool initSign = false;
bool initLumin = false;

void sendToSignContent(anytype ident, dyn_dyn_anytype list){

  if(!isReduActive())
    return;

  if(!initSign)
  {
    initSign = true;
    return;
  }

  string signName;
  dyn_int value;

  for(int i = 2; i <= dynlen(list); i++)  //starta sa 2 zato sto liste pocinju od 1, a sql upit vraca u prvoj liniji header pa treba i njega preskociti
  {
    value = list[i][2];
    signName = dpSubStr(list[i][1], DPSUB_DP);  //DPSUB_DP -
    dpSet(signName + ".response.signStatus", 1);
    startThread("sendToSignContentSingle", signName, value);
  }
}

bool loadSettings(string signName)
{
  settings["ID"] = "servID" + rand();
  settings["HOST"] = "localhost";

  if(!getDP(systemName + "_mp_SignSettings.settings.serverPort", settings["PORT"])) return false;
  if(!getDP(systemName + signName + ".settings.IP", settings["IP"])) return false;
  if(!getDP(systemName + signName + ".settings.signType", settings["TYPE"])) return false;

  return true;
}

void sendToSignContentSingle(string signName, dyn_int value)
{
  Log::info("sendToSignContentSingle", "Starting sending values to sign" + signName);

  //getting mapped values that needs to be sent on sign
  dyn_int getSignSymbols = getMappingValueArray(value, signName);
  dyn_mixed args;
  string xmlRpcMethod = "";

  if(getSignSymbols[1] == -1)
  {
     Log::error("sendToSignContentSingle", "MappedValues is undefined " + signName);
     dpSet(systemName + signName + ".response.signStatus", -1);
     return;
  }

  if (!loadSettings(signName))
  {
     Log::error("loadSettings", "Could not load settings for script ReadSignValues" + settings);
     return;
  }

  switch(settings["TYPE"])
  {
    case 4:  //display signs
      args = generateArgumentsForDisplaySign(settings["IP"], settings["TYPE"], getSignSymbols[1]);
      xmlRpcMethod = xmlRpcMethodWriteTwoPannelsDisplaySettings;
      break;
    case 6:  //matrix signs
      if(dynlen(getSignSymbols) == 1)
         args = generateArgumenstForMatrixSign(settings["IP"], settings["TYPE"], getSignSymbols[1], -1);
      else
         args = generateArgumenstForMatrixSign(settings["IP"], settings["TYPE"], getSignSymbols[1], getSignSymbols[2]);

      xmlRpcMethod = xmlRpcMethodWriteMatrixSettings;
    break;
    case 8:  //display on loops signs
      args = generateArgumentsForDisplayLoopSign(settings["IP"], settings["TYPE"], getSignSymbols[1]);
      xmlRpcMethod = xmlRpcMethodWriteTwoPannelsDisplayLoopSettings;
      break;
    case 10:  //oversized signs
      args = makeDynMixed(settings["TYPE"], settings["IP"], getSignSymbols[1]);
      xmlRpcMethod = xmlRpcMethodWriteOversizedSign;
      break;
    default:  //other signs
      if(dynlen(getSignSymbols) == 1)
         args = makeDynMixed(settings["TYPE"], settings["IP"], getSignSymbols[1]);
      else
         args = makeDynMixed(settings["TYPE"], settings["IP"], getSignSymbols);
     xmlRpcMethod = xmlRpcMethodWriteSettings;
  }

  Log::info("sendToSignContentSingle", "Znak: " + signName + " -- Args: " + args);
  int res = xmlRpcSendToSign(args, xmlRpcMethod, settings["ID"], settings["HOST"], settings["PORT"]);
  Log::info("sendToSignContentSingle", "Znak: " + signName + " -- Result od xmlrpc call: " + res);

  if (res == 0) dpSet(systemName + signName + ".response.signStatus", 0);
  else
  {
    Log::info("sendToSignContentSingle", "Znak: " + signName + " Not sent. Pokusava ponovo");
    delay(1);
    res = xmlRpcSendToSign(args, xmlRpcMethod, settings["ID"], settings["HOST"], settings["PORT"]);

    Log::info("sendToSignContentSingle", "Znak: " + signName + " -- Result second try: " + res);

    if (res == 0) dpSet(systemName + signName + ".response.signStatus", 0);
    else
    {
      Log::error("sendToSignContentSingle", "There si not communication, can not send values to sign" + signName);
      dpSet(systemName + signName + ".response.signStatus", -1);
    }//end else
  }//end else
}

void sendToSignLuminosity(anytype ident, dyn_dyn_anytype list)
{
  if(!isReduActive())
    return;

  if(!initLumin)
  {
    initLumin = true;
    return;
  }
  string signName;
  int value;

  for(int i = 2; i <= dynlen(list); i++)  //starta sa 2 zato sto liste pocinju od 1, a sql upit vraca u prvoj liniji header pa treba i njega preskociti
  {
    value = list[i][2];
    signName = dpSubStr(list[i][1], DPSUB_DP);  //DPSUB_DP -
    dpSet(signName + ".response.signStatus", 1);
    startThread("sendToSignLuminositySingle", signName, value);
  }
}

void sendToSignLuminositySingle(string signName, int value)
{
  dyn_mixed args;
  int iFixBrightness, iFixBrightnessPriority, iDaytimeDepedencePriority, iLightSensorPriority;

  if (!loadSettings(signName))
  {
     Log::error("loadSettings", "Could not load settings for script ReadSignValues" + settings);
     return;
  }

  if(value == "0")       //time day time
  {
      iFixBrightness = -1; iFixBrightnessPriority = 0; iDaytimeDepedencePriority = 2; iLightSensorPriority = 1;
  }
  else if(value == "1")  //light sensor
  {
      iFixBrightness = -1; iFixBrightnessPriority = 0; iDaytimeDepedencePriority = 1; iLightSensorPriority = 2;
  }
  else                   //fix brightness
  {
      iFixBrightness = value; iFixBrightnessPriority = 2; iDaytimeDepedencePriority = 0; iLightSensorPriority = 1;
  }

   dyn_mixed args = makeDynMixed(settings["TYPE"], settings["IP"], iFixBrightness, iFixBrightnessPriority, iDaytimeDepedencePriority, iLightSensorPriority);
   Log::info("sendToSignLuminositySingle", "Send to sign luminosity: " + signName + " -- Args: " + args);

   int res = xmlRpcSendToSign(args, xmlRpcMethodWriteBrightness, settings["ID"], settings["HOST"], settings["PORT"]);
   Log::info("sendToSignLuminositySingle", "Znak: " + signName + " -- Result od xmlrpc call: " + res);

   if (res != 0)
   {
     Log::error("sendToSignLuminositySingle", "There si not communication, can not send values to sign" + signName);
     dpSet(systemName + signName + ".response.signStatus", -1);
   }
    else dpSet(systemName + signName + ".response.signStatus", 0);
}

mapping getTypeMapping(int signType)
{
  dyn_string mappingSignType;
  mapping map;
  string dp = systemName + "Type" + signType + ".settings.mappedValues";
  string value, idPicture;

  if(signType == 0){
    Log::error("getTypeMapping", "Sign type is not defined " + signType);
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

dyn_int getMappingValueArray(dyn_int value, string dpe)
{
  dyn_int signArrayForSending;
  int signType;
  if(!getDP(systemName + dpe + ".settings.signType", signType))
      Log::error("getMappingValueArray", "MappedValues is undefined " + dpe);

  mapping map = getTypeMapping(signType);
  if(mappinglen(map) == 0)
  {
      Log::error("getMappingValueArray", "Mapping is empty for SignType " + signType);
      return -1;
  }

  for(int i=1;i<=dynlen(value);i++)
  {
    if (!mappingHasKey(map, (string)value[i])){
      Log::error("getMappingValueArray", "Mapping does not contain value. Map: " + map);
      signArrayForSending[1] = -1;
      return signArrayForSending;
    }
    signArrayForSending[i] = map[(string)value[i]];
  }
  return signArrayForSending;
}

//generate arguments for command that needs to change content on Matrix sign
//bgr1 - ID of first content (panel)
//bgr2 - ID of second content (panel), if value is -1 than show fisrt content only
dyn_mixed generateArgumenstForMatrixSign(string signIP, int signType, int firstPanelToShow, int secondPanelToShow)
{
   dyn_mixed args;
			int active = 1;
   int duration = 0;
   if(secondPanelToShow >= 0) duration = 30;

			int fn1 = 0; int cl1 = 0; int alig1 = 1; int maxSp1 = 2; int y1 = 0; int xL1 = 0; int xR1 = 47;
			int fn2 = 0; int cl2 = 0; int alig2 = 1; int maxSp2 = 2; int y2 = 0; int xL2 = 0; int xR2 = 47;
			int fn3 = 0; int cl3 = 0; int alig3 = 1; int maxSp3 = 2; int y3 = 0; int xL3 = 0; int xR3 = 47;
   string sText = "";

			args = makeDynMixed(signType, signIP,
                       active, duration, firstPanelToShow, secondPanelToShow,
                       fn1, cl1, alig1, maxSp1, y1, xL1, xR1,
                       fn2, cl2, alig2, maxSp2, y2, xL2, xR2,
                       fn3, cl3, alig3, maxSp3, y3, xL3, xR3,
                       sText);

   Log::info("generateArgumenstForMatrixSign", "Generate arguments for matrix sign: " + signIP + " -- Args: " + args);
   return args;
}

mapping getMappingDisplay()
{
  dyn_string getConfigFromDp;
  mapping map;
  string nameOfArguments;
  string arguments;
  dpGet(systemName + "_mp_SignSettings.settings.displayConfiguration", getConfigFromDp);

  if(dynlen(getConfigFromDp) == 0)
  {
      Log::error("getMappingDisplay", "DP is empty" + getConfigFromDp);
      return map;
  }
  for(int i=1; i <= dynlen(getConfigFromDp); i++)
  {
     nameOfArguments = substr(getConfigFromDp[i], 0, strpos(getConfigFromDp[i], "|", 0));
     arguments = substr(getConfigFromDp[i], strpos(getConfigFromDp[i], "|", 1) + 1);
     map[nameOfArguments] = arguments;
  }

  return map;
}

//return id of picture based on pictureId
string getIdPictureForDisplay(string pictureId)
{
  dyn_string getConfigFromDp, splitArray;
  mapping map;
  dpGet(systemName + "_mp_SignSettings.settings.displayPictureNamesConfig", getConfigFromDp);
  if(dynlen(getConfigFromDp) == 0)
  {
      Log::error("getIdPictureForDisplay", "DP is empty" + getConfigFromDp);
      return "Error";
  }

  for(int i=1; i <= dynlen(getConfigFromDp); i++)
  {
     splitArray = strsplit(getConfigFromDp[i], "|");
     if(dynlen(splitArray) < 2)
     {
        Log::error("getIdPictureForDisplay", "splitArray is < 2" + splitArray);
        return "Error";
     }
     map[splitArray[1]] = splitArray[2];
  }
  return map[pictureId];
}

//generate arguments for command that needs to change content on Display sign
dyn_mixed generateArgumentsForDisplaySign(string ipAddress, int signType, int iValue)
{
   dyn_mixed args;
   mapping displayConfigMap = getMappingDisplay();
   string pictureId = getIdPictureForDisplay(iValue);
   string stringArguments = (mappingHasKey(displayConfigMap, pictureId)) ? displayConfigMap[pictureId] : "-1";
   dyn_string splitArray = strsplit(stringArguments, "|");

   for(int i=1;i<36;i++) strreplace(splitArray[i], " ", "");
   for(int i=37;i<70;i++) strreplace(splitArray[i], " ", "");
   strreplace(splitArray[1], "TypeID", signType);
   strreplace(splitArray[2], "IPAddress", ipAddress);

   int iSign_Type_ID = splitArray[1];
   string sIP_addr = splitArray[2];
   int Active = splitArray[3], Duration = splitArray[4], Bgr1 = splitArray[5];
			int Bgr2 = splitArray[8], Fn1 = splitArray[11], Cl1 = splitArray[12], Alig1 = splitArray[13];
   int MaxSp1 = splitArray[14], Y1 = splitArray[15], XL1 = splitArray[16], XR1 = splitArray[17];
			int Fn2 = splitArray[18], Cl2 = splitArray[19], Alig2 = splitArray[20];
   int MaxSp2 = splitArray[21], Y2 = splitArray[22], XL2 = splitArray[23], XR2 = splitArray[24];
			int Fn3 = splitArray[25], Cl3 = splitArray[26], Alig3 = splitArray[27];
   int MaxSp3 = splitArray[28], Y3 = splitArray[29], XL3 = splitArray[30], XR3 = splitArray[31];
   int Pict1 = splitArray[32], Pict2 = splitArray[33], Pict3 = splitArray[34], Pict4 = splitArray[35];
   string sText = substr(splitArray[36], 1, (strlen(splitArray[36])-2));

   int Active_2 = splitArray[37], Duration_2 = splitArray[38], Bgr1_2 = splitArray[39];
			int Bgr2_2 = splitArray[42];
   int Fn1_2 = splitArray[45], Cl1_2 = splitArray[46], Alig1_2 = splitArray[47];
   int MaxSp1_2 = splitArray[48], Y1_2 = splitArray[49], XL1_2 = splitArray[50], XR1_2 = splitArray[51];
			int Fn2_2 = splitArray[52], Cl2_2 = splitArray[53], Alig2_2 = splitArray[54];
   int MaxSp2_2 = splitArray[55], Y2_2 = splitArray[56], XL2_2 = splitArray[57], XR2_2 = splitArray[58];
			int Fn3_2 = splitArray[59], Cl3_2 = splitArray[60], Alig3_2 = splitArray[61];
   int MaxSp3_2 = splitArray[62], Y3_2 = splitArray[63], XL3_2 = splitArray[64], XR3_2 = splitArray[65];
   int Pict1_2 = splitArray[66], Pict2_2 = splitArray[67], Pict3_2 = splitArray[68], Pict4_2 = splitArray[69];
   string sText_2 = substr(splitArray[70], 1, (strlen(splitArray[70])-1));

   if(strpos(sText, "TIME", 0) > 1)
   {
      //dio treba rijesiti kad se bude znalo kako se zove meteostanica
      float fTemp = 0, fTemp1;
      time ms1t, tCurTime = getCurrentTime();
      if(!getDP(systemName + meteoStation + ".measurements.temperature", fTemp1)) return args;
      if(!getDP(systemName + meteoStation + ".measurements.temperature:_original.._stime", ms1t)) return args;

      //If the temperature reading is in time, send temperature value to sign
      if((tCurTime - ms1t) < 600)  //10min
         fTemp = fTemp1;
      else
       fTemp = 99;

      string sTemp = "";
      sprintf(sTemp,"%+5.1f", fTemp);

      if(fTemp != 99){
        strreplace(sText, "'TIME'", "'TIME' " + sTemp + "°C");
        strreplace(sText_2, "'TIME'", "'TIME' " + sTemp + "°C");
      }
   }

   args = makeDynMixed(iSign_Type_ID, sIP_addr,
                          Active, Duration,
                          Bgr1, 0, 0,
                          Bgr2, 136, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1,
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2,
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3,
                          Pict1, Pict2, Pict3, Pict4,
                          sText,
                          Active_2, Duration,
                          Bgr1_2, 0, 0,
                          Bgr2_2, 136, 0,
                          Fn1_2, Cl1, Alig1, MaxSp1, Y1_2, XL1, XR1,
                          Fn2_2, Cl2, Alig2, MaxSp2, Y2_2, XL2, XR2,
                          Fn3_2, Cl3, Alig3, MaxSp3, Y3_2, XL3, XR3,
                          Pict1_2, Pict2_2, Pict3_2, Pict4_2,
                          sText_2);

   Log::info("generateArgumentsForDisplaySign", "Get arguments for display sign: " + ipAddress + " -- Args: " + args);
   return args;

}

//generate arguments for command that needs to change content on Display Loop sign
dyn_mixed generateArgumentsForDisplayLoopSign(string ipAddress, int signType, int iValue)
{
   dyn_mixed args;
   mapping displayConfigMap = getMappingDisplay();
   string pictureId = getIdPictureForDisplay(iValue);
   string stringArguments = displayConfigMap[pictureId];
   dyn_string splitArray = strsplit(stringArguments, "|");

   for(int i=1;i<32;i++) strreplace(splitArray[i], " ", "");
   for(int i=37;i<62;i++) strreplace(splitArray[i], " ", "");
   strreplace(splitArray[1], "TypeID", signType);
   strreplace(splitArray[2], "IPAddress", ipAddress);

   int iSign_Type_ID = splitArray[1];
   string sIP_addr = splitArray[2];
   int Active = splitArray[3], Duration = splitArray[4], Bgr1 = splitArray[5];
			int Bgr2 = splitArray[8], Fn1 = splitArray[11], Cl1 = splitArray[12], Alig1 = splitArray[13];
   int MaxSp1 = splitArray[14], Y1 = splitArray[15], XL1 = splitArray[16], XR1 = splitArray[17];
			int Fn2 = splitArray[18], Cl2 = splitArray[19], Alig2 = splitArray[20];
   int MaxSp2 = splitArray[21], Y2 = splitArray[22], XL2 = splitArray[23], XR2 = splitArray[24];
			int Fn3 = splitArray[25], Cl3 = splitArray[26], Alig3 = splitArray[27];
   int MaxSp3 = splitArray[28], Y3 = splitArray[29], XL3 = splitArray[30], XR3 = splitArray[31];
   string sText = substr(splitArray[32], 1, (strlen(splitArray[32])-2));
   int Active_2 = splitArray[33], Duration_2 = splitArray[34], Bgr1_2 = splitArray[35];
			int Bgr2_2 = splitArray[38];
   int Fn1_2 = splitArray[41], Cl1_2 = splitArray[42], Alig1_2 = splitArray[43];
   int MaxSp1_2 = splitArray[44], Y1_2 = splitArray[45], XL1_2 = splitArray[46], XR1_2 = splitArray[47];
			int Fn2_2 = splitArray[48], Cl2_2 = splitArray[49], Alig2_2 = splitArray[50];
   int MaxSp2_2 = splitArray[51], Y2_2 = splitArray[52], XL2_2 = splitArray[53], XR2_2 = splitArray[54];
			int Fn3_2 = splitArray[55], Cl3_2 = splitArray[56], Alig3_2 = splitArray[57];
   int MaxSp3_2 = splitArray[58], Y3_2 = splitArray[59], XL3_2 = splitArray[60], XR3_2 = splitArray[61];
   string sText_2 = substr(splitArray[62], 1, (strlen(splitArray[62])-1));

   args = makeDynMixed(iSign_Type_ID, sIP_addr,
                          Active, Duration,
                          Bgr1, 0, 0,
                          Bgr2, 176, 0,
                          Fn1, Cl1, Alig1, MaxSp1, Y1, XL1, XR1,
                          Fn2, Cl2, Alig2, MaxSp2, Y2, XL2, XR2,
                          Fn3, Cl3, Alig3, MaxSp3, Y3, XL3, XR3,
                          sText,
                          Active_2, Duration,
                          Bgr1_2, 0, 0,
                          Bgr2_2, 176, 0,
                          Fn1_2, Cl1, Alig1, MaxSp1, Y1_2, XL1, XR1,
                          Fn2_2, Cl2, Alig2, MaxSp2, Y2_2, XL2, XR2,
                          Fn3_2, Cl3, Alig3, MaxSp3, Y3_2, XL3, XR3,
                          sText_2);

   Log::info("generateArgumentsForDisplayLoopSign", "Get arguments for display loop sign: " + ipAddress + " -- Args: " + args);
   return args;
}
