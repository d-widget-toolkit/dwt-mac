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
module dwt.internal.cocoa.NSDatePicker;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSColor;
import dwt.internal.cocoa.NSControl;
import dwt.internal.cocoa.NSDate;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSDatePicker : NSControl {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSDate dateValue() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_dateValue);
    return result !is null ? new NSDate(result) : null;
}

public void setBackgroundColor(NSColor color) {
    OS.objc_msgSend(this.id, OS.sel_setBackgroundColor_, color !is null ? color.id : null);
}

public void setDatePickerElements(NSDatePickerElementFlags elementFlags) {
    OS.objc_msgSend(this.id, OS.sel_setDatePickerElements_, elementFlags);
}

public void setDatePickerStyle(NSDatePickerStyle newStyle) {
    OS.objc_msgSend(this.id, OS.sel_setDatePickerStyle_, newStyle);
}

public void setDateValue(NSDate newStartDate) {
    OS.objc_msgSend(this.id, OS.sel_setDateValue_, newStartDate !is null ? newStartDate.id : null);
}

public void setDrawsBackground(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setDrawsBackground_, flag);
}

public void setTextColor(NSColor color) {
    OS.objc_msgSend(this.id, OS.sel_setTextColor_, color !is null ? color.id : null);
}

public static objc.Class cellClass() {
    return cast(objc.Class)OS.objc_msgSend(OS.class_NSDatePicker, OS.sel_cellClass);
}

public static void setCellClass(objc.Class factoryId) {
    OS.objc_msgSend(OS.class_NSDatePicker, OS.sel_setCellClass_, factoryId);
}

}
