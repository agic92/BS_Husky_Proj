//-dbg "level1" za debugiranje


main()
{
  
  dpQueryConnectSingle("restartRelay", true, "", 
                       "SELECT '_online.._value' FROM 'RO-*.state.gubitak_komunikacije' WHERE _DPT = \"Nisa\"");

}


void restartRelay(anytype ident, dyn_dyn_anytype list){
  
  string dpe;
  bool value;

   
  for(int i = 2; i <= dynlen(list); i++)  //starta sa 2 zato sto liste pocinju od 1, a sql upit vraca u prvoj liniji header pa treba i njega preskociti
  {    
    value = list[i][2];
    dpe = list[i][1];
    dpe = dpSubStr(dpe, DPSUB_DP);  //DPSUdB_DP - 

    if (value == TRUE) //desio se gubitak komunikacije
    {    
      startThread("restartSingleRelay", dpe, value);
    }
  }

  
}

void restartSingleRelay(string dpe, bool value){
  
  int res, status, i=0;  
  bool novo_stanje;
  string response;

    DebugTN("Ormar bez komunikacije:"+dpe+" stanje:"+value);

  //Sacekati 60 sekundi u slučaju da je privremeni gubitak komunikacije
  delay(90);
  
  
  dpGet(dpe + ".state.gubitak_komunikacije", novo_stanje);

  // I dalje postoji gubitak komunikacije
  if(novo_stanje){
      
    DebugTN("Ormar potrebno restartati:"+dpe+" stanje:"+novo_stanje);
     
    strreplace(dpe, "RO-", "Relay-"); //Na osnovu naziva ormara iz "Nise" pravi naziv releja iz "UDPRelay"

    DebugTN("Relay restartati:"+dpe);
    
    if (!dpExists(dpe)){
        DebugTN("Ne postoji reley za ormar: " + dpe);
        return;
    }
      
    
    // Gašenje uređaja
    while (i<3)
    {
      dpSet(dpe+ ".cmd.Relay", 0); //Oba releja
      dpSet(dpe+ ".cmd.State", 1); //Komanda zatvara relej, ali je spojeno na NC kontakte pa će ugasiti uređaj
    
      delay(1);

      dpGet(dpe+ ".status.CommandStatus", status);

      if(status == 0) {
        //Stigao odgovor
        dpGet(dpe+ ".status.Response", response);
        
        if(response == "11")
        {
          //Kontakti uspješno zatvoreni
          DebugTN("Relay uspjesno ugašen:"+dpe);
          break;
        }
        else{
           DebugTN("Status releja:"+dpe+ " trazeno 11 a stiglo:"+response+ " pokušaj:" + i);       
        }
      }
      else {
        DebugTN("Nije stigao odgovor releja:"+dpe+ "pokušaj:" + i);
      }
      
       i++; 
       delay(1);
    }
  
    delay(2);
    
    //Ponovo paljenje
    i = 0;    
    while (i<3)
    {
      dpSet(dpe+ ".cmd.Relay", 0); //Oba releja
      dpSet(dpe+ ".cmd.State", 0); //Komanda otvara relej, ali je spojeno na NC kontakte pa će upaliti uređaj
    
      delay(1);

      dpGet(dpe+ ".status.CommandStatus", status);

      if(status == 0) {
        //Stigao odgovor
        dpGet(dpe+ ".status.Response", response);
        
        if(response == "00")
        {
          //Kontakti uspješno otvoreni
          DebugTN("Relay uspjesno upaljen:"+dpe);
          break;
        }
        else{
           DebugTN("Status releja:"+dpe+ " trazeno 00 a stiglo:"+response+ " pokušaj:" + i);       
        }
      }
      else {
        DebugTN("Nije stigao odgovor releja:"+dpe+ "pokušaj:" + i);
      }
      
       i++; 
       delay(1);
    }  
  
    
     
     
  }  
  else {
    DebugTN("Ormar NIJE potrebno restartati:"+dpe+" stanje:"+novo_stanje);
  }
  
 

}
