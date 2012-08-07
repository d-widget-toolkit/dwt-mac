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
module dwt.internal.cocoa.NSText;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSColor;
import dwt.internal.cocoa.NSFont;
import dwt.internal.cocoa.NSRange;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSView;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSText : NSView {
    
public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void copy(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_copy_, sender !is null ? sender.id : null);
}

public void cut(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_cut_, sender !is null ? sender.id : null);
}

public cocoa.id delegate_() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_delegate);
    return result !is null ? new cocoa.id(result) : null;
}

public NSFont font() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_font);
    return result !is null ? new NSFont(result) : null;
}

public id delegate() {
    int /*long*/ result = OS.objc_msgSend(this.id, OS.sel_delegate);
    return result !is 0 ? new id(result) : null;
}

public NSFont font() {
    int /*long*/ result = OS.objc_msgSend(this.id, OS.sel_font);
    return result !is 0 ? new NSFont(result) : null;
}

}

public void replaceCharactersInRange(NSRange range, NSString aString) {
    OS.objc_msgSend(this.id, OS.sel_replaceCharactersInRange_withString_, range, aString !is null ? aString.id : null);
}

public void scrollRangeToVisible(NSRange range) {
    OS.objc_msgSend(this.id, OS.sel_scrollRangeToVisible_, range);
}

public void selectAll(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_selectAll_, sender !is null ? sender.id : null);
}

public NSRange selectedRange() {
    NSRange result = NSRange();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_selectedRange);
    return result;
}

public void setAlignment(NSTextAlignment mode) {
    OS.objc_msgSend(this.id, OS.sel_setAlignment_, mode);
}

public void setBackgroundColor(NSColor color) {
    OS.objc_msgSend(this.id, OS.sel_setBackgroundColor_, color !is null ? color.id : null);
}

public void setDelegate(cocoa.id anObject) {
    OS.objc_msgSend(this.id, OS.sel_setDelegate_, anObject !is null ? anObject.id : null);
}

public void setDrawsBackground(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setDrawsBackground_, flag);
}

public void setEditable(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setEditable_, flag);
}

public void setFont(NSFont obj) {
    OS.objc_msgSend(this.id, OS.sel_setFont_, obj !is null ? obj.id : null);
}

public void setHorizontallyResizable(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setHorizontallyResizable_, flag);
}

public void setMaxSize(NSSize newMaxSize) {
    OS.objc_msgSend(this.id, OS.sel_setMaxSize_, newMaxSize);
}

public void setMinSize(NSSize newMinSize) {
    OS.objc_msgSend(this.id, OS.sel_setMinSize_, newMinSize);
}

public void setSelectable(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setSelectable_, flag);
}

public void setSelectedRange(NSRange range) {
    OS.objc_msgSend(this.id, OS.sel_setSelectedRange_, range);
}

public void setString(NSString string) {
    OS.objc_msgSend(this.id, OS.sel_setString_, string !is null ? string.id : null);
}

public void setTextColor(NSColor color) {
    OS.objc_msgSend(this.id, OS.sel_setTextColor_, color !is null ? color.id : null);
}

public void sizeToFit() {
    OS.objc_msgSend(this.id, OS.sel_sizeToFit);
}

public NSString string() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_string);
    return result !is null ? new NSString(result) : null;
}

}
