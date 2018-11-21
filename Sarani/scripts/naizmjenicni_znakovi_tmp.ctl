main() {
  while(1) {
    dpSet("SysSarani:VMS1-TKD1.command.izbor_znaka", 17);
    dpSet("SysSarani:VMS2-TKD1.command.izbor_znaka", 17);
    dpSet("SysSarani:VMS5-TKL1.command.izbor_znaka", 17);
    dpSet("SysSarani:VMS6-TKL1.command.izbor_znaka", 17);
    delay(5);
    dpSet("SysSarani:VMS1-TKD1.command.izbor_znaka", 25);
    dpSet("SysSarani:VMS2-TKD1.command.izbor_znaka", 25);
    dpSet("SysSarani:VMS5-TKL1.command.izbor_znaka", 25);
    dpSet("SysSarani:VMS6-TKL1.command.izbor_znaka", 25);
    delay(5);
  }
}
