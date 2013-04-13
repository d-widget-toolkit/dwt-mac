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
module dwt.internal.cocoa.NSValue;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSRange;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;
import bindings = dwt.internal.objc.bindings;

public class NSValue : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public char* objCType() {
    return cast(char*) OS.objc_msgSend(this.id, OS.sel_objCType);
}

public NSPoint pointValue() {
    return OS.objc_msgSend_stret!(NSPoint)(this.id, OS.sel_pointValue);
}

public NSRange rangeValue() {
    return OS.objc_msgSend_stret!(NSRange)(this.id, OS.sel_rangeValue);
}

public NSRect rectValue() {
    return OS.objc_msgSend_stret!(NSRect)(this.id, OS.sel_rectValue);
}

public NSSize sizeValue() {
    return OS.objc_msgSend_stret!(NSSize)(this.id, OS.sel_sizeValue);
}

public static NSValue valueWithPoint(NSPoint point) {
    objc.id result = OS.objc_msgSend(OS.class_NSValue, OS.sel_valueWithPoint_, point);
    return result !is null ? new NSValue(result) : null;
}

public static NSValue valueWithRange(NSRange range) {
    objc.id result = OS.objc_msgSend(OS.class_NSValue, OS.sel_valueWithRange_, range);
    return result !is null ? new NSValue(result) : null;
}

public static NSValue valueWithRect(NSRect rect) {
    objc.id result = OS.objc_msgSend(OS.class_NSValue, OS.sel_valueWithRect_, rect);
    return result !is null ? new NSValue(result) : null;
}

public static NSValue valueWithSize(NSSize size) {
    objc.id result = OS.objc_msgSend(OS.class_NSValue, OS.sel_valueWithSize_, size);
    return result !is null ? new NSValue(result) : null;
}

}
