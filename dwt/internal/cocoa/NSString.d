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
module dwt.internal.cocoa.NSString;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSRange;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSString : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public String getString() {
    wchar[] buffer = new wchar[length()];
    getCharacters(buffer.ptr);
    return dwt.dwthelper.utils.toString(buffer);
}

public wchar[] getString16() {
    wchar[] buffer = new wchar[length()];
    getCharacters(buffer.ptr);
    return buffer;
}

public static NSString stringWith(String str) {
    return stringWithUTF8String((str ~ '\0').ptr);
}

public static NSString stringWith16(wchar[] buffer) {
	return stringWithCharacters(buffer.ptr, buffer.length);
}

public /*const*/char* UTF8String() {
    return cast(/*const*/char*) OS.objc_msgSend(this.id, OS.sel_UTF8String);
}

public wchar characterAtIndex(NSUInteger index) {
    return cast(wchar) OS.objc_msgSend(this.id, OS.sel_characterAtIndex_, index);
}

public NSComparisonResult compare(NSString string) {
    return cast(NSComparisonResult) OS.objc_msgSend(this.id, OS.sel_compare_, string !is null ? string.id : null);
}

public /*const*/ char* fileSystemRepresentation() {
    return cast(/*const*/ char*) OS.objc_msgSend(this.id, OS.sel_fileSystemRepresentation);
}

public void getCharacters(wchar* buffer) {
    OS.objc_msgSend(this.id, OS.sel_getCharacters_, buffer);
}

public void getCharacters(wchar* buffer, NSRange aRange) {
    OS.objc_msgSend(this.id, OS.sel_getCharacters_range_, buffer, aRange);
}

public NSString initWithCharacters(/*const*/wchar* characters, NSUInteger length) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithCharacters_length_, characters, length);
    return result is this.id ? this : (result !is null ? new NSString(result) : null);
}

public bool isEqualToString(NSString aString) {
    return OS.objc_msgSend_bool(this.id, OS.sel_isEqualToString_, aString !is null ? aString.id : null);
}

public NSString lastPathComponent() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_lastPathComponent);
    return result is this.id ? this : (result !is null ? new NSString(result) : null);
}

public NSUInteger length() {
    return cast(NSUInteger) OS.objc_msgSend(this.id, OS.sel_length);
}

public NSString lowercaseString() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_lowercaseString);
    return result is this.id ? this : (result !is null ? new NSString(result) : null);
}

public NSString pathExtension() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_pathExtension);
    return result is this.id ? this : (result !is null ? new NSString(result) : null);
}

public NSString stringByAddingPercentEscapesUsingEncoding(NSStringEncoding enc) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_stringByAddingPercentEscapesUsingEncoding_, enc);
    return result is this.id ? this : (result !is null ? new NSString(result) : null);
}

public NSString stringByAppendingPathComponent(NSString str) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_stringByAppendingPathComponent_, str !is null ? str.id : null);
    return result is this.id ? this : (result !is null ? new NSString(result) : null);
}

public NSString stringByAppendingString(NSString aString) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_stringByAppendingString_, aString !is null ? aString.id : null);
    return result is this.id ? this : (result !is null ? new NSString(result) : null);
}

public NSString stringByDeletingLastPathComponent() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_stringByDeletingLastPathComponent);
    return result is this.id ? this : (result !is null ? new NSString(result) : null);
}

public NSString stringByDeletingPathExtension() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_stringByDeletingPathExtension);
    return result is this.id ? this : (result !is null ? new NSString(result) : null);
}

public NSString stringByReplacingOccurrencesOfString(NSString target, NSString replacement) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_stringByReplacingOccurrencesOfString_withString_, target !is null ? target.id : null, replacement !is null ? replacement.id : null);
    return result is this.id ? this : (result !is null ? new NSString(result) : null);
}

public static NSString stringWithCharacters(/*const*/wchar* characters, NSUInteger length) {
    objc.id result = OS.objc_msgSend(OS.class_NSString, OS.sel_stringWithCharacters_length_, characters, length);
    return result !is null ? new NSString(result) : null;
}

public static NSString stringWithFormat(NSString stringWithFormat) {
    int /*long*/ result = OS.objc_msgSend(OS.class_NSString, OS.sel_stringWithFormat_, stringWithFormat !is null ? stringWithFormat.id : 0);
}

public static NSString stringWithFormat(NSString stringWithFormat) {
    objc.id result = OS.objc_msgSend(OS.class_NSString, OS.sel_stringWithFormat_, stringWithFormat !is null ? stringWithFormat.id : null);
    return result !is mull ? new NSString(result) : null;
}

public static NSString stringWithUTF8String(/*const*/char* nullTerminatedCString) {
    objc.id result = OS.objc_msgSend(OS.class_NSString, OS.sel_stringWithUTF8String_, nullTerminatedCString);
    return result !is null ? new NSString(result) : null;
}

}