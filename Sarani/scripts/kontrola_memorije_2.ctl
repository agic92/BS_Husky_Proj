main()
{
  dpConnect("work", "SysSarani:_MemoryCheck_2.FreePerc");
  
  dpConnect("work2", "SysSarani:memory_check.server2", "SysSarani:memory_check_interval2.server2");
}

work (string dp1, int memory) {
  if (memory < 20) {
    string t = "ps aux --sort -rss >>/home/sarani/memory/memory_" + memory + ".txt";
    system(t);
    DebugTN("Memorija pala na kritični nivo: " + memory + "%");
  }
}

work2 (string dp1, int razlika1, string dp2, int razlika2) {
  string k = formatTime("%H_%M_%S", getCurrentTime());
  if (razlika1 >= 5 || razlika2 >= 3) {
    string t = "ps aux --sort -rss >>/home/sarani/memory_interval2/memory_" + k + ".txt";
    system(t);
    DebugTN("Razlika memorija na početku i kraju intervala na kritičnom nivou: " + razlika1 + "%, razlika2: " + razlika2 + "%");
  }
}
