#uses "CtrlHTTP"
#uses "CtrlXmlRpc"
#uses "xmlrpcHandlerCommon.ctl"
#uses "CtrlZlib"
#uses "log.ctl"
#uses "basicMethods.ctl"
#uses "XmlRpcMethods.ctl"

mapping settings;
string systemName = getSystemName();
string serverId = rand();
string scriptName = "Meteostation-OAL";
string meteostationName = scriptName;
dyn_string roadSensor1ChannelIds,
           roadSensor2ChannelIds,
           visibilitySensorChannelIds,
           weatherStationSensorChannelIds,
           alarmsStateDps;
dyn_dyn_string sensorIdChannelIdArray;
int roadSensor1NoConnectionCount,
    roadSensor2NoConnectionCount,
    visibilitySensorNoConnectionCount,
    weatherStationSensorNoConnectionCount;

main()
{
  string managerName;
  DebugTN("myManId(): ", myManId());
  DebugTN("convManIdToInt(): ", convManIdToInt(CTRL_MAN, myManId(), 1));
  convManIntToName(convManIdToInt(CTRL_MAN, myManId(), 1), managerName);
  DebugTN("managerName: ", managerName);


  if (!loadSettings())
  {
    Log::error("main", "Could not load settings for script " + scriptName);
  }

  if (httpServer(false, settings["HTTP_PORT"], settings["HTTPS_PORT"]) < 0)
  {
    Log::exception("main", "HTTP server did not start");
  }

  if(!httpConnect("xmlrpcHandler", "/RPC2") < 0)
  {
    Log::exception("main", "httpConnect method did not start successfully");
  }

  Log::info("main", "HTTP server started successfully at port " + settings["HTTP_PORT"]);

  while(true)
  {
    startThread("updateDataEveryMinute");
    delay(60);
  }
}

bool loadSettings()
{
  //Datapoint name should start with "MS-"

  strreplace(meteostationName, "Meteostation", "MS");

  if(!getDP(systemName + scriptName + ".settings.HTTP_PORT",
   settings["HTTP_PORT"])) return false;
  if(!getDP(systemName + scriptName + ".settings.HTTPS_PORT",
   settings["HTTPS_PORT"])) return false;
  if(!getDP(systemName + meteostationName + ".settings.meteostationIP",
   settings["MeteostationIP"])) return false;
  if(!getDP(systemName + meteostationName + ".settings.meteostationPort",
   settings["MeteostationPort"])) return false;
  if(!getDP(systemName + meteostationName + ".settings.adapterHost",
   settings["AdapterHost"])) return false;
  if(!getDP(systemName + meteostationName + ".settings.adapterPort",
   settings["AdapterPort"])) return false;
  if(!getDP(systemName + meteostationName + ".settings.roadSensorId",
   settings["RoadSensor1Id"])) return false;
  if(!getDP(systemName + meteostationName + ".settings.roadSensor2Id",
   settings["RoadSensor2Id"])) return false;
  if(!getDP(systemName + meteostationName + ".settings.visibilitySensorId",
   settings["VisibilitySensorId"])) return false;
  if(!getDP(systemName + meteostationName + ".settings.weatherStationSensorId",
   settings["WeatherStationSensorId"])) return false;
  if(!getDP(systemName + meteostationName + ".settings.roadSensor1ChannelIds",
   roadSensor1ChannelIds)) return false;
  if(!getDP(systemName + meteostationName + ".settings.roadSensor2ChannelIds",
   roadSensor2ChannelIds)) return false;
  if(!getDP(systemName + meteostationName + ".settings.visibilitySensorChannelIds",
   visibilitySensorChannelIds)) return false;
  if(!getDP(systemName + meteostationName + ".settings.weatherStationSensorChannelIds",
   weatherStationSensorChannelIds)) return false;
  if(!getDP(systemName + meteostationName + ".settings.alarmStateDps",
   alarmsStateDps)) return false;

  return true;
}

mixed xmlrpcHandler(const mixed content, string user, string ip, dyn_string ds1, dyn_string ds2, int connIdx)
{
  string methodName;
  dyn_mixed methodArguments;
  mixed methodResult;
  dyn_errClass derr;
  string cookie = httpGetHeader(connIdx, "Cookie");

  if (xmlrpcDecodeRequest(content, methodName, methodArguments) < 0)
  {
    derr = getLastError();
    throwError(derr);
    derr = xmlRpcMakeError(PRIO_SEVERE, ERR_SYSTEM, ERR_PARAMETER, "Error parsing xml-rpc stream", "Method: " + methodName);
    throwError(derr);
    Log::error("xmlrpcHandler", "Error in calling xmlrpcDecodeRequest() method");
    return xmlrpcReturnFault(derr);

  }

  methodResult = methodHandlerOwn(methodName, methodArguments, user, cookie);

  return encodeMethodResult(methodResult, connIdx);
}


mixed methodHandlerOwn(string methodName, dyn_mixed &methodArguments, string user, string cookie)
{
  switch (methodName)
  {
    case "scada.bstelecom.ba.IScada.iamAlive":
      if (!setDP(methodArguments[1] + ":_original.._value", getCurrentTime()))
      {
        Log::error("methodHandlerOwn", "Error in setting alive parameter");
        return "Error";
      }
      return "Client is alive";

    default:
        return methodHandlerCommon(sMethod, asValues, user, cookie);
   }
}

void updateDataEveryMinute() {
  string dataFunction = "bstelecom.umb.UmbProtocolAdapter.readSensors",
         alarmFunction = "bstelecom.umb.UmbProtocolAdapter.readAlarms";

  mapping sensorIdChannelIdMapping,
          alarmsChannelIdMapping;

  dyn_mixed arguments;

  mixed data;

  bool isRoadSensor1Active = false,
       isRoadSensor2Active = false,
       isVisibilitySensorActive = false,
       isWeatherStationSensorActive = false;
  //If the server is not active, do not read data from meteostation
  if(!isReduActive())
  {
    return;
  }

  appendToSensorIdChannelIdArray(roadSensor1ChannelIds, "RoadSensor1Id");
  appendToSensorIdChannelIdArray(roadSensor2ChannelIds, "RoadSensor2Id");
  appendToSensorIdChannelIdArray(visibilitySensorChannelIds, "VisibilitySensorId");
  appendToSensorIdChannelIdArray(weatherStationSensorChannelIds, "WeatherStationSensorId");

  for (int i = 1; i <= dynlen(sensorIdChannelIdArray); i++)
  {
    sensorIdChannelIdMapping[sensorIdChannelIdArray[i][1]] = "";
  }

  arguments = makeDynMixed(settings["MeteostationIP"], settings["MeteostationPort"], sensorIdChannelIdMapping);

  if (!executeXmlRpcMethods(dataFunction, arguments, data, serverId))
  {
    Log::exception("updateDataEveryMinute", "Error in executing XmlRpc methods. Exiting...");
    return;
  }

  for (int i = 1; i <= dynlen(sensorIdChannelIdArray); i++)
  {
    if (mappingHasKey(data, sensorIdChannelIdArray[i][1]))
    {
      if (strpos(data[sensorIdChannelIdArray[i][1]], "error") == -1)
      {
        setDP(systemName + meteostationName + ".measurements." + sensorIdChannelIdArray[i][2], data[sensorIdChannelIdArray[i][1]]);
      }
      else
      {
        if (strpos(sensorIdChannelIdArray[i][1], settings["RoadSensor1Id"]) >= 0)
        {
          isRoadSensor1Active = true;
        }
        else if (strpos(sensorIdChannelIdArray[i][1], settings["RoadSensor2Id"]) >= 0)
        {
          isRoadSensor2Active = true;
        }
        else if (strpos(sensorIdChannelIdArray[i][1], settings["VisibilitySensorId"]) >= 0)
        {
          isVisibilitySensorActive = true;
        }
        else if (strpos(sensorIdChannelIdArray[i][1], settings["WeatherStationSensorId"]) >= 0)
        {
          isWeatherStationSensorActive = true;
        }
      }
    }
  }

  mapping alarmsChannelIdMapping;
  alarmsChannelIdMapping[settings["RoadSensor1Id"] + ".101"] = "";
  alarmsChannelIdMapping[settings["RoadSensor2Id"] + ".101"] = "";
  alarmsChannelIdMapping[settings["VisibilitySensorId"] + ".651"] = "";
  alarmsChannelIdMapping[settings["WeatherStationSensorId"] + ".200"] = "";

  checkSensorsConnections(isRoadSensor1Active, isRoadSensor2Active, isVisibilitySensorActive, isWeatherStationSensorActive);

  mappingClear(data);

  arguments = makeDynMixed(settings["MeteostationIP"], settings["MeteostationPort"], alarmsChannelIdMapping);

  if (!executeXmlRpcMethods(alarmFunction, arguments, data, serverId))
  {
    Log::exception("updateDataEveryMinute", "Wrong format of the alarm result obtained from adapter. Exiting...");
    return;
  }

  updateSensorStates(data);

  setDP(systemName + meteostationName + ".state.lastRead", getCurrentTime());
}

void checkSensorsConnections(bool isRoadSensor1Active, bool isRoadSensor2Active, bool isVisibilitySensorActive, bool isWeatherStationSensorActive)
{
  if (!isRoadSensor1Active)
  {
    roadSensor1NoConnectionCount++;
    if (roadSensor1NoConnectionCount >= 3)
    {
      setDP(systemName + meteostationName + ".alarm.isRoadSensorConnected", false);
    }
  }
  else
  {
    setDP(systemName + meteostationName + ".alarm.isRoadSensorConnected", true);
    roadSensor1NoConnectionCount = 0;
  }

  if (!isRoadSensor2Active)
  {
    roadSensor2NoConnectionCount++;
    if (roadSensor2NoConnectionCount >= 3)
    {
      setDP(systemName + meteostationName + ".alarm.isRoadSensor2Connected", false);
    }
  }
  else
  {
    setDP(systemName + meteostationName + ".alarms.isRoadSensor2Connected", true);
    roadSensor2NoConnectionCount = 0;
  }

  if (!isVisibilitySensorActive)
  {
    visibilitySensorNoConnectionCount++;
    if (visibilitySensorNoConnectionCount >= 3)
    {
      setDP(systemName + meteostationName + ".alarms.isVisibilitySensorConnected", false);
    }
  }
  else
  {
    setDP(systemName + meteostationName + ".alarms.isVisibilitySensorConnected", true);
    visibilitySensorNoConnectionCount = 0;
  }

  if (!isWeatherStationSensorActive)
  {
    weatherStationSensorNoConnectionCount++;
    if (weatherStationSensorNoConnectionCount >= 3)
    {
      setDP(systemName + meteostationName + ".alarms.isWeatherStationSensorConnected", false);
    }
  }
  else
  {
    setDP(systemName + meteostationName + ".alarms.isWeatherStationSensorConnected", true);
    weatherStationSensorNoConnectionCount = 0;
  }

  bool isMeteoStationConnected = (!isRoadSensor1Active && !isRoadSensor2Active && !isVisibilitySensorActive && !isWeatherStationSensorActive) ? false : true;
  setDP(systemName + meteostationName + ".alarms.isConnected", isMeteoStationConnected);
}

void appendToSensorIdChannelIdArray(dyn_string array, string mappingKey)
{
  for (int i = 1; i <= dynlen(array); i++)
  {
    dyn_string singleMapping = strsplit(array[i], "|");
    singleMapping[1] = settings[mappingKey] + "." + singleMapping[1];
    dynAppend(sensorIdChannelIdArray, singleMapping);
  }
}

bool executeXmlRpcMethods(string functionName, dyn_mixed arguments, mixed &data, string serverId)
{
  xmlrpcClient();

  if (!xmlrpcConnectToServer(serverId, settings["AdapterHost"], settings["AdapterPort"], FALSE))
    return false;
  if (xmlrpcCall(serverId, functionName, arguments, data) == -1)
    return false;
  if (!xmlrpcCloseServer(serverId))
    return false;
  if(getType(data) != MAPPING_VAR)
    return false;

  return true;
}

void updateSensorStates(mixed data)
{
  mapping sensorStateDps;
  sensorStateDps[settings["RoadSensor1Id"]] = "roadSensor1State";
  sensorStateDps[settings["RoadSensor2Id"]] = "roadSensor2State";
  sensorStateDps[settings["VisibilitySensorId"]] = "visibilitySensorState";
  sensorStateDps[settings["WeatherStationSensorId"]] = "weatherStationSensorState";

  for (int i = 1; i <= mappinglen(sensorStateDps); i++)
  {
    if (mappingHasKey(data, mappingGetKey(sensorStateDps, i) + ".description"))
    {
      setDP(systemName + meteostationName + ".state." + mappingGetValue(sensorStateDps, i), data[mappingGetKey(sensorStateDps, i) + ".description"]);
    }
  }
}

//------------------------------------------------------------------------------
// Changelog

// 2018.10.03 - v1.0
// Initial version.

//------------------------------------------------------------------------------
