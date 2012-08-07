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
module dwt.internal.cocoa.NSHTTPCookie;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSDictionary;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSURL;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSHTTPCookie : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public static NSArray cookiesWithResponseHeaderFields(NSDictionary headerFields, NSURL URL) {
    objc.id result = OS.objc_msgSend(OS.class_NSHTTPCookie, OS.sel_cookiesWithResponseHeaderFields_forURL_, headerFields !is null ? headerFields.id : null, URL !is null ? URL.id : null);
    return result !is null ? new NSArray(result) : null;
}

public bool isSessionOnly() {
    return OS.objc_msgSend_bool(this.id, OS.sel_isSessionOnly);
}

public NSString name() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_name);
    return result !is null ? new NSString(result) : null;
}

public NSString value() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_value);
    return result !is null ? new NSString(result) : null;
}

}
