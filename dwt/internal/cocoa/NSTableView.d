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
module dwt.internal.cocoa.NSTableView;

import dwt.dwthelper.utils;
import dwt.internal.c.Carbon;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSImage;
import dwt.internal.cocoa.NSIndexSet;
import dwt.internal.cocoa.NSColor;
import dwt.internal.cocoa.NSControl;
import dwt.internal.cocoa.NSEvent;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSRange;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.NSTableColumn;
import dwt.internal.cocoa.NSTableHeaderView;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSTableView : NSControl {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void addTableColumn(NSTableColumn column) {
    OS.objc_msgSend(this.id, OS.sel_addTableColumn_, column !is null ? column.id : null);
}

public bool allowsColumnReordering() {
    return OS.objc_msgSend_bool(this.id, OS.sel_allowsColumnReordering);
}

public bool canDragRowsWithIndexes(NSIndexSet rowIndexes, NSPoint mouseDownPoint) {
    return OS.objc_msgSend_bool(this.id, OS.sel_canDragRowsWithIndexes_atPoint_, rowIndexes !is null ? rowIndexes.id : null, mouseDownPoint);
}

public NSInteger clickedColumn() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_clickedColumn);
}

public NSInteger clickedRow() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_clickedRow);
}

public NSInteger columnAtPoint(NSPoint point) {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_columnAtPoint_, point);
}

public NSIndexSet columnIndexesInRect(NSRect rect) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_columnIndexesInRect_, rect);
    return result !is null ? new NSIndexSet(result) : null;
}

public NSInteger columnWithIdentifier(cocoa.id identifier) {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_columnWithIdentifier_, identifier !is null ? identifier.id : null);
}

public void deselectAll(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_deselectAll_, sender !is null ? sender.id : null);
}

public void deselectRow(NSInteger row) {
    OS.objc_msgSend(this.id, OS.sel_deselectRow_, row);
}

public NSImage dragImageForRowsWithIndexes(NSIndexSet dragRows, NSArray tableColumns, NSEvent dragEvent, NSPointPointer dragImageOffset) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_dragImageForRowsWithIndexes_tableColumns_event_offset_, dragRows !is null ? dragRows.id : null, tableColumns !is null ? tableColumns.id : null, dragEvent !is null ? dragEvent.id : null, dragImageOffset);
    return result !is null ? new NSImage(result) : null;
}

public NSRect frameOfCellAtColumn(NSInteger column, NSInteger row) {
    NSRect result = NSRect();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_frameOfCellAtColumn_row_, column, row);
    return result;
}

public NSTableHeaderView headerView() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_headerView);
    return result !is null ? new NSTableHeaderView(result) : null;
}

public void highlightSelectionInClipRect(NSRect clipRect) {
    OS.objc_msgSend(this.id, OS.sel_highlightSelectionInClipRect_, clipRect);
}

public NSSize intercellSpacing() {
    NSSize result = NSSize();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_intercellSpacing);
    return result;
}

public bool isRowSelected(NSInteger row) {
    return OS.objc_msgSend_bool(this.id, OS.sel_isRowSelected_, row);
}

public void moveColumn(NSInteger column, NSInteger newIndex) {
    OS.objc_msgSend(this.id, OS.sel_moveColumn_toColumn_, column, newIndex);
}

public void noteNumberOfRowsChanged() {
    OS.objc_msgSend(this.id, OS.sel_noteNumberOfRowsChanged);
}

public NSInteger numberOfColumns() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_numberOfColumns);
}

public NSInteger numberOfRows() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_numberOfRows);
}

public NSInteger numberOfSelectedRows() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_numberOfSelectedRows);
}

public NSRect rectOfColumn(NSInteger column) {
    NSRect result = NSRect();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_rectOfColumn_, column);
    return result;
}

public NSRect rectOfRow(NSInteger row) {
    NSRect result = NSRect();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_rectOfRow_, row);
    return result;
}

public void reloadData() {
    OS.objc_msgSend(this.id, OS.sel_reloadData);
}

public void removeTableColumn(NSTableColumn column) {
    OS.objc_msgSend(this.id, OS.sel_removeTableColumn_, column !is null ? column.id : null);
}

public NSInteger rowAtPoint(NSPoint point) {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_rowAtPoint_, point);
}

public CGFloat rowHeight() {
    return cast(CGFloat) OS.objc_msgSend_fpret(this.id, OS.sel_rowHeight);
}

public NSRange rowsInRect(NSRect rect) {
    NSRange result = NSRange();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_rowsInRect_, rect);
    return result;
}

public void scrollColumnToVisible(NSInteger column) {
    OS.objc_msgSend(this.id, OS.sel_scrollColumnToVisible_, column);
}

public void scrollRowToVisible(NSInteger row) {
    OS.objc_msgSend(this.id, OS.sel_scrollRowToVisible_, row);
}

public void selectAll(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_selectAll_, sender !is null ? sender.id : null);
}

public void selectRowIndexes(NSIndexSet indexes, bool extend) {
    OS.objc_msgSend(this.id, OS.sel_selectRowIndexes_byExtendingSelection_, indexes !is null ? indexes.id : null, extend);
}

public NSInteger selectedRow() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_selectedRow);
}

public NSIndexSet selectedRowIndexes() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_selectedRowIndexes);
    return result !is null ? new NSIndexSet(result) : null;
}

public void setAllowsColumnReordering(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setAllowsColumnReordering_, flag);
}

public void setAllowsMultipleSelection(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setAllowsMultipleSelection_, flag);
}

public void setBackgroundColor(NSColor color) {
    OS.objc_msgSend(this.id, OS.sel_setBackgroundColor_, color !is null ? color.id : null);
}

public void setColumnAutoresizingStyle(NSTableViewColumnAutoresizingStyle style) {
    OS.objc_msgSend(this.id, OS.sel_setColumnAutoresizingStyle_, style);
}

public void setDataSource(cocoa.id aSource) {
    OS.objc_msgSend(this.id, OS.sel_setDataSource_, aSource !is null ? aSource.id : null);
}

public void setDelegate(cocoa.id delegate_) {
    OS.objc_msgSend(this.id, OS.sel_setDelegate_, delegate_ !is null ? delegate_.id : null);
}

public void setDoubleAction(objc.SEL aSelector) {
    OS.objc_msgSend(this.id, OS.sel_setDoubleAction_, aSelector);
}

public void setDropRow(NSInteger row, NSTableViewDropOperation op) {
    OS.objc_msgSend(this.id, OS.sel_setDropRow_dropOperation_, row, op);
}

public void setHeaderView(NSTableHeaderView headerView) {
    OS.objc_msgSend(this.id, OS.sel_setHeaderView_, headerView !is null ? headerView.id : null);
}

public void setHighlightedTableColumn(NSTableColumn tc) {
    OS.objc_msgSend(this.id, OS.sel_setHighlightedTableColumn_, tc !is null ? tc.id : null);
}

public void setIndicatorImage(NSImage anImage, NSTableColumn tc) {
    OS.objc_msgSend(this.id, OS.sel_setIndicatorImage_inTableColumn_, anImage !is null ? anImage.id : null, tc !is null ? tc.id : null);
}

public void setIntercellSpacing(NSSize aSize) {
    OS.objc_msgSend(this.id, OS.sel_setIntercellSpacing_, aSize);
}

public void setRowHeight(CGFloat rowHeight) {
    OS.objc_msgSend(this.id, OS.sel_setRowHeight_, rowHeight);
}

public void setUsesAlternatingRowBackgroundColors(bool useAlternatingRowColors) {
    OS.objc_msgSend(this.id, OS.sel_setUsesAlternatingRowBackgroundColors_, useAlternatingRowColors);
}

public NSArray tableColumns() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_tableColumns);
    return result !is null ? new NSArray(result) : null;
}

public void tile() {
    OS.objc_msgSend(this.id, OS.sel_tile);
}

public bool usesAlternatingRowBackgroundColors() {
    return OS.objc_msgSend_bool(this.id, OS.sel_usesAlternatingRowBackgroundColors);
}

public static objc.Class cellClass() {
    return cast(objc.Class)OS.objc_msgSend(OS.class_NSTableView, OS.sel_cellClass);
}

public static void setCellClass(objc.Class factoryId) {
    OS.objc_msgSend(OS.class_NSTableView, OS.sel_setCellClass_, factoryId);
}

}
