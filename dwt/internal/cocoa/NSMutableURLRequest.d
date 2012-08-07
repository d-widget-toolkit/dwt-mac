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
module dwt.internal.cocoa.NSMutableURLRequest;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSURL;
import dwt.internal.cocoa.NSURLRequest;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSMutableURLRequest : NSURLRequest {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void setCachePolicy(int /*long*/ policy) {
    OS.objc_msgSend(this.id, OS.sel_setCachePolicy_, policy);
}

public void setCachePolicy(NSURLRequestCachePolicy policy) {
    OS.objc_msgSend(this.id, OS.sel_setCachePolicy_, policy);
}

public void setURL(NSURL URL) {
    OS.objc_msgSend(this.id, OS.sel_setURL_, URL !is null ? URL.id : null);
}

public static NSURLRequest requestWithURL(NSURL URL) {
    objc.id result = OS.objc_msgSend(OS.class_NSMutableURLRequest, OS.sel_requestWithURL_, URL !is null ? URL.id : null);
    return result !is null ? new NSMutableURLRequest(result) : null;
}

}
