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
 *     Jacob Carlborg <doob@me.com>
 *******************************************************************************/
module dwt.internal.cocoa.NSData;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSData : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public /*const*/void* bytes() {
    return cast(/*const*/void*) OS.objc_msgSend(this.id, OS.sel_bytes);
}

public static NSData dataWithBytes(/*const*/void* bytes, NSUInteger length) {
    objc.id result = OS.objc_msgSend(OS.class_NSData, OS.sel_dataWithBytes_length_, bytes, length);
    return result !is null ? new NSData(result) : null;
}

public void getBytes(void* buffer) {
    OS.objc_msgSend(this.id, OS.sel_getBytes_, buffer);
}

public void getBytes(void* buffer, NSUInteger length) {
    OS.objc_msgSend(this.id, OS.sel_getBytes_length_, buffer, length);
}

public NSUInteger length() {
    return cast(NSUInteger) OS.objc_msgSend(this.id, OS.sel_length);
}

}
