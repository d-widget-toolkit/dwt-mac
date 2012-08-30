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
module dwt.internal.cocoa.NSSlider;

import dwt.dwthelper.utils;
import dwt.internal.c.Carbon;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSControl;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSSlider : NSControl {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public CGFloat knobThickness() {
    return cast(CGFloat)OS.objc_msgSend_fpret(this.id, OS.sel_knobThickness);
}

public double maxValue() {
    return OS.objc_msgSend_fpret(this.id, OS.sel_maxValue);
}

public double minValue() {
    return OS.objc_msgSend_fpret(this.id, OS.sel_minValue);
}

public void setMaxValue(double aDouble) {
    OS.objc_msgSend(this.id, OS.sel_setMaxValue_, aDouble);
}

public void setMinValue(double aDouble) {
    OS.objc_msgSend(this.id, OS.sel_setMinValue_, aDouble);
}

public static objc.Class cellClass() {
    return cast(objc.Class) OS.objc_msgSend(OS.class_NSSlider, OS.sel_cellClass);
}

public static void setCellClass(objc.Class factoryId) {
    OS.objc_msgSend(OS.class_NSSlider, OS.sel_setCellClass_, factoryId);
}

}
