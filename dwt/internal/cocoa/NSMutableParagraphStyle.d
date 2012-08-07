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
module dwt.internal.cocoa.NSMutableParagraphStyle;

import dwt.dwthelper.utils;
import dwt.internal.c.Carbon;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSParagraphStyle;
import dwt.internal.cocoa.NSText;
import dwt.internal.cocoa.NSTextTab;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSMutableParagraphStyle : NSParagraphStyle {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void addTabStop(NSTextTab anObject) {
    OS.objc_msgSend(this.id, OS.sel_addTabStop_, anObject !is null ? anObject.id : null);
}

public void setAlignment(NSTextAlignment alignment) {
    OS.objc_msgSend(this.id, OS.sel_setAlignment_, alignment);
}

public void setDefaultTabInterval(CGFloat aFloat) {
    OS.objc_msgSend(this.id, OS.sel_setDefaultTabInterval_, aFloat);
}

public void setFirstLineHeadIndent(CGFloat aFloat) {
    OS.objc_msgSend(this.id, OS.sel_setFirstLineHeadIndent_, aFloat);
}

public void setLineBreakMode(NSLineBreakMode mode) {
    OS.objc_msgSend(this.id, OS.sel_setLineBreakMode_, mode);
}

public void setLineSpacing(CGFloat aFloat) {
    OS.objc_msgSend(this.id, OS.sel_setLineSpacing_, aFloat);
}

public void setTabStops(NSArray array) {
    OS.objc_msgSend(this.id, OS.sel_setTabStops_, array !is null ? array.id : null);
}

}
