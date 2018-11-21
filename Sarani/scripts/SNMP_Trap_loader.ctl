string scon_SpecTrap = "1.3.6.1.4.1.24149.1.2.1.0.19";
string scon_SpecTrap__device_connection_error = "1.3.6.1.4.1.24149.1.2.1.0.9";
string scon_SpecTrap_device_connection_OK = "1.3.6.1.4.1.24149.1.2.1.0.10";
string scon_SpecTrap_device_connection_stopped = "1.3.6.1.4.1.24149.1.2.1.0.11";
//string sEntOID = "1.3.6.1.4.1.311.1.1.3.1.1";
string scon_EntOID = "1.3.6.1.4.1.24149.1.2.1";                  
string scon_IPAddr = "192.168.131.242";
string scon_Description = "1.3.6.1.4.1.24149.1.2.2";

string scon_SourceName = "Source name:";
//string sSelect = "SELECT '_original.._value' FROM '*.name' WHERE _DPT = \"Camera\" AND  '_original.._value' == \"";
string sSelect = "SELECT '_original.._value' FROM '*.Name' WHERE _DPT = \"camera\" AND  '_original.._value' == \"";
    
main()
{
  DebugTN("SNMP_Trap_loader - start!");
  dyn_errClass err;
   
  dpConnect("SNMP_Trap_work1", "_16_SNMPManager.Trap.specificTrap", "_16_SNMPManager.Trap.EnterpriseOID", "_16_SNMPManager.Trap.IPAddress", "_16_SNMPManager.Trap.PayloadValue", "_16_SNMPManager.Trap.PayloadOID");
  err = getLastError();
  if(dynlen(err) > 0)
  {
    DebugTN("An error has occurred:", err);
    //further measures
  }
}


SNMP_Trap_work1(string dp_specificTrap, string sSTrap, string dp_EnterpriseOID, string sEOID, string dp_IPAddress, string sIP, string dp_PayloadValue, dyn_dyn_anytype dd_PV, string dp_PayloadOID, dyn_dyn_anytype ddPOID) 
{ 
  if(!isReduActive())
    return;
  
  DebugFTN("level2", dp_specificTrap, sSTrap, dp_EnterpriseOID, sEOID, dp_IPAddress, sIP, dp_PayloadValue, dd_PV);
  string sCameraName;
  string sCameraDP;
  int iCamera_Communication = -1; //no changes
  //iCamera_Communication = 0; //error
  //iCamera_Communication = 1; //OK
  if(dynlen(dd_PV) > 1)
  {
    if(sEOID == scon_EntOID && sSTrap == scon_SpecTrap && sIP == scon_IPAddr && ddPOID[2] == scon_Description)
      DebugTN("PTZ move - poslije filtera - ", dd_PV[2]);
  
    else if(sEOID == scon_EntOID && sSTrap == scon_SpecTrap__device_connection_error && sIP == scon_IPAddr && ddPOID[2] == scon_Description)
    {
      iCamera_Communication = 0;
      DebugTN("Device comunnication error - poslije filtera - ", dd_PV[2]);
    }   
    else if(sEOID == scon_EntOID && sSTrap == scon_SpecTrap_device_connection_stopped && sIP == scon_IPAddr && ddPOID[2] == scon_Description)
    {
      iCamera_Communication = 0;
      DebugTN("Device comunnication stopped - poslije filtera - ", dd_PV[2]);
    }  
    else if(sEOID == scon_EntOID && sSTrap == scon_SpecTrap_device_connection_OK && sIP == scon_IPAddr && ddPOID[2] == scon_Description)
    {
      iCamera_Communication = 1;
      DebugTN("Device comunnication OK - poslije filtera - ", dd_PV[2]);
    }
    
    if(iCamera_Communication > -1)
    {
      sCameraName = GetDeviceName(dd_PV[2]);
      sCameraDP = GetDevice_dataPoint(sCameraName);
      DebugFTN("level3", " dpSet(" + sCameraDP + ".Connection", iCamera_Communication);
      dpSet(sCameraDP + ".Connection", iCamera_Communication); 
    }
  }
}

string GetDeviceName(string sSource)
{
  string sDeviceName = "";
  int iPos = strpos(sSource, scon_SourceName);
  if(iPos >=0)
  {
    iPos += strlen(scon_SourceName) + 1;
    sDeviceName = substr(sSource, iPos);
  }
  DebugFTN("level3", "GetDeviceName:", sSource, sDeviceName);
  return sDeviceName;
}

string GetDevice_dataPoint(string sCameraName)
{
  dyn_dyn_anytype dd_dpCams;
  dyn_string list1;
  int z;
  string sSelect1 = sSelect + sCameraName + "\"";
  dpQuery(sSelect1, dd_dpCams); 
  //for(z=2;z<=dynlen(dd_dpCams);z++)
    // setValue(list1,"appendItem",tab[z][2]);
  DebugFTN("level3", "GetDevice_dataPoint() - dd_dpCams", dd_dpCams);
  if (dynlen(dd_dpCams)>1)
  {
    string sDPName = dpSubStr(dd_dpCams[2][1], DPSUB_DP);  //DPSUB_DP -
    DebugFTN("level3", "dd_dpCams[2]", dd_dpCams[2][1], sDPName);    
    return sDPName;
  }
  return "";
}
