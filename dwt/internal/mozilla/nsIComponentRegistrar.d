module dwt.internal.mozilla.nsIComponentRegistrar;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsID;
import dwt.internal.mozilla.nsISupports;
import dwt.internal.mozilla.nsIFile;
import dwt.internal.mozilla.nsIFactory;
import dwt.internal.mozilla.nsISimpleEnumerator;

const char[] NS_ICOMPONENTREGISTRAR_IID_STR = "2417cbfe-65ad-48a6-b4b6-eb84db174392";

const nsIID NS_ICOMPONENTREGISTRAR_IID= 
  {0x2417cbfe, 0x65ad, 0x48a6, 
    [ 0xb4, 0xb6, 0xeb, 0x84, 0xdb, 0x17, 0x43, 0x92 ]};

interface nsIComponentRegistrar : nsISupports {
  static const char[] IID_STR = NS_ICOMPONENTREGISTRAR_IID_STR;
  static const nsIID IID = NS_ICOMPONENTREGISTRAR_IID;

extern(System):
  nsresult AutoRegister(nsIFile aSpec);
  nsresult AutoUnregister(nsIFile aSpec);
  nsresult RegisterFactory(nsCID * aClass, char *aClassName, char *aContractID, nsIFactory aFactory);
  nsresult UnregisterFactory(nsCID * aClass, nsIFactory aFactory);
  nsresult RegisterFactoryLocation(nsCID * aClass, char *aClassName, char *aContractID, nsIFile aFile, char *aLoaderStr, char *aType);
  nsresult UnregisterFactoryLocation(nsCID * aClass, nsIFile aFile);
  nsresult IsCIDRegistered(nsCID * aClass, PRBool *_retval);
  nsresult IsContractIDRegistered(char *aContractID, PRBool *_retval);
  nsresult EnumerateCIDs(nsISimpleEnumerator *_retval);
  nsresult EnumerateContractIDs(nsISimpleEnumerator *_retval);
  nsresult CIDToContractID(nsCID * aClass, char **_retval);
  nsresult ContractIDToCID(char *aContractID, nsCID * *_retval);
}

