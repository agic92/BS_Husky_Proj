// ----------------------------------------------------------------------------
// creator: Joshua Hercher 9.1.2018
// purpose: Controller class for LoginFramework
// ----------------------------------------------------------------------------

#uses "login"
#uses "login_internal" // used by openMultiMonitorPara
#uses "classes/auth/OaAuthUI"
#uses "classes/CommandInterface"
#uses "msc_multiScreening"        // Used by afterLogin for 'msc_deleteFav'
#uses "classes/loginFramework/LoginFrameworkChildView"
#uses "classes/loginFramework/LoginFrameworkView"

/**
 * const variables to access corresponding properties of UI elements
 */
const string TEXT = "text";
const string ENABLED = "enabled";
const string TOOLTIP = "toolTipText";
const string VISIBLE = "visible";

/**
 * enum containing the states the LoginFramework can be in
 * the enum is sorted by order of appearance, meaning SYSTEMUSENOTIFICATION follow LOGIN
 * and CLOSE follows SYSTEMUSENOTIFICATION
 * The enum is used to load the correct panel when moving forward or back in the Framework.
 */
enum LoginFrameworkState
{
  LOGIN,
  SYSTEMUSENOTIFICATION,
  CLOSE
};

/**
 * The LoginFrameworkController class
 * implements the controller logic to control the panels
 * This class is a mediator between the different panels (parent and child)
 *
 * This class is also a singleton meaning only one instance exists at any time
 *
 * This class is part of a simplified MVC pattern each panel receives the instance of this class
 * A panel must pass an instance to this class by using the setLoginFrameworkChildView()
 * using setLoginFrameworkChildView()
 * The View classes must be a representation of the panel (model) they represent so that function calls are
 * always defined
 *
 * @author jhercher
 */
class LoginFrameworkController
{
  //singleton instance
  static private shared_ptr<LoginFrameworkController> instance;
  private LoginFrameworkView m_loginFrameworkView;
  private shared_ptr<LoginFrameworkChildView> m_loginFrameworkChildView; //shared_ptr because each child implements its own subclass
  private shared_ptr<OaAuthUI> m_ui;
  private bool m_useUserLanguage = TRUE;
  private bool m_openMonitorConfiguration = FALSE;
  private LoginFrameworkState m_state = LoginFrameworkState::LOGIN; //framework always starts with Login
  private string m_panel;
  private string m_module;
  private dyn_string m_dollar;

  /**
   * @author jhercher
   *
   * Constructor of this class
   * must be private to accomodate Singleton pattern
   */
  private LoginFrameworkController(){}

  /**
   * @author jhercher
   *
   * This function returns the instance of this class. In case no instance has been created yet
   * a new instance is created otherwise the allready created instance is returned
   *
   * @return shared_ptr<LoginFrameworkController> instance of class LoginFrameworkController
   */
  static public shared_ptr<LoginFrameworkController> getInstance()
  {
    if(instance == nullptr)
    {
      instance = new LoginFrameworkController();
    }

    return instance;
  }

  /**
   * @author jhercher
   *
   * functions passes the View of the base panel to the controller
   *
   * @param LoginFrameworkView loginFrameworkView: View representation of the base panel
   */
  public void setLoginFrameworkView(LoginFrameworkView loginFrameworkView)
  {
    m_loginFrameworkView = loginFrameworkView;
  }

  /**
   * @author jhercher
   *
   * function passes the View of the child panel to the controller and deletes the previous child view
   * from the member variable. This is done because at any time only one childview must be present and
   * it must the corresponding child view of the child panel
   * At the end of the function the language is set so the child panel loads in the active language
   *
   * @param shared_ptr<LoginFrameworkChilView> loginFrameworkChildView: view object representing the child panel
   */
  public void setLoginFrameworkChildView(shared_ptr<LoginFrameworkChildView> loginFrameworkChildView)
  {
    m_loginFrameworkChildView = nullptr; //object expects an object of the previously saved subtype here so we need to remove it
    m_loginFrameworkChildView = loginFrameworkChildView;

    if(!m_loginFrameworkView.isInitialized())
    {
      this.initializeLanguage();
      m_loginFrameworkView.setInitialized(TRUE);
    }

    this.setLanguage();
  }

  /**
   * @author jhercher
   *
   * function saves an OaAuthUI object to the controller instance, this must be the same instance that is used
   * by the login panel.
   * This provides full functionality of the class based authentication process.
   * The shared_ptr is used to guarantee that the same instance as in the login panel is used
   *
   * @param shared_ptr<OaAuthUI> ui: object of the OaAuthUI class
   */
  public void setOaAuthUI(shared_ptr<OaAuthUI> ui)
  {
    m_ui = nullptr;
    m_ui = ui;
  }

  /**
   * @author jhercher
   *
   * function returns the member variable m_ui
   *
   * @return shared_ptr<OaAuthUI>: object of type OaAuthUI
   */
  public shared_ptr<OaAuthUI> getUI()
  {
    return m_ui;
  }

  /**
   * @author jhercher
   *
   * function transitions the internal state to the next state
   * if the state was LOGIN the next state depends on whether sysusenotifications are activated or not
   * the state after SYSTEMUSENOTIFICATION must be CLOSE
   * There is no state after CLOSE
   */
  private void nextState()
  {
    switch(m_state)
    {
      case LoginFrameworkState::LOGIN:
        if(this.useSystemNotification())
        {
          m_state = LoginFrameworkState::SYSTEMUSENOTIFICATION;
        }
        else
        {
          m_state = LoginFrameworkState::CLOSE;
        }
        break;
      case LoginFrameworkState::SYSTEMUSENOTIFICATION:
        m_state = LoginFrameworkState::CLOSE;
        break;
      default:
        break;
    }
  }

  /**
   * @author jhercher
   *
   * function transitions internal state to the previous state
   * if the state was SYSTEMUSENOTIFICATION the previous state could be CLOSE or LOGIN depending if the
   * UI runs locally or is connected via serversideauthentication
   * the previous state of LOGIN is CLOSE
   * CLOSE has no previous state.
   */
  private void previousState()
  {
    switch(m_state)
    {
      case LoginFrameworkState::SYSTEMUSENOTIFICATION:
        m_state = LoginFrameworkState::LOGIN;
        break;
      case LoginFrameworkState::LOGIN:
        m_state = LoginFrameworkState::CLOSE;
        break;
      default:
        break;
    }
  }

  /**
   * @author jhercher
   *
   * The function allows to set the current state of the login process manually.
   *
   * @param LoginFrameworkState state
   */
  public void setState(LoginFrameworkState state)
  {
    m_state = state;
  }

  /**
   * @author jhercher
   *
   * function returns the current state of the login process saved in member variable m_state
   *
   * @return LoginFrameworkState: member variable m_state
   */
  public LoginFrameworkState getState()
  {
    return m_state;
  }

  /**
   * @author jhercher
   *
   * function set the panel that should be opened after the login process
   *
   * @param string panel relative path to panel
   */
  public void setPanel(string panel)
  {
    m_panel = panel;
  }

  /**
   * @author jhercher
   *
   * function set the module that should be opened after the login process
   *
   * @param string module name of the module
   */
  public void setModule(string module)
  {
    m_module = module;
  }

  /**
   * @author jhercher
   *
   * function set the dollar parameters for the panel that is opened after the login process
   *
   * @param string dollar dollar parameters as string
   * @param string delimiter optional parameter to change delimiter when coverting from string to dyn_string
   */
  public void setDollar(string dollar, string delimiter = "|")
  {
    m_dollar = stringToDynString(dollar, delimiter);

    for(int i = 1; i <= dynlen(m_dollar); i++)
    {
      dyn_string tempDollar = stringToDynString(m_dollar[i], ":");
      if(dynlen(tempDollar) == 2)
      {
        m_dollar[i] = "$" + m_dollar[i];
      }
    }
  }

  /**
   * @author jhercher
   *
   * function sets the member variable m_useUserLanguage which determines if the UI should be startet
   * with the selected language or the language saved in the user datapoint
   *
   * @param bool useUserLanguage: TRUE if saved language should be used FALSE if selected language should be used
   */
  public void setUseUserLanguage(bool useUserLanguage)
  {
    m_useUserLanguage = useUserLanguage;
  }

  /**
   * @author jhercher
   *
   * funciton sets the member variable m_openMonitorConfiguration which determines if the monitor settings
   * dialog should be opened before starting the HMI
   *
   * @param bool openMonitorConfiguration: TRUE if panel should be opened, FALSE if panel should not be opened
   */
  public void setOpenMonitorConfiguration(bool openMonitorConfiguration)
  {
    m_openMonitorConfiguration = openMonitorConfiguration;
  }

  /**
   * @author jhercher
   *
   * function calls the frameworkView to set the enabled state of the element btn_accept
   *
   * @param bool enabled: TRUE enabled, FLASE not enabled
   */
  public void setBtnAcceptEnabled(bool enabled)
  {
    m_loginFrameworkView.setObjectEnabled(m_loginFrameworkView.getBtnAccept(), enabled);
  }

  /**
   * @author jhercher
   *
   * function calls the frameworkView to set the text of the element btn_accept
   *
   * @param string text: text to be displayed on button
   */
  public void setBtnAcceptText(string text)
  {
    m_loginFrameworkView.setObjectText(m_loginFrameworkView.getBtnAccept(), text);
  }

  /**
   * @author jhercher
   *
   * function calls the frameworkView to set the tooltip of the element btn_accept
   *
   * @param string toolTip: tooltip to be displayed on when hovering button
   */
  public void setBtnAcceptToolTip(string toolTip)
  {
    m_loginFrameworkView.setObjectToolTip(m_loginFrameworkView.getBtnAccept(), toolTip);
  }

  /**
   * @author jhercher
   *
   * function calls the frameworkView to set the visible state of the element btn_accept
   *
   * @param bool visible: TRUE visible, FLASE not visible
   */
  public void setBtnAcceptVisible(bool visible)
  {
    m_loginFrameworkView.setObjectVisible(m_loginFrameworkView.getBtnAccept(), visible);
  }

  /**
   * @author jhercher
   *
   * function calls the frameworkView to set the enabled state of the element btn_cancle
   *
   * @param bool enabled: TRUE enabled, FLASE not enabled
   */
  public void setBtnCancelEnabled(bool enabled)
  {
    m_loginFrameworkView.setObjectEnabled(m_loginFrameworkView.getBtnCancel(), enabled);
  }

  /**
   * @author jhercher
   *
   * function calls the frameworkView to set the text of the element btn_cancle
   *
   * @param string text: text to be displayed on button
   */
  public void setBtnCancelText(string text)
  {
    m_loginFrameworkView.setObjectText(m_loginFrameworkView.getBtnCancel(), text);
  }

  /**
   * @author jhercher
   *
   * function calls the frameworkView to set the tooltip of the element btn_cancle
   *
   * @param string toolTip: tooltip to be displayed on when hovering button
   */
  public void setBtnCancelToolTip(string toolTip)
  {
    m_loginFrameworkView.setObjectToolTip(m_loginFrameworkView.getBtnCancel(), toolTip);
  }

  /**
   * @author jhercher
   *
   * function calls the frameworkView to set the visible state of the element btn_cancle
   *
   * @param bool visible: TRUE visible, FLASE not visible
   */
  public void setBtnCancelVisible(bool visible)
  {
    m_loginFrameworkView.setObjectVisible(m_loginFrameworkView.getBtnCancel(), visible);
  }

  /**
   * @author jhercher
   *
   * function calls the frameworkView to set the items of the language combobox
   *
   * @pram dyn_string items: containing all available languages
   */
  public void setCmbBxLanguageItems(dyn_string items)
  {
    m_loginFrameworkView.setCmbBxLanguageItems(items);
  }

  /**
   * @author jhercher
   *
   * function is called when the selected language in the language combobox is changed
   * the function then changes the current language index
   *
   * @param string language: language identifier (e.g. "de_AT.utf8")
   */
  public void setCmbBxLanguageChanged(string language)
  {
    int langIndex = getLangIdx(language);
    m_loginFrameworkView.setLangIndex(langIndex);
  }

  /**
   * @author jhercher
   *
   * function calls the frameworkView to set the visible state of the element txt_platform
   *
   * @param bool visible: TRUE visible, FLASE not visible
   */
  public void setTxtPlatformVisible(bool visible)
  {
    m_loginFrameworkView.setObjectVisible(m_loginFrameworkView.getTxtPlatform(), visible);
  }

  /**
   * @author jhercher
   *
   * function calls the frameworkView to set the visible state of the element txt_version
   *
   * @param bool visible: TRUE visible, FLASE not visible
   */
  public void setTxtVersionVisible(bool visible)
  {
    m_loginFrameworkView.setObjectVisible(m_loginFrameworkView.getTxtVersion(), visible);
  }

  /**
   * @author jhercher
   *
   * function calls the frameworkView to set the visible state of the element txt_welcome
   *
   * @param bool visible: TRUE visible, FLASE not visible
   */
  public void setTxtWelcomeVisible(bool visible)
  {
    m_loginFrameworkView.setObjectVisible(m_loginFrameworkView.getTxtWelcome(), visible);
  }

  /**
   * @author jhercher
   *
   * function is called when clicking the btn_action button.
   * the state is transitioned to the next state and the action method of the child panel
   * is executed
   */
  public void doContinue()
  {
    this.nextState();
    m_loginFrameworkChildView.doContinue();
  }

  /**
   * @author jhercher
   *
   * function is called when clicking the btn_cancle button.
   * the state is transition to the previous state and the cancle method of the child
   * panel is executed
   */
  public void doCancel()
  {
    this.previousState();
    m_loginFrameworkChildView.doCancel();
  }

  /**
   * @author jhercher
   *
   * function loads the given panel as child panel into the base panel, if another child panel
   * already exists it is removed first.
   *
   * @param string panel: the panel which should be added as child panel
   * @param dyn_string dollars: optional parameter dollar parameters that are used in the childpanel
   */
  public void switchPanel(string panel, dyn_string dollars = makeDynString())
  {
    m_loginFrameworkView.switchPanel(panel, dollars);
  }

  /**
   * @author jhercher
   *
   * function delegates the openHelp call to the child panel which opens the help with the
   * keyword fitting the context. E.g. SystemUseNotification panel and login panel open a different
   * page of the online help
   */
  public void openHelp()
  {
    m_loginFrameworkChildView.openHelp();
  }

  /**
   * @author jhercher
   *
   * function returns the index of the selected language
   *
   * @return int: index of selected language
   */
  public int getLangIndex()
  {
    return m_loginFrameworkView.getLangIndex();
  }

  /**
   * @author jhercher
   *
   * function sets the selected language for all objects in the views/panels
   * this is not done with switchlang() because it would open and close the panel
   */
  public void setLanguage()
  {
    m_loginFrameworkView.setLanguage();
    m_loginFrameworkChildView.setLanguage(this.getLangIndex());
  }

  /**
   * @author jhercher
   *
   * function returns if system use notifications are used or not
   *
   * @return bool: TRUE if SUN is used, FALSE if SUN is not used
   */
  public bool useSystemNotification()
  {
    bool enabled;
    if(dpExists("_SystemUseNotification_0001"))
    {
      dpGet("_SystemUseNotification_0001.Enabled", enabled);
      return enabled;
    }
    return FALSE;
  }

  /**
   * @author jhercher
   *
   * function returns the path of the next panel. In case of the login panel (LOGIN state) this function
   * uses the getLoginPanel method to determine which panel should be loaded which it self
   * reads the config entries: loginPanelLocal (default: vision/loginFramework/login_Standard.pnl)
   * and loginPanelServer (default: vision/loginFramework/login_Server.pnl).
   * In case the state is SYSTEMUSENOTIFICATION it returns the path to the SUN panel.
   * other states (CLOSE) have no next panel
   *
   * @return string: path to the next child panel
   */
  public string getNextPanel()
  {
    string panel = "";

    switch(m_state)
    {
      case LoginFrameworkState::LOGIN:
        panel = getLoginPanel();
        break;
      case LoginFrameworkState::SYSTEMUSENOTIFICATION:
        panel = "vision/loginFramework/SystemUseNotification.pnl";
        break;
      default:
        break;
    }

    return panel;
  }

  /**
    @author jhercher
    @brief starts the login execution
  */
  public void startLogin()
  {
    if(m_ui.setUiUser())
    {
      this.setShapes(FALSE);
      m_ui.updateNewPanelTopology(); // in case panel topology has been created while panel was already open

      this.startUserInterface();

      this.setShapes(TRUE);
    }
    else
    {
      OaAuthenticationError err = OaAuthenticationError::UserNotAuth;
      string message = getCatStr("OaLogin", OaAuthError::getErrorKeyword(err), m_loginFrameworkController.getLangIndex());
      displayFailedLogin(message);
    }
  }

  /*
    @author jhercher
    @brief displays a warning panel
    @param string reason: string to be displayed in panel
  */
  public void displayFailedLogin(string reason)
  {
    dyn_string result;
    dyn_float fResult;

//    ChildPanelOnCentralModalReturn("vision/MessageWarning", getCatStr("general", "warning"), makeDynString(reason), fResult, result);
    ChildPanelOnCentralModalReturn("vision/MessageWarning", getCatStr("general", "warning"), "Pogrešan unos korisničkog imena i/ili lozinke!", fResult, result);
  }

  /**
   * @author jhercher
   *
   * function starts the UI and sets the necessary options for the HMI to work
   */
  private void startUserInterface()
  {
    bool loadFromDp = TRUE;
    int configNumber;

    m_ui.setManagerUser();

    if(m_ui.getNewPanelTopology())
    {
      CommandInterface::commandCreateUserUiConfigurationDp(getUserId(m_ui.getUsername()));
      configNumber = m_ui.getMonitorConfigNumber();
      if (m_openMonitorConfiguration)
      {
        bool success = this.selectMultiScreenPara(configNumber);
        if(!success)
        {
          return;
        }
        else
        {
          loadFromDp = FALSE;
        }
      }

      if (loadFromDp)
      {
        m_ui.initPtms(configNumber);
      }
    }

    // password is actually not used in this function therefor we just pass empty string
    afterLogin(m_ui.getUsername(), "", this.getLanguageForUI(), 0, configNumber, m_panel, m_module, m_dollar);
  }

  /*
    @author jhercher
    @brief handles the SSO login mechanism
  */
  public void handleSSO()
  {
    if(m_ui.isSSOEnabled())
    {
      setShapes(FALSE);

      delay(1); //to give the user the possibility to change the language
      this.doContinue();
    }
  }

  /*
    @author jhercher
    @brief de/activates control shapes in login panel
    @para bool enabled: bool TRUE to activate, FALSE to deactivate
  */
  private void setShapes(bool enabled)
  {
    if(m_ui.isSSOEnabled())
    {
      if(enabled)
      {
        this.setBtnAcceptEnabled(enabled);
        this.setBtnCancelEnabled(enabled);
      }
    }
    else
    {
      this.setBtnAcceptEnabled(enabled);
      this.setBtnCancelEnabled(enabled);
    }
  }

  /*
    @author jhercher
    @brief opens multimonitor configuration panel
    @param int iConfigNum: int number of config for user
  */
  private bool selectMultiScreenPara(int &iConfigNum)
  {
    if (openMultiMonitorPara(m_ui.getUsername(), iConfigNum) == 1)
    {
      return TRUE;
    }
    return FALSE;
  }

  /**
   * @author jhercher
   *
   * function initializes the language combobox with all available languages for the current project
   */
  private void initializeLanguage()
  {
    dyn_string dsLangs;

    for(int i = 0; i < getNoOfLangs(); i++)
    {
      dynAppend(dsLangs,getLocale(i));
    }

    this.setCmbBxLanguageItems(dsLangs);
    this.setCmbBxLanguageChanged(m_loginFrameworkView.getObjectText(m_loginFrameworkView.getCmbBxLanguage()));
  }

  /**
   * @author jhercher
   *
   * function returns the language that will be used in the HMI. in case the member variable
   * m_useUserLanguage is set to TRUE the language is read from the user object stored in the m_ui member
   * which read the language from the datapoint. otherwise the currently selected language is chosen.
   *
   * @return string: language to be used for the HMI (e.g. de_AT.utf8)
   */
  private string getLanguageForUI()
  {
    string language;
    if(m_useUserLanguage)
    {
      language = m_ui.getUserLanguage();
    }
    else
    {
      language = getLocale(this.getLangIndex());
    }

    return language;
  }
};
