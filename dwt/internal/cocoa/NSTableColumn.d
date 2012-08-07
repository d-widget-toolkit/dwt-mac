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
module dwt.internal.cocoa.NSTableColumn;

import dwt.dwthelper.utils;
import dwt.internal.c.Carbon;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSCell;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSTableHeaderCell;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSTableColumn : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSCell dataCell() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_dataCell);
    return result !is null ? new NSCell(result) : null;
}

public NSTableHeaderCell headerCell() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_headerCell);
    return result !is null ? new NSTableHeaderCell(result) : null;
}

public NSTableColumn initWithIdentifier(cocoa.id identifier) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithIdentifier_, identifier !is null ? identifier.id : null);
    return result is this.id ? this : (result !is null ? new NSTableColumn(result) : null);
}

public NSUInteger resizingMask() {
    return cast(NSUInteger) OS.objc_msgSend(this.id, OS.sel_resizingMask);
}

public void setDataCell(NSCell cell) {
    OS.objc_msgSend(this.id, OS.sel_setDataCell_, cell !is null ? cell.id : null);
}

public void setEditable(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setEditable_, flag);
}

public void setHeaderCell(NSCell cell) {
    OS.objc_msgSend(this.id, OS.sel_setHeaderCell_, cell !is null ? cell.id : null);
}

public void setIdentifier(cocoa.id identifier) {
    OS.objc_msgSend(this.id, OS.sel_setIdentifier_, identifier !is null ? identifier.id : null);
}

public void setMinWidth(CGFloat minWidth) {
    OS.objc_msgSend(this.id, OS.sel_setMinWidth_, minWidth);
}

public void setResizingMask(NSUInteger resizingMask) {
    OS.objc_msgSend(this.id, OS.sel_setResizingMask_, resizingMask);
}

public void setWidth(CGFloat width) {
    OS.objc_msgSend(this.id, OS.sel_setWidth_, width);
}

public CGFloat width() {
    return cast(CGFloat) OS.objc_msgSend_fpret(this.id, OS.sel_width);
}

}
