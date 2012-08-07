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
module dwt.internal.cocoa.NSGraphicsContext;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSBitmapImageRep;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSWindow;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSGraphicsContext : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public static NSGraphicsContext currentContext() {
    objc.id result = OS.objc_msgSend(OS.class_NSGraphicsContext, OS.sel_currentContext);
    return result !is null ? new NSGraphicsContext(result) : null;
}

public void flushGraphics() {
    OS.objc_msgSend(this.id, OS.sel_flushGraphics);
}

public static NSGraphicsContext graphicsContextWithBitmapImageRep(NSBitmapImageRep bitmapRep) {
    objc.id result = OS.objc_msgSend(OS.class_NSGraphicsContext, OS.sel_graphicsContextWithBitmapImageRep_, bitmapRep !is null ? bitmapRep.id : null);
    return result !is null ? new NSGraphicsContext(result) : null;
}

public static NSGraphicsContext graphicsContextWithGraphicsPort(void* graphicsPort, bool initialFlippedState) {
    objc.id result = OS.objc_msgSend(OS.class_NSGraphicsContext, OS.sel_graphicsContextWithGraphicsPort_flipped_, graphicsPort, initialFlippedState);
    return result !is null ? new NSGraphicsContext(result) : null;
}

public static NSGraphicsContext graphicsContextWithGraphicsPort(int /*long*/ graphicsPort, bool initialFlippedState) {
    int /*long*/ result = OS.objc_msgSend(OS.class_NSGraphicsContext, OS.sel_graphicsContextWithGraphicsPort_flipped_, graphicsPort, initialFlippedState);
    return result !is 0 ? new NSGraphicsContext(result) : null;
}

public static NSGraphicsContext graphicsContextWithWindow(NSWindow window) {
    objc.id result = OS.objc_msgSend(OS.class_NSGraphicsContext, OS.sel_graphicsContextWithWindow_, window !is null ? window.id : null);
    return result !is null ? new NSGraphicsContext(result) : null;
}

public void* graphicsPort() {
    return cast(void*) OS.objc_msgSend(this.id, OS.sel_graphicsPort);
}

public NSImageInterpolation imageInterpolation() {
    return cast(NSImageInterpolation) OS.objc_msgSend(this.id, OS.sel_imageInterpolation);
}

public bool isDrawingToScreen() {
    return OS.objc_msgSend_bool(this.id, OS.sel_isDrawingToScreen);
}

public bool isDrawingToScreen() {
    return OS.objc_msgSend_bool(this.id, OS.sel_isDrawingToScreen);
}

public void restoreGraphicsState() {
    OS.objc_msgSend(this.id, OS.sel_restoreGraphicsState);
}

public static void static_restoreGraphicsState() {
    OS.objc_msgSend(OS.class_NSGraphicsContext, OS.sel_restoreGraphicsState);
}

public void saveGraphicsState() {
    OS.objc_msgSend(this.id, OS.sel_saveGraphicsState);
}

public static void static_saveGraphicsState() {
    OS.objc_msgSend(OS.class_NSGraphicsContext, OS.sel_saveGraphicsState);
}

public void setCompositingOperation(NSCompositingOperation operation) {
    OS.objc_msgSend(this.id, OS.sel_setCompositingOperation_, operation);
}

public static void setCurrentContext(NSGraphicsContext context) {
    OS.objc_msgSend(OS.class_NSGraphicsContext, OS.sel_setCurrentContext_, context !is null ? context.id : null);
}

public void setImageInterpolation(NSImageInterpolation interpolation) {
    OS.objc_msgSend(this.id, OS.sel_setImageInterpolation_, interpolation);
}

public void setPatternPhase(NSPoint phase) {
    OS.objc_msgSend(this.id, OS.sel_setPatternPhase_, phase);
}

public void setShouldAntialias(bool antialias) {
    OS.objc_msgSend(this.id, OS.sel_setShouldAntialias_, antialias);
}

public bool shouldAntialias() {
    return OS.objc_msgSend_bool(this.id, OS.sel_shouldAntialias);
}

}
