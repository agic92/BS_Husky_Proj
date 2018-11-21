main()
{
  startThread("YellowBlinker");
}

YellowBlinker()
{
  bool bSync = false;
  while(1)
  {
    bSync = bSync ^ 1; 
    dpSet("SysSarani:BS.Blinker", bSync);
    delay(0,750);  
  }
}
