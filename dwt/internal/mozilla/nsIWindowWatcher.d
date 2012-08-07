module dwt.internal.mozilla.nsIWindowWatcher;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsID;
import dwt.internal.mozilla.nsISupports;

import dwt.internal.mozilla.nsIDOMWindow;
import dwt.internal.mozilla.nsIObserver; 
import dwt.internal.mozilla.nsIPrompt; 
import dwt.internal.mozilla.nsIAuthPrompt;
import dwt.internal.mozilla.nsISimpleEnumerator;
import dwt.internal.mozilla.nsIWebBrowserChrome;
import dwt.internal.mozilla.nsIWindowCreator; 

const char[] NS_IWINDOWWATCHER_IID_STR = "002286a8-494b-43b3-8ddd-49e3fc50622b";

const nsIID NS_IWINDOWWATCHER_IID= 
  {0x002286a8, 0x494b, 0x43b3, 
    [ 0x8d, 0xdd, 0x49, 0xe3, 0xfc, 0x50, 0x62, 0x2b ]};

interface nsIWindowWatcher : nsISupports {

  static const char[] IID_STR = NS_IWINDOWWATCHER_IID_STR;
  static const nsIID IID = NS_IWINDOWWATCHER_IID;

extern(System):
  nsresult OpenWindow(nsIDOMWindow aParent, char *aUrl, char *aName, char *aFeatures, nsISupports aArguments, nsIDOMWindow *_retval);
  nsresult RegisterNotification(nsIObserver aObserver);
  nsresult UnregisterNotification(nsIObserver aObserver);
  nsresult GetWindowEnumerator(nsISimpleEnumerator *_retval);
  nsresult GetNewPrompter(nsIDOMWindow aParent, nsIPrompt *_retval);
  nsresult GetNewAuthPrompter(nsIDOMWindow aParent, nsIAuthPrompt *_retval);
  nsresult SetWindowCreator(nsIWindowCreator creator);
  nsresult GetChromeForWindow(nsIDOMWindow aWindow, nsIWebBrowserChrome *_retval);
  nsresult GetWindowByName(PRUnichar *aTargetName, nsIDOMWindow aCurrentWindow, nsIDOMWindow *_retval);
  nsresult GetActiveWindow(nsIDOMWindow  *aActiveWindow);
  nsresult SetActiveWindow(nsIDOMWindow  aActiveWindow);

}

