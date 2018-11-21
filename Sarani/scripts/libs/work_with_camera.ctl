#uses "CtrlHTTP"
#uses "CtrlXmlRpc" // xmlrpcEncodeValue is used for base64 encoding, so we need to load this

// General HTTP constants
string HTTP_HOST              = "Host:";
string HTTP_PROTOCOL          = "HTTP/";
string HTTP_VERSION           = "1.1";
string HTTP_COMMAND_GET       = "GET";
string HTTP_COMMAND_POST      = "POST";
string HTTP_CONTENT_TYPE      = "Content-Type:";
string HTTP_CONTENT_LENGTH    = "Content-Length:";
string HTTP_CONTENT_ENCODING  = "Content-Transfer-Encoding:";
string HTTP_CONNECTION        = "Connection:";
string HTTP_CONNECTION_TYPE   = "Keep-Alive";
string HTTP_TRANSFER_ENCODING = "Transfer-Encoding:";
string HTTP_WWW_AUTHENICATE   = "WWW-Authenticate:";
string HTTP_AUTHORIZATION     = "Authorization:";
string LINE_TERMINATOR        = "\r\n";


//resetuje kameru
void RebootCamera(string CameraIp)
{
  int read, open, close, err;  
   string data;    
   unsigned port;

   port=80;
   open=tcpOpen(CameraIp, port);
   DebugTN("open: " + open);  
   
 // primjer poruke  
 // http://<IP_addr_of_device>/cgi-bin/admin/setparam.cgi?system_reset=0  
   
   httpGet(open, CameraIp, "/cgi-bin/admin/setparam.cgi?system_reset=0", "root", "nik");
  
  close=tcpClose(open); 
  err=getLastError(); 
  DebugTN("close: " + close); 
  DebugTN("err:" +err); 
}


//Kalibrise PTZ kameru
void CalibrateCamera(string CameraIp)
{
  int read, open, close, err;  
   string data;    
   unsigned port;

   port=80;
   open=tcpOpen(CameraIp, port);
   DebugTN("open: " + open);  
   
 // primjer poruke  
 // http://<IP_addr_of_device>/cgi-bin/admin/camctrl.cgi?calibrate=go  
      
   httpGet(open, CameraIp, "/cgi-bin/camctrl/camctrl.cgi?calibrate=go", "root", "nik");
  
  close=tcpClose(open); 
  err=getLastError(); 
  DebugTN("close: " + close); 
  DebugTN("err:" +err); 
}



int httpGet(int handle, string host, string uri, string username = "", string password = "", string authorization = "Basic")
{
  // When an username is provided first try it with basic authorization
  if (authorization == "Basic" && username != "")
  {
    authorization = "Basic " + base64encode(username + ":" + password);
  }
  
  string message = HTTP_COMMAND_GET   + " " + uri + " " + HTTP_PROTOCOL + HTTP_VERSION + LINE_TERMINATOR +                   
                   HTTP_HOST           + " " + host + LINE_TERMINATOR +                   
                   (authorization == "" ? "" : HTTP_AUTHORIZATION + " " + authorization + LINE_TERMINATOR) +
                   //"Authorization: Basic cm9vdDpuaWs=" + LINE_TERMINATOR +   //username = root, pass= nik
                   HTTP_CONNECTION     + " " + HTTP_CONNECTION_TYPE + LINE_TERMINATOR +                    
                   LINE_TERMINATOR;//+

  int bytesSent = tcpWrite(handle, message);

  dyn_errClass errors = getLastError();

  if (dynlen(errors) > 0)
  {
    throwError(makeError("", PRIO_WARNING, ERR_SYSTEM, 54, "httpGet(" + handle + ", " + host + ", " + uri + ", ...) error during tcpWrite", bytesSent, 
                         HTTP_COMMAND_GET + " " + uri + " " + HTTP_PROTOCOL + HTTP_VERSION));
    throwError(errors);  
      
    return -1;
  }

  return bytesSent;
}


string base64encode(string text, bool utf8 = false)
{
  blob input;
  string result;
  
  blobAppendValue(input, text, strlen(text));
  
  int rc = xmlrpcEncodeValue(input, result, utf8);
  
  // Remove leading '<value><base64>' part
  result = substr(result, strlen("<value><base64>"));
  
  // And trailing '</base64></value>' part
  result = substr(result, 0, strlen(result) - strlen("</base64></value>"));
  
  DebugFTN("BASE64", "base64encode(" + text + ", " + utf8 + ") input: " + input + " rc: " + rc + " result: " + result);
  
  return result;
}


//pinga zadatu IP adresu
PingTst(string sIPAddr)
{
  string result;
  DebugTN("start of Ping command ping " + sIPAddr);  
  
  dyn_string tmp;
  tmp[1]=""; // Contents 
  tmp[2]="white"; // Background 
  tmp[3]="<[100,100,100],2,[0,0,0],3,[0,0,0],0,[0,0,0],0,[0,0,0],0,[0,0,0],0>"; // Foreground 
    
  int iLen = table_camera_list.lineCount();
  int iCameraIndex;  
  for(int i = 0; i< iLen - 1; i++)
  {
     string sIP = table_camera_list.cellValueRC(i,"Ip");     
     if(sIP == sIPAddr)
     {
       iCameraIndex = i;
       tmp[1] = "Testing...";
       table_camera_list.cellValueRC(i, "Ping_test", tmp);
       break;
     }                         
  }     
//if windows  
  result = system("cmd /c ping " + sIPAddr);
//if linux
  //result = system("cmd /c ping -c 4 " + sIPAddr);
  
 // result = system("cmd /c ping -c 4 " + "10.111.5.139");
  
  DebugTN("ping result - ping " + sIPAddr + ": " + result);

 //if windows   
/*  
  if(result == 0)
  {
    tmp[1] = "Pass";
    tmp[3] = "green";
    table_camera_list.cellValueRC(iCameraIndex, "Ping_test", tmp);      
  }
  else if(result == 1)
  {
    tmp[1] = "Fail";
    tmp[3] = "red";
    table_camera_list.cellValueRC(iCameraIndex, "Ping_test", tmp);      
  }
  else           
  {    
    tmp[1] = "Error";
    tmp[3] = "blue";
    table_camera_list.cellValueRC(iCameraIndex, "Ping_test", tmp);      
  }
  */
  //if linux
  if(result > 0)
  {
    tmp[1] = "Pass";
    tmp[3] = "green";
    table_camera_list.cellValueRC(iCameraIndex, "Ping_test", tmp);      
  }
  else if(result == 1)
  {
    tmp[1] = "Fail";
    tmp[3] = "red";
    table_camera_list.cellValueRC(iCameraIndex, "Ping_test", tmp);      
  }  
       
  // DebugTN("Ip: ", sIp, "CheckBox value: " + bCB);        
}

//pinga zadatu IP adresu
PingPTZTst(string sIPAddr)
{
  string result;
  DebugTN("start of Ping command ping " + sIPAddr);  
  
  dyn_string tmp;
  tmp[1]=""; // Contents 
  tmp[2]="white"; // Background 
  tmp[3]="<[100,100,100],2,[0,0,0],3,[0,0,0],0,[0,0,0],0,[0,0,0],0,[0,0,0],0>"; // Foreground 
    
  int iLen = table_camera_list.lineCount();
  int iCameraIndex;  
  for(int i = 0; i< iLen - 1; i++)
  {
     string sIP = table_camera_list.cellValueRC(i,"Ip");     
     if(sIP == sIPAddr)
     {
       iCameraIndex = i;
       tmp[1] = "Testing...";
       table_camera_list.cellValueRC(i, "Ping_test", tmp);
       break;
     }                         
  }     
//if windows  
  //result = system("cmd /c ping " + sIPAddr);
//if linux
  result = system("cmd /c ping -c 4 " + sIPAddr);
  
//  result = system("cmd /c ping -c 4 " + "10.111.5.139");
//  DebugTN("ping result - ping " + sIPAddr + ": " + result);

 //if windows   
/*  
  if(result == 0)
  {
    tmp[1] = "Pass";
    tmp[3] = "green";
    table_camera_list.cellValueRC(iCameraIndex, "Ping_test", tmp);      
  }
  else if(result == 1)
  {
    tmp[1] = "Fail";
    tmp[3] = "red";
    table_camera_list.cellValueRC(iCameraIndex, "Ping_test", tmp);      
  }
  else           
  {    
    tmp[1] = "Error";
    tmp[3] = "blue";
    table_camera_list.cellValueRC(iCameraIndex, "Ping_test", tmp);      
  }
  */
  //if linux
  if(result > 0)
  {
    tmp[1] = "Pass";
    tmp[3] = "green";
    table_PTZ_camera_list.cellValueRC(iCameraIndex, "Ping_test", tmp);      
  }
  else if(result == 1)
  {
    tmp[1] = "Fail";
    tmp[3] = "red";
    table_PTZ_camera_list.cellValueRC(iCameraIndex, "Ping_test", tmp);      
  }  
       
  // DebugTN("Ip: ", sIp, "CheckBox value: " + bCB);        
}



//dobavlja listu kamera sa njihovim imenima i IP adresama
dyn_dyn_anytype get_camera_list(string sysName)
{
  dyn_dyn_anytype list;
  string sSelect;
  if(sysName == "")
    sSelect = "SELECT '_online.._value' FROM '{K*.ip,LOT*.ip}' WHERE _DPT = \"camera\"";    
  else
    sSelect = "SELECT '_online.._value' FROM '{K*.ip,LOT*.ip}' REMOTE '" + sysName + "' WHERE _DPT = \"camera\"";
      
  int i, iVal;
  int iRes = dpQuery(sSelect, list);
  
//  int iRes = dpQuery(sSelect, list);
  string dpe;

   //logiranje za debagiranje  
  DebugTN("iRes = " + iRes, list);  
  
  for(i = 2; i<=dynlen(list); i++)
  {
    dpe = list[i][1];
    iVal = list[i][2];
    //DebugTN("List remote hostova: ", list);
  } 
  return list;
}


//dobavlja listu PTZ kamera sa njihovim imenima i IP adresama
dyn_dyn_anytype get_PTZ_camera_list(string sysName)
{
  dyn_dyn_anytype list;
  string sSelect;
  if(sysName == "")
    sSelect = "SELECT '_online.._value' FROM '*PTZ*.ip' WHERE _DPT = \"camera\"";    
  else
    sSelect = "SELECT '_online.._value' FROM '*PTZ*.ip' REMOTE '" + sysName + "' WHERE _DPT = \"camera\"";
      
  int i, iVal;
  int iRes = dpQuery(sSelect, list);
  
//  int iRes = dpQuery(sSelect, list);
  string dpe;

   //logiranje za debagiranje  
  DebugTN("iRes = " + iRes, list);  
  
  for(i = 2; i<=dynlen(list); i++)
  {
    dpe = list[i][1];
    iVal = list[i][2];
    //DebugTN("List remote hostova: ", list);
  } 
  return list;
}


fill_camera_table()
{
  table_camera_list.deleteAllLines();
  dyn_dyn_anytype ddaCamera_list;
  string sSys_Name = cbSysName.text();  
  ddaCamera_list = get_camera_list(sSys_Name); 
  
  
  //table_camera_list.
  int iLen = dynlen(ddaCamera_list);
  //DebugTN(dynlen(ddaCamera_list));
    
  
  for(int i = 2; i< iLen + 1; i++)
  {        
    string sCamera_name = ddaCamera_list[i][1];
    int iR = strreplace(sCamera_name, ".ip", "");
    table_camera_list.appendLine("Id", (i-1), "CheckBox", "", "Camera_name", sCamera_name, "Ip", ddaCamera_list[i][2]);    
    
    //dodaje checkbox u celiju
    bool val;
    table_camera_list.cellValueRC(i-2, "CheckBox", false);
  }
  
    //table_camera_list.cellValueRC(5,"CheckBox", false);
  
  init_table();           
}


init_table()
{
  //prilagodi sirinu kolona i visinu redova
  table_camera_list.adjustColumn(0);
  table_camera_list.adjustColumn(1);
  table_camera_list.adjustColumn(2);
  table_camera_list.adjustColumn(3);
 
  table_camera_list.rowHeight(20);
  
  //dozvoli editovanje checkbox kolone
  table_camera_list.columnEditable(1, true);
  
  //sakrij kolone    
}

fill_PTZ_camera_table()
{
  table_PTZ_camera_list.deleteAllLines();
  dyn_dyn_anytype ddaCamera_list;
  string sSys_Name = cbSysName.text();  
  ddaCamera_list = get_PTZ_camera_list(sSys_Name); 
  
  
  //table_camera_list.
  int iLen = dynlen(ddaCamera_list);
  //DebugTN(dynlen(ddaCamera_list));
    
  
  for(int i = 2; i< iLen + 1; i++)
  {        
    string sCamera_name = ddaCamera_list[i][1];
    int iR = strreplace(sCamera_name, ".ip", "");
    table_PTZ_camera_list.appendLine("Id", (i-1), "CheckBox", "", "Camera_name", sCamera_name, "Ip", ddaCamera_list[i][2]);    
    
    //dodaje checkbox u celiju
    bool val;
    table_PTZ_camera_list.cellValueRC(i-2, "CheckBox", false);
  }
  
    //table_camera_list.cellValueRC(5,"CheckBox", false);
  
  init_PTZ_table();           
}

init_PTZ_table()
{
  //prilagodi sirinu kolona i visinu redova
  table_PTZ_camera_list.adjustColumn(0);
  table_PTZ_camera_list.adjustColumn(1);
  table_PTZ_camera_list.adjustColumn(2);
  table_PTZ_camera_list.adjustColumn(3);
 
  table_PTZ_camera_list.rowHeight(20);
  
  //dozvoli editovanje checkbox kolone
  table_PTZ_camera_list.columnEditable(1, true);
  
  //sakrij kolone    
}

