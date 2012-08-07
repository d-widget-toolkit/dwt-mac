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
module dwt.internal.cocoa.NSHTTPCookieStorage;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSHTTPCookie;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSURL;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSHTTPCookieStorage : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSArray cookies() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_cookies);
    return result !is null ? new NSArray(result) : null;
}

public NSArray cookiesForURL(NSURL URL) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_cookiesForURL_, URL !is null ? URL.id : null);
    return result !is null ? new NSArray(result) : null;
}

public NSArray cookiesForURL(NSURL URL) {
    int /*long*/ result = OS.objc_msgSend(this.id, OS.sel_cookiesForURL_, URL !is null ? URL.id : 0);
    return result !is 0 ? new NSArray(result) : null;
}

public void deleteCookie(NSHTTPCookie cookie) {
    OS.objc_msgSend(this.id, OS.sel_deleteCookie_, cookie !is null ? cookie.id : null);
}

public void setCookie(NSHTTPCookie cookie) {
    OS.objc_msgSend(this.id, OS.sel_setCookie_, cookie !is null ? cookie.id : null);
}

public static NSHTTPCookieStorage sharedHTTPCookieStorage() {
    objc.id result = OS.objc_msgSend(OS.class_NSHTTPCookieStorage, OS.sel_sharedHTTPCookieStorage);
    return result !is null ? new NSHTTPCookieStorage(result) : null;
}

}
