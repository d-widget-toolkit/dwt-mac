module dwt.internal.mozilla.nsIWebNavigationInfo;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsID;
import dwt.internal.mozilla.nsISupports;
import dwt.internal.mozilla.nsIWebNavigation;
import dwt.internal.mozilla.nsStringAPI;

const char[] NS_IWEBNAVIGATIONINFO_IID_STR = "62a93afb-93a1-465c-84c8-0432264229de";

const nsIID NS_IWEBNAVIGATIONINFO_IID= 
  {0x62a93afb, 0x93a1, 0x465c, 
    [ 0x84, 0xc8, 0x04, 0x32, 0x26, 0x42, 0x29, 0xde ]};

interface nsIWebNavigationInfo : nsISupports {

  static const char[] IID_STR = NS_IWEBNAVIGATIONINFO_IID_STR;
  static const nsIID IID = NS_IWEBNAVIGATIONINFO_IID;

extern(System):
  enum { UNSUPPORTED = 0U };
  enum { IMAGE = 1U };
  enum { PLUGIN = 2U };
  enum { OTHER = 32768U };

  nsresult IsTypeSupported(nsACString * aType, nsIWebNavigation aWebNav, PRUint32 *_retval);

}

