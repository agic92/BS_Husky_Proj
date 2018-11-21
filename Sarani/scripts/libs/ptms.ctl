// Global variables

// Store the revision number
global string ptms_strRevision = "$Revision: 1.18.2.8 $";

global bool ptms_bDebug = false;

global dyn_int iptms_XPosition;            // X position of one of our displays
global dyn_int iptms_YPosition;            // Y position of one of our displays
global dyn_int iptms_Width;                // Width of one of our displays
global dyn_int iptms_Height;               // Height of one of our displays

global int      iptms_NumPanels = 0;       // How many panels do we have
global dyn_char cptms_Displays;            // Characters for the X displays
global dyn_char cptms_Displays_Right;      // Displays to the right
global dyn_char cptms_Displays_Left;       // Displays to the left

global dyn_string strptms_Basepanels;			 // Name of the basepanel to be used in every monitor
global dyn_string strptms_PanelsToLoad;                // Panels to load after initialisation
global dyn_string strptms_Templates;

global string strptms_TemplateName;			   // Name of the template that we want to use

global char cptms_PrimaryDisplay;          // The letter of the primary display ( where we normally

int iConfigNum = 1;

int iptms_DisplayIndex;                    // Index of this display ( in array of windows )

// Store the display width and height for each of the N monitors
global mapping tptms_DisplayWidth;         // Display width
global mapping tptms_DisplayHeight;        // Display height
global mapping tptms_DisplayPosX;         // Display width
global mapping tptms_DisplayPosY;        // Display height

// Each of the functions can return one of the following results
const int ptms_RESULT_OK        = 0;        // everything is ok, we can continue
const int ptms_RESULT_FAILED    = 1;        // Failed. We can't continue ( probably because we can't read remote datapoint )
const int ptms_RESULT_IDENTICAL = 2;        // Datapoints are identical. No need to copy !

global dyn_string ptms_ServerNames;            // Hold ALL server names that we're conected to
global dyn_uint ptms_ServerIds; 

global dyn_string ptms_DisplayServerNames;    // Holds all server names to be shown in navigation
global dyn_string ptms_AlarmServerNames;      // Holds all server names ot be shown in alarm lines or alarm screen
/************************************************
Name : ptms_InitializeScreens()
*************************************************
Description:
    This function should be called first before calling
    any of the other mm functions.
    This funciton will be called from the very first panel that we
    have, being the 'BasePanel'
    
    The information is stored in various global variables. This
    implies that you need to restart an Ui when a "new" panel is 
    added / activated / scaled         
    ( Adding/activating/scaling is done in control Panel )
    
Usage:
    To be called from the 'EvenInitialize' 
    of our Basepanel
    
Parameters:
    none
    
Returns:
    
************************************************/

void ptms_InitializeScreens(int iNum = 1) //index of Configuration
{
  // Locla data
  int iIndex = 1;
  int iX=0, iY=0, iWidth, iHeight;
  string strSection = "ksmm";
  string strKeyword = "MaxScreens";
  string strMaxPanels;
  int iMaxPanels;
  string strFile;
  int iMaxMonitor;
  int screenSizeX,screenSizeY;
  int next;
   
  iConfigNum = iNum;

  dynClear(iptms_Width);
  dynClear(iptms_Height);
  dynClear(iptms_XPosition);
  dynClear(iptms_YPosition);

  int ScreenNum=getScreenCount(); //holen der Anzhal
  int autoWidth,autoHeight,autoPosX,autoPosY;
    
  for(int k=0;k<ScreenNum;k++)
  {
    getScreenSize(autoWidth,autoHeight,autoPosX,autoPosY,k);
    next = k+1;
    if(dynlen(g_diXRes)<next)
    {
      ptms_AppendScreen(next,next,next,next,"DEFAULTPT",-1,-1,"DEFAULTTEMP",false);
    }
      
    iWidth=g_diXRes[next];
    iHeight=g_diYRes[next];
       
    if(iWidth == -1 || iHeight == -1) //Wenn default
    {
      iWidth = g_iDefaultResX;
      iHeight = g_iDefaultResY;
    }   
    //not else if, because iDefault can also be automatic
    if(iWidth == 0 || iHeight == 0) //Wenn auto
    {
      iWidth = autoWidth;
      iHeight = autoHeight;
    }
      
    tptms_DisplayWidth[ g_dsCharacters[next] ]  = iWidth;
    tptms_DisplayHeight[ g_dsCharacters[next]] = iHeight;
    tptms_DisplayPosX [ g_dsCharacters[next] ] = autoPosX;
    tptms_DisplayPosY [ g_dsCharacters[next] ] = autoPosY; 
    dynAppend( iptms_Width, iWidth );
    dynAppend( iptms_Height, iHeight);
    dynAppend( iptms_XPosition, autoPosX ); //always auto pos
    dynAppend( iptms_YPosition, autoPosY ); //always auto pos
  }
  
  strptms_PanelsToLoad = g_dsPanels; //int the form PanelIndex|Systemname|Screen

  // Now store the number of displays
  iptms_NumPanels = dynlen( iptms_XPosition );

  
  //cstoeg: Only to fill it
  strptms_TemplateName = g_sDefaultTemplate;

  // Now determine the character that we assign to each of the monitors  
  ptms_DetermineMonitorCharacters();
  ptms_SaveConfigToDp("_"+getUserName(),true,iConfigNum);

}



/************************************************
Name : ptms_DetermineMonitorCharacters()
*************************************************
Description:
    This funciton will, based on the number of monitors,
    assign a character to each of the monitors.
    
    Global variables are filled to reflect the result:
    
		global dyn_char cptms_Displays;            
		global int      iptms_NumPanels = 0;       
    
    
Usage:
    
Parameters:
    none
    
Returns:
    
************************************************/
void ptms_DetermineMonitorCharacters()
{

  // Local data
  dyn_string strCharacters; 		  // The character that we assignb to every monitor
  dyn_string strCharactersRight; 	// The character to the left of every monitor
  dyn_string strCharactersLeft; 	// The character to the right of every monitor
  dyn_string strBasePanels;			  // What basepanel to open on each monitor

 
// clear Dyns for initialization
  dynClear(strptms_Templates);
  dynClear(cptms_Displays);
  dynClear(cptms_Displays_Right);
  dynClear(cptms_Displays_Left);
  
  //cstoeg: replace DEFAULTTEMP with correct DefaultTemplate
  for (int j = 1; j<=dynlen(g_dsTemplates); j++)
  {
    //cstoeg: replace DEFAULTTEMP with correct DefaultTemplate
    if(g_dsTemplates[j]=="DEFAULTTEMP")
    {
      strBasePanels[j]="/"+g_sDefaultTemplate+"/basePanel_$W_$H_"+g_sDefaultTemplate;
      dynAppend( strptms_Templates,g_sDefaultTemplate);
    }
    else //cstoeg: Load correct Basepanel
    {
      strBasePanels[j]="/"+g_dsTemplates[j]+"/basePanel_$W_$H_"+g_dsTemplates[j];
      dynAppend( strptms_Templates,g_dsTemplates[j]);
    }
  } 
  
  // Now assign the characters to the individual monitors
  for( int t = 1; t <= iptms_NumPanels; t++)
  {
    dynAppend( cptms_Displays,       g_dsCharacters[t] );
    dynAppend( cptms_Displays_Right, g_dsRCharacters[t] );
    dynAppend( cptms_Displays_Left,  g_dsLCharacters[t] );

    dynAppend( strptms_Basepanels, strBasePanels[t] );
    
    if( ptms_bDebug ) DebugN( "mm: Display : " + t + " = character " + g_dsCharacters[t] + " basepanel=" + strBasePanels[t] + " right=" +  g_dsRCharacters[t] + " left=" + g_dsLCharacters[t] );
  }
  
  // The first display is the primary display
  cptms_PrimaryDisplay = cptms_Displays[1];
  
}


/************************************************
Name : ptms_GetPrimaryDisplayCharacter()
*************************************************
Description:
    Returns the character of the 'primary' 
    display. Normally this should be:
    
    'A'    When there's one display
    'B'    When there are 2, 3 or 4
    
Usage:
    
Parameters:
    none
    
Returns:
    
************************************************/

char ptms_GetPrimaryDisplayCharacter()
{
  return cptms_PrimaryDisplay;
}

/************************************************
Name : ptms_GetDisplayLeft()
*************************************************
Description:
    Get the character of the display
    to the left of the indicated display.

    The function will have a 'wrap around'.
    So, when you ask for the panel left of 'A'
    then you will get 'D' ( in a 4 panel configuration )
    
Usage: 
     ptms_GetDisplayRight( 'D' )
     Will return 'A'
     
     
Parameters:
    none
    
Returns:
    
************************************************/

char ptms_GetDisplayLeft(
  char cDisplay
)
{
  // Local data
  int iPos;
  
  // Determine the position of the display
  iPos = dynContains( cptms_Displays, cDisplay );
  
  // Look for the proper panel that lies left of us
  if( iPos >= 1 )
  {
    return cptms_Displays_Left[ iPos ];
  }  

  // when the requested character doesn't lie in our valid
  // range then just return ptms_GetPrimaryDisplayCharacter(). There's always an ptms_GetPrimaryDisplayCharacter()
  return ptms_GetPrimaryDisplayCharacter();      
}

/************************************************
Name : ptms_GetDisplayRight()
*************************************************
Description:
    Get the character of the display
    to the right of the indicated display.

    The function will have a 'wrap around'.
    So, when you ask for the panel right of 'D'
    then you will get 'A' ( in a 4 panel configuration )
    
Usage: 
     ptms_GetDisplayRight( 'D' )
     Will return ptms_GetPrimaryDisplayCharacter()
     
     
Parameters:
    none
    
Returns:
    
************************************************/

char ptms_GetDisplayRight(
  char cDisplay
)
{
  // Local data
  int iPos;
  
  // Determine the position of the display
  iPos = dynContains( cptms_Displays, cDisplay );

  // Look for the proper panel that lies to the right of us  
  if( iPos >= 1 )
  {
    return cptms_Displays_Right[ iPos ];
  }  
  
  // when the requested character doesn't lie in our valid
  // range then just return ptms_GetPrimaryDisplayCharacter(). There's always an ptms_GetPrimaryDisplayCharacter()
  return ptms_GetPrimaryDisplayCharacter();
}

/************************************************
Name : ptms_LoadBasePanels()
*************************************************
Description:
    There are 2 base panels:
    
      basepanel_user_1024
      basepanel_user_1600
      
    This function goes through the global array
    looking for the proper display size
    and opening the proper panel      
    
Usage: 
  
     
Parameters:
    none
    
Returns:
    
************************************************/

void ptms_LoadBasePanels()
{
  // Now open each of the modules ( for our X displays )
  for( int t = 1; (t <= iptms_NumPanels && t <= g_iNumberOfScreens) ; t++)
  {
    if(g_dbUsedScreens[t] == true) //cstoeg: nur wenn Schirm genutzt wird
    {
      ptms_LoadOneBasePanel(
        t,
        iptms_XPosition[t],
        iptms_YPosition[t],
        iptms_Width[t],
        iptms_Height[t],
        cptms_Displays[t],
        strptms_Basepanels[t],
        strptms_TemplateName );
    }
  }  
}

/************************************************
Name : ptms_LoadOneBasePanel()
*************************************************
Description:
    Loads one particular base panel
    ( 1024 or 1600 )    
    
Usage: 
  
     
Parameters:
    none
    
Returns:
    
************************************************/

void ptms_LoadOneBasePanel(
  int iScreenNr,      // Number of the screen
  int x,              // x position of panel
  int y,              // y position of pane
  int iWidth,         // Widt of panel, should be 1024 or 1600
  int iHeight,        // Height of panel ( actually not used here )
  char cScreen,       // Character to put in front of panel modules ( A, B, C or D )
  string strBasepanel,// What basepanel to open
  string strTemplate, // what default template to open
  int iNode = 0       //Load this toponode into the mainModule
)
{
  // Locla data
  string strPanel;
  string strScreen = cScreen;
  dyn_string dsParams;
  int iOrigWidth = iWidth;
  int iOrigHeight = iHeight;
  
  if( ptms_bDebug ) DebugN( "ptms_LoadOneBasePanel() opening panel " + cScreen + " at " + x + "," + y );

  // Look for the first panel that is smaller, or for the first panel that is bigger
  strPanel = ptms_FindProperTemplate(
    iWidth,
    iHeight,
    strBasepanel,
    strTemplate
  );  
  
  // Store the width and height of every panel. We might need it lateron
  tptms_DisplayWidth[ strScreen ]  = iWidth;
  tptms_DisplayHeight[ strScreen ] = iHeight;

  if( !iWidth )
  {
    strPanel = "para/PanelTopology/templates/_BasePanelNotFound.pnl";
    dsParams= makeDynString( "$w1:"+iOrigWidth,"$h1:"+iOrigHeight, 
                             "$temp:"+strTemplate);
  }
  else
    dsParams= makeDynString( "$Screen:"+cScreen,"$Number:"+iScreenNr);
  
  if(iNode != 0)
    dynAppend(dsParams, "$Node:" + iNode);
  
  // Now actually open the panel
  ModuleOnWithPanel(
    "BS_Husky",
    x, 
    y, 
    0, 0, 1, 1, 
    "",
    strPanel,
    "basepanel", 
   dsParams);

  // wait for the module to be open
  while( !isModuleOpen("BS_Husky") ) 
  {
    delay(0,50);
  } 
  
}

/************************************************
Name : ptms_FindProperTemplate()
*************************************************
Description:
    Looks for a template that is smaller then 
    our resolution    
    
Usage: 
  
     
Parameters:
    none
    
Returns:
    
************************************************/

string ptms_FindProperTemplate(
  int &iWidth,
  int &iHeight,
  string strBasePanel,
  string strTemplate
)
{
  string strPanel;
  bool bTryDefaultResolution = TRUE;

  while( iHeight || bTryDefaultResolution )
  {
    if(iHeight == 0)  //last try with 1024x768
    {
      bTryDefaultResolution = FALSE;
      iWidth = 1024;
      iHeight = 768;      
    }    
    
    // Replace the keywords in our basepanel.
    // $W -> width of the monitor
    // $H -> height of the monitor
    // $T -> name of the template
    strPanel = "para/PanelTopology/templates" + strBasePanel + ".";    
    strreplace( strPanel, "$T", strTemplate );
    strreplace( strPanel, "$W", iWidth );
    strreplace( strPanel, "$H", iHeight );

    // Do we have this template, in this resolution ?
    if( getPath( PANELS_REL_PATH, strPanel + "pnl" ) != "" )
      return strPanel + "pnl";
    
    if( getPath( PANELS_REL_PATH, strPanel + "xml" ) != "" )
      return strPanel + "xml";
    
    // When we get here then we did not find the template.
    // time to switch to a lower resolution
    if      ( iWidth >= 1920 ) { iWidth = 1680; iHeight = 1050; }
    else if ( iWidth >= 1600 ) { iWidth = 1400; iHeight = 1050; }
    else if ( iWidth >= 1400 ) { iWidth = 1280; iHeight = 1024; }
    else if ( iWidth >= 1280 ) { iWidth = 1024; iHeight = 768;  }
    else                       { iHeight = 0; }
  }  

  // When the resolution doesn't match then set width and height to 0
  // so that they get a nice empty panel with a warning
  iWidth = 0;
  iHeight = 0;

  return "";
}

/************************************************
Name : ptms_LoadTemplatePreview()
*************************************************
Description:
    Loads the Preview for the given Template   
    
Usage: in SelectScreens.pnl und in PT_parameterize.pnl und in PT_preview.pnl 
  
     
Parameters:
    none
    
Returns:
    
************************************************/

void ptms_LoadTemplatePreview(string strTemp)
{
  // Determine the name of the bitmap
  
  if(strTemp=="UNUSED") //Screen is not used
  {
    setValue("txt_template","text",getCatStr("ptms_MultiMonitor","ScreenUnused"));
    ptms_UnLoadTemplatePreview();
  }
  else
  {  
    if(strTemp == "DEFAULTTEMP")
      strTemp=g_sDefaultTemplate;
    
    strTemp = getPath( PICTURES_REL_PATH, "Para/PanelTopology/templates/"+ strTemp+ "/"+ strTemp+ ".png"  ); 
    if(strTemp=="")
    {
      strTemp="NOPREVIEW";
      //setValue("txt_template","text",getCatStr("ptms_MultiMonitor","noPreview"));
    }
  }
  
  if(strTemp!="NOPREVIEW" && strTemp!="UNUSED")
  {
    setValue("brd_preview","fill","[pattern,[fit,png," + strTemp + "]]");
    setValue("txt_info","visible",false);
  }
  else
  {
    setValue("brd_preview","fill","[solid]");
    if(strTemp=="UNUSED")
      setValue("txt_info","text",getCatStr("ptms_MultiMonitor","ScreenUnused"));
    else if(strTemp=="NOPREVIEW")
      setValue("txt_info","text",getCatStr("ptms_MultiMonitor","noPreview"));
    
    setValue("txt_info","visible",true);
    
  }
 
     
    
}

/************************************************
Name : ptms_UnLoadTemplatePreview()
*************************************************
Description:
    UnLoads the Preview 
    
Usage: in SelectScreens.pnl und in PT_parameterize.pnl und in PT_preview.pnl 
  
     
Parameters:
    none
    
Returns:
    
************************************************/
void ptms_UnLoadTemplatePreview()
{
  setValue("brd_preview","fill","[solid]");
}


/************************************************
Name : ptms_LoadInitPanel()
*************************************************
Description:
    used to open Templates on different Screens 
    
Usage: in SelectScreens.pnl und in PT_parameterize.pnl und in PT_preview.pnl 
  
     
Parameters:
    none
    
Returns:
    
************************************************/

void ptms_LoadInitPanel(int num, string sScreen, int iPanelNode = 0)
{ 
  string temp,panel,sys,template;
  int node;
  dyn_string dsPanelInfo;
  int resX;
  int resY;
  dyn_int duiConnSystems;
  dyn_string     dsfileName;
  dyn_langString dlsnodeName;
  
  
  string path = "para/PanelTopology/templates/";
  
  template = strptms_Templates[num];
  dsPanelInfo = strsplit(strptms_PanelsToLoad[num],"|");
    
  if(dsPanelInfo[1] == "DEFAULTPT")
  {
    node=1;
    sys="";
  }
  else
  {
    node=dsPanelInfo[1];
    sys=dsPanelInfo[2];
  }
  
  dpGet( "_DistConnections.Dist.ManNums", duiConnSystems );
  
  if(sys+":" == getSystemName()) //Own System
    sys="";
  
  if(sys != "" && !dynContains(duiConnSystems,getSystemId(sys+":")))  //ohter System is not Connected Load Default Panel of Own System
  {
    node=1;
    sys="";
  }
  else  // Other System and Connection to this system
    strreplace(sys,":","");
    
  resX=tptms_DisplayWidth[sScreen];
  resY=tptms_DisplayHeight[sScreen];
  
  ptnavi_InitUserInterface(sys,dsfileName,dlsnodeName);
  
  if(sys=="")
    sys=getSystemName();
  strreplace(sys,":","");
  
  if ( isModuleOpen(ptms_BuildModuleName("naviModule", sScreen)) )
  {
    string strPanel = ptms_FindProperTemplate(resX, resY, "/" + template + "/naviPanel_$W_$H_$T", template);

    RootPanelOnModule(strPanel, "Navi", ptms_BuildModuleName("naviModule", sScreen), makeDynString());
  }
  
  if ( isModuleOpen(ptms_BuildModuleName("mainModule", sScreen)) )
    pt_panelOn3((iPanelNode == 0) ? node : iPanelNode, ptms_BuildModuleName("mainModule", sScreen), sys, 0, 1); 
  
  if ( isModuleOpen(ptms_BuildModuleName("infoModule", sScreen)) )
  {
    string strPanel = ptms_FindProperTemplate(resX, resY, "/" + template + "/infoPanel_$W_$H_$T", template);

    RootPanelOnModule(strPanel, "Info",ptms_BuildModuleName("infoModule",sScreen), makeDynString());    
  }  
}


/************************************************
Name : ptms_LoadInitPanel()
*************************************************
Description:
    used to Build the different Modul names which are needed for MultiMonitoring
    
Usage: in SelectScreens.pnl und in PT_parameterize.pnl und in PT_preview.pnl 
  
     
Parameters:
    none
    
Returns:
    
************************************************/
string ptms_BuildModuleName(string sModuleName, string ModuleNumber = "1")
{
  if ( strpos(sModuleName, "_") > 0)
  {
    sModuleName=substr(sModuleName, 0, strpos(sModuleName, "_"));
  }
  sModuleName = sModuleName + "_" + ModuleNumber;
  
 return sModuleName;
}

//Function to Show error Message panel
void ptms_showErrorMessage(string messageCat, string message)
{
  string output=getCatStr(messageCat,message);
  ChildPanelOnRelativModal("vision/MessageWarning","",
          makeDynString(output),0,0);    
}


void ptms_SaveConfigToDp(string prefix = "_Default", bool overwrite = false, int iNum = 1)
{ 
    int k;  //Loop - counter
    
    //Local Variables
    dyn_string dsLConfigs,dsLUsedMonitors,dsLTemp,dsLRes,dsLPanels,dsLChar,dsLLChar,dsLRChar,dsLDT,dsLDR;
    dyn_int diLNumber;
    
    //Temorary Help Variables
    string stemp,stemp1,stemp2,stemp3,stemp4,stemp5,stemp6,stemp7;   
    string dummy = ",";
    
    iConfigNum = iNum;
    
    stemp1=stemp2=stemp3=stemp4=stemp5=stemp6=stemp7="";
   
    if(prefix!= "_Default")
    {
      if(strpos(prefix,"_")==0)
        prefix = strltrim(prefix,"_");
      
      prefix = ptnavi_getUserIdent(prefix);                 
    }
    
    if(strpos(prefix,"_")!=0) //if first char not "_" then add it
      prefix = "_"+prefix;

    if(!overwrite)
      for(k=dynlen(g_dbUsedScreens);k>g_iNumberOfScreens;k--)
      {
         dynRemove(g_dsLCharacters,k);
         dynRemove(g_dsRCharacters,k);
         dynRemove(g_dsCharacters,k);
         dynRemove(g_dsPanels,k);
         dynRemove(g_diXRes,k);
         dynRemove(g_diYRes,k);
         dynRemove(g_dsTemplates,k);
         dynRemove(g_dbUsedScreens,k);       
      }
    
    dpGet(prefix+"_UiConfiguration.ConfigNames",dsLConfigs,
          prefix+"_UiConfiguration.UsedMonitors",dsLUsedMonitors,
          prefix+"_UiConfiguration.TemplatesToLoad",dsLTemp,
          prefix+"_UiConfiguration.ScreenResolutions",dsLRes,
          prefix+"_UiConfiguration.PanelsToLoad",dsLPanels,
          prefix+"_UiConfiguration.NumberOfDisplays",diLNumber,
          prefix+"_UiConfiguration.Characters",dsLChar,
          prefix+"_UiConfiguration.CharactersLeft",dsLLChar,
          prefix+"_UiConfiguration.CharactersRight",dsLRChar,
          prefix+"_UiConfiguration.Default.DefaultTemplate",dsLDT,
          prefix+"_UiConfiguration.Default.DefaultResolution",dsLDR);
    
    //make global Variables lokal and bring them in
    //correct format to save
    dsLConfigs[iConfigNum]=g_sConfigName;   
    dsLDT[iConfigNum]= g_sDefaultTemplate+"/basePanel_$W_$H_"+g_sDefaultTemplate;
    
    if(g_iDefaultResX==0 || g_iDefaultResY==0)
      stemp = "auto";
    else if(g_iDefaultResX==0 || g_iDefaultResY==0)
      stemp = "DEFAULTRES";     
    else
      stemp = g_iDefaultResX+"x"+g_iDefaultResY;
    
    dsLDR[iConfigNum]= stemp;
    
    
    for(k=1;k<=dynlen(g_dbUsedScreens);k++)
    {
      if(k==dynlen(g_dbUsedScreens)) //Avoid Seperator "," at the end of the string
        dummy="";
        
      stemp1 +=g_dbUsedScreens[k]+dummy;
      
      if(g_dsTemplates[k]=="DEFAULTTEMP")
        stemp2 +=g_dsTemplates[k]+dummy;
      else
      {
        stemp2 +=g_dsTemplates[k]+"/basePanel_$W_$H_"+g_dsTemplates[k]+dummy;
      }
      
      
      if(g_diXRes[k]==0)      
        stemp3 += "auto"+dummy;
      else if(g_diXRes[k]== -1)  
        stemp3 += "DEFAULTRES"+dummy;
      else
        stemp3 +=g_diXRes[k]+"x"+g_diYRes[k]+dummy;

      if(dynlen(g_dsPanels) < k+1)//IM 95744
        g_dsPanels[k+1] = g_dsPanels[k];  
      stemp4 +=g_dsPanels[k]+dummy;
      stemp5 +=g_dsCharacters[k]+dummy;
      stemp6 +=g_dsLCharacters[k]+dummy;
      stemp7 +=g_dsRCharacters[k]+dummy;               
    }
    
    
    
    
    dsLUsedMonitors[iConfigNum]=stemp1;
    dsLTemp[iConfigNum]=stemp2;
    dsLRes[iConfigNum]=stemp3;
    dsLPanels[iConfigNum]=stemp4;
    dsLChar[iConfigNum]=stemp5;
    dsLLChar[iConfigNum]=stemp6;
    dsLRChar[iConfigNum]=stemp7;
    
    diLNumber[iConfigNum]=g_iNumberOfScreens;   
    
    dpSetWait(prefix+"_UiConfiguration.ConfigNames",dsLConfigs,
          prefix+"_UiConfiguration.UsedMonitors",dsLUsedMonitors,
          prefix+"_UiConfiguration.TemplatesToLoad",dsLTemp,
          prefix+"_UiConfiguration.ScreenResolutions",dsLRes,
          prefix+"_UiConfiguration.PanelsToLoad",dsLPanels,
          prefix+"_UiConfiguration.NumberOfDisplays",diLNumber,
          prefix+"_UiConfiguration.Characters",dsLChar,
          prefix+"_UiConfiguration.CharactersLeft",dsLLChar,
          prefix+"_UiConfiguration.CharactersRight",dsLRChar,
          prefix+"_UiConfiguration.Default.DefaultTemplate",dsLDT,
          prefix+"_UiConfiguration.Default.DefaultResolution",dsLDR);
}

void ptms_InitPanelGlobalsFromDp(string prefix = "_Default", int iNum = 1)
{
  //Local Variables
  dyn_string dsLConfigs,dsLUsedMonitors,dsLTemp,dsLRes,dsLPanels,dsLChar,dsLLChar,dsLRChar,dsLDT,dsLDR;
  dyn_int diLNumber;
    
  //Temorary Help Variables
  string stemp = "";
  dyn_anytype datemp;
  dyn_string dstemp;
  dyn_string dstempRes;
    
  //cstoeg: Maybe extend here with different Configurations by changing of dyn_pos over listScelector
  iConfigNum = iNum; 
  
  int k; // Loop Counter
  
  //IM 88547: stop variable is not used 
  //stop = false; //stop Logon Countdown with setting this to true
  
  if(prefix!= "_Default")
  {
    if(strpos(prefix,"_")==0)
      prefix = strltrim(prefix,"_");
      
    prefix = ptnavi_getUserIdent(prefix);                 
  }
  
  if(strpos(prefix,"_")!=0) //if first char not "_" then add it
      prefix = "_"+prefix;
  
  if(dpExists(prefix+"_UiConfiguration"))
  {   
    dpGet(prefix+"_UiConfiguration.ConfigNames",dsLConfigs,
          prefix+"_UiConfiguration.UsedMonitors",dsLUsedMonitors,
          prefix+"_UiConfiguration.TemplatesToLoad",dsLTemp,
          prefix+"_UiConfiguration.ScreenResolutions",dsLRes,
          prefix+"_UiConfiguration.PanelsToLoad",dsLPanels,
          prefix+"_UiConfiguration.NumberOfDisplays",diLNumber,
          prefix+"_UiConfiguration.Characters",dsLChar,
          prefix+"_UiConfiguration.CharactersLeft",dsLLChar,
          prefix+"_UiConfiguration.CharactersRight",dsLRChar,
          prefix+"_UiConfiguration.Default.DefaultTemplate",dsLDT,
          prefix+"_UiConfiguration.Default.DefaultResolution",dsLDR);
  }
    
    
  //There is an Existing Configuration
  if(dynlen(dsLConfigs)>=1)  
  {
    //get Config Name
    g_sConfigName = dsLConfigs[iConfigNum];
      
    //get used Monitors into dyn_bool
    stemp = dsLUsedMonitors[iConfigNum]; //true;false;true;...
    datemp = strsplit(stemp,",");   
    g_dbUsedScreens = datemp; // Used Screens 
      
    //get used Templates
    stemp = dsLTemp[iConfigNum];
    g_dsTemplates = strsplit(stemp,","); // HMINEW\basePanel_$W_$H_HMINEW
      
    for(k=1;k<=dynlen(g_dsTemplates);k++)  //make only HMINEW
    {
      dstemp = strsplit(g_dsTemplates[k],"/");
      g_dsTemplates[k]=dstemp[1];
    }
        
      
    stemp=dsLDR[iConfigNum];
    if(stemp=="auto")
    {
      g_iDefaultResX = 0;
      g_iDefaultResY = 0;
    }
    else if (stemp=="DEFAULTRES")
    {
      g_iDefaultResX = -1;
      g_iDefaultResY = -1;
    }
    else
    {
      dstemp=strsplit(stemp,"x");
      g_iDefaultResX = dstemp[1];
      g_iDefaultResY = dstemp[2];        
    }
      
    //get used Templates
    stemp=dsLRes[iConfigNum]; // 1600x1200;auto;auto;
    dstemp=strsplit(stemp,",");
      
    for(k=1;k<=dynlen(dstemp);k++)
    {
      if(dstemp[k]=="auto")
      {
         dynAppend(g_diXRes,0); //-> auto Resolution
         dynAppend(g_diYRes,0);
      }
      else
      {
        dstempRes=strsplit(dstemp[k],"x");
        if(dynlen(dstempRes) != 2)
        {
          dynAppend(g_diXRes,-1); //-1 error in given Resolution -> do DEFAULTRES
          dynAppend(g_diYRes,-1); 
        }
        else  //given Resolution
        {
          dynAppend(g_diXRes,dstempRes[1]);
          dynAppend(g_diYRes,dstempRes[2]); 
        } //end of else                 
      } //end of else
    }//end of loop
      
      
      
    //getPanelsToLoad
    stemp = dsLPanels[iConfigNum];
    g_dsPanels = strsplit(stemp,","); //Codiertet String des Panels das aufgeschaltet werden soll
                                     //Syntax: IndexofPanelTopology|System|Paramenters 
                                     //g.e.: 23|System2|$hello:gg 
                                     //      2|System1|        
     
    //getNumberofScreens
    g_iNumberOfScreens = diLNumber[iConfigNum];
      
    //getScreenCharacters
    stemp = dsLChar[iConfigNum];
    g_dsCharacters = strsplit(stemp,",");
      
    //getRScreenCharacters
    stemp = dsLLChar[iConfigNum];
    g_dsRCharacters = strsplit(stemp,",");
      
    //getRScreenCharacters
    stemp = dsLRChar[iConfigNum];
    g_dsLCharacters = strsplit(stemp,",");
           
    g_sDefaultTemplate = dsLDT[iConfigNum];
    dstemp = strsplit(g_sDefaultTemplate,"/");
    g_sDefaultTemplate = dstemp[1];
                                                             
  }
  else // Default Configuration does exist 
  {
      ptms_AppendScreen(1,"1","1","1","DEFAULTPT",-1,-1,"DEFAULTTEMP",true,true,"default_Conf");  
  }
}

void ptms_AppendScreen(int num, string LC, string RC, string C, string PN, int x, int y, string temp, bool use, bool new = false, string confn="" )
{
  if(new)
  {
    g_sConfigName = confn;
    g_iNumberOfScreens = 1;
    g_sDefaultTemplate = "DEFAULTTEMP";

    g_iDefaultResX = 0;
    g_iDefaultResY = 0;   
  }

  g_dsLCharacters[num]=LC;
  g_dsRCharacters[num]=RC;
  g_dsCharacters[num]=C;
  g_dsPanels[num]=PN;
  
  g_diXRes[num]=x;
  g_diYRes[num]=y;
  g_dsTemplates[num]=temp;
  g_dbUsedScreens[num]=use;
    
}

void ptms_showScreens(int from, int num, bool login = false)
{
  int k;
  string lc,rc,s;

  
  if(from<=num)
  {
    for(k=from;k<=num;k++)
    {
      if(dynlen(g_dsCharacters)>=k)
      {
        s=g_dsCharacters[k];
        if(s=="")
          s=k;        
      }
      else
      {
        s=k;
        
       
        ptms_AppendScreen(k,s,s,s,"DEFAULTPT",-1,-1,"DEFAULTTEMP",!login);  //!login -> because an unconfigurated screen should not be used at login
      }           
      addSymbol(myModuleName(),myPanelName(),"para/msc/msc_Screen.pnl","SCREEN_"+k,makeDynString("$ScreenNumber:"+s),
                pos_x[k],pos_y[k],0,1,1);        
    }
    k--;
  }
  else
  {
    for(k=from-1;k>num;--k) 
    {
      removeSymbol(myModuleName(),myPanelName(),"SCREEN_"+k);
      if(g_dbUsedScreens[k])
        g_iActNumberOfScreens--;
    }
  }  
  g_iNumberOfScreens = k;  // set new number of Screens
}

int ptms_getNumberOfScreens()
{
  return iptms_NumPanels;
}

string ptms_getScreenCharacterForScreen(int num)
{
  return cptms_Displays[num];
}


void ptms_createGlobals()
{  
  addGlobal("g_iNumberOfScreens",INT_VAR);
  addGlobal("g_sConfigName",STRING_VAR);
  addGlobal("g_dbUsedScreens",DYN_BOOL_VAR); // Used Screens 
  addGlobal("g_diXRes",DYN_INT_VAR);
  addGlobal("g_diYRes",DYN_INT_VAR); // Resolution of Screens
  addGlobal("g_dsTemplates",DYN_STRING_VAR);  // Templates of the specific Screens
  addGlobal("g_dsPanels",DYN_STRING_VAR);     // Panels to Load
  addGlobal("g_dsCharacters",DYN_STRING_VAR); // Characters of Screen
  addGlobal("g_dsLCharacters",DYN_STRING_VAR);
  addGlobal("g_dsRCharacters",DYN_STRING_VAR);
  addGlobal("g_iActNumberOfScreens",INT_VAR);
  addGlobal("g_sDefaultTemplate",STRING_VAR);
  addGlobal("g_iDefaultResY",INT_VAR);
  addGlobal("g_iDefaultResX",INT_VAR);
}

void ptms_removeGlobals()
{
  removeGlobal("g_iNumberOfScreens");
  removeGlobal("g_sConfigName");
  removeGlobal("g_dbUsedScreens");
  removeGlobal("g_diXRes");
  removeGlobal("g_diYRes");
  removeGlobal("g_dsTemplates");
  removeGlobal("g_dsPanels");
  removeGlobal("g_dsCharacters");
  removeGlobal("g_dsLCharacters");
  removeGlobal("g_dsRCharacters");
  removeGlobal("g_iActNumberOfScreens");
  removeGlobal("g_sDefaultTemplate");
  removeGlobal("g_iDefaultResY");
  removeGlobal("g_iDefaultResX");
}

/**************************************************
Name : ptms_InitializeSystems()
***************************************************
Description:
  This function is to be called first.
  It will read the contents of "_PanelTopology.navigation.SystemNames"
  and of the _PanelTopologyServers datapoint.
  
  All stuff is stored in global variables
  because we'll need it lateron
 
  
Usage:
  is called from the function in 'Login.ctl'
  
Parameters:
  None

Returns:
  Nothing
  
**************************************************/

void ptms_InitializeSystems()
{ 
  dyn_float  df;
  dyn_string ds;
  dyn_string strLeafsTopology;
  bool bResult;
  bool bOverallResult = true;      // Overall result is TRUE sofar
  
 
  // Get the remote server names
  if( dpExists( "_PanelTopology.navigation.SystemNames" ))
  {
    dpGet("_PanelTopology.navigation.SystemNames", ptms_ServerNames );
    for (int i = 1; i <= dynlen(ptms_ServerNames); i++)
    {
      ptms_ServerIds[i]=getSystemId(ptms_ServerNames[i]+":");          // Remove the :
    }
  }
  
  // when the variable ksar_ServerNames is empty, then this means:
  // - The datapoint did not exists
  // - The datapoint was empty
  // When it is empty, then we just add our own local server
  if( !dynlen( ptms_ServerNames ))
  {
    // get all system names and system numbers that we know  
    getSystemNames ( ptms_ServerNames, ptms_ServerIds ); // Get system names with:
      
    // When we still have no server names
    // then it is likely that we are not distributed at all
    // we then just take our own system name
    if( !dynlen( ptms_ServerNames ))
    {
      dynAppend( ptms_ServerNames, getSystemName() );
      dynAppend( ptms_ServerIds, getSystemId());   
    }
  }

  for (int i = 1; i <= dynlen(ptms_ServerNames); i++)
  {
      strreplace(ptms_ServerNames[i], ":", "" );         // Remove the :
  }
  
  
  ptms_CheckServerOnlineLogin();
    
  if (ptms_bDebug) DebugN( "ptms_InitializeSystems() has found server names : " + ptms_ServerNames );
  
  if(!getUserPermission(4))
    return;
  //Copping Datapoints
  // Get the layout of our reference datapoints
  ptms_DPLayout_GetLayout( "_PanelTopology", strLeafsTopology );
  
  for( int t = 1; t <= dynlen( ptms_ServerNames ); t++)
  { 
      bResult = true;
      if( ptms_CollectOneDatapoint( strLeafsTopology , ptms_ServerNames[t], "_PanelTopology", "_PanelTopology", true) != ptms_RESULT_OK) bResult = false;
      
      // When one datapoint failed, then the overall result is bad
      bOverallResult &= bResult;

  }
  if(!bOverallResult)
    DebugN( "!!!!Error while coping Dps in ptms_MulitServer afterLogin" );      
}

// *************************************
// Name : ptms_CollectOneDatapoint
// *************************************
// Description:
//    Will make a local copy of a remote datapoint.
// Returns:
//    None
// **************************************

int ptms_CollectOneDatapoint(
  dyn_string &strLeafs,          // The leafs that need to be copied
  string strServerName,
  string strType,                // The data type ( for making the local instance )
  string strDatapoint,            // The ctual datapoint to be created
  bool bRename                    // TRUE -> server name is added to make datapoint unique
)
{
  // Local data
  string strLocalDatapoint;      // Determine the name of the local copy
  string strLocalDatapointDPCreate;
  dyn_string strSource;
  dyn_string strTarget;
  dyn_anytype dData;
  time t1 = getCurrentTime();
  int iResult;
  
  if( !dynlen( strLeafs )){       // When strLeafs is empty
    if (ptms_bDebug) DebugN( "ms Local datapoint type : " + strType + " is unknown." );
    return ptms_RESULT_FAILED;    // then we have no local copy ( that is : we do not have the local datapoint type )
  }  
  
  // Determine the name of the local datapoint
  if( bRename )
  {  
    strLocalDatapoint = getSystemName() + strServerName + strDatapoint;
    strLocalDatapointDPCreate = strServerName + strDatapoint;
  }  
  else
  {
    strLocalDatapoint = getSystemName() + strDatapoint;
    strLocalDatapointDPCreate = strDatapoint;
  }  
  
  // Construct the full name of the remote datapoint by adding the system name
  strDatapoint = strServerName + ":" + strDatapoint;

  // When the remote and local are actually the same datapoint
  // then we should just exit !
  if( strDatapoint == strLocalDatapoint ){
    if (ptms_bDebug) DebugN( "ms Not necessary to copy " + strDatapoint + "->" + strLocalDatapoint );
    return ptms_RESULT_OK;
  }  
  
  if (ptms_bDebug) DebugN( "ptms_CollectOneDatapoint() " + strDatapoint + "-> " + strLocalDatapoint );

  // When we already have a local copy of the remote datapoint
  // then we compare the timestamps of the remote and local copy
  // When they are identical, then we are ready  

   // when the timestamp of the local and the remote system are identical
  // then we do not need to collect the datapoint
  iResult = ptms_EqualTime( t1, strLocalDatapoint, strDatapoint, strLeafs[1] );

  if( iResult == ptms_RESULT_IDENTICAL )
  {                                                      // Datapoints are identical
    if (ptms_bDebug) DebugN( "ms Datapoints are identical " + strDatapoint + "->" + strLocalDatapoint );
    return ptms_RESULT_OK;                               // so say, 'ok'
  }  
  
  if( iResult == ptms_RESULT_FAILED )
  {  
    if (ptms_bDebug) DebugN( "ms Failed to read timestamps of remote system." );
    return ptms_RESULT_FAILED;
  }
      
  // We did not have a local copy, or the timestamps were different
  // so we:
  // - Do a dpGet() to get the remote data
  // - do a dpCreate() to get a local copy
  
  for( int t = 1; t <= dynlen( strLeafs ); t++)
  {
    strSource[t] =  strDatapoint      + "." + strLeafs[t];
    strTarget[t] =  strLocalDatapoint + "." + strLeafs[t];
    
    
  }

  if( !dpExists( strDatapoint )){        // When remote datapoint does not exist
    if (ptms_bDebug) DebugN( "ms Can't read remote datapoint : " + strDatapoint );
    return ptms_RESULT_FAILED;           // then, time to exit
  }  
  
  // Do a dpGet() to get all elements of the remote datapoint
  // when the dpGet() fails, then we just exit and don't make the local datapoint !
  if( dpGet( strSource, dData ) != -1 )
  {
      
  }  
  else{    
    if (ptms_bDebug) DebugN( "ms dpGet() failed for remote datapoint " + strDatapoint );
    return ptms_RESULT_FAILED;
  }  
  
  // Make a lcoal copy of the datapoint
  if(!dpExists( strLocalDatapointDPCreate ))
    dpCreate( strLocalDatapointDPCreate, strType );
  
  // Wait and make sure that the dp really exists
  while( !dpExists( strLocalDatapointDPCreate ))
    delay( 0, 100 );

  // Now write the local datapoint
  dpSetTimed( t1, strTarget, dData );    
  
  return ptms_RESULT_OK;
}      


// *************************************
// Name : ptms_EqualTime
// *************************************
// Description:
//   Will compare the timestamp of the remote datapoint
//   versus the timestamp of the local datapoint.
//
//   When the timestamps are identical then nothing is done.
//   ( because we already have a valid local copy )
//
// Returns:
//    TRUE when the timestamps have been read, and when they are identical
//
// **************************************

int ptms_EqualTime( 
  time &t,    
  string strLocalDatapoint,         // Name of local datapoint
  string strDatapoint,               // Name of rmeote dp
  string strLeaf                    // The first leaf that we use to read the timestamp
)
{
  // Locla data
  time t1;
  time t2;

  if( !dpExists( strDatapoint + "." + strLeaf )){     // When the remote datapoint does not exist
    if (ptms_bDebug) DebugN( "ms Remote datapoint " + strDatapoint + " does not exist" );
    return ptms_RESULT_FAILED;                        // then we cant't continue
  }  
  
  
  // Try to obtain the first timestamp
  if( dpGet( strDatapoint + "." + strLeaf + ":_original.._stime", t1 ) == -1 )
    return ptms_RESULT_FAILED;  

  // Return the timestamp of the remote datapoint
  t = t1;
  
  if( !dpExists( strLocalDatapoint + "." + strLeaf ))      // When the local datapoint does not exist
    return ptms_RESULT_OK;                                  // then just exit
  
  // Try to obtain the first timestamp
  if( dpGet( strLocalDatapoint + "." + strLeaf + ":_original.._stime", t2 ) == -1 )
  {
    if (ptms_bDebug) DebugN( "ms Could not get timestamp of LOCAL system : " +  strLocalDatapoint );
    
    // We did not get the timestamp of the local datapoint
    // probably because it doesn't exists
    return ptms_RESULT_OK;  
  }  

  if( t1 == t2 )                      // When timestamps are the same
     return ptms_RESULT_IDENTICAL;    // then datapoint is identical
  else
     return ptms_RESULT_OK;            // Just continue. Timestamps are not identical

}  
    

void ptms_CheckServerOnlineLogin()
{
  dyn_int iOnline;
  dyn_string strOnline;
  dyn_string strOffline;
  
    
  dpGet( "_DistConnections.Dist.ManNums", iOnline );
  
  // Which servers are currently online
  if (ptms_bDebug) DebugN( "ptms_CheckServerOnline() has found following servers to be online" + iOnline );
  
  for( int t = 1; t <= dynlen( ptms_ServerNames ); t++)
  {   
    if( !(ptms_ServerIds[t] == getSystemId()) && !(dynContains( iOnline, ptms_ServerIds[t] ) > 0 ) )
    {
      dynRemove(ptms_ServerIds,t);
      dynRemove(ptms_ServerNames,t); 
    }
  }
}

// **************************************
// Name : ptms_DPLayout_GetLayout()
// **************************************
// Description:
//		See above.
//		Calls 'ptms_DPLayout_GetLayoutPlusType'
//		to get the actual structure of the requested dp type.
//
// Returns:
//		None
// **************************************


void ptms_DPLayout_GetLayout(
  string strDPType,		        // Datapoint type you want to get information for
  dyn_string    &strLeafs		// Dyn_string that receives the requested information
)
{
  // Local data
  dyn_int       iLeafTypes;	        // Dyn_int that receives the data type of every leaf in your datapoint type

  if( dynlen( dpTypes( strDPType )) == 0 )
  {
    if (ptms_bDebug) DebugN( "Type : " + strDPType + " does noet exists" );
    return; 
  }
  
  // Note:
  // 'iLeafTypes' is just needed temporarily because
  // we need to saisy the function 'ptms_DPLayout_GetLayoutPlusType()'

  ptms_DPLayout_GetLayoutPlusType(
    strDPType,				// Datapoint type you want to get information for
    strLeafs,				// Dyn_string that receives the requested information
    iLeafTypes );			// Dyn_int that receives the data type of every leaf in your datapoint type

}

// **************************************
// Name : ptms_DPLayout_GetLayoutPlusType()
// **************************************
// Description:
//		gets the layout of one datapoint.
//		When en element of type TYPEREF is found
//		then this function is called recursively.
//
//
// Returns:
//		None
// **************************************

void ptms_DPLayout_GetLayoutPlusType(
  string 				strDPType,		// Datapoint type you want to get information for
  dyn_string    &strLeafs,		// Dyn_string that receives the requested information
  dyn_int       &iLeafTypes,	// Dyn_int that receives the data type of every leaf in your datapoint type
  string strPrefix = ""				// Needed because we call our selves recursively
)
{
  // Local data
  dyn_dyn_string names;
  dyn_dyn_int    types;
  int            iLeaf;
  dyn_string     strLeafElements;
  int            iType;
  int            iLeafElement;
  string         strOneLeaf;
  int            iSearch;
  int            iMaxLeaves;
  string         strEmbeddedObject;
  
  dyn_int  ShowLeaves = makeDynInt( 
    DPEL_CHAR,
    DPEL_UINT,
    DPEL_INT,
    DPEL_ULONG,
    DPEL_LONG,
    DPEL_FLOAT,
    DPEL_BOOL,
    DPEL_BIT32,
    DPEL_BIT64,
    DPEL_STRING,
    DPEL_TIME,
    DPEL_DPID,
    DPEL_LANGSTRING,
    DPEL_TYPEREF,
    DPEL_BLOB,

    DPEL_DYN_CHAR,
    DPEL_DYN_UINT,
    DPEL_DYN_INT,
    DPEL_DYN_ULONG,
    DPEL_DYN_LONG,
    DPEL_DYN_FLOAT,
    DPEL_DYN_BOOL,
    DPEL_DYN_BIT32,
    DPEL_DYN_BIT64,
    DPEL_DYN_STRING,
    DPEL_DYN_TIME,
    DPEL_DYN_DPID,
    DPEL_DYN_LANGSTRING,
    DPEL_DYN_BLOB );
    
  dynClear( names );
  dynClear( types );
     
  // Get the layout of the specified object type  
  dpTypeGet( strDPType,names,types);

  // Iterate through all leafs 
  for( iLeaf =1; iLeaf <= dynlen( names ); iLeaf++){
          
    // Get the elements of one leaf           
    strLeafElements = names[ iLeaf ];
      
    // The last element of the "types" array holds the actual
    // data type of this leaf
    if( dynlen( types[iLeaf]  ))
      iType = types[iLeaf][ dynlen(types[iLeaf])];
    else
      iType = 0;  

      
    if( dynContains( ShowLeaves, iType ) >= 1 ){
      
      // Iterate through the various elements of one leaf
      for( iLeafElement=1; iLeafElement <= dynlen( strLeafElements ); iLeafElement++){
        
        // When one element of a leaf is empty, then look up the previous leafs
        // until you find a non-empty space
        if( strLeafElements[ iLeafElement ] == ""){
      
          for( iSearch = iLeaf; (iSearch >=1) && (strLeafElements[ iLeafElement ] == ""); iSearch --){

            if( dynlen( names[iSearch] ) >= iLeafElement ){
              if( names[iSearch][iLeafElement] != ""){
                strLeafElements[ iLeafElement ] = names[iSearch][iLeafElement];
              }  
            }  
              
          }
        }
      }

  
      strOneLeaf = strPrefix;
        
      if( iType == DPEL_TYPEREF )											// When it is a typeref
        iMaxLeaves = dynlen( strLeafElements ) - 1;		// then last element contains name of "reffed" datapoint
      else	
        iMaxLeaves = dynlen( strLeafElements );
          
      for( iLeafElement=2; iLeafElement <= iMaxLeaves; iLeafElement++){
        if( iLeafElement > 2 )
          strOneLeaf += ".";
        strOneLeaf += strLeafElements[ iLeafElement ];
      }

      dynAppend( strLeafs, strOneLeaf );	// Add the full "path" of the leaf
      dynAppend( iLeafTypes, iType );			// Add the data type of the leaf


      if( iType == DPEL_TYPEREF ){
        // We've just determined that this is a typeref
          
        strEmbeddedObject = strLeafElements[ dynlen( strLeafElements ) ];
          
        // Call recursively for the embedded object
        ptms_DPLayout_GetLayoutPlusType(strEmbeddedObject, strLeafs, iLeafTypes, strOneLeaf + "." );
      }
    }  
  }    
}


int ptms_upgradePtTemplates()
{  
  //BEGIN OF: PART 1
  //Filling the new description DPE with " ", so that wie have the same number
  //of Dyn - Elements like in name
  dyn_langString name;
  dyn_langString dLaStrtemp;
  langString latemp = " ";
  string stemp = " ";
  dyn_string link;
  int error;
  
  //no paneltopology is used
  if(!dpExists("_PanelTopology"))
    return 1; 
  
  error=dpGet("_PanelTopology.nodeName:_online.._value", name);
  if(error<0)
    return -1;
  
  for(int i=1; i<=dynlen(name); i++)
  {
    dynAppend(dLaStrtemp, latemp);
    dynAppend(link, stemp);  
  }
    
  error=dpSetWait("_PanelTopology.description", dLaStrtemp,
                  "_PanelTopology.locality", dLaStrtemp,
                  "_PanelTopology.functionality", dLaStrtemp,
                  "_PanelTopology.panelLink", link);
  
  if(error<0)
    return -2;
  
  //END OF: PART 1
  //------------------------------------------------------------------
  //BEGIN: PART 2
  //Copping old templates to new template folder under 3.8 
  
  int iXres,iYres;
  int iRes;
  string sPathOld;
  string sPathNew;
  bool bErr = true;
  int iCurrentTemplateNum;
 
  error = dpGet("_PanelTopology.template.xResolution",iXres,
                "_PanelTopology.template.yResolution",iYres,
                "_PanelTopology.template.templateNumber",iCurrentTemplateNum);
  
  if(error <0)
    return -3;
  
  if(iCurrentTemplateNum != 4)
    switch(iXres)
    {
      case 1600: iRes = 1; break;
      case 1280: iRes = 2; break;
      case 1024: iRes = 3; break;
      default: iRes = 4; break; 
    }
  
  string sTemplatePath = PROJ_PATH+"panels/para/PanelTopology/templates/"; 
  
    
  string sTempOld;
  string sTempNew = "_"+iXres+"_"+iYres+"_TEMPLATE"+iCurrentTemplateNum;
  
  if(iCurrentTemplateNum != 4)
    sTempOld = "_"+iRes+"_"+iCurrentTemplateNum;
  else
    sTempOld = "";
 
  if(iCurrentTemplateNum != 4)
    sPathOld = sTemplatePath+"basePanel"+sTempOld+".pnl";
  else
    sPathOld = PROJ_PATH+"panels/basePanel_user.pnl";
    
  sPathNew = sTemplatePath+"TEMPLATE"+iCurrentTemplateNum+"/basePanel"+sTempNew+".pnl";
  
  if(access(sPathOld,F_OK) >= 0)
    if(access(sPathNew,F_OK) < 0)
      bErr=copyFile(sPathOld,sPathNew);
  
  if(!bErr)
    return -4;
  
  if(iCurrentTemplateNum != 4)
    sPathOld = sTemplatePath+"naviPanel"+sTempOld+".pnl";
  else
    sPathOld = sTemplatePath+"naviPanel_user.pnl";
  sPathNew = sTemplatePath+"TEMPLATE"+iCurrentTemplateNum+"/naviPanel"+sTempNew+".pnl";
  
  if(access(sPathOld,F_OK) >= 0)
    if(access(sPathNew,F_OK) < 0)
      bErr=copyFile(sPathOld,sPathNew);
  
  if(!bErr)
    return -5;
  
  if(iCurrentTemplateNum != 4)
    sPathOld = sTemplatePath+"infoPanel"+sTempOld+".pnl";
  else
    sPathOld = sTemplatePath+"infoPanel_user.pnl";
  sPathNew = sTemplatePath+"TEMPLATE"+iCurrentTemplateNum+"/infoPanel"+sTempNew+".pnl";
  
  if(access(sPathOld,F_OK) >= 0)
    if(access(sPathNew,F_OK) < 0)
      bErr=copyFile(sPathOld,sPathNew);
  
  if(!bErr)
    return -6;
    
  //
  //END OF: PART 2
  //-------------------------------------------------------------------
  //BEGIN: PART 3
  //Create a new _Default _UiConfiguration Datapoint and fill it with the values of 
  //existing PT
  
  dyn_int diNumberOfScreens;
  dyn_string dsConfigName,dsUsedScreens,dsTemplates,dsPanels,dsResolution;
  dyn_string dsCharacters,dsLCharacters,dsRCharacters,dsDefaultTemplate,dsDefaultResolution;
  string dp = "_Default_UiConfiguration";
  
  /* cstoeg: for testing until final verion
  
  // Creating new Dp
  if(!dpExists(dp))
  {
    error=dpCreate("_Default_UiConfiguration","_Ui_Config");
    if(error<0)
      return -7;
    while(!dpExists("_Default_UiConfiguration"))
      delay(0,100);
  }
  else
  {
    error=dpGet(dp+".ConfigNames",dsConfigName);
    
    if(error < 0)
      return -8;    
    
    if(dynlen(dsConfigName))
      return 1;  //do not overwrite if exists
  }  
  
  dsConfigName=makeDynString();
  
    
  dsConfigName[1]            =    "default_Conf";
  dsUsedScreens[1]          =    "TRUE";
  dsTemplates[1]             =    "DEFAULTTEMP";
  dsResolution[1]            =    "DEFAULTRES";
  dsPanels[1]                =    "DEFAULTPT";
  diNumberOfScreens[1]       =    1;
  dsCharacters[1]            =    "1";
  dsLCharacters[1]           =    "1";
  dsRCharacters[1]           =    "1";
  dsDefaultTemplate[1]       =    "TEMPLATE"+iCurrentTemplateNum+"/basePanel_$W_$H_TEMPLATE"+iCurrentTemplateNum;
  dsDefaultResolution[1]     =    iXres+"x"+iYres;
  
  
  
  error=dpSetWait(dp+".ConfigNames",dsConfigName,
                  dp+".UsedMonitors",dsUsedScreens,
                  dp+".TemplatesToLoad",dsTemplates,
                  dp+".ScreenResolutions",dsResolution,
                  dp+".PanelsToLoad",dsPanels,
                  dp+".NumberOfDisplays",diNumberOfScreens,
                  dp+".Characters",dsCharacters,
                  dp+".CharactersLeft",dsLCharacters,
                  dp+".CharactersRight",dsRCharacters,
                  dp+".Default.DefaultTemplate",dsDefaultTemplate,
                  dp+".Default.DefaultResolution",dsDefaultResolution);
  if(error<0)
    return -9;
    
  */
  
  //
  //END OF: PART 3
 //-----------------------------------------------------------------------------------------

  
  return 2; //return OK
}


/************************************************
Name : ptms_UserDefinedInitFunctions()
*************************************************
Description:
Function which is called in the basePanel of each Template
to allow costumer to define his own init - Functions
For example after upgrade to 3.8 from earlier Version    
    
Usage: 
--  
     
Parameters:
none
    
Returns:
nothing
    
************************************************/
void ptms_UserDefinedInitFunctions()
{
  
  //ToDoPlease define your init Functions here
  
}

dyn_bool ptms_getUsedScreens(string prefix = "_Default", int iNum = 1)
{
  dyn_string dsUsed;
  
  if(prefix!= "_Default")
  {
    if(strpos(prefix,"_")==0)
      prefix = strltrim(prefix,"_");
      
    prefix = ptnavi_getUserIdent(prefix);                 
  }
  
  if(strpos(prefix,"_")!=0) //if first char not "_" then add it
    prefix = "_"+prefix;
  
  dpGet(prefix + "_UiConfiguration.UsedMonitors", dsUsed);
  
  if(dynlen(dsUsed) >= iNum)
    dsUsed = strsplit(dsUsed[iNum], ",");
  else
    dsUsed = strsplit(dsUsed[1], ",");
  
  return (dyn_bool)dsUsed;
}
