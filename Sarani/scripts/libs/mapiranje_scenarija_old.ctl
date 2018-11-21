#uses "latin_to_cyrillic.ctl"

string mapiranjeScenarija(string scenarij){

  mapping map = vratiMapuZaScenarije();
    
  string key;
                   
  for(int i=1;i<=mappinglen(map);i++){
     key = mappingGetKey(map, i);
     if(strpos(scenarij, key, 0) >= 0) {
       return map[key]; }   
  }
  return "";
}

string mapiranjeScenarijaReverse(string scenarij){

  mapping map = vratiMapuZaScenarije();
    
  string value;
                   
  for(int i=1;i<=mappinglen(map);i++){
     value = mappingGetValue(map, i);
     if(strpos(scenarij, value, 0) >= 0) {
        return mappingGetKey(map, i);
      }   
  }
  return "";
}


mapping vratiMapuZaScenarije(){

  mapping map;
  map["KolonaVozilaDesnaCev-Ogranicenje40"] = latinToCyrillic ("Kolona Vozila Desna Cev - Ograničenje 40");
  map["KolonaVozilaDesnaCev-Ogranicenje60"] = latinToCyrillic ("Kolona Vozila Desna Cev - Ograničenje 60");
  map["KolonaVozilaLevaCev-Ogranicenje40"] = latinToCyrillic ("Kolona Vozila Leva Cev - Ograničenje 40");
  map["KolonaVozilaLevaCev-Ogranicenje60"] = latinToCyrillic ("Kolona Vozila Leva Cev - Ograničenje 60");
  map["ObustavaSaobracajaDesnaCev"] = latinToCyrillic ("Obustava Saobraćaja Desna Cev");
  map["ObustavaSaobracajaLevaCev"] = latinToCyrillic ("Obustava Saobraćaja LevaCev");
  map["Pozar-VatrodojavnaZona1"] = latinToCyrillic ("Požar - Vatrodojavna Zona 1");
  map["Pozar-VatrodojavnaZona2"] = latinToCyrillic ("Požar - Vatrodojavna Zona 2");
  map["Pozar-VatrodojavnaZona3"] = latinToCyrillic ("Požar - Vatrodojavna Zona 3");
  map["Pozar-VatrodojavnaZona4"] = latinToCyrillic ("Požar - Vatrodojavna Zona 4");
  map["Pozar-VatrodojavnaZona5"] = latinToCyrillic ("Požar - Vatrodojavna Zona 5");
  map["Pozar-VatrodojavnaZona6"] = latinToCyrillic ("Požar - Vatrodojavna Zona 6");
  map["Pozar-VatrodojavnaZona7"] = latinToCyrillic ("Požar - Vatrodojavna Zona 7");
  map["Pozar-VatrodojavnaZona8"] = latinToCyrillic ("Požar - Vatrodojavna Zona 8");
  map["Pozar-VatrodojavnaZona9"] = latinToCyrillic ("Požar - Vatrodojavna Zona 9");
  map["Pozar-VatrodojavnaZona10"] = latinToCyrillic ( "Požar - Vatrodojavna Zona 10");
  map["Pozar-VatrodojavnaZona11"] = latinToCyrillic ( "Požar - Vatrodojavna Zona 11");
  map["Pozar-VatrodojavnaZona12"] = latinToCyrillic ( "Požar - Vatrodojavna Zona 12");
  map["Pozar-VatrodojavnaZona13"] = latinToCyrillic ( "Požar - Vatrodojavna Zona 13");
  map["Pozar-VatrodojavnaZona14"] = latinToCyrillic ( "Požar - Vatrodojavna Zona 14");
  map["Pozar-VatrodojavnaZona15"] = latinToCyrillic ( "Požar - Vatrodojavna Zona 15");
  map["Pozar-VatrodojavnaZona16"] = latinToCyrillic ( "Požar - Vatrodojavna Zona 16");
  map["Pozar-VatrodojavnaZona17"] = latinToCyrillic ( "Požar - Vatrodojavna Zona 17");
  map["RadoviDesnaCev-DesnaTraka"] = latinToCyrillic ( "Radovi Desna Cev - Desna Traka");
  map["RadoviDesnaCev-LevaTraka"] = latinToCyrillic ("Radovi Desna Cev - Leva Traka");
  map["RadoviLevaCev-DesnaTraka"] = latinToCyrillic ("Radovi Leva Cev - Desna Traka");
  map["RadoviLevaCev-LevaTraka"] = latinToCyrillic ("Radovi Leva Cev - Leva Traka");
  map["RadoviZatvorenaDesnaCev"] = latinToCyrillic ("Radovi Zatvorena Desna Cev");
  map["RadoviZatvorenaLevaCev"] = latinToCyrillic ("Radovi Zatvorena Leva Cev");
  map["RedovniUsloviOdvijanjuSaobracaja"] = latinToCyrillic ("Redovni Uslovi Odvijanju Saobraćaja");
  map["SaobracajnaNezgodaIliZaustavljenoVoziloDesnaCev-DesnaTraka"] = latinToCyrillic ("Saobraćajna Nezgoda ili Zaustavljeno Vozilo Desna Cev - Desna Traka");  
  map["SaobracajnaNezgodaIliZaustavljenoVoziloDesnaCev-LevaTraka"] = latinToCyrillic ("Saobraćajna Nezgoda ili Zaustavljeno Vozilo Desna Cev - Leva Traka");
  map["SaobracajnaNezgodaIliZaustavljenoVoziloLevaCev-DesnaTraka"] = latinToCyrillic ("Saobraćajna Nezgoda ili Zaustavljeno Vozilo Leva Cev - Desna Traka");
  map["SaobracajnaNezgodaIliZaustavljenoVoziloLevaCev-LevaTraka"] = latinToCyrillic ("Saobraćajna Nezgoda ili Zaustavljeno Vozilo Leva Cev - Leva Traka");
  map["VremenskeNeprilike-Klizavo1"] = latinToCyrillic ("Vremenske Neprilike - Klizavo 1");
  map["VremenskeNeprilike-Klizavo2"] = latinToCyrillic ("Vremenske Neprilike - Klizavo 2");
  map["VremenskeNeprilike-Magla1"] = latinToCyrillic ("Vremenske Neprilike - Magla 1");
  map["VremenskeNeprilike-Magla2"] = latinToCyrillic ("Vremenske Neprilike - Magla 2");
  map["VremenskeNeprilike-Poledica"] = latinToCyrillic ("Vremenske Neprilike - Poledica");
  map["VremenskeNeprilike-Sneg1"] = latinToCyrillic ("Vremenske Neprilike - Sneg 1");  
  map["VremenskeNeprilike-Sneg2"] = latinToCyrillic ("Vremenske Neprilike - Sneg 2");
  map["VremenskeNeprilike-Vetar1"] = latinToCyrillic ("Vremenske Neprilike - Vetar 1");
  map["VremenskeNeprilike-Vetar2"] = latinToCyrillic ("Vremenske Neprilike - Vetar 2");
  map["VoznjaUSuprotnomSmeruLevaCev"] = latinToCyrillic ("Voznja U Suprotnom Smeru - Leva Cev");
  map["VoznjaUSuprotnomSmeruDesnaCev"] = latinToCyrillic ("Voznja U Suprotnom Smeru - Desna Cev");
  return map;

}
