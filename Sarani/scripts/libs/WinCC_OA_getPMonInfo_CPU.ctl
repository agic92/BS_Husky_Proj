#uses "pmon.ctl"
#uses "CtrlPv2Admin"

string gTcpFifo;
int gTcpFileDescriptor;
int hostnr;

string sProjUser="";            // user project lock in console
string sProjPassword="";        // password for console
int ipmonPort;                  // Pmon Port (default=4999)
string sHostname = "localhost"; // hostname for local server

// mapping to store the information read from the process-monitor
mapping m_PMonList;

NFR_getPID(string s_process, int &i_PID)
{
  //DebugTN(__LINE__,"NFR_getPID - m_PMonList - s_process",m_PMonList,s_process);
  if(mappingHasKey(m_PMonList,s_process))
  {
    i_PID = m_PMonList[s_process];
  }
  else
  {
    i_PID = -1;
  }
}

int NFR_readPmonListCPU(int i_hostNum)
{
  dyn_dyn_string ddsResultList; // result of MGRLIST:LIST
  //ddsResultList[i][1] <manager>
  //ddsResultList[i][2] <startMode>
  //ddsResultList[i][3] <secKill>
  //ddsResultList[i][4] <restartCount>
  //ddsResultList[i][5] <resetMin>
  //ddsResultList[i][6] <CommandlineOptions>

  dyn_dyn_string ddsResultStati;// result of MGRLIST:STATI
  //ddsResultStati[i][1] <state> 0(stopped),1(init),2(running),3(blocked)
  //ddsResultStati[i][2] <PID> 
  //ddsResultStati[i][3] <startMode> 0(manual),1(once),2(always)
  //ddsResultStati[i][4] <startTime> 
  //ddsResultStati[i][5] <manNum> 
 
  dyn_string ds_manList;
  dyn_string ds_manListNames;
  dyn_int di_manNums;
  dyn_int di_PIDs;
  dyn_bool db_selectedManagers;
  
  int errList; // errorcode of MGRLIST:LIST
  int errStati;// errorcode of MGRLIST:STATI
  
  string s_reduPostFix;
  
  string s_version;
  
  int i;

  if(i_hostNum == 2)
    s_reduPostFix = "_2";
  
  if(!dpExists("NFR_PMonInfo_CPU" + s_reduPostFix))
  {
    dpCreate("NFR_PMonInfo_CPU" + s_reduPostFix,"NFR_PMonInfo_CPU");
  }
  
  paCfgReadValue(PROJ_PATH + "config/config","general","pmonPort",ipmonPort);
  if(ipmonPort == 0)
  {
    if(_SOLARIS)
      ipmonPort = 4779;
    else
      ipmonPort = 4999;
  }
  
  // refresh the information in an interval of 60 seconds
  while(1)
  {
    // array to store the information for the selected managers
    dyn_string ds_selectedManagers;
    
    // initialize the variables
    mappingClear(m_PMonList);
    dynClear(ds_manList);
    dynClear(di_manNums);
    dynClear(di_PIDs);
    dynClear(ds_manListNames);
    
    // read the current settings which managers the user has selected
    dpGet("NFR_PMonInfo_CPU" + s_reduPostFix + ".managerList",ds_manList,
          "NFR_PMonInfo_CPU" + s_reduPostFix + ".managerNums",di_manNums,
          "NFR_PMonInfo_CPU" + s_reduPostFix + ".selectedManagers",db_selectedManagers);

    for(i=1;i<=dynlen(db_selectedManagers);i++)
    {
      string s_manager;
      int i_num;

      //DebugTN(__LINE__,"check if manager is selected",ds_manList[i],di_manNums[i],db_selectedManagers[i]);
      if(db_selectedManagers[i] == 1)
      {
        //DebugTN(__LINE__,"check the length of the arrays",db_selectedManagers[i],i,dynlen(ds_manList),dynlen(di_manNums));
        // check if the other arrays have the correct length
        if(i <= dynlen(ds_manList) && i <= dynlen(di_manNums))
        {
          s_manager = ds_manList[i];
          i_num = di_manNums[i];
      
          s_version = VERSION;

          if(s_version == "3.9" || s_version == "3.10")
          {
            if(s_manager != "PVSS00data" && s_manager != "PVSS00event")
            {
              s_manager = s_manager + "#" + i_num;
            }
          }
          else
          {
            if(s_manager != "WCCILdata" && s_manager != "WCCILevent")
            {
              s_manager = s_manager + "#" + i_num;
            }
          }
          //DebugTN(__LINE__,"add manager to array of selected managers",s_manager);
          dynAppend(ds_selectedManagers,s_manager);
        }
      }
    }
    
    //DebugTN(__LINE__,"list of selected managers",ds_selectedManagers);

    // initialize the variables
    dynClear(ds_manList);
    dynClear(di_manNums);
    dynClear(db_selectedManagers);
  
    errList = pmon_query(sProjUser+"#"+sProjPassword+"#MGRLIST:LIST", sHostname, ipmonPort, ddsResultList,0,1);
    errStati= pmon_query(sProjUser+"#"+sProjPassword+"#MGRLIST:STATI", sHostname, ipmonPort, ddsResultStati,0,1);
  
    for(i=1;i<=dynlen(ddsResultList);i++)
    {
      string s_manager;
      int i_num;
      int i_PID;
    
      s_manager = ddsResultList[i][1];
      i_num = ddsResultStati[i][5];
      i_PID = ddsResultStati[i][2];

      dynAppend(ds_manList,s_manager);    
      dynAppend(di_manNums,i_num);    
      dynAppend(di_PIDs,i_PID);    

    
      s_version = VERSION;

      if(s_version == "3.9" || s_version == "3.10")
      {
        if(s_manager != "PVSS00data" && s_manager != "PVSS00event")
        {
          s_manager = s_manager + "#" + i_num;
        }
      }
      else
      {
        if(s_manager != "WCCILdata" && s_manager != "WCCILevent")
        {
          s_manager = s_manager + "#" + i_num;
        }
      }
      m_PMonList[s_manager] = i_PID;
      dynAppend(ds_manListNames,s_manager);
    }

    for(i=1;i<=dynlen(ds_manListNames);i++)
    {
      string s_manListName;
      
      s_manListName = ds_manListNames[i];
      
      if(dynContains(ds_selectedManagers,s_manListName))
        db_selectedManagers[i] = 1;
      else
        db_selectedManagers[i] = 0;
        
    }   
    
    dpSetWait("NFR_PMonInfo_CPU" + s_reduPostFix + ".managerList",ds_manList,
              "NFR_PMonInfo_CPU" + s_reduPostFix + ".managerNums",di_manNums,
              "NFR_PMonInfo_CPU" + s_reduPostFix + ".processIDs",di_PIDs,
              "NFR_PMonInfo_CPU" + s_reduPostFix + ".selectedManagers",db_selectedManagers);
    
    // wait 60 seconds before starting the next loop
    delay(10);
  }
  return(1);
}

