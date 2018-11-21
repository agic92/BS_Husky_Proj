#uses "CtrlHTTP"
#uses "CtrlXmlRpc"
#uses "xmlrpcHandlerCommon.ctl"
#uses "CtrlZlib"

int HTTP_PORT = 8888;

const int HTTPS_PORT = 0; // To enable https, set this to 443

main()
{
  //Start the HTTP Server
  if (httpServer(false, HTTP_PORT, HTTPS_PORT) < 0)
  {
   DebugN("ERROR: HTTP-server can't start. --- Check license");
   return;
  }

  //Start the XmlRpc Handler
  httpConnect("xmlrpcHandler", "/RPC2");
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

 

 
//ovo bi se trebalo mijenjati u zavisnoti koliko imamo parametara
mixed methodHandlerOwn(string sMethod, dyn_mixed &asValues, string user, string cookie)
{
  int rc; // return code
  switch (sMethod)
  {
    case "wccoa.own.testmethod" :
        return xmlrpc_wccoa_own_testmethod(sMethod, asValues);
    case "setDP" :
        DebugN("Setting data point " + asValues[1] +" value to " + asValues[2]);
        rc=dpSet(asValues[1], asValues[2]); 
        return "Setting data point " + asValues[1] +" value to " + asValues[2];
    default:
        return methodHandlerCommon(sMethod, asValues, user, cookie);
   }
}

 
//test metoda koja ogranicava na 2 broj parametara
private mixed xmlrpc_wccoa_own_testmethod(string sMethod, dyn_mixed values)
{
   mixed res;
   string name;
   
   //Check parameters
   if (dynlen(values) >= 2)
       return xmlRpcMakeError(PRIO_SEVERE, ERR_CONTROL, ERR_INVALID_ARGUMENT, sMethod, ""+values);

   //Magic Code:
   name = values[1];
   res = "Hello World"+name;
   return res;

}
