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
module dwt.internal.cocoa.NSObject;

import dwt.dwthelper.utils;
import dwt.internal.cocoa.DOMEvent;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSImage;
import dwt.internal.cocoa.NSNotification;
import dwt.internal.cocoa.NSOutlineView;
import dwt.internal.cocoa.NSPasteboard;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSTableColumn;
import dwt.internal.cocoa.NSTableView;
import dwt.internal.cocoa.NSURL;
import dwt.internal.cocoa.NSURLAuthenticationChallenge;
import dwt.internal.cocoa.NSURLCredential;
import dwt.internal.cocoa.NSWindow;
import dwt.internal.cocoa.OS;
import dwt.internal.cocoa.Protocol;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSObject : cocoa.id {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSObject alloc() {
    this.id = OS.objc_msgSend(objc_getClass(), OS.sel_alloc);
    return this;
}

public cocoa.id accessibilityAttributeValue(NSString attribute, cocoa.id parameter) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_accessibilityAttributeValue_forParameter_, attribute !is null ? attribute.id : null, parameter !is null ? parameter.id : null);
    return result !is null ? new id(result) : null;
}

public bool accessibilitySetOverrideValue(id value, NSString attribute) {
    return OS.objc_msgSend_bool(this.id, OS.sel_accessibilitySetOverrideValue_forAttribute_, value !is null ? value.id : null, attribute !is null ? attribute.id : null);
}

public void draggedImage(NSImage image, NSPoint screenPoint, NSDragOperation operation) {
    OS.objc_msgSend(this.id, OS.sel_draggedImage_endedAt_operation_, image !is null ? image.id : null, screenPoint, operation);
}

public NSWindow draggingDestinationWindow() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_draggingDestinationWindow);
    return result !is null ? new NSWindow(result) : null;
}

public NSPoint draggingLocation() {
    NSPoint result = NSPoint();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_draggingLocation);
    return result;
}

public NSPasteboard draggingPasteboard() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_draggingPasteboard);
    return result !is null ? new NSPasteboard(result) : null;
}

public NSDragOperation draggingSourceOperationMask() {
    return cast(NSDragOperation) OS.objc_msgSend(this.id, OS.sel_draggingSourceOperationMask);
}

public NSObject autorelease() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_autorelease);
    return result is this.id ? this : (result !is null ? new NSObject(result) : null);
}

public void cancelAuthenticationChallenge(NSURLAuthenticationChallenge challenge) {
    OS.objc_msgSend(this.id, OS.sel_cancelAuthenticationChallenge_, challenge !is null ? challenge.id : null);
}

public NSString className() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_className);
    return result !is null ? new NSString(result) : null;
}

public bool conformsToProtocol(Protocol aProtocol) {
    return OS.objc_msgSend_bool(this.id, OS.sel_conformsToProtocol_, aProtocol !is null ? aProtocol.id : null);
}

public cocoa.id copy() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_copy);
    return result !is null ? new cocoa.id(result) : null;
}

public NSString description() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_description);
    return result !is null ? new NSString(result) : null;
}

public NSObject init() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_init);
    return result is this.id ? this : (result !is null ? new NSObject(result) : null);
}

public bool isEqual(cocoa.id object) {
    return OS.objc_msgSend_bool(this.id, OS.sel_isEqual_, object !is null ? object.id : null);
}

public bool isEqualTo(cocoa.id object) {
    return OS.objc_msgSend_bool(this.id, OS.sel_isEqualTo_, object !is null ? object.id : null);
}

public bool isKindOfClass(objc.Class aClass) {
    return OS.objc_msgSend_bool(this.id, OS.sel_isKindOfClass_, aClass);
}

public cocoa.id mutableCopy() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_mutableCopy);
    return result !is null ? new cocoa.id(result) : null;
}

public void performSelectorOnMainThread(objc.SEL aSelector, cocoa.id arg, bool wait) {
    OS.objc_msgSend(this.id, OS.sel_performSelectorOnMainThread_withObject_waitUntilDone_, aSelector, arg !is null ? arg.id : null, wait);
}

public void release() {
    OS.objc_msgSend(this.id, OS.sel_release);
}

public bool respondsToSelector(objc.SEL aSelector) {
    return OS.objc_msgSend_bool(this.id, OS.sel_respondsToSelector_, aSelector);
}

public cocoa.id retain() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_retain);
    return result !is null ? new cocoa.id(result) : null;
}

public NSUInteger retainCount() {
    return cast(NSUInteger) OS.objc_msgSend(this.id, OS.sel_retainCount);
}

public void setValue(cocoa.id value, NSString key) {
    OS.objc_msgSend(this.id, OS.sel_setValue_forKey_, value !is null ? value.id : null, key !is null ? key.id : null);
}

public objc.Class superclass() {
    return cast(objc.Class) OS.objc_msgSend(this.id, OS.sel_superclass);
}

public void useCredential(NSURLCredential credential, NSURLAuthenticationChallenge challenge) {
    OS.objc_msgSend(this.id, OS.sel_useCredential_forAuthenticationChallenge_, credential !is null ? credential.id : null, challenge !is null ? challenge.id : null);
}

public cocoa.id valueForKey(NSString key) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_valueForKey_, key !is null ? key.id : null);
    return result !is null ? new cocoa.id(result) : null;
}

public void addEventListener(NSString type, cocoa.id listener, bool useCapture) {
    OS.objc_msgSend(this.id, OS.sel_addEventListener_listener_useCapture_, type !is null ? type.id : null, listener !is null ? listener.id : null, useCapture);
}

public void handleEvent(DOMEvent evt) {
    OS.objc_msgSend(this.id, OS.sel_handleEvent_, evt !is null ? evt.id : null);
}

}
