module dwt.internal.mozilla.nsIDOMWindow;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsID;
import dwt.internal.mozilla.nsISupports;

import dwt.internal.mozilla.nsIDOMWindowCollection;
import dwt.internal.mozilla.nsIDOMDocument;
import dwt.internal.mozilla.nsIDOMBarProp;
import dwt.internal.mozilla.nsISelection;
import dwt.internal.mozilla.nsStringAPI;

alias PRUint64 DOMTimeStamp;

const char[] NS_IDOMWINDOW_IID_STR = "a6cf906b-15b3-11d2-932e-00805f8add32";

const nsIID NS_IDOMWINDOW_IID= 
  {0xa6cf906b, 0x15b3, 0x11d2, 
    [ 0x93, 0x2e, 0x00, 0x80, 0x5f, 0x8a, 0xdd, 0x32 ]};

interface nsIDOMWindow : nsISupports {

  static const char[] IID_STR = NS_IDOMWINDOW_IID_STR;
  static const nsIID IID = NS_IDOMWINDOW_IID;

extern(System):
  nsresult GetDocument(nsIDOMDocument  *aDocument);
  nsresult GetParent(nsIDOMWindow  *aParent);
  nsresult GetTop(nsIDOMWindow  *aTop);
  nsresult GetScrollbars(nsIDOMBarProp  *aScrollbars);
  nsresult GetFrames(nsIDOMWindowCollection  *aFrames);
  nsresult GetName(nsAString * aName);
  nsresult SetName(nsAString * aName);
  nsresult GetTextZoom(float *aTextZoom);
  nsresult SetTextZoom(float aTextZoom);
  nsresult GetScrollX(PRInt32 *aScrollX);
  nsresult GetScrollY(PRInt32 *aScrollY);
  nsresult ScrollTo(PRInt32 xScroll, PRInt32 yScroll);
  nsresult ScrollBy(PRInt32 xScrollDif, PRInt32 yScrollDif);
  nsresult GetSelection(nsISelection *_retval);
  nsresult ScrollByLines(PRInt32 numLines);
  nsresult ScrollByPages(PRInt32 numPages);
  nsresult SizeToContent();

}

