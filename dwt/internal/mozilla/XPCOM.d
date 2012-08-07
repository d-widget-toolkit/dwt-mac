/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is Mozilla Communicator client code, released March 31, 1998.
 *
 * The Initial Developer of the Original Code is
 * Netscape Communications Corporation.
 * Portions created by Netscape are Copyright (C) 1998-1999
 * Netscape Communications Corporation.  All Rights Reserved.
 *
 * Contributor(s):
 *
 * IBM
 * -  Binding to permit interfacing between Mozilla and DWT
 * -  Copyright (C) 2003, 2006 IBM Corp.  All Rights Reserved.
 * Port to the D programming language:
 *      John Reimer <terminal.node@gmail.com>
 *******************************************************************************/

module dwt.internal.mozilla.XPCOM;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsID;
import dwt.internal.mozilla.nsStringAPI;
import dwt.internal.mozilla.nsIModule;
import dwt.internal.mozilla.nsIComponentManager;
import dwt.internal.mozilla.nsIComponentRegistrar;
import dwt.internal.mozilla.nsIServiceManager;
import dwt.internal.mozilla.nsIFile;
import dwt.internal.mozilla.nsILocalFile;
import dwt.internal.mozilla.nsIDirectoryService;
import dwt.internal.mozilla.nsIMemory;
import dwt.internal.mozilla.nsIDebug;
import dwt.internal.mozilla.nsITraceRefcnt;
    public static final nsID EXTERNAL_CID = new nsID ("f2c59ad0-bd76-11dd-ad8b-0800200c9a66"); //$NON-NLS-1$
    public static final nsID NS_PROMPTSERVICE_CID = new nsID("a2112d6a-0e28-421f-b46a-25c0b308cbd0"); //$NON-NLS-1$
private import dwt.dwthelper.utils;
    public static final String EXTERNAL_CONTRACTID = "@eclipse.org/external;1"; //$NON-NLS-1$
    public static final String NS_COOKIESERVICE_CONTRACTID = "@mozilla.org/cookieService;1"; //$NON-NLS-1$
    public static final String NS_SCRIPTSECURITYMANAGER_CONTRACTID = "@mozilla.org/scriptsecuritymanager;1"; //$NON-NLS-1$
    public static final String NS_PROMPTSERVICE_CONTRACTID = "@mozilla.org/embedcomp/prompt-service;1"; //$NON-NLS-1$
/******************************************************************************
    public static final String NS_VARIANT_CONTRACTID = "@mozilla.org/variant;1"; //$NON-NLS-1$
    public static final String NS_OS_HOME_DIR = "Home"; //$NON-NLS-1$
  Original SWT XPCOM constant declarations for XPCOM
    public static final int NS_ERROR_FACTORY_NO_SIGNATURE_SUPPORT = NS_ERROR_BASE + 0x101;
******************************************************************************/
public static final native int nsDynamicFunctionLoad_sizeof ();

/**
 * @param dest cast=(void *)
 * @param src cast=(const void *),flags=no_out critical
 * @param size cast=(size_t)
 */
public static final native void memmove (int /*long*/ dest, nsDynamicFunctionLoad src, int /*long*/ size);
   
const String MOZILLA_FIVE_HOME = "MOZILLA_FIVE_HOME"; //$NON-NLS-1$
const String MOZILLA_PLUGIN_PATH = "MOZ_PLUGIN_PATH"; //$NON-NLS-1$
const String CONTENT_MAYBETEXT = "application/x-vnd.mozilla.maybe-text"; //$NON-NLS-1$
const String CONTENT_MULTIPART = "multipart/x-mixed-replace"; //$NON-NLS-1$
const String DOMEVENT_FOCUS = "focus"; //$NON-NLS-1$
const String DOMEVENT_UNLOAD = "unload"; //$NON-NLS-1$
const String DOMEVENT_MOUSEDOWN = "mousedown"; //$NON-NLS-1$
const String DOMEVENT_MOUSEUP = "mouseup"; //$NON-NLS-1$
const String DOMEVENT_MOUSEMOVE = "mousemove"; //$NON-NLS-1$
const String DOMEVENT_MOUSEDRAG = "draggesture"; //$NON-NLS-1$
const String DOMEVENT_MOUSEWHEEL = "DOMMouseScroll"; //$NON-NLS-1$
const String DOMEVENT_MOUSEOVER = "mouseover"; //$NON-NLS-1$
const String DOMEVENT_MOUSEOUT = "mouseout"; //$NON-NLS-1$
const String DOMEVENT_KEYUP = "keyup"; //$NON-NLS-1$
const String DOMEVENT_KEYDOWN = "keydown"; //$NON-NLS-1$
const String DOMEVENT_KEYPRESS = "keypress"; //$NON-NLS-1$
public static final native int _nsEmbedCString_Length(int /*long*/ ptr);
public static final int nsEmbedCString_Length(int /*long*/ ptr) {
    lock.lock();
    try {
        return _nsEmbedCString_Length(ptr);
    } finally {
        lock.unlock();
    }
}
/**
 * @method flags=cpp
 * @param ptr cast=(nsIScriptGlobalObject *)
 */
public static final native int _nsIScriptGlobalObject_EnsureScriptEnvironment(int /*long*/ ptr, int lang);
public static final int nsIScriptGlobalObject_EnsureScriptEnvironment(int /*long*/ ptr, int lang) {
    lock.lock();
    try {
        return _nsIScriptGlobalObject_EnsureScriptEnvironment(ptr, lang);
    } finally {
        lock.unlock();
    }
}
/**
 * @method flags=cpp
 * @param ptr cast=(nsIScriptGlobalObject *)
 */
public static final native int /*long*/ _nsIScriptGlobalObject_GetScriptGlobal(int /*long*/ ptr, int lang);
public static final int /*long*/ nsIScriptGlobalObject_GetScriptGlobal(int /*long*/ ptr, int lang) {
    lock.lock();
    try {
        return _nsIScriptGlobalObject_GetScriptGlobal(ptr, lang);
    } finally {
        lock.unlock();
    }
}
/**
 * @method flags=cpp
 * @param ptr cast=(nsIScriptGlobalObject *)
 */
public static final native int /*long*/ _nsIScriptGlobalObject_GetScriptContext(int /*long*/ ptr, int lang);
public static final int /*long*/ nsIScriptGlobalObject_GetScriptContext(int /*long*/ ptr, int lang) {
    lock.lock();
    try {
        return _nsIScriptGlobalObject_GetScriptContext(ptr, lang);
    } finally {
        lock.unlock();
    }
}
/**
 * @method flags=cpp
 * @param ptr cast=(nsIScriptContext *)
 */
public static final native int /*long*/ _nsIScriptContext_GetNativeContext(int /*long*/ ptr);
public static final int /*long*/ nsIScriptContext_GetNativeContext(int /*long*/ ptr) {
    lock.lock();
    try {
        return _nsIScriptContext_GetNativeContext(ptr);
    } finally {
        lock.unlock();
    }
}

/**
 * @method flags=cpp
    try {
/* CID constants */
const nsID NS_APPSHELL_CID = { 0x2d96b3df, 0xc051, 0x11d1, [0xa8,0x27,0x00,0x40,0x95,0x9a,0x28, 0xc9]}; //$NON-NLS-1$
const nsID NS_CATEGORYMANAGER_CID = { 0x16d222a6, 0x1dd2, 0x11b2, [0xb6,0x93,0xf3,0x8b,0x02,0xc0,0x21,0xb2]}; //$NON-NLS-1$
const nsID NS_DOWNLOAD_CID = { 0xe3fa9D0a, 0x1dd1, 0x11b2, [0xbd,0xef,0x8c,0x72,0x0b,0x59,0x74,0x45]}; //$NON-NLS-1$
const nsID NS_FILEPICKER_CID = { 0x54ae32f8, 0x1dd2, 0x11b2, [0xa2,0x09,0xdf,0x7c,0x50,0x53,0x70,0xf8]}; //$NON-NLS-1$
const nsID NS_HELPERAPPLAUNCHERDIALOG_CID = {0xf68578eb,0x6ec2,0x4169,[0xae,0x19,0x8c,0x62,0x43,0xf0,0xab,0xe1]}; //$NON-NLS-1$
const nsID NS_INPUTSTREAMCHANNEL_CID = {0x6ddb050c,0x0d04,0x11d4,[0x98,0x6e,0x00,0xc0,0x4f,0xa0,0xcf,0x4a]}; //$NON-NLS-1$
const nsID NS_IOSERVICE_CID = {0x9ac9e770,0x18bc,0x11d3,[0x93,0x37,0x00,0x10,0x4b,0xa0,0xfd,0x40]}; //$NON-NLS-1$
const nsID NS_LOADGROUP_CID = {0xe1c61582,0x2a84,0x11d3,[0x8c,0xce,0x00,0x60,0xb0,0xfc,0x14,0xa3]}; //$NON-NLS-1$
const nsID NS_PROMPTSERVICE_CID = {0xa2112d6a,0x0e28,0x421f,[0xb4,0x6a,0x25,0xc0,0xb3,0x08,0xcb,0xd0]}; //$NON-NLS-1$
    }
const String NS_CONTEXTSTACK_CONTRACTID = "@mozilla.org/js/xpc/ContextStack;1"; //$NON-NLS-1$
const String NS_COOKIEMANAGER_CONTRACTID = "@mozilla.org/cookiemanager;1"; //$NON-NLS-1$
const String NS_DIRECTORYSERVICE_CONTRACTID = "@mozilla.org/file/directory_service;1"; //$NON-NLS-1$
const String NS_DOMSERIALIZER_CONTRACTID = "@mozilla.org/xmlextras/xmlserializer;1"; //$NON-NLS-1$
const String NS_DOWNLOAD_CONTRACTID = "@mozilla.org/download;1"; //$NON-NLS-1$
const String NS_FILEPICKER_CONTRACTID = "@mozilla.org/filepicker;1"; //$NON-NLS-1$
const String NS_HELPERAPPLAUNCHERDIALOG_CONTRACTID = "@mozilla.org/helperapplauncherdialog;1"; //$NON-NLS-1$
const String NS_MEMORY_CONTRACTID = "@mozilla.org/xpcom/memory-service;1"; //$NON-NLS-1$
const String NS_OBSERVER_CONTRACTID = "@mozilla.org/observer-service;1"; //$NON-NLS-1$
const String NS_PREFLOCALIZEDSTRING_CONTRACTID = "@mozilla.org/pref-localizedstring;1"; //$NON-NLS-1$
const String NS_PREFSERVICE_CONTRACTID = "@mozilla.org/preferences-service;1"; //$NON-NLS-1$
const String NS_PROMPTSERVICE_CONTRACTID = "@mozilla.org/embedcomp/prompt-service;1"; //$NON-NLS-1$
const String NS_TRANSFER_CONTRACTID = "@mozilla.org/transfer;1"; //$NON-NLS-1$
const String NS_WEBNAVIGATIONINFO_CONTRACTID = "@mozilla.org/webnavigation-info;1"; //$NON-NLS-1$
const String NS_WINDOWWATCHER_CONTRACTID = "@mozilla.org/embedcomp/window-watcher;1"; //$NON-NLS-1$
/* directory service constants */
const String NS_APP_APPLICATION_REGISTRY_DIR = "AppRegD"; //$NON-NLS-1$
const String NS_APP_CACHE_PARENT_DIR = "cachePDir"; //$NON-NLS-1$
const String NS_APP_HISTORY_50_FILE = "UHist"; //$NON-NLS-1$
const String NS_APP_LOCALSTORE_50_FILE = "LclSt"; //$NON-NLS-1$
const String NS_APP_PLUGINS_DIR_LIST = "APluginsDL"; //$NON-NLS-1$
const String NS_APP_PREF_DEFAULTS_50_DIR = "PrfDef"; //$NON-NLS-1$
const String NS_APP_PREFS_50_DIR = "PrefD"; //$NON-NLS-1$
const String NS_APP_PREFS_50_FILE = "PrefF"; //$NON-NLS-1$
const String NS_APP_USER_CHROME_DIR = "UChrm"; //$NON-NLS-1$
const String NS_APP_USER_MIMETYPES_50_FILE = "UMimTyp"; //$NON-NLS-1$
const String NS_APP_USER_PROFILE_50_DIR = "ProfD"; //$NON-NLS-1$
const String NS_GRE_COMPONENT_DIR = "GreComsD"; //$NON-NLS-1$
const String NS_GRE_DIR = "GreD"; //$NON-NLS-1$
const String NS_OS_CURRENT_PROCESS_DIR = "CurProcD"; //$NON-NLS-1$
const String NS_OS_HOME_DIR = "Home"; //$NON-NLS-1$
const String NS_OS_TEMP_DIR = "TmpD"; //$NON-NLS-1$
const String NS_XPCOM_COMPONENT_DIR = "ComsD"; //$NON-NLS-1$
const String NS_XPCOM_CURRENT_PROCESS_DIR = "XCurProcD"; //$NON-NLS-1$
const String NS_XPCOM_INIT_CURRENT_PROCESS_DIR = "MozBinD"; //$NON-NLS-1$
    try {
        return _nsIMemory_Alloc(ptr, size);
    } finally {
        lock.unlock();
    }
}
/**
 * @method flags=cpp
 * @param ptr1 cast=(nsIMemory *)
 * @param ptr2 cast=(void *)
 * @param size cast=(size_t)
 */
public static final native int /*long*/ _nsIMemory_Realloc(int /*long*/ ptr1, int /*long*/ ptr2, int size);
public static final int /*long*/ nsIMemory_Realloc(int /*long*/ ptr1, int /*long*/ ptr2, int size) {
    lock.lock();
    try {
        return _nsIMemory_Realloc(ptr1, ptr2, size);
    } finally {
        lock.unlock();
    }
}
/** @param functionLoad cast=(const nsDynamicFunctionLoad *) */
public static final native int _XPCOMGlueLoadXULFunctions (int /*long*/ functionLoad);
public static final int XPCOMGlueLoadXULFunctions (int /*long*/ functionLoad) {
    lock.lock();
    try {
        return _XPCOMGlueLoadXULFunctions(functionLoad);
    } finally {
        lock.unlock();
    }
}
public static final native int _Call(int /*long*/ ptr);
public static final int Call(int /*long*/ ptr) {
    lock.lock();
    try {
        return _Call(ptr);
    } finally {
        lock.unlock();
    }
}

/**
 * @param ptr cast=(DWT_XREInitEmbedding)
 * @param aLibXULDirectory cast=(nsILocalFile *)
 * @param aAppDirectory cast=(nsILocalFile *)
 * @param aAppDirProvider cast=(nsIDirectoryServiceProvider *)
 * @param aStaticComponents cast=(nsStaticModuleInfo const *)
 */
public static final native int _Call(int /*long*/ ptr, int /*long*/ aLibXULDirectory, int /*long*/ aAppDirectory, int /*long*/ aAppDirProvider, int /*long*/ aStaticComponents, int aStaticComponentsCount);
public static final int Call(int /*long*/ ptr, int /*long*/ aLibXULDirectory, int /*long*/ aAppDirectory, int /*long*/ aAppDirProvider, int /*long*/ aStaticComponents, int aStaticComponentsCount) {
    lock.lock();
    try {
        return _Call(ptr, aLibXULDirectory, aAppDirectory, aAppDirProvider, aStaticComponents, aStaticComponentsCount);
    } finally {
        lock.unlock();
    }
}

static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, double arg0);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, double arg0) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, char[] arg1, int[] arg2);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, char[] arg1, int[] arg2) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, char[] arg1, long[] arg2);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, char[] arg1, long[] arg2) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, long [] arg0, long [] arg1);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, long [] arg0, long [] arg1) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1);
    } finally {
        lock.unlock();
    }
}

static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, short arg0, int arg1, int arg2, int arg3);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, short arg0, int arg1, int arg2, int arg3) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, short arg0, long arg1, int arg2, long arg3);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, short arg0, long arg1, int arg2, long arg3) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3);
    } finally {
        lock.unlock();
    }
}

static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, byte[] arg0, long arg1, int[] arg2);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, byte[] arg0, long arg1, int[] arg2) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, long[] arg2);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, long[] arg2) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2);
    } finally {
        lock.unlock();
    }
}
}
/* XPCOM constants */
const int NS_OK =  0;
const int NS_COMFALSE = 1;
const int NS_BINDING_ABORTED = 0x804B0002;
const int NS_ERROR_BASE = 0xc1f30000;
const int NS_ERROR_NOT_INITIALIZED =  NS_ERROR_BASE + 1;
const int NS_ERROR_ALREADY_INITIALIZED = NS_ERROR_BASE + 2;
const int NS_ERROR_NOT_IMPLEMENTED =  0x80004001;
const int NS_NOINTERFACE =  0x80004002;
const int NS_ERROR_NO_INTERFACE =  NS_NOINTERFACE;
const int NS_ERROR_INVALID_POINTER =  0x80004003;
const int NS_ERROR_NULL_POINTER = NS_ERROR_INVALID_POINTER;
const int NS_ERROR_ABORT = 0x80004004;
const int NS_ERROR_FAILURE = 0x80004005;
const int NS_ERROR_UNEXPECTED = 0x8000ffff;
const int NS_ERROR_OUT_OF_MEMORY = 0x8007000e;
const int NS_ERROR_ILLEGAL_VALUE = 0x80070057;
const int NS_ERROR_INVALID_ARG = NS_ERROR_ILLEGAL_VALUE;
const int NS_ERROR_NO_AGGREGATION = 0x80040110;
const int NS_ERROR_NOT_AVAILABLE = 0x80040111;
const int NS_ERROR_FACTORY_NOT_REGISTERED = 0x80040154;
const int NS_ERROR_FACTORY_REGISTER_AGAIN = 0x80040155;
const int NS_ERROR_FACTORY_NOT_LOADED = 0x800401f8;
const int NS_ERROR_FACTORY_NO_SIGNATURE_SUPPORT = NS_ERROR_BASE + 0x101;
const int NS_ERROR_FACTORY_EXISTS = NS_ERROR_BASE + 0x100;
const int NS_ERROR_HTMLPARSER_UNRESOLVEDDTD = 0x804e03f3;
const int NS_ERROR_FILE_NOT_FOUND = 0x80520012;
const int NS_ERROR_FILE_UNRECOGNIZED_PATH = 0x80520001;
    }
public nsresult NS_FAILED( nsresult result ) {
    return result & 0x80000000;
    } finally {
        lock.unlock();
public nsresult NS_SUCCEEDED( nsresult result ) {
    return !(result & 0x80000000);
        lock.unlock();
    }
public PRUint32 strlen_PRUnichar ( PRUnichar* str )
{
    PRUint32 len = 0;
    if (str !is null) 
        while (*(str++) != 0) len++;
    return len;
    }
}
/******************************************************************************
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, byte[] arg1, short arg2);
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, byte[] arg1, short arg2);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, byte[] arg1, short arg2) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2);
    } finally {
        lock.unlock();
    }
}

static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, byte[] arg0, int arg1, nsID arg2, int[] arg3);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, byte[] arg0, int arg1, nsID arg2, int[] arg3) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, byte[] arg0, long arg1, nsID arg2, long[] arg3);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, byte[] arg0, long arg1, nsID arg2, long[] arg3) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, byte[] arg1, int arg2, int[] arg3);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, byte[] arg1, int arg2, int[] arg3) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, byte[] arg1, long arg2, long[] arg3);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, byte[] arg1, long arg2, long[] arg3) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, char[] arg1, char[] arg2, int[] arg3);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, char[] arg1, char[] arg2, int[] arg3) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, char[] arg1, char[] arg2, long [] arg3);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, char[] arg1, char[] arg2, long [] arg3) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, char[] arg1, char[] arg2, int[] arg3);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, char[] arg1, char[] arg2, int[] arg3) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, int arg2, char[] arg3);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, int arg2, char[] arg3) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, int arg2, char[] arg3);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, int arg2, char[] arg3) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, int arg2, int arg3);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, int arg2, int arg3) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, int arg2, int arg3);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, int arg2, int arg3) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, long arg2, int arg3);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, long arg2, int arg3) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, int arg2, int[] arg3);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, int arg2, int[] arg3) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, long arg2, long[] arg3);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, long arg2, long[] arg3) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, int arg2, int[] arg3);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, int arg2, int[] arg3) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, int[] arg0, int[] arg1, int[] arg2, int[] arg3);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, int[] arg0, int[] arg1, int[] arg2, int[] arg3) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, nsID arg0, byte[] arg1, byte[] arg2, int arg3);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, nsID arg0, byte[] arg1, byte[] arg2, int arg3) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, nsID arg0, byte[] arg1, byte[] arg2, long arg3);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, nsID arg0, byte[] arg1, byte[] arg2, long arg3) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, nsID arg0, int arg1, nsID arg2, int[] arg3);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, nsID arg0, int arg1, nsID arg2, int[] arg3) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, nsID arg0, long arg1, nsID arg2, long [] arg3);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, nsID arg0, long arg1, nsID arg2, long [] arg3) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, byte[] arg0, int arg1, int[] arg2, int[] arg3);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, byte[] arg0, int arg1, int[] arg2, int[] arg3) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, byte[] arg0, int arg1, long [] arg2, int[] arg3);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, byte[] arg0, int arg1, long [] arg2, int[] arg3) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, byte[] arg2, byte[] arg3);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, byte[] arg2, byte[] arg3) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, byte[] arg2, byte[] arg3);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, byte[] arg2, byte[] arg3) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, byte[] arg2, int arg3);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, byte[] arg2, int arg3) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, byte[] arg2, long arg3);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, byte[] arg2, long arg3) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, short[] arg0, int arg1, int[] arg2, int[] arg3);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, short[] arg0, int arg1, int[] arg2, int[] arg3) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, short[] arg0, long arg1, int[] arg2, long[] arg3);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, short[] arg0, long arg1, int[] arg2, long[] arg3) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3);
    } finally {
        lock.unlock();
    }
}

static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, char[] arg0, int arg1, int arg2, int arg3, int arg4);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, char[] arg0, int arg1, int arg2, int arg3, int arg4) {
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, byte[] arg0, int arg1, long arg2, long [] arg3, int[] arg4);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, byte[] arg0, int arg1, long arg2, long [] arg3, int[] arg4) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4);
    } finally {
        lock.unlock();
    }
}
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, long arg2, long arg3, long arg4);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, long arg2, long arg3, long arg4) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, int arg2, int arg3, int arg4);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, int arg2, int arg3, int arg4) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int[] arg1, int[] arg2, int[] arg3, int[] arg4);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int[] arg1, int[] arg2, int[] arg3, int[] arg4) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, char[] arg1, char[] arg2, char[] arg3, int[] arg4);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, char[] arg1, char[] arg2, char[] arg3, int[] arg4) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, char[] arg1, char[] arg2, char[] arg3, int[] arg4);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, char[] arg1, char[] arg2, char[] arg3, int[] arg4) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, byte[] arg0, int arg1, int arg2, int[] arg3, int[] arg4);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, byte[] arg0, int arg1, int arg2, int[] arg3, int[] arg4) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, byte[] arg0, int arg1, long arg2, long [] arg3, int[] arg4);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, byte[] arg0, int arg1, long arg2, long [] arg3, int[] arg4) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, byte[] arg2, int arg3, int arg4);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, byte[] arg2, int arg3, int arg4) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4);
    } finally {
        lock.unlock();
    }
}

static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, byte[] arg2, long arg3, int arg4);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, byte[] arg2, long arg3, int arg4) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, nsID arg1, int arg2, int arg3, int[] arg4);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, nsID arg1, int arg2, int arg3, int[] arg4) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, nsID arg1, long arg2, long arg3, long[] arg4);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, nsID arg1, long arg2, long arg3, long[] arg4) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4);
    } finally {
        lock.unlock();
    }
}
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, byte[] arg1, byte[] arg2, byte[] arg3, int arg4, int[] arg5) {
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, char[] arg2, long arg3, long arg4, long arg5);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, char[] arg2, long arg3, long arg4, long arg5) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, char[] arg2, long arg3, long arg4, long arg5);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, char[] arg2, long arg3, long arg4, long arg5) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5);
    } finally {
        lock.unlock();
    }
}
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, char[] arg2, int arg3, long arg4, int arg5);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, char[] arg2, int arg3, long arg4, int arg5) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, char[] arg2, long arg3, long arg4, long arg5);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, char[] arg2, long arg3, long arg4, long arg5) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, char[] arg2, long arg3, long arg4, long arg5);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, char[] arg2, long arg3, long arg4, long arg5) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, int[] arg0, int[] arg1, int[] arg2, int[] arg3, int[] arg4, int[] arg5);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, int[] arg0, int[] arg1, int[] arg2, int[] arg3, int[] arg4, int[] arg5) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5);
    } finally {
        lock.unlock();
    }
}

static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, long[] arg0, long[] arg1, long[] arg2, long[] arg3, long[] arg4, int[] arg5);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, long[] arg0, long[] arg1, long[] arg2, long[] arg3, long[] arg4, int[] arg5) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, int arg2, int arg3, int arg4, int arg5);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, int arg2, int arg3, int arg4, int arg5) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, int arg2, int arg3, int arg4, int arg5);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, int arg2, int arg3, int arg4, int arg5) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, int arg2, int arg3, int arg4, int[] arg5);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, int arg2, int arg3, int arg4, int [] arg5) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5);
    } finally {
        lock.unlock();
    }
}

static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, long arg2, long arg3, long arg4, long[] arg5);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, long arg2, long arg3, long arg4, long[] arg5) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, nsID arg0, byte[] arg1, byte[] arg2, int arg3, byte[] arg4, byte[] arg5);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, nsID arg0, byte[] arg1, byte[] arg2, int arg3, byte[] arg4, byte[] arg5) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, nsID arg0, byte[] arg1, byte[] arg2, long arg3, byte[] arg4, byte[] arg5);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, nsID arg0, byte[] arg1, byte[] arg2, long arg3, byte[] arg4, byte[] arg5) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, long arg2, long arg3, long arg4, long arg5);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, long arg2, long arg3, long arg4, long arg5) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, long arg2, long arg3, long arg4, long arg5);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, long arg2, long arg3, long arg4, long arg5) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, char[] arg1, char[] arg2, char[] arg3, int[] arg4, int[] arg5);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, char[] arg1, char[] arg2, char[] arg3, int[] arg4, int[] arg5) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, char[] arg1, char[] arg2, char[] arg3, int[] arg4, int[] arg5);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, char[] arg1, char[] arg2, char[] arg3, int[] arg4, int[] arg5) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, byte[] arg0, byte[] arg1, byte[] arg2, int arg3, int arg4, int[] arg5);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, byte[] arg0, byte[] arg1, byte[] arg2, int arg3, int arg4, int[] arg5) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, byte[] arg0, byte[] arg1, byte[] arg2, int arg3, int arg4, long[] arg5);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, byte[] arg0, byte[] arg1, byte[] arg2, int arg3, int arg4, long[] arg5) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, int arg2, int arg3, int[] arg4, int[] arg5);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, int arg2, int arg3, int[] arg4, int[] arg5) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, int arg1, int arg2, long arg3, int[] arg4, long [] arg5);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, int arg1, int arg2, long arg3, int[] arg4, long [] arg5) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, char[] arg2, char[] arg3, int arg4, int [] arg5);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, char[] arg2, char[] arg3, int arg4, int [] arg5) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, char[] arg2, char[] arg3, int arg4, long[] arg5);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, char[] arg2, char[] arg3, int arg4, long[] arg5) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, int arg2, byte[] arg3, byte[] arg4, int arg5);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, int arg2, byte[] arg3, byte[] arg4, int arg5) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, long arg2, byte[] arg3, byte[] arg4, long arg5);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, long arg1, long arg2, byte[] arg3, byte[] arg4, long arg5) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5);
    } finally {
        lock.unlock();
    }
}
    } finally {
        lock.unlock();
    }
}

    XPCOM Startup functions

******************************************************************************/

extern (System):

struct nsStaticModuleInfo
{
    char *name;
    nsGetModuleProc getModule;
}

alias nsresult function (nsIComponentManager, nsIFile, nsIModule*) nsGetModuleProc;

/******************************************************************************

******************************************************************************/

nsresult  NS_InitXPCOM2( nsIServiceManager *result, nsIFile binDirectory,
	                     nsIDirectoryServiceProvider appFileLocationProvider );
nsresult  NS_InitXPCOM3( nsIServiceManager *result, nsIFile binDirectory,
	                     nsIDirectoryServiceProvider appFileLocationProvider,
	                     nsStaticModuleInfo* staticComponents,
	                     PRUint32 componentCount );
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, int arg2, int arg3, int arg4, int arg5, int arg6, int[] arg7);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, int arg2, int arg3, int arg4, int arg5, int arg6, int[] arg7) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, long arg1, long arg2, long arg3, long arg4, long arg5, long arg6, long[] arg7);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, long arg1, long arg2, long arg3, long arg4, long arg5, long arg6, long[] arg7) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7);
    } finally {
        lock.unlock();
    }
}

nsresult  NS_ShutdownXPCOM(nsIServiceManager servMgr);
nsresult  NS_GetServiceManager(nsIServiceManager *result);
nsresult  NS_GetComponentManager(nsIComponentManager *result);
nsresult  NS_GetComponentRegistrar(nsIComponentRegistrar *result);
nsresult  NS_GetMemoryManager(nsIMemory *result);
nsresult  NS_NewLocalFile(nsAString* path, PRBool followLinks, nsILocalFile* result);
nsresult  NS_NewNativeLocalFile(nsACString* path, PRBool followLinks, nsILocalFile* result);
void *    NS_Alloc(PRSize size);
void *    NS_Realloc(void *ptr, PRSize size);
void      NS_Free(void *ptr);
nsresult  NS_GetDebug(nsIDebug *result);
nsresult  NS_GetTraceRefcnt(nsITraceRefcnt *result);
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, int arg2, int arg3, int arg4, int arg5, int arg6, int arg7, int arg8, int arg9, int arg10, int arg11, int arg12, short arg13, int arg14);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, int arg0, int arg1, int arg2, int arg3, int arg4, int arg5, int arg6, int arg7, int arg8, int arg9, int arg10, int arg11, int arg12, short arg13, int arg14) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14);
    } finally {
        lock.unlock();
    }
}
static final native int _VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, int arg1, int arg2, long arg3, int arg4, int arg5, int arg6, int arg7, int arg8, int arg9, int arg10, int arg11, int arg12, short arg13, long arg14);
static final int VtblCall(int fnNumber, int /*long*/ ppVtbl, long arg0, int arg1, int arg2, long arg3, int arg4, int arg5, int arg6, int arg7, int arg8, int arg9, int arg10, int arg11, int arg12, short arg13, long arg14) {
    lock.lock();
    try {
        return _VtblCall(fnNumber, ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14);
    } finally {
        lock.unlock();
    }
}

/**
 * @method flags=no_gen
 */
public static final native int GetAddress(int ptr, int index);

