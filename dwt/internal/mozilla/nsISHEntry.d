module dwt.internal.mozilla.nsISHEntry;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsID;
import dwt.internal.mozilla.nsISupports;

import dwt.internal.mozilla.nsIHistoryEntry;
import dwt.internal.mozilla.nsIContentViewer; 
import dwt.internal.mozilla.nsIURI;
import dwt.internal.mozilla.nsIInputStream; 
import dwt.internal.mozilla.nsIDocShellTreeItem;
import dwt.internal.mozilla.nsISupportsArray;
import dwt.internal.mozilla.nsStringAPI;

const char[] NS_ISHENTRY_IID_STR = "542a98b9-2889-4922-aaf4-02b6056f4136";

const nsIID NS_ISHENTRY_IID= 
  {0x542a98b9, 0x2889, 0x4922, 
    [ 0xaa, 0xf4, 0x02, 0xb6, 0x05, 0x6f, 0x41, 0x36 ]};

interface nsISHEntry : nsIHistoryEntry {

  static const char[] IID_STR = NS_ISHENTRY_IID_STR;
  static const nsIID IID = NS_ISHENTRY_IID;

extern(System):
  nsresult SetURI(nsIURI aURI);
  nsresult GetReferrerURI(nsIURI  *aReferrerURI);
  nsresult SetReferrerURI(nsIURI  aReferrerURI);
  nsresult GetContentViewer(nsIContentViewer  *aContentViewer);
  nsresult SetContentViewer(nsIContentViewer  aContentViewer);
  nsresult GetSticky(PRBool *aSticky);
  nsresult SetSticky(PRBool aSticky);
  nsresult GetWindowState(nsISupports  *aWindowState);
  nsresult SetWindowState(nsISupports  aWindowState);
  nsresult GetViewerBounds(nsRect * bounds);
  nsresult SetViewerBounds(nsRect * bounds);
  nsresult AddChildShell(nsIDocShellTreeItem shell);
  nsresult ChildShellAt(PRInt32 index, nsIDocShellTreeItem *_retval);
  nsresult ClearChildShells();
  nsresult GetRefreshURIList(nsISupportsArray  *aRefreshURIList);
  nsresult SetRefreshURIList(nsISupportsArray  aRefreshURIList);
  nsresult SyncPresentationState();
  nsresult SetTitle(nsAString * aTitle);
  nsresult GetPostData(nsIInputStream  *aPostData);
  nsresult SetPostData(nsIInputStream  aPostData);
  nsresult GetLayoutHistoryState(nsILayoutHistoryState  *aLayoutHistoryState);
  nsresult SetLayoutHistoryState(nsILayoutHistoryState  aLayoutHistoryState);
  nsresult GetParent(nsISHEntry  *aParent);
  nsresult SetParent(nsISHEntry  aParent);
  nsresult GetLoadType(PRUint32 *aLoadType);
  nsresult SetLoadType(PRUint32 aLoadType);
  nsresult GetID(PRUint32 *aID);
  nsresult SetID(PRUint32 aID);
  nsresult GetPageIdentifier(PRUint32 *aPageIdentifier);
  nsresult SetPageIdentifier(PRUint32 aPageIdentifier);
  nsresult GetCacheKey(nsISupports  *aCacheKey);
  nsresult SetCacheKey(nsISupports  aCacheKey);
  nsresult GetSaveLayoutStateFlag(PRBool *aSaveLayoutStateFlag);
  nsresult SetSaveLayoutStateFlag(PRBool aSaveLayoutStateFlag);
  nsresult GetExpirationStatus(PRBool *aExpirationStatus);
  nsresult SetExpirationStatus(PRBool aExpirationStatus);
  nsresult GetContentType(nsACString * aContentType);
  nsresult SetContentType(nsACString * aContentType);
  nsresult SetScrollPosition(PRInt32 x, PRInt32 y);
  nsresult GetScrollPosition(PRInt32 *x, PRInt32 *y);
  nsresult Create(nsIURI URI, nsAString * title, nsIInputStream inputStream, nsILayoutHistoryState layoutHistoryState, nsISupports cacheKey, nsACString * contentType);
  nsresult Clone(nsISHEntry *_retval);
  nsresult SetIsSubFrame(PRBool aFlag);
  nsresult GetAnyContentViewer(nsISHEntry *ownerEntry, nsIContentViewer *_retval);

}

