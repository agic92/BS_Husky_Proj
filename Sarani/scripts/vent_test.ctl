main()
{
  string sCopy1 = "cp /home/sarani/BS_Husky_projects/TakovoPreljina/log/PVSS_II.log /home/sarani/logovi/dpConnect_problem/`date +%Y_%m_%d_%H:%M:%S`.log &";
  string sCopy2 = "cp /home/sarani/BS_Husky_projects/TakovoPreljina/log/PVSS_II.log.bak /home/sarani/logovi/dpConnect_problem/`date +%Y_%m_%d_%H:%M:%S`.log.bak &";
  system(sCopy1);
  system(sCopy2);
   //dpConnect("javljanje","SysSarani:V18_4-1L.function.clock", "SysSarani:grupa_1.glavni_prekidac_L", "SysSarani:grupa_1.UPS_aktivan");
}


javljanje(string dp1,bool clock_state, string dp2,bool glavni_prekidac, string dp3, bool ups_aktivan)
{
  DebugTN("javljanje - ", clock_state, glavni_prekidac, ups_aktivan);
}
