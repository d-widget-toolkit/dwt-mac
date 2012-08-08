﻿/*******************************************************************************
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
module dwt.widgets.ExpandBar;

import dwt.dwthelper.utils;





import dwt.widgets.Composite;
import dwt.widgets.Control;
import dwt.widgets.Display;
import dwt.widgets.Event;
import dwt.widgets.ExpandItem;
import dwt.widgets.Listener;
import dwt.widgets.ScrollBar;
import dwt.widgets.TypedListener;

/**
 * Instances of this class support the layout of selectable
 * expand bar items.
 * <p>
 * The item children that may be added to instances of this class
 * must be of type <code>ExpandItem</code>.
 * </p><p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>V_SCROLL</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Expand, Collapse</dd>
 * </dl>
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see ExpandItem
 * @see ExpandEvent
 * @see ExpandListener
 * @see ExpandAdapter
 * @see <a href="http://www.eclipse.org/swt/snippets/#expandbar">ExpandBar snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">DWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.2
 * @noextend This class is not intended to be subclassed by clients.
 */
public class ExpandBar : Composite {
    ExpandItem [] items;
    int itemCount;
    ExpandItem focusItem;
    int spacing;
    int yCurrentScroll;
    Font font;
    Color foreground;
    Listener listener;
    bool inDispose;

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
 * @see DWT#V_SCROLL
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, checkStyle (style));
    items = new ExpandItem [4];

    listener = new class (this) Listener {
        ExpandBar eb;

        this (ExpandBar eb) {
            this.eb = eb;
        }

        public void handleEvent (Event event) {
            switch (event.type) {
                case DWT.Dispose:       eb.onDispose (event);          break;
                case DWT.MouseDown:     eb.onMouseDown (event);        break;
                case DWT.MouseUp:       eb.onMouseUp (event);          break;
                case DWT.Paint:         eb.onPaint (event);            break;
                case DWT.Resize:        eb.onResize ();                break;
                case DWT.KeyDown:       eb.onKeyDown (event);          break;
                case DWT.FocusIn:       eb.onFocus ();                 break;
                case DWT.FocusOut:      eb.onFocus ();                 break;
                case DWT.Traverse:      eb.onTraverse (event);         break;
                default:
            }
        }
    };
    addListener (DWT.Dispose, listener);
    addListener (DWT.MouseDown, listener);
    addListener (DWT.MouseUp, listener);
    addListener (DWT.Paint, listener);
    addListener (DWT.Resize, listener);
    addListener (DWT.KeyDown, listener);
    addListener (DWT.FocusIn, listener);
    addListener (DWT.FocusOut, listener);
    addListener (DWT.Traverse, listener);

    ScrollBar verticalBar = getVerticalBar ();
    if (verticalBar !is null) {
        verticalBar.addListener (DWT.Selection, new class () Listener {
                                 public void handleEvent (Event event) {
                                 onScroll (event);
                                 }
                                 });
    }
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when an item in the receiver is expanded or collapsed
 * by sending it one of the messages defined in the <code>ExpandListener</code>
 * interface.
 *
 * @param listener the listener which should be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see ExpandListener
 * @see #removeExpandListener
 */
public void addExpandListener (ExpandListener listener) {
    checkWidget ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (DWT.Expand, typedListener);
    addListener (DWT.Collapse, typedListener);
}

static int checkStyle (int style) {
    return style & ~DWT.H_SCROLL;
}

protected void checkSubclass () {
    if (!isValidSubclass ()) error (DWT.ERROR_INVALID_SUBCLASS);
}

public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    int height = 0, width = 0;
    if (wHint is DWT.DEFAULT || hHint is DWT.DEFAULT) {
        if (itemCount > 0) {
            height += spacing;
            GC gc = new GC (this);
            for (int i = 0; i < itemCount; i++) {
                ExpandItem item = items [i];
                height += item.getHeaderHeight ();
                if (item.expanded) height += item.height;
                height += spacing;
                width = Math.max (width, item.getPreferredWidth (gc));
            }
            gc.dispose ();
        }
    }
    if (width is 0) width = DEFAULT_WIDTH;
    if (height is 0) height = DEFAULT_HEIGHT;
    if (wHint !is DWT.DEFAULT) width = wHint;
    if (hHint !is DWT.DEFAULT) height = hHint;
    Rectangle trim = computeTrim (0, 0, width, height);
    return new Point (trim.width, trim.height);
}

void createItem (ExpandItem item, int style, int index) {
    if (!(0 <= index && index <= itemCount)) error (DWT.ERROR_INVALID_RANGE);
    if (itemCount is items.length) {
        ExpandItem [] newItems = new ExpandItem [itemCount + 4];
        System.arraycopy (items, 0, newItems, 0, items.length);
        items = newItems;
    }
    System.arraycopy (items, index, items, index + 1, itemCount - index);
    items [index] = item;
    itemCount++;
    if (focusItem is null) focusItem = item;
    item.width = Math.max (0, getClientArea ().width - spacing * 2);
    layoutItems (index, true);
}

void destroyItem (ExpandItem item) {
    if (inDispose) return;
    int index = 0;
    while (index < itemCount) {
        if (items [index] is item) break;
        index++;
    }
    if (index is itemCount) return;
    if (item is focusItem) {
        int focusIndex = index > 0 ? index - 1 : 1;
        if (focusIndex < itemCount) {
            focusItem = items [focusIndex];
            focusItem.redraw ();
        } else {
            focusItem = null;
        }
    }
    System.arraycopy (items, index + 1, items, index, --itemCount - index);
    items [itemCount] = null;
    item.redraw ();
    layoutItems (index, true);
}

int getBandHeight () {
    if (font is null) return ExpandItem.CHEVRON_SIZE;
    GC gc = new GC (this);
    FontMetrics metrics = gc.getFontMetrics ();
    gc.dispose ();
    return Math.max (ExpandItem.CHEVRON_SIZE, metrics.getHeight ());
}

public Color getForeground () {
    checkWidget ();
    if (foreground is null) {
        Display display = getDisplay ();
        return display.getSystemColor (DWT.COLOR_TITLE_FOREGROUND);
    }
    return foreground;
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
public ExpandItem getItem (int index) {
    checkWidget ();
    if (!(0 <= index && index < itemCount)) error (DWT.ERROR_INVALID_RANGE);
    return items [index];
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
    checkWidget ();
    return itemCount;
}

/**
 * Returns an array of <code>ExpandItem</code>s which are the items
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
public ExpandItem [] getItems () {
    checkWidget ();
    ExpandItem [] result = new ExpandItem [itemCount];
    System.arraycopy (items, 0, result, 0, itemCount);
    return result;
}

/**
 * Returns the receiver's spacing.
 *
 * @return the spacing
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getSpacing () {
    checkWidget ();
    return spacing;
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
 *    <li>ERROR_NULL_ARGUMENT - if the item is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the item has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int indexOf (ExpandItem item) {
    checkWidget ();
    if (item is null) error (DWT.ERROR_NULL_ARGUMENT);
    for (int i = 0; i < itemCount; i++) {
        if (items [i] is item) return i;
    }
    return -1;
}

void layoutItems (int index, bool setScrollbar_) {
    if (index < itemCount) {
        int y = spacing - yCurrentScroll;
        for (int i = 0; i < index; i++) {
            ExpandItem item = items [i];
            if (item.expanded) y += item.height;
            y += item.getHeaderHeight() + spacing;
        }
        for (int i = index; i < itemCount; i++) {
            ExpandItem item = items [i];
            item.setBounds (spacing, y, 0, 0, true, false);
            if (item.expanded) y += item.height;
            y += item.getHeaderHeight() + spacing;
        }
    }
    if (setScrollbar_) setScrollbar ();
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when items in the receiver are expanded or collapsed.
 *
 * @param listener the listener which should no longer be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see ExpandListener
 * @see #addExpandListener
 */
public void removeExpandListener (ExpandListener listener) {
    checkWidget ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (DWT.Expand, listener);
    eventTable.unhook (DWT.Collapse, listener);
}

public void setFont(Font font) {
    super.setFont (font);
    this.font = font;
    layoutItems (0, true);
}

public void setForeground (Color color) {
    super.setForeground (color);
    foreground = color;
}

void setScrollbar () {
    if (itemCount is 0) return;
    ScrollBar verticalBar = getVerticalBar ();
    if (verticalBar is null) return;
    int height = getClientArea ().height;
    ExpandItem item = items [itemCount - 1];
    int maxHeight = item.y + getBandHeight () + spacing;
    if (item.expanded) maxHeight += item.height;

    //claim bottom free space
    if (yCurrentScroll > 0 && height > maxHeight) {
        yCurrentScroll = Math.max (0, yCurrentScroll + maxHeight - height);
        layoutItems (0, false);
    }
    maxHeight += yCurrentScroll;

    int selection = Math.min (yCurrentScroll, maxHeight);
    int increment = verticalBar.getIncrement ();
    int pageIncrement = verticalBar.getPageIncrement ();
    verticalBar.setValues(selection, 0, maxHeight, height, increment, pageIncrement);
    verticalBar.setVisible(maxHeight > height);
}

/**
 * Sets the receiver's spacing. Spacing specifies the number of pixels allocated around
 * each item.
 *
 * @param spacing the spacing around each item
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSpacing (int spacing) {
    checkWidget ();
    if (spacing < 0) return;
    if (spacing is this.spacing) return;
    this.spacing = spacing;
    int width = Math.max (0, getClientArea ().width - spacing * 2);
    for (int i = 0; i < itemCount; i++) {
        ExpandItem item = items[i];
        if (item.width !is width) item.setBounds (0, 0, width, item.height, false, true);
    }
    layoutItems (0, true);
    redraw ();
}

void showItem (ExpandItem item) {
    Control control = item.control;
    if (control !is null && !control.isDisposed ()) {
        control.setVisible (item.expanded);
    }
    item.redraw ();
    int index = indexOf (item);
    layoutItems (index + 1, true);
}

void onDispose (Event event) {
    removeListener (DWT.Dispose, listener);
    notifyListeners (DWT.Dispose, event);
    event.type = DWT.None;
    /*
     * Usually when an item is disposed, destroyItem will change the size of the items array,
     * reset the bounds of all the tabs and manage the widget associated with the tab.
     * Since the whole folder is being disposed, this is not necessary.  For speed
     * the inDispose flag is used to skip over this part of the item dispose.
     */
    inDispose = true;

    for (int i = 0; i < itemCount; i++) {
        items [i].dispose ();
    }
    items = null;
    font = null;
    foreground = null;
    focusItem = null;
}

void onFocus () {
    if (focusItem !is null) focusItem.redraw ();
}

void onKeyDown (Event event) {
    if (focusItem is null) return;
    switch (event.keyCode) {
        case 13: /* Return */
        case 32: /* Space */
            Event ev = new Event ();
            ev.item = focusItem;
            sendEvent (focusItem.expanded ? DWT.Collapse :DWT.Expand, ev);
            focusItem.expanded = !focusItem.expanded;
            showItem (focusItem);
            break;
        case DWT.ARROW_UP: {
            int focusIndex = indexOf (focusItem);
            if (focusIndex > 0) {
                focusItem.redraw ();
                focusItem = items [focusIndex - 1];
                focusItem.redraw ();
            }
            break;
        }
        case DWT.ARROW_DOWN: {
            int focusIndex = indexOf (focusItem);
            if (focusIndex < itemCount - 1) {
                focusItem.redraw ();
                focusItem = items [focusIndex + 1];
                focusItem.redraw ();
            }
            break;
        }

        default:
    }
}

void onMouseDown (Event event) {
    if (event.button !is 1) return;
    int x = event.x;
    int y = event.y;
    for (int i = 0; i < itemCount; i++) {
        ExpandItem item = items[i];
        bool hover = item.x <= x && x < (item.x + item.width) && item.y <= y && y < (item.y + getBandHeight ());
        if (hover && item !is focusItem) {
            focusItem.redraw ();
            focusItem = item;
            focusItem.redraw ();
            forceFocus ();
            break;
        }
    }
}

void onMouseUp (Event event) {
    if (event.button !is 1) return;
    if (focusItem is null) return;
    int x = event.x;
    int y = event.y;
    bool hover = focusItem.x <= x && x < (focusItem.x + focusItem.width) && focusItem.y <= y && y < (focusItem.y + getBandHeight ());
    if (hover) {
        Event ev = new Event ();
        ev.item = focusItem;
        notifyListeners (focusItem.expanded ? DWT.Collapse : DWT.Expand, ev);
        focusItem.expanded = !focusItem.expanded;
        showItem (focusItem);
    }
}

void onPaint (Event event) {
    bool hasFocus = isFocusControl ();
    for (int i = 0; i < itemCount; i++) {
        ExpandItem item = items [i];
        item.drawItem (event.gc, hasFocus && item is focusItem);
    }
}

void onResize () {
    Rectangle rect = getClientArea ();
    int width = Math.max (0, rect.width - spacing * 2);
    for (int i = 0; i < itemCount; i++) {
        ExpandItem item = items[i];
        item.setBounds (0, 0, width, item.height, false, true);
    }
    setScrollbar ();
}

void onScroll (Event event) {
    ScrollBar verticalBar = getVerticalBar ();
    if (verticalBar !is null) {
        yCurrentScroll = verticalBar.getSelection();
        layoutItems (0, false);
    }
}

void onTraverse (Event event) {
    switch (event.detail) {
        case DWT.TRAVERSE_TAB_NEXT:
        case DWT.TRAVERSE_TAB_PREVIOUS:
            event.doit = true;
            break;
        default:
    }
}

}
