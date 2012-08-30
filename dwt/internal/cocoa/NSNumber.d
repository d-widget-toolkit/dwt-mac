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
module dwt.internal.cocoa.NSNumber;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSRange;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.NSValue;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSNumber : NSValue {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public bool boolValue() {
    return OS.objc_msgSend_bool(this.id, OS.sel_boolValue);
}

public double doubleValue() {
    return OS.objc_msgSend_fpret(this.id, OS.sel_doubleValue);
}

public float floatValue() {
    return cast(float)OS.objc_msgSend_fpret(this.id, OS.sel_floatValue);
}

public int intValue() {
    return cast(int)/*64*/OS.objc_msgSend(this.id, OS.sel_intValue);
}

public NSInteger integerValue() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_integerValue);
}

public static NSNumber numberWithBool(bool value) {
    objc.id result = OS.objc_msgSend(OS.class_NSNumber, OS.sel_numberWithBool_, value);
    return result !is null ? new NSNumber(result) : null;
}

public static NSNumber numberWithDouble(double value) {
    objc.id result = OS.objc_msgSend(OS.class_NSNumber, OS.sel_numberWithDouble_, value);
    return result !is null ? new NSNumber(result) : null;
}

public static NSNumber numberWithInt(int value) {
    objc.id result = OS.objc_msgSend(OS.class_NSNumber, OS.sel_numberWithInt_, value);
    return result !is null ? new NSNumber(result) : null;
}

public static NSNumber numberWithInteger(NSInteger value) {
    objc.id result = OS.objc_msgSend(OS.class_NSNumber, OS.sel_numberWithInteger_, value);
    return result !is null ? new NSNumber(result) : null;
}

public static NSValue valueWithPoint(NSPoint point) {
    objc.id result = OS.objc_msgSend(OS.class_NSNumber, OS.sel_valueWithPoint_, point);
    return result !is null ? new NSValue(result) : null;
}

public static NSValue valueWithRange(NSRange range) {
    objc.id result = OS.objc_msgSend(OS.class_NSNumber, OS.sel_valueWithRange_, range);
    return result !is null ? new NSValue(result) : null;
}

public static NSValue valueWithRect(NSRect rect) {
    objc.id result = OS.objc_msgSend(OS.class_NSNumber, OS.sel_valueWithRect_, rect);
    return result !is null ? new NSValue(result) : null;
}

public static NSValue valueWithSize(NSSize size) {
    objc.id result = OS.objc_msgSend(OS.class_NSNumber, OS.sel_valueWithSize_, size);
    return result !is null ? new NSValue(result) : null;
}

}
