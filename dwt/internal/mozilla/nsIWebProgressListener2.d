module dwt.internal.mozilla.nsIWebProgressListener2;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsID;

import dwt.internal.mozilla.nsIWebProgressListener;
import dwt.internal.mozilla.nsIWebProgress;
import dwt.internal.mozilla.nsIRequest;

const char[] NS_IWEBPROGRESSLISTENER2_IID_STR = "3f24610d-1e1f-4151-9d2e-239884742324";

const nsIID NS_IWEBPROGRESSLISTENER2_IID=
  {0x3f24610d, 0x1e1f, 0x4151,
    [ 0x9d, 0x2e, 0x23, 0x98, 0x84, 0x74, 0x23, 0x24 ]};

interface nsIWebProgressListener2 : nsIWebProgressListener {

  static const char[] IID_STR = NS_IWEBPROGRESSLISTENER2_IID_STR;
  static const nsIID IID = NS_IWEBPROGRESSLISTENER2_IID;

extern(System):
  nsresult OnProgressChange64(nsIWebProgress aWebProgress, nsIRequest aRequest, PRInt64 aCurSelfProgress, PRInt64 aMaxSelfProgress, PRInt64 aCurTotalProgress, PRInt64 aMaxTotalProgress);

}

