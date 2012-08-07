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
module dwt.internal.cocoa.NSControl;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSCell;
import dwt.internal.cocoa.NSFont;
import dwt.internal.cocoa.NSFormatter;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSText;
import dwt.internal.cocoa.NSView;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSControl : NSView {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public bool abortEditing() {
    return OS.objc_msgSend_bool(this.id, OS.sel_abortEditing);
}

public objc.SEL action() {
    return cast(objc.SEL) OS.objc_msgSend(this.id, OS.sel_action);
}

public NSCell cell() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_cell);
    return result !is null ? new NSCell(result) : null;
}

public static objc.Class cellClass() {
    return cast(objc.Class) OS.objc_msgSend(OS.class_NSControl, OS.sel_cellClass);
}

public NSText currentEditor() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_currentEditor);
    return result !is null ? new NSText(result) : null;
}

public double doubleValue() {
    return OS.objc_msgSend_fpret(this.id, OS.sel_doubleValue);
}

public NSFont font() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_font);
    return result !is null ? new NSFont(result) : null;
}

public bool isEnabled() {
    return OS.objc_msgSend_bool(this.id, OS.sel_isEnabled);
}

}

public bool sendAction(objc.SEL theAction, cocoa.id theTarget) {
    return OS.objc_msgSend_bool(this.id, OS.sel_sendAction_to_, theAction, theTarget !is null ? theTarget.id : null);
}

public void setAction(objc.SEL aSelector) {
    OS.objc_msgSend(this.id, OS.sel_setAction_, aSelector);
}

public void setAlignment(NSTextAlignment mode) {
    OS.objc_msgSend(this.id, OS.sel_setAlignment_, mode);
}

public void setCell(NSCell aCell) {
    OS.objc_msgSend(this.id, OS.sel_setCell_, aCell !is null ? aCell.id : 0);
}

public void setCell(NSCell aCell) {
    OS.objc_msgSend(this.id, OS.sel_setCell_, aCell !is null ? aCell.id : 0);
}

public static void setCellClass(objc.Class factoryId) {
    OS.objc_msgSend(OS.class_NSControl, OS.sel_setCellClass_, factoryId);
}

public void setDoubleValue(double aDouble) {
    OS.objc_msgSend(this.id, OS.sel_setDoubleValue_, aDouble);
}

public void setEnabled(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setEnabled_, flag);
}

public void setFont(NSFont fontObj) {
    OS.objc_msgSend(this.id, OS.sel_setFont_, fontObj !is null ? fontObj.id : null);
}

public void setFormatter(NSFormatter newFormatter) {
    OS.objc_msgSend(this.id, OS.sel_setFormatter_, newFormatter !is null ? newFormatter.id : null);
}

public void setStringValue(NSString aString) {
    OS.objc_msgSend(this.id, OS.sel_setStringValue_, aString !is null ? aString.id : null);
}

public void setTarget(cocoa.id anObject) {
    OS.objc_msgSend(this.id, OS.sel_setTarget_, anObject !is null ? anObject.id : null);
}

public void sizeToFit() {
    OS.objc_msgSend(this.id, OS.sel_sizeToFit);
}

public NSString stringValue() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_stringValue);
    return result !is null ? new NSString(result) : null;
}

public cocoa.id target() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_target);
    return result !is null ? new cocoa.id(result) : null;
}

}
