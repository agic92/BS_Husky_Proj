// ----------------------------------------------------------------------------
// creator: Joshua Hercher 9.1.2018
// purpose: View Class for Standard Login Panel
// ----------------------------------------------------------------------------

#uses "classes/loginFramework/LoginFrameworkController"

/**
 * LoginFrameworkLoginStd class implements the LoginFrameworkChildView interface
 * this class implements a LoginFrameworkChildView for the vision/loginFramework/login_Standard.pnl
 *
 * \author jhercher
 */
class LoginFrameworkLoginStd: LoginFrameworkChildView
{
  private mixed m_panel; //is actually the panel as an object
  private string m_txtUsername;
  private string m_txtPassword;
  private string m_txtDomain;
  private string m_chkBxMonitor;
  private string m_chkBxUserLang;

  private shared_ptr<LoginFrameworkController> m_loginFrameworkController = LoginFrameworkController::getInstance();

  /**
   * @author jhercher
   *
   * constructor
   * assigns all elements in the child panel, as well as the panel itself to a member variable
   *
   * @param mixed panel: variable to access panel has to be called by passing "self" in a panel
   * @para string txtUsername: name of txt_Username in panel
   * @para string txtPassword: name of txt_Password in panel
   * @para string txtDomain: name of txt_Domain in panel
   * @para string chkBxUserLang: name of chkBx_UserLang in panel
   * @para string chkBxMonitor: name of chkBx_Monitor in panel
   */
  public LoginFrameworkLoginStd(mixed panel, string txtUsername, string txtPassword,
                                string txtDomain, string chkBxUserLang, string chkBxMonitor)
  {
    m_panel = panel;
    m_txtUsername = txtUsername;
    m_txtPassword = txtPassword;
    m_txtDomain = txtDomain;
    m_chkBxMonitor = chkBxMonitor;
    m_chkBxUserLang = chkBxUserLang;
  }

  /**
   * @author jhercher
   *
   * function either opens system use notification or starts the HMI after the panel function
   * authenticate() is called
   * function is called when pressing the btn_Action in base panel
   */
  public void doContinue()
  {
    this.enableTextFields(FALSE);
    if(m_panel.authenticate())
    {
      if(m_loginFrameworkController.useSystemNotification())
      {
        string panel = m_loginFrameworkController.getNextPanel();
        m_loginFrameworkController.switchPanel(panel);
      }
      else
      {
        m_loginFrameworkController.startLogin();
      }
    }
    else
    {
      this.enableTextFields(TRUE);
    }
  }

  /**
   * @author jhercher
   *
   * function closes the panel
   * function is called when pressing the btn_Cancel in base panel
   */
  public void doCancel()
  {
    PanelOff();
  }

  /**
   * @author jhercher
   *
   * function opens the online_help at the login chapter
   */
  public void openHelp()
  {
    string keyword = "login";

    if(dpExists("ApplicationProperties"))
    {
      keyword = "da_login";
    }

    std_help(keyword);
  }

  /**
   * @author jhercher
   *
   * function sets the text and/or the tooltips of the elements int the child panel
   * to the correct language
   *
   * @param int langIndex: language index which should be accessed in catalogue file
   */
  public void setLanguage(int langIndex)
  {
    this.setObjectToolTip(m_txtDomain, getCatStr("general", "loginToolTipDomain", langIndex));
//     this.setObjectToolTip(m_txtUsername, getCatStr("general", "loginToolTipUsername", langIndex));
//     this.setObjectToolTip(m_txtPassword, getCatStr("general", "loginPassword", langIndex));
    this.setObjectToolTip(m_txtUsername, "Korisničko ime");
    this.setObjectToolTip(m_txtPassword, "Lozinka");
    this.setChkBxText(m_chkBxUserLang, getCatStr("OaLogin", "login_userLang", langIndex), 0);
    this.setChkBxText(m_chkBxMonitor, getCatStr("general", "loginCheckbox", langIndex), 0);
//     this.setObjectPlaceholderText(m_txtUsername, getCatStr("general", "loginUsername", langIndex));
//     this.setObjectPlaceholderText(m_txtPassword, getCatStr("general", "loginPassword", langIndex));
    this.setObjectPlaceholderText(m_txtUsername, "Korisničko ime");
    this.setObjectPlaceholderText(m_txtPassword, "Lozinka");

    this.setFrameworkLanguage(langIndex);
  }

  /**
   * @author jhercher
   *
   * function calls the panel function authenticate (function is implemented in panel
   * because it is also called in the panel itself in case of sso). and returns if authentication
   * process was successful or not
   *
   * @return bool: TRUE if successfully authenticated, FALSE if not
   */
  public bool authenticate()
  {
    return m_panel.authenticate();
  }

  /**
   * @author jhercher
   *
   * function dis/enables the textfields to enter username and password
   *
   * @param bool enabled: if TRUE textfields are enabled, else textfields are disabled
   */
  private void enableTextFields(bool enabled)
  {
    setValue(m_txtUsername, ENABLED, enabled);
    setValue(m_txtPassword, ENABLED, enabled);
  }

  /**
   * @author jhercher
   *
   * function sets the tooltip of an object
   *
   * @param string object: name of the object which tooltip should be set
   * @param string toolTip: text to which the tooltip should be set
   */
  private void setObjectToolTip(string object, string toolTip)
  {
    setValue(object, TOOLTIP, toolTip);
  }

  /**
   * @author jhercher
   *
   * function sets the text of the checkbox
   *
   * @param string chkBx: name of the checkbox object which text should be changed
   * @param string text: the text the checkbox object should get
   * @param int index: the index which element of the checkbox should be changed
   */
  private void setChkBxText(string chkBx, string text, int index)
  {
    setValue(chkBx, TEXT, index, text);
  }

  /**
   * @author jhercher
   *
   * function sets the text of and object
   *
   * @param string object: the object which text should be changed
   * @param string text: the text which should be displayed on the object
   */
  private void setObjectText(string object, string text)
  {
    setValue(object, TEXT, text);
  }

  /**
   * @author jhercher
   *
   * function sets the placeholderText of and object
   *
   * @param string object: the object which text should be changed
   * @param string text: the text which should be displayed on the object
   */
  private void setObjectPlaceholderText(string object, string text)
  {
    setValue(object, "placeholderText", text);
  }

  /**
   * @author jhercher
   *
   * function changes the text and/or tooltip of the base panel to fit the the functionality
   * of the child panel and the system use notification settings.
   * If system use notifications are not used btn_Accept of base panel displays "Login" otherwise
   * it displays "continue"
   *
   * @param int langIndex: the language index which should be used to access the catalogue file
   */
  private void setFrameworkLanguage(int langIndex)
  {
    string btnAcceptText, btnAcceptToolTip;
    if(m_loginFrameworkController.useSystemNotification())
    {
      btnAcceptText = getCatStr("OaLogin", "continue", langIndex);
      btnAcceptToolTip = getCatStr("OaLogin", "sun_ActionTooltip", langIndex);
    }
    else
    {
      btnAcceptText = getCatStr("general", "loginToolTipLogin", langIndex);
      btnAcceptToolTip = btnAcceptText;
    }

    m_loginFrameworkController.setBtnAcceptText(btnAcceptText);
    m_loginFrameworkController.setBtnAcceptToolTip(btnAcceptToolTip);
    m_loginFrameworkController.setBtnCancelText(getCatStr("Console", "3502", langIndex));
    m_loginFrameworkController.setBtnCancelToolTip(getCatStr("OaLogin", "sun_CancelTooltip", langIndex));
  }
};
