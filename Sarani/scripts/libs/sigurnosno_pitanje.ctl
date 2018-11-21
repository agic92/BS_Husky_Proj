bool sigurnosnoPitanje(string sc){
  
  dyn_errClass err; 
  dyn_float dreturnf;
  dyn_string dreturns;
  string scenarij, idText; 

  err = getLastError(); //get the error 
  if(dynlen(err) > 0) 
  { 
    DebugN("Greska, vraca error: "); // no error 
    DebugTN(getErrorText(err)); //get the error text 
  } 
  else 
  { 
    DebugN("OK"); // no error 
  }

  //otvori prozor sa upozorenjem i pitaj operatera da li zeli da postavi scenarij
  ChildPanelOnCentralModalReturn("vision/MessageWarning2", "Upozorenje",      
      makeDynString("$1:" + latinToCyrillic("Da li ste sigurni da zelite da pokrenete scenarij: ") + sc, "$2:" + latinToCyrillic("Da"), "$3:" + latinToCyrillic("Ne")),
      dreturnf,
      dreturns);
  
   DebugTN("Stigao odgovor za postavljanje scenarija: " + dreturns);
   if(dreturnf[1] == 1){    
       return true;
   }   
   return false;
}
