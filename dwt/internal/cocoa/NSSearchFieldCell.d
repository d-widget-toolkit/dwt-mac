/*******************************************************************************
 * Copyright (c) 2000, 2009 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *    IBM Corporation - initial API and implementation
 *******************************************************************************/
module dwt.internal.cocoa.NSSearchFieldCell;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSButtonCell;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSTextFieldCell;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSSearchFieldCell : NSTextFieldCell {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSButtonCell cancelButtonCell() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_cancelButtonCell);
    return result !is null ? new NSButtonCell(result) : null;
}

public NSButtonCell searchButtonCell() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_searchButtonCell);
    return result !is null ? new NSButtonCell(result) : null;
}

public NSRect searchTextRectForBounds(NSRect rect) {
    NSRect result = NSRect();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_searchTextRectForBounds_, rect);
    return result;
}

public void setCancelButtonCell(NSButtonCell cell) {
    OS.objc_msgSend(this.id, OS.sel_setCancelButtonCell_, cell !is null ? cell.id : null);
}

public void setSearchButtonCell(NSButtonCell cell) {
    OS.objc_msgSend(this.id, OS.sel_setSearchButtonCell_, cell !is null ? cell.id : null);
}

}
