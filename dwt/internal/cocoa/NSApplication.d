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
module dwt.internal.cocoa.NSApplication;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSDate;
import dwt.internal.cocoa.NSEvent;
import dwt.internal.cocoa.NSImage;
import dwt.internal.cocoa.NSMenu;
import dwt.internal.cocoa.NSResponder;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSWindow;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSApplication : NSResponder {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void activateIgnoringOtherApps(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_activateIgnoringOtherApps_, flag);
}

public void beginSheet(NSWindow sheet, NSWindow docWindow, cocoa.id modalDelegate, objc.SEL didEndSelector, void* contextInfo) {
    OS.objc_msgSend(this.id, OS.sel_beginSheet_modalForWindow_modalDelegate_didEndSelector_contextInfo_, sheet !is null ? sheet.id : null, docWindow !is null ? docWindow.id : null, modalDelegate !is null ? modalDelegate.id : null, didEndSelector, contextInfo);
}

public NSEvent currentEvent() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_currentEvent);
    return result !is null ? new NSEvent(result) : null;
}

public void endSheet(NSWindow sheet, NSInteger returnCode) {
    OS.objc_msgSend(this.id, OS.sel_endSheet_returnCode_, sheet !is null ? sheet.id : null, returnCode);
}

public void finishLaunching() {
    OS.objc_msgSend(this.id, OS.sel_finishLaunching);
}

public void hide(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_hide_, sender !is null ? sender.id : null);
}

public void hideOtherApplications(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_hideOtherApplications_, sender !is null ? sender.id : null);
}

public bool isActive() {
    return OS.objc_msgSend_bool(this.id, OS.sel_isActive);
}

public bool isRunning() {
    return OS.objc_msgSend_bool(this.id, OS.sel_isRunning);
}

public NSWindow keyWindow() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_keyWindow);
    return result !is null ? new NSWindow(result) : null;
}

public NSMenu mainMenu() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_mainMenu);
    return result !is null ? new NSMenu(result) : null;
}

public NSEvent nextEventMatchingMask(NSUInteger mask, NSDate expiration, NSString mode, bool deqFlag) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_nextEventMatchingMask_untilDate_inMode_dequeue_, mask, expiration !is null ? expiration.id : null, mode !is null ? mode.id : null, deqFlag);
    return result !is null ? new NSEvent(result) : null;
}

public void orderFrontStandardAboutPanel(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_orderFrontStandardAboutPanel_, sender !is null ? sender.id : null);
}

public NSArray orderedWindows() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_orderedWindows);
    return result !is null ? new NSArray(result) : null;
}

public void postEvent(NSEvent event, bool flag) {
    OS.objc_msgSend(this.id, OS.sel_postEvent_atStart_, event !is null ? event.id : null, flag);
}

public void run() {
    OS.objc_msgSend(this.id, OS.sel_run);
}

public NSInteger runModalForWindow(NSWindow theWindow) {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_runModalForWindow_, theWindow !is null ? theWindow.id : null);
}

public void sendEvent(NSEvent theEvent) {
    OS.objc_msgSend(this.id, OS.sel_sendEvent_, theEvent !is null ? theEvent.id : null);
}

public void setApplicationIconImage(NSImage image) {
    OS.objc_msgSend(this.id, OS.sel_setApplicationIconImage_, image !is null ? image.id : null);
}

public void setDelegate(cocoa.id anObject) {
    OS.objc_msgSend(this.id, OS.sel_setDelegate_, anObject !is null ? anObject.id : null);
}

public void setMainMenu(NSMenu aMenu) {
    OS.objc_msgSend(this.id, OS.sel_setMainMenu_, aMenu !is null ? aMenu.id : null);
}

public void setServicesMenu(NSMenu aMenu) {
    OS.objc_msgSend(this.id, OS.sel_setServicesMenu_, aMenu !is null ? aMenu.id : null);
}

public static NSApplication sharedApplication() {
    objc.id result = OS.objc_msgSend(OS.class_NSApplication, OS.sel_sharedApplication);
    return result !is null ? new NSApplication(result) : null;
}

public void stop(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_stop_, sender !is null ? sender.id : null);
}

public void terminate(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_terminate_, sender !is null ? sender.id : null);
}

public void unhideAllApplications(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_unhideAllApplications_, sender !is null ? sender.id : null);
}

public NSArray windows() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_windows);
    return result !is null ? new NSArray(result) : null;
}

}
