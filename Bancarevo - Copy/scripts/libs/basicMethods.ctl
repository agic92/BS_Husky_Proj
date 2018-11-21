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

mapping fromDynStringToMap (dyn_string dynString)
{

    mapping returnMap;
    dyn_string mappingVariables;

    for (int i = 1; i <= dynlen(dynString); i++)
    {
        mappingVariables = strsplit(dynString[i], "|");
        string key = mappingVariables[1];
        string value = mappingVariables[dynlen(mappingVariables)];
        if (value == "-")
        {
            value = "";
        }
        returnMap[key] = value;
    }
    return returnMap;
}
