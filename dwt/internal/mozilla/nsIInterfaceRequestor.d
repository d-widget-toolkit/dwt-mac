module dwt.internal.mozilla.nsIInterfaceRequestor;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsID;
import dwt.internal.mozilla.nsISupports;

const char[] NS_IINTERFACEREQUESTOR_IID_STR = "033a1470-8b2a-11d3-af88-00a024ffc08c";

const nsIID NS_IINTERFACEREQUESTOR_IID= 
  {0x033a1470, 0x8b2a, 0x11d3, 
    [ 0xaf, 0x88, 0x00, 0xa0, 0x24, 0xff, 0xc0, 0x8c ]};

interface nsIInterfaceRequestor : nsISupports {

  static const char[] IID_STR = NS_IINTERFACEREQUESTOR_IID_STR;
  static const nsIID IID = NS_IINTERFACEREQUESTOR_IID;

extern(System):
  nsresult GetInterface(nsIID * uuid, void * *result);

}

