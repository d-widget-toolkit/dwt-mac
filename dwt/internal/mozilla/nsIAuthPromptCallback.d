module dwt.internal.mozilla.nsIAuthPromptCallback;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsID;
import dwt.internal.mozilla.nsISupports;
import dwt.internal.mozilla.nsIAuthInformation;

const char[] NS_IAUTHPROMPTCALLBACK_IID_STR = "bdc387d7-2d29-4cac-92f1-dd75d786631d";

const nsIID NS_IAUTHPROMPTCALLBACK_IID= 
  {0xbdc387d7, 0x2d29, 0x4cac, 
    [ 0x92, 0xf1, 0xdd, 0x75, 0xd7, 0x86, 0x63, 0x1d ]};

interface nsIAuthPromptCallback : nsISupports {

  static const char[] IID_STR = NS_IAUTHPROMPTCALLBACK_IID_STR;
  static const nsIID IID = NS_IAUTHPROMPTCALLBACK_IID;

extern(System):
  nsresult OnAuthAvailable(nsISupports aContext, nsIAuthInformation aAuthInfo);
  nsresult OnAuthCancelled(nsISupports aContext, PRBool userCancel);
}
