module dwt.internal.mozilla.nsIBinaryInputStream;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsID;
import dwt.internal.mozilla.nsISupports;

import dwt.internal.mozilla.nsIInputStream;
import dwt.internal.mozilla.nsStringAPI;

const char[] NS_IBINARYINPUTSTREAM_IID_STR = "7b456cb0-8772-11d3-90cf-0040056a906e";

const nsIID NS_IBINARYINPUTSTREAM_IID= 
  {0x7b456cb0, 0x8772, 0x11d3, 
    [ 0x90, 0xcf, 0x00, 0x40, 0x05, 0x6a, 0x90, 0x6e ]};

interface nsIBinaryInputStream : nsIInputStream {

  static const char[] IID_STR = NS_IBINARYINPUTSTREAM_IID_STR;
  static const nsIID IID = NS_IBINARYINPUTSTREAM_IID;

extern(System):
  nsresult SetInputStream(nsIInputStream aInputStream);
  nsresult ReadBoolean(PRBool *_retval);
  nsresult Read8(PRUint8 *_retval);
  nsresult Read16(PRUint16 *_retval);
  nsresult Read32(PRUint32 *_retval);
  nsresult Read64(PRUint64 *_retval);
  nsresult ReadFloat(float *_retval);
  nsresult ReadDouble(double *_retval);
  nsresult ReadCString(nsACString * _retval);
  nsresult ReadString(nsAString * _retval);
  nsresult ReadBytes(PRUint32 aLength, char **aString);
  nsresult ReadByteArray(PRUint32 aLength, PRUint8 **aBytes);

}

