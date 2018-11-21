main()
{
    timedFunc("Reset","_Broj_vozila");  
}

//reset trenutnog broja vozila svako sat vremena
Reset(string trenutni_broj_vozila,time t1, time t2)
{

  dyn_dyn_anytype list;
  dpQuery("SELECT '_original.._value' FROM '*.trenutni_broj_vozila'", list);

  for (int i = 2; i <= dynlen(list); i++)
  { 
      string element = dpSubStr(list[i][1], DPSUB_DP);      
      dpSet(element + ".trenutni_broj_vozila", 0);
      DebugTN("Resetovan trenutni broj vozila, " + element);
  } 

}
