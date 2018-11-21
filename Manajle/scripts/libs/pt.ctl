//=====================================================================================================================
// Panel Topology - Library                                                                                (c)2001 ETM
//=====================================================================================================================

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Header
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// <summary>
///   Library for modification of panel topology
/// </summary>
/// <remark>
///  The library is spitted into two parts.
///  I) Functions for direct PT modification
///   The functions always starts with the prefix 'ptop'
///   Following public functions are spezified in this part:
///   +functions for load/save topology
///     <c>ptopLoadTopology</c>       Loads the topology from DB to var
///     <c>ptopSaveTopology</c>       Saves the topology from var to DB
///   +functions for common use
///     <c>ptopDebugTopology</c>      Debugs the topology to log
///     <c>ptopDebugPanel</c>         Debugs one panel to log
///     <c>ptopPanelToString</c>      converts one panel to a string
///   +functions for get/set/modify items
///     <c>ptopCreatePanelVar</c>     creats a panel variable
///     <c>ptopGetPanel</c>           Gets defined panel with specific id
///     <c>ptopGetPanels</c>          Gets defined panels with specific ids
///     <c>ptopGetAllPanels</c>       Gets all defined panels
///     <c>ptopSetPanel</c>           Sets defined panel
///     <c>ptopSetPanels</c>          Sets defined panels
///     <c>ptopAppendChildPanel</c>   Appends defined panel as child after a specific id
///     <c>ptopAppendChildPanels</c>  Appends defined panela as child after a specific id
///     <c>ptopAppendPanel</c>        Appends defined panel after a specific id
///     <c>ptopAppendPanels</c>       Appends defined panels after a specific id
///     <c>ptopRemovePanel</c>        Removes a panel with a specific id
///     <c>ptopRemovePanels</c>             Removes a panels with a specific ids
///     <c>ptopGetNavigationId</c>          Returns the Id of the panel, dependent from the given direction
///     <c>ptopGetNavigationIdFirstChild</c>Returns the Id of the first child of a panel with a specific id
///     <c>ptopGetNavigationIdNext</c>      Returns the Id of the next sibling of a panel with a specific id
///     <c>ptopGetNavigationIdParent</c>    Returns the Id of the parent panel of a panel with a specific id
///     <c>ptopGetNavigationIdPrevious</c>  Returns the Id of the previous sibling of a panel with a specific id
///     <c>ptopGetNavigationIdStartup</c>   Returns the Id of the startup panel (= root-panel)
///
///   A panel is declarated as vartype <mapping> and hast always the following keys/properties:
///   +From the mapping tree framework:
///    "Id":             <string> with global ID which defines this item and never change
///    "NodeName":       <langString> with the name of the node in the tree
///    "Parent":         <string> ID of the parent item
///    "Childs":         <dyn_string> with the ID's of child items
///   +Special properies for a panel in this library:
///    "SumAlertNumber": <unsigned> index of panelfiles with same name
///    "File":           <string> with the filename of the panel
///    "Type":           <unsigned> which defines the type of the panel (CHILD, BROTHERBEFORE or BROTHERAFTER)
///    "ModuleName":     <string> with the module name
///    "Icon":           <string> with the filename of the icon
///    "MenuBar":        <bool> display menubar
///    "IconBar":        <bool> display iconbar
///    "Modal":          <bool> is the panel modal or not
///    "Centered":       <bool> display centered
///    "Parameters":     <dyn_string> with the list of defined $-parameters
///    "PermissionBit":  <unsigned> bit needet to display the panel�
///
///  II) Functions for use in the PT-panel
///   The functions always starts with the prefix 'pt_'
///   Following public functions are spezified in this part:
///     <c>pt_setAddButtons</c>             setting "node-insert"-buttons (in)visible
///     <c>pt_getNodePosition</c>           node[idx]-position in global vars (in dp)
///     <c>pt_checkTopologie</c>            checking the consistence of the topology
///     <c>pt_readTopologyDp</c>            reading topology from dp
///     <c>pt_readTopologyTree</c>          reading topology from tree
///     <c>pt_writeTopologyDp</c>           writing topology into dp
///     <c>pt_writeTopologyTree</c>         writing topology into tree
///     <c>pt_isTreeChanged</c>             checking if topology tree changed
///     <c>pt_insertGlobal</c>              inserting node data into the global variables
///     <c>pt_deleteGlobal</c>              deleting node data from the global variables
///     <c>pt_removeGlobals</c>             removing all global variables defined in the session
///     <c>pt_showError</c>                 showing error in a child panel
///     <c>pt_createNavigation</c>          calculating back/forward/up/down-panels of a panel
///     <c>pt_setNodeParaFields</c>         enabling/disabling parameter-fields in nodePara
///     <c>pt_getDollarParams</c>           reading dollar params from a panel
///     <c>pt_mergeDollars</c>              merging $params into form $1:aaa$2:bbb ...etc.
///     <c>pt_splitDollars</c>              splitting dollar parameters and their values defined in topology
///     <c>pt_showDollars</c>               displaying $params in the table in nodePara
///     <c>pt_getBackwardPanel</c>          getting panelname in backward direction
///     <c>pt_getForwardPanel</c>           getting panelname in forward direction
///     <c>pt_getUpwardPanel</c>            getting panelname in upward direction
///     <c>pt_getDownwardPanel</c>          getting panelname in downward direction
///     <c>pt_panelOn[2|3]</c>              displaying a panel of the topology in a module
///     <c>pt_getRelFromAbsPanelPath</c>    creating a relative path from absolute panel path
///     <c>pt_createDpTypeSumAlertPanel</c> generating panel sum alert datapoint type
///     <c>pt_generateSumAlerts</c>         generating panel sum alert datapoints
///     <c>pt_getLastChild</c>              recursive search for the last child in a path
///     <c>pt_getDownSumAlertDps</c>        getting all child sum alerts of a panel
///     <c>pt_fileNameToDpName</c>          creating sum alert dp name from panel name and number
///     <c>pt_checkSumAlerts</c>            checking all panels with sum alerts
///     <c>pt_checkAllAlerts</c>            checking if all alert are used and if all used dps in sumalerts are alert dps
///     <c>pt_getAllAlertsInTopology</c>    reading all alerts in the whole topology recursively
///     <c>pt_log</c>                       writing message into the log file and/or into the list in check-panel
///     <c>pt_getSumAlertNumber</c>         generates the next free number for panel sum alert dp
///     <c>pt_initPanelOnButton</c>         setting values in PT_sumX objects
///     <c>pt_changePara</c>                online changing of parameters of a PT_sumX object
///     <c>pt_getTopologyNumber</c>         getting position of a panel in the topology
///     <c>pt_updateSumAlertPanel</c>       updating sum alert dp of a panel of the topology if the
///                                         panel was modified in Gedi
///     <c>pt_removeSumAlertPanel</c>       deleting sum alert dp of a panel of the topology if the
///                                         panel was deleted in Gedi
///     <c>pt_sumParaAtRightClick</c>       online calling para panel for PT_sumX objects
///     <c>pt_decodePanelAlerts</c>         decoding function 'pt_fileNameToDpName()' in acknowledge scripts
///                                         of the PT_sumX.pnl objects
///     <c>pt_moduleNumber</c>              converts modulename in modulename (without number) and number
///     <c>pt_buildModuleName</c>           converts modulename and modulenumber and returns modulename_modulenumber
///
///   History of this library:
///   01.07.2001 Peter Varga: Implement functions for use in the PT-panel
///   30.09.2003 Michael Halper: Some modifications
///   16.04.2004 Thomas Stoklasek: Some modifications
///   08.02.2007 Markus Trummer: Some modifications
///   27.03.2008 Christian Lichtenberger: Implement functions for direct PT modification
///   19.06.2008 Christopher St�gerer: Changed (int) iModuleNumber to (string) ModuleNumber because auf new MultiMonitorSupport
/// </remark>
/// <seealso cref="aes.ctl"/>
/// <seealso cref="mtree.ctl"/>

#uses "mtree.ctl"
#uses "aes.ctl"
#uses "ptnavi.ctl"
#uses "svnlib.ctl"

//#####################################################################################################################
//  I) Functions for direct PT modification
//#####################################################################################################################

///   Following global variables are used in this part:
mapping ptopEmptyPanel;
mapping ptopEmptyTopology;
bool ptopPanelIsInited = false;
const int PTOP_NAVIGATION_STARTUP = 0;
const int PTOP_NAVIGATION_PREVIOUS = 1;
const int PTOP_NAVIGATION_NEXT = 2;
const int PTOP_NAVIGATION_PARENT = 3;
const int PTOP_NAVIGATION_FIRSTCHILD = 4;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Public load/save topology
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// <summary>Loads the topology from DB to var</summary>
/// <param name="topology">complete topology</param>
/// <returns>Value <0 if error, otherwise >=0 </returns>
public int ptopLoadTopology(mapping &topology)
{
  int ret;
  ret = _ptopLoadTopology(topology);
  return ret;
}

/// <summary>Saves the topology from var to DB</summary>
/// <param name="topology">complete topology</param>
/// <returns>Value <0 if error, otherwise >=0 </returns>
public int ptopSaveTopology(mapping &topology)
{
  int ret;
  ret = _ptopSaveTopology(topology);
  return ret;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Public common
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// <summary>Debugs the topology to log</summary>
/// <param name="topology">complete topology</param>
/// <param name="startId">optional, start debug from this id</param>
/// <returns>Value <0 if error, otherwise >=0 </returns>
public int ptopDebugTopology(mapping &topology, string startId="-1")
{
  int ret;

  if (startId == "-1")
  {
    if (mappingHasKey(topology, mtreeRootId))
      startId = mtreeRootId;
    else
    {
      dyn_string keys = mappingKeys(topology);
      if (dynlen(keys) >= 1)
        startId = keys[1];
    }
  }

  ret = _ptopDebugTopologyPanel(topology, startId);
  return ret;
}

/// <summary>Debugs one panel to log</summary>
/// <param name="panel">panel to debug</param>
/// <returns>Value <0 if error, otherwise >=0 </returns>
public int ptopDebugPanel(mapping panel)
{
  return DebugN(_ptopPanelToString(panel, -1));
}

/// <summary>converts one panel to a string</summary>
/// <param name="panel">panel to convert</param>
/// <returns>string of a panel</returns>
public string ptopPanelToString(mapping panel)
{
  return _ptopPanelToString(panel, -1);
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Public create panel var
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// <summary>creats a panel variable</summary>
/// <param name="name">name of the panel</param>
/// <param name="fileName">filename of the panel</param>
/// <returns>mapping with parameters of the panel</returns>
public mapping ptopCreatePanelVar(langString name, string fileName)
{
  int ret;
  mapping panel;

  panel = _ptopGetEmptyPanel();

  panel["NodeName"] = name;
  panel["File"] = fileName;

  return panel;
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Public get panel
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// <summary>Gets defined panel with specific id</summary>
/// <param name="topology">complete topology</param>
/// <param name="id">ID of the panel</param>
/// <param name="panel">complete panel</param>
/// <returns>Value <0 if error, otherwise >=0 </returns>
public int ptopGetPanel(mapping &topology, string id, mapping &panel)
{
  return mtreeGetItem(topology, id, panel);
}

/// <summary>Gets defined panels with specific ids</summary>
/// <param name="topology">complete topology</param>
/// <param name="ids">ID's of the panels</param>
/// <param name="panels">complete panels</param>
/// <returns>Value <0 if error, otherwise >=0 </returns>
public int ptopGetPanels(mapping &topology, dyn_string ids, dyn_mapping &panels)
{
  return mtreeGetItems(topology, ids, panels);
}

/// <summary>Gets all defined panels</summary>
/// <param name="topology">complete topology</param>
/// <param name="panels">complete panels</param>
/// <returns>Value <0 if error, otherwise >=0 </returns>
public int ptopGetAllPanels(mapping topology, dyn_mapping &panels)
{
  return mtreeGetAllItems(topology, panels);
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Public set panel
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// <summary>Sets defined panel</summary>
/// <param name="topology">complete topology</param>
/// <param name="panel">complete panel</param>
/// <returns>Value <0 if error, otherwise >=0 </returns>
public int ptopSetPanel(mapping &topology, mapping panel)
{
  return mtreeSetItem(topology, panel);
}

/// <summary>Sets defined panels</summary>
/// <param name="topology">complete topology</param>
/// <param name="panels">complete panels</param>
/// <returns>Value <0 if error, otherwise >=0 </returns>
public int ptopSetPanels(mapping topology, dyn_mapping panels)
{
  return mtreeSetItems(topology, panels);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Public append panel
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// <summary>Appends defined panel as child after a specific id</summary>
/// <param name="topology">complete topology</param>
/// <param name="parentId">ID of the parent panel</param>
/// <param name="panel">complete panel</param>
/// <param name="first">append as last or insert as first</param>
/// <returns>Value <0 if error, otherwise >=0 </returns>
public int ptopAppendChildPanel(mapping &topology, string parentId, mapping &panel, bool first=false)
{
  int ret;
  dyn_mapping panels = makeDynAnytype(panel);
  ret = _ptopGenerateId(topology, panels);
  if (ret < 0)
    return ret;
  panel = panels[1];
  return mtreeAppendChildItem(topology, parentId, panel, first);
}

/// <summary>Appends defined panels as child after a specific id</summary>
/// <param name="topology">complete topology</param>
/// <param name="parentId">ID of the parent panel</param>
/// <param name="panel">complete panel</param>
/// <param name="first">append as last or insert as first</param>
/// <returns>Value <0 if error, otherwise >=0 </returns>
public int ptopAppendChildPanels(mapping &topology, string parentId, dyn_mapping &panels, bool first=false)
{
  int ret;
  ret = _ptopGenerateId(topology, panels);
  if (ret < 0)
    return ret;
  return mtreeAppendChildItems(topology, parentId, panels, first);
}

/// <summary>Appends defined panel after a specific id</summary>
/// <param name="topology">complete topology</param>
/// <param name="panel">complete panel</param>
/// <param name="afterId">id of the brother panel</param>
/// <returns>Value <0 if error, otherwise >=0 </returns>
public int ptopAppendPanel(mapping &topology, mapping &panel, string afterId)
{
  int ret;
  dyn_mapping panels = makeDynAnytype(panel);
  ret = _ptopGenerateId(topology, panels);
  if (ret < 0)
    return ret;
  panel = panels[1];
  return mtreeAppendItem(topology, panel, afterId);
}

/// <summary>Appends defined panels after a specific id</summary>
/// <param name="topology">complete topology</param>
/// <param name="panel">complete panel</param>
/// <param name="afterId">id of the brother panel</param>
/// <returns>Value <0 if error, otherwise >=0 </returns>
public int ptopAppendPanels(mapping &topology, dyn_mapping &panels, string afterId)
{
  int ret;
  ret = _ptopGenerateId(topology, panels);
  if (ret < 0)
    return ret;
  return mtreeAppendItems(topology, panels, afterId);
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Public remove panel
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// <summary>Removes a panel with a specific id</summary>
/// <param name="topology">complete topology</param>
/// <param name="id">ID of the panel</param>
/// <returns>Value <0 if error, otherwise >=0 </returns>
public int ptopRemovePanel(mapping &topology, string id)
{
  return mtreeRemoveItem(topology, id);
}

/// <summary>Removes panels with specific ids</summary>
/// <param name="topology">complete topology</param>
/// <param name="ids">ID's of the panels</param>
/// <returns>Value <0 if error, otherwise >=0 </returns>
public int ptopRemovePanels(mapping &topology, dyn_string ids)
{
  return mtreeRemoveItems(topology, ids);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Public navigate in paneltopology
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/// <summary>returns the Id of the previous sibling of a panel with a specific id</summary>
/// <param name="topology">complete topology</param>
/// <param name="currentId">ID of the panel from which navigation starts</param>
/// <param name="id">ID of the previous sibling</param>
/// <returns>Value <0 if error, otherwise >=0 </returns>
public int ptopGetNavigationIdPrevious(mapping &topology, string currentId, string &id)
{
  return _ptopGetNavigation(topology, PTOP_NAVIGATION_PREVIOUS, currentId, id);
}

/// <summary>returns the Id of the next sibling of a panel with a specific id</summary>
/// <param name="topology">complete topology</param>
/// <param name="currentId">ID of the panel from which navigation starts</param>
/// <param name="id">ID of the next sibling</param>
/// <returns>Value <0 if error, otherwise >=0 </returns>
public int ptopGetNavigationIdNext(mapping &topology, string currentId, string &id)
{
  return _ptopGetNavigation(topology, PTOP_NAVIGATION_NEXT, currentId, id);
}

/// <summary>returns the Id of the parent of a panel with a specific id</summary>
/// <param name="topology">complete topology</param>
/// <param name="currentId">ID of the panel from which navigation starts</param>
/// <param name="id">ID of the parent panel</param>
/// <returns>Value <0 if error, otherwise >=0 </returns>
public int ptopGetNavigationIdParent(mapping &topology, string currentId, string &id)
{
  return _ptopGetNavigation(topology, PTOP_NAVIGATION_PARENT, currentId, id);
}

/// <summary>returns the Id of the first child of a panel with a specific id</summary>
/// <param name="topology">complete topology</param>
/// <param name="currentId">ID of the panel from which navigation starts</param>
/// <param name="id">ID of the first child</param>
/// <returns>Value <0 if error, otherwise >=0 </returns>
public int ptopGetNavigationIdFirstChild(mapping &topology, string currentId, string &id)
{
  return _ptopGetNavigation(topology, PTOP_NAVIGATION_FIRSTCHILD, currentId, id);
}

/// <summary>returns the Id of the startup panel (= root-panel)</summary>
/// <param name="topology">complete topology</param>
/// <param name="id">ID of the root panel</param>
/// <returns>Value <0 if error, otherwise >=0 </returns>
public int ptopGetNavigationIdStartup(mapping &topology, string &id)
{
  return _ptopGetNavigation(topology, PTOP_NAVIGATION_STARTUP, "", id);
}

//
/// <summary>returns the Id of the panel, dependent from the requested direction and the current panel</summary>
/// <param name="topology">complete topology</param>
/// <param name="currentId">ID of the panel from which navigation starts</param>
/// <param name="iDirection">int with the requested direction</param>
/// <param name="id">ID of the root panel</param>
/// <returns>Value <0 if error, otherwise >=0 </returns>
public int ptopGetNavigationId(mapping &topology, string currentId, int iDirection, string &id)
{
  return _ptopGetNavigation(topology, iDirection, "", id);
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Private functions to get/set topology from/to DB
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// <summary>Linke a constructor vor this library and the topology var</summary>
/// <param name="topology">complete topology</param>
/// <remark>
///   Done actions:
///    -init the library
///    -init the mapping topology variable
///   The actions are always only done once
/// </remark>
/// <returns>
///   Value <0 if error, otherwise >=0
///   The value is the count of done actions
/// </returns>
private int _ptopInit(mapping &topology)
{
  int doCount;
  mapping tree;

  mtreeInit(tree);

  if (!ptopPanelIsInited)
  {
    //Define empty item
    ptopEmptyPanel = _ptopGetEmptyPanel();
    ptopPanelIsInited = true;
    doCount++;
  }

  if (!mappingHasKey(topology, mtreeRootId))
  {
    topology = _ptopGetEmptyTopology();
    doCount++;
  }

  return doCount;
}

/// <summary>Returnes a empty panel</summary>
private mapping _ptopGetEmptyPanel()
{
  mapping emptyPanel;
  langString desc, loc, func;
  string link;

  if (mappingHasKey(ptopEmptyPanel, "Id"))
    return ptopEmptyPanel;

  //Define empty panel with empty item
  emptyPanel = mtreeCreateEmptyItemVar();

  //Append empty panel custom properties
  emptyPanel["SumAlertNumber"] = (unsigned) 0;
  emptyPanel["File"] = "";
  emptyPanel["Type"] = (unsigned) 0;
  emptyPanel["ModuleName"] = "";
  emptyPanel["Icon"] = "";
  emptyPanel["MenuBar"] = false;
  emptyPanel["IconBar"] = false;
  emptyPanel["Modal"] = false;
  emptyPanel["Centered"] = false;
  emptyPanel["Parameters"] = makeDynString();
  emptyPanel["PermissionBit"] = (unsigned) 1;
  emptyPanel["Description"] = desc;
  emptyPanel["Locality"] = loc;
  emptyPanel["Functionality"] = func;
  emptyPanel["PanelLink"] = link;

  return emptyPanel;
}

/// <summary>Returnes a empty topology</summary>
private mapping _ptopGetEmptyTopology()
{
  mapping topology;

  if (mappingHasKey(ptopEmptyTopology, mtreeRootId))
    return ptopEmptyTopology;

  mapping rootItem;
  rootItem = _ptopGetEmptyPanel();
  rootItem["Id"] = mtreeRootId;
  topology[mtreeRootId] = rootItem;

  ptopEmptyTopology = topology;

  return topology;
}

/// <summary>Loads the paneltopology from the DB</summary>
private int _ptopLoadTopology(mapping &topology)
{
  int ret;
  dyn_uint indices, parents, alerts, types, menuBar, iconBar, permissions;
  dyn_langString names, descs, locs, funcs;
  dyn_string panels, modules, icons, parameters, links;
  dyn_bool modals, centered;
  string rootId = mtreeRootId;

  mappingClear(topology);

  //init library
  ret = _ptopInit(topology);

  //read topology from DB
  pt_readTopologyDp(indices, parents, alerts, names, panels, types, modules, icons, menuBar, iconBar,
                       modals, centered, parameters, permissions, descs, locs, funcs, links, ret);
  if (ret < 0)
    return -1;

  if (dynlen(panels)>=1 && panels[1] == "")
    panels[1] = "main.pnl";

  //append root panel
  mapping panel = _ptopGetEmptyPanel();
  panel["Id"] = rootId;
  topology[rootId] = panel;

  //convert values to topology mapping
  for (int i=1; i<=dynlen(indices); i++)
  {
    mapping panel = _ptopGetEmptyPanel();
    panel["Id"] = panels[i] + "_" + alerts[i];
    if (dynlen(alerts) >= i)
      panel["SumAlertNumber"] = alerts[i];
    else
      alerts[i] = panel["SumAlertNumber"];

    panel["NodeName"] = names[i];
    if (dynlen(panels) >= i)
      panel["File"] = panels[i];
    if (dynlen(types) >= i)
      panel["Type"] = types[i];
    if (dynlen(modules) >= i)
      panel["ModuleName"] = modules[i];
    if (dynlen(icons) >= i)
      panel["Icon"] = icons[i];
    if (dynlen(menuBar) >= i)
      panel["MenuBar"] = menuBar[i];
    if (dynlen(iconBar) >= i)
      panel["IconBar"] = iconBar[i];
    if (dynlen(modals) >= i)
      panel["Modal"] = modals[i];
    if (dynlen(centered) >= i)
      panel["Centered"] = centered[i];
    if (dynlen(parameters) >= i)
    {
      //get $-Parameters from string
      dyn_string dollars = strsplit(parameters[i], "$");
      dynRemove(dollars, 1);
      for (int i=1; i<=dynlen(dollars);i++)
        dollars[i] = "$"+dollars[i];
      panel["Parameters"] = dollars;
    }
    if (dynlen(permissions) >= i)
      panel["PermissionBit"] = permissions[i];
    if (dynlen(descs) >= i)
      panel["Description"] = descs[i];
    if (dynlen(locs) >= i)
      panel["Locality"] = locs[i];
    if (dynlen(funcs) >= i)
      panel["Functionality"] = funcs[i];
    if (dynlen(links) >= i)
      panel["PanelLink"] = links[i];

    if (parents[i] != 0)
    {
      int parentPos = dynContains(indices, parents[i]);
      panel["Parent"] = panels[parentPos] + "_" + alerts[parentPos];
    }
    else
    {
      panel["Parent"] = rootId;
      dynAppend(topology[rootId]["Childs"], panel["Id"]);
    }

    dyn_string ds;
    for (int x=1; x<=dynlen(parents); x++)
    {
      if (parents[x] == indices[i])
        dynAppend(ds, panels[x] + "_" + alerts[x]);
    }
    panel["Childs"] = ds;

    topology[panel["Id"]] = panel;
  }

  return ret;
}

/// <summary>Saves the paneltopology to the DB</summary>
private int _ptopSaveTopology(mapping topology)
{
  int ret;
  dyn_langString emptyDynLang;
  dyn_string emptyDynString;
  dyn_errClass derr;
  string rootId = mtreeRootId;
  mapping saveValues;
  dyn_string dpes;
  dyn_anytype values;

  //init library
  ret = _ptopInit(topology);

  //init saveValues
  saveValues["_PanelTopology.panelNumber"] = makeDynUInt();
  saveValues["_PanelTopology.parentNumber"] = makeDynUInt();
  saveValues["_PanelTopology.sumAlertNumber"] = makeDynUInt();
  saveValues["_PanelTopology.nodeName"] = emptyDynLang;
  saveValues["_PanelTopology.fileName"] = makeDynString();
  saveValues["_PanelTopology.panelType"] = makeDynUInt();
  saveValues["_PanelTopology.moduleName"] = makeDynString();
  saveValues["_PanelTopology.iconName"] = makeDynString();
  saveValues["_PanelTopology.menuBar"] = makeDynUInt();
  saveValues["_PanelTopology.iconBar"] = makeDynUInt();
  saveValues["_PanelTopology.modal"] = makeDynBool();
  saveValues["_PanelTopology.centered"] = makeDynBool();
  saveValues["_PanelTopology.parameter"] = makeDynString();
  saveValues["_PanelTopology.permissionBit"] = makeDynUInt();
  saveValues["_PanelTopology.backwardPanel"] = makeDynUInt();
  saveValues["_PanelTopology.forwardPanel"] = makeDynUInt();
  saveValues["_PanelTopology.upwardPanel"] = makeDynUInt();
  saveValues["_PanelTopology.downwardPanel"] = makeDynUInt();
  saveValues["_PanelTopology.description"] = makeDynString();
  saveValues["_PanelTopology.locality"] = emptyDynLang;
  saveValues["_PanelTopology.functionality"] = emptyDynLang;
  saveValues["_PanelTopology.panelLink"] = makeDynString();

  //convert topology mapping to values
  dyn_string ds = topology[rootId]["Childs"];
  for (int i=1; i<=dynlen(ds); i++)   //add only childs and not root-panel itself
  {
    ret = _ptopSaveTopology_AddToSaveList(topology, ds[i], 0, saveValues);
    if (ret < 0)
      return ret;
  }

  for (int i=1; i<=dynlen(ds); i++)   //add only childs and not root-panel itself
  {
    ret = _ptopSaveTopology_UpdateNavigations(topology, ds[i], saveValues);
    if (ret < 0)
      return ret;
  }

  //convert mapping --> dyn vars
  dpes = mappingKeys(saveValues);
  for (int i=1; i<=dynlen(dpes); i++)
    values[i] = saveValues[dpes[i]];

  //set PT to Dp
  ret = dpSet(dpes, values);
  derr = getLastError();
  if (ret < 0)
    return ret;
  if (dynlen(derr) >= 1)
    return -1;

  //generate sumalerts
  //pt_generateSumAlerts(1, true, false);
  return ret;
}

/// <summary>adds recursive panels to the list to save</summary>
private int _ptopSaveTopology_AddToSaveList(mapping &topology, string id, int parentPvssId, mapping &saveValues)
{
  int index;
  int ret;
  string rootId = mtreeRootId;

  //check must have keys
  if (!mappingHasKey(topology, id))
  {
    throwError(makeError("", PRIO_SEVERE, ERR_PARAM, 76, "unknown panel id '"+id+"'"));
    return -1;
  }

  if (!mappingHasKey(topology[id], "Id") ||
      !mappingHasKey(topology[id], "SumAlertNumber") ||
      !mappingHasKey(topology[id], "Childs"))
  {
    throwError(makeError("", PRIO_SEVERE, ERR_PARAM, 76, "missing key 'Id,SumAlertNumber or Childs'", mappingKeys(topology[id])));
    return -1;
  }

  //append musts
  dynAppend(saveValues["_PanelTopology.panelNumber"], (int)-1);
  index = dynlen(saveValues["_PanelTopology.panelNumber"]);
  saveValues["_PanelTopology.panelNumber"][index] = index;
  topology[id]["PvssIndex"] = index; //remember also in topology
  saveValues["_PanelTopology.parentNumber"][index] = parentPvssId;
  topology[id]["PvssParentIndex"] = parentPvssId; //remember also in topology
  saveValues["_PanelTopology.sumAlertNumber"][index] = topology[id]["SumAlertNumber"];
  saveValues["_PanelTopology.backwardPanel"][index] = 0;
  saveValues["_PanelTopology.forwardPanel"][index] = 0;
  saveValues["_PanelTopology.upwardPanel"][index] = 0;
  saveValues["_PanelTopology.downwardPanel"][index] = 0;

  //append dummies for optionals
  saveValues["_PanelTopology.nodeName"][index] = (langString)"";
  saveValues["_PanelTopology.fileName"][index] = (string)"";
  saveValues["_PanelTopology.panelType"][index] = (unsigned)0;
  saveValues["_PanelTopology.moduleName"][index] = (string)"";
  saveValues["_PanelTopology.iconName"][index] = (string)"";
  saveValues["_PanelTopology.menuBar"][index] = (unsigned)0;
  saveValues["_PanelTopology.iconBar"][index] = (unsigned)0;
  saveValues["_PanelTopology.modal"][index] = (bool)true;
  saveValues["_PanelTopology.centered"][index] = (bool)true;
  saveValues["_PanelTopology.parameter"][index] = (string)"";
  saveValues["_PanelTopology.permissionBit"][index] = (unsigned)1;
  saveValues["_PanelTopology.description"][index] = (langString)"";
  saveValues["_PanelTopology.locality"][index] = (langString)"";
  saveValues["_PanelTopology.functionality"][index] = (langString)"";
  saveValues["_PanelTopology.panelLink"][index] = (string)"";


  //set optional keys
  if (mappingHasKey(topology[id], "NodeName"))
    saveValues["_PanelTopology.nodeName"][index] = topology[id]["NodeName"];
  if (mappingHasKey(topology[id], "File"))
    saveValues["_PanelTopology.fileName"][index] = topology[id]["File"];
  if (mappingHasKey(topology[id], "Type"))
    saveValues["_PanelTopology.panelType"][index] = topology[id]["Type"];
  if (mappingHasKey(topology[id], "ModuleName"))
    saveValues["_PanelTopology.moduleName"][index] = topology[id]["ModuleName"];
  if (mappingHasKey(topology[id], "Icon"))
    saveValues["_PanelTopology.iconName"][index] = topology[id]["Icon"];
  if (mappingHasKey(topology[id], "MenuBar"))
    saveValues["_PanelTopology.menuBar"][index] = topology[id]["MenuBar"];
  if (mappingHasKey(topology[id], "IconBar"))
    saveValues["_PanelTopology.iconBar"][index] = topology[id]["IconBar"];
  if (mappingHasKey(topology[id], "Modal"))
    saveValues["_PanelTopology.modal"][index] = topology[id]["Modal"];
  if (mappingHasKey(topology[id], "Centered"))
    saveValues["_PanelTopology.centered"][index] = topology[id]["Centered"];
  if (mappingHasKey(topology[id], "Parameters"))
  {
    dyn_string dollars = topology[id]["Parameters"];
    saveValues["_PanelTopology.parameter"][index] = "";
    for (int i=1; i<=dynlen(dollars);i++)
      saveValues["_PanelTopology.parameter"][index] += dollars[i];
  }
  if (mappingHasKey(topology[id], "PermissionBit"))
    saveValues["_PanelTopology.permissionBit"][index] = topology[id]["PermissionBit"];
  if (mappingHasKey(topology[id], "Description"))
    saveValues["_PanelTopology.description"][index] = topology[id]["Description"];
  if (mappingHasKey(topology[id], "Locality"))
    saveValues["_PanelTopology.locality"][index] = topology[id]["Locality"];
  if (mappingHasKey(topology[id], "Functionality"))
    saveValues["_PanelTopology.functionality"][index] = topology[id]["Functionality"];
  if (mappingHasKey(topology[id], "PanelLink"))
    saveValues["_PanelTopology.panelLink"][index] = topology[id]["PanelLink"];


  //do it for all childs
  dyn_string ds = topology[id]["Childs"];
  for (int i=1; i<=dynlen(ds); i++)
    _ptopSaveTopology_AddToSaveList(topology, ds[i], index, saveValues);
  return 0;
}

/// <summary>updates recursive some properties of the panels</summary>
private int _ptopSaveTopology_UpdateNavigations(mapping &topology, string id, mapping &saveValues)
{
  int index;
  int ret;
  string rootId = mtreeRootId;
  dyn_string ds;

  //check must have keys
  if (!mappingHasKey(topology, id))
  {
    throwError(makeError("", PRIO_SEVERE, ERR_PARAM, 76, "unknown panel id '"+id+"'"));
    return -1;
  }

  if (!mappingHasKey(topology[id], "PvssIndex") ||
      !mappingHasKey(topology[id], "PvssParentIndex"))
  {
    throwError(makeError("", PRIO_SEVERE, ERR_PARAM, 76, "missing key 'PvssIndex or PvssParentIndex'", mappingKeys(topology[id])));
    return -1;
  }

  index = topology[id]["PvssIndex"];

  mapping parentPanel = topology[topology[id]["Parent"]];
  int pos = dynContains(parentPanel["Childs"], id);

  if (dynContains(topology[rootId]["Childs"], id) > 0)  //is first level
    saveValues["_PanelTopology.backwardPanel"][index] = 0;
  else if (pos > 1)  //use my brother before
    saveValues["_PanelTopology.backwardPanel"][index] = topology[parentPanel["Childs"][pos-1]]["PvssIndex"];
  else          //use the last brother
    saveValues["_PanelTopology.backwardPanel"][index] = topology[parentPanel["Childs"][dynlen(parentPanel["Childs"])]]["PvssIndex"];

  if (dynContains(topology[rootId]["Childs"], id) > 0)  //is first level
    saveValues["_PanelTopology.forwardPanel"][index] = 0;
  else if (pos < dynlen(parentPanel["Childs"]))  //use my brother after
    saveValues["_PanelTopology.forwardPanel"][index] = topology[parentPanel["Childs"][pos+1]]["PvssIndex"];
  else          //use the first brother
    saveValues["_PanelTopology.forwardPanel"][index] = topology[parentPanel["Childs"][1]]["PvssIndex"];

  if (dynContains(topology[rootId]["Childs"], id) > 0 ||   //is first level
      (parentPanel["PvssIndex"] > 1 && dynContains(topology[rootId]["Childs"], parentPanel["Id"]) > 0))  //parent is first level and id not 1
    saveValues["_PanelTopology.upwardPanel"][index] = 0;
  else
    saveValues["_PanelTopology.upwardPanel"][index] = topology[id]["PvssParentIndex"];

  ds = topology[id]["Childs"];
  if (dynlen(ds) >= 1)
    saveValues["_PanelTopology.downwardPanel"][index] = topology[ds[1]]["PvssIndex"];
  else
    saveValues["_PanelTopology.downwardPanel"][index] = 0;

  //do it for all childs
  dyn_string ds = topology[id]["Childs"];
  for (int i=1; i<=dynlen(ds); i++)
    _ptopSaveTopology_UpdateNavigations(topology, ds[i], saveValues);
  return 0;
}

/// <summary>write debug infos of a panel to the log</summary>
private int _ptopDebugTopologyPanel(mapping &topology, string id, int level=0)
{
  if (!mappingHasKey(topology, id))
  {
    throwError(makeError("", PRIO_SEVERE, ERR_PARAM, 76, "unknown panel id '"+id+"'"));
    return -1;
  }

  DebugN(_ptopPanelToString(topology[id], level));

  level++;
  dyn_string ds = topology[id]["Childs"];
  for (int i=1; i<=dynlen(ds); i++)
    _ptopDebugTopologyPanel(topology, ds[i], level);
  return 0;
}

/// <summary>converts a panel to string</summary>
private string _ptopPanelToString(mapping panel, int level=-1)
{
  string res;

  if (level>=0)
    res += level + ", ";
  for (int i=1; i<=level; i++)
    res += "  ";
  res += panel["Id"]+", "+(string)panel["NodeName"]+", "+panel["File"];
  return res;
}

/// <summary>creates the id of a panel</summary>
private int _ptopGenerateId(mapping &topology, dyn_mapping &panels)
{
  int ret = _ptopInit(topology);
  if (ret < 0)
    return ret;

  for (int i=1; i<=dynlen(panels); i++)
  {
    if (!mappingHasKey(panels[i], "File"))
    {
      throwError(makeError("", PRIO_SEVERE, ERR_PARAM, 76, "missing key 'File' in panel '"+mappingKeys(panels[i])+"'"));
      return -1;
    }
  }

  dyn_anytype keys = mappingKeys(topology);
  dyn_uint nums;
  dyn_string files;
  for (int k=1; k<=dynlen(keys); k++)
  {
    files[k] = topology[keys[k]]["File"];
    nums[k] = topology[keys[k]]["SumAlertNumber"];
  }

  for (int i=1; i<=dynlen(panels); i++)
  {
    //generate id for item
    unsigned num = 0;
    for (int k=1; k<=dynlen(files); k++)
    {
      if (files[k] == panels[i]["File"] && nums[k] > num)
        num = nums[k];
    }
    num++;  //increase the maximum number

    //define in panels
    panels[i]["Id"] = panels[i]["File"] + "_" + num;
    panels[i]["SumAlertNumber"] = num;

    //append to key list
    dynAppend(keys, panels[i]["Id"]);
    dynAppend(files, panels[i]["File"]);
    dynAppend(nums, num);
  }

  return 0;
}

/// <summary>returns the Id of a requested panel, dependent from the current panel and the direction</summary>
private int _ptopGetNavigation(mapping &topology, int iDirection, string currentId, string &id)
{
  int retval = 0;
  switch(iDirection)
  {
    case PTOP_NAVIGATION_STARTUP:
      // startup
      {
        if (dynlen(topology[mtreeRootId]["Childs"]) >= 1)
          id = topology[mtreeRootId]["Childs"][1];
        else
          retval = -1;
        break;
      }
    case PTOP_NAVIGATION_PREVIOUS:
      //previous
      {
        string parent = topology[currentId]["Parent"];
        dyn_string siblings = topology[parent]["Childs"];
        int myPos = dynContains(siblings, currentId);

        if(dynlen(siblings) == 1 || parent == "")
        {
          retval = -1;
          id = "";
          break;
        }

        if(myPos == 1)
        {
          id = siblings[dynlen(siblings)];
        }
        else
        {
          id = siblings[myPos-1];
        }
        break;
      }
    case PTOP_NAVIGATION_NEXT:
      // next
      {
        string parent = topology[currentId]["Parent"];
        dyn_string siblings = topology[parent]["Childs"];
        int myPos = dynContains(siblings, currentId);
        if(dynlen(siblings) == 1 || parent == "")
        {
          retval = -1;
          id = "";
          break;
        }

        if(myPos == dynlen(siblings))
        {
          id = siblings[1];
        }
        else
        {
          id = siblings[myPos+1];
        }

        break;
      }
    case PTOP_NAVIGATION_PARENT:
      // Parent
      {
        id = topology[currentId]["Parent"];
        if(id == "")
          retval = -1;
        break;
      }
    case PTOP_NAVIGATION_FIRSTCHILD:
      // First Child
      {
        dyn_string childs = topology[currentId]["Childs"];
        if(dynlen(childs) >= 1)
        {
          id = childs[1];
        }
        else
        {
          id = "";
          retval = -1;
        }
        break;
      }
    default:
      retval = -1;
      break;
  }

  return retval;
}


//#####################################################################################################################
//  II) Functions for use in the PT-panel
//#####################################################################################################################

///   Following global variables are used in this part:
global dyn_int        gPtTreeIndices;
global dyn_uint       gPtIndices;
global dyn_uint       gPtAlerts;
global dyn_langString gPtNames;
global dyn_string     gPtPanels;
global dyn_uint       gPtTypes;
global dyn_string     gPtModules;
global dyn_string     gPtIcons;
global dyn_uint       gPtMenuBar;
global dyn_uint       gPtIconBar;
global dyn_bool       gPtModal;
global dyn_bool       gPtCentered;
global dyn_string     gPtParameters;
global dyn_uint       gPtPermissions;
global dyn_uint       gPtParents;
global dyn_langString gPtDescription;
global dyn_langString gPtLocality;
global dyn_langString gPtFunctionality;
global dyn_string     gPtPanelLink;

global dyn_uint       gPtIndicesOld;
global dyn_uint       gPtAlertsOld;
global dyn_langString gPtNamesOld;
global dyn_string     gPtPanelsOld;
global dyn_uint       gPtTypesOld;
global dyn_string     gPtModulesOld;
global dyn_string     gPtIconsOld;
global dyn_uint       gPtMenuBarOld;
global dyn_uint       gPtIconBarOld;
global dyn_bool       gPtModalOld;
global dyn_bool       gPtCenteredOld;
global dyn_string     gPtParametersOld;
global dyn_uint       gPtPermissionsOld;
global dyn_string     iconImage;
global dyn_langString gPtDescriptionOld;
global dyn_langString gPtLocalityOld;
global dyn_langString gPtFunctionalityOld;
global dyn_string     gPtPanelLinkOld;

global string         gPtFreePanel=". . .";
global dyn_string     gPtPrioRanges;
global unsigned       gPtRefNr;

const int CHILD         = 1;
const int BROTHERBEFORE = 2;
const int BROTHERAFTER  = 3;

global dyn_uint       gPtParentsReverse;


////////////////////////////////////////////////////////////////////////////
pt_getFreeNodePos(int &posFree)
{
  posFree = pt_getFreeNodePosition(gPtIndices, gPtParents);
}

public int pt_getFreeNodePosition(dyn_int indices, dyn_int parents)
{
  int posFree = 0;

  for (int i = 1; i <= dynlen(indices); i++)
  {
    if ( indices[i] > 1 && parents[i] == 0 )
    {
      posFree = i;
      break;
    }
  }
  return posFree;
}

////////////////////////////////////////////////////////////////////////////
pt_setAddButtons(unsigned id)
{
  int posIdx=dynContains(gPtIndices,id), level=pt_getNodeLevel(id);
  int posFree;
  bool bChildren = pt_hasChilden(id);

  posFree = pt_getFreeNodePosition(gPtIndices, gPtParents);
  if (posIdx<=0) return;

  cmdAddChild.enabled=(gPtTypes[posIdx]==0);
  cmdAddBrotherBefore.enabled=(level>0);
  cmdAddBrotherAfter.enabled =(level>0);

  cmdModify.enabled =(posIdx != posFree);
  cmdDelete.enabled = (!bChildren && level!=0);  //don't allow to delete a rootnode and nodes with children
  cmdGenSumDown.enabled=(posIdx < posFree);
  cmdGenSumPanel.enabled=(posIdx < posFree);
}

////////////////////////////////////////////////////////////////////////////
pt_getNodePosition(int idx, int &pos)
{
  pos=dynContains(gPtTreeIndices,idx);
}

////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////
// fName=="" ==> Checking treeView-Object (global variables)
////////////////////////////////////////////////////////////////////////////
// check, if configurated Panels exist -> if there is a problem, select that node
pt_checkTopologie(string shapeName, string &str, int &error)
{
  shape treeTopology = getShape(shapeName);
  int        i,j,idx,posFree;
  bool       bFree;
  string     nName;
  dyn_int    indices,parents,back,forw,up,down;
  dyn_string names,panels,ds1,ds2,ds;
  langString ls;

  posFree = pt_getFreeNodePosition(gPtIndices, gPtParents);
  error=0;

  for (i=1;i<=dynlen(gPtPanels);i++)  //for all Panels
  {
    ls=gPtNames[i]; nName=ls;
    bFree=(i>=posFree);
    if (!bFree && strrtrim(strltrim(gPtPanels[i]))=="")
    {
      error=-4; str=""; // panel name empty
      treeTopology.setSelectedItems(gPtTreeIndices[i], true);
      break;
    }
    if (!bFree && getPath(PANELS_REL_PATH,gPtPanels[i])=="")
    {
      error=-2; str=gPtPanels[i]; // panel does not exist
      treeTopology.setSelectedItems(gPtTreeIndices[i], true);
      break;
    }
    ds1=strsplit(gPtParameters[i],"$");
    if (dynlen(ds1)>0) dynRemove(ds1,1);
    for (j=1;j<=dynlen(ds1);j++)
    {
      ds2=strsplit(ds1[j],":");
      if (dynlen(ds2)<2)
      {
        error=-14; str="";
        treeTopology.setSelectedItems(gPtTreeIndices[i], true);
        break;
      }
    }
    if (error<0) break; // value for $parameter not defined
  }
}

////////////////////////////////////////////////////////////////////////////
pt_readTopologyDp(dyn_uint       &indices,
                  dyn_uint       &parents,
                  dyn_uint       &alerts,
                  dyn_langString &names,
                  dyn_string     &panels,
                  dyn_uint       &types,
                  dyn_string     &modules,
                  dyn_string     &icons,
                  dyn_uint       &menuBar,
                  dyn_uint       &iconBar,
                  dyn_bool       &modals,
                  dyn_bool       &centered,
                  dyn_string     &parameters,
                  dyn_uint       &permissions,
                  dyn_langString &description,
                  dyn_langString &locality,
                  dyn_langString &functionality,
                  dyn_string     &panellink,
                  int            &error,
                  string         systemPrefix = "")
{
  int        i,j,k;
  string     param;
  dyn_string paramsPanel, paramsDp, valuesDp, ds1, ds2;

  if(systemPrefix == "")
  {
     systemPrefix = getSystemName();
  }


  error = pt_checkPanelTopologyCache();

  // error==-1 dpGet-error
  if (error<0)
  {
    error=-1;
    return;
  }

  indices = g_PanelTopologyCache[ systemPrefix + "_PanelTopology.panelNumber:_online.._value"];
  parents = g_PanelTopologyCache[ systemPrefix + "_PanelTopology.parentNumber:_online.._value"];
  alerts  = g_PanelTopologyCache[ systemPrefix + "_PanelTopology.sumAlertNumber:_online.._value"];
  names   = g_PanelTopologyCache[ systemPrefix + "_PanelTopology.nodeName:_online.._value"];
  panels  = g_PanelTopologyCache[ systemPrefix + "_PanelTopology.fileName:_online.._value"];
  types   = g_PanelTopologyCache[ systemPrefix + "_PanelTopology.panelType:_online.._value"];
  modules = g_PanelTopologyCache[ systemPrefix + "_PanelTopology.moduleName:_online.._value"];
  icons   = g_PanelTopologyCache[ systemPrefix + "_PanelTopology.iconName:_online.._value"];
  menuBar    = g_PanelTopologyCache[ systemPrefix + "_PanelTopology.menuBar:_online.._value"];
  iconBar    = g_PanelTopologyCache[ systemPrefix + "_PanelTopology.iconBar:_online.._value"];
  modals  = g_PanelTopologyCache[ systemPrefix + "_PanelTopology.modal:_online.._value"];
  centered= g_PanelTopologyCache[ systemPrefix + "_PanelTopology.centered:_online.._value"];
  parameters = g_PanelTopologyCache[ systemPrefix + "_PanelTopology.parameter:_online.._value"];
  permissions = g_PanelTopologyCache[ systemPrefix + "_PanelTopology.permissionBit:_online.._value"];
  description  = g_PanelTopologyCache[ systemPrefix + "_PanelTopology.description:_online.._value"];
  locality  = g_PanelTopologyCache[ systemPrefix + "_PanelTopology.locality:_online.._value"];
  functionality  = g_PanelTopologyCache[ systemPrefix + "_PanelTopology.functionality:_online.._value"];
  panellink  = g_PanelTopologyCache[ systemPrefix + "_PanelTopology.panelLink:_online.._value"];


  for ( i = 1; i <= dynlen(indices); i++ )
  {
    if ( i == 1 )
    {
      ds1 = names[i]; for (j=1;j<=dynlen(ds1);j++) ds1[j]="StartPanel";
      names[i] = ds1;
    }
    else
    if ( i > 1 && parents[i] == 0 )
    {
      ds1 = names[i]; for (j=1;j<=dynlen(ds1);j++) ds1[j]=gPtFreePanel;
      names[i] = ds1;
    }
  }
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
int pt_readTopologyTree(dyn_string &names,
                        dyn_string &panels)
{
  DebugN("pt_readTopologyTree - function at the moment not used"); return(0);
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
pt_writeTopologyDp(dyn_int        indices,
                   dyn_langString names,
                   dyn_string     panels,
                   dyn_uint       types,
                   dyn_uint       alerts,
                   dyn_string     modules,
                   dyn_string     icons,
                   dyn_uint       menuBar,
                   dyn_uint       iconBar,
                   dyn_bool       modals,
                   dyn_bool       centered,
                   dyn_string     parameters,
                   dyn_uint       permissions,
                   int            &error,
                   bool           autogenerateSumalerts = false,  //generate Sumalerts without UserInteraction
                   dyn_langString description="",
                   dyn_langString locality="",
                   dyn_langString functionality="",
                   dyn_string     panellink="",
                   bool           suppressSumAlertAutogeneration = false) // IM104828: This shall only be true when called from pt_generateSumAlerts()/pt_sortNodes()!
{
  int          i;
  dyn_int      back,forw,up,down;
  dyn_float    df;
  dyn_string   ds;
  dyn_errClass errC;

  // setting panel indices
  pt_createNavigation(indices,gPtParents,back,forw,up,down);
  error = dpSet("_PanelTopology.panelNumber:_original.._value", indices,
                "_PanelTopology.parentNumber:_original.._value", gPtParents,
                "_PanelTopology.sumAlertNumber:_original.._value", alerts,
                "_PanelTopology.nodeName:_original.._value", names,
                "_PanelTopology.fileName:_original.._value", panels,
                "_PanelTopology.panelType:_original.._value", types,
                "_PanelTopology.moduleName:_original.._value", modules,
                "_PanelTopology.iconName:_original.._value", icons,
                "_PanelTopology.menuBar:_original.._value", menuBar,
                "_PanelTopology.iconBar:_original.._value", iconBar,
                "_PanelTopology.modal:_original.._value", modals,
                "_PanelTopology.centered:_original.._value", centered,
                "_PanelTopology.parameter:_original.._value", parameters,
                "_PanelTopology.permissionBit:_original.._value", permissions,
                "_PanelTopology.backwardPanel:_original.._value", back,
                "_PanelTopology.forwardPanel:_original.._value", forw,
                "_PanelTopology.upwardPanel:_original.._value", up,
                "_PanelTopology.downwardPanel:_original.._value", down,
                "_PanelTopology.description:_original.._value", description,
                "_PanelTopology.locality:_original.._value", locality,
                "_PanelTopology.functionality:_original.._value", functionality,
                "_PanelTopology.panelLink:_original.._value", panellink);
  // dpSet-error
  if (error<0)
  {
    error=-7;
    return;
  }

  // creating sum alert datapoints for panels
  if (!suppressSumAlertAutogeneration)
  {
    if (pt_isTreeChanged() && !autogenerateSumalerts)
    {
      ChildPanelOnCentralModalReturn("vision/MessageInfo",
        getCatStr("pt","topologychanged"),
        makeDynString(getCatStr("pt","wantcreatesumalerts"),
                      getCatStr("para","yes"),
                      getCatStr("para","no")),df,ds);
      if (df[1])
        pt_generateSumAlerts(1,true);
    }
    else if (autogenerateSumalerts)
    {
      pt_generateSumAlerts(1, true, false);
    }
  }
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
pt_writeTopologyTree(string         shapeName,
                     dyn_uint       indices,
                     dyn_uint       parents,
                     dyn_langString names,
                     dyn_string     panels,
                     dyn_uint       types,
                     dyn_int       &treeIndices,
                     int           &error)
{
  shape treeTopology = getShape(shapeName);
  int        i,j,k,len,pos=0, nrOfNodes = dynlen(indices);
  int        idx,row,iImageIndex,posFree;
  string     s;
  dyn_string dsNames=names;
  bool       bShowProgressbar = (nrOfNodes>300);


  treeIndices=makeDynInt();
  error=0;

  if (bShowProgressbar)
    openProgressBar(getCatStr("pt","loadingNodes"),
                    "generate_tree.png",
                    "", "0/"+nrOfNodes, "0 %",
                    2);

  treeTopology.clear();
  posFree = pt_getFreeNodePosition(gPtIndices, gPtParents);

  for (i=1;i<=dynlen(indices);i++)
  {
    iImageIndex = pt_getIconNr(i, posFree);
    if (bShowProgressbar && (i%100 == 0))  //for better performance refresh (=make a dpSet) every 100 loaded node
    {
      if (!isProgressBarOpen())  //if user has closed the progressbar, open it again
        openProgressBar(getCatStr("pt","loadingNodes"),
                       "generate_tree.png",
                       "", "0/"+nrOfNodes, "0 %",
                       2);

      sprintf(s,"%3.0f %",(1.0*i/nrOfNodes*100.0));
      showProgressBar(getCatStr("pt","addNode")+" "+dsNames[i],
                      i+"/"+nrOfNodes, s, 1.0*i/nrOfNodes*100.0);
    }
    if (parents[i]==0)
    {
      //Create a RootNoede

      treeTopology.appendItemNC("", indices[i], dsNames[i]);
      treeTopology.setIcon(indices[i], 0, iconImage[iImageIndex]);

      treeTopology.setDragEnabled( indices[i], true );
      treeTopology.setDropEnabled( indices[i], true );

    }
    else
    {
      if (dynContains(indices,parents[i])<1)
      {
        DebugN("pt_writeTopologyTree - Values in the _PanelTopology datapoint are invalid !!!");
        continue; //!!! Fehlermeldung
      }

      treeTopology.appendItemNC(indices[parents[i]], indices[i], dsNames[i]);
      treeTopology.setIcon(indices[i], 0, iconImage[iImageIndex]);
      treeTopology.setExpandable(indices[parents[i]],true);  //set the parent of the node expandable

      treeTopology.setDragEnabled( indices[i], true );
      treeTopology.setDropEnabled( indices[i], true );

    }
    treeIndices[i]=idx;
  }

  if (bShowProgressbar)
    closeProgressBar();

  if ( dynlen(gPtTypes) > 0 )
    pt_setAddButtons(treeIndices[1]);

  setInputFocus(myModuleName(),myPanelName(),"treeTopology");
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
bool pt_isTreeChanged()
{
  return(gPtIndicesOld     != gPtIndices    ||
         gPtAlertsOld      != gPtAlerts     ||
         gPtNamesOld       != gPtNames      ||
         gPtPanelsOld      != gPtPanels     ||
         gPtTypesOld       != gPtTypes      ||
         gPtModulesOld     != gPtModules    ||
         gPtIconsOld       != gPtIcons      ||
         gPtMenuBarOld     != gPtMenuBar    ||
         gPtIconBarOld     != gPtIconBar    ||
         gPtModalOld       != gPtModal      ||
         gPtCenteredOld    != gPtCentered   ||
         gPtParametersOld  != gPtParameters ||
         gPtPermissionsOld    != gPtPermissions   ||
         gPtDescriptionOld    != gPtDescription   ||
         gPtLocalityOld       != gPtLocality      ||
         gPtFunctionalityOld  != gPtFunctionality ||
         gPtPanelLinkOld      != gPtPanelLink     );
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
pt_insertGlobal(int pos, string nodeName, int idx)
{
  int        i,j,id;
  dyn_string ds;
  langString ls, ls_empty;

  for (i=0;i<getNoOfLangs();i++)
  {
    id=getGlobalLangId(i); // Globale Id
    ds[getLangIdx(id)+1]=getCatStr("pt","newpanel",getLangIdx(id));
  }
  ls=ds;
  dynInsertAt(gPtIndices,pos,pos);
  dynInsertAt(gPtTreeIndices,idx,pos);
  dynInsertAt(gPtNames,ls,pos);
  dynInsertAt(gPtPanels,"",pos);
  dynInsertAt(gPtTypes,0,pos);
  dynInsertAt(gPtAlerts,0,pos);
  dynInsertAt(gPtModules,"",pos);
  dynInsertAt(gPtIcons,"",pos);
  dynInsertAt(gPtMenuBar,0,pos);
  dynInsertAt(gPtIconBar,0,pos);
  dynInsertAt(gPtModal,1,pos);
  dynInsertAt(gPtCentered,1,pos);
  dynInsertAt(gPtParameters,"",pos);
  dynInsertAt(gPtPermissions,1,pos);
  dynInsertAt(gPtDescription, ls_empty, pos);
  dynInsertAt(gPtLocality, ls_empty, pos);
  dynInsertAt(gPtFunctionality, ls_empty, pos);
  dynInsertAt(gPtPanelLink, "", pos);
  // setting panel indices
  for (i=1;i<=dynlen(gPtIndices);i++) gPtIndices[i]=i;
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
pt_deleteGlobal(int pos)
{
  int i,j;

  dynRemove(gPtIndices,pos);
  dynRemove(gPtTreeIndices,pos);
  dynRemove(gPtNames,pos);
  dynRemove(gPtPanels,pos);
  dynRemove(gPtTypes,pos);
  dynRemove(gPtAlerts,pos);
  dynRemove(gPtModules,pos);
  dynRemove(gPtIcons,pos);
  dynRemove(gPtMenuBar,pos);
  dynRemove(gPtIconBar,pos);
  dynRemove(gPtModal,pos);
  dynRemove(gPtCentered,pos);
  dynRemove(gPtParameters,pos);
  dynRemove(gPtPermissions,pos);
  dynRemove(gPtDescription, pos);
  dynRemove(gPtLocality, pos);
  dynRemove(gPtFunctionality, pos);
  dynRemove(gPtPanelLink, pos);
  // setting panel indices
  for (i=1;i<=dynlen(gPtIndices);i++) gPtIndices[i]=i;
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
pt_removeGlobals()
{
  return;
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
pt_showError(int error, string str)
{
  string     sErr=getCatStr("pt","error"+error);
  dyn_float  df;
  dyn_string ds;

  // HOOK >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> HOOK
  // When a function 'hookpt_ShowError()' is defined
  // then call this one to for projects thatr have their own
  // topology check.
  if( isFunctionDefined( "hookpt_ShowError" ) )
  {
    string strEval = "string main(){ return hookpt_ShowError(" + error + "); }";
    bool bResult;

    evalScript( sErr, strEval, makeDynString() );
  }
  else
  {
    sErr=getCatStr("pt","error"+error);
  }
  // HOOK <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< HOOK

  if (str!="")
    sErr+=":\n"+str+" !";
  else
    sErr+=" !";
  if (error<0)
  {
    ChildPanelOnCentralModalReturn("vision/MessageWarning",
      getCatStr("para","warning"),makeDynString(sErr),df,ds);
  }
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
pt_createNavigation(dyn_int &indices, dyn_int &parents, dyn_int &back, dyn_int &forw, dyn_int &up, dyn_int &down)
{
  int       i,j,posParent,level;
  int       idx,parentIdx,nl,np;

  int       error;

  if ( globalExists("gPtCalledFromNativeGedi") && gPtCalledFromNativeGedi )
  {

     error = pt_checkPanelTopologyCache();

     indices = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.panelNumber:_online.._value"];
     parents = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.parentNumber:_online.._value"];
     back = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.backwardPanel:_online.._value"];
     forw = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.forwardPanel:_online.._value"];
     up = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.upwardPanel:_online.._value"];
     down = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.downwardPanel:_online.._value"];

     return;
  }

  // create gPtParentsReverse for faster search of last child
  for(i=dynlen(gPtParents);i>=1;i--)
  {
    dynAppend(gPtParentsReverse,gPtParents[i]);
  }

  // defining navigation
  for (int i=1;i<=dynlen(indices);i++)
  {

    back[i]=-1; forw[i]=-1; up[i]=-1; down[i]=-1;

    // parents

    level=pt_getNodeParentInfo(indices[i]);
    if (level>0) parentIdx=gPtParents[i];
    else         parentIdx=-1;

    if (parentIdx>0)   parents[i]=indices[parentIdx];
    else               parents[i]=0;

    // backwards
    if (level==0)
    {
      back[i]=0;
    }
    else
    {
      back[i]=pt_getMyBrotherBefore(i);
      if (back[i] == i)
        back[i]=pt_getMyLastChild(gPtParents[i]);
    }

    // forwards
    if (level==0)
    {
      forw[i]=0;
    }
    else
    {
      forw[i]=pt_getMyBrotherAfter(i);
      if (forw[i] == i)
        forw[i] = pt_getFirstChild(gPtParents[i]);
    }

    // upwards
    if ( level==0 || (level>0 && pt_getNodeParentInfo(gPtParents[i])==0 && parentIdx>1) )
      up[i]=0;
    else
      up[i]=parentIdx;

    // downwards
    down[i] = pt_getFirstChild(i);
  }
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
pt_setNodeParaFields(string refName)
{
  bool b;

  refName=strrtrim(strltrim(refName));
  b=(refName!="");

  txtNodeName.enabled=(txtNodeName.text!="StartPanel");
  cmdLang.enabled=(txtNodeName.text!="StartPanel");
  txtModuleNameTxt1.enabled=(b && txtNodeName.text!="StartPanel");
  txtModuleNameTxt2.enabled=(b && txtNodeName.text!="StartPanel");
  txtModuleName.enabled=(b && txtNodeName.text!="StartPanel");
  chkModal.enabled=b;
  chkCentered.enabled=b;
  txtPropsTxt.enabled=b;
  txtPermTxt.enabled=b;
  cmbPermission.enabled=b;
  t1.enabled=b;
  t3.enabled=b;
  b1.enabled=b;
  b2.enabled=b;
  b3.enabled=b;
  tab.enabled=b;
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
dyn_string pt_getDollarParams(string panelName)
{
  dyn_string ds=makeDynString();
  string panelExist = getPath(PANELS_REL_PATH, panelName);

  if ( panelExist != "" )
    ds=getDollarParamsFromPanel(panelName);

  return (ds);
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
string pt_mergeDollars(dyn_string params)
{
  int    i;
  string param="";

  for (i=1;i<=dynlen(params);i++)
  {
    param+=params[i]+":";
  }
  return (param);
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
pt_splitDollars(string parameters, dyn_string &dollars, dyn_string &values)
{
  int        i;
  int j = 1;
  dyn_string ds, params=strsplit(parameters,"$");
  string dollar;


  dynClear(dollars);
  dynClear(values);
  for (i=2;i<=dynlen(params);i++)
  {
    ds=strsplit(params[i],":");
    if ( dynlen( ds) == 1 && strpos( params[i], ":") > 0 && dynlen( params) > i && strpos( params[i+1], ":") < 0 )
                 // sonderfall: �bergabe von $-Parameter   $hugo:$blubb
                 //             Leerer $-Parameter         $hugo:$blubb:
    {
      dollar = ds[1];
      values[j] =   "$"+params[i+1];
      dollars[j] =  "$"+dollar;
      j++;
      i++;
      continue;
    }
    else if (dynlen(ds)>0)
    {
      dollar = ds[1];
      string sTempString = params[i];
      strreplace( sTempString, ds[1]+":", "");   // remove $parameter:
      if (dynlen(ds)>1)                          // foreign system
      {
        values[j]=sTempString;
      }
      else
        values[j]= "";
    }
    else
    {
      values[j] = "";
      dollar =  params[i];
    }

    dollars[j] =  "$"+ dollar;
    j++;
  }
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
pt_showDollars(string sName,string param)
{
  int        i;
  string     value,dollar;
  dyn_string ds;
  dyn_string dsDollars, dsValues;

  pt_splitDollars( param, dsDollars, dsValues);

  setValue(sName,"deleteAllLines");

  for ( i=1; i<= dynlen(dsDollars); i++)
    ds[i] = " ...";

  setValue(sName,"appendLines", dynlen( ds) ,   "dollarParams",    dsDollars,
            "dpSelector",      ds,
            "panelSelector",   ds,
            "colorSelector",   ds,
            "value",           dsValues  );
}

////////////////////////////////////////////////////////////////////////////
pt_getXY(string fileName, int &x, int &y)
{
  int     PBreite,PHoehe;
  dyn_int di=getPanelSize(fileName);



  dpGet("_PanelTopology.template.panelWidth:_online.._value",PBreite,
        "_PanelTopology.template.panelHeight:_online.._value",PHoehe);
  x=(PBreite-di[1])/2;
  y=(PHoehe-di[2]-20)/2;
  if(x<0) x=0;
  if(y<0) y=0;
}
////////////////////////////////////////////////////////////////////////////
// iDirection: 0=home (main)
//             1=backwards
//             2=forwards
//             3=upwards
//             4=downwards
//            -1=show this panel
////////////////////////////////////////////////////////////////////////////
pt_panelOn(string panelName, string sModuleName, int iDirection = -1, string strServerName="",
           int iUpdateNavigationButtons = 0, int iUpdateHistory=1)
{
  int            i,pos,newpos=0,error=0,x,y, iModuleNumber;
  string         newPanel;
  dyn_int        back,forw,up,down,panelType,permissionBit,di,menuBar,iconBar;
  dyn_bool       modal,centered;
  dyn_string     fileName,moduleName,parameter,panelNames,params,dollar;
  dyn_langString nodeName;
  string         ModuleNumber;

  if (iDirection<-2 || iDirection>4) return;

  string sys = getSystemName();

  if(strServerName == "")
  {
    strreplace(sys,":","");
    strServerName = sys;
  }

  pt_moduleNumber(sModuleName, ModuleNumber);

  error = pt_checkPanelTopologyCache();

  // error==-1 dpGet-error
  if (error<0)
  {
    pt_showError(error, "");
    return;
  }


  //if a panel of another System is currently shown as rootPanel,
  // the topology of this system has to be used, to get the correct panel
  // correspondig to the requested navigation direction

  if (sModuleName=="naviModule" && iDirection != -1)
      panelName=rootPanel(pt_buildModuleName("mainModule", ModuleNumber));

  dyn_string dsPanelNameWithSystem = strsplit(panelName, " ");

  if (dynlen(dsPanelNameWithSystem) > 1)
  {
     string sSystemPart = dsPanelNameWithSystem[1];

     if( patternMatch("System?", sSystemPart))
     {
        sys = dsPanelNameWithSystem[1];
        strreplace(sys,":","");
        strServerName = sys;

        panelName = "";

        for(int i=2; i<= dynlen(dsPanelNameWithSystem);i++)
        {
          if(i < dynlen(dsPanelNameWithSystem))
          {
              panelName = panelName + dsPanelNameWithSystem[i]+" ";
          }
          else
          {
             panelName = panelName + dsPanelNameWithSystem[i];
          }
        }
     }
  }

  nodeName = g_PanelTopologyCache[ strServerName + ":_PanelTopology.nodeName:_online.._value"];
  fileName = g_PanelTopologyCache[ strServerName + ":_PanelTopology.fileName:_online.._value"];
  panelType = g_PanelTopologyCache[ strServerName + ":_PanelTopology.panelType:_online.._value"];
  moduleName = g_PanelTopologyCache[ strServerName + ":_PanelTopology.moduleName:_online.._value"];
  menuBar = g_PanelTopologyCache[ strServerName + ":_PanelTopology.menuBar:_online.._value"];
  iconBar = g_PanelTopologyCache[ strServerName + ":_PanelTopology.iconBar:_online.._value"];
  modal = g_PanelTopologyCache[ strServerName + ":_PanelTopology.modal:_online.._value"];
  centered = g_PanelTopologyCache[ strServerName + ":_PanelTopology.centered:_online.._value"];
  parameter =  g_PanelTopologyCache[ strServerName + ":_PanelTopology.parameter:_online.._value"];
  back = g_PanelTopologyCache[ strServerName + ":_PanelTopology.backwardPanel:_online.._value"];
  forw = g_PanelTopologyCache[ strServerName + ":_PanelTopology.forwardPanel:_online.._value"];
  up = g_PanelTopologyCache[ strServerName + ":_PanelTopology.upwardPanel:_online.._value"];
  down = g_PanelTopologyCache[ strServerName + ":_PanelTopology.downwardPanel:_online.._value"];
  permissionBit = g_PanelTopologyCache[ strServerName + ":_PanelTopology.permissionBit:_online.._value"];

  panelNames=nodeName;

  // no panel in this direction
  pos=(iDirection==-1)?dynContains(fileName,panelName):dynContains(panelNames,panelName);
  if (pos<1)
  {
    pt_showError(-3, "");
    return;
  }

//  if (iDirection==-1) newpos=forw[pos];
                      // TI 14635
  if (iDirection==-1||iDirection == -2) newpos=pos;
  else
  if (iDirection==0) newpos=1;
  else
  if (iDirection==1) newpos=back[pos];
  else
  if (iDirection==2) newpos=forw[pos];
  else
  if (iDirection==3) newpos=up[pos];
  else
  if (iDirection==4) newpos=down[pos];

  if (newpos<=0)
  {
    pt_showError(-15, "");
    return;
  }
  else
  if (dynlen(fileName)<newpos || fileName[newpos]=="")
  {
    pt_showError(-11, "");  // panel to display not found
    return;
  }

  // permission?
  if (!getUserPermission(permissionBit[newpos]))
  {
    pt_showError(-12, nodeName[newpos]);
    return;
  }

  // closing child panel
  if (panelType[pos]==1 && iDirection>0)
  {
    // upwards or backwards
    if (iDirection==1 || iDirection==3)
    {
      if (sModuleName=="naviModule")
        PanelOffModule(nodeName[pos],"mainModule");
      else
        PanelOffPanel(nodeName[pos]);
    }
    return;
  }

  // old is root in other module and (home or upwards or backwards)
  if (panelType[pos]==0 && moduleName[pos]!="" &&
      (iDirection==0 || iDirection==1 || iDirection==3))
  {
    ModuleOff(moduleName[pos]);
    return;
  }

  //building panel parameters
  params=strsplit(parameter[newpos],"$");

  //**** mhalper: figure out if there is a "dollar script" to evaluate
  PT_evalDollarScript(params);
  //****

  if (dynlen(params)>1) dynRemove(params,1);
  for (i=1;i<=dynlen(params);i++)
  {
    dollar[i]="$"+params[i];
  }

  // displaying panel

  // childpanel
  if (panelType[newpos]>0)
  {
    if (modal[newpos])        // modal
    {
      if (centered[newpos])   // modal & centered
      {
        pt_getXY(fileName[newpos],x,y);
        if (sModuleName=="naviModule")
          ChildPanelOnModuleModal(fileName[newpos],nodeName[newpos],pt_buildModuleName("mainModule", ModuleNumber),
            dollar,x,y);
        else
          ChildPanelOnCentralModal(fileName[newpos],nodeName[newpos],
            dollar);
      }
      else                    // modal & not centered
      {
        if (sModuleName=="naviModule")
          ChildPanelOnModuleModal(fileName[newpos],nodeName[newpos],pt_buildModuleName("mainModule", ModuleNumber),
            dollar,0,0);
        else
          ChildPanelOnModal(fileName[newpos],nodeName[newpos],
            dollar,0,0);
      }
    }
    else                      // not modal
    {
      if (centered[newpos])   // not modal & centered
      {
        pt_getXY(fileName[newpos],x,y);
        if (sModuleName=="naviModule")
          ChildPanelOnModule(fileName[newpos],nodeName[newpos],pt_buildModuleName("mainModule", ModuleNumber),
            dollar,x,y);
        else
          ChildPanelOnCentral(fileName[newpos],nodeName[newpos],
            dollar);
      }
      else                    // not modal & not centered
      {
        if (sModuleName=="naviModule")
          ChildPanelOnModule(fileName[newpos],nodeName[newpos],pt_buildModuleName("mainModule", ModuleNumber),
            dollar,0,0);
        else
          ChildPanelOn(fileName[newpos],nodeName[newpos],
            dollar,0,0);
      }
    }
  }
  else                     // rootpanel
  {
    // rootpanel in same module
    if (moduleName[newpos]=="")
    {
      if(iUpdateHistory == iptnavi_OPENPANEL_ADDHISTORY )
        ptnavi_HistoryAdd(ModuleNumber,newpos,strServerName,parameter[newpos]);

      //used for history and navigation through dist in future
      dpSetWait(myUiDpName()+".Navigation.ModuleName",pt_buildModuleName("mainModule", ModuleNumber),
                myUiDpName()+".Navigation.System",strServerName,
                myUiDpName()+".Navigation.TopoNode",newpos);

      if (sModuleName=="naviModule")
        RootPanelOnModule(fileName[newpos],nodeName[newpos],pt_buildModuleName("mainModule", ModuleNumber),
          dollar);
      else if (sModuleName=="mainModule")
        RootPanelOnModule(fileName[newpos],nodeName[newpos],pt_buildModuleName("mainModule", ModuleNumber),
          dollar);
      else if (sModuleName=="infoModule")
        RootPanelOnModule(fileName[newpos],nodeName[newpos],pt_buildModuleName("mainModule", ModuleNumber),
          dollar);
      else
        RootPanelOn(fileName[newpos],nodeName[newpos],
          dollar,0,0);
    }
    else                         // rootpanel in new module
    {
      di=getPanelSize(fileName[newpos]);
      ModuleOnWithPanel(moduleName[newpos],
        0,0,
        di[1],
        di[2],
        iconBar[newpos]-1,
        menuBar[newpos]-1,
        "",
        fileName[newpos],
        nodeName[newpos],
        dollar);
    }
  }
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
pt_panelOn2(string sModuleName, string strServerName="",
           int iUpdateNavigationButtons = 0, int iUpdateHistory = 1)
{
  int            i,error=0,newpos=0,pNr=$panelNumber,refNr,x,y;
  string         newPanel,pNa=$panelName;
  dyn_int        back,forw,up,down,panelType,permissionBit,di,menuBar,iconBar,alertNumber,diPanelNumber;
  dyn_bool       modal,centered;
  dyn_string     fileName,moduleName,parameter,panelNames,params,dsFileName,dollar;
  dyn_langString nodeName;
  int iModuleNumber;
  string ModuleNumber;


  string sys = getSystemName();

  if(strServerName == "")
  {
    strreplace(sys,":","");
    strServerName = sys;
  }

  pt_moduleNumber(sModuleName, ModuleNumber);

  dpGet(strServerName+":_PTPanelOn.fileName:_online.._value",dsFileName,
        strServerName+":_PTPanelOn.panelNumber:_online.._value",diPanelNumber);

  error = pt_checkPanelTopologyCache(strServerName);

  // error==-1 dpGet-error
  if (error<0)
  {
    pt_showError(error, "");
    return;
  }

  fileName = g_PanelTopologyCache[ strServerName + ":_PanelTopology.fileName:_online.._value"];
  alertNumber  = g_PanelTopologyCache[ strServerName + ":_PanelTopology.sumAlertNumber:_online.._value"];

  if ( isDollarDefined("$refNumber") )
  {
    refNr = $refNumber;
    if (refNr>0 && refNr<=dynlen(dsFileName))
    {
      pNa=dsFileName[refNr]; pNr=diPanelNumber[refNr];
    }
  }
  newpos=pt_getTopologyNumber(fileName,alertNumber,pNa,pNr);

  if (newpos<1)
  {
    pt_showError(-3, "");
    return;
  }

  error = pt_checkPanelTopologyCache(strServerName);

  // error==-1 dpGet-error
  if (error<0)
  {
    pt_showError(error, "");
    return;
  }


  nodeName = g_PanelTopologyCache[ strServerName + ":_PanelTopology.nodeName:_online.._value"];
  fileName = g_PanelTopologyCache[ strServerName + ":_PanelTopology.fileName:_online.._value"];
  panelType = g_PanelTopologyCache[ strServerName + ":_PanelTopology.panelType:_online.._value"];
  moduleName = g_PanelTopologyCache[ strServerName + ":_PanelTopology.moduleName:_online.._value"];
  menuBar = g_PanelTopologyCache[ strServerName + ":_PanelTopology.menuBar:_online.._value"];
  iconBar = g_PanelTopologyCache[ strServerName + ":_PanelTopology.iconBar:_online.._value"];
  modal = g_PanelTopologyCache[ strServerName + ":_PanelTopology.modal:_online.._value"];
  centered = g_PanelTopologyCache[ strServerName + ":_PanelTopology.centered:_online.._value"];
  parameter = g_PanelTopologyCache[ strServerName + ":_PanelTopology.parameter:_online.._value"];
  back = g_PanelTopologyCache[ strServerName + ":_PanelTopology.backwardPanel:_online.._value"];
  forw = g_PanelTopologyCache[ strServerName + ":_PanelTopology.forwardPanel:_online.._value"];
  up = g_PanelTopologyCache[ strServerName + ":_PanelTopology.upwardPanel:_online.._value"];
  down = g_PanelTopologyCache[ strServerName + ":_PanelTopology.downwardPanel:_online.._value"];
  permissionBit = g_PanelTopologyCache[ strServerName + ":_PanelTopology.permissionBit:_online.._value"];


  if (dynlen(fileName)<newpos || fileName[newpos]=="")
  {
    pt_showError(-11, "");  // panel to display not found
    return;
  }

  panelNames=nodeName;

  // permission?
  if (!getUserPermission(permissionBit[newpos]))
  {
    pt_showError(-12, panelNames[newpos]);
    return;
  }

  //**** mhalper: figure out if there is a " script" to execute instead of a panel
  if (strtolower(strltrim(substr(fileName[newpos], 0, 10), " ")) == "execscript")
  {
    int iErr;

    PT_execScript(fileName[newpos], iErr);

    if (iErr==0) return;
    else         return;  //ToDo - Error handling
  }
  //****

  //building panel parameters
  params=strsplit(parameter[newpos],"$");

  //**** mhalper: figure out if there is a "dollar script" to evaluate
  PT_evalDollarScript(params);
  //****

  if (dynlen(params)>1) dynRemove(params,1);
  for (i=1;i<=dynlen(params);i++)
  {
    dollar[i]="$"+params[i];
  }

  // displaying panel

  // childpanel
  if (panelType[newpos]>0)
  {
    if (modal[newpos])        // modal
    {
      if (centered[newpos])   // modal & centered
      {
        pt_getXY(fileName[newpos],x,y);
        if (sModuleName=="naviModule")
          ChildPanelOnModuleModal(fileName[newpos],nodeName[newpos],pt_buildModuleName("mainModule", ModuleNumber),
            dollar,x,y);
        else
          ChildPanelOnCentralModal(fileName[newpos],nodeName[newpos],
            dollar);
      }
      else                    // modal & not centered
      {
        if (sModuleName=="naviModule")
          ChildPanelOnModuleModal(fileName[newpos],nodeName[newpos],pt_buildModuleName("mainModule", ModuleNumber),
            dollar,0,0);
        else
          ChildPanelOnModal(fileName[newpos],nodeName[newpos],
            dollar,0,0);
      }
    }
    else                      // not modal
    {
      if (centered[newpos])   // not modal & centered
      {
        pt_getXY(fileName[newpos],x,y);
        if (sModuleName=="naviModule")
          ChildPanelOnModule(fileName[newpos],nodeName[newpos],pt_buildModuleName("mainModule", ModuleNumber),
            dollar,x,y);
        else
          ChildPanelOnCentral(fileName[newpos],nodeName[newpos],
            dollar);
      }
      else                    // not modal & not centered
      {
        if (sModuleName=="naviModule")
          ChildPanelOnModule(fileName[newpos],nodeName[newpos],pt_buildModuleName("mainModule", ModuleNumber),
            dollar,0,0);
        else
          ChildPanelOn(fileName[newpos],nodeName[newpos],
            dollar,0,0);
      }
    }
  }
  else                     // rootpanel
  {
    // rootpanel in same module
    if (moduleName[newpos]=="")
    {
      if(iUpdateHistory == iptnavi_OPENPANEL_ADDHISTORY )
        ptnavi_HistoryAdd(ModuleNumber,newpos,strServerName,parameter[newpos]);


      //used for history and navigation through dist in future
      dpSetWait(myUiDpName()+".Navigation.ModuleName",pt_buildModuleName("mainModule", ModuleNumber),
                myUiDpName()+".Navigation.System",strServerName,
                myUiDpName()+".Navigation.TopoNode",newpos);

      if (sModuleName=="naviModule")
      {
        RootPanelOnModule(fileName[newpos],strServerName+" "+nodeName[newpos],pt_buildModuleName("mainModule", ModuleNumber),
          dollar);
      }
      else
        RootPanelOn(fileName[newpos],strServerName+" "+nodeName[newpos],
          dollar,0,0);
    }
    else                         // rootpanel in new module
    {
      di=getPanelSize(fileName[newpos]);
      ModuleOnWithPanel(moduleName[newpos],
        0,0,
        di[1],
        di[2],
        iconBar[newpos]-1,
        menuBar[newpos]-1,
        "",
        fileName[newpos],
        nodeName[newpos],
        dollar);
    }
  }
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
pt_panelOn3(int pos, string sModuleName, string strServerName="",
           int iUpdateNavigationButtons = 0, int iUpdateHistory=1)
{
  int            i,error=0,newpos=0,pNr,refNr,x,y, iModuleNumber;
  string         newPanel,pNa;
  dyn_int        back,forw,up,down,panelType,permissionBit,di,menuBar,iconBar,alertNumber,diPanelNumber;
  dyn_bool       modal,centered;
  dyn_string     fileName,moduleName,parameter,panelNames,params,dsFileName,dollar;
  dyn_langString nodeName;
  string ModuleNumber;


  string sys = getSystemName();

  if(strServerName == "")
  {
    strreplace(sys,":","");
    strServerName = sys;
  }

  pt_moduleNumber(sModuleName, ModuleNumber);

  error = pt_checkPanelTopologyCache(strServerName);

  nodeName = g_PanelTopologyCache[strServerName + ":_PanelTopology.nodeName:_online.._value"];
  fileName = g_PanelTopologyCache[ strServerName + ":_PanelTopology.fileName:_online.._value"];
  panelType  = g_PanelTopologyCache[ strServerName + ":_PanelTopology.panelType:_online.._value"];
  moduleName     = g_PanelTopologyCache[ strServerName + ":_PanelTopology.moduleName:_online.._value"];
  alertNumber  = g_PanelTopologyCache[ strServerName + ":_PanelTopology.sumAlertNumber:_online.._value"];
  menuBar   = g_PanelTopologyCache[ strServerName + ":_PanelTopology.menuBar:_online.._value"];
  iconBar = g_PanelTopologyCache[ strServerName + ":_PanelTopology.iconBar:_online.._value"];
  modal  = g_PanelTopologyCache[ strServerName + ":_PanelTopology.modal:_online.._value"];
  centered= g_PanelTopologyCache[ strServerName + ":_PanelTopology.centered:_online.._value"];
  parameter = g_PanelTopologyCache[ strServerName + ":_PanelTopology.parameter:_online.._value"];
  back    = g_PanelTopologyCache[ strServerName + ":_PanelTopology.backwardPanel:_online.._value"];
  forw    = g_PanelTopologyCache[ strServerName + ":_PanelTopology.forwardPanel:_online.._value"];
  up      = g_PanelTopologyCache[ strServerName + ":_PanelTopology.upwardPanel:_online.._value"];
  down    = g_PanelTopologyCache[ strServerName + ":_PanelTopology.downwardPanel:_online.._value"];
  permissionBit = g_PanelTopologyCache[ strServerName + ":_PanelTopology.permissionBit:_online.._value"];


  // error==-1 dpGet-error
  if (error<0)
  {
    pt_showError(error, "");
    return;
  }

  pNa=fileName[pos]; pNr=alertNumber[pos];

  newpos=pt_getTopologyNumber(fileName,alertNumber,pNa,pNr);

  if (newpos<1)
  {
    pt_showError(-3, "");
    return;
  }

  if ( fileName[newpos]=="" )
    return;
  else if (dynlen(fileName)<newpos)// || fileName[newpos]=="")
  {
    pt_showError(-11, "");  // panel to display not found
    return;
  }

  panelNames=nodeName;
  // permission?
  if (!getUserPermission(permissionBit[newpos]))
  {
    pt_showError(-12, panelNames[newpos]);
    return;
  }

  //**** mhalper: figure out if there is a " script" to execute instead of a panel
  if (strtolower(strltrim(substr(fileName[newpos], 0, 10), " ")) == "execscript")
  {
    int iErr;

    PT_execScript(fileName[newpos], iErr);

    if (iErr==0) return;
    else         return;  //ToDo - Error handling
  }
  //****

  //building panel parameters
  params=strsplit(parameter[newpos],"$");

  //**** mhalper: figure out if there is a "dollar script" to evaluate
  PT_evalDollarScript(params);
  //****

  if (dynlen(params)>1) dynRemove(params,1);
  for (i=1;i<=dynlen(params);i++)
  {
    dollar[i]="$"+params[i];
  }

  // displaying panel
  // childpanel
  if (panelType[newpos]>0)
  {
    if (modal[newpos])        // modal
    {
      if (centered[newpos])   // modal & centered
      {
        pt_getXY(fileName[newpos],x,y);
        if (sModuleName=="naviModule")
          ChildPanelOnModuleModal(fileName[newpos],nodeName[newpos],pt_buildModuleName("mainModule", ModuleNumber),
            dollar,x,y);
        else
          ChildPanelOnCentralModal(fileName[newpos],nodeName[newpos],
            dollar);
      }
      else                    // modal & not centered
      {
        if (sModuleName=="naviModule")
          ChildPanelOnModuleModal(fileName[newpos],nodeName[newpos],pt_buildModuleName("mainModule", ModuleNumber),
            dollar,0,0);
        else
          ChildPanelOnModal(fileName[newpos],nodeName[newpos],
            dollar,0,0);
      }
    }
    else                      // not modal
    {
      if (centered[newpos])   // not modal & centered
      {
        pt_getXY(fileName[newpos],x,y);
        if (sModuleName=="naviModule")
          ChildPanelOnModule(fileName[newpos],nodeName[newpos],pt_buildModuleName("mainModule", ModuleNumber),
            dollar,x,y);
        else
          ChildPanelOnCentral(fileName[newpos],nodeName[newpos],
            dollar);
      }
      else                    // not modal & not centered
      {
        if (sModuleName=="naviModule")
          ChildPanelOnModule(fileName[newpos],nodeName[newpos],pt_buildModuleName("mainModule", ModuleNumber),
            dollar,0,0);
        else
          ChildPanelOn(fileName[newpos],nodeName[newpos],
            dollar,0,0);
      }
    }
  }
  else                     // rootpanel
  {
// rootpanel in same module
    if (moduleName[newpos]=="")
    {
      if(iUpdateHistory == iptnavi_OPENPANEL_ADDHISTORY )
        ptnavi_HistoryAdd(ModuleNumber,newpos,strServerName,parameter[newpos]);

      //used for history and navigation through dist in future
      dpSetWait(myUiDpName()+".Navigation.ModuleName",pt_buildModuleName("mainModule", ModuleNumber),
                myUiDpName()+".Navigation.System",strServerName,
                myUiDpName()+".Navigation.TopoNode",newpos);

      if (sModuleName=="naviModule"||sModuleName=="mainModule")
        RootPanelOnModule(fileName[newpos],strServerName+" "+nodeName[newpos],pt_buildModuleName("mainModule", ModuleNumber),
          dollar);
      else
        RootPanelOn(fileName[newpos],strServerName+" "+nodeName[newpos],
          dollar,0,0);
    }
    else                         // rootpanel in new module
    {
      di=getPanelSize(fileName[newpos]);
      ModuleOnWithPanel(moduleName[newpos],
        0,0,
        di[1],
        di[2],
        iconBar[newpos]-1,
        menuBar[newpos]-1,
        "",
        fileName[newpos],
        nodeName[newpos],
        dollar);
    }
  }
}

////////////////////////////////////////////////////////////////////////////
ptChildPanelOnModuleCentral(string FileName,string PanelName,string ModuleName,
                    dyn_string Parameter)
{
   int     PBreite,PHoehe,x,y;
   string  sRoot=rootPanel(ModuleName);
   dyn_int di;

   di=getPanelSize(FileName);
   panelSize(sRoot,PBreite,PHoehe);
   x=(PBreite-di[1])/2;
   y=(PHoehe-di[2]-20)/2;
   if(x<0) x=0;
   if(y<0) y=0;

   ChildPanelOnModule(FileName,PanelName,ModuleName,Parameter,x,y);

}
////////////////////////////////////////////////////////////////////////////
ptChildPanelOnModuleCentralModal(string FileName,string PanelName,string ModuleName,
                         dyn_string Parameter)
{
   int     PBreite,PHoehe,x,y;
   string  sRoot=rootPanel(ModuleName);
   dyn_int di;

   di=getPanelSize(FileName);

   panelSize(sRoot,PBreite,PHoehe);
   x=(PBreite-di[1])/2;
   y=(PHoehe-di[2]-20)/2;
   if(x<0) x=0;
   if(y<0) y=0;

   ChildPanelOnModuleModal(FileName,PanelName,ModuleName,Parameter,x,y);
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
string pt_getRelFromAbsPanelPath(string absPath)
{
  int    pos;
  string relPath;

  strreplace(absPath,"\\","/");
  pos=strpos(absPath,"/panels/");
  if (pos<0)
  {
    relPath="";
  }
  else
  {
    relPath=substr(absPath,pos+8,strlen(absPath)-pos-8);
  }
  return (relPath);
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
pt_createDpTypeSumAlertPanel(int firstNr, bool toEnd)
{
  int            i,err;
  string         name="_SumAlertPanel",dpe,sClass;
  unsigned       uAckHasPrio,uOrder;
  bool           ok;
  dyn_uint       duMin=makeDynUInt(),duMax=duMin;
  dyn_float      df;
  dyn_string     prioRange=makeDynString(),dsOn,dsOff,ds,dpt=dpTypes(),
                 dsLeaf, dsDynamicAttribute;
  langString     ls_lt;
  dyn_langString dlOn,dlOff;
  dyn_dyn_int    dpeTypes;
  dyn_dyn_string dpeElements;

  dpGet("_SumAlertGeneral.prioRange.name:_online.._value",    prioRange,
        "_SumAlertGeneral.prioRange.min:_online.._value",     duMin,
        "_SumAlertGeneral.prioRange.max:_online.._value",     duMax,
        "_SumAlertGeneral.prioRange.textOn:_online.._value",  dlOn,
        "_SumAlertGeneral.prioRange.textOff:_online.._value", dlOff,
        "_SumAlertGeneral.ack_has_prio:_online.._value",      uAckHasPrio,
        "_SumAlertGeneral.order:_online.._value",             uOrder);

  // composing _SumAlertPanel datapoint type
  dpeElements[1][1]=name;
  dpeTypes[1][1]=DPEL_STRUCT;
  for (i=1;i<=dynlen(prioRange);i++)
  {
    dpeElements[i+1][2]=prioRange[i];
    dpeTypes[i+1][2]=DPEL_STRING;
  }
  // creating/changing _SumAlertPanel datapoint type
  if (dynContains(dpt,name)>0)
    err=dpTypeChange(dpeElements,dpeTypes);
  else
  {
    err=dpTypeCreate(dpeElements,dpeTypes);
  }
  if (err)
  {
    ChildPanelOnCentralModalReturn("vision/MessageWarning",
      getCatStr("para","warning"), makeDynString(getCatStr("ac","dptcreateerror")),
      df,ds);
    return;
  }
  // creating master datapoint
  if (!dpExists("_mp__SumAlertPanel"))
  {
    dpCreate("_mp__SumAlertPanel",name);
    if ( !dpExists("_dt_"+name) )
      dpCreate("_dt_"+name, "_DynamicDatapoints");
  }
  // writing alert_hdl parameters
  for (i=1;i<=dynlen(prioRange);i++)
  {
    dpe="_mp__SumAlertPanel."+prioRange[i];

    dpDeactivateAlert(dpe, ok, true);

    dpSetTimed(0,dpe+":_alert_hdl.._type",DPCONFIG_SUM_ALERT); // IM 106203
    dpSetTimed(0,dpe+":_alert_hdl.._text1",dlOn[i],
              dpe+":_alert_hdl.._text0",dlOff[i],
              dpe+":_alert_hdl.._class","",
              dpe+":_alert_hdl.._ack_has_prio",uAckHasPrio,
              dpe+":_alert_hdl.._order",uOrder,
              dpe+":_alert_hdl.._dp_list",makeDynString("_TmpBitAlert."),
              dpe+":_alert_hdl.._dp_pattern","",
              dpe+":_alert_hdl.._prio_pattern",duMin[i]+"-"+duMax[i],
              dpe+":_alert_hdl.._abbr_pattern","",
              dpe+":_alert_hdl.._ack_deletes",true,
              dpe+":_alert_hdl.._non_ack",true,
              dpe+":_alert_hdl.._came_ack",true,
              dpe+":_alert_hdl.._pair_ack",true,
              dpe+":_alert_hdl.._both_ack",true,
              dpe+":_alert_hdl.._panel","",
              dpe+":_alert_hdl.._panel_param",makeDynString(),
              dpe+":_alert_hdl.._help",ls_lt);

    dpActivateAlert(dpe, ok, true);

    dsLeaf[i] = dpe + ":_alert_hdl";
    dsDynamicAttribute[i] = "_da_alert_hdl_sum";
  }
  dpSet("_dt_"+name+".Leaf:_original.._value", dsLeaf,
        "_dt_"+name+".DynamicAttribute:_original.._value", dsDynamicAttribute);

  pt_generateSumAlerts(firstNr,toEnd);
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
int pt_generateSumAlerts(int firstNr, bool toEnd, bool startFromPanel=true)
{
  int          i, j, k, iError, upTo, iPrior, iAll, iOf, aType = DPCONFIG_SUM_ALERT,
               errors=0, posFree, iNotOwnSystem = 0;
  unsigned     uAckHasPrio,uOrder;
  char         cPrior;
  bool         b,bTypeChanged, ok, bMissingDollarDisplayed, bNoDollarDefined;
  time         tTime;
  string       dpName, dpe, s, aClass, sT, sTime, sScript, sPName, sDpe;
  dyn_int      indices, prioMin, prioMax;
  dyn_float    df;
  langString   ls, ls_lt;
  dyn_string   names, panels, types, modules, dollars, values,
               modals, centered, parameters, permissions,
               params, prioRange, confirmDps, dps, ds, dsLeafs, dsDps,
               allDps,actDps,
               defaultDps=makeDynString(getSystemName()+"_TmpBitAlert.");
  dyn_uint     parents,back,forw,up,down,alerts;
  dyn_errClass errC;
  dyn_langString dLs;
  dyn_langString dlOn,dlOff;
  dyn_dyn_anytype dda;
  // IM104828:
  // Always sort nodes prior to sumalertgeneration. If they are unsorted it may be that
  // the last node is defined somewhere in the middle of all nodes and pt_getLastChild()
  // will not return all nodes!

  /*
    31.01.2014   Pokorny, Martin  113307 :
    - function pt_sortNodes() is obsolete after version 3.11.0, does not work correctly and is not necessary to use it
  */
//   pt_sortNodes(false, true);

  dpGet("_SumAlertGeneral.prioRange.name:_online.._value",    prioRange,
        "_SumAlertGeneral.prioRange.min:_online.._value",     prioMin,
        "_SumAlertGeneral.prioRange.max:_online.._value",     prioMax,
        "_SumAlertGeneral.prioRange.textOn:_online.._value",  dlOn,
        "_SumAlertGeneral.prioRange.textOff:_online.._value", dlOff,
        "_SumAlertGeneral.ack_has_prio:_online.._value",      uAckHasPrio,
        "_SumAlertGeneral.order:_online.._value",             uOrder);

  pt_checkPanelTopologyCache();

  indices = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.panelNumber:_online.._value"];
  parents = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.parentNumber:_online.._value"];
  alerts  = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.sumAlertNumber:_online.._value"];
  dLs     = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.nodeName:_online.._value"];
  panels  = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.fileName:_online.._value"];
  types   = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.panelType:_online.._value"];
  modules = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.moduleName:_online.._value"];
  modals  = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.modal:_online.._value"];
  centered= g_PanelTopologyCache[ getSystemName() + "_PanelTopology.centered:_online.._value"];
  parameters = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.parameter:_online.._value"];
  permissions = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.permissionBit:_online.._value"];
  back    = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.backwardPanel:_online.._value"];
  forw    = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.forwardPanel:_online.._value"];
  up      = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.upwardPanel:_online.._value"];
  down    = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.downwardPanel:_online.._value"];

  for (i=1;i<=dynlen(dLs);i++) names[i]=dLs[i];
  // no sum alert for free panels
  posFree = pt_getFreeNodePosition(indices, parents);
  if (firstNr>=posFree)
  {
    if (startFromPanel)
    {
      ChildPanelOnCentralModalReturn("vision/MessageWarning",
        getCatStr("para","warning"),
        makeDynString(getCatStr("pt","noalertsforfreepanels")),
        df,ds);
    }
    else
    {
      string msg = "pt_generateSumAlerts:::" + getCatStr("pt","noalertsforfreepanels");
      strreplace(msg, "\n", " ");
      throwError(makeError("", PRIO_SEVERE, ERR_SYSTEM, 0, msg));
    }
    return -1;
  }


  /*
    31.01.2014   Pokorny, Martin  IM 113307 :
    - get all childs for  panel ID in a list and generate sum alerts, do not show only for the 1. and last node

  // creating sum alert for all requested panels
  if (toEnd) // toEnd==TRUE: sum alert for the choosen path (panel + all childs)
  {

    pt_getLastChild(firstNr, indices, parents, upTo);
//    pt_getLastChild(firstNr, gPtIndices, gPtParents, upTo);
  }
  else
    upTo=firstNr; // toEnd==FALSE: sum alert for exactly one panel

  iAll=upTo-firstNr+1;
  */

  dyn_int diChilds = pt_getChilds(firstNr, indices, parents, toEnd);
  dynInsertAt(diChilds, firstNr, 1); // add also first ID in to list
  int iLen = dynlen(diChilds);
  iAll = iLen;  // for progressbar

  if (startFromPanel)
  {
    openProgressBar(getCatStr("pt","createalert"),
                    "sumalarm.gif",
                    "", "0/"+iAll, "0 %",
                    2);
  }

  /*
    31.01.2014   Pokorny, Martin  IM 113307 :
    - go for each child, and create sum alerts Dps (if not exists)

  for (i=firstNr;i<=upTo;i++)
    */

  for(int j=1; j<=iLen;j++)
  {
    i = diChilds[j]; // IM 113307 (mpokorny): 'i' is not the counter, but the id of child
    if (startFromPanel)
    {
      iOf=j-firstNr+1;
      sprintf(s,"%3.0f %",(1.0*iOf/iAll*100.0));
      showProgressBar(getCatStr("pt","creatingdpfor")+names[i],
                      iOf+"/"+iAll, s, 1.0*iOf/iAll*100.0);
    }
    if (strrtrim(strltrim(panels[i]))=="")
    {
      break; // Free panels
    }

    // creating datapoint name
    dpName=pt_fileNameToDpName(panels[i],alerts[i]);
    // creating panel sum alert datapoint
    if (!dpExists(dpName))
    {
      dpCopyBufferClear();
      dpCopy("_mp__SumAlertPanel",dpName,iError);
    }
    else
    {
      int iMp;
      dyn_string dsMpDpe = dpNames("_mp__SumAlertPanel.*");

      for ( iMp = 1; iMp <= dynlen(dsMpDpe); iMp++)
      {
        string s = dsMpDpe[iMp];
        int iAlertType;
        strreplace(s, dpSubStr(dsMpDpe[iMp],DPSUB_DP), dpName);
        dpGet(s + ":_alert_hdl.._type", iAlertType);  // check if there is allredy a sumalert
        if ( iAlertType != DPCONFIG_SUM_ALERT)
            dpCopyConfig(dpSubStr(dsMpDpe[iMp],DPSUB_DP_EL), dpName,makeDynString("_alert_hdl"), iError);
     }
    }
    if (iError)
    {
      errors++;
      throwError(makeError("", PRIO_INFO, ERR_SYSTEM, 0, "pt_generateSumAlerts:::dpCopy:::iError "+iError+" ( _mp__SumAlertPanel -> "+dpName+" )"));
      if (startFromPanel)
      {
        closeProgressBar();
        ChildPanelOnCentralModalReturn("vision/MessageWarning",
          getCatStr("para","warning"),makeDynString(getCatStr("sql","errorOccured")),df,ds);
      }
      else
      {
        string msg = "pt_generateSumAlerts:::" + getCatStr("sql","errorOccured");
        strreplace(msg, "\n", " ");
        throwError(makeError("", PRIO_SEVERE, ERR_SYSTEM, 0, msg));
      }
      return -2;
    }
  }

  // creating sum alerts
  /*
    31.01.2014   Pokorny, Martin  IM 113307 :
    - go for each child, and crate sum alert

  for (i=firstNr;i<=upTo;i++)
    */
  int iLen = dynlen(diChilds);
  for(int iCount=1; iCount<=iLen;iCount++)
  {
    i = diChilds[iCount]; // IM 113307 (mpokorny): 'i' is not the counter, but the id of child

    if (toEnd) // only for from-to
    {
      if (startFromPanel)
      {
        iOf=iCount-firstNr+1;
        sprintf(s,"%3.0f %",(1.0*iOf/iAll*100.0));
          showProgressBar(getCatStr("pt","parametersfor")+names[i], iOf+"/"+iAll,
                          s, 1.0*iOf/iAll*100.0);
      }
    }

    // creating datapoint name
    dpName=pt_fileNameToDpName(panels[i],alerts[i]);

    // building $parameter of the panel
    params=strsplit(parameters[i],"$");

    if (dynlen(params)>0) dynRemove(params,1);
    for (j=1;j<=dynlen(params);j++) params[j]="$"+params[j];

    // searching datapoints to confirm in all subpanels
    pt_splitDollars(parameters[i], dollars, values);
    if (startFromPanel)
      getConfirmDps(panels[i], dps, dollars, values);
    else
    {
      if (getPath(PANELS_REL_PATH, panels[i]) == "") //Panel does not exists
      {
        throwError(makeError("", PRIO_WARNING, ERR_SYSTEM, 0, "Panel '"+panels[i]+"' not found"));
      }
      else
        getConfirmDps(panels[i], dps, dollars, values);
    }

    pt_decodePanelAlerts( dps );

    bMissingDollarDisplayed = false;

    // setting alert handling datapoint parameters
    for (j=1;j<=dynlen(prioRange);j++)
    {
      if (!toEnd) // only if one node
      {
        if (startFromPanel)
        {
          sprintf(s,"%3.0f %",(1.0*j/dynlen(prioRange)*100.0));
            showProgressBar(prioRange[j], j+"/"+dynlen(prioRange),
                            s, 1.0*j/dynlen(prioRange)*100.0);
        }
      }
      confirmDps=makeDynString();
      // searching datapoints to confirm in this panel
      dsDps=dps;
      pt_getDownSumAlertDps(indices[i], indices, parents, alerts, panels, prioRange[j], confirmDps);
      dynAppend(confirmDps,dsDps);

      // removing nonexistent and dist dps from list
      for (k=dynlen(confirmDps);k>0;k--)
      {
        string     sTemp  = "";
        dyn_string dsTemp = strsplit(confirmDps[k], ".");

        if (dynlen(dsTemp) > 0)
        {
          sTemp = dpSubStr(dsTemp[1], DPSUB_SYS_DP);
          bNoDollarDefined = false;
        }
        else if(dynlen(dollars)!=0 && dynlen(values)!=0) //$-Param unset (set with default Values)
          bNoDollarDefined = true;
        // remove dist DPs
        if (sTemp != "" && dpSubStr(confirmDps[k], DPSUB_SYS) != getSystemName() )
        {
          dynRemove(confirmDps,k);
          iNotOwnSystem++;
          continue;
        }
        //remove nonexistent dps
        if ( !dpExists(sTemp) )
        {
          string sErr;
          if (sTemp!="")
          {
            errors++;
            sErr = "pt_generateSumAlerts:::" + getCatStr("para","dpnotexists") + " :" + dsTemp[1];
            throwError(makeError("", PRIO_INFO, ERR_SYSTEM, 0, sErr));
          }
          else if (!bMissingDollarDisplayed && bNoDollarDefined)  //display only one error (for all 3 Ranges: Warn, Alert, Danger)
          {
            errors++;
            bMissingDollarDisplayed = true;
            sErr = "pt_generateSumAlerts:::" + getCatStr("pt","missingdollar") + " : " + panels[i];
            throwError(makeError("", PRIO_INFO, ERR_SYSTEM, 0, sErr));
          }
          dynRemove(confirmDps,k);
        }
        else
        {
          confirmDps[k]=dpSubStr(confirmDps[k],DPSUB_DP_EL);
        }
      }

      dynUnique(confirmDps);
      dpe=dpName+"."+prioRange[j];

      dpGet(dpe+":_alert_hdl.._type",aType);
      if ( aType != DPCONFIG_SUM_ALERT )
      {
        dpSetTimed(0,dpe+":_alert_hdl.._type",DPCONFIG_SUM_ALERT); // IM 106203
        dpSetTimed(0,dpe+":_alert_hdl.._text1",dlOn[j],
                  dpe+":_alert_hdl.._text0",dlOff[j],
                  dpe+":_alert_hdl.._class","",
                  dpe+":_alert_hdl.._ack_has_prio",uAckHasPrio,
                  dpe+":_alert_hdl.._order",uOrder,
                  dpe+":_alert_hdl.._dp_list",makeDynString("_TmpBitAlert."),
                  dpe+":_alert_hdl.._dp_pattern","",
                  dpe+":_alert_hdl.._prio_pattern",prioMin[j]+"-"+prioMax[j],
                  dpe+":_alert_hdl.._abbr_pattern","",
                  dpe+":_alert_hdl.._ack_deletes",true,
                  dpe+":_alert_hdl.._non_ack",true,
                  dpe+":_alert_hdl.._came_ack",true,
                  dpe+":_alert_hdl.._pair_ack",true,
                  dpe+":_alert_hdl.._both_ack",true,
                  dpe+":_alert_hdl.._panel","",
                  dpe+":_alert_hdl.._panel_param",makeDynString(),
                  dpe+":_alert_hdl.._help",ls_lt);
      }

      dyn_string test;
      dpGet(dpe+":_alert_hdl.._dp_list", test);

      // acknowledge and deactivate before changing
      dpDeactivateAlert( dpe, ok, true);

      dpSetTimed(0,dpe+":_alert_hdl.._dp_list",(dynlen(confirmDps)>0)?confirmDps:defaultDps, // IM 106203
                dpe+":_alert_hdl.._panel",panels[i],
                dpe+":_alert_hdl.._panel_param",params,
                dpe+":_alert_hdl.._prio_pattern",prioMin[j]+"-"+prioMax[j] );
      ds=dLs[i];
      for (k=1;k<=dynlen(ds);k++) ds[k]+=" - "+prioRange[j];
      ls=ds;
      dpSetComment(dpe,ds);
      if (dynlen(confirmDps)>0)
        dpActivateAlert( dpe, ok, true);
    }
  }

  //hook function after generating summary alarms e.g. to set panel links
  if(isFunctionDefined("HOOK_pt_generateSumAlerts"))
  { /*HOOK_pt_generateSumAlerts(
          int firstNr, //start node number
          bool toEnd,  //run generation to the end
          bool startFromPanel, //executed from panel
          int errors, //number of errors on summery alarm generation e.g. dp does not exist, or $ parameter is not given
          int iNotOwnSystem) // error, used DP is not from the own system, so i cannot be part of a summary alarm
    */
    HOOK_pt_generateSumAlerts(firstNr, toEnd, startFromPanel, errors, iNotOwnSystem);
  }

  if (startFromPanel)
  {
    closeProgressBar();
    if (errors > 0)
    {
      ChildPanelOnCentralModalReturn("vision/MessageWarning",
        getCatStr("para","warning"),makeDynString(getCatStr("sql","errorOccured")),df,ds);
      return -3;
    }
    else if ( iNotOwnSystem > 0 )
    {
      ChildPanelOnCentralModalReturn("vision/MessageInfo1",
        getCatStr("para","information"),makeDynString(getCatStr("pt","notOwnSystem")),df,ds);
      return -4;
    }
  }
  else
  {
    if (errors > 0)
    {
      string msg = "pt_generateSumAlerts:::" + getCatStr("sql","errorOccured");
      strreplace(msg, "\n", " ");
      throwError(makeError("", PRIO_WARNING, ERR_SYSTEM, 0, msg));
      return -3;
    }
    else if ( iNotOwnSystem > 0 )
    {
      string msg = "pt_generateSumAlerts:::" + getCatStr("pt","notOwnSystem");
      strreplace(msg, "\n", " ");
      throwError(makeError("", PRIO_WARNING, ERR_SYSTEM, 0, msg));
      return -4;
    }
  }

  return 0;
}


/*------------------------------------------------------------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  @name   :pt_getChilds
  @author :Pokorny, Martin
  @desc   :function to get list of child nodes (can be use also recursive)
  @notes  :
  @param  :iID[int] - root ID
  @param  :indices[dyn_uint] - list of all IDs
  @param  :parents[dyn_uint] - list of parents IDs
  @param  :bRecursive[bool] - get childs recursive (== TRUE)
  @return :dyn_int - lsit of child IDs
  @history:
    31.01.2014  Pokorny, Martin :created (for IM 113307)
  @to do  :
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/
dyn_int pt_getChilds(int iID, dyn_uint indices, dyn_uint parents, bool bRecursive)
{
  dyn_int diChilds;

  int iLen = dynlen(parents);
  for(int i=1; i<=iLen;i++)
  {
    if (iID != parents[i])
      continue;

    dynAppend(diChilds, indices[i]);

    if (bRecursive)
      dynAppend(diChilds, pt_getChilds(indices[i], indices, parents, bRecursive));
  }

  dynSort(diChilds);
  dynUnique(diChilds);
  return diChilds;
}


////////////////////////////////////////////////////////////////////////////
// searching recursively for the last child in the path
////////////////////////////////////////////////////////////////////////////
pt_getLastChild(int first, dyn_uint indices, dyn_uint parents, int &lastChild)
{
  int i;

  lastChild=first;
  for (i=first+1;i<=dynlen(indices);i++)
  {
    if (parents[i]==first)
    {
      lastChild=indices[i];
    }
  }
  if (lastChild>first)
    pt_getLastChild(lastChild, indices, parents, lastChild);
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
pt_getDownSumAlertDps(int        index,
                      dyn_uint   indices,
                      dyn_uint   parents,
                      dyn_uint   alerts,
                      dyn_string panels,
                      string     prioRange,
                      dyn_string &confirmDps)
{
  int        error,i;
  string     dpName;
  dyn_string ds;

  for (i=index+1;i<=dynlen(indices);i++)
  {
    if (parents[i]==index)
    {
      dpName=pt_fileNameToDpName(panels[i],alerts[i]);
      ds=dpNames(dpName+"."+prioRange,"_SumAlertPanel");
      dynAppend(confirmDps,ds);
    }
  }
}
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
string pt_fileNameToDpName(string fileName, int alertNo)
{
  string dpName=fileName;

  if ( strpos(dpName, ".xml") != -1 )
    strreplace(dpName,".xml","");
  else if ( strpos(dpName, ".pnl") != -1 )
    strreplace(dpName,".pnl","");
  else
  {
    int iPos = strpos(dpName,".");
    dpName = substr(dpName,0,iPos);
  }
  dpName+="_"+alertNo;
  strreplace(dpName," ","_");
  strreplace(dpName,"\\","_");
  strreplace(dpName,"/","_");

  return(dpName);
}

////////////////////////////////////////////////////////////////////////////
// checking sumalerts based on panel topology
////////////////////////////////////////////////////////////////////////////
PT_checkSumAlerts(bool        startFromPanel, // true = fct started from
                                              //   panel, open check-panel
                  bool        bLog,           // true = debug
                  bool        bDetail,        // detailed results
                  dyn_string &result)         // results in text format
{
  int            i,j,k,l,error=0,foundOK,foundNOK,tooMuch,errors=0,pos,childNotFound=0,lastChild,posFree;
  dyn_uint       indices,parents,types,menuBar,iconBar,permissions,alerts;
  dyn_langString names,description,locality,functionality,panellink;
  dyn_float      df;
  dyn_string     panels,modules,parameters,icons,
                 alertDps=dpNames("*","_SumAlertPanel"),
                 prioRanges,ds,panelAlerts,dollars,values,unexpected;
  dyn_bool       modals,centered;
  string         dp,s=getCurrentTime(),sDp;

  result=makeDynString();
  PT_log(bLog,startFromPanel,s+getCatStr("pt","check_1"),result);  // Panel sum alert check
  PT_log(bLog,startFromPanel,"",result);
  // Reading topology...
  PT_log(bLog,startFromPanel,getCatStr("pt","check_2"),result);
  pt_readTopologyDp(indices,
                    parents,
                    alerts,
                    names,
                    panels,
                    types,
                    modules,
                    icons,
                    menuBar,
                    iconBar,
                    modals,
                    centered,
                    parameters,
                    permissions,
                    description,
                    locality,
                    functionality,
                    panellink,
                    error);

  if (error<0)
  {
    if (startFromPanel)
    {
      pt_showError(error, "");
    }
    PT_log(bLog,startFromPanel,getCatStr("pt","check_3"),result); // ERROR reading panel topology - CANCELLED
   return;
  }

  // reading priority ranges
  dpGet("_SumAlertGeneral.prioRange.name:_online.._value",prioRanges);

  // checking panel sum alert hierarchy
  PT_log(bLog,startFromPanel,getCatStr("pt","check_4"),result); // Checking panel sum alert hierarchy...
  for (i=1;i<=dynlen(prioRanges);i++)
  {
    if (dpElementType("_mp__SumAlertPanel."+prioRanges[i])!=DPEL_STRING)
    {
      PT_log(bLog,startFromPanel,getCatStr("pt","check_5"),result);  // Wrong _SumAlertPanel hierarchy!
      return;
    }
  }

  PT_log(bLog,startFromPanel,"",result);
  PT_log(bLog,startFromPanel,getCatStr("pt","check_8"),result);  // Checking if all panel sumalerts and
                                                                 // all referenced DPs exist
  if (startFromPanel)
  {
    openProgressBar(getCatStr("pt","check_1"),
                    "sumalarm.gif",
                    "", "", "",
                    2);
  }

  posFree = pt_getFreeNodePosition(gPtIndices, gPtParents);

  for (i=1;i<posFree;i++)
  {
    if (startFromPanel)
    {
      sprintf(s,"%3.0f %",(1.0*i/posFree*100.0));
      showProgressBar(names[i],
                      i+"/"+posFree, s, 1.0*i/posFree*100.0);
    }
    PT_log(bLog,startFromPanel,"...'"+names[i]+"' ("+panels[i]+")",result);  // ... checking ...
    alertDps[i]=pt_fileNameToDpName(panels[i],alerts[i]);
    if (!dpExists(alertDps[i]))
    {
      errors++;
      PT_log(bLog,startFromPanel,"   "+
        getCatStr("pt","check_9")+" ("+alertDps[i]+")",result);  // ERROR - sumalert does not exist
      continue;
    }
    else
    {
      panelAlerts=makeDynString();
      pt_splitDollars(parameters[i], dollars, values);
      // reading panel sum alerts
      j=getConfirmDps(panels[i], panelAlerts, dollars, values);
      pt_decodePanelAlerts(panelAlerts);
      l=0;
      for (k=dynlen(panelAlerts);k>0;k--)
      {
        sDp=dpSubStr(panelAlerts[k],DPSUB_DP_EL);
        if (!dpExists(sDp))
        {
          PT_log(bLog,startFromPanel,"   "+
            getCatStr("para","dpnotexists")+" '"+panelAlerts[k]+"'",result);  // ERROR - dp does not exist
          dynRemove(panelAlerts,k);
        }
        else
          if ( dpTypeName(dpSubStr(sDp,DPSUB_DP)) != "_SumAlertPanel" )
            dynRemove(panelAlerts,k);
      }
    }

    pt_getLastChild(i, indices, parents, lastChild);
    unexpected=panelAlerts;
    for (j=i+1;j<=lastChild;j++)
    {
      s=pt_fileNameToDpName(panels[j],alerts[j])+".";
      for (k=1;k<=dynlen(prioRanges);k++)
      {
        if ( parents[j]==i )
        {
          if ( dynContains(panelAlerts,s+prioRanges[k])<1 )
          {
            errors++;  // ! ERROR - child sumalert not found
            PT_log(bLog,startFromPanel,"   "+
              getCatStr("pt","check_11")+" '"+names[j]+"'",result);
            break;
          }
          else
          {
            // right use of sumalert
            dynRemove(unexpected,dynContains(unexpected,s+prioRanges[k]));
          }
        }
      }
    }
    for (j=1;j<=dynlen(unexpected);j++)
    {
      errors++;  // ! ERROR - unexpected use of sumalert in
      PT_log(bLog,startFromPanel,"   "+
        getCatStr("pt","check_13")+": '"+unexpected[j]+"'",result);
    }
  }

  if (startFromPanel)
  {
    closeProgressBar();
  }
  s=getCurrentTime();
  PT_log(bLog,startFromPanel,"",result);

  if (errors>0)
  {
    PT_log(bLog,startFromPanel,s+getCatStr("pt","check_18"),result);  // Ready, ERROR
    ChildPanelOnCentralModalReturn("vision/MessageWarning",
      getCatStr("para","warning"),makeDynString(getCatStr("pt","check_19")),df,ds);
  }
  else
  {
    PT_log(bLog,startFromPanel,s+getCatStr("pt","check_20"),result);  // Ready, OK
  }
  PT_log(bLog,startFromPanel,"--------------------------------------------------------------",result);
}

////////////////////////////////////////////////////////////////////////////
// 1. Alle Alarme mit PVSS00ascii holen
// 2. Alle _SumAlertPanel's beginnend main.pnl rekursiv holen
// 3. sort, unique
// 4. Vergleich in beiden Richtungen in einer Schleife!
////////////////////////////////////////////////////////////////////////////
PT_checkAllAlerts(bool        startFromPanel, // true = fct started from
                                              //   panel, open check-panel
                  bool        bLog,           // true = debug
                  bool        bDetail,        // detailed results
                  dyn_string &result)         // results in text format
{
  int            i,j,k,l,error=0,errors=0,pos,iNotExist=0,iNotAlert=0,
                 typePos,activePos,firstPos,iType,confLength=0;
  int            elementPos;//IM 108043
  bool           bSum,bNotExist=false,bNotAlert=false,bNotUsed=false,bActive;
  dyn_float      df;
  dyn_uint       alertNo;
  dyn_string     allAlerts,panelNames,fileNames,alertDps,allPanelAlerts=makeDynString(),prioRanges,
                 sumAlerts=makeDynString(),ds,sums;
  string         dp,s=getCurrentTime(),sDp,sNotExist,sNotAlert,
                 tmpFileName=tmpnam(),sRecord,s1,s2,startSum="",ss1,ss2;
  dyn_dyn_anytype tab;
  file           fd;

  result=makeDynString();
  PT_log(bLog,startFromPanel,s+getCatStr("pt","check_31"),result);  // Checking all alerts <==> panel sum alerts
  PT_log(bLog,startFromPanel,"",result);
  PT_log(bLog,startFromPanel,getCatStr("pt","check_32"),result); // Reading alert datapoints...

  // reading panel sum alerts and panel names

  pt_checkPanelTopologyCache();

  alertNo = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.sumAlertNumber:_online.._value"];
  panelNames = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.nodeName:_online.._value"];
  fileNames = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.fileName:_online.._value"];

  dpGet("_SumAlertGeneral.prioRange.name:_online.._value",prioRanges);

  // sum alert name of the startpanel
  if (fileNames[1]!="") startSum=pt_fileNameToDpName(fileNames[1],alertNo[1]);

  // reading all active alerts (excepting internal dps)
  // writing into temporary file
  if (_WIN32)
    system(getPath(BIN_REL_PATH,getComponentName(ASCII_COMPONENT)+".exe") + " -out "+tmpFileName+
           " -filter P:_alert_hdl -filterDp **;");
  else
    system(getPath(BIN_REL_PATH,getComponentName(ASCII_COMPONENT)) + " -out "+tmpFileName+
           " -filter P:_alert_hdl -filterDp '**;'");

  fd=fopen(tmpFileName,"r");
  if (fd<=0)
  {
    return;
  }

  if (startFromPanel)
  {
    openProgressBar(getCatStr("pt","check_21"),
                    "sumalarm.gif",
                    "", "", "",
                    1);
  }
  // reading temporary file
  i=0; j=0; firstPos=65535;
  while (!feof(fd))
  {
    fgets(sRecord,65535,fd);
    i++;
    if (strpos(sRecord,"ElementName") >= 0)//IM 108043 seit 3.11 steht im Ascii File
//                                           # AlertValue
//                                           Manager/User	ElementName	...usw...
    {
      // finding position for '_type' and '_active'
      firstPos=i;
      ds=strsplit(sRecord,"\t");
      typePos=dynContains(ds,"_alert_hdl.._type");
      activePos=dynContains(ds,"_alert_hdl.._active");
      elementPos=dynContains(ds,"ElementName");//IM 108043
    }
    else
    if ( strltrim(strrtrim(sRecord))=="" || strpos(sRecord,"#")==0 ) // empty or comment
    {
      continue;
    }
    else
    if (i>firstPos)
    {
      ds=strsplit(sRecord,"\t");
      if (dynlen(ds)<typePos || dynlen(ds)<activePos) // CR in text
      {
        s="";
        if (dynlen(ds)>0)
        {
          s="'"+ds[1]+"'";
          if (dpExists(dpSubStr(ds[elementPos],DPSUB_DP)))//IM 108043
          {
            s+=" (DPT: "+dpTypeName(ds[elementPos])+")";//IM 108043
          }
        }
        PT_log(bLog,startFromPanel,getCatStr("pt","check_6")+s,result); // CR in text
        iType=0;
      }
      else
      if ( //dynlen(ds) >= typePos && dynlen(ds) >= activePos &&
           strpos(dpSubStr(ds[elementPos],DPSUB_DP_EL),"_") != 0 || "_TmpBitAlert" == dpSubStr(ds[elementPos],DPSUB_DP)) // intern dps not needed
      {
        // getting '_type' and '_active'
        iType=ds[typePos];
        bActive=ds[activePos];
      }
      else
      {
        iType=0;
      }
                                  // sum alert name of the startpanel not needed
      if ( iType!=0 && bActive && dpSubStr(ds[elementPos],DPSUB_DP)!=startSum)
      {
        j++;
        allAlerts[j]=dpSubStr(ds[elementPos],DPSUB_DP_EL);
        if (startFromPanel)
        {
          showProgressBar("", allAlerts[j],"", -1);
        }
      }
    }
  }
  fclose(fd);
  remove(  tmpFileName);
  dynSortAsc(allAlerts);
  dynUnique(allAlerts);
  PT_log(bLog,startFromPanel,"",result);

  if (startFromPanel)
  {
    closeProgressBar();
    while ( isModuleOpen("ProgressBar") )
    {
      delay(0,500);
    }
    openProgressBar(getCatStr("pt","check_21"),
                    "sumalarm.gif",
                    "", "", "",
                    2);
  }
  // getting all alerts from panel sum alerts
  allPanelAlerts=makeDynString();
  PT_log(bLog,startFromPanel,getCatStr("pt","check_2"),result); // Reading topology...
  // is topology defined?
  if (fileNames[1]!="" && startSum!="")
  {
    // reading all alerts from the topology recursively
    dyn_string dsErrors = makeDynString();
    for (i=1; i<=dynlen(prioRanges);i++)
    {
      dynAppend(dsErrors, pt_getAllAlertsInTopology(startSum+"."+prioRanges[i],allPanelAlerts,sums,startFromPanel));
    }
    if (dynlen(dsErrors)>0)
    {
      for ( i=1; i<=dynlen(dsErrors); i++)
          PT_log(bLog,startFromPanel, dsErrors[i], result); // sum alarms don't include alarms
    }

    dynSortAsc(allPanelAlerts);
    dynUnique(allPanelAlerts);
  }

  PT_log(bLog,startFromPanel,"",result);

  // checking alerts
  i = 1;j = 1;
  l = ( dynlen(allAlerts) > dynlen(allPanelAlerts) ) ? dynlen(allAlerts) : dynlen(allPanelAlerts);

  while ( true )
  {
    if (startFromPanel)
    {
      if ( dynlen(allAlerts) > dynlen(allPanelAlerts) && i <= dynlen(allAlerts) )
      {
        k = i;
        ss1 = allAlerts[i];
      }
      else
      if ( j <= dynlen(allPanelAlerts) )
      {
        k = j;
        ss1 = allPanelAlerts[j];
      }
      sprintf(s,"%3.0f %",(1.0*k/l*100.0));
      showProgressBar(ss1,
                      k+"/"+l, s, 1.0*k/l*100.0);
    }
    if (i <= dynlen(allAlerts) )
    {
      s1 = allAlerts[i];
      if (dpSubStr(s1, DPSUB_DP)=="_TmpBitAlert")
      {
        i++;
        continue;
      }
    }
    else
      s1 = "";
    if (j <= dynlen(allPanelAlerts) )
      s2 = allPanelAlerts[j];
    else s2 = "";

    if ( s1 != "" && s1 == s2 )
    {
      i++; j++;
    }
    else if ( s1 != "" && (pt_compareStrings(s1,s2) == -1 || s2 == "") ) // s1 < s2
    {
      // ERROR - alert not used in sum alerts
      PT_log(bLog,startFromPanel,"   "+getCatStr("pt","check_40")+"'"+s1+"' (DPT: "+dpTypeName(s1)+")",result);
      errors++;
      i++;
    }
    else if ( s2 != "" && (pt_compareStrings(s1,s2) == 1 || s1 == "") ) // s1 > s2
    {
      // ERROR - used datapoint does not exist or isn't an (active) alert
      PT_log(bLog,startFromPanel,"   "+getCatStr("pt","check_35")+"'"+s2+"' (DPT: "+dpTypeName(s2)+")",result);
      errors++;
      j++;
    }
    else
    {
      i++; j++;
    }

    if ( i > dynlen(allAlerts) && j > dynlen(allPanelAlerts) )
      break;
  }

  if (startFromPanel)
  {
    closeProgressBar();
  }
  s=getCurrentTime();
  PT_log(bLog,startFromPanel,"",result);

  if (errors>0)
  {
    PT_log(bLog,startFromPanel,s+getCatStr("pt","check_18"),result);  // Ready, ERROR
    ChildPanelOnCentralModalReturn("vision/MessageWarning",
      getCatStr("para","warning"),makeDynString(getCatStr("pt","check_19")),df,ds);
  }
  else
  {
    PT_log(bLog,startFromPanel,s+getCatStr("pt","check_20"),result);  // Ready, OK
  }
  PT_log(bLog,startFromPanel,"--------------------------------------------------------------",result);
}

/////////////////////////////////////////////
// Language dependent compare of two strings
// Return value: -1: s1 <  s2
//                0: s1 == s2
//                1: s1 >  s2
/////////////////////////////////////////////
int pt_compareStrings(string s1, string s2)
{
  dyn_string ds = makeDynString(s1,s2);

  if ( s1 == s2 )
    return (0);  // s1 == s2
  dynSortAsc(ds);
  if ( dynContains(ds,s1) == 1)
    return (-1); // s1 < s2
  else
    return (1);  // s1 > s2
}
////////////////////////////////////////////////////////////////////////////
// Reading all alerts in the whole topology recursively
////////////////////////////////////////////////////////////////////////////
dyn_string pt_getAllAlertsInTopology(string s, dyn_string &panelAlerts, dyn_string &sums, bool startFromPanel)
{
  int         i,j,iType;
  dyn_anytype iTypes;
  dyn_string  ds,alerts,dps;
  string sPattern;
  dyn_string dsErrors=makeDynString();

  if (startFromPanel)
  {
    showProgressBar("","", s, -1);
  }
  // reading alerts included in sumalert
  dpGet(s+":_alert_hdl.._dp_list",ds);

  if (dynlen(ds)==0) //if no DP-List is given, it is dp_pattern
  {
    dpGet(s+":_alert_hdl.._dp_pattern", sPattern);

    if (sPattern!="" && sPattern!="*" && sPattern!="**")
      ds = dpNames(sPattern);
  }

  // getting type of alerts
  for (j=1;j<=dynlen(ds);j++)
  {
    dps[j]=ds[j]+":_alert_hdl.._type";
  }
  if (dynlen(dps)!=0)
  {
    dpGet(dps,iTypes);
  }
  else // no alarm included in sum alarm
  {
    dynAppend(dsErrors, "   " + getCatStr("pt", "emptySumAlert")+": '"+s+"' "+ getCatStr("pt", "pattern") +" "+sPattern);
  }


  // processing alerts
  for (j=1;j<=dynlen(ds);j++)
  {
    // if sumalert and not yet processed
    if (iTypes[j]==DPCONFIG_SUM_ALERT && dynContains(sums,ds[j]) < 1) // is a sum alert?
    {
      // alert is a sumalert and not yet processed
      dynAppend(sums,ds[j]);
      // recursive decoding of sumalerts
      dynAppend(dsErrors, pt_getAllAlertsInTopology(dpSubStr(ds[j],DPSUB_DP_EL),panelAlerts,sums,startFromPanel));
    }
    else
    {
      // alert is not a sumalert
      dynAppend(panelAlerts,dpSubStr(ds[j],DPSUB_DP_EL));
    }
  }
  return dsErrors;
}

////////////////////////////////////////////////////////////////////////////
// bLog           == true - writing messages also into the log file
// startFromPanel == true - appending message lines into the table of PT_sumAlertCheck.pnl
// text                   - message text
// result                 - all message lines in a dyn_string
////////////////////////////////////////////////////////////////////////////
PT_log(bool bLog, bool startFromPanel, string text, dyn_string &result)
{
  if (bLog && text!="")
    DebugN(getCurrentTime()," PT: "+text);
  if (startFromPanel)
  {
    tblLog.appendLine("#1",text);
    lstLog.appendItem(text); lstLog.bottomPos(0);
    delay(0,100);
  }
  dynAppend(result,text);
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
unsigned pt_getSumAlertNumber(string fileName)
{
  unsigned aNo=0,i,posFile;

  for (i=1;i<=dynlen(gPtPanels);i++)
  {
    if (gPtPanels[i]==fileName && gPtAlerts[i]>aNo)
        aNo=gPtAlerts[i];
  }
  aNo++;
  return(aNo);
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
pt_initPanelOnButton(bool showIcon,
                     string iconShape = "",
                     dyn_string objectsEnDis = makeDynString()) //dynClear(objectsEnDis))
{
  int            i,pos=0,pNr=$panelNumber,refNr=$refNumber;
  string         pNa=$panelName, dpe;
  dyn_int        alertNumber,diPanelNumber;
  dyn_string     ds,fileName,dsFileName,prioRanges;
  dyn_langString dls;

  //**** mhalper
  dyn_int        diPermissionBits;
  dyn_langString dlsToolTips;
  //****

  pt_checkPanelTopologyCache();

  fileName = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.fileName:_online.._value"];
  alertNumber = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.sumAlertNumber:_online.._value"];
  dls = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.nodeName:_online.._value"];
  ds = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.iconName:_online.._value"];
  diPermissionBits = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.permissionBit:_online.._value"];
  dlsToolTips = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.description:_online.._value"];

  dpGet("_PTPanelOn.fileName:_online.._value",dsFileName,
        "_PTPanelOn.panelNumber:_online.._value",diPanelNumber,
        "_SumAlertGeneral.prioRange.name:_online.._value",prioRanges);

  if (refNr>0 && refNr<=dynlen(dsFileName))
  {
    pNa=dsFileName[refNr];
    pNr=diPanelNumber[refNr];
  }
  pos=pt_getTopologyNumber(fileName,alertNumber,pNa,pNr);

  // set text
  if (pos<1 || pNa=="" || pNr<1)
  {
    if ( refNr > 0 ) // sumX
      dpConnect("pt_manageAccess","_PTPanelOn.fileName:_online.._value",
                                  "_PTPanelOn.panelNumber:_online.._value");
    this.text=""; return;
  }

  if (this.name=="txtPanelOn")
    this.text=" "+dls[pos];
  else if (this.name=="cmdPanelOn") //**** mhalper: do not write a text on the button if an icon used used
  {
    if (ds[pos]!="")
      this.text="";
    else
      this.text=dls[pos];
  }
  else
    this.text=dls[pos];

  if (showIcon) // show icon
  {
    if (ds[pos]!="")
    {
      //**** mhalper: include user bits
      if (getUserPermission(diPermissionBits[pos]))
        pt_initPanelOnButton_grap_obj(TRUE, iconShape, "any", ds[pos], dlsToolTips[pos], objectsEnDis);
      else
      {
        if (strreplace(ds[pos], "_enabled.", "_disabled.") < 0)
        {
          if (strreplace(ds[pos], "_en.", "_dis.") < 0);
        }
        pt_initPanelOnButton_grap_obj(FALSE, iconShape, "any", ds[pos], dlsToolTips[pos], objectsEnDis);
      }
      //****
    }
  }

  if ( refNr > 0 ) // sumX
    dpConnect("pt_manageAccess","_PTPanelOn.fileName:_online.._value",
                                "_PTPanelOn.panelNumber:_online.._value");
  else // not sumX
  {
    for (i=1;i<=dynlen(prioRanges);i++)
    {
      dpe=pt_fileNameToDpName(pNa,pNr)+"."+prioRanges[i]+":_alert_hdl.._act_state_color";
      if (dpExists(dpe))
      {
        dpConnect("pt_setBackColorCB", true,dpe);
      }
    }

  }

}
pt_manageAccess(string dp1, dyn_string dsFileName, string dp2, dyn_int diPanelNumber)
{
  int    i,refNr=$refNumber,iDummy;
  string dpe;
  dyn_string prioRanges;

  dpGet("_SumAlertGeneral.prioRange.name:_online.._value",prioRanges);
  if (ptOldFileName!=dsFileName || ptOldPanelNumber!=diPanelNumber)
  {
    for (i=1;i<=dynlen(prioRanges);i++)
    {
      if (dynlen(ptOldFileName)>=refNr && ptOldFileName[refNr]!="" &&
          dynlen(ptOldPanelNumber)>=refNr && ptOldPanelNumber[refNr]!=0 &&
          dynlen(ptAlertDone)>=i && ptAlertDone[i])
      {
        dpe=pt_fileNameToDpName(ptOldFileName[refNr],ptOldPanelNumber[refNr])+"."+prioRanges[i]+":_alert_hdl.._act_state_color";
        if (dpExists(dpe))
        {
          iDummy=dpDisconnect("pt_setBackColorCB", dpe);
          setValue("sum"+i,"backCol","_3DFace");
          ptAlertDone[i]=false;
        }
      }
      if (dsFileName[refNr]!="" &&  diPanelNumber[refNr]!=0 && (dynlen(ptAlertDone)<i || !ptAlertDone[i]))
      {
        dpe=pt_fileNameToDpName(dsFileName[refNr],diPanelNumber[refNr])+"."+prioRanges[i]+":_alert_hdl.._act_state_color";
        if (dpExists(dpe))
        {
          dpConnect("pt_setBackColorCB", true, dpe);
          ptAlertDone[i]=true;
        }
      }
    }
    ptOldFileName=dsFileName; ptOldPanelNumber=diPanelNumber;
  }
}

pt_initPanelOnButton_grap_obj(bool enDis, string iconShape, string s, string ds, string dlsToolTip, dyn_string objectsEnDis)
{
  int i;

  if (enDis == TRUE)
  {
    setValue(iconShape,"fill","[pattern,[tile,any,"+ds+"]]",
                    "enabled", enDis,
                    "toolTipText", dlsToolTip);
  }
  else
  {
    setValue(iconShape,"enabled", enDis,
                    "toolTipText", dlsToolTip);
  }

  if (dynlen(objectsEnDis) >= 1)
  {
    for (i = 1; i <= dynlen(objectsEnDis); i++)
    {
      setValue(objectsEnDis[i],"enabled",enDis,
                               "toolTipText", dlsToolTip);
    }
  }
}

////////////////////////////////////////////////////////////////////////////
pt_setBackColorCB(string dpSource, string sNewColor)
{
  int        refNr=$refNumber,sumNr;
  string     s;
  dyn_string ds=strsplit(dpSource,":"), prioRanges;

  dpGet("_SumAlertGeneral.prioRange.name:_online.._value",prioRanges);
  dpSource=dpSubStr(dpSource,DPSUB_SYS_DP_EL_CONF_DET_ATT);
  ds=strsplit(dpSource,":"); s=ds[2];
  ds=strsplit(s,"."); s=ds[2]; sumNr=dynContains(prioRanges,s);

  if (shapeExists("sum"+sumNr))
  setValue("sum"+sumNr,"backCol",sNewColor);
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
pt_changePara(int refNr,bool showIcon=false)
{
  int            i,pos=0,pNrOld,pNr,error=0,sumNr;
  string         pNaOld,pNa,refName,dpe,dpeOld;
  dyn_int        alertNumber,diPanelNumber,diPanelNumberOld;
  dyn_float      df;
  dyn_string     icons,fileName,prioRanges,ds,dollars,values,params,oldParams,dss,
                 dsFileName,dsFileNameOld;
  dyn_langString dls;

  pt_checkPanelTopologyCache();

  fileName = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.fileName:_online.._value"];
  alertNumber = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.sumAlertNumber:_online.._value"];
  dls = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.nodeName:_online.._value"];
  icons = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.iconName:_online.._value"];

  dpGet("_PTPanelOn.fileName:_online.._value",dsFileName,
        "_PTPanelOn.panelNumber:_online.._value",diPanelNumber,
        "_SumAlertGeneral.prioRange.name:_online.._value",prioRanges);

  if (refNr<1 || refNr>dynlen(dsFileName))
  {
    error=-101;
    pt_showError(error, "");
    return;
  }
  dsFileNameOld=dsFileName;
  diPanelNumberOld=diPanelNumber;
  refName="sum"+refNr;
  pNaOld=dsFileName[refNr]; pNrOld=diPanelNumber[refNr];
  dpeOld=pt_fileNameToDpName(pNaOld,pNrOld);
  params[1]="$refNumberForOnlinePara:"+refNr;
  params[2]="$panelName:"+dsFileName[refNr];
  params[3]="$panelNumber:"+diPanelNumber[refNr];
  for (i=1;i<=dynlen(prioRanges);i++)
    params[i+3]="$"+i+":"+prioRanges[i];
  oldParams=params;

  // calling para panel
  ChildPanelOnCentralModalReturn("objects_parampanels/STD_PANELS/PTSumAlert_para.pnl",
    getCatStr("pt","onlinepara"),oldParams,df,params);

  dynRemove(oldParams,1);
  // clear sum button
  if (dynlen(params)<1)
  {
    setValue(refName+".cmdPanelOn","text","");
    setValue(refName+".cmdPanelOn","buttonType",BT_TEXT);
    pNa="";pNr=0;
  }
  else
  {
    ds=strsplit(params[1],":");
    pNa=(dynlen(ds)>1)?ds[2]:"";
    ds=strsplit(params[2],":");
    pNr=(dynlen(ds)>1)?ds[2]:"";
  }
  // no changes
  if (pNa==pNaOld && pNr==dpeOld) return;

  dsFileName[refNr] = pNa;
  diPanelNumber[refNr] = pNr;
  dpSet("_PTPanelOn.fileName:_original.._value",dsFileName,
            "_PTPanelOn.panelNumber:_original.._value",diPanelNumber);

  pos=pt_getTopologyNumber(fileName,alertNumber,pNa,pNr);
  if (pos<1)
  {
    setValue(refName+".cmdPanelOn","text","");
  }
  else
  {
    setValue(refName+".cmdPanelOn","text",dls[pos]);
    if (!showIcon) return; // don't show icon

    if (icons[pos]!="")
    {
      setValue(refName+".cmdPanelOn","buttonType",BT_PIXMAP);
      if (strpos(icons[pos],".bmp")>0) //
        setValue(refName+".cmdPanelOn","fill","[pattern,[tile,bmp,"+icons[pos]+"]]");
      else
      if (strpos(icons[pos],".xpm")>0)
        setValue(refName+".cmdPanelOn","fill","[pattern,[tile,xpm,"+icons[pos]+"]]");
      else
      if (strpos(icons[pos],".gif")>0)
        setValue(refName+".cmdPanelOn","fill","[pattern,[tile,gif,"+icons[pos]+"]]");
    }
    else
      setValue(refName+".cmdPanelOn","buttonType",BT_TEXT);
  }
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
int pt_getTopologyNumber(dyn_string fileName,dyn_int alertNumber,string pNa,int pNr)
{
  int pos=0,i;

  for (i=1;i<=dynlen(fileName);i++)
  {
    if (fileName[i]==pNa && alertNumber[i]==pNr)
    {
      pos=i; break;
    }
  }
  return(pos);
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
pt_updateSumAlertPanel(string fileName) // fileName including relative path
{
  int        pos, j;
  string     param;
  dyn_string dsFileName, paramsPanel, parameters, ds1, ds2, paramsDp, valuesDp;
  dyn_string dsDollars, dsValues;

  if (!isEvConnOpen ())
    return;

  addGlobal("gPtCalledFromNativeGedi", BOOL_VAR); gPtCalledFromNativeGedi = true;
  strreplace(fileName,"\\","/");

  if (useSVN() && isFunctionDefined("SVN_savePanel"))
  {
    DebugFN("SVN", "about to call SVN savePanel");
    SVN_savePanel(fileName);
  }

  pt_checkPanelTopologyCache();

  parameters = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.parameter:_online.._value"];
  dsFileName = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.fileName:_online.._value"];

  for (pos=1;pos<=dynlen(dsFileName);pos++)
  {
    strreplace(dsFileName[pos],"\\","/");

    // is the panel in the topology?
    if (dsFileName[pos]==fileName) // yes
    {
      // creating sum alerts
      pt_generateSumAlerts(pos, false, false);

      // updating $-parameters
      paramsPanel=pt_getDollarParams(dsFileName[pos]);

      pt_splitDollars( parameters[pos], dsDollars, dsValues);

      for (j=dynlen( dsDollars); j>0; j--)
      {
         if (dynContains(  paramsPanel, dsDollars[j] ) < 1)
         {
            dynRemove( dsDollars, j);
            dynRemove( dsValues, j);
         }
      }

      for (j=dynlen( paramsPanel); j>0; j--)
      {
         if (dynContains(  dsDollars, paramsPanel[j] ) < 1)
         {
            dsDollars[dynlen(dsDollars)+1] = paramsPanel[j];
            dsValues[dynlen(dsDollars)] = "";
         }
      }

      param="";
      for (j=1;j<=dynlen(dsDollars);j++)
      {
        param+=dsDollars[j]+":"+dsValues[j];
      }

      param= strrtrim(strltrim(param));

      parameters[pos]=param;
    }

  }
  dpSet("_PanelTopology.parameter:_original.._value",parameters);
  removeGlobal("gPtCalledFromNativeGedi");
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
pt_removeSumAlertPanel(string fileName) // fileName including relative path
{
  int        pos;
  string     s,dpName;
  dyn_uint   duSumAlertNumber;
  dyn_string dsFileName;

  strreplace(fileName,"\\","/");

  // Call the hook function, if it exists
  if (useSVN() && isFunctionDefined("SVN_removePanel"))
  {
    DebugFN("SVN", "about to call SVN removePanel");
    SVN_removePanel(fileName);
  }

  pt_checkPanelTopologyCache();

  dsFileName = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.fileName:_online.._value"];
  duSumAlertNumber = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.sumAlertNumber:_online.._value"];

  for (pos=1;pos<=dynlen(dsFileName);pos++)
  {
    s=strreplace(dsFileName[pos],"\\","/");
    if (dsFileName[pos]==fileName)
    {
      dpName=pt_fileNameToDpName(dsFileName[pos],duSumAlertNumber[pos]);
      dpDelete(dpName);
    }
  }
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
pt_sumParaAtRightClick(int refNr, bool bIcon)
{
  int        answer = 0;
  dyn_string popup;

  string snum;
  string myMod = myModuleName();
  pt_moduleNumber(myMod,snum);

  // object not in navigation module
  if (myMod!="naviModule") return;

  if (isMotif())
  {
    dyn_float  df;
    dyn_string ds;

    ChildPanelOnRelativModal("vision/MessageWarning",
      getCatStr("para","warning"),
      makeDynString(getCatStr("pt","ismotif")),0,0,df,ds);
    return;
  }

  popup = makeDynString("PUSH_BUTTON", + getCatStr("STD_Symbols","properties") + ", 1, "
                                       + (getUserPermission(4)?"1":"0"));
  popupMenu(popup, answer);

  switch (answer)
  {
    case 1: pt_changePara(refNr,bIcon);
            break;
  }
}

////////////////////////////////////////////////////////////////////////////
// Decoding function 'pt_fileNameToDpName' in acknowledge script
// of the PT_sumX.pnl objects
////////////////////////////////////////////////////////////////////////////
pt_decodePanelAlerts( dyn_string &dps )
{
  int        i, j, pos;
  string     sDpe, sPName, sScript, s;
  dyn_string ds;

  for ( j = dynlen(dps); j > 0 ; j--)
  {
    if ( strpos(dps[j],"pt_fileNameToDpName") == 0)
    {
      sDpe = substr(dps[j], strpos(dps[j],")") + 1, strlen(dps[j]) - strpos(dps[j], ")") - 1);
      s = substr(dps[j],strpos(dps[j], "(") + 1, strpos(dps[j],")") - strpos(dps[j], "(") - 1);
      ds = strsplit( s, "," );
      if ( dynlen(ds) > 0 ) sPName = ds[1];
      if ( sPName == "" )
      {
        dynRemove(dps,j);
        continue;
      }
      sScript = substr(dps[j], 0 ,strpos(dps[j], ")") + 1);
      strreplace(sScript, sPName, "\"" + sPName + "\"");
      sScript = "string main(){ string s; s = " + sScript + "; return(s);}";
      evalScript( s, sScript, makeDynString() );
      dps[j] = s + sDpe;
    }
  }
}

////////////////////////////////////////////////////////////////////////////
PT_panelOnFromTopology()
{
  ChildPanelOnCentralModal("para/PanelTopology/PT_navigation.pnl","PT-PanelOn",makeDynString());
}

////////////////////////////////////////////////////////////////////////////
// STANDARD PANELS - START
////////////////////////////////////////////////////////////////////////////
// ============================================================================
// pt_init_PT_sumX() - event init sum1-sum3 button
// ============================================================================
pt_init_PT_navi_sumX(string sumX)
{
  dpConnect("manageAccess_init_PT_navi_sumq", TRUE, myUiDpName()+".UserName:_online.._value",
                                                    "_PanelTopology.permissionBit:_online.._value",
                                                    "_PTPanelOn.fileName:_online.._value");
}
// ============================================================================
// pt_init_PT_sum4() - event init sum quit button
// ============================================================================
pt_init_PT_sum4()
{
  dpConnect("manageAccess_init_PT_sum4", TRUE, myUiDpName()+".UserName:_online.._value",
                                               "_PanelTopology.permissionBit:_online.._value",
                                               "_PTPanelOn.fileName:_online.._value");
}

manageAccess_init_PT_sum4(string dp1, string UserName,
                          string dp2, dyn_string permissionBits,
                          string dp3, dyn_string filenames)
{
  dyn_string objectsEnDis;

  dynAppend(objectsEnDis, "sum1");
  dynAppend(objectsEnDis, "sum2");
  dynAppend(objectsEnDis, "sum3");
  dynAppend(objectsEnDis, "txtPanelOn");

  pt_initPanelOnButton(TRUE, "icon", objectsEnDis);
}
// ============================================================================
// pt_init_PT_navi_sumq() - event init sum quit button
// ============================================================================
pt_init_PT_navi_sumq()
{
  dpConnect("manageAccess_init_PT_navi_sumq", TRUE, myUiDpName()+".UserName:_online.._value",
                                                    "_PanelTopology.permissionBit:_online.._value",
                                                    "_PTPanelOn.fileName:_online.._value");
}

manageAccess_init_PT_navi_sumq(string dp1, string UserName,
                               string dp2, dyn_string permissionBits,
                               string dp3, dyn_string filenames)
{
  pt_initPanelOnButton(TRUE);
}

// ============================================================================
// pt_init_PT_navi_vt() - event init variable trend button
// ============================================================================
pt_init_PT_navi_vt()
{
  dpConnect("manageAccess_init_PT_navi_vt",myUiDpName()+".UserName:_online.._value",
                                           "_PanelTopology.permissionBit:_online.._value");
}

manageAccess_init_PT_navi_vt(string dp1, string UserName,
                             string dp2, dyn_string permissionBits)
{
  int            pos;
  dyn_string     filenames;
  dyn_langString dlsToolTips;

  pt_checkPanelTopologyCache();

  filenames = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.fileName:_online.._value"];
  dlsToolTips = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.nodeName:_online.._value"];

  pos = dynContains(filenames, "vision/trend/VT_trend.pnl");

  if (pos > 0)
  {
/*
    if (getUserPermission(permissionBits[pos]))
      pt_init_PT_navi_vt_TRUE();
    else
      pt_init_PT_navi_vt_FALSE();
*/
    setValue("","enabled", getUserPermission(permissionBits[pos]));
    this.toolTipText(dlsToolTips[pos]);
  }
  else
  {
/*
  if (getUserPermission(2))
    pt_init_PT_navi_vt_TRUE();
  else
    pt_init_PT_navi_vt_FALSE();
*/
    setValue("","enabled", getUserPermission(2));
  }
}

pt_init_PT_navi_vt_TRUE()
{
//  if (dpExists("ApplicationProperties"))
    setValue("","fill","[pattern,[tile,gif,trend_enabled.gif]]",
                "enabled", true);
//  else
//    setValue("","fill","[pattern,[tile,bmp,trend_red_enabled.bmp]]",
//                "enabled", true);
}

pt_init_PT_navi_vt_FALSE()
{
//  if (dpExists("ApplicationProperties"))
    //setValue("","fill","[pattern,[tile,gif,icons/trend_disabled.gif]]",
    setValue("","enabled", false);
//  else
//    //setValue("","fill","[pattern,[tile,bmp,trend_red_disabled.bmp]]",
//    setValue("","enabled", false);
}

// ============================================================================
// pt_init_PT_navi_sm() - event init system management button
// ============================================================================
pt_init_PT_navi_sm()
{
  dpConnect("manageAccess_init_PT_navi_sm",myUiDpName()+".UserName:_online.._value");
}

manageAccess_init_PT_navi_sm(string dp1, string UserName)
{
/*
  if (dpExists("ApplicationProperties"))
  {
    if (getUserPermission(3))
      setValue("","fill","[pattern,[tile,gif,sysmgm_enabled.gif]]",
               "enabled", true);
    else
      //setValue("","fill","[pattern,[tile,gif,icons/sysmgm_disabled.gif]]",
      setValue("","enabled", false);
  }
  else
  {
    if (getUserPermission(3))
      setValue("","fill","[pattern,[tile,bmp,sysmgm_enabled.bmp]]",
               "enabled", true);
    else
      //setValue("","fill","[pattern,[tile,bmp,sysmgm_disabled.bmp]]",
      setValue("","enabled", false);
  }
*/
  setValue("","enabled", getUserPermission(3));
}

// ============================================================================
// pt_init_PT_navi_hq() - event init horn acknowledge button
// ============================================================================
pt_init_PT_navi_hq()
{
  dpConnect("manageAccess_init_PT_navi_hq",myUiDpName()+".UserName:_online.._value");
}

manageAccess_init_PT_navi_hq(string dp1, string UserName)
{
/*
  if (dpExists("ApplicationProperties"))
  {
    if (getUserPermission(3))
      setValue("","fill","[pattern,[tile,gif,horn_ack_enabled.gif]]",
               "enabled", TRUE);
    else
      //setValue("","fill","[pattern,[tile,gif,icons/horn_ack_disabled.gif]]",
      setValue("","enabled", FALSE);
  }
  else
  {
    if (getUserPermission(3))
      setValue("","fill","[pattern,[tile,gif,icons/horn_ack_enabled.gif]]",
                 "enabled", TRUE);
    else
      //setValue("","fill","[pattern,[tile,gif,icons/horn_ack_disabled.gif]]",
      setValue("","enabled", FALSE);
  }
*/
  setValue("","enabled", getUserPermission(3));
}

// ============================================================================
// pt_init_PT_navi_hlp() - event init help button
// ============================================================================
pt_init_PT_navi_hlp()
{
  dpConnect("manageAccess_init_PT_navi_hlp",myUiDpName()+".UserName:_online.._value");
}

manageAccess_init_PT_navi_hlp(string dp1, string UserName)
{
/*
  if (dpExists("ApplicationProperties"))
  {
    if (getUserPermission(1))
     setValue("","fill","[pattern,[tile,gif,help_enabled.gif]]",
              "enabled", TRUE);
   else
     //setValue("","fill","[pattern,[tile,gif,icons/help_disabled.gif]]",
     setValue("","enabled", FALSE);
  }
  else
  {
    if (getUserPermission(1))
      setValue("","fill","[pattern,[tile,bmp,help_32x32_enabled.bmp]]",
               "enabled", TRUE);
    else
      //setValue("","fill","[pattern,[tile,bmp,help_32x32_disabled.bmp]]",
      setValue("","enabled", FALSE);
  }
*/
  setValue("","enabled", getUserPermission(1));
}

// ============================================================================
// pt_init_PT_navi_gq() - event init common acknowledge button
// ============================================================================
pt_init_PT_navi_gq()
{
  dpConnect("manageAccess_init_PT_navi_gq",myUiDpName()+".UserName:_online.._value");
}

manageAccess_init_PT_navi_gq(string dp1, string UserName)
{
  //if (dpExists("ApplicationProperties"))
  //{
/*
    if (getUserPermission(3))
      setValue("","fill","[pattern,[tile,gif,icons/general_ack_enabled.gif]]",
                  "enabled", TRUE);
    else
      //setValue("","fill","[pattern,[tile,gif,icons/general_ack_disabled.gif]]",
      setValue("","enabled", FALSE);
*/
    setValue("","enabled", getUserPermission(5));
 // }
  //else
  //{
/*
     if (getUserPermission(2))
       setValue("","fill","[pattern,[tile,bmp,general_ack_enabled.bmp]]",
                   "enabled", TRUE);
     else
       //setValue("","fill","[pattern,[tile,bmp,general_ack_disabled.bmp]]",
       setValue("","enabled", FALSE);
*/
  //  setValue("","enabled", getUserPermission(5));
  //}
}

// ============================================================================
// pt_init_PT_navi_as() - event init alert screen
// ============================================================================
pt_init_PT_navi_as()
{
  dpConnect("manageAccess_init_PT_navi_as",myUiDpName()+".UserName:_online.._value",
                                           "_PanelTopology.permissionBit:_online.._value");
}

manageAccess_init_PT_navi_as(string dp1, string UserName,
                             string dp2, dyn_string permissionBits)
{
  int            pos;
  dyn_string     filenames;
  dyn_langString dlsToolTips;

  pt_checkPanelTopologyCache();

  filenames = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.fileName:_online.._value"];
  dlsToolTips = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.nodeName:_online.._value"];

  pos = dynContains(filenames, "vision/SC/AlertScreen");

  if (pos > 0)
  {
/*
    if (getUserPermission(permissionBits[pos]))
      pt_init_PT_navi_as_TRUE();
    else
      pt_init_PT_navi_as_FALSE();
*/
    setValue("","enabled", getUserPermission(permissionBits[pos]));
    this.toolTipText(dlsToolTips[pos]);
  }
  else
  {
/*
    if (getUserPermission(2))
      pt_init_PT_navi_as_TRUE();
    else
      pt_init_PT_navi_as_FALSE();
*/
    setValue("","enabled", getUserPermission(2));
  }
}

pt_init_PT_navi_as_TRUE()
{
  if (dpExists("ApplicationProperties"))
    setValue("","fill","[pattern,[tile,gif,icons/alert_screen_enabled.gif]]",
                "enabled", TRUE);
  else
    setValue("","fill","[pattern,[tile,bmp,alert_screen_enabled.bmp]]",
                "enabled", TRUE);
}

pt_init_PT_navi_as_FALSE()
{
  if (dpExists("ApplicationProperties"))
    //setValue("","fill","[pattern,[tile,bmp,alert_screen_disabled.bmp]]",
    setValue("","enabled", FALSE);
  else
    //setValue("","fill","[pattern,[tile,gif,icons/alert_screen_disabled.gif]]",
    setValue("","enabled", FALSE);
}

// ============================================================================
// pt_click_PT_navi_aes() - start alert and event  screen
// ============================================================================
pt_click_PT_navi_aes(string screenConfig, string module, int action)
{
  if (module == "")
     module = "WinCC_OA-AES";
  openAES(screenConfig, module, action);
}

// ============================================================================
// pt_click_PT_navi_es() - start event screen
// ============================================================================
pt_click_PT_navi_es()
{
  openAES("aes_events", "WinCC_OA-AES", AES_ACTION_AUTORUN );
}

// ============================================================================
// pt_click_PT_navi_as() - start alert screen
// ============================================================================
pt_click_PT_navi_as()
{
  openAES("aes_alerts", "WinCC_OA-AES", AES_ACTION_AUTORUN );
}

// ============================================================================
// Function:    pt_init_sumX_PT_cascade0_1()
// Parameter:   pos_prioRanges ... prio ranges position can be 1, 2 or 3
// ============================================================================
pt_init_sumX_PT_cascade0_1(int pos_prioRanges)
{
  string       dpe;
  dyn_int      panelNumber;
  dyn_string   prioRanges, fileNames;
  dyn_errClass err;

  dpGet("_SumAlertGeneral.prioRange.name:_online.._value",    prioRanges);

  pt_checkPanelTopologyCache();

  panelNumber  = g_PanelTopologyCache[ getSystemName()  + "_PanelTopology.sumAlertNumber:_online.._value"];
  fileNames  = g_PanelTopologyCache[ getSystemName()  + "_PanelTopology.fileName:_online.._value"];

  // _PanelTopology leer
  if ( dynlen(fileNames) < 1 ) return;

  dpe = pt_fileNameToDpName(fileNames[1], panelNumber[1]);

  if ( dynlen(prioRanges) > pos_prioRanges-1)
  {
    if( dpSubStr( dpe + "." + prioRanges[pos_prioRanges] + ":_alert_hdl.._act_state_color", DPSUB_DP_EL ) == "" )
    {
      setValue("", "color", "_dpdoesnotexist");
      return;
    }

    dpConnect("EP_setBackColorCB", dpe + "." + prioRanges[pos_prioRanges] + ":_alert_hdl.._act_state_color");

    err = getLastError();

    if (dynlen(err) > 0)
      setValue("", "color", "_dpdoesnotexist");
  }
}

EP_setBackColorCB(string dpSource, string sNewColor)
{
  setValue("", "backCol", sNewColor);
}

// ============================================================================
// Function:    pt_init_sumX_PT_cascade1()
// Parameter:   pos_prioRanges ... prio ranges position can be 1, 2 or 3
// ============================================================================
pt_init_sumX_PT_cascade1(string sDpe)
{
  dyn_errClass err;

  if( dpSubStr( sDpe+":_alert_hdl.._act_state_color", DPSUB_DP_EL ) == "" )
  {
    setValue("", "color", "_dpdoesnotexist");
    return;
  }

  dpConnect("EP_setBackColorCB",
            sDpe+":_alert_hdl.._act_state_color");
  err = getLastError();
  if (dynlen(err) > 0)
    setValue("", "color", "_dpdoesnotexist");
}

// ============================================================================
// Function:    pt_init_PT_cascade0_1()
// ============================================================================
pt_init_PT_cascade0_1()
{
  int      i;
  bool      soundOn, clickState, dblState,
            rightState;
  string    clickFile, rightFile, dblFile;

  //**** mhalper: do init section for demo application
  if (dpExists("ApplicationProperties"))
  {
    dpGet("ApplicationProperties.sound.on:_online.._value", soundOn);
    if (soundOn == 1)
    {
      dpGet("ApplicationProperties.sound.onClickEnabled:_online.._value",     clickState,
          "ApplicationProperties.sound.onRightClickEnabled:_online.._value",rightState,
          "ApplicationProperties.sound.onDblClickEnabled:_online.._value",  dblState,
          "ApplicationProperties.sound.onClick:_online.._value",            clickFile,
          "ApplicationProperties.sound.onRightClick:_online.._value",       rightFile,
          "ApplicationProperties.sound.onDblClick:_online.._value",         dblFile);
      if (clickState == 1) enableSound(1,clickState,clickFile);
      if (rightState == 1) enableSound(2,rightState,rightFile);
      if (dblState == 1)   enableSound(3,dblState,dblFile);
    }
  }

  dpConnect("CBcasInitInclUserPermission",TRUE, myUiDpName()+".UserName:_online.._value",
                                                "_PanelTopology.permissionBit:_online.._value");
}

// ============================================================================
// Function:    pt_init_PT_cascade1()
// ============================================================================
pt_init_PT_cascade1(string dollarPos)
{
  int            pos=dollarPos,i,iType;
  string         ID,pID,sNo,sName;
  dyn_uint       parents,panel,downward;
  dyn_langString dls;

  casPanelOn.removeItem("");
  if (pos<1)
  {
    this.text="";
    return;
  }
  else
  {
    pt_checkPanelTopologyCache();

    dls = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.nodeName:_online.._value"];
    panel = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.panelNumber:_online.._value"];
    parents = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.parentNumber:_online.._value"];
    downward = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.downwardPanel:_online.._value"];

    this.text=dls[pos];
  }

  sName=dls[pos]+"...";
  sNo=pos;
  casPanelOn.insertItem("",0,-1,sNo,sName);
  if (downward[pos]>0)
    casPanelOn.insertItem("",2,-1,"","");

  for (i=pos+1;i<=dynlen(panel);i++)
  {
    if (pos>1 && parents[i]<pos)
      break;
    pID=(parents[i]==pos || parents[i]==0)?"":"ID_"+parents[i];
    iType=(downward[i]==0)?0:1;
    sName=dls[i];
    if (iType==0) sName+="...";
    sNo=panel[i];
    ID="ID_"+panel[i];
    casPanelOn.insertItem(pID,iType,-1,(iType==0)?sNo:ID,sName);
    if (pos==1 && parents[i]<pos)
      continue;
    if (downward[i]>0 && parents[i]!=0)
    {
      casPanelOn.insertItem(ID,0,-1,sNo,sName+"...");
      casPanelOn.insertItem(ID,2,-1,"","");
    }
  }
}

//***************************************************************
CBcasInitInclUserPermission(string dp1, string UserName,
                            string dp2, dyn_string permissionBits)
{
  int            pos=1,i,e,iType;
  string         ID,pID,sNo,sName, s;
  dyn_uint       parents,panel,downward;
  dyn_langString dls;

  //**** mhalper
  int            i_points = 0, iDdsPos;
  bool           bRem, bStandard = FALSE;
  string         sPath;
  dyn_int        di_panels, di, diPermissionBit;
  dyn_string     ds, fileName, dsPID;
  dyn_dyn_string dds_casPaths;
  dyn_string     dsCasItems = makeDynString("");  // IM 80366: ensure that the Items exist
  //****

  casPanelOn.removeItem("");
  if (pos<1)
  {
    this.text="";
    return;
  }
  else
  {
    pt_checkPanelTopologyCache();

    dls = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.nodeName:_online.._value"];
    panel = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.panelNumber:_online.._value"];
    parents = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.parentNumber:_online.._value"];
    downward = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.downwardPanel:_online.._value"];
    fileName = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.fileName:_online.._value"];
    diPermissionBit = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.permissionBit:_online.._value"];

  }

  //**** mhalper
  if (dpExists("ApplicationProperties"))
  {
    //**** assembling DPE data for analysing only
//    for (i = 1; i <= dynlen(dls); i++)
//    {
//      s = dls[i];
//      ds[i] = s +"|"+ panel[i] +"|"+ parents[i] +"|"+ downward[i] +"|"+ fileName[i];
//    }
    //DebugTN("ds",ds);
    //****

    //**** get number of points entry for seperator inserting
    for ( i = 1; i <= dynlen(dls); i++)
    {
     if (dls[i] == gPtFreePanel)
      {
        i_points = i;
        break;
      }
    }
    //get seperator panels (panelnumber - i_points = number) - has to be changed if "static" panels are changed
    dynClear(di_panels);
    di_panels[1] = 19;
    di_panels[2] = 36;
    di_panels[3] = 46;
    di_panels[4] = 55;
    di_panels[5] = 97;
  }
  //****

  //first panel and seperator...
  sName=dls[pos]; //+" ..."; //mhalper
  sNo=pos;
  casPanelOn.insertItem("",0,-1,sNo,sName);
  iDdsPos = pos; //mhalper
  pt_getCasPaths(iDdsPos, dls[pos], panel[pos], parents[pos], downward[pos], fileName[pos], 0, dds_casPaths); //mhalper
  if (downward[pos]>0)
  {
    casPanelOn.insertItem("",2,-1,"","");
    pt_getCasPaths(iDdsPos+=1, "-", "-", "-", "-", "-", 1, dds_casPaths);  //mhalper
  }

  //...all other panels
  dynClear(di);
  di[1] = 1;
  dsPID[1] = "";

  for (i=pos+1;i<=dynlen(panel);i++)
  {
    if (pos>1 && parents[i]<pos)
      break;

    pID   = (parents[i]==pos || parents[i]==0)?"":"ID_"+parents[i];
    iType = (downward[i] == 0)?0:1;
    sName = dls[i];
    bRem  = FALSE;

    if (iType==0)
      sName+=""; //" ..."; //mhalper

    sNo = panel[i];
    ID  = "ID_"+panel[i];

    //**** mhalper: insert seperators for demo application
    if (dpExists("ApplicationProperties"))
    {
      if (parents[i] == i_points && dynContains(di_panels, panel[i]-i_points))
      {
        casPanelOn.insertItem("ID_"+i_points,2,-1,"","");
        dynAppend(dsCasItems, "ID_"+i_points);
        if (dynlen(di) == 2)
          di[dynlen(di)] += 1;
        else
        {
          for (e = dynlen(di); e > 2; e--)  //only possible because seperators are all on second level
          {
            dynRemove(di, dynlen(di));
            bRem = TRUE;
          }

          di[dynlen(di)] += 1;
        }
        pt_dsPath_to_sPath(di, sPath);

        pt_getCasPaths(iDdsPos+=1, "-", "-", "-", "-", "-", sPath, dds_casPaths);
      }
    }
    //****

    casPanelOn.insertItem(pID,iType,-1,(iType==0)?sNo:ID,sName);
    dynAppend(dsCasItems, pID);
    //**** mhalper: figure out the current cas path and add it to
    if (dsPID[dynlen(dsPID)] == pID)
    {
      di[dynlen(di)] += 1;
    }
    else if (pID == "")
    {
      pt_dsPathForwardOrBackward(di, dsPID, pID, bRem);
    }
    else
    {
      if (dynContains(dsPID, pID) == 0)
      {
        if (bStandard == FALSE && iType == 1)
          dynAppend(di, 0);
        else
        {
          bStandard = FALSE;
          di[dynlen(di)] += 1;
        }
        dynAppend(dsPID, pID); //to figure out afterwards, how much levels to step back
      }
      else
      {
        pt_dsPathForwardOrBackward(di, dsPID, pID, bRem);
      }
    }
    pt_dsPath_to_sPath(di, sPath);
    pt_getCasPaths(iDdsPos+=1, dls[i], panel[i], parents[i], downward[i], fileName[i], sPath, dds_casPaths);
    bStandard = FALSE;
    //****

    if (pos==1 && parents[i]<pos)
      continue;

    //the "node continue": SysMgmt > SysMgmt
    //the cascade:                   -------
    if (downward[i]>0 && parents[i]!=0)
    {
      casPanelOn.insertItem(ID,0,-1,sNo,sName); //+"..."); //mhalper
      dynAppend(dsCasItems, ID);
      //**** mhalper: get path of first standard item...
      dynAppend(di, 0);
      pt_dsPath_to_sPath(di, sPath);
      pt_getCasPaths(iDdsPos+=1, dls[i], panel[i], parents[i], downward[i], fileName[i], sPath, dds_casPaths);
      //****

      casPanelOn.insertItem(ID,2,-1,"","");
      dynAppend(dsCasItems, ID);
      //**** mhalper: ... and of standard seperator
      di[dynlen(di)] = 1;
      pt_dsPath_to_sPath(di, sPath);
      pt_getCasPaths(iDdsPos+=1, "-", "-", "-", "-", "-", sPath, dds_casPaths);

      bStandard = TRUE; //only one level should be added when new popup was inserted
      //****
    }
  }

  //**** mhalper: enable / disable cascade items
  //correct filename and or script
  for (i = 1; i <= dynlen(fileName); i++)
  {
    if (substr(strtolower(fileName[i]), 4, 6) != "script")
    {
      if ( (fileName[i] == "") || (access(getPath(PANELS_REL_PATH, fileName[i]), F_OK) != 0) )
      {
        for (e = 1; e <= dynlen(dds_casPaths); e++)
        {
          if(dls[i]==dds_casPaths[e][1]&&panel[i]==dds_casPaths[e][2]&&parents[i]==dds_casPaths[e][3]&&downward[i]==dds_casPaths[e][4]&&fileName[i]==dds_casPaths[e][5])
          {
            if (fileName[i] == "")
            {
              if(dls[i]==dds_casPaths[e+1][1]&&panel[i]==dds_casPaths[e+1][2]&&parents[i]==dds_casPaths[e+1][3]&&downward[i]==dds_casPaths[e+1][4]&&fileName[i]==dds_casPaths[e+1][5])
              {
                if(dynContains(dsCasItems,dds_casPaths[e+1][6]))
                  casPanelOn.enableItem(dds_casPaths[e+1][6], FALSE);
              }
              else if (dls[i] == gPtFreePanel)
                ;
              else
                if(dynContains(dsCasItems,dds_casPaths[e][6]))
                  casPanelOn.enableItem(dds_casPaths[e][6], FALSE);
            }
            else if (downward[i]>0 && parents[i]!=0)
              if(dynContains(dsCasItems,dds_casPaths[e+1][6]))
                casPanelOn.enableItem(dds_casPaths[e+1][6], FALSE);
            else
              if(dynContains(dsCasItems,dds_casPaths[e][6]))
                casPanelOn.enableItem(dds_casPaths[e][6], FALSE);
          }
        }
      }
    }
  }

  //correct user permission
  for (i = 1; i <= dynlen(diPermissionBit); i++)
  {
    if (!getUserPermission(diPermissionBit[i])) // && substr(strtolower(fileName[i]), 0, 6) != "script")
    {
      for (e = 1; e <= dynlen(dds_casPaths); e++)
      {
        if(dls[i]==dds_casPaths[e][1]&&panel[i]==dds_casPaths[e][2]&&parents[i]==dds_casPaths[e][3]&&downward[i]==dds_casPaths[e][4]&&fileName[i]==dds_casPaths[e][5])
        {
          if (fileName[i] != "")
          {
            if (downward[i]>0 && parents[i]!=0)
              if(dynContains(dsCasItems,dds_casPaths[e+1][6]))
                casPanelOn.enableItem(dds_casPaths[e+1][6], FALSE);
            else
              if(dynContains(dsCasItems,dds_casPaths[e][6]))
                casPanelOn.enableItem(dds_casPaths[e][6], FALSE);
          }
        }
      }
    }
  }

  //only for demo application
  if (dpExists("ApplicationProperties") || dpExists("ApplicationExtensions"))
  {
    dyn_string ds = strsplit(dds_casPaths[dynlen(dds_casPaths)][6], ".");

    casPanelOn.enableItem(ds[1] + ".8.2", dpExists("ExtensionPackage01"));    //"pvss_report"
    casPanelOn.enableItem(ds[1] + ".9.2", dpExists("ExtensionPackage03"));    //"recipes"
    //casPanelOn.enableItem(ds[1] + ".11.3", dpExists("ExtensionPackage09"));    //"scheduler"
    casPanelOn.enableItem(ds[1] + ".11.2", dpExists("ExtensionPackage02"));    //"voice"
    casPanelOn.enableItem(ds[1] + ".11.3", dpExists("ExtensionPackage06"));    //"sms_alarming"
    casPanelOn.enableItem(ds[1] + ".11.6", dpExists("ExtensionPackage02"));    //"shift_plan"
    casPanelOn.enableItem(ds[1] + ".12.2", dpExists("ExtensionPackage04"));    //"web_server"
    casPanelOn.enableItem(ds[1] + ".12.3", dpExists("ExtensionPackage05"));    //"wap_server"

  }
}

// ============================================================================
// Function:    pt_getCasPaths() - delivers the cascade paths of all entries
// ============================================================================
pt_getCasPaths(int i, string dls, string panel, string parent, string downward, string fileName, string path, dyn_dyn_string &dds_casPaths)
{
  dds_casPaths[i][1] = dls;
  dds_casPaths[i][2] = panel;
  dds_casPaths[i][3] = parent;
  dds_casPaths[i][4] = downward;
  dds_casPaths[i][5] = fileName;
  dds_casPaths[i][6] = path;
}

// ============================================================================
// Function:    pt_getCasPaths() - builds a correct cas path form an dyn string
// ============================================================================
pt_dsPath_to_sPath(dyn_int di, string &sPath)
{
  int e;

  sPath = "";
  for (e = 1; e <= dynlen(di); e++)
  {
    if (e == 1)
      sPath = di[e];
    else
      sPath = sPath + "." + di[e];
  }
}

// ============================================================================
// Function:    pt_getCasPaths() - build path forward or backward
// ============================================================================
pt_dsPathForwardOrBackward(dyn_int &di, dyn_string &dsPID, string pID, bool bRem)
{
  int e;

  for (e = dynlen(dsPID) ; e >= 1; e--)
  {
    if (dsPID[e] == pID)
    {
      di[dynlen(di)] += 1;
      break;
    }
    else
    {
      if (bRem == FALSE)
        dynRemove(di, dynlen(di));

      dynRemove(dsPID, dynlen(dsPID));
    }
  }
}

////////////////////////////////////////////////////////////////////////////
// STANDARD BUTTONS - END
////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////
// SCRIPT EXECUTION, EVALUATION - START
////////////////////////////////////////////////////////////////////////////
string PT_createExecScript(string sScript)
{
  //check if a script or a lib function to evaluate
  if(sScript!="")
  {
    //a whole script is to evaluate
    if(strpos(sScript, "{")==0)
    {
      sScript = "string main()\n"+sScript+"\n";
    }
    else  //only one library function should be evaluated
    {
      sScript = "string main()\n"+
                "{\n"+
                "   "+sScript+";\n"+
                "}\n";
    }
  }
  return sScript;
}
////////////////////////////////////////////////////////////////////////////
string PT_createEvalScript(string sScript)
{
  //check if a script or a lib function to evaluate
  if(sScript!="")
  {
    //a whole script is to evaluate
    if(strpos(sScript, "{")==0)
    {
      sScript = "string main()\n"+sScript+"\n";
    }
    else  //only one library function should be evaluated
    {
      sScript = "string main()\n"+
                "{\n"+
                "string sReturn;\n"+
                "  sReturn = "+sScript+";\n"+  //"  sReturn = getCatStr(\"DemoApp\",\"measurements\");\n"+
                "  return(sReturn);\n"+
                "}\n";
    }
  }
  return sScript;
}

////////////////////////////////////////////////////////////////////////////
PT_evalDollarScript(dyn_string &params)
{
  int            i, iErr, iStrpos;
  dyn_string     scriptOrNotScript;

  for (i=1;i<=dynlen(params);i++)
  {
    //example "dollar script":  4:"dpe_group:SCRIPT getCatStr(\"DemoApp\",\"measurements\")
    iStrpos = strpos(params[i], ":");
    scriptOrNotScript[1] = substr(params[i], 0, iStrpos+1);
    scriptOrNotScript[2] = substr(strtolower(params[i]), iStrpos+1, 10);
    scriptOrNotScript[3] = substr(params[i], iStrpos+1+10, strlen(params[i]));
    scriptOrNotScript[3] = strltrim(scriptOrNotScript[3], " ");

    if (dynlen(scriptOrNotScript) >= 3)
    {
      if (strtolower(scriptOrNotScript[2]) == "evalscript")
      {
        //check if a script or a lib function to evaluate
        scriptOrNotScript[3] = PT_createEvalScript(scriptOrNotScript[3]);

        //do the script evaluation
        if(checkScript(scriptOrNotScript[3]))
          iErr = evalScript(scriptOrNotScript[2], scriptOrNotScript[3], makeDynString("")); //if ok 0, if bug -1

        if (iErr == 0)
          params[i] = scriptOrNotScript[1] + scriptOrNotScript[2];
        else
          ;  //ToDo - Error handling
      }
    }
  }
}

PT_execScript(string ex, int &iErr)
{
  string sScript = substr(ex, 10, strlen(ex));

  sScript = strltrim(sScript, " ");

  //check if a script or a lib function to evaluate
  sScript = PT_createExecScript(sScript);

  //do the script evaluation
  if(checkScript(sScript))
    iErr = execScript(sScript, makeDynString("")); //if ok 0, if bug -1
  else
    iErr = -99;
}
////////////////////////////////////////////////////////////////////////////
// SCRIPT EXECUTION, EVALUATION - END
////////////////////////////////////////////////////////////////////////////


//cstoeg int -> string
pt_moduleNumber(string &sModuleName, string &ModuleNumber)
{

  dyn_string dsModuleName = strsplit(sModuleName, "_");

  if (dynlen(dsModuleName) >= 2)
  {
    sModuleName = "";

    //Extract the module number from the last position
    ModuleNumber = dsModuleName[dynlen(dsModuleName)];

    //Re-create the module name
    for (int i = 1; i < dynlen(dsModuleName); i++)
    {
      sModuleName = sModuleName + dsModuleName[i];

      if (i != dynlen(dsModuleName) - 1)
      {
        sModuleName = sModuleName + "_";
      }
    }
  }
  else
  {
    ModuleNumber = "NONUMBER";
  }
}

//int -> string
string pt_buildModuleName(string sModuleName, string ModuleNumber = "NONUMBER")
{
  if ( strpos(sModuleName, "_") > 0)
  {
    sModuleName=   substr(sModuleName, 0, strpos(sModuleName, "_"));
  }

  if(ModuleNumber != "NONUMBER")  //if project version was older than 3.7
    sModuleName = sModuleName + "_" + ModuleNumber;
  else
  {
    string screenName = ptnavi_GetScreenName();
    if (screenName != "") sModuleName = sModuleName + "_" + screenName;
  }

 return sModuleName;
}

// ============================================================================
// Function:    unsigned pt_createItem(unsigned oldSelection, unsigned insertMode, unsigned lastChild=0, int alerts=0, langString name, string panel="", bool type=false, string module="", string icon="", bool menuBar=true, bool iconBar=true, bool modal=true, bool centered=true, int permission=1)
//              <- Create a new Node and display it in treeTopology
// Parameters:  unsigned oldSelection  ...which node in tree is selected at the moment
//              unsigned insertMode    ...CHILD, BROTHERBEFORE, BROTHERAFTER
//              unsigned lastChild=0   ...the id of the last child - only needed for insertMode CHILD
//              init-values: int alerts=0, langString name, string panel="", bool type=false, string module="", string icon="", bool menuBar=true, bool iconBar=true, bool modal=true, bool centered=true, int permission=
// return:      id of the new node
// ============================================================================
unsigned pt_createItem(unsigned oldSelection,
                       unsigned insertMode,
                       unsigned lastChild=0,
                       int alerts=0,
                       langString name=makeDynString(),
                       string panel="",
                       bool type=false,
                       string module="",
                       string icon="",
                       bool menuBar=true,
                       bool iconBar=true,
                       bool modal=true,
                       bool centered=true,
                       string parameters="",
                       int permission=1,
                       langString description,
                       langString locality,
                       langString functionality,
                       string panellink)
{
  unsigned newIndex = dynlen(gPtIndices)+1, noOfLangs = getNoOfLangs();
  dyn_string pName;
  int pos, afterPos;
  unsigned tmpParent;
// define the position according to insertMode
  if (insertMode == CHILD)
  {
    tmpParent = oldSelection;
    pos = (lastChild>0?lastChild+1:oldSelection+1);
    afterPos = getLastChildOfThatLevel(oldSelection);  //insert after lastChild of selection
    if (afterPos < 1)
      afterPos = oldSelection;
  }
  else if (insertMode == BROTHERBEFORE)
  {
    tmpParent = gPtParents[oldSelection];
    pos = oldSelection;
    afterPos = getBrotherBefore(oldSelection);  //insert before selection
    if (afterPos<1)
      afterPos = tmpParent;
  }
  else if (insertMode == BROTHERAFTER)
  {
    tmpParent = gPtParents[oldSelection];
    pt_getLastChild(oldSelection, gPtIndices, gPtParents, pos); //searching lastChild of Node
    pos++;
    if (pos < 2)
      pos = oldSelection + 1;

    afterPos=oldSelection; //insert after selection
  }
  else
    return 0;
// create a NodeName in all Languages
  for (int i=1; i<=noOfLangs; i++)
    pName[i] = getCatStr("pt","newpanel",i-1);



  pt_insertItemAt(pos, pos, gPtIndices, true, true);
  pt_insertItemAt(pos, pos, gPtTreeIndices/*, true*/);
  pt_insertItemAt(pos, 0, gPtAlerts, true);
  pt_insertItemAt(pos, pName, gPtNames);
  pt_insertItemAt(pos, panel, gPtPanels);
  pt_insertItemAt(pos, type, gPtTypes);
  pt_insertItemAt(pos, module, gPtModules);
  pt_insertItemAt(pos, icon, gPtIcons);
  pt_insertItemAt(pos, menuBar, gPtMenuBar);
  pt_insertItemAt(pos, iconBar, gPtIconBar);
  pt_insertItemAt(pos, modal, gPtModal);
  pt_insertItemAt(pos, centered, gPtCentered);
  pt_insertItemAt(pos, parameters, gPtParameters);
  pt_insertItemAt(pos, permission, gPtPermissions);
  pt_insertItemAt(pos, description, gPtDescription);
  pt_insertItemAt(pos, locality, gPtLocality);
  pt_insertItemAt(pos, functionality, gPtFunctionality);
  pt_insertItemAt(pos, panellink, gPtPanelLink);
  pt_insertItemAt(pos, 0, gPtParents, true);

  gPtParents[pos]=tmpParent;

  treeTopology.appendItem(tmpParent, pos, ((string)gPtNames[pos]), afterPos);//mtrummer!!!

  treeTopology.setDragEnabled(pos, true);
  treeTopology.setDropEnabled( pospos, true );
  return pos;
}
// ============================================================================
// Function:    void pt_insertItemAt(unsigned id, anytype value, dyn_anytype &var, bool increase=false, bool changeIdsInTree=false)
//              <- Insert one Element at special position in an Array, increase the following elements - if increase==true and changes the ID of treeTopology if changeIdsInTree==true
// Parameters:  unsigned id           ...the new Id which sould be inserted
//              anytype value         ...the value which sould be inserted
//              dyn_anytype &var      ...the array where to insert
//              bool increase         ...should the elements followed of the id be incremented
//              bool changeIdsInTree  ...sould the ids of the tree-widget treeTopology changed
void pt_insertItemAt(unsigned id, anytype value, dyn_anytype &var, bool increase=false, bool changeIdsInTree=false)
{
  int i;
  anytype tmp1, tmp2;

  dynAppend(var, tmp2);
  for ( i=dynlen(var); i>=id; i--)
  {
    if ( increase && var[i-1]>=id )
    {
      if (changeIdsInTree)
        treeTopology.changeId(var[i-1],var[i-1]+1);

      var[i] = var[i-1]+1;
    }
    else
    {
      var[i] = var[i-1];
    }
  }
  var[id] = value;
}
// ============================================================================
// Function:    bool pt_removeItem(unsigned id)
//              <- remove a Node of treeTopology
// Parameters:  unsigned id  ...which node in tree should be removed
// return:      false ...if node has children
//              true  ...if deleted
// ============================================================================
bool pt_removeItem(unsigned id)
{
  if(pt_hasChilden(id))  //don't delete nodes with children
    return false;
  treeTopology.removeItem(id);
  pt_removeItemAt(id, gPtIndices, true, true);

  pt_removeItemAt(id, gPtTreeIndices/*, true*/);
  pt_removeItemAt(id, gPtAlerts, true);
  pt_removeItemAt(id, gPtNames);
  pt_removeItemAt(id, gPtPanels);
  pt_removeItemAt(id, gPtTypes);
  pt_removeItemAt(id, gPtModules);
  pt_removeItemAt(id, gPtIcons);
  pt_removeItemAt(id, gPtMenuBar);
  pt_removeItemAt(id, gPtIconBar);
  pt_removeItemAt(id, gPtModal);
  pt_removeItemAt(id, gPtCentered);
  pt_removeItemAt(id, gPtParameters);
  pt_removeItemAt(id, gPtPermissions);
  pt_removeItemAt(id, gPtParents, true);
  pt_removeItemAt(id, gPtDescription);
  pt_removeItemAt(id, gPtLocality);
  pt_removeItemAt(id, gPtFunctionality);
  pt_removeItemAt(id, gPtPanelLink);
  return true;
}
// ============================================================================
// Function:    anytype pt_removeItemAt(unsigned id, dyn_anytype &var, bool decrease=false, bool changeIdsInTree=false)
//              <- Remove one Element at special position in an Array, decrease the following elements - if decrease==true and changes the ID of treeTopology if changeIdsInTree==true
// Parameters:  unsigned id           ...the Id which sould be removed
//              dyn_anytype &var      ...the array where the element should be removed
//              bool decrease         ...should the elements followed of the id be decremented
//              bool changeIdsInTree  ...sould the ids of the tree-widget treeTopology changed
// return:      deleted Value
// ============================================================================
anytype pt_removeItemAt(unsigned id, dyn_anytype &var, bool decrease=false, bool changeIdsInTree=false)
{
  anytype ret;
  if(id>dynlen(var))
    return ret;

  int i;
  ret = var[id];
  for ( i=id; i<dynlen(var); i++)
  {
    if (decrease && var[i+1]>=id)
    {
      if (changeIdsInTree)
        treeTopology.changeId(i+1,i);
      var[i]=var[i+1]-1;
    }
    else
    {
      var[i]=var[i+1];
    }
  }
  dynRemove(var, dynlen(var));
  return(ret);  //return removed value
}
// ============================================================================
// Function:    void pt_swapItems(unsigned id1, unsigned id2)
//              <- swap two Elements
// Parameters:  unsigned id1 ...the Id1 which sould be swapped with Id2
//              unsigned id2 ...the Id2 which sould be swapped with Id1
// ============================================================================
void pt_swapItems(unsigned id1, unsigned id2)
{
  dyn_bool dbOpen;
  int error;

  //save opened tree parts
  for(int i = 1; i < dynlen(gPtParents); i++)
  {
    dbOpen[i] = treeTopology.isOpen(i);
  }

  //move tree parts
  if( id1 < id2 ) //order is necessary see moveIDs
    moveIDs(id2, id1);
  else
    moveIDs(id1, id2);

  //swap ids/isOpen() values for correct display
  bool temp = dbOpen[id1];
  dbOpen[id1] = dbOpen[id2];
  dbOpen[id2] = temp;

  //clear tree and reload topology
  treeTopology.clear();
  pt_writeTopologyTree("treeTopology", gPtIndices,gPtParents,gPtNames,gPtPanels,gPtTypes,gPtTreeIndices,error);

  //re-expand tree parts
  for(int i = 1; i < dynlen(dbOpen); i++)
  {
    treeTopology.setOpen(i, dbOpen[i]);
  }

}
// ============================================================================
// Function:    void pt_swapItemsAt(unsigned id1, unsigned id2, dyn_anytype &var)
//              <- swap two Elements in an Array
// Parameters:  unsigned id1 ...the Id1 which sould be swapped with Id2
//              unsigned id2 ...the Id2 which sould be swapped with Id1
// ============================================================================
void pt_swapItemsAt(unsigned id1, unsigned id2, dyn_anytype &var)
{
  anytype tmp = var[id1];
  var[id1]=var[id2];
  var[id2]=tmp;
}
// ============================================================================
// Function:    bool pt_hasChilden(unsigned id)
//              <- has the node children
// Parameters:  unsigned id           ...the Id which sould be investigated
// return:      true  ...node has children
//              false ...node has no children
// ============================================================================
bool pt_hasChilden(unsigned id)
{
  for (int i=1; i<=dynlen(gPtParents); i++)
  {
    if (gPtParents[i]==id)
      return true;
  }
  return false;
}
// ============================================================================
// Function:    dyn_int pt_makeParentList()
//              <- creates a Parentlist of treeTopology
// return:      dyn_int ...the list of all parents of the treeTopology
// ============================================================================
dyn_int pt_makeParentList()
{
  dyn_int parentList;
  for (int i = 1; i<=dynlen(gPtIndices); i++)
    dynAppend(parentList,treeTopology.parent(gPtIndices[i]));
  return parentList;
}
// ============================================================================
// Function:    unsigned pt_getOtherSelection(unsigned oldSelection)
//              <- determines which node should be selected
// Parameters:  unsigned id ...the Id of old selection
// return:      new selection
// ============================================================================
unsigned pt_getOtherSelection(unsigned oldSelection)
{
  string strParent = treeTopology.parent(oldSelection);
  unsigned  parent = (strParent == "" ? 0 : strParent ) ,
            item;
  item=treeTopology.itemAbove(oldSelection);
  if (item==parent)  //try to find the node after
  {
    string tmp = treeTopology.itemBelow(oldSelection);
    if (tmp!="")
    {
      item = tmp;
      item--;
    }
  }

  return item;
}
// ============================================================================
// Function:    bool pt_hasNoParents(unsigned id)
//              <- has the node a parent?
// Parameters:  unsigned id ...the Id of node
// return:      true  ...has no parent
//              false ...has a parent
// ============================================================================
bool pt_hasNoParents(unsigned id)
{
  return (gPtParents[id]==0);
}
// ============================================================================
// Function:    int pt_getNodeLevel(unsigned id, int actLevel=0, dyn_int parents = gPtParents, dyn_int indices = gPtIndices)
//              <- which NodeLevel as a specific node?
// Parameters:  unsigned id ...the Id of node
//              the other paramters are for recursive use within the function
// return:      the level of node
// ============================================================================
int pt_getNodeLevel(unsigned id, int actLevel=0, dyn_int parents = gPtParents, dyn_int indices = gPtIndices)
{
  if(dynlen(parents)==0)
    parents = gPtParents;
  if(dynlen(indices)==0)
    indices = gPtIndices;
  if (id==0 || indices[id]==0)
    return -1;

  if (parents[indices[id]]!=0)
    actLevel = pt_getNodeLevel(parents[indices[id]], ++actLevel, parents, indices);
  return(actLevel);
}

// ============================================================================
// Function:    int pt_getNodeParentInfo(unsigned id)
//              <- if a parent exists > 0
//              uses the global variables gPtParents and gPtIndices
// Parameters:  unsigned id ...the Id of node
// return:      information if a parent node exists
// ============================================================================
int pt_getNodeParentInfo(unsigned id)
{
  if (id==0 || gPtIndices[id]==0)
    return -1;

  if (gPtParents[gPtIndices[id]]!=0)
    return 1;
  else
    return 0;
}
// ============================================================================
// Function:    int pt_getIconNr(unsigned id, unsigned posFree)
//              <- which Icon should be displayed in the treeTopology
// Parameters:  unsigned id       ...the Id of node
//              unsigned posFree  ...the pos of FreeNode (the node with name ". . .")
// return:      the number of icon
// ============================================================================
int pt_getIconNr(unsigned id, unsigned posFree)
{
  if (id == posFree)
  {
    return 3;
  }
  else
  {
    return ((gPtTypes[id])?2:1);
  }
}
// ============================================================================
// Function:    void pt_exportTreeToTxtFile(string fileName)
//              <- exports the Tree to a txt-file (there is no import possible!)
// Parameters:  string fileName
// ============================================================================
void pt_exportTreeToTxtFile(string fileName)
{
  file f;
   f=fopen(fileName, "w");
   fprintf(f, "%s\n"," ");  //write a '\n', otherwise the first row is missing in the file

   string tabs="", tmpName, tmpPanel, tmpModule;
   int level;

   for (int i=1; i<=dynlen(gPtParents); i++)
   {
     if (i>1 && gPtParents[i]!=gPtParents[i-1])  //only calulate level if parent has differs to the parent before
     {
       level = pt_getNodeLevel(i);
       tabs="";
       for (int j=0; j<level; j++)
         tabs+="\t";
     }
     tmpName = gPtNames[i];
     tmpPanel = ((gPtPanels[i] == "")?" ":gPtPanels[i]);
     tmpModule = ((gPtModules[i] =="")?" ":gPtModules[i]);

     fprintf(f,"%s%s\t%s\t%s\n",tabs, tmpName, tmpPanel, tmpModule);
   }

   int err=ferror(f);
   if(err!=0)
     DebugN("ERROR beim �ffnen!!!");
   fclose(f);
}
// ============================================================================
// Function:    int pt_getFirstChild(unsigned id)
//              <- get the first child of a node
// Parameters:  unsigned id       ...the Id of node
// return:      the number of first child of the node
//              0 ...if the node has no children
// ============================================================================
int pt_getFirstChild(unsigned id)
{
  int i_dc;

  i_dc = dynContains(gPtParents,id);

  return i_dc;
}
// ============================================================================
// Function:    int pt_getMyLastChild(unsigned id)
//              <- get the last child of a node
// Parameters:  unsigned id       ...the Id of start-node
// return:      the number of last child of the node
//              0 ...if the node has no children
// ============================================================================
int pt_getMyLastChild(unsigned id)
{
  int i_dc, i_id;

  i_dc = dynContains(gPtParentsReverse,id);
  if(i_dc > 0)
    i_id = dynlen(gPtParents) - i_dc + 1;
  else
    i_id = 0;

  return i_id;
}
// ============================================================================
// Function:    int pt_getMyBrotherBefore(unsigned id)
//              <- get the brother before a node
// Parameters:  unsigned id       ...the Id of node
// return:      the number of brother before the node
//              id ...if there is no brother before
// ============================================================================
int pt_getMyBrotherBefore(unsigned id)
{
  for ( int i=id-1; i>=1; i--)
   if (gPtParents[i]==gPtParents[id])
     return i;
  return id;
}
// ============================================================================
// Function:    int pt_getMyBrotherAfter(unsigned id)
//              <- get the brother after a node
// Parameters:  unsigned id       ...the Id of node
// return:      the number of brother after the node
//              id ...if there is no brother after
// ============================================================================
int pt_getMyBrotherAfter(unsigned id)
{
  for ( int i=id+1; i<=dynlen(gPtParents); i++)
   if (gPtParents[i]==gPtParents[id])
     return i;
  return id;
}


// ============================================================================
// Function:    int pt_openBasePanel(string  sPTBasePanelType)
// ============================================================================
pt_openBasePanel(string sPTBasePanelType)
{
  dyn_string     fileName;
  dyn_langString nodeName;
  int iModule,  xResolution, yResolution, xSize, ySize, iDisplay;
  string sModule, sModuleNumber;

  pt_checkPanelTopologyCache();

  nodeName = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.nodeName:_online.._value"];
  fileName = g_PanelTopologyCache[ getSystemName() + "_PanelTopology.fileName:_online.._value"];

  sModule = myModuleName();

  panelSize( "", xResolution, yResolution);
  xResolution += 6;
  yResolution += 6;
DebugTN(xResolution, yResolution);
  getScreenSize(xSize, ySize);

  iDisplay = xSize / xResolution;
  pt_moduleNumber(sModule, sModuleNumber);  //iModule has to be int because of compatibility
  if(sModuleNumber=="NONUMBER")
    iModule=1;
  else
    iModule = sModuleNumber;

  //cstoeg: if _new is used then the mulitscreening is handeld by the login.ctl
  if(dpExists("_Default_UiConfiguration") && isDollarDefined("$Screen") && isDollarDefined("$Number") )
  {
    naviModule.ModuleName = ptms_BuildModuleName("naviModule",$Screen);
    mainModule.ModuleName = ptms_BuildModuleName("mainModule",$Screen);
    infoModule.ModuleName = ptms_BuildModuleName("infoModule",$Screen);
    ptms_LoadInitPanel($Number,$Screen);
  }
  else
  {
    //in that case iModule hast to be a integer because of compatibility to earlyer versions
    naviModule.ModuleName=pt_buildModuleName( "naviModule",sModuleNumber);
    mainModule.ModuleName=pt_buildModuleName( "mainModule",sModuleNumber);
    infoModule.ModuleName=pt_buildModuleName( "infoModule",sModuleNumber);
    RootPanelOnModule("para/PanelTopology/templates/naviPanel_"+sPTBasePanelType+".pnl","Navi",pt_buildModuleName( "naviModule",sModuleNumber),makeDynString());
    RootPanelOnModule(fileName[1],nodeName[1],pt_buildModuleName( "mainModule",sModuleNumber),makeDynString());
    RootPanelOnModule("para/PanelTopology/templates/infoPanel_"+sPTBasePanelType+".pnl","Info",pt_buildModuleName( "infoModule",sModuleNumber),makeDynString());

    if(iDisplay>iModule)
    {
      int yPos= 0;
      int xPos= iModule;
      ModuleOn(pt_buildModuleName(sModule,iModule+1), xResolution*xPos, 0   , xResolution, yResolution,0,0, "");
      RootPanelOnModule("para/PanelTopology/templates/basePanel_"+sPTBasePanelType+".pnl ", " ",pt_buildModuleName(sModule,iModule+1), " ");
    }
  }
}

// ============================================================================
// Function:    pt_sortNodes(bool displayProgressBar=false)
//              <- sort Paneltopology-Arrays
//              needed if nodes are inserted not in correct order (with wrong IDs)
// ============================================================================
// IM104828:
// Sumalertgeneration will be done automatically by pt_writeTopologyDp() what needs to be
// suppressed if this function was called from pt_generateSumAlerts() (this is the only place
// in code where pt_sortNodes is called with suppressSumAlertGeneration set to true)
pt_sortNodes(bool displayProgressBar=false, bool suppressSumAlertGeneration = false)
{
  /*
    31.01.2014   Pokorny, Martin  113307 :
    - function is obsolete after version 3.11.0
  */
  if (VERSION_NUMERIC >= 311100)
  {
    throwError(makeError("", PRIO_WARNING, ERR_IMPL, 53, "Function '"+__FUNCTION__+ "'is obsolete since version '3.11.1'"));
    return ;
  }
  int error;
  bool bChanged = false;

  if (displayProgressBar)
    openProgressBar(getCatStr("pt","repairPT"),
                    "sumalarm.gif",
                    "", "", "",
                    2);

  // read Topology form DP
  pt_readTopologyDp(gPtIndices,
                       gPtParents,
                       gPtAlerts,
                       gPtNames,
                       gPtPanels,
                       gPtTypes,
                       gPtModules,
                       gPtIcons,
                       gPtMenuBar,
                       gPtIconBar,
                       gPtModal,
                       gPtCentered,
                       gPtParameters,
                       gPtPermissions,
                       gPtDescription,
                       gPtLocality,
                       gPtFunctionality,
                       gPtPanelLink,
                       error);

  // IM 102435 -->
  // All dyns in _PanelTopology MUST have the same dynlen; After updating a project to 3.10
  // the elements "description", "locality", "functionality", "panelLink" may have a dynlen of 0.
  // The dynlen of _PanelTopology.nodeName is now taken as reference and checked against the 4
  // mentioned elements. If the currently checked one has a dynlen of 0 it will be updated to
  // an empty dyn of the same length as nodeName. If its dynlen is smaller than nodeName empty
  // dyn elements will fill up the rest.
  if (dynlen(gPtNames) != dynlen(gPtDescription) ||
      dynlen(gPtNames) != dynlen(gPtLocality) ||
      dynlen(gPtNames) != dynlen(gPtFunctionality) ||
      dynlen(gPtNames) != dynlen(gPtPanelLink))
  {
    // Only do the update if there are differences...
    langString emptyLangString;
    string emptyString;
    for (int i = 1; i <= dynlen(gPtNames); i++)
    {
      if (dynlen(gPtDescription) < i) dynAppend(gPtDescription, emptyLangString);
      if (dynlen(gPtLocality) < i) dynAppend(gPtLocality, emptyLangString);
      if (dynlen(gPtFunctionality) < i) dynAppend(gPtFunctionality, emptyLangString);
      if (dynlen(gPtPanelLink) < i) dynAppend(gPtPanelLink, emptyString);
    }
  }
  // --> IM 102435

  dyn_int sortedIds;
  int dif;

  for ( int i =1; i<=dynlen(gPtParents)-1; i++)
  {
    if (displayProgressBar)
      showProgressBar(getCatStr("pt","repairPTfor")+gPtNames[i],"", "", ((float) i/dynlen(gPtParents))*100);

    if (gPtParents[i+1]!=i)
    {
      dif = 0;
      for ( int j = i+2; j<=dynlen(gPtParents); j++)
      {
        if (gPtParents[j]==i && gPtParents[j]!=gPtParents[i+1+dif])  // if element is a child of i, but don't change pos of brothers
        {
          moveIDs(j,i+1 + dif);  //move element from oldId (=j) to newId (=i+1 +dif)
          dif++;                 //dif is the count of elements which are moved for that parent
          bChanged=true;
        }
      }
    }
  }
  if (!bChanged)  //there is nothing to save or generate if nothing has changed
  {
    if (displayProgressBar)
    {
      showProgressBar("OK!","", "", 100);
      closeProgressBar();
    }
    return;
  }

  // write Topology form DP
  pt_writeTopologyDp(gPtIndices,
                     gPtNames,
                     gPtPanels,
                     gPtTypes,
                     gPtAlerts,
                     gPtModules,
                     gPtIcons,
                     gPtMenuBar,
                     gPtIconBar,
                     gPtModal,
                     gPtCentered,
                     gPtParameters,
                     gPtPermissions,
                     error,
                     true,
                     gPtDescription,
                     gPtLocality,
                     gPtFunctionality,
                     gPtPanelLink,
                     suppressSumAlertGeneration);

  if (displayProgressBar)
  {
    showProgressBar("OK!","", "", 100);
    closeProgressBar();
  }
}

// ============================================================================
// Function:    moveIDs(unsigned oldId, unsigned newId)
//              <- move ArrayElements from oldId to newId and increase or decrease IDs
// Parameters:  unsigned oldId, newId
// ============================================================================
moveIDs(unsigned oldId, unsigned newId)
{
  int tmpParent;
  if(oldId<newId)  //we can just move forward!
  {
    DebugN( "Can't move" );
    return;
  }

  pt_moveItemAt(newId, oldId, gPtAlerts);//, true); //IM 102345 moves one item from old to new position and in-/de-crease data for elements between

  pt_moveItemAt(newId, oldId, gPtNames);        //just move one item from old to new position
  pt_moveItemAt(newId, oldId, gPtPanels);
  pt_moveItemAt(newId, oldId, gPtTypes);
  pt_moveItemAt(newId, oldId, gPtModules);
  pt_moveItemAt(newId, oldId, gPtIcons);
  pt_moveItemAt(newId, oldId, gPtMenuBar);
  pt_moveItemAt(newId, oldId, gPtIconBar);
  pt_moveItemAt(newId, oldId, gPtModal);
  pt_moveItemAt(newId, oldId, gPtCentered);
  pt_moveItemAt(newId, oldId, gPtParameters);
  pt_moveItemAt(newId, oldId, gPtPermissions);    //just move one item from old to new position
  pt_moveItemAt(newId, oldId, gPtDescription);
  pt_moveItemAt(newId, oldId, gPtLocality);
  pt_moveItemAt(newId, oldId, gPtFunctionality);
  pt_moveItemAt(newId, oldId, gPtPanelLink);

  pt_moveItemAt(newId, oldId, gPtParents, true);  //moves one item from old to new position and in-/de-crease data for elements between
                                                  //because parentIDs of other elements also change depending on element move!
}


// ============================================================================
// Function:    void pt_moveItemAt(unsigned newId, unsigned oldId, dyn_anytype &var, bool increase=false)
//              <- moves one Element from old position to new position in an Array, in-/de-crease the following elements - if increase==true
// Parameters:  unsigned newId        ...the new Id where the element sould be inserted
//              unsigned oldId        ...the old Id where the element sould be removed
//              dyn_anytype &var      ...the array where to move
//              bool increase         ...should the elements followed of the id be in-/de-cremented
//         newId < oldId !!!!
void pt_moveItemAt(unsigned newId, unsigned oldId, dyn_anytype &var, bool increase=false)
{
  int i;
  anytype tmp1, tmp2, value = var[oldId];
  string changed="";
  string art="";
  bool db=false;

  if(oldId<newId)  //we can just move forward!
    return;

//  insert one item
  dynAppend(var, tmp2);  // add one item
  for ( i=dynlen(var); i>=newId; i--)  //move items: var[i] = var[i-1] ...
  {
    if ( increase)              // should the elements followed of the id be incremented
    {
      if (var[i-1] == oldId)    // replace oldId by newId
      {
        var[i]=newId;
      }
      else if (var[i-1] >= newId)  // if greater newId -> increase because a new element will be inserted before
      {
        var[i] = var[i-1]+1;
      }
      else  //just move
      {
        var[i] = var[i-1];
      }
    }
    else  //just move
    {
      var[i] = var[i-1];
    }
  }
  var[newId] = value;  //copy value from oldId to newId

  pt_removeItemAt(oldId+1, var, increase);  //remove the element with oldId (+1 because 1 element was insertet before oldId)
}

int pt_checkPanelTopologyCache(string strServerName="")
{
  string sys = getSystemName();

  if(strServerName == "")
  {
    strreplace(sys,":","");
    strServerName = sys;
  }

  if (! globalExists("g_PanelTopologyCache"))
  {
    addGlobal("g_PanelTopologyCache", MAPPING_VAR);
  }
  if (!mappingHasKey(g_PanelTopologyCache, strServerName+":_PanelTopology.permissionBit:_online.._stime"))
    g_PanelTopologyCache[strServerName+":_PanelTopology.permissionBit:_online.._stime"] = (time)1; // IM 98092


  time t;
  dyn_int        back,forw,up,down,panelType,permissionBit,di,menuBar,iconBar,alertNumber,diPanelNumber, alertNumber;
  dyn_bool       modal,centered;
  dyn_string     fileName,moduleName,parameter,panelNames,params,dsFileName,dollar, parents, iconName;
  dyn_langString nodeName;
  int error = 0;
  dyn_langString description;
  dyn_langString locality;
  dyn_langString functionality;
  dyn_string panellink;
  dyn_uint panelNumber;

  dpGet(strServerName+":_PanelTopology.permissionBit:_online.._stime", t);

  if (t != g_PanelTopologyCache[strServerName+":_PanelTopology.permissionBit:_online.._stime"])
  {
    error = dpGet(strServerName+":_PanelTopology.nodeName:_online.._value",nodeName,
                  strServerName+":_PanelTopology.parentNumber:_online.._value",parents,
                  strServerName+":_PanelTopology.fileName:_online.._value",fileName,
                  strServerName+":_PanelTopology.panelType:_online.._value",panelType,
                  strServerName+":_PanelTopology.moduleName:_online.._value",moduleName,
                  strServerName+":_PanelTopology.menuBar:_online.._value",menuBar,
                  strServerName+":_PanelTopology.iconBar:_online.._value",iconBar,
                  strServerName+":_PanelTopology.modal:_online.._value",modal,
                  strServerName+":_PanelTopology.centered:_online.._value",centered,
                  strServerName+":_PanelTopology.parameter:_online.._value",parameter,
                  strServerName+":_PanelTopology.backwardPanel:_online.._value",back,
                  strServerName+":_PanelTopology.forwardPanel:_online.._value",forw,
                  strServerName+":_PanelTopology.upwardPanel:_online.._value",up,
                  strServerName+":_PanelTopology.downwardPanel:_online.._value",down,
                  strServerName+":_PanelTopology.permissionBit:_online.._value",permissionBit,
                  strServerName+":_PanelTopology.sumAlertNumber:_online.._value",alertNumber,
                  strServerName+":_PanelTopology.description:_online.._value",description,
                  strServerName+":_PanelTopology.locality:_online.._value",locality,
                  strServerName+":_PanelTopology.functionality:_online.._value",functionality,
                  strServerName+":_PanelTopology.panelLink:_online.._value",panellink,
                  strServerName+":_PanelTopology.panelNumber:_online.._value",panelNumber,
                  strServerName+":_PanelTopology.iconName:_online.._value",iconName);


    g_PanelTopologyCache[strServerName+":_PanelTopology.iconName:_online.._value"] = iconName ;
    g_PanelTopologyCache[strServerName+":_PanelTopology.panelNumber:_online.._value"] = panelNumber ;
    g_PanelTopologyCache[strServerName+":_PanelTopology.description:_online.._value"] = description ;
    g_PanelTopologyCache[strServerName+":_PanelTopology.locality:_online.._value"] = locality;
    g_PanelTopologyCache[strServerName+":_PanelTopology.functionality:_online.._value"] = functionality;
    g_PanelTopologyCache[strServerName+":_PanelTopology.panelLink:_online.._value"] = panellink;
    g_PanelTopologyCache[strServerName+":_PanelTopology.sumAlertNumber:_online.._value"]= alertNumber ;
    g_PanelTopologyCache[strServerName+":_PanelTopology.parentNumber:_online.._value"]= parents ;
    g_PanelTopologyCache[strServerName+":_PanelTopology.nodeName:_online.._value"]=nodeName;
    g_PanelTopologyCache[strServerName+":_PanelTopology.fileName:_online.._value"]=fileName;
    g_PanelTopologyCache[strServerName+":_PanelTopology.panelType:_online.._value"]=panelType;
    g_PanelTopologyCache[strServerName+":_PanelTopology.moduleName:_online.._value"]=moduleName;
    g_PanelTopologyCache[strServerName+":_PanelTopology.menuBar:_online.._value"]=menuBar;
    g_PanelTopologyCache[strServerName+":_PanelTopology.iconBar:_online.._value"]=iconBar;
    g_PanelTopologyCache[strServerName+":_PanelTopology.modal:_online.._value"]=modal;
    g_PanelTopologyCache[strServerName+":_PanelTopology.centered:_online.._value"]=centered;
    g_PanelTopologyCache[strServerName+":_PanelTopology.parameter:_online.._value"]=parameter;
    g_PanelTopologyCache[strServerName+":_PanelTopology.backwardPanel:_online.._value"]=back;
    g_PanelTopologyCache[strServerName+":_PanelTopology.forwardPanel:_online.._value"]=forw;
    g_PanelTopologyCache[strServerName+":_PanelTopology.upwardPanel:_online.._value"]=up;
    g_PanelTopologyCache[strServerName+":_PanelTopology.downwardPanel:_online.._value"]=down;
    g_PanelTopologyCache[strServerName+":_PanelTopology.permissionBit:_online.._value"]=permissionBit;
    g_PanelTopologyCache[strServerName+":_PanelTopology.permissionBit:_online.._stime"] = t;
  }
  return error;
}
