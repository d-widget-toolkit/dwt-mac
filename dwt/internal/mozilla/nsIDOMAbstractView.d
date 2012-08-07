module dwt.internal.mozilla.nsIDOMAbstractView;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsID;
import dwt.internal.mozilla.nsISupports;

import dwt.internal.mozilla.nsIDOMDocumentView;

alias PRUint64 DOMTimeStamp;

const char[] NS_IDOMABSTRACTVIEW_IID_STR = "f51ebade-8b1a-11d3-aae7-0010830123b4";

const nsIID NS_IDOMABSTRACTVIEW_IID= 
  {0xf51ebade, 0x8b1a, 0x11d3, 
    [ 0xaa, 0xe7, 0x00, 0x10, 0x83, 0x01, 0x23, 0xb4 ]};

interface nsIDOMAbstractView : nsISupports {

  static const char[] IID_STR = NS_IDOMABSTRACTVIEW_IID_STR;
  static const nsIID IID = NS_IDOMABSTRACTVIEW_IID;

extern(System):
  nsresult GetDocument(nsIDOMDocumentView  *aDocument);

}

