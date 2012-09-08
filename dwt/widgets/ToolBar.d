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
module dwt.widgets.ToolBar;

import dwt.dwthelper.utils;



import dwt.DWT;
import dwt.accessibility.ACC;
import dwt.dwthelper.System;
import dwt.internal.cocoa.NSButton;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSNumber;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSGraphicsContext;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSFont;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSMutableArray;
import dwt.internal.cocoa.NSView;
import dwt.internal.cocoa.SWTView;
import dwt.internal.cocoa.OS;
import cocoa = dwt.internal.cocoa.id;

import objc = dwt.internal.objc.runtime;
import dwt.widgets.Composite;
import dwt.widgets.Control;
import dwt.widgets.ToolItem;
import dwt.widgets.Widget;
import dwt.graphics.Point;
import dwt.graphics.Rectangle;

/**
 * Instances of this class support the layout of selectable
 * tool bar items.
 * <p>
 * The item children that may be added to instances of this class
 * must be of type <code>ToolItem</code>.
 * </p><p>
 * Note that although this class is a subclass of <code>Composite</code>,
 * it does not make sense to add <code>Control</code> children to it,
 * or set a layout on it.
 * </p><p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>FLAT, WRAP, RIGHT, HORIZONTAL, VERTICAL, SHADOW_OUT</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
 * </dl>
 * <p>
 * Note: Only one of the styles HORIZONTAL and VERTICAL may be specified.
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#toolbar">ToolBar, ToolItem snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">DWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 * @noextend This class is not intended to be subclassed by clients.
 */
public class ToolBar : Composite {

    alias Composite.computeSize computeSize;
    alias Composite.createHandle createHandle;
    alias Composite.forceFocus forceFocus;
    alias Composite.setBounds setBounds;
    alias Composite.setToolTipText setToolTipText;

    int itemCount;
    ToolItem [] items;
    NSArray accessibilityAttributes = null;

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
 * @see DWT#FLAT
 * @see DWT#WRAP
 * @see DWT#RIGHT
 * @see DWT#HORIZONTAL
 * @see DWT#SHADOW_OUT
 * @see DWT#VERTICAL
 * @see Widget#checkSubclass()
 * @see Widget#getStyle()
 */
public this (Composite parent, int style) {
    super (parent, checkStyle (style));

    /*
     * Ensure that either of HORIZONTAL or VERTICAL is set.
     * NOTE: HORIZONTAL and VERTICAL have the same values
     * as H_SCROLL and V_SCROLL so it is necessary to first
     * clear these bits to avoid scroll bars and then reset
     * the bits using the original style supplied by the
     * programmer.
     */
    if ((style & DWT.VERTICAL) !is 0) {
        this.style |= DWT.VERTICAL;
    } else {
        this.style |= DWT.HORIZONTAL;
    }
}

objc.id accessibilityAttributeNames(objc.id id, objc.SEL sel) {

    if (accessibilityAttributes is null) {
        NSMutableArray ourAttributes = NSMutableArray.arrayWithCapacity(10);
        ourAttributes.addObject(OS.NSAccessibilityRoleAttribute);
        ourAttributes.addObject(OS.NSAccessibilityRoleDescriptionAttribute);
        ourAttributes.addObject(OS.NSAccessibilityParentAttribute);
        ourAttributes.addObject(OS.NSAccessibilityPositionAttribute);
        ourAttributes.addObject(OS.NSAccessibilitySizeAttribute);
        ourAttributes.addObject(OS.NSAccessibilityWindowAttribute);
        ourAttributes.addObject(OS.NSAccessibilityTopLevelUIElementAttribute);
        ourAttributes.addObject(OS.NSAccessibilityHelpAttribute);
        ourAttributes.addObject(OS.NSAccessibilityEnabledAttribute);
        ourAttributes.addObject(OS.NSAccessibilityFocusedAttribute);
        ourAttributes.addObject(OS.NSAccessibilityChildrenAttribute);

        if (accessible !is null) {
            // See if the accessible will override or augment the standard list.
            // Help, title, and description can be overridden.
            NSMutableArray extraAttributes = NSMutableArray.arrayWithCapacity(3);
            extraAttributes.addObject(OS.NSAccessibilityHelpAttribute);
            extraAttributes.addObject(OS.NSAccessibilityDescriptionAttribute);
            extraAttributes.addObject(OS.NSAccessibilityTitleAttribute);

            for (int i = cast(int)/*64*/extraAttributes.count() - 1; i >= 0; i--) {
                NSString attribute = new NSString(extraAttributes.objectAtIndex(i).id);
                if (accessible.internal_accessibilityAttributeValue(attribute, ACC.CHILDID_SELF) !is null) {
                    ourAttributes.addObject(extraAttributes.objectAtIndex(i));
                }
            }
        }

        accessibilityAttributes = ourAttributes;
        accessibilityAttributes.retain();
    }

    return accessibilityAttributes.id;
}

objc.id accessibilityAttributeValue (objc.id id, objc.SEL sel, objc.id arg0) {
    NSString nsAttributeName = new NSString(arg0);

    if (accessible !is null) {
        cocoa.id returnObject = accessible.internal_accessibilityAttributeValue(nsAttributeName, ACC.CHILDID_SELF);
        if (returnObject !is null) return returnObject.id;
    }

    if (nsAttributeName.isEqualToString (OS.NSAccessibilityRoleAttribute) || nsAttributeName.isEqualToString (OS.NSAccessibilityRoleDescriptionAttribute)) {
        NSString role = OS.NSAccessibilityToolbarRole;

        if (nsAttributeName.isEqualToString (OS.NSAccessibilityRoleAttribute))
            return role.id;
        else {
            objc.id roleDescription = OS.NSAccessibilityRoleDescription(role.id, null);
            return roleDescription;
        }
    } else if (nsAttributeName.isEqualToString(OS.NSAccessibilityEnabledAttribute)) {
        return NSNumber.numberWithBool(isEnabled()).id;
    } else if (nsAttributeName.isEqualToString(OS.NSAccessibilityFocusedAttribute)) {
        bool focused = (view.id is view.window().firstResponder().id);
        return NSNumber.numberWithBool(focused).id;
    }

    return super.accessibilityAttributeValue(id, sel, arg0);
}

bool accessibilityIsIgnored(objc.id id, objc.SEL sel) {
    // Toolbars aren't ignored.
    return false;
}

static int checkStyle (int style) {
    /*
     * Even though it is legal to create this widget
     * with scroll bars, they serve no useful purpose
     * because they do not automatically scroll the
     * widget's client area.  The fix is to clear
     * the DWT style.
     */
    return style & ~(DWT.H_SCROLL | DWT.V_SCROLL);
}

protected void checkSubclass () {
    if (!isValidSubclass ()) error (DWT.ERROR_INVALID_SUBCLASS);
}

public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget();
    int width = wHint, height = hHint;
    if (wHint is DWT.DEFAULT) width = 0x7FFFFFFF;
    if (hHint is DWT.DEFAULT) height = 0x7FFFFFFF;
    int [] result = layout (width, height, false);
    Point extent = new Point (result [1], result [2]);
    if (wHint !is DWT.DEFAULT) extent.x = wHint;
    if (hHint !is DWT.DEFAULT) extent.y = hHint;
    return extent;
}

void createHandle () {
    state |= THEME_BACKGROUND;
    NSView widget = cast(NSView)(new SWTView()).alloc();
    widget.initWithFrame(NSRect());
    widget.init();
    //  widget.setDrawsBackground(false);
    view = widget;
}

void createItem (ToolItem item, int index) {
    if (!(0 <= index && index <= itemCount)) error (DWT.ERROR_INVALID_RANGE);
    if (itemCount is items.length) {
        ToolItem [] newItems = new ToolItem [itemCount + 4];
        System.arraycopy (items, 0, newItems, 0, items.length);
        items = newItems;
    }
    item.createWidget();
    view.addSubview(item.view);
    System.arraycopy (items, index, items, index + 1, itemCount++ - index);
    items [index] = item;
    relayout ();
}

void createWidget () {
    super.createWidget ();
    items = new ToolItem [4];
    itemCount = 0;
}

void destroyItem (ToolItem item) {
    int index = 0;
    while (index < itemCount) {
        if (items [index] is item) break;
        index++;
    }
    if (index is itemCount) return;
    System.arraycopy (items, index + 1, items, index, --itemCount - index);
    items [itemCount] = null;
    item.view.removeFromSuperview();
    relayout ();
}

void drawBackground (objc.id id, NSGraphicsContext context, NSRect rect) {
    if (id !is view.id) return;
    if (background !is null) {
        fillBackground (view, context, rect, -1);
    }
}

void enableWidget(bool enabled) {
    super.enableWidget(enabled);
    for (int i = 0; i < itemCount; i++) {
        ToolItem item = items[i];
        if (item !is null) {
            item.enableWidget(enabled);
        }
    }
}

Widget findTooltip (NSPoint pt) {
    pt = view.convertPoint_fromView_ (pt, null);
    for (int i = 0; i < itemCount; i++) {
        ToolItem item = items [i];
        if (OS.NSPointInRect(pt, item.view.frame())) return item;
    }
    return super.findTooltip (pt);
}

/**
 * Returns the item at the given, zero-relative index in the
 * receiver. Throws an exception if the index is out of range.
 *
 * @param index the index of the item to return
 * @return the item at the given index
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_RANGE - if the index is not between 0 and the number of elements in the list minus 1 (inclusive)</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public ToolItem getItem (int index) {
    checkWidget();
    if (0 <= index && index < itemCount) return items [index];
    error (DWT.ERROR_INVALID_RANGE);
    return null;
}

/**
 * Returns the item at the given point in the receiver
 * or null if no such item exists. The point is in the
 * coordinate system of the receiver.
 *
 * @param point the point used to locate the item
 * @return the item at the given point
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the point is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public ToolItem getItem (Point pt) {
    checkWidget();
    if (pt is null) error (DWT.ERROR_NULL_ARGUMENT);
    for (int i=0; i<itemCount; i++) {
        Rectangle rect = items [i].getBounds ();
        if (rect.contains (pt)) return items [i];
    }
    return null;
}

/**
 * Returns the number of items contained in the receiver.
 *
 * @return the number of items
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getItemCount () {
    checkWidget();
    return itemCount;
}

/**
 * Returns an array of <code>ToolItem</code>s which are the items
 * in the receiver.
 * <p>
 * Note: This is not the actual structure used by the receiver
 * to maintain its list of items, so modifying the array will
 * not affect the receiver.
 * </p>
 *
 * @return the items in the receiver
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public ToolItem [] getItems () {
    checkWidget();
    ToolItem [] result = new ToolItem [itemCount];
    System.arraycopy (items, 0, result, 0, itemCount);
    return result;
}

/**
 * Returns the number of rows in the receiver. When
 * the receiver has the <code>WRAP</code> style, the
 * number of rows can be greater than one.  Otherwise,
 * the number of rows is always one.
 *
 * @return the number of items
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getRowCount () {
    checkWidget();
    Rectangle rect = getClientArea ();
    return layout (rect.width, rect.height, false) [0];
}

/**
 * Searches the receiver's list starting at the first item
 * (index 0) until an item is found that is equal to the
 * argument, and returns the index of that item. If no item
 * is found, returns -1.
 *
 * @param item the search item
 * @return the index of the item
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the tool item is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the tool item has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int indexOf (ToolItem item) {
    checkWidget();
    if (item is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (item.isDisposed()) error(DWT.ERROR_INVALID_ARGUMENT);
    for (int i=0; i<itemCount; i++) {
        if (items [i] is item) return i;
    }
    return -1;
}

int [] layoutHorizontal (int width, int height, bool resize) {
    int xSpacing = 0, ySpacing = 2;
    int marginWidth = 0, marginHeight = 0;
    int x = marginWidth, y = marginHeight;
    int maxX = 0, rows = 1;
    bool wrap = (style & DWT.WRAP) !is 0;
    int itemHeight = 0;
    Point [] sizes = new Point [itemCount];
    for (int i=0; i<itemCount; i++) {
        Point size = sizes [i] = items [i].computeSize ();
        itemHeight = Math.max (itemHeight, size.y);
    }
    for (int i=0; i<itemCount; i++) {
        ToolItem item = items [i];
        Point size = sizes [i];
        if (wrap && i !is 0 && x + size.x > width) {
            rows++;
            x = marginWidth;
            y += ySpacing + itemHeight;
        }
        if (resize) {
            item.setBounds (x, y, size.x, itemHeight);
            bool visible = x + size.x <= width && y + itemHeight <= height;
            item.setVisible (visible);
            Control control = item.control;
            if (control !is null) {
                int controlY = y + (itemHeight - size.y) / 2;
                control.setBounds (x, controlY, size.x, itemHeight - (controlY - y));
            }
        }
        x += xSpacing + size.x;
        maxX = Math.max (maxX, x);
    }

    return [rows, maxX, y + itemHeight];
}

int [] layoutVertical (int width, int height, bool resize) {
    int xSpacing = 2, ySpacing = 0;
    int marginWidth = 0, marginHeight = 0;
    int x = marginWidth, y = marginHeight;
    int maxY = 0, cols = 1;
    bool wrap = (style & DWT.WRAP) !is 0;
    int itemWidth = 0;
    Point [] sizes = new Point [itemCount];
    for (int i=0; i<itemCount; i++) {
        Point size = sizes [i] = items [i].computeSize ();
        itemWidth = Math.max (itemWidth, size.x);
    }
    for (int i=0; i<itemCount; i++) {
        ToolItem item = items [i];
        Point size = sizes [i];
        if (wrap && i !is 0 && y + size.y > height) {
            cols++;
            x += xSpacing + itemWidth;
            y = marginHeight;
        }
        if (resize) {
            item.setBounds (x, y, itemWidth, size.y);
            bool visible = x + itemWidth <= width && y + size.y <= height;
            item.setVisible (visible);
            Control control = item.control;
            if (control !is null) {
                int controlX = x + (itemWidth - size.x) / 2;
                control.setBounds (controlX, y, itemWidth - (controlX - x), size.y);
            }
        }
        y += ySpacing + size.y;
        maxY = Math.max (maxY, y);
    }

    return [cols, x + itemWidth, maxY];
}

int [] layout (int nWidth, int nHeight, bool resize) {
    if ((style & DWT.VERTICAL) !is 0) {
        return layoutVertical (nWidth, nHeight, resize);
    } else {
        return layoutHorizontal (nWidth, nHeight, resize);
    }
}

void relayout () {
    if (!getDrawing()) return;
    Rectangle rect = getClientArea ();
    layout (rect.width, rect.height, true);
}

void releaseChildren (bool destroy) {
    if (items !is null) {
        for (int i=0; i<itemCount; i++) {
            ToolItem item = items [i];
            if (item !is null && !item.isDisposed ()) {
                item.release (false);
            }
        }
        itemCount = 0;
        items = null;
    }
    super.releaseChildren (destroy);
}

void releaseHandle () {
    super.releaseHandle ();
    if (accessibilityAttributes !is null) accessibilityAttributes.release();
    accessibilityAttributes = null;
}

void removeControl (Control control) {
    super.removeControl (control);
    for (int i=0; i<itemCount; i++) {
        ToolItem item = items [i];
        if (item.control is control) item.setControl (null);
    }
}

void resized () {
    super.resized ();
    relayout ();
}

void setFont(NSFont font) {
    for (int i = 0; i < itemCount; i++) {
        ToolItem item = items[i];
        if (item.button !is null) (cast(NSButton)item.button).setAttributedTitle(item.createString());
    }
}

public void setRedraw (bool redraw) {
    checkWidget();
    super.setRedraw (redraw);
    if (redraw && drawCount is 0) relayout();
}

}
