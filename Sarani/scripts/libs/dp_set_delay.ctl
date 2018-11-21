// Non blocking dpSet call delayed by given seconds
// Returns an integer that is the handle to the thread created for the timer
// instance.  "Handle" is need if you plan to call dpSetStop to stop the timer
// prior to it actually setting the DP.
int dpSetDelayed(int secs, string dp, anytype val)
{
  return(startThread("dpSetDelayed_thread",secs,dp,val));
}

// Stop a delayed dpSet created by a prior call to dpSetDelayed
// "handle" is the integer value returned by the previous call to dpSetDelayed
// Returns 0 is the stopThread call succeeded.  Returns -1 if the stopThread
// call failed (ie the delay completed and the dpSet has aleady been 
// implemented).
int dpSetStop(int handle)
{
  return(stopThread(handle));
}

// This is the thread that implements the delay and dpSet
void dpSetDelayed_thread(int secs, string dp, anytype val)
{
  delay(secs);
  dpSet(dp,val);
}

int dpGetDelayed(int secs, string dp, anytype val)
{
  return(startThread("dpGetDelayed_thread",secs,dp,val));
}

int dpGetStop(int handle)
{
  return(stopThread(handle));
}

void dpGetDelayed_thread(int secs, string dp, anytype val)
{
  delay(secs);
  dpGet(dp,val);
}
