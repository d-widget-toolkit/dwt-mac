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
module dwt.internal.cocoa.NSOpenPanel;

import dwt.dwthelper.utils;
import dwt.internal.c.Carbon;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSSavePanel;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSOpenPanel : NSSavePanel {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSArray filenames() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_filenames);
    return result !is null ? new NSArray(result) : null;
}

public static NSOpenPanel openPanel() {
    objc.id result = OS.objc_msgSend(OS.class_NSOpenPanel, OS.sel_openPanel);
    return result !is null ? new NSOpenPanel(result) : null;
}

public void setAllowsMultipleSelection(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setAllowsMultipleSelection_, flag);
}

public void setCanChooseDirectories(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setCanChooseDirectories_, flag);
}

public void setCanChooseFiles(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setCanChooseFiles_, flag);
}

public static NSSavePanel savePanel() {
    objc.id result = OS.objc_msgSend(OS.class_NSOpenPanel, OS.sel_savePanel);
    return result !is null ? new NSSavePanel(result) : null;
}

public static CGFloat minFrameWidthWithTitle(NSString aTitle, NSUInteger aStyle) {
    return cast(CGFloat)OS.objc_msgSend_fpret(OS.class_NSOpenPanel, OS.sel_minFrameWidthWithTitle_styleMask_, aTitle !is null ? aTitle.id : null, aStyle);
}

}
