/*******************************************************************************
 * Copyright (c) 2000, 2009 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *
 * Port to the D programming language:
 *     Jacob Carlborg <doob@me.com>
 *******************************************************************************/
module dwt.browser.Safari;

import dwt.dwthelper.utils;

import java.util.Enumeration;
import dwt.graphics.Point;
import dwt.graphics.Rectangle;
import dwt.internal.C;
import dwt.internal.Callback;
import dwt.internal.Compatibility;
import dwt.internal.cocoa.DOMDocument;
import dwt.internal.cocoa.DOMKeyboardEvent;







import dwt.browser.Browser;
import dwt.browser.LocationEvent;
import dwt.browser.ProgressEvent;
import dwt.browser.ProgressListener;
import dwt.browser.StatusTextEvent;
import dwt.browser.TitleEvent;
import dwt.browser.TitleListener;
import dwt.browser.WebBrowser;
import dwt.browser.WindowEvent;
import Carbon = dwt.internal.c.Carbon;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

class Safari : WebBrowser {
    WebView webView;
    WebPreferences preferences;
    SWTWebViewDelegate delegate_;
    bool changingLocation;
    String lastHoveredLinkURL, lastNavigateURL;
    String html;
    objc.id identifier;
    int resourceCount;
    String url = ""; //$NON-NLS-1$
    Point location;
    Point size;
    bool statusBar = true, toolBar = true, ignoreDispose;
    int lastMouseMoveX, lastMouseMoveY;
    //TEMPORARY CODE
//  bool doit;

    static int /*long*/ delegateClass;
    static bool Initialized;

    static const int MIN_SIZE = 16;
    static const int MAX_PROGRESS = 100;
    static const String WebElementLinkURLKey = "WebElementLinkURL"; //$NON-NLS-1$
    static const String AGENT_STRING = "Safari/unknown"; //$NON-NLS-1$
    static const String URI_FROMMEMORY = "file:///"; //$NON-NLS-1$
    static const String PROTOCOL_FILE = "file://"; //$NON-NLS-1$
    static const String PROTOCOL_HTTP = "http://"; //$NON-NLS-1$
    static const String ABOUT_BLANK = "about:blank"; //$NON-NLS-1$
    static const String HEADER_SETCOOKIE = "Set-Cookie"; //$NON-NLS-1$
    static const String ADD_WIDGET_KEY = "dwt.internal.addWidget"; //$NON-NLS-1$
    static const String SAFARI_EVENTS_FIX_KEY = "dwt.internal.safariEventsFix"; //$NON-NLS-1$
    //static const String DWT_OBJECT = "SWT_OBJECT"; //$NON-NLS-1$
    static const byte[] DWT_OBJECT = ['S', 'W', 'T', '_', 'O', 'B', 'J', 'E', 'C', 'T', '\0'];

    /* event strings */
    static const String DOMEVENT_KEYUP = "keyup"; //$NON-NLS-1$
    static const String DOMEVENT_KEYDOWN = "keydown"; //$NON-NLS-1$
    static const String DOMEVENT_MOUSEDOWN = "mousedown"; //$NON-NLS-1$
    static const String DOMEVENT_MOUSEUP = "mouseup"; //$NON-NLS-1$
    static const String DOMEVENT_MOUSEMOVE = "mousemove"; //$NON-NLS-1$
    static const String DOMEVENT_MOUSEWHEEL = "mousewheel"; //$NON-NLS-1$

    static this () {
        NativeClearSessions = new class () Runnable {
            public void run() {
                NSHTTPCookieStorage storage = NSHTTPCookieStorage.sharedHTTPCookieStorage();
                NSArray cookies = storage.cookies();
                NSUInteger count = cookies.count();
                for (NSUInteger i = 0; i < count; i++) {
                    NSHTTPCookie cookie = new NSHTTPCookie(cookies.objectAtIndex(i));
                    if (cookie.isSessionOnly()) {
                        storage.deleteCookie(cookie);
                    }
                }
            }
        };

        NativeGetCookie = new Runnable () {
            public void run () {
                NSHTTPCookieStorage storage = NSHTTPCookieStorage.sharedHTTPCookieStorage ();
                NSURL url = NSURL.URLWithString (NSString.stringWith (CookieUrl));
                NSArray cookies = storage.cookiesForURL (url);
                int count = (int)/*64*/cookies.count ();
                if (count is 0) return;

                NSString name = NSString.stringWith (CookieName);
                for (int i = 0; i < count; i++) {
                    NSHTTPCookie current = new NSHTTPCookie (cookies.objectAtIndex (i));
                    if (current.name ().compare (name) is OS.NSOrderedSame) {
                        CookieValue = current.value ().getString ();
                        return;
                    }
                }
            }
        };

        NativeSetCookie = new Runnable () {
            public void run () {
                NSURL url = NSURL.URLWithString (NSString.stringWith (CookieUrl));
                NSMutableDictionary headers = NSMutableDictionary.dictionaryWithCapacity (1);
                headers.setValue (NSString.stringWith (CookieValue), NSString.stringWith (HEADER_SETCOOKIE));
                NSArray cookies = NSHTTPCookie.cookiesWithResponseHeaderFields (headers, url);
                if (cookies.count () is 0) return;
                NSHTTPCookieStorage storage = NSHTTPCookieStorage.sharedHTTPCookieStorage ();
                NSHTTPCookie cookie = new NSHTTPCookie (cookies.objectAtIndex (0));
                storage.setCookie (cookie);
                CookieResult = true;
            }
        };
    }

public void create (Composite parent, int style) {
    if (delegateClass is 0) {
    if (OS.objc_lookUpClass(className) is null) {
        Class safariClass = this.classinfo;
        objc.IMP proc3; = cast(objc.IMP) &browserProc3;
        objc.IMP proc4; = cast(objc.IMP) &browserProc4;
        objc.IMP proc5; = cast(objc.IMP) &browserProc5;
        objc.IMP proc6; = cast(objc.IMP) &browserProc6;
        objc.IMP proc7; = cast(objc.IMP) &browserProc7;
        objc.IMP setFrameProc = OS.CALLBACK_webView_setFrame(proc4);
        String className = "SWTWebViewDelegate"; //$NON-NLS-1$
        byte[] types = {'*','\0'};
        size_t size = C.PTR_SIZEOF, align_ = C.PTR_SIZEOF is 4 ? 2 : 3;
        delegateClass = OS.objc_allocateClassPair(cast(objc.Class) OS.class_NSObject, className, 0);
        OS.class_addIvar(delegateClass, DWT_OBJECT, size, cast(byte)align_, types);
        OS.class_addMethod(delegateClass, OS.sel_webView_didChangeLocationWithinPageForFrame_, proc4, "@:@@"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_webView_didFailProvisionalLoadWithError_forFrame_, proc5, "@:@@@"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_webView_didFinishLoadForFrame_, proc4, "@:@@"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_webView_didReceiveTitle_forFrame_, proc5, "@:@@@"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_webView_didStartProvisionalLoadForFrame_, proc4, "@:@@"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_webView_didCommitLoadForFrame_, proc4, "@:@@"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_webView_resource_didFinishLoadingFromDataSource_, proc5, "@:@@@"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_webView_resource_didReceiveAuthenticationChallenge_fromDataSource_, proc6, "@:@@@@"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_webView_resource_didFailLoadingWithError_fromDataSource_, proc6, "@:@@@@"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_webView_identifierForInitialRequest_fromDataSource_, proc5, "@:@@@"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_webView_resource_willSendRequest_redirectResponse_fromDataSource_, proc7, "@:@@@@@"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_webView_createWebViewWithRequest_, proc4, "@:@@"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_webViewShow_, proc3, "@:@"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_webViewClose_, proc3, "@:@"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_webView_contextMenuItemsForElement_defaultMenuItems_, proc5, "@:@@@"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_webView_setStatusBarVisible_, proc4, "@:@B"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_webView_setResizable_, proc4, "@:@B"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_webView_setToolbarsVisible_, proc4, "@:@B"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_webView_setStatusText_, proc4, "@:@@"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_webViewFocus_, proc3, "@:@"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_webViewUnfocus_, proc3, "@:@"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_webView_runJavaScriptAlertPanelWithMessage_, proc4, "@:@@"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_webView_runJavaScriptConfirmPanelWithMessage_, proc4, "@:@@"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_webView_runOpenPanelForFileButtonWithResultListener_, proc4, "@:@@"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_webView_mouseDidMoveOverElement_modifierFlags_, proc5, "@:@@I"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_webView_printFrameView_, proc4, "@:@@"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_webView_decidePolicyForMIMEType_request_frame_decisionListener_, proc7, "@:@@@@@"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_webView_decidePolicyForNavigationAction_request_frame_decisionListener_, proc7, "@:@@@@@"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_webView_decidePolicyForNewWindowAction_request_newFrameName_decisionListener_, proc7, "@:@@@@@"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_webView_unableToImplementPolicyWithError_frame_, proc5, "@:@@@"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_download_decideDestinationWithSuggestedFilename_, proc4, "@:@@"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_handleEvent_, proc3, "@:@"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_webView_setFrame_, setFrameProc, "@:@{NSRect}"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_webView_windowScriptObjectAvailable_, proc4, "@:@@"); //$NON-NLS-1$
        OS.class_addMethod(delegateClass, OS.sel_callJava, proc5, "@:@@@"); //$NON-NLS-1$
        OS.objc_registerClassPair(delegateClass);

        int /*long*/ metaClass = OS.objc_getMetaClass (className);
        OS.class_addMethod(metaClass, OS.sel_isSelectorExcludedFromWebScript_, proc3, "@:@"); //$NON-NLS-1$
        OS.class_addMethod(metaClass, OS.sel_webScriptNameForSelector_, proc3, "@:@"); //$NON-NLS-1$
        OS.objc_registerClassPair(delegateClass);

        int /*long*/ metaClass = OS.objc_getMetaClass (className);
        OS.class_addMethod(metaClass, OS.sel_isSelectorExcludedFromWebScript_, proc3, "@:@"); //$NON-NLS-1$
        OS.class_addMethod(metaClass, OS.sel_webScriptNameForSelector_, proc3, "@:@"); //$NON-NLS-1$
    }

    /*
    * Override the default event mechanism to not send key events so
    * that the browser can send them by listening to the DOM instead.
    */
    browser.setData(new ArrayWrapperString(SAFARI_EVENTS_FIX_KEY));

    WebView webView = cast(WebView)(new WebView()).alloc();
    if (webView is null) DWT.error(DWT.ERROR_NO_HANDLES);
    webView.initWithFrame(browser.view.frame(), null, null);
    webView.setAutoresizingMask(OS.NSViewWidthSizable | OS.NSViewHeightSizable);
    final SWTWebViewDelegate delegate_ = cast(SWTWebViewDelegate)(new SWTWebViewDelegate()).alloc().init();
    Display display = browser.getDisplay();
    display.setData(ADD_WIDGET_KEY, new ArrayWrapperObject([cast(Object) delegate_, browser]));
    this.delegate_ = delegate_;
    this.webView = webView;
    browser.view.addSubview(webView);

    Listener listener = new class () Listener {
        public void handleEvent(Event e) {
            switch (e.type) {
                case DWT.FocusIn:
                    this.outer.webView.window().makeFirstResponder(this.outer.webView);
                    break;
                case DWT.Dispose: {
                    /* make this handler run after other dispose listeners */
                    if (ignoreDispose) {
                        ignoreDispose = false;
                        break;
                    }
                    ignoreDispose = true;
                    browser.notifyListeners (e.type, e);
                    e.type = DWT.NONE;

                    e.display.setData(ADD_WIDGET_KEY, new ArrayWrapperObject([delegate_, null]));

                    this.outer.webView.setFrameLoadDelegate(null);
                    this.outer.webView.setResourceLoadDelegate(null);
                    this.outer.webView.setUIDelegate(null);
                    this.outer.webView.setPolicyDelegate(null);
                    this.outer.webView.setDownloadDelegate(null);

                    this.outer.webView.release();
                    this.outer.webView = null;
                    this.outer.delegate_.release();
                    this.outer.delegate_ = null;
                    html = null;
                    lastHoveredLinkURL = lastNavigateURL = null;

                    Enumeration elements = functions.elements ();
                    while (elements.hasMoreElements ()) {
                        ((BrowserFunction)elements.nextElement ()).dispose (false);
                    }
                    functions = null;

                    if (preferences !is null) preferences.release ();
                    preferences = null;
                    break;
                }
                default:
            }
        }
    };
    browser.addListener(DWT.Dispose, listener);
    /* Needed to be able to tab into the browser */
    browser.addListener(DWT.KeyDown, listener);
    browser.addListener(DWT.FocusIn, listener);

    webView.setFrameLoadDelegate(delegate_);
    webView.setResourceLoadDelegate(delegate_);
    webView.setUIDelegate(delegate_);
    webView.setPolicyDelegate(delegate_);
    webView.setDownloadDelegate(delegate_);
    webView.setApplicationNameForUserAgent(NSString.stringWith(AGENT_STRING));

    if (!Initialized) {
        Initialized = true;
        /* disable applets */
        WebPreferences.standardPreferences().setJavaEnabled(false);
    }
}

public bool back() {
    html = null;
    return webView.goBack();
}

static objc.id browserProc3(objc.id id, objc.SEL sel, objc.id arg0) {
    if (id is delegateClass) {
        if (sel is OS.sel_isSelectorExcludedFromWebScript_) {
            return isSelectorExcludedFromWebScript (arg0) ? 1 : 0;
        } else if (sel is OS.sel_webScriptNameForSelector_) {
            return webScriptNameForSelector (arg0);
        }
    }

    Widget widget = Display.getCurrent().findWidget(id);
    if (widget is null) return null;
    Safari safari = cast(Safari)(cast(Browser)widget).webBrowser;
    if (sel is OS.sel_webViewShow_) {
        safari.webViewShow(arg0);
    } else if (sel is OS.sel_webViewClose_) {
        safari.webViewClose(arg0);
    } else if (sel is OS.sel_webViewFocus_) {
        safari.webViewFocus(arg0);
    } else if (sel is OS.sel_webViewUnfocus_) {
        safari.webViewUnfocus(arg0);
    } else if (sel is OS.sel_handleEvent_) {
        safari.handleEvent(arg0);
    }
    return null;
}

static objc.id browserProc4(objc.id id, objc.SEL sel, objc.id arg0, objc.id arg1) {
    Widget widget = Display.getCurrent().findWidget(id);
    if (widget is null) return null;
    Safari safari = cast(Safari)(cast(Browser)widget).webBrowser;
    if (sel is OS.sel_webView_didChangeLocationWithinPageForFrame_) {
        safari.webView_didChangeLocationWithinPageForFrame(arg0, arg1);
    } else if (sel is OS.sel_webView_didFinishLoadForFrame_) {
        safari.webView_didFinishLoadForFrame(arg0, arg1);
    } else if (sel is OS.sel_webView_didStartProvisionalLoadForFrame_) {
        safari.webView_didStartProvisionalLoadForFrame(arg0, arg1);
    } else if (sel is OS.sel_webView_didCommitLoadForFrame_) {
        safari.webView_didCommitLoadForFrame(arg0, arg1);
    } else if (sel is OS.sel_webView_setFrame_) {
        safari.webView_setFrame(arg0, arg1);
    } else if (sel is OS.sel_webView_createWebViewWithRequest_) {
        return safari.webView_createWebViewWithRequest(arg0, arg1);
    } else if (sel is OS.sel_webView_setStatusBarVisible_) {
        safari.webView_setStatusBarVisible(arg0, arg1 !is null);
    } else if (sel is OS.sel_webView_setResizable_) {
        safari.webView_setResizable(arg0, arg1 !is null);
    } else if (sel is OS.sel_webView_setStatusText_) {
        safari.webView_setStatusText(arg0, arg1);
    } else if (sel is OS.sel_webView_setToolbarsVisible_) {
        safari.webView_setToolbarsVisible(arg0, arg1 !is null);
    } else if (sel is OS.sel_webView_runJavaScriptAlertPanelWithMessage_) {
        safari.webView_runJavaScriptAlertPanelWithMessage(arg0, arg1);
    } else if (sel is OS.sel_webView_runJavaScriptConfirmPanelWithMessage_) {
        return safari.webView_runJavaScriptConfirmPanelWithMessage(arg0, arg1);
    } else if (sel is OS.sel_webView_runOpenPanelForFileButtonWithResultListener_) {
        safari.webView_runOpenPanelForFileButtonWithResultListener(arg0, arg1);
    } else if (sel is OS.sel_download_decideDestinationWithSuggestedFilename_) {
        safari.download_decideDestinationWithSuggestedFilename(arg0, arg1);
    } else if (sel is OS.sel_webView_printFrameView_) {
        safari.webView_printFrameView(arg0, arg1);
    } else if (sel is OS.sel_webView_windowScriptObjectAvailable_) {
        safari.webView_windowScriptObjectAvailable (arg0, arg1);
    }
    return null;
}

static objc.id browserProc5(objc.id id, objc.SEL sel, objc.id arg0, objc.id arg1, objc.id arg2) {
    Widget widget = Display.getCurrent().findWidget(id);
    if (widget is null) return null;
    Safari safari = cast(Safari)(cast(Browser)widget).webBrowser;
    if (sel is OS.sel_webView_didFailProvisionalLoadWithError_forFrame_) {
        safari.webView_didFailProvisionalLoadWithError_forFrame(arg0, arg1, arg2);
    } else if (sel is OS.sel_webView_didReceiveTitle_forFrame_) {
        safari.webView_didReceiveTitle_forFrame(arg0, arg1, arg2);
    } else if (sel is OS.sel_webView_resource_didFinishLoadingFromDataSource_) {
        safari.webView_resource_didFinishLoadingFromDataSource(arg0, arg1, arg2);
    } else if (sel is OS.sel_webView_identifierForInitialRequest_fromDataSource_) {
        return safari.webView_identifierForInitialRequest_fromDataSource(arg0, arg1, arg2);
    } else if (sel is OS.sel_webView_contextMenuItemsForElement_defaultMenuItems_) {
        return safari.webView_contextMenuItemsForElement_defaultMenuItems(arg0, arg1, arg2);
    } else if (sel is OS.sel_webView_mouseDidMoveOverElement_modifierFlags_) {
        safari.webView_mouseDidMoveOverElement_modifierFlags(arg0, arg1, arg2);
    } else if (sel is OS.sel_webView_unableToImplementPolicyWithError_frame_) {
        safari.webView_unableToImplementPolicyWithError_frame(arg0, arg1, arg2);
    } else if (sel is OS.sel_callJava) {
        id result = safari.callJava (arg0, arg1, arg2);
        return result is null ? 0 : result.id;
    }
    return null;
}

static objc.id browserProc6(objc.id id, objc.SEL sel, objc.id arg0, objc.id arg1, objc.id arg2, objc.id arg3) {
    Widget widget = Display.getCurrent().findWidget(id);
    if (widget is null) return null;
    Safari safari = cast(Safari)(cast(Browser)widget).webBrowser;
    if (sel is OS.sel_webView_resource_didFailLoadingWithError_fromDataSource_) {
        safari.webView_resource_didFailLoadingWithError_fromDataSource(arg0, arg1, arg2, arg3);
    } else if (sel is OS.sel_webView_resource_didReceiveAuthenticationChallenge_fromDataSource_) {
        safari.webView_resource_didReceiveAuthenticationChallenge_fromDataSource(arg0, arg1, arg2, arg3);
    }
    return null;
}

static objc.id browserProc7(objc.id id, objc.SEL sel, objc.id arg0, objc.id arg1, objc.id arg2, objc.id arg3, objc.id arg4) {
    Widget widget = Display.getCurrent().findWidget(id);
    if (widget is null) return null;
    Safari safari = cast(Safari)(cast(Browser)widget).webBrowser;
    if (sel is OS.sel_webView_resource_willSendRequest_redirectResponse_fromDataSource_) {
        return safari.webView_resource_willSendRequest_redirectResponse_fromDataSource(arg0, arg1, arg2, arg3, arg4);
    } else if (sel is OS.sel_webView_decidePolicyForMIMEType_request_frame_decisionListener_) {
        safari.webView_decidePolicyForMIMEType_request_frame_decisionListener(arg0, arg1, arg2, arg3, arg4);
    } else if (sel is OS.sel_webView_decidePolicyForNavigationAction_request_frame_decisionListener_) {
        safari.webView_decidePolicyForNavigationAction_request_frame_decisionListener(arg0, arg1, arg2, arg3, arg4);
    } else if (sel is OS.sel_webView_decidePolicyForNewWindowAction_request_newFrameName_decisionListener_) {
        safari.webView_decidePolicyForNewWindowAction_request_newFrameName_decisionListener(arg0, arg1, arg2, arg3, arg4);
    }
    return null;
}

static bool isSelectorExcludedFromWebScript (int /*long*/ aSelector) {
    return aSelector !is OS.sel_callJava;
}

static int /*long*/ webScriptNameForSelector (int /*long*/ aSelector) {
    if (aSelector is OS.sel_callJava) {
        return NSString.stringWith ("callJava").id; //$NON-NLS-1$
    }
    return 0;
}

static bool isSelectorExcludedFromWebScript (int /*long*/ aSelector) {
    return aSelector !is OS.sel_callJava;
}

static int /*long*/ webScriptNameForSelector (int /*long*/ aSelector) {
    if (aSelector is OS.sel_callJava) {
        return NSString.stringWith ("callJava").id; //$NON-NLS-1$
    }
    return 0;
}

public bool execute (String script) {
    return webView.stringByEvaluatingJavaScriptFromString (NSString.stringWith (script)) !is null;
}

public bool forward () {
    html = null;
    return webView.goForward();
}

public String getBrowserType () {
    return "safari"; //$NON-NLS-1$
}

public String getText() {
    WebFrame mainFrame = webView.mainFrame();
    WebDataSource dataSource = mainFrame.dataSource();
    if (dataSource is null) return "";  //$NON-NLS-1$
    WebDocumentRepresentation representation = dataSource.representation();
    if (representation is null) return "";  //$NON-NLS-1$
    NSString source = representation.documentSource();
    if (source is null) return "";  //$NON-NLS-1$
    return source.getString();
}

public String getUrl() {
    return url;
}

public bool isBackEnabled() {
    return webView.canGoBack();
}

public bool isForwardEnabled() {
    return webView.canGoForward();
}

public void refresh() {
    webView.reload(null);
}

public bool setText(String html) {
    /*
    * Bug in Safari.  The web view segment faults in some circumstances
    * when the text changes during the location changing callback.  The
    * fix is to defer the work until the callback is done.
    */
    if (changingLocation) {
        this.html = html;
    } else {
        _setText(html);
    }
    return true;
}

void _setText(String html) {
    NSString string = NSString.stringWith(html);
    NSString URLString = NSString.stringWith(URI_FROMMEMORY);
    NSURL URL = NSURL.URLWithString(URLString);
    WebFrame mainFrame = webView.mainFrame();
    mainFrame.loadHTMLString(string, URL);
}

public bool setUrl(String url) {
    html = null;

    if (url.indexOf('/') is 0) {
        url = PROTOCOL_FILE ~ url;
    } else if (url.indexOf(':') is -1) {
        url = PROTOCOL_HTTP ~ url;
    }

    NSString str = NSString.stringWith(url);
    NSString unescapedStr = NSString.stringWith("%#"); //$NON-NLS-1$
    Carbon.CFStringRef ptr = OS.CFURLCreateStringByAddingPercentEscapes(null, cast(Carbon.CFStringRef) str.id, cast(Carbon.CFStringRef) unescapedStr.id, null, OS.kCFStringEncodingUTF8);
    NSString escapedString = new NSString(cast(objc.id) ptr);
    NSURL inURL = NSURL.URLWithString(escapedString);
    OS.CFRelease(ptr);
    NSURLRequest request = NSURLRequest.requestWithURL(inURL);
    WebFrame mainFrame = webView.mainFrame();
    mainFrame.loadRequest(request);
    return true;
}

public void stop() {
    html = null;
    webView.stopLoading(null);
}

/* WebFrameLoadDelegate */

void webView_didChangeLocationWithinPageForFrame(objc.id sender, objc.id frameID) {
    WebFrame frame = new WebFrame(frameID);
    WebDataSource dataSource = frame.dataSource();
    NSURLRequest request = dataSource.request();
    NSURL url = request.URL();
    NSString s = url.absoluteString();
    NSUInteger length = s.length();
    if (length is 0) return;
    String url2 = s.getString();
    /*
     * If the URI indicates that the page is being rendered from memory
     * (via setText()) then set it to about:blank to be consistent with IE.
     */
    if (url2.equals (URI_FROMMEMORY)) url2 = ABOUT_BLANK;

    final Display display = browser.getDisplay();
    bool top = frameID is webView.mainFrame().id;
    if (top) {
        StatusTextEvent statusText = new StatusTextEvent(browser);
        statusText.display = display;
        statusText.widget = browser;
        statusText.text = url2;
        for (int i = 0; i < statusTextListeners.length; i++) {
            statusTextListeners[i].changed(statusText);
        }
    }

    LocationEvent location = new LocationEvent(browser);
    location.display = display;
    location.widget = browser;
    location.location = url2;
    location.top = top;
    for (int i = 0; i < locationListeners.length; i++) {
        locationListeners[i].changed(location);
    }
}

void webView_didFailProvisionalLoadWithError_forFrame(objc.id sender, objc.id error, objc.id frame) {
    if (frame is webView.mainFrame().id) {
        /*
        * Feature on Safari.  The identifier is used here as a marker for the events
        * related to the top frame and the URL changes related to that top frame as
        * they should appear on the location bar of a browser.  It is expected to reset
        * the identifier to 0 when the event didFinishLoadingFromDataSource related to
        * the identifierForInitialRequest event is received.  However, Safari fires
        * the didFinishLoadingFromDataSource event before the entire content of the
        * top frame is loaded.  It is possible to receive multiple willSendRequest
        * events in this interval, causing the Browser widget to send unwanted
        * Location.changing events.  For this reason, the identifier is reset to 0
        * when the top frame has either finished loading (didFinishLoadForFrame
        * event) or failed (didFailProvisionalLoadWithError).
        */
        identifier = null;
    }

    NSError nserror = new NSError(error);
    NSInteger errorCode = nserror.code();
    if (errorCode <= OS.NSURLErrorBadURL) {
        NSString description = nserror.localizedDescription();
        if (description !is null) {
            String descriptionString = description.getString();
            String urlString = null;
            NSDictionary info = nserror.userInfo();
            if (info !is null) {
                NSString key = new NSString(OS.NSErrorFailingURLStringKey_);
                id id = info.valueForKey(key);
                if (id !is null) {
                    NSString url = new NSString(id);
                    urlString = url.getString();
                }
            }
            String message = urlString !is null ? urlString ~ "\n\n" : ""; //$NON-NLS-1$ //$NON-NLS-2$
            message ~= Compatibility.getMessage ("DWT_Page_Load_Failed", [new ArrayWrapperString(descriptionString)]); //$NON-NLS-1$
            MessageBox messageBox = new MessageBox(browser.getShell(), DWT.OK | DWT.ICON_ERROR);
            messageBox.setMessage(message);
            messageBox.open();
        }
    }
}

void webView_didFinishLoadForFrame(objc.id sender, objc.id frameID) {
    hookDOMMouseListeners(frameID);
    if (frameID is webView.mainFrame().id) {
        hookDOMKeyListeners(frameID);

        final Display display = browser.getDisplay();
        /*
        * To be consistent with other platforms a title event should be fired when a
        * page has completed loading.  A page with a <title> tag will do this
        * automatically when the didReceiveTitle callback is received.  However a page
        * without a <title> tag will not do this by default, so fire the event
        * here with the page's url as the title.
        */
        WebFrame frame = new WebFrame(frameID);
        WebDataSource dataSource = frame.dataSource();
        if (dataSource !is null) {
            NSString title = dataSource.pageTitle();
            if (title is null) {    /* page has no title */
                final TitleEvent newEvent = new TitleEvent(browser);
                newEvent.display = display;
                newEvent.widget = browser;
                newEvent.title = url;
                for (int i = 0; i < titleListeners.length; i++) {
                    final TitleListener listener = titleListeners[i];
                    /*
                    * Note on WebKit.  Running the event loop from a Browser
                    * delegate callback breaks the WebKit (stop loading or
                    * crash).  The workaround is to invoke Display.asyncExec()
                    * so that the Browser does not crash if this is attempted.
                    */
                    display.asyncExec(
                        new class (display, browser, listener) Runnable {

                            Display display;
                            Browser browser;
                            TitleListener listener;

                            this (Display display, Browser browser, TitleListener listener)
                            {
                                this.display = display;
                                this.browser = browser;
                                this.listener = listener;
                            }

                            public void run() {
                                if (!display.isDisposed() && !browser.isDisposed()) {
                                    listener.changed(newEvent);
                                }
                            }
                        }
                    );
                }
            }
        }
        final ProgressEvent progress = new ProgressEvent(browser);
        progress.display = display;
        progress.widget = browser;
        progress.current = MAX_PROGRESS;
        progress.total = MAX_PROGRESS;
        for (int i = 0; i < progressListeners.length; i++) {
            final ProgressListener listener = progressListeners[i];
            /*
            * Note on WebKit.  Running the event loop from a Browser
            * delegate callback breaks the WebKit (stop loading or
            * crash).  The ProgressBar widget currently touches the
            * event loop every time the method setSelection is called.
            * The workaround is to invoke Display.asyncExec() so that
            * the Browser does not crash when the user updates the
            * selection of the ProgressBar.
            */
            display.asyncExec(
                new class (display, browser, listener) Runnable {

                    Display display;
                    Browser browser;
                    ProgressListener listener;

                    this (Display display, Browser browser, ProgressListener listener)
                    {
                        this.display = display;
                        this.browser = browser;
                        this.listener = listener;
                    }

                    public void run() {
                        if (!display.isDisposed() && !browser.isDisposed()) {
                            listener.completed(progress);
                        }
                    }
                }
            );
        }

        /* re-install registered functions */
        Enumeration elements = functions.elements ();
        while (elements.hasMoreElements ()) {
            BrowserFunction function = (BrowserFunction)elements.nextElement ();
            execute (function.functionString);
        }

        /*
        * Feature on Safari.  The identifier is used here as a marker for the events
        * related to the top frame and the URL changes related to that top frame as
        * they should appear on the location bar of a browser.  It is expected to reset
        * the identifier to 0 when the event didFinishLoadingFromDataSource related to
        * the identifierForInitialRequest event is received.  However, Safari fires
        * the didFinishLoadingFromDataSource event before the entire content of the
        * top frame is loaded.  It is possible to receive multiple willSendRequest
        * events in this interval, causing the Browser widget to send unwanted
        * Location.changing events.  For this reason, the identifier is reset to 0
        * when the top frame has either finished loading (didFinishLoadForFrame
        * event) or failed (didFailProvisionalLoadWithError).
        */
        identifier = null;
    }
}

void hookDOMKeyListeners(objc.id frameID) {
    WebFrame frame = new WebFrame(frameID);
    DOMDocument document = frame.DOMDocument_();
    if (document is null) return;

    NSString type = NSString.stringWith(DOMEVENT_KEYDOWN);
    document.addEventListener(type, delegate_, false);

    type = NSString.stringWith(DOMEVENT_KEYUP);
    document.addEventListener(type, delegate_, false);
}

void hookDOMMouseListeners(objc.id frameID) {
    WebFrame frame = new WebFrame(frameID);
    DOMDocument document = frame.DOMDocument_();
    if (document is null) return;

    NSString type = NSString.stringWith(DOMEVENT_MOUSEDOWN);
    document.addEventListener(type, delegate_, false);

    type = NSString.stringWith(DOMEVENT_MOUSEUP);
    document.addEventListener(type, delegate_, false);

    type = NSString.stringWith(DOMEVENT_MOUSEMOVE);
    document.addEventListener(type, delegate_, false);

    type = NSString.stringWith(DOMEVENT_MOUSEWHEEL);
    document.addEventListener(type, delegate_, false);
}

void webView_didReceiveTitle_forFrame(objc.id sender, objc.id titleID, objc.id frameID) {
    if (frameID is webView.mainFrame().id) {
        NSString title = new NSString(titleID);
        String newTitle = title.getString();
        TitleEvent newEvent = new TitleEvent(browser);
        newEvent.display = browser.getDisplay();
        newEvent.widget = browser;
        newEvent.title = newTitle;
        for (int i = 0; i < titleListeners.length; i++) {
            titleListeners[i].changed(newEvent);
        }
    }
}

void webView_didStartProvisionalLoadForFrame(objc.id sender, objc.id frameID) {
    /*
    * This code is intentionally commented.  WebFrameLoadDelegate:didStartProvisionalLoadForFrame is
    * called before WebResourceLoadDelegate:willSendRequest and
    * WebFrameLoadDelegate:didCommitLoadForFrame.  The resource count is reset when didCommitLoadForFrame
    * is received for the top frame.
    */
//  if (frameID is webView.mainFrame().id) {
//      /* reset resource status variables */
//      resourceCount= 0;
//  }
}

void webView_didCommitLoadForFrame(objc.id sender, objc.id frameID) {
    WebFrame frame = new WebFrame(frameID);
    WebDataSource dataSource = frame.dataSource();
    NSURLRequest request = dataSource.request();
    NSURL url = request.URL();
    NSString s = url.absoluteString();
    NSUInteger length = s.length();
    if (length is 0) return;
    String url2 = s.getString();
    /*
     * If the URI indicates that the page is being rendered from memory
     * (via setText()) then set it to about:blank to be consistent with IE.
     */
    if (url2.equals (URI_FROMMEMORY)) url2 = ABOUT_BLANK;

    final Display display = browser.getDisplay();
    bool top = frameID is webView.mainFrame().id;
    if (top) {
        /* reset resource status variables */
        resourceCount = 0;
        this.url = url2;

        final ProgressEvent progress = new ProgressEvent(browser);
        progress.display = display;
        progress.widget = browser;
        progress.current = 1;
        progress.total = MAX_PROGRESS;
        for (int i = 0; i < progressListeners.length; i++) {
            final ProgressListener listener = progressListeners[i];
            /*
            * Note on WebKit.  Running the event loop from a Browser
            * delegate callback breaks the WebKit (stop loading or
            * crash).  The widget ProgressBar currently touches the
            * event loop every time the method setSelection is called.
            * The workaround is to invoke Display.asyncexec so that
            * the Browser does not crash when the user updates the
            * selection of the ProgressBar.
            */
            display.asyncExec(
                new class (display, browser, listener) Runnable {

                    Display display;
                    Browser browser;
                    ProgressListener listener;

                    this (Display display, Browser browser, ProgressListener listener)
                    {
                        this.display = display;
                        this.browser = browser;
                        this.listener = listener;
                    }

                    public void run() {
                        if (!display.isDisposed() && !browser.isDisposed())
                            listener.changed(progress);
                    }
                }
            );
        }

        StatusTextEvent statusText = new StatusTextEvent(browser);
        statusText.display = display;
        statusText.widget = browser;
        statusText.text = url2;
        for (int i = 0; i < statusTextListeners.length; i++) {
            statusTextListeners[i].changed(statusText);
        }
    }
    LocationEvent location = new LocationEvent(browser);
    location.display = display;
    location.widget = browser;
    location.location = url2;
    location.top = top;
    for (int i = 0; i < locationListeners.length; i++) {
        locationListeners[i].changed(location);
    }
}

void webView_windowScriptObjectAvailable (int /*long*/ webView, int /*long*/ windowScriptObject) {
    NSObject scriptObject = new NSObject (windowScriptObject);
    NSString key = NSString.stringWith ("external"); //$NON-NLS-1$
    scriptObject.setValue (delegate, key);
}

/* WebResourceLoadDelegate */

void webView_resource_didFinishLoadingFromDataSource(objc.id sender, objc.id identifier, objc.id dataSource) {
    /*
    * Feature on Safari.  The identifier is used here as a marker for the events
    * related to the top frame and the URL changes related to that top frame as
    * they should appear on the location bar of a browser.  It is expected to reset
    * the identifier to 0 when the event didFinishLoadingFromDataSource related to
    * the identifierForInitialRequest event is received.  However, Safari fires
    * the didFinishLoadingFromDataSource event before the entire content of the
    * top frame is loaded.  It is possible to receive multiple willSendRequest
    * events in this interval, causing the Browser widget to send unwanted
    * Location.changing events.  For this reason, the identifier is reset to 0
    * when the top frame has either finished loading (didFinishLoadForFrame
    * event) or failed (didFailProvisionalLoadWithError).
    */
    // this code is intentionally commented
    //if (this.identifier is identifier) this.identifier = 0;
}

void webView_resource_didFailLoadingWithError_fromDataSource(objc.id sender, objc.id identifier, objc.id error, objc.id dataSource) {
    /*
    * Feature on Safari.  The identifier is used here as a marker for the events
    * related to the top frame and the URL changes related to that top frame as
    * they should appear on the location bar of a browser.  It is expected to reset
    * the identifier to 0 when the event didFinishLoadingFromDataSource related to
    * the identifierForInitialRequest event is received.  However, Safari fires
    * the didFinishLoadingFromDataSource event before the entire content of the
    * top frame is loaded.  It is possible to receive multiple willSendRequest
    * events in this interval, causing the Browser widget to send unwanted
    * Location.changing events.  For this reason, the identifier is reset to 0
    * when the top frame has either finished loading (didFinishLoadForFrame
    * event) or failed (didFailProvisionalLoadWithError).
    */
    // this code is intentionally commented
    //if (this.identifier is identifier) this.identifier = 0;
}

void webView_resource_didReceiveAuthenticationChallenge_fromDataSource (int /*long*/ sender, int /*long*/ identifier, int /*long*/ challenge, int /*long*/ dataSource) {
    NSURLAuthenticationChallenge nsChallenge = new NSURLAuthenticationChallenge (challenge);

    /*
     * Do not invoke the listeners if this challenge has been failed too many
     * times because a listener is likely giving incorrect credentials repeatedly
     * and will do so indefinitely.
     */
    if (nsChallenge.previousFailureCount () < 3) {
        for (int i = 0; i < authenticationListeners.length; i++) {
            AuthenticationEvent event = new AuthenticationEvent (browser);
            event.location = lastNavigateURL;
            authenticationListeners[i].authenticate (event);
            if (!event.doit) {
                id challengeSender = nsChallenge.sender ();
                OS.objc_msgSend (challengeSender.id, OS.sel_cancelAuthenticationChallenge_, challenge);
                return;
            }
            if (event.user !is null && event.password !is null) {
                id challengeSender = nsChallenge.sender ();
                NSString user = NSString.stringWith (event.user);
                NSString password = NSString.stringWith (event.password);
                NSURLCredential credential = NSURLCredential.credentialWithUser (user, password, OS.NSURLCredentialPersistenceForSession);
                OS.objc_msgSend (challengeSender.id, OS.sel_useCredential_forAuthenticationChallenge_, credential.id, challenge);
                return;
            }
        }
    }

    /* no listener handled the challenge, so try to invoke the native panel */
    int /*long*/ cls = OS.class_WebPanelAuthenticationHandler;
    if (cls !is 0) {
        int /*long*/ method = OS.class_getClassMethod (cls, OS.sel_sharedHandler);
        if (method !is 0) {
            int /*long*/ handler = OS.objc_msgSend (cls, OS.sel_sharedHandler);
            if (handler !is 0) {
                OS.objc_msgSend (handler, OS.sel_startAuthentication, challenge, webView.window ().id);
                return;
            }
        }
    }

    /* the native panel was not available, so show a custom dialog */
    String[] userReturn = new String[1], passwordReturn = new String[1];
    NSURLCredential proposedCredential = nsChallenge.proposedCredential ();
    if (proposedCredential !is null) {
        userReturn[0] = proposedCredential.user ().getString ();
        if (proposedCredential.hasPassword ()) {
            passwordReturn[0] = proposedCredential.password ().getString ();
        }
    }
    NSURLProtectionSpace space = nsChallenge.protectionSpace ();
    String host = space.host ().getString () + ':' + space.port ();
    String realm = space.realm ().getString ();
    bool result = showAuthenticationDialog (userReturn, passwordReturn, host, realm);
    if (!result) {
        id challengeSender = nsChallenge.sender ();
        OS.objc_msgSend (challengeSender.id, OS.sel_cancelAuthenticationChallenge_, challenge);
        return;
    }
    id challengeSender = nsChallenge.sender ();
    NSString user = NSString.stringWith (userReturn[0]);
    NSString password = NSString.stringWith (passwordReturn[0]);
    NSURLCredential credential = NSURLCredential.credentialWithUser (user, password, OS.NSURLCredentialPersistenceForSession);
    OS.objc_msgSend (challengeSender.id, OS.sel_useCredential_forAuthenticationChallenge_, credential.id, challenge);
}

bool showAuthenticationDialog (final String[] user, final String[] password, String host, String realm) {
    final Shell shell = new Shell (browser.getShell ());
    shell.setLayout (new GridLayout ());
    String title = DWT.getMessage ("DWT_Authentication_Required"); //$NON-NLS-1$
    shell.setText (title);
    Label label = new Label (shell, DWT.WRAP);
    label.setText (Compatibility.getMessage ("DWT_Enter_Username_and_Password", new String[] {realm, host})); //$NON-NLS-1$

    GridData data = new GridData ();
    Monitor monitor = browser.getMonitor ();
    int maxWidth = monitor.getBounds ().width * 2 / 3;
    int width = label.computeSize (DWT.DEFAULT, DWT.DEFAULT).x;
    data.widthHint = Math.min (width, maxWidth);
    data.horizontalAlignment = GridData.FILL;
    data.grabExcessHorizontalSpace = true;
    label.setLayoutData (data);

    Label userLabel = new Label (shell, DWT.NONE);
    userLabel.setText (DWT.getMessage ("DWT_Username")); //$NON-NLS-1$

    final Text userText = new Text (shell, DWT.BORDER);
    if (user[0] !is null) userText.setText (user[0]);
    data = new GridData ();
    data.horizontalAlignment = GridData.FILL;
    data.grabExcessHorizontalSpace = true;
    userText.setLayoutData (data);

    Label passwordLabel = new Label (shell, DWT.NONE);
    passwordLabel.setText (DWT.getMessage ("DWT_Password")); //$NON-NLS-1$

    final Text passwordText = new Text (shell, DWT.PASSWORD | DWT.BORDER);
    if (password[0] !is null) passwordText.setText (password[0]);
    data = new GridData ();
    data.horizontalAlignment = GridData.FILL;
    data.grabExcessHorizontalSpace = true;
    passwordText.setLayoutData (data);

    final bool[] result = new bool[1];
    final Button[] buttons = new Button[2];
    Listener listener = new Listener() {
        public void handleEvent(Event event) {
            user[0] = userText.getText();
            password[0] = passwordText.getText();
            result[0] = event.widget is buttons[1];
            shell.close();
        }
    };

    Composite composite = new Composite (shell, DWT.NONE);
    data = new GridData ();
    data.horizontalAlignment = GridData.END;
    composite.setLayoutData (data);
    composite.setLayout (new GridLayout (2, true));
    buttons[0] = new Button (composite, DWT.PUSH);
    buttons[0].setText (DWT.getMessage("DWT_Cancel")); //$NON-NLS-1$
    buttons[0].setLayoutData (new GridData (GridData.FILL_HORIZONTAL));
    buttons[0].addListener (DWT.Selection, listener);
    buttons[1] = new Button (composite, DWT.PUSH);
    buttons[1].setText (DWT.getMessage("DWT_OK")); //$NON-NLS-1$
    buttons[1].setLayoutData (new GridData (GridData.FILL_HORIZONTAL));
    buttons[1].addListener (DWT.Selection, listener);

    shell.setDefaultButton (buttons[1]);
    shell.pack ();
    shell.open ();
    Display display = browser.getDisplay ();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }

    return result[0];
}

    final Display display = browser.getDisplay();
    final ProgressEvent progress = new ProgressEvent(browser);
    progress.display = display;
    progress.widget = browser;
    progress.current = resourceCount;
    progress.total = Math.max(resourceCount, MAX_PROGRESS);
    for (int i = 0; i < progressListeners.length; i++) {
        final ProgressListener listener = progressListeners[i];
        /*
        * Note on WebKit.  Running the event loop from a Browser
        * delegate callback breaks the WebKit (stop loading or
        * crash).  The widget ProgressBar currently touches the
        * event loop every time the method setSelection is called.
        * The workaround is to invoke Display.asyncexec so that
        * the Browser does not crash when the user updates the
        * selection of the ProgressBar.
        */
        display.asyncExec(
            new class (display, browser, listener) Runnable {

                Display display;
                Browser browser;
                ProgressListener listener;

                this (Display display, Browser browser, ProgressListener listener)
                {
                    this.display = display;
                    this.browser = browser;
                    this.listener = listener;
                }

                public void run() {
                    if (!display.isDisposed() && !browser.isDisposed())
                        listener.changed(progress);
                }
            }
        );
    }

    NSNumber identifier = NSNumber.numberWithInt(resourceCount++);
    if (this.identifier is null) {
        WebDataSource dataSource = new WebDataSource(dataSourceID);
        WebFrame frame = dataSource.webFrame();
        if (frame.id is webView.mainFrame().id) this.identifier = identifier.id;
    }
    return identifier.id;

}

objc.id webView_resource_willSendRequest_redirectResponse_fromDataSource(objc.id sender, objc.id identifier, objc.id request, objc.id redirectResponse, objc.id dataSource) {
    NSURLRequest nsRequest = new NSURLRequest (request);
    NSURL url = nsRequest.URL ();
    if (url.isFileURL ()) {
        NSMutableURLRequest newRequest = new NSMutableURLRequest (nsRequest.mutableCopy ());
        newRequest.autorelease ();
        newRequest.setCachePolicy (OS.NSURLRequestReloadIgnoringLocalCacheData);
        return newRequest.id;
    }
    return request;
}

/* UIDelegate */

objc.id webView_createWebViewWithRequest(objc.id sender, objc.id request) {
    WindowEvent newEvent = new WindowEvent(browser);
    newEvent.display = browser.getDisplay();
    newEvent.widget = browser;
    newEvent.required = true;
    if (openWindowListeners !is null) {
        for (int i = 0; i < openWindowListeners.length; i++) {
            openWindowListeners[i].open(newEvent);
        }
    }
    WebView result = null;
    Browser browser = null;
    if (newEvent.browser !is null && cast(Safari) newEvent.browser.webBrowser) {
        browser = newEvent.browser;
    }
    if (browser !is null && !browser.isDisposed()) {
        result = (cast(Safari)browser.webBrowser).webView;
        if (request !is null) {
            WebFrame mainFrame = result.mainFrame();
            mainFrame.loadRequest(new NSURLRequest(request));
        }
    }
    return result !is null ? result.id : null;
}

void webViewShow(objc.id sender) {
    /*
    * Feature on WebKit.  The Safari WebKit expects the application
    * to create a new Window using the Objective C Cocoa API in response
    * to UIDelegate.createWebViewWithRequest. The application is then
    * expected to use Objective C Cocoa API to make this window visible
    * when receiving the UIDelegate.webViewShow message.  For some reason,
    * a window created with the Carbon API hosting the new browser instance
    * does not redraw until it has been resized.  The fix is to increase the
    * size of the Shell and restore it to its initial size.
    */
    Shell parent = browser.getShell();
    Point pt = parent.getSize();
    parent.setSize(pt.x+1, pt.y);
    parent.setSize(pt.x, pt.y);
    WindowEvent newEvent = new WindowEvent(browser);
    newEvent.display = browser.getDisplay();
    newEvent.widget = browser;
    if (location !is null) newEvent.location = location;
    if (size !is null) newEvent.size = size;
    /*
    * Feature in Safari.  Safari's tool bar contains
    * the address bar.  The address bar is displayed
    * if the tool bar is displayed. There is no separate
    * notification for the address bar.
    * Feature in Safari.  The menu bar is always
    * displayed. There is no notification to hide
    * the menu bar.
    */
    newEvent.addressBar = toolBar;
    newEvent.menuBar = true;
    newEvent.statusBar = statusBar;
    newEvent.toolBar = toolBar;
    for (int i = 0; i < visibilityWindowListeners.length; i++) {
        visibilityWindowListeners[i].show(newEvent);
    }
    location = null;
    size = null;
}

void webView_setFrame(objc.id sender, objc.id frame) {
    NSRect rect = NSRect();
    OS.memmove(&rect, frame, NSRect.sizeof);
    /* convert to DWT system coordinates */
    Rectangle bounds = browser.getDisplay().getBounds();
    location = new Point(cast(int)rect.x, bounds.height - cast(int)rect.y - cast(int)rect.height);
    size = new Point(cast(int)rect.width, cast(int)rect.height);
}

void webViewFocus(objc.id sender) {
}

void webViewUnfocus(objc.id sender) {
}

void webView_runJavaScriptAlertPanelWithMessage(objc.id sender, objc.id messageID) {
    NSString message = new NSString(messageID);
    String text = message.getString();

    MessageBox messageBox = new MessageBox(browser.getShell(), DWT.OK | DWT.ICON_WARNING);
    messageBox.setText("Javascript");   //$NON-NLS-1$
    messageBox.setMessage(text);
    messageBox.open();
}

objc.id webView_runJavaScriptConfirmPanelWithMessage(objc.id sender, objc.id messageID) {
    NSString message = new NSString(messageID);
    String text = message.getString();

    MessageBox messageBox = new MessageBox(browser.getShell(), DWT.OK | DWT.CANCEL | DWT.ICON_QUESTION);
    messageBox.setText("Javascript");   //$NON-NLS-1$
    messageBox.setMessage(text);
    return messageBox.open() is DWT.OK ? cast(objc.id) 1 : null;
}

void webView_runOpenPanelForFileButtonWithResultListener(objc.id sender, objc.id resultListenerID) {
    FileDialog dialog = new FileDialog(browser.getShell(), DWT.NONE);
    String result = dialog.open();
    WebOpenPanelResultListener resultListener = new WebOpenPanelResultListener(resultListenerID);
    if (result is null) {
        resultListener.cancel();
        return;
    }
    resultListener.chooseFilename(NSString.stringWith(result));
}

void webViewClose(objc.id sender) {
    Shell parent = browser.getShell();
    WindowEvent newEvent = new WindowEvent(browser);
    newEvent.display = browser.getDisplay();
    newEvent.widget = browser;
    for (int i = 0; i < closeWindowListeners.length; i++) {
        closeWindowListeners[i].close(newEvent);
    }
    browser.dispose();
    if (parent.isDisposed()) return;
    /*
    * Feature on WebKit.  The Safari WebKit expects the application
    * to create a new Window using the Objective C Cocoa API in response
    * to UIDelegate.createWebViewWithRequest. The application is then
    * expected to use Objective C Cocoa API to make this window visible
    * when receiving the UIDelegate.webViewShow message.  For some reason,
    * a window created with the Carbon API hosting the new browser instance
    * does not redraw until it has been resized.  The fix is to increase the
    * size of the Shell and restore it to its initial size.
    */
    Point pt = parent.getSize();
    parent.setSize(pt.x+1, pt.y);
    parent.setSize(pt.x, pt.y);
}

objc.id webView_contextMenuItemsForElement_defaultMenuItems(objc.id sender, objc.id element, objc.id defaultMenuItems) {
    Point pt = browser.getDisplay().getCursorLocation();
    Event event = new Event();
    event.x = pt.x;
    event.y = pt.y;
    browser.notifyListeners(DWT.MenuDetect, event);
    Menu menu = browser.getMenu();
    if (!event.doit) return null;
    if (menu !is null && !menu.isDisposed()) {
        if (event.x !is pt.x || event.y !is pt.y) {
            menu.setLocation(event.x, event.y);
        }
        menu.setVisible(true);
        return null;
    }
    return defaultMenuItems;
}

void webView_setStatusBarVisible(objc.id sender, bool visible) {
    /* Note.  Webkit only emits the notification when the status bar should be hidden. */
    statusBar = visible;
}

void webView_setStatusText(objc.id sender, objc.id textID) {
    NSString text = new NSString(textID);
    NSUInteger length = text.length();
    if (length is 0) return;

    StatusTextEvent statusText = new StatusTextEvent(browser);
    statusText.display = browser.getDisplay();
    statusText.widget = browser;
    statusText.text = text.getString();
    for (int i = 0; i < statusTextListeners.length; i++) {
        statusTextListeners[i].changed(statusText);
    }
}

void webView_setResizable(objc.id sender, bool visible) {
}

void webView_setToolbarsVisible(objc.id sender, bool visible) {
    /* Note.  Webkit only emits the notification when the tool bar should be hidden. */
    toolBar = visible;
}

void webView_mouseDidMoveOverElement_modifierFlags (objc.id sender, objc.id elementInformationID, objc.id modifierFlags) {
    if (elementInformationID is null) return;

    NSString key = NSString.stringWith(WebElementLinkURLKey);
    NSDictionary elementInformation = new NSDictionary(elementInformationID);
    id value = elementInformation.valueForKey(key);
    if (value is null) {
        /* not currently over a link */
        if (lastHoveredLinkURL is null) return;
        lastHoveredLinkURL = null;
        StatusTextEvent statusText = new StatusTextEvent(browser);
        statusText.display = browser.getDisplay();
        statusText.widget = browser;
        statusText.text = "";   //$NON-NLS-1$
        for (int i = 0; i < statusTextListeners.length; i++) {
            statusTextListeners[i].changed(statusText);
        }
        return;
    }

    NSString url = (new NSURL(value.id)).absoluteString();
    NSUInteger length = url.length();
    String urlString;
    if (length is 0) {
        urlString = ""; //$NON-NLS-1$
    } else {
        urlString = url.getString();
    }
    if (urlString.equals(lastHoveredLinkURL)) return;

    lastHoveredLinkURL = urlString;
    StatusTextEvent statusText = new StatusTextEvent(browser);
    statusText.display = browser.getDisplay();
    statusText.widget = browser;
    statusText.text = urlString;
    for (int i = 0; i < statusTextListeners.length; i++) {
        statusTextListeners[i].changed(statusText);
    }
}

void webView_printFrameView (objc.id sender, objc.id frameViewID) {
    WebFrameView view = new WebFrameView(frameViewID);
    bool viewPrint = view.documentViewShouldHandlePrint();
    if (viewPrint) {
        view.printDocumentView();
        return;
    }
    NSPrintInfo info = NSPrintInfo.sharedPrintInfo();
    NSPrintOperation operation = view.printOperationWithPrintInfo(info);
    if (operation !is null) operation.runOperation();
}

/* PolicyDelegate */

void webView_decidePolicyForMIMEType_request_frame_decisionListener(objc.id sender, objc.id type, objc.id request, objc.id frame, objc.id listenerID) {
    bool canShow = WebView.canShowMIMEType(new NSString(type));
    WebPolicyDecisionListener listener = new WebPolicyDecisionListener(listenerID);
    if (canShow) {
        listener.use();
    } else {
        listener.download();
    }
}

void webView_decidePolicyForNavigationAction_request_frame_decisionListener(objc.id sender, objc.id actionInformation, objc.id request, objc.id frame, objc.id listenerID) {
    NSURL url = (new NSURLRequest(request)).URL();
    WebPolicyDecisionListener listener = new WebPolicyDecisionListener(listenerID);
    if (url is null) {
        /* indicates that a URL with an invalid format was specified */
        listener.ignore();
        return;
    }
    NSString s = url.absoluteString();
    String url2 = s.getString();
    /*
     * If the URI indicates that the page is being rendered from memory
     * (via setText()) then set it to about:blank to be consistent with IE.
     */
    if (url2.equals (URI_FROMMEMORY)) url2 = ABOUT_BLANK;

    LocationEvent newEvent = new LocationEvent(browser);
    newEvent.display = browser.getDisplay();
    newEvent.widget = browser;
    newEvent.location = url2;
    newEvent.doit = true;
    if (locationListeners !is null) {
        changingLocation = true;
        for (int i = 0; i < locationListeners.length; i++) {
            locationListeners[i].changing(newEvent);
        }
        changingLocation = false;
    }
    if (newEvent.doit) {
        if (jsEnabledChanged) {
            jsEnabledChanged = false;
            if (preferences is null) {
                preferences = (WebPreferences)new WebPreferences ().alloc ().init ();
                webView.setPreferences (preferences);
            }
            preferences.setJavaScriptEnabled (jsEnabled);
        }
        listener.use();
        lastNavigateURL = url2;
    } else {
        listener.ignore();
    }
    if (html !is null && !browser.isDisposed()) {
        String html = this.html;
        this.html = null;
        _setText(html);
    }
}

void webView_decidePolicyForNewWindowAction_request_newFrameName_decisionListener(objc.id sender, objc.id actionInformation, objc.id request, objc.id frameName, objc.id listenerID) {
    WebPolicyDecisionListener listener = new WebPolicyDecisionListener(listenerID);
    listener.use();
}

void webView_unableToImplementPolicyWithError_frame(objc.id sender, objc.id error, objc.id frame) {
}

/* WebDownload */

void download_decideDestinationWithSuggestedFilename(objc.id downloadId, objc.id filename) {
    NSString string = new NSString(filename);
    String name = string.getString();
    FileDialog dialog = new FileDialog(browser.getShell(), DWT.SAVE);
    dialog.setText(DWT.getMessage ("DWT_FileDownload")); //$NON-NLS-1$
    dialog.setFileName(name);
    String path = dialog.open();
    NSURLDownload download = new NSURLDownload(downloadId);
    if (path is null) {
        /* cancel pressed */
        download.cancel();
        return;
    }
    download.setDestination(NSString.stringWith(path), true);
}

/* DOMEventListener */

void handleEvent(objc.id evtId) {
    NSString string = new NSString(OS.objc_msgSend(evtId, OS.sel_type));
    String type = string.getString();

    if (DOMEVENT_KEYDOWN.equals(type) || DOMEVENT_KEYUP.equals(type)) {
        DOMKeyboardEvent event = new DOMKeyboardEvent(evtId);

        bool ctrl = event.ctrlKey();
        bool shift = event.shiftKey();
        bool alt = event.altKey();
        bool meta = event.metaKey();
        int keyCode = event.keyCode();
        int charCode = event.charCode();

        Event keyEvent = new Event();
        keyEvent.widget = browser;
        int eventType = DOMEVENT_KEYDOWN.equals(type) ? DWT.KeyDown : DWT.KeyUp;
        keyEvent.type = eventType;
        int translatedKey = translateKey (keyCode);
        keyEvent.keyCode = translatedKey;
        keyEvent.character = cast(char)charCode;
        int stateMask = (alt ? DWT.ALT : 0) | (ctrl ? DWT.CTRL : 0) | (shift ? DWT.SHIFT : 0) | (meta ? DWT.COMMAND : 0);
        keyEvent.stateMask = stateMask;
        keyEvent.stateMask = stateMask;
        browser.notifyListeners(keyEvent.type, keyEvent);
        if (!keyEvent.doit) {
            event.preventDefault();
        } else {
            if (eventType is DWT.KeyDown && stateMask is DWT.COMMAND) {
                if (translatedKey is 'v') {
                    webView.paste (webView);
                } else if (translatedKey is 'c') {
                    webView.copy (webView);
                } else if (translatedKey is 'x') {
                    webView.cut (webView);
                }
            }
        }
        return;
    }

    if (DOMEVENT_MOUSEWHEEL.equals(type)) {
        DOMWheelEvent event = new DOMWheelEvent(evtId);
        int clientX = event.clientX();
        int clientY = event.clientY();
        int delta = event.wheelDelta();
        bool ctrl = event.ctrlKey();
        bool shift = event.shiftKey();
        bool alt = event.altKey();
        bool meta = event.metaKey();
        Event mouseEvent = new Event();
        mouseEvent.type = DWT.MouseWheel;
        mouseEvent.widget = browser;
        mouseEvent.x = clientX; mouseEvent.y = clientY;
        mouseEvent.count = delta / 120;
        mouseEvent.stateMask = (alt ? DWT.ALT : 0) | (ctrl ? DWT.CTRL : 0) | (shift ? DWT.SHIFT : 0) | (meta ? DWT.COMMAND : 0);
        browser.notifyListeners (mouseEvent.type, mouseEvent);
        return;
    }

    /* mouse event */

    DOMMouseEvent event = new DOMMouseEvent(evtId);

    int clientX = event.clientX();
    int clientY = event.clientY();
    int detail = event.detail();
    int button = event.button();
    bool ctrl = event.ctrlKey();
    bool shift = event.shiftKey();
    bool alt = event.altKey();
    bool meta = event.metaKey();

    Event mouseEvent = new Event ();
    mouseEvent.widget = browser;
    mouseEvent.x = clientX; mouseEvent.y = clientY;
    mouseEvent.stateMask = (alt ? DWT.ALT : 0) | (ctrl ? DWT.CTRL : 0) | (shift ? DWT.SHIFT : 0) | (meta ? DWT.COMMAND : 0);
    if (DOMEVENT_MOUSEDOWN.equals (type)) {
        mouseEvent.type = DWT.MouseDown;
        mouseEvent.button = button + 1;
        mouseEvent.count = detail;
    } else if (DOMEVENT_MOUSEUP.equals (type)) {
        mouseEvent.type = DWT.MouseUp;
        mouseEvent.button = button + 1;
        mouseEvent.count = detail;
        switch (mouseEvent.button) {
            case 1: mouseEvent.stateMask |= DWT.BUTTON1; break;
            case 2: mouseEvent.stateMask |= DWT.BUTTON2; break;
            case 3: mouseEvent.stateMask |= DWT.BUTTON3; break;
            case 4: mouseEvent.stateMask |= DWT.BUTTON4; break;
            case 5: mouseEvent.stateMask |= DWT.BUTTON5; break;
            default:
        }
    } else if (DOMEVENT_MOUSEMOVE.equals (type)) {
        /*
        * Bug in Safari.  Spurious and redundant mousemove events are received in
        * various contexts, including following every MouseUp.  The workaround is
        * to not fire MouseMove events whose x and y values match the last MouseMove
        */
        if (mouseEvent.x is lastMouseMoveX && mouseEvent.y is lastMouseMoveY) return;
        mouseEvent.type = DWT.MouseMove;
        lastMouseMoveX = mouseEvent.x; lastMouseMoveY = mouseEvent.y;
    }

    browser.notifyListeners (mouseEvent.type, mouseEvent);
    if (detail is 2 && DOMEVENT_MOUSEDOWN.equals (type)) {
        mouseEvent = new Event ();
        mouseEvent.widget = browser;
        mouseEvent.x = clientX; mouseEvent.y = clientY;
        mouseEvent.stateMask = (alt ? DWT.ALT : 0) | (ctrl ? DWT.CTRL : 0) | (shift ? DWT.SHIFT : 0) | (meta ? DWT.COMMAND : 0);
        mouseEvent.type = DWT.MouseDoubleClick;
        mouseEvent.button = button + 1;
        mouseEvent.count = detail;
        browser.notifyListeners (mouseEvent.type, mouseEvent);
    }
}

/* external */

Object convertToJava (int /*long*/ value) {
    NSObject object = new NSObject (value);
    int /*long*/ clazz = OS.objc_lookUpClass ("NSString"); //$NON-NLS-1$
    if (object.isKindOfClass (clazz)) {
        NSString string = new NSString (value);
        return string.getString ();
    }
    clazz = OS.objc_lookUpClass ("NSNumber"); //$NON-NLS-1$
    if (object.isKindOfClass (clazz)) {
        NSNumber number = new NSNumber (value);
        int /*long*/ ptr = number.objCType ();
        byte[] type = new byte[1];
        OS.memmove (type, ptr, 1);
        if (type[0] is 'c' || type[0] is 'B') {
            return new Boolean (number.boolValue ());
        }
        if ("islqISLQfd".indexOf (type[0]) !is -1) { //$NON-NLS-1$
            return new Double (number.doubleValue ());
        }
    }
    clazz = OS.objc_lookUpClass ("WebScriptObject"); //$NON-NLS-1$
    if (object.isKindOfClass (clazz)) {
        WebScriptObject script = new WebScriptObject (value);
        id id = script.valueForKey (NSString.stringWith ("length")); //$NON-NLS-1$
        if (id is null) { /* not a JS array */
            DWT.error (DWT.ERROR_INVALID_ARGUMENT);
        }
        int length = new NSNumber (id).intValue ();
        Object[] arguments = new Object[length];
        for (int i = 0; i < length; i++) {
            id current = script.webScriptValueAtIndex (i);
            if (current !is null) {
                arguments[i] = convertToJava (current.id);
            }
        }
        return arguments;
    }
    clazz = OS.objc_lookUpClass ("WebUndefined"); //$NON-NLS-1$
    if (object.isKindOfClass (clazz)) {
        return null;
    }

    DWT.error (DWT.ERROR_INVALID_ARGUMENT);
    return null;
}

NSObject convertToJS (Object value) {
    if (value is null) {
        return WebUndefined.undefined ();
    }
    if (value instanceof String) {
        return NSString.stringWith ((String)value);
    }
    if (value instanceof Boolean) {
        return NSNumber.numberWithBool (((Boolean)value).boolValue ());
    }
    if (value instanceof Number) {
        return NSNumber.numberWithDouble (((Number)value).doubleValue ());
    }
    if (value instanceof Object[]) {
        Object[] arrayValue = (Object[]) value;
        int length = arrayValue.length;
        if (length > 0) {
            NSMutableArray array = NSMutableArray.arrayWithCapacity (length);
            for (int i = 0; i < length; i++) {
                Object currentObject = arrayValue[i];
                array.addObject (convertToJS (currentObject));
            }
            return array;
        }
    }
    DWT.error (DWT.ERROR_INVALID_RETURN_VALUE);
    return null;
}

NSObject callJava (int /*long*/ index, int /*long*/ args, int /*long*/ arg1) {
    Object returnValue = null;
    NSObject object = new NSObject (index);
    int /*long*/ clazz = OS.objc_lookUpClass ("NSNumber"); //$NON-NLS-1$
    if (object.isKindOfClass (clazz)) {
        NSNumber number = new NSNumber (index);
        Object key = new Integer (number.intValue ());
        BrowserFunction function = (BrowserFunction)functions.get (key);
        if (function !is null) {
            try {
                Object temp = convertToJava (args);
                if (temp instanceof Object[]) {
                    Object[] arguments = (Object[])temp;
                    try {
                        returnValue = function.function (arguments);
                    } catch (Exception e) {
                        /* exception during function invocation */
                        returnValue = WebBrowser.CreateErrorString (e.getLocalizedMessage ());
                    }
                }
            } catch (IllegalArgumentException e) {
                /* invalid argument value type */
                if (function.isEvaluate) {
                    /* notify the evaluate function so that a java exception can be thrown */
                    function.function (new String[] {WebBrowser.CreateErrorString (new DWTException (DWT.ERROR_INVALID_RETURN_VALUE).getLocalizedMessage ())});
                }
                returnValue = WebBrowser.CreateErrorString (e.getLocalizedMessage ());
            }
        }
    }
    try {
        return convertToJS (returnValue);
    } catch (DWTException e) {
        /* invalid return value type */
        return convertToJS (WebBrowser.CreateErrorString (e.getLocalizedMessage ()));
    }
}

}
