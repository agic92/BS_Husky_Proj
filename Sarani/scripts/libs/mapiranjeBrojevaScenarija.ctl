#uses "latin_to_cyrillic.ctl"

mapping dohvatiMapuScenarija() {
  mapping map;
  
  map[0] = latinToCyrillic ("Redovni Uslovi Odvijanju Saobraćaja");
  map[1] = latinToCyrillic ("Požar - Vatrodojavna Zona 1");
  map[2] = latinToCyrillic ("Požar - Vatrodojavna Zona 2");
  map[3] = latinToCyrillic ("Požar - Vatrodojavna Zona 3");
  map[4] = latinToCyrillic ("Požar - Vatrodojavna Zona 4");
  map[5] = latinToCyrillic ("Požar - Vatrodojavna Zona 5");
  map[6] = latinToCyrillic ("Požar - Vatrodojavna Zona 6");
  map[7] = latinToCyrillic ("Požar - Vatrodojavna Zona 7");
  map[8] = latinToCyrillic ("Požar - Vatrodojavna Zona 8");
  map[9] = latinToCyrillic ("Požar - Vatrodojavna Zona 9");
  map[10] = latinToCyrillic ( "Požar - Vatrodojavna Zona 10");
  map[11] = latinToCyrillic ( "Požar - Vatrodojavna Zona 11");
  map[12] = latinToCyrillic ( "Požar - Vatrodojavna Zona 12");
  map[13] = latinToCyrillic ( "Požar - Vatrodojavna Zona 13");
  map[14] = latinToCyrillic ( "Požar - Vatrodojavna Zona 14");
  map[15] = latinToCyrillic ( "Požar - Vatrodojavna Zona 15");
  map[16] = latinToCyrillic ( "Požar - Vatrodojavna Zona 16");
  map[17] = latinToCyrillic ( "Požar - Vatrodojavna Zona 17");
  
  map[18] = latinToCyrillic ("Saobraćajna Nezgoda ili Zaustavljeno Vozilo Desna Cev - Desna Traka");  
  map[19] = latinToCyrillic ("Saobraćajna Nezgoda ili Zaustavljeno Vozilo Desna Cev - Leva Traka");
  map[20] = latinToCyrillic ("Saobraćajna Nezgoda ili Zaustavljeno Vozilo Leva Cev - Desna Traka");
  map[21] = latinToCyrillic ("Saobraćajna Nezgoda ili Zaustavljeno Vozilo Leva Cev - Leva Traka");
  
  map[22] = latinToCyrillic ("Vremenske Neprilike - Klizavo 1");
  map[23] = latinToCyrillic ("Vremenske Neprilike - Klizavo 2");
  map[24] = latinToCyrillic ("Vremenske Neprilike - Magla 1");
  map[25] = latinToCyrillic ("Vremenske Neprilike - Magla 2");
  map[26] = latinToCyrillic ("Vremenske Neprilike - Poledica");
  map[27] = latinToCyrillic ("Vremenske Neprilike - Sneg 1");  
  map[28] = latinToCyrillic ("Vremenske Neprilike - Sneg 2");
  map[29] = latinToCyrillic ("Vremenske Neprilike - Vetar 1");
  map[30] = latinToCyrillic ("Vremenske Neprilike - Vetar 2");
  
  map[31] = latinToCyrillic ("Kolona Vozila Desna Cev - Ograničenje 40");
  map[32] = latinToCyrillic ("Kolona Vozila Desna Cev - Ograničenje 60");
  map[33] = latinToCyrillic ("Kolona Vozila Leva Cev - Ograničenje 40");
  map[34] = latinToCyrillic ("Kolona Vozila Leva Cev - Ograničenje 60");
  
  map[35] = latinToCyrillic ("Obustava Saobraćaja Desna Cev");
  map[36] = latinToCyrillic ("Obustava Saobraćaja LevaCev");
  
  //Ove treba dodati u scenarije
  map[37] = latinToCyrillic ("Voznja U Suprotnom Smeru - Leva Cev");
  map[38] = latinToCyrillic ("Voznja U Suprotnom Smeru - Desna Cev");
  
  map[39] = latinToCyrillic("Požar u tunelu - kolona vozila ispred požara");
  
  map[40] = latinToCyrillic ("Radovi Desna Cev - Desna Traka");
  map[41] = latinToCyrillic ("Radovi Desna Cev - Leva Traka");
  map[42] = latinToCyrillic ("Radovi Leva Cev - Desna Traka");
  map[43] = latinToCyrillic ("Radovi Leva Cev - Leva Traka");
  map[44] = latinToCyrillic ("Radovi Zatvorena Desna Cev");
  map[45] = latinToCyrillic ("Radovi Zatvorena Leva Cev");
  
  map[46] = latinToCyrillic ("Kolona Vozila Obe Cevi - Ogranicenje 40");
  map[47] = latinToCyrillic ("Kolona Vozila Obe Cevi - Ogranicenje 60");
  map[48] = latinToCyrillic ("Obustava Saobracaja Obe Cevi");
 
  map[-1] = " ";
  return map;
}

dyn_string getNaziviScenarija (dyn_int brojeviScenarija) {
  mapping m = dohvatiMapuScenarija();
  dyn_string nazivi;
  for (int i=1; i<=dynlen(brojeviScenarija); i++) {
    if (mappingHasKey(m, brojeviScenarija[i])) {
      dynAppend(nazivi, m[brojeviScenarija[i]]);
    }
  }
  return nazivi;
}

int getBrojScenarija (string scenarij) {
  mapping m = dohvatiMapuScenarija();
  string broj;
  dyn_string nazivi;
  for (int i=1; i<=mappinglen(m); i++) {
    string value = mappingGetValue(m, i);
    if (value == scenarij) {
      return mappingGetKey(m,i);
      
    }
  }
  return -1;
}

int getAlgoritamRasvjete(int broj_algoritma) {
  
  // 0 - automatika u ovisnosti od nivoa osvjetljenja prilazne zone i doba dana
  // 1 - desna na 100%, lijeva adaptivna na automatici, bazna ista u cijelom tunelu = 100%, 
  //     prilazna u desnoj ukljucena, u lijevoj na automatici
  // 2 - lijeva na 100%, desna adaptivna na automatici, bazna ista u cijelom tunelu = 100%, 
  //     prilazna u lijevoj ukljucena, u desnoj na automatici
  // 3 - sva rasvjeta u tunelu na 100%, ukljucena i prilazna
  mapping map;
  
  map[0] = 0;  
  
  map[1] = 1;
  map[2] = 1;
  map[3] = 1;
  map[4] = 1;
  map[5] = 1;
  map[6] = 1;
  map[7] = 1;
  map[8] = 1;
  map[9] = 1;
  map[10] = 2;
  map[11] = 2;
  map[12] = 2;
  map[13] = 2;
  map[14] = 2;
  map[15] = 2;
  map[16] = 2;
  map[17] = 2;
  
  map[18] = 1;  
  map[19] = 1;
  map[20] = 2;
  map[21] = 2;
  
  map[22] = 0;
  map[23] = 0;
  map[24] = 0;
  map[25] = 0;
  map[26] = 0;
  map[27] = 0;  
  map[28] = 0;
  map[29] = 0;
  map[30] = 0;
  
  map[31] = 0; 
  map[32] = 0;
  map[33] = 0;
  map[34] = 0;
  
  map[35] = 3;
  map[36] = 3;
  
  //Ove treba dodati u scenarije
  map[37] = 1;
  map[38] = 2;
  
  //map[39] = latinToCyrillic("Požar u tunelu - kolona vozila ispred požara");
  
  map[40] = 0;
  map[41] = 0;
  map[42] = 0;
  map[43] = 0;
  map[44] = 0;
  map[45] = 0;
  
  map[46] = 0;
  map[47] = 0;
  map[48] = 3;
  
  for (int i=1; i<=mappinglen(map); i++) {
    if (mappingGetKey(map, i) == broj_algoritma) {
      return mappingGetValue(map, i);
    }
  }
  return 0;
}


dyn_string getAlgoritamOzvucenja(int broj_algoritma) {
  
  // 0 - razglas iskljucen
  // 1 - ukljucena prva trecina desne cijevi
  // 2 - ukljucena druga trecina desne cijevi
  // 3 - ukljucena treca trecina desne cijevi
  // 4 - ukljucena prva trecina lijeve cijevi
  // 5 - ukljucena druga trecina lijeve cijevi
  // 6 - ukljucena treca trecina lijeve cijevi
  // 7 - ukljucena horna u kolskom prolazu
  mapping map;
   
  map[0] = makeDynString("");  
  /*
  map[1] = makeDynString("Sarani 1-1");
  map[2] = makeDynString("Sarani 1-1");
  map[3] = makeDynString("Sarani 1-1");
  map[4] = makeDynString("Sarani 1-1","Sarani 1-2","Sarani 1-Kolski");
  map[5] = makeDynString("Sarani 1-1","Sarani 1-2","Sarani 1-Kolski");
  map[6] = makeDynString("Sarani 1-2");
  map[7] = makeDynString("Sarani 1-2");
  map[8] = makeDynString("Sarani 1-3");
  map[9] = makeDynString("Sarani 1-3");
  map[10] = makeDynString("Sarani 2-1");
  map[11] = makeDynString("Sarani 2-1");
  map[12] = makeDynString("Sarani 2-2");
  map[13] = makeDynString("Sarani 2-1","Sarani 2-Kolski");
  map[14] = makeDynString("Sarani 2-1","Sarani 2-Kolski");
  map[15] = makeDynString("Sarani 2-3");
  map[16] = makeDynString("Sarani 2-3");
  map[17] = makeDynString("Sarani 2-3");*/
  
  map[1] = makeDynString("Sarani 1-Sve");  //("Sarani 1-1","Sarani 1-2", "Sarani 1-3", "Sarani 1-Kolski");
  map[2] = makeDynString("Sarani 1-Sve");  //("Sarani 1-1","Sarani 1-2", "Sarani 1-3", "Sarani 1-Kolski");
  map[3] = makeDynString("Sarani 1-Sve");  //("Sarani 1-1","Sarani 1-2", "Sarani 1-3", "Sarani 1-Kolski");
  map[4] = makeDynString("Sarani 1-Sve");  //("Sarani 1-1","Sarani 1-2", "Sarani 1-3", "Sarani 1-Kolski");
  map[5] = makeDynString("Sarani 1-Sve");  //("Sarani 1-1","Sarani 1-2", "Sarani 1-3", "Sarani 1-Kolski");
  map[6] = makeDynString("Sarani 1-Sve");  //("Sarani 1-1","Sarani 1-2", "Sarani 1-3", "Sarani 1-Kolski");
  map[7] = makeDynString("Sarani 1-Sve");  //("Sarani 1-1","Sarani 1-2", "Sarani 1-3", "Sarani 1-Kolski");
  map[8] = makeDynString("Sarani 1-Sve");  //("Sarani 1-1","Sarani 1-2", "Sarani 1-3", "Sarani 1-Kolski");
  map[9] = makeDynString("Sarani 1-Sve");  //("Sarani 1-1","Sarani 1-2", "Sarani 1-3", "Sarani 1-Kolski");
  map[10] = makeDynString("Sarani 2-Sve");  //("Sarani 2-1", "Sarani 2-2", "Sarani 2-3", "Sarani 2-Kolski");
  map[11] = makeDynString("Sarani 2-Sve");  //("Sarani 2-1", "Sarani 2-2", "Sarani 2-3", "Sarani 2-Kolski");
  map[12] = makeDynString("Sarani 2-Sve");  //("Sarani 2-1", "Sarani 2-2", "Sarani 2-3", "Sarani 2-Kolski");
  map[13] = makeDynString("Sarani 2-Sve");  //("Sarani 2-1", "Sarani 2-2", "Sarani 2-3", "Sarani 2-Kolski");
  map[14] = makeDynString("Sarani 2-Sve");  //("Sarani 2-1", "Sarani 2-2", "Sarani 2-3", "Sarani 2-Kolski");
  map[15] = makeDynString("Sarani 2-Sve");  //("Sarani 2-1", "Sarani 2-2", "Sarani 2-3", "Sarani 2-Kolski");
  map[16] = makeDynString("Sarani 2-Sve");  //("Sarani 2-1", "Sarani 2-2", "Sarani 2-3", "Sarani 2-Kolski");
  map[17] = makeDynString("Sarani 2-Sve");  //("Sarani 2-1", "Sarani 2-2", "Sarani 2-3", "Sarani 2-Kolski");
  
  map[18] = makeDynString("");   
  map[19] = makeDynString(""); 
  map[20] = makeDynString(""); 
  map[21] = makeDynString(""); 
  
  map[22] = makeDynString(""); 
  map[23] = makeDynString(""); 
  map[24] = makeDynString(""); 
  map[25] = makeDynString(""); 
  map[26] = makeDynString(""); 
  map[27] = makeDynString("");   
  map[28] = makeDynString(""); 
  map[29] = makeDynString(""); 
  map[30] = makeDynString(""); 
  
  map[31] = makeDynString("");  
  map[32] = makeDynString(""); 
  map[33] = makeDynString(""); 
  map[34] = makeDynString(""); 
  
  map[35] = makeDynString(""); 
  map[36] = makeDynString(""); 
  
  //Ove treba dodati u scenarije
  map[37] = makeDynString(""); 
  map[38] = makeDynString(""); 
  
  //map[39] = latinToCyrillic("Požar u tunelu - kolona vozila ispred požara");
  
  map[40] = makeDynString(""); 
  map[41] = makeDynString(""); 
  map[42] = makeDynString(""); 
  map[43] = makeDynString(""); 
  map[44] = makeDynString(""); 
  map[45] = makeDynString(""); 
  
  map[46] = makeDynString(""); 
  map[47] = makeDynString(""); 
  map[48] = makeDynString(""); 
  
  for (int i=1; i<=mappinglen(map); i++) {
    if (mappingGetKey(map, i) == broj_algoritma) {
      return mappingGetValue(map, i);
    }
  }
  return "";
}

