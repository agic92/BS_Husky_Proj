/*03.04.2018 Umjesto mapiranja po nazivu parametra, rade se mapiranja po ID-u parametra*/


#uses "CtrlADO" //za omogućavanje db funkcija

int rcDb, rc, rc2;
  dbRecordset rs;
  anytype fld;
  int errCnt, errNo, errNative;
  string errDescr, errSql;
  dbConnection conn;
  dyn_dyn_float s2;
  dyn_mapping s1;
  

main () {
  timedFunc("processData", "prointer_ms"); 
}

processData(string dp,time t1, time t2)
{
  rcDb = dbOpenConnection("DSN=prointer;UID=glassfish;PWD=kliker;", conn);

  if (!rcDb)
  {
    DebugTN("Uspjesno otvorena konekcija");
    
    dyn_string meteoStations = makeDynString("SysSarani:MS1", "SysSarani:MS2", "SysBrdjani:MS1", "SysSavinac:MS1");
    
    for (int i=1;i<=dynlen(meteoStations); i++) {
      processMSData(meteoStations[i]);
    }
    
    rc = dbOpenRecordset(conn, "select pg_notify('event_changes, 'event_changes' || '_INSERT'", rs);
    dbCloseConnection (conn);
  }
  else {
    DebugTN("Neuspjesno otvaranje konekcije");
    rc2 = dbGetError (conn, errCnt, errNo, errNative, errDescr, errSql);
    if (!rc2)
    {
      DebugN("Errornumber : ", errNo);
      DebugN("BaseError : ", errNative);
      DebugN("Description : ", errDescr);
      DebugN("SQL-errortext: ", errSql);
    }
  }
  
  
}

processMSData (string dpe_ref) {
  string dpe = dpe_ref + ".response.state.";
  int mts_id, sen_id, mep_id;
  
  dyn_string parametri = makeDynString("Temperatura_Zraka",
                                       "Temperatura_Ceste",
                                       "Tacka_Rosista",
                                       "Relativna_Vlaznost",
                                       "Smjer_Vjetra",
                                       "Pritisak_Zraka",
                                       "Tip_Padavina",
                                       "Intezitet_Padavina",
                                       "Kolicina_Padavina",
                                       "Vidljivost",
                                       "Stanje_Ceste",
                                       "Brzina_Vjetra",
                                       "Visina_vodenog_sloja",
                                       "Temperatura_Smrzavanja_Soli",
                                       "Temperatura_Ceste2",
                                       "Visina_vodenog_sloja2",
                                       "Temperatura_Smrzavanja_Soli2",
                                       "Stanje_Ceste2");
  
  mts_id = getMeteostationId(dpe_ref);
    
  for (int i=1; i<=dynlen(parametri); i++) {
    string vrijednost_parametra;
    dpGet(dpe + parametri[i], vrijednost_parametra);
    mep_id = getParameterId(parametri[i]);
    sen_id = getSensorId(dpe_ref, parametri[i]);
    insertData(mts_id, mep_id, sen_id, vrijednost_parametra);
//       DebugTN("parametar: " +  parametri[i] + ", parametar_id: " + mep_id + ", senzor_id: " + sen_id);
  }
    
}


int getMeteostationId(string ms) {
  string naziv_meteostanice = getMapiraniNazivMeteostanice(ms);
  rc = dbOpenRecordset(conn, "select id from pmis.meteo_stanica where naziv like '" + naziv_meteostanice + "%'", rs);
  rc = dbGetField (rs, 0, fld);
  return fld;
}

int getParameterId(string parametar) {
  /*string naziv_parametra = getMapiraniNazivParametra(parametar);
  rc = dbOpenRecordset(conn, "select id from pmis.merni_parametri where naziv like '" + naziv_parametra + "%'", rs);
  rc = dbGetField (rs, 0, fld);*/
  
  
  mapping m;
  m["Temperatura_Zraka"] = 1;//1
  m["Temperatura_Ceste"] = 2;//2
  m["Tacka_Rosista"] = 3;//3
  m["Relativna_Vlaznost"] = 4;//4
  m["Smjer_Vjetra"] = 5;//5
  m["Pritisak_Zraka"] = 6;//6
  m["Tip_Padavina"] = 7;//7
  m["Intezitet_Padavina"] = 8;//8
  m["Kolicina_Padavina"] = 26;//26
  m["Vidljivost"] = 9;//9
  m["Stanje_Ceste"] = 10;//10;
  m["Brzina_Vjetra"] = 11;//11
  m["Visina_vodenog_sloja"] = 12;//12
  m["Temperatura_Smrzavanja_Soli"] = 13;//13
  m["Temperatura_Ceste2"] = 2;//2
  m["Visina_vodenog_sloja2"] = 12;//12
  m["Temperatura_Smrzavanja_Soli2"] = 13;//13
  m["Stanje_Ceste2"] = 10;//10
  
  for (int i=1; i<=mappinglen(m); i++) {
    if (mappingGetKey(m, i) == parametar) {
      return mappingGetValue(m, i);
    }
  }
  return -1;
  
  
  
  
  
  return fld;
}

int getSensorId(string ms, string parametar) {
  string naziv_senzora = getNazivSenzora(ms, parametar);
  rc = dbOpenRecordset(conn, "select id from pmis.senzor where naziv like '%" + naziv_senzora + "%'", rs);
  rc = dbGetField (rs, 0, fld);
  return fld;
}

void insertData(int mts_id, int mep_id, int sen_id, int vrijednost_parametra) {
  time t = getCurrentTime();
  string datum = formatTime("%Y-%m-%d", t);
  string vrijeme = formatTime("%H:%M:%S", t);
  string command = "insert into pmis.rezultati_merenja (id,sen_id,mts_id,mep_id,vrednost,datum,vreme) values (nextval('pmis.rezultati_merenja_seq')," + sen_id + "," + mts_id + "," + mep_id + "," + vrijednost_parametra + ",'"
                                                                                                             + datum + "','" + vrijeme + "')";
  rc = dbBulkCommand(conn, makeDynString(command));
//   DebugTN("command: " + command + "\ndbBulkCommand: " + rc);
}
string getMapiraniNazivMeteostanice(string ms) {
  mapping m;
  m["System1:MS1"] = "MS Šarani1";
  m["SysSarani:MS1"] = "MS Šarani1";
  m["SysSarani:MS2"] = "MS Šarani2";
  m["SysBrdjani:MS1"] = "MS Preljina";
  m["SysSavinac:MS1"] = "MS Takovo";
  
  for (int i=1; i<=mappinglen(m); i++) {
    if (mappingGetKey(m, i) == ms) {
      return mappingGetValue(m, i);
    }
  }
  return "";
}

string getMapiraniNazivParametra(string ms) {
  mapping m;
  m["Temperatura_Zraka"] = "Temperatura vazduha";//1
  m["Temperatura_Ceste"] = "Temperatura ceste";//2
  m["Tacka_Rosista"] = "Tačka rosišta";//3
  m["Relativna_Vlaznost"] = "Relativna vlažnost";//4
  m["Smjer_Vjetra"] = "Smer vetra";//5
  m["Pritisak_Zraka"] = "Pritisak";//6
  m["Tip_Padavina"] = "Tip padavina";//7
  m["Intezitet_Padavina"] = "Intezitet padavina";//8
  m["Kolicina_Padavina"] = "Količina padavina";//26
  m["Vidljivost"] = "Vidljivost";//9
  m["Stanje_Ceste"] = "Stanje ceste";//10;
  m["Brzina_Vjetra"] = "Brzina vetra";//11
  m["Visina_vodenog_sloja"] = "Visina vodenog sloja";//12
  m["Temperatura_Smrzavanja_Soli"] = "Temperatura smrzavanja soli";//13
  m["Temperatura_Ceste2"] = "Temperatura ceste";//2
  m["Visina_vodenog_sloja2"] = "Visina vodenog sloja";//12
  m["Temperatura_Smrzavanja_Soli2"] = "Temperatura smrzavanja soli";//13
  m["Stanje_Ceste2"] = "Stanje ceste";//10
  
  for (int i=1; i<=mappinglen(m); i++) {
    if (mappingGetKey(m, i) == ms) {
      return mappingGetValue(m, i);
    }
  }
  return "";
}

string getNazivSenzora(string ms, string parametar) {
  string naziv_senzora, naziv_meteostanice;
  
  switch(ms) {
        case "System1:MS1":
        case "SysSarani:MS1":
          naziv_meteostanice = "MS1";
          break;
        case "SysSarani:MS2":
          naziv_meteostanice = "MS2";
          break;
        case "SysBrdjani:MS1":
          naziv_meteostanice = "MS3";
          break;
        case "SysSavinac:MS1":
          naziv_meteostanice = "MS4";
          break;
      }
  
  
  switch(parametar) {
    case "Temperatura_Ceste":
    case "Stanje_Ceste":
    case "Visina_vodenog_sloja":
    case "Temperatura_Smrzavanja_Soli":
      switch(ms) {
        case "System1:MS1":
        case "SysSarani:MS1":
        case "SysBrdjani:MS1":
          naziv_senzora = naziv_meteostanice + "-IDMS_36865";
          break;
        case "SysSarani:MS2":
        case "SysSavinac:MS1":
          naziv_senzora = naziv_meteostanice + "-IDMS_4097";
          break;
      }
      break;
    case "Temperatura_Ceste2":
    case "Stanje_Ceste2":
    case "Visina_vodenog_sloja2":
    case "Temperatura_Smrzavanja_Soli2":
      switch(ms) {
        case "System1:MS1":
        case "SysSarani:MS1":
        case "SysBrdjani:MS1":
          naziv_senzora = naziv_meteostanice + "-IDMS_36866";
          break;
        case "SysSarani:MS2":
        case "SysSavinac:MS1":
          naziv_senzora = naziv_meteostanice + "-IDMS_4098";
          break;
      }
      break;
    case "Vidljivost":
      naziv_senzora = naziv_meteostanice + "-IDMS_12289";
      break;
    default:
      naziv_senzora = naziv_meteostanice + "-IDMS_28673";
      break;
  }
  return naziv_senzora;
}
