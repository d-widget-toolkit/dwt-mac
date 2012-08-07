module dwt.internal.mozilla.nsIDOMComment;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsID;

import dwt.internal.mozilla.nsIDOMCharacterData;

const char[] NS_IDOMCOMMENT_IID_STR = "a6cf9073-15b3-11d2-932e-00805f8add32";

const nsIID NS_IDOMCOMMENT_IID= 
  {0xa6cf9073, 0x15b3, 0x11d2, 
    [ 0x93, 0x2e, 0x00, 0x80, 0x5f, 0x8a, 0xdd, 0x32 ]};

interface nsIDOMComment : nsIDOMCharacterData {

extern(System):
  static const char[] IID_STR = NS_IDOMCOMMENT_IID_STR;
  static const nsIID IID = NS_IDOMCOMMENT_IID;

}

