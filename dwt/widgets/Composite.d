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
module dwt.widgets.Composite;


import dwt.*;
import dwt.accessibility.*;
import dwt.graphics.*;
import dwt.internal.cocoa.*;
import cocoa = dwt.internal.cocoa.id;

import dwt.dwthelper.utils;
import Carbon = dwt.internal.c.Carbon;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;
import dwt.widgets.Control;
import dwt.widgets.Decorations;
import dwt.widgets.Display;
import dwt.widgets.Event;
import dwt.widgets.Layout;
import dwt.widgets.Menu;
import dwt.widgets.Scrollable;
import dwt.widgets.ScrollBar;
import dwt.widgets.Shell;
import dwt.widgets.Widget;

import tango.io.Stdout;

/**
 * Instances of this class are controls which are capable
 * of containing other controls.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>NO_BACKGROUND, NO_FOCUS, NO_MERGE_PAINTS, NO_REDRAW_RESIZE, NO_RADIO_GROUP, EMBEDDED, DOUBLE_BUFFERED</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
 * </dl>
 * <p>
 * Note: The <code>NO_BACKGROUND</code>, <code>NO_FOCUS</code>, <code>NO_MERGE_PAINTS</code>,
 * and <code>NO_REDRAW_RESIZE</code> styles are intended for use with <code>Canvas</code>.
 * They can be used with <code>Composite</code> if you are drawing your own, but their
 * behavior is undefined if they are used with subclasses of <code>Composite</code> other
 * than <code>Canvas</code>.
 * </p><p>
 * Note: The <code>CENTER</code> style, although undefined for composites, has the
 * same value as <code>EMBEDDED</code> which is used to embed widgets from other
 * widget toolkits into DWT.  On some operating systems (GTK, Motif), this may cause
 * the children of this composite to be obscured.
 * </p><p>
 * This class may be subclassed by custom control implementors
 * who are building controls that are constructed from aggregates
 * of other controls.
 * </p>
 *
 * @see Canvas
 * @see <a href="http://www.eclipse.org/swt/snippets/#composite">Composite snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class Composite : Scrollable {
    
    alias Scrollable.computeSize computeSize;
    alias Scrollable.forceFocus forceFocus;
    alias Scrollable.moveAbove moveAbove;
    alias Scrollable.moveBelow moveBelow;
    alias Scrollable.setBounds setBounds;
    alias Scrollable.translateTraversal translateTraversal;
    
    Layout layout_;
    Control[] tabList;
    int layoutCount, backgroundMode;
    
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
 * @param parent a widget which will be the parent of the new instance (cannot be null)
 * @param style the style of widget to construct
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 * </ul>
 *
 * @see DWT#NO_BACKGROUND
 * @see DWT#NO_FOCUS
 * @see DWT#NO_MERGE_PAINTS
 * @see DWT#NO_REDRAW_RESIZE
 * @see DWT#NO_RADIO_GROUP
 * @see DWT#EMBEDDED
 * @see DWT#DOUBLE_BUFFERED
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, style);
}

Control [] _getChildren () {
    auto vi = view.id;
    NSArray views = contentView().subviews();
    NSUInteger count = views.count();
    Control [] children = new Control [count];
    if (count is 0) return children;
    NSUInteger j = 0;
    for (NSUInteger i=0; i<count; i++){auto o = views.objectAtIndex (count - i - 1).id;
        Widget widget = display.getWidget (views.objectAtIndex (count - i - 1).id);
        if (widget !is null && widget !is this && cast(Control) widget) {
            children [j++] = cast(Control) widget;
        }
    }
    if (j is count) return children;
    Control [] newChildren = new Control [j];
    System.arraycopy (children, 0, newChildren, 0, j);
    return newChildren;
}

Control [] _getTabList () {
    if (tabList is null) return null;
    int count = 0;
    for (int i=0; i<tabList.length; i++) {
        if (!tabList [i].isDisposed ()) count++;
    }
    if (count is tabList.length) return tabList;
    Control [] newList = new Control [count];
    int index = 0;
    for (int i=0; i<tabList.length; i++) {
        if (!tabList [i].isDisposed ()) {
            newList [index++] = tabList [i];
        }
    }
    tabList = newList;
    return tabList;
}

bool acceptsFirstResponder (objc.id id, objc.SEL sel) {
    if ((state & CANVAS) !is 0) {
        if ((style & DWT.NO_FOCUS) is 0 && hooksKeys ()) {
            if (contentView().subviews().count() is 0) return true;
        }
        return false;
    }
    return super.acceptsFirstResponder (id, sel);
}

objc.id accessibilityAttributeNames(objc.id id, objc.SEL sel) {
    
    if (id is view.id) {
        if (accessible !is null) {
            // If there is an accessible, it may provide its own list of attributes if it's a lightweight control.
            // If not, let Cocoa handle it for this view.
            cocoa.id returnObject = accessible.internal_accessibilityAttributeNames(ACC.CHILDID_SELF);
            if (returnObject !is null) return returnObject.id;
        }
    }
    
    return super.accessibilityAttributeNames(id, sel);
}

bool accessibilityIsIgnored(objc.id id, objc.SEL sel) {
    // If we have an accessible and it represents a valid accessible role, this view is not ignored.
    if (view !is null && id is view.id) {
        if (accessible !is null) {
            cocoa.id role = accessible.internal_accessibilityAttributeValue(OS.NSAccessibilityRoleAttribute, ACC.CHILDID_SELF);
            if (role !is null) return false; 
        }
    }

    return super.accessibilityIsIgnored(id, sel);
}

/**
 * Clears any data that has been cached by a Layout for all widgets that 
 * are in the parent hierarchy of the changed control up to and including the 
 * receiver.  If an ancestor does not have a layout, it is skipped.
 * 
 * @param changed an array of controls that changed state and require a recalculation of size
 * 
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the changed array is null any of its controls are null or have been disposed</li> 
 *    <li>ERROR_INVALID_PARENT - if any control in changed is not in the widget tree of the receiver</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public void changed (Control[] changed) {
    checkWidget ();
    if (changed is null) error (DWT.ERROR_INVALID_ARGUMENT);
    for (int i=0; i<changed.length; i++) {
        Control control = changed [i];
        if (control is null) error (DWT.ERROR_INVALID_ARGUMENT);
        if (control.isDisposed ()) error (DWT.ERROR_INVALID_ARGUMENT);
        bool ancestor = false;
        Composite composite = control.parent;
        while (composite !is null) {
            ancestor = composite is this;
            if (ancestor) break;
            composite = composite.parent;
        }
        if (!ancestor) error (DWT.ERROR_INVALID_PARENT);
    }
    for (int i=0; i<changed.length; i++) {
        Control child = changed [i];
        Composite composite = child.parent;
        while (child !is this) {
            if (composite.layout_ is null || !composite.layout_.flushCache (child)) {
                composite.state |= LAYOUT_CHANGED;
            }
            child = composite;
            composite = child.parent;
        }
    }
}

public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget();
    Point size;
    if (layout_ !is null) {
        if ((wHint is DWT.DEFAULT) || (hHint is DWT.DEFAULT)) {
            changed |= (state & LAYOUT_CHANGED) !is 0;
            size = layout_.computeSize (this, wHint, hHint, changed);
            state &= ~LAYOUT_CHANGED;
        } else {
            size = new Point (wHint, hHint);
        }
    } else {
        size = minimumSize (wHint, hHint, changed);
    }
    if (size.x is 0) size.x = DEFAULT_WIDTH;
    if (size.y is 0) size.y = DEFAULT_HEIGHT;
    if (wHint !is DWT.DEFAULT) size.x = wHint;
    if (hHint !is DWT.DEFAULT) size.y = hHint;
    Rectangle trim = computeTrim (0, 0, size.x, size.y);
    return new Point (trim.width, trim.height);
}

protected void checkSubclass () {
    /* Do nothing - Subclassing is allowed */
}

Widget [] computeTabList () {
    Widget result [] = super.computeTabList ();
    if (result.length is 0) return result;
    Control [] list = tabList !is null ? _getTabList () : _getChildren ();
    for (int i=0; i<list.length; i++) {
        Control child = list [i];
        Widget [] childList = child.computeTabList ();
        if (childList.length !is 0) {
            Widget [] newResult = new Widget [result.length + childList.length];
            System.arraycopy (result, 0, newResult, 0, result.length);
            System.arraycopy (childList, 0, newResult, result.length, childList.length);
            result = newResult;
        }
    }
    return result;
}

void createHandle () {
    state |= CANVAS;
    bool scrolled = (style & (DWT.V_SCROLL | DWT.H_SCROLL)) !is 0;
    if (!scrolled)  state |= THEME_BACKGROUND;
    NSRect rect = NSRect();
    if (scrolled || hasBorder ()) {
        NSScrollView scrollWidget = cast(NSScrollView)(new SWTScrollView()).alloc();
        scrollWidget.initWithFrame (rect);
        scrollWidget.setDrawsBackground(false);
        if ((style & DWT.H_SCROLL) !is 0) scrollWidget.setHasHorizontalScroller(true);
        if ((style & DWT.V_SCROLL) !is 0) scrollWidget.setHasVerticalScroller(true);
        scrollWidget.setBorderType(hasBorder() ? OS.NSBezelBorder : OS.NSNoBorder);
        scrollView = scrollWidget;
    }
    NSView widget = (NSView)new SWTCanvasView().alloc();
    widget.initWithFrame (rect);
//  widget.setFocusRingType(OS.NSFocusRingTypeExterior);
    view = widget;
    if (scrollView !is null) {
        NSClipView contentView = scrollView.contentView();
        contentView.setAutoresizesSubviews(true);
        view.setAutoresizingMask(OS.NSViewWidthSizable | OS.NSViewHeightSizable);
    }
}

void drawBackground (objc.id id, NSGraphicsContext context, NSRect rect) {
    if (id !is view.id) return;
    if ((state & CANVAS) !is 0) {
        if ((style & DWT.NO_BACKGROUND) is 0) {
            fillBackground (view, context, rect, -1);
        }
    }
}

Composite findDeferredControl () {
    return layoutCount > 0 ? this : parent.findDeferredControl ();
}

Menu [] findMenus (Control control) {
    if (control is this) return new Menu [0];
    Menu result [] = super.findMenus (control);
    Control [] children = _getChildren ();
    for (int i=0; i<children.length; i++) {
        Control child = children [i];
        Menu [] menuList = child.findMenus (control);
        if (menuList.length !is 0) {
            Menu [] newResult = new Menu [result.length + menuList.length];
            System.arraycopy (result, 0, newResult, 0, result.length);
            System.arraycopy (menuList, 0, newResult, result.length, menuList.length);
            result = newResult;
        }
    }
    return result;
}

void fixChildren (Shell newShell, Shell oldShell, Decorations newDecorations, Decorations oldDecorations, Menu [] menus) {
    super.fixChildren (newShell, oldShell, newDecorations, oldDecorations, menus);
    Control [] children = _getChildren ();
    for (int i=0; i<children.length; i++) {
        children [i].fixChildren (newShell, oldShell, newDecorations, oldDecorations, menus);
    }
}

void fixTabList (Control control) {
    if (tabList is null) return;
    int count = 0;
    for (int i=0; i<tabList.length; i++) {
        if (tabList [i] is control) count++;
    }
    if (count is 0) return;
    Control [] newList = null;
    int length = tabList.length - count;
    if (length !is 0) {
        newList = new Control [length];
        int index = 0;
        for (int i=0; i<tabList.length; i++) {
            if (tabList [i] !is control) {
                newList [index++] = tabList [i];
            }
        }
    }
    tabList = newList;
}

/**
 * Returns the receiver's background drawing mode. This
 * will be one of the following constants defined in class
 * <code>DWT</code>:
 * <code>INHERIT_NONE</code>, <code>INHERIT_DEFAULT</code>,
 * <code>INHERTIT_FORCE</code>.
 *
 * @return the background mode
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see DWT
 * 
 * @since 3.2
 */
public int getBackgroundMode () {
    checkWidget ();
    return backgroundMode;
}

/**
 * Returns a (possibly empty) array containing the receiver's children.
 * Children are returned in the order that they are drawn.  The topmost
 * control appears at the beginning of the array.  Subsequent controls
 * draw beneath this control and appear later in the array.
 * <p>
 * Note: This is not the actual structure used by the receiver
 * to maintain its list of children, so modifying the array will
 * not affect the receiver. 
 * </p>
 *
 * @return an array of children
 * 
 * @see Control#moveAbove
 * @see Control#moveBelow
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Control [] getChildren () {
    checkWidget();
    return _getChildren ();
}

/**
 * Returns layout which is associated with the receiver, or
 * null if one has not been set.
 *
 * @return the receiver's layout or null
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Layout getLayout () {
    checkWidget();
    return layout_;
}

/**
 * Returns <code>true</code> if the receiver has deferred
 * the performing of layout, and <code>false</code> otherwise.
 *
 * @return the receiver's deferred layout state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * 
 * @see #setLayoutDeferred(bool)
 * @see #isLayoutDeferred()
 *
 * @since 3.1
 */
public bool getLayoutDeferred () {
    checkWidget ();
    return layoutCount > 0 ;
}

/**
 * Gets the (possibly empty) tabbing order for the control.
 *
 * @return tabList the ordered list of controls representing the tab order
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * 
 * @see #setTabList
 */
public Control [] getTabList () {
    checkWidget ();
    Control [] tabList = _getTabList ();
    if (tabList is null) {
        int count = 0;
        Control [] list =_getChildren ();
        for (int i=0; i<list.length; i++) {
            if (list [i].isTabGroup ()) count++;
        }
        tabList = new Control [count];
        int index = 0;
        for (int i=0; i<list.length; i++) {
            if (list [i].isTabGroup ()) {
                tabList [index++] = list [i];
            }
        }
    }
    return tabList;
}

bool hooksKeys () {
    return hooks (DWT.KeyDown) || hooks (DWT.KeyUp);
}

void invalidateChildrenVisibleRegion () {
    Control [] children = _getChildren ();
    for (int i=0; i<children.length; i++) {
        Control child = children [i];
        child.resetVisibleRegion ();
        child.invalidateChildrenVisibleRegion ();
    }
}

/**
 * Returns <code>true</code> if the receiver or any ancestor 
 * up to and including the receiver's nearest ancestor shell
 * has deferred the performing of layouts.  Otherwise, <code>false</code>
 * is returned.
 *
 * @return the receiver's deferred layout state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * 
 * @see #setLayoutDeferred(bool)
 * @see #getLayoutDeferred()
 * 
 * @since 3.1
 */
public bool isLayoutDeferred () {
    checkWidget ();
    return findDeferredControl () !is null;
}

bool isOpaque (objc.id id, objc.SEL sel) {
    if ((state & CANVAS) !is 0) {
        if (id is view.id) {
            if (region is null && background !is null && background[3] is 1) {
                return true;
            }
        }
    }
    return super.isOpaque (id, sel);
}

bool isTabGroup () {
    if ((state & CANVAS) !is 0) return true;
    return super.isTabGroup ();
}

void keyDown (objc.id id, objc.SEL sel, objc.id theEvent) {
    if (view.window ().firstResponder ().id is id) {
        if ((state & CANVAS) !is 0) {
            Shell s = this.getShell();
            NSArray array = NSArray.arrayWithObject (new NSEvent (theEvent));
            s.keyInputHappened = false;
            view.interpretKeyEvents (array);
            if (imeInComposition ()) return;
            if (!s.keyInputHappened) {
                NSEvent nsEvent = new NSEvent (theEvent);
                bool [] consume = new bool [1];
                if (translateTraversal (nsEvent.keyCode (), nsEvent, consume)) return;
                if (isDisposed ()) return;
                if (!sendKeyEvent (nsEvent, DWT.KeyDown)) return;
                if (consume [0]) return;
            }
            return;
        }
    }
    super.keyDown (id, sel, theEvent);
}

/**
 * If the receiver has a layout, asks the layout to <em>lay out</em>
 * (that is, set the size and location of) the receiver's children. 
 * If the receiver does not have a layout, do nothing.
 * <p>
 * This is equivalent to calling <code>layout(true)</code>.
 * </p>
 * <p>
 * Note: Layout is different from painting. If a child is
 * moved or resized such that an area in the parent is
 * exposed, then the parent will paint. If no child is
 * affected, the parent will not paint.
 * </p>
 * 
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void layout () {
    checkWidget ();
    layout (true);
}

/**
 * If the receiver has a layout, asks the layout to <em>lay out</em>
 * (that is, set the size and location of) the receiver's children. 
 * If the argument is <code>true</code> the layout must not rely
 * on any information it has cached about the immediate children. If it
 * is <code>false</code> the layout may (potentially) optimize the
 * work it is doing by assuming that none of the receiver's 
 * children has changed state since the last layout.
 * If the receiver does not have a layout, do nothing.
 * <p>
 * If a child is resized as a result of a call to layout, the 
 * resize event will invoke the layout of the child.  The layout
 * will cascade down through all child widgets in the receiver's widget 
 * tree until a child is encountered that does not resize.  Note that 
 * a layout due to a resize will not flush any cached information 
 * (same as <code>layout(false)</code>).
 * </p>
 * <p>
 * Note: Layout is different from painting. If a child is
 * moved or resized such that an area in the parent is
 * exposed, then the parent will paint. If no child is
 * affected, the parent will not paint.
 * </p>
 *
 * @param changed <code>true</code> if the layout must flush its caches, and <code>false</code> otherwise
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void layout (bool changed) {
    checkWidget ();
    if (layout_ is null) return;
    layout (changed, false);
}

/**
 * If the receiver has a layout, asks the layout to <em>lay out</em>
 * (that is, set the size and location of) the receiver's children. 
 * If the changed argument is <code>true</code> the layout must not rely
 * on any information it has cached about its children. If it
 * is <code>false</code> the layout may (potentially) optimize the
 * work it is doing by assuming that none of the receiver's 
 * children has changed state since the last layout.
 * If the all argument is <code>true</code> the layout will cascade down
 * through all child widgets in the receiver's widget tree, regardless of
 * whether the child has changed size.  The changed argument is applied to 
 * all layouts.  If the all argument is <code>false</code>, the layout will
 * <em>not</em> cascade down through all child widgets in the receiver's widget 
 * tree.  However, if a child is resized as a result of a call to layout, the 
 * resize event will invoke the layout of the child.  Note that 
 * a layout due to a resize will not flush any cached information 
 * (same as <code>layout(false)</code>).
 * </p>
 * <p>
 * Note: Layout is different from painting. If a child is
 * moved or resized such that an area in the parent is
 * exposed, then the parent will paint. If no child is
 * affected, the parent will not paint.
 * </p>
 *
 * @param changed <code>true</code> if the layout must flush its caches, and <code>false</code> otherwise
 * @param all <code>true</code> if all children in the receiver's widget tree should be laid out, and <code>false</code> otherwise
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public void layout (bool changed, bool all) {
    checkWidget ();
    if (layout_ is null && !all) return;
    markLayout (changed, all);
    updateLayout (all);
}

/**
 * Forces a lay out (that is, sets the size and location) of all widgets that 
 * are in the parent hierarchy of the changed control up to and including the 
 * receiver.  The layouts in the hierarchy must not rely on any information 
 * cached about the changed control or any of its ancestors.  The layout may 
 * (potentially) optimize the work it is doing by assuming that none of the 
 * peers of the changed control have changed state since the last layout.
 * If an ancestor does not have a layout, skip it.
 * <p>
 * Note: Layout is different from painting. If a child is
 * moved or resized such that an area in the parent is
 * exposed, then the parent will paint. If no child is
 * affected, the parent will not paint.
 * </p>
 * 
 * @param changed a control that has had a state change which requires a recalculation of its size
 * 
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the changed array is null any of its controls are null or have been disposed</li> 
 *    <li>ERROR_INVALID_PARENT - if any control in changed is not in the widget tree of the receiver</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public void layout (Control [] changed) {
    checkWidget ();
    if (changed is null) error (DWT.ERROR_INVALID_ARGUMENT);
    for (int i=0; i<changed.length; i++) {
        Control control = changed [i];
        if (control is null) error (DWT.ERROR_INVALID_ARGUMENT);
        if (control.isDisposed ()) error (DWT.ERROR_INVALID_ARGUMENT);
        bool ancestor = false;
        Composite composite = control.parent;
        while (composite !is null) {
            ancestor = composite is this;
            if (ancestor) break;
            composite = composite.parent;
        }
        if (!ancestor) error (DWT.ERROR_INVALID_PARENT);
    }
    int updateCount = 0;
    Composite [] update = new Composite [16];
    for (int i=0; i<changed.length; i++) {
        Control child = changed [i];
        Composite composite = child.parent;
        while (child !is this) {
            if (composite.layout_ !is null) {
                composite.state |= LAYOUT_NEEDED;
                if (!composite.layout_.flushCache (child)) {
                    composite.state |= LAYOUT_CHANGED;
                }
            }
            if (updateCount is update.length) {
                Composite [] newUpdate = new Composite [update.length + 16];
                System.arraycopy (update, 0, newUpdate, 0, update.length);
                update = newUpdate;
            }
            child = update [updateCount++] = composite;
            composite = child.parent;
        }
    }
    for (int i=updateCount-1; i>=0; i--) {
        update [i].updateLayout (false);
    }
}

void markLayout (bool changed, bool all) {
    if (layout_ !is null) {
        state |= LAYOUT_NEEDED;
        if (changed) state |= LAYOUT_CHANGED;
    }
    if (all) {
        Control [] children = _getChildren ();
        for (int i=0; i<children.length; i++) {
            children [i].markLayout (changed, all);
        }
    }
}

Point minimumSize (int wHint, int Hint, bool changed) {
    Control [] children = _getChildren ();
    int width = 0, height = 0;
    for (int i=0; i<children.length; i++) {
        Rectangle rect = children [i].getBounds ();
        width = Math.max (width, rect.x + rect.width);
        height = Math.max (height, rect.y + rect.height);
    }
    return new Point (width, height);
}

bool mouseEvent (int /*long*/ id, int /*long*/ sel, int /*long*/ theEvent, int type) {
    bool result = super.mouseEvent (id, sel, theEvent, type);
    return (state & CANVAS) is 0 ? result : new NSEvent (theEvent).type () !is OS.NSLeftMouseDown;
}

    if ((state & CANVAS) !is 0) return;
    super.pageDown(id, sel, sender);
}

void pageUp(objc.id id, objc.SEL sel, objc.id sender) {
    if ((state & CANVAS) !is 0) return;
    super.pageUp(id, sel, sender);
}

void reflectScrolledClipView (objc.id id, objc.SEL sel, objc.id aClipView) {
    if ((state & CANVAS) !is 0) return;
    super.reflectScrolledClipView (id, sel, aClipView);
}

void releaseChildren (bool destroy) {
    Control [] children = _getChildren ();
    for (int i=0; i<children.length; i++) {
        Control child = children [i];
        if (child !is null && !child.isDisposed ()) {
            child.release (false);
        }
    }
    super.releaseChildren (destroy);
}

void releaseWidget () {
    super.releaseWidget ();
    layout_ = null;
    tabList = null;
}

void removeControl (Control control) {
    fixTabList (control);
}

void resized () {
    super.resized ();
    if (layout_ !is null) {
        markLayout (false, false);
        updateLayout (false);
    }
}

void scrollWheel (objc.id id, objc.SEL sel, objc.id theEvent) {
    if ((state & CANVAS) !is 0) {
        NSView view = scrollView !is null ? scrollView : this.view;
        if (id is view.id) {
            NSEvent nsEvent = new NSEvent(theEvent);
            Carbon.CGFloat delta = nsEvent.deltaY();
            if (delta !is 0) {
                if (hooks (DWT.MouseWheel) || filters (DWT.MouseWheel)) {
                    if (!sendMouseEvent(nsEvent, DWT.MouseWheel, true)) {
                        return;
                    }
                }
            }
            bool handled = false;
            ScrollBar bar = verticalBar;
            if (delta !is 0 && bar !is null && bar.getEnabled ()) {
                if (-1 < delta && delta < 0) delta = -1;
                if (0 < delta && delta < 1) delta = 1;
                int selection = Math.max (0, (int)(0.5f + bar.getSelection () - bar.getIncrement () * delta));
                bar.setSelection (selection);
                Event event = new Event ();
                event.detail = delta > 0 ? DWT.PAGE_UP : DWT.PAGE_DOWN; 
                bar.sendEvent (DWT.Selection, event);
                handled = true;
            }
            bar = horizontalBar;
            delta = nsEvent.deltaX ();
            if (delta !is 0 && bar !is null && bar.getEnabled ()) {
                int selection = Math.max (0, cast(int)(0.5f + bar.getSelection () - bar.getIncrement () * delta));
                bar.setSelection (selection);
                Event event = new Event ();
                event.detail = delta > 0 ? DWT.PAGE_UP : DWT.PAGE_DOWN; 
                bar.sendEvent (DWT.Selection, event);
                handled = true;
            }
            if (!handled) view.superview().scrollWheel(nsEvent);
            return;
        }
        callSuper(id, sel, theEvent);
        return;
    }
    super.scrollWheel (id, sel, theEvent);
}

/**
 * Sets the background drawing mode to the argument which should
 * be one of the following constants defined in class <code>DWT</code>:
 * <code>INHERIT_NONE</code>, <code>INHERIT_DEFAULT</code>,
 * <code>INHERIT_FORCE</code>.
 *
 * @param mode the new background mode
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see DWT
 * 
 * @since 3.2
 */
public void setBackgroundMode (int mode) {
    checkWidget ();
    backgroundMode = mode;
    Control [] children = _getChildren ();
    for (int i = 0; i < children.length; i++) {
        children [i].updateBackgroundMode ();
    }
}

public bool setFocus () {
    checkWidget ();
    Control [] children = _getChildren ();
    for (int i= 0; i < children.length; i++) {
        if (children [i].setFocus ()) return true;
    }
    return super.setFocus ();
}

/**
 * Sets the layout which is associated with the receiver to be
 * the argument which may be null.
 *
 * @param layout the receiver's new layout or null
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setLayout (Layout layout) {
    checkWidget();
    this.layout_ = layout;
}

/**
 * If the argument is <code>true</code>, causes subsequent layout
 * operations in the receiver or any of its children to be ignored.
 * No layout of any kind can occur in the receiver or any of its
 * children until the flag is set to false.
 * Layout operations that occurred while the flag was
 * <code>true</code> are remembered and when the flag is set to 
 * <code>false</code>, the layout operations are performed in an
 * optimized manner.  Nested calls to this method are stacked.
 *
 * @param defer the new defer state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * 
 * @see #layout(bool)
 * @see #layout(Control[])
 *
 * @since 3.1
 */
public void setLayoutDeferred (bool defer) {
    if (!defer) {
        if (--layoutCount is 0) {
            if ((state & LAYOUT_CHILD) !is 0 || (state & LAYOUT_NEEDED) !is 0) {
                updateLayout (true);
            }
        }
    } else {
        layoutCount++;
    }
}

bool setScrollBarVisible (ScrollBar bar, bool visible) {
    bool changed = super.setScrollBarVisible (bar, visible);
    if (changed && layout_ !is null) {
        markLayout (false, false);
        updateLayout (false);
    }
    return changed;
}

bool setTabGroupFocus () {
    if (isTabItem ()) return setTabItemFocus ();
    bool takeFocus = (style & DWT.NO_FOCUS) is 0;
    if ((state & CANVAS) !is 0) takeFocus = hooksKeys ();
    if (takeFocus && setTabItemFocus ()) return true;
    Control [] children = _getChildren ();
    for (int i=0; i<children.length; i++) {
        Control child = children [i];
        if (child.isTabItem () && child.setTabItemFocus ()) return true;
    }
    return false;
}

/**
 * Sets the tabbing order for the specified controls to
 * match the order that they occur in the argument list.
 *
 * @param tabList the ordered list of controls representing the tab order or null
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if a widget in the tabList is null or has been disposed</li> 
 *    <li>ERROR_INVALID_PARENT - if widget in the tabList is not in the same widget tree</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setTabList (Control [] tabList) {
    checkWidget ();
    if (tabList !is null) {
        for (int i=0; i<tabList.length; i++) {
            Control control = tabList [i];
            if (control is null) error (DWT.ERROR_INVALID_ARGUMENT);
            if (control.isDisposed ()) error (DWT.ERROR_INVALID_ARGUMENT);
            if (control.parent !is this) error (DWT.ERROR_INVALID_PARENT);
        }
        Control [] newList = new Control [tabList.length];
        System.arraycopy (tabList, 0, newList, 0, tabList.length);
        tabList = newList;
    } 
    this.tabList = tabList;
}

int traversalCode (int key, NSEvent theEvent) {
    if ((state & CANVAS) !is 0) {
        if ((style & DWT.NO_FOCUS) !is 0) return 0;
        if (hooksKeys ()) return 0;
    }
    return super.traversalCode (key, theEvent);
}

void updateBackgroundMode () {
    super.updateBackgroundMode ();
    Control [] children = _getChildren ();
    for (int i = 0; i < children.length; i++) {
        children [i].updateBackgroundMode ();
    }
}

void updateCursorRects (bool enabled) {
    super.updateCursorRects (enabled);
    Control [] children = _getChildren ();
    for (int i = 0; i < children.length; i++) {
        Control control = children [i];
        control.updateCursorRects (enabled && control.isEnabled ());
    }
}

void updateCursorRects (bool enabled) {
    super.updateCursorRects (enabled);
    Control [] children = _getChildren ();
    for (int i = 0; i < children.length; i++) {
        Control control = children [i];
        control.updateCursorRects (enabled && control.isEnabled ());
    }
}

void updateLayout (bool all) {
    Composite parent = findDeferredControl ();
    if (parent !is null) {
        parent.state |= LAYOUT_CHILD;
        return;
    }
    if ((state & LAYOUT_NEEDED) !is 0) {
        bool changed = (state & LAYOUT_CHANGED) !is 0;
        state &= ~(LAYOUT_NEEDED | LAYOUT_CHANGED);
        layout_.layout (this, changed);
    }
    if (all) {
        state &= ~LAYOUT_CHILD;
        Control [] children = _getChildren ();
        for (int i=0; i<children.length; i++) {
            children [i].updateLayout (all);
        }
    }
}

}
