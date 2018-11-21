#uses "CtrlHTTP"
#uses "CtrlXmlRpc"
#uses "xmlrpcHandlerCommon.ctl"
#uses "CtrlZlib"
#uses "log.ctl"
#uses "basicMethods.ctl"
#uses "XmlRpcMethods.ctl"

mapping settings;
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

  httpRunPassive(true);
  httpSetMaxAge(1800);

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
  switch (sMethod)
  {
    case "setDP" :
      if (dynlen(methodArguments) != 2)
      {
        return xmlRpcMakeError(PRIO_SEVERE, ERR_CONTROL, ERR_INVALID_ARGUMENT, methodName, methodArguments);
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

    default:
        return methodHandlerCommon(methodName, methodArguments, user, cookie);
   }
}
