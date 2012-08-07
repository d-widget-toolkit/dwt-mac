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
module dwt.internal.cocoa.NSMenuItem;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSImage;
import dwt.internal.cocoa.NSMenu;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSMenuItem : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSMenuItem initWithTitle(NSString aString, objc.SEL aSelector, NSString charCode) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithTitle_action_keyEquivalent_, aString !is null ? aString.id : null, aSelector, charCode !is null ? charCode.id : null);
    return result is this.id ? this : (result !is null ? new NSMenuItem(result) : null);
}

public bool isHidden() {
    return OS.objc_msgSend_bool(this.id, OS.sel_isHidden);
}

public NSString keyEquivalent() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_keyEquivalent);
    return result !is null ? new NSString(result) : null;
}

public NSUInteger keyEquivalentModifierMask() {
    return cast(NSUInteger) OS.objc_msgSend(this.id, OS.sel_keyEquivalentModifierMask);
}

public static NSMenuItem separatorItem() {
    objc.id result = OS.objc_msgSend(OS.class_NSMenuItem, OS.sel_separatorItem);
    return result !is null ? new NSMenuItem(result) : null;
}

public void setAction(objc.SEL aSelector) {
    OS.objc_msgSend(this.id, OS.sel_setAction_, aSelector);
}

public void setEnabled(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setEnabled_, flag);
}

public void setHidden(bool hidden) {
    OS.objc_msgSend(this.id, OS.sel_setHidden_, hidden);
}

public void setImage(NSImage menuImage) {
    OS.objc_msgSend(this.id, OS.sel_setImage_, menuImage !is null ? menuImage.id : null);
}

public void setKeyEquivalent(NSString aKeyEquivalent) {
    OS.objc_msgSend(this.id, OS.sel_setKeyEquivalent_, aKeyEquivalent !is null ? aKeyEquivalent.id : null);
}

public void setKeyEquivalentModifierMask(NSUInteger mask) {
    OS.objc_msgSend(this.id, OS.sel_setKeyEquivalentModifierMask_, mask);
}

public void setMenu(NSMenu menu) {
    OS.objc_msgSend(this.id, OS.sel_setMenu_, menu !is null ? menu.id : null);
}

public void setState(NSInteger state) {
    OS.objc_msgSend(this.id, OS.sel_setState_, state);
}

public void setSubmenu(NSMenu submenu) {
    OS.objc_msgSend(this.id, OS.sel_setSubmenu_, submenu !is null ? submenu.id : null);
}

public void setTarget(cocoa.id anObject) {
    OS.objc_msgSend(this.id, OS.sel_setTarget_, anObject !is null ? anObject.id : null);
}

public void setTitle(NSString aString) {
    OS.objc_msgSend(this.id, OS.sel_setTitle_, aString !is null ? aString.id : null);
}

public NSInteger state() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_state);
}

public NSMenu submenu() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_submenu);
    return result !is null ? new NSMenu(result) : null;
}

public NSString title() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_title);
    return result !is null ? new NSString(result) : null;
}

}
