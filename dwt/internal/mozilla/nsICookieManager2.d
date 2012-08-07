module dwt.internal.mozilla.nsICookieManager2;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsID;
import dwt.internal.mozilla.nsICookieManager;
import dwt.internal.mozilla.nsICookie2;
import dwt.internal.mozilla.nsStringAPI;

const char[] NS_ICOOKIEMANAGER2_IID_STR = "3e73ff5f-154e-494f-b640-3c654ba2cc2b";

const nsIID NS_ICOOKIEMANAGER2_IID= 
  {0x3e73ff5f, 0x154e, 0x494f, 
    [ 0xb6, 0x40, 0x3c, 0x65, 0x4b, 0xa2, 0xcc, 0x2b ]};

interface nsICookieManager2 : nsICookieManager {

  static const char[] IID_STR = NS_ICOOKIEMANAGER2_IID_STR;
  static const nsIID IID = NS_ICOOKIEMANAGER2_IID;

extern(System):
  nsresult Add(nsACString * aDomain, nsACString * aPath, nsACString * aName, nsACString * aValue, PRBool aSecure, PRBool aIsSession, PRInt64 aExpiry);
  nsresult FindMatchingCookie(nsICookie2 aCookie, PRUint32 *aCountFromHost, PRBool *_retval);
}

