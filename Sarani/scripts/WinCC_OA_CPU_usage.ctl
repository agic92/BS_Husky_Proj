// script to read the CPU and memory usage for the given list of managers
// the result is written to the file <process-name>_CPU.log at the data-directory

#uses "WinCC_OA_getPMonInfo_CPU.ctl"
#uses "hosts.ctl"

// mapping to store the used CPU-time and the elapsed time for the CPU-calculation
mapping m_times;

// list of processes for CPU- and memory-tracing
dyn_string ds_managers;

// list of managers with existing logfiles
dyn_string ds_managerLogs;

// variable to store if the timedFunc is already started
bool b_startedTF;

// path for the log-files
string s_logPath;

// values for the timedFunc-calls
int i_intervalTF;

// store the information if the script is running on host1 or host2 in a redundant system
int i_hostNum;
string s_reduPostFix;

// store the information for the report logfile
bool b_recordMsgInfo;
mapping m_reportFileData;
string s_logSeparator;

main()
{
  int i_return;
  bool b_configError;

  // get the information if the script is running on host1 or host2 in a redundant system
  if(isRedundant())
  {
    i_hostNum = initHosts();
    
    if(i_hostNum == 2)
      s_reduPostFix = "_2";
  }

  // check if the datapoint NFR_work_PMonInfo exists
  if(!dpExists("NFR_PMonInfo_CPU"))
  {
    dyn_errClass deC_error;
    string s_error;
    
    b_configError = 1;
    //DebugTN(__LINE__,"Datapoint NFR_PMonInfo_CPU is missing - CPU information cannot be used");
    s_error = getCatStr("_errors","00007");
    deC_error = makeError("_errors",PRIO_FATAL,ERR_CONTROL,54,"NFR_PMonInfo_CPU " + s_error);

    throwError(deC_error);
  }

  // check if the datapoint NFR_work_PMonInfo_2 exists in a redundant system
  if(isRedundant() && !dpExists("NFR_PMonInfo_CPU_2"))
  {
    dyn_errClass deC_error;
    string s_error;
    
    b_configError = 1;
    //DebugTN(__LINE__,"Datapoint NFR_PMonInfo_CPU is missing - CPU information cannot be used");
    s_error = getCatStr("_errors","00007");
    deC_error = makeError("_errors",PRIO_FATAL,ERR_CONTROL,54,"NFR_PMonInfo_CPU_2 " + s_error);

    throwError(deC_error);
  }

  if(b_configError == 0)
  {
    // read the current managers and PIDs from the process monitor and write it to the NFR_PMonList-datapoint
    // start it in an own thread because and endless while-loop is used
    //DebugTN(__LINE__,"NFR_readPmonList",i_hostNum);
    startThread("NFR_readPmonListCPU",i_hostNum);
  
    // create datapoint for timedFunc()
    i_return = NFR_createTFDatapoints();
  
    // do the connect to the control-datapoint
    dpConnect("NFR_work_PMonInfo",1,"NFR_PMonInfo_CPU.active",
                                    "NFR_PMonInfo_CPU.CPU_checkInterval",
                                    "NFR_PMonInfo_CPU.separator",
                                    "NFR_PMonInfo_CPU.recordMsgInfo");
    
    // do the connect to the control-datapoint to create new datapoints
    dpConnect("NFR_work_createDatapoint",1,"NFR_PMonInfo_CPU.createDP");
  }
}

NFR_work_PMonInfo(string s_dpActive, bool b_active,
                  string s_dpInterval, int i_interval,
                  string s_dpSeparator, string s_separator,
                  string s_dpMsgInfo, bool b_msgInfo)
{
  int i_return;
  int i;
  string s_logDir;
  
  dyn_errClass deC_err;

  if(b_active == 0)
  {
    dpSetWait("TF_CPU_check.validFrom",0,
              "TF_CPU_check.validUntil",1);
    
    b_startedTF = 0;
    dynClear(ds_managerLogs);
    b_recordMsgInfo = 0;
  }
  else
  {
    if(i_interval == 0)
      i_interval = 30;
    
    i_intervalTF = i_interval;
    
    dpGet("NFR_PMonInfo_CPU.logDirectory",s_logDir);
    
    if(!b_startedTF)
    {
      string s_dir;
      
      // append the date + time when tracing the CPU was started to the log-directory
      // also the hostname is written to the directory
      s_dir = formatTime("%Y%m%d_%H%M%S",getCurrentTime());
      s_dir = s_dir + "_" + getHostname();
      s_logPath = s_logDir + "/" + s_dir;
      
      mkdir(s_logPath);
      
      // add a "/" at the end of the path
      s_logPath = s_logPath + "/";
    }

    // write the file with the system-information 
    i_return = NFR_getSystemInfo();
    
    // get the list of processes for CPU tracing
    i_return = NFR_getSelectedManagers();
    
    // set the global variables for the report logfile
    b_recordMsgInfo = b_msgInfo;
    s_logSeparator = s_separator;

    // create the inital report logfile including header information
    i_return = NFR_createReportLogFile();
    
    // create the inital logfile including header information
    // check if the datapoint for the process-name exists
    for(i=1;i<=dynlen(ds_managers);i++)
    {
      string s_processInfoDP;
      
      // check if the initial log-file is already created
      if(!dynContains(ds_managerLogs,ds_managers[i]))
      {
        //DebugTN(__LINE__,"initial logfile not existing",ds_managerLogs,ds_managers[i]);
        i_return = NFR_createLogFile(ds_managers[i]);
      }

      // check if the datapoint for the process-name exists
      if(ds_managers[i] == "Idle")
      {
        s_processInfoDP = ds_managers[i] + "_CPU" + s_reduPostFix;
      }
      else
      {
        s_processInfoDP = ds_managers[i] + s_reduPostFix;
      }

      if(!dpExists(s_processInfoDP))
      {
        int i_err;
      
        // call an own function to create the datapoint for the process-name
        // a normal dpCopy will not work in a redundant system for the passive server
        dpSet("NFR_PMonInfo_CPU.createDP",s_processInfoDP);
      }
    }

    dpSetWait("TF_CPU_check.validFrom",0,
              "TF_CPU_check.validUntil",makeTime(2035,1,1),
              "TF_CPU_check.interval",i_interval);
    
    if(!b_startedTF)
    {
      // start timedFunc
      //DebugTN(__LINE__,"start timedFunc");
      timedFunc("NFR_TF_recordCPU","TF_CPU_check");
      deC_err = getLastError();
      if(dynlen(deC_err) == 0)
        b_startedTF = 1;
    }
  }
}

NFR_TF_recordCPU(string s_timedFuncDP,time t_last,time t_now,bool b_call)
{
  int i_return;
  int i_VC;
  int i;
  
  // reset the global variable for the logfile information
  mappingClear(m_reportFileData);
  
  // get the current VC-information (NFR simulation)
  // if the datapoint does not exist i_VC = -1
  if(b_recordMsgInfo)
  {
    if(dpExists("NFR_messageSimulation"))
      dpGet("NFR_messageSimulation.information.VC_per_sec",i_VC);
    else
      i_VC = -1;
  }    
    
  // start an own thread for every process 
  for(i=1;i<=dynlen(ds_managers);i++)
  {
    // start the CTRL thread
    startThread("NFR_recordCPU",ds_managers[i]);
  }
  
  // check if the threads for all processes are finished
  while(mappinglen(m_reportFileData) != dynlen(ds_managers))
  {
    delay(1);
  }
  
  // call the function to write the report logfile
  i_return = NFR_writeReportLogFile(t_now,i_VC);
  
}

// main-function to start the necessary sub-functions for every process
NFR_recordCPU(string s_process)
{
  // read the current output of the ps-command
  NFR_readCPU(s_process);
  
  // read the last process information, calculate the CPU-usage and write it to the log-file
  if(_WIN32 || s_process != "Idle")
  {
    NFR_appendCPULogFile(s_process);
  }
  else if(_UNIX && s_process == "Idle")
  {
    NFR_appendIdleCPULogFile(s_process);
  }
}


// function to create the inital logfile including header information
int NFR_createLogFile(string s_process)
{
  string s_line;
  string s_logFile;
  file f_logFile;
  
  s_logFile = s_process + "_CPU.log";
  
  f_logFile = fopen(s_logPath + s_logFile,"w");
  
  // define the header fitting the ps-command because it is different on every operating system
  // at the end of the line you have to add the column for the CPU usage in percent and the current time:       %CPU                     Time
  if(s_process == "Idle")
  {
    s_line = "%CPU Idle                     Time\n";
  }
  else
  {
    if(_WIN32)
    {
      s_line = "Name                Pid Pri Thd  Hnd   Priv        CPU Time    Elapsed Time      %CPU                     Time\n";
    }
  
    if(_UNIX)
    {
      s_line = "COMMAND           PID   RSS    VSZ     ELAPSED     TIME      %CPU                     Time\n";    
    }
  }
    
  fputs(s_line,f_logFile);
  fclose(f_logFile);
  
  dynAppend(ds_managerLogs,s_process);

  return(1);
}

// read the current output of the ps-command
NFR_readCPU(string s_process)
{
  string s_commandPrefix;
  string s_command;
  string s_exePath;
  string s_exe;
  string s_exeOptions;
  
  string s_fileName;
  
  int i_PID;
  
  if(s_process != "Idle")
  {
    // get the PID for the process
    NFR_getPID(s_process, i_PID);
  
    //DebugTN(__LINE__,"process + PID",s_process,i_PID);
  
    // define which ps-command and which options shall be used
    // ps command is different on every operating system
    if(_WIN32)
    {
      //s_commandPrefix = "cmd /c ";
      s_exePath = PROJ_PATH + "data/PSTools/";
      s_exe = "pslist.exe";
      s_exeOptions = i_PID;
    }
  
    if(_UNIX)
    {
      s_exe = "ps";
      s_exeOptions = "-o comm,pid,rss,vsz,etime,time -p " + i_PID;
    }
  
    s_fileName = s_process + "_pslist.log";
  
    s_command = s_commandPrefix + s_exePath + s_exe + " " + s_exeOptions + " > " + s_logPath + s_fileName;
  }
  else if(s_process == "Idle")
  {
    if(_WIN32)
    {
      // to be able to calculate the CPU-Idle we need to get the pslist-values for "Idle" and "System"
      //s_commandPrefix = "cmd /c ";
      s_exePath = PROJ_PATH + "data/PSTools/";
      s_exe = "pslist.exe";

      s_exeOptions = "Idle";
      s_fileName = s_exeOptions + "_pslist.log";
 
      s_command = s_commandPrefix + s_exePath + s_exe + " " + s_exeOptions + " > " + s_logPath + s_fileName;

      // call the first system-command to write the Idle_pslist.log-file
      system(s_command);
      
      s_exeOptions = "System";
      s_fileName = s_exeOptions + "_pslist.log";
  
      s_command = s_commandPrefix + s_exePath + s_exe + " " + s_exeOptions + " > " + s_logPath + s_fileName;
    }
    if(_UNIX)
    {
      s_exe = "cat";
      s_exeOptions = "/proc/stat | grep \"cpu \"";

      s_fileName = s_process + "_stat.log";
 
      s_command = s_exe + " " + s_exeOptions + " > " + s_logPath + s_fileName;
    }
    if(_SOLARIS)
    {
      // use the uptime command to get the idle CPU time
      s_exe = "uptime";
      s_exeOptions = "";
              
      s_fileName = s_process + "_stat.log";
      s_command = s_exe + " " + s_exeOptions + " > " + s_logPath + s_fileName;
    }
  }

  //DebugTN(__LINE__,"s_command",s_command);
  system(s_command);
}

// read the last process information, calculate the CPU-usage and write it to the log-file
NFR_appendCPULogFile(string s_process)
{
  string s_command;
  string s_exe, s_exeOptions;
  string s_fileName, s_logFile;
  string s_tmpFile, s_tmpLine;
  
  file f_tmpFile;

  string s_CPU, s_elapsed, s_CPUPercent, s_memory;

  float f_usedCPU;
  int i_memory;
  
  dyn_string ds_parts;
  
  dyn_time dt_times;

  time t_lastElapsed, t_nowElapsed;
  time t_lastCPU, t_nowCPU;
  time t_current;
  string s_timeCurrent;
  
  string s_tmpLineSystem;
  
  string s_numCPUs;
  int i_numCPUs;
  
  int i_fileExists = -1;

  s_exe = "tail";
  s_exeOptions = "-1";

  s_fileName = s_process + "_pslist.log";
  s_tmpFile = s_process + "_tmp.log";

  // delete the old tmp-file
  remove(s_logPath + s_tmpFile);
  
  // command to redirect the last line for the ps command into an own file
  s_command = s_exe + " " + s_exeOptions + " " + s_logPath + s_fileName + " > " + s_logPath + s_tmpFile;

  //DebugTN(__LINE__,"s_command",s_command);
  system(s_command);

  // check if the tmp-file is readable
  while(i_fileExists == -1)
  {
    i_fileExists = access(s_logPath + s_tmpFile,R_OK);
    delay(0,500);
  }
  
  // open the tmp-file to read the current process information
  f_tmpFile = fopen(s_logPath + s_tmpFile,"r");
  
  fgets(s_tmpLine,1000,f_tmpFile);
  fclose(f_tmpFile);
  
  s_tmpLine = substr(s_tmpLine,0,strlen(s_tmpLine)-1);

  //DebugTN(__LINE__,"s_tmpLine",s_tmpLine);
  
  // return if s_tmpLine is empty
  if(strlen(s_tmpLine) == 0)
  {
    return;
  }

  // to calculate the CPU-Idle we need also the System-information
  
  if(s_process == "Idle" && _WIN32)
  {
    s_fileName = "System" + "_pslist.log";
    s_tmpFile = "System" + "_tmp.log";

    // delete the old tmp-file
    remove(s_logPath + s_tmpFile);
  
    // command to redirect the last line for the ps command into an own file
    s_command = s_exe + " " + s_exeOptions + " " + s_logPath + s_fileName + " > " + s_logPath + s_tmpFile;

    //DebugTN(__LINE__,"s_command",s_command);
    system(s_command);

    // check if the tmp-file is readable
    while(i_fileExists == -1)
    {
      i_fileExists = access(s_logPath + s_tmpFile,R_OK);
      delay(0,500);
    }
  
    // open the tmp-file to read the current process information
    f_tmpFile = fopen(s_logPath + s_tmpFile,"r");
  
    fgets(s_tmpLineSystem,1000,f_tmpFile);
    fclose(f_tmpFile);
  
    s_tmpLineSystem = substr(s_tmpLineSystem,0,strlen(s_tmpLineSystem)-1);

    //DebugTN(__LINE__,"s_tmpLine",s_tmpLine);
  
    // return if s_tmpLine is empty
    if(strlen(s_tmpLineSystem) == 0)
    {
      return;
    }

  }    
    
  // read memory information, CPU- and elapsed time from the ps output
  // ps-command is different at the operating systems
  // define the columns where the necessary information is written to
  if(_WIN32)
  {
    int i_hours, i_minutes, i_seconds, i_milli;

    if(s_process != "Idle")
    {
      sscanf(s_tmpLine,"%*s %*s %*s %*s %*s %s %s %s",s_memory,s_CPU,s_elapsed);
      i_memory = (int)s_memory;
    }
    else
    {
      //DebugTN(__LINE__,"s_tmpLine",s_tmpLine);
      sscanf(s_tmpLine,"%*s %*s %*s %s %*s %*s %s %s",s_numCPUs,s_CPU,s_elapsed);
      sscanf(s_tmpLineSystem,"%*s %*s %*s %*s %*s %*s %*s %s",s_elapsed);
      
      i_numCPUs = (int)s_numCPUs;
      
      //DebugTN(__LINE__,"i_numCPUs",i_numCPUs,"s_CPU",s_CPU,"s_elapsed",s_elapsed);
    }

    //DebugTN(__LINE__,"i_memory",i_memory,"s_CPU",s_CPU,"s_elapsed",s_elapsed);
  
    strreplace(s_CPU," ","");
    strreplace(s_CPU,":",".");

    ds_parts = strsplit(s_CPU,".");

    i_hours = (int)ds_parts[1];
    i_minutes = (int)ds_parts[2];
    i_seconds = (int)ds_parts[3];
    i_milli = (int)ds_parts[4];

    setPeriod(t_nowCPU,i_hours*3600+i_minutes*60+i_seconds,i_milli);

    strreplace(s_elapsed," ","");
    strreplace(s_elapsed,":",".");

    ds_parts = strsplit(s_elapsed,".");

    i_hours = (int)ds_parts[1];
    i_minutes = (int)ds_parts[2];
    i_seconds = (int)ds_parts[3];
    i_milli = (int)ds_parts[4];

    setPeriod(t_nowElapsed,i_hours*3600+i_minutes*60+i_seconds,i_milli);
  }
  
  if(_UNIX)
  {
    int i_hours, i_minutes, i_seconds;
    int i_days;

    sscanf(s_tmpLine,"%*s %*s %*s %s %s %s",s_memory,s_elapsed,s_CPU);
    i_memory = (int)s_memory;
    
    //DebugTN(__LINE__,"i_memory",i_memory,"s_CPU",s_CPU,"s_elapsed",s_elapsed);

    strreplace(s_CPU," ","");

    ds_parts = strsplit(s_CPU,"-");

    if(dynlen(ds_parts) > 1)
    {
      i_days = (int)ds_parts[1];
      s_CPU = ds_parts[2];
    }
    else
    {
      i_days = 0;
    }
    
    ds_parts = strsplit(s_CPU,":");
    if(dynlen(ds_parts) == 2)
    {
      i_hours = 0;
      i_minutes = (int)ds_parts[1];
      i_seconds = (int)ds_parts[2];
    }
    else
    {
      i_hours = (int)ds_parts[1];
      i_minutes = (int)ds_parts[2];
      i_seconds = (int)ds_parts[3];
    }

    setPeriod(t_nowCPU,i_days*86400+i_hours*3600+i_minutes*60+i_seconds);

    
    strreplace(s_elapsed," ","");

    ds_parts = strsplit(s_elapsed,"-");

    if(dynlen(ds_parts) > 1)
    {
      i_days = (int)ds_parts[1];
      s_elapsed = ds_parts[2];
    }
    else
    {
      i_days = 0;
    }
    
    ds_parts = strsplit(s_elapsed,":");
    if(dynlen(ds_parts) == 2)
    {
      i_hours = 0;
      i_minutes = (int)ds_parts[1];
      i_seconds = (int)ds_parts[2];
    }
    else
    {
      i_hours = (int)ds_parts[1];
      i_minutes = (int)ds_parts[2];
      i_seconds = (int)ds_parts[3];
    }

    setPeriod(t_nowElapsed,i_days*86400+i_hours*3600+i_minutes*60+i_seconds);
  }


  // create the mapping entries for the calculation if they do not exist
  if(!mappingHasKey(m_times,s_process))
  {
    t_lastCPU = t_nowCPU;
    t_lastElapsed = t_nowElapsed;
    
    m_times[s_process] = makeDynTime(t_lastCPU,t_lastElapsed);
    
    sprintf(s_CPUPercent,"% 3.2f",0);
  }

  // read the mapping entries for the calculation
  else
  {
    float f_diffCPU, f_diffElapsed;
    
    dt_times = m_times[s_process];
    t_lastCPU = dt_times[1];
    t_lastElapsed = dt_times[2];
    
    
    //DebugTN(__LINE__,"t_nowCPU - t_lastCPU",t_nowCPU,t_lastCPU);
    
    // if the elapsed time for the CPU is equal to the last call the result is 0.0%
    if(t_nowCPU == t_lastCPU)
    {
      sprintf(s_CPUPercent,"% 3.2f",0);
    }
    // calculate the average CPU-usage for the last interval
    else
    {
      f_diffCPU = t_nowCPU - t_lastCPU;
      f_diffElapsed = t_nowElapsed - t_lastElapsed;
      
      // in case of the CPU-Idle calculation we have to divided the result for f_diffCPU by the number of processors
      if(s_process == "Idle")
      {
        //DebugTN(__LINE__,"f_diffCPU - i_numCPUs",f_diffCPU,i_numCPUs);
        f_diffCPU = f_diffCPU/i_numCPUs;
        //DebugTN(__LINE__,"f_diffCPU - i_numCPUs",f_diffCPU,i_numCPUs);
      }
    
      f_usedCPU = f_diffCPU/f_diffElapsed*100;

      sprintf(s_CPUPercent,"% 3.2f",f_usedCPU);
    
      t_lastCPU = t_nowCPU;
      t_lastElapsed = t_nowElapsed;

      m_times[s_process] = makeDynTime(t_lastCPU,t_lastElapsed);
    }
  }
  
  // write the information to the NFR_ProcessInfo-datapoint and to the mapping for report logfile
  if(s_process != "Idle")
  {
    dyn_anytype da_processData;
    string s_tmpCPUPercent;
    
    dpSet(s_process + s_reduPostFix + ".CPU_Percent",f_usedCPU,
          s_process + s_reduPostFix + ".Memory",i_memory);
    
    s_tmpCPUPercent = s_CPUPercent;
    strreplace(s_tmpCPUPercent," ","");
    da_processData[1] = s_tmpCPUPercent;
    da_processData[2] = i_memory;
    m_reportFileData[s_process] = da_processData;
  }
  else if(s_process == "Idle")
  {
    string s_tmpCPUPercent;

    dpSet(s_process + "_CPU" + s_reduPostFix + ".CPU_Percent",f_usedCPU);
    
    s_tmpCPUPercent = s_CPUPercent;
    strreplace(s_tmpCPUPercent," ","");
    m_reportFileData[s_process] = s_tmpCPUPercent;
  }
  
  t_current = getCurrentTime();
  s_timeCurrent = formatTime("%Y.%m.%d %H:%M:%S",t_current,".%03d");

  // add the result for the CPU-calculation to the output of the ps-command
  if(s_process != "Idle")
  {
    s_tmpLine = s_tmpLine + "     " + s_CPUPercent + "  " + s_timeCurrent + "\n";
  }
  else if(s_process == "Idle")
  {
    s_tmpLine = s_CPUPercent + "  " + s_timeCurrent + "\n";
  }

  f_tmpFile = fopen(s_logPath + s_tmpFile,"w");
  
  fputs(s_tmpLine,f_tmpFile);
  fclose(f_tmpFile);
  
  s_logFile = s_process + "_CPU.log";
  
  // write the result to the logfile <process-name>_CPU.log
  s_command = s_exe + " " + s_exeOptions + " " + s_logPath + s_tmpFile + " >> " + s_logPath + s_logFile;

  //DebugTN(__LINE__,"s_command",s_command);
  system(s_command);
}


int NFR_createTFDatapoints()
{
  if(!dpExists("TF_CPU_check"))
  {
    dpCreate("TF_CPU_check","_TimedFunc");
  
    while(!dpExists("TF_CPU_check"))
      delay(3);
  }
    
  dpSetWait("TF_CPU_check.validFrom",0,
            "TF_CPU_check.validUntil",1,
            "TF_CPU_check.interval",20,
            "TF_CPU_check.syncDay",-1,
            "TF_CPU_check.syncMonth",-1,
            "TF_CPU_check.syncTime",0,
            "TF_CPU_check.syncWeekDay",-1);
  return(1);
}


int NFR_getSelectedManagers()
{
  dyn_string ds_manList;
  dyn_int di_manNums;
  dyn_bool db_selectedManagers;
  int i;
  bool b_idleCPU;

  dpGet("NFR_PMonInfo_CPU" + s_reduPostFix + ".managerList",ds_manList,
        "NFR_PMonInfo_CPU" + s_reduPostFix + ".managerNums",di_manNums,
        "NFR_PMonInfo_CPU" + s_reduPostFix + ".selectedManagers",db_selectedManagers,
        "NFR_PMonInfo_CPU.getCPUIdle",b_idleCPU);
  
  dynClear(ds_managers);

  for(i=1;i<=dynlen(db_selectedManagers);i++)
  {
    if(db_selectedManagers[i] == 1)
    {
      // check if the other arrays have the correct length
      if(i <= dynlen(ds_manList) && i <= dynlen(ds_manList))
      {
        string s_manager;
        string s_version;
      
        s_version = VERSION;
      
        if(s_version == "3.9" || s_version == "3.10")
        {
          if(ds_manList[i] == "PVSS00data" || ds_manList[i] == "PVSS00event")
          {
            s_manager = ds_manList[i];
          }
          else
          {
            if(di_manNums[i] == 0)
            {
              s_manager = ds_manList[i];
            }
            // if the manager-number is higher than 0 the process-name is set with <manager-name>#<manager-number>
            else
            {
              s_manager = ds_manList[i] + "#" + di_manNums[i]; 
            }
          }
        }
        else
        {
          if(ds_manList[i] == "WCCILdata" || ds_manList[i] == "WCCILevent")
          {
            s_manager = ds_manList[i];
          }
          else
          {
            if(di_manNums[i] == 0)
            {
              s_manager = ds_manList[i];
            }
            // if the manager-number is higher than 0 the process-name is set with <manager-name>#<manager-number>
            else
            {
              s_manager = ds_manList[i] + "#" + di_manNums[i]; 
            }
          }
        }
        dynAppend(ds_managers,s_manager);
      }
    }
  }

  if(b_idleCPU == 1)
  {
    dynAppend(ds_managers,"Idle");
  }
  return(1);
}

NFR_appendIdleCPULogFile(string s_process)
{
  string s_tmpLine;
  string s_logFile;
  file f_logFile;
  file f_tmpFile;
  string s_tmpFile;
  string s_user, s_nice, s_system, s_idle, s_iowait, s_irq, s_softirq;
  int i_user, i_nice, i_system, i_idle, i_iowait, i_irq, i_softirq;
  int i_nowTotal, i_nowIdle;
  int i_lastTotal, i_lastIdle;
  
  float f_diffIdle, f_diffTotal;
  
  float f_idleCPU;
  string s_CPUPercent;
  string s_command, s_exe, s_exeOptions;
  
  time t_current;
  string s_timeCurrent;

  s_exe = "tail";
  s_exeOptions = "-1";
  
  s_tmpFile = "Idle_stat.log";
  
  f_tmpFile = fopen(s_logPath + s_tmpFile,"r");
  
  fgets(s_tmpLine,1000,f_tmpFile);
  fclose(f_tmpFile);

  if(_UNIX && !_SOLARIS)
  {
    sscanf(s_tmpLine,"%*s %s %s %s %s %s %s %s",s_user,s_nice,s_system,s_idle,s_iowait,s_irq,s_softirq);
  
    i_user = (int)s_user;
    i_nice = (int)s_nice;
    i_system = (int)s_system;
    i_idle = (int)s_idle;
    i_iowait = (int)s_iowait;
    i_irq = (int)s_irq;
    i_softirq = (int)s_softirq;
  
    i_nowTotal = i_user + i_nice + i_system + i_idle + i_iowait + i_irq + i_softirq;
    i_nowIdle = i_idle;
  
    if(!mappingHasKey(m_times,s_process))
    {
      i_lastIdle = i_nowIdle;
      i_lastTotal = i_nowTotal;
    
      m_times[s_process] = makeDynInt(i_lastIdle,i_lastTotal);
    
      sprintf(s_CPUPercent,"% 3.2f",0);
    }
    else
    {
      dyn_int di_times;
    
      di_times = m_times[s_process];

      i_lastIdle = di_times[1];
      i_lastTotal = di_times[2];
    }

    //DebugTN(__LINE__,"i_lastTotal, i_lastIdle",i_lastTotal,i_lastIdle);
    //DebugTN(__LINE__,"i_nowTotal, i_nowIdle",i_nowTotal,i_nowIdle);
  
    // if the elapsed time for the CPU is equal to the last call the result is 0.0%
    if(i_nowIdle == i_lastIdle)
    {
      sprintf(s_CPUPercent,"% 3.2f",0);
    }
    // calculate the average CPU-idle for the last interval
    else
    {
      f_diffIdle = i_nowIdle - i_lastIdle;
      f_diffTotal = i_nowTotal - i_lastTotal;

      f_idleCPU = 100-((f_diffTotal-f_diffIdle)/f_diffTotal*100);

      //DebugTN(__LINE__,"f_diffTotal, f_diffIdle, f_idleCPU",f_diffTotal,f_diffIdle,f_idleCPU);

      sprintf(s_CPUPercent,"% 3.2f",f_idleCPU);
    
      i_lastIdle = i_nowIdle;
      i_lastTotal = i_nowTotal;
    
      m_times[s_process] = makeDynInt(i_lastIdle,i_lastTotal);
    }
  }
  else if(_SOLARIS)
  {
    string s_idleCPU, s_tmpIdleCPU;
    dyn_string ds_tmpLineParts;
    dyn_string ds_idleCPUParts;
    float f_idleCPUPart1, f_idleCPUPart2;
    
    ds_tmpLineParts = strsplit(s_tmpLine," ");
    
    // get the necessary idle value based on the calculation interval
    if(i_intervalTF <= 60)
    {
      s_tmpIdleCPU = ds_tmpLineParts[dynlen(ds_tmpLineParts)-2];
      s_idleCPU = substr(s_tmpIdleCPU,0,strlen(s_tmpIdleCPU)-1);
    }
    else if(i_intervalTF > 60 && i_intervalTF <= 300)
    {
      s_tmpIdleCPU = ds_tmpLineParts[dynlen(ds_tmpLineParts)-1];
      s_idleCPU = substr(s_tmpIdleCPU,0,strlen(s_tmpIdleCPU)-1);
    }
    else
    {
      s_tmpIdleCPU = ds_tmpLineParts[dynlen(ds_tmpLineParts)];
      s_idleCPU = substr(s_tmpIdleCPU,0,strlen(s_tmpIdleCPU)-1);
    }
    
    strreplace(s_idleCPU,",",".");
    ds_idleCPUParts = strsplit(s_idleCPU,".");
    f_idleCPUPart1 = (float)ds_idleCPUParts[1];
    f_idleCPUPart2 = (float)ds_idleCPUParts[2];

    f_idleCPU = 100 - (f_idleCPUPart1 + f_idleCPUPart2/100);

    sprintf(s_CPUPercent,"% 3.2f",f_idleCPU);
  }

  s_process = s_process + "_CPU";
  
  // write the information to the NFR_ProcessInfo-datapoint
  dpSet(s_process + s_reduPostFix + ".CPU_Percent",f_idleCPU);
  
  t_current = getCurrentTime();
  s_timeCurrent = formatTime("%Y.%m.%d %H:%M:%S",t_current,".%03d");

  // write the result for the CPU-calculation to the tmp-file
  s_tmpLine = s_CPUPercent + "  " + s_timeCurrent + "\n";  

  f_tmpFile = fopen(s_logPath + s_tmpFile,"w");
  
  fputs(s_tmpLine,f_tmpFile);
  fclose(f_tmpFile);
  
  s_logFile = s_process + ".log";
  
  // write the result to the logfile <process-name>_CPU.log
  s_command = s_exe + " " + s_exeOptions + " " + s_logPath + s_tmpFile + " >> " + s_logPath + s_logFile;

  //DebugTN(__LINE__,"s_command",s_command);
  system(s_command);
}


// write the file with the system-information 
int NFR_getSystemInfo()
{
  string s_command;
  string s_exePath;
  string s_exe;
  string s_sysFile;
  string s_tmpFile;
  string s_tmpLine;
  file f_tmpFile;
  
  s_sysFile = "SystemInfo.txt";
  s_tmpFile = "SystemInfo_tmp.txt";
  
  if(_UNIX && !_SOLARIS)
  {
    s_exe = "cat";

    // add a header to the sys info file
    f_tmpFile = fopen(s_logPath + s_tmpFile,"w");

    s_tmpLine = "System information for " + getHostname() + "\n";  
    fputs(s_tmpLine,f_tmpFile);

    s_tmpLine = "\n";  
    fputs(s_tmpLine,f_tmpFile);

    fclose(f_tmpFile);

    s_command = s_exe + " " + s_logPath + s_tmpFile + " >> " + s_logPath + s_sysFile;

    //DebugTN(__LINE__,"s_command",s_command);
    system(s_command);
    
    // get the version-information
    f_tmpFile = fopen(s_logPath + s_tmpFile,"w");

    s_tmpLine = "+++ Version +++" + "\n";  
    fputs(s_tmpLine,f_tmpFile);

    s_tmpLine = "\n";  
    fputs(s_tmpLine,f_tmpFile);

    fclose(f_tmpFile);

    s_command = s_exe + " " + s_logPath + s_tmpFile + " >> " + s_logPath + s_sysFile;
    
    //DebugTN(__LINE__,"s_command",s_command);
    system(s_command);

    s_command = s_exe + " " + "/proc/version" + " >> " + s_logPath + s_sysFile;
    
    //DebugTN(__LINE__,"s_command",s_command);
    system(s_command);
    
    
    // get the CPU-information
    f_tmpFile = fopen(s_logPath + s_tmpFile,"w");

    // add empty lines to the result file
    s_tmpLine = "\n";  
    fputs(s_tmpLine,f_tmpFile);

    s_tmpLine = "\n";  
    fputs(s_tmpLine,f_tmpFile);

    s_tmpLine = "+++ CPU +++" + "\n";  
    fputs(s_tmpLine,f_tmpFile);

    s_tmpLine = "\n";  
    fputs(s_tmpLine,f_tmpFile);

    fclose(f_tmpFile);

    s_command = s_exe + " " + s_logPath + s_tmpFile + " >> " + s_logPath + s_sysFile;
    
    //DebugTN(__LINE__,"s_command",s_command);
    system(s_command);

    s_command = s_exe + " " + "/proc/cpuinfo" + " >> " + s_logPath + s_sysFile;
    
    //DebugTN(__LINE__,"s_command",s_command);
    system(s_command);


    // get the memory-information
    f_tmpFile = fopen(s_logPath + s_tmpFile,"w");

    // add empty lines to the result file
    s_tmpLine = "\n";  
    fputs(s_tmpLine,f_tmpFile);

    s_tmpLine = "\n";  
    fputs(s_tmpLine,f_tmpFile);

    s_tmpLine = "+++ Memory +++" + "\n";  
    fputs(s_tmpLine,f_tmpFile);

    s_tmpLine = "\n";  
    fputs(s_tmpLine,f_tmpFile);

    fclose(f_tmpFile);

    s_command = s_exe + " " + s_logPath + s_tmpFile + " >> " + s_logPath + s_sysFile;
    
    //DebugTN(__LINE__,"s_command",s_command);
    system(s_command);

    s_command = s_exe + " " + "/proc/meminfo" + " >> " + s_logPath + s_sysFile;
    
    //DebugTN(__LINE__,"s_command",s_command);
    system(s_command);
  }
  
  else if(_WIN32)
  {
    // on Windows we get all necessary information with one command
    s_exePath = PROJ_PATH + "data/PSTools/";
    s_exe = "PsInfo.exe";

    s_command = s_exePath + s_exe + " > " + s_logPath + s_sysFile;

    //DebugTN(__LINE__,"s_command",s_command);
    system(s_command);
  }
  
  else if(_SOLARIS)
  {
    // variables for Solaris functions
    dyn_string ds_stringBuffer;
    bool b_startRead;
    int i_lineCount;

    s_exe = "cat";

    // add a header to the sys info file
    f_tmpFile = fopen(s_logPath + s_tmpFile,"w");

    s_tmpLine = "System information for " + getHostname() + "\n";  
    fputs(s_tmpLine,f_tmpFile);

    s_tmpLine = "\n";  
    fputs(s_tmpLine,f_tmpFile);

    fclose(f_tmpFile);

    s_command = s_exe + " " + s_logPath + s_tmpFile + " >> " + s_logPath + s_sysFile;
    
    //DebugTN(__LINE__,"s_command",s_command);
    system(s_command);

    // get the version-information
    f_tmpFile = fopen(s_logPath + s_tmpFile,"w");

    s_tmpLine = "+++ Version +++" + "\n";  
    fputs(s_tmpLine,f_tmpFile);

    s_tmpLine = "\n";  
    fputs(s_tmpLine,f_tmpFile);

    fclose(f_tmpFile);

    s_command = s_exe + " " + s_logPath + s_tmpFile + " >> " + s_logPath + s_sysFile;
    
    //DebugTN(__LINE__,"s_command",s_command);
    system(s_command);

    s_command = "showrev | grep version" + " >> " + s_logPath + s_sysFile;
    
    //DebugTN(__LINE__,"s_command",s_command);
    system(s_command);

    // get the CPU-information
    f_tmpFile = fopen(s_logPath + s_tmpFile,"w");

    // add empty lines to the result file
    f_tmpFile = fopen(s_logPath + s_tmpFile,"w");

    s_tmpLine = "\n";  
    fputs(s_tmpLine,f_tmpFile);

    s_tmpLine = "\n";  
    fputs(s_tmpLine,f_tmpFile);

    s_tmpLine = "+++ CPU +++" + "\n";  
    fputs(s_tmpLine,f_tmpFile);

    s_tmpLine = "\n";  
    fputs(s_tmpLine,f_tmpFile);

    fclose(f_tmpFile);

    s_command = s_exe + " " + s_logPath + s_tmpFile + " >> " + s_logPath + s_sysFile;
    
    //DebugTN(__LINE__,"s_command",s_command);
    system(s_command);

    s_command = "prtdiag" + " >> " + s_logPath + s_tmpFile;

    //DebugTN(__LINE__,"s_command",s_command);
    system(s_command);
    
    //DebugTN(__LINE__,"read tmp file",s_tmpFile);
    // read the output-file to get the necessary information
    f_tmpFile = fopen(s_logPath + s_tmpFile,"r");
    
    while(!feof(f_tmpFile))
    {
      fgets(s_tmpLine,1000,f_tmpFile);
      
      //DebugTN(__LINE__,"read line from tmp file",s_tmpLine);
      
      //check if the line contains the information "Processor"
      if(strpos(s_tmpLine,"Processor",0) > 0)
      {
        //DebugTN(__LINE__,"start reading string buffer",s_tmpLine);
        b_startRead = 1;
      }
      
      // stop reading when reaching the next section
      if(strpos(s_tmpLine,"Memory",0) > 0)
      {
        //DebugTN(__LINE__,"stop reading string buffer",s_tmpLine);
        b_startRead = 0;
      }
      
      if(b_startRead == 1)
      {
        //DebugTN(__LINE__,"add line to string buffer",s_tmpLine);
        dynAppend(ds_stringBuffer, s_tmpLine);
      }
    }
    
    fclose(f_tmpFile);

    f_tmpFile = fopen(s_logPath + s_tmpFile,"w");
    
    // write the buffered information to the tmp file
    for(i_lineCount=1;i_lineCount<=dynlen(ds_stringBuffer);i_lineCount++)
    {
      s_tmpLine = ds_stringBuffer[i_lineCount];
      fputs(s_tmpLine,f_tmpFile);
    }
    fclose(f_tmpFile);
    
    s_command = s_exe + " " + s_logPath + s_tmpFile + " >> " + s_logPath + s_sysFile;

    //DebugTN(__LINE__,"s_command",s_command);
    system(s_command);

    // add the information how many CPUs are installed to the sys-info file
    s_command = "uname -X | grep NumCPU" + " >> " + s_logPath + s_sysFile;
    
    //DebugTN(__LINE__,"s_command",s_command);
    system(s_command);


    // get the memory-information
    f_tmpFile = fopen(s_logPath + s_tmpFile,"w");

    // add empty lines to the result file
    s_tmpLine = "\n";  
    fputs(s_tmpLine,f_tmpFile);

    s_tmpLine = "\n";  
    fputs(s_tmpLine,f_tmpFile);

    s_tmpLine = "+++ Memory +++" + "\n";  
    fputs(s_tmpLine,f_tmpFile);

    s_tmpLine = "\n";  
    fputs(s_tmpLine,f_tmpFile);

    fclose(f_tmpFile);

    s_command = s_exe + " " + s_logPath + s_tmpFile + " >> " + s_logPath + s_sysFile;
    
    //DebugTN(__LINE__,"s_command",s_command);
    system(s_command);

    s_command = "prtconf | grep Memory" + " >> " + s_logPath + s_sysFile;
    
    //DebugTN(__LINE__,"s_command",s_command);
    system(s_command);
  }
  return(1);
}

// function to create the inital report logfile including header information
int NFR_createReportLogFile()
{
  string s_line;
  string s_logFile;
  string s_separator;
  file f_logFile;
  int i;

  if(s_logSeparator != "TAB")
    s_separator = s_logSeparator;
  else
    s_separator = "\t";
  
  s_logFile = "ReportFile.log";
  f_logFile = fopen(s_logPath + s_logFile,"w");
  
  // define the header fitting the list of managers and the current settings
  s_line = "Time";

  for(i=1;i<=dynlen(ds_managers);i++)
  {
    if(ds_managers[i] != "Idle")
      s_line = s_line + s_separator + ds_managers[i] + " - %CPU" + s_separator + ds_managers[i] + " - Memory";
  }
  
  if(dynContains(ds_managers,"Idle"))
  {
    s_line = s_line + s_separator + "Idle - %CPU";
  }
    
  if(b_recordMsgInfo == 1)
  {
    s_line = s_line + s_separator + "VC/sec";
  }

  s_line = s_line + "\n";
    
  fputs(s_line,f_logFile);
  fclose(f_logFile);

  return(1);
}

int NFR_writeReportLogFile(time t_now, int i_VC)
{
  string s_exe, s_exeOptions;
  string s_command;
  string s_tmpFile;
  string s_logFile;
  string s_line;
  string s_separator;
  string s_timeCurrent;  

  file f_tmpFile;
  
  int i;

  s_logFile = "ReportFile.log";

  s_exe = "tail";
  s_exeOptions = "-1";

  if(s_logSeparator != "TAB")
    s_separator = s_logSeparator;
  else
    s_separator = "\t";
  
  s_tmpFile = "ReportFile_tmp.log";
  f_tmpFile = fopen(s_logPath + s_tmpFile,"w");

  // write the time to the beginning of the line
  s_timeCurrent = formatTime("%Y.%m.%d %H:%M:%S",t_now,".%03d");
  s_line = s_timeCurrent;
  
  for(i=1;i<=dynlen(ds_managers);i++)
  {
    if(ds_managers[i] != "Idle")
    {
      dyn_anytype da_processData;
    
      da_processData = m_reportFileData[ds_managers[i]];
      s_line = s_line + s_separator + da_processData[1] + s_separator + da_processData[2];
    }
  }

  if(dynContains(ds_managers,"Idle"))
  {
    string s_idleCPU;
    
    s_idleCPU = m_reportFileData["Idle"];
    s_line = s_line + s_separator + s_idleCPU;
  }
  
  if(b_recordMsgInfo == 1)
  {
    s_line = s_line + s_separator + i_VC;
  }

  s_line = s_line + "\n";
    
  fputs(s_line,f_tmpFile);
  fclose(f_tmpFile);

  // write the result to the logfile <process-name>_CPU.log
  s_command = s_exe + " " + s_exeOptions + " " + s_logPath + s_tmpFile + " >> " + s_logPath + s_logFile;

  //DebugTN(__LINE__,"s_command",s_command);
  system(s_command);

  return(1);
}


NFR_work_createDatapoint(string s_dp,string s_processInfoDP)
{
  int i_err;
  
  dpCopy("_mp_NFR_ProcessInfo",s_processInfoDP,i_err,-1);
}
