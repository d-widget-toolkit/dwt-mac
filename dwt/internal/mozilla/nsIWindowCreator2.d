module dwt.internal.mozilla.nsIWindowCreator2;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsID;

import dwt.internal.mozilla.nsIWindowCreator;
import dwt.internal.mozilla.nsIURI; 
import dwt.internal.mozilla.nsIWebBrowserChrome;

const char[] NS_IWINDOWCREATOR2_IID_STR = "f673ec81-a4b0-11d6-964b-eb5a2bf216fc";

const nsIID NS_IWINDOWCREATOR2_IID= 
  {0xf673ec81, 0xa4b0, 0x11d6, 
    [ 0x96, 0x4b, 0xeb, 0x5a, 0x2b, 0xf2, 0x16, 0xfc ]};

interface nsIWindowCreator2 : nsIWindowCreator {

  static const char[] IID_STR = NS_IWINDOWCREATOR2_IID_STR;
  static const nsIID IID = NS_IWINDOWCREATOR2_IID;

extern(System):
  enum { PARENT_IS_LOADING_OR_RUNNING_TIMEOUT = 1U };
  nsresult CreateChromeWindow2(nsIWebBrowserChrome parent, PRUint32 chromeFlags, PRUint32 contextFlags, nsIURI uri, PRBool *cancel, nsIWebBrowserChrome *_retval);

}

