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
module dwt.internal.cocoa.NSSavePanel;

import dwt.dwthelper.utils;
import dwt.internal.c.Carbon;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSPanel;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSView;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSSavePanel : NSPanel {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSString filename() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_filename);
    return result !is null ? new NSString(result) : null;
}

public NSInteger runModal() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_runModal);
}

public NSInteger runModalForDirectory(NSString path, NSString name) {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_runModalForDirectory_file_, path !is null ? path.id : null, name !is null ? name.id : null);
}

public static NSSavePanel savePanel() {
    objc.id result = OS.objc_msgSend(OS.class_NSSavePanel, OS.sel_savePanel);
    return result !is null ? new NSSavePanel(result) : null;
}

public void setAccessoryView(NSView view) {
    OS.objc_msgSend(this.id, OS.sel_setAccessoryView_, view !is null ? view.id : null);
}

public void setCanCreateDirectories(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setCanCreateDirectories_, flag);
}

public void setDirectory(NSString path) {
    OS.objc_msgSend(this.id, OS.sel_setDirectory_, path !is null ? path.id : null);
}

public void setMessage(NSString message) {
    OS.objc_msgSend(this.id, OS.sel_setMessage_, message !is null ? message.id : null);
}

public void setTitle(NSString title) {
    OS.objc_msgSend(this.id, OS.sel_setTitle_, title !is null ? title.id : null);
}

public void validateVisibleColumns() {
    OS.objc_msgSend(this.id, OS.sel_validateVisibleColumns);
}

public static CGFloat minFrameWidthWithTitle(NSString aTitle, NSUInteger aStyle) {
    return cast(CGFloat)OS.objc_msgSend_fpret(OS.class_NSSavePanel, OS.sel_minFrameWidthWithTitle_styleMask_, aTitle !is null ? aTitle.id : null, aStyle);
}

}
