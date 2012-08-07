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
module dwt.internal.cocoa.NSStepper;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSControl;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSStepper : NSControl {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public double increment() {
    return OS.objc_msgSend_fpret(this.id, OS.sel_increment);
}

public double maxValue() {
    return OS.objc_msgSend_fpret(this.id, OS.sel_maxValue);
}

public double minValue() {
    return OS.objc_msgSend_fpret(this.id, OS.sel_minValue);
}

public void setIncrement(double increment) {
    OS.objc_msgSend(this.id, OS.sel_setIncrement_, increment);
}

public void setMaxValue(double maxValue) {
    OS.objc_msgSend(this.id, OS.sel_setMaxValue_, maxValue);
}

public void setMinValue(double minValue) {
    OS.objc_msgSend(this.id, OS.sel_setMinValue_, minValue);
}

public void setValueWraps(bool valueWraps) {
    OS.objc_msgSend(this.id, OS.sel_setValueWraps_, valueWraps);
}

public static objc.Class cellClass() {
    return cast(objc.Class) OS.objc_msgSend(OS.class_NSStepper, OS.sel_cellClass);
}

public static void setCellClass(objc.Class factoryId) {
    OS.objc_msgSend(OS.class_NSStepper, OS.sel_setCellClass_, factoryId);
}

}
