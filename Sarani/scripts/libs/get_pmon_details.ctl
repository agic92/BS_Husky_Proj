#uses "pa.ctl"
#uses "pmon.ctl"


//!!!!!!!!!!! constants !!!!!!!!!!!!!!!
//const  int    PA_TCP_TIMEOUT          = 6;
//const  int    PA_TCP_TIMEOUT_LOCAL    = 2;
//const  int    PA_ATTEMPTS             = 200;
//const  int    PA_ATTEMPTS_LOCAL       = 100;
//const  int    PA_TIMEOUT_PMON_RUNNING = 10;

//const  int    PA_DEFAULT_PORTNUMBER   = 4999;
//const  string PA_DEFAULT_HOSTNAME     = "localhost";
const  string PA_USER_NAME     = "root";
const  string PA_USER_PASSWORD     = "beeste";

global dyn_dyn_string dds_Hosts;
global string gHost = "";
global int gPort = 4999;


//vraca detalje o pmon-u (manager-e (skripte, UI-e...) koji su definsani u projektu i status tih manager-a)
dyn_dyn_string get_pmon_Info(string projectName)
{
    string  sPmon, sLog, sPvssPath, sConfig, consoleName, host, otherProject = "", sss;
          //, sAutostart = (autostart)?"":" -noAutostart";
    //string projectName = "test2";
    string sUser = PA_USER_NAME;
    string sPassword = PA_USER_PASSWORD;
    int     port, iErr, fd;
    bool    isRunning, startConsoleProcess = false;
    dyn_int di;
    dyn_errClass derr;
    dyn_dyn_string ddsManagerList;
    dyn_dyn_string ddsExtended_ManagerList;
    dyn_dyn_string ddsManagerStat;
    dyn_dyn_string ddsCompletManagerList;
  
  
    DebugTN("2");
    paGetProjAttr(projectName, "pvss_path", sPvssPath);
    //paGetProjAttr(projectName, "PVSS_II", sConfig);
    iErr = paProjName2ConfigFile(projectName, sConfig);
    DebugTN("3");
    paIsProjRunning(projectName, otherProject, isRunning, sUser, sPassword);
    DebugTN("4");
    ddsManagerList = pmon_getMenagerList(projectName, otherProject, isRunning, sUser, sPassword);
    DebugTN("4a");
    ddsManagerStat = pmon_getMenagerStat(projectName, otherProject, isRunning, sUser, sPassword);
    DebugTN("4b");
    ddsExtended_ManagerList = extend_manager_list_to_6_elements(ddsManagerList);
    
    ddsCompletManagerList = combine_two_arrays(ddsExtended_ManagerList, ddsManagerStat);
    DebugTN("4c");
    return ddsCompletManagerList;
}

dyn_dyn_string extend_manager_list_to_6_elements(dyn_dyn_string ddsList)
{
  int iLLen = dynlen(ddsList);  
  
  if(iLLen > 1)
  {    
    for(int i = 1; i < iLLen + 1; i++)
    {
      int iL = dynlen(ddsList[i]);
      //DebugTN("extend_manager_list_to_6_elements - dynlen(ddsList[" + i + "]) = " + iL);
      if(iL<6)
      {
        int j;
        for(j = iL; j < 6; j++)
        {
          dynAppend(ddsList[i], "");
        }
      }
    }
  }
  //DebugTN("extended ddsList: ", ddsList);  
  return ddsList;  
}

//ddsList - lista managera
//ddsStat - status managera
dyn_dyn_string combine_two_arrays(dyn_dyn_string ddsList, dyn_dyn_string ddsStat)
{
  dyn_dyn_string ddsCompletManagerList;
  int iLLen = dynlen(ddsList);
  int iSLen = dynlen(ddsStat);
  
  if((iLLen > 1) && (iSLen > 1))
  {
    dynAppend(ddsCompletManagerList, ddsList);
    for(int i = 2; i < iLLen + 1; i++)
    {
      dynAppend(ddsCompletManagerList[i], ddsStat[i]);
    }
  }
  //DebugTN("Complete list: ", ddsCompletManagerList);  
  return ddsCompletManagerList;  
}

//-----------------------------------------------------------------------------
// !!!!!!!!!!!!!!
//-----------------------------------------------------------------------------
paIsProjRunning(string projName, string &otherProject, bool &bRun, string sUser, string sPassword)
{
  file           fd;
  string         host;
  int            port, iErr;
  bool           err;
  dyn_dyn_string ddsResult;

//DebugN(" --- paIsProjRunning --- projName",projName);
    DebugTN("5");
//    ako je gHost prazan trazi host name - dobice "localhost"
    host = gHost;
    port = gPort;
    if(host == "")
    {
      iErr = paGetProjHostPort(projName, host, port);
    }
  otherProject = "";
  if ( iErr )
  {
    otherProject = "";
    bRun = false;
      DebugTN("error: " + iErr);
    return;
  }
    DebugTN("6");
  err = pmon_query(sUser+"#"+sPassword+"#PROJECT:", host, port, ddsResult, false, true);

  if ( err || dynlen(ddsResult) < 1 )
  {
    otherProject = "";
    bRun = false;
    DebugTN("6 error = " + err);
    return;
  }
  else
  if ( ddsResult[1][1] != projName )
  {
    DebugTN("6 bez greske error = " + err);
    DebugTN(ddsResult); 
    otherProject = ddsResult[1][1];
    bRun = false;
    return;
  }
  DebugTN("6b");
//  DebugTN("6b dssResult: ", dssResult, ddsResult[1][1]);
  DebugTN("6b dssResult: ", ddsResult[1][1]);
}

//vraca ime projekta koji je pokrenut
string paGetProjectName(string host, int port, string sUser, string sPassword)
{
  int            iErr;
  bool           err;
  dyn_dyn_string ddsResult;
  string sProjName;

  err = pmon_query(sUser+"#"+sPassword+"#PROJECT:", host, port, ddsResult, false, true);

  if ( err || dynlen(ddsResult) < 1 )
  {    
    sProjName = "";
  }
  else
  if (ddsResult[1][1])
  {
    sProjName = ddsResult[1][1];
  }
  DebugTN("Project name dssResult: ", sProjName);
  return sProjName;
}

int paGetProjHostPort(string projName, string &host, int &port)
{
  int err = 0;
  string config, rec, sPort;
  file fd;
  dyn_string ds;

  err = paGetProjAttr(projName, "pmonPort", sPort); // ??? projName[@hostName]
  port = sPort;
  if ( port == 0 )
//    port = PA_DEFAULT_PORTNUMBER;
    port = pmonPort();

  err = paGetProjAttr(projName, "remoteHost", host);
  DebugTN("paGetProjHostPort - host: " + host);
  if ( host == "" )
    host = PA_DEFAULT_HOSTNAME;

  if ( err > 0 ) err = 0;
  return(err);
}

//-------------------------------------------------------------
// execute tcp query
//   MGRLIST:LIST  or
//   MGRLIST:STATI
//-------------------------------------------------------------
bool pmon_query(string command, string host, int port,
                dyn_dyn_string &ddsResult, bool showErrorDialog = false, bool openTcp = false )
{
  int          fd, iCount = 0, i, j = 0, ret,
               iTimeOut = (host=="localhost" || host=="")?PA_TCP_TIMEOUT_LOCAL:PA_TCP_TIMEOUT;
  string       gTcpFifo;
  bool         bAnswerFull = false, error = false;
  string       result, sTemp;
  dyn_string   ds1, ds2, dsRes;
  dyn_anytype  daResult;
  dyn_errClass err;
  
  //DebugN("pmon_query --- command",command, host, port, showErrorDialog, openTcp);
  if (openTcp)  //new connection should be open
  {
    float tcpTimeOut;
    DebugTN("7");
    if ((host == "localhost" || host == getHostname()) && _WIN32)
    //if ((host == "localhost" ) && _WIN32)
    {
     // if(host == getHostname())
     //   tcpTimeOut = 3;
     // else
        tcpTimeOut = 0.250;
    }
    else
      tcpTimeOut = 5;

    DebugTN("8");    
    string name, ip;
 
    dyn_string addr_list;  
     
    fd = tcpOpen(host, port, tcpTimeOut);
    //fd = tcpOpen("192.168.131.73", port, tcpTimeOut);
    err = getLastError();

    ip = getHostByName(host, addr_list);
    DebugTN("pmon_query - host: " + host + ", port: " + port + ", tcpTimeOut: " + tcpTimeOut, ", getHostname(): " + getHostname() + ", getHostByName(): " + addr_list + ", err = " + err);
    
    if (dynlen(err) >= 1)
    {
      if ( fd != -1 )
        tcpClose(fd);  //Es k�nnten sonst Verbindungen �brig bleiben
      
        DebugTN("9");
        
      if (showErrorDialog)
      {
        throwError(err);   //Auf jeden Fall ausgeben da es nicht von selbst ausgegeben wird
        errorDialog(err);
      }
        DebugTN("10");
      return(true);
    }
  }
  else if (gTcpFileDescriptor < 0)
  {
    err = getLastError();
    if (dynlen(err)) errorDialog(err);
      DebugTN("11");
    return(true);
  }
  else
  {
    fd = gTcpFileDescriptor;
  }
  
  command += "\n";
  
  //Write command
  ret = tcpWrite(fd, command);
  err = getLastError();
  //DebugN("pmon_query --- tcpWrite ERROR",gTcpFileDescriptor,"command",command);
  
  if ((ret == -1) || (dynlen(err) >= 1)) //Error in tcpWrite
  {
    if (openTcp && (fd > -1))     //if was opened and is still open
      tcpClose(fd);               //close connection 
    
    if (showErrorDialog)
      errorDialog(err);
    
    gTcpFifo = "";
      DebugTN("12");
    return(true);
  }
  
  sTemp = gTcpFifo;
  
  // reading all answer lines
  result = "-1";
  while ((result != "") && !bAnswerFull)   //do as long not all pieces where get
  {                                        //if result is emty the last tcpRead dit not get answer
    int ret;                               //this means there is nothing more to get
    
    result = "";  //Start with emty string, because tcpRead does not reset it
    ret = tcpRead(fd, result, iTimeOut);
    err = getLastError();
    //DebugN("tcpRead", ret, dynlen(err), strlen(result), iTimeOut);
    if ((ret == -1) || (dynlen(err)>=1)) //Error in tcpRead
    {
      //DebugN("pmon_query --- tcpRead ERROR",gTcpFileDescriptor,"fd",fd);
      if (showErrorDialog)
        errorDialog(err);
      
      if (openTcp && (fd > -1))     //if was opened and is still open
        tcpClose(fd);               //close connection 
      
      gTcpFifo = "";
        DebugTN("13");
      return(true);
    }
    
    if (strpos(command, "#PROJECT") > 0)
    {
      //DebugN("--- gTcpFileDescriptor",gTcpFileDescriptor,"fd",fd);
      //DebugN("--- result",result);
      if (openTcp && (fd > -1))     //if was opened and is still open
        tcpClose(fd);               //close connection 
      
      ddsResult[1][1] = result;
      gTcpFifo = "";
      DebugTN("- 14 rsult: " + result);
        DebugTN("14");
      return(false);
    }
    
    sTemp += result;  //Result with tcpRead could come in pieces
    
    //check out count of items
    ds1 = strsplit(sTemp, "\n");
    if ((dynlen(ds1) > 1) && (strpos(ds1[1],"LIST") == 0) && (iCount == 0))
    {
      sscanf(ds1[1],"LIST:%d", iCount);
      if (strpos(command, "#MGRLIST:STATI") > 0)
        iCount +=3;
      else
        iCount +=2;
    }
/*
    else
    if ( dynlen(ds1) > 1 && strpos(ds1[1],"LIST") != 0 )
    {
      dynClear(ddsResult);
      gTcpFifo = "";
      return(false);
    }
*/
    while ((dynlen(ds1) > 0) && (strpos(ds1[1], "LIST:") != 0))
    {
      dynRemove(ds1, 1);
    }
    
    if ((dynlen(ds1) == iCount) && (iCount > 0))  //All pieces where get
    {
      bAnswerFull = true;
      break;
    }
    else
    {
      delay(0,10);
    }
  }

  if (openTcp && (fd > -1))     //if was opened and is still open
    tcpClose(fd);               //close connection 
  
  if (!bAnswerFull)     //Not all pieces where get
  {
    dynClear(ddsResult);
    //DebugN("--- gTcpFileDescriptor",gTcpFileDescriptor,"fd",fd);
    //DebugN("Answer not full",ds1);
      DebugTN("15");
    return(true);
  }
  
  //Create Result
  //DebugN("--- gTcpFileDescriptor",gTcpFileDescriptor,"fd",fd);
  //DebugN("Answer",sTemp);
  strreplace(sTemp, ds1[1]+"\n", "");
  for (i=2; i<dynlen(ds1); i++)
  {
    dsRes = strsplit(ds1[i], ";");
    ddsResult[++j] = dsRes;
    strreplace(sTemp, ds1[i]+"\n", "");
  }
  strreplace(sTemp, ds1[i]+"\n", "");
  
  gTcpFifo = sTemp;
    DebugTN("16");
  return(false);
}

//-------------------------------------------------------------
// get description of a manager ('clear text')
//-------------------------------------------------------------
string pmon_getManDescript(string manName)
{
  string descript;
  
  pmonClearLastError();

  if ( strpos(manName, ".exe") > 0 )
    manName = strrtrim(manName, ".exe");
  descript = getCatStr("managers", manName);
  
  if ( dynlen(getLastError()) )  descript = ""; // not found

  return descript;
}

dyn_dyn_string pmon_getMenagerList(string projName, string &otherProject, bool &bRun, string sUser, string sPassword)
{
  file           fd;
  string         host;
  int            port, iErr;
  bool           err;
  dyn_dyn_string ddsResult;

  //DebugN(" --- paIsProjRunning --- projName",projName);
  DebugTN("5m");
  //    ako je gHost prazan trazi host name - dobice "localhost"
  host = gHost;
  port = gPort;
  if(host == "")
  {
    iErr = paGetProjHostPort(projName, host, port);
  }
  
  otherProject = "";
  if ( iErr )
  {
    otherProject = "";
    bRun = false;
      DebugTN("error: " + iErr);
    return ddsResult;
  }
    DebugTN("6m");
    DebugTN("pmon_query - host: " + host + ", projName: " + projName);
  err = pmon_query(sUser+"#"+sPassword+"#MGRLIST:LIST", host, port, ddsResult, false, true);  

  if ( err || dynlen(ddsResult) < 1 )
  {
    otherProject = "";
    bRun = false;
    DebugTN("6 error = " + err);
    return ddsResult;
  }
  else
  if ( ddsResult[1][1] != projName )
  {
    DebugTN("6m bez greske error = " + err);
    //DebugTN(ddsResult); 
    otherProject = ddsResult[1][1];
    bRun = false;
    return ddsResult;
  }
  DebugTN("6mb");
  //DebugTN("6mb dssResult: ", ddsResult, ddsResult[1][1]);
}


dyn_dyn_string pmon_getMenagerStat(string projName, string &otherProject, bool &bRun, string sUser, string sPassword)
{
  file           fd;
  string         host;
  int            port, iErr;
  bool           err;
  dyn_dyn_string ddsResult;

  //DebugN(" --- paIsProjRunning --- projName",projName);
  DebugTN("5m");
  //    ako je gHost prazan trazi host name - dobice "localhost"
  host = gHost;
  port = gPort;
  if(host == "")
  {
    iErr = paGetProjHostPort(projName, host, port);
  }
  
  otherProject = "";
  if ( iErr )
  {
    otherProject = "";
    bRun = false;
    DebugTN("error: " + iErr);
    return ddsResult;
  }
  
  DebugTN("6m");
  err = pmon_query(sUser+"#"+sPassword+"#MGRLIST:STATI", host, port, ddsResult, false, true);
  DebugTN("--------------------- len: ", dynlen(ddsResult));

  if ( err || dynlen(ddsResult) < 1 )
  {
    otherProject = "";
    bRun = false;
    DebugTN("6 error = " + err);
    return ddsResult;
  }
  else
  if ( ddsResult[1][1] != projName )
  {
    DebugTN("6m bez greske error = " + err);
    //DebugTN(ddsResult); 
    otherProject = ddsResult[1][1];
    bRun = false;
    return ddsResult;
  }
  DebugTN("6mb");
  //DebugTN("6mb dssResult: ", ddsResult, ddsResult[1][1]);   
}

//-----------------------------------------------------------------------------
//-------------------------------------------------------------
// execute tcp command
//-------------------------------------------------------------
bool pmon_command(string command, string host, int port,
             bool showErrorDialog = false, bool openTcp = false)
{
  int          fd,
               iTimeOut = (host=="localhost"||host=="")?PA_TCP_TIMEOUT_LOCAL:PA_TCP_TIMEOUT;
  bool         error = false;
  string       result;
  dyn_anytype  daResult;
  dyn_errClass err;
  
  error = false;

  //#104535: Avoid Child Panel if function is used in CTRL - Manager
  if(myManType() == CTRL_MAN)
    showErrorDialog = false;  

  if ( openTcp )
  {
    fd = tcpOpen(host, port);
    err = getLastError();
    if ( dynlen(err) >= 1 )
    {
      if ( fd != -1 )
        tcpClose(fd);  //Es k�nnte Verbindung �brig bleiben
      
      throwError(err);  //Ausgeben da nicht per Default ausgegeben
      errorDialog(err);
      return(true);
    }
  }
  else if ( gTcpFileDescriptor2 < 0 )
  {
    err = getLastError();
    if ( dynlen(err) ) errorDialog(err);
    return(true);
  }
  else
  {
    fd = gTcpFileDescriptor2;
  }
  
  command += "\n";
  
  if ( tcpWrite(fd, command) == -1 )
  {
    err = getLastError();
    if ( openTcp && fd > -1 ) tcpClose(fd);// fd = -1;
    
    if ( dynlen(err) && showErrorDialog )
      errorDialog(err);
    return(true);
  }
  
  if ( tcpRead(fd, result, iTimeOut) == -1 )
  {
    err = getLastError();
    if ( openTcp && fd > -1 ) tcpClose(fd);// fd = -1;
    
    if ( dynlen(err) && showErrorDialog )
      errorDialog(err);
    return(true);
  }
//DebugN("pmon_command --- command",command,"gTcpFileDescriptor",gTcpFileDescriptor,"fd",fd);
//DebugN("result",result);

  if ( strltrim(strrtrim(result)) == "" && showErrorDialog )
  {
    pmon_warningOutput("errTcp", -1);
    error = true;
  }
  else
  if ( result != "OK" && showErrorDialog )
  {
    string code;

    sscanf(result, "ERROR %s", code);
    //pmon_warningOutput(code, -1);
      
    error = true;
  }
  
  if ( openTcp && fd > -1 ) tcpClose(fd);
  return(error);
}

//-------------------------------------------------------------
// stop manager at position manPos
//-------------------------------------------------------------
pmonStopManager2(bool &err, string projName, int manPos, string sUser, string sPassword)
{
  string str, host;
  //int    port, iErr = paGetProjHostPort(projName, host, port);
  int    port, iErr;
  host = gHost;
  port = gPort;  
  if(host == "")
  {
    iErr = paGetProjHostPort(projName, host, port);
  }
  dyn_dyn_anytype daResult;

  if ( iErr )
  {
    pmon_warningOutput("errHostOrPort", -1);
    err = true;
    return;
  }

  sprintf(str, "SINGLE_MGR:STOP %d", manPos);
  str = sUser+"#"+sPassword+"#"+str;
  
  err = pmon_command(str, host, port, true, true);
}

//-------------------------------------------------------------
// start manager at position manPos according properties saved in progs
//-------------------------------------------------------------
pmonStartManager2(bool &err, string projName, int manPos, string sUser, string sPassword)
{
  string str, host;
  int    port, iErr;
  host = gHost;
  port = gPort;  
  if(host == "")
  {
    iErr = paGetProjHostPort(projName, host, port);
  }
  dyn_dyn_anytype daResult;

  if ( iErr )
  {
    pmon_warningOutput("errHostOrPort", -1);
    err = true;
    return;
  }

  sprintf(str, "SINGLE_MGR:START %d", manPos);
  str = sUser+"#"+sPassword+"#"+str;
  
  err = pmon_command(str, host, port, true, true);
  DebugTN("pmonStartManager2 - str: " + str + ", host: " + host + ", port: " + port + ", err: " +err);
}


//dobavlja listu imena systemNames, HostName i ime projekta  
//PAZNJA - lista je dvodimenzionalni niz, prvi clan je sysName, drugi hostName, treci ProjectName
//Kad je prazan string za sysName, radi se o lokalnom systemName-u
dyn_dyn_string get_list_of_hosts()
{
  dyn_dyn_string dds_Hosts;
  dyn_dyn_anytype dda_SysNames;
  dda_SysNames = get_list_of_systemNames();
  int i;
  for(i = 2; i<=dynlen(dda_SysNames); i++)
  {    
    string sSysName = dda_SysNames[i][2];
    //DebugTN("List remote hostova: ", list);
    dyn_string dsHostName = getRemoteSystemHosts(sSysName);
    int j;
    for(j = 1; j <= dynlen(dsHostName); j++)
    {
      string sProj =   paGetProjectName(dsHostName[j], gPort, PA_USER_NAME, PA_USER_PASSWORD);
      //DebugTN("SysName: " + sSysName, "Host: " + dsHostName[j], "Project name: " + sProj);
      dyn_string host_details = makeDynString(sSysName, dsHostName[j], sProj);
      dynAppend(dds_Hosts, host_details);      
    }    
  }
  DebugTN("dds_Hosts: ", dds_Hosts); 
  return dds_Hosts;
}

//dobavlja listu imena systemNames-a 
//PAZNJA - lista je dvodimenzionalni niz, imena se nalaze u list[i][2]
//Kad je prazan string radi se o lokalnom systemName-u
dyn_dyn_anytype get_list_of_systemNames()
{
  string sSelect = "SELECT '_online.._value' FROM '_DistSync*.Config.Systemname'";;
  dyn_dyn_anytype list;
  int i, iVal;
  int iRes = dpQuery(sSelect, list);
  string dpe;

   //logiranje za debagiranje  
  //DebugTN("iRes = " + iRes);  
  
  for(i = 2; i<=dynlen(list); i++)
  {
    dpe = list[i][1];
    iVal = list[i][2];
    //DebugTN("List remote hostova: ", list);
  } 
  return list;
}


fill_table()
{
  table_pmon_details.deleteAllLines();
  dyn_dyn_string ddsManager_details_org;
  string sProject_Name = cbProjectName.text();
  gHost = cbHostName.text();
  ddsManager_details_org = get_pmon_Info(sProject_Name); 
  
  dyn_dyn_string ddsManager_details = filter_Array(ddsManager_details_org);
  delay(1); 
  DebugTN("--- ++ --- Poslije klika");
  //DebugTN(ddsManager_details);
  
  //table_pmon_details.
  int iLen = dynlen(ddsManager_details);
  //DebugTN(dynlen(ddsManager_details));
    
  
  for(int i = 1; i< iLen + 1; i++)
  {

    //start_mode
    string sStart_mode = "unknown";
    switch(ddsManager_details[i][3])
    {
      case 0:
      sStart_mode = "manual";
      break;
      case 1:
      sStart_mode = "once";
      break;
      case 2:
      sStart_mode = "always";
      break;
    }
    
    //state
    string sState = "unknown";
    string sColor = "white";
    switch(ddsManager_details[i][8])
    {
      case 0:
      sState = "stopped";
      sColor = "white";
      break;
      case 1:
      sState = "init";
      sColor = "yelow";
      break;
      case 2:
      sState = "running";
      sColor = "green";
      break;
      case 3:
      sState = "blocked";
      sColor = "blue";
      break;
      default:
      sState = ddsManager_details[i][8];      
    }
    
    table_pmon_details.appendLine("Id", ddsManager_details[i][1], "CheckBox", "", "Type", ddsManager_details[i][2], "Start_mode", sStart_mode, "#5", ddsManager_details[i][4],
                                  "#6", ddsManager_details[i][5], "#7", ddsManager_details[i][6], "Start_details", ddsManager_details[i][7], 
                                  "State", sState, "Proc_Id", ddsManager_details[i][9],  "#8", ddsManager_details[i][10],
                                  "Last_Start", ddsManager_details[i][11]);
    table_pmon_details.cellBackColRC(i-1, "State", sColor);
    
    //dodaje checkbox u celiju
    bool val;
    table_pmon_details.cellValueRC(i-1,"CheckBox",val);

  }
  
  init_table();           
}

init_table()
{
  //prilagodi sirinu kolona i visinu redova
  table_pmon_details.adjustColumn(0);
  table_pmon_details.adjustColumn(2);
  table_pmon_details.adjustColumn(6);
  table_pmon_details.adjustColumn(10);
  
  table_pmon_details.rowHeight(20);
  
  //dozvoli editovanje checkbox kolone
  table_pmon_details.columnEditable(1, true);
  
  //sakrij kolone  
  table_pmon_details.columnVisibility(3, false);
  table_pmon_details.columnVisibility(4, false);
  table_pmon_details.columnVisibility(5, false);
  table_pmon_details.columnVisibility(11, false);
}

dyn_dyn_string filter_Array(dyn_dyn_string ddsManager_details)
{
    dyn_dyn_string ddsFilteredManager_details;
    int iLen = dynlen(ddsManager_details);
//    ddsManager_details = get_pmon_Info(); 
    DebugTN("ddsManager_details len = " + iLen);
    
    for(int i = 2; i< iLen + 1; i++)
  {
    
    //Ako je manager tipa WCCIL, nemoj ga prikazivati
    int iWCCI;    
    string sWCCI = "WCCIL";
    iWCCI = strpos(ddsManager_details[i][1], sWCCI,0);
    if(iWCCI >= 0)
    {
      continue;
      //dynRemove(ddsManager_details, i);
    }
    
    //Ako je manager tipa WCCIL, nemoj ga prikazivati
    int iWCCI;    
    string sWCCI = "WCCOAvalarch";
    iWCCI = strpos(ddsManager_details[i][1], sWCCI,0);
    if(iWCCI >= 0)
    {
      continue;
      //dynRemove(ddsManager_details, i);
    }
      
    dyn_string ds = makeDynString(i, ddsManager_details[i][1], ddsManager_details[i][2], ddsManager_details[i][3], 
                                  ddsManager_details[i][4], ddsManager_details[i][5], ddsManager_details[i][6], 
                                  ddsManager_details[i][7], ddsManager_details[i][8], ddsManager_details[i][9], 
                                  ddsManager_details[i][10], ddsManager_details[i][11]);
    //DebugTN("ds: ", ds);
    dynAppend(ddsFilteredManager_details, ds);
    
  }
  return ddsFilteredManager_details;    
}
