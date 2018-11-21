#uses "log.ctl"
#uses "latin_to_cyrillic.ctl"

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

mapping getMapfromDynString (dyn_string dynString)
{

    mapping returnMap;
    dyn_string mappingVariables;

    for (int i = dynlen(dynString); i >= 1; i--)
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

mapping fromNumberToMonthName()
{
    mapping returnMap;
    returnMap[1] = latinToCyrillic("Januar");
    returnMap[2] = latinToCyrillic("Februar");
    returnMap[3] = latinToCyrillic("Mart");
    returnMap[4] = latinToCyrillic("April");
    returnMap[5] = latinToCyrillic("Maj");
    returnMap[6] = latinToCyrillic("Juni");
    returnMap[7] = latinToCyrillic("Juli");
    returnMap[8] = latinToCyrillic("August");
    returnMap[9] = latinToCyrillic("Septembar");
    returnMap[10] = latinToCyrillic("Oktobar");
    returnMap[11] = latinToCyrillic("Novembar");
    returnMap[12] = latinToCyrillic("Decembar");

    return returnMap;
}

mapping getMapfromDatapoint (string datapointName)
{
    dyn_string dynStringReportFunctions;

    if(!dpExists(datapointName))
    {
        Log::error("dpExists", "Datapoint does not exist <%s>.", datapointName);
        return makeMapping();
    }

    getDP(datapointName, dynStringReportFunctions);
    return getMapfromDynString(dynStringReportFunctions);
}
