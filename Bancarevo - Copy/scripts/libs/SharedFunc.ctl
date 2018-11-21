#uses "CtrlXmlRpc"

int xmlRpcSendToSign(dyn_mixed args, string xmlRpcMethod, bool backup)
{
    string id = rand();
  string host = "localhost";
 // string host = "192.168.131.73";
  // string host = "192.168.131.23";
  int port = "8087";
  int backupPort = "8088";
  bool secure = FALSE;
  
  if(backup)
  {
    port = backupPort;
  }

  xmlrpcClient();
  xmlrpcConnectToServer(id, host, port, secure);
  
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

mapping GetMapping(int index, int jezik)
{
  mapping map;  
  dyn_string mapiranje;
  string lang = "";
  
  if(jezik == 0) lang = "latinica";
  else lang = "cirilica";
  
  string dp = "config_znakovi.znak_objasnjenje_" + lang;

  dpGet(dp, mapiranje);
  
  for(int i=1; i <= dynlen(mapiranje); i++)
  {
    int vrijednost;
    string objasnjenje;
    
    vrijednost = substr(mapiranje[i], 0, strpos(mapiranje[i], "|", 0));
    objasnjenje = substr(mapiranje[i], strpos(mapiranje[i], "|", 1) + 1);
    
    map[vrijednost] = objasnjenje;
  }  
  
  return map;  
}

string vratiNazivZnaka(int index)
{  
  int jezik = getActiveLang();
  mapping map = GetMapping(index, jezik);  
  return map[index]; 
}
