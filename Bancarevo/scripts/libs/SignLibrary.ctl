#uses "CtrlXmlRpc"
#uses "latin_to_cyrillic.ctl"
#uses "log"

int xmlRpcSendToSign(dyn_mixed args, string xmlRpcMethod, string id, string host, int port)
{
  xmlrpcClient();
  xmlrpcConnectToServer(id, host, port, FALSE);

  dyn_errClass err;
  int res;

  for(int x = 1; x <= 3; x++)
  {
    xmlrpcCall(id, xmlRpcMethod, args, res);

    err = getLastError();
    if (dynlen(err) > 0)
    {
      DebugTN("Error1: " + err);
      delay(0, 30);
    }
    else if (res != 0)
    {
      DebugN("Error2: " + res);
      delay(0, 30);
    }
    else
    {
      x = 3;
    }
  }

  xmlrpcCloseServer(id);
  return res;
}

mapping getMappingForSignExplanation(int index)
{
  mapping map;
  dyn_string mapiranje;
  string dp = $SYSTEMNAME + "_mp_SignSettings.settings.signExplanation";

  dpGet(dp, mapiranje);

  for(int i=1; i <= dynlen(mapiranje); i++)
  {
    int vrijednost;
    string objasnjenje;

    vrijednost = substr(mapiranje[i], 0, strpos(mapiranje[i], "|", 0));
    objasnjenje = substr(mapiranje[i], strpos(mapiranje[i], "|", 1) + 1);

    map[vrijednost] = latinToCyrillic(objasnjenje);
  }

  return map;
}

string getSignExplanation(int index)
{
  mapping map = getMappingForSignExplanation(index);
  return map[index];
}

//returns the map based on value datapoint element response.signStatus
mapping getColorsForStatusCode(string dpSource)
{
  mapping map;
  dyn_string statusCodeMapping;
  string dp = $SYSTEMNAME + "_mp_SignSettings.settings.statusCodeMapping";
  dpGet(dp, statusCodeMapping);

  for(int i=1; i <= dynlen(statusCodeMapping); i++)
  {
    int value;
    string color;

    value = substr(statusCodeMapping[i], 0, strpos(statusCodeMapping[i], "|", 0));
    color = substr(statusCodeMapping[i], strpos(statusCodeMapping[i], "|", 1) + 1);

    map[value] = color;
  }

  return map;
}
/*
mapping getMappingDisplay()
{
  dyn_string getConfigFromDp;
  mapping map;
  string nameOfArguments;
  string arguments;
  dpGet($SYSTEMNAME + "_mp_SignSettings.settings.displayConfiguration", getConfigFromDp);

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
  dpGet($SYSTEMNAME + "_mp_SignSettings.settings.displayPictureNamesConfig", getConfigFromDp);
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
*/
