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
module dwt.internal.cocoa.NSColorPanel;

import dwt.dwthelper.utils;
import dwt.internal.c.Carbon;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSColor;
import dwt.internal.cocoa.NSPanel;
import dwt.internal.cocoa.OS;
import dwt.internal.cocoa.NSString;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSColorPanel : NSPanel {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSColor color() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_color);
    return result !is null ? new NSColor(result) : null;
}

public void setColor(NSColor color) {
    OS.objc_msgSend(this.id, OS.sel_setColor_, color !is null ? color.id : null);
}

public static NSColorPanel sharedColorPanel() {
    objc.id result = OS.objc_msgSend(OS.class_NSColorPanel, OS.sel_sharedColorPanel);
    return result !is null ? new NSColorPanel(result) : null;
}

public static CGFloat minFrameWidthWithTitle(NSString aTitle, NSUInteger aStyle) {
    return cast(CGFloat)OS.objc_msgSend_fpret(OS.class_NSColorPanel, OS.sel_minFrameWidthWithTitle_styleMask_, aTitle !is null ? aTitle.id : 0, aStyle);
}

}
