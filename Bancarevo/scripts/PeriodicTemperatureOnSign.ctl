#uses "SignLibrary.ctl"
#uses "log"
#uses "basicMethods.ctl"

float oldTemperatureAfterRound;
string systemName = getSystemName();
string xmlRpcMethod = "bstelecom.sign.SignProtocolAdapter.writePortalSignTwoPanels";
string meteoStation = "MS-OAL";
//Info displays with the possibility of displaying the temperature
dyn_string signs = makeDynString("VMS1-OAD");
//Which contents can display temperature on Info Display
dyn_int infoWithTemperature = makeDynInt(1);
mapping signSettings;

main()
{
  dyn_errClass err;

  dpConnect("updateTemperatureOnSign", systemName + meteoStation + ".measurements.temperature");

  err = getLastError();
  if(dynlen(err) > 0)
  {
     Log::error("updateTemperatureOnSign", "Problem with sending temperature do display");
  }
}

updateTemperatureOnSign(string dpeMeteoStation, float temperature)
{
  Log::info("updateTemperatureOnSign", "Starting sending temperature " + temperature);

  if(!isReduActive())
    return;

  float temperatureForSend = 0;
  bool temperatureChanged;
  time lastReadingFromMeteo, tCurTime = getCurrentTime();

  if(!getDP(systemName + meteoStation + ".measurements.temperature:_original.._stime", lastReadingFromMeteo)) return;

  //if the temperature readings are in time are, sent to the mark
  if((tCurTime - lastReadingFromMeteo) < 600)  //10min
      temperatureForSend = temperature;
  else{
      temperatureForSend = 99;
  }

  float temperatureAfterRound = roundToFirstDecimal(temperatureForSend);

  Log::info("updateTemperatureOnSign", "Meteostatation temp: temperatureAfterRound: " + temperatureAfterRound);

  if((temperatureAfterRound - oldTemperatureAfterRound >= 0.1) || (oldTemperatureAfterRound - temperatureAfterRound >= 0.1))
  {
	    temperatureChanged = true;
	    oldTemperatureAfterRound = temperatureAfterRound;
  }
  else Log::info("updateTemperatureOnSign", "Nema promjene > 0.1");

  for(int i=1;i<=dynlen(signs);i++)
  {
    if (!loadSignSettings(signs[i]))
    {
       Log::error("loadSettings", "Could not load settings for script updateTemperatureOnSign" + signSettings);
       return;
    }
    for(int j=1;j<=dynlen(infoWithTemperature);j++)
    {
      //temperature changed and the contents can display the temperature
      if((signSettings["VALUE"][1] == infoWithTemperature[j]) && temperatureChanged) {
          sendTemperatureToSign(signs[i], signSettings["TYPE"], signSettings["IP"], temperatureAfterRound, signSettings["VALUE"][1]);
      }
      else Log::info("updateTemperatureOnSign", "Nema podudaranja vrijednosti sa vrijednostima koje mogu pokazati temperaturu");

    }//end for
  }//end for
}

bool loadSignSettings(string signName)
{
  signSettings["ID"] = "servID" + rand();
  signSettings["HOST"] = "localhost";

  if(!getDP(systemName + "_mp_SignSettings.settings.serverPort", signSettings["PORT"])) return false;
  if(!getDP(systemName + signName + ".command.value", signSettings["VALUE"])) return false;
  if(!getDP(systemName + signName + ".settings.IP", signSettings["IP"])) return false;
  if(!getDP(systemName + signName + ".settings.signType", signSettings["TYPE"])) return false;
  if(!getDP(systemName + signName + ".response.signStatus", signSettings["STATUS"])) return false;

  return true;
}

float roundToFirstDecimal(float fValue)
{
  int iTemp10 = 10 * fValue;
  float fRounded = iTemp10;
  fRounded = fRounded / 10;

  return fRounded;
}

sendTemperatureToSign(string signName, int signType, string ipAddress, float temp, int iValue){

  dyn_mixed args;

  Log::info("sendTemperatureToSign", "signType: " + signType, "IP:" + ipAddress + "temperatura:" + temp);

  args = generateArgumentsForDisplaySign(ipAddress, signType, iValue, temp);

  Log::info("sendTemperatureToSign", "SendToSign: " + signName + " Args: " + args);
  Log::info("sendTemperatureToSign", "settings: " + signSettings);

  int res = xmlRpcSendToSign(args, xmlRpcMethod, signSettings["ID"], signSettings["HOST"], signSettings["PORT"]);

  DebugFTN("level1", "SendToSign " + signName + " Response: " + res);
  Log::info("sendTemperatureToSign", "SendToSign " + signName + " Response: " + res);

  if (res == 0) dpSet(systemName + signName + ".response.signStatus", 0);
  else
  {
    Log::info("sendTemperatureToSign", "Znak: " + signName + " Not sent. Pokusava ponovo");
    delay(1);
    res = xmlRpcSendToSign(args, xmlRpcMethod, signSettings["ID"], signSettings["HOST"], signSettings["PORT"]);

    Log::info("sendTemperatureToSign", "Znak: " + signName + " -- Result second try: " + res);

    if (res == 0) dpSet(systemName + signName + ".response.signStatus", 0);
    else
    {
      Log::error("sendTemperatureToSign", "There si not communication, can not send values to sign" + signName);
      dpSet(systemName + signName + ".response.signStatus", -1);
    }//end else
  }//end else

}

//generate arguments for command that needs to change content on Display sign
dyn_mixed generateArgumentsForDisplaySign(string ipAddress, int signType, int iValue, float temp)
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
      strreplace(sText, "'TIME'", "'TIME' " + temp + "°C");
      strreplace(sText_2, "'TIME'", "'TIME' " + temp + "°C");
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
