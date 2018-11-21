main()
{

  dpQueryConnectSingle("sendToThreadLoopDetecotorCounter", true, "Identi", 
                       "SELECT '_online.._value' FROM '*.VehicleCounter.Module1.Counters.direction1.Car' WHERE _DPT = \"LoopDetector\"");
  
}

sendToThreadLoopDetecotorCounter(anytype ident, dyn_dyn_anytype list)
{
   int threadId = startThread("sendToLoopDetecotorCounter", list);
}

sendToLoopDetecotorCounter(dyn_dyn_anytype list)
{
  string dpe;
  int sumaModula;  
  
  for(int i = 2; i <= dynlen(list); i++)  //starta sa 2 zato sto liste pocinju od 1, a sql upit vraca u prvoj liniji header pa treba i njega preskociti
  { 
    dpe = list[i][1];         
    dpe = dpSubStr(dpe, DPSUB_DP);  //DPSUB_DP - 
    
    if(dpe == "BP05_D" || dpe == "BP07_D" || dpe == "BP08_L" || dpe == "BP06_L" || dpe == "BP09_D" || dpe == "BP11_D" || dpe == "BP12_L" || dpe == "BP10_L"){    
       sumaModula = getVehicleCounter(dpe, "Module1") + getVehicleCounter(dpe, "Module2");
    }
    
    switch(dpe){
      case "BP05_D": EP_Device05(dpe, sumaModula); break;
      case "BP07_D": EP_Device07(dpe, sumaModula); break;
      case "BP08_L": EP_Device08(dpe, sumaModula); break;
      case "BP06_L": EP_Device06(dpe, sumaModula); break;
      case "BP09_D": EP_Device09(dpe, sumaModula); break;
      case "BP11_D": EP_Device11(dpe, sumaModula); break;
      case "BP12_L": EP_Device12(dpe, sumaModula); break;
      case "BP10_L": EP_Device10(dpe, sumaModula); break;  
      default: return;    
    } 
        
  }

}

int getVehicleCounter(string dpe, string module){
  int car,carWithTrailer, lorry, lorryWithTrailer, bus, motorbike, van, truck;
  
  dpGet(dpe + ".VehicleCounter." + module + ".Counters.direction1.Car", car,
        dpe + ".VehicleCounter." + module + ".Counters.direction1.CarWithTrailer", carWithTrailer,
        dpe + ".VehicleCounter." + module + ".Counters.direction1.Lorry", lorry,
        dpe + ".VehicleCounter." + module + ".Counters.direction1.LorryWithTrailer", lorryWithTrailer,
        dpe + ".VehicleCounter." + module + ".Counters.direction1.Bus", bus,
        dpe + ".VehicleCounter." + module + ".Counters.direction1.Motorbike", motorbike,
        dpe + ".VehicleCounter." + module + ".Counters.direction1.Van", van,
        dpe + ".VehicleCounter." + module + ".Counters.direction1.Truck",truck);
  
  int suma = car + carWithTrailer + lorry + lorryWithTrailer + bus + motorbike + van + truck;
  return suma;
}

//sumaModula je zbir dva modula razlicitih kalsa vozila
void EP_Device05(string dp, int sumaModula)
{    
  int trenutniBrojVozila, staraVrijednostZbiraModula;
  dpGet("broj_vozila_gaj_desna.trenutni_broj_vozila", trenutniBrojVozila);
  dpGet("broj_vozila_gaj_desna.brojac_prometa_ulaz", staraVrijednostZbiraModula); //stara vrijednost je zbir dva modula, odnosi se na konkretnu zonu
    
  if(staraVrijednostZbiraModula != sumaModula) 
  {
      int razlika = abs(sumaModula - staraVrijednostZbiraModula);
      
      if(razlika < 0 || razlika > 3) trenutniBrojVozila = 0;
      else trenutniBrojVozila += razlika;
            
      dpSet("broj_vozila_gaj_desna.trenutni_broj_vozila", trenutniBrojVozila);
      dpSet("broj_vozila_gaj_desna.brojac_prometa_ulaz", sumaModula);
  }   
}

//sumaModula je zbir dva modula
void EP_Device07(string dp, int sumaModula)
{    
  int trenutniBrojVozila, staraVrijednostZbiraModula;
  dpGet("broj_vozila_gaj_desna.trenutni_broj_vozila", trenutniBrojVozila);
  dpGet("broj_vozila_gaj_desna.brojac_prometa_izlaz", staraVrijednostZbiraModula); //stara vrijednost je zbir dva modula, odnosi se na konkretnu zonu
    
  if(staraVrijednostZbiraModula != sumaModula) 
  {
      int razlika = abs(sumaModula - staraVrijednostZbiraModula);
      
      if(razlika < 0 || razlika > 3) trenutniBrojVozila = 0;
      else {
        trenutniBrojVozila -= razlika;
        if(trenutniBrojVozila < 0) trenutniBrojVozila = 0;
      }
      
      dpSet("broj_vozila_gaj_desna.trenutni_broj_vozila", trenutniBrojVozila);
      dpSet("broj_vozila_gaj_desna.brojac_prometa_izlaz", sumaModula);
  }   
}

void EP_Device08(string dp, int sumaModula)
{    
  int trenutniBrojVozila, staraVrijednostZbiraModula;
  dpGet("broj_vozila_gaj_lijeva.trenutni_broj_vozila", trenutniBrojVozila);
  dpGet("broj_vozila_gaj_lijeva.brojac_prometa_ulaz", staraVrijednostZbiraModula); //stara vrijednost je zbir dva modula, odnosi se na konkretnu zonu
    
  if(staraVrijednostZbiraModula != sumaModula) 
  {
      int razlika = abs(sumaModula - staraVrijednostZbiraModula);
      
      if(razlika < 0 || razlika > 3) trenutniBrojVozila = 0;
      else trenutniBrojVozila += razlika;
           
      dpSet("broj_vozila_gaj_lijeva.trenutni_broj_vozila", trenutniBrojVozila);
      dpSet("broj_vozila_gaj_lijeva.brojac_prometa_ulaz", sumaModula);
  }    
}

void EP_Device06(string dp, int sumaModula)
{    
  int trenutniBrojVozila, staraVrijednostZbiraModula;
  dpGet("broj_vozila_gaj_lijeva.trenutni_broj_vozila", trenutniBrojVozila);
  dpGet("broj_vozila_gaj_lijeva.brojac_prometa_izlaz", staraVrijednostZbiraModula); //stara vrijednost je zbir dva modula, odnosi se na konkretnu zonu
    
  if(staraVrijednostZbiraModula != sumaModula) 
  {
      int razlika = abs(sumaModula - staraVrijednostZbiraModula);
      
      if(razlika < 0 || razlika > 3) trenutniBrojVozila = 0;
      else{         
        trenutniBrojVozila -= razlika;
        if(trenutniBrojVozila < 0) trenutniBrojVozila = 0;
      }
      
      dpSet("broj_vozila_gaj_lijeva.trenutni_broj_vozila", trenutniBrojVozila);
      dpSet("broj_vozila_gaj_lijeva.brojac_prometa_izlaz", sumaModula);
  } 
}

//sumaModula je zbir dva modula
void EP_Device09(string dp, int sumaModula)
{    
  int trenutniBrojVozila, staraVrijednostZbiraModula;
  dpGet("broj_vozila_igman_desna.trenutni_broj_vozila", trenutniBrojVozila);
  dpGet("broj_vozila_igman_desna.brojac_prometa_ulaz", staraVrijednostZbiraModula); //stara vrijednost je zbir dva modula, odnosi se na konkretnu zonu
  
  if(staraVrijednostZbiraModula != sumaModula) 
  {
      int razlika = abs(sumaModula - staraVrijednostZbiraModula);
      
      if(razlika < 0 || razlika > 3) trenutniBrojVozila = 0;
      else trenutniBrojVozila += razlika;
            
      dpSet("broj_vozila_igman_desna.trenutni_broj_vozila", trenutniBrojVozila);
      dpSet("broj_vozila_igman_desna.brojac_prometa_ulaz", sumaModula);
  }   
}

//sumaModula je zbir dva modula
void EP_Device11(string dp, int sumaModula)
{    
  int trenutniBrojVozila, staraVrijednostZbiraModula;
  dpGet("broj_vozila_igman_desna.trenutni_broj_vozila", trenutniBrojVozila);
  dpGet("broj_vozila_igman_desna.brojac_prometa_izlaz", staraVrijednostZbiraModula); //stara vrijednost je zbir dva modula, odnosi se na konkretnu zonu
    
  if(staraVrijednostZbiraModula != sumaModula) 
  {
      int razlika = abs(sumaModula - staraVrijednostZbiraModula);
      
      if(razlika < 0 || razlika > 3) trenutniBrojVozila = 0;
      else{        
        trenutniBrojVozila -= razlika;
        if(trenutniBrojVozila < 0) trenutniBrojVozila = 0;
      }
     
      dpSet("broj_vozila_igman_desna.trenutni_broj_vozila", trenutniBrojVozila);
      dpSet("broj_vozila_igman_desna.brojac_prometa_izlaz", sumaModula);
  }   
}


void EP_Device12(string dp, int sumaModula)
{    
  int trenutniBrojVozila, staraVrijednostZbiraModula;
  dpGet("broj_vozila_igman_lijeva.trenutni_broj_vozila", trenutniBrojVozila);
  dpGet("broj_vozila_igman_lijeva.brojac_prometa_ulaz", staraVrijednostZbiraModula); //stara vrijednost je zbir dva modula, odnosi se na konkretnu zonu
    
  if(staraVrijednostZbiraModula != sumaModula) 
  {
      int razlika = abs(sumaModula - staraVrijednostZbiraModula);
      
      if(razlika < 0 || razlika > 3) trenutniBrojVozila = 0;
      else trenutniBrojVozila += razlika;
           
      dpSet("broj_vozila_igman_lijeva.trenutni_broj_vozila", trenutniBrojVozila);
      dpSet("broj_vozila_igman_lijeva.brojac_prometa_ulaz", sumaModula);
  }    
}

void EP_Device10(string dp, int sumaModula)
{    
  int trenutniBrojVozila, staraVrijednostZbiraModula;
  dpGet("broj_vozila_igman_lijeva.trenutni_broj_vozila", trenutniBrojVozila);
  dpGet("broj_vozila_igman_lijeva.brojac_prometa_izlaz", staraVrijednostZbiraModula); //stara vrijednost je zbir dva modula, odnosi se na konkretnu zonu
    
  if(staraVrijednostZbiraModula != sumaModula) 
  {
      int razlika = abs(sumaModula - staraVrijednostZbiraModula);
      
      if(razlika < 0 || razlika > 3) trenutniBrojVozila = 0;
      else{        
        trenutniBrojVozila -= razlika;
        if(trenutniBrojVozila < 0) trenutniBrojVozila = 0;
      }
    
      dpSet("broj_vozila_igman_lijeva.trenutni_broj_vozila", trenutniBrojVozila);
      dpSet("broj_vozila_igman_lijeva.brojac_prometa_izlaz", sumaModula);
  } 
}
