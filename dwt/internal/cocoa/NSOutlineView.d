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
module dwt.internal.cocoa.NSOutlineView;

import dwt.dwthelper.utils;
import dwt.internal.c.Carbon;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSTableColumn;
import dwt.internal.cocoa.NSTableView;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSOutlineView : NSTableView {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void collapseItem(cocoa.id item) {
    OS.objc_msgSend(this.id, OS.sel_collapseItem_, item !is null ? item.id : null);
}

public void collapseItem(cocoa.id item, bool collapseChildren) {
    OS.objc_msgSend(this.id, OS.sel_collapseItem_collapseChildren_, item !is null ? item.id : null, collapseChildren);
}

public void expandItem(cocoa.id item) {
    OS.objc_msgSend(this.id, OS.sel_expandItem_, item !is null ? item.id : null);
}

public void expandItem(cocoa.id item, bool expandChildren) {
    OS.objc_msgSend(this.id, OS.sel_expandItem_expandChildren_, item !is null ? item.id : null, expandChildren);
}

public NSRect frameOfOutlineCellAtRow(NSInteger row) {
    NSRect result = NSRect();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_frameOfOutlineCellAtRow_, row);
    return result;
}

public CGFloat indentationPerLevel() {
    return cast(CGFloat)OS.objc_msgSend_fpret(this.id, OS.sel_indentationPerLevel);
}

public bool isItemExpanded(cocoa.id item) {
    return OS.objc_msgSend_bool(this.id, OS.sel_isItemExpanded_, item !is null ? item.id : null);
}

public cocoa.id itemAtRow(NSInteger row) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_itemAtRow_, row);
    return result !is null ? new cocoa.id(result) : null;
}

public NSInteger levelForItem(cocoa.id item) {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_levelForItem_, item !is null ? item.id : null);
}

public NSTableColumn outlineTableColumn() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_outlineTableColumn);
    return result !is null ? new NSTableColumn(result) : null;
}

public void reloadItem(cocoa.id item, bool reloadChildren) {
    OS.objc_msgSend(this.id, OS.sel_reloadItem_reloadChildren_, item !is null ? item.id : null, reloadChildren);
}

public NSInteger rowForItem(cocoa.id item) {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_rowForItem_, item !is null ? item.id : null);
}

public void setAutoresizesOutlineColumn(bool resize) {
    OS.objc_msgSend(this.id, OS.sel_setAutoresizesOutlineColumn_, resize);
}

public void setAutosaveExpandedItems(bool save) {
    OS.objc_msgSend(this.id, OS.sel_setAutosaveExpandedItems_, save);
}

public void setDropItem(cocoa.id item, NSInteger index) {
    OS.objc_msgSend(this.id, OS.sel_setDropItem_dropChildIndex_, item !is null ? item.id : null, index);
}

public void setOutlineTableColumn(NSTableColumn outlineTableColumn) {
    OS.objc_msgSend(this.id, OS.sel_setOutlineTableColumn_, outlineTableColumn !is null ? outlineTableColumn.id : null);
}

public static objc.Class cellClass() {
    return cast(objc.Class) OS.objc_msgSend(OS.class_NSOutlineView, OS.sel_cellClass);
}

public static void setCellClass(objc.Class factoryId) {
    OS.objc_msgSend(OS.class_NSOutlineView, OS.sel_setCellClass_, factoryId);
}

}
