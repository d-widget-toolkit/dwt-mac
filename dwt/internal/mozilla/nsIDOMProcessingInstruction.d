module dwt.internal.mozilla.nsIDOMProcessingInstruction;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsID;
import dwt.internal.mozilla.nsIDOMNode;
import dwt.internal.mozilla.nsStringAPI;

const char[] NS_IDOMPROCESSINGINSTRUCTION_IID_STR = "a6cf907f-15b3-11d2-932e-00805f8add32";

const nsIID NS_IDOMPROCESSINGINSTRUCTION_IID= 
  {0xa6cf907f, 0x15b3, 0x11d2, 
    [ 0x93, 0x2e, 0x00, 0x80, 0x5f, 0x8a, 0xdd, 0x32 ]};

interface nsIDOMProcessingInstruction : nsIDOMNode {

  static const char[] IID_STR = NS_IDOMPROCESSINGINSTRUCTION_IID_STR;
  static const nsIID IID = NS_IDOMPROCESSINGINSTRUCTION_IID;

  nsresult GetTarget(nsAString * aTarget);
  nsresult GetData(nsAString * aData);
  nsresult SetData(nsAString * aData);

}

