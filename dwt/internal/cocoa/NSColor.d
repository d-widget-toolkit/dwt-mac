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
module dwt.internal.cocoa.NSColor;

import dwt.dwthelper.utils;
import dwt.internal.c.Carbon;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSColorSpace;
import dwt.internal.cocoa.NSImage;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSColor : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public CGFloat alphaComponent() {
    return cast(CGFloat)OS.objc_msgSend_fpret(this.id, OS.sel_alphaComponent);
}

public static NSColor alternateSelectedControlColor() {
    objc.id result = OS.objc_msgSend(OS.class_NSColor, OS.sel_alternateSelectedControlColor);
    return result !is null ? new NSColor(result) : null;
}

public static NSColor alternateSelectedControlColor() {
    int /*long*/ result = OS.objc_msgSend(OS.class_NSColor, OS.sel_alternateSelectedControlColor);
    return result !is 0 ? new NSColor(result) : null;
}

public static NSColor alternateSelectedControlTextColor() {
    objc.id result = OS.objc_msgSend(OS.class_NSColor, OS.sel_alternateSelectedControlTextColor);
    return result !is null ? new NSColor(result) : null;
}

public static NSColor blackColor() {
    objc.id result = OS.objc_msgSend(OS.class_NSColor, OS.sel_blackColor);
    return result !is null ? new NSColor(result) : null;
}

public CGFloat blueComponent() {
    return cast(CGFloat)OS.objc_msgSend_fpret(this.id, OS.sel_blueComponent);
}

public static NSColor clearColor() {
    objc.id result = OS.objc_msgSend(OS.class_NSColor, OS.sel_clearColor);
    return result !is null ? new NSColor(result) : null;
}

public NSColor colorUsingColorSpace(NSColorSpace space) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_colorUsingColorSpace_, space !is null ? space.id : null);
    return result is this.id ? this : (result !is null ? new NSColor(result) : null);
}

public NSColor colorUsingColorSpaceName(NSString colorSpace) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_colorUsingColorSpaceName_, colorSpace !is null ? colorSpace.id : null);
    return result is this.id ? this : (result !is null ? new NSColor(result) : null);
}

public static NSColor colorWithDeviceRed(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) {
    objc.id result = objc.objc_msgSend(OS.class_NSColor, OS.sel_colorWithDeviceRed_green_blue_alpha_, red, green, blue, alpha);
    return result !is null ? new NSColor(result) : null;
}

public static NSColor colorWithPatternImage(NSImage image) {
    objc.id result = OS.objc_msgSend(OS.class_NSColor, OS.sel_colorWithPatternImage_, image !is null ? image.id : null);
    return result !is null ? new NSColor(result) : null;
}

public static NSColor controlBackgroundColor() {
    objc.id result = OS.objc_msgSend(OS.class_NSColor, OS.sel_controlBackgroundColor);
    return result !is null ? new NSColor(result) : null;
}

public static NSColor controlBackgroundColor() {
    int /*long*/ result = OS.objc_msgSend(OS.class_NSColor, OS.sel_controlBackgroundColor);
    return result !is 0 ? new NSColor(result) : null;
}

public static NSColor controlDarkShadowColor() {
    objc.id result = OS.objc_msgSend(OS.class_NSColor, OS.sel_controlDarkShadowColor);
    return result !is null ? new NSColor(result) : null;
}

public static NSColor controlHighlightColor() {
    objc.id result = OS.objc_msgSend(OS.class_NSColor, OS.sel_controlHighlightColor);
    return result !is null ? new NSColor(result) : null;
}

public static NSColor controlLightHighlightColor() {
    objc.id result = OS.objc_msgSend(OS.class_NSColor, OS.sel_controlLightHighlightColor);
    return result !is null ? new NSColor(result) : null;
}

public static NSColor controlShadowColor() {
    objc.id result = OS.objc_msgSend(OS.class_NSColor, OS.sel_controlShadowColor);
    return result !is null ? new NSColor(result) : null;
}

public static NSColor controlTextColor() {
    objc.id result = OS.objc_msgSend(OS.class_NSColor, OS.sel_controlTextColor);
    return result !is null ? new NSColor(result) : null;
}

public static NSColor disabledControlTextColor() {
    objc.id result = OS.objc_msgSend(OS.class_NSColor, OS.sel_disabledControlTextColor);
    return result !is null ? new NSColor(result) : null;
}

public void getComponents(CGFloat* components) {
    OS.objc_msgSend(this.id, OS.sel_getComponents_, components);
}

public CGFloat greenComponent() {
    return cast(CGFloat)OS.objc_msgSend_fpret(this.id, OS.sel_greenComponent);
}

public NSInteger numberOfComponents() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_numberOfComponents);
}

public CGFloat redComponent() {
    return cast(CGFloat)OS.objc_msgSend_fpret(this.id, OS.sel_redComponent);
}

public static NSColor secondarySelectedControlColor() {
    objc.id result = OS.objc_msgSend(OS.class_NSColor, OS.sel_secondarySelectedControlColor);
    return result !is null ? new NSColor(result) : null;
}

public static NSColor selectedControlColor() {
    objc.id result = OS.objc_msgSend(OS.class_NSColor, OS.sel_selectedControlColor);
    return result !is null ? new NSColor(result) : null;
}

public static NSColor selectedControlTextColor() {
    objc.id result = OS.objc_msgSend(OS.class_NSColor, OS.sel_selectedControlTextColor);
    return result !is null ? new NSColor(result) : null;
}

public static NSColor selectedTextBackgroundColor() {
    objc.id result = OS.objc_msgSend(OS.class_NSColor, OS.sel_selectedTextBackgroundColor);
    return result !is null ? new NSColor(result) : null;
}

public static NSColor selectedTextColor() {
    objc.id result = OS.objc_msgSend(OS.class_NSColor, OS.sel_selectedTextColor);
    return result !is null ? new NSColor(result) : null;
}

public void set() {
    OS.objc_msgSend(this.id, OS.sel_set);
}

public void setFill() {
    OS.objc_msgSend(this.id, OS.sel_setFill);
}

public void setStroke() {
    OS.objc_msgSend(this.id, OS.sel_setStroke);
}

public static NSColor textBackgroundColor() {
    objc.id result = OS.objc_msgSend(OS.class_NSColor, OS.sel_textBackgroundColor);
    return result !is null ? new NSColor(result) : null;
}

public static NSColor textColor() {
    objc.id result = OS.objc_msgSend(OS.class_NSColor, OS.sel_textColor);
    return result !is null ? new NSColor(result) : null;
}

public static NSColor windowBackgroundColor() {
    objc.id result = OS.objc_msgSend(OS.class_NSColor, OS.sel_windowBackgroundColor);
    return result !is null ? new NSColor(result) : null;
}

public static NSColor windowFrameColor() {
    objc.id result = OS.objc_msgSend(OS.class_NSColor, OS.sel_windowFrameColor);
    return result !is null ? new NSColor(result) : null;
}

public static NSColor windowFrameTextColor() {
    objc.id result = OS.objc_msgSend(OS.class_NSColor, OS.sel_windowFrameTextColor);
    return result !is null ? new NSColor(result) : null;
}

}
