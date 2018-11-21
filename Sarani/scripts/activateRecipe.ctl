void activateRecipe(string rct, string rcp){ 

  // This activates a selected recipe, in case of validity.
  string  lastUseOfType,lastActUser,lastUsage,err,validRecipe,validType;
  dyn_float	 df;
  dyn_string ds,elementValues,elements;

  if (rct == ""){
    string sMessageText=getCatStr("Recipe", "rct_select");
    ChildPanelOnCentralReturn("vision/MessageInfo1",getCatStr("general","information"),makeDynString(sMessageText),df,ds);
    return;
  }
  
  if (rcp == ""){
    string sMessageText=getCatStr("Recipe", "rcp_select");
    ChildPanelOnCentralReturn("vision/MessageInfo1",getCatStr("general","information"),makeDynString(sMessageText),df,ds);
    return;
  }
  
  // Check if the selected rct is still valid.
  // If it is not - set all values to empty.
  if (!dpExists(rct)){
    string 		sMessageText=getCatStr("Recipe","recipeType_not_exists");
	   ChildPanelOnCentralReturn("vision/MessageWarning",getCatStr("general","warning"), makeDynString(sMessageText),df,ds);
    return;
  }  
  
  // Check if the selected rcp is still valid
  if (!dpExists(rcp))
  {
    string sMessageText = getCatStr("Recipe", "recipe_not_exists");
	   ChildPanelOnCentralReturn("vision/MessageWarning",getCatStr("general","warning"),makeDynString(sMessageText),df,ds);
    return;
  }
  
  // Open progress bar, activate the recipe and check possible errors.
  if (err == "") openProgressBar("Rezepte","",getCatStr("Recipe","rcp_activation1")+"\""+ rcp +"\""+getCatStr("Recipe","rcp_activation2"), "", "", 1);
  
  //Ovdje aktivira scenarij
  rcp_activateRecipe(rcp, rct, err);

  if (err == -1){
    string sMessageText=getCatStr("Recipe","rct_error_act");
    closeProgressBar();
    ChildPanelOnCentralReturn("vision/MessageWarning",getCatStr("general","warning"),makeDynString(sMessageText),df,ds);
    return;
  } 
  if (err == -2){
    string sMessageText=getCatStr("Recipe","rcp_error_act");
    closeProgressBar();
    ChildPanelOnCentralReturn("vision/MessageWarning",getCatStr("general","warning"),makeDynString(sMessageText),df,ds);
    return;
  }
  if (err == -3){
    string sMessageText=getCatStr("Recipe","rcp_number_rct");
    closeProgressBar();
    ChildPanelOnCentralReturn("vision/MessageWarning",getCatStr("general","warning"),makeDynString(sMessageText),df,ds);
    return;
  }
  if (err == -5){
    string sMessageText=getCatStr("va","action.fileSwitch.progress_1");
    closeProgressBar();
    ChildPanelOnCentralReturn("vision/MessageWarning",getCatStr("general","warning"),makeDynString(sMessageText),df,ds);
    return;
  }
  if (err == -6){
    string sMessageText=getCatStr("sim","no_sims_to_delete");
    closeProgressBar();
    ChildPanelOnCentralReturn("vision/MessageWarning",getCatStr("general","warning"),makeDynString(sMessageText),df,ds);
    return;
  }
  
  // Case OK: Set all fields with the new values
  if (err == 0 || err == ""){
    string sMessageText = getCatStr("Recipe","rcp_activated");
    closeProgressBar();
    //ChildPanelOnCentralReturn("vision/MessageInfo1",getCatStr("general","information"),makeDynString("Scenarij pokrenut"), df, ds);
  }
  
}
