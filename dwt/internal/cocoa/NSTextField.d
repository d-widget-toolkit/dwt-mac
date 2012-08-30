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
module dwt.internal.cocoa.NSTextField;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSColor;
import dwt.internal.cocoa.NSControl;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSTextField : NSControl {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void selectText(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_selectText_, sender !is null ? sender.id : null);
}

public void setBackgroundColor(NSColor color) {
    OS.objc_msgSend(this.id, OS.sel_setBackgroundColor_, color !is null ? color.id : null);
}

public void setBordered(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setBordered_, flag);
}

public void setDelegate(cocoa.id anObject) {
    OS.objc_msgSend(this.id, OS.sel_setDelegate_, anObject !is null ? anObject.id : null);
}

public void setDrawsBackground(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setDrawsBackground_, flag);
}

public void setEditable(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setEditable_, flag);
}

public void setSelectable(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setSelectable_, flag);
}

public void setTextColor(NSColor color) {
    OS.objc_msgSend(this.id, OS.sel_setTextColor_, color !is null ? color.id : null);
}

public static objc.Class cellClass() {
    return cast(objc.Class) OS.objc_msgSend(OS.class_NSTextField, OS.sel_cellClass);
}

public static void setCellClass(objc.Class factoryId) {
    OS.objc_msgSend(OS.class_NSTextField, OS.sel_setCellClass_, factoryId);
}

}
