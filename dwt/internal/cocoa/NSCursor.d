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
module dwt.internal.cocoa.NSCursor;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSImage;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSCursor : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public static NSCursor IBeamCursor() {
    objc.id result = OS.objc_msgSend(OS.class_NSCursor, OS.sel_IBeamCursor);
    return result !is null ? new NSCursor(result) : null;
}

public static NSCursor arrowCursor() {
    objc.id result = OS.objc_msgSend(OS.class_NSCursor, OS.sel_arrowCursor);
    return result !is null ? new NSCursor(result) : null;
}

public static NSCursor crosshairCursor() {
    objc.id result = OS.objc_msgSend(OS.class_NSCursor, OS.sel_crosshairCursor);
    return result !is null ? new NSCursor(result) : null;
}

public static NSCursor currentCursor() {
    objc.id result = OS.objc_msgSend(OS.class_NSCursor, OS.sel_currentCursor);
    return result !is null ? new NSCursor(result) : null;
}

public NSCursor initWithImage(NSImage newImage, NSPoint aPoint) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithImage_hotSpot_, newImage !is null ? newImage.id : null, aPoint);
    return result is this.id ? this : (result !is null ? new NSCursor(result) : null);
}

public static NSCursor pointingHandCursor() {
    objc.id result = OS.objc_msgSend(OS.class_NSCursor, OS.sel_pointingHandCursor);
    return result !is null ? new NSCursor(result) : null;
}

public static void pop() {
    OS.objc_msgSend(OS.class_NSCursor, OS.sel_pop);
}

public void push() {
    OS.objc_msgSend(this.id, OS.sel_push);
}

public static NSCursor resizeDownCursor() {
    objc.id result = OS.objc_msgSend(OS.class_NSCursor, OS.sel_resizeDownCursor);
    return result !is null ? new NSCursor(result) : null;
}

public static NSCursor resizeLeftCursor() {
    objc.id result = OS.objc_msgSend(OS.class_NSCursor, OS.sel_resizeLeftCursor);
    return result !is null ? new NSCursor(result) : null;
}

public static NSCursor resizeLeftRightCursor() {
    objc.id result = OS.objc_msgSend(OS.class_NSCursor, OS.sel_resizeLeftRightCursor);
    return result !is null ? new NSCursor(result) : null;
}

public static NSCursor resizeRightCursor() {
    objc.id result = OS.objc_msgSend(OS.class_NSCursor, OS.sel_resizeRightCursor);
    return result !is null ? new NSCursor(result) : null;
}

public static NSCursor resizeUpCursor() {
    objc.id result = OS.objc_msgSend(OS.class_NSCursor, OS.sel_resizeUpCursor);
    return result !is null ? new NSCursor(result) : null;
}

public static NSCursor resizeUpDownCursor() {
    objc.id result = OS.objc_msgSend(OS.class_NSCursor, OS.sel_resizeUpDownCursor);
    return result !is null ? new NSCursor(result) : null;
}

public void set() {
    OS.objc_msgSend(this.id, OS.sel_set);
}

public static void setHiddenUntilMouseMoves(bool flag) {
    OS.objc_msgSend(OS.class_NSCursor, OS.sel_setHiddenUntilMouseMoves_, flag);
}

public void setOnMouseEntered(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setOnMouseEntered_, flag);
}

}
