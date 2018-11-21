/*
  @author Frank Christ

  Encryption key word
  $License: NOLICENSE
 
  This control handles requests between the HID Ctrl Extension DLL
  and the workstation datapoint. This is the main library and
  should be running on all HID Workstations
 
  HISTORY:
  2014.04.14  base version                        fchrist
*/
//----------------------------------------------------------------

#uses "CtrlHid"


// DPE names, should not be modified
const string VIDEO_OA_HID_ACTIVECAM = "activeCam";
const string VIDEO_OA_HID_ACTIVECAMDP = "activeCamDp";
const string VIDEO_OA_HID_ACTIVEWIDGET = "activeWidget";
const string VIDEO_OA_HID_JOYSTICK_DEVICENAME = "joystick.configuration.deviceName";
const string VIDEO_OA_HID_JOYSTICK_VENDORID = "joystick.configuration.vendorId";
const string VIDEO_OA_HID_JOYSTICK_PRODUCTID = "joystick.configuration.productId";
const string VIDEO_OA_HID_JOYSTICK_STATUS = "joystick.controller.status";
const string VIDEO_OA_HID_JOYSTICK_CONNECT = "joystick.controller.connect";
const string VIDEO_OA_HID_JOYSTICK_WATCHDOG = "joystick.controller.watchdog";
const string VIDEO_OA_HID_JOGSHUTTLE_DEVICENAME = "jogShuttle.configuration.deviceName";
const string VIDEO_OA_HID_JOGSHUTTLE_VENDORID = "jogShuttle.configuration.vendorId";
const string VIDEO_OA_HID_JOGSHUTTLE_PRODUCTID = "jogShuttle.configuration.productId";
const string VIDEO_OA_HID_JOGSHUTTLE_STATUS = "jogShuttle.controller.status";
const string VIDEO_OA_HID_JOGSHUTTLE_CONNECT = "jogShuttle.controller.connect";
const string VIDEO_OA_HID_JOGSHUTTLE_WATCHDOG = "jogShuttle.controller.watchdog";

global int g_hidWorkstationID=-1;
global int g_hidActiveCamID=-1;
global string g_hidActiveCamDP="";
global string g_hidActiveCamMode="live";
global string g_hidActiveEwo="";

/*
  Main init function, that needs to be called when starting the UI or CTRL
  manager
*/
VIDEO_OA_HID_init()
{
  VIDEO_OA_HID_debugWork("VIDEO_OA_HID_init() called!");

  // get our workstationID
  g_hidWorkstationID = myManNum();
    
  // register debug flags
  int DbgNumber;  
  DbgNumber = registerDbgFlag("hid_work");     // use -dbg work for more debug informations
  DbgNumber = registerDbgFlag("hid_extend");   // use -dbg extend for more debug informations
                                             // while searching an error

  // init the hid control extension
  int ret = hid_init();
  if (ret < 0)
  {
    VIDEO_OA_HID_debugError(PRIO_SEVERE, ERR_PARAM, 1);
    return;
  } 
  else
  {
    VIDEO_OA_HID_debugWork("HID Ctrl Extension init done!");
  }  
  
  // register for Joystick configuration changes
  ret = dpConnect("VIDEO_OA_HID_updateJoystickCB", true, 
                  VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+"." + VIDEO_OA_HID_JOYSTICK_DEVICENAME,
                  VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+"." + VIDEO_OA_HID_JOYSTICK_VENDORID,
                  VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+"." + VIDEO_OA_HID_JOYSTICK_PRODUCTID);  
  if(ret != 0)
  {
    VIDEO_OA_HID_debugError(PRIO_SEVERE, ERR_PARAM, 2);
    return;
  }
  
  // register for JogShuttle configuration changes
  ret = dpConnect("VIDEO_OA_HID_updateJogShuttleCB", true, 
                  VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+"." + VIDEO_OA_HID_JOGSHUTTLE_DEVICENAME,
                  VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+"." + VIDEO_OA_HID_JOGSHUTTLE_VENDORID,
                  VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+"." + VIDEO_OA_HID_JOGSHUTTLE_PRODUCTID);  
  if(ret != 0)
  {
    VIDEO_OA_HID_debugError(PRIO_SEVERE, ERR_PARAM, 3);
    return;
  }

  // register for active Workstation camera ID
  ret = dpConnect("VIDEO_OA_HID_updateActiveCamCB", true, 
                  VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+"." + VIDEO_OA_HID_ACTIVECAM);  
  if(ret != 0)
  {
    VIDEO_OA_HID_debugError(PRIO_SEVERE, ERR_PARAM, 4);
    return;
  }

  // register for active Workstation camera DP and Mode
  ret = dpConnect("VIDEO_OA_HID_updateActiveCamDpCB", true, 
                  VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+"." + VIDEO_OA_HID_ACTIVECAMDP);  
  if(ret != 0)
  {
    VIDEO_OA_HID_debugError(PRIO_SEVERE, ERR_PARAM, 4);
    return;
  }

  // register for active Widget
  ret = dpConnect("VIDEO_OA_HID_updateActiveWidgetCB", true, 
                  VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+"." + VIDEO_OA_HID_ACTIVEWIDGET);  
  if(ret != 0)
  {
    VIDEO_OA_HID_debugError(PRIO_SEVERE, ERR_PARAM, 5);
    return;
  }

  VIDEO_OA_HID_debugWork("VIDEO_OA_HID_init() successful!");
}
//----------------------------------------------------------------




/*
  Main init function, that needs to be called when starting the UI or CTRL
  manager
*/
VIDEO_OA_HID_closeAll()
{
  // close all hid connections
  int ret = hid_closeAll();
  if (ret < 0)
  {
    VIDEO_OA_HID_debugError(PRIO_SEVERE, ERR_PARAM, 6);
    return;
  } 
  else
  {
    VIDEO_OA_HID_debugWork("HID Ctrl Extension close all done!");
  }  
}
//----------------------------------------------------------------




/* configures a joystick to be used
*/
VIDEO_OA_HID_setJoystick(int iVendor, int iProduct, string sDeviceName, int wkst = -1)
{
  VIDEO_OA_HID_debugExtend( "VIDEO_OA_HID_setJoystick() DeviceName=" + sDeviceName + " Vendor=" + iVendor + " Product=" + iProduct );
  
  if(wkst == -1)
  {
    wkst = g_hidWorkstationID;
  }  
  
  // configure this device
  dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+"." + VIDEO_OA_HID_JOYSTICK_DEVICENAME, sDeviceName,
        VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+"." + VIDEO_OA_HID_JOYSTICK_VENDORID, iVendor,
        VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+"." + VIDEO_OA_HID_JOYSTICK_PRODUCTID, iProduct);
}




/* configures a jogShuttle to be used
*/
VIDEO_OA_HID_setJogShuttle(int iVendor, int iProduct, string sDeviceName, int wkst = -1)
{
  VIDEO_OA_HID_debugExtend( "VIDEO_OA_HID_setJogShuttle() DeviceName=" + sDeviceName + " Vendor=" + iVendor + " Product=" + iProduct );
  
  if(wkst == -1)
  {
    wkst = g_hidWorkstationID;
  }  
  
  // configure this device
  dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+"." + VIDEO_OA_HID_JOGSHUTTLE_DEVICENAME, sDeviceName,
        VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+"." + VIDEO_OA_HID_JOGSHUTTLE_VENDORID, iVendor,
        VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+"." + VIDEO_OA_HID_JOGSHUTTLE_PRODUCTID, iProduct);
}




/*
   opens a joystick device
*/
VIDEO_OA_HID_updateJoystickCB(string dp1, string deviceName,
                              string dp2, int vendorId,
                              string dp3, int productId)
{
  VIDEO_OA_HID_debugWork("VIDEO_OA_HID_updateJoystickCB() deviceName=" + deviceName);
  
  // Open Joystick device  
  bool ret = hid_open(  vendorId, productId, HID_DEVICE_TYPE_JOYSTICK );    // TODO open always as device 1
  if(!ret)
  {
    VIDEO_OA_HID_debugError(PRIO_SEVERE, ERR_PARAM, 7);
  }
}



/*
   opens a jogshuttle device
*/
VIDEO_OA_HID_updateJogShuttleCB(string dp1, string deviceName,
                                string dp2, int vendorId,
                                string dp3, int productId)
{
  VIDEO_OA_HID_debugWork("VIDEO_OA_HID_updateJogShuttleCB() deviceName=" + deviceName);
  
  // Open Jogshuttle device  
  bool ret = hid_open(  vendorId, productId, HID_DEVICE_TYPE_JOGSHUTTLE );    // TODO open always as device 2
  if(!ret)
  {
    VIDEO_OA_HID_debugError(PRIO_SEVERE, ERR_PARAM, 8);
  }
}




/*
  Retreives all currently connected hid devices
*/
VIDEO_OA_HID_getDevices() 
{
  VIDEO_OA_HID_debugExtend("VIDEO_OA_HID_getDevices()");
  hid_getDevices();
}
//----------------------------------------------------------------



/*
  callback method for changes on .activeCam @wkst (new cam selected)
  this function is called, when the activeCam of our workstation
  is modified 
  @param dp: the dp name. can be empty when set for other monitor
  @param newcamId: the new camera for our workstation
*/
VIDEO_OA_HID_updateActiveCamCB(string dp, int camID)
{
  VIDEO_OA_HID_debugWork("VIDEO_OA_HID_updateActiveCamCB(" + dp + ", " + camID + ")");
  g_hidActiveCamID = camID;
  hid_setActiveCam(camID, true); // true : setDPdirect (ctrl ext setzt joystick cmd selber)
  hid_setCamControl(true);
  return;
}
//----------------------------------------------------------------




/*
  callback method for changes on .activeCam @wkst (new cam selected)
  this function is called, when the activeCam of our workstation
  is modified 
  @param dp: the dp name. can be empty when set for other monitor
  @param newcamId: the new camera for our workstation
*/
VIDEO_OA_HID_updateActiveCamDpCB(string dp, string camDP)
{
  VIDEO_OA_HID_debugWork("VIDEO_OA_HID_updateActiveCamDpCB(" + dp + ", " + camDP + ")");
  dyn_string dTemp = strsplit(camDP, ";");
  if(dynlen(dTemp) == 2)
  {
    g_hidActiveCamDP = dTemp[1];
    g_hidActiveCamMode = dTemp[2];
    if(strpos(g_hidActiveCamMode, "live") == 0)
    {
      hid_setActiveCamDp(g_hidActiveCamDP, true); // true : setDPdirect (ctrl ext setzt joystick cmd selber)
      hid_setCamControl(true);
    }
  }
  else
  {
    VIDEO_OA_HID_debugError(PRIO_SEVERE, ERR_PARAM, 4);
  }
  return;
}
//----------------------------------------------------------------




/*
  callback method for changes on .activeCam @wkst (new cam selected)
  this function is called, when the activeCam of our workstation
  is modified 
  @param dp: the dp name. can be empty when set for other monitor
  @param newcamId: the new camera for our workstation
*/
VIDEO_OA_HID_updateActiveWidgetCB(string dp, string sWidget)
{
  VIDEO_OA_HID_debugWork("VIDEO_OA_HID_updateActiveWidgetCB(" + dp + ", " + sWidget + ")");
  if(sWidget != "")
  {
    dyn_string list = strsplit(sWidget, ";");
    if(dynlen(list) >= 1)
    {
      g_hidActiveEwo = list[1];
      VIDEO_OA_HID_debugWork("VIDEO_OA_HID_updateActiveWidgetCB(activeEwo=" + g_hidActiveEwo + ")");
    }
  }
  return;
}
//----------------------------------------------------------------




/*
  Returns the workstation dp prefix string for selected workstation
  eg: Workstation_0001
  @param wkst: the workstation nr. if -1, the current 
      workstation nr. will be used (using myManNum());
*/
string VIDEO_OA_HID_getWorkstation(int wkst = -1)
{
  int num;

  if (wkst == -1)
    num = myManNum();
  else
    num = wkst;  
  
  return "Workstation_" + VIDEO_OA_HID_getFormattedNr(num);
}
//----------------------------------------------------------------



/*
  Returns the camera dp prefix string for selected camara
  @param nr: the camera nr.
*/
string VIDEO_OA_HID_getCamera(int nr) 
{
  return "Camera_" + VIDEO_OA_HID_getFormattedNr(nr, 5);
}
//----------------------------------------------------------------



/*
  VIDEO_OA_HID_getFormattedNr
  returns a string representing the number with preceding digits
  @param nr: the number we want as string
  @digits: the number of digits we want. default = 5 (00001)
*/
string VIDEO_OA_HID_getFormattedNr(int nr, int digits = 5)
{
  string ret, format;
  sprintf(format, "%%0%dd", digits);
  sprintf(ret, format, nr);
  return ret;
}
//----------------------------------------------------------------



void VIDEO_OA_HID_joystickValueCB(int iValue, string sParam)
{
  return;
}

bool bPause = true;
void VIDEO_OA_HID_jogshuttleValueCB(int iValue, string sParam)
{
  string sJogshuttle;
  dpGet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+"." + VIDEO_OA_HID_JOGSHUTTLE_DEVICENAME, sJogshuttle);

  VIDEO_OA_HID_debugExtend( "VIDEO_OA_HID_jogshuttleValueCB() Device=" + sJogshuttle + ", param=" + sParam  + ", iValue=" + iValue);

  
  if(sParam == "Dial")
  {
    if (iValue>0)
    {  
      dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+".widget.command",
            "widget=" + g_hidActiveEwo + ";cmd=playbackStepForward");
      bPause=true;
    }
    else if(iValue<0)
    {
      dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+".widget.command",
            "widget=" + g_hidActiveEwo + ";cmd=playbackStepBackward");
      bPause=true;
    }
  }
  else if(sParam == "Wheel")
  {
    if (iValue == 0)
    {  
      dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+".widget.command",
            "widget=" + g_hidActiveEwo + ";cmd=playbackPause");
      bPause=true;
    }
    else 
    {
      dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+".widget.command",
            "widget=" + g_hidActiveEwo + ";cmd=playbackPlay;speed=" + iValue);
      bPause=false;
    }
  }
  else if(sParam == "Button1" && iValue==1)
  {
    if(strpos(sJogshuttle, "AXIS") >= 0)
    {
    }
    else
    {
      dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+".widget.command",
            "widget=" + g_hidActiveEwo + ";cmd=playbackPlay;speed=-500");
      bPause=false;
    }
  }
  else if(sParam == "Button2" && iValue==1)
  {
    if(strpos(sJogshuttle, "AXIS") >= 0)
    {
      dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+".widget.command",
            "widget=" + g_hidActiveEwo + ";cmd=playbackStepBackward");
      bPause=true;
    }
    else
    {
      dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+".widget.command",
            "widget=" + g_hidActiveEwo + ";cmd=playbackPlay;speed=-100");
      bPause=false;
    }
  }
  else if(sParam == "Button3" && iValue==1)
  {
    if(strpos(sJogshuttle, "AXIS") >= 0)
    {
      if(bPause)
      {
        dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+".widget.command",
              "widget=" + g_hidActiveEwo + ";cmd=playbackPlay;speed=100");
        bPause=false;
      }
      else
      {
        dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+".widget.command",
              "widget=" + g_hidActiveEwo + ";cmd=playbackPause");
        bPause=true;
      }
    }
    else
    {
      dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+".widget.command",
            "widget=" + g_hidActiveEwo + ";cmd=playbackPause");
      bPause=true;
    }
  }
  else if(sParam == "Button4" && iValue==1)
  {
    if(strpos(sJogshuttle, "AXIS") >= 0)
    {
      dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+".widget.command",
            "widget=" + g_hidActiveEwo + ";cmd=playbackStepForward");
      bPause=true;
    }
    else
    {
      dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+".widget.command",
            "widget=" + g_hidActiveEwo + ";cmd=playbackPlay;speed=100");
      bPause=false;
    }
  }
  else if(sParam == "Button5" && iValue==1)
  {
    if(strpos(sJogshuttle, "AXIS") >= 0)
    {
    }
    else
    {
      dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+".widget.command",
            "widget=" + g_hidActiveEwo + ";cmd=playbackPlay;speed=500");
      bPause=false;
    }
  }
  else if(sParam == "Button6" && iValue==1)
  {
    if(strpos(sJogshuttle, "AXIS") >= 0)
    {
    }
    else
    {
    }
  }
}


/* returns for each device that is found with hid_getDevices()
*/
hid_device_cb(int iVendor, int iProduct, string sDeviceName, int iDeviceType)
{
  VIDEO_OA_HID_debugExtend( "hid_device_cb() DeviceName=" + sDeviceName + " Vendor=" + iVendor + 
                            " Product=" + iProduct  + " DeviceType=" + iDeviceType);
  
  // call custom callback function
  if (isFunctionDefined("VIDEO_OA_HID_deviceCB"))
  {
    startThread("VIDEO_OA_HID_deviceCB", iVendor, iProduct, sDeviceName, iDeviceType);
  }
}




/* returns the status for each individual device
*/
hid_status_cb(int iStatus, int iDevice)
{
  VIDEO_OA_HID_debugExtend( "hid_status_cb() Device=" + iDevice + ", Status=" + iStatus );

  bool bConnect = (iStatus == HID_STATUS_OPEN_OK) ? true : false;
  

  switch(iDevice)
  {
    // the CTRL Extension Init status is set for iDevice == 0
    case 0:  
    { 
      dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+ "." + VIDEO_OA_HID_JOYSTICK_CONNECT, bConnect);  
      dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+ "." + VIDEO_OA_HID_JOYSTICK_STATUS, iStatus);  
      dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+ "." + VIDEO_OA_HID_JOYSTICK_WATCHDOG, false);
      dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+ "." + VIDEO_OA_HID_JOGSHUTTLE_CONNECT, bConnect);  
      dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+ "." + VIDEO_OA_HID_JOGSHUTTLE_STATUS, iStatus);  
      dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+ "." + VIDEO_OA_HID_JOGSHUTTLE_WATCHDOG, false);
      break;
    }
      
    // the joystick is always device 1
    case HID_DEVICE_TYPE_JOYSTICK:  
    { 
      dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+ "." + VIDEO_OA_HID_JOYSTICK_CONNECT, bConnect);  
      dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+ "." + VIDEO_OA_HID_JOYSTICK_STATUS, iStatus);  
      break;
    }
      
    // the jogShuttle is always device 2
    case HID_DEVICE_TYPE_JOGSHUTTLE:
    {
      dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+ "." + VIDEO_OA_HID_JOGSHUTTLE_CONNECT, bConnect);  
      dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+ "." + VIDEO_OA_HID_JOGSHUTTLE_STATUS, iStatus);  
      break;
    }
      
    default:
    {
        break;
    }
  }
}



/* triggers the watchdog for each individual device
*/
hid_watchdog_cb(int iDevice)
{
  VIDEO_OA_HID_debugExtend( "hid_watchdog_cb() Device=" + iDevice );

  switch(iDevice)
  {
    // the joystick is always device 1
    case HID_DEVICE_TYPE_JOYSTICK:  
    { 
      dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+ "." + VIDEO_OA_HID_JOYSTICK_WATCHDOG, false);  
      break;
    }
      
    // the jogShuttle is always device 2
    case HID_DEVICE_TYPE_JOGSHUTTLE:
    {
      dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+ "." + VIDEO_OA_HID_JOGSHUTTLE_WATCHDOG, 0);  
      break;
    }
      
    default:
    {
        break;
    }
  }
}



/*
 */
hid_value_cb(int iValue, int iDevice, string sParam)
{
  VIDEO_OA_HID_debugExtend( "hid_value_cb() " + sParam + "=" + iValue + " Device=" + iDevice );
  
  switch(iDevice)
  {
    // the joystick is always device 1
    case HID_DEVICE_TYPE_JOYSTICK:  
    { 
      VIDEO_OA_HID_joystickValueCB(iValue, sParam);
      
      if(sParam=="X" || sParam=="Y" || sParam=="Z" || sParam=="Rx" || sParam=="Ry" || sParam=="Rz")
      {
        dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+ ".joystick.axis." + sParam, iValue);
      }
      else if(sParam=="Slider")
      {
        dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+ ".joystick.slider.Slider_1", iValue);
      }
      else if(sParam=="Hat Switch")
      {
        dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+ ".joystick.hatSwitch.Switch_1", iValue);
      }
      else if(strpos(sParam, "Button") >= 0)
      {
        strreplace(sParam, "Button","Button_");
        dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+ ".joystick.keys." + sParam, iValue);
      }
      break;
    }
      
    // the jogShuttle is always device 2
    case HID_DEVICE_TYPE_JOGSHUTTLE:
    {
      VIDEO_OA_HID_jogshuttleValueCB(iValue, sParam);

      if(sParam=="Dial" || sParam=="Wheel")
      {
        dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+ ".jogShuttle.jog." + sParam, iValue);
      }
      else if(strpos(sParam, "Button") >= 0)
      {
        strreplace(sParam, "Button","Button_");
        dpSet(VIDEO_OA_HID_getWorkstation(g_hidWorkstationID)+ ".jogShuttle.keys." + sParam, iValue);
      }
      break;
    }
      
    default:
    {
        break;
    }
  }
  
  // call custom callback function
  if (isFunctionDefined("VIDEO_OA_HID_valueCB"))
  {
    startThread("VIDEO_OA_HID_valueCB", iValue, iDevice, sParam);
  }
  
}



/*
  Debug function, should only be called from other debug functions
  @param msg: the debug msg
  @param dbgFlag: the message will be written, when the dbgFlag
                  is set (use -dbg <flagname>)
*/
VIDEO_OA_HID_debug(string msg, string dbgFlag)
{
  if (isDbgFlag(dbgFlag))
    DebugTN("VIDEO_OA_HID: " + msg);
}
//----------------------------------------------------------------




/*
  Debug function if dbg Flag "hid_work" is set.
  param msg: the debug msg
*/
VIDEO_OA_HID_debugWork(string msg)
{
  VIDEO_OA_HID_debug("DBG: " + msg, "hid_work");
}
//----------------------------------------------------------------



/*
  Debug function if dbg Flag "hid_extend" is set.
  @param msg: the debug msg
*/
VIDEO_OA_HID_debugExtend(string msg)
{
  VIDEO_OA_HID_debug("DBGEXT: " + msg, "hid_extend");
}
//----------------------------------------------------------------



/*
  Debug function if an error occurs
  @param prio: error priority
  @param type: error type
  @param error: errorcode id
*/
VIDEO_OA_HID_debugError(int prio, int type, int error)
{
  errClass err = makeError("voa_hid", prio, type, error);
  throwError(err);
}
//----------------------------------------------------------------



