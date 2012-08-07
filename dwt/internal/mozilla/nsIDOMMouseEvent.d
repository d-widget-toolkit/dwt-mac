module dwt.internal.mozilla.nsIDOMMouseEvent;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsID;

import dwt.internal.mozilla.nsIDOMUIEvent;
import dwt.internal.mozilla.nsIDOMEventTarget;
import dwt.internal.mozilla.nsIDOMAbstractView;
import dwt.internal.mozilla.nsStringAPI;

const char[] NS_IDOMMOUSEEVENT_IID_STR = "ff751edc-8b02-aae7-0010-8301838a3123";

const nsIID NS_IDOMMOUSEEVENT_IID= 
  {0xff751edc, 0x8b02, 0xaae7, 
    [ 0x00, 0x10, 0x83, 0x01, 0x83, 0x8a, 0x31, 0x23 ]};

interface nsIDOMMouseEvent : nsIDOMUIEvent {

  static const char[] IID_STR = NS_IDOMMOUSEEVENT_IID_STR;
  static const nsIID IID = NS_IDOMMOUSEEVENT_IID;

extern(System):
  nsresult GetScreenX(PRInt32 *aScreenX);
  nsresult GetScreenY(PRInt32 *aScreenY);
  nsresult GetClientX(PRInt32 *aClientX);
  nsresult GetClientY(PRInt32 *aClientY);
  nsresult GetCtrlKey(PRBool *aCtrlKey);
  nsresult GetShiftKey(PRBool *aShiftKey);
  nsresult GetAltKey(PRBool *aAltKey);
  nsresult GetMetaKey(PRBool *aMetaKey);
  nsresult GetButton(PRUint16 *aButton);
  nsresult GetRelatedTarget(nsIDOMEventTarget  *aRelatedTarget);

  nsresult InitMouseEvent(nsAString * typeArg, PRBool canBubbleArg, PRBool cancelableArg, nsIDOMAbstractView viewArg, PRInt32 detailArg, PRInt32 screenXArg, PRInt32 screenYArg, PRInt32 clientXArg, PRInt32 clientYArg, PRBool ctrlKeyArg, PRBool altKeyArg, PRBool shiftKeyArg, PRBool metaKeyArg, PRUint16 buttonArg, nsIDOMEventTarget relatedTargetArg);

}