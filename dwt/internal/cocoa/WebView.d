/*******************************************************************************
 * Copyright (c) 2000, 2009 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *    IBM Corporation - initial API and implementation
 *
 * Port to the D programming language:
 *    Jacob Carlborg <doob@me.com>
 *******************************************************************************/
module dwt.internal.cocoa.WebView;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSView;
import dwt.internal.cocoa.OS;
import dwt.internal.cocoa.WebFrame;
import dwt.internal.cocoa.WebPreferences;
import objc = dwt.internal.objc.runtime;

public class WebView : NSView {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public bool canGoBack() {
    return OS.objc_msgSend_bool(this.id, OS.sel_canGoBack);
}

public bool canGoForward() {
    return OS.objc_msgSend_bool(this.id, OS.sel_canGoForward);
}

public static bool canShowMIMEType(NSString MIMEType) {
    return OS.objc_msgSend_bool(OS.class_WebView, OS.sel_canShowMIMEType_, MIMEType !is null ? MIMEType.id : null);
}

public void copy(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_copy_, sender !is null ? sender.id : null);
}

public void cut(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_cut_, sender !is null ? sender.id : null);
}

public void copy(id sender) {
    OS.objc_msgSend(this.id, OS.sel_copy_, sender !is null ? sender.id : 0);
}

public void cut(id sender) {
    OS.objc_msgSend(this.id, OS.sel_cut_, sender !is null ? sender.id : 0);
}

public bool goBack() {
    return OS.objc_msgSend_bool(this.id, OS.sel_goBack);
}

public bool goForward() {
    return OS.objc_msgSend_bool(this.id, OS.sel_goForward);
}

public WebView initWithFrame(NSRect frame, NSString frameName, NSString groupName) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithFrame_frameName_groupName_, frame, frameName !is null ? frameName.id : null, groupName !is null ? groupName.id : null);
    return result is this.id ? this : (result !is null ? new WebView(result) : null);
}

public WebFrame mainFrame() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_mainFrame);
    return result !is null ? new WebFrame(result) : null;
}

public void paste(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_paste_, sender !is null ? sender.id : null);
}

public void reload(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_reload_, sender !is null ? sender.id : null);
}

public void setApplicationNameForUserAgent(NSString applicationName) {
    OS.objc_msgSend(this.id, OS.sel_setApplicationNameForUserAgent_, applicationName !is null ? applicationName.id : null);
}

public void setDownloadDelegate(cocoa.id delegate_) {
    OS.objc_msgSend(this.id, OS.sel_setDownloadDelegate_, delegate_ !is null ? delegate_.id : null);
}

public void setFrameLoadDelegate(cocoa.id delegate_) {
    OS.objc_msgSend(this.id, OS.sel_setFrameLoadDelegate_, delegate_ !is null ? delegate_.id : null);
}

public void setPolicyDelegate(cocoa.id delegate_) {
    OS.objc_msgSend(this.id, OS.sel_setPolicyDelegate_, delegate_ !is null ? delegate_.id : null);
}

public void setPreferences(WebPreferences prefs) {
    OS.objc_msgSend(this.id, OS.sel_setPreferences_, prefs !is null ? prefs.id : 0);
}

public void setPreferences(WebPreferences prefs) {
    OS.objc_msgSend(this.id, OS.sel_setPreferences_, prefs !is null ? prefs.id : null);
}

public void setResourceLoadDelegate(cocoa.id delegate_) {
    OS.objc_msgSend(this.id, OS.sel_setResourceLoadDelegate_, delegate_ !is null ? delegate_.id : null);
}

public void setUIDelegate(cocoa.id delegate_) {
    OS.objc_msgSend(this.id, OS.sel_setUIDelegate_, delegate_ !is null ? delegate_.id : null);
}

public void stopLoading(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_stopLoading_, sender !is null ? sender.id : null);
}

public NSString stringByEvaluatingJavaScriptFromString(NSString script) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_stringByEvaluatingJavaScriptFromString_, script !is null ? script.id : null);
    return result !is null ? new NSString(result) : null;
}

}
