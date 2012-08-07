module dwt.internal.mozilla.nsIHelperAppLauncher_1_8;

private import dwt.internal.mozilla.Common;
private import dwt.internal.mozilla.nsID;
private import dwt.internal.mozilla.nsICancelable;
private import dwt.internal.mozilla.nsIURI;
private import dwt.internal.mozilla.nsIMIMEInfo;
private import dwt.internal.mozilla.nsIFile;
private import dwt.internal.mozilla.nsIWebProgressListener2;
private import dwt.internal.mozilla.nsStringAPI;
private import dwt.internal.mozilla.prtime;

const char[] NS_IHELPERAPPLAUNCHER_1_8_IID_STR = "99a0882d-2ff9-4659-9952-9ac531ba5592";

const nsIID NS_IHELPERAPPLAUNCHER_1_8_IID= 
  {0x99a0882d, 0x2ff9, 0x4659, 
    [ 0x99, 0x52, 0x9a, 0xc5, 0x31, 0xba, 0x55, 0x92 ]};

interface nsIHelperAppLauncher_1_8 : nsICancelable {

  static const char[] IID_STR = NS_IHELPERAPPLAUNCHER_1_8_IID_STR;
  static const nsIID IID = NS_IHELPERAPPLAUNCHER_1_8_IID;

extern(System):
  nsresult GetMIMEInfo(nsIMIMEInfo  *aMIMEInfo);
  nsresult GetSource(nsIURI  *aSource);
  nsresult GetSuggestedFileName(nsAString * aSuggestedFileName);
  nsresult SaveToDisk(nsIFile aNewFileLocation, PRBool aRememberThisPreference);
  nsresult LaunchWithApplication(nsIFile aApplication, PRBool aRememberThisPreference);
  nsresult SetWebProgressListener(nsIWebProgressListener2 aWebProgressListener);
  nsresult CloseProgressWindow();
  nsresult GetTargetFile(nsIFile  *aTargetFile);
  nsresult GetTimeDownloadStarted(PRTime *aTimeDownloadStarted);

}