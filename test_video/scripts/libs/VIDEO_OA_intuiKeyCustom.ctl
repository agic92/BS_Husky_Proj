/*
  @author Christoph Schnedl

  Encryption key word
  $License: NOLICENSE
 
  User defined Functions for the PVSS_VIDEO Ctrl. Note that some
  functions are mandatory and must not be deleted.
 
  HISTORY:
  2008.07.14  base version                        cschnedl
*/
//----------------------------------------------------------------

#uses "VIDEO_OA_intuiKeyProduct.ctl"

const string DebugPraefix = "VIDEO_OA_KBD: ";

// Configuration Settings
// setings can be modified in init() below
string CONF_COMPORT;
string CONF_COMSETTINGS;
int    CONF_TIMESMOOTHING;
int    CONF_CTDUR;
int    CONF_CTPERIOD;
int    CONF_CAMERA_DIGITS;

// DPE names, should not be modified
const string WKST_ACTIVECAM = "activeCam";
const string WKST_ACTIVEMON = "activeMon";
const string WKST_MONITORFIELD = "keyboard.monitorField";
const string WKST_KEYS = "keyboard.keys";
const string WKST_CONTROLLER_STATUS = "keyboard.controller.status";
const string WKST_CONTROLLER_CONNECT = "keyboard.controller.connect";
const string WKST_CONTROLLER_WATCHDOG = "keyboard.controller.watchdog";
const string WKST_SERIALPORT_WINDOWS = "keyboard.serialPort.windows";
const string WKST_SERIALPORT_LINUX = "keyboard.serialPort.linux";

const string CAM_COMMAND = ".object.command.request";

const string MON_COM_REQUEST = ".object.command.request";
const string MON_COM_RESPONSE = ".object.command.response";
const string MON_COM_STATE = ".object.device.state";

// for WinCC OA Video functions
string TEXT_CAMERA;        // text for camera selection	
string TEXT_MONITOR;       // text for monitor selection	
string TEXT_SHOT;          // text for preset selection	
string TEXT_INVALID_CAM;   // text for unknown camera 
string TEXT_INVALID_MON;   // text for unknown monitor
string TEXT_INACTIVE_MON;  // text for inactive monitor
string TEXT_CAM_NAME;      // text for the camera name on StatusDisplay
string TEXT_MON_NAME;      // text for the monitor name on StatusDisplay



// for application functions
// user defined function step 1:
string TEXT_GROUP; // text for group selection
string TEXT_SEQ; // text for sequence selection
string TEXT_MONITOR_GRID;  // text for monitor grid selection
string TEXT_MONITOR_CLEAR; // text for monitor grid clear

int m_workstationID=-1;
int m_activeCamID=-1;
int m_activeMonIdx=-1;
int m_currentShotPosition=-1;
time m_lastTimeShot;
time m_lastActiveTime;
time m_watchDogTime;

mapping g_m_mutex1, g_m_mutex2, g_m_mutex3;

/*
  Main init function, that needs to be called when starting the UI or CTRL
  manager
*/
VIDEO_OA_KBD_init()
{
  //Configuration Settings
  
  string sUserPortWIN32;
  string sUserPortLINUX;
  string sDefaultPortWIN32="COM1";
  string sDefaultPortLINUX="/dev/ttyS0";
  
  // get our workstationID
  m_workstationID = myManNum();
    
  // get serial port settings  
  dpGet(VIDEO_OA_KBD_getWorkstation(m_workstationID)+"." + WKST_SERIALPORT_WINDOWS, sUserPortWIN32,
        VIDEO_OA_KBD_getWorkstation(m_workstationID)+"." + WKST_SERIALPORT_LINUX, sUserPortLINUX);
  
  if(_WIN32)     // Windows serial port settings
  { 
   CONF_COMPORT = (sUserPortWIN32=="") ? sDefaultPortWIN32 : sUserPortWIN32 ;
  }
  else if (_UNIX)// Linux serial port settings 
   CONF_COMPORT = (sUserPortLINUX=="") ? sDefaultPortLINUX : sUserPortLINUX ;
  
  else // unkown operating system
    CONF_COMPORT = ""; 
  
  
  CONF_COMSETTINGS = "19200,n,8,1";
  CONF_TIMESMOOTHING = 250;
  CONF_CTDUR = 0;
  CONF_CTPERIOD = 0;
  CONF_CAMERA_DIGITS = 5;
  
  VIDEO_OA_KBD_debugWork(VIDEO_OA_KBD_getWorkstation(m_workstationID)+" keyboard start parameter Port: "+CONF_COMPORT+" Settings: "+CONF_COMSETTINGS);
  
  
  // for PVSS Video functions
  TEXT_CAMERA = VIDEO_OA_KBD_getSaveCatStr("voa_keyboard", "prefixCam");
  TEXT_MONITOR = VIDEO_OA_KBD_getSaveCatStr("voa_keyboard", "prefixMon");  
  TEXT_SHOT = VIDEO_OA_KBD_getSaveCatStr("voa_keyboard", "prefixPos");
  TEXT_INVALID_CAM = VIDEO_OA_KBD_getSaveCatStr("voa_keyboard", "errInvCam");
  TEXT_INVALID_MON = VIDEO_OA_KBD_getSaveCatStr("voa_keyboard", "errInvMon");
  TEXT_INACTIVE_MON = VIDEO_OA_KBD_getSaveCatStr("voa_keyboard", "errInactiveMon");
  TEXT_CAM_NAME = VIDEO_OA_KBD_getSaveCatStr("voa_keyboard", "nameCamera");
  TEXT_MON_NAME = VIDEO_OA_KBD_getSaveCatStr("voa_keyboard", "nameMonitor");
  
  // for custom application functions
  // user defined function step 2:
  
  // text for group selection
  TEXT_GROUP = VIDEO_OA_KBD_getSaveCatStr("voa_keyboard_custom", "prefixGrp");
  // text for sequence selection
  //TEXT_SEQ = VIDEO_OA_KBD_getSaveCatStr("video_custom", "prefixSeq");
  // text for monitor grid selection
  TEXT_MONITOR_GRID = VIDEO_OA_KBD_getSaveCatStr("voa_keyboard_custom", "prefixMonitorGrid");
  

  // init the keyboard device
  VIDEO_OA_KBD_initKeyboard();
}
//----------------------------------------------------------------

 
 
/*
  function to get and save message catalog texts
  @param cat: message catalog
  @param msgKey: key to search for
  @return string value for the given key
*/
string VIDEO_OA_KBD_getSaveCatStr(string cat, string msgKey)
{
  string ret;
  
  ret = getCatStr(cat, msgKey);
  dyn_errClass err = getLastError();
  if (dynlen(err) > 0)
  {
    DebugN("FEHLER VIDEO_OA_KBD_getSaveCatStr",cat,msgKey);
    throwError(err);
    return "NODEF_TXT";
  }
  return ret;
}
//----------------------------------------------------------------



/*
  callback method for number inputs (confirmed with enter)
  this function is mandatory as it's required by the main ctrl
  @param numberEntered: 
          the number entered at the keyboard. The number
          is sent, when the user presses the "ENTER"-Button.
  @param inputMode: 
          the inputmode to decide, which number was entered. 
          (eg. IKEY_INPUTMODE_CAMERA, IKEY_INPUTMODE_MONITOR or 
          IKEY_INPUTMODE_USER for user defined input modes.
  @param userPrefix:
          the prefix text displayed while entered the number
          you should use this prefix to compare between
          your user defined input modes
*/
VIDEO_OA_KBD_numberEnteredCB(int numberEntered, int inputMode, string userPrefix) synchronized(g_m_mutex2)
{
  VIDEO_OA_KBD_debugExtend("=============> numberEnteredCB(" + numberEntered + ", " + inputMode + ", \"" + userPrefix + "\")");
  
  if (numberEntered == 0) // skip when 0
    return;
  else
    intuiKey_clearDisplay(IKEY_STATUS_DISPLAY);
  
  intuiKey_setInputMode(IKEY_INPUTMODE_WAITING, "", 0); // ignore number inputs while processing

  switch(inputMode)
  {
    case IKEY_INPUTMODE_CAMERA:
      VIDEO_OA_KBD_camSelected(numberEntered);
      break;
    case IKEY_INPUTMODE_MONITOR:
      VIDEO_OA_KBD_monitorSelected(numberEntered);
      break;
    case IKEY_INPUTMODE_USER:
      if (userPrefix == TEXT_SHOT)
        VIDEO_OA_KBD_shotSelected(numberEntered);
      
      // application functions
      // user defined function step 3:
      else if (userPrefix == TEXT_GROUP)
        VIDEO_OA_KBD_groupSelected(numberEntered);
      //else if (userPrefix == TEXT_SEQ)
      //  VIDEO_OA_KBD_sequenceSelected(numberEntered);
      else if (userPrefix == TEXT_MONITOR_GRID)
        VIDEO_OA_KBD_monitorGridSelected(numberEntered);
            
      // Display Monitor + Kamera again      
      VIDEO_OA_KBD_updateStatusDisplay(); 
      break;
  }
  intuiKey_setInputMode(IKEY_INPUTMODE_NONE, "", 5);
 
}
//----------------------------------------------------------------



/*
  this function refreshes the status display (mon/cam)
  this function is mandatory as it's required by the main ctrl
*/
VIDEO_OA_KBD_updateStatusDisplay()
{
  VIDEO_OA_KBD_debugExtend("=============> updateStatusDisplay()");
  int x1, x2;
  
  if (m_activeMonIdx < 10)
    x1 = 5;
  else if (m_activeMonIdx < 100)
    x1 = 4;
  else if (m_activeMonIdx < 1000)
    x1 = 3;
  else
    x1 = 2;
  
  if (m_activeCamID < 10)
    x2= 15;
  else if (m_activeCamID < 100)
    x2= 14;
  else if (m_activeCamID < 1000)
    x2= 13;
  else
    x2= 12;
  
  intuiKey_clearDisplay(IKEY_STATUS_DISPLAY);
  
  VIDEO_OA_KBD_setStatusText( false, false, 3, 1, TEXT_MON_NAME);
  VIDEO_OA_KBD_setStatusText( false, false, 13, 1, TEXT_CAM_NAME);
  VIDEO_OA_KBD_setStatusText( true, false, x1, 2, "" + m_activeMonIdx);
  VIDEO_OA_KBD_setStatusText( true, false, x2,2, "" + m_activeCamID);
  
  intuiKey_setInputMode(IKEY_INPUTMODE_NONE, "", 5); 
}
//----------------------------------------------------------------



/*
  this function refreshes the softkey display (softkey descriptions)
  this function is mandatory as t's required by the main ctrl
*/
VIDEO_OA_KBD_updateSoftKeyDisplay()
{
  VIDEO_OA_KBD_debugExtend("=============> updateSoftKeyDisplay()");
 	intuiKey_clearDisplay(IKEY_SOFTKEY_DISPLAY);
  	
  VIDEO_OA_KBD_setSoftKeyText(1, "Schließen");
        
  VIDEO_OA_KBD_setSoftKeyText(2, "Szenario", 1);
  VIDEO_OA_KBD_setSoftKeyText(2, "laden", 2);

  //VIDEO_OA_KBD_setSoftKeyText(3, "Gruppe", 1);
  //VIDEO_OA_KBD_setSoftKeyText(3, "vor", 2);
        
  VIDEO_OA_KBD_setSoftKeyText(4, "Grid", 1);
  VIDEO_OA_KBD_setSoftKeyText(4, "ändern", 2);
        
  VIDEO_OA_KBD_setSoftKeyText(11, "Monitor", 1);
  VIDEO_OA_KBD_setSoftKeyText(11, "löschen", 2);
        
  //VIDEO_OA_KBD_setSoftKeyText(5, "Sequenzer", 1);
  //VIDEO_OA_KBD_setSoftKeyText(5, "laden", 2);
        
  //VIDEO_OA_KBD_setSoftKeyText(6, "Sequenzer", 1);
  //VIDEO_OA_KBD_setSoftKeyText(6, "halten", 2);
        
  //VIDEO_OA_KBD_setSoftKeyText(7, "Sequenzer", 1);
  //VIDEO_OA_KBD_setSoftKeyText(7, "zurück", 2);        
        
  //VIDEO_OA_KBD_setSoftKeyText(10, "Gruppe", 1);
  //VIDEO_OA_KBD_setSoftKeyText(10, "zurück", 2);
        
  //VIDEO_OA_KBD_setSoftKeyText(12, "Sequenzer", 1);
  //VIDEO_OA_KBD_setSoftKeyText(12, "Geschw.", 2);
        
  //VIDEO_OA_KBD_setSoftKeyText(13, "Sequenzer", 1);
  //VIDEO_OA_KBD_setSoftKeyText(13, "starten", 2);
        
  //VIDEO_OA_KBD_setSoftKeyText(14, "Sequenzer", 1);
  //VIDEO_OA_KBD_setSoftKeyText(14, "vor", 2);
}
//----------------------------------------------------------------



/*
  VIDEO_OA_KBD_checkTimer
  This function is called every 3 secons by the ctrlExt 
  to check if timers are expired (when in terminal mode!)
  this function is mandatory as t's required by the main ctrl
*/
VIDEO_OA_KBD_checkTimer()
{
  long nowPeriod = period(getCurrentTime());
  
  // timer wenn anderer Monitor ausgewählt ist, das Bedienpult aber 
  // 30 Sekunden lang nicht bedient wurde.
  if (((nowPeriod - period(VIDEO_OA_KBD_getLastActiveTime())) >= 30) && (m_activeMonIdx > 1) && (VIDEO_OA_KBD_currentInputMode() == IKEY_INPUTMODE_NONE))
  {
    VIDEO_OA_KBD_monitorSelected(1);
  }
  
  // timer für watchdog mechanismus
  if ((nowPeriod - period(m_watchDogTime)) >= 30)
  {
    dpSet(VIDEO_OA_KBD_getWorkstation(m_workstationID) + "." + WKST_CONTROLLER_WATCHDOG, 0);
    m_watchDogTime = getCurrentTime();
  }
}
//----------------------------------------------------------------



/*
  this function is called by VIDEO_OA_KBD_numberEnteredCB, when the user 
  has entered a new camera ID (IKEY_INPUTMODE_CAMERA)
  @param camId: the new selected camera. 
*/
VIDEO_OA_KBD_camSelected(int camId, bool fromCB = false)
{
  VIDEO_OA_KBD_debugExtend("=============> camSelected(" + camId + ")");
  
  if (m_activeCamID == camId)
  {
    if(!fromCB)  // display was cleared after number input
    {    
      VIDEO_OA_KBD_updateStatusDisplay();
    }
    return;
  }
    
  if (dpExists(VIDEO_OA_KBD_getCamera(camId)))
  {
    // request cam for display
    if (m_activeMonIdx == 1)
    {
      // request the control and display the new status
      VIDEO_OA_KBD_requestCamControl(camId);
      VIDEO_OA_KBD_updateStatusDisplay();

      if(!fromCB)  // avoid loop
      {
        // requesting cam for local ewo
        dpSet(VIDEO_OA_KBD_getWorkstation(m_workstationID) + "." + WKST_ACTIVECAM, camId,
              VIDEO_OA_KBD_getWorkstation(m_workstationID) + "." + WKST_ACTIVECAM + ":_original.._userbyte1", 2);  
      }
    }
    else
    {
      if(!fromCB)  // callback has only effect on local monitor
      {
        // requesting cam for display monitor
        VIDEO_OA_KBD_requestCamForMonitor(camId);
      }
    }
  }
  else
  {
    if(camId == 0)
    {
      m_activeCamID = camId;
      VIDEO_OA_KBD_updateStatusDisplay();
    }    
    else if(!fromCB)    
    {
      VIDEO_OA_KBD_debugWork("Kamera " + camId + " does not exist");
      VIDEO_OA_KBD_setStatusText( false, false, 2, 2, TEXT_INVALID_CAM);
      delay(1);
      VIDEO_OA_KBD_updateStatusDisplay();
    }
  }
}
//----------------------------------------------------------------#



/*
  this function is called by VIDEO_OA_KBD_numberEnteredCB, when the user
  has entered a new monitor ID (IKEY_INPUTMODE_MONITOR)
  @param monId: the new selected monitor.
*/
VIDEO_OA_KBD_monitorSelected(int monId, bool fromCB = false)
{
  VIDEO_OA_KBD_debugExtend("=============> monitorSelected(" + monId + ", " + fromCB + ")");
  string displayState;
  bool ret = VIDEO_OA_KBD_isMonitorIndexDefined(monId, displayState);
  VIDEO_OA_KBD_debugExtend("=============> monitorState(" + monId + ", " + ret  + ", " + displayState + ")");
 
  // check if a new monitor is selected
  if(monId == m_activeMonIdx)
  {
    if(!fromCB)  // display was cleared after number input
    {    
      VIDEO_OA_KBD_updateStatusDisplay();
    }
    return;
  }
  
  // check selected monitor
  if (monId == 0)
  {
    // clear cam and mon
    m_activeCamID = 0;
  }
  else if (monId == 1) // local monitor
  {
    // get cam currently displayed on local monitor
    dpGet(VIDEO_OA_KBD_getWorkstation(m_workstationID) + "." + WKST_ACTIVECAM, m_activeCamID);
  }
  else if (ret) // monitor 2-xx
  {
    if(VIDEO_OA_KBD_isDisplayStateOK(displayState))
    {    
      // get cam currently displayed on display monitor      
      m_activeCamID = VIDEO_OA_KBD_parseCamFromDisplayState(displayState, VIDEO_OA_KBD_getVideoDialog(monId));
    }
    else
    {
      VIDEO_OA_KBD_debugWork("Monitor " + monId + " is not active!");
      if(!fromCB)
      {
        VIDEO_OA_KBD_setStatusText( false, false, 2, 2, TEXT_INACTIVE_MON);
        delay(1);
      }
      VIDEO_OA_KBD_updateStatusDisplay();
      return;
      }
  }
  else // invalid monitor nr.
  {
    VIDEO_OA_KBD_debugWork("Monitor " + monId + " does not exist!");
    if(!fromCB)
    {
      VIDEO_OA_KBD_setStatusText( false, false, 2, 2, TEXT_INVALID_MON);
      delay(1);
    }
    VIDEO_OA_KBD_updateStatusDisplay();
    return;
  }

  // set the new active monitor in our local varibale
  m_activeMonIdx = monId;
 
  // TODO FOXME
  VIDEO_OA_KBD_setLastActiveTime(); // ??
  
  // request cam control  
  if(m_activeCamID != 0)  
  {
    VIDEO_OA_KBD_requestCamControl(m_activeCamID);
  }
  else
  {
    VIDEO_OA_KBD_releaseCamControl();
  }

  // update the status display
  VIDEO_OA_KBD_updateStatusDisplay();  
  
  // if this is the call directly from the device, we set the datapoint now
  if (!fromCB)
  {
      VIDEO_OA_KBD_setActiveMon(monId);  
  }
}
//----------------------------------------------------------------



/*
  this function is called bye VIDEO_OA_KBD_numberEnteredCB, when the user
  has entered a new shot position (IKEY_INPUTMODE_USER)
  @param shotId: the new selected camera position (shot)
*/
VIDEO_OA_KBD_shotSelected(int shotId)
{
  int minPos = 1;
  int maxPos = 20;
  
  if (shotId < minPos)
    shotId = minPos;
  if (shotId > maxPos)
    shotId = maxPos;
  
  VIDEO_OA_KBD_debugExtend("=============> shotSelected(" + shotId + ")");
  dpSet(VIDEO_OA_KBD_getCamera(m_activeCamID) + CAM_COMMAND, "PTZ:cmd=move;presetno=" + shotId + ";");

  m_lastTimeShot = getCurrentTime();
  m_currentShotPosition = shotId;  
}
//----------------------------------------------------------------



/*
  this function is called, when the user pressed one of
  the Iris Keys (+ or -). 
  @param direction: 
        +1 when upper iris key pressed
        -1 when lower iris key pressed
  @param pressed
        true if key was pressed
        false if key was released
*/
VIDEO_OA_KBD_handleIris(int direction, bool pressed)
{
  // Zeitvergleich, innerhalb 30 sec von letzter Shot Taste - n�chste pos, ansonsten normale iris
  
  int diffsec = period(getCurrentTime()) - period(m_lastTimeShot);
  if (diffsec < 30)
  {
    if (pressed)
      VIDEO_OA_KBD_shotSelected(m_currentShotPosition + direction);
  }
  else if (pressed)
  {
    int speed = 100 * direction;
    dpSet(VIDEO_OA_KBD_getCamera(m_activeCamID) + CAM_COMMAND, "PTZ:cmd=iris;start=" + speed + ";");
  }
  else
  {
     dpSet(VIDEO_OA_KBD_getCamera(m_activeCamID) + CAM_COMMAND, "PTZ:cmd=iris;stop");
  }

  VIDEO_OA_KBD_setLastActiveTime();

}
//----------------------------------------------------------------



/*
  this function is called, when the user pressed one of the 
  focus keys (+ or -)
  @param direction: 
        +1 when upper iris key pressed
        -1 when lower iris key pressed
  @param pressed
        true if key was pressed
        false if key was released
*/
VIDEO_OA_KBD_handleFocus(int direction, bool pressed)
{
  if (pressed)
  {
    int speed = 100 * direction;
    dpSet(VIDEO_OA_KBD_getCamera(m_activeCamID) + CAM_COMMAND, "PTZ:cmd=focus;start=" + speed + ";");
  }
  else
  {
    dpSet(VIDEO_OA_KBD_getCamera(m_activeCamID) + CAM_COMMAND, "PTZ:cmd=focus;stop");
  }
  VIDEO_OA_KBD_setLastActiveTime();

}
//----------------------------------------------------------------



/*
  Called, when a key is pressed. 
  Note: number keys are not handled by this function 
  BE CAREFUL: this function is called twice for each keystroke
    the first time when pressed (pressed = true)
    the second time when released (pressed = false)
  this function is NOT mandatory
  @param keyCode: the keycode, eg. 0x8 for the upper right Softkey
  @param keyName: the keyname, eg "Softkey_1_R" for the upper right Softkey
  @param pressed: true if key was pressed, false if released.
*/
VIDEO_OA_KBD_customKeyPressed(int keyCode, string keyName, bool pressed)
{
  bool released = !pressed;
  
  switch (keyName)
  {
    // normaler Tastendruck
    case "Softkey_1_L":
      if (pressed) intuiKey_exitTerminalMode();
      break;

    // Iris und Focus Tasten
    case "Iris_A":
      VIDEO_OA_KBD_handleIris(+1, pressed);
      break;
    case "Iris_B":
      VIDEO_OA_KBD_handleIris(-1, pressed);
      break;
    case "Focus_A":
      VIDEO_OA_KBD_handleFocus(+1, pressed);
      break;
    case "Focus_B":
      VIDEO_OA_KBD_handleFocus(-1, pressed);
      break;

    
    // Monitor and Shot keys
    case "Monitor":
      if (pressed) intuiKey_setInputMode(IKEY_INPUTMODE_MONITOR, TEXT_MONITOR, 4);
      break;
    case "Shot":
      if(pressed) intuiKey_setInputMode(IKEY_INPUTMODE_USER, TEXT_SHOT, 2);
      break;
      
      
    // user defined:
    // user defined function step 4:
    case "Softkey_2_L": // Beschreibung "Szenario laden"
      if (pressed) intuiKey_setInputMode(IKEY_INPUTMODE_USER, TEXT_GROUP, 4);
      break;
    //case "Softkey_5_L": // Beschreibung "Sequenzer laden"
    //  if (pressed) intuiKey_setInputMode(IKEY_INPUTMODE_USER, TEXT_SEQ, 4);
    //  break;  
    case "Softkey_4_L": // Beschreibung "Monitor grid setzen"
      if (pressed) intuiKey_setInputMode(IKEY_INPUTMODE_USER, TEXT_MONITOR_GRID, 4);
      break;
    case "Softkey_4_R": // Beschreibung "Monitor löschen"
      if (pressed) VIDEO_OA_KBD_monitorClearSelected();
      break;
            
  }
    
}
//----------------------------------------------------------------



/*
  this function is called by VIDEO_OA_KBD_numberEnteredCB, when the user
  has entered a new group ID (IKEY_INPUTMODE_USER)
  @param groupId: the new selected group
*/
VIDEO_OA_KBD_groupSelected(int groupId)
{
  // user defined function step 5:
  VIDEO_OA_KBD_debugExtend("=============> groupSelected(" + groupId + ")");
  
  dpSet(VIDEO_OA_KBD_getWorkstation()+".custom.actGroup",groupId);
}
//----------------------------------------------------------------



/*
  this function is called by VIDEO_OA_KBD_numberEnteredCB, when the user
  has entered a new group ID (IKEY_INPUTMODE_USER)
  @param groupId: the new selected sequence
*/
VIDEO_OA_KBD_sequenceSelected(int groupId)
{
  // user defined function step 5:
  VIDEO_OA_KBD_debugExtend("=============> sequenceSelected(" + groupId + ")");
  
  dpSet(VIDEO_OA_KBD_getWorkstation()+".custom.actSequence",groupId);
}
//----------------------------------------------------------------



/*
  this function is called by VIDEO_OA_KBD_numberEnteredCB, when the user
  has entered a new grid Count (IKEY_INPUTMODE_USER)
  @param gridCount: the new selected group
*/
VIDEO_OA_KBD_monitorGridSelected(int gridCount)
{
  // user defined function step 5:
  VIDEO_OA_KBD_debugExtend("=============> monitorGridSelected(" + gridCount + ")");

  string state;
  bool bExists = VIDEO_OA_KBD_isMonitorIndexDefined(m_activeMonIdx, state);
  if(m_activeMonIdx > 1 && bExists)
  {
    dpSet(VIDEO_OA_KBD_getMonitor(m_activeMonIdx) + MON_COM_REQUEST, "cmd=setgrid;dialogcount=" + gridCount + ";clearunused=1;");
  }
  else
  {
    VIDEO_OA_KBD_setStatusText( false, false, 2, 2, TEXT_INVALID_MON);
    delay(1);
    VIDEO_OA_KBD_updateStatusDisplay();
  }
}



/*
  this function is called by VIDEO_OA_KBD_numberEnteredCB, when the user
  has entered a video dialog to be cleared (IKEY_INPUTMODE_USER)
  @param groupId: the new selected group
*/
VIDEO_OA_KBD_monitorClearSelected()
{
  // user defined function step 5:
  VIDEO_OA_KBD_debugExtend("=============> monitorClearSelected(" + m_activeMonIdx + ")");
  
  string state;
  bool bExists = VIDEO_OA_KBD_isMonitorIndexDefined(m_activeMonIdx, state);
  if(m_activeMonIdx > 1 && bExists)
  {
    dpSet(VIDEO_OA_KBD_getMonitor(m_activeMonIdx) + MON_COM_REQUEST, "cmd=clear;videodlg=" +  VIDEO_OA_KBD_getVideoDialog(m_activeMonIdx) + ";");
  }
  else
  {
    VIDEO_OA_KBD_setStatusText( false, false, 2, 2, TEXT_INVALID_MON);
    delay(1);
    VIDEO_OA_KBD_updateStatusDisplay();
  }
}
