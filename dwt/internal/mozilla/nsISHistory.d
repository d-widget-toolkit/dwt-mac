module dwt.internal.mozilla.nsISHistory;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsID;
import dwt.internal.mozilla.nsISupports;

import dwt.internal.mozilla.nsIHistoryEntry; 
import dwt.internal.mozilla.nsISHistoryListener; 
import dwt.internal.mozilla.nsISimpleEnumerator;

const char[] NS_ISHISTORY_IID_STR = "7294fe9b-14d8-11d5-9882-00c04fa02f40";

const nsIID NS_ISHISTORY_IID= 
  {0x7294fe9b, 0x14d8, 0x11d5, 
    [ 0x98, 0x82, 0x00, 0xc0, 0x4f, 0xa0, 0x2f, 0x40 ]};

interface nsISHistory : nsISupports {

  static const char[] IID_STR = NS_ISHISTORY_IID_STR;
  static const nsIID IID = NS_ISHISTORY_IID;

extern(System):
  nsresult GetCount(PRInt32 *aCount);
  nsresult GetIndex(PRInt32 *aIndex);
  nsresult GetMaxLength(PRInt32 *aMaxLength);
  nsresult SetMaxLength(PRInt32 aMaxLength);
  nsresult GetEntryAtIndex(PRInt32 index, PRBool modifyIndex, nsIHistoryEntry *_retval);
  nsresult PurgeHistory(PRInt32 numEntries);
  nsresult AddSHistoryListener(nsISHistoryListener aListener);
  nsresult RemoveSHistoryListener(nsISHistoryListener aListener);
  nsresult GetSHistoryEnumerator(nsISimpleEnumerator  *aSHistoryEnumerator);

}

