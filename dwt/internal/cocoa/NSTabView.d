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
module dwt.internal.cocoa.NSTabView;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSFont;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.NSTabViewItem;
import dwt.internal.cocoa.NSView;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSTabView : NSView {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void addTabViewItem(NSTabViewItem tabViewItem) {
    OS.objc_msgSend(this.id, OS.sel_addTabViewItem_, tabViewItem !is null ? tabViewItem.id : null);
}

public NSRect contentRect() {
    NSRect result = NSRect();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_contentRect);
    return result;
}

public void insertTabViewItem(NSTabViewItem tabViewItem, NSInteger index) {
    OS.objc_msgSend(this.id, OS.sel_insertTabViewItem_atIndex_, tabViewItem !is null ? tabViewItem.id : null, index);
}

public NSSize minimumSize() {
    NSSize result = NSSize();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_minimumSize);
    return result;
}

public void removeTabViewItem(NSTabViewItem tabViewItem) {
    OS.objc_msgSend(this.id, OS.sel_removeTabViewItem_, tabViewItem !is null ? tabViewItem.id : null);
}

public void selectTabViewItemAtIndex(NSInteger index) {
    OS.objc_msgSend(this.id, OS.sel_selectTabViewItemAtIndex_, index);
}

public NSTabViewItem selectedTabViewItem() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_selectedTabViewItem);
    return result !is null ? new NSTabViewItem(result) : null;
}

public void setControlSize(int /*long*/ controlSize) {
    OS.objc_msgSend(this.id, OS.sel_setControlSize_, controlSize);
}

public void setControlSize(NSControlSize controlSize) {
    OS.objc_msgSend(this.id, OS.sel_setControlSize_, controlSize);
}

public void setDelegate(cocoa.id anObject) {
    OS.objc_msgSend(this.id, OS.sel_setDelegate_, anObject !is null ? anObject.id : null);
}

public void setFont(NSFont font) {
    OS.objc_msgSend(this.id, OS.sel_setFont_, font !is null ? font.id : null);
}

public void setTabViewType(NSTabViewType tabViewType) {
    OS.objc_msgSend(this.id, OS.sel_setTabViewType_, tabViewType);
}

public NSTabViewItem tabViewItemAtPoint(NSPoint point) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_tabViewItemAtPoint_, point);
    return result !is null ? new NSTabViewItem(result) : null;
}

}
