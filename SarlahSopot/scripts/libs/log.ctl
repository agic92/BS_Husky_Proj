enum LogLevel { Trace = 0, Info = 1, Warning = 2, Error = 3 };

class Log
{
	private static string name = "Log";
	private static LogLevel level = LogLevel::Trace;
	private static time lastLogTime = 0;

	public static void init(string logName, LogLevel logLevel) { name = logName; level = logLevel; }

	public static string getname() { return name; }
	public static LogLevel getLevel() { return logLevel; }
	public static void setLevel(LogLevel value) { level = value; }

	private static int write(string tag, string method, string format = "", ...)
	{
		time t = getCurrentTime();
		if (lastLogTime > 0 && (int)(t - lastLogTime) >= 1) DebugN("");
		lastLogTime = t;

		string data, output; va_list args; int l = va_start(args);
		if (l == 0) sprintf(data, format);
		else if (l == 1) sprintf(data, format, va_arg(args));
		else if (l == 2) sprintf(data, format, va_arg(args), va_arg(args));
		else if (l == 3) sprintf(data, format, va_arg(args), va_arg(args), va_arg(args));
		else if (l == 4) sprintf(data, format, va_arg(args), va_arg(args), va_arg(args), va_arg(args));
		else sprintf(data, format, va_arg(args), va_arg(args), va_arg(args), va_arg(args), va_arg(args));
		string output; sprintf(output, "[%s] %s at %s: %s", name, tag, method, data);
		return DebugTN(output);
	}

	public static int trace(string method, string format = "", ...)
	{
		if ((int)level > (int)LogLevel::Trace) return 1;
		va_list args; int l = va_start(args);
		return l == 0 ? write("TRACE", method, format) :
			write("TRACE", method, format, va_arg(args));
	}

	public static int info(string method, string format = "", ...)
	{
		if ((int)level > (int)LogLevel::Info) return 1;
		va_list args; va_start(args);
		return write("INFO", method, format, args);
	}

	public static int warning(string method, string format = "", ...)
	{
		if ((int)level > (int)LogLevel::Warning) return 1;
		va_list args; va_start(args);
		return write("WARNING", method, format, args);
	}

	public static int error(string method, string format = "", ...)
	{
		dyn_errClass err = getLastError();
		if (dynlen(err) > 0) format += " (" + getErrorText(err) + ")";
		va_list args; va_start(args);
		return write("ERROR", method, format, args);
	}

	public static int exception(string method, string format = "", ...)
	{
		dyn_errClass err = getLastException();
		if (dynlen(err) > 0) format += " (" + getErrorText(err) + ")";
		va_list args; va_start(args);
		return write("EXCEPTION", method, format, args);
	}
};

//------------------------------------------------------------------------------
// Changelog

// 2018.01.31 - v1.0
// Initial version.

//------------------------------------------------------------------------------
