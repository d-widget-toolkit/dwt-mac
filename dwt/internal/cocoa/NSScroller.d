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
module dwt.internal.cocoa.NSScroller;

import dwt.dwthelper.utils;
import dwt.internal.c.Carbon;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSControl;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;



public class NSScroller : NSControl {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSControlSize controlSize() {
    return cast(NSControlSize) OS.objc_msgSend(this.id, OS.sel_controlSize);
}

}

public NSScrollerPart hitPart() {
    return cast(NSScrollerPart) OS.objc_msgSend(this.id, OS.sel_hitPart);
}

public static float /*double*/ scrollerWidthForControlSize(int /*long*/ controlSize) {
    return (float)OS.objc_msgSend_fpret(OS.class_NSScroller, OS.sel_scrollerWidthForControlSize_, controlSize);
}

public void setControlSize(int /*long*/ controlSize) {
    OS.objc_msgSend(this.id, OS.sel_setControlSize_, controlSize);
}

public static CGFloat scrollerWidth() {
    return cast(CGFloat) OS.objc_msgSend_fpret(OS.class_NSScroller, OS.sel_scrollerWidth);
}

public static CGFloat scrollerWidthForControlSize(NSControlSize controlSize) {
    return cast(CGFloat)OS.objc_msgSend_fpret(OS.class_NSScroller, OS.sel_scrollerWidthForControlSize_, controlSize);
}

public void setControlSize(NSControlSize controlSize) {
    OS.objc_msgSend(this.id, OS.sel_setControlSize_, controlSize);
}

public void setFloatValue(float aFloat, CGFloat proportion) {
    OS.objc_msgSend(this.id, OS.sel_setFloatValue_knobProportion_, aFloat, proportion);
}

public static objc.Class cellClass() {
    return cast(objc.Class) OS.objc_msgSend(OS.class_NSScroller, OS.sel_cellClass);
}

public static void setCellClass(objc.Class factoryId) {
    OS.objc_msgSend(OS.class_NSScroller, OS.sel_setCellClass_, factoryId);
}

}
