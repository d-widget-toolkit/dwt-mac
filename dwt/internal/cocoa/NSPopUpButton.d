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
module dwt.internal.cocoa.NSPopUpButton;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSButton;
import dwt.internal.cocoa.NSMenu;
import dwt.internal.cocoa.NSMenuItem;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSPopUpButton : NSButton {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSInteger indexOfSelectedItem() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_indexOfSelectedItem);
}

public NSPopUpButton initWithFrame(NSRect buttonFrame, bool flag) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithFrame_pullsDown_, buttonFrame, flag);
    return result is this.id ? this : (result !is null ? new NSPopUpButton(result) : null);
}

public NSMenuItem itemAtIndex(NSInteger index) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_itemAtIndex_, index);
    return result !is null ? new NSMenuItem(result) : null;
}

public NSString itemTitleAtIndex(NSInteger index) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_itemTitleAtIndex_, index);
    return result !is null ? new NSString(result) : null;
}

public NSMenu menu() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_menu);
    return result !is null ? new NSMenu(result) : null;
}

public NSInteger numberOfItems() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_numberOfItems);
}

public void removeAllItems() {
    OS.objc_msgSend(this.id, OS.sel_removeAllItems);
}

public void removeItemAtIndex(NSInteger index) {
    OS.objc_msgSend(this.id, OS.sel_removeItemAtIndex_, index);
}

public void selectItem(NSMenuItem item) {
    OS.objc_msgSend(this.id, OS.sel_selectItem_, item !is null ? item.id : null);
}

public void selectItemAtIndex(NSInteger index) {
    OS.objc_msgSend(this.id, OS.sel_selectItemAtIndex_, index);
}

public void setAutoenablesItems(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setAutoenablesItems_, flag);
}

public void setPullsDown(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setPullsDown_, flag);
}

public NSString titleOfSelectedItem() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_titleOfSelectedItem);
    return result !is null ? new NSString(result) : null;
}

public static objc.Class cellClass() {
    return cast(objc.Class)OS.objc_msgSend(OS.class_NSPopUpButton, OS.sel_cellClass);
}

public static void setCellClass(objc.Class factoryId) {
    OS.objc_msgSend(OS.class_NSPopUpButton, OS.sel_setCellClass_, factoryId);
}

}
