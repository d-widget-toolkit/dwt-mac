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
module dwt.internal.cocoa.NSPrintPanel;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSPrintInfo;
import dwt.internal.cocoa.NSWindow;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSPrintPanel : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void beginSheetWithPrintInfo(NSPrintInfo printInfo, NSWindow docWindow, cocoa.id delegate_, objc.SEL didEndSelector, void* contextInfo) {
    OS.objc_msgSend(this.id, OS.sel_beginSheetWithPrintInfo_modalForWindow_delegate_didEndSelector_contextInfo_, printInfo !is null ? printInfo.id : null, docWindow !is null ? docWindow.id : null, delegate_ !is null ? delegate_.id : null, didEndSelector, contextInfo);
}

public NSPrintPanelOptions options() {
    return cast(NSPrintPanelOptions) OS.objc_msgSend(this.id, OS.sel_options);
}

public static NSPrintPanel printPanel() {
    objc.id result = OS.objc_msgSend(OS.class_NSPrintPanel, OS.sel_printPanel);
    return result !is null ? new NSPrintPanel(result) : null;
}

public NSInteger runModalWithPrintInfo(NSPrintInfo printInfo) {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_runModalWithPrintInfo_, printInfo !is null ? printInfo.id : null);
}

public void setOptions(NSPrintPanelOptions options) {
    OS.objc_msgSend(this.id, OS.sel_setOptions_, options);
}

}
