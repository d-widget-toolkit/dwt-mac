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
module dwt.internal.cocoa.NSView;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSEvent;
import dwt.internal.cocoa.NSGraphicsContext;
import dwt.internal.cocoa.NSImage;
import dwt.internal.cocoa.NSMenu;
import dwt.internal.cocoa.NSPasteboard;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSResponder;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSTrackingArea;
import dwt.internal.cocoa.NSWindow;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSView : NSResponder {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public bool acceptsFirstMouse(NSEvent theEvent) {
    return OS.objc_msgSend_bool(this.id, OS.sel_acceptsFirstMouse_, theEvent !is null ? theEvent.id : null);
}

public void addSubview(NSView aView) {
    OS.objc_msgSend(this.id, OS.sel_addSubview_, aView !is null ? aView.id : null);
}

public void addSubview(NSView aView, NSWindowOrderingMode place, NSView otherView) {
    OS.objc_msgSend(this.id, OS.sel_addSubview_positioned_relativeTo_, aView !is null ? aView.id : null, place, otherView !is null ? otherView.id : null);
}

public NSToolTipTag addToolTipRect(NSRect aRect, cocoa.id anObject, void* data) {
    return cast(NSToolTipTag) OS.objc_msgSend(this.id, OS.sel_addToolTipRect_owner_userData_, aRect, anObject !is null ? anObject.id : null, data);
}

public void beginDocument() {
    OS.objc_msgSend(this.id, OS.sel_beginDocument);
}

public void beginPageInRect(NSRect aRect, NSPoint location) {
    OS.objc_msgSend(this.id, OS.sel_beginPageInRect_atPlacement_, aRect, location);
}

public NSRect bounds() {
    return OS.objc_msgSend_stret!(NSRect)(this.id, OS.sel_bounds);
}

public bool canBecomeKeyView() {
    return OS.objc_msgSend_bool(this.id, OS.sel_canBecomeKeyView);
}

public NSPoint convertPoint_fromView_(NSPoint aPoint, NSView aView) {
    return OS.objc_msgSend_stret!(NSPoint)(this.id, OS.sel_convertPoint_fromView_, aPoint, aView !is null ? aView.id : null);
}

public NSPoint convertPoint_toView_(NSPoint aPoint, NSView aView) {
    return OS.objc_msgSend_stret!(NSPoint)(this.id, OS.sel_convertPoint_toView_, aPoint, aView !is null ? aView.id : null);
}

public NSPoint convertPointFromBase(NSPoint aPoint) {
    return OS.objc_msgSend_stret!(NSPoint)(this.id, OS.sel_convertPointFromBase_, aPoint);
}

public NSPoint convertPointToBase(NSPoint aPoint) {
    return OS.objc_msgSend_stret!(NSPoint)(this.id, OS.sel_convertPointToBase_, aPoint);
}

public NSRect convertRect_fromView_(NSRect aRect, NSView aView) {
    return OS.objc_msgSend_stret!(NSRect)(this.id, OS.sel_convertRect_fromView_, aRect, aView !is null ? aView.id : null);
}

public NSRect convertRect_toView_(NSRect aRect, NSView aView) {
    return OS.objc_msgSend_stret!(NSRect)(this.id, OS.sel_convertRect_toView_, aRect, aView !is null ? aView.id : null);
}

public NSRect convertRectFromBase(NSRect aRect) {
    return OS.objc_msgSend_stret!(NSRect)(this.id, OS.sel_convertRectFromBase_, aRect);
}

public NSRect convertRectToBase(NSRect aRect) {
    return OS.objc_msgSend_stret!(NSRect)(this.id, OS.sel_convertRectToBase_, aRect);
}

public NSSize convertSize_fromView_(NSSize aSize, NSView aView) {
    return OS.objc_msgSend_stret!(NSSize)(this.id, OS.sel_convertSize_fromView_, aSize, aView !is null ? aView.id : null);
}

public NSSize convertSize_toView_(NSSize aSize, NSView aView) {
    return OS.objc_msgSend_stret!(NSSize)(this.id, OS.sel_convertSize_toView_, aSize, aView !is null ? aView.id : null);
}

public NSSize convertSizeFromBase(NSSize aSize) {
    return OS.objc_msgSend_stret!(NSSize)(this.id, OS.sel_convertSizeFromBase_, aSize);
}

public NSSize convertSizeToBase(NSSize aSize) {
    return OS.objc_msgSend_stret!(NSSize)(this.id, OS.sel_convertSizeToBase_, aSize);
}

public void discardCursorRects() {
    OS.objc_msgSend(this.id, OS.sel_discardCursorRects);
}

public void display() {
    OS.objc_msgSend(this.id, OS.sel_display);
}

public void displayIfNeeded() {
    OS.objc_msgSend(this.id, OS.sel_displayIfNeeded);
}

public void displayRectIgnoringOpacity(NSRect aRect, NSGraphicsContext context) {
    OS.objc_msgSend(this.id, OS.sel_displayRectIgnoringOpacity_inContext_, aRect, context !is null ? context.id : null);
}

public void dragImage(NSImage anImage, NSPoint viewLocation, NSSize initialOffset, NSEvent event, NSPasteboard pboard, cocoa.id sourceObj, bool slideFlag) {
    OS.objc_msgSend(this.id, OS.sel_dragImage_at_offset_event_pasteboard_source_slideBack_, anImage !is null ? anImage.id : null, viewLocation, initialOffset, event !is null ? event.id : null, pboard !is null ? pboard.id : null, sourceObj !is null ? sourceObj.id : null, slideFlag);
}

public void drawRect(NSRect rect) {
    OS.objc_msgSend(this.id, OS.sel_drawRect_, rect);
}

public void endDocument() {
    OS.objc_msgSend(this.id, OS.sel_endDocument);
}

public void endPage() {
    OS.objc_msgSend(this.id, OS.sel_endPage);
}

public NSRect frame() {
    return OS.objc_msgSend_stret!(NSRect)(this.id, OS.sel_frame);
}

public NSView hitTest(NSPoint aPoint) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_hitTest_, aPoint);
    return result is this.id ? this : (result !is null ? new NSView(result) : null);
}

public NSView initWithFrame(NSRect frameRect) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithFrame_, frameRect);
    return result is this.id ? this : (result !is null ? new NSView(result) : null);
}

public bool isFlipped() {
    return OS.objc_msgSend_bool(this.id, OS.sel_isFlipped);
}

public bool isHidden() {
    return OS.objc_msgSend_bool(this.id, OS.sel_isHidden);
}

public bool isHiddenOrHasHiddenAncestor() {
    return OS.objc_msgSend_bool(this.id, OS.sel_isHiddenOrHasHiddenAncestor);
}

public bool isOpaque() {
    return OS.objc_msgSend_bool(this.id, OS.sel_isOpaque);
}

public void lockFocus() {
    OS.objc_msgSend(this.id, OS.sel_lockFocus);
}

public NSMenu menuForEvent(NSEvent event) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_menuForEvent_, event !is null ? event.id : null);
    return result !is null ? new NSMenu(result) : null;
}

public void registerForDraggedTypes(NSArray newTypes) {
    OS.objc_msgSend(this.id, OS.sel_registerForDraggedTypes_, newTypes !is null ? newTypes.id : null);
}

public void removeFromSuperview() {
    OS.objc_msgSend(this.id, OS.sel_removeFromSuperview);
}

public void removeTrackingArea(NSTrackingArea trackingArea) {
    OS.objc_msgSend(this.id, OS.sel_removeTrackingArea_, trackingArea !is null ? trackingArea.id : null);
}

public void resetCursorRects() {
    OS.objc_msgSend(this.id, OS.sel_resetCursorRects);
}

public void scrollPoint(NSPoint aPoint) {
    OS.objc_msgSend(this.id, OS.sel_scrollPoint_, aPoint);
}

public bool scrollRectToVisible(NSRect aRect) {
    return OS.objc_msgSend_bool(this.id, OS.sel_scrollRectToVisible_, aRect);
}

public void setAutoresizesSubviews(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setAutoresizesSubviews_, flag);
}

public void setAutoresizingMask(NSUInteger mask) {
    OS.objc_msgSend(this.id, OS.sel_setAutoresizingMask_, mask);
}

public void setFocusRingType(NSFocusRingType focusRingType) {
    OS.objc_msgSend(this.id, OS.sel_setFocusRingType_, focusRingType);
}

public void setFrame(NSRect frameRect) {
    OS.objc_msgSend(this.id, OS.sel_setFrame_, frameRect);
}

public void setFrameOrigin(NSPoint newOrigin) {
    OS.objc_msgSend(this.id, OS.sel_setFrameOrigin_, newOrigin);
}

public void setFrameSize(NSSize newSize) {
    OS.objc_msgSend(this.id, OS.sel_setFrameSize_, newSize);
}

public void setHidden(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setHidden_, flag);
}

public void setNeedsDisplay(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setNeedsDisplay_, flag);
}

public void setNeedsDisplayInRect(NSRect invalidRect) {
    OS.objc_msgSend(this.id, OS.sel_setNeedsDisplayInRect_, invalidRect);
}

public void setToolTip(NSString string) {
    OS.objc_msgSend(this.id, OS.sel_setToolTip_, string !is null ? string.id : null);
}

public bool shouldDelayWindowOrderingForEvent(NSEvent theEvent) {
    return OS.objc_msgSend_bool(this.id, OS.sel_shouldDelayWindowOrderingForEvent_, theEvent !is null ? theEvent.id : null);
}

public NSArray subviews() {
	objc.id result = OS.objc_msgSend(this.id, OS.sel_subviews);
	return result !is null ? new NSArray(result) : null;
}

public NSView superview() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_superview);
    return result is this.id ? this : (result !is null ? new NSView(result) : null);
}

public NSArray trackingAreas() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_trackingAreas);
    return result !is null ? new NSArray(result) : null;
}

public void unlockFocus() {
    OS.objc_msgSend(this.id, OS.sel_unlockFocus);
}

public void unregisterDraggedTypes() {
    OS.objc_msgSend(this.id, OS.sel_unregisterDraggedTypes);
}

public void updateTrackingAreas() {
    OS.objc_msgSend(this.id, OS.sel_updateTrackingAreas);
}

public void viewDidMoveToWindow() {
    OS.objc_msgSend(this.id, OS.sel_viewDidMoveToWindow);
}

public NSRect visibleRect() {
    return OS.objc_msgSend_stret!(NSRect)(this.id, OS.sel_visibleRect);
}

public NSWindow window() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_window);
    return result !is null ? new NSWindow(result) : null;
}

}
