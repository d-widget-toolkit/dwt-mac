module dwt.internal.mozilla.nsIWebBrowser;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsID;
import dwt.internal.mozilla.nsISupports;

import dwt.internal.mozilla.nsIWebBrowserChrome; 
import dwt.internal.mozilla.nsIURIContentListener;
import dwt.internal.mozilla.nsIDOMWindow;
import dwt.internal.mozilla.nsIWeakReference;

const char[] NS_IWEBBROWSER_IID_STR = "69e5df00-7b8b-11d3-af61-00a024ffc08c";

const nsIID NS_IWEBBROWSER_IID= 
  {0x69e5df00, 0x7b8b, 0x11d3, 
    [ 0xaf, 0x61, 0x00, 0xa0, 0x24, 0xff, 0xc0, 0x8c ]};

interface nsIWebBrowser : nsISupports {

  static const char[] IID_STR = NS_IWEBBROWSER_IID_STR;
  static const nsIID IID = NS_IWEBBROWSER_IID;

extern(System):
  nsresult AddWebBrowserListener(nsIWeakReference aListener, nsIID * aIID);
  nsresult RemoveWebBrowserListener(nsIWeakReference aListener, nsIID * aIID);
  nsresult GetContainerWindow(nsIWebBrowserChrome  *aContainerWindow);
  nsresult SetContainerWindow(nsIWebBrowserChrome  aContainerWindow);
  nsresult GetParentURIContentListener(nsIURIContentListener  *aParentURIContentListener);
  nsresult SetParentURIContentListener(nsIURIContentListener  aParentURIContentListener);
  nsresult GetContentDOMWindow(nsIDOMWindow  *aContentDOMWindow);

}

