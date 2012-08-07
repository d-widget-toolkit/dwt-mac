/*******************************************************************************
 * Copyright (c) 2000, 2009 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     
 * Port to the D programming language:
 *     Jacob Carlborg <doob@me.com>
 *******************************************************************************/
module dwt.widgets.Scrollable;


import dwt.internal.cocoa.*;

import dwt.*;
import dwt.graphics.*;

import dwt.dwthelper.utils;
import objc = dwt.internal.objc.runtime;
import dwt.widgets.Composite;
import dwt.widgets.Control;
import dwt.widgets.Display;
import dwt.widgets.ScrollBar;
import dwt.widgets.Widget;

/**
 * This class is the abstract superclass of all classes which
 * represent controls that have standard scroll bars.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>H_SCROLL, V_SCROLL</dd>
 * <dt><b>Events:</b>
 * <dd>(none)</dd>
 * </dl>
 * <p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the DWT implementation.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 * @noextend This class is not intended to be subclassed by clients.
 */
public abstract class Scrollable : Control {
    
    alias Widget.setInputState setInputState;
    
    NSScrollView scrollView;
    ScrollBar horizontalBar, verticalBar;
    
this () {
    /* Do nothing */
}

/**
 * Constructs a new instance of this class given its parent
 * and a style value describing its behavior and appearance.
 * <p>
 * The style value is either one of the style constants defined in
 * class <code>DWT</code> which is applicable to instances of this
 * class, or must be built by <em>bitwise OR</em>'ing together 
 * (that is, using the <code>int</code> "|" operator) two or more
 * of those <code>DWT</code> style constants. The class description
 * lists the style constants that are applicable to the class.
 * Style bits are also inherited from superclasses.
 * </p>
 *
 * @param parent a composite control which will be the parent of the new instance (cannot be null)
 * @param style the style of control to construct
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see DWT#H_SCROLL
 * @see DWT#V_SCROLL
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, style);
}

bool accessibilityIsIgnored(objc.id id, objc.SEL sel) {
    // Always ignore scrollers.
    if (scrollView !is null && id is scrollView.id) return true;
    return super.accessibilityIsIgnored(id, sel);   
}

/**
 * Given a desired <em>client area</em> for the receiver
 * (as described by the arguments), returns the bounding
 * rectangle which would be required to produce that client
 * area.
 * <p>
 * In other words, it returns a rectangle such that, if the
 * receiver's bounds were set to that rectangle, the area
 * of the receiver which is capable of displaying data
 * (that is, not covered by the "trimmings") would be the
 * rectangle described by the arguments (relative to the
 * receiver's parent).
 * </p>
 * 
 * @param x the desired x coordinate of the client area
 * @param y the desired y coordinate of the client area
 * @param width the desired width of the client area
 * @param height the desired height of the client area
 * @return the required bounds to produce the given client area
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #getClientArea
 */
public Rectangle computeTrim (int x, int y, int width, int height) {
    checkWidget();
    if (scrollView !is null) {
        NSSize size = NSSize();
        size.width = width;
        size.height = height;
        NSBorderType border = hasBorder() ? OS.NSBezelBorder : OS.NSNoBorder;
        size = NSScrollView.frameSizeForContentSize(size, (style & DWT.H_SCROLL) !is 0, (style & DWT.V_SCROLL) !is 0, border);
        width = cast(int)size.width;
        height = cast(int)size.height;
        NSRect frame = scrollView.contentView().frame();
        x -= frame.x;
        y -= frame.y;
    }
    return new Rectangle (x, y, width, height);
}

ScrollBar createScrollBar (int style) {
    if (scrollView is null) return null;
    ScrollBar bar = new ScrollBar ();
    bar.parent = this;
    bar.style = style;
    bar.display = display;
    NSScroller scroller;
    objc.SEL actionSelector;
    NSRect rect = NSRect();
    if ((style & DWT.H_SCROLL) !is 0) {
        rect.width = 1;
    } else {
        rect.height = 1;
    }
    scroller = cast(NSScroller)(new SWTScroller()).alloc();
    scroller.initWithFrame(rect);
    if ((style & DWT.H_SCROLL) !is 0) {
        scrollView.setHorizontalScroller(scroller);
        actionSelector = OS.sel_sendHorizontalSelection;
    } else {
        scrollView.setVerticalScroller(scroller);
        actionSelector = OS.sel_sendVerticalSelection;
    }
    bar.view = scroller;
    bar.createJNIRef();
    bar.register();
    if ((state & CANVAS) is 0) {
        bar.target = scroller.target();
        bar.actionSelector = scroller.action();
    }
    scroller.setTarget(scrollView);
    scroller.setAction(actionSelector);
    if ((state & CANVAS) !is 0) {
        bar.updateBar(0, 0, 100, 10);
    }
    return bar;
}

void createWidget () {
    super.createWidget ();
    if ((style & DWT.H_SCROLL) !is 0) horizontalBar = createScrollBar (DWT.H_SCROLL);
    if ((style & DWT.V_SCROLL) !is 0) verticalBar = createScrollBar (DWT.V_SCROLL);
}

void deregister () {
    super.deregister ();
    if (scrollView !is null) display.removeWidget (scrollView);
}

/**
 * Returns a rectangle which describes the area of the
 * receiver which is capable of displaying data (that is,
 * not covered by the "trimmings").
 * 
 * @return the client area
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #computeTrim
 */
public Rectangle getClientArea () {
    checkWidget();
    if (scrollView !is null) {
        NSSize size = scrollView.contentSize();
        NSClipView contentView = scrollView.contentView();
        NSRect bounds = contentView.bounds();
        return new Rectangle((int)bounds.x, (int)bounds.y, (int)size.width, (int)size.height);
    } else {
        NSRect rect = view.bounds();
        return new Rectangle(0, 0, cast(int)rect.width, cast(int)rect.height);
    }
}

/**
 * Returns the receiver's horizontal scroll bar if it has
 * one, and null if it does not.
 *
 * @return the horizontal scroll bar (or null)
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public ScrollBar getHorizontalBar () {
    checkWidget();
    return horizontalBar;
}

/**
 * Returns the receiver's vertical scroll bar if it has
 * one, and null if it does not.
 *
 * @return the vertical scroll bar (or null)
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public ScrollBar getVerticalBar () {
    checkWidget();
    return verticalBar;
}

bool hooksKeys () {
    return hooks (DWT.KeyDown) || hooks (DWT.KeyUp) || hooks (DWT.Traverse);
}

bool isEventView (int /*long*/ id) {
    return id is eventView ().id;
}

bool isTrim (NSView view) {
    if (scrollView !is null) {
        if (scrollView.id is view.id) return true;
        if (horizontalBar !is null && horizontalBar.view.id is view.id) return true;
        if (verticalBar !is null && verticalBar.view.id is view.id) return true;
    }
    return super.isTrim (view);
}

void register () {
    super.register ();
    if (scrollView !is null) display.addWidget (scrollView, this);
}

void releaseHandle () {
    super.releaseHandle ();
    if (scrollView !is null) scrollView.release();
    scrollView = null;
}

void releaseChildren (bool destroy) {
    if (horizontalBar !is null) {
        horizontalBar.release (false);
        horizontalBar = null;
    }
    if (verticalBar !is null) {
        verticalBar.release (false);
        verticalBar = null;
    }
    super.releaseChildren (destroy);
}

void sendHorizontalSelection () {
    if ((state & CANVAS) is 0 && scrollView !is null && visibleRgn is 0) {
        scrollView.contentView().setCopiesOnScroll(!isObscured());
    }
    horizontalBar.sendSelection ();
}

void sendVerticalSelection () {
    if ((state & CANVAS) is 0 && scrollView !is null && visibleRgn is 0) {
        scrollView.contentView().setCopiesOnScroll(!isObscured());
    }
    verticalBar.sendSelection ();
}

void enableWidget (bool enabled) {
    super.enableWidget (enabled);
    if (horizontalBar !is null) horizontalBar.enableWidget (enabled);
    if (verticalBar !is null) verticalBar.enableWidget (enabled);
}

bool setScrollBarVisible (ScrollBar bar, bool visible) {
    if (scrollView is null) return false;
    if ((state & CANVAS) is 0) return false;
    if (visible) {
        if ((bar.state & HIDDEN) is 0) return false;
        bar.state &= ~HIDDEN;
    } else {
        if ((bar.state & HIDDEN) !is 0) return false;
        bar.state |= HIDDEN;
    }
    if ((bar.style & DWT.HORIZONTAL) !is 0) {
        scrollView.setHasHorizontalScroller (visible);
    } else {
        scrollView.setHasVerticalScroller (visible);
    }
    bar.sendEvent (visible ? DWT.Show : DWT.Hide);
    sendEvent (DWT.Resize);
    return true;
}

void setZOrder () {
    super.setZOrder ();
    if (scrollView !is null) scrollView.setDocumentView (view);
}

NSView topView () {
    if (scrollView !is null) return scrollView;
    return super.topView ();
}

void updateCursorRects (bool enabled) {
    super.updateCursorRects (enabled);
    if (scrollView is null) return;
    updateCursorRects (enabled, scrollView);    
    NSClipView contentView = scrollView.contentView ();
    updateCursorRects (enabled, contentView);
}

}
