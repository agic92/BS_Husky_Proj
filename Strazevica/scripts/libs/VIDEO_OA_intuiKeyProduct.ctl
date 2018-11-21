/*
  @author Christoph Schnedl

  Encryption key word
  $License: NOLICENSE
 
  This control handles requests between the Keyboard and the 
  IntuiKey Ctrl Extension DLL. This is the main library and
  should be running on all IntuiKey Workstations
 
  HISTORY:
  2008.07.14  base version                        cschnedl
*/
//----------------------------------------------------------------

#uses "CtrlIntuiKey"


// global (but secret) variables. other global variables are
// defined in the intuiKeyWorkstation.ctl ctrl script.
bool m_firstInitDone = false;
string m_lastCamStateConnect;
string m_lastMonConnect;
int m_inputMode;

dyn_string m_asMonitorField;

/*
  Debug function, should only be called from other debug functions
  @param msg: the debug msg
  @param dbgFlag: the message will be written, when the dbgFlag
                  is set (use -dbg <flagname>)
*/
VIDEO_OA_KBD_debug(string msg, string dbgFlag)
{
  if (isDbgFlag(dbgFlag))
    DebugTN(DebugPraefix + msg);
}
//----------------------------------------------------------------



/*
  Debug function if dbg Flag "V_work" is set.
  param msg: the debug msg
*/
VIDEO_OA_KBD_debugWork(string msg)
{
  VIDEO_OA_KBD_debug("DBG: " + msg, "V_work");
}
//----------------------------------------------------------------



/*
  Debug function if dbg Flag "V_extend" is set.
  @param msg: the debug msg
*/
VIDEO_OA_KBD_debugExtend(string msg)
{
  VIDEO_OA_KBD_debug("DBGEXT: " + msg, "V_extend");
}
//----------------------------------------------------------------



/*
  Debug function if an error occurs
  @param prio: error priority
  @param type: error type
  @param error: errorcode id
*/
VIDEO_OA_KBD_debugError(int prio, int type, int error)
{
  errClass err = makeError("voa_keyboard", prio, type, error);
  throwError(err);
}
//----------------------------------------------------------------



/*
  Initialises the keyboard. If an error occurs, it will retry
  _forever_ until the connection could be established.
*/
VIDEO_OA_KBD_initKeyboard()
{

  VIDEO_OA_KBD_debugExtend("=============> initKeyboard()");
 
  int DbgNumber;  
  DbgNumber = registerDbgFlag("V_work");     // use -dbg work for more debug informations
  DbgNumber = registerDbgFlag("V_extend");   // use -dbg extend for more debug informations
                                             // while searching an error
  
  // inits Keyboard
  bool kbdFound = intuiKey_initKeyboard(CONF_COMPORT, CONF_COMSETTINGS, TEXT_CAMERA, CONF_CAMERA_DIGITS);
  if (!kbdFound)
  {
    VIDEO_OA_KBD_debugError(PRIO_SEVERE, ERR_PARAM, 1);
    return;
  } 
  else
  {
    intuiKey_setSmoothing(CONF_TIMESMOOTHING, CONF_CTDUR, CONF_CTPERIOD);
    VIDEO_OA_KBD_debugWork(DebugPraefix + "COM Port offen!");
    
    VIDEO_OA_KBD_setActiveMon(1);
  }  
}
//----------------------------------------------------------------



/*
  Callback method for key press input. the function VIDEO_OA_KBD_customKeyPressed
  for user defined behaviour will be called at the end of this function
  This function sets the dpe's for the pressed keys
  @param keyPressed: the keycode of the pressed key
  @param pressed: true if pressed, false if released
*/
VIDEO_OA_KBD_keyPressedCB(int keyPressed, bool pressed)
{
  VIDEO_OA_KBD_debugExtend("=============> keyPressedCB(" + keyPressed + ", " + pressed + ")");

  string key = "";
  
  switch(keyPressed)
  {
    case 0x1:
      key = "Softkey_1_L";
      break;
    case 0x2:
      key = "Softkey_2_L";
      break;
    case 0x3:
      key = "Softkey_3_L";
      break;
    case 0x4:
      key = "Softkey_4_L";
      break;
    case 0x5:
      key = "Softkey_5_L";
      break;
    case 0x6:
      key = "Softkey_6_L";
      break;
    case 0x7:
      key = "Softkey_7_L";
      break;
    case 0x8:
      key = "Softkey_1_R";
      break;
    case 0x9:
      key = "Softkey_2_R";
      break;
    case 0xA:
      key = "Softkey_3_R";
      break;
    case 0xB:
      key = "Softkey_4_R";
      break;
    case 0xC:
      key = "Softkey_5_R";
      break;
    case 0xD:
      key = "Softkey_6_R";
      break;
    case 0xE:
      key = "Softkey_7_R";
      break;
    case 0x20:
      key = "Monitor";
      break;
    case 0x21:
      key = "Product";
      break;
    case 0x22:
      key = "Clear";
      break;
    case 0x23:
      key = "Iris_A";
      break;
    case 0x24:
      key = "Iris_B";
      break;
    case 0x25:
      key = "Ack";
      break;
    case 0x27:
      key = "Shot";
      break;
    case 0x28:
      key = "Focus_A";
      break;
    case 0x29:
      key = "Focus_B";
      break;
    case 0x80:
      key = "Special_1";
      break;
    case 0x81:
      key = "Special_2";
      break;
    case 0x82:
      key = "Special_3";
      break;
    default:
      VIDEO_OA_KBD_debugWork("Unknown Key: " + keyPressed);
      VIDEO_OA_KBD_setStatusText( false, false, 1, 4, "Unknown: " + keyPressed);
      return;
  }

  dpSet(VIDEO_OA_KBD_getWorkstation(m_workstationID) + "." + WKST_KEYS + "." + key, pressed);
  
  if (isFunctionDefined("VIDEO_OA_KBD_customKeyPressed"))
    VIDEO_OA_KBD_customKeyPressed(keyPressed, key, pressed);
  	
}
//----------------------------------------------------------------



/*
  called when the IntuiKey Keyboard has changed its status mode
  this function refreshes the softkey display when the keyboard
  has entered terminal mode
  @param newMode: the new status mode (see documentation)
*/
VIDEO_OA_KBD_statusChangedCB(int newMode) synchronized(g_m_mutex1)
{
  VIDEO_OA_KBD_debugExtend("=============> statusChangedCB(" + newMode + ")");
  dpSet(VIDEO_OA_KBD_getWorkstation(m_workstationID) + "." + WKST_CONTROLLER_STATUS, newMode);
  bool connect = false;
  
  if (/*(newMode == IKEY_STATUS_WAITING_FOR_KEYBOARD) || */(newMode == IKEY_STATUS_TERMINAL_MODE_ON)) // initialisiert
  {
    connect = true;
        
    // Beim ersten mal kein dpDisconnect    
    if (m_firstInitDone) 
    {
      dpDisconnect("VIDEO_OA_KBD_updateActiveCamCB", VIDEO_OA_KBD_getWorkstation(m_workstationID) + "." + WKST_ACTIVECAM);
      dpDisconnect("VIDEO_OA_KBD_updateActiveMonCB", VIDEO_OA_KBD_getWorkstation(m_workstationID) + "." + WKST_ACTIVEMON);
      dpDisconnect("VIDEO_OA_KBD_updateMonitorFieldCB", VIDEO_OA_KBD_getWorkstation(m_workstationID) + "." + WKST_MONITORFIELD);

      // init the workstation values      
      m_activeCamID=-1;
      m_activeMonIdx=-1;

    }
    else
    {
      m_firstInitDone = true;
    }
    
    VIDEO_OA_KBD_debug("connecting....", "");
    
    dpConnect("VIDEO_OA_KBD_updateActiveCamCB", true, VIDEO_OA_KBD_getWorkstation(m_workstationID) + "." + WKST_ACTIVECAM);
    dpConnect("VIDEO_OA_KBD_updateActiveMonCB", true, VIDEO_OA_KBD_getWorkstation(m_workstationID) + "." + WKST_ACTIVEMON);
    dpConnect("VIDEO_OA_KBD_updateMonitorFieldCB", true, VIDEO_OA_KBD_getWorkstation(m_workstationID) + "." + WKST_MONITORFIELD);
        
  }
  
  // aktualisiere status display, wenn initialisiert
  if (newMode == IKEY_STATUS_TERMINAL_MODE_ON) // initialisiert
    VIDEO_OA_KBD_updateSoftKeyDisplay();
  
  // aktuellen Zustand auf das DPE schreiben
  dpSet(VIDEO_OA_KBD_getWorkstation(m_workstationID) + "." + WKST_CONTROLLER_CONNECT, connect);
}
//----------------------------------------------------------------



/*
  Fired when the monitor to which we are connected, changed it's 
  camera. updates status display and requests control for the new
  selected camera
  @param dp: the dp of the monitor command
  @param cmd: the command for the monitor. "cmd=show;source=<cameraid>"
*/
VIDEO_OA_KBD_monitorCmdResponseCB(string dp, string cmd)
{
  VIDEO_OA_KBD_debugExtend("=============> monitorCmdResponseCB(" + dp + ", " + cmd + ")");
  int newCam = VIDEO_OA_KBD_parseCamFromCmd(cmd);
  
  // set new active cam
  if(newCam != 0)
  {
    VIDEO_OA_KBD_requestCamControl(newCam);
  }
  else
  {
    VIDEO_OA_KBD_releaseCamControl();
  }
  
  // refresh status display
  VIDEO_OA_KBD_updateStatusDisplay();
}
//----------------------------------------------------------------



/*
  sets the member variable for active monitor idx
  @param monId: the monitor id
*/
VIDEO_OA_KBD_setActiveMon(int monIdx)
{
  m_activeMonIdx = monIdx;
  dpSet(VIDEO_OA_KBD_getWorkstation(m_workstationID) + "." + WKST_ACTIVEMON, monIdx);
}
//----------------------------------------------------------------



/*
  callback method for joystick movements.
  this method is optional and will be called, when no camera is selected
*/
VIDEO_OA_KBD_joystickMovedCB(float x, float y, float z) synchronized(g_m_mutex3)
{
  VIDEO_OA_KBD_debugWork("JOYSTICKMOVEDCB SHOULD NOT BE CALLED");
}
//----------------------------------------------------------------



/*
  sends a request to control a camera
  @param camID: the cam id for the camera we want to control
*/
VIDEO_OA_KBD_requestCamControl(int camID)
{
  VIDEO_OA_KBD_debugExtend("=============> requestCamControl(" + camID + ")");
  m_activeCamID = camID;
  intuiKey_setActiveCam(camID, true); // true : setDPdirect (ctrl ext setzt joystick cmd selber)
  intuiKey_setCamControl(true);
  return;
}
//----------------------------------------------------------------



/*
  releases the control of a camera
  @param camID: the cam id for the camera we want to control
*/
VIDEO_OA_KBD_releaseCamControl()
{
  VIDEO_OA_KBD_debugExtend("=============> releaseCamControl()");
  m_activeCamID = 0;
  intuiKey_setActiveCam(0, true); // true : setDPdirect (ctrl ext setzt joystick cmd selber)
  return;
}
//----------------------------------------------------------------



/*
  sends a request to display a cam on current selected monitor
  @param camId: the cam id
*/
VIDEO_OA_KBD_requestCamForMonitor(int camId)
{
  if (m_lastMonConnect != "")
  {
    dpDisconnect("VIDEO_OA_KBD_monitorCmdResponseCB", m_lastMonConnect);
  }

  if (m_activeMonIdx > 1)
  {
    string cmd = "cmd=show;source=" + VIDEO_OA_KBD_getCamera(camId) + ";videodlg=" + VIDEO_OA_KBD_getVideoDialog(m_activeMonIdx);

    m_lastMonConnect = VIDEO_OA_KBD_getMonitor(m_activeMonIdx) + MON_COM_RESPONSE;
    dpConnect("VIDEO_OA_KBD_monitorCmdResponseCB", false, m_lastMonConnect);
  
    dpSet(VIDEO_OA_KBD_getMonitor(m_activeMonIdx) + MON_COM_REQUEST, cmd);
  }
}
//----------------------------------------------------------------



/*
  callback method for changes on .activeCam @wkst (new cam selected)
  this function is called, when the activeCam of our workstation
  is modified (either by our script or outside)
  @param dp: the dp name. can be empty when set for other monitor
  @param newcamId: the new camera for our workstation
*/
VIDEO_OA_KBD_updateActiveCamCB(string dp, int newCamId)
{
  VIDEO_OA_KBD_debugExtend("=============> updateActiveCamCB(" + dp + ", " + newCamId + ")");
  VIDEO_OA_KBD_camSelected(newCamId, true);
  return;
}
//----------------------------------------------------------------




/*
  Callback function for changes on the active monitor dpe
  @param dp: the active camera dpe 
  @param newMonIdx: the new active monitor index
*/
VIDEO_OA_KBD_updateActiveMonCB(string dp, int newMonIdx)
{
  VIDEO_OA_KBD_debugExtend("=============> VIDEO_OA_KBD_updateActiveMonCB(" + dp + ", " + newMonIdx + ")");
  VIDEO_OA_KBD_monitorSelected(newMonIdx, true);
}
//----------------------------------------------------------------




/*
  Callback function for changes on monitor field configuration
  @param dp: the monitor field dpe 
  @param asMField: the new monitor field configuration
*/
VIDEO_OA_KBD_updateMonitorFieldCB(string dp, dyn_string asMField)
{
  VIDEO_OA_KBD_debugExtend("=============> VIDEO_OA_KBD_updateMonitorFieldCB(" + dp + ", " + asMField + ")");

  // store new monitor field configuration 
  m_asMonitorField = asMField;
}
//----------------------------------------------------------------



/*
  Returns the workstation dp prefix string for selected workstation
  eg: Workstation_0001
  @param wkst: the workstation nr. if -1, the current 
      workstation nr. will be used (using myManNum());
*/
string VIDEO_OA_KBD_getWorkstation(int wkst = -1)
{
  //VIDEO_OA_KBD_debugExtend("=============> getWorkstation(" + wkst + ")");
  int num;

  if (wkst == -1)
    num = myManNum();
  else
    num = wkst;  
  
  return "Workstation_" + VIDEO_OA_KBD_getFormattedNr(num);
}
//----------------------------------------------------------------



/*
  Returns the camera dp prefix string for selected camara
  @param nr: the camera nr.
*/
string VIDEO_OA_KBD_getCamera(int nr) 
{
  return "Camera_" + VIDEO_OA_KBD_getFormattedNr(nr, 5);
}
//----------------------------------------------------------------



/*
  VIDEO_OA_KBD_getMonitor
  Returns the monitor dp prefix string for selected monitor
  @param idx: the monitor idx
*/
string VIDEO_OA_KBD_getMonitor(int idx) 
{
  string monitorDp = "";
  
  // split the field entry to extract monitor and video dialog
  if(dynlen(m_asMonitorField) >= idx)
  {
    dyn_string fieldEntry = strsplit(m_asMonitorField[idx], "|");
    monitorDp = fieldEntry[1];
  }
  
  return monitorDp;
}
//----------------------------------------------------------------



/*
  VIDEO_OA_KBD_getVideoDialog
  Returns the videoDialog string for selected monitor
  @param idx: the monitor idx
*/
string VIDEO_OA_KBD_getVideoDialog(int idx) 
{
  string videoDialog = "VD1";
  
  // split the field entry to extract monitor and video dialog
  if(dynlen(m_asMonitorField) >= idx)
  {
    dyn_string fieldEntry = strsplit(m_asMonitorField[idx], "|");
    if(dynlen(fieldEntry) >= 2)
    {
      videoDialog = fieldEntry[2];
    }
  }
  
  return videoDialog;
}
//----------------------------------------------------------------



/*
  VIDEO_OA_KBD_getFormattedNr
  returns a string representing the number with preceding digits
  @param nr: the number we want as string
  @digits: the number of digits we want. default = 5 (00001)
*/
string VIDEO_OA_KBD_getFormattedNr(int nr, int digits = 5)
{
  string ret, format;
  sprintf(format, "%%0%dd", digits);
  sprintf(ret, format, nr);
  return ret;
}
//----------------------------------------------------------------



/*
  VIDEO_OA_KBD_setStatusText
  prints a text on the status display
  @param bBold:         text in bold
  @param bInverse:      text in inverse
  @param posX:          x position for text
  @param posY:          y position for text
  @param text:          text to be printed
*/
void VIDEO_OA_KBD_setStatusText(bool bBold, bool bInverse, int posX, int posY, string text)
{
  intuiKey_setText(IKEY_STATUS_DISPLAY, bBold, bInverse, posX, posY, VIDEO_OA_KBD_convertUtf8ToIso(text));
}
//----------------------------------------------------------------




/*
  VIDEO_OA_KBD_setSoftKeyText
  prints a text next to the associated softkey
  @param softkey: 
        the softkey nr. for which we want to print the description
        softkey 1-7 = left side, 8-14 = right side
  @param text:
        the text for the softkey
  @param line: 
        this parameter is optional and specifies the line number (1 or 2)
        if line = 0, the text will be printed centered over line 1 and 2
*/
void VIDEO_OA_KBD_setSoftKeyText(int softkey, string text, int line = 0)
{
  VIDEO_OA_KBD_debugExtend("=============> setSoftKeyText(" + softkey + ", " + text + ", " + line + ")");
  int col, row, top;

  const int skHeight = 35;
  const int topSpace = -1;
  const int lineHeight = 8;
  
  // convert text to ISO
  text = VIDEO_OA_KBD_convertUtf8ToIso(text);  
  
  if (softkey < 8) // linke Seite
  {
    col = 1;
  } 
  else // rechte Seite
  {
    col = (21 - strlen(text)) * 6;
    softkey -= 7;
  }
  
  if (line == 0)
    top = lineHeight + lineHeight/2;
  else
    top = line*lineHeight;
  
  row = skHeight*(softkey-1) + topSpace + top;
  VIDEO_OA_KBD_debugExtend("row for " + text + " is " + row);
  intuiKey_setText(IKEY_SOFTKEY_DISPLAY, false, false, col, row, text, true);

  // linux quickfix
  if(_UNIX)
    delay(0, 50);
}
//----------------------------------------------------------------



/*
  VIDEO_OA_KBD_isMonitorIndexDefined
  checks if the monitor is available for our workstation and 
  returns the camera dp name for the monitor (if found)
  @param iIndex: the monitor index 
  @param source: the camera name will be written here, if monitor is defined
  @param iManNum: our manager nr. default = own wkst.
*/
bool VIDEO_OA_KBD_isMonitorIndexDefined(unsigned iIndex,string &source)
{
 source="";

 if (iIndex==1) // local ewo 
 {
   source=VIDEO_OA_KBD_getCamera(m_activeCamID);
   return 1; 
 }
 else if(iIndex==0 ||
         dynlen(m_asMonitorField) < iIndex || 
         m_asMonitorField[iIndex]=="")
 {
   VIDEO_OA_KBD_debugWork("Selected Monitor " + iIndex + " not defined in monitorField configuration.");
   return 0; // not defined
 }
 else if (dpExists(VIDEO_OA_KBD_getMonitor(iIndex)+MON_COM_STATE))
 {
   dpGet(VIDEO_OA_KBD_getMonitor(iIndex)+MON_COM_STATE,source);
  
   return 1; // defined
 }
   
 else
   return 0; 
 
}
//----------------------------------------------------------------



/*
  VIDEO_OA_KBD_parseCamFromCmd
  returns the camera from a cmd string
  @para cmd: the cmd string, must be in format "cmd=show;source=<camname>"
*/
int VIDEO_OA_KBD_parseCamFromCmd(string cmd)
{
  dyn_string arrCmds = strsplit(cmd, ";");
  bool cmdIsShow = false;
  string camString = "";
  int camId = 0;

  for(int i = 1; i <= dynlen(arrCmds); i++)
  {
    dyn_string singleCmd = strsplit(arrCmds[i], "=");
    if(dynlen(singleCmd) == 2)
    {    
      string key = singleCmd[1];
      string val = singleCmd[2];
    
      if ((key == "cmd") && (val == "show")) // achtung: kein else: cmdIsShow = false !
        cmdIsShow = true;
      if (key == "source")
        camString = val;
    }
  }
  
  if(cmdIsShow && camString != "")
  {
    VIDEO_OA_KBD_debugExtend("Found CAM from string: " + camString);
    camId = (int) substr(camString, strlen("Camera_"));
  }
  
  return camId;
}
//----------------------------------------------------------------



/*
  VIDEO_OA_KBD_isDisplayStateOK
  returns the actual overall state from the monitor state
  @para cmd: the displayState string, must be in format "state=ok;source=<camname>"
*/
bool VIDEO_OA_KBD_isDisplayStateOK(string displayState)
{
  VIDEO_OA_KBD_debugExtend("VIDEO_OA_KBD_isDisplayStateOK: displayState=" + displayState);
  dyn_string arrCmds = strsplit(displayState, ";");

  for(int i = 1; i <= dynlen(arrCmds); i++)
  {
    dyn_string singleCmd = strsplit(arrCmds[i], "=");
    string key = singleCmd[1];
    string val = singleCmd[2];
    
    if (key == "state" && val=="ok")
    {
      return true;
    }
  }
  
  return false;
}
//----------------------------------------------------------------



/*
  VIDEO_OA_KBD_parseCamFromDisplayState
  returns the camera from the monitor state
  @para cmd: the cmd string, must be in format "cmd=show;source=<camname>"
*/
int VIDEO_OA_KBD_parseCamFromDisplayState(string displayState, string videoDialog)
{
  VIDEO_OA_KBD_debugExtend("VIDEO_OA_KBD_parseCamFromDisplayState: state=" + displayState + ", videoDialog = " + videoDialog);
  dyn_string arrCmds = strsplit(displayState, ";");
  string camString = ""; 
  int    camId = 0;

  for(int i = 1; i <= dynlen(arrCmds); i++)
  {
    dyn_string singleCmd = strsplit(arrCmds[i], "=");
    string key = singleCmd[1];
    string val = singleCmd[2];
    
    if (key == "source")
    {
      dyn_string dialogs = strsplit(val, ",");
      for(int j = 1; j <= dynlen(dialogs); j++)
      {
        dyn_string stateElement = strsplit(dialogs[j], " ");
        string camera = stateElement[1];
        string vd     = stateElement[10];
        if(videoDialog == "VD" + vd)
        {
          camString = camera;
        }
        
      }
    }
  }
  
  if(camString != "")
  {
    VIDEO_OA_KBD_debugExtend("Found CAM from monitor state string: " + camString);
    camId = (int) substr(camString, strlen("Camera_"));
  }
  else
  {
    VIDEO_OA_KBD_debugExtend("No CAM found in monitor state string.");
  }
  return camId;
}
//----------------------------------------------------------------



/*
  VIDEO_OA_KBD_setLastActive
  sets the time, when the camera was controlled the last time
  wird aufgerufen durch:
   - writePos() in CtrlExt
   - handleFocus in UserLib (nicht Produkt Bestandteil)
   - handleIris in UserLib (nicht Produkt Bestandteil)
*/
VIDEO_OA_KBD_setLastActiveTime()
{
  m_lastActiveTime = getCurrentTime();
}
//----------------------------------------------------------------



/*
  VIDEO_OA_KBD_getLastActive
  @return the time, when the camera was controlled the last time
*/
time VIDEO_OA_KBD_getLastActiveTime()
{
  return m_lastActiveTime;
}
//----------------------------------------------------------------



/*
  VIDEO_OA_KBD_inputModeChanged
  this function is called, when the inputMode is changed
  @param inputMode: the new input mode
*/
VIDEO_OA_KBD_inputModeChanged(int newMode)
{
  m_inputMode = newMode;
  VIDEO_OA_KBD_setLastActiveTime();
}
//----------------------------------------------------------------



/*
  VIDEO_OA_KBD_currentInputMode
  returns the current Input Mode
*/
int VIDEO_OA_KBD_currentInputMode()
{
  return m_inputMode;
}
//----------------------------------------------------------------



/** ---------------------------------------------------------------------------------------------
* Converts all UTF-8  strings to ISO 8859-1 strings
*
*/
string VIDEO_OA_KBD_convertUtf8ToIso(string text)
{
	string result;

	for(int j=0; j< strlen(text); j++)
	{
		if(text[j] == (char)0xc2)
		{
			// skip 0xc2 and use the following char
			j++;
			result += (string)(char)text[j];
		}
		else if (text[j] == (char)0xc3)
		{
			// skip 0xc3 and use the following char plus 0x40
			j++;
			result += (string)((char)text[j] + (char)0x40);
		}
		else
		{
			result += (string)(char)text[j];
		}
	}
	return result;
}
//----------------------------------------------------------------
