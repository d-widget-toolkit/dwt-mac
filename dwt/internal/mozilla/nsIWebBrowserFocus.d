module dwt.internal.mozilla.nsIWebBrowserFocus;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsID;
import dwt.internal.mozilla.nsISupports;
import dwt.internal.mozilla.nsIDOMWindow; 
import dwt.internal.mozilla.nsIDOMElement;

const char[] NS_IWEBBROWSERFOCUS_IID_STR = "9c5d3c58-1dd1-11b2-a1c9-f3699284657a";

const nsIID NS_IWEBBROWSERFOCUS_IID= 
  {0x9c5d3c58, 0x1dd1, 0x11b2, 
    [ 0xa1, 0xc9, 0xf3, 0x69, 0x92, 0x84, 0x65, 0x7a ]};

interface nsIWebBrowserFocus : nsISupports {

  static const char[] IID_STR = NS_IWEBBROWSERFOCUS_IID_STR;
  static const nsIID IID = NS_IWEBBROWSERFOCUS_IID;

extern(System):
  nsresult Activate();
  nsresult Deactivate();
  nsresult SetFocusAtFirstElement();
  nsresult SetFocusAtLastElement();
  nsresult GetFocusedWindow(nsIDOMWindow  *aFocusedWindow);
  nsresult SetFocusedWindow(nsIDOMWindow  aFocusedWindow);
  nsresult GetFocusedElement(nsIDOMElement  *aFocusedElement);
  nsresult SetFocusedElement(nsIDOMElement  aFocusedElement);

}

