#uses "CtrlXmlRpc"
#uses "log.ctl"

mapping settings;
mapping eventsDP;

void main()
{
	Log::init("ONVIF", LogLevel::Trace);
	if (!loadSettings()) { Log::warning("main", "Failed to load settings!"); return; }
	Log::setLevel((LogLevel)settings["LogLevel"]);

	xmlrpcClient();

	subscribe();
	handleEvents();

	Log::info("main", "exit");
	exit();
}

void test()
{
	//mixed result = rpcCall("OnvifProtocolAdapter.test", makeDynMixed(0));
	//Log::info("main", "aaa"); DebugTN(result);

	//mixed result = rpcCall("OnvifProtocolAdapter.getSystemDateAndTime",
	//	makeDynMixed("http://192.168.128.158:8000"));
	//DebugTN(result);
	//exit();

	//mixed result = rpcCall("OnvifProtocolAdapter.subscribe",
	//	makeDynMixed(settings["Adapter"]["SubscriberUrl"], settings["Devices"][1]["Url"],
	//	settings["Devices"][1]["Username"], settings["Devices"][1]["Password"]));
	//DebugTN(result);
}

mixed rpcCall(string function, dyn_mixed args = makeDynMixed())
{
	Log::trace("rpcCall", "{function: %s}", function);

	string host = settings["Adapter"]["Host"]; int port = settings["Adapter"]["Port"];
	if (!xmlrpcConnectToServer("XMLRPC", host, port, false, "")) {
		Log::warning("rpcCall", "Failed to resolve XML-RPC host <%s>.", host); return false; }

	mixed result;
	if (xmlrpcCall("XMLRPC", function, args, result) == -1) {
		Log::error("rpcCall", "Failed to call XML-RPC function <%s>.", function); return false; }

	if (!xmlrpcCloseServer("XMLRPC"))
		Log::warning("rpcCall", "Failed to close connection to the XML-RPC server.");

	if (getType(result) == MIXED_VAR) {
		Log::error("rpcCall", "Failed to get a result from XML-RPC function <%s>.", function);
		return false; }

	if (getType(result) != MAPPING_VAR) return result;

	if (mappingHasKey(result, "ErrorCode") && result["ErrorCode"] != 0) {
		Log::error("rpcCall", "Failed to execute sucessfully XML-RPC function <%s> (%d: %s).\r\n%s",
			function, result["ErrorCode"], result["ErrorText"], result["ErrorDetails"]);
		return false; }

	if (mappingHasKey(result, "Data")) return result["Data"];

	return result;
}

bool getDP(string key, mixed &value)
{
	if (dpGet(key, value) == 0) return true;

	Log::error("getDP", "Failed to get dp <%s>.", key);
	return false;
}

bool setDP(string key, mixed value)
{
	if (dpSet(key, value) == 0) return true;

	Log::error("setDP", "Failed to set dp <%s>.", key);
	return false;
}

dyn_string formatEventData(mapping m)
{
	dyn_string result = makeDynString();
	for (int i = 1; i <= mappinglen(m); i++)
		result[i] = "Name: " + mappingGetKey(m, i) + ", Value: " + mappingGetValue(m, i);
	return result;
}

bool loadSettings()
{
	Log::trace("loadSettings");

	// General settings
	if (!getDP("_mp_ONVIF_Settings.LogLevel",
		settings["LogLevel"])) return false;

	// Adapter settings
	settings["Adapter"] = makeMapping();
	if (!getDP("_mp_ONVIF_Settings.Adapter.Host",
		settings["Adapter"]["Host"])) return false;
	if (!getDP("_mp_ONVIF_Settings.Adapter.Port",
		settings["Adapter"]["Port"]))	return false;
	if (!getDP("_mp_ONVIF_Settings.Adapter.SubscriberUrl",
		settings["Adapter"]["SubscriberUrl"])) return false;
	if (!getDP("_mp_ONVIF_Settings.Adapter.SubscriptionInterval",
		settings["Adapter"]["SubscriptionInterval"])) return false;
	if (!getDP("_mp_ONVIF_Settings.Adapter.PollingInterval",
		settings["Adapter"]["PollingInterval"])) return false;

	// Devices
	mixed devicesDP; settings["Devices"] = makeDynMapping();
	if (!getDP("_mp_ONVIF_Settings.DevicesDP", devicesDP)) return false;
	settings["DevicesDP"] = devicesDP;

	for (int i = 1; i <= sizeof(devicesDP); i++) {
		settings["Devices"][i] = makeMapping();
		if (!getDP(devicesDP[i] + ".Name",
			settings["Devices"][i]["Name"])) return false;
		if (!getDP(devicesDP[i] + ".Url",
			settings["Devices"][i]["Url"])) return false;
		if (!getDP(devicesDP[i] + ".Username",
			settings["Devices"][i]["Username"])) return false;
		if (!getDP(devicesDP[i] + ".Password",
			settings["Devices"][i]["Password"])) return false;
		if (!getDP(devicesDP[i] + ".EventDP",
			settings["Devices"][i]["EventDP"])) return false; }

	return true;
}

void subscribe()
{
	Log::trace("subscribe");

	for (int i = 1; i <= dynlen(settings["Devices"]); i++)
		subscribeToDevice(settings["DevicesDP"][i], settings["Devices"][i]);
}

bool subscribeToDevice(string deviceDP, mapping device)
{
	setDP(deviceDP + ".SubscriptionReference", "");

	mixed result = rpcCall("OnvifProtocolAdapter.subscribe",
		makeDynMixed(settings["Adapter"]["SubscriberUrl"], device["Url"],
		device["Username"], device["Password"]));
	if (getType(result) == BOOL_VAR && result == false) {
		Log::warning("main", "Failed to subscribe to events for device <%s>.", device["Name"]);
		return false; }

	string subscriptionReference = (string) result;
	Log::info("main", "Sucessfully subscribed to events for device <%s>.", device["Name"]);
	setDP(deviceDP + ".SubscriptionReference", subscriptionReference);
	eventsDP[subscriptionReference] = device["EventDP"];

	return true;
}

void handleEvents()
{
	Log::trace("handleEvents");

	while (true)
	{
		mixed result = rpcCall("OnvifProtocolAdapter.getNotifications",
			makeDynMixed(settings["Adapter"]["SubscriberUrl"]));

		if (dynlen(result) > 0) DebugTN(result); // Treba ukloniti u produkcijskoj verziji!

		if (getType(result) == BOOL_VAR && result == false)
			Log::warning("main", "Failed to get notifications.");
		else writeEvents(result);

		delay(0, settings["Adapter"]["PollingInterval"]); }
}

void writeEvents(dyn_mapping notifications)
{
	Log::trace("writeEvents");

	for (int i = 1; i <= dynlen(notifications); i++) {
		mapping notification = notifications[i];
		string eventDP = eventsDP[notification["ProducerReference"]];
		setDP(eventDP + ".Timestamp", notification["Timestamp"]);
		setDP(eventDP + ".SubscriptionReference", notification["SubscriptionReference"]);
		setDP(eventDP + ".ProducerReference", notification["ProducerReference"]);
		setDP(eventDP + ".Topic",	notification["Topic"]);
		setDP(eventDP + ".Message.Time", scanTimeUTC(notification["Message"]["UtcTime"]));
		setDP(eventDP + ".Message.PropertyOperation", notification["Message"]["PropertyOperation"]);
		if (mappingHasKey(notification["Message"], "Source"))
			setDP(eventDP + ".Message.Source", formatEventData(notification["Message"]["Source"]));
		if (mappingHasKey(notification["Message"], "Key"))
			setDP(eventDP + ".Message.Key", formatEventData(notification["Message"]["Key"]));
		if (mappingHasKey(notification["Message"], "Data"))
			setDP(eventDP + ".Message.Data", formatEventData(notification["Message"]["Data"])); }
}
