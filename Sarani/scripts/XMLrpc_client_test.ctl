#uses "CtrlXmlRpc"

main()
{
  while(true)
  {
     delay(0.5); 
  
    string id = "servID" + rand();
    string host = "localhost";
    int port = "8087";
    bool secure = FALSE;
  
    xmlrpcClient();
    xmlrpcConnectToServer(id, host, port, secure);

    DebugTN("xml-rpc_client test before xmlrpcCloseServer() - ", id);
    xmlrpcCloseServer(id);  
    DebugTN("xml-rpc_client test after xmlrpcCloseServer() - ", id);
    //delay(10);
  }
  
}
