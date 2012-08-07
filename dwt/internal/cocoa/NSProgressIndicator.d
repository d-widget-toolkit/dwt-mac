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
module dwt.internal.cocoa.NSProgressIndicator;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSView;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSProgressIndicator : NSView {

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

public double doubleValue() {
    return OS.objc_msgSend_fpret(this.id, OS.sel_doubleValue);
}

public double maxValue() {
    return OS.objc_msgSend_fpret(this.id, OS.sel_maxValue);
}

public double minValue() {
    return OS.objc_msgSend_fpret(this.id, OS.sel_minValue);
}

public void setControlSize(NSControlSize size) {
    OS.objc_msgSend(this.id, OS.sel_setControlSize_, size);
}

public void setDoubleValue(double doubleValue) {
    OS.objc_msgSend(this.id, OS.sel_setDoubleValue_, doubleValue);
}

public void setIndeterminate(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setIndeterminate_, flag);
}

public void setMaxValue(double newMaximum) {
    OS.objc_msgSend(this.id, OS.sel_setMaxValue_, newMaximum);
}

public void setMinValue(double newMinimum) {
    OS.objc_msgSend(this.id, OS.sel_setMinValue_, newMinimum);
}

public void setUsesThreadedAnimation(bool threadedAnimation) {
    OS.objc_msgSend(this.id, OS.sel_setUsesThreadedAnimation_, threadedAnimation);
}

public void sizeToFit() {
    OS.objc_msgSend(this.id, OS.sel_sizeToFit);
}

public void startAnimation(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_startAnimation_, sender !is null ? sender.id : null);
}

public void stopAnimation(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_stopAnimation_, sender !is null ? sender.id : null);
}

}
