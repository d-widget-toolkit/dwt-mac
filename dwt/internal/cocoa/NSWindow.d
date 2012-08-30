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
module dwt.internal.cocoa.NSWindow;

import dwt.dwthelper.utils;
import dwt.internal.c.Carbon;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSButton;
import dwt.internal.cocoa.NSButtonCell;
import dwt.internal.cocoa.NSColor;
import dwt.internal.cocoa.NSGraphicsContext;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSResponder;
import dwt.internal.cocoa.NSScreen;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSText;
import dwt.internal.cocoa.NSToolbar;
import dwt.internal.cocoa.NSView;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSWindow : NSResponder {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void addChildWindow(NSWindow childWin, NSWindowOrderingMode place) {
    OS.objc_msgSend(this.id, OS.sel_addChildWindow_ordered_, childWin !is null ? childWin.id : null, place);
}

public CGFloat alphaValue() {
    return cast(CGFloat) OS.objc_msgSend_fpret(this.id, OS.sel_alphaValue);
}

public bool areCursorRectsEnabled() {
    return OS.objc_msgSend_bool(this.id, OS.sel_areCursorRectsEnabled);
}

public void becomeKeyWindow() {
    OS.objc_msgSend(this.id, OS.sel_becomeKeyWindow);
}

public bool canBecomeKeyWindow() {
    return OS.objc_msgSend_bool(this.id, OS.sel_canBecomeKeyWindow);
}

public NSPoint cascadeTopLeftFromPoint(NSPoint topLeftPoint) {
    NSPoint result = NSPoint();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_cascadeTopLeftFromPoint_, topLeftPoint);
    return result;
}

public void close() {
    OS.objc_msgSend(this.id, OS.sel_close);
}

public NSRect contentRectForFrameRect(NSRect frameRect) {
    NSRect result = NSRect();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_contentRectForFrameRect_, frameRect);
    return result;
}

public NSView contentView() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_contentView);
    return result !is null ? new NSView(result) : null;
}

public NSPoint convertBaseToScreen(NSPoint aPoint) {
    NSPoint result = NSPoint();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_convertBaseToScreen_, aPoint);
    return result;
}

public NSPoint convertScreenToBase(NSPoint aPoint) {
    NSPoint result = NSPoint();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_convertScreenToBase_, aPoint);
    return result;
}

public NSButtonCell defaultButtonCell() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_defaultButtonCell);
    return result !is null ? new NSButtonCell(result) : null;
}

public void deminiaturize(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_deminiaturize_, sender !is null ? sender.id : null);
}

public void disableCursorRects() {
    OS.objc_msgSend(this.id, OS.sel_disableCursorRects);
}

public void display() {
    OS.objc_msgSend(this.id, OS.sel_display);
}

public void enableCursorRects() {
    OS.objc_msgSend(this.id, OS.sel_enableCursorRects);
}

public NSText fieldEditor(bool createFlag, cocoa.id anObject) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_fieldEditor_forObject_, createFlag, anObject !is null ? anObject.id : null);
    return result !is null ? new NSText(result) : null;
}

public NSResponder firstResponder() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_firstResponder);
    return result !is null ? new NSResponder(result) : null;
}

public NSRect frame() {
    NSRect result = NSRect();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_frame);
    return result;
}

public NSRect frameRectForContentRect(NSRect contentRect) {
    NSRect result = NSRect();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_frameRectForContentRect_, contentRect);
    return result;
}

public NSGraphicsContext graphicsContext() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_graphicsContext);
    return result !is null ? new NSGraphicsContext(result) : null;
}

public bool hasShadow() {
    return OS.objc_msgSend_bool(this.id, OS.sel_hasShadow);
}

public NSWindow initWithContentRect(NSRect contentRect, NSUInteger aStyle, NSBackingStoreType bufferingType, bool flag) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithContentRect_styleMask_backing_defer_, contentRect, aStyle, bufferingType, flag);
    return result is this.id ? this : (result !is null ? new NSWindow(result) : null);
}

public NSWindow initWithContentRect(NSRect contentRect, NSUInteger aStyle, NSBackingStoreType bufferingType, bool flag, NSScreen screen) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithContentRect_styleMask_backing_defer_screen_, contentRect, aStyle, bufferingType, flag, screen !is null ? screen.id : null);
    return result is this.id ? this : (result !is null ? new NSWindow(result) : null);
}

public void invalidateShadow() {
    OS.objc_msgSend(this.id, OS.sel_invalidateShadow);
}

public bool isDocumentEdited() {
    return OS.objc_msgSend_bool(this.id, OS.sel_isDocumentEdited);
}

public bool isKeyWindow() {
    return OS.objc_msgSend_bool(this.id, OS.sel_isKeyWindow);
}

public bool isMiniaturized() {
    return OS.objc_msgSend_bool(this.id, OS.sel_isMiniaturized);
}

public bool isSheet() {
    return OS.objc_msgSend_bool(this.id, OS.sel_isSheet);
}

public bool isVisible() {
    return OS.objc_msgSend_bool(this.id, OS.sel_isVisible);
}

public bool isZoomed() {
    return OS.objc_msgSend_bool(this.id, OS.sel_isZoomed);
}

public bool makeFirstResponder(NSResponder aResponder) {
    return OS.objc_msgSend_bool(this.id, OS.sel_makeFirstResponder_, aResponder !is null ? aResponder.id : null);
}

public void makeKeyAndOrderFront(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_makeKeyAndOrderFront_, sender !is null ? sender.id : null);
}

public static CGFloat minFrameWidthWithTitle(NSString aTitle, NSUInteger aStyle) {
    return cast(CGFloat)OS.objc_msgSend_fpret(OS.class_NSWindow, OS.sel_minFrameWidthWithTitle_styleMask_, aTitle !is null ? aTitle.id : null, aStyle);
}

public NSSize minSize() {
    NSSize result = NSSize();
    OS.objc_msgSend_stret(result, this.id, OS.sel_minSize);
    return result;
}

public void miniaturize(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_miniaturize_, sender !is null ? sender.id : null);
}

public NSPoint mouseLocationOutsideOfEventStream() {
    NSPoint result = NSPoint();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_mouseLocationOutsideOfEventStream);
    return result;
}

public void orderBack(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_orderBack_, sender !is null ? sender.id : null);
}

public void orderFront(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_orderFront_, sender !is null ? sender.id : null);
}

public void orderFrontRegardless() {
    OS.objc_msgSend(this.id, OS.sel_orderFrontRegardless);
}

public void orderOut(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_orderOut_, sender !is null ? sender.id : null);
}

public void orderWindow(NSWindowOrderingMode place, NSInteger otherWin) {
    OS.objc_msgSend(this.id, OS.sel_orderWindow_relativeTo_, place, otherWin);
}

public NSWindow parentWindow() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_parentWindow);
    return result is this.id ? this : (result !is null ? new NSWindow(result) : null);
}

public void removeChildWindow(NSWindow childWin) {
    OS.objc_msgSend(this.id, OS.sel_removeChildWindow_, childWin !is null ? childWin.id : null);
}

public NSScreen screen() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_screen);
    return result !is null ? new NSScreen(result) : null;
}

public void sendEvent(NSEvent theEvent) {
    OS.objc_msgSend(this.id, OS.sel_sendEvent_, theEvent !is null ? theEvent.id : null);
}

public void setAcceptsMouseMovedEvents(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setAcceptsMouseMovedEvents_, flag);
}

public void setAlphaValue(CGFloat windowAlpha) {
    OS.objc_msgSend(this.id, OS.sel_setAlphaValue_, windowAlpha);
}

public void setBackgroundColor(NSColor color) {
    OS.objc_msgSend(this.id, OS.sel_setBackgroundColor_, color !is null ? color.id : null);
}

public void setContentView(NSView aView) {
    OS.objc_msgSend(this.id, OS.sel_setContentView_, aView !is null ? aView.id : null);
}

public void setDefaultButtonCell(NSButtonCell defButt) {
    OS.objc_msgSend(this.id, OS.sel_setDefaultButtonCell_, defButt !is null ? defButt.id : null);
}

public void setDelegate(cocoa.id anObject) {
    OS.objc_msgSend(this.id, OS.sel_setDelegate_, anObject !is null ? anObject.id : null);
}

public void setDocumentEdited(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setDocumentEdited_, flag);
}

public void setFrame(NSRect frameRect, bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setFrame_display_, frameRect, flag);
}

public void setFrame(NSRect frameRect, bool displayFlag, bool animateFlag) {
    OS.objc_msgSend(this.id, OS.sel_setFrame_display_animate_, frameRect, displayFlag, animateFlag);
}

public void setHasShadow(bool hasShadow) {
    OS.objc_msgSend(this.id, OS.sel_setHasShadow_, hasShadow);
}

public void setLevel(NSInteger newLevel) {
    OS.objc_msgSend(this.id, OS.sel_setLevel_, newLevel);
}

public void setMinSize(NSSize size) {
    OS.objc_msgSend(this.id, OS.sel_setMinSize_, size);
}

public void setOpaque(bool isOpaque) {
    OS.objc_msgSend(this.id, OS.sel_setOpaque_, isOpaque);
}

public void setReleasedWhenClosed(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setReleasedWhenClosed_, flag);
}

public void setShowsResizeIndicator(bool show) {
    OS.objc_msgSend(this.id, OS.sel_setShowsResizeIndicator_, show);
}

public void setShowsToolbarButton(bool show) {
    OS.objc_msgSend(this.id, OS.sel_setShowsToolbarButton_, show);
}

public void setTitle(NSString aString) {
    OS.objc_msgSend(this.id, OS.sel_setTitle_, aString !is null ? aString.id : null);
}

public void setToolbar(NSToolbar toolbar) {
    OS.objc_msgSend(this.id, OS.sel_setToolbar_, toolbar !is null ? toolbar.id : null);
}

public NSButton standardWindowButton(NSWindingButton b) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_standardWindowButton_, b);
    return result !is null ? new NSButton(result) : null;
}

public NSUInteger styleMask() {
    return OS.objc_msgSend(this.id, OS.sel_styleMask);
}

public void toggleToolbarShown(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_toggleToolbarShown_, sender !is null ? sender.id : null);
}

public NSToolbar toolbar() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_toolbar);
    return result !is null ? new NSToolbar(result) : null;
}

public NSInteger windowNumber() {
    return OS.objc_msgSend(this.id, OS.sel_windowNumber);
}

public void zoom(cocoa.id sender) {
    OS.objc_msgSend(this.id, OS.sel_zoom_, sender !is null ? sender.id : null);
}

}
