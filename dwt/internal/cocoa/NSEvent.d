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
module dwt.internal.cocoa.NSEvent;

import dwt.dwthelper.utils;
import dwt.internal.c.Carbon;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSDate;
import dwt.internal.cocoa.NSGraphicsContext;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSWindow;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSEvent : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public CGEventRef CGEvent() {
    return cast(CGEventRef) OS.objc_msgSend(this.id, OS.sel_CGEvent);
}

public NSInteger buttonNumber() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_buttonNumber);
}

public NSString characters() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_characters);
    return result !is null ? new NSString(result) : null;
}

public NSString charactersIgnoringModifiers() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_charactersIgnoringModifiers);
    return result !is null ? new NSString(result) : null;
}

public NSInteger clickCount() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_clickCount);
}

public CGFloat deltaX() {
    return cast(CGFloat) OS.objc_msgSend_fpret(this.id, OS.sel_deltaX);
}

public CGFloat deltaY() {
    return cast(CGFloat) OS.objc_msgSend_fpret(this.id, OS.sel_deltaY);
}

public static NSEvent enterExitEventWithType(NSEventType type, NSPoint location, NSUInteger flags, double time, NSInteger wNum, NSGraphicsContext context, NSInteger eNum, NSInteger tNum, void* data) {
    objc.id result = OS.objc_msgSend(OS.class_NSEvent, OS.sel_enterExitEventWithType_location_modifierFlags_timestamp_windowNumber_context_eventNumber_trackingNumber_userData_, type, location, flags, time, wNum, context !is null ? context.id : null, eNum, tNum, data);
    return result !is null ? new NSEvent(result) : null;
}

public ushort keyCode() {
    return cast(ushort) OS.objc_msgSend(this.id, OS.sel_keyCode);
}

public NSPoint locationInWindow() {
    NSPoint result = NSPoint();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_locationInWindow);
    return result;
}

public NSUInteger modifierFlags() {
    return cast(NSUInteger) OS.objc_msgSend(this.id, OS.sel_modifierFlags);
}

public static NSPoint mouseLocation() {
    NSPoint result = NSPoint();
    OS.objc_msgSend_stret(&result, OS.class_NSEvent, OS.sel_mouseLocation);
    return result;
}

public static NSEvent otherEventWithType(NSEventType type, NSPoint location, NSUInteger flags, double time, NSTimeInterval wNum, NSGraphicsContext context, short subtype, NSInteger d1, NSInteger d2) {
    objc.id result = OS.objc_msgSend(OS.class_NSEvent, OS.sel_otherEventWithType_location_modifierFlags_timestamp_windowNumber_context_subtype_data1_data2_, type, location, flags, time, wNum, context !is null ? context.id : null, subtype, d1, d2);
    return result !is null ? new NSEvent(result) : null;
}

public double timestamp() {
    return OS.objc_msgSend_fpret(this.id, OS.sel_timestamp);
}

public NSEventType type() {
    return cast(NSEventType) OS.objc_msgSend(this.id, OS.sel_type);
}

public NSWindow window() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_window);
    return result !is null ? new NSWindow(result) : null;
}

}
