#uses "log"
#uses "CtrlXmlRpc"
#uses "basicMethods.ctl"

string systemName = getSystemName();
string xmlRpcMethodReadSettings = "bstelecom.sign.SignProtocolAdapter.readCurrentSignPanel";
string xmlRpcMethodReadDisplaySettings = "bstelecom.sign.SignProtocolAdapter.readCurrentPortalSignPanel";
string xmlRpcMethodReadMatrixSettings = "bstelecom.sign.SignProtocolAdapter.readCurrentMatrixSignPanel";
string xmlRpcMethodReadBrightness = "bstelecom.sign.SignProtocolAdapter.readSignBrightness";
string xmlRpcMethodReadOversizeVehicleSettings = "bstelecom.sign.SignProtocolAdapter.readVangabaritni_Sign";
string xmlRpcMethodReadDisplayLoopSettings = "bstelecom.sign.SignProtocolAdapter.readCurrentPortal_PetljaSignPanel";
mapping settings;

main()
{
  timedFunc("readSignQuery", "SignReadFunc");//dodati SignReadFunc, interval 120 sekundi i syncTime -1

  int queryValue = dpQueryConnectSingle("readSignValue", true, "Identi",
                       "SELECT '_online.._value' FROM '*.command.value' WHERE _DPT = \"Sign\"");
  int queryBrightness = dpQueryConnectSingle("readSignBrightness", true, "Identi",
                       "SELECT '_online.._value' FROM '*.command.intensity' WHERE _DPT = \"Sign\"");

  if ( sdGetLastError() < 0 || queryValue != 0 || queryBrightness != 0)
  {
    Log::error("dpQueryConnectSingle", "Failed to connect to dp <%s>.", "Query for reading values from signs");
    return;
  }
}

void readSignQuery()
{
  dyn_dyn_anytype list;
  dpQuery("SELECT '_online.._value' FROM '" + systemName + "*.command.value' WHERE _DPT = \"Sign\"", list);

  for(int i = 2; i <= dynlen(list); i++){
     string dpe = dpSubStr(list[i][1], DPSUB_DP);
     startThread("readSignValueSingle", dpe);
     startThread("readSignBrightnessSingle", dpe);
  }

}

//when status on signs changes, this method invokes
readSignValue(anytype ident, dyn_dyn_anytype list)
{
  if(!isReduActive())
    return;

  string dpe;
  delay(6);

  for(int i = 2; i <= dynlen(list); i++)
  {
    dpe = dpSubStr(list[i][1], DPSUB_DP);  //DPSUB_DP -
    int thId = startThread("readSignValueSingle", dpe);
    waitThread(thId);
  }
}

//when intensity on signs changes, this method invokes
readSignBrightness(anytype ident, dyn_dyn_anytype list)
{
  if(!isReduActive())
    return;

  string dpe;
  delay(10);

  for(int i = 2; i <= dynlen(list); i++)
  {
    dpe = dpSubStr(list[i][1], DPSUB_DP);  //DPSUB_DP -
    int thId = startThread("readSignBrightnessSingle", dpe);
    waitThread(thId);
  }
}

bool loadSettings(string signName)
{
  settings["ID"] = "servID" + rand();
  settings["HOST"] = "localhost";

  if(!getDP(systemName + "_mp_SignSettings.settings.serverPort", settings["PORT"])) return false;
  if(!getDP(systemName + signName + ".response.signStatus", settings["STATUS"])) return false;
  if(!getDP(systemName + signName + ".settings.IP", settings["IP"])) return false;
  if(!getDP(systemName + signName + ".settings.signType", settings["TYPE"])) return false;

  return true;
}

void readSignValueSingle(string signName)
{
  delay(0.5);
  Log::info("readSignValueSingle", "Starting reading values from sign" + signName);

  mapping readCurrentSign;
  int readCurentSignOversizeVehicle;
  int active, duration;

  if (!loadSettings(signName))
  {
     Log::error("loadSettings", "Could not load settings for script ReadSignValues" + settings);
     return;
  }

  //try reading from the sign max 3 times, if it reads dont't try anymore, he will not try further because he managed to read
  for(int x = 1; x <= 3; x++)
  {
    if(settings["TYPE"] == 4) readCurrentSign = xmlrpcCallForSignRead(signName, xmlRpcMethodReadDisplaySettings); //display signs
    else if(settings["TYPE"] == 6) readCurrentSign = xmlrpcCallForSignRead(signName, xmlRpcMethodReadMatrixSettings); //matrix signs
    else if(settings["TYPE"] == 8) readCurrentSign = xmlrpcCallForSignRead(signName, xmlRpcMethodReadDisplayLoopSettings); //display on loops signs
    else if(settings["TYPE"] == 10) readCurentSignOversizeVehicle = xmlrpcCallForSignRead(signName, xmlRpcMethodReadOversizeVehicleSettings); //oversized signs
    else readCurrentSign =  xmlrpcCallForSignRead(signName, xmlRpcMethodReadSettings); //other signs

    if(settings["TYPE"] != 10)
    {
      active = (mappingHasKey(readCurrentSign, "Active0")) ? readCurrentSign["Active0"] : -1;
      duration = (mappingHasKey(readCurrentSign, "Duration0")) ? readCurrentSign["Duration0"] : -1;

      //in the case that he did not read well from the sign of value, return to the beginning and try again in the opposite end for the loop
      if(active == -1 || duration == -1){
          Log::warning("readCurrentSign", "Could not load readCurrentSign active and duration parameter" + readCurrentSign);
          delay(2);
      }
      else x = 3;
    }
    else x = 3;
  }

  switch(settings["TYPE"])
  {
    case 4:  //display signs
      //doraditi sta se bude slalo na znak
      setDisplayDatapoint(settings["TYPE"], signName, readCurrentSign, settings["STATUS"]);
      break;
    case 6:  //matrix signs
      setMatrixSignDatapoint(settings["TYPE"], signName, readCurrentSign, settings["STATUS"]);
      break;
    case 8:  //display on loops signs
      setDisplayLoopSignDatapoint(settings["TYPE"], signName, readCurrentSign, settings["STATUS"]);
      break;
    case 10:  //oversized signs
      setOversizeVehicleSignDatapoint(settings["TYPE"], signName, readCurentSignOversizeVehicle, settings["STATUS"]);
      break;
    default:  //other signs
      setDatapoint(settings["TYPE"], signName, readCurrentSign, settings["STATUS"]);
  }

  dyn_errClass err = getLastError();
  if(dynlen(err) > 0)
  {
     errorDialog(err);
     Log::error("xmlrpcHandler", "Error occured in readCurrentSign");
  }

  if (!xmlrpcCloseServer(settings["ID"]))
		 Log::warning("rpcCall", "Failed to close connection to the XML-RPC server.");
}

mixed xmlrpcCallForSignRead(string signName, string function)
{
  dyn_mixed argsSign = makeDynMixed(settings["TYPE"], settings["IP"]);
  mapping readCurrentSign;
  int readCurentSignOversizeVehicle;

  xmlrpcClient();
  xmlrpcConnectToServer(settings["ID"], settings["HOST"], settings["PORT"], FALSE);

  if(settings["STATUS"] == 1)
  {
     Log::warning("readSignValueSingle", "It's currently being sent on sign");
     delay(1);
  }

  if(settings["TYPE"] == 10 && function != xmlRpcMethodReadBrightness){ //display signs
     if (xmlrpcCall(settings["ID"], function, argsSign, readCurentSignOversizeVehicle) == -1)
     {
  		    Log::error("rpcCall", "Failed to call XML-RPC function <%s>.", function);
        return false;
     }
     return  readCurentSignOversizeVehicle;
  }
  else
  {
    if (xmlrpcCall(settings["ID"], function, argsSign, readCurrentSign) == -1)
    {
  		   Log::error("rpcCall", "Failed to call XML-RPC function <%s>.", function);
       return false;
    }
  }
  return readCurrentSign;
}

void readSignBrightnessSingle(string signName)
{
  delay(0,5);

  Log::info("readSignBrightnessSingle", "Starting reading brightness from sign" + signName);

  mapping readCurrentSign;
  int brightnessValue;
  int brightnessValueDepedence;

  if (!loadSettings(signName))
  {
     Log::error("loadSettings", "Could not load settings for script ReadSignValues" + settings);
     return;
  }

  for(int x = 1; x <= 3; x++)
  {
     readCurrentSign = xmlrpcCallForSignRead(signName, xmlRpcMethodReadBrightness);
     brightnessValue = (mappingHasKey(readCurrentSign, "CurrentBrightness")) ? readCurrentSign["CurrentBrightness"] : -1;
     brightnessValueDepedence = (mappingHasKey(readCurrentSign, "Brightness_depedence_Value")) ? readCurrentSign["Brightness_depedence_Value"] : -1;

     if(brightnessValue == -1 || brightnessValueDepedence == -1)
     {
        Log::warning("readSignBrightnessSingle", "Could not load readCurrentSign CurrentBrightness or Brightness_depedence_Value parameter" + readCurrentSign);
        delay(2);
     }
     else x = 3;
  }
  //can't read or connect to sign
  if(brightnessValue == -1 || brightnessValueDepedence == -1)
  {
     Log::error("readSignBrightnessSingle", "Can't read or connect to sign" + settings);
     dpSet(signName + ".response.signStatus", -1);
  }
  else
  {
    dpSet(signName + ".response.intensity", brightnessValue);  //in (%)
    dpSet(signName + ".response.lightingMode", brightnessValueDepedence);  //0 = Fix mode; 1 = Brightness depends on day time; 2 = Brightness depends on light sensor(s)
  }

  if (!xmlrpcCloseServer(settings["ID"]))
		 Log::warning("rpcCall", "Failed to close connection to the XML-RPC server.");
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
     map[value] = idPicture;   //get id of picture based on value
  }
  return map;
}

int getImageMappingValue(int value, string dpe)
{
  int signType;
  if(!getDP(systemName + dpe + ".settings.signType", signType))
      Log::error("getTypeMapping", "MappedValues is undefined " + dpe);

  mapping map = getTypeMapping(signType);
  if(mappinglen(map) == 0)
  {
      Log::error("getImageMappingValue", "Mapping is empty for SignType " + signType);
      return -1;
  }
  else if (!mappingHasKey(map, (string)value))
  {
      Log::error("getImageMappingValue", "Mapping does not contain value. Map: " + map);
      return -1;
  }

  if (mappingHasKey(map,pictureId)) return map[pictureId];
  return -1;
}

//return name of picture based on pictureId
int getPictureNameForDisplay(string pictureId)
{
  dyn_string getConfigFromDp, splitArray;
  mapping map;
  dpGet(systemName + "_mp_SignSettings.settings.displayPictureNamesConfig", getConfigFromDp);
  if(dynlen(getConfigFromDp) == 0)
  {
      Log::error("getIdPictureForDisplay", "DP is empty" + getConfigFromDp);
      return -1;
  }

  for(int i=1; i <= dynlen(getConfigFromDp); i++)
  {
     splitArray = strsplit(getConfigFromDp[i], "|");
     if(dynlen(splitArray) < 2)
     {
        Log::error("getIdPictureForDisplay", "splitArray is < 2" + splitArray);
        return -1;
     }
     map[splitArray[2]] = splitArray[1];
  }
  return map[pictureId];
}

mapping getDisplayConfiguration()
{
  dyn_string getConfigFromDp;
  mapping map;
  string nameOfArguments;
  string arguments;
  dpGet(systemName + "_mp_SignSettings.settings.displayConfiguration", getConfigFromDp);

  if(dynlen(getConfigFromDp) == 0)
  {
      Log::error("getDisplayConfiguration", "DP is empty" + getConfigFromDp);
      return map;
  }
  for(int i=1; i <= dynlen(getConfigFromDp); i++)
  {
     nameOfArguments = substr(getConfigFromDp[i], 0, strpos(getConfigFromDp[i], "|", 0));
     arguments = substr(getConfigFromDp[i], strpos(getConfigFromDp[i], "|", 1) + 1);
     dyn_mixed s = getArgumentsFromConfig(arguments);
     map[nameOfArguments] = s;
  }

  return map;
}

string getPictureIdForDisplay(mapping mapRead)
{
  string key = "";
  dyn_mixed values;
  mapping mapConfig = getDisplayConfiguration();

  for(int i=1;i<=mappinglen(mapConfig);i++)
  {
    key = mappingGetKey(mapConfig, i);
    values = mappingGetValue(mapConfig, i);
    if(compareTheValues(values, mapRead)) return key;
  }

  return "no key";
}

bool compareTheValues(dyn_mixed values, mapping map)
{
   //map are values that are read from the sign, key/value pair
  if(mappinglen(map) == 0)
  {
     Log::error("compareTheValues", "Empty map for display configuration after cutting" + values);
     return false;
  }
  //dont't check sText0 because it's enough to check sText1
  if(mappinglen(map) == 10 && dynlen(values) == 9)
  {
    if(values[1] == map["Active0"] && values[2] == map["Duration0"] && values[3] == map["Bgr10"] && values[4] == map["Bgr20"]
       && values[5] == map["Active1"] && values[6] == map["Duration1"] && values[7] == map["Bgr11"] && values[8] == map["Bgr21"])
      {
        if(values[9] == map["sText1"]) return true;
        if(strpos(map["sText1"], "TIME", 0) > 1) return (strpos(map["sText1"], "TIME", 0) == strpos(values[9], "'TIME'", 0));
      }
  }
   //dont't check sText0 because it's enough to check sText1
  if(mappinglen(map) == 18  && dynlen(values) == 17)
  {
    if(values[1] == map["Active0"] && values[2] == map["Duration0"] && values[3] == map["Bgr10"] && values[4] == map["Bgr20"]
       && values[5] == map["Pict10"] && values[6] == map["Pict20"] && values[7] == map["Pict30"] && values[8] == map["Pict40"]
       && values[9] == map["Active1"] && values[10] == map["Duration1"] && values[11] == map["Bgr11"] && values[12] == map["Bgr21"]
       && values[13] == map["Pict11"] && values[14] == map["Pict21"] && values[15] == map["Pict31"] && values[16] == map["Pict41"])
      {
        if(values[17] == map["sText1"]) return true;
        if(strpos(map["sText1"], "TIME", 0) > 1)  return (strpos(map["sText1"], "TIME", 0) == strpos(values[17], "'TIME'", 0));
      }
  }

  return false;

}

dyn_mixed getArgumentsFromConfig(string stringArguments)
{
   dyn_string splitArray = strsplit(stringArguments, "|");
   dyn_mixed args;
   int Active, Duration, Bgr1, Bgr2, Pict1, Pict2, Pict3, Pict4;
   int Active_2, Duration_2, Bgr1_2, Bgr2_2, Pict1_2, Pict2_2, Pict3_2, Pict4_2;
   string sText_2;

   if(dynlen(splitArray) == 0)
   {
      Log::error("getArgumentsFromConfig", "DP is empty" + splitArray);
      return map;
   }

   //regular display sign
   if(dynlen(splitArray) == 70)
   {
     for(int i=1;i<36;i++) strreplace(splitArray[i], " ", "");
     for(int i=37;i<70;i++) strreplace(splitArray[i], " ", "");

     Active = splitArray[3]; Duration = splitArray[4]; Bgr1 = splitArray[5]; Bgr2 = splitArray[8];
     Pict1 = splitArray[32]; Pict2 = splitArray[33]; Pict3 = splitArray[34]; Pict4 = splitArray[35];
     //string sText = substr(splitArray[36], 1, (strlen(splitArray[36])-2));

     Active_2 = splitArray[37]; Duration_2 = splitArray[38]; Bgr1_2 = splitArray[39]; Bgr2_2 = splitArray[42];
     Pict1_2 = splitArray[66]; Pict2_2 = splitArray[67]; Pict3_2 = splitArray[68]; Pict4_2 = splitArray[69];
     sText_2 = substr(splitArray[70], 1, (strlen(splitArray[70])-1));


     args = makeDynMixed(Active, Duration, Bgr1, Bgr2, Pict1, Pict2, Pict3, Pict4,
                            Active_2, Duration, Bgr1_2, Bgr2_2, Pict1_2, Pict2_2, Pict3_2, Pict4_2,
                            sText_2);
   }

   if(dynlen(splitArray) == 62)
   {
     for(int i=1;i<32;i++) strreplace(splitArray[i], " ", "");
     for(int i=37;i<62;i++) strreplace(splitArray[i], " ", "");

     Active = splitArray[3]; Duration = splitArray[4]; Bgr1 = splitArray[5]; Bgr2 = splitArray[8];
     //string sText = substr(splitArray[32], 1, (strlen(splitArray[32])-2));

     Active_2 = splitArray[33]; Duration_2 = splitArray[34]; Bgr1_2 = splitArray[35]; Bgr2_2 = splitArray[38];
     sText_2 = substr(splitArray[62], 1, (strlen(splitArray[62])-1));

     args = makeDynMixed(Active, Duration, Bgr1, Bgr2,
                            Active_2, Duration, Bgr1_2, Bgr2_2, sText_2);
   }

   return args;
}

setDatapoint(int signType, string signName, mapping readCurrentSign, int status)
{
  dyn_int responseValues, commandValues;
  int duration;
  if(!getDP(systemName + signName + ".command.value", commandValues))
      Log::error("setDatapoint", "Error reading values from sign " + signName);

  responseValues[1] = (mappingHasKey(readCurrentSign, "PanelId0")) ? readCurrentSign["PanelId0"] : -1; //panelId0  panel/znak koji je postavljen
  duration = (mappingHasKey(readCurrentSign, "Duration0")) ? readCurrentSign["Duration0"] : -1;
  Log::info("setDatapoint", "znak: " + signName + " -- na znaku: " + getImageMappingValue(responseValues[1], signName) + " -- scada: " + commandValues[1]);

  if(responseValues[1] == -1 || duration == -1)
  {
     dpSet(systemName + signName + ".response.signStatus", -1);
     Log::error("setDatapoint", "There si not communication, can not read values from sign: " + signName);
  }
  else
  {
    dpSet(systemName + signName + ".response.signStatus", 0);
    int panelId = getImageMappingValue(responseValues[1], signName);
    if(panelId == -1)
    {
        Log::error("setDatapoint", "PanelID is -1, something wrong with mapping" + signName);
        dpSet(systemName + signName + ".response.signStatus", -1);
        return;
    }
    //check if command value and read value is different
    if(commandValues[1] != panelId)
    {
       Log::warning("setDatapoint", "Error: Different signs: " + signName + ", current command value: " + commandValues[1] + ", current read value: " + panelId);
       dpSet(systemName + signName + ".response.signStatus", -10);
    }

    dpSet(systemName + signName + ".response.value", panelId);
  }
}

setOversizeVehicleSignDatapoint(int signType, string signName, int readCurentSignOversizeVehicle, int status)
{
  dyn_int commandValues;
  if(!getDP(systemName + signName + ".command.value", commandValues))
      Log::error("setOversizeVehicleSignDatapoint", "Error reading values from sign " + signName);

  //0 -ugasen 1 - previsoko vozilo 2 - presiroko vozilo -1 - greska ili nepoznato
  Log::info("setOversizeVehicleSignDatapoint", "znak: " + signName + " -- na znaku: " + getImageMappingValue(readCurentSignOversizeVehicle, signName) + " -- scada: " + commandValues[1]);

  if(readCurentSignOversizeVehicle == -1)
  {
     dpSet(systemName + signName + ".response.signStatus", -1);
     Log::error("setOversizeVehicleSignDatapoint", "There si not communication, can not read values from sign: " + signName);
  }
  else
  {
    dpSet(systemName + signName + ".response.signStatus", 0);
    int panelId = getImageMappingValue(readCurentSignOversizeVehicle, signName);
    if(panelId == -1)
    {
        Log::error("setOversizeVehicleSignDatapoint", "PanelID is -1, something wrong with mapping" + signName);
        dpSet(systemName + signName + ".response.signStatus", -1);
        return;
    }

    //check if command value and read value is different
    if(commandValues[1] != panelId)
    {
       Log::warning("setOversizeVehicleSignDatapoint", "Error: Different signs: " + signName + ", current command value: " + commandValues[1] + ", current read value: " + panelId);
       dpSet(systemName + signName + ".response.signStatus", -10);
     }

    dpSet(systemName + signName + ".response.value", panelId);
  }
}

setMatrixSignDatapoint(int signType, string signName, mapping readCurrentSign, int status)
{
  int activeSecondContent, durationSecondContent;
  string sText, sText_2;
  dyn_int responseValues, commandValues;

  if(!getDP(systemName + signName + ".command.value", commandValues))
      Log::error("setMatrixSignDatapoint", "Error reading values from sign " + signName);

  int active = (mappingHasKey(readCurrentSign, "Active0")) ? readCurrentSign["Active0"] : -1;
  int duration = (mappingHasKey(readCurrentSign, "Duration0")) ? readCurrentSign["Duration0"] : -1;

  //in the case that he did not read well from the sign of value, return to the beginning and try again in the opposite end for the loop
  if(active == -1 || duration == -1)
  {
     dpSet(systemName + signName + ".response.signStatus", -1);
     Log::error("setMatrixSignDatapoint", "There si not communication, can not read values from sign: " + signName);
  }
  else
  {
    dpSet(systemName + signName + ".response.signStatus", 0);
    responseValues[1] = (mappingHasKey(readCurrentSign, "Bgr10")) ? readCurrentSign["Bgr10"] : -1;
    sText = (mappingHasKey(readCurrentSign, "sText0")) ? readCurrentSign["sText0"] : -1;
    activeSecondContent = (mappingHasKey(readCurrentSign, "Active1")) ? readCurrentSign["Active1"] : -1;
    responseValues[2] = (mappingHasKey(readCurrentSign, "Bgr11")) ? readCurrentSign["Bgr11"] : -1;
    durationSecondContent = (mappingHasKey(readCurrentSign, "Duration1")) ? readCurrentSign["Duration1"] : -1;
    sText_2 = (mappingHasKey(readCurrentSign, "sText1")) ? readCurrentSign["sText1"] : -1;

    dyn_int panelsId;
    for(int i=1; i <= dynlen(responseValues); i++)
    {
      if(responseValues[i] != -1){
         panelsId[i] = getImageMappingValue(responseValues[i], signName);
        //check is there any different values
        if(dynlen(commandValues) != dynlen(responseValues))
        {
           Log::error("setMatrixSignDatapoint", "Razlicite velicine: " + responseValues);
           dpSet(systemName + signName + ".response.signStatus", -10);
        }
        else
        {
          if(commandValues[i] != panelsId[i])
          {
            Log::warning("setMatrixSignDatapoint", "Error: Different signs: " + signName + ", current command value: " + commandValues[i] + ", current read value: " + panelsId[i]);
            dpSet(systemName + signName + ".response.signStatus", -10);
          }//end if
        }//end else
      }//end if
    }//enf for

    Log::info("setMatrixSignDatapoint", "znak: " + signName + " -- na znaku: " + panelsId + " -- scada: " + commandValues);
    dpSet(systemName + signName + ".response.value", panelsId);
  }
}

setDisplayDatapoint(int signType, string signName, mapping readCurrentSign, int status)
{
  int bgr1, bgr2, pict1, pict2, pict3, pict4;
  int activeSecondContent, durationSecondContent, bgr1SecondContent, bgr2SecondContent, pict1SecondContent, pict2SecondContent, pict3SecondContent, pict4SecondContent;
	 string sText, sTextSecondContent;

  int active = (mappingHasKey(readCurrentSign, "Active0")) ? readCurrentSign["Active0"] : -1;
  int duration = (mappingHasKey(readCurrentSign, "Duration0")) ? readCurrentSign["Duration0"] : -1;

  //in the case that he did not read well from the sign of value, return to the beginning and try again in the opposite end for the loop
  if(active == -1 || duration == -1)
  {
     dpSet(systemName + signName + ".response.signStatus", -1);
     Log::error("setDisplayDatapoint", "There si not communication, can not read values from sign: " + signName);
  }
  else if (active == 0)
  {
    dpSet(systemName + signName + ".response.signStatus", 0);
    bgr1 = 0; bgr2 = 0; pict1 = 0; pict2 = 0; pict3 = 0; pict4 = 0; sText = "";
    activeSecondContent = 0; durationSecondContent = 0; bgr1SecondContent = 0; bgr2SecondContent = 0; pict1SecondContent = 0;
    pict2SecondContent = 0; pict3SecondContent = 0; pict4SecondContent = 0; sTextSecondContent = "";

    dyn_int displayValues = makeDynInt(active, duration, bgr1, bgr2, pict1, pict2, pict3, pict4,
                            activeSecondContent, durationSecondContent, bgr1SecondContent, bgr2SecondContent,
                            pict1SecondContent, pict2SecondContent, pict3SecondContent, pict4SecondContent
                            );

    Log::info("setDisplayDatapoint", "Portal Values: " + displayValues + "  TEXT PANEL1: " + sText + "  TEXT PANEL2: " + sTextSecondContent);

    int pictureName;
    pictureName = getPictureNameForDisplay("PortalUgasen");
    if(pictureName == -1)
    {
       Log::error("setDisplayDatapoint", "There si no picture name in displayPictureName: " + pictureName);
       return;
    }

    dpSet(systemName + signName + ".response.value", displayValues,
          systemName + signName + ".response.textOnDisplayFirstContent", sText,
          systemName + signName + ".response.textOnDisplaySecondContent", sTextSecondContent,
          systemName + signName + ".response.displayImageValue", pictureName
          );
  }
  else
  {
    dpSet(systemName + signName + ".response.signStatus", 0);
    bgr1 = (mappingHasKey(readCurrentSign, "Bgr10")) ? readCurrentSign["Bgr10"] : -1;
    bgr2 = (mappingHasKey(readCurrentSign, "Bgr20")) ? readCurrentSign["Bgr20"] : -1;
    pict1 = (mappingHasKey(readCurrentSign, "Pict10")) ? readCurrentSign["Pict10"] : -1;
    pict2 = (mappingHasKey(readCurrentSign, "Pict20")) ? readCurrentSign["Pict20"] : -1;
    pict3 = (mappingHasKey(readCurrentSign, "Pict30")) ? readCurrentSign["Pict30"] : -1;
    pict4 = (mappingHasKey(readCurrentSign, "Pict40")) ? readCurrentSign["Pict40"] : -1;
    sText = (mappingHasKey(readCurrentSign, "sText0")) ? readCurrentSign["sText0"] : "";

    activeSecondContent = (mappingHasKey(readCurrentSign, "Active1")) ? readCurrentSign["Active1"] : -1;
    durationSecondContent = (mappingHasKey(readCurrentSign, "Duration1")) ? readCurrentSign["Duration1"] : -1;
    bgr1SecondContent = (mappingHasKey(readCurrentSign, "Bgr11")) ? readCurrentSign["Bgr11"] : -1;
    bgr2SecondContent = (mappingHasKey(readCurrentSign, "Bgr21")) ? readCurrentSign["Bgr21"] : -1;
    pict1SecondContent = (mappingHasKey(readCurrentSign, "Pict11")) ? readCurrentSign["Pict11"] : -1;
    pict2SecondContent = (mappingHasKey(readCurrentSign, "Pict21")) ? readCurrentSign["Pict21"] : -1;
    pict3SecondContent = (mappingHasKey(readCurrentSign, "Pict31")) ? readCurrentSign["Pict31"] : -1;
    pict4SecondContent = (mappingHasKey(readCurrentSign, "Pict41")) ? readCurrentSign["Pict41"] : -1;
    sTextSecondContent = (mappingHasKey(readCurrentSign, "sText1")) ? readCurrentSign["sText1"] : "";

   dyn_int displayValues = makeDynInt(active, duration, bgr1, bgr2, pict1, pict2, pict3, pict4,
                            activeSecondContent, durationSecondContent, bgr1SecondContent, bgr2SecondContent,
                            pict1SecondContent, pict2SecondContent, pict3SecondContent, pict4SecondContent
                            );

    Log::info("setDisplayDatapoint", "Portal Values: " + displayValues + "  TEXT PANEL1: " + sText + "  TEXT PANEL2: " + sTextSecondContent);

    string pictureId = getPictureIdForDisplay(readCurrentSign);
    int pictureName;
    if(pictureId == "no key")
    {
       Log::error("compareTheValues", "No key for reading map" + pictureId);
       dpSet(systemName + signName + ".response.signStatus", -1);
       return;
    }

    pictureName = getPictureNameForDisplay(pictureId);
    if(pictureName == -1)
    {
       Log::error("setDisplayDatapoint", "There si no picture name in displayPictureName: " + pictureName);
       dpSet(systemName + signName + ".response.signStatus", -1);
       return;
    }
    strreplace(sText, "'nl'", "-NL-");
    strreplace(sTextSecondContent, "'nl'", "-NL-");

    dpSet(systemName + signName + ".response.value", displayValues,
          systemName + signName + ".response.textOnDisplayFirstContent", sText,
          systemName + signName + ".response.textOnDisplaySecondContent", sTextSecondContent,
          systemName + signName + ".response.displayImageValue", pictureName
          );

  }//end else
}

setDisplayLoopSignDatapoint(int signType, string signName, mapping readCurrentSign, int status)
{
  int bgr1, bgr2;
  int activeSecondContent, durationSecondContent, bgr1SecondContent, bgr2SecondContent;
	 string sText, sTextSecondContent;

  int active = (mappingHasKey(readCurrentSign, "Active0")) ? readCurrentSign["Active0"] : -1;
  int duration = (mappingHasKey(readCurrentSign, "Duration0")) ? readCurrentSign["Duration0"] : -1;

  //in the case that he did not read well from the sign of value, return to the beginning and try again in the opposite end for the loop
  if(active == -1 || duration == -1)
  {
     dpSet(systemName + signName + ".response.signStatus", -1);
     Log::error("setDisplayLoopSignDatapoint", "There si not communication, can not read values from sign: " + signName);
  }
  else if (active == 0)
  {
    dpSet(systemName + signName + ".response.signStatus", 0);
    bgr1 = 0; bgr2 = 0; sText = ""; activeSecondContent = 0; durationSecondContent = 0;
    bgr1SecondContent = 0; bgr2SecondContent = 0; sTextSecondContent = "";

    dyn_int displayValues = makeDynInt(active, duration, bgr1, bgr2, activeSecondContent, durationSecondContent, bgr1SecondContent, bgr2SecondContent);

    Log::info("setDisplayLoopSignDatapoint", "Portal Values: " + displayValues + "  TEXT PANEL1: " + sText + "  TEXT PANEL2: " + sTextSecondContent);

    int pictureName;
    pictureName = getPictureNameForDisplay("PortalPetljaUgasen");
    if(pictureName == -1)
    {
       Log::error("setDisplayLoopSignDatapoint", "There si no picture name in displayPictureName: " + pictureName);
       dpSet(systemName + signName + ".response.signStatus", -1);
       return;
    }

    dpSet(systemName + signName + ".response.value", displayValues,
          systemName + signName + ".response.textOnDisplayFirstContent", sText,
          systemName + signName + ".response.textOnDisplaySecondContent", sTextSecondContent,
          systemName + signName + ".response.displayImageValue", pictureName);
  }
  else
  {
    dpSet(systemName + signName + ".response.signStatus", 0);
    bgr1 = (mappingHasKey(readCurrentSign, "Bgr10")) ? readCurrentSign["Bgr10"] : -1;
    bgr2 = (mappingHasKey(readCurrentSign, "Bgr20")) ? readCurrentSign["Bgr20"] : -1;
    sText = (mappingHasKey(readCurrentSign, "sText0")) ? readCurrentSign["sText0"] : "";

    activeSecondContent = (mappingHasKey(readCurrentSign, "Active1")) ? readCurrentSign["Active1"] : -1;
    durationSecondContent = (mappingHasKey(readCurrentSign, "Duration1")) ? readCurrentSign["Duration1"] : -1;
    bgr1SecondContent = (mappingHasKey(readCurrentSign, "Bgr11")) ? readCurrentSign["Bgr11"] : -1;
    bgr2SecondContent = (mappingHasKey(readCurrentSign, "Bgr21")) ? readCurrentSign["Bgr21"] : -1;
    sTextSecondContent = (mappingHasKey(readCurrentSign, "sText1")) ? readCurrentSign["sText1"] : "";

    dyn_int displayValues = makeDynInt(active, duration, bgr1, bgr2, activeSecondContent, durationSecondContent, bgr1SecondContent, bgr2SecondContent);

    Log::info("setDisplayLoopSignDatapoint", "Portal Values: " + displayValues + "  TEXT PANEL1: " + sText + "  TEXT PANEL2: " + sTextSecondContent);

    string pictureId = getPictureIdForDisplay(readCurrentSign);
    int pictureName;
    if(pictureId == "no key")
    {
       Log::error("compareTheValues", "No key for reading map" + pictureId);
       dpSet(systemName + signName + ".response.signStatus", -1);
       return;
    }

    pictureName = getPictureNameForDisplay(pictureId);
    if(pictureName == -1)
    {
       Log::error("setDisplayLoopSignDatapoint", "There si no picture name in displayPictureName: " + pictureName);
       dpSet(systemName + signName + ".response.signStatus", -1);
       return;
    }
    strreplace(sText, "'nl'", "-NL-");
    strreplace(sTextSecondContent, "'nl'", "-NL-");

    dpSet(systemName + signName + ".response.value", displayValues,
          systemName + signName + ".response.textOnDisplayFirstContent", sText,
          systemName + signName + ".response.textOnDisplaySecondContent", sTextSecondContent,
          systemName + signName + ".response.displayImageValue", pictureName
          );
  }//end else
}
