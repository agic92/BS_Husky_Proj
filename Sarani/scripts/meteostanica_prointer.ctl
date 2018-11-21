#uses "CtrlADO" //za omogućavanje db funkcija

int rc, rc2;
  dbRecordset rs;
  anytype fld;
  int errCnt, errNo, errNative;
  string errDescr, errSql;
  dbConnection conn;
  float latitude, longitude;
  dyn_dyn_float s2;
  mapping m1, m2, m3_1, m3_2;
  dyn_mapping s1;
  
main () {
  //DebugTN("start");
  startThread("Sarani1");
  startThread("Sarani2");
  startThread("Brdjani");
  startThread("Savinac");

}

Sarani1(string dp, time ocitanje) {
  dpConnect("meteostanica", "SysSarani:MS1.response.state.Zadnje_ocitanje");
}

Sarani2(string dp, time ocitanje) {
  dpConnect("meteostanica", "SysSarani:MS2.response.state.Zadnje_ocitanje");
}

Brdjani(string dp, time ocitanje) {
  dpConnect("meteostanica", "SysBrdjani:MS1.response.state.Zadnje_ocitanje");
}

Savinac(string dp, time ocitanje) {
  dpConnect("meteostanica", "SysSavinac:MS1.response.state.Zadnje_ocitanje");
}


meteostanica(string dp, time zadnje_ocitanje) {
  string dpe_ref = dpSubStr(dp, DPSUB_SYS_DP);
  string dpe = dpe_ref + ".response.state.";
  string temp_zraka, temp_ceste, tacka_rosista, rel_vlaznost, smjer_vjetra, pritisak, 
         tip_padavina, int_padavina, vidljivost, stanje_ceste, brzina_vjetra, 
         visina_vod_sloja, temp_smrz_soli, kol_padavina, temp_ceste2, visina_vod_sloja2, stanje_ceste2, temp_smrz_soli2, vrijednost_parametra;
  int mts_id, sen_id, mep_id;
//   DebugTN("DPE: " + dpSubStr(dp, DPSUB_DP_EL));
  
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
  
  rc = dbOpenConnection("DSN=prointer;UID=glassfish;PWD=kliker;", conn);

  if (!rc)
  {
    DebugTN("Uspjesno otvorena konekcija: " + dpe_ref);
    mts_id = getMeteostationId(dpe_ref);
    
    for (int i=1; i<=dynlen(parametri); i++) {
      dpGet(dpe + parametri[i], vrijednost_parametra);
      mep_id = getParameterId(parametri[i]);
      sen_id = getSensorId(dpe_ref, parametri[i]);
      insertData(mts_id, mep_id, sen_id, vrijednost_parametra);
//       DebugTN("parametar: " +  parametri[i] + ", parametar_id: " + mep_id + ", senzor_id: " + sen_id);
    }
    
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

int getMeteostationId(string ms) {
  string naziv_meteostanice = getMapiraniNazivMeteostanice(ms);
  rc = dbOpenRecordset(conn, "select id from pmis.meteo_stanica where naziv like '" + naziv_meteostanice + "%'", rs);
  rc = dbGetField (rs, 0, fld);
  return fld;
}

int getParameterId(string parametar) {
  string naziv_parametra = getMapiraniNazivParametra(parametar);
  rc = dbOpenRecordset(conn, "select id from pmis.merni_parametri where naziv like '" + naziv_parametra + "%'", rs);
  rc = dbGetField (rs, 0, fld);
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
  m["Temperatura_Zraka"] = "Temperatura zraka";
  m["Temperatura_Ceste"] = "Temperatura ceste";
  m["Tacka_Rosista"] = "Tačka rosišta";
  m["Relativna_Vlaznost"] = "Relativna vlažnost";
  m["Smjer_Vjetra"] = "Smer vetra";
  m["Pritisak_Zraka"] = "Pritisak";
  m["Tip_Padavina"] = "Tip padavina";
  m["Intezitet_Padavina"] = "Intezitet padavina";
  m["Kolicina_Padavina"] = "Količina padavina";
  m["Vidljivost"] = "Vidljivost";
  m["Stanje_Ceste"] = "Stanje ceste";
  m["Brzina_Vjetra"] = "Brzina vetra";
  m["Visina_vodenog_sloja"] = "Visina vodenog sloja";
  m["Temperatura_Smrzavanja_Soli"] = "Temperatura smrzavanja soli";
  m["Temperatura_Ceste2"] = "Temperatura ceste";
  m["Visina_vodenog_sloja2"] = "Visina vodenog sloja";
  m["Temperatura_Smrzavanja_Soli2"] = "Temperatura smrzavanja soli";
  m["Stanje_Ceste2"] = "Stanje ceste";
  
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
