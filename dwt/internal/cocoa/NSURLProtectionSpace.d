/*******************************************************************************
 * Copyright (c) 2000, 2009 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *    IBM Corporation - initial API and implementation
 *******************************************************************************/
module dwt.internal.cocoa.NSURLProtectionSpace;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSString;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSURLProtectionSpace : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSString host() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_host);
    return result !is null ? new NSString(result) : null;
}

public NSInteger port() {
    return OS.objc_msgSend(this.id, OS.sel_port);
}

public NSString realm() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_realm);
    return result !is null ? new NSString(result) : null;
}

}
