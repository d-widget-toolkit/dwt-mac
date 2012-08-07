module dwt.internal.mozilla.nsILocalFile;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.prlink;
import dwt.internal.mozilla.prio;
import dwt.internal.mozilla.prtime;
import dwt.internal.mozilla.nsID;
import dwt.internal.mozilla.nsIFile;
import dwt.internal.mozilla.nsStringAPI;

import tango.stdc.stdio : FILE;

const char[] NS_ILOCALFILE_IID_STR = "aa610f20-a889-11d3-8c81-000064657374";

const nsIID NS_ILOCALFILE_IID= 
  {0xaa610f20, 0xa889, 0x11d3, 
    [ 0x8c, 0x81, 0x00, 0x00, 0x64, 0x65, 0x73, 0x74 ]};

interface nsILocalFile : nsIFile {

    static const char[] IID_STR = NS_ILOCALFILE_IID_STR;
    static const nsIID IID = NS_ILOCALFILE_IID;

extern(System):
    nsresult InitWithPath(nsAString * filePath);
    nsresult InitWithNativePath(nsACString * filePath);
    nsresult InitWithFile(nsILocalFile aFile);
    nsresult GetFollowLinks(PRBool *aFollowLinks);
    nsresult SetFollowLinks(PRBool aFollowLinks);
    nsresult OpenNSPRFileDesc(PRInt32 flags, PRInt32 mode, PRFileDesc * *_retval);
    nsresult OpenANSIFileDesc(char *mode, FILE * *_retval);
    nsresult Load(PRLibrary * *_retval);
    nsresult GetDiskSpaceAvailable(PRInt64 *aDiskSpaceAvailable);
    nsresult AppendRelativePath(nsAString * relativeFilePath);
    nsresult AppendRelativeNativePath(nsACString * relativeFilePath);
    nsresult GetPersistentDescriptor(nsACString * aPersistentDescriptor);
    nsresult SetPersistentDescriptor(nsACString * aPersistentDescriptor);
    nsresult Reveal();
    nsresult Launch();
    nsresult GetRelativeDescriptor(nsILocalFile fromFile, nsACString * _retval);
    nsresult SetRelativeDescriptor(nsILocalFile fromFile, nsACString * relativeDesc);
}

