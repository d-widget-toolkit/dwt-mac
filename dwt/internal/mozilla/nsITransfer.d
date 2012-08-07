module dwt.internal.mozilla.nsITransfer;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsID;
import dwt.internal.mozilla.nsISupports;

import dwt.internal.mozilla.prtime;

import dwt.internal.mozilla.nsIWebProgressListener2;
import dwt.internal.mozilla.nsIURI;
import dwt.internal.mozilla.nsICancelable;
import dwt.internal.mozilla.nsIMIMEInfo;
import dwt.internal.mozilla.nsILocalFile;
import dwt.internal.mozilla.nsStringAPI;

const char[] NS_ITRANSFER_IID_STR = "23c51569-e9a1-4a92-adeb-3723db82ef7c";

const nsIID NS_ITRANSFER_IID= 
  {0x23c51569, 0xe9a1, 0x4a92, 
    [ 0xad, 0xeb, 0x37, 0x23, 0xdb, 0x82, 0xef, 0x7c ]};

interface nsITransfer : nsIWebProgressListener2 {

  static const char[] IID_STR = NS_ITRANSFER_IID_STR;
  static const nsIID IID = NS_ITRANSFER_IID;

extern(System):
  nsresult Init(nsIURI aSource, nsIURI aTarget, nsAString * aDisplayName, nsIMIMEInfo aMIMEInfo, PRTime startTime, nsILocalFile aTempFile, nsICancelable aCancelable);

}

