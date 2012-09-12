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
module dwt.internal.cocoa.NSComboBox;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSTextField;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSComboBox : NSTextField {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void addItemWithObjectValue(cocoa.id object) {
    OS.objc_msgSend(this.id, OS.sel_addItemWithObjectValue_, object !is null ? object.id : null);
}

public void deselectItemAtIndex(NSInteger index) {
    OS.objc_msgSend(this.id, OS.sel_deselectItemAtIndex_, index);
}

public NSInteger indexOfSelectedItem() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_indexOfSelectedItem);
}

public void insertItemWithObjectValue(cocoa.id object, NSInteger index) {
    OS.objc_msgSend(this.id, OS.sel_insertItemWithObjectValue_atIndex_, object !is null ? object.id : null, index);
}

public cocoa.id itemObjectValueAtIndex(NSInteger index) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_itemObjectValueAtIndex_, index);
    return result !is null ? new cocoa.id(result) : null;
}

public NSInteger numberOfItems() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_numberOfItems);
}

public NSInteger numberOfVisibleItems() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_numberOfVisibleItems);
}

public void removeAllItems() {
    OS.objc_msgSend(this.id, OS.sel_removeAllItems);
}

public void removeItemAtIndex(NSInteger index) {
    OS.objc_msgSend(this.id, OS.sel_removeItemAtIndex_, index);
}

public void selectItemAtIndex(NSInteger index) {
    OS.objc_msgSend(this.id, OS.sel_selectItemAtIndex_, index);
}

public void setNumberOfVisibleItems(NSInteger visibleItems) {
    OS.objc_msgSend(this.id, OS.sel_setNumberOfVisibleItems_, visibleItems);
}

public static objc.Class cellClass() {
    return cast(objc.Class)OS.objc_msgSend(OS.class_NSComboBox, OS.sel_cellClass);
}

public static void setCellClass(objc.Class factoryId) {
    OS.objc_msgSend(OS.class_NSComboBox, OS.sel_setCellClass_, factoryId);
}

}
