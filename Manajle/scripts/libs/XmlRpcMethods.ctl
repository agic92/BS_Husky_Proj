#uses "CtrlHTTP"
#uses "CtrlXmlRpc"
#uses "xmlrpcHandlerCommon.ctl"
#uses "CtrlZlib"

mixed encodeMethodResult (mixed methodResult)
{
  string encodedResult;
  mixed xmlResult;

  dyn_errClass derr = xmlRpcGetErrorFromResult(methodResult);
  if (dynlen(derr) > 0)
  {
    throwError(derr);
    return makeDynString(xmlrpcReturnFault(derr), "Content-Type: text/xml");
  }

  encodedResult = xmlrpcReturnSuccess(methodResult);

  //Compressing the result if the other side allows it
  if ( strlen(encodedResult) > 1024 && strpos(httpGetHeader(connIdx, "Accept-Encoding"),"gzip") >= 0)
  {
    //Return compressed content
    blob b;
    gzip(encodedResult, b);
    xmlResult = makeDynMixed(b, "Content-Type: text/xml", "Content-Encoding: gzip");
  }
  else
  {
    //Return plain content
    xmlResult = makeDynString( encodedResult, "Content-Type: text/xml");
  }
  return xmlResult;
}

void ackFireAlarmOnControlUnit(string detectorName)
{
  int controlUnitPort;
  string controlUnitName, controlUnitIP;
  string serverId = "servID";
  string function = "bstelecom.edp.gateway.IGateway.operatingTelegram";
  dyn_mixed methodArguments;
  mixed result;

  getDP(systemName + detectorName + ".settings.controlUnit", controlUnitName);
  getDP(systemName + controlUnitName + ".settings.IP", controlUnitIP,
        systemName + controlUnitName + ".settings.port", controlUnitPort);

  /*client.getGateway().operatingTelegram(operatingFunction, operatingTelegramNum, objectType, panel, subset, detector, parameter)*/

  methodArguments = makeDynMixed(4097, 1, 10, controlUnitId, 0, 0, 6);

  xmlrpcClient();
  xmlrpcConnectToServer(serverId, controlUnitIP, controlUnitPort, FALSE);
  xmlrpcCall(serverId, function, methodArguments, result);
  xmlrpcCloseServer(serverId);
}
