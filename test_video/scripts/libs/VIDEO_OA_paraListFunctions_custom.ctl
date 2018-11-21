//----------------------------------------------------------------
/*
  dyn_bool VIDEO_OA_paraListGetVisibleDisplaysForGridname(string gridname, bool emptyDefault = 0)
  function returns a dyn field with visibilty informations on a 24 grid based display
  
   1  2  3  4  5  6
   7  8  9 10 11 12
  13 14 15 16 17 18
  19 20 21 22 23 24
  
  @author MN
  @param  gridname           : gridname
  @param  emptyDefault       : 0 = return an empty field for an undefined gridname
                               1 = return an field with 1 for each index

*/
//----------------------------------------------------------------

dyn_bool VIDEO_OA_paraListGetVisibleDisplaysForGridname(string gridname, bool emptyDefault = 0)
{
  dyn_bool displayVisible;
  
  switch (gridname) 
  {
    
    // version fix grids
    case "1x1" : 
             displayVisible = makeDynBool(1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0); 
             break;   
    case "2x2" : 
             displayVisible = makeDynBool(1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0); 
             break;
    case "2x3" : 
             displayVisible = makeDynBool(1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0); 
             break;
    case "3x4": 
             displayVisible = makeDynBool(1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0); 
             break;
    case "4x6": 
             displayVisible = makeDynBool(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1); 
             break;
             
             
    // version free grids            
    case "1+2" : 
             displayVisible = makeDynBool(1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0); 
             break;
    case "2+1" :  
             displayVisible = makeDynBool(1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0); 
             break;
    case "3+2" : 
             displayVisible = makeDynBool(1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);              
             break;
    case "2+3": 
             displayVisible = makeDynBool(1, 0, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);  
             break;
    case "2T": 
             displayVisible = makeDynBool(1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0);  
             break;
    case "user_6": 
             displayVisible = makeDynBool(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);   
             break;
    case "user_7": 
             displayVisible = makeDynBool(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1); 
             break;
    case "user_8": 
             displayVisible = makeDynBool(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1); 
             break;
    case "user_9": 
             displayVisible = makeDynBool(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1); 
             break;
    case "user_10": 
             displayVisible = makeDynBool(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1); 
             break;
    case "user_11": 
             displayVisible = makeDynBool(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1); 
             break;
    case "user_12": 
             displayVisible = makeDynBool(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1); 
             break;
    case "user_13": 
             displayVisible = makeDynBool(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1); 
             break;
    case "user_14": 
             displayVisible = makeDynBool(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1); 
             break;
    case "user_15": 
             displayVisible = makeDynBool(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1); 
             break;
    case "user_16": 
             displayVisible = makeDynBool(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1); 
             break;
             
    default: 
             if(!emptyDefault)
               displayVisible = makeDynBool(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1); // undefined grid
             else
               displayVisible = makeDynBool(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);         
  }
  return displayVisible;
}


//----------------------------------------------------------------
/*
  dyn_int VIDEO_OA_paraList_getDisplayNamesForGrid(int grid = 0)
  function returns a selection of display number to show different grids
  on a 24 grid based display
  
  @author MN
  @param  grid           : grid  count -> 1,4,6,12,24 

*/
//----------------------------------------------------------------
dyn_int VIDEO_OA_paraList_getDisplayNamesForGrid(string grid = 0)
{
  
  dyn_int gridIdSetting;
  switch(grid)
  {
    case "1x1" : 
             gridIdSetting = makeDynInt( 1); 
             break;
    case "2x2" : 
             gridIdSetting = makeDynInt( 1, 2, 7, 8); 
             break;
    case "2x3" : 
             gridIdSetting = makeDynInt( 1, 2, 3, 7, 8, 9); 
             break;
    case "3x4": 
             gridIdSetting = makeDynInt( 1, 2, 3, 4, 7, 8, 9, 10, 13, 14, 15, 16); 
             break;
    case "4x6": 
             gridIdSetting = makeDynInt( 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24); 
             break;                           
    case "1+2" : 
             gridIdSetting = makeDynInt( 1, 3, 9); 
             break;
    case "2+1" : 
             gridIdSetting = makeDynInt( 1, 3, 7); 
             break;
    case "3+2" : 
             gridIdSetting = makeDynInt( 1, 2, 3, 7, 9);   
             break; 
    case "2+3" : 
             gridIdSetting = makeDynInt(1, 3, 7, 8, 9); 
             break; 
    case "2T" : 
             gridIdSetting = makeDynInt(1, 3, 5, 9, 13, 14, 16, 17);  
             break; 
    case "user_6" : 
             gridIdSetting = makeDynInt();  
             break;              
     case "user_7" : 
             gridIdSetting = makeDynInt();   
             break; 
     case "user_8" : 
             gridIdSetting = makeDynInt();   
             break;                   
     case "user_9" : 
             gridIdSetting = makeDynInt(); 
             break; 
     case "user_10" : 
             gridIdSetting = makeDynInt(); 
             break; 
     case "user_11" : 
             gridIdSetting = makeDynInt(); 
             break; 
     case "user_12" : 
             gridIdSetting = makeDynInt(); 
             break; 
     case "user_13" : 
             gridIdSetting = makeDynInt(); 
             break; 
     case "user_14" : 
             gridIdSetting = makeDynInt(); 
             break; 
     case "user_15" : 
             gridIdSetting = makeDynInt();  
             break; 
     case "user_16" : 
             gridIdSetting = makeDynInt();   
             break; 
             
     default: gridIdSetting = makeDynInt(); 
  }

  return gridIdSetting;
}
//----------------------------------------------------------------







