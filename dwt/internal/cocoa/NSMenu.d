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
module dwt.internal.cocoa.NSMenu;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSEvent;
import dwt.internal.cocoa.NSMenuItem;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSView;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSMenu : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void addItem(NSMenuItem newItem) {
    OS.objc_msgSend(this.id, OS.sel_addItem_, newItem !is null ? newItem.id : null);
}

public NSMenuItem addItemWithTitle(NSString aString, objc.SEL aSelector, NSString charCode) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_addItemWithTitle_action_keyEquivalent_, aString !is null ? aString.id : null, aSelector, charCode !is null ? charCode.id : null);
    return result !is null ? new NSMenuItem(result) : null;
}

public NSMenuItem addItemWithTitle(NSString aString, int /*long*/ aSelector, NSString charCode) {
    int /*long*/ result = OS.objc_msgSend(this.id, OS.sel_addItemWithTitle_action_keyEquivalent_, aString !is null ? aString.id : 0, aSelector, charCode !is null ? charCode.id : 0);
    return result !is 0 ? new NSMenuItem(result) : null;
}

public void cancelTracking() {
    OS.objc_msgSend(this.id, OS.sel_cancelTracking);
}

public NSInteger indexOfItemWithTarget(cocoa.id target, objc.SEL actionSelector) {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_indexOfItemWithTarget_andAction_, target !is null ? target.id : null, actionSelector);
}

public NSMenu initWithTitle(NSString aTitle) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithTitle_, aTitle !is null ? aTitle.id : null);
    return result is this.id ? this : (result !is null ? new NSMenu(result) : null);
}

public void insertItem(NSMenuItem newItem, NSInteger index) {
    OS.objc_msgSend(this.id, OS.sel_insertItem_atIndex_, newItem !is null ? newItem.id : null, index);
}

public NSArray itemArray() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_itemArray);
    return result !is null ? new NSArray(result) : null;
}

public NSMenuItem itemAtIndex(NSInteger index) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_itemAtIndex_, index);
    return result !is null ? new NSMenuItem(result) : null;
}

public NSInteger numberOfItems() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_numberOfItems);
}

public static void popUpContextMenu(NSMenu menu, NSEvent event, NSView view) {
    OS.objc_msgSend(OS.class_NSMenu, OS.sel_popUpContextMenu_withEvent_forView_, menu !is null ? menu.id : null, event !is null ? event.id : null, view !is null ? view.id : null);
}

public void removeItem(NSMenuItem item) {
    OS.objc_msgSend(this.id, OS.sel_removeItem_, item !is null ? item.id : null);
}

public void removeItemAtIndex(NSInteger index) {
    OS.objc_msgSend(this.id, OS.sel_removeItemAtIndex_, index);
}

public void setAutoenablesItems(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setAutoenablesItems_, flag);
}

public void setDelegate(cocoa.id anObject) {
    OS.objc_msgSend(this.id, OS.sel_setDelegate_, anObject !is null ? anObject.id : null);
}

public void setSubmenu(NSMenu aMenu, NSMenuItem anItem) {
    OS.objc_msgSend(this.id, OS.sel_setSubmenu_forItem_, aMenu !is null ? aMenu.id : null, anItem !is null ? anItem.id : null);
}

public void setTitle(NSString aString) {
    OS.objc_msgSend(this.id, OS.sel_setTitle_, aString !is null ? aString.id : null);
}

}
