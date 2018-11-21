//Version V1.1
#uses "CtrlHTTP"
#uses "CtrlXmlRpc"
#uses "xmlrpcHandlerCommon.ctl"
#uses "CtrlZlib"

int HTTP_PORT = 8008;

const int HTTPS_PORT = 0; // To enable https, set this to 443
string msName = "MS1"; // ime Meteostanice
const string meteostanica = "10.101.0.216"; // IP meteostanice
const int msPort = 8000; // Port meteostanice, defaultni je 8000
const string host = "127.0.0.1"; // Računar na kojem je Adapter 
const int port = 6204; // Port adapter servera

const string rs = "36866"; //road sensor id
const string rs2 ="36865"; //second road sensor id
const string vs = "12289"; //visibility sensor id
const string ws = "28673";  //weather station sensor id

int cestovniNedostupan = 0;
int cestovniNedostupan2 = 0;
int meteoNedostupan = 0;
int vidljivostNedostupan = 0;

main()
{
  DebugFTN("level1", "Start " + msName + " .ctl");
  //Start the HTTP Server
  int id = httpServer(false, HTTP_PORT, HTTPS_PORT);
  httpRunPassive(true);
  if (id < 0)
  {
   DebugFTN("level1", "ERROR: HTTP-server can't start. --- Check license");
   return;
  }

  //Start the XmlRpc Handler
  httpConnect("xmlrpcHandler", "/xmlrpc");
  DebugFTN("level1", "HTTP Server installed",id);/* check if the function  httpServer was executed correctly */ 
  
  dyn_errClass err; 
  err = getLastError(); /* check possible errors */ 
  
  if(dynlen(err) > 0) 
  { 
    DebugFTN("level1", err);
    errorDialog(err); 
    throwError(err);
  }
  else 
  {
    DebugFTN("level1", "Server started at port " + HTTP_PORT); //No errors 
  } 
  //startThread("updater"); // Thread...because I can
  updater();
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
    DebugFTN("level1", derr);
    throwError(derr);
    //Output Error
    derr = xmlRpcMakeError(PRIO_SEVERE, ERR_SYSTEM, ERR_PARAMETER, "Error parsing xml-rpc stream", "Method: "+sMethod);

    throwError(derr);
    return xmlrpcReturnFault(derr);

  }

   //Start own method handler
   methodResult = methodHandlerOwn(sMethod, daArgs, user,cookie);
   derr = xmlRpcGetErrorFromResult(methodResult); /* Get error from result if error occurred */

   if (dynlen(derr) > 0) //Error occurred
   {
      DebugFTN("level1", derr);
      throwError(derr);
      // return fault

      //Encode Error
      return makeDynString(xmlrpcReturnFault(derr), "Content-Type: text/xml");
    }

    sRet = xmlrpcReturnSuccess(methodResult); //Encode result //Compress the result if the other side allows it
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
  DebugFTN("level1", "Calling method " + sMethod );  
  switch (sMethod)
  {
    case "scada.bstelecom.ba.IScada.iamAlive":
        if (dynlen(asValues) != 1)
          return xmlRpcMakeError(PRIO_SEVERE, ERR_CONTROL, ERR_INVALID_ARGUMENT, sMethod, "" + asValues);
        DebugFTN("level1", "I am alive " + asValues[1]);
        time t = getCurrentTime();
        dpSet(asValues[1] + ":_original.._value", t);
        return "You are alive.";
    default:
        return methodHandlerCommon(sMethod, asValues, user, cookie);
   }
}

void updater()
{
  while(true) 
  {
    startThread("updatePodataka");
    delay(60);   // 1 minuta pauze.
  }  
}

void updatePodataka() {
  //ako nije aktivan server ne ocitavaj meteostanicu
 if(!isReduActive())
   return;
 
	int cestovni = 0;
       int cestovni2 = 0;
	int meteo = 0;
	int vidljivost = 0;
  //while(true) {
  try{    
	// Resetovanje brojaca
	cestovni = 0;
       cestovni2 = 0;
	meteo = 0;
	vidljivost = 0;
    //string id = "servID"; // ID servera, nebitan podatak ako ne znaš šta je ID    
	string id = rand(); // ID servera, nebitan podatak ako ne znaš šta je ID    
    string func = "bstelecom.umb.UmbProtocolAdapter.readSensors"; // Funkcija za prikupljanje podataka
    mapping m; //Mapiranje, stringa na string. Pattern mapiranja je ["sensorID.channelID"] = ""; 
    // Cestovni senzor
    m[rs + ".101"] = "";
    m[rs + ".151"] = "";
    m[rs + ".601"] = "";
    m[rs + ".900"] = "";
    // Cestovni senzor 2
    m[rs2 + ".101"] = "";
    m[rs2 + ".151"] = "";
    m[rs2 + ".601"] = "";
    m[rs2 + ".900"] = "";        
    // Senzor vidljivosti
    m[vs + ".651"]="";
    // Meteo senzor
    m[ws + ".100"]="";
    m[ws + ".400"]="";
    m[ws + ".440"]="";
    m[ws + ".460"]="";
    m[ws + ".820"]="";
    m[ws + ".620"]="";
    m[ws + ".440"]="";
    m[ws + ".300"]="";
    m[ws + ".200"]="";
    m[ws + ".500"]="";
    m[ws + ".110"]="";
    m[ws + ".700"]="";
    dyn_mixed args = makeDynMixed(meteostanica,msPort,m);
    //DebugN(args); //ispis argumenata
    mixed res;
    bool secure = FALSE;
    xmlrpcClient();
    xmlrpcConnectToServer(id, host, port, secure);
    xmlrpcCall(id, func, args, res);
    xmlrpcCloseServer(id);
	// Da li su senzori vidljivi
	bool cestovni = false;
       bool cestovni2 = false;
	bool meteo = false;
	bool vidljivost = false;
  DebugFTN("level1", "readSensors - res: ", res); // ispis rezultata
  if(getType(res) != MAPPING_VAR){ //ako nije MAPPING_VAR izadji
    DebugFTN("level1", "ERROR - Nije stigao odgovor u ispravnom formatu!");
      return;
    }
    
    // postavljanje DP-ova za cestovni senzor  
    if(mappingHasKey(res, rs + ".101"))
     if(strpos(res[rs + ".101"],"error",0) == -1) { // -1 nema, -2 error
      dpSet(msName + ".response.state.Temperatura_Ceste",res[rs + ".101"]); 
	  cestovni++;
	 }
//     if(mappingHasKey(res, rs + ".106"))
//      if(strpos(res[rs + ".106"],"error",0) == -1) { // -1 nema, -2 error
//       dpSet(msName + ".response.state.scenariji.temperatura_ceste_avg_5_min",res[rs + ".106"]); 
// 	  cestovni++;
// 	 }
    if(mappingHasKey(res, rs + ".151"))
     if(strpos(res[rs + ".151"],"error",0) == -1) { // -1 nema, -2 error
      dpSet(msName + ".response.state.Temperatura_Smrzavanja_Soli",res[rs + ".151"]);
	  cestovni++;
	 }
//     if(mappingHasKey(res, rs + ".156"))
//      if(strpos(res[rs + ".156"],"error",0) == -1) { // -1 nema, -2 error
//       dpSet(msName + ".response.state.scenariji.tacka_smrzavanja_avg_5_min",res[rs + ".156"]);
// 	  cestovni++;
// 	 }
    if(mappingHasKey(res, rs + ".601"))
     if(strpos(res[rs + ".601"],"error",0) == -1) { // -1 nema, -2 error
      dpSet(msName + ".response.state.Visina_vodenog_sloja", res[rs + ".601"]);
	  cestovni++;
	 }
//     if(mappingHasKey(res, rs + ".606"))
//      if(strpos(res[rs + ".606"],"error",0) == -1) { // -1 nema, -2 error
//       dpSet(msName + ".response.state.scenariji.vodeni_sloj_avg_1_min", res[rs + ".606"]);
// 	  cestovni++;
// 	 }
    if(mappingHasKey(res, rs + ".900"))
     if(strpos(res[rs + ".900"],"error",0) == -1) { // -1 nema, -2 error
      dpSet(msName + ".response.state.Stanje_Ceste",res[rs + ".900"]);
	  cestovni++;
	 }

    // postavljanje DP-ova za drugi cestovni senzor  
    if(mappingHasKey(res, rs2 + ".101"))
     if(strpos(res[rs2 + ".101"],"error",0) == -1) { // -1 nema, -2 error
      dpSet(msName + ".response.state.Temperatura_Ceste2",res[rs2 + ".101"]); 
	  cestovni2++;
	 }
//     if(mappingHasKey(res, rs2 + ".106"))
//      if(strpos(res[rs2 + ".106"],"error",0) == -1) { // -1 nema, -2 error
//       dpSet(msName + ".response.state.scenariji.temperatura_ceste_avg_5_min2",res[rs2 + ".106"]); 
// 	  cestovni2++;
// 	 }
    if(mappingHasKey(res, rs2 + ".151"))
     if(strpos(res[rs2 + ".151"],"error",0) == -1) { // -1 nema, -2 error
      dpSet(msName + ".response.state.Temperatura_Smrzavanja_Soli2",res[rs2 + ".151"]);
	  cestovni2++;
	 }
//     if(mappingHasKey(res, rs2 + ".156"))
//      if(strpos(res[rs2 + ".156"],"error",0) == -1) { // -1 nema, -2 error
//       dpSet(msName + ".response.state.scenariji.tacka_smrzavanja_avg_5_min2",res[rs2 + ".156"]);
// 	  cestovni2++;
// 	 }
    if(mappingHasKey(res, rs2 + ".601"))
     if(strpos(res[rs2 + ".601"],"error",0) == -1) { // -1 nema, -2 error
      dpSet(msName + ".response.state.Visina_vodenog_sloja2", res[rs2 + ".601"]);
	  cestovni2++;
	 }
//     if(mappingHasKey(res, rs2 + ".606"))
//      if(strpos(res[rs2 + ".606"],"error",0) == -1) { // -1 nema, -2 error
//       dpSet(msName + ".response.state.scenariji.vodeni_sloj_avg_1_min2", res[rs2 + ".606"]);
// 	  cestovni2++;
// 	 }
    if(mappingHasKey(res , rs2 + ".900"))
     if(strpos(res[rs2 + ".900"],"error",0) == -1) { // -1 nema, -2 error
      dpSet(msName + ".response.state.Stanje_Ceste2",res[rs2 + ".900"]);
	  cestovni2++;
	 }        
    
    //postavljanje DP-ova za senzor vidljivosti
    if(mappingHasKey(res, vs + ".651"))
     if(strpos(res[vs + ".651"],"error",0) == -1) { // -1 nema, -2 error
      dpSet(msName + ".response.state.Vidljivost",res[vs + ".651"]);
	  vidljivost++;
	 }
    
    
    //postavljanje DP-ova za meteo senzor    
    if(mappingHasKey(res,ws + ".100"))
     if(strpos(res[ws + ".100"],"error",0) == -1) { // -1 nema, -2 error
      dpSet(msName + ".response.state.Temperatura_Zraka",res[ws + ".100"]);
	  meteo++;
	 }
    if(mappingHasKey(res,ws + ".400"))
     if(strpos(res[ws + ".400"],"error",0) == -1) { // -1 nema, -2 error
      float brzina1,brzina2,brzina3;
      // Uzimanje starih vrijednosti
      dpGet(msName + ".response.state.Brzina_Vjetra",brzina1);
      dpGet(msName + ".response.state.Brzina_Vjetra_1_Minut",brzina2);
      dpGet(msName + ".response.state.Brzina_Vjetra_2_Minuta",brzina3);
      // Postavljanje novih vrijednosti      
      dpSet(msName + ".response.state.Brzina_Vjetra",res[ws + ".400"]);
      dpSet(msName + ".response.state.Brzina_Vjetra_1_Minut",brzina1);
      dpSet(msName + ".response.state.Brzina_Vjetra_2_Minuta",brzina2);
      dpSet(msName + ".response.state.Brzina_Vjetra_3_Minuta",brzina3);	    
      meteo++;
	 }
//     if(mappingHasKey(res,ws + ".440"))
//      if(strpos(res[ws + ".440"],"error",0) == -1) { // -1 nema, -2 error
//       dpSet(msName + ".response.state.scenariji.vjetar_max_5_min",res[ws + ".440"]);
//       
// 	  meteo++;
// 	 }
    if(mappingHasKey(res,ws + ".460"))
     if(strpos(res[ws + ".460"],"error",0) == -1) { // -1 nema, -2 error
      dpSet(msName + ".response.state.Prosjecna_Brzina_Vjetra",res[ws + ".460"]);
      
	  meteo++;
	 }
    if(mappingHasKey(res,ws + ".460"))
     if(strpos(res[ws + ".460"],"error",0) == -1) { // -1 nema, -2 error
      dpSet(msName + ".response.state.Brzina_Vjetra_Do_15_Minuta",res[ws + ".460"]);
	  meteo++;
	 }
    if(mappingHasKey(res,ws + ".820"))
     if(strpos(res[ws + ".820"],"error",0) == -1) { // -1 nema, -2 error
      dpSet(msName + ".response.state.Intezitet_Padavina",res[ws + ".820"]);
	  meteo++;
	 }
    if(mappingHasKey(res,ws + ".620"))
     if(strpos(res[ws + ".620"],"error",0) == -1) { // -1 nema, -2 error
      dpSet(msName + ".response.state.Kolicina_Padavina",res[ws + ".620"]);
	  meteo++;
	 }
    if(mappingHasKey(res,ws + ".440"))
     if(strpos(res[ws + ".440"],"error",0) == -1) { // -1 nema, -2 error
      dpSet(msName + ".response.state.Maksimalna_Brzina_Vjetra",res[ws + ".440"]);
	  meteo++;
	 }
    if(mappingHasKey(res,ws + ".300"))
     if(strpos(res[ws + ".300"],"error",0) == -1) { // -1 nema, -2 error
      dpSet(msName + ".response.state.Pritisak_Zraka",res[ws + ".300"]);
	  meteo++;
	 }
    if(mappingHasKey(res,ws + ".200"))
     if(strpos(res[ws + ".200"],"error",0) == -1) { // -1 nema, -2 error
      dpSet(msName + ".response.state.Relativna_Vlaznost",res[ws + ".200"]);
	  meteo++;
	 }
    if(mappingHasKey(res,ws + ".500"))
     if(strpos(res[ws + ".500"],"error",0) == -1) { // -1 nema, -2 error
      dpSet(msName + ".response.state.Smjer_Vjetra",res[ws + ".500"]);
	  meteo++;
	 }
    if(mappingHasKey(res,ws + ".110"))
     if(strpos(res[ws + ".110"],"error",0) == -1) { // -1 nema, -2 error
      dpSet(msName + ".response.state.Tacka_Rosista",res[ws + ".110"]);
	  meteo++;
	 }
    if(mappingHasKey(res,ws + ".700"))
     if(strpos(res[ws + ".700"],"error",0) == -1) { // -1 nema, -2 error
      dpSet(msName + ".response.state.Tip_Padavina",res[ws + ".700"]);
	  meteo++;
	 }
    
	// Provjera da li postoje senzori
	if(meteo == 0) {
		if(meteoNedostupan >= 3) { // Tri minute zaredom javio da nema meteo senzora
			dpSet(msName + ".response.alarm.Status_Meteoroloska_Stanica_Prisutna",false);
			meteoNedostupan = 0;
		}
		else
			meteoNedostupan++;
	}
	else { // Meteo senzor dostupan
		dpSet(msName + ".response.alarm.Status_Meteoroloska_Stanica_Prisutna",true);
		meteoNedostupan = 0;
	}
	
	if(cestovni == 0) {
		if(cestovniNedostupan >= 3) {
			dpSet(msName + ".response.alarm.Status_Prisutan_Senzor_Ceste",false); 
			cestovniNedostupan = 0;
		}
		else
			cestovniNedostupan++;
	}
	else {
		dpSet(msName + ".response.alarm.Status_Prisutan_Senzor_Ceste",true);
		cestovniNedostupan = 0;
	}
	if(cestovni2 == 0) {
		if(cestovniNedostupan2 >= 3) {
			dpSet(msName + ".response.alarm.Status_Prisutan_Senzor_Ceste2",false); 
			cestovniNedostupan2 = 0;
		}
		else
			cestovniNedostupan2++;
	}
	else {
		dpSet(msName + ".response.alarm.Status_Prisutan_Senzor_Ceste2",true);
		cestovniNedostupan2 = 0;
	}

	if(vidljivost == 0) {
		if(vidljivostNedostupan >= 3 ) {
			dpSet(msName + ".response.alarm.Status_Senzor_Vidljivosti_Prisutan",false);
			vidljivostNedostupan = 0;
		}
		else
			vidljivostNedostupan++;
	}
	else {
		dpSet(msName + ".response.alarm.Status_Senzor_Vidljivosti_Prisutan",true);
		vidljivostNedostupan = 0;
	}

  if(mappingHasKey(res, "error") && mappingHasKey(res, "errorDescription"))
  {
    DebugFTN("level1","readSensors has error");
     if((strpos(res["errorDescription"],"No route to host",0) > -1) 
       && (strpos(res["error"],"connection",0) > -1))
    { //greska u komunikaciji izmedju adaptera i meteo stanice
      //preskoci postavljanje vremena zadnjeg ocitanja
      DebugFTN("level1", "readSensors - res: ", res); //ispisi rezultat
    }
     else   // Zadnje javljanje
      dpSet(msName + ".response.state.Zadnje_ocitanje",getCurrentTime());   
	 }
   else{   		
    // Zadnje javljanje
    dpSet(msName + ".response.state.Zadnje_ocitanje",getCurrentTime());
  }
    mappingClear(res); // Čišćenje mapiranih rezultata
    
    // Očitanje alarma
    mapping alarmi;
    alarmi[rs + ".101"] = ""; // Alarmi za cestovni senzor
    alarmi[rs2 + ".101"] = ""; // Alarmi za cestovni senzor 2
    alarmi[vs + ".651"] = ""; // Alarmi za senzor vidljivosti
    alarmi[ws + ".200"] = ""; // Alarmi za meteo senzor
    
    args = makeDynMixed(meteostanica,msPort,alarmi);
    func = "bstelecom.umb.UmbProtocolAdapter.readAlarms";
    xmlrpcClient();
    xmlrpcConnectToServer(id, host, port, secure);
    xmlrpcCall(id, func, args, res);
    xmlrpcCloseServer(id);
    //DebugN("1");
    DebugFTN("level1", "readAlarms - res: ", res); // ispis rezultata
      
    if(mappingHasKey(res, rs + ".description"))       
		dpSet(msName + ".response.alarm.Senzor_Ceste_Status",res[rs + ".description"]);	
    if(mappingHasKey(res, rs2 + ".description"))
		dpSet(msName + ".response.alarm.Senzor_Ceste_Status2",res[rs2 + ".description"]);
    if(mappingHasKey(res, vs + ".description"))
		dpSet(msName + ".response.alarm.Senzor_Vidljivosti_Status",res[vs + ".description"]);
    if(mappingHasKey(res,ws + ".description"))
		dpSet(msName + ".response.alarm.Senzor_Meteo_Status",res[ws + ".description"]);

  if(mappingHasKey(res, "error"))
    if(mappingHasKey(res, "errorDescription"))
     if(strpos(res["errorDescription"],"No route to host",0) > -1) { //greska u komunikaciji izmedju adaptera i meteo stanice
       DebugFTN("level1", "readAlarms - res: ", res); //ispisi rezultat
	 }    
		
    /*if(senzorCestePrisutan && senzorVidljivostiPrisutan && meteoSenzorPrisutan)
      dpSet(msName + ".response.alarm.Status_Nema_Komunikacije",false); // Sve uredu, ima komunikacije, stavi alarm na false
    else
      dpSet(msName + ".response.alarm.Status_Nema_Komunikacije",true); // Nema komunikacije, stavi alarm na true
      */
    
    
   // delay(60);   // 1 minuta pauze.    
  }  
  catch
  {
    DebugFTN("level1", getLastException());
  }
}


