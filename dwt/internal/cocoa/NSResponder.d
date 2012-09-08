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
module dwt.internal.cocoa.NSResponder;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSEvent;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSResponder : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public bool acceptsFirstResponder() {
    return OS.objc_msgSend_bool(this.id, OS.sel_acceptsFirstResponder);
}

public bool becomeFirstResponder() {
    return OS.objc_msgSend_bool(this.id, OS.sel_becomeFirstResponder);
}

public void cursorUpdate(NSEvent event) {
    OS.objc_msgSend(this.id, OS.sel_cursorUpdate_, event !is null ? cast(int)event.id : 0);
}

public void doCommandBySelector(objc.SEL aSelector) {
    OS.objc_msgSend(this.id, OS.sel_doCommandBySelector_, aSelector);
}

public void flagsChanged(NSEvent theEvent) {
    OS.objc_msgSend(this.id, OS.sel_flagsChanged_, theEvent !is null ? theEvent.id : null);
}

public void helpRequested(NSEvent eventPtr) {
    OS.objc_msgSend(this.id, OS.sel_helpRequested_, eventPtr !is null ? eventPtr.id : null);
}

public void insertText(cocoa.id insertString) {
    OS.objc_msgSend(this.id, OS.sel_insertText_, insertString !is null ? insertString.id : null);
}

public void interpretKeyEvents(NSArray eventArray) {
    OS.objc_msgSend(this.id, OS.sel_interpretKeyEvents_, eventArray !is null ? eventArray.id : null);
}

public void keyDown(NSEvent theEvent) {
    OS.objc_msgSend(this.id, OS.sel_keyDown_, theEvent !is null ? theEvent.id : null);
}

public void keyUp(NSEvent theEvent) {
    OS.objc_msgSend(this.id, OS.sel_keyUp_, theEvent !is null ? theEvent.id : null);
}

public void mouseDown(NSEvent theEvent) {
    OS.objc_msgSend(this.id, OS.sel_mouseDown_, theEvent !is null ? theEvent.id : null);
}

public void mouseDragged(NSEvent theEvent) {
    OS.objc_msgSend(this.id, OS.sel_mouseDragged_, theEvent !is null ? theEvent.id : null);
}

public void mouseEntered(NSEvent theEvent) {
    OS.objc_msgSend(this.id, OS.sel_mouseEntered_, theEvent !is null ? theEvent.id : null);
}

public void mouseExited(NSEvent theEvent) {
    OS.objc_msgSend(this.id, OS.sel_mouseExited_, theEvent !is null ? theEvent.id : null);
}

public void mouseMoved(NSEvent theEvent) {
    OS.objc_msgSend(this.id, OS.sel_mouseMoved_, theEvent !is null ? theEvent.id : null);
}

public void mouseUp(NSEvent theEvent) {
    OS.objc_msgSend(this.id, OS.sel_mouseUp_, theEvent !is null ? theEvent.id : null);
}

public void moveToBeginningOfParagraph(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_moveToBeginningOfParagraph_, sender !is null ? sender.id : null);
}

public void moveToEndOfParagraph(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_moveToEndOfParagraph_, sender !is null ? sender.id : null);
}

public void moveUp(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_moveUp_, sender !is null ? sender.id : null);
}

public void noResponderFor(objc.SEL eventSelector) {
    OS.objc_msgSend(this.id, OS.sel_noResponderFor_, eventSelector);
}

public void otherMouseDown(NSEvent theEvent) {
    OS.objc_msgSend(this.id, OS.sel_otherMouseDown_, theEvent !is null ? theEvent.id : null);
}

public void otherMouseDragged(NSEvent theEvent) {
    OS.objc_msgSend(this.id, OS.sel_otherMouseDragged_, theEvent !is null ? theEvent.id : null);
}

public void otherMouseUp(NSEvent theEvent) {
    OS.objc_msgSend(this.id, OS.sel_otherMouseUp_, theEvent !is null ? theEvent.id : null);
}

public void pageDown(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_pageDown_, sender !is null ? sender.id : null);
}

public void pageUp(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_pageUp_, sender !is null ? sender.id : null);
}

public bool resignFirstResponder() {
    return OS.objc_msgSend_bool(this.id, OS.sel_resignFirstResponder);
}

public void rightMouseDown(NSEvent theEvent) {
    OS.objc_msgSend(this.id, OS.sel_rightMouseDown_, theEvent !is null ? theEvent.id : null);
}

public void rightMouseDragged(NSEvent theEvent) {
    OS.objc_msgSend(this.id, OS.sel_rightMouseDragged_, theEvent !is null ? theEvent.id : null);
}

public void rightMouseUp(NSEvent theEvent) {
    OS.objc_msgSend(this.id, OS.sel_rightMouseUp_, theEvent !is null ? theEvent.id : null);
}

public void scrollWheel(NSEvent theEvent) {
    OS.objc_msgSend(this.id, OS.sel_scrollWheel_, theEvent !is null ? theEvent.id : null);
}

}
