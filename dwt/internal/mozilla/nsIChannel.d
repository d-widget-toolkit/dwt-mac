module dwt.internal.mozilla.nsIChannel;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsID;
import dwt.internal.mozilla.nsISupports;

import dwt.internal.mozilla.nsIRequest;
import dwt.internal.mozilla.nsIURI;
import dwt.internal.mozilla.nsIInterfaceRequestor; 
import dwt.internal.mozilla.nsIInputStream; 
import dwt.internal.mozilla.nsIStreamListener;
import dwt.internal.mozilla.nsStringAPI;

const char[] NS_ICHANNEL_IID_STR = "c63a055a-a676-4e71-bf3c-6cfa11082018";
const nsIID NS_ICHANNEL_IID= 
  {0xc63a055a, 0xa676, 0x4e71, 
    [ 0xbf, 0x3c, 0x6c, 0xfa, 0x11, 0x08, 0x20, 0x18 ]};

interface nsIChannel : nsIRequest {

  static const char[] IID_STR = NS_ICHANNEL_IID_STR;
  static const nsIID IID = NS_ICHANNEL_IID;

extern(System):
  nsresult GetOriginalURI(nsIURI  *aOriginalURI);
  nsresult SetOriginalURI(nsIURI  aOriginalURI);
  nsresult GetURI(nsIURI  *aURI);
  nsresult GetOwner(nsISupports  *aOwner);
  nsresult SetOwner(nsISupports  aOwner);

  nsresult GetNotificationCallbacks(nsIInterfaceRequestor  *aNotificationCallbacks);
  nsresult SetNotificationCallbacks(nsIInterfaceRequestor  aNotificationCallbacks);
  nsresult GetSecurityInfo(nsISupports  *aSecurityInfo);
  nsresult GetContentType(nsACString * aContentType);
  nsresult SetContentType(nsACString * aContentType);
  nsresult GetContentCharset(nsACString * aContentCharset);
  nsresult SetContentCharset(nsACString * aContentCharset);
  nsresult GetContentLength(PRInt32 *aContentLength);
  nsresult SetContentLength(PRInt32 aContentLength);
  nsresult Open(nsIInputStream *_retval);
  nsresult AsyncOpen(nsIStreamListener aListener, nsISupports aContext);

  enum { LOAD_DOCUMENT_URI = 65536U };
  enum { LOAD_RETARGETED_DOCUMENT_URI = 131072U };
  enum { LOAD_REPLACE = 262144U };
  enum { LOAD_INITIAL_DOCUMENT_URI = 524288U };
  enum { LOAD_TARGETED = 1048576U };
  enum { LOAD_CALL_CONTENT_SNIFFERS = 2097152U };
}

