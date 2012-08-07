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
module dwt.internal.cocoa.NSAttributedString;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSDictionary;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSRange;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.NSTextAttachment;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSAttributedString : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public static NSAttributedString attributedStringWithAttachment(NSTextAttachment attachment) {
    int /*long*/ result = OS.objc_msgSend(OS.class_NSAttributedString, OS.sel_attributedStringWithAttachment_, attachment !is null ? attachment.id : 0);
    return result !is 0 ? new NSAttributedString(result) : null;
}

public static NSAttributedString attributedStringWithAttachment(NSTextAttachment attachment) {
    objc.id result = OS.objc_msgSend(OS.class_NSAttributedString, OS.sel_attributedStringWithAttachment_, attachment !is null ? attachment.id : null);
    return result !is null ? new NSAttributedString(result) : null;
}

public NSDictionary attributesAtIndex(NSUInteger location, NSRangePointer range, NSRange rangeLimit) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_attributesAtIndex_longestEffectiveRange_inRange_, location, range, rangeLimit);
    return result !is null ? new NSDictionary(result) : null;
}

public NSRange doubleClickAtIndex(NSUInteger location) {
    NSRange result = NSRange();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_doubleClickAtIndex_, location);
    return result;
}

public void drawAtPoint(NSPoint point) {
    OS.objc_msgSend(this.id, OS.sel_drawAtPoint_, point);
}

public void drawInRect(NSRect rect) {
    OS.objc_msgSend(this.id, OS.sel_drawInRect_, rect);
}

public NSAttributedString initWithString(NSString str, NSDictionary attrs) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithString_attributes_, str !is null ? str.id : null, attrs !is null ? attrs.id : null);
    return result is this.id ? this : (result !is null ? new NSAttributedString(result) : null);
}

public NSUInteger nextWordFromIndex(NSUInteger location, bool isForward) {
    return cast(NSUInteger) OS.objc_msgSend(this.id, OS.sel_nextWordFromIndex_forward_, location, isForward);
}

public NSSize size() {
    NSSize result = NSSize();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_size);
    return result;
}

public NSAttributedString attributedSubstringFromRange(NSRange range) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_attributedSubstringFromRange_, range);
    return result is this.id ? this : (result !is null ? new NSAttributedString(result) : null);
}

public NSAttributedString initWithString(NSString str) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithString_, str !is null ? str.id : null);
    return result is this.id ? this : (result !is null ? new NSAttributedString(result) : null);
}

public NSUInteger length() {
    return cast(NSUInteger) OS.objc_msgSend(this.id, OS.sel_length);
}

public NSString string() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_string);
    return result !is null ? new NSString(result) : null;
}

}
