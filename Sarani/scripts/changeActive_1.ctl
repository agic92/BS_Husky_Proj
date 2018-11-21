#uses "CtrlXmlRpc"
main(){

  dpConnect("funkcija", "SysSarani:_ReduManager.Status.Active");
  dpConnect("funkcija2", "SysSarani:_ReduManager.Status.Active");
}

funkcija(string dp, bool vrijednost){
    
    string host = "localhost";  
    int port = 9001;
 
    string id = "servID";
    string func = "bstelecom.ppa.gateway.IGateway.changeActiveStatus"; 
    
    dyn_mixed args = makeDynMixed(vrijednost);
    
    DebugN(args);
    mixed res;
    bool secure = FALSE;
    xmlrpcClient();
    xmlrpcConnectToServer(id, host, port, secure);
    xmlrpcCall(id, func, args, res);
    
    DebugTN("Result of XmlRpc call", res);
    xmlrpcCloseServer(id);
    
}

funkcija2(string dp, bool vrijednost){
    
    string host = "localhost";  
    int port = 9002;
 
    string id = "servID";
    string func = "bstelecom.ppa.gateway.IGateway.changeActiveStatus"; 
    
    dyn_mixed args = makeDynMixed(vrijednost);
    
    DebugN(args);
    mixed res;
    bool secure = FALSE;
    xmlrpcClient();
    xmlrpcConnectToServer(id, host, port, secure);
    xmlrpcCall(id, func, args, res);
    
    DebugTN("Result of XmlRpc call", res);
    xmlrpcCloseServer(id);
    
}
