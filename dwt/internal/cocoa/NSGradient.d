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
module dwt.internal.cocoa.NSGradient;

import dwt.dwthelper.utils;
import dwt.internal.c.Carbon;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSColor;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSGradient : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void drawFromPoint(NSPoint startingPoint, NSPoint endingPoint, NSGradientDrawingOptions options) {
    OS.objc_msgSend(this.id, OS.sel_drawFromPoint_toPoint_options_, startingPoint, endingPoint, options);
}

public void drawInRect(NSRect rect, CGFloat angle) {
    OS.objc_msgSend(this.id, OS.sel_drawInRect_angle_, rect, angle);
}

public NSGradient initWithStartingColor(NSColor startingColor, NSColor endingColor) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithStartingColor_endingColor_, startingColor !is null ? startingColor.id : null, endingColor !is null ? endingColor.id : null);
    return result is this.id ? this : (result !is null ? new NSGradient(result) : null);
}

}
