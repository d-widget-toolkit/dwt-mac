module dwt.internal.mozilla.nsIDOMEventTarget;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsID;
import dwt.internal.mozilla.nsISupports;
import dwt.internal.mozilla.nsIDOMEvent;
import dwt.internal.mozilla.nsIDOMEventListener;
import dwt.internal.mozilla.nsStringAPI;

alias PRUint64 DOMTimeStamp;

const char[] NS_IDOMEVENTTARGET_IID_STR = "1c773b30-d1cf-11d2-bd95-00805f8ae3f4";

const nsIID NS_IDOMEVENTTARGET_IID= 
  {0x1c773b30, 0xd1cf, 0x11d2, 
    [ 0xbd, 0x95, 0x00, 0x80, 0x5f, 0x8a, 0xe3, 0xf4 ]};

//extern(System)

interface nsIDOMEventTarget : nsISupports {

  static const char[] IID_STR = NS_IDOMEVENTTARGET_IID_STR;
  static const nsIID IID = NS_IDOMEVENTTARGET_IID;

extern(System):
  nsresult AddEventListener(nsAString * type, nsIDOMEventListener listener, PRBool useCapture);
  nsresult RemoveEventListener(nsAString * type, nsIDOMEventListener listener, PRBool useCapture);
  nsresult DispatchEvent(nsIDOMEvent evt, PRBool *_retval);

}

