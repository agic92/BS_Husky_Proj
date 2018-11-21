#uses "activateRecipe.ctl"

/*-------------------------------------------------------------------------------------*/
bool pokreniScenarijPoledica() {
  string scenarij = "VremenskeNeprilike-Poledica";
  activateRecipe("CeliTunel", scenarij);
  
  return (provjeriUspjesnoPostavljanjeScenarija(scenarij));
}

/*-------------------------------------------------------------------------------------*/

bool pokreniScenarijSnijeg1() {
  string scenarij = "VremenskeNeprilike-Sneg1";
  activateRecipe("CeliTunel", scenarij);
  
  return (provjeriUspjesnoPostavljanjeScenarija(scenarij));
}
/*-------------------------------------------------------------------------------------*/

bool pokreniScenarijSnijeg2() {
  string scenarij = "VremenskeNeprilike-Sneg2";
  activateRecipe("CeliTunel", scenarij);
  
  return (provjeriUspjesnoPostavljanjeScenarija(scenarij));
}
/*-------------------------------------------------------------------------------------*/

bool pokreniScenarijVjetar1() {
  string scenarij = "VremenskeNeprilike-Vetar1";
  activateRecipe("CeliTunel", scenarij);
  
  return (provjeriUspjesnoPostavljanjeScenarija(scenarij));
}
/*-------------------------------------------------------------------------------------*/

bool pokreniScenarijVjetar2() {
  string scenarij = "VremenskeNeprilike-Vetar2";
  activateRecipe("CeliTunel", scenarij);
  
  return (provjeriUspjesnoPostavljanjeScenarija(scenarij));
}
/*-------------------------------------------------------------------------------------*/

bool pokreniScenarijMagla1() {
  string scenarij = "VremenskeNeprilike-Magla1";
  activateRecipe("CeliTunel", scenarij);
  
  return (provjeriUspjesnoPostavljanjeScenarija(scenarij));
}
/*-------------------------------------------------------------------------------------*/

bool pokreniScenarijMagla2() {
  string scenarij = "VremenskeNeprilike-Magla2";
  activateRecipe("CeliTunel", scenarij);
  
  return (provjeriUspjesnoPostavljanjeScenarija(scenarij));
}
/*-------------------------------------------------------------------------------------*/

bool pokreniScenarijKlizavo1() {
  string scenarij = "VremenskeNeprilike-Klizavo1";
  activateRecipe("CeliTunel", scenarij);
  
  return (provjeriUspjesnoPostavljanjeScenarija(scenarij));
}
/*-------------------------------------------------------------------------------------*/

bool pokreniScenarijKlizavo2() {
  string scenarij = "VremenskeNeprilike-Klizavo2";
  activateRecipe("CeliTunel", scenarij);
  
  return (provjeriUspjesnoPostavljanjeScenarija(scenarij));
}
/*-------------------------------------------------------------------------------------*/

bool provjeriUspjesnoPostavljanjeScenarija(string scenarij) {
  string trenutniScenarij;
  dpGet("SysSarani:CeliTunel.lastActivatedOfThisType", trenutniScenarij);
  
  return (scenarij==trenutniScenarij);
}
/*-------------------------------------------------------------------------------------*/
