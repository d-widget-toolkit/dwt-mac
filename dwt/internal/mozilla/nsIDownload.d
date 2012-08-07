module dwt.internal.mozilla.nsIDownload;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsISupports;
import dwt.internal.mozilla.nsID;
import dwt.internal.mozilla.nsITransfer;
import dwt.internal.mozilla.nsIWebProgressListener;
import dwt.internal.mozilla.nsIURI; 
import dwt.internal.mozilla.nsILocalFile;
import dwt.internal.mozilla.nsIObserver; 
import dwt.internal.mozilla.nsICancelable;
import dwt.internal.mozilla.nsIMIMEInfo; 
import dwt.internal.mozilla.nsStringAPI;
import dwt.internal.mozilla.prtime;

const char[] NS_IDOWNLOAD_IID_STR = "9e1fd9f2-9727-4926-85cd-f16c375bba6d";

const nsIID NS_IDOWNLOAD_IID= 
  {0x9e1fd9f2, 0x9727, 0x4926, 
    [ 0x85, 0xcd, 0xf1, 0x6c, 0x37, 0x5b, 0xba, 0x6d ]};

interface nsIDownload : nsISupports {

  static const char[] IID_STR = NS_IDOWNLOAD_IID_STR;
  static const nsIID IID = NS_IDOWNLOAD_IID;

extern(System):
  nsresult Init(nsIURI aSource, nsIURI aTarget, nsAString* aDisplayName, nsIMIMEInfo aMIMEInfo, PRTime startTime, PRBool aPersist);
  nsresult GetSource(nsIURI  *aSource);
  nsresult GetTarget(nsIURI  *aTarget);
  nsresult GetPersist(PRBool *aPersist);
  nsresult GetPercentComplete(PRInt32 *aPercentComplete);
  nsresult GetDisplayName(PRUnichar * *aDisplayName);
  nsresult SetDisplayName(PRUnichar* aDisplayName);
  nsresult GetStartTime(PRInt64 *aStartTime);
  nsresult GetMIMEInfo(nsIMIMEInfo  *aMIMEInfo);
  nsresult GetListener(nsIWebProgressListener* aListener);
  nsresult SetListener(nsIWebProgressListener aListener);
  nsresult GetObserver(nsIObserver * aObserver);
  nsresult SetObserver(nsIObserver aObserver);
}
