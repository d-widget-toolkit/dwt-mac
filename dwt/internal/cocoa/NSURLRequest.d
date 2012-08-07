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
module dwt.internal.cocoa.NSURLRequest;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSURL;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSURLRequest : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSURL URL() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_URL);
    return result !is null ? new NSURL(result) : null;
}

public NSURLRequest initWithURL(NSURL URL) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithURL_, URL !is null ? URL.id : null);
    return result is this.id ? this : (result !is null ? new NSURLRequest(result) : null);
}

public static NSURLRequest requestWithURL(NSURL URL) {
    objc.id result = OS.objc_msgSend(OS.class_NSURLRequest, OS.sel_requestWithURL_, URL !is null ? URL.id : null);
    return result !is null ? new NSURLRequest(result) : null;
}

}
