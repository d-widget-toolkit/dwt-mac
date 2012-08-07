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
module dwt.internal.cocoa.NSFontPanel;

import dwt.dwthelper.utils;
import dwt.internal.c.Carbon;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSFont;
import dwt.internal.cocoa.NSPanel;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSFontPanel : NSPanel {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSFont panelConvertFont(NSFont fontObj) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_panelConvertFont_, fontObj !is null ? fontObj.id : null);
    return result !is null ? new NSFont(result) : null;
}

public void setPanelFont(NSFont fontObj, bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setPanelFont_isMultiple_, fontObj !is null ? fontObj.id : null, flag);
}

public static NSFontPanel sharedFontPanel() {
    objc.id result = OS.objc_msgSend(OS.class_NSFontPanel, OS.sel_sharedFontPanel);
    return result !is null ? new NSFontPanel(result) : null;
}

public static CGFloat minFrameWidthWithTitle(NSString aTitle, NSUInteger aStyle) {
    return cast(CGFloat)OS.objc_msgSend_fpret(OS.class_NSFontPanel, OS.sel_minFrameWidthWithTitle_styleMask_, aTitle !is null ? aTitle.id : null, aStyle);
}

}
