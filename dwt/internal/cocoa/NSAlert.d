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
module dwt.internal.cocoa.NSAlert;

import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSButton;
import dwt.internal.cocoa.NSError;
import dwt.internal.cocoa.NSImage;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSView;
import dwt.internal.cocoa.NSWindow;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSAlert : NSObject {

public this () {
    super();
}

public this (objc.id id) {
    super(id);
}

public this (cocoa.id id) {
    super(id);
}

public NSButton addButtonWithTitle(NSString title) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_addButtonWithTitle_, title !is null ? title.id : null);
    return result !is null ? new NSButton(result) : null;
}

public void beginSheetModalForWindow(NSWindow window, id delegate, int /*long*/ didEndSelector, int /*long*/ contextInfo) {
    OS.objc_msgSend(this.id, OS.sel_beginSheetModalForWindow_modalDelegate_didEndSelector_contextInfo_, window !is null ? window.id : 0, delegate !is null ? delegate.id : 0, didEndSelector, contextInfo);
}

public void beginSheetModalForWindow(NSWindow window, cocoa.id delegate_, objc.SEL didEndSelector, void* contextInfo) {
    OS.objc_msgSend(this.id, OS.sel_beginSheetModalForWindow_modalDelegate_didEndSelector_contextInfo_, window !is null ? window.id : null, delegate_ !is null ? delegate_.id : null, didEndSelector, contextInfo);
}

public NSInteger runModal() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_runModal);
}

public void setAlertStyle (NSAlertStyle style) {
    OS.objc_msgSend(this.id, OS.sel_setAlertStyle_, style);
}

public void setMessageText(NSString messageText) {
    OS.objc_msgSend(this.id, OS.sel_setMessageText_, messageText !is null ? messageText.id : 0);
}

public void setMessageText(NSString messageText) {
    OS.objc_msgSend(this.id, OS.sel_setMessageText_, messageText !is null ? messageText.id : null);
}

public NSWindow window () {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_window);
    return result !is null ? new NSWindow(result) : null;
}

}
