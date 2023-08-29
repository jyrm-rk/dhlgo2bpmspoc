package GO2_Review;

// -----( IS Java Code Template v1.2

import com.wm.data.*;
import com.wm.util.Values;
import com.wm.app.b2b.server.Service;
import com.wm.app.b2b.server.ServiceException;
// --- <<IS-START-IMPORTS>> ---
import com.softwareag.util.IDataMap;
import java.util.concurrent.ThreadLocalRandom;
// --- <<IS-END-IMPORTS>> ---

public final class util

{
	// ---( internal utility methods )---

	final static util _instance = new util();

	static util _newInstance() { return new util(); }

	static util _cast(Object o) { return (util)o; }

	// ---( server methods )---




	public static final void generateCountryRandom (IData pipeline)
        throws ServiceException
	{
		// --- <<IS-START(generateCountryRandom)>> ---
		// @sigtype java 3.5
		// [o] field:0:required country
		IDataMap idm=new IDataMap(pipeline);
		int i=ThreadLocalRandom.current().nextInt(0, 3);
		
		idm.put("country", countries[i]);
		// --- <<IS-END>> ---

                
	}



	public static final void generateRandomString (IData pipeline)
        throws ServiceException
	{
		// --- <<IS-START(generateRandomString)>> ---
		// @sigtype java 3.5
		// [o] field:0:required str
		IDataMap idm=new IDataMap(pipeline);
		StringBuilder sb=new StringBuilder();
		
		for(int i=0;i<3;i++) {
			sb.append(candidateChars.charAt(ThreadLocalRandom.current().nextInt(0, candidateChars.length())));
		}
				
		idm.put("str", sb.toString() );
		// --- <<IS-END>> ---

                
	}



	public static final void sleepRandom (IData pipeline)
        throws ServiceException
	{
		// --- <<IS-START(sleepRandom)>> ---
		// @sigtype java 3.5
		//Sleep up to 5 seconds
		
		IDataMap idm=new IDataMap(pipeline);
		try {
			long sleepAmountInMilliseconds= ThreadLocalRandom.current().nextLong(100, 5000);
			//idm.put("slept", Long.toString(sleepAmountInMilliseconds));
			Thread.sleep(sleepAmountInMilliseconds);
		} catch(Exception ex) {
			idm.put("except", ex.toString());
		}
		// --- <<IS-END>> ---

                
	}

	// --- <<IS-START-SHARED>> ---
	static String candidateChars="ABCDEFG";
	static String[] countries={"SG","MY","AU"};
	// --- <<IS-END-SHARED>> ---
}

