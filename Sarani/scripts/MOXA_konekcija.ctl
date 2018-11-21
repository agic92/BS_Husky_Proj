void main() {
  //timedFunc("pratiMoxu", "KonekcijaMOXA");
}

pratiMoxu (string dp, time t1, time t2) {
  string query = "SELECT '_online.._value' FROM '*.state.provjera_komunikacije'"; //'*A1.alarm.slice_diagnosis'";
  dyn_dyn_anytype niz;
  dpQuery(query, niz);
  time t;
  time now = getCurrentTime();
  string s;
  
  for (int i=2; i<=dynlen(niz); i++) {
    dpGet(niz[i][1]+":_online.._stime",  t);
    int razlika = (int)now - (int)t;
    bool zadnjeAktivnoStanje;
    dpGet("SysSarani:" + dpSubStr(niz[i][1], DPSUB_DP) + ".state.gubitak_komunikacije", zadnjeAktivnoStanje);
    if (razlika>=9 && !zadnjeAktivnoStanje) {
      dpSet("SysSarani:" + dpSubStr(niz[i][1], DPSUB_DP) + ".state.gubitak_komunikacije", 1);
    }
    else if (zadnjeAktivnoStanje && razlika<9) {
      dpSet("SysSarani:" + dpSubStr(niz[i][1], DPSUB_DP) + ".state.gubitak_komunikacije", 0);
    }
  }
}
