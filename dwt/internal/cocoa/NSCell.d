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
module dwt.internal.cocoa.NSCell;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSAttributedString;
import dwt.internal.cocoa.NSColor;
import dwt.internal.cocoa.NSEvent;
import dwt.internal.cocoa.NSFont;
import dwt.internal.cocoa.NSFormatter;
import dwt.internal.cocoa.NSImage;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSView;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSCell : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSAttributedString attributedStringValue() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_attributedStringValue);
    return result !is null ? new NSAttributedString(result) : null;
}

public NSSize cellSize() {
    NSSize result = new NSSize();
    OS.objc_msgSend_stret(result, this.id, OS.sel_cellSize);
    return result;
}

    NSSize result = new NSSize();
    OS.objc_msgSend_stret(result, this.id, OS.sel_cellSize);
    return result;
}

public NSSize cellSizeForBounds(NSRect aRect) {
    NSSize result = NSSize();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_cellSizeForBounds_, aRect);
    return result;
}

public void drawInteriorWithFrame(NSRect cellFrame, NSView controlView) {
    OS.objc_msgSend(this.id, OS.sel_drawInteriorWithFrame_inView_, cellFrame, controlView !is null ? controlView.id : null);
}

public void drawWithExpansionFrame(NSRect cellFrame, NSView view) {
    OS.objc_msgSend(this.id, OS.sel_drawWithExpansionFrame_inView_, cellFrame, view !is null ? view.id : null);
}

public void drawWithExpansionFrame(NSRect cellFrame, NSView view) {
    OS.objc_msgSend(this.id, OS.sel_drawWithExpansionFrame_inView_, cellFrame, view !is null ? view.id : 0);
}

public NSRect drawingRectForBounds(NSRect theRect) {
    NSRect result = NSRect();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_drawingRectForBounds_, theRect);
    return result;
}

public NSRect expansionFrameWithFrame(NSRect cellFrame, NSView view) {
    NSRect result = new NSRect();
    OS.objc_msgSend_stret(result, this.id, OS.sel_expansionFrameWithFrame_inView_, cellFrame, view !is null ? view.id : null);
    return result;
}

public NSRect expansionFrameWithFrame(NSRect cellFrame, NSView view) {
    NSRect result = new NSRect();
    OS.objc_msgSend_stret(result, this.id, OS.sel_expansionFrameWithFrame_inView_, cellFrame, view !is null ? view.id : 0);
    return result;
}

public NSFont font() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_font);
    return result !is null ? new NSFont(result) : null;
}

public NSColor highlightColorWithFrame(NSRect cellFrame, NSView controlView) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_highlightColorWithFrame_inView_, cellFrame, controlView !is null ? controlView.id : null);
    return result !is null ? new NSColor(result) : null;
}

public NSUInteger hitTestForEvent(NSEvent event, NSRect cellFrame, NSView controlView) {
    return OS.objc_msgSend(this.id, OS.sel_hitTestForEvent_inRect_ofView_, event !is null ? event.id : null, cellFrame, controlView !is null ? controlView.id : null);
}

public NSImage image() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_image);
    return result !is null ? new NSImage(result) : null;
}

public NSRect imageRectForBounds(NSRect theRect) {
    NSRect result = new NSRect();
    OS.objc_msgSend_stret(result, this.id, OS.sel_imageRectForBounds_, theRect);
    return result;
}

public bool isEnabled() {
    return OS.objc_msgSend_bool(this.id, OS.sel_isEnabled);
}

public bool isHighlighted() {
    return OS.objc_msgSend_bool(this.id, OS.sel_isHighlighted);
}

public NSInteger nextState() {
    return OS.objc_msgSend(this.id, OS.sel_nextState);
}

public void setAlignment(NSTextAlignment mode) {
    OS.objc_msgSend(this.id, OS.sel_setAlignment_, mode);
}

public NSColor highlightColorWithFrame(NSRect cellFrame, NSView controlView) {
    int /*long*/ result = OS.objc_msgSend(this.id, OS.sel_highlightColorWithFrame_inView_, cellFrame, controlView !is null ? controlView.id : 0);
    return result !is 0 ? new NSColor(result) : null;
}

public int /*long*/ hitTestForEvent(NSEvent event, NSRect cellFrame, NSView controlView) {
    return OS.objc_msgSend(this.id, OS.sel_hitTestForEvent_inRect_ofView_, event !is null ? event.id : 0, cellFrame, controlView !is null ? controlView.id : 0);
}

public NSImage image() {
    int /*long*/ result = OS.objc_msgSend(this.id, OS.sel_image);
    return result !is 0 ? new NSImage(result) : null;
}

public NSRect imageRectForBounds(NSRect theRect) {
    NSRect result = new NSRect();
    OS.objc_msgSend_stret(result, this.id, OS.sel_imageRectForBounds_, theRect);
    return result;
}

public bool isEnabled() {
    return OS.objc_msgSend_bool(this.id, OS.sel_isEnabled);
}

public bool isHighlighted() {
    return OS.objc_msgSend_bool(this.id, OS.sel_isHighlighted);
}

public int /*long*/ nextState() {
    return OS.objc_msgSend(this.id, OS.sel_nextState);
}

public void setAlignment(int /*long*/ mode) {
    OS.objc_msgSend(this.id, OS.sel_setAlignment_, mode);
}

public void setAllowsMixedState(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setAllowsMixedState_, flag);
}

public void setAttributedStringValue(NSAttributedString obj) {
    OS.objc_msgSend(this.id, OS.sel_setAttributedStringValue_, obj !is null ? obj.id : null);
}

public void setControlSize(NSControlSize size) {
    OS.objc_msgSend(this.id, OS.sel_setControlSize_, size);
}

public void setEnabled(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setEnabled_, flag);
}

public void setControlSize(int /*long*/ size) {
    OS.objc_msgSend(this.id, OS.sel_setControlSize_, size);
}

public void setEnabled(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setEnabled_, flag);
}

public void setFont(NSFont fontObj) {
    OS.objc_msgSend(this.id, OS.sel_setFont_, fontObj !is null ? fontObj.id : null);
}

public void setFormatter(NSFormatter newFormatter) {
    OS.objc_msgSend(this.id, OS.sel_setFormatter_, newFormatter !is null ? newFormatter.id : null);
}

public void setHighlighted(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setHighlighted_, flag);
}

public void setImage(NSImage image) {
    OS.objc_msgSend(this.id, OS.sel_setImage_, image !is null ? image.id : null);
}

public void setLineBreakMode(NSLineBreakMode mode) {
    OS.objc_msgSend(this.id, OS.sel_setLineBreakMode_, mode);
}

public void setObjectValue(cocoa.id obj) {
    OS.objc_msgSend(this.id, OS.sel_setObjectValue_, obj !is null ? obj.id : null);
}

public void setScrollable(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setScrollable_, flag);
}

public void setTitle(NSString aString) {
    OS.objc_msgSend(this.id, OS.sel_setTitle_, aString !is null ? aString.id : null);
}

public void setWraps(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setWraps_, flag);
}

public NSString title() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_title);
    return result !is null ? new NSString(result) : null;
}

public NSRect titleRectForBounds(NSRect theRect) {
    NSRect result = NSRect();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_titleRectForBounds_, theRect);
    return result;
}

public bool wraps() {
    return OS.objc_msgSend_bool(this.id, OS.sel_wraps);
}

}
