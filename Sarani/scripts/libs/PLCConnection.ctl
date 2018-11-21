//provjerava konekciju sa PLC-om
void PLCConnection(string plc)
{
  int rc;
  if( !dpExists(sys_name + plc + ".ConnState:_alert_hdl.._act_state_color"))
  {
    setValue("", "color", "_dpdoesnotexist");
    return;
  }

  rc = dpConnect("checkPLCConnection", 
                 sys_name + plc + ".ConnState:_alert_hdl.._act_state_color");

  if ( sdGetLastError() < 0 || rc != 0)
  {
    setValue("", "color", "_dpdoesnotexist");
  }
}

void checkPLCConnection(string dp, string connStateColor){
      setValue("", "color", connStateColor);
}




