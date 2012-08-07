module dwt.internal.mozilla.nsIDOMDocumentView;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsID;
import dwt.internal.mozilla.nsISupports;

import dwt.internal.mozilla.nsIDOMAbstractView;

alias PRUint64 DOMTimeStamp;

const char[] NS_IDOMDOCUMENTVIEW_IID_STR = "1acdb2ba-1dd2-11b2-95bc-9542495d2569";

const nsIID NS_IDOMDOCUMENTVIEW_IID= 
  {0x1acdb2ba, 0x1dd2, 0x11b2, 
    [ 0x95, 0xbc, 0x95, 0x42, 0x49, 0x5d, 0x25, 0x69 ]};

interface nsIDOMDocumentView : nsISupports {

  static const char[] IID_STR = NS_IDOMDOCUMENTVIEW_IID_STR;
  static const nsIID IID = NS_IDOMDOCUMENTVIEW_IID;

extern(System):
  nsresult GetDefaultView(nsIDOMAbstractView  *aDefaultView);

}

