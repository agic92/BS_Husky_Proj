//-dbg "level1" za debugiranje
#uses "CtrlHTTP"
#uses "CtrlXmlRpc"
#uses "xmlrpcHandlerCommon.ctl"
#uses "CtrlZlib"
#uses "log.ctl"
#uses "basicMethods.ctl"
#uses "XmlRpcMethods.ctl"

mapping settings;
dyn_string incidents;
string systemName = getSystemName();
string scriptName = "Videodetection1";

main()
{
  if (!loadSettings())
  {
    Log::error("main", "Could not load settings for script " + scriptName);
  }

  if (httpServer(false, settings["HTTP_PORT"], settings["HTTPS_PORT"]) < 0)
  {
    Log::exception("main", "HTTP server did not start");
  }
  /*With the control function 'httpRunPassive(bool) you can specify if the
    passive server should accept clients (true) or redirect them to the active server (false).*/
  httpRunPassive(true);

  if(!httpConnect("xmlrpcHandler", "/RPC2") < 0)
  {
    Log::exception("main", "httpConnect method did not start successfully");
  }

  Log::info("main", "HTTP server started successfully at port " + settings["HTTP_PORT"]);
}

bool loadSettings()
{
  if(!getDP(systemName + scriptName + ".settings.HTTP_PORT",
   settings["HTTP_PORT"])) return false;
  if(!getDP(systemName + scriptName + ".settings.HTTPS_PORT",
   settings["HTTPS_PORT"])) return false;
  if(!getDP(systemName + "_mp_Camera.settings.incidentList",
   incidents)) return false;

  return true;
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

  //Start own method handler - this is where the script logic is done, the rest of the code is same for all scripts using xmlrpc
  methodResult = methodHandlerOwn(methodName, methodArguments, user, cookie);

  return encodeMethodResult(methodResult, connIdx);
}

mixed methodHandlerOwn(string methodName, dyn_mixed &methodArguments, string user, string cookie)
{
  string dataPointName = methodArguments[1];
  strreplace (dataPointName, systemName, "");

  dyn_string cameraParameters = strsplit(dataPointName, ".");
  string cameraName = cameraParameters[1];
  string imageName = cameraParameters[2];

  switch (methodName)
  {
    case "setDP" :
      if (dynlen(methodArguments) != 2)
      {
        return xmlRpcMakeError(PRIO_SEVERE, ERR_CONTROL, ERR_INVALID_ARGUMENT, methodName, methodArguments);
      }

      bool isActive;

      if (!getDP(cameraName + ".settings.isActive", isActive))
      {
        Log::error("methodHandlerOwn", "Unsuccessful check of camera activity");
        return "Error";
      }
      else if (!isActive) {
        Log::info ("methodHandlerOwn", "Camera " + cameraName + " deactivated, alerts are ignored");
        return "Error";
      }

      if (!setDP(methodArguments[1], methodArguments[2]))
      {
        Log::error("methodHandlerOwn", "Failed to set datapoint for incident on camera " + cameraName);
        return "Error";
      }
      return "Value of data point " + methodArguments[1] + " is set to " + methodArguments[2];

   case "scada.bstelecom.ba.IScada.iamAlive":
      if (!setDP(methodArguments[1] + ":_original.._value", getCurrentTime()))
      {
        Log::error("methodHandlerOwn", "Error in setting alive parameter");
        return "Error";
      }
      return "Client is alive";

   case "setImageName":
        if (dynlen(methodArguments) < 1) return xmlRpcMakeError(PRIO_SEVERE, ERR_CONTROL, ERR_INVALID_ARGUMENT, methodName, methodArguments);

        string incidentName = getIncident(imageName);

        if(!setDP(systemName + cameraName + ".imageNames." + incidentName, imageName))
        {
          Log::error("methodHandlerOwn", "Error in setting image name for camera " + cameraName + ", incident " + incidentName);
          return "Error";
        }

		    return "Value of data point " + systemName + cameraName + ".imageNames." + incidentName + " is set to " + imageName;
    default:
        return methodHandlerCommon(methodName, methodArguments, user, cookie);
   }
}

string getIncident(string imageName)
{
  for (int i = 1; i <= dynlen(incidents); i++)
  {
    if (strpos(imageName, incidents[i]) > 0) return incidents[i];
  }

  return "";
}
