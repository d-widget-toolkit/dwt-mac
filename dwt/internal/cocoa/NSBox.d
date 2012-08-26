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
module dwt.internal.cocoa.NSBox;

import dwt.internal.c.Carbon;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSCell;
import dwt.internal.cocoa.NSColor;
import dwt.internal.cocoa.NSFont;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSView;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSBox : NSView {

public this () {
    super();
}

public this (objc.id id) {
    super(id);
}

public this (cocoa.id id) {
    super(id);
}

public CGFloat borderWidth () {
    return cast(CGFloat) OS.objc_msgSend_fpret(this.id, OS.sel_borderWidth);
}

public NSView contentView() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_contentView);
    return result !is null ? new NSView(result) : null;
}

public NSSize contentViewMargins () {
    NSSize result = NSSize();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_contentViewMargins);
    return result;
}

public void setBorderType (NSBorderType aType) {
    OS.objc_msgSend(this.id, OS.sel_setBorderType_, aType);
}

public void setBorderWidth (CGFloat borderWidth) {
    OS.objc_msgSend(this.id, OS.sel_setBorderWidth_, borderWidth);
}

public void setBoxType (NSBoxType boxType) {
    OS.objc_msgSend(this.id, OS.sel_setBoxType_, boxType);
}

public void setContentView (NSView aView) {
    OS.objc_msgSend(this.id, OS.sel_setContentView_, aView !is null ? aView.id : null);
}

public void setContentViewMargins(NSSize offsetSize) {
    OS.objc_msgSend(this.id, OS.sel_setContentViewMargins_, offsetSize);
}

public void setFillColor(NSColor fillColor) {
    OS.objc_msgSend(this.id, OS.sel_setFillColor_, fillColor !is null ? fillColor.id : null);
}

public void setTitle(NSString aString) {
    OS.objc_msgSend(this.id, OS.sel_setTitle_, aString !is null ? aString.id : null);
}

public void setTitleFont(NSFont fontObj) {
    OS.objc_msgSend(this.id, OS.sel_setTitleFont_, fontObj !is null ? fontObj.id : null);
}

public void setTitlePosition(NSTitlePosition aPosition) {
    OS.objc_msgSend(this.id, OS.sel_setTitlePosition_, aPosition);
}

public void sizeToFit () {
    OS.objc_msgSend(this.id, OS.sel_sizeToFit);
}

public NSCell titleCell () {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_titleCell);
    return result !is null ? new NSCell(result) : null;
}

public NSFont titleFont() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_titleFont);
    return result !is null ? new NSFont(result) : null;
}

}

alias NSUInteger NSBoxType;

enum {
    NSBoxPrimary = 0,
    NSBoxSecondary = 1,
    NSBoxSeparator = 2,
    NSBoxOldStyle = 3,
    NSBoxCustom = 4
}