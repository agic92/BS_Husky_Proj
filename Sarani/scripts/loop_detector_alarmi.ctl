/*******************************************************************************
  Name:        LoopDetector
  Description: Loop detector / Traffic counter
  Version:     1.4.1
    
  Note:
    LogLevel: 0 - debug, 1 - trace, 2 - info, 3 - warning, 4 - error
    Alarm: 0 - none, 1 - wrong direction, 2 - loop fault, 3 - traffic jam, 4 - bumper to bumper, 5 - lost connection.
********************************************************************************/

#uses "CtrlXmlRpc"
#uses "loop_detector_ini.ctl" // devices, serverID.

mapping settings;
int globalLock = 0;
dyn_int locks;
dyn_mapping lastVehicles;
mapping alarms;
mapping scriptBlocked;
mapping threads;
time lastLogTime = 0;

int main()
{
  
  alarms = makeMapping(
    0, "none", 1, "wrong direction", 2, "loop fault",
    3, "traffic jam", 4, "bumper to bumper");
  
  settings = makeMapping(
    "ServerIpAddress", "127.0.0.1",
    "ServerPort", 8484,
    "DevicesCount", 0,
    "LoopDelay", 1,
    "LogLevel", 1);
  loadSettings();
  writeInfo("main", "LoopDetector is running.");
  
  locks = makeDynInt();
  xmlrpcClient();
  
  int count = settings["DevicesCount"];
  for (int i = 1; i <= count; i++) { threads[i] = -1; startDeviceThread(i); }
  
  if (timedFunc("onCheckScriptBlocked", "LoopDetector_CheckScriptBlocked") != 0)
    writeWarning("main", "Failed to set timed function LoopDetector_CheckScriptBlocked.");
}

mapping makeMapping(...)
{
  mapping m;
  va_list params;
  int count = va_start(params);
  for (int i = 1; i <= count; i+= 2) m[params[i]] = params[i + 1];
  va_end(params);
  return m;
}
mapping addMapping(mapping m, string key, mixed value) { m[key] = value; return m; }

string formatString(string format, anytype arg1 = "", anytype arg2 = "",
  anytype arg3 = "", anytype arg4 = "", anytype arg5 = "")
{
  string value;
  if (sprintf(value, format, arg1, arg2, arg3, arg4, arg5) > -1) return value;
  else return "";
}

int writeLog(string tag, string method, string data = "")
{
  time t = getCurrentTime();
  if ((int)(t - lastLogTime) >= 1) DebugN("");
  lastLogTime = t;
  return DebugTN(formatString("LoopDetector - %s at %s: %s", tag, method, data));
}

int writeTrace(string method, string data = "")
{
  return settings["LogLevel"] <= 1 ? writeLog("TRACE", method, data) : 1;
}

int writeInfo(string method, string data = "")
{
  return settings["LogLevel"] <= 2 ? writeLog("INFO", method, data) : 1;
}

int writeWarning(string method, string data = "")
{
  return settings["LogLevel"] <= 3 ? writeLog("WARNING", method, data) : 1;
}

bool writeDebugTrace(int id, string source, string message, anytype data)
{
  if (settings["LogLevel"] > 0) return true;
  
  string dataPoint = devices[id] + ".DebugTrace"; string dp;
  if (dpSet(dp = dataPoint + ".Source", source) != 0) {
    errorHandler(); writeWarning("writeDebugTrace", dp); return false; }
  if (dpSet(dp = dataPoint + ".Message", message) != 0) {
    errorHandler(); writeWarning("writeDebugTrace", dp); return false; }
  if (dpSet(dp = dataPoint + ".Data", data) != 0) {
    errorHandler(); writeWarning("writeDebugTrace", dp); return false; }
  return true;
}

bool errorHandler()
{
  dyn_errClass error = getLastError(); if (dynlen(error) == 0) return false;
  DebugTN("ERROR: " + getErrorText(error) + "\r\n" + getErrorStackTrace(error));
  return true;
}

bool exceptionHandler()
{
  dyn_errClass error = getLastException(); if (dynlen(error) == 0) return false;
  DebugTN("EXCEPTION: " + getErrorText(error) + "\r\n" + getErrorStackTrace(error));
  return true;
}

bool getGlobalLock()
{
  int threadId = getThreadId();
  while ((globalLock != 0) && (globalLock != threadId)) delay(0, 50);
  globalLock = threadId; return true;
}
bool releaseGlobalLock() { globalLock = 0; return true; }

bool getLock(int id)
{
  int threadId = getThreadId();
  while ((locks[id] != 0) && (locks[id] != threadId)) delay(0, 50);
  locks[id] = threadId; return true;
}
bool releaseLock(int id) { locks[id] = 0; return true; }

void loadSettings()
{
  mixed value;
  if (dpGet("LoopDetector_Settings.ServerIpAddress", value) == 0)
    settings["ServerIpAddress"] = value;
  if (dpGet("LoopDetector_Settings.ServerPort", value) == 0)
    settings["ServerPort"] = value;
  if (dpGet("LoopDetector_Settings.DevicesCount", value) == 0)
    settings["DevicesCount"] = value;
  if (dpGet("LoopDetector_Settings.LoopDelay", value) == 0)
    settings["LoopDelay"] = value;
  if (dpGet("LoopDetector_Settings.LogLevel", value) == 0)
    settings["LogLevel"] = value;
  writeInfo("loadSettings", settings);
}

mapping getServerSettings(int id)
{
  mapping result;
  string device = devices[id];
  result["Comm_Protocol"] = "TCP";
  result["TcpClient_IpAddress"] = dpGetOrDefault(device + ".DeviceIpAddress", "");
  result["TcpClient_Port"] = dpGetOrDefault(device + ".DevicePort", 0);
  return result;
}

anytype dpGetOrDefault(string name, anytype defaultValue)
{
  anytype value;
  if (dpGet(name, value) == 0) return value;
  else return defaultValue;
}

bool rpcConnect(int id)
{
  string device = devices[id];
  string host = dpGetOrDefault(device + ".ServerIpAddress", "");
  if (host == "") host = settings["ServerIpAddress"];
  int port = dpGetOrDefault(device + ".ServerPort", "");
  if (port == 0) port = settings["ServerPort"];
  
  writeDebugTrace(id, "rpcConnect", "Before connect.", formatString("device: %s", device));
  if (!xmlrpcConnectToServer(device, host, port, false)) { errorHandler(); return false; }
  writeDebugTrace(id, "rpcConnect", "After connect.", formatString("device: %s", device));
  return true;
}

bool rpcDisconnect(int id)
{
  string device = devices[id];
  writeDebugTrace(id, "rpcDisconnect", "Before disconnect.", formatString("device: %s", device));
  if (!xmlrpcCloseServer(device)) { errorHandler(); return false; }
  writeDebugTrace(id, "rpcDisconnect", "After disconnect.", formatString("device: %s", device));
  return true;
}

bool rpcCall(int id, string name, dyn_mixed args, mixed &result)
{
  string device = devices[id];
  rpcConnect(id);
  
  writeDebugTrace(id, "rpcCall", "Before call.",
    formatString("device: %s, name: %s, args: {%s}", device, name, args));
  int success = xmlrpcCall(device, name, args, result);
  writeDebugTrace(id, "rpcCall", "After call.",
    formatString("device: %s, name: %s, args: {%s}, success: %s", device, name, args, success));
  if (success != 0) { errorHandler(); return false; }
  
  if (mappinglen(result) == 0)
    writeWarning(formatString("rpcCall (device: %s, name: %s, args: {%s})", device, name, args),
      "Server returned empty result.");
  else writeTrace(formatString("rpcCall (device: %s, name: %s, args: {%s})", device, name, args),
    "Server returned valid data.");
  
  rpcDisconnect(id);
  return true;
}

bool isServerActive()
{
  string dp = (isPrimaryServer ? "_ReduManager" : "_ReduManager_2") + ".Status.Active";
  return dpGetOrDefault(dp, false);
}

void setConnectionTimestamp()
{
  string dp = (isPrimaryServer ? "BrojacPrometa" : "BrojacPrometa_2") + ".IntegrClient.timestamp";
  if (dpSet(dp, getCurrentTime()) != 0) {
    errorHandler(); writeWarning("setConnectionTimestamp", dp); }
}

void startDeviceThread(int id)
{
  writeTrace("startDeviceThread", formatString("id: %s", id));
  
  if (threads[id] >= 0) if (stopThread(threads[id]) == -1)
    writeWarning("startDeviceThread", formatString(
      "Thread for device [%s] failed to stop.", devices[id]));
  
  locks[id] = 0; setScriptBlocked(id, false);
  if ((threads[id] = startThread("threadProc", id)) == -1)
    writeWarning("startDeviceThread", formatString(
      "Thread for device [%s] failed to start.", devices[id]));
  
  writeInfo("startDeviceThread", formatString(
    "Thread for device [%s] started with id [%s].", devices[id], threads[id]));
}

void threadProc(int id)
{
  writeTrace("threadProc", formatString("id: %s", id));
  
  string name = devices[id];
  string query = "SELECT '_online.._value' FROM '" +
    formatString("%s.CounterReset.Process", name) +
    "' WHERE _DPT = \"LoopDetector\"";
  int success = dpQueryConnectSingle("doCounterReset", true, id, query);
  if (success != 0) {
    errorHandler();
    writeWarning("threadProc", formatString(
      "Failed to set connect to CounterReset for device [%s].", devices[id])); }
  
  while (true) {
    if (isServerActive()) getDataFromDevice(id);
    setScriptBlocked(id, false); setConnectionTimestamp(); delay(settings["LoopDelay"]); }
}

bool getDataFromDevice(int id)
{
  writeTrace("getDataFromDevice", formatString("id: %s", id));
  
  getLock(id);
  try {
    mapping data;
    
    if (getVehicleData(id, data)) {
      if (!storeVehicleData(id, data))
        writeWarning("getDataFromDevice", formatString(
          "Failed to store VehicleData for device [%s].", devices[id])); }
    else
      writeWarning("getDataFromDevice", formatString(
        "Failed to get VehicleData for device [%s].", devices[id]));
    
    if (getVehicleCounter(id, data)) {
      if (!storeVehicleCounter(id, data))
        writeWarning("getDataFromDevice", formatString(
          "Failed to store VehicleCounter for device [%s].", devices[id])); }
    else
      writeWarning("getDataFromDevice", formatString(
          "Failed to get VehicleCounter for device [%s].", devices[id])); }
  catch { exceptionHandler(); }
  
  releaseLock(id);
  return true;
}

void doCounterReset(anytype userData, dyn_dyn_anytype value)
{
  writeTrace("doCaunterReset", formatString("userData: %s", userData));
  
  int id = userData; bool reset = value[2][2];
  if (!reset) return;
  
  bool success = executeCounterReset(id);
  
  string dp = devices[id] + ".CounterReset.Success";
  if (dpSet(dp, success) != 0) { errorHandler(); writeWarning("doCounterReset", dp); return; }

  dp = devices[id] + ".CounterReset.Process";
  if (dpSet(dp, false) != 0) { errorHandler(); writeWarning("doCounterReset", dp); return; }
}

bool executeCounterReset(int id)
{
  writeTrace("executeCounterReset", formatString("id: %s", id));  
  
  bool result = false;
  getLock(id);
  
  try {
    if (rpcConnect(id)) {
      
      string device = devices[id];
      int address = dpGetOrDefault(device + ".DeviceBusAddress", 50);
      mapping serverSettings = getServerSettings(id);
  
      rpcCall(id, "LoopDetectorProtocolAdapter.executeCounterReset",
        makeDynMixed(serverSettings, address), result);
  
      if (result) writeInfo("executeCounterReset",
        formatString("CounterReset for device [%s] executed.", devices[id]));
      else writeInfo("executeCounterReset",
       formatString("CounterReset for device [%s] failed to execute.", devices[id])); }}
  catch { exceptionHandler(); }
  
  releaseLock(id);
  return result;
}

bool getVehicleData(int id, mapping &data)
{
  writeTrace("getVehicleData", formatString("id: %s", id));  
  
  try {
    if (rpcConnect(id)) {
    
    string device = devices[id];
    int address = dpGetOrDefault(device + ".DeviceBusAddress", 50);
    mapping serverSettings = getServerSettings(id);
  
    mapping result;
    if (rpcCall(id, "LoopDetectorProtocolAdapter.getVehicleData",
                makeDynMixed(serverSettings, 1, address, 0x1F), result)) {
      data["Module1"] = result;
      if (!mappingHasKey(result, "VehicleDataCount")) storeAlarm(id,0,5); }
    else storeAlarm(id,0,5);
  
    if (rpcCall(id, "LoopDetectorProtocolAdapter.getVehicleData",
      makeDynMixed(serverSettings, 2, address, 0x1F), result)) {
      data["Module2"] = result;
      if (!mappingHasKey(result, "VehicleDataCount")) storeAlarm(id,1,5); }
    else storeAlarm(id,1,5);
  }
	  
    else writeWarning("getVehicleData", formatString(
      "Failed to connect to the server for device [%s].", devices[id])); }
  
  catch { exceptionHandler(); }
  
  return true;
}

bool getVehicleCounter(int id, mapping &data)
{
  writeTrace("getVehicleCounter", formatString("id: %s", id));
  
  try {
    if (rpcConnect(id)) {
      
      string device = devices[id];
      int address = dpGetOrDefault(device + ".DeviceBusAddress", 50);
      mapping serverSettings = getServerSettings(id);
  
      mapping result;
      if (rpcCall(id, "LoopDetectorProtocolAdapter.getVehicleCounter",
                  makeDynMixed(serverSettings, 1, address, 0x0F), result)) {
        data["Module1"] = result;
        if (!mappingHasKey(result, key = "Counters")) storeAlarm(id, 0, 5); }
      else storeAlarm(id, 0, 5);
      if (rpcCall(id, "LoopDetectorProtocolAdapter.getVehicleCounter",
                  makeDynMixed(serverSettings, 2, address, 0x0F), result)) {
        data["Module2"] = result; 
        if (!mappingHasKey(result, key = "Counters")) storeAlarm(id, 1, 5); }
      else storeAlarm(id, 1, 5);
    }
		
    else writeWarning("getVehicleCounter", formatString(
      "Failed to connect to the server for device [%s].", devices[id])); }
	  
    catch { exceptionHandler(); }
  
  return true;
}

bool storeVehicleData(int id, mapping &data)
{
  writeTrace("storeVehicleData", formatString("id: %s, data: %s", id, data));
  
  string method = "storeVehicleData";
  string dataPoint = devices[id] + ".VehicleData";
  
  for (int i = 0; i < 2; i++) {
  string key; string dpModule = key = i == 0 ? "Module1" : "Module2";
  
  if (mappingHasKey(data, key)) {
    mapping module = data[key];
    
    if (mappingHasKey(module, key = "VehicleDataCount")) {
      int vehicleDataCount = module[key];
      string dp = dataPoint + "." + dpModule + ".VehicleDataCount";
      if (dpSet(dp, vehicleDataCount) != 0) { errorHandler(); writeWarning(method, dp); return false; }}
    
      if (mappingHasKey(module, key = "LoopStatus")) {
        mapping loopStatus = module[key];
      
        if (mappingHasKey(loopStatus, key = "FirstLoop")) {
          mapping firstLoop = loopStatus[key];
          if (mappingHasKey(firstLoop, key = "AdjustmentState")) {
            string dp = dataPoint + "." + dpModule + ".LoopStatus.FirstLoop.AdjustmentState";
            if (dpSet(dp, firstLoop[key]) != 0) { errorHandler(); writeWarning(method, dp); return false; }}
          if (mappingHasKey(firstLoop, key = "FaultState")) {
            string dp = dataPoint + "." + dpModule + ".LoopStatus.FirstLoop.FaultState";
            if (dpSet(dp, firstLoop[key]) != 0) { errorHandler(); writeWarning(method, dp); return false; }}}
          
        if (mappingHasKey(loopStatus, key = "SecondLoop")) {
          mapping secondLoop = loopStatus[key];
          if (mappingHasKey(secondLoop, key = "AdjustmentState")) {
            string dp = dataPoint + "." + dpModule + ".LoopStatus.SecondLoop.AdjustmentState";
            if (dpSet(dp, secondLoop[key]) != 0) { errorHandler(); writeWarning(method, dp); return false; }}
          if (mappingHasKey(secondLoop, key = "FaultState")) {
            string dp = dataPoint + "." + dpModule + ".LoopStatus.SecondLoop.FaultState";
            if (dpSet(dp, secondLoop[key]) != 0) { errorHandler(); writeWarning(method, dp); return false; }}}
      
        if (mappingHasKey(loopStatus, key = "TrafficJam")) {
          string dp = dataPoint + "." + dpModule + ".LoopStatus.TrafficJam";
          if (dpSet(dp, loopStatus[key]) != 0) { errorHandler(); writeWarning(method, dp); return false; }}}
        
      if (mappingHasKey(module, key = "VehicleDataBlocks")) {
        dyn_mixed vehicleDataBlocks = module[key];
        for (int j = 0; j < dynlen(vehicleDataBlocks); j++) {
          mapping dataBlock = vehicleDataBlocks[j + 1];
          
          int alarm = getAlarmFromVehicleData(id, dpModule, dataBlock);
          if (alarm == 0) lastVehicles[id] = dataBlock;
          else {
            storeAlarm(id, i, alarm);
            if (alarm > 1) {
              dataBlock["VehicleClass"] = 0;
              dataBlock["VehicleLength"] = 0;
              dataBlock["VehicleSpeed"] = 0; }}
          
          if (mappingHasKey(dataBlock, key = "VehicleClass")) {
            string dp = dataPoint + "." + dpModule + ".VehicleDataBlocks." + j + ".VehicleClass";
            if (dpSet(dp, dataBlock[key]) != 0) { errorHandler(); writeWarning(method, dp); return false; }}
          
          if (mappingHasKey(dataBlock, key = "DrivingDirection")) {
            string dp = dataPoint + "." + dpModule + ".VehicleDataBlocks." + j + ".DrivingDirection";
            if (dpSet(dp, dataBlock[key]) != 0) { errorHandler(); writeWarning(method, dp); return false; }}
          
          if (mappingHasKey(dataBlock, key = "VehicleLength")) {
            string dp = dataPoint + "." + dpModule + ".VehicleDataBlocks." + j + ".VehicleLength";
            if (dpSet(dp, dataBlock[key]) != 0) { errorHandler(); writeWarning(method, dp); return false; }}
          
          if (mappingHasKey(dataBlock, key = "VehicleSpeed")) {
            string dp = dataPoint + "." + dpModule + ".VehicleDataBlocks." + j + ".VehicleSpeed";
            if (dpSet(dp, dataBlock[key]) != 0) { errorHandler(); writeWarning(method, dp); return false; }}
          
          if (mappingHasKey(dataBlock, key = "TimeGap")) {
            string dp = dataPoint + "." + dpModule + ".VehicleDataBlocks." + j + ".TimeGap";
            if (dpSet(dp, dataBlock[key]) != 0) { errorHandler(); writeWarning(method, dp); return false; }}
          
          if (mappingHasKey(dataBlock, key = "BusyTime")) {
            string dp = dataPoint + "." + dpModule + ".VehicleDataBlocks." + j + ".BusyTime";
            if (dpSet(dp, dataBlock[key]) != 0) { errorHandler(); writeWarning(method, dp); return false; }}}}}}
  
  return true;
}

bool storeVehicleCounter(int id, mapping &data)
{
  writeTrace("storeVehicleCounter", formatString("id: %s, data: %s", id, data));  
  
  string method = "storeVehicleData";
  string dataPoint = devices[id] + ".VehicleCounter";
  
  for (int i = 0; i < 2; i++) {
  string key; string dpModule = key = i == 0 ? "Module1" : "Module2";
  
  if (mappingHasKey(data, key)) {
    mapping module = data[key];
    
    if (mappingHasKey(module, key = "Counters")) {
      mapping counters = module[key];
      
      for (int i = 0; i < 2; i++) {
        string dir = key = i == 0 ? "direction1" : "direction2";
        if (mappingHasKey(counters, key)) {
          mapping direction = counters[key];
          
           if (mappingHasKey(direction, key = "Other")) {
             string dp = dataPoint + "." + dpModule + ".Counters." + dir + ".Other";
             if (dpSet(dp, direction[key]) != 0) { errorHandler(); writeWarning(method, dp); return false; }}

           if (mappingHasKey(direction, key = "Car")) {
             string dp = dataPoint + "." + dpModule + ".Counters." + dir + ".Car";
             if (dpSet(dp, direction[key]) != 0) { errorHandler(); writeWarning(method, dp); return false; }}

           if (mappingHasKey(direction, key = "CarWithTrailer")) {
             string dp = dataPoint + "." + dpModule + ".Counters." + dir + ".CarWithTrailer";
             if (dpSet(dp, direction[key]) != 0) { errorHandler(); writeWarning(method, dp); return false; }}

           if (mappingHasKey(direction, key = "Lorry")) {
             string dp = dataPoint + "." + dpModule + ".Counters." + dir + ".Lorry";
             if (dpSet(dp, direction[key]) != 0) { errorHandler(); writeWarning(method, dp); return false; }}

           if (mappingHasKey(direction, key = "LorryWithTrailer")) {
             string dp = dataPoint + "." + dpModule + ".Counters." + dir + ".LorryWithTrailer";
             if (dpSet(dp, direction[key]) != 0) { errorHandler(); writeWarning(method, dp); return false; }}

           if (mappingHasKey(direction, key = "Bus")) {
             string dp = dataPoint + "." + dpModule + ".Counters." + dir + ".Bus";
             if (dpSet(dp, direction[key]) != 0) { errorHandler(); writeWarning(method, dp); return false; }}

           if (mappingHasKey(direction, key = "Motorbike")) {
             string dp = dataPoint + "." + dpModule + ".Counters." + dir + ".Motorbike";
             if (dpSet(dp, direction[key]) != 0) { errorHandler(); writeWarning(method, dp); return false; }}

           if (mappingHasKey(direction, key = "Van")) {
             string dp = dataPoint + "." + dpModule + ".Counters." + dir + ".Van";
             if (dpSet(dp, direction[key]) != 0) { errorHandler(); writeWarning(method, dp); return false; }}

           if (mappingHasKey(direction, key = "Truck")) {
             string dp = dataPoint + "." + dpModule + ".Counters." + dir + ".Truck";
             if (dpSet(dp, direction[key]) != 0) { errorHandler(); writeWarning(method, dp); return false; }}}}}
           
    if (mappingHasKey(module, key = "Sums")) {
      mapping sums = module[key];
      
      for (int j = 0; j < 2; j++) {
        string dir = key = j == 0 ? "direction1" : "direction2";
        if (mappingHasKey(sums, key)) {
          mapping direction = sums[key];
          
           if (mappingHasKey(direction, key = "Car")) {
             string dp = dataPoint + "." + dpModule + ".Sums." + dir + ".Car";
             if (dpSet(dp, direction[key]) != 0) { errorHandler(); writeWarning(method, dp); return false; }}

           if (mappingHasKey(direction, key = "Lorry")) {
             string dp = dataPoint + "." + dpModule + ".Sums." + dir + ".Lorry";
             if (dpSet(dp, direction[key]) != 0) { errorHandler(); writeWarning(method, dp); return false; }}

           if (mappingHasKey(direction, key = "LightTraffic")) {
             string dp = dataPoint + "." + dpModule + ".Sums." + dir + ".LightTraffic";
             if (dpSet(dp, direction[key]) != 0) { errorHandler(); writeWarning(method, dp); return false; }}

           if (mappingHasKey(direction, key = "HeavyGoods")) {
             string dp = dataPoint + "." + dpModule + ".Sums." + dir + ".HeavyGoods";
             if (dpSet(dp, direction[key]) != 0) { errorHandler(); writeWarning(method, dp); return false; }}

           if (mappingHasKey(direction, key = "BusAndCarWithTrailer")) {
             string dp = dataPoint + "." + dpModule + ".Sums." + dir + ".BusAndCarWithTrailer";
             if (dpSet(dp, direction[key]) != 0) { errorHandler(); writeWarning(method, dp); return false; }}

           if (mappingHasKey(direction, key = "HeavyTraffic")) {
             string dp = dataPoint + "." + dpModule + ".Sums." + dir + ".HeavyTraffic";
             if (dpSet(dp, direction[key]) != 0) { errorHandler(); writeWarning(method, dp); return false; }}

           if (mappingHasKey(direction, key = "All")) {
             string dp = dataPoint + "." + dpModule + ".Sums." + dir + ".All";
             if (dpSet(dp, direction[key]) != 0) { errorHandler(); writeWarning(method, dp); return false; }}

           if (mappingHasKey(direction, key = "CounterLoopCrossing")) {
             string dp = dataPoint + "." + dpModule + ".Sums." + dir + ".CounterLoopCrossing";
             if (dpSet(dp, direction[key]) != 0) { errorHandler(); writeWarning(method, dp); return false; }}}}}}}
  
  return true;
}

int getAlarmFromVehicleData(int id, string module, mapping &data)
{
  writeTrace("getAlarmFromVehicleData", formatString("id: %s, module: %s", id, module));  
  
  string key; int class = -1, direction = -1, length = -1, speed = -1;
  if (mappingHasKey(data, key = "VehicleClass")) class = data[key];
  if (mappingHasKey(data, key = "DrivingDirection")) direction = data[key];
  if (mappingHasKey(data, key = "VehicleLength")) length = data[key];
  if (mappingHasKey(data, key = "VehicleSpeed")) speed = data[key];
  
  if (class == 0 && length == 40 && speed == 0) return 2;
  if (class == 0 && length == 40 && speed == 5) return 3;
  if (class == 0 && length == 45 && speed == lastVehicles[id]["VehicleSpeed"]) return 4;
  
  int moduleDirection = dpGetOrDefault(devices[id] + "." + module + ".Direction", 1);
  if (direction != moduleDirection) return 1; 
  
  return 0;
}

bool storeAlarm(int id, int module, int alarm)
{
  writeTrace("storeAlarm", formatString("id: %s, alarm: %s", id, alarm));  
  
  string method = "storeAlarm";
  string dpDevice = devices[id];
  
  string dpModule = module == 0 ? "Module1" : "Module2";
  string dp = dpDevice + "." + dpModule + ".Vehicle.Alarm";
  if (dpSet(dp, alarm) != 0) { errorHandler(); writeWarning(method, dp); return false; }
  if (dpSet(dp, 0) != 0) { errorHandler(); writeWarning(method, dp); return false; }
  writeInfo("storeAlarm", formatString(
    "Alarm [%s] stored for device [%s], module [%s].", alarms[alarm], dpDevice, dpModule));
  
  return true;
}

void onCheckScriptBlocked(string dp, time before, time now, bool call)
{
  writeTrace("onCheckScriptBlocking");
  
  string method = "onCheckScriptBlocked";
  int count = settings["DevicesCount"];
  
  for (int i = 1; i <= count; i++)
    if (!scriptBlocked[i]) scriptBlocked[i] = true;
    else setScriptBlocked(i, true);
}

bool setScriptBlocked(int id, bool blocked)
{
  writeTrace("setScriptBlocked", formatString("id: %s, blocked: %s", id, blocked));
  
  string dpDevice = devices[id];
  string dp = dpDevice + ".Alarms.ScriptBlocked";
  
  bool alarm = dpGetOrDefault(dp, !blocked);
  if (blocked != alarm) {
    if (dpSet(dp, blocked) != 0) { errorHandler(); writeWarning(method, dp); return false; }
    writeInfo("setScriptBlocked", formatString(
      "Script for device [%s] is %s.", dpDevice, blocked ? "blocked" : "unblocked")); }
  scriptBlocked[id] = blocked;
  
  if (blocked) startDeviceThread(id);
}
