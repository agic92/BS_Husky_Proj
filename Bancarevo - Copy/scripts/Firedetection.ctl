#uses "CtrlHTTP"
#uses "CtrlXmlRpc"
#uses "xmlrpcHandlerCommon.ctl"
#uses "CtrlZlib"
#uses "log.ctl"
#uses "basicMethods.ctl"
#uses "XmlRpcMethods.ctl"


mapping settings;
dyn_string objectTypesMeaning, detectorsObjectStatus,
               panelsObjectStatus, loopObjectStatus;
dyn_dyn_string objectTypes, objectStatuses;
string systemName = getSystemName();
string scriptName = "Firedetection";

main()
{
  if (!loadSettings())
  {
    Log::error("main", "Could not load settings for script " + scriptName);
  }

  /*if (httpServer(false, settings["HTTP_PORT"], settings["HTTPS_PORT"]) < 0)
  {
    Log::exception("main", "HTTP server did not start");
  }
  httpRunPassive(true);

  if(!httpConnect("xmlrpcHandler", "/RPC2") < 0)
  {
    Log::exception("main", "httpConnect method did not start successfully");
  }

  Log::info("main", "HTTP server started successfully at port " + settings["HTTP_PORT"]);*/

}

mixed xmlrpcHandler(const mixed content, string user, string ip, dyn_string ds1, dyn_string ds2, int connIdx)
{
  string methodName;
  dyn_mixed methodArguments;
  mixed methodResult;
  dyn_errClass derr;
  string cookie = httpGetHeader(connIdx, "Cookie");

   //Decoding content
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
  int objectStatus, eventType, objectType, panelId, detectorId, detector;
  switch (methodName)
  {
    case "bstelecom.edp.scada.IScada.reportStatus" :
        /*------------------------------------------------------------------------------------------------*/
        objectStatus = methodArguments[1];
        eventType = methodArguments[2];
        objectType = methodArguments[3];
        panel = methodArguments[4];
        detectorId = methodArguments[5];
        detector = methodArguments[6];

        string detectorName = getDetectorName(panel, detectorId, detector);
        string controlUnitName = getControlUnitName(panel, detectorId, detector);

        for (int i = 1; i <= dynlen(objectTypes); i++)
        {
          if (objectType == objectTypes[i][1])
          {
            dyn_string objectStatuses;
            getDP(systemName + "_mp_FireDetectors.settings." + objectTypes[i][1], objectStatuses);

            for (int j = 1; j <= dynlen(objectStatuses); j++)
            {
              dyn_string arrayArguments = strsplit(objectStatuses[j], "|");

              if (objectStatus == arrayArguments[j][1])
              {
                if (detectorName != "")
                {
                  setDP(systemName + detectorName + ".alarm." + arrayArguments[j][2], eventType);
                }
                else if (controlUnitName != "")
                {
                  setDP(systemName + controlUnitName + ".alarm." + arrayArguments[j][2], eventType);
                }
                else
                {
                  /*TO-DO na licu mjesta: Provjeriti dobiva li se od adaptera informacija o ID-u petlje, kako bi se znalo koja petlja ide u gresku.
                    Tek nakon toga zavrsiti ovaj dio koda koji obradjuje alarme za petlje

                    Također provjeriti šta predstavlja parametar detector i to izmijeniti u skripti i datapoint-u.

                    Postojeći parametar subset je preimenovan u detectorId jer, iako na centrali on predstavlja subset, na SCADI je on identifikator svakog detektora posebno.*/
                }
              }
              dynAppend(objectStatuses, arrayArguments);
            }
          }
        }
        return "Ack reportStatus";

    case "bstelecom.edp.scada.IScada.ackOperatingTelegram":
        return "Ack ackOperatingTelegram";

    case "bstelecom.edp.scada.IScada.iamAlive":
        if (!setDP(methodArguments[1] + ":_original.._value", getCurrentTime()))
        {
          Log::error("methodHandlerOwn", "Error in setting alive parameter");
          return "Error";
        }
        return "Client is alive";

    case "bstelecom.edp.scada.IScada.alarmsReset":
        DebugFTN("level1","Reset alarm centrala : " + methodArguments[1]);
        mixed result = resetDetectorStatus(methodArguments[1]);
        return "Resetovanje alarma zavrseno " + result;

    default:
        return methodHandlerCommon(methodName, methodArguments, user, cookie);
   }
}

mixed resetDetectorStatus(string controlUnitName) {
  dyn_string datapoints = dpNames("*.alarm.fireAlarm");

  for (int i = 1; i <= dynlen(datapoints); i++)
  {
    string fireAlarmControlUnit;
    string dp = dpSubStr(datapoints[i], DPSUB_SYS_DP);

    getDP(dp + ".settings.controlUnit", fireAlarmControlUnit);
    if (controlUnitName == fireAlarmControlUnit)
    {
      setDP(datapoints[i], 0);
      getDP(dp + ".settings.detectorFault", 0);
    }
  }
  return "Fire control unit " + controlUnitName + " reseted";
}

string getDetectorName(int panelId, int detectorId, int detector)
{
  dyn_string datapoints = dpNames("*.settings.detectorId");

  for (int i = 1; i <= dynlen(datapoints); i++)
  {
    dyn_string detectorParameters;
    string dp = dpSubStr(datapoints[i], DPSUB_SYS_DP);

    getDP(dp + ".settings.panelId", detectorParameters[1]);
    getDP(dp + ".settings.detectorId", detectorParameters[2]);
    getDP(dp + ".settings.detector", detectorParameters[3]);

    if (panelId == detectorParameters[1] && detectorId == detectorParameters[2] && detector == detectorParameters[3])
    {
      return dpSubStr(datapoints[i], DPSUB_DP);
    }
  }

  return "";
}

string getControlUnitName(int panelId)
{
  dyn_string datapoints = dpNames("*.settings.keyboardUnlocked");

  for (int i = 1; i <= dynlen(datapoints); i++)
  {
    dyn_string detectorParameters;
    string dp = dpSubStr(datapoints[i], DPSUB_SYS_DP);

    getDP(dp + ".settings.panelId", detectorParameters[1]);

    if (panelId == detectorParameters[1])
    {
      return dpSubStr(datapoints[i], DPSUB_DP);
    }
  }

  return "";
}

string getLoopName(string controlUnit)
{
  /*TO-DO na licu mjesta: ako se namjesti da dolaze podaci o petljama, skripta treba da vrati
    naziv datapointa koji odgovara */

  return "";
}

bool loadSettings()
{
  if(!getDP(systemName + scriptName + ".settings.HTTP_PORT",
   settings["HTTP_PORT"])) return false;
  if(!getDP(systemName + scriptName + ".settings.HTTPS_PORT",
   settings["HTTPS_PORT"])) return false;

  if(!getDP(systemName + "_mp_FireDetectors.settings.objectTypesMeaning",
   objectTypesMeaning)) return false;

  for (int i = 1; i <= dynlen(objectTypesMeaning); i++)
  {
    dyn_string arrayArguments = strsplit(objectTypesMeaning[i], "|");
    dynAppend(objectTypes, arrayArguments);
  }


  if(!getDP(systemName + "_mp_FireDetectors.settings.detectorsObjectStatus",
   settings["DetectorsObjectStatus"])) return false;
  if(!getDP(systemName + "_mp_FireDetectors.settings.controlUnitObjectStatus",
   settings["PanelsObjectStatus"])) return false;
  if(!getDP(systemName + "_mp_FireDetectors.settings.loopObjectStatus",
   settings["LoopObjectStatus"])) return false;


  return true;
}
