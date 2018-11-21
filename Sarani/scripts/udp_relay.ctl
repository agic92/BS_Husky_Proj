//-dbg "level1" za debugiranje


int UDP_PORT = 12345;
int open;

main()
{

  startThread("udpListener");  
  
  dpQueryConnectSingle("sendToRelay", false, "", 
                       "SELECT '_online.._value' FROM '*.cmd.State' WHERE _DPT = \"UDPRelay\"");

}


void udpListener()
{
  dyn_errClass err;

   int read;

   string data;

   time maxTime = 100;

   unsigned  writePort;

   string writeHost;

   //Ovo radi na win (slusa samo na jednoj IP)
   //open = udpOpen("10.101.0.1", UDP_PORT);
   
   //Ovo bi trebalo raditi na linux, slusa na svim IP
   open = udpOpen("", UDP_PORT);
   
     if (open != -1){
      DebugN("Otvoren port:" +open);
      }
      else {
          DebugN("Greska open:" +getLastError());  
      }  

   
   
   

   while(1){
 
     read = udpRead(open, data, writeHost, writePort, maxTime);

     if (read != -1){
        
       if (writeHost != "" || data != "")
       {
         DebugN("Primljeni podaci:" +data+ " IP:"+writeHost+" port:"+writePort);
        
          //Ako dodje IPv6 adresa skida prvi dio        
         strreplace(writeHost, "::ffff:", "");  
         
         dyn_dyn_anytype relay;
          dpQuery("SELECT '_online.._value' FROM 'Relay*.IP' WHERE _DPT = \"UDPRelay\" AND  '_online.._value' == \""+writeHost+"\"", relay); 
 
            for(int i = 2; i <= dynlen(relay); i++)  //starta sa 2 zato sto liste pocinju od 1, a sql upit vraca u prvoj liniji header pa treba i njega preskociti
            {    
              if (writeHost == relay[i][2])
              { 
               string dpe;             
              dpe = relay[i][1];
              dpe = dpSubStr(dpe, DPSUB_DP);  //DPSUdB_DP - 
            
            
            
              dpSet(dpe+".status.Response", data);
              dpSet(dpe+".status.CommandStatus", 0);
            
              DebugN("Upisani podaci u DP:" +dpe);
              }           
            }
        }
        
        data="";
        writeHost="";
        
      }
      else {
          DebugN("Greska read:" +getLastError());
          //delay(1);  
      }
       
     
     
   }

    udpClose(open);   
}

void sendToRelay(anytype ident, dyn_dyn_anytype list){
  
  string dpe;
  int value;
  int relay;
   
  for(int i = 2; i <= dynlen(list); i++)  //starta sa 2 zato sto liste pocinju od 1, a sql upit vraca u prvoj liniji header pa treba i njega preskociti
  {    
    value = list[i][2];
    dpe = list[i][1];
    dpe = dpSubStr(dpe, DPSUB_DP);  //DPSUdB_DP - 
    dpGet(dpe + ".cmd.Relay", relay);      
    startThread("sendToRelaySingle", dpe, value, relay);
  }

  
}

void sendToRelaySingle(string dpe, int value, int relay){
  
  int port = 0, res;  
  string ip_adresa, command;
  //int iSignSymbol;
  
  //sklapanje komande
// FF0000 - Status Read command (ASCII encoding)
// 
// FF0100 - Relay 1 OFF command (ASCII encoding)
// FF0101 - Relay 1 ON command (ASCII encoding)
// 
// FF0200 - Relay 2 OFF command (ASCII encoding)
// FF0201 - Relay 2 ON command (ASCII encoding)
// 
// FFE000 - All relays OFF command (ASCII encoding)
// FFE003 - All relays ON command (ASCII encoding)

  if (value == 2)
  {
    command = "FF0000";
  }
  else {
    if (relay == 0) {
      command = value ? "FFE003" : "FFE000";  
    }
    else {
      command = "FF0"+relay+"0";
      command += value ? "1": "0";  
    }
  }
  
  DebugTN("Komanda: "+ command);

  dpGet(dpe + ".IP", ip_adresa);
  dpGet(dpe + ".Port", port);
  
  dpSet(dpe+ ".status.CommandStatus", 1);
  
   dyn_errClass err;

  
   DebugTN("Komanda: "+ command+" IP:"+ip_adresa+" port:"+port);
    
  res = udpWrite(open, command, ip_adresa, port);
  

  
  if (res != -1){
      DebugTN("Uspjesno poslana komanda:"+command+" res:"+res);
      dpSet(dpe+ ".status.CommandStatus", 2);
  }
  else {
      DebugTN("Greška u slanju komande:"+command+ " greska:" + getLastError());
      dpSet(dpe+ ".status.CommandStatus", -1);  
  }  
 

}
