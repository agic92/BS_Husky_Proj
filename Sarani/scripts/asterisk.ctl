#uses "CtrlHTTP"
#uses "CtrlXmlRpc"
#uses "xmlrpcHandlerCommon.ctl"
#uses "CtrlZlib"

int HTTP_PORT = 8002;

const int HTTPS_PORT = 0; // To enable https, set this to 443

//-dbg 1 - prikaz promjena dataPont-a vezanih za status sip telefona
//-dbg 2 - prikaz javljanja client-a za Asterisk
 

main()
{
  //Start the HTTP Server
  int id = httpServer(false, HTTP_PORT, HTTPS_PORT);
  if (id < 0)
  {
   DebugTN("ERROR: HTTP-server can't start. --- Check license");
   return;
  }
  httpRunPassive(true);
  httpSetMaxAge(1800);

  //Start the XmlRpc Handler
  httpConnect("xmlrpcHandler", "/RPC2");
  DebugTN("HTTP Server installed",id);/* check if the function  httpServer was executed correctly */ 
  
  dyn_errClass err; 
  err = getLastError(); /* check possible errors */ 
  
  if(dynlen(err) > 0) 
  { 
    DebugTN(err);
    errorDialog(err); 
    throwError(err);
  }
  else 
  {
    DebugTN("Server started at port " + HTTP_PORT); //No errors 
  } 

}

 

mixed xmlrpcHandler(const mixed content, string user, string ip, dyn_string ds1, dyn_string ds2, int connIdx)
{
  string sMethod, sRet;
  dyn_mixed daArgs;
  mixed methodResult;
  mixed xmlResult;
  string cookie = httpGetHeader(connIdx, "Cookie");
  int ret;
  dyn_errClass derr;

   //Decode content
  ret = xmlrpcDecodeRequest(content, sMethod, daArgs);
  derr = getLastError();
  if (ret < 0 || dynlen(derr)>=1)
  {
    DebugTN(derr);
    throwError(derr);
    //Output Error
    derr = xmlRpcMakeError(PRIO_SEVERE, ERR_SYSTEM, ERR_PARAMETER, "Error parsing xml-rpc stream", "Method: "+sMethod);

    throwError(derr);
    return xmlrpcReturnFault(derr);

  }

   //Start own method handler
   methodResult = methodHandlerOwn(sMethod, daArgs, user,cookie);
   derr = xmlRpcGetErrorFromResult(methodResult); /* Get error
   from result if error occurred */

   if (dynlen(derr) > 0) //Error occurred
   {
      DebugTN(derr);
      throwError(derr);
      // return fault

      //Encode Error
      return makeDynString(xmlrpcReturnFault(derr), "Content-Type: text/xml");
    }

    sRet = xmlrpcReturnSuccess(methodResult); //Encode result
    //Compress the result if the other side allows it
    if ( strlen(sRet) > 1024 && strpos(httpGetHeader(connIdx, "Accept-Encoding"),"gzip") >= 0)
    {
      //Return compressed content
      blob b;
      gzip(sRet, b);
      xmlResult = makeDynMixed(b, "Content-Type: text/xml", "Content-Encoding: gzip");
    }
    else
    {
      //Return plain content
      xmlResult = makeDynString( sRet, "Content-Type: text/xml");
    }
    return xmlResult;
}

 

 

mixed methodHandlerOwn(string sMethod, dyn_mixed &asValues, string user, string cookie)
{
  int rc; // return code
  DebugFTN(1, "Calling method " + sMethod );  
  switch (sMethod)
  {
    case "setDP" :
        if (dynlen(asValues) != 2)
          return xmlRpcMakeError(PRIO_SEVERE, ERR_CONTROL, ERR_INVALID_ARGUMENT, sMethod, "" + asValues);
        DebugFTN(1, "Setting data point " + asValues[1] +" value to " + asValues[2]);
        rc=dpSet(asValues[1], asValues[2]);
        return "Setting data point " + asValues[1] +" value to " + asValues[2];
    case "scada.bstelecom.ba.IScada.iamAlive":
        if (dynlen(asValues) != 1)
          return xmlRpcMakeError(PRIO_SEVERE, ERR_CONTROL, ERR_INVALID_ARGUMENT, sMethod, "" + asValues);
        DebugFTN(2, "I am alive " + asValues[1]);
        time t = getCurrentTime();
        dpSet(asValues[1] + ":_original.._value", t);
        return "You are alive.";
    default:
        return methodHandlerCommon(sMethod, asValues, user, cookie);
   }
}
