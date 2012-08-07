/*******************************************************************************
 * Copyright (c) 2003, 2009 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *      John Reimer <terminal.node@gmail.com>
 *******************************************************************************/
module dwt.browser.Mozilla;

import dwt.dwthelper.utils;

import tango.text.locale.Core;
import tango.io.Stdout;
import tango.text.convert.Format;
import tango.io.Console;
import tango.sys.Environment;
import tango.stdc.string;

version (linux)
    import dwt.internal.c.gtk;

else version (darwin)
    import objc = dwt.internal.objc.runtime;

import dwt.*;
import dwt.widgets.*;
import dwt.graphics.*;
import dwt.internal.*;
import dwt.internal.mozilla.*;

import dwt.browser.Browser;
import dwt.browser.WebBrowser;
import dwt.browser.MozillaDelegate;
import dwt.browser.AppFileLocProvider;
import dwt.browser.WindowCreator2;
import dwt.browser.PromptService2Factory;
import dwt.browser.HelperAppLauncherDialogFactory;
import dwt.browser.DownloadFactory;
import dwt.browser.DownloadFactory_1_8;
import dwt.browser.FilePickerFactory;
import dwt.browser.FilePickerFactory_1_8;
import dwt.browser.InputStream;
import dwt.browser.StatusTextEvent;
import dwt.browser.ProgressEvent;
import dwt.browser.LocationEvent;
import dwt.browser.WindowEvent;
import dwt.browser.TitleEvent;


import XPCOM = dwt.internal.mozilla.XPCOM;
import XPCOMInit = dwt.internal.mozilla.XPCOMInit;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsIDOMNode;
import dwt.internal.mozilla.nsIDOMEventListener;
import dwt.internal.mozilla.nsIDOMDocument;
import dwt.internal.mozilla.nsIFactory;
import dwt.internal.mozilla.nsIRequest;
import dwt.internal.mozilla.nsIStreamListener;
import dwt.internal.mozilla.nsIWindowCreator;
import dwt.internal.mozilla.nsStringAPI;

import dwt.widgets.Control;

class Mozilla : WebBrowser, 
                nsIWeakReference, 
                nsIWebProgressListener, 
                nsIWebBrowserChrome,
                nsIWebBrowserChromeFocus, 
                nsIEmbeddingSiteWindow, 
                nsIInterfaceRequestor, 
                nsISupportsWeakReference, 
                nsIContextMenuListener, 
                nsIURIContentListener,
                nsITooltipListener, 
                nsIDOMEventListener {
                    
    version (linux)
        GtkWidget* embedHandle;
    else version (darwin)
        objc.id embedHandle;

    nsIWebBrowser webBrowser;
    Object webBrowserObject;
    MozillaDelegate mozDelegate;

    int chromeFlags = nsIWebBrowserChrome.CHROME_DEFAULT;
    int refCount, lastKeyCode, lastCharCode, authCount;
    nsIRequest request;
    Point location, size;
    bool visible, isChild, ignoreDispose;
    Shell tip = null;
    Listener listener;
    nsIDOMWindow[] unhookedDOMWindows;
    String lastNavigateURL;
    byte[] htmlBytes;

    static nsIAppShell AppShell;
    static AppFileLocProvider LocationProvider;
    static WindowCreator2 WindowCreator;
    static int BrowserCount, NextJSFunctionIndex = 1;
    static Hashtable AllFunctions = new Hashtable (); 
    static bool Initialized, IsPre_1_8, IsPre_1_9, PerformedVersionCheck, XPCOMWasGlued, XPCOMInitWasGlued;

    /* XULRunner detect constants */
    static const String GRERANGE_LOWER = "1.8.1.2"; //$NON-NLS-1$
    static const String GRERANGE_LOWER_FALLBACK = "1.8"; //$NON-NLS-1$
    static const bool LowerRangeInclusive = true;
    static const String GRERANGE_UPPER = "1.9.*"; //$NON-NLS-1$
    static const bool UpperRangeInclusive = true;

    static const int MAX_PORT = 65535;
    static const String SEPARATOR_OS = System.getProperty ("file.separator"); //$NON-NLS-1$
    static const String ABOUT_BLANK = "about:blank"; //$NON-NLS-1$
    static const String DISPOSE_LISTENER_HOOKED = "dwt.browser.Mozilla.disposeListenerHooked"; //$NON-NLS-1$
    static const String PREFIX_JAVASCRIPT = "javascript:"; //$NON-NLS-1$
    static const String PREFERENCE_CHARSET = "intl.charset.default"; //$NON-NLS-1$
    static const String PREFERENCE_DISABLEOPENDURINGLOAD = "dom.disable_open_during_load"; //$NON-NLS-1$
    static const String PREFERENCE_DISABLEWINDOWSTATUSCHANGE = "dom.disable_window_status_change"; //$NON-NLS-1$
    static const String PREFERENCE_LANGUAGES = "intl.accept_languages"; //$NON-NLS-1$
    static const String PREFERENCE_PROXYHOST_FTP = "network.proxy.ftp"; //$NON-NLS-1$
    static const String PREFERENCE_PROXYPORT_FTP = "network.proxy.ftp_port"; //$NON-NLS-1$
    static const String PREFERENCE_PROXYHOST_HTTP = "network.proxy.http"; //$NON-NLS-1$
    static const String PREFERENCE_PROXYPORT_HTTP = "network.proxy.http_port"; //$NON-NLS-1$
    static const String PREFERENCE_PROXYHOST_SSL = "network.proxy.ssl"; //$NON-NLS-1$
    static const String PREFERENCE_PROXYPORT_SSL = "network.proxy.ssl_port"; //$NON-NLS-1$
    static const String PREFERENCE_PROXYTYPE = "network.proxy.type"; //$NON-NLS-1$
    static const String PROFILE_AFTER_CHANGE = "profile-after-change"; //$NON-NLS-1$
    static const String PROFILE_BEFORE_CHANGE = "profile-before-change"; //$NON-NLS-1$
    static       String PROFILE_DIR; //= SEPARATOR_OS ~ "eclipse" ~ SEPARATOR_OS; //$NON-NLS-1$
    static const String PROFILE_DO_CHANGE = "profile-do-change"; //$NON-NLS-1$
    static const String PROPERTY_PROXYPORT = "network.proxy_port"; //$NON-NLS-1$
    static const String PROPERTY_PROXYHOST = "network.proxy_host"; //$NON-NLS-1$
    static const String SEPARATOR_LOCALE = "-"; //$NON-NLS-1$
    static const String SHUTDOWN_PERSIST = "shutdown-persist"; //$NON-NLS-1$
    static const String STARTUP = "startup"; //$NON-NLS-1$
    static const String TOKENIZER_LOCALE = ","; //$NON-NLS-1$
    static const String URI_FROMMEMORY = "file:///"; //$NON-NLS-1$
    static const String XULRUNNER_PATH = "dwt.browser.XULRunnerPath"; //$NON-NLS-1$

// TEMPORARY CODE
static const String GRE_INITIALIZED = "dwt.browser.XULRunnerInitialized"; //$NON-NLS-1$

    this () {
        PROFILE_DIR = SEPARATOR_OS ~ "eclipse" ~ SEPARATOR_OS;
        MozillaClearSessions = new class() Runnable {
            public void run () {
                if (!Initialized) return;
                nsIServiceManager serviceManager;
                int rc = XPCOM.NS_GetServiceManager (&serviceManager);
                if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
                if (serviceManager is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);

                nsICookieManager manager;
                rc = serviceManager.GetServiceByContractID (XPCOM.NS_COOKIEMANAGER_CONTRACTID.ptr, &nsICookieManager.IID, cast(void**)&manager);
                if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
                if (manager is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
                serviceManager.Release ();

                nsISimpleEnumerator enumerator;
                rc = manager.GetEnumerator (&enumerator);
                if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);

                PRBool moreElements;
                rc = enumerator.HasMoreElements (&moreElements);
                if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
                while (moreElements !is 0) {
                    nsICookie cookie;
                    rc = enumerator.GetNext (cast(nsISupports*)&cookie);
                    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
                    PRUint64 expires;
                    rc = cookie.GetExpires (&expires);
                    if (expires is 0) {
                        /* indicates a session cookie */
                        scope auto domain = new nsEmbedCString;
                        scope auto name = new nsEmbedCString;
                        scope auto path = new nsEmbedCString;
                        cookie.GetHost (cast(nsACString*)domain);
                        cookie.GetName (cast(nsACString*)name);
                        cookie.GetPath (cast(nsACString*)path);
                        rc = manager.Remove (cast(nsACString*)domain, cast(nsACString*)name, cast(nsACString*)path, 0);
                        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
                    }
                    cookie.Release ();
                    rc = enumerator.HasMoreElements (&moreElements);
                    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
                }
                enumerator.Release ();
                manager.Release ();
            }
        };

        MozillaGetCookie = new Runnable() {
            public void run() {
                if (!Initialized) return;

                int /*long*/[] result = new int /*long*/[1];
                int rc = XPCOM.NS_GetServiceManager (result);
                if (rc !is XPCOM.NS_OK) error (rc);
                if (result[0] is 0) error (XPCOM.NS_NOINTERFACE);

                nsIServiceManager serviceManager = new nsIServiceManager (result[0]);
                result[0] = 0;
                rc = serviceManager.GetService (XPCOM.NS_IOSERVICE_CID, nsIIOService.NS_IIOSERVICE_IID, result);
                if (rc !is XPCOM.NS_OK) error (rc);
                if (result[0] is 0) error (XPCOM.NS_NOINTERFACE);

                nsIIOService ioService = new nsIIOService (result[0]);
                result[0] = 0;
                byte[] bytes = MozillaDelegate.wcsToMbcs (null, CookieUrl, false);
                int /*long*/ aSpec = XPCOM.nsEmbedCString_new (bytes, bytes.length);
                rc = ioService.NewURI (aSpec, null, 0, result);
                XPCOM.nsEmbedCString_delete (aSpec);
                ioService.Release ();
                if (rc !is XPCOM.NS_OK) {
                    serviceManager.Release ();
                    return;
                }
                if (result[0] is 0) error (XPCOM.NS_ERROR_NULL_POINTER);

                nsIURI aURI = new nsIURI (result[0]);
                result[0] = 0;
                byte[] aContractID = MozillaDelegate.wcsToMbcs (null, XPCOM.NS_COOKIESERVICE_CONTRACTID, true);
                rc = serviceManager.GetServiceByContractID (aContractID, nsICookieService.NS_ICOOKIESERVICE_IID, result);
                int /*long*/ cookieString;
                if (rc is XPCOM.NS_OK && result[0] !is 0) {
                    nsICookieService cookieService = new nsICookieService (result[0]);
                    result[0] = 0;
                    rc = cookieService.GetCookieString (aURI.getAddress(), 0, result);
                    cookieService.Release ();
                    if (rc !is XPCOM.NS_OK) error (rc);
                    if (result[0] is 0) {
                        aURI.Release ();
                        serviceManager.Release ();
                        return;
                    }
                    cookieString = result[0];
                } else {
                    result[0] = 0;
                    rc = serviceManager.GetServiceByContractID (aContractID, nsICookieService_1_9.NS_ICOOKIESERVICE_IID, result);
                    if (rc !is XPCOM.NS_OK) error (rc);
                    if (result[0] is 0) error (XPCOM.NS_NOINTERFACE);
                    nsICookieService_1_9 cookieService = new nsICookieService_1_9 (result[0]);
                    result[0] = 0;
                    rc = cookieService.GetCookieString(aURI.getAddress(), 0, result);
                    cookieService.Release ();
                    if (rc !is XPCOM.NS_OK) error (rc);
                    if (result[0] is 0) {
                        aURI.Release ();
                        serviceManager.Release ();
                        return;
                    }
                    cookieString = result[0];
                }
                aURI.Release ();
                serviceManager.Release ();
                result[0] = 0;

                int length = C.strlen (cookieString);
                bytes = new byte[length];
                XPCOM.memmove (bytes, cookieString, length);
                C.free (cookieString);
                String allCookies = new String (MozillaDelegate.mbcsToWcs (null, bytes));
                StringTokenizer tokenizer = new StringTokenizer (allCookies, ";"); //$NON-NLS-1$
                while (tokenizer.hasMoreTokens ()) {
                    String cookie = tokenizer.nextToken ();
                    int index = cookie.indexOf ('=');
                    if (index !is -1) {
                        String name = cookie.substring (0, index).trim ();
                        if (name.equals (CookieName)) {
                            CookieValue = cookie.substring (index + 1).trim ();
                            return;
                        }
                    }
                }
            }
        };

        MozillaSetCookie = new Runnable() {
            public void run() {
                if (!Initialized) return;

                int /*long*/[] result = new int /*long*/[1];
                int rc = XPCOM.NS_GetServiceManager (result);
                if (rc !is XPCOM.NS_OK) error (rc);
                if (result[0] is 0) error (XPCOM.NS_NOINTERFACE);

                nsIServiceManager serviceManager = new nsIServiceManager (result[0]);
                result[0] = 0;
                rc = serviceManager.GetService (XPCOM.NS_IOSERVICE_CID, nsIIOService.NS_IIOSERVICE_IID, result);
                if (rc !is XPCOM.NS_OK) error (rc);
                if (result[0] is 0) error (XPCOM.NS_NOINTERFACE);

                nsIIOService ioService = new nsIIOService (result[0]);
                result[0] = 0;
                byte[] bytes = MozillaDelegate.wcsToMbcs (null, CookieUrl, false);
                int /*long*/ aSpec = XPCOM.nsEmbedCString_new (bytes, bytes.length);
                rc = ioService.NewURI (aSpec, null, 0, result);
                XPCOM.nsEmbedCString_delete (aSpec);
                ioService.Release ();
                if (rc !is XPCOM.NS_OK) {
                    serviceManager.Release ();
                    return;
                }
                if (result[0] is 0) error (XPCOM.NS_ERROR_NULL_POINTER);

                nsIURI aURI = new nsIURI(result[0]);
                result[0] = 0;
                byte[] aCookie = MozillaDelegate.wcsToMbcs (null, CookieValue, true);
                byte[] aContractID = MozillaDelegate.wcsToMbcs (null, XPCOM.NS_COOKIESERVICE_CONTRACTID, true);
                rc = serviceManager.GetServiceByContractID (aContractID, nsICookieService.NS_ICOOKIESERVICE_IID, result);
                if (rc is XPCOM.NS_OK && result[0] !is 0) {
                    nsICookieService cookieService = new nsICookieService (result[0]);
                    rc = cookieService.SetCookieString (aURI.getAddress(), 0, aCookie, 0);
                    cookieService.Release ();
                } else {
                    result[0] = 0;
                    rc = serviceManager.GetServiceByContractID (aContractID, nsICookieService_1_9.NS_ICOOKIESERVICE_IID, result);
                    if (rc !is XPCOM.NS_OK) error (rc);
                    if (result[0] is 0) error (XPCOM.NS_NOINTERFACE);
                    nsICookieService_1_9 cookieService = new nsICookieService_1_9 (result[0]);
                    rc = cookieService.SetCookieString(aURI.getAddress(), 0, aCookie, 0);
                    cookieService.Release ();
                }
                result[0] = 0;
                aURI.Release ();
                serviceManager.Release ();
                CookieResult = rc is 0;
            }
        };
    }

extern(D)
public void create (Composite parent, int style) {
    mozDelegate = new MozillaDelegate (super.browser);
    Display display = parent.getDisplay ();

    if (!Initialized) {
        bool initLoaded = false;
        bool IsXULRunner = false;

        String greInitialized = System.getProperty (GRE_INITIALIZED); 
        if ("true" == greInitialized) { //$NON-NLS-1$
            /* 
             * Another browser has already initialized xulrunner in this process,
             * so just bind to it instead of trying to initialize a new one.
             */
            Initialized = true;
        }
        String mozillaPath = System.getProperty (XULRUNNER_PATH);
        if (mozillaPath is null) {
            // we don't need to load an initial library in D, so set to "true"
            initLoaded = true;
        } else {
            mozillaPath ~= SEPARATOR_OS ~ mozDelegate.getLibraryName ();
            IsXULRunner = true;
        }
         
        if (initLoaded) {
            /* attempt to discover a XULRunner to use as the GRE */
            XPCOMInit.GREVersionRange range;

            range.lower = GRERANGE_LOWER.ptr;
            range.lowerInclusive = LowerRangeInclusive;

            range.upper = GRERANGE_UPPER.ptr;
            range.upperInclusive = UpperRangeInclusive;

            char[] greBuffer = new char[XPCOMInit.PATH_MAX];

            int rc = XPCOMInit.GRE_GetGREPathWithProperties (&range, 1, null, 0, greBuffer.ptr, greBuffer.length);

            /*
             * A XULRunner was not found that supports wrapping of XPCOM handles as JavaXPCOM objects.
             * Drop the lower version bound and try to detect an earlier XULRunner installation.
             */

            if (rc !is XPCOM.NS_OK) {
                range.lower = GRERANGE_LOWER_FALLBACK.ptr;
                rc = XPCOMInit.GRE_GetGREPathWithProperties (&range, 1, null, 0, greBuffer.ptr, greBuffer.length);
            }

            if (rc is XPCOM.NS_OK) {
                /* indicates that a XULRunner was found */
                mozillaPath = greBuffer;
                IsXULRunner = mozillaPath.length > 0;

                /*
                 * Test whether the detected XULRunner can be used as the GRE before loading swt's
                 * XULRunner library.  If it cannot be used then fall back to attempting to use
                 * the GRE pointed to by MOZILLA_FIVE_HOME.
                 * 
                 * One case where this will fail is attempting to use a 64-bit xulrunner while swt
                 * is running in 32-bit mode, or vice versa.
                 */

                if (IsXULRunner) {
                    rc = XPCOMInit.XPCOMGlueStartup (mozillaPath.ptr);
                    if (rc !is XPCOM.NS_OK) {
                        mozillaPath = mozillaPath.substring (0, mozillaPath.lastIndexOf (SEPARATOR_OS));
                        if (Device.DEBUG) Cerr ("cannot use detected XULRunner: ") (mozillaPath).newline; //$NON-NLS-1$
                        
                        /* attempt to XPCOMGlueStartup the GRE pointed at by MOZILLA_FIVE_HOME */
                        auto ptr = Environment.get(XPCOM.MOZILLA_FIVE_HOME);

                        if (ptr is null) {
                            IsXULRunner = false;
                        } else {
                            mozillaPath = ptr;
                            /*
                             * Attempting to XPCOMGlueStartup a mozilla-based GRE !is xulrunner can
                             * crash, so don't attempt unless the GRE appears to be xulrunner.
                             */
                            if (mozillaPath.indexOf("xulrunner") is -1) { //$NON-NLS-1$
                                IsXULRunner = false;    

                            } else {
                                mozillaPath ~= SEPARATOR_OS ~ mozDelegate.getLibraryName ();
                                rc = XPCOMInit.XPCOMGlueStartup (toStringz(mozillaPath));
                                if (rc !is XPCOM.NS_OK) {
                                    IsXULRunner = false;
                                    mozillaPath = mozillaPath.substring (0, mozillaPath.lastIndexOf (SEPARATOR_OS));
                                    if (Device.DEBUG) Cerr ("failed to start as XULRunner: " )(mozillaPath).newline; //$NON-NLS-1$
                                }
                            }
                        } 
                    }
                    if (IsXULRunner) {
                        XPCOMInitWasGlued = true;
                    }
                }
            }
        }

        if (IsXULRunner) {
            if (Device.DEBUG) Cerr ("XULRunner path: ") (mozillaPath).newline; //$NON-NLS-1$

            XPCOMWasGlued = true;

            /*
             * Remove the trailing xpcom lib name from mozillaPath because the
             * Mozilla.initialize and NS_InitXPCOM2 invocations require a directory name only.
             */
            mozillaPath = mozillaPath.substring (0, mozillaPath.lastIndexOf (SEPARATOR_OS));
        } else {
            if ((style & DWT.MOZILLA) !is 0) {
                browser.dispose ();
                String errorString = (mozillaPath !is null && mozillaPath.length > 0) ?
                    " [Failed to use detected XULRunner: " ~ mozillaPath ~ "]" :
                    " [Could not detect registered XULRunner to use]";  //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
                DWT.error (DWT.ERROR_NO_HANDLES, null, errorString);
            }

            /* attempt to use the GRE pointed at by MOZILLA_FIVE_HOME */
            auto mozFiveHome = Environment.get(XPCOM.MOZILLA_FIVE_HOME);
            if (mozFiveHome !is null) {
                mozillaPath = mozFiveHome;
            } else {
                browser.dispose ();
                DWT.error (DWT.ERROR_NO_HANDLES, null, " [Unknown Mozilla path (MOZILLA_FIVE_HOME not set)]"); //$NON-NLS-1$
            }
            if (Device.DEBUG) Cerr ("Mozilla path: ") (mozillaPath).newline; //$NON-NLS-1$

            /*
            * Note.  Embedding a Mozilla GTK1.2 causes a crash.  The workaround
            * is to check the version of GTK used by Mozilla by looking for
            * the libwidget_gtk.so library used by Mozilla GTK1.2. Mozilla GTK2
            * uses the libwidget_gtk2.so library.   
            */
            if (Compatibility.fileExists (mozillaPath, "components/libwidget_gtk.so")) { //$NON-NLS-1$
                browser.dispose ();
                DWT.error (DWT.ERROR_NO_HANDLES, null, " [Mozilla GTK2 required (GTK1.2 detected)]"); //$NON-NLS-1$                         
            }
        }

        if (!Initialized) {
            LocationProvider = new AppFileLocProvider (mozillaPath);
            LocationProvider.AddRef ();

            /* extract external.xpt to temp */
            String tempPath = System.getProperty ("java.io.tmpdir"); //$NON-NLS-1$
            File componentsDir = new File (tempPath, "eclipse/mozillaComponents"); //$NON-NLS-1$
            java.io.InputStream is = Library.class.getResourceAsStream ("/external.xpt"); //$NON-NLS-1$
            if (is !is null) {
                if (!componentsDir.exists ()) {
                    componentsDir.mkdirs ();
                }
                int read;
                byte [] buffer = new byte [4096];
                File file = new File (componentsDir, "external.xpt"); //$NON-NLS-1$
                try {
                    FileOutputStream os = new FileOutputStream (file);
                    while ((read = is.read (buffer)) !is -1) {
                        os.write(buffer, 0, read);
                    }
                    os.close ();
                    is.close ();
                } catch (FileNotFoundException e) {
                } catch (IOException e) {
                }
            }
            if (componentsDir.exists () && componentsDir.isDirectory ()) {
                LocationProvider.setComponentsPath (componentsDir.getAbsolutePath ());
            }

            if (IsXULRunner) {
                int size = XPCOM.nsDynamicFunctionLoad_sizeof ();
                /* alloc memory for two structs, the second is empty to signify the end of the list */
                int /*long*/ ptr = C.malloc (size * 2);
                C.memset (ptr, 0, size * 2);
                nsDynamicFunctionLoad functionLoad = new nsDynamicFunctionLoad ();
                byte[] bytes = MozillaDelegate.wcsToMbcs (null, "XRE_InitEmbedding", true); //$NON-NLS-1$
                functionLoad.functionName = C.malloc (bytes.length);
                C.memmove (functionLoad.functionName, bytes, bytes.length);
                functionLoad.function = C.malloc (C.PTR_SIZEOF);
                C.memmove (functionLoad.function, new int /*long*/[] {0} , C.PTR_SIZEOF);
                XPCOM.memmove (ptr, functionLoad, XPCOM.nsDynamicFunctionLoad_sizeof ());
                XPCOM.XPCOMGlueLoadXULFunctions (ptr);
                C.memmove (result, functionLoad.function, C.PTR_SIZEOF);
                int /*long*/ functionPtr = result[0];
                result[0] = 0;
                C.free (functionLoad.function);
                C.free (functionLoad.functionName);
                C.free (ptr);
                rc = XPCOM.Call (functionPtr, localFile.getAddress (), localFile.getAddress (), LocationProvider.getAddress (), 0, 0);
                if (rc is XPCOM.NS_OK) {
                    System.setProperty (XULRUNNER_PATH, mozillaPath);
                }
            } else {
                rc = XPCOM.NS_InitXPCOM2 (0, localFile.getAddress(), LocationProvider.getAddress ());
            }
            localFile.Release ();
            LocationProvider.Release();
            if (rc !is XPCOM.NS_OK) {
                browser.dispose ();
                DWT.error (DWT.ERROR_NO_HANDLES, null, Format(" [MOZILLA_FIVE_HOME may not point at an embeddable GRE] [NS_InitEmbedding {0} error {1} ] ", mozillaPath, rc ) ); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
            }
            System.setProperty (GRE_INITIALIZED, "true"); //$NON-NLS-1$
        }

        nsIComponentManager componentManager;
        int rc = XPCOM.NS_GetComponentManager (&componentManager);
        if (rc !is XPCOM.NS_OK) {
            browser.dispose ();
            error (rc, __FILE__, __LINE__);
        }
        if (componentManager is null) {
            browser.dispose ();
            error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
        }
        
        if (mozDelegate.needsSpinup ()) {
            /* nsIAppShell is discontinued as of xulrunner 1.9, so do not fail if it is not found */
            rc = componentManager.CreateInstance (&XPCOM.NS_APPSHELL_CID, null, &nsIAppShell.IID, cast(void**)&AppShell);
            if (rc !is XPCOM.NS_ERROR_NO_INTERFACE) {
                if (rc !is XPCOM.NS_OK) {
                    browser.dispose ();
                    error (rc, __FILE__, __LINE__);
                }
                if (AppShell is null) {
                    browser.dispose ();
                    error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
                }
    
                rc = AppShell.Create (null, null);
                if (rc !is XPCOM.NS_OK) {
                    browser.dispose ();
                    error (rc, __FILE__, __LINE__);
                }
                rc = AppShell.Spinup ();
                if (rc !is XPCOM.NS_OK) {
                    browser.dispose ();
                    error (rc, __FILE__, __LINE__);
                }
            }
        }

        WindowCreator = new WindowCreator2;
        WindowCreator.AddRef ();
        
        nsIServiceManager serviceManager;
        rc = XPCOM.NS_GetServiceManager (&serviceManager);
        if (rc !is XPCOM.NS_OK) {
            browser.dispose ();
            error (rc, __FILE__, __LINE__);
        }
        if (serviceManager is null) {
            browser.dispose ();
            error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
        }
        
        nsIWindowWatcher windowWatcher;
        rc = serviceManager.GetServiceByContractID (XPCOM.NS_WINDOWWATCHER_CONTRACTID.ptr, &nsIWindowWatcher.IID, cast(void**)&windowWatcher);
        if (rc !is XPCOM.NS_OK) {
            browser.dispose ();
            error (rc, __FILE__, __LINE__);
        }
        if (windowWatcher is null) {
            browser.dispose ();
            error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);       
        }

        rc = windowWatcher.SetWindowCreator (cast(nsIWindowCreator)WindowCreator);
        if (rc !is XPCOM.NS_OK) {
            browser.dispose ();
            error (rc, __FILE__, __LINE__);
        }
        windowWatcher.Release ();

        if (LocationProvider !is null) {
            nsIDirectoryService directoryService;
            rc = serviceManager.GetServiceByContractID (XPCOM.NS_DIRECTORYSERVICE_CONTRACTID.ptr, &nsIDirectoryService.IID, cast(void**)&directoryService);
            if (rc !is XPCOM.NS_OK) {
                browser.dispose ();
                error (rc, __FILE__, __LINE__);
            }
            if (directoryService is null) {
                browser.dispose ();
                error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
            }

            nsIProperties properties;
            rc = directoryService.QueryInterface (&nsIProperties.IID, cast(void**)&properties);
            if (rc !is XPCOM.NS_OK) {
                browser.dispose ();
                error (rc, __FILE__, __LINE__);
            }
            if (properties is null) {
                browser.dispose ();
                error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
            }
            directoryService.Release ();

            nsIFile profileDir;
            rc = properties.Get (XPCOM.NS_APP_APPLICATION_REGISTRY_DIR.ptr, &nsIFile.IID, cast(void**)&profileDir);
            if (rc !is XPCOM.NS_OK) {
                browser.dispose ();
                error (rc, __FILE__, __LINE__);
            }
            if (profileDir is null) {
                browser.dispose ();
                error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
            }
            properties.Release ();

            scope auto path = new nsEmbedCString;
            rc = profileDir.GetNativePath (cast(nsACString*)path);
            if (rc !is XPCOM.NS_OK) {
                browser.dispose ();
                error (rc, __FILE__, __LINE__);
            }

            String profilePath = path.toString() ~ PROFILE_DIR;
            LocationProvider.setProfilePath (profilePath);
            LocationProvider.isXULRunner = IsXULRunner;

            profileDir.Release ();

            /* notify observers of a new profile directory being used */
            nsIObserverService observerService;
            rc = serviceManager.GetServiceByContractID (XPCOM.NS_OBSERVER_CONTRACTID.ptr, &nsIObserverService.IID, cast(void**)&observerService);
            if (rc !is XPCOM.NS_OK) {
                browser.dispose ();
                error (rc, __FILE__, __LINE__);
            }
            if (observerService is null) {
                browser.dispose ();
                error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
            }

            wchar* chars = STARTUP.toString16().toString16z();
            rc = observerService.NotifyObservers (null, PROFILE_DO_CHANGE.ptr, chars);
            if (rc !is XPCOM.NS_OK) {
                browser.dispose ();
                error (rc, __FILE__, __LINE__);
            }

            rc = observerService.NotifyObservers (null, PROFILE_AFTER_CHANGE.ptr, chars);
            if (rc !is XPCOM.NS_OK) {
                browser.dispose ();
                error (rc, __FILE__, __LINE__);
            }
            observerService.Release ();
        }

        /*
         * As a result of using a common profile the user cannot change their locale
         * and charset.  The fix for this is to set mozilla's locale and charset
         * preference values according to the user's current locale and charset.
         */

        nsIPrefService prefService;
        rc = serviceManager.GetServiceByContractID (XPCOM.NS_PREFSERVICE_CONTRACTID.ptr, &nsIPrefService.IID, cast(void**)&prefService);
        if (rc !is XPCOM.NS_OK) {
            browser.dispose ();
            error (rc, __FILE__, __LINE__);
        }
        if (serviceManager is null) {
            browser.dispose ();
            error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
        }

        char[1] buffer = new char[1];
        nsIPrefBranch prefBranch;
        rc = prefService.GetBranch (buffer.ptr, &prefBranch);    /* empty buffer denotes root preference level */
        prefService.Release ();
        if (rc !is XPCOM.NS_OK) {
            browser.dispose ();
            error (rc, __FILE__, __LINE__);
        }
        if (prefBranch is null) {
            browser.dispose ();
            error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
        }

        /* get Mozilla's current locale preference value */
        String prefLocales = null;
        nsIPrefLocalizedString localizedString = null;
        //buffer = MozillaDelegate.wcsToMbcs (null, PREFERENCE_LANGUAGES, true);
        rc = prefBranch.GetComplexValue (PREFERENCE_LANGUAGES.ptr, &nsIPrefLocalizedString.IID, cast(void**)&localizedString);
        /* 
         * Feature of Debian.  For some reason attempting to query for the current locale
         * preference fails on Debian.  The workaround for this is to assume a value of
         * "en-us,en" since this is typically the default value when mozilla is used without
         * a profile.
         */
        if (rc !is XPCOM.NS_OK) {
            prefLocales = "en-us,en" ~ TOKENIZER_LOCALE;    //$NON-NLS-1$
        } else {
            if (localizedString is null) {
                browser.dispose ();
                error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
            }
            PRUnichar* tmpChars;
            rc = localizedString.ToString (&tmpChars);
            if (rc !is XPCOM.NS_OK) {
                browser.dispose ();
                error (rc, __FILE__, __LINE__);
            }
            if (tmpChars is null) {
                browser.dispose ();
                error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
            }
            int span = XPCOM.strlen_PRUnichar (tmpChars);
            prefLocales = Utf.toString(tmpChars[0 .. span]) ~ TOKENIZER_LOCALE;
        }

        /*
         * construct the new locale preference value by prepending the
         * user's current locale and language to the original value 
         */

        String language = Culture.current.twoLetterLanguageName ();
        String country = Region.current.twoLetterRegionName ();
        String stringBuffer = language.dup;

        stringBuffer ~= SEPARATOR_LOCALE;
        stringBuffer ~= country.toLowerCase ();
        stringBuffer ~= TOKENIZER_LOCALE;
        stringBuffer ~= language;
        stringBuffer ~= TOKENIZER_LOCALE;
        String newLocales = stringBuffer.dup;

        int start, end = -1;
        do {
            start = end + 1;
            end = prefLocales.indexOf (TOKENIZER_LOCALE, start);
            String token;
            if (end is -1) {
                token = prefLocales.substring (start);
            } else {
                token = prefLocales.substring (start, end);
            }
            if (token.length () > 0) {
                token = (token ~ TOKENIZER_LOCALE).trim ();
                /* ensure that duplicate locale values are not added */
                if (newLocales.indexOf (token) is -1) {
                    stringBuffer ~= token;
                }
            }
        } while (end !is -1);
        newLocales[] = stringBuffer[];
        if (!newLocales.equals (prefLocales)) {
            /* write the new locale value */
            newLocales = newLocales.substring (0, newLocales.length () - TOKENIZER_LOCALE.length ()); /* remove trailing tokenizer */
            if (localizedString is null) {
                rc = componentManager.CreateInstanceByContractID (XPCOM.NS_PREFLOCALIZEDSTRING_CONTRACTID.ptr, null, &nsIPrefLocalizedString.IID, cast(void**)&localizedString);
                if (rc !is XPCOM.NS_OK) {
                    browser.dispose ();
                    error (rc, __FILE__, __LINE__);
                }
                if (localizedString is null) {
                    browser.dispose ();
                    error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
                }
            }
            localizedString.SetDataWithLength (newLocales.length, newLocales.toString16().toString16z());
            rc = prefBranch.SetComplexValue (PREFERENCE_LANGUAGES.ptr, &nsIPrefLocalizedString.IID, cast(nsISupports)localizedString);
        }
        if (localizedString !is null) {
            localizedString.Release ();
            localizedString = null;
        }

        /* get Mozilla's current charset preference value */
        String prefCharset = null;
        rc = prefBranch.GetComplexValue (PREFERENCE_CHARSET.ptr, &nsIPrefLocalizedString.IID, cast(void**)&localizedString);
        /* 
         * Feature of Debian.  For some reason attempting to query for the current charset
         * preference fails on Debian.  The workaround for this is to assume a value of
         * "ISO-8859-1" since this is typically the default value when mozilla is used
         * without a profile.
         */
        if (rc !is XPCOM.NS_OK) {
            prefCharset = "ISO-8859-1"; //$NON_NLS-1$
        } else {
            if (localizedString is null) {
                browser.dispose ();
                error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
            }
            PRUnichar* tmpChar;
            rc = localizedString.ToString (&tmpChar);
            if (rc !is XPCOM.NS_OK) {
                browser.dispose ();
                error (rc, __FILE__, __LINE__);
            }
            if (tmpChar is null) {
                browser.dispose ();
                error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
            }
            int span = XPCOM.strlen_PRUnichar (tmpChar);
            prefCharset = Utf.toString(tmpChar[0 .. span]);
        }

        String newCharset = System.getProperty ("file.encoding");   // $NON-NLS-1$
        if (!newCharset.equals (prefCharset)) {
            /* write the new charset value */
            if (localizedString is null) {
                rc = componentManager.CreateInstanceByContractID (XPCOM.NS_PREFLOCALIZEDSTRING_CONTRACTID.ptr, null, &nsIPrefLocalizedString.IID, cast(void**)&localizedString);
                if (rc !is XPCOM.NS_OK) {
                    browser.dispose ();
                    error (rc, __FILE__, __LINE__);
                }
                if (localizedString is null) {
                    browser.dispose ();
                    error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
                }
            }
            localizedString.SetDataWithLength (newCharset.length, newCharset.toString16().toString16z());
            rc = prefBranch.SetComplexValue (PREFERENCE_CHARSET.ptr, &nsIPrefLocalizedString.IID, cast(nsISupports)localizedString);
        }
        if (localizedString !is null) localizedString.Release ();

        /*
        * Check for proxy values set as documented java properties and update mozilla's
        * preferences with these values if needed.
        */

        // NOTE: in dwt, these properties don't exist so both keys will return null
        // (which appears to be ok in this situaion)
        String proxyHost = System.getProperty (PROPERTY_PROXYHOST);
        String proxyPortString = System.getProperty (PROPERTY_PROXYPORT);

        int port = -1;
        if (proxyPortString !is null) {
            try {
                int value = Integer.valueOf (proxyPortString).intValue ();
                if (0 <= value && value <= MAX_PORT) port = value;
            } catch (NumberFormatException e) {
                /* do nothing, java property has non-integer value */
            }
        }

        if (proxyHost !is null) {
            rc = componentManager.CreateInstanceByContractID (XPCOM.NS_PREFLOCALIZEDSTRING_CONTRACTID.ptr, null, &nsIPrefLocalizedString.IID, cast(void**)&localizedString);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            if (localizedString is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);

            rc = localizedString.SetDataWithLength (proxyHost.length, proxyHost.toString16().toString16z());
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            rc = prefBranch.SetComplexValue (PREFERENCE_PROXYHOST_FTP.ptr, &nsIPrefLocalizedString.IID, cast(nsISupports)localizedString);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            rc = prefBranch.SetComplexValue (PREFERENCE_PROXYHOST_HTTP.ptr, &nsIPrefLocalizedString.IID, cast(nsISupports)localizedString);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            rc = prefBranch.SetComplexValue (PREFERENCE_PROXYHOST_SSL.ptr, &nsIPrefLocalizedString.IID, cast(nsISupports)localizedString);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            localizedString.Release ();
        }

        if (port !is -1) {
            rc = prefBranch.SetIntPref (PREFERENCE_PROXYPORT_FTP.ptr, port);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            rc = prefBranch.SetIntPref (PREFERENCE_PROXYPORT_HTTP.ptr, port);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            rc = prefBranch.SetIntPref (PREFERENCE_PROXYPORT_SSL.ptr, port);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        }

        if (proxyHost !is null || port !is -1) {
            rc = prefBranch.SetIntPref (PREFERENCE_PROXYTYPE.ptr, 1);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        }

        /*
        * Ensure that windows that are shown during page loads are not blocked.  Firefox may
        * try to block these by default since such windows are often unwelcome, but this
        * assumption should not be made in the Browser's context.  Since the Browser client
        * is responsible for creating the new Browser and Shell in an OpenWindowListener,
        * they should decide whether the new window is unwelcome or not and act accordingly. 
        */
        rc = prefBranch.SetBoolPref (PREFERENCE_DISABLEOPENDURINGLOAD.ptr, 0);
        if (rc !is XPCOM.NS_OK) {
            browser.dispose ();
            error (rc, __FILE__, __LINE__);
        }

        /* Ensure that the status text can be set through means like javascript */ 
        rc = prefBranch.SetBoolPref (PREFERENCE_DISABLEWINDOWSTATUSCHANGE.ptr, 0);
        if (rc !is XPCOM.NS_OK) {
            browser.dispose ();
            error (rc, __FILE__, __LINE__);
        }

        prefBranch.Release ();

        PromptService2Factory factory = new PromptService2Factory ();
        factory.AddRef ();

        nsIComponentRegistrar componentRegistrar;
        rc = componentManager.QueryInterface (&nsIComponentRegistrar.IID, cast(void**)&componentRegistrar);
        if (rc !is XPCOM.NS_OK) {
            browser.dispose ();
            error (rc, __FILE__, __LINE__);
        }
        if (componentRegistrar is null) {
            browser.dispose ();
            error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
        }
        
        String aClassName = "Prompt Service"; 
        componentRegistrar.AutoRegister (0);     /* detect the External component */ 

        rc = componentRegistrar.RegisterFactory (&XPCOM.NS_PROMPTSERVICE_CID, aClassName.ptr, XPCOM.NS_PROMPTSERVICE_CONTRACTID.ptr, cast(nsIFactory)factory);

        if (rc !is XPCOM.NS_OK) {
            browser.dispose ();
            error (rc, __FILE__, __LINE__);
        }
        factory.Release ();

        ExternalFactory externalFactory = new ExternalFactory ();
        externalFactory.AddRef ();
        aContractID = MozillaDelegate.wcsToMbcs (null, XPCOM.EXTERNAL_CONTRACTID, true); 
        aClassName = MozillaDelegate.wcsToMbcs (null, "External", true); //$NON-NLS-1$
        rc = componentRegistrar.RegisterFactory (XPCOM.EXTERNAL_CID, aClassName, aContractID, externalFactory.getAddress ());
        if (rc !is XPCOM.NS_OK) {
            browser.dispose ();
            error (rc);
        }
        externalFactory.Release ();

        rc = serviceManager.GetService (XPCOM.NS_CATEGORYMANAGER_CID, nsICategoryManager.NS_ICATEGORYMANAGER_IID, result);
        if (rc !is XPCOM.NS_OK) error (rc);
        if (result[0] is 0) error (XPCOM.NS_NOINTERFACE);
        serviceManager.Release ();

        nsICategoryManager categoryManager = new nsICategoryManager (result[0]);
        result[0] = 0;
        byte[] category = MozillaDelegate.wcsToMbcs (null, "JavaScript global property", true); //$NON-NLS-1$
        byte[] entry = MozillaDelegate.wcsToMbcs (null, "external", true); //$NON-NLS-1$
        rc = categoryManager.AddCategoryEntry(category, entry, aContractID, 1, 1, result);
        result[0] = 0;
        categoryManager.Release ();

        /*
        * This Download factory will be used if the GRE version is < 1.8.
        * If the GRE version is 1.8.x then the Download factory that is registered later for
        *   contract "Transfer" will be used.
        * If the GRE version is >= 1.9 then no Download factory is registered because this
        *   functionality is provided by the GRE.
        */
        DownloadFactory downloadFactory = new DownloadFactory ();
        downloadFactory.AddRef ();
        aClassName = "Download";
        rc = componentRegistrar.RegisterFactory (&XPCOM.NS_DOWNLOAD_CID, aClassName.ptr, XPCOM.NS_DOWNLOAD_CONTRACTID.ptr, cast(nsIFactory)downloadFactory);
        if (rc !is XPCOM.NS_OK) {
            browser.dispose ();
            error (rc, __FILE__, __LINE__);
        }
        downloadFactory.Release ();

        FilePickerFactory pickerFactory = IsXULRunner ? new FilePickerFactory_1_8 () : new FilePickerFactory ();
        pickerFactory.AddRef ();
        aClassName = "FilePicker";
        rc = componentRegistrar.RegisterFactory (&XPCOM.NS_FILEPICKER_CID, aClassName.ptr, XPCOM.NS_FILEPICKER_CONTRACTID.ptr, cast(nsIFactory)pickerFactory);
        if (rc !is XPCOM.NS_OK) {
            browser.dispose ();
            error (rc, __FILE__, __LINE__);
        }
        pickerFactory.Release ();

        componentRegistrar.Release ();
        componentManager.Release ();

        Initialized = true;
    }

    if (display.getData (DISPOSE_LISTENER_HOOKED) is null) {
        display.setData (DISPOSE_LISTENER_HOOKED, stringcast(DISPOSE_LISTENER_HOOKED));
        display.addListener (DWT.Dispose, dgListener( &handleDisposeEvent, display )  );

                    // the following is intentionally commented, because calling XRE_TermEmbedding
                    // causes subsequent browser instantiations within the process to fail

//                  int size = XPCOM.nsDynamicFunctionLoad_sizeof ();
//                  /* alloc memory for two structs, the second is empty to signify the end of the list */
//                  int /*long*/ ptr = C.malloc (size * 2);
//                  C.memset (ptr, 0, size * 2);
//                  nsDynamicFunctionLoad functionLoad = new nsDynamicFunctionLoad ();
//                  byte[] bytes = MozillaDelegate.wcsToMbcs (null, "XRE_TermEmbedding", true); //$NON-NLS-1$
//                  functionLoad.functionName = C.malloc (bytes.length);
//                  C.memmove (functionLoad.functionName, bytes, bytes.length);
//                  functionLoad.function = C.malloc (C.PTR_SIZEOF);
//                  C.memmove (functionLoad.function, new int /*long*/[] {0} , C.PTR_SIZEOF);
//                  XPCOM.memmove (ptr, functionLoad, XPCOM.nsDynamicFunctionLoad_sizeof ());
//                  XPCOM.XPCOMGlueLoadXULFunctions (ptr);
//                  C.memmove (result, functionLoad.function, C.PTR_SIZEOF);
//                  int /*long*/ functionPtr = result[0];
//                  result[0] = 0;
//                  C.free (functionLoad.function);
//                  C.free (functionLoad.functionName);
//                  C.free (ptr);
//                  XPCOM.Call (functionPtr);

    }

    BrowserCount++;
    nsIComponentManager componentManager;
    int rc = XPCOM.NS_GetComponentManager (&componentManager);
    if (rc !is XPCOM.NS_OK) {
        browser.dispose ();
        error (rc, __FILE__, __LINE__);
    }
    if (componentManager is null) {
        browser.dispose ();
        error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
    }
    
    nsID NS_IWEBBROWSER_CID = { 0xF1EAC761, 0x87E9, 0x11d3, [0xAF, 0x80, 0x00, 0xA0, 0x24, 0xFF, 0xC0, 0x8C] }; //$NON-NLS-1$
    rc = componentManager.CreateInstance (&NS_IWEBBROWSER_CID, null, &nsIWebBrowser.IID, cast(void**)&webBrowser);
    if (rc !is XPCOM.NS_OK) {
        browser.dispose ();
        error (rc, __FILE__, __LINE__);
    }
    if (webBrowser is null) {
        browser.dispose ();
        error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);   
    }
    
    this.AddRef ();

    rc = webBrowser.SetContainerWindow ( cast(nsIWebBrowserChrome)this );
    if (rc !is XPCOM.NS_OK) {
        browser.dispose ();
        error (rc, __FILE__, __LINE__);
    }
            
    nsIBaseWindow baseWindow;
    rc = webBrowser.QueryInterface (&nsIBaseWindow.IID, cast(void**)&baseWindow);
    if (rc !is XPCOM.NS_OK) {
        browser.dispose ();
        error (rc, __FILE__, __LINE__);
    }
    if (baseWindow is null) {
        browser.dispose ();
        error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
    }
    
    Rectangle rect = browser.getClientArea ();
    if (rect.isEmpty ()) {
        rect.width = 1;
        rect.height = 1;
    }

    embedHandle = mozDelegate.getHandle ();

    rc = baseWindow.InitWindow (cast(void*)embedHandle, null, 0, 0, rect.width, rect.height);
    if (rc !is XPCOM.NS_OK) {
        browser.dispose ();
        error (XPCOM.NS_ERROR_FAILURE);
    }
    rc = delegate.createBaseWindow (baseWindow);
    if (rc !is XPCOM.NS_OK) {
        browser.dispose ();
        error (XPCOM.NS_ERROR_FAILURE);
    }
    rc = baseWindow.SetVisibility (1);
    if (rc !is XPCOM.NS_OK) {
        browser.dispose ();
        error (XPCOM.NS_ERROR_FAILURE);
    }
    baseWindow.Release ();

    if (!PerformedVersionCheck) {
        PerformedVersionCheck = true;
        
        nsIComponentRegistrar componentRegistrar;
        rc = componentManager.QueryInterface (&nsIComponentRegistrar.IID, cast(void**)&componentRegistrar);
        if (rc !is XPCOM.NS_OK) {
            browser.dispose ();
            error (rc, __FILE__,__LINE__);
        }
        if (componentRegistrar is null) {
            browser.dispose ();
            error (XPCOM.NS_NOINTERFACE,__FILE__,__LINE__);
        }

        HelperAppLauncherDialogFactory dialogFactory = new HelperAppLauncherDialogFactory ();
        dialogFactory.AddRef ();
        String aClassName = "Helper App Launcher Dialog"; //$NON-NLS-1$
        rc = componentRegistrar.RegisterFactory (&XPCOM.NS_HELPERAPPLAUNCHERDIALOG_CID, aClassName.ptr, XPCOM.NS_HELPERAPPLAUNCHERDIALOG_CONTRACTID.ptr, cast(nsIFactory)dialogFactory);
        if (rc !is XPCOM.NS_OK) {
            browser.dispose ();
            error (rc,__FILE__,__LINE__);
        }
        dialogFactory.Release ();

        /*
        * Check for the availability of the pre-1.8 implementation of nsIDocShell
        * to determine if the GRE's version is < 1.8.
        */
        nsIInterfaceRequestor interfaceRequestor;
        rc = webBrowser.QueryInterface (&nsIInterfaceRequestor.IID, cast(void**)&interfaceRequestor);
        if (rc !is XPCOM.NS_OK) {
            browser.dispose ();
            error (XPCOM.NS_ERROR_FAILURE);
        }
        if (interfaceRequestor is null) {
            browser.dispose ();
            error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
        }

        nsIDocShell docShell;
        rc = interfaceRequestor.GetInterface (&nsIDocShell.IID, cast(void**)&docShell);
        if (rc is XPCOM.NS_OK && docShell !is null) {
            IsPre_1_8 = true;
            docShell.Release ();
        }
        IsPre_1_9 = true;

        /*
        * A Download factory for contract "Transfer" must be registered iff the GRE's version is 1.8.x.
        *   Check for the availability of the 1.8 implementation of nsIDocShell to determine if the
        *   GRE's version is 1.8.x.
        * If the GRE version is < 1.8 then the previously-registered Download factory for contract
        *   "Download" will be used.
        * If the GRE version is >= 1.9 then no Download factory is registered because this
        *   functionality is provided by the GRE.
        */
        if (!IsPre_1_8) {
            nsIDocShell_1_8 docShell_1_8;
            rc = interfaceRequestor.GetInterface (&nsIDocShell_1_8.IID, cast(void**)&docShell_1_8);
            if (rc is XPCOM.NS_OK && docShell_1_8 !is null) { /* 1.8 */
                docShell_1_8.Release ();
 
                DownloadFactory_1_8 downloadFactory_1_8 = new DownloadFactory_1_8 ();
                downloadFactory_1_8.AddRef ();
                
                aClassName = "Transfer"; //$NON-NLS-1$
                rc = componentRegistrar.RegisterFactory (&XPCOM.NS_DOWNLOAD_CID, aClassName.ptr, XPCOM.NS_TRANSFER_CONTRACTID.ptr, cast(nsIFactory)downloadFactory_1_8);
                if (rc !is XPCOM.NS_OK) {
                    browser.dispose ();
                    error (rc, __FILE__, __LINE__);
                }
                downloadFactory_1_8.Release ();
                } else { /* >= 1.9 */
                IsPre_1_9 = false;
                rc = webBrowser.QueryInterface (&nsIWebNavigation.IID, cast(void**)&webNavigation);
            }
        }
        interfaceRequestor.Release ();
        componentRegistrar.Release ();
    }
    componentManager.Release ();

    /*
     * Bug in XULRunner 1.9.  On win32, Mozilla does not clear its background before content has
     * been set into it.  As a result, embedders appear broken if they do not immediately display
     * a URL or text.  The Mozilla bug for this is https://bugzilla.mozilla.org/show_bug.cgi?id=453523.
     * 
     * The workaround is to subclass the Mozilla window and clear it whenever WM_ERASEBKGND is received.
     * This subclass should be removed once content has been set into the browser.
     */
    if (!IsPre_1_9) {
        delegate.addWindowSubclass ();
    }

    if (rc !is XPCOM.NS_OK) {
        browser.dispose ();
        error (rc, __FILE__, __LINE__);
    }

    // TODO: Find appropriate place to "Release" uriContentListener -JJR
    nsIURIContentListener uriContentListener;
    this.QueryInterface(&nsIURIContentListener.IID, cast(void**)&uriContentListener);
    if (rc !is XPCOM.NS_OK) {
        browser.dispose();
        error(rc);
    }
    if (uriContentListener is null) {
        browser.dispose();
        error(XPCOM.NS_ERROR_NO_INTERFACE);
    }

    rc = webBrowser.SetParentURIContentListener (uriContentListener);
    if (rc !is XPCOM.NS_OK) {
        browser.dispose ();
        error (rc, __FILE__, __LINE__);
    }

    mozDelegate.init ();
        
    int[] folderEvents = [
        DWT.Dispose,
        DWT.Resize,  
        DWT.FocusIn,
        DWT.Activate,
        DWT.Deactivate,
        DWT.Show,
        DWT.KeyDown     // needed to make browser traversable
    ];
    
    for (int i = 0; i < folderEvents.length; i++) {
        browser.addListener (folderEvents[i], dgListener( &handleFolderEvent ));
    }
}

/*******************************************************************************

    Event Handlers for the Mozilla Class:
    
    These represent replacements for SWT's anonymous classes as used within
    the Mozilla class.  Since D 1.0x anonymous classes do not work equivalently 
    to Java's, we replace the anonymous classes with D delegates and templates
    (ie dgListener which wrap the delegate in a class).  This circumvents some
    nasty, evasive bugs.
    
    extern(D) becomes a necessary override on these methods because this class 
    implements a XPCOM/COM interface resulting in all class methods defaulting
    to extern(System). -JJR

 ******************************************************************************/

extern(D)
private void handleDisposeEvent (Event event, Display display) {
    if (BrowserCount > 0) return; /* another display is still active */

    nsIServiceManager serviceManager;

    int rc = XPCOM.NS_GetServiceManager (&serviceManager);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (serviceManager is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);

    nsIObserverService observerService;
    rc = serviceManager.GetServiceByContractID (XPCOM.NS_OBSERVER_CONTRACTID.ptr, &nsIObserverService.IID, cast(void**)&observerService);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (observerService is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);

    rc = observerService.NotifyObservers (null, PROFILE_BEFORE_CHANGE.ptr, SHUTDOWN_PERSIST.toString16().toString16z());
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    observerService.Release ();

    if (LocationProvider !is null) {
        String prefsLocation = LocationProvider.profilePath ~ AppFileLocProvider.PREFERENCES_FILE;
        scope auto pathString = new nsEmbedString (prefsLocation.toString16());
        nsILocalFile localFile;
        rc = XPCOM.NS_NewLocalFile (cast(nsAString*)pathString, 1, &localFile);
        if (rc !is XPCOM.NS_OK) Mozilla.error (rc, __FILE__, __LINE__);
        if (localFile is null) Mozilla.error (XPCOM.NS_ERROR_NULL_POINTER);

        nsIFile prefFile;
        rc = localFile.QueryInterface (&nsIFile.IID, cast(void**)&prefFile); 
        if (rc !is XPCOM.NS_OK) Mozilla.error (rc, __FILE__, __LINE__);
        if (prefFile is null) Mozilla.error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
        localFile.Release ();

        nsIPrefService prefService;
        rc = serviceManager.GetServiceByContractID (XPCOM.NS_PREFSERVICE_CONTRACTID.ptr, &nsIPrefService.IID, cast(void**)&prefService);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        if (prefService is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);

        rc = prefService.SavePrefFile(prefFile);
        prefService.Release ();
        prefFile.Release ();
    }
    serviceManager.Release ();

    if (XPCOMWasGlued) {
        /*
         * XULRunner 1.9 can crash on Windows if XPCOMGlueShutdown is invoked here,
         * presumably because one or more of its unloaded symbols are referenced when
         * this callback returns.  The workaround is to delay invoking XPCOMGlueShutdown
         * so that its symbols are still available once this callback returns.
         */
         display.asyncExec (new class() Runnable {
             public void run () {
                 XPCOMInit.XPCOMGlueShutdown ();
             }
         });
         XPCOMWasGlued = XPCOMInitWasGlued = false;
    } 

    Initialized = false;
}
  
        
extern(D)
private void handleFolderEvent (Event event) {
            Control control = cast(Control)browser;
            switch (event.type) {
                case DWT.Dispose: {
                    /* make this handler run after other dispose listeners */
                    if (ignoreDispose) {
                        ignoreDispose = false;
                        break;
                    }
                    ignoreDispose = true;
                    browser.notifyListeners (event.type, event);
                    event.type = DWT.NONE;
                    onDispose (event.display);
                    break;
                }
                case DWT.Resize: onResize (); break;
                case DWT.FocusIn: Activate (); break;
                case DWT.Activate: Activate (); break;
                case DWT.Deactivate: {
                    Display display = event.display;
                    if (control is display.getFocusControl ()) Deactivate ();
                    break;
                }
                case DWT.Show: {
                    /*
                    * Feature in GTK Mozilla.  Mozilla does not show up when
                    * its container (a GTK fixed handle) is made visible
                    * after having been hidden.  The workaround is to reset
                    * its size after the container has been made visible. 
                    */
                    Display display = event.display;
                    display.asyncExec(new class () Runnable {
                        public void run() {
                            if (browser.isDisposed ()) return;
                            onResize ();
                        }
                    });
                    break;
                }
                default: break;
            }
        }

/*******************************************************************************

*******************************************************************************/
    
extern(D)
public bool back () {
    htmlBytes = null;

    //int /*long*/[] result = new int /*long*/[1];
    nsIWebNavigation webNavigation;
    int rc = webBrowser.QueryInterface (&nsIWebNavigation.IID, cast(void**)&webNavigation);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (webNavigation is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
    
    //nsIWebNavigation webNavigation = new nsIWebNavigation (result[0]);          
    rc = webNavigation.GoBack ();   
    webNavigation.Release ();
    return rc is XPCOM.NS_OK;
}

extern(D)
void deregisterFunction (BrowserFunction function) {
    super.deregisterFunction (function);
    AllFunctions.remove (new Integer (function.index));
}

public bool execute (String script) {
    /*
    * This could be the first content that is set into the browser, so
    * ensure that the custom subclass that works around Mozilla bug
    * https://bugzilla.mozilla.org/show_bug.cgi?id=453523 is removed.
    */
    delegate.removeWindowSubclass ();

    /*
    * As of mozilla 1.9 executing javascript via the javascript: protocol no
    * longer happens synchronously.  As a result, the result of executing JS
    * is not returned to the java side when expected by the client.  The
    * workaround is to invoke the javascript handler directly via C++, which is
    * exposed as of mozilla 1.9.
    */
    int /*long*/[] result = new int /*long*/[1];
    if (!IsPre_1_9) {
        int rc = XPCOM.NS_GetServiceManager (result);
        if (rc !is XPCOM.NS_OK) error (rc);
        if (result[0] is 0) error (XPCOM.NS_NOINTERFACE);

        nsIServiceManager serviceManager = new nsIServiceManager (result[0]);
        result[0] = 0;
        nsIPrincipal principal = null;
        byte[] aContractID = MozillaDelegate.wcsToMbcs (null, XPCOM.NS_SCRIPTSECURITYMANAGER_CONTRACTID, true);
        rc = serviceManager.GetServiceByContractID (aContractID, nsIScriptSecurityManager_1_9_1.NS_ISCRIPTSECURITYMANAGER_IID, result);
        if (rc is XPCOM.NS_OK && result[0] !is 0) {
            nsIScriptSecurityManager_1_9_1 securityManager = new nsIScriptSecurityManager_1_9_1 (result[0]);
            result[0] = 0;
            rc = securityManager.GetSystemPrincipal (result);
            if (rc !is XPCOM.NS_OK) error (rc);
            if (result[0] is 0) error (XPCOM.NS_ERROR_NULL_POINTER);
            principal = new nsIPrincipal (result[0]);
            result[0] = 0;
            securityManager.Release ();
        } else {
            rc = serviceManager.GetServiceByContractID (aContractID, nsIScriptSecurityManager_1_9.NS_ISCRIPTSECURITYMANAGER_IID, result);
            if (rc is XPCOM.NS_OK && result[0] !is 0) {
                nsIScriptSecurityManager_1_9 securityManager = new nsIScriptSecurityManager_1_9 (result[0]);
                result[0] = 0;
                rc = securityManager.GetSystemPrincipal (result);
                if (rc !is XPCOM.NS_OK) error (rc);
                if (result[0] is 0) error (XPCOM.NS_ERROR_NULL_POINTER);
                principal = new nsIPrincipal (result[0]);
                result[0] = 0;
                securityManager.Release ();
            }
        }
        serviceManager.Release ();

        if (principal !is null) {
            rc = webBrowser.QueryInterface (nsIInterfaceRequestor.NS_IINTERFACEREQUESTOR_IID, result);
            if (rc !is XPCOM.NS_OK) error (rc);
            if (result[0] is 0) error (XPCOM.NS_ERROR_NO_INTERFACE);

            nsIInterfaceRequestor interfaceRequestor = new nsIInterfaceRequestor (result[0]);
            result[0] = 0;
            nsID scriptGlobalObjectNSID = new nsID ("6afecd40-0b9a-4cfd-8c42-0f645cd91829"); /* nsIScriptGlobalObject */ //$NON-NLS-1$
            rc = interfaceRequestor.GetInterface (scriptGlobalObjectNSID, result);
            interfaceRequestor.Release ();

            if (rc is XPCOM.NS_OK && result[0] !is 0) {
                int /*long*/ scriptGlobalObject = result[0];
                result[0] = 0;
                rc = (int/*64*/)XPCOM.nsIScriptGlobalObject_EnsureScriptEnvironment (scriptGlobalObject, 2); /* nsIProgrammingLanguage.JAVASCRIPT */
                if (rc !is XPCOM.NS_OK) error (rc);
                int /*long*/ scriptContext = XPCOM.nsIScriptGlobalObject_GetScriptContext (scriptGlobalObject, 2); /* nsIProgrammingLanguage.JAVASCRIPT */
                int /*long*/ globalJSObject = XPCOM.nsIScriptGlobalObject_GetScriptGlobal (scriptGlobalObject, 2); /* nsIProgrammingLanguage.JAVASCRIPT */
                new nsISupports (scriptGlobalObject).Release ();

                if (scriptContext !is 0 && globalJSObject !is 0) {
                    /* ensure that the received nsIScriptContext implements the expected interface */
                    nsID scriptContextNSID = new nsID ("e7b9871d-3adc-4bf7-850d-7fb9554886bf"); /* nsIScriptContext */ //$NON-NLS-1$                    
                    rc = new nsISupports (scriptContext).QueryInterface (scriptContextNSID, result);
                    if (rc is XPCOM.NS_OK && result[0] !is 0) {
                        new nsISupports (result[0]).Release ();
                        result[0] = 0;

                        int /*long*/ nativeContext = XPCOM.nsIScriptContext_GetNativeContext (scriptContext);
                        if (nativeContext !is 0) {
                            int length = script.length ();
                            char[] scriptChars = new char[length];
                            script.getChars(0, length, scriptChars, 0);
                            byte[] urlbytes = MozillaDelegate.wcsToMbcs (null, getUrl (), true);
                            rc = principal.GetJSPrincipals (nativeContext, result);
                            if (rc is XPCOM.NS_OK && result[0] !is 0) {
                                int /*long*/ principals = result[0];
                                result[0] = 0;
                                principal.Release ();
                                String mozillaPath = LocationProvider.mozillaPath + delegate.getJSLibraryName () + '\0';
                                byte[] pathBytes = null;
                                try {
                                    pathBytes = mozillaPath.getBytes ("UTF-8"); //$NON-NLS-1$
                                } catch (UnsupportedEncodingException e) {
                                    pathBytes = mozillaPath.getBytes ();
                                }
                                rc = XPCOM.JS_EvaluateUCScriptForPrincipals (pathBytes, nativeContext, globalJSObject, principals, scriptChars, length, urlbytes, 0, result);
                                return rc !is 0;
                            }
                        }
                    }
                }
            }
            principal.Release ();
        }
    }

    /* fall back to the pre-1.9 approach */

    String url = PREFIX_JAVASCRIPT + script + ";void(0);";  //$NON-NLS-1$

    //nsIWebNavigation webNavigation = new nsIWebNavigation (result[0]);
    //char[] arg = url.toCharArray (); 
    //char[] c = new char[arg.length+1];
    //System.arraycopy (arg, 0, c, 0, arg.length);
    rc = webNavigation.LoadURI (url.toString16().toString16z(), nsIWebNavigation.LOAD_FLAGS_NONE, null, null, null);
    webNavigation.Release ();
    return rc is XPCOM.NS_OK;
}

extern(D)
static Browser findBrowser (void* handle) {
    version (linux) return MozillaDelegate.findBrowser (cast(GtkWidget*)handle);
    version (darwin) return MozillaDelegate.findBrowser (cast(objc.id)handle);
    if (result[0] is 0) return null;    /* the parent chrome is disconnected */
}

extern(D)
public bool forward () {
    htmlBytes = null;

    //int /*long*/[] result = new int /*long*/[1];
    nsIWebNavigation webNavigation;
    int rc = webBrowser.QueryInterface (&nsIWebNavigation.IID, cast(void**)&webNavigation);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (webNavigation is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
    
    //nsIWebNavigation webNavigation = new nsIWebNavigation (result[0]);
    rc = webNavigation.GoForward ();
    webNavigation.Release ();

    return rc is XPCOM.NS_OK;
}

extern(D)
int getNextFunctionIndex () {
    return NextJSFunctionIndex++;
}

public String getText () {
    //int /*long*/[] result = new int /*long*/[1];
    nsIDOMWindow window;
    int rc = webBrowser.GetContentDOMWindow (&window);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (window is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);

    //nsIDOMWindow window = new nsIDOMWindow (result[0]);
    //result[0] = 0;
    nsIDOMDocument document;
    rc = window.GetDocument (&document);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (document is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
    window.Release ();

    //int /*long*/ document = result[0];
    //result[0] = 0;
    nsIComponentManager componentManager;
    rc = XPCOM.NS_GetComponentManager (&componentManager);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (componentManager is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);

    //nsIComponentManager componentManager = new nsIComponentManager (result[0]);
    //result[0] = 0;
    //byte[] contractID = MozillaDelegate.wcsToMbcs (null, XPCOM.NS_DOMSERIALIZER_CONTRACTID, true);
    String chars = null;
    nsIDOMSerializer_1_7 serializer_1_7;
    rc = componentManager.CreateInstanceByContractID (XPCOM.NS_DOMSERIALIZER_CONTRACTID.ptr, null, &nsIDOMSerializer_1_7.IID, cast(void**)&serializer_1_7);
    if (rc is XPCOM.NS_OK) {    /* mozilla >= 1.7 */
        if (serializer_1_7 is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);

        //nsIDOMSerializer_1_7 serializer = new nsIDOMSerializer_1_7 (result[0]);
        //result[0] = 0;
        scope auto string = new nsEmbedString;
        rc = serializer_1_7.SerializeToString (cast(nsIDOMNode)document, cast(nsAString*) string);
        serializer_1_7.Release ();

        //int length = XPCOM.nsEmbedString_Length (string);
        //int /*long*/ buffer = XPCOM.nsEmbedString_get (string);
        //chars = new char[length];
        //XPCOM.memmove (chars, buffer, length * 2);
        //XPCOM.nsEmbedString_delete (string);
        chars = string.toString();
    } else {    /* mozilla < 1.7 */
        nsIDOMSerializer serializer;
        rc = componentManager.CreateInstanceByContractID (XPCOM.NS_DOMSERIALIZER_CONTRACTID.ptr, null, &nsIDOMSerializer.IID, cast(void**)&serializer);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        if (serializer is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
        // TODO: Lookup SerializeToString contract. Find out if the string must provide it's own memory to the method. -JJR
        PRUnichar* string;
        //nsIDOMSerializer serializer = new nsIDOMSerializer (result[0]);
        //result[0] = 0;
        rc = serializer.SerializeToString (cast(nsIDOMNode)document, &string );
        serializer.Release ();

        //int length = XPCOM.strlen_PRUnichar (string);
        //chars = new char[length];
        //XPCOM.memmove (chars, result[0], length * 2);
        chars = Utf.toString(fromString16z(string));
    }

    componentManager.Release ();
    document.Release ();
    return chars.dup;
}

extern(D)
public String getUrl () {
    //int /*long*/[] result = new int /*long*/[1];
    nsIWebNavigation webNavigation;
    int rc = webBrowser.QueryInterface (&nsIWebNavigation.IID, cast(void**)&webNavigation);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (webNavigation is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);

    //nsIWebNavigation webNavigation = new nsIWebNavigation (result[0]);
    nsIURI aCurrentURI;
    rc = webNavigation.GetCurrentURI (&aCurrentURI);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    webNavigation.Release ();

    String location = null;
    if (aCurrentURI !is null) {
        //nsIURI uri = new nsIURI (aCurrentURI[0]);
        scope auto aSpec = new nsEmbedCString;
        rc = aCurrentURI.GetSpec (cast(nsACString*)aSpec);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        //int length = XPCOM.nsEmbedCString_Length (aSpec);
        //int /*long*/ buffer = XPCOM.nsEmbedCString_get (aSpec);
        location = aSpec.toString;
        //XPCOM.memmove (dest, buffer, length);
        //XPCOM.nsEmbedCString_delete (aSpec);
        aCurrentURI.Release ();
    }
    if (location is null) return ""; //$NON-NLS-1$

    /*
     * If the URI indicates that the page is being rendered from memory
     * (via setText()) then set it to about:blank to be consistent with IE.
     */
    if (location.equals (URI_FROMMEMORY)) location = ABOUT_BLANK;
    return location;
}

extern(D)
public Object getWebBrowser () {
    if ((browser.getStyle () & DWT.MOZILLA) is 0) return null;
    if (webBrowserObject !is null) return webBrowserObject;
    implMissing(__FILE__,__LINE__);
/+
    try {
        // TODO: this references the JavaXPCOM browser... not sure what needs to be done here,
        // but I don't think this method is necessary.
        Class clazz = Class.forName ("org.mozilla.xpcom.Mozilla"); //$NON-NLS-1$
        Method method = clazz.getMethod ("getInstance", new Class[0]); //$NON-NLS-1$
        Object mozilla = method.invoke (null, new Object[0]);
        method = clazz.getMethod ("wrapXPCOMObject", new Class[] {Long.TYPE, String.class}); //$NON-NLS-1$
        webBrowserObject = webBrowser.getAddress ()), nsIWebBrowser.NS_IWEBBROWSER_IID_STR});
        /*
         * The following AddRef() is needed to offset the automatic Release() that
         * will be performed by JavaXPCOM when webBrowserObject is finalized.
         */
        webBrowser.AddRef ();
        return webBrowserObject;
   } catch (ClassNotFoundException e) {
   } catch (NoSuchMethodException e) {
   } catch (IllegalArgumentException e) {
   } catch (IllegalAccessException e) {
   } catch (InvocationTargetException e) {
   }
+/
   return null;
}

extern(D)
public bool isBackEnabled () {
    //int /*long*/[] result = new int /*long*/[1];
    nsIWebNavigation webNavigation;
    int rc = webBrowser.QueryInterface (&nsIWebNavigation.IID, cast(void**)&webNavigation);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (webNavigation is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
    
    //nsIWebNavigation webNavigation = new nsIWebNavigation (result[0]);
    PRBool aCanGoBack; /* PRBool */
    rc = webNavigation.GetCanGoBack (&aCanGoBack);   
    webNavigation.Release ();
    return aCanGoBack !is 0;
}

extern(D)
public bool isForwardEnabled () {
    //int /*long*/[] result = new int /*long*/[1];
    nsIWebNavigation webNavigation;
    int rc = webBrowser.QueryInterface (&nsIWebNavigation.IID, cast(void**)&webNavigation);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (webNavigation is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
    
    //nsIWebNavigation webNavigation = new nsIWebNavigation (result[0]);
    PRBool aCanGoForward; /* PRBool */
    rc = webNavigation.GetCanGoForward (&aCanGoForward);
    webNavigation.Release ();
    return aCanGoForward !is 0;
}

extern(D)
static void error (int code ) {
    error ( code, "NOT GIVEN", 0 );
}

extern(D)
static String error (int code, char[] file, int line) {
    Stdout ("File: ")(file)("  Line: ")(line).newline;
    throw new DWTError ("XPCOM error " ~ Integer.toString(code)); //$NON-NLS-1$
}

extern(D)
void onDispose (Display display) {
    int rc = webBrowser.RemoveWebBrowserListener (cast(nsIWeakReference)this, &nsIWebProgressListener.IID);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);

    rc = webBrowser.SetParentURIContentListener (null);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    
    rc = webBrowser.SetContainerWindow (0);
    if (rc !is XPCOM.NS_OK) error (rc);

    unhookDOMListeners ();
    if (listener !is null) {
        int[] folderEvents = [
            DWT.Dispose,
            DWT.Resize,  
            DWT.FocusIn,
            DWT.Activate,
            DWT.Deactivate,
            DWT.Show,
            DWT.KeyDown,
        ];
        for (int i = 0; i < folderEvents.length; i++) {
            browser.removeListener (folderEvents[i], listener);
        }
        listener = null;
    }

    //int /*long*/[] result = new int /*long*/[1];
    nsIBaseWindow baseWindow;
    rc = webBrowser.QueryInterface (&nsIBaseWindow.IID, cast(void**)&baseWindow);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (baseWindow is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);

    //nsIBaseWindow baseWindow = new nsIBaseWindow (result[0]);
    rc = baseWindow.Destroy ();
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    baseWindow.Release ();

    Release ();
    webBrowser.Release ();
    webBrowser = null;
    webBrowserObject = null;
    lastNavigateURL = null;
    htmlBytes = null;

    if (tip !is null && !tip.isDisposed ()) tip.dispose ();
    tip = null;
    location = size = null;

    //Enumeration elements = unhookedDOMWindows.elements ();
    foreach (win ; unhookedDOMWindows) {
        //LONG ptrObject = (LONG)elements.nextElement ();
        win.Release ();
    }
    unhookedDOMWindows = null;

    mozDelegate.onDispose (embedHandle);
    mozDelegate = null;
    elements = functions.elements ();
    while (elements.hasMoreElements ()) {
        BrowserFunction function = ((BrowserFunction)elements.nextElement ());
        AllFunctions.remove (new Integer (function.index));
        function.dispose (false);
    }
    functions = null;


    embedHandle = null;
    BrowserCount--;
}

extern(D)
void Activate () {
    //int /*long*/[] result = new int /*long*/[1];
    nsIWebBrowserFocus webBrowserFocus;
    int rc = webBrowser.QueryInterface (&nsIWebBrowserFocus.IID, cast(void**)&webBrowserFocus);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (webBrowserFocus is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
    
    //nsIWebBrowserFocus webBrowserFocus = new nsIWebBrowserFocus (result[0]);
    rc = webBrowserFocus.Activate ();
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    webBrowserFocus.Release ();
}

extern(D)
void Deactivate () {
    //int /*long*/[] result = new int /*long*/[1];
    nsIWebBrowserFocus webBrowserFocus;
    int rc = webBrowser.QueryInterface (&nsIWebBrowserFocus.IID, cast(void**)&webBrowserFocus);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (webBrowserFocus is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
    
    //nsIWebBrowserFocus webBrowserFocus = new nsIWebBrowserFocus (result[0]);
    rc = webBrowserFocus.Deactivate ();
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    webBrowserFocus.Release ();
}

extern(D)
void onResize () {
    Rectangle rect = browser.getClientArea ();
    int width = Math.max (1, rect.width);
    int height = Math.max (1, rect.height);

    //int /*long*/[] result = new int /*long*/[1];
    nsIBaseWindow baseWindow;
    int rc = webBrowser.QueryInterface (&nsIBaseWindow.IID, cast(void**)&baseWindow);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (baseWindow is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);

    mozDelegate.setSize (embedHandle, width, height);
    //nsIBaseWindow baseWindow = new nsIBaseWindow (result[0]);
    rc = baseWindow.SetPositionAndSize (0, 0, width, height, 1);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    baseWindow.Release ();
}

extern(D)
public void refresh () {
    htmlBytes = null;

    //int /*long*/[] result = new int /*long*/[1];
    nsIWebNavigation webNavigation;
    int rc = webBrowser.QueryInterface (&nsIWebNavigation.IID, cast(void**)&webNavigation);
    if (rc !is XPCOM.NS_OK) error(rc);
    if (webNavigation is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
    
    //nsIWebNavigation webNavigation = new nsIWebNavigation (result[0]);          
    rc = webNavigation.Reload (nsIWebNavigation.LOAD_FLAGS_NONE);
    webNavigation.Release ();
    if (rc is XPCOM.NS_OK) return;
    /*
    * Feature in Mozilla.  Reload returns an error code NS_ERROR_INVALID_POINTER
    * when it is called immediately after a request to load a new document using
    * LoadURI.  The workaround is to ignore this error code.
    *
    * Feature in Mozilla.  Attempting to reload a file that no longer exists
    * returns an error code of NS_ERROR_FILE_NOT_FOUND.  This is equivalent to
    * attempting to load a non-existent local url, which is not a Browser error,
    * so this error code should be ignored. 
    */
    if (rc !is XPCOM.NS_ERROR_INVALID_POINTER && rc !is XPCOM.NS_ERROR_FILE_NOT_FOUND) error (rc, __FILE__, __LINE__);
}

extern (D) void registerFunction (BrowserFunction function) {
    super.registerFunction (function);
    AllFunctions.put (new Integer (function.index), function);
}

extern (D) public bool setText (String html) {
    /*
    *  Feature in Mozilla.  The focus memory of Mozilla must be 
    *  properly managed through the nsIWebBrowserFocus interface.
    *  In particular, nsIWebBrowserFocus.deactivate must be called
    *  when the focus moves from the browser (or one of its children
    *  managed by Mozilla to another widget.  We currently do not
    *  get notified when a widget takes focus away from the Browser.
    *  As a result, deactivate is not properly called. This causes
    *  Mozilla to retake focus the next time a document is loaded.
    *  This breaks the case where the HTML loaded in the Browser 
    *  varies while the user enters characters in a text widget. The text
    *  widget loses focus every time new content is loaded.
    *  The current workaround is to call deactivate everytime if 
    *  the browser currently does not have focus. A better workaround
    *  would be to have a way to call deactivate when the Browser
    *  or one of its children loses focus.
    */
    if (browser !is browser.getDisplay().getFocusControl ()) {
        Deactivate ();
    }
    /* convert the String containing HTML to an array of bytes with UTF-8 data */
    /+
    byte[] data = null;
    try {
        data = html.getBytes ("UTF-8"); //$NON-NLS-1$
    } catch (UnsupportedEncodingException e) {
        return false;
    }
    +/
    /*
     * This could be the first content that is set into the browser, so
     * ensure that the custom subclass that works around Mozilla bug
     * https://bugzilla.mozilla.org/show_bug.cgi?id=453523 is removed.
     */
    delegate.removeWindowSubclass ();

    int /*long*/[] result = new int /*long*/[1];
    int rc = webBrowser.QueryInterface (nsIWebBrowserStream.NS_IWEBBROWSERSTREAM_IID, result);
    if (rc is XPCOM.NS_OK && result[0] !is 0) {
        /*
        * Setting mozilla's content through nsIWebBrowserStream does not cause a page
        * load to occur, so the events that usually accompany a page change are not
        * fired.  To make this behave as expected, navigate to about:blank first and
        * then set the html content once the page has loaded.
        */
        new nsISupports (result[0]).Release ();
        result[0] = 0;

        /*
        * If htmlBytes is not null then the about:blank page is already being loaded,
        * so no Navigate is required.  Just set the html that is to be shown.
        */
        bool blankLoading = htmlBytes !is null;
        htmlBytes = data;
        if (blankLoading) return true;

        /* navigate to about:blank */
        rc = webBrowser.QueryInterface (nsIWebNavigation.NS_IWEBNAVIGATION_IID, result);
        if (rc !is XPCOM.NS_OK) error (rc);
        if (result[0] is 0) error (XPCOM.NS_ERROR_NO_INTERFACE);
        nsIWebNavigation webNavigation = new nsIWebNavigation (result[0]);
        result[0] = 0;
        char[] uri = new char[ABOUT_BLANK.length () + 1];
        ABOUT_BLANK.getChars (0, ABOUT_BLANK.length (), uri, 0);
        rc = webNavigation.LoadURI (uri, nsIWebNavigation.LOAD_FLAGS_NONE, 0, 0, 0);
        if (rc !is XPCOM.NS_OK) error (rc);
        webNavigation.Release ();
    } else {
    //byte[] contentCharsetBuffer = MozillaDelegate.wcsToMbcs (null, "UTF-8", true);  //$NON-NLS-1$
    scope auto aContentCharset = new nsEmbedCString ("UTF-8");

        byte[] contentTypeBuffer = MozillaDelegate.wcsToMbcs (null, "text/html", true); // $NON-NLS-1$
        int /*long*/ aContentType = XPCOM.nsEmbedCString_new (contentTypeBuffer, contentTypeBuffer.length);

    nsIServiceManager serviceManager;
    rc = XPCOM.NS_GetServiceManager (&serviceManager);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (serviceManager is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);

    //nsIServiceManager serviceManager = new nsIServiceManager (result[0]);
    //result[0] = 0;
    nsIIOService ioService;
    rc = serviceManager.GetService (&XPCOM.NS_IOSERVICE_CID, &nsIIOService.IID, cast(void**)&ioService);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (ioService is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
        serviceManager.Release ();

    //nsIIOService ioService = new nsIIOService (result[0]);
    //result[0] = 0;
        /*
        * Note.  Mozilla ignores LINK tags used to load CSS stylesheets
        * when the URI protocol for the nsInputStreamChannel
        * is about:blank.  The fix is to specify the file protocol.
        */
    //byte[] aString = MozillaDelegate.wcsToMbcs (null, URI_FROMMEMORY, false);
    scope auto aSpec = new nsEmbedCString(URI_FROMMEMORY);
    nsIURI uri;
    rc = ioService.NewURI (cast(nsACString*)aSpec, null, null, &uri);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (uri is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
    //XPCOM.nsEmbedCString_delete (aSpec);
        ioService.Release ();

    //nsIURI uri = new nsIURI (result[0]);
    //result[0] = 0;
    nsIInterfaceRequestor interfaceRequestor;
    rc = webBrowser.QueryInterface (&nsIInterfaceRequestor.IID, cast(void**)&interfaceRequestor);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (interfaceRequestor is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
    //nsIInterfaceRequestor interfaceRequestor = new nsIInterfaceRequestor (result[0]);
    //result[0] = 0;

        /*
        * Feature in Mozilla. LoadStream invokes the nsIInputStream argument
        * through a different thread.  The callback mechanism must attach 
        * a non java thread to the JVM otherwise the nsIInputStream Read and
        * Close methods never get called.
        */
    
    // Using fully qualified name for disambiguation with dwthelper InputStream -JJR
    auto inputStream = new dwt.browser.InputStream.InputStream (cast(byte[])html);
        inputStream.AddRef ();

    rc = interfaceRequestor.GetInterface (&nsIDocShell_1_9.IID, cast(void**)&docShell_1_9);
        rc = interfaceRequestor.GetInterface (&nsIDocShell_1_8.IID, cast(void**)&docShell_1_8);
            nsIDocShell docShell;
            rc = interfaceRequestor.GetInterface (&nsIDocShell.IID, cast(void**)&docShell);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            if (docShell is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
            //nsIDocShell docShell = new nsIDocShell (result[0]);
            rc = docShell.LoadStream (inputStream, uri, cast(nsACString*) aContentType,  cast(nsACString*)aContentCharset, null);
        docShell.Release ();

        inputStream.Release ();
        interfaceRequestor.Release ();
        uri.Release ();
    //XPCOM.nsEmbedCString_delete (aContentType);
        //XPCOM.nsEmbedCString_delete (aContentCharset);
    }
    return true;
}

extern(D)
public bool setUrl (String url) {
    htmlBytes = null;

    nsIWebNavigation webNavigation;
    int rc = webBrowser.QueryInterface (&nsIWebNavigation.IID, cast(void**)&webNavigation);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (webNavigation is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);

    rc = webNavigation.LoadURI (url.toString16().toString16z(), nsIWebNavigation.LOAD_FLAGS_NONE, null, null, null);
    /*
     * This could be the first content that is set into the browser, so
     * ensure that the custom subclass that works around Mozilla bug
     * https://bugzilla.mozilla.org/show_bug.cgi?id=453523 is removed.
     */
    delegate.removeWindowSubclass ();

    webNavigation.Release ();
    return rc is XPCOM.NS_OK;
}

extern(D)
public void stop () {
    htmlBytes = null;

    nsIWebNavigation webNavigation;
    //int /*long*/[] result = new int /*long*/[1];
    int rc = webBrowser.QueryInterface (&nsIWebNavigation.IID, cast(void**)&webNavigation);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (webNavigation is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
    
    //nsIWebNavigation webNavigation = new nsIWebNavigation (result[0]);      
    rc = webNavigation.Stop (nsIWebNavigation.STOP_ALL);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    webNavigation.Release ();
}

extern(D)
void hookDOMListeners (nsIDOMEventTarget target, bool isTop) {
    scope auto string = new nsEmbedString (XPCOM.DOMEVENT_FOCUS.toString16());
    target.AddEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_UNLOAD.toString16());
    target.AddEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_MOUSEDOWN.toString16());
    target.AddEventListener (cast(nsAString*)string,cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_MOUSEUP.toString16());
    target.AddEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_MOUSEMOVE.toString16());
    target.AddEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_MOUSEWHEEL.toString16());
    target.AddEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_MOUSEDRAG.toString16());
    target.AddEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();

    /*
    * Only hook mouseover and mouseout if the target is a top-level frame, so that mouse moves
    * between frames will not generate events.
    */
    if (isTop && mozDelegate.hookEnterExit ()) {
        string = new nsEmbedString (XPCOM.DOMEVENT_MOUSEOVER.toString16());
        target.AddEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
        //string.dispose ();
        string = new nsEmbedString (XPCOM.DOMEVENT_MOUSEOUT.toString16());
        target.AddEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
        //string.dispose ();
    }

    string = new nsEmbedString (XPCOM.DOMEVENT_KEYDOWN.toString16());
    target.AddEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_KEYPRESS.toString16());
    target.AddEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_KEYUP.toString16());
    target.AddEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
}

extern(D)
void unhookDOMListeners () {
    //int /*long*/[] result = new int /*long*/[1];
    nsIDOMWindow window;
    int rc = webBrowser.GetContentDOMWindow (&window);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (window is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);

    //nsIDOMWindow window = new nsIDOMWindow (result[0]);
    //result[0] = 0;
    nsIDOMEventTarget target;
    rc = window.QueryInterface (&nsIDOMEventTarget.IID, cast(void**)&target);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (target is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);

    //nsIDOMEventTarget target = new nsIDOMEventTarget (result[0]);
    //result[0] = 0;
    unhookDOMListeners (target);
    target.Release ();

    /* Listeners must be unhooked in pages contained in frames */
    nsIDOMWindowCollection frames;
    rc = window.GetFrames (&frames);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (frames is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
    //nsIDOMWindowCollection frames = new nsIDOMWindowCollection (result[0]);
    //result[0] = 0;
    PRUint32 count;
    rc = frames.GetLength (&count); /* PRUint32 */
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    //int count = frameCount[0];

    if (count > 0) {
        nsIDOMWindow frame;
        for (int i = 0; i < count; i++) {
            rc = frames.Item (i, &frame);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            if (frame is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);

            //nsIDOMWindow frame = new nsIDOMWindow (result[0]);
            //result[0] = 0;
            rc = frame.QueryInterface (&nsIDOMEventTarget.IID, cast(void**)&target);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            if (target is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);

            //target = new nsIDOMEventTarget (result[0]);
            //result[0] = 0;
            unhookDOMListeners (target);
            target.Release ();
            frame.Release ();
        }
    }
    frames.Release ();
    window.Release ();
}

extern(D)
void unhookDOMListeners (nsIDOMEventTarget target) {
    scope auto string = new nsEmbedString (XPCOM.DOMEVENT_FOCUS.toString16());
    target.RemoveEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_UNLOAD.toString16());
    target.RemoveEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_MOUSEDOWN.toString16());
    target.RemoveEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_MOUSEUP.toString16());
    target.RemoveEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_MOUSEMOVE.toString16());
    target.RemoveEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_MOUSEWHEEL.toString16());
    target.RemoveEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_MOUSEDRAG.toString16());
    target.RemoveEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_MOUSEOVER.toString16());
    target.RemoveEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_MOUSEOUT.toString16());
    target.RemoveEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_KEYDOWN.toString16());
    target.RemoveEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_KEYPRESS.toString16());
    target.RemoveEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_KEYUP.toString16());
    target.RemoveEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
}

/* nsISupports */

extern(System)
nsresult QueryInterface (nsID* riid, void** ppvObject) {
    if (riid is null || ppvObject is null) return XPCOM.NS_ERROR_NO_INTERFACE;

    if (*riid == nsISupports.IID) {
        *ppvObject = cast(void*)cast(nsISupports)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIWeakReference.IID) {
        *ppvObject = cast(void*)cast(nsIWeakReference)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIWebProgressListener.IID) {
        *ppvObject = cast(void*)cast(nsIWebProgressListener)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIWebBrowserChrome.IID) {
        *ppvObject = cast(void*)cast(nsIWebBrowserChrome)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIWebBrowserChromeFocus.IID) {
        *ppvObject = cast(void*)cast(nsIWebBrowserChromeFocus)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIEmbeddingSiteWindow.IID) {
        *ppvObject = cast(void*)cast(nsIEmbeddingSiteWindow)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIInterfaceRequestor.IID) {
        *ppvObject = cast(void*)cast(nsIInterfaceRequestor)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsISupportsWeakReference.IID) {
        *ppvObject = cast(void*)cast(nsISupportsWeakReference)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIContextMenuListener.IID) {
        *ppvObject = cast(void*)cast(nsIContextMenuListener)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIURIContentListener.IID) {
        *ppvObject = cast(void*)cast(nsIURIContentListener)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsITooltipListener.IID) {
        *ppvObject = cast(void*)cast(nsITooltipListener)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    *ppvObject = null;
    return XPCOM.NS_ERROR_NO_INTERFACE;
}

extern(System)
nsrefcnt AddRef () {
    refCount++;
    return refCount;
}

extern(System)
nsrefcnt Release () {
    refCount--;
    if (refCount is 0) return 0;
    return refCount;
}

/* nsIWeakReference */  

extern(System)
nsresult QueryReferent (nsID* riid, void** ppvObject) {
    return QueryInterface (riid, ppvObject);
}

/* nsIInterfaceRequestor */

extern(System)
nsresult GetInterface ( nsID* riid, void** ppvObject) {
    if (riid is null || ppvObject is null) return XPCOM.NS_ERROR_NO_INTERFACE;
    //nsID guid = new nsID ();
    //XPCOM.memmove (guid, riid, nsID.sizeof);
    if (*riid == nsIDOMWindow.IID) {
        nsIDOMWindow aContentDOMWindow;
        //int /*long*/[] aContentDOMWindow = new int /*long*/[1];
        int rc = webBrowser.GetContentDOMWindow (&aContentDOMWindow);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        if (aContentDOMWindow is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
        *ppvObject = cast(void*)aContentDOMWindow;
        //XPCOM.memmove (ppvObject, aContentDOMWindow, C.PTR_SIZEOF);
        return rc;
    }
    return QueryInterface (riid, ppvObject);
}

extern(System)
nsresult GetWeakReference (nsIWeakReference* ppvObject) {
    *ppvObject = cast(nsIWeakReference)this;
    //XPCOM.memmove (ppvObject, new int /*long*/[] {weakReference.getAddress ()}, C.PTR_SIZEOF);
    AddRef ();
    return XPCOM.NS_OK;
}

/* nsIWebProgressListener */

extern(System)
nsresult OnStateChange (nsIWebProgress aWebProgress, nsIRequest aRequest, PRUint32 aStateFlags, nsresult aStatus) {
    if ((aStateFlags & nsIWebProgressListener.STATE_IS_DOCUMENT) is 0) return XPCOM.NS_OK;
    if ((aStateFlags & nsIWebProgressListener.STATE_START) !is 0) {
        if (request is null) request = aRequest;
        /*
         * Add the page's nsIDOMWindow to the collection of windows that will
         * have DOM listeners added to them later on in the page loading
         * process.  These listeners cannot be added yet because the
         * nsIDOMWindow is not ready to take them at this stage.
         */
            //int /*long*/[] result = new int /*long*/[1];
            nsIDOMWindow window;
            //nsIWebProgress progress = new nsIWebProgress (aWebProgress);
            int rc = aWebProgress.GetDOMWindow (&window);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            if (window is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
            unhookedDOMWindows ~= window;
    } else if ((aStateFlags & nsIWebProgressListener.STATE_REDIRECTING) !is 0) {
        if (request is aRequest) request = null;
    } else if ((aStateFlags & nsIWebProgressListener.STATE_STOP) !is 0) {
        /*
        * If this page's nsIDOMWindow handle is still in unhookedDOMWindows then
        * add its DOM listeners now.  It's possible for this to happen since
        * there is no guarantee that a STATE_TRANSFERRING state change will be
        * received for every window in a page, which is when these listeners
        * are typically added.
        */
        //int /*long*/[] result = new int /*long*/[1];
        //nsIWebProgress progress = new nsIWebProgress (aWebProgress);
        nsIDOMWindow domWindow;
        int rc = aWebProgress.GetDOMWindow (&domWindow);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        if (domWindow is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
        //nsIDOMWindow domWindow = new nsIDOMWindow (result[0]);

        //LONG ptrObject = new LONG (result[0]);
        //result[0] = 0;
        int index = unhookedDOMWindows.arrayIndexOf (domWindow);
        if (index !is -1) {
            nsIDOMWindow contentWindow;
            rc = webBrowser.GetContentDOMWindow (&contentWindow);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            if (contentWindow is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
            bool isTop = contentWindow is domWindow;
            contentWindow.Release ();
            //result[0] = 0;
            nsIDOMEventTarget target;
            rc = domWindow.QueryInterface (&nsIDOMEventTarget.IID, cast(void**)&target);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            if (target is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);

            //nsIDOMEventTarget target = new nsIDOMEventTarget (result[0]);
            //result[0] = 0;
            hookDOMListeners (target, isTop);
            target.Release ();

            /*
            * Remove and unreference the nsIDOMWindow from the collection of windows
            * that are waiting to have DOM listeners hooked on them. 
            */
            unhookedDOMWindows = unhookedDOMWindows.arrayIndexRemove (index);
            domWindow.Release ();
        }

        /*
         * If htmlBytes is not null then there is html from a previous setText() call
         * waiting to be set into the about:blank page once it has completed loading. 
         */
        if (htmlBytes !is null) {
            nsIRequest req = new nsIRequest (aRequest);
            int /*long*/ name = XPCOM.nsEmbedCString_new ();
            rc = req.GetName (name);
            if (rc !is XPCOM.NS_OK) error (rc);
            int length = XPCOM.nsEmbedCString_Length (name);
            int /*long*/ buffer = XPCOM.nsEmbedCString_get (name);
            byte[] dest = new byte[length];
            XPCOM.memmove (dest, buffer, length);
            String url = new String (dest);
            XPCOM.nsEmbedCString_delete (name);

            if (url.startsWith (ABOUT_BLANK)) {
                /*
                 * Setting mozilla's content with nsIWebBrowserStream invalidates the 
                 * DOM listeners that were hooked on it (about:blank), so remove them and
                 * add new ones after the content has been set.
                 */
                unhookDOMListeners ();

                rc = XPCOM.NS_GetServiceManager (result);
                if (rc !is XPCOM.NS_OK) error (rc);
                if (result[0] is 0) error (XPCOM.NS_NOINTERFACE);

                nsIServiceManager serviceManager = new nsIServiceManager (result[0]);
                result[0] = 0;
                rc = serviceManager.GetService (XPCOM.NS_IOSERVICE_CID, nsIIOService.NS_IIOSERVICE_IID, result);
                if (rc !is XPCOM.NS_OK) error (rc);
                if (result[0] is 0) error (XPCOM.NS_NOINTERFACE);
                serviceManager.Release ();

                nsIIOService ioService = new nsIIOService (result[0]);
                result[0] = 0;
                /*
                * Note.  Mozilla ignores LINK tags used to load CSS stylesheets
                * when the URI protocol for the nsInputStreamChannel
                * is about:blank.  The fix is to specify the file protocol.
                */
                byte[] aString = MozillaDelegate.wcsToMbcs (null, URI_FROMMEMORY, false);
                int /*long*/ aSpec = XPCOM.nsEmbedCString_new (aString, aString.length);
                rc = ioService.NewURI (aSpec, null, 0, result);
                if (rc !is XPCOM.NS_OK) error (rc);
                if (result[0] is 0) error (XPCOM.NS_NOINTERFACE);
                XPCOM.nsEmbedCString_delete (aSpec);
                ioService.Release ();

                nsIURI uri = new nsIURI (result[0]);
                result[0] = 0;

                rc = webBrowser.QueryInterface (nsIWebBrowserStream.NS_IWEBBROWSERSTREAM_IID, result);
                if (rc !is XPCOM.NS_OK) error (rc);
                if (result[0] is 0) error (XPCOM.NS_NOINTERFACE);

                nsIWebBrowserStream stream = new nsIWebBrowserStream (result[0]);
                result[0] = 0;

                byte[] contentTypeBuffer = MozillaDelegate.wcsToMbcs (null, "text/html", true); // $NON-NLS-1$
                int /*long*/ aContentType = XPCOM.nsEmbedCString_new (contentTypeBuffer, contentTypeBuffer.length);

                rc = stream.OpenStream (uri.getAddress (), aContentType);
                if (rc !is XPCOM.NS_OK) error (rc);
                int /*long*/ ptr = C.malloc (htmlBytes.length);
                XPCOM.memmove (ptr, htmlBytes, htmlBytes.length);
                int pageSize = 8192;
                int pageCount = htmlBytes.length / pageSize + 1;
                int /*long*/ current = ptr;
                for (int i = 0; i < pageCount; i++) {
                    length = i is pageCount - 1 ? htmlBytes.length % pageSize : pageSize;
                    if (length > 0) {
                        rc = stream.AppendToStream (current, length);
                        if (rc !is XPCOM.NS_OK) error (rc);
                    }
                    current += pageSize;
                }
                rc = stream.CloseStream ();
                if (rc !is XPCOM.NS_OK) error (rc);
                C.free (ptr);
                XPCOM.nsEmbedCString_delete (aContentType);
                stream.Release ();
                uri.Release ();
                htmlBytes = null;

                rc = webBrowser.GetContentDOMWindow (result);
                if (rc !is XPCOM.NS_OK) error (rc);
                if (result[0] is 0) error (XPCOM.NS_ERROR_NO_INTERFACE);
                bool isTop = result[0] is domWindow.getAddress ();
                new nsISupports (result[0]).Release ();
                result[0] = 0;

                rc = domWindow.QueryInterface (nsIDOMEventTarget.NS_IDOMEVENTTARGET_IID, result);
                if (rc !is XPCOM.NS_OK) error (rc);
                if (result[0] is 0) error (XPCOM.NS_ERROR_NO_INTERFACE);
                nsIDOMEventTarget target = new nsIDOMEventTarget (result[0]);
                result[0] = 0;
                hookDOMListeners (target, isTop);
                target.Release ();
            }
        }
        domWindow.Release ();

        /*
        * Feature in Mozilla.  When a request is redirected (STATE_REDIRECTING),
        * it never reaches the state STATE_STOP and it is replaced with a new request.
        * The new request is received when it is in the state STATE_STOP.
        * To handle this case,  the variable request is set to 0 when the corresponding
        * request is redirected. The following request received with the state STATE_STOP
        * - the new request resulting from the redirection - is used to send
        * the ProgressListener.completed event.
        */
        if (request is aRequest || request is null) {
            request = null;
            StatusTextEvent event = new StatusTextEvent (browser);
            event.display = browser.getDisplay ();
            event.widget = browser;
            event.text = ""; //$NON-NLS-1$
            for (int i = 0; i < statusTextListeners.length; i++) {
                statusTextListeners[i].changed (event);
            }

            /* re-install registered functions */
            Enumeration elements = functions.elements ();
            while (elements.hasMoreElements ()) {
                BrowserFunction function = (BrowserFunction)elements.nextElement ();
                execute (function.functionString);
            }

            ProgressEvent event2 = new ProgressEvent (browser);
            event2.display = browser.getDisplay ();
            event2.widget = browser;
            for (int i = 0; i < progressListeners.length; i++) {
                progressListeners[i].completed (event2);
            }
        }
    } else if ((aStateFlags & nsIWebProgressListener.STATE_TRANSFERRING) !is 0) {
        /*
        * Hook DOM listeners to the page's nsIDOMWindow here because this is
        * the earliest opportunity to do so.    
        */
        //int /*long*/[] result = new int /*long*/[1];
       // nsIWebProgress progress = new nsIWebProgress (aWebProgress);
        nsIDOMWindow domWindow;
        int rc = aWebProgress.GetDOMWindow (&domWindow);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        if (domWindow is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
        //nsIDOMWindow domWindow = new nsIDOMWindow (result[0]);

        //LONG ptrObject = new LONG (result[0]);
        //result[0] = 0;
        int index = unhookedDOMWindows.arrayIndexOf ( domWindow);
        if (index !is -1) {
            nsIDOMWindow contentWindow;
            rc = webBrowser.GetContentDOMWindow (&contentWindow);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            if (contentWindow is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
            bool isTop = contentWindow is domWindow;
            contentWindow.Release ();
            //result[0] = 0;
            nsIDOMEventTarget target;
            rc = domWindow.QueryInterface (&nsIDOMEventTarget.IID, cast(void**)&target);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            if (target is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);

            //nsIDOMEventTarget target = new nsIDOMEventTarget (result[0]);
            //result[0] = 0;
            hookDOMListeners (target, isTop);
            target.Release ();

            /*
            * Remove and unreference the nsIDOMWindow from the collection of windows
            * that are waiting to have DOM listeners hooked on them. 
            */
            unhookedDOMWindows = unhookedDOMWindows.arrayIndexRemove(index);
            domWindow.Release ();
        }
        domWindow.Release ();
    }
    return XPCOM.NS_OK;
}

extern(System)
nsresult OnProgressChange (nsIWebProgress aWebProgress, nsIRequest aRequest, PRInt32 aCurSelfProgress, PRInt32 aMaxSelfProgress, PRInt32 aCurTotalProgress, PRInt32 aMaxTotalProgress) {
    if (progressListeners.length is 0) return XPCOM.NS_OK;
    if (awaitingNavigate || super.progressListeners.length is 0) return XPCOM.NS_OK;
    ProgressEvent event = new ProgressEvent (browser);
    event.display = browser.getDisplay ();
    event.widget = browser;
    event.current = aCurTotalProgress;
    event.total = aMaxTotalProgress;
    for (int i = 0; i < super.progressListeners.length; i++) {
        super.progressListeners[i].changed (event);
    }
    return XPCOM.NS_OK;
}

extern(System)
nsresult OnLocationChange (nsIWebProgress aWebProgress, nsIRequest aRequest, nsIURI aLocation) {
    /*
    * Feature in Mozilla.  When a page is loaded via setText before a previous
    * setText page load has completed, the expected OnStateChange STATE_STOP for the
    * original setText never arrives because it gets replaced by the OnStateChange
    * STATE_STOP for the new request.  This results in the request field never being
    * cleared because the original request's OnStateChange STATE_STOP is still expected
    * (but never arrives).  To handle this case, the request field is updated to the new
    * overriding request since its OnStateChange STATE_STOP will be received next.
    */
    if (request !is null && request !is aRequest) request = aRequest;

    if (locationListeners.length is 0) return XPCOM.NS_OK;

    //nsIWebProgress webProgress = new nsIWebProgress (aWebProgress);
    
    nsIDOMWindow domWindow;
    //int /*long*/[] aDOMWindow = new int /*long*/[1];
    int rc = aWebProgress.GetDOMWindow (&domWindow);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (domWindow is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
    
    //nsIDOMWindow domWindow = new nsIDOMWindow (aDOMWindow[0]);
    //int /*long*/[] aTop = new int /*long*/[1];
    nsIDOMWindow topWindow;
    rc = domWindow.GetTop (&topWindow);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (topWindow is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
    domWindow.Release ();
    
    //nsIDOMWindow topWindow = new nsIDOMWindow (aTop[0]);
    topWindow.Release ();
    
    //nsIURI location = new nsIURI (aLocation);
    scope auto aSpec = new nsEmbedCString;
    aLocation.GetSpec (cast(nsACString*)aSpec);
    //int length = XPCOM.nsEmbedCString_Length (aSpec);
    //int /*long*/ buffer = XPCOM.nsEmbedCString_get (aSpec);
    //byte[] dest = new byte[length];
    //XPCOM.memmove (dest, buffer, length);
    //XPCOM.nsEmbedCString_delete (aSpec);
    String url = aSpec.toString;

    /*
     * As of Mozilla 1.8, the first time that a page is displayed, regardless of
     * whether it's via Browser.setURL() or Browser.setText(), the GRE navigates
     * to about:blank and fires the corresponding navigation events.  Do not send
     * this event on to the user since it is not expected.
     */
    if (!IsPre_1_8 && aRequest is null && url.startsWith (ABOUT_BLANK)) return XPCOM.NS_OK;

    LocationEvent event = new LocationEvent (browser);
    event.display = browser.getDisplay ();
    event.widget = browser;
    event.location = url;
    /*
     * If the URI indicates that the page is being rendered from memory
     * (via setText()) then set it to about:blank to be consistent with IE.
     */
    if (event.location.equals (URI_FROMMEMORY)) event.location = ABOUT_BLANK;
    event.top = topWindow is domWindow;
    for (int i = 0; i < locationListeners.length; i++) {
        locationListeners[i].changed (event);
    }
    return XPCOM.NS_OK;
}

extern(System)
nsresult OnStatusChange (nsIWebProgress aWebProgress, nsIRequest aRequest, nsresult aStatus, PRUnichar* aMessage) {
    if (statusTextListeners.length is 0) return XPCOM.NS_OK;
    StatusTextEvent event = new StatusTextEvent (browser);
    event.display = browser.getDisplay ();
    event.widget = browser;
    //int length = XPCOM.strlen_PRUnichar (aMessage);
    //char[] dest = new char[length];
    //XPCOM.memmove (dest, aMessage, length * 2);
    event.text = Utf.toString(fromString16z(aMessage));
    for (int i = 0; i < statusTextListeners.length; i++) {
        statusTextListeners[i].changed (event);
    }
    return XPCOM.NS_OK;
}       

extern(System)
nsresult OnSecurityChange (nsIWebProgress aWebProgress, nsIRequest aRequest, PRUint32 state) {
    return XPCOM.NS_OK;
}

/* nsIWebBrowserChrome */

extern(System)
nsresult SetStatus (PRUint32 statusType, PRUnichar* status) {
    if (statusTextListeners.length is 0) return XPCOM.NS_OK;
    StatusTextEvent event = new StatusTextEvent (browser);
    event.display = browser.getDisplay ();
    event.widget = browser;
    //int length = XPCOM.strlen_PRUnichar (status);
    //char[] dest = new char[length];
    //XPCOM.memmove (dest, status, length * 2);
    //String string = new String (dest);
    event.text = Utf.toString(fromString16z(status));
    for (int i = 0; i < statusTextListeners.length; i++) {
        statusTextListeners[i].changed (event);
    }
    return XPCOM.NS_OK;
}

extern(System)
nsresult GetWebBrowser (nsIWebBrowser* aWebBrowser) {
    //int /*long*/[] ret = new int /*long*/[1];   
    if (webBrowser !is null) {
        webBrowser.AddRef ();
        *aWebBrowser = webBrowser;  
    }
    //XPCOM.memmove (aWebBrowser, ret, C.PTR_SIZEOF);
    return XPCOM.NS_OK;
}

extern(System)
nsresult SetWebBrowser (nsIWebBrowser aWebBrowser) {
    if (webBrowser !is null) webBrowser.Release ();
    webBrowser = aWebBrowser !is null ? cast(nsIWebBrowser)cast(void*)aWebBrowser : null;                
    return XPCOM.NS_OK;
}

extern(System)
nsresult GetChromeFlags (PRUint32* aChromeFlags) {
    //int[] ret = new int[1];
    *aChromeFlags = chromeFlags;
    //XPCOM.memmove (aChromeFlags, ret, 4); /* PRUint32 */
    return XPCOM.NS_OK;
}

extern(System)
nsresult SetChromeFlags (PRUint32 aChromeFlags) {
    chromeFlags = aChromeFlags;
    return XPCOM.NS_OK;
}

extern(System)
nsresult DestroyBrowserWindow () {
    WindowEvent newEvent = new WindowEvent (browser);
    newEvent.display = browser.getDisplay ();
    newEvent.widget = browser;
    for (int i = 0; i < closeWindowListeners.length; i++) {
        closeWindowListeners[i].close (newEvent);
    }
    /*
    * Note on Mozilla.  The DestroyBrowserWindow notification cannot be cancelled.
    * The browser widget cannot be used after this notification has been received.
    * The application is advised to close the window hosting the browser widget.
    * The browser widget must be disposed in all cases.
    */
    browser.dispose ();
    return XPCOM.NS_OK;
}

extern(System)
nsresult SizeBrowserTo (PRInt32 aCX, PRInt32 aCY) {
    size = new Point (aCX, aCY);
    bool isChrome = (chromeFlags & nsIWebBrowserChrome.CHROME_OPENAS_CHROME) !is 0;
    if (isChrome) {
        Shell shell = browser.getShell ();
        shell.setSize (shell.computeSize (size.x, size.y));
    }
    return XPCOM.NS_OK;
}

extern(System)
nsresult ShowAsModal () {
    //int /*long*/[] result = new int /*long*/[1];
    nsIServiceManager serviceManager;
    int rc = XPCOM.NS_GetServiceManager (&serviceManager);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (serviceManager is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);

    //nsIServiceManager serviceManager = new nsIServiceManager (result[0]);
    //result[0] = 0;
    //byte[] aContractID = MozillaDelegate.wcsToMbcs (null, XPCOM.NS_CONTEXTSTACK_CONTRACTID, true);
    nsIJSContextStack stack;
    rc = serviceManager.GetServiceByContractID (XPCOM.NS_CONTEXTSTACK_CONTRACTID.ptr, &nsIJSContextStack.IID, cast(void**)&stack);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (stack is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
    serviceManager.Release ();

    //nsIJSContextStack stack = new nsIJSContextStack (result[0]);
    //result[0] = 0;
    rc = stack.Push (null);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);

    Shell shell = browser.getShell ();
    Display display = browser.getDisplay ();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    JSContext* result;
    rc = stack.Pop (&result);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    stack.Release ();
    return XPCOM.NS_OK;
}

extern(System)
nsresult IsWindowModal (PRBool* retval) {
    *retval = (chromeFlags & nsIWebBrowserChrome.CHROME_MODAL) !is 0 ? 1 : 0;
    //XPCOM.memmove (retval, new int[] {result}, 4); /* PRBool */
    return XPCOM.NS_OK;
}

extern(System)
nsresult ExitModalEventLoop (nsresult aStatus) {
    return XPCOM.NS_OK;
}

/* nsIEmbeddingSiteWindow */ 

extern(System)
nsresult SetDimensions (PRUint32 flags, PRInt32 x, PRInt32 y, PRInt32 cx, PRInt32 cy) {
    if ((flags & nsIEmbeddingSiteWindow.DIM_FLAGS_POSITION) !is 0) {
        location = new Point (x, y);
        browser.getShell ().setLocation (x, y);
    }
    if ((flags & nsIEmbeddingSiteWindow.DIM_FLAGS_SIZE_INNER) !is 0) {
        browser.setSize (cx, cy);
    }
    if ((flags & nsIEmbeddingSiteWindow.DIM_FLAGS_SIZE_OUTER) !is 0) {
        browser.getShell ().setSize (cx, cy);
    }
    return XPCOM.NS_OK;
}

extern(System)
nsresult GetDimensions (PRUint32 flags, PRInt32* x, PRInt32* y, PRInt32* cx, PRInt32* cy) {
    if ((flags & nsIEmbeddingSiteWindow.DIM_FLAGS_POSITION) !is 0) {
        Point location = browser.getShell ().getLocation ();
        if (x !is null) *x = location.x; /* PRInt32 */
        if (y !is null) *y = location.y; /* PRInt32 */
    }
    if ((flags & nsIEmbeddingSiteWindow.DIM_FLAGS_SIZE_INNER) !is 0) {
        Point size = browser.getSize ();
        if (cx !is null) *cx = size.x; /* PRInt32 */
        if (cy !is null) *cy = size.y; /* PRInt32 */
    }
    if ((flags & nsIEmbeddingSiteWindow.DIM_FLAGS_SIZE_OUTER) !is 0) {
        Point size = browser.getShell().getSize ();
        if (cx !is null) *cx = size.x; /* PRInt32 */
        if (cy !is null) *cy = size.y; /* PRInt32 */
    }
    return XPCOM.NS_OK;
}

extern(System)
nsresult SetFocus () {
    //int /*long*/[] result = new int /*long*/[1];
    nsIBaseWindow baseWindow;
    int rc = webBrowser.QueryInterface (&nsIBaseWindow.IID, cast(void**)&baseWindow);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (baseWindow is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
    
    //nsIBaseWindow baseWindow = new nsIBaseWindow (result[0]);
    rc = baseWindow.SetFocus ();
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    baseWindow.Release ();

    /*
    * Note. Mozilla notifies here that one of the children took
    * focus. This could or should be used to fire an DWT.FOCUS_IN
    * event on Browser focus listeners.
    */
    return XPCOM.NS_OK;         
}   

extern(System)
nsresult GetVisibility (PRBool* aVisibility) {
    bool visible = browser.isVisible () && !browser.getShell ().getMinimized ();
    *aVisibility = visible ? 1 : 0;
    //XPCOM.memmove (aVisibility, new int[] {visible ? 1 : 0}, 4); /* PRBool */
    return XPCOM.NS_OK;
}

extern(System)
nsresult SetVisibility (PRBool aVisibility) {
    if (isChild) {
        WindowEvent event = new WindowEvent (browser);
        event.display = browser.getDisplay ();
        event.widget = browser;
        if (aVisibility !is 0) {
            /*
            * Bug in Mozilla.  When the JavaScript window.open is executed, Mozilla
            * fires multiple SetVisibility 1 notifications.  The workaround is
            * to ignore subsequent notifications. 
            */
            if (!visible) {
                visible = true;
                event.location = location;
                event.size = size;
                event.addressBar = (chromeFlags & nsIWebBrowserChrome.CHROME_LOCATIONBAR) !is 0;
                event.menuBar = (chromeFlags & nsIWebBrowserChrome.CHROME_MENUBAR) !is 0;
                event.statusBar = (chromeFlags & nsIWebBrowserChrome.CHROME_STATUSBAR) !is 0;
                event.toolBar = (chromeFlags & nsIWebBrowserChrome.CHROME_TOOLBAR) !is 0;
                for (int i = 0; i < visibilityWindowListeners.length; i++) {
                    visibilityWindowListeners[i].show (event);
                }
                location = null;
                size = null;
            }
        } else {
            visible = false;
            for (int i = 0; i < visibilityWindowListeners.length; i++) {
                visibilityWindowListeners[i].hide (event);
            }
        }
    } else {
        visible = aVisibility !is 0;
    }
    return XPCOM.NS_OK;         
}

extern(System)
nsresult GetTitle (PRUnichar** aTitle) {
    return XPCOM.NS_OK;         
}
 
extern(System)
nsresult SetTitle (PRUnichar* aTitle) {
    if (titleListeners.length is 0) return XPCOM.NS_OK;
    TitleEvent event = new TitleEvent (browser);
    event.display = browser.getDisplay ();
    event.widget = browser;
    /*
    * To be consistent with other platforms the title event should
    * contain the page's url if the page does not contain a <title>
    * tag. 
    */
    int length = XPCOM.strlen_PRUnichar (aTitle);
    if (length > 0) {
        //char[] dest = new char[length];
        //XPCOM.memmove (dest, aTitle, length * 2);
        event.title = Utf.toString(fromString16z(aTitle));
    } else {
        event.title = getUrl ();
    }
    for (int i = 0; i < titleListeners.length; i++) {
        titleListeners[i].changed (event);
    }
    return XPCOM.NS_OK;         
}

extern(System)
nsresult GetSiteWindow (void** aSiteWindow) {
    /*
    * Note.  The handle is expected to be an HWND on Windows and
    * a GtkWidget* on GTK.  This callback is invoked on Windows
    * when the javascript window.print is invoked and the print
    * dialog comes up. If no handle is returned, the print dialog
    * does not come up on this platform.  
    */
    *aSiteWindow = cast(void*) embedHandle;
    return XPCOM.NS_OK;         
}  
 
/* nsIWebBrowserChromeFocus */

extern(System)
nsresult FocusNextElement () {
    /*
    * Bug in Mozilla embedding API.  Mozilla takes back the focus after sending
    * this event.  This prevents tabbing out of Mozilla. This behaviour can be reproduced
    * with the Mozilla application TestGtkEmbed.  The workaround is to
    * send the traversal notification after this callback returns.
    */
    browser.getDisplay ().asyncExec (new class() Runnable {
        public void run () {
            if (browser.isDisposed ()) return;
            browser.traverse (DWT.TRAVERSE_TAB_NEXT);
        }
    });
    return XPCOM.NS_OK;  
}

extern(System)
nsresult FocusPrevElement () {
    /*
    * Bug in Mozilla embedding API.  Mozilla takes back the focus after sending
    * this event.  This prevents tabbing out of Mozilla. This behaviour can be reproduced
    * with the Mozilla application TestGtkEmbed.  The workaround is to
    * send the traversal notification after this callback returns.
    */
    browser.getDisplay ().asyncExec (new class() Runnable {
        public void run () {
            if (browser.isDisposed ()) return;
            browser.traverse (DWT.TRAVERSE_TAB_PREVIOUS);
        }
    });
    return XPCOM.NS_OK;         
}

/* nsIContextMenuListener */

extern(System)
nsresult OnShowContextMenu (PRUint32 aContextFlags, nsIDOMEvent aEvent, nsIDOMNode aNode) {
    //nsIDOMEvent domEvent = new nsIDOMEvent (aEvent);
    //int /*long*/[] result = new int /*long*/[1];
    nsIDOMMouseEvent domMouseEvent;
    int rc = aEvent.QueryInterface (&nsIDOMMouseEvent.IID, cast(void**)&domMouseEvent);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (domMouseEvent is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);

    //nsIDOMMouseEvent domMouseEvent = new nsIDOMMouseEvent (result[0]);
    PRInt32 aScreenX, aScreenY;
    rc = domMouseEvent.GetScreenX (&aScreenX);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    rc = domMouseEvent.GetScreenY (&aScreenY);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    domMouseEvent.Release ();
    
    auto event = new Event;
    event.x = aScreenX;
    event.y = aScreenY;
    browser.notifyListeners (DWT.MenuDetect, event);
    if (!event.doit) return XPCOM.NS_OK;
    Menu menu = browser.getMenu ();
    if (menu !is null && !menu.isDisposed ()) {
        if (aScreenX !is event.x || aScreenY !is event.y) {
            menu.setLocation (event.x, event.y);
        }
        menu.setVisible (true);
    }
    return XPCOM.NS_OK;         
}

/* nsIURIContentListener */

extern(System)
nsresult OnStartURIOpen (nsIURI aURI, PRBool* retval) {
    authCount = 0;

        //XPCOM.memmove (retval, new int[] {0}, 4); /* PRBool */
    //nsIURI location = new nsIURI (aURI);
    scope auto aSpec = new nsEmbedCString;
    aURI.GetSpec (cast(nsACString*)aSpec);
    //int length = XPCOM.nsEmbedCString_Length (aSpec);
    //int /*long*/ buffer = XPCOM.nsEmbedCString_get (aSpec);
    //buffer = XPCOM.nsEmbedCString_get (aSpec);
    //byte[] dest = new byte[length];
    //XPCOM.memmove (dest, buffer, length);
    //XPCOM.nsEmbedCString_delete (aSpec);
    String value = aSpec.toString;
    bool doit = true;
    if (request is null) {
        /* 
         * listeners should not be notified of internal transitions like "javascript:..."
         * because this is an implementation side-effect, not a true navigate
         */
        if (!value.startsWith (PREFIX_JAVASCRIPT)) {
            if (locationListeners.length > 0) {
                LocationEvent event = new LocationEvent (browser);
                event.display = browser.getDisplay();
                event.widget = browser;
                event.location = value;
                /*
                 * If the URI indicates that the page is being rendered from memory
                 * (via setText()) then set it to about:blank to be consistent with IE.
                 */
                if (event.location.equals (URI_FROMMEMORY)) event.location = ABOUT_BLANK;
                event.doit = doit;
                for (int i = 0; i < locationListeners.length; i++) {
                    locationListeners[i].changing (event);
                }
                doit = event.doit && !browser.isDisposed();
            }

            if (doit) {
                if (jsEnabledChanged) {
                    jsEnabledChanged = false;
    
                    int /*long*/[] result = new int /*long*/[1];
                    int rc = webBrowser.QueryInterface (nsIWebBrowserSetup.NS_IWEBBROWSERSETUP_IID, result);
                    if (rc !is XPCOM.NS_OK) error (rc);
                    if (result[0] is 0) error (XPCOM.NS_NOINTERFACE);
    
                    nsIWebBrowserSetup setup = new nsIWebBrowserSetup (result[0]);
                    result[0] = 0;
                    rc = setup.SetProperty (nsIWebBrowserSetup.SETUP_ALLOW_JAVASCRIPT, jsEnabled ? 1 : 0);
                    if (rc !is XPCOM.NS_OK) error (rc);
                    setup.Release ();
                }
                lastNavigateURL = value;
            }
        }
    }
    *retval = doit ? 0 : 1;
    //XPCOM.memmove (retval, new int[] {doit ? 0 : 1}, 4); /* PRBool */
    return XPCOM.NS_OK;
}

extern(System)
nsresult DoContent (char* aContentType, PRBool aIsContentPreferred, nsIRequest aRequest, nsIStreamListener* aContentHandler, PRBool* retval) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult IsPreferred (char* aContentType, char** aDesiredContentType, PRBool* retval) {
    bool preferred = false;
    auto size = strlen (aContentType);
    if (size > 0) {
        //byte[] typeBytes = new byte[size + 1];
        //XPCOM.memmove (typeBytes, aContentType, size);
        String contentType = fromStringz(aContentType);

        /* do not attempt to handle known problematic content types */
        if (!contentType.equals (XPCOM.CONTENT_MAYBETEXT) && !contentType.equals (XPCOM.CONTENT_MULTIPART)) {
            /* determine whether browser can handle the content type */
            // int /*long*/[] result = new int /*long*/[1];
            nsIServiceManager serviceManager;
            int rc = XPCOM.NS_GetServiceManager (&serviceManager);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            if (serviceManager is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
            //nsIServiceManager serviceManager = new nsIServiceManager (result[0]);
            //result[0] = 0;

            /* First try to use the nsIWebNavigationInfo if it's available (>= mozilla 1.8) */
            //byte[] aContractID = MozillaDelegate.wcsToMbcs (null, XPCOM.NS_WEBNAVIGATIONINFO_CONTRACTID, true);
            nsIWebNavigationInfo info;
            rc = serviceManager.GetServiceByContractID (XPCOM.NS_WEBNAVIGATIONINFO_CONTRACTID.ptr, &nsIWebNavigationInfo.IID, cast(void**)&info);
            if (rc is XPCOM.NS_OK) {
                //byte[] bytes = MozillaDelegate.wcsToMbcs (null, contentType, true);
                scope auto typePtr = new nsEmbedCString(contentType);
                //nsIWebNavigationInfo info = new nsIWebNavigationInfo (result[0]);
                //result[0] = 0;
                PRUint32 isSupportedResult; /* PRUint32 */
                rc = info.IsTypeSupported (cast(nsACString*)typePtr, null, &isSupportedResult);
                if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
                info.Release ();
                //XPCOM.nsEmbedCString_delete (typePtr);
                preferred = isSupportedResult !is 0;
            } else {
                /* nsIWebNavigationInfo is not available, so do the type lookup */
                //result[0] = 0;
                nsICategoryManager categoryManager;
                rc = serviceManager.GetService (&XPCOM.NS_CATEGORYMANAGER_CID, &nsICategoryManager.IID, cast(void**)&categoryManager);
                if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
                if (categoryManager is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);

                //nsICategoryManager categoryManager = new nsICategoryManager (result[0]);
                //result[0] = 0;
                char* categoryBytes = "Gecko-Content-Viewers"; //$NON-NLS-1$
                char* result;
                rc = categoryManager.GetCategoryEntry (categoryBytes, aContentType, &result);
                categoryManager.Release ();
                /* if no viewer for the content type is registered then rc is XPCOM.NS_ERROR_NOT_AVAILABLE */
                preferred = rc is XPCOM.NS_OK;
            }
            serviceManager.Release ();
        }
    }

    *retval = preferred ? 1 : 0; /* PRBool */
    if (preferred) {
        *aDesiredContentType = null;
    }
    return XPCOM.NS_OK;
}

extern(System)
nsresult CanHandleContent (char* aContentType, PRBool aIsContentPreferred, char** aDesiredContentType, PRBool* retval) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult GetLoadCookie (nsISupports* aLoadCookie) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult SetLoadCookie (nsISupports aLoadCookie) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult GetParentContentListener (nsIURIContentListener* aParentContentListener) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult SetParentContentListener (nsIURIContentListener aParentContentListener) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

/* nsITooltipListener */

extern(System)
nsresult OnShowTooltip (PRInt32 aXCoords, PRInt32 aYCoords, PRUnichar* aTipText) {
    //int length = XPCOM.strlen_PRUnichar (aTipText);
    //char[] dest = new char[length];
    //XPCOM.memmove (dest, aTipText, length * 2);
    String text = Utf.toString(fromString16z(aTipText));
    if (tip !is null && !tip.isDisposed ()) tip.dispose ();
    Display display = browser.getDisplay ();
    Shell parent = browser.getShell ();
    tip = new Shell (parent, DWT.ON_TOP);
    tip.setLayout (new FillLayout());
    Label label = new Label (tip, DWT.CENTER);
    label.setForeground (display.getSystemColor (DWT.COLOR_INFO_FOREGROUND));
    label.setBackground (display.getSystemColor (DWT.COLOR_INFO_BACKGROUND));
    label.setText (text);
    /*
    * Bug in Mozilla embedded API.  Tooltip coordinates are wrong for 
    * elements inside an inline frame (IFrame tag).  The workaround is 
    * to position the tooltip based on the mouse cursor location.
    */
    Point point = display.getCursorLocation ();
    /* Assuming cursor is 21x21 because this is the size of
     * the arrow cursor on Windows
     */ 
    point.y += 21;
    tip.setLocation (point);
    tip.pack ();
    tip.setVisible (true);
    return XPCOM.NS_OK;
}

extern(System)
nsresult OnHideTooltip () {
    if (tip !is null && !tip.isDisposed ()) tip.dispose ();
    tip = null;
    return XPCOM.NS_OK;
}

/* nsIDOMEventListener */

extern(System)
nsresult HandleEvent (nsIDOMEvent event) {
    //nsIDOMEvent domEvent = new nsIDOMEvent (event);

    scope auto type = new nsEmbedString;
    int rc = event.GetType (cast(nsAString*)type);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    //int length = XPCOM.nsEmbedString_Length (type);
    //int /*long*/ buffer = XPCOM.nsEmbedString_get (type);
    //char[] chars = new char[length];
    //XPCOM.memmove (chars, buffer, length * 2);
    String typeString = type.toString;
    //XPCOM.nsEmbedString_delete (type);

    if (XPCOM.DOMEVENT_UNLOAD.equals (typeString)) {
        //int /*long*/[] result = new int /*long*/[1];
        nsIDOMEventTarget target;
        rc = event.GetCurrentTarget (&target);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        if (target is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);

        //nsIDOMEventTarget target = new nsIDOMEventTarget (result[0]);
        unhookDOMListeners (target);
        target.Release ();
        return XPCOM.NS_OK;
    }

    if (XPCOM.DOMEVENT_FOCUS.equals (typeString)) {
        mozDelegate.handleFocus ();
        return XPCOM.NS_OK;
    }

    if (XPCOM.DOMEVENT_KEYDOWN.equals (typeString)) {
        //int /*long*/[] result = new int /*long*/[1];
        nsIDOMKeyEvent domKeyEvent;
        rc = event.QueryInterface (&nsIDOMKeyEvent.IID, cast(void**)&domKeyEvent);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        if (domKeyEvent is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
        //nsIDOMKeyEvent domKeyEvent = new nsIDOMKeyEvent (result[0]);
        //result[0] = 0;

        PRUint32 aKeyCode; /* PRUint32 */
        rc = domKeyEvent.GetKeyCode (&aKeyCode);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        int keyCode = super.translateKey (aKeyCode);

        /*
        * if keyCode is lastKeyCode then either a repeating key like Shift
        * is being held or a key for which key events are not sent has been
        * pressed.  In both of these cases a KeyDown should not be sent.
        */
        if (keyCode !is lastKeyCode) {
            lastKeyCode = keyCode;
            switch (keyCode) {
                case DWT.SHIFT:
                case DWT.CONTROL:
                case DWT.ALT:
                case DWT.CAPS_LOCK:
                case DWT.NUM_LOCK:
                case DWT.SCROLL_LOCK:
                case DWT.COMMAND: {
                    /* keypress events will not be received for these keys, so send KeyDowns for them now */
                    PRBool aAltKey, aCtrlKey, aShiftKey, aMetaKey; /* PRBool */
                    rc = domKeyEvent.GetAltKey (&aAltKey);
                    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
                    rc = domKeyEvent.GetCtrlKey (&aCtrlKey);
                    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
                    rc = domKeyEvent.GetShiftKey (&aShiftKey);
                    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
                    rc = domKeyEvent.GetMetaKey (&aMetaKey);
                    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);

                    Event keyEvent = new Event ();
                    keyEvent.widget = browser;
                    keyEvent.type = DWT.KeyDown;
                    keyEvent.keyCode = keyCode;
                    keyEvent.stateMask = (aAltKey !is 0 ? DWT.ALT : 0) | (aCtrlKey !is 0 ? DWT.CTRL : 0) | (aShiftKey !is 0 ? DWT.SHIFT : 0) | (aMetaKey !is 0 ? DWT.COMMAND : 0);
                    keyEvent.stateMask &= ~keyCode;     /* remove current keydown if it's a state key */
                    browser.notifyListeners (keyEvent.type, keyEvent);
                    if (!keyEvent.doit) {
                        event.PreventDefault ();
                    }
                    break;
                }
                default: {
                    /* 
                    * If the keydown has Meta (but not Meta+Ctrl) as a modifier then send a KeyDown event for it here
                    * because a corresponding keypress event will not be received for it from the DOM.  If the keydown
                    * does not have Meta as a modifier, or has Meta+Ctrl as a modifier, then then do nothing here
                    * because its KeyDown event will be sent from the keypress listener.
                    */
                    PRBool aMetaKey; /* PRBool */
                    rc = domKeyEvent.GetMetaKey (&aMetaKey);
                    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
                    if (aMetaKey !is 0) {
                        PRBool aCtrlKey; /* PRBool */
                        rc = domKeyEvent.GetCtrlKey (&aCtrlKey);
                        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
                        if (aCtrlKey is 0) {
                            PRBool aAltKey, aShiftKey; /* PRBool */
                            rc = domKeyEvent.GetAltKey (&aAltKey);
                            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
                            rc = domKeyEvent.GetShiftKey (&aShiftKey);
                            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);

                            Event keyEvent = new Event ();
                            keyEvent.widget = browser;
                            keyEvent.type = DWT.KeyDown;
                            keyEvent.keyCode = lastKeyCode;
                            keyEvent.stateMask = (aAltKey !is 0 ? DWT.ALT : 0) | (aCtrlKey !is 0? DWT.CTRL : 0) | (aShiftKey !is 0? DWT.SHIFT : 0) | (aMetaKey !is 0? DWT.COMMAND : 0);
                            browser.notifyListeners (keyEvent.type, keyEvent);
                            if (!keyEvent.doit) {
                                event.PreventDefault ();
                            }
                        }
                    }
                }
            }
        }

        domKeyEvent.Release ();
        return XPCOM.NS_OK;
    }

    if (XPCOM.DOMEVENT_KEYPRESS.equals (typeString)) {
        /*
        * if keydown could not determine a keycode for this key then it's a
        * key for which key events are not sent (eg.- the Windows key)
        */
        if (lastKeyCode is 0) return XPCOM.NS_OK;

        /*
        * On linux only, unexpected keypress events are received for some
        * modifier keys.  The workaround is to ignore these events since
        * KeyDown events are sent for these keys in the keydown listener.  
        */
        switch (lastKeyCode) {
            case DWT.CAPS_LOCK:
            case DWT.NUM_LOCK:
            case DWT.SCROLL_LOCK: return XPCOM.NS_OK;
            default: break;
        }

        //int /*long*/[] result = new int /*long*/[1];
        nsIDOMKeyEvent domKeyEvent;
        rc = event.QueryInterface (&nsIDOMKeyEvent.IID, cast(void**)&domKeyEvent);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        if (domKeyEvent is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
        //nsIDOMKeyEvent domKeyEvent = new nsIDOMKeyEvent (result[0]);
        //result[0] = 0;

        PRBool aAltKey, aCtrlKey, aShiftKey, aMetaKey; /* PRBool */
        rc = domKeyEvent.GetAltKey (&aAltKey);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        rc = domKeyEvent.GetCtrlKey (&aCtrlKey);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        rc = domKeyEvent.GetShiftKey (&aShiftKey);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        rc = domKeyEvent.GetMetaKey (&aMetaKey);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        domKeyEvent.Release ();

        PRUint32 aCharCode; /* PRUint32 */
        rc = domKeyEvent.GetCharCode (&aCharCode);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        lastCharCode = aCharCode;
        if (lastCharCode is 0) {
            switch (lastKeyCode) {
                case DWT.TAB: lastCharCode = DWT.TAB; break;
                case DWT.CR: lastCharCode = DWT.CR; break;
                case DWT.BS: lastCharCode = DWT.BS; break;
                case DWT.ESC: lastCharCode = DWT.ESC; break;
                case DWT.DEL: lastCharCode = DWT.DEL; break;
                default: break;
            }
        }
        if (aCtrlKey !is 0 && (0 <= lastCharCode && lastCharCode <= 0x7F)) {
            if ('a'  <= lastCharCode && lastCharCode <= 'z') lastCharCode -= 'a' - 'A';
            if (64 <= lastCharCode && lastCharCode <= 95) lastCharCode -= 64;
        }

        Event keyEvent = new Event ();
        keyEvent.widget = browser;
        keyEvent.type = DWT.KeyDown;
        keyEvent.keyCode = lastKeyCode;
        keyEvent.character = cast(wchar)lastCharCode;
        keyEvent.stateMask = (aAltKey !is 0 ? DWT.ALT : 0) | (aCtrlKey !is 0 ? DWT.CTRL : 0) | (aShiftKey !is 0 ? DWT.SHIFT : 0) | (aMetaKey !is 0 ? DWT.COMMAND : 0);
        browser.notifyListeners (keyEvent.type, keyEvent);
        if (!keyEvent.doit) {
            event.PreventDefault ();
        }
        return XPCOM.NS_OK;
    }

    if (XPCOM.DOMEVENT_KEYUP.equals (typeString)) {
        //int /*long*/[] result = new int /*long*/[1];
        nsIDOMKeyEvent domKeyEvent;
        rc = event.QueryInterface (&nsIDOMKeyEvent.IID, cast(void**)&domKeyEvent);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        if (domKeyEvent is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
        //nsIDOMKeyEvent domKeyEvent = new nsIDOMKeyEvent (result[0]);
        //result[0] = 0;

        PRUint32 aKeyCode; /* PRUint32 */
        rc = domKeyEvent.GetKeyCode (&aKeyCode);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        int keyCode = super.translateKey (aKeyCode);
        if (keyCode is 0) {
            /* indicates a key for which key events are not sent */
            domKeyEvent.Release ();
            return XPCOM.NS_OK;
        }
        if (keyCode !is lastKeyCode) {
            /* keyup does not correspond to the last keydown */
            lastKeyCode = keyCode;
            lastCharCode = 0;
        }

        PRBool aAltKey, aCtrlKey, aShiftKey, aMetaKey; /* PRBool */
        rc = domKeyEvent.GetAltKey (&aAltKey);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        rc = domKeyEvent.GetCtrlKey (&aCtrlKey);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        rc = domKeyEvent.GetShiftKey (&aShiftKey);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        rc = domKeyEvent.GetMetaKey (&aMetaKey);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        domKeyEvent.Release ();

        Event keyEvent = new Event ();
        keyEvent.widget = browser;
        keyEvent.type = DWT.KeyUp;
        keyEvent.keyCode = lastKeyCode;
        keyEvent.character = cast(wchar)lastCharCode;
        keyEvent.stateMask = (aAltKey !is 0 ? DWT.ALT : 0) | (aCtrlKey !is 0 ? DWT.CTRL : 0) | (aShiftKey !is 0 ? DWT.SHIFT : 0) | (aMetaKey !is 0 ? DWT.COMMAND : 0);
        switch (lastKeyCode) {
            case DWT.SHIFT:
            case DWT.CONTROL:
            case DWT.ALT:
            case DWT.COMMAND: {
                keyEvent.stateMask |= lastKeyCode;
            }
            default: break;
        }
        browser.notifyListeners (keyEvent.type, keyEvent);
        if (!keyEvent.doit) {
            event.PreventDefault ();
        }
        lastKeyCode = lastCharCode = 0;
        return XPCOM.NS_OK;
    }

    /* mouse event */

    //int /*long*/[] result = new int /*long*/[1];
    nsIDOMMouseEvent domMouseEvent;
    rc = event.QueryInterface (&nsIDOMMouseEvent.IID, cast(void**)&domMouseEvent);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (domMouseEvent is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
    //nsIDOMMouseEvent domMouseEvent = new nsIDOMMouseEvent (result[0]);
    //result[0] = 0;

    /*
     * MouseOver and MouseOut events are fired any time the mouse enters or exits
     * any element within the Browser.  To ensure that DWT events are only
     * fired for mouse movements into or out of the Browser, do not fire an
     * event if the element being exited (on MouseOver) or entered (on MouseExit)
     * is within the Browser.
     */
    if (XPCOM.DOMEVENT_MOUSEOVER.equals (typeString) || XPCOM.DOMEVENT_MOUSEOUT.equals (typeString)) {
        nsIDOMEventTarget eventTarget;
        rc = domMouseEvent.GetRelatedTarget (&eventTarget);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        if (eventTarget !is null) {
            domMouseEvent.Release ();
            return XPCOM.NS_OK;
        }
    }

    PRInt32 aClientX, aClientY, aDetail; /* PRInt32 */
    rc = domMouseEvent.GetClientX (&aClientX);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    rc = domMouseEvent.GetClientY (&aClientY);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    rc = domMouseEvent.GetDetail (&aDetail);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    PRUint16 aButton; /* PRUint16 */
    rc = domMouseEvent.GetButton (&aButton);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    PRBool aAltKey, aCtrlKey, aShiftKey, aMetaKey; /* PRBool */
    rc = domMouseEvent.GetAltKey (&aAltKey);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    rc = domMouseEvent.GetCtrlKey (&aCtrlKey);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    rc = domMouseEvent.GetShiftKey (&aShiftKey);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    rc = domMouseEvent.GetMetaKey (&aMetaKey);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    domMouseEvent.Release ();

    Event mouseEvent = new Event ();
    mouseEvent.widget = browser;
    mouseEvent.x = aClientX; mouseEvent.y = aClientY;
    mouseEvent.stateMask = (aAltKey !is 0 ? DWT.ALT : 0) | (aCtrlKey !is 0 ? DWT.CTRL : 0) | (aShiftKey !is 0 ? DWT.SHIFT : 0) | (aMetaKey !is 0 ? DWT.COMMAND : 0);

    if (XPCOM.DOMEVENT_MOUSEDOWN.equals (typeString)) {
        mozDelegate.handleMouseDown ();
        mouseEvent.type = DWT.MouseDown;
        mouseEvent.button = aButton + 1;
        mouseEvent.count = aDetail;
    } else if (XPCOM.DOMEVENT_MOUSEUP.equals (typeString)) {
        /*
         * Bug on OSX.  For some reason multiple mouseup events come from the DOM
         * when button 3 is released on OSX.  The first of these events has a count
         * detail and the others do not.  The workaround is to not fire received
         * button 3 mouseup events that do not have a count since mouse events
         * without a click count are not valid.
         */
        int button = aButton + 1;
        int count = aDetail;
        if (count is 0 && button is 3) return XPCOM.NS_OK;
        mouseEvent.type = DWT.MouseUp;
        mouseEvent.button = button;
        mouseEvent.count = count;
    } else if (XPCOM.DOMEVENT_MOUSEMOVE.equals (typeString)) {
        mouseEvent.type = DWT.MouseMove;
    } else if (XPCOM.DOMEVENT_MOUSEWHEEL.equals (typeString)) {
        mouseEvent.type = DWT.MouseWheel;
        mouseEvent.count = -aDetail;
    } else if (XPCOM.DOMEVENT_MOUSEOVER.equals (typeString)) {
        mouseEvent.type = DWT.MouseEnter;
    } else if (XPCOM.DOMEVENT_MOUSEOUT.equals (typeString)) {
        mouseEvent.type = DWT.MouseExit;
    } else if (XPCOM.DOMEVENT_MOUSEDRAG.equals (typeString)) {
        mouseEvent.type = DWT.DragDetect;
        mouseEvent.button = aButton + 1;
        switch (mouseEvent.button) {
            case 1: mouseEvent.stateMask |= DWT.BUTTON1; break;
            case 2: mouseEvent.stateMask |= DWT.BUTTON2; break;
            case 3: mouseEvent.stateMask |= DWT.BUTTON3; break;
            case 4: mouseEvent.stateMask |= DWT.BUTTON4; break;
            case 5: mouseEvent.stateMask |= DWT.BUTTON5; break;
            default: break;
        }
    }

    browser.notifyListeners (mouseEvent.type, mouseEvent);
    if (aDetail is 2 && XPCOM.DOMEVENT_MOUSEDOWN.equals (typeString)) {
        mouseEvent = new Event ();
        mouseEvent.widget = browser;
        mouseEvent.x = aClientX; mouseEvent.y = aClientY;
        mouseEvent.stateMask = (aAltKey !is 0 ? DWT.ALT : 0) | (aCtrlKey !is 0 ? DWT.CTRL : 0) | (aShiftKey !is 0 ? DWT.SHIFT : 0) | (aMetaKey !is 0 ? DWT.COMMAND : 0);
        mouseEvent.type = DWT.MouseDoubleClick;
        mouseEvent.button = aButton + 1;
        mouseEvent.count = aDetail;
        browser.notifyListeners (mouseEvent.type, mouseEvent);  
    }
    return XPCOM.NS_OK;
}
}
