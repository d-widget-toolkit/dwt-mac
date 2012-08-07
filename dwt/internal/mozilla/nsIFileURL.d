module dwt.internal.mozilla.nsIFileURL;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsID;
import dwt.internal.mozilla.nsIURL;
import dwt.internal.mozilla.nsIFile;

const char[] NS_IFILEURL_IID_STR = "d26b2e2e-1dd1-11b2-88f3-8545a7ba7949";

const nsIID NS_IFILEURL_IID= 
  {0xd26b2e2e, 0x1dd1, 0x11b2, 
    [ 0x88, 0xf3, 0x85, 0x45, 0xa7, 0xba, 0x79, 0x49 ]};

interface nsIFileURL : nsIURL {

  static const char[] IID_STR = NS_IFILEURL_IID_STR;
  static const nsIID IID = NS_IFILEURL_IID;

extern(System):
  nsresult GetFile(nsIFile  *aFile);
  nsresult SetFile(nsIFile  aFile);

}

