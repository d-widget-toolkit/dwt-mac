module dwt.internal.mozilla.nsIMIMEInfo;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsID;
import dwt.internal.mozilla.nsISupports;

import dwt.internal.mozilla.nsIURI;
import dwt.internal.mozilla.nsIFile;
import dwt.internal.mozilla.nsIStringEnumerator;
import dwt.internal.mozilla.nsStringAPI;

alias PRInt32 nsMIMEInfoHandleAction;

const char[] NS_IMIMEINFO_IID_STR = "1448b42f-cf0d-466e-9a15-64e876ebe857";

const nsIID NS_IMIMEINFO_IID= 
  {0x1448b42f, 0xcf0d, 0x466e, 
    [ 0x9a, 0x15, 0x64, 0xe8, 0x76, 0xeb, 0xe8, 0x57 ]};

interface nsIMIMEInfo : nsISupports {

  static const char[] IID_STR = NS_IMIMEINFO_IID_STR;
  static const nsIID IID = NS_IMIMEINFO_IID;

extern(System):
  nsresult GetFileExtensions(nsIUTF8StringEnumerator *_retval);
  nsresult SetFileExtensions(nsACString * aExtensions);
  nsresult ExtensionExists(nsACString * aExtension, PRBool *_retval);
  nsresult AppendExtension(nsACString * aExtension);
  nsresult GetPrimaryExtension(nsACString * aPrimaryExtension);
  nsresult SetPrimaryExtension(nsACString * aPrimaryExtension);
  nsresult GetMIMEType(nsACString * aMIMEType);
  nsresult SetDescription(nsAString * aDescription);
  nsresult GetMacType(PRUint32 *aMacType);
  nsresult SetMacType(PRUint32 aMacType);
  nsresult GetMacCreator(PRUint32 *aMacCreator);
  nsresult SetMacCreator(PRUint32 aMacCreator);
  nsresult Equals(nsIMIMEInfo aMIMEInfo, PRBool *_retval);
  nsresult GetPreferredApplicationHandler(nsIFile  *aPreferredApplicationHandler);
  nsresult SetPreferredApplicationHandler(nsIFile  aPreferredApplicationHandler);
  nsresult GetApplicationDescription(nsAString * aApplicationDescription);
  nsresult SetApplicationDescription(nsAString * aApplicationDescription);
  nsresult GetHasDefaultHandler(PRBool *aHasDefaultHandler);
  nsresult GetDefaultDescription(nsAString * aDefaultDescription);
  nsresult LaunchWithFile(nsIFile aFile);

  enum { saveToDisk = 0 };
  enum { alwaysAsk = 1 };
  enum { useHelperApp = 2 };
  enum { handleInternally = 3 };
  enum { useSystemDefault = 4 };

  nsresult GetPreferredAction(nsMIMEInfoHandleAction *aPreferredAction);
  nsresult SetPreferredAction(nsMIMEInfoHandleAction aPreferredAction);
  nsresult GetAlwaysAskBeforeHandling(PRBool *aAlwaysAskBeforeHandling);
  nsresult SetAlwaysAskBeforeHandling(PRBool aAlwaysAskBeforeHandling);

}

