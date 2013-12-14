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
module dwt.widgets.Tree;

import tango.text.convert.Format;
import dwt.dwthelper.utils;






import cocoa = dwt.internal.cocoa.id;

import dwt.DWT;
import dwt.accessibility.ACC;
import dwt.dwthelper.System;
import dwt.internal.cocoa.NSBezierPath;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSButton;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSFont;
import dwt.internal.cocoa.NSView;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSEvent;
import dwt.internal.cocoa.NSImage;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSTableColumn;
import dwt.internal.cocoa.NSTextFieldCell;
import dwt.internal.cocoa.NSButtonCell;
import dwt.internal.cocoa.NSTableHeaderView;
import dwt.internal.cocoa.NSNotification;
import dwt.internal.cocoa.NSDictionary;
import dwt.internal.cocoa.NSNumber;
import dwt.internal.cocoa.NSColor;
import dwt.internal.cocoa.NSCell;
import dwt.internal.cocoa.NSAttributedString;
import dwt.internal.cocoa.NSMutableDictionary;
import dwt.internal.cocoa.NSMutableParagraphStyle;
import dwt.internal.cocoa.NSOutlineView;
import dwt.internal.cocoa.NSTableView;
import dwt.internal.cocoa.NSMutableAttributedString;
import dwt.internal.cocoa.NSRange;
import dwt.internal.cocoa.NSGraphicsContext;
import dwt.internal.cocoa.NSAffineTransform;
import dwt.internal.cocoa.NSTableHeaderCell;
import dwt.internal.cocoa.NSApplication;
import dwt.internal.cocoa.NSIndexSet;
import dwt.internal.cocoa.NSScrollView;
import dwt.internal.cocoa.NSMutableIndexSet;
import dwt.internal.cocoa.SWTScrollView;
import dwt.internal.cocoa.SWTTableHeaderCell;
import dwt.internal.cocoa.SWTTreeItem;
import dwt.internal.cocoa.SWTImageTextCell;
import dwt.internal.cocoa.SWTOutlineView;
import dwt.internal.cocoa.SWTTableHeaderView;
import dwt.internal.cocoa.OS;
import Carbon = dwt.internal.c.Carbon;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;
import dwt.widgets.Composite;
import dwt.widgets.Event;
import dwt.widgets.TreeColumn;
import dwt.widgets.TreeItem;
import dwt.widgets.TypedListener;
import dwt.widgets.Widget;
import dwt.widgets.Listener;
import dwt.widgets.Display;
import dwt.graphics.Point;
import dwt.graphics.Image;
import dwt.graphics.Color;
import dwt.graphics.Rectangle;
import dwt.graphics.GC;
import dwt.graphics.GCData;
import dwt.graphics.Font;
import dwt.events.TreeListener;
import dwt.events.SelectionListener;

/**
 * Instances of this class provide a selectable user interface object
 * that displays a hierarchy of items and issues notification when an
 * item in the hierarchy is selected.
 * <p>
 * The item children that may be added to instances of this class
 * must be of type <code>TreeItem</code>.
 * </p><p>
 * Style <code>VIRTUAL</code> is used to create a <code>Tree</code> whose
 * <code>TreeItem</code>s are to be populated by the client on an on-demand basis
 * instead of up-front.  This can provide significant performance improvements for
 * trees that are very large or for which <code>TreeItem</code> population is
 * expensive (for example, retrieving values from an external source).
 * </p><p>
 * Here is an example of using a <code>Tree</code> with style <code>VIRTUAL</code>:
 * <code><pre>
 *  final Tree tree = new Tree(parent, DWT.VIRTUAL | DWT.BORDER);
 *  tree.setItemCount(20);
 *  tree.addListener(DWT.SetData, new Listener() {
 *      public void handleEvent(Event event) {
 *          TreeItem item = cast(TreeItem)event.item;
 *          TreeItem parentItem = item.getParentItem();
 *          String text = null;
 *          if (parentItem is null) {
 *              text = "node " + tree.indexOf(item);
 *          } else {
 *              text = parentItem.getText() + " - " + parentItem.indexOf(item);
 *          }
 *          item.setText(text);
 *          System.out_.println(text);
 *          item.setItemCount(10);
 *      }
 *  });
 * </pre></code>
 * </p><p>
 * Note that although this class is a subclass of <code>Composite</code>,
 * it does not normally make sense to add <code>Control</code> children to
 * it, or set a layout on it, unless implementing something like a cell
 * editor.
 * </p><p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>SINGLE, MULTI, CHECK, FULL_SELECTION, VIRTUAL, NO_SCROLL</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Selection, DefaultSelection, Collapse, Expand, SetData, MeasureItem, EraseItem, PaintItem</dd>
 * </dl>
 * </p><p>
 * Note: Only one of the styles SINGLE and MULTI may be specified.
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#tree">Tree, TreeItem, TreeColumn snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">DWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 * @noextend This class is not intended to be subclassed by clients.
 */
public class Tree : Composite {

    alias Composite.computeSize computeSize;
    alias Composite.updateCursorRects updateCursorRects;

    NSTableColumn firstColumn, checkColumn;
    NSTextFieldCell dataCell;
    NSButtonCell buttonCell;
    NSTableHeaderView headerView;
    TreeItem [] items;
    int itemCount;
    TreeColumn [] columns;
    TreeColumn sortColumn;
    int columnCount;
    int sortDirection;
    bool ignoreExpand, ignoreSelect, ignoreRedraw, reloadPending, drawExpansion;
    Rectangle imageBounds;
    TreeItem insertItem;
    bool insertBefore;

    static int NEXT_ID;

    static final int FIRST_COLUMN_MINIMUM_WIDTH = 5;
    static final int IMAGE_GAP = 3;
    static final int TEXT_GAP = 2;
    static final int CELL_GAP = 1;

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
 * @see DWT#SINGLE
 * @see DWT#MULTI
 * @see DWT#CHECK
 * @see DWT#FULL_SELECTION
 * @see DWT#VIRTUAL
 * @see DWT#NO_SCROLL
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, checkStyle (style));
}

void _addListener (int eventType, Listener listener) {
    super._addListener (eventType, listener);
    clearCachedWidth (items);
}

TreeItem _getItem (TreeItem parentItem, int index, bool create) {
    int count;
    TreeItem[] items;
    if (parentItem !is null) {
        count = parentItem.itemCount;
        items = parentItem.items;
    } else {
        count = this.itemCount;
        items = this.items;
    }
    if (index < 0 || index >= count) return null;
    TreeItem item = items [index];
    if (item !is null || (style & DWT.VIRTUAL) is 0 || !create) return item;
    item = new TreeItem (this, parentItem, DWT.NONE, index, false);
    items [index] = item;
    return item;
}

objc.id accessibilityAttributeValue (objc.id id, objc.SEL sel, objc.id arg0) {

    if (accessible !is null) {
        NSString attribute = new NSString(arg0);
        cocoa.id returnValue = accessible.internal_accessibilityAttributeValue(attribute, ACC.CHILDID_SELF);
        if (returnValue !is null) return returnValue.id;
    }

    NSString attributeName = new NSString(arg0);

    // Accessibility Verifier queries for a title or description.  NSOutlineView doesn't
    // seem to return either, so we return a default description value here.
    if (attributeName.isEqualToString (OS.NSAccessibilityDescriptionAttribute)) {
        return NSString.stringWith("").id;
    }

    return super.accessibilityAttributeValue(id, sel, arg0);
}


/**
 * Adds the listener to the collection of listeners who will
 * be notified when the user changes the receiver's selection, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * When <code>widgetSelected</code> is called, the item field of the event object is valid.
 * If the receiver has the <code>DWT.CHECK</code> style and the check selection changes,
 * the event object detail field contains the value <code>DWT.CHECK</code>.
 * <code>widgetDefaultSelected</code> is typically called when an item is double-clicked.
 * The item field of the event object is valid for default selection, but the detail field is not used.
 * </p>
 *
 * @param listener the listener which should be notified when the user changes the receiver's selection
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see SelectionListener
 * @see #removeSelectionListener
 * @see SelectionEvent
 */
public void addSelectionListener(SelectionListener listener) {
    checkWidget ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (DWT.Selection, typedListener);
    addListener (DWT.DefaultSelection, typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when an item in the receiver is expanded or collapsed
 * by sending it one of the messages defined in the <code>TreeListener</code>
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
 * @see TreeListener
 * @see #removeTreeListener
 */
public void addTreeListener(TreeListener listener) {
    checkWidget ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (DWT.Expand, typedListener);
    addListener (DWT.Collapse, typedListener);
}

int calculateWidth (TreeItem[] items, int index, GC gc, bool recurse) {
    if (items is null) return 0;
    int width = 0;
    for (int i=0; i<items.length; i++) {
        TreeItem item = items [i];
        if (item !is null) {
            int itemWidth = item.calculateWidth (index, gc);
            width = Math.max (width, itemWidth);
            if (recurse && item.getExpanded ()) {
                width = Math.max (width, calculateWidth (item.items, index, gc, recurse));
            }
        }
    }
    return width;
}

NSSize cellSize (objc.id id, objc.SEL sel) {
    NSSize size = super.cellSize(id, sel);
    NSImage image = (new NSCell(id)).image();
    if (image !is null) size.width += imageBounds.width + IMAGE_GAP;
    if (hooks(DWT.MeasureItem)) {
        void* outValue;
        OS.object_getInstanceVariable(id, Display.SWT_ROW, outValue);
        TreeItem item = cast(TreeItem) display.getWidget (cast(objc.id)outValue);
        OS.object_getInstanceVariable(id, Display.SWT_COLUMN, outValue);
        cocoa.id tableColumn = cast(cocoa.id)outValue;
        int columnIndex = 0;
        for (int i=0; i<columnCount; i++) {
            if (columns [i].nsColumn is tableColumn) {
                columnIndex = i;
                break;
            }
        }
        sendMeasureItem (item, columnIndex, size);
    }
    return size;
}

bool canDragRowsWithIndexes_atPoint(objc.id id, objc.SEL sel, objc.id arg0, NSPoint clickPoint) {
    NSOutlineView tree = cast(NSOutlineView)view;

    // If the current row is not selected and the user is not attempting to modify the selection, select the row first.
    NSInteger row = tree.rowAtPoint(clickPoint);
    NSUInteger modifiers = NSApplication.sharedApplication().currentEvent().modifierFlags();

    bool drag = (state & DRAG_DETECT) !is 0 && hooks (DWT.DragDetect);
    if (drag) {
        if (!tree.isRowSelected(row) && (modifiers & (OS.NSCommandKeyMask | OS.NSShiftKeyMask | OS.NSAlternateKeyMask | OS.NSControlKeyMask)) is 0) {
            NSIndexSet set = cast(NSIndexSet)(new NSIndexSet()).alloc();
            set = set.initWithIndex(row);
            tree.selectRowIndexes (set, false);
            set.release();
        }
    }

    // The clicked row must be selected to initiate a drag.
    return (tree.isRowSelected(row) && drag);
}

bool checkData (TreeItem item) {
    if (item.cached) return true;
    if ((style & DWT.VIRTUAL) !is 0) {
        item.cached = true;
        Event event = new Event ();
        TreeItem parentItem = item.getParentItem ();
        event.item = item;
        event.index = parentItem is null ? indexOf (item) : parentItem.indexOf (item);
        ignoreRedraw = true;
        sendEvent (DWT.SetData, event);
        //widget could be disposed at this point
        ignoreRedraw = false;
        if (isDisposed () || item.isDisposed ()) return false;
        if (!setScrollWidth (item)) item.redraw (-1);
    }
    return true;
}

static int checkStyle (int style) {
    /*
     * Feature in Windows.  Even when WS_HSCROLL or
     * WS_VSCROLL is not specified, Windows creates
     * trees and tables with scroll bars.  The fix
     * is to set H_SCROLL and V_SCROLL.
     *
     * NOTE: This code appears on all platforms so that
     * applications have consistent scroll bar behavior.
     */
    if ((style & DWT.NO_SCROLL) is 0) {
        style |= DWT.H_SCROLL | DWT.V_SCROLL;
    }
    /* This platform is always FULL_SELECTION */
    style |= DWT.FULL_SELECTION;
    return checkBits (style, DWT.SINGLE, DWT.MULTI, 0, 0, 0, 0);
}

protected void checkSubclass () {
    if (!isValidSubclass ()) error (DWT.ERROR_INVALID_SUBCLASS);
}

void checkItems () {
    if (!reloadPending) return;
    reloadPending = false;
    TreeItem[] selectedItems = getSelection ();
    (cast(NSOutlineView)view).reloadData ();
    selectItems (selectedItems, true);
    ignoreExpand = true;
    for (int i = 0; i < itemCount; i++) {
        if (items[i] !is null) items[i].updateExpanded ();
    }
    ignoreExpand = false;
}

void clear (TreeItem parentItem, int index, bool all) {
    TreeItem item = _getItem (parentItem, index, false);
    if (item !is null) {
        item.clear();
        item.redraw (-1);
        if (all) {
            clearAll (item, true);
        }
    }
}

void clearAll (TreeItem parentItem, bool all) {
    int count = getItemCount (parentItem);
    if (count is 0) return;
    TreeItem [] children = parentItem is null ? items : parentItem.items;
    for (int i=0; i<count; i++) {
        TreeItem item = children [i];
        if (item !is null) {
            item.clear ();
            item.redraw (-1);
            if (all) clearAll (item, true);
        }
    }
}

/**
 * Clears the item at the given zero-relative index in the receiver.
 * The text, icon and other attributes of the item are set to the default
 * value.  If the tree was created with the <code>DWT.VIRTUAL</code> style,
 * these attributes are requested again as needed.
 *
 * @param index the index of the item to clear
 * @param all <code>true</code> if all child items of the indexed item should be
 * cleared recursively, and <code>false</code> otherwise
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_RANGE - if the index is not between 0 and the number of elements in the list minus 1 (inclusive)</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see DWT#VIRTUAL
 * @see DWT#SetData
 *
 * @since 3.2
 */
public void clear (int index, bool all) {
    checkWidget ();
    int count = getItemCount ();
    if (index < 0 || index >= count) error (DWT.ERROR_INVALID_RANGE);
    clear (null, index, all);
}

/**
 * Clears all the items in the receiver. The text, icon and other
 * attributes of the items are set to their default values. If the
 * tree was created with the <code>DWT.VIRTUAL</code> style, these
 * attributes are requested again as needed.
 *
 * @param all <code>true</code> if all child items should be cleared
 * recursively, and <code>false</code> otherwise
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see DWT#VIRTUAL
 * @see DWT#SetData
 *
 * @since 3.2
 */
public void clearAll (bool all) {
    checkWidget ();
    clearAll (null, all);
}

void clearCachedWidth (TreeItem[] items) {
    if (items is null) return;
    for (int i = 0; i < items.length; i++) {
        TreeItem item = items [i];
        if (item is null) break;
        item.width = -1;
        clearCachedWidth (item.items);
    }
}

void collapseItem_collapseChildren (objc.id id, objc.SEL sel, objc.id itemID, bool children) {
    TreeItem item = cast(TreeItem)display.getWidget(itemID);
    if (!ignoreExpand) item.sendExpand (false, children);
    ignoreExpand = true;
    super.collapseItem_collapseChildren (id, sel, itemID, children);
    ignoreExpand = false;
    if (isDisposed() || item.isDisposed()) return;
    setScrollWidth ();
}

objc.id columnAtPoint(objc.id id, objc.SEL sel, NSPoint point) {
    if ((style & DWT.CHECK) != 0) {
        if (point.x <= getCheckColumnWidth() && point.y < headerView.frame().height) return cast(objc.id)1;
    }
    return super.columnAtPoint(id, sel, point);
}

public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    int width = 0, height = 0;
    if (wHint is DWT.DEFAULT) {
        if (columnCount !is 0) {
            for (int i=0; i<columnCount; i++) {
                width += columns [i].getWidth ();
            }
        } else {
            GC gc = new GC (this);
            width = calculateWidth (items, 0, gc, true) + CELL_GAP;
            gc.dispose ();
        }
        if ((style & DWT.CHECK) !is 0) width += getCheckColumnWidth ();
    } else {
        width = wHint;
    }
    if (hHint is DWT.DEFAULT) {
        height = (cast(NSOutlineView) view).numberOfRows () * getItemHeight () + getHeaderHeight ();
    } else {
        height = hHint;
    }
    if (width <= 0) width = DEFAULT_WIDTH;
    if (height <= 0) height = DEFAULT_HEIGHT;
    Rectangle rect = computeTrim (0, 0, width, height);
    return new Point (rect.width, rect.height);
}

void createColumn (TreeItem item, int index) {
    if (item.items !is null) {
        for (int i = 0; i < item.items.length; i++) {
            if (item.items[i] !is null) createColumn (item.items[i], index);
        }
    }
    String [] strings = item.strings;
    if (strings !is null) {
        String [] temp = new String [columnCount];
        System.arraycopy (strings, 0, temp, 0, index);
        System.arraycopy (strings, index, temp, index+1, columnCount-index-1);
        temp [index] = "";
        item.strings = temp;
    }
    if (index is 0) item.text = "";
    Image [] images = item.images;
    if (images !is null) {
        Image [] temp = new Image [columnCount];
        System.arraycopy (images, 0, temp, 0, index);
        System.arraycopy (images, index, temp, index+1, columnCount-index-1);
        item.images = temp;
    }
    if (index is 0) item.image = null;
    Color [] cellBackground = item.cellBackground;
    if (cellBackground !is null) {
        Color [] temp = new Color [columnCount];
        System.arraycopy (cellBackground, 0, temp, 0, index);
        System.arraycopy (cellBackground, index, temp, index+1, columnCount-index-1);
        item.cellBackground = temp;
    }
    Color [] cellForeground = item.cellForeground;
    if (cellForeground !is null) {
        Color [] temp = new Color [columnCount];
        System.arraycopy (cellForeground, 0, temp, 0, index);
        System.arraycopy (cellForeground, index, temp, index+1, columnCount-index-1);
        item.cellForeground = temp;
    }
    Font [] cellFont = item.cellFont;
    if (cellFont !is null) {
        Font [] temp = new Font [columnCount];
        System.arraycopy (cellFont, 0, temp, 0, index);
        System.arraycopy (cellFont, index, temp, index+1, columnCount-index-1);
        item.cellFont = temp;
    }
}

void createHandle () {
    NSScrollView scrollWidget = cast(NSScrollView) (new SWTScrollView ()).alloc ();
    scrollWidget.init ();
    scrollWidget.setHasHorizontalScroller ((style & DWT.H_SCROLL) !is 0);
    scrollWidget.setHasVerticalScroller ((style & DWT.V_SCROLL) !is 0);
    scrollWidget.setAutohidesScrollers (true);
    scrollWidget.setBorderType(cast(NSBorderType)(hasBorder () ? OS.NSBezelBorder : OS.NSNoBorder));

    NSOutlineView widget = cast(NSOutlineView) (new SWTOutlineView ()).alloc ();
    /*
    * Bug in Cocoa.  Calling init, instead of initWithFrame on an NSOutlineView
    * cause the NSOutlineView to leak some memory.  The work around is to call
    * initWithFrame and pass an empty NSRect instead of calling init.
    */
    widget.initWithFrame(NSRect());
    widget.setAllowsMultipleSelection ((style & DWT.MULTI) !is 0);
    widget.setAllowsColumnReordering (false);
    widget.setAutoresizesOutlineColumn (false);
    widget.setAutosaveExpandedItems (true);
    widget.setDataSource (widget);
    widget.setDelegate (widget);
    widget.setColumnAutoresizingStyle (OS.NSTableViewNoColumnAutoresizing);
    NSSize spacing = NSSize();
    spacing.width = spacing.height = CELL_GAP;
    widget.setIntercellSpacing(spacing);
    widget.setDoubleAction (OS.sel_sendDoubleSelection);
    if (!hasBorder ()) widget.setFocusRingType (OS.NSFocusRingTypeNone);

    headerView = cast(NSTableHeaderView)(new SWTTableHeaderView ()).alloc ().init ();
    widget.setHeaderView (null);

    NSString str = NSString.stringWith ("");  //$NON-NLS-1$
    if ((style & DWT.CHECK) !is 0) {
        checkColumn = cast(NSTableColumn) (new NSTableColumn ()).alloc ();
        checkColumn = checkColumn.initWithIdentifier(NSString.stringWith(Format("{}", ++NEXT_ID)));
        checkColumn.headerCell ().setTitle (str);
        widget.addTableColumn (checkColumn);
        widget.setOutlineTableColumn (checkColumn);
        checkColumn.setResizingMask (OS.NSTableColumnNoResizing);
        checkColumn.setEditable (false);
        objc.Class cls = NSButton.cellClass (); /* use our custom cell class */
        buttonCell = new NSButtonCell (OS.class_createInstance (cls, 0));
        buttonCell.init ();
        checkColumn.setDataCell (buttonCell);
        buttonCell.setButtonType (OS.NSSwitchButton);
        buttonCell.setImagePosition (OS.NSImageOnly);
        buttonCell.setAllowsMixedState (true);
        checkColumn.setWidth (getCheckColumnWidth ());
    }

    firstColumn = cast(NSTableColumn) (new NSTableColumn ()).alloc ();
    firstColumn = firstColumn.initWithIdentifier(NSString.stringWith(Format("{}", ++NEXT_ID)));
    /*
    * Feature in Cocoa.  If a column's width is too small to show any content
    * then outlineView_objectValueForTableColumn_byItem is never invoked to
    * query for item values, which is a problem for VIRTUAL Trees.  The
    * workaround is to ensure that, for 0-column Trees, the internal first
    * column always has a minimal width that makes this call come in.
    */
    firstColumn.setMinWidth (FIRST_COLUMN_MINIMUM_WIDTH);
    firstColumn.setWidth(0);
    firstColumn.headerCell ().setTitle (str);
    widget.addTableColumn (firstColumn);
    widget.setOutlineTableColumn (firstColumn);
    dataCell = cast(NSTextFieldCell)(new SWTImageTextCell ()).alloc ().init ();
    dataCell.setLineBreakMode(OS.NSLineBreakByClipping);
    firstColumn.setDataCell (dataCell);

    scrollView = scrollWidget;
    view = widget;
}

void createItem (TreeColumn column, int index) {
    if (!(0 <= index && index <= columnCount)) error (DWT.ERROR_INVALID_RANGE);
    if (index is 0) {
        // first column must be left aligned
        column.style &= ~(DWT.LEFT | DWT.RIGHT | DWT.CENTER);
        column.style |= DWT.LEFT;
    }
    if (columnCount is columns.length) {
        TreeColumn [] newColumns = new TreeColumn [columnCount + 4];
        System.arraycopy (columns, 0, newColumns, 0, columns.length);
        columns = newColumns;
    }
    NSTableColumn nsColumn;
    if (columnCount is 0) {
        //TODO - clear attributes, alignment etc.
        nsColumn = firstColumn;
        nsColumn.setMinWidth (0);
        firstColumn = null;
    } else {
        //TODO - set attributes, alignment etc.
        NSOutlineView outlineView = cast(NSOutlineView)view;
        NSString str = NSString.stringWith ("");
        nsColumn = cast(NSTableColumn) (new NSTableColumn ()).alloc ();
        nsColumn = nsColumn.initWithIdentifier(NSString.stringWith(Format("{}", ++NEXT_ID)));
        nsColumn.setMinWidth(0);
        nsColumn.headerCell ().setTitle (str);
        outlineView.addTableColumn (nsColumn);
        int checkColumn = (style & DWT.CHECK) !is 0 ? 1 : 0;
        outlineView.moveColumn (columnCount + checkColumn, index + checkColumn);
        nsColumn.setDataCell (dataCell);
        if (index is 0) {
            outlineView.setOutlineTableColumn (nsColumn);
        }
    }
    column.createJNIRef ();
    NSTableHeaderCell headerCell = cast(NSTableHeaderCell)(new SWTTableHeaderCell ()).alloc ().init ();
    nsColumn.setHeaderCell (headerCell);
    display.addWidget (headerCell, column);
    column.nsColumn = nsColumn;
    nsColumn.setWidth (0);
    System.arraycopy (columns, index, columns, index + 1, columnCount++ - index);
    columns [index] = column;
    for (int i = 0; i < itemCount; i++) {
        TreeItem item = items [i];
        if (item !is null) {
            if (columnCount > 1) {
                createColumn (item, index);
            }
        }
    }
}

void createItem (TreeItem item, TreeItem parentItem, int index) {
    int count;
    TreeItem [] items;
    if (parentItem !is null) {
        count = parentItem.itemCount;
        items = parentItem.items;
    } else {
        count = this.itemCount;
        items = this.items;
    }
    if (index is -1) index = count;
    if (!(0 <= index && index <= count)) error (DWT.ERROR_INVALID_RANGE);
    if (count is items.length) {
        TreeItem [] newItems = new TreeItem [items.length + 4];
        System.arraycopy (items, 0, newItems, 0, items.length);
        items = newItems;
        if (parentItem !is null) {
            parentItem.items = items;
        } else {
            this.items = items;
        }
    }
    System.arraycopy (items, index, items, index + 1, count++ - index);
    items [index] = item;
    item.items = new TreeItem [4];
    SWTTreeItem handle = cast(SWTTreeItem) (new SWTTreeItem ()).alloc ().init ();
    item.handle = handle;
    item.createJNIRef ();
    item.register ();
    if (parentItem !is null) {
        parentItem.itemCount = count;
    } else {
        this.itemCount = count;
    }
    ignoreExpand = true;
    reloadItem (parentItem, true);
    if (parentItem !is null && parentItem.itemCount is 1 && parentItem.expanded) {
        (cast(NSOutlineView)view).expandItem (parentItem.handle);
    }
    ignoreExpand = false;
}

void createWidget () {
    super.createWidget ();
    items = new TreeItem [4];
    columns = new TreeColumn [4];
}

Color defaultBackground () {
    return display.getWidgetColor (DWT.COLOR_LIST_BACKGROUND);
}

NSFont defaultNSFont () {
    return display.outlineViewFont;
}

Color defaultForeground () {
    return display.getWidgetColor (DWT.COLOR_LIST_FOREGROUND);
}

/**
 * Deselects all selected items in the receiver.
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void deselectAll () {
    checkWidget ();
    NSTableView widget = cast(NSOutlineView) view;
    ignoreSelect = true;
    widget.deselectAll (null);
    ignoreSelect = false;
}

void deregister () {
    super.deregister ();
    display.removeWidget (headerView);
    display.removeWidget (dataCell);
    if (buttonCell !is null) display.removeWidget (buttonCell);
}

/**
 * Deselects an item in the receiver.  If the item was already
 * deselected, it remains deselected.
 *
 * @param item the item to be deselected
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the item is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the item has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public void deselect (TreeItem item) {
    checkWidget ();
    if (item is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (item.isDisposed ()) error (DWT.ERROR_INVALID_ARGUMENT);
    NSOutlineView widget = cast(NSOutlineView)view;
    NSInteger row = widget.rowForItem(item.handle);
    ignoreSelect = true;
    widget.deselectRow (row);
    ignoreSelect = false;
}

void destroyItem (TreeColumn column) {
    int index = 0;
    while (index < columnCount) {
        if (columns [index] is column) break;
        index++;
    }
    for (int i=0; i<items.length; i++) {
        TreeItem item = items [i];
        if (item !is null) {
            if (columnCount <= 1) {
                item.strings = null;
                item.images = null;
                item.cellBackground = null;
                item.cellForeground = null;
                item.cellFont = null;
            } else {
                if (item.strings !is null) {
                    String [] strings = item.strings;
                    if (index is 0) {
                        item.text = strings [1] !is null ? strings [1] : "";
                    }
                    String [] temp = new String [columnCount - 1];
                    System.arraycopy (strings, 0, temp, 0, index);
                    System.arraycopy (strings, index + 1, temp, index, columnCount - 1 - index);
                    item.strings = temp;
                } else {
                    if (index is 0) item.text = "";
                }
                if (item.images !is null) {
                    Image [] images = item.images;
                    if (index is 0) item.image = images [1];
                    Image [] temp = new Image [columnCount - 1];
                    System.arraycopy (images, 0, temp, 0, index);
                    System.arraycopy (images, index + 1, temp, index, columnCount - 1 - index);
                    item.images = temp;
                } else {
                    if (index is 0) item.image = null;
                }
                if (item.cellBackground !is null) {
                    Color [] cellBackground = item.cellBackground;
                    Color [] temp = new Color [columnCount - 1];
                    System.arraycopy (cellBackground, 0, temp, 0, index);
                    System.arraycopy (cellBackground, index + 1, temp, index, columnCount - 1 - index);
                    item.cellBackground = temp;
                }
                if (item.cellForeground !is null) {
                    Color [] cellForeground = item.cellForeground;
                    Color [] temp = new Color [columnCount - 1];
                    System.arraycopy (cellForeground, 0, temp, 0, index);
                    System.arraycopy (cellForeground, index + 1, temp, index, columnCount - 1 - index);
                    item.cellForeground = temp;
                }
                if (item.cellFont !is null) {
                    Font [] cellFont = item.cellFont;
                    Font [] temp = new Font [columnCount - 1];
                    System.arraycopy (cellFont, 0, temp, 0, index);
                    System.arraycopy (cellFont, index + 1, temp, index, columnCount - 1 - index);
                    item.cellFont = temp;
                }
            }
        }
    }

    int oldIndex = indexOf (column.nsColumn);

    System.arraycopy (columns, index + 1, columns, index, --columnCount - index);
    columns [columnCount] = null;
    if (columnCount is 0) {
        //TODO - reset attributes
        firstColumn = column.nsColumn;
        firstColumn.retain ();
        /*
        * Feature in Cocoa.  If a column's width is too small to show any content
        * then outlineView_objectValueForTableColumn_byItem is never invoked to
        * query for item values, which is a problem for VIRTUAL Trees.  The
        * workaround is to ensure that, for 0-column Trees, the internal first
        * column always has a minimal width that makes this call come in.
        */
        firstColumn.setMinWidth (FIRST_COLUMN_MINIMUM_WIDTH);
        setScrollWidth ();
    } else {
        if (index is 0) {
            (cast(NSOutlineView)view).setOutlineTableColumn(columns[0].nsColumn);
        }
        (cast(NSOutlineView)view).removeTableColumn(column.nsColumn);
    }

    NSArray array = (cast(NSOutlineView)view).tableColumns ();
    NSUInteger arraySize = array.count ();
    for (NSUInteger i = oldIndex; i < arraySize; i++) {
        objc.id columnId = array.objectAtIndex (i).id;
        for (int j = 0; j < columnCount; j++) {
            if (columns[j].nsColumn.id is columnId) {
                columns [j].sendEvent (DWT.Move);
                break;
            }
        }
    }
}

void destroyItem (TreeItem item) {
    int count;
    TreeItem[] items;
    TreeItem parentItem = item.parentItem;
    if (parentItem !is null) {
        count = parentItem.itemCount;
        items = parentItem.items;
    } else {
        count = this.itemCount;
        items = this.items;
    }
    int index = 0;
    while (index < count) {
        if (items [index] is item) break;
        index++;
    }
    System.arraycopy (items, index + 1, items, index, --count - index);
    items [count] = null;
    if (parentItem !is null) {
        parentItem.itemCount = count;
    } else {
        this.itemCount = count;
    }
    reloadItem (parentItem, true);
    setScrollWidth ();
    if (this.itemCount is 0) imageBounds = null;
}

bool dragDetect(int x, int y, bool filter, bool[] consume) {
    // Let Cocoa determine if a drag is starting and fire the notification when we get the callback.
    return false;
}

void drawInteriorWithFrame_inView (objc.id id, objc.SEL sel, NSRect rect, objc.id view) {
    bool hooksErase = hooks (DWT.EraseItem);
    bool hooksPaint = hooks (DWT.PaintItem);
    bool hooksMeasure = hooks (DWT.MeasureItem);

    NSTextFieldCell cell = new NSTextFieldCell (id);

    NSOutlineView widget = cast(NSOutlineView)this.view;
    void* outValue;
    OS.object_getInstanceVariable(id, Display.SWT_ROW, outValue);
    TreeItem item = cast(TreeItem) display.getWidget (cast(objc.id)outValue);
    NSInteger rowIndex = widget.rowForItem(item.handle);
    OS.object_getInstanceVariable(id, Display.SWT_COLUMN, outValue);
    cocoa.id tableColumn = cast(cocoa.id)outValue;
    NSInteger nsColumnIndex = widget.tableColumns().indexOfObjectIdenticalTo(tableColumn);
    int columnIndex = 0;
    for (int i=0; i<columnCount; i++) {
        if (columns [i].nsColumn is tableColumn) {
            columnIndex = i;
            break;
        }
    }

    Color background = item.cellBackground !is null ? item.cellBackground [columnIndex] : null;
    if (background is null) background = item.background;
    bool drawBackground = background !is null;
    bool drawForeground = true;
    bool isSelected = cell.isHighlighted();
    bool drawSelection = isSelected;
    bool hasFocus = hooksErase && hasFocus ();

    Color selectionBackground = null, selectionForeground = null;
    if (isSelected && (hooksErase || hooksPaint)) {
        selectionForeground = Color.cocoa_new(display, hasFocus ? display.alternateSelectedControlTextColor : display.selectedControlTextColor);
        selectionBackground = Color.cocoa_new(display, hasFocus ? display.alternateSelectedControlColor : display.secondarySelectedControlColor);
    }

    NSSize contentSize = super.cellSize(id, OS.sel_cellSize);
    NSImage image = cell.image();
    if (image !is null) contentSize.width += imageBounds.width + IMAGE_GAP;
    int contentWidth = cast(int)Math.ceil (contentSize.width);
    NSSize spacing = widget.intercellSpacing();
    int itemHeight = cast(int)Math.ceil (widget.rowHeight() + spacing.height);

    NSRect cellRect = widget.rectOfColumn (nsColumnIndex);
    cellRect.y = rect.y;
    cellRect.height = rect.height + spacing.height;
    if (columnCount is 0) {
        NSRect rowRect = widget.rectOfRow (rowIndex);
        cellRect.width = rowRect.width;
    }
    Cocoa.CGFloat offsetX = 0, offsetY = 0;
    if (hooksPaint || hooksErase) {
        NSRect frameCell = widget.frameOfCellAtColumn(nsColumnIndex, rowIndex);
        offsetX = rect.x - frameCell.x;
        offsetY = rect.y - frameCell.y;
        if (drawExpansion) {
            offsetX -= 0.5f;
            offsetY -= 0.5f;
        }
    }
    int itemX = cast(int)(rect.x - offsetX), itemY = cast(int)(rect.y - offsetY);
    NSGraphicsContext context = NSGraphicsContext.currentContext ();

    if (hooksMeasure) {
        sendMeasureItem(item, columnIndex, contentSize);
    }

    Color userForeground = null;
    if (hooksErase) {
        context.saveGraphicsState();
        NSAffineTransform transform = NSAffineTransform.transform();
        transform.translateXBy(offsetX, offsetY);
        transform.concat();

        GCData data = new GCData ();
        data.paintRectStruct = cellRect;
        data.paintRect = &data.paintRectStruct;
        GC gc = GC.cocoa_new (this, data);
        gc.setFont (item.getFont (columnIndex));
        if (isSelected) {
            gc.setForeground (selectionForeground);
            gc.setBackground (selectionBackground);
        } else {
            gc.setForeground (item.getForeground (columnIndex));
            gc.setBackground (item.getBackground (columnIndex));
        }
        if (!drawExpansion) {
            gc.setClipping (cast(int)(cellRect.x - offsetX), cast(int)(cellRect.y - offsetY), cast(int)cellRect.width, cast(int)cellRect.height);
        }
        Event event = new Event ();
        event.item = item;
        event.gc = gc;
        event.index = columnIndex;
        event.detail = DWT.FOREGROUND;
        if (drawBackground) event.detail |= DWT.BACKGROUND;
        if (isSelected) event.detail |= DWT.SELECTED;
        event.x = cast(int)cellRect.x;
        event.y = cast(int)cellRect.y;
        event.width = cast(int)cellRect.width;
        event.height = cast(int)cellRect.height;
        sendEvent (DWT.EraseItem, event);
        if (!event.doit) {
            drawForeground = drawBackground = drawSelection = false;
        } else {
            drawBackground = drawBackground && (event.detail & DWT.BACKGROUND) !is 0;
            drawForeground = (event.detail & DWT.FOREGROUND) !is 0;
            drawSelection = drawSelection && (event.detail & DWT.SELECTED) !is 0;
        }
        if (!drawSelection && isSelected) {
            userForeground = Color.cocoa_new(display, gc.getForeground().handle);
        }
        gc.dispose ();

        context.restoreGraphicsState();

        if (isDisposed ()) return;
        if (item.isDisposed ()) return;

        if (drawSelection && ((style & DWT.HIDE_SELECTION) is 0 || hasFocus)) {
            cellRect.height = cellRect.height - spacing.height;
            callSuper (widget.id, OS.sel_highlightSelectionInClipRect_, cellRect);
            cellRect.height = cellRect.height + spacing.height;
        }
    }

    if (drawBackground && !drawSelection) {
        context.saveGraphicsState ();
        Carbon.CGFloat[] colorRGB = background.handle;
        NSColor color = NSColor.colorWithDeviceRed (colorRGB[0], colorRGB[1], colorRGB[2], 1f);
        color.setFill ();
        NSBezierPath.fillRect (cellRect);
        context.restoreGraphicsState ();
    }

    if (insertItem !is null && !insertItem.isDisposed()) {
        context.saveGraphicsState ();
        NSRect contentRect = cell.titleRectForBounds (rect);
        GCData data = new GCData ();
        data.paintRectStruct = contentRect;
        data.paintRect = &data.paintRectStruct;
        GC gc = GC.cocoa_new (this, data);
        gc.setClipping (cast(int)(contentRect.x - offsetX), cast(int)(contentRect.y - offsetY), cast(int)contentRect.width, cast(int)contentRect.height);
        Rectangle itemRect = insertItem.getImageBounds(0).union_(insertItem.getBounds());
        Rectangle clientRect = getClientArea();
        int x = clientRect.x + clientRect.width;
        int posY = insertBefore ? itemRect.y : itemRect.y + itemRect.height - 1;
        gc.drawLine(itemRect.x, posY, x, posY);
        gc.dispose ();
        context.restoreGraphicsState ();
    }

    if (drawForeground) {
        if ((!drawExpansion || hooksMeasure) && image !is null) {
            NSRect destRect = NSRect();
            destRect.x = rect.x + IMAGE_GAP;
            destRect.y = rect.y + cast(float)Math.ceil((rect.height - imageBounds.height) / 2);
            destRect.width = imageBounds.width;
            destRect.height = imageBounds.height;
            NSRect srcRect = NSRect();
            NSSize size = image.size();
            srcRect.width = size.width;
            srcRect.height = size.height;
            context.saveGraphicsState();
            NSBezierPath.bezierPathWithRect(rect).addClip();
            NSAffineTransform transform = NSAffineTransform.transform();
            transform.scaleXBy(1, -1);
            transform.translateXBy(0, -(destRect.height + 2 * destRect.y));
            transform.concat();
            image.drawInRect(destRect, srcRect, OS.NSCompositeSourceOver, 1);
            context.restoreGraphicsState();
            int imageWidth = imageBounds.width + IMAGE_GAP;
            rect.x = rect.x + imageWidth;
            rect.width = rect.width - imageWidth;
        }
        cell.setHighlighted (false);
        bool callSuper = false;
        if (userForeground !is null) {
            /*
            * Bug in Cocoa.  For some reason, it is not possible to change the
            * foreground color to black when the cell is highlighted. The text
            * still draws white.  The fix is to draw the text and not call super.
            */
            Cocoa.CGFloat [] color = userForeground.handle;
            if (color[0] is 0 && color[1] is 0 && color[2] is 0 && color[3] is 1) {
                NSMutableAttributedString newStr = new NSMutableAttributedString(cell.attributedStringValue().mutableCopy());
                NSRange range = NSRange();
                range.length = newStr.length();
                newStr.removeAttribute(OS.NSForegroundColorAttributeName, range);
                NSRect newRect = NSRect();
                newRect.x = rect.x + TEXT_GAP;
                newRect.y = rect.y;
                newRect.width = rect.width - TEXT_GAP;
                newRect.height = rect.height;
                NSSize size = newStr.size();
                if (newRect.height > size.height) {
                	newRect.y = newRect.y + ((newRect.height - size.height) / 2);
                    newRect.height = size.height;
                }
                newStr.drawInRect(newRect);
                newStr.release();
            } else {
                NSColor nsColor = NSColor.colorWithDeviceRed(color[0], color[1], color[2], color[3]);
                cell.setTextColor(nsColor);
                callSuper = true;
            }
        } else {
            callSuper = true;
        }
        if (callSuper) {
            NSAttributedString attrStr = cell.attributedStringValue();
            NSSize size = attrStr.size();
            if (rect.height > size.height) {
            	rect.y = rect.y + ((rect.height - size.height) / 2);
                rect.height = size.height;
            }
            super.drawInteriorWithFrame_inView(id, sel, rect, view);
        }
    }

    if (hooksPaint) {
        context.saveGraphicsState();
        NSAffineTransform transform = NSAffineTransform.transform();
        transform.translateXBy(offsetX, offsetY);
        transform.concat();

        GCData data = new GCData ();
        data.paintRectStruct = cellRect;
        data.paintRect = &data.paintRectStruct;
        GC gc = GC.cocoa_new (this, data);
        gc.setFont (item.getFont (columnIndex));
        if (drawSelection) {
            gc.setForeground (selectionForeground);
            gc.setBackground (selectionBackground);
        } else {
            gc.setForeground (userForeground !is null ? userForeground : item.getForeground (columnIndex));
            gc.setBackground (item.getBackground (columnIndex));
        }
        if (!drawExpansion) {
            gc.setClipping (cast(int)(cellRect.x - offsetX), cast(int)(cellRect.y - offsetY), cast(int)cellRect.width, cast(int)cellRect.height);
        }
        Event event = new Event ();
        event.item = item;
        event.gc = gc;
        event.index = columnIndex;
        if (drawForeground) event.detail |= DWT.FOREGROUND;
        if (drawBackground) event.detail |= DWT.BACKGROUND;
        if (drawSelection) event.detail |= DWT.SELECTED;
        event.x = itemX;
        event.y = itemY;
        event.width = contentWidth;
        event.height = itemHeight;
        sendEvent (DWT.PaintItem, event);
        gc.dispose ();

        context.restoreGraphicsState();
    }
}

void drawWithExpansionFrame_inView (objc.id id, objc.SEL sel, NSRect cellFrame, objc.id view) {
    drawExpansion = true;
    super.drawWithExpansionFrame_inView(id, sel, cellFrame, view);
    drawExpansion = false;
}

void expandItem_expandChildren (objc.id id, objc.SEL sel, objc.id itemID, bool children) {
    TreeItem item = cast(TreeItem)display.getWidget(itemID);
    if (!ignoreExpand) item.sendExpand (true, children);
    ignoreExpand = true;
    super.expandItem_expandChildren (id, sel, itemID, children);
    ignoreExpand = false;
    if (isDisposed() || item.isDisposed()) return;
    if (!children) {
        ignoreExpand = true;
        TreeItem[] items = item.items;
        for (int i = 0; i < item.itemCount; i++) {
            if (items[i] !is null) items[i].updateExpanded ();
        }
        ignoreExpand = false;
    }
    setScrollWidth (false, item.items, true);
}

NSRect expansionFrameWithFrame_inView(objc.id id, objc.SEL sel, NSRect cellRect, objc.id view) {
    if (toolTipText is null) {
        NSRect rect = super.expansionFrameWithFrame_inView(id, sel, cellRect, view);
        NSCell cell = new NSCell(id);
        if (rect.width !is 0 && rect.height !is 0) {
            if (hooks(DWT.MeasureItem)) {
                NSSize cellSize = cell.cellSize();
                cellRect.width = cellSize.width;
                return cellRect;
            }
        } else {
            NSRect expansionRect;
            if (hooks(DWT.MeasureItem)) {
                expansionRect = cellRect;
                NSSize cellSize = cell.cellSize();
                expansionRect.width = cellSize.width;
            } else {
                expansionRect = cell.titleRectForBounds(cellRect);
                NSSize cellSize = super.cellSize(id, OS.sel_cellSize);
                expansionRect.width = cellSize.width;
            }
            NSRect contentRect = scrollView.contentView().bounds();
            contentRect = OS.NSIntersectionRect(expansionRect, contentRect);
            if (!OS.NSEqualRects(expansionRect, contentRect)) {
                return expansionRect;
            }
        }
        return rect;
    }
    return NSRect();
}

Widget findTooltip (NSPoint pt) {
    NSTableView widget = cast(NSTableView)view;
    NSTableHeaderView headerView = widget.headerView();
    if (headerView !is null) {
        pt = headerView.convertPoint_fromView_ (pt, null);
        NSInteger index = headerView.columnAtPoint (pt);
        if (index !is -1) {
            NSArray nsColumns = widget.tableColumns ();
            cocoa.id nsColumn = nsColumns.objectAtIndex (index);
            for (int i = 0; i < columnCount; i++) {
                TreeColumn column = columns [i];
                if (column.nsColumn.id is nsColumn.id) {
                    return column;
                }
            }
        }
    }
    return super.findTooltip (pt);
}

int getCheckColumnWidth () {
    return cast(int)checkColumn.dataCell().cellSize().width;
}

public Rectangle getClientArea () {
    checkWidget ();
    Rectangle rect = super.getClientArea ();
    NSTableHeaderView headerView = (cast(NSTableView) view).headerView ();
    if (headerView !is null) {
        int height =  cast(int) headerView.bounds ().height;
        rect.y -= height;
        rect.height += height;
    }
    return rect;
}

TreeColumn getColumn (cocoa.id id) {
    for (int i = 0; i < columnCount; i++) {
        if (columns[i].nsColumn.id is id.id) {
            return columns[i];
        }
    }
    return null;
}

/**
 * Returns the column at the given, zero-relative index in the
 * receiver. Throws an exception if the index is out of range.
 * Columns are returned in the order that they were created.
 * If no <code>TreeColumn</code>s were created by the programmer,
 * this method will throw <code>ERROR_INVALID_RANGE</code> despite
 * the fact that a single column of data may be visible in the tree.
 * This occurs when the programmer uses the tree like a list, adding
 * items but never creating a column.
 *
 * @param index the index of the column to return
 * @return the column at the given index
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_RANGE - if the index is not between 0 and the number of elements in the list minus 1 (inclusive)</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Tree#getColumnOrder()
 * @see Tree#setColumnOrder(int[])
 * @see TreeColumn#getMoveable()
 * @see TreeColumn#setMoveable(bool)
 * @see DWT#Move
 *
 * @since 3.1
 */
public TreeColumn getColumn (int index) {
    checkWidget ();
    if (!(0 <=index && index < columnCount)) error (DWT.ERROR_INVALID_RANGE);
    return columns [index];
}

/**
 * Returns the number of columns contained in the receiver.
 * If no <code>TreeColumn</code>s were created by the programmer,
 * this value is zero, despite the fact that visually, one column
 * of items may be visible. This occurs when the programmer uses
 * the tree like a list, adding items but never creating a column.
 *
 * @return the number of columns
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public int getColumnCount () {
    checkWidget ();
    return columnCount;
}

/**
 * Returns an array of zero-relative integers that map
 * the creation order of the receiver's items to the
 * order in which they are currently being displayed.
 * <p>
 * Specifically, the indices of the returned array represent
 * the current visual order of the items, and the contents
 * of the array represent the creation order of the items.
 * </p><p>
 * Note: This is not the actual structure used by the receiver
 * to maintain its list of items, so modifying the array will
 * not affect the receiver.
 * </p>
 *
 * @return the current visual order of the receiver's items
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Tree#setColumnOrder(int[])
 * @see TreeColumn#getMoveable()
 * @see TreeColumn#setMoveable(bool)
 * @see DWT#Move
 *
 * @since 3.2
 */
public int [] getColumnOrder () {
    checkWidget ();
    int [] order = new int [columnCount];
    for (int i = 0; i < columnCount; i++) {
        TreeColumn column = columns [i];
        int index = indexOf (column.nsColumn);
        if ((style & DWT.CHECK) !is 0) index -= 1;
        order [index] = i;
    }
    return order;
}

/**
 * Returns an array of <code>TreeColumn</code>s which are the
 * columns in the receiver. Columns are returned in the order
 * that they were created.  If no <code>TreeColumn</code>s were
 * created by the programmer, the array is empty, despite the fact
 * that visually, one column of items may be visible. This occurs
 * when the programmer uses the tree like a list, adding items but
 * never creating a column.
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
 *
 * @see Tree#getColumnOrder()
 * @see Tree#setColumnOrder(int[])
 * @see TreeColumn#getMoveable()
 * @see TreeColumn#setMoveable(bool)
 * @see DWT#Move
 *
 * @since 3.1
 */
public TreeColumn [] getColumns () {
    checkWidget ();
    TreeColumn [] result = new TreeColumn [columnCount];
    System.arraycopy (columns, 0, result, 0, columnCount);
    return result;
}

/**
 * Returns the width in pixels of a grid line.
 *
 * @return the width of a grid line in pixels
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public int getGridLineWidth () {
    checkWidget ();
    return 0;
}

/**
 * Returns the height of the receiver's header
 *
 * @return the height of the header or zero if the header is not visible
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public int getHeaderHeight () {
    checkWidget ();
    NSTableHeaderView headerView = (cast(NSOutlineView) view).headerView ();
    if (headerView is null) return 0;
    return cast(int) headerView.bounds ().height;
}

/**
 * Returns <code>true</code> if the receiver's header is visible,
 * and <code>false</code> otherwise.
 * <p>
 * If one of the receiver's ancestors is not visible or some
 * other condition makes the receiver not visible, this method
 * may still indicate that it is considered visible even though
 * it may not actually be showing.
 * </p>
 *
 * @return the receiver's header's visibility state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public bool getHeaderVisible () {
    checkWidget ();
    return (cast(NSOutlineView) view).headerView () !is null;
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
 *
 * @since 3.1
 */
public TreeItem getItem (int index) {
    checkWidget ();
    int count = getItemCount ();
    if (index < 0 || index >= count) error (DWT.ERROR_INVALID_RANGE);
    return _getItem (null, index, true);
}

/**
 * Returns the item at the given point in the receiver
 * or null if no such item exists. The point is in the
 * coordinate system of the receiver.
 * <p>
 * The item that is returned represents an item that could be selected by the user.
 * For example, if selection only occurs in items in the first column, then null is
 * returned if the point is outside of the item.
 * Note that the DWT.FULL_SELECTION style hint, which specifies the selection policy,
 * determines the extent of the selection.
 * </p>
 *
 * @param point the point used to locate the item
 * @return the item at the given point, or null if the point is not in a selectable item
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the point is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public TreeItem getItem (Point point) {
    checkWidget ();
    if (point is null) error (DWT.ERROR_NULL_ARGUMENT);
    checkItems ();
    NSOutlineView widget = cast(NSOutlineView)view;
    NSPoint pt = NSPoint();
    pt.x = point.x;
    pt.y = point.y;
    NSInteger row = widget.rowAtPoint(pt);
    if (row is -1) return null;
    NSRect rect = widget.frameOfOutlineCellAtRow(row);
    if (OS.NSPointInRect(pt, rect)) return null;
    cocoa.id id = widget.itemAtRow(row);
    Widget item = display.getWidget (id.id);
    if (item !is null && cast(TreeItem) item) {
        return cast(TreeItem)item;
    }
    return null;
}

/**
 * Returns the number of items contained in the receiver
 * that are direct item children of the receiver.  The
 * number that is returned is the number of roots in the
 * tree.
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

int getItemCount (TreeItem item) {
    return item is null ? itemCount : item.itemCount;
}

/**
 * Returns the height of the area which would be used to
 * display <em>one</em> of the items in the tree.
 *
 * @return the height of one item
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getItemHeight () {
    checkWidget ();
    return cast(int)(cast(NSOutlineView) view).rowHeight () + CELL_GAP;
}

/**
 * Returns a (possibly empty) array of items contained in the
 * receiver that are direct item children of the receiver.  These
 * are the roots of the tree.
 * <p>
 * Note: This is not the actual structure used by the receiver
 * to maintain its list of items, so modifying the array will
 * not affect the receiver.
 * </p>
 *
 * @return the items
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public TreeItem [] getItems () {
    checkWidget ();
    TreeItem [] result = new TreeItem [itemCount];
    for (int i=0; i<itemCount; i++) {
        result [i] = _getItem (null, i, true);
    }
    return result;
}

/**
 * Returns <code>true</code> if the receiver's lines are visible,
 * and <code>false</code> otherwise. Note that some platforms draw
 * grid lines while others may draw alternating row colors.
 * <p>
 * If one of the receiver's ancestors is not visible or some
 * other condition makes the receiver not visible, this method
 * may still indicate that it is considered visible even though
 * it may not actually be showing.
 * </p>
 *
 * @return the visibility state of the lines
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public bool getLinesVisible () {
    checkWidget ();
    return (cast(NSOutlineView) view).usesAlternatingRowBackgroundColors ();
}

/**
 * Returns the receiver's parent item, which must be a
 * <code>TreeItem</code> or null when the receiver is a
 * root.
 *
 * @return the receiver's parent item
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public TreeItem getParentItem () {
    checkWidget ();
    return null;
}

/**
 * Returns an array of <code>TreeItem</code>s that are currently
 * selected in the receiver. The order of the items is unspecified.
 * An empty array indicates that no items are selected.
 * <p>
 * Note: This is not the actual structure used by the receiver
 * to maintain its selection, so modifying the array will
 * not affect the receiver.
 * </p>
 * @return an array representing the selection
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public TreeItem [] getSelection () {
    checkWidget ();
    NSOutlineView widget = cast(NSOutlineView) view;
    if (widget.numberOfSelectedRows () is 0) {
        return new TreeItem [0];
    }
    NSIndexSet selection = widget.selectedRowIndexes ();
    NSUInteger count = selection.count ();
    NSUInteger [] indexBuffer = new NSUInteger [count];
    selection.getIndexes (indexBuffer.ptr, count, null);
    TreeItem [] result = new TreeItem [count];
    for (NSUInteger i=0; i<count; i++) {
        cocoa.id id = widget.itemAtRow (indexBuffer [i]);
        Widget item = display.getWidget (id.id);
        if (item !is null && cast(TreeItem) item) {
            result[i] = cast(TreeItem) item;
        }
    }
    return result;
}

/**
 * Returns the number of selected items contained in the receiver.
 *
 * @return the number of selected items
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getSelectionCount () {
    checkWidget ();
    return cast(int)/*64*/(cast(NSOutlineView) view).numberOfSelectedRows ();
}

/**
 * Returns the column which shows the sort indicator for
 * the receiver. The value may be null if no column shows
 * the sort indicator.
 *
 * @return the sort indicator
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setSortColumn(TreeColumn)
 *
 * @since 3.2
 */
public TreeColumn getSortColumn () {
    checkWidget ();
    return sortColumn;
}

/**
 * Returns the direction of the sort indicator for the receiver.
 * The value will be one of <code>UP</code>, <code>DOWN</code>
 * or <code>NONE</code>.
 *
 * @return the sort direction
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setSortDirection(int)
 *
 * @since 3.2
 */
public int getSortDirection () {
    checkWidget ();
    return sortDirection;
}

/**
 * Returns the item which is currently at the top of the receiver.
 * This item can change when items are expanded, collapsed, scrolled
 * or new items are added or removed.
 *
 * @return the item at the top of the receiver
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.1
 */
public TreeItem getTopItem () {
    checkWidget ();
    //TODO - partial item at the top
    NSRect rect = scrollView.documentVisibleRect ();
    NSPoint point = NSPoint ();
    point.x = rect.x;
    point.y = rect.y;
    NSOutlineView outlineView = cast(NSOutlineView)view;
    NSInteger index = outlineView.rowAtPoint (point);
    if (index is -1) return null; /* empty */
    cocoa.id item = outlineView.itemAtRow (index);
    return cast(TreeItem)display.getWidget (item.id);
}

void highlightSelectionInClipRect(objc.id id, objc.SEL sel, NSRect clipRect) {
    if (hooks (DWT.EraseItem)) return;
    if ((style & DWT.HIDE_SELECTION) !is 0 && !hasFocus()) return;
    callSuper (id, sel, clipRect);
}

NSUInteger hitTestForEvent (objc.id id, objc.SEL sel, objc.id event, NSRect rect, objc.id controlView) {
    /*
    * For some reason, the cell class needs to implement hitTestForEvent:inRect:ofView:,
    * otherwise the double action selector is not called properly.
    */
    return cast(NSUInteger) callSuper(id, sel, event, rect, controlView);
}

objc.id image (objc.id id, objc.SEL sel) {
    void* image;
    OS.object_getInstanceVariable(id, Display.SWT_IMAGE, image);
    return cast(objc.id)image;
}

NSRect imageRectForBounds (objc.id id, objc.SEL sel, NSRect cellFrame) {
    NSImage image = (new NSCell(id)).image();
    if (image !is null) {
        cellFrame.x = cellFrame.x + IMAGE_GAP;
        cellFrame.width = imageBounds.width;
        cellFrame.height = imageBounds.height;
    }
    return cellFrame;
}

int indexOf (NSTableColumn column) {
    return cast(int)/*64*/(cast(NSTableView)view).tableColumns().indexOfObjectIdenticalTo(column);
}

/**
 * Searches the receiver's list starting at the first column
 * (index 0) until a column is found that is equal to the
 * argument, and returns the index of that column. If no column
 * is found, returns -1.
 *
 * @param column the search column
 * @return the index of the column
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the column is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public int indexOf (TreeColumn column) {
    checkWidget ();
    if (column is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (column.isDisposed ()) error (DWT.ERROR_INVALID_ARGUMENT);
    for (int i=0; i<columnCount; i++) {
        if (columns [i] is column) return i;
    }
    return -1;
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
 *
 * @since 3.1
 */
public int indexOf (TreeItem item) {
    checkWidget ();
    if (item is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (item.isDisposed ()) error (DWT.ERROR_INVALID_ARGUMENT);
    if (item.parentItem !is null) return -1;
    for (int i = 0; i < itemCount; i++) {
        if (item is items[i]) return i;
    }
    return -1;
}

bool isTrim (NSView view) {
    if (super.isTrim (view)) return true;
    return view.id is headerView.id;
}

objc.id menuForEvent(objc.id id, objc.SEL sel, objc.id theEvent) {
    if (id !is headerView.id) {
        /*
         * Feature in Cocoa: Table views do not change the selection when the user
         * right-clicks or control-clicks on an NSTableView or its subclasses. Fix is to select the
         * clicked-on row ourselves.
         */
        NSEvent event = new NSEvent(theEvent);
        NSOutlineView tree = cast(NSOutlineView)view;

        // get the current selections for the outline view.
        NSIndexSet selectedRowIndexes = tree.selectedRowIndexes();

        // select the row that was clicked before showing the menu for the event
        NSPoint mousePoint = view.convertPoint_fromView_(event.locationInWindow(), null);
        NSInteger row = tree.rowAtPoint(mousePoint);

        // figure out if the row that was just clicked on is currently selected
        if (selectedRowIndexes.containsIndex(row) is false) {
            NSIndexSet set = cast(NSIndexSet)(new NSIndexSet()).alloc();
            set = set.initWithIndex(row);
            tree.selectRowIndexes (set, false);
            set.release();
        }
        // else that row is currently selected, so don't change anything.
    }

    return super.menuForEvent(id, sel, theEvent);
}

void mouseDown (objc.id id, objc.SEL sel, objc.id theEvent) {
    if (headerView !is null && id is headerView.id) {
        NSTableView widget = cast(NSTableView)view;
        widget.setAllowsColumnReordering(false);
        NSPoint pt = headerView.convertPoint_fromView_((new NSEvent(theEvent)).locationInWindow(), null);
        NSInteger nsIndex = headerView.columnAtPoint(pt);
        if (nsIndex !is -1) {
            cocoa.id nsColumn = widget.tableColumns().objectAtIndex(nsIndex);
            for (int i = 0; i < columnCount; i++) {
                if (columns[i].nsColumn.id is nsColumn.id) {
                    widget.setAllowsColumnReordering(columns[i].movable);
                    break;
                }
            }
        }
    }
    else if (id is view.id) {
        // Bug/feature in Cocoa:  If the tree has a context menu we just set it visible instead of returning
        // it from menuForEvent:.  This has the side effect, however, of sending control-click to the NSTableView,
        // which is interpreted as a single click that clears the selection.  Fix is to ignore control-click,
        NSEvent event = new NSEvent(theEvent);
        if ((event.modifierFlags() & OS.NSControlKeyMask) !is 0) return;
    }
    super.mouseDown(id, sel, theEvent);
}

/*
 * Feature in Cocoa.  If a checkbox is in multi-state mode, nextState cycles
 * from off to mixed to on and back to off again.  This will cause the on state
 * to momentarily appear while clicking on the checkbox.  To avoid this,
 * override [NSCell nextState] to go directly to the desired state.
 */
objc.id nextState (objc.id id, objc.SEL sel) {
    NSOutlineView outlineView = cast(NSOutlineView)view;
    NSInteger index = outlineView.selectedRow ();
    TreeItem item = cast(TreeItem)display.getWidget (outlineView.itemAtRow (index).id);
    if (item.grayed) {
        return cast(objc.id)(item.checked ? OS.NSOffState : OS.NSMixedState);
    }
    return cast(objc.id)(item.checked ? OS.NSOffState : OS.NSOnState);
}

objc.id outlineView_child_ofItem (objc.id id, objc.SEL sel, objc.id outlineView, objc.id index, objc.id itemID) {
    TreeItem parent = cast(TreeItem) display.getWidget (itemID);
    TreeItem item = _getItem (parent, cast(NSInteger)index, true);
    return item.handle.id;
}

void outlineView_didClickTableColumn (objc.id id, objc.SEL sel, objc.id outlineView, objc.id tableColumn) {
    TreeColumn column = getColumn (new cocoa.id (tableColumn));
    if (column is null) return; /* either CHECK column or firstColumn in 0-column Tree */
    column.postEvent (DWT.Selection);
}

objc.id outlineView_objectValueForTableColumn_byItem (objc.id id, objc.SEL sel, objc.id outlineView, objc.id tableColumn, objc.id itemID) {
    TreeItem item = cast(TreeItem) display.getWidget (itemID);
    checkData (item);
    if (checkColumn !is null && tableColumn is checkColumn.id) {
        NSNumber value;
        if (item.checked && item.grayed) {
            value = NSNumber.numberWithInt (OS.NSMixedState);
        } else {
            value = NSNumber.numberWithInt (item.checked ? OS.NSOnState : OS.NSOffState);
        }
        return value.id;
    }
    for (int i=0; i<columnCount; i++) {
        if (columns [i].nsColumn.id is tableColumn) {
            return item.createString (i).id;
        }
    }
    return item.createString (0).id;
}

bool outlineView_isItemExpandable (objc.id id, objc.SEL sel, objc.id outlineView, objc.id item) {
    if (item is null) return true;
    return (cast(TreeItem) display.getWidget (item)).itemCount !is 0;
}

NSInteger outlineView_numberOfChildrenOfItem (objc.id id, objc.SEL sel, objc.id outlineView, objc.id item) {
    if (item is null) return itemCount;
    return (cast(TreeItem) display.getWidget (item)).itemCount;
}

void outlineView_willDisplayCell_forTableColumn_item (objc.id id, objc.SEL sel, objc.id outlineView, objc.id cell, objc.id tableColumn, objc.id itemID) {
    if (checkColumn !is null && tableColumn is checkColumn.id) return;
    TreeItem item = cast(TreeItem) display.getWidget(itemID);
    int index = 0;
    for (int i=0; i<columnCount; i++) {
        if (columns [i].nsColumn.id is tableColumn) {
            index = i;
            break;
        }
    }
    NSTextFieldCell textCell = new NSTextFieldCell (cell);
    OS.object_setInstanceVariable(cell, Display.SWT_ROW, itemID);
    OS.object_setInstanceVariable(cell, Display.SWT_COLUMN, tableColumn);
    Image image = index is 0 ? item.image : (item.images is null ? null : item.images [index]);
    textCell.setImage (image !is null ? image.handle : null);
    NSColor color;
    if (textCell.isEnabled()) {
        if (textCell.isHighlighted ()) {
            color = NSColor.selectedControlTextColor();
        } else {
            Color foreground = item.cellForeground !is null ? item.cellForeground [index] : null;
            if (foreground is null) foreground = item.foreground;
            if (foreground is null) foreground = getForegroundColor ();
            color = NSColor.colorWithDeviceRed (foreground.handle [0], foreground.handle [1], foreground.handle [2], 1);
        }
    } else {
        color = NSColor.disabledControlTextColor();
    }
    int alignment = OS.NSLeftTextAlignment;
    if (columnCount > 0) {
        int style = columns [index].style;
        if ((style & DWT.CENTER) !is 0) {
            alignment = OS.NSCenterTextAlignment;
        } else if ((style & DWT.RIGHT) !is 0) {
            alignment = OS.NSRightTextAlignment;
        }
    }
    Font font = item.cellFont !is null ? item.cellFont [index] : null;
    if (font is null) font = item.font;
    if (font is null) font = this.font;
    if (font is null) font = defaultFont ();
    if (font.extraTraits !is 0) {
        NSMutableDictionary dict = (cast(NSMutableDictionary)(new NSMutableDictionary()).alloc()).initWithCapacity(5);
        dict.setObject (color, OS.NSForegroundColorAttributeName);
        dict.setObject (font.handle, OS.NSFontAttributeName);
        addTraits(dict, font);
        NSMutableParagraphStyle paragraphStyle = cast(NSMutableParagraphStyle)(new NSMutableParagraphStyle ()).alloc ().init ();
        paragraphStyle.setLineBreakMode (OS.NSLineBreakByClipping);
        paragraphStyle.setAlignment (cast(NSTextAlignment)alignment);
        dict.setObject (paragraphStyle, OS.NSParagraphStyleAttributeName);
        paragraphStyle.release ();
        NSAttributedString attribStr = (cast(NSAttributedString) (new NSAttributedString ()).alloc ()).initWithString (textCell.title(), dict);
        textCell.setAttributedStringValue(attribStr);
        attribStr.release();
        dict.release();
    } else {
        textCell.setFont(font.handle);
        textCell.setTextColor(color);
        textCell.setAlignment (cast(NSTextAlignment)alignment);
    }
}

void outlineViewColumnDidMove (objc.id id, objc.SEL sel, objc.id aNotification) {
    NSNotification notification = new NSNotification (aNotification);
    NSDictionary userInfo = notification.userInfo ();
    cocoa.id nsOldIndex = userInfo.valueForKey (NSString.stringWith ("NSOldColumn")); //$NON-NLS-1$
    cocoa.id nsNewIndex = userInfo.valueForKey (NSString.stringWith ("NSNewColumn")); //$NON-NLS-1$
    int oldIndex = (new NSNumber (nsOldIndex)).intValue ();
    int newIndex = (new NSNumber (nsNewIndex)).intValue ();
    int startIndex = Math.min (oldIndex, newIndex);
    int endIndex = Math.max (oldIndex, newIndex);
    NSOutlineView outlineView = cast(NSOutlineView)view;
    NSArray nsColumns = outlineView.tableColumns ();
    for (int i = startIndex; i <= endIndex; i++) {
        cocoa.id columnId = nsColumns.objectAtIndex (i);
        TreeColumn column = getColumn (columnId);
        if (column !is null) {
            column.sendEvent (DWT.Move);
            if (isDisposed ()) return;
        }
    }
}

void outlineViewColumnDidResize (objc.id id, objc.SEL sel, objc.id aNotification) {
    NSNotification notification = new NSNotification (aNotification);
    NSDictionary userInfo = notification.userInfo ();
    cocoa.id columnId = userInfo.valueForKey (NSString.stringWith ("NSTableColumn")); //$NON-NLS-1$
    TreeColumn column = getColumn (columnId);
    if (column is null) return; /* either CHECK column or firstColumn in 0-column Tree */

    column.sendEvent (DWT.Resize);
    if (isDisposed ()) return;

    NSOutlineView outlineView = cast(NSOutlineView)view;
    int index = indexOf (column.nsColumn);
    if (index is -1) return; /* column was disposed in Resize callback */

    NSArray nsColumns = outlineView.tableColumns ();
    NSInteger columnCount = outlineView.numberOfColumns ();
    for (NSInteger i = index + 1; i < columnCount; i++) {
        columnId = nsColumns.objectAtIndex (i);
        column = getColumn (columnId);
        if (column !is null) {
            column.sendEvent (DWT.Move);
            if (isDisposed ()) return;
        }
    }
}

void outlineViewSelectionDidChange (objc.id id, objc.SEL sel, objc.id notification) {
    if (ignoreSelect) return;
    NSOutlineView widget = cast(NSOutlineView) view;
    NSInteger row = widget.selectedRow ();
    if (row is -1)
        postEvent (DWT.Selection);
    else {
        cocoa.id _id = widget.itemAtRow (row);
        TreeItem item = cast(TreeItem) display.getWidget (_id.id);
        Event event = new Event ();
        event.item = item;
        event.index = row;
        postEvent (DWT.Selection, event);
    }
}

void outlineView_setObjectValue_forTableColumn_byItem (objc.id id, objc.SEL sel, objc.id outlineView, objc.id object, objc.id tableColumn, objc.id itemID) {
    if (checkColumn !is null && tableColumn is checkColumn.id)  {
        TreeItem item = cast(TreeItem) display.getWidget (itemID);
        item.checked = !item.checked;
        Event event = new Event ();
        event.detail = DWT.CHECK;
        event.item = item;
        postEvent (DWT.Selection, event);
        item.redraw (-1);
    }
}

bool outlineView_writeItems_toPasteboard(objc.id id, objc.SEL sel, objc.id arg0, objc.id arg1, objc.id arg2) {
    return sendMouseEvent(NSApplication.sharedApplication().currentEvent(), DWT.DragDetect, true);
}

void register () {
    super.register ();
    display.addWidget (headerView, this);
    display.addWidget (dataCell, this);
    if (buttonCell !is null) display.addWidget (buttonCell, this);
}

void releaseChildren (bool destroy) {
    for (int i=0; i<items.length; i++) {
        TreeItem item = items [i];
        if (item !is null && !item.isDisposed ()) {
            item.release (false);
        }
    }
    items = null;
    if (columns !is null) {
        for (int i=0; i<columnCount; i++) {
            TreeColumn column = columns [i];
            if (column !is null && !column.isDisposed ()) {
                column.release (false);
            }
        }
        columns = null;
    }
    super.releaseChildren (destroy);
}

void releaseHandle () {
    super.releaseHandle ();
    if (headerView !is null) headerView.release ();
    headerView = null;
    if (firstColumn !is null) firstColumn.release ();
    firstColumn = null;
    if (checkColumn !is null) checkColumn.release ();
    checkColumn = null;
    if (dataCell !is null) dataCell.release ();
    dataCell = null;
    if (buttonCell !is null) buttonCell.release();
    buttonCell = null;
}

void releaseWidget () {
    super.releaseWidget ();
    sortColumn = null;
}

void reloadItem (TreeItem item, bool recurse) {
    if (getDrawing()) {
        NSOutlineView widget = cast(NSOutlineView)view;
        TreeItem[] selectedItems = getSelection ();
        if (item !is null) {
            widget.reloadItem (item.handle, recurse);
        } else {
            widget.reloadData ();
        }
        selectItems (selectedItems, true);
    } else {
        reloadPending = true;
    }
}

/**
 * Removes all of the items from the receiver.
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void removeAll () {
    checkWidget ();
    for (int i=0; i<items.length; i++) {
        TreeItem item = items [i];
        if (item !is null && !item.isDisposed ()) item.release (false);
    }
    items = new TreeItem [4];
    itemCount = 0;
    imageBounds = null;
    (cast(NSOutlineView) view).reloadData ();
    setScrollWidth ();
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the user changes the receiver's selection.
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
 * @see SelectionListener
 * @see #addSelectionListener
 */
public void removeSelectionListener (SelectionListener listener) {
    checkWidget ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    eventTable.unhook (DWT.Selection, listener);
    eventTable.unhook (DWT.DefaultSelection, listener);
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
 * @see TreeListener
 * @see #addTreeListener
 */
public void removeTreeListener (TreeListener listener) {
    checkWidget ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (DWT.Expand, listener);
    eventTable.unhook (DWT.Collapse, listener);
}

void setImage (objc.id id, objc.SEL sel, objc.id arg0) {
    OS.object_setInstanceVariable(id, Display.SWT_IMAGE, arg0);
}

/**
 * Display a mark indicating the point at which an item will be inserted.
 * The drop insert item has a visual hint to show where a dragged item
 * will be inserted when dropped on the tree.
 *
 * @param item the insert item.  Null will clear the insertion mark.
 * @param before true places the insert mark above 'item'. false places
 *  the insert mark below 'item'.
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the item has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setInsertMark (TreeItem item, bool before) {
    checkWidget ();
    if (item !is null && item.isDisposed()) error(DWT.ERROR_INVALID_ARGUMENT);
    TreeItem oldMark = insertItem;
    insertItem = item;
    insertBefore = before;
    if (oldMark !is null && !oldMark.isDisposed()) oldMark.redraw (-1);
    if (item !is null) item.redraw (-1);
}

/**
 * Selects all of the items in the receiver.
 * <p>
 * If the receiver is single-select, do nothing.
 * </p>
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void selectAll () {
    checkWidget ();
    if ((style & DWT.SINGLE) !is 0) return;
    checkItems ();
    NSOutlineView widget = cast(NSOutlineView) view;
    ignoreSelect = true;
    widget.selectAll (null);
    ignoreSelect = false;
}

/**
 * Selects an item in the receiver.  If the item was already
 * selected, it remains selected.
 *
 * @param item the item to be selected
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the item is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the item has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public void select (TreeItem item) {
    checkWidget ();
    if (item is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (item.isDisposed ()) error (DWT.ERROR_INVALID_ARGUMENT);
    checkItems ();
    showItem (item);
    NSOutlineView outlineView = cast(NSOutlineView) view;
    NSInteger row = outlineView.rowForItem (item.handle);
    NSIndexSet set = cast(NSIndexSet)(new NSIndexSet()).alloc();
    set = set.initWithIndex(row);
    ignoreSelect = true;
    outlineView.selectRowIndexes (set, false);
    ignoreSelect = false;
    set.release();
}

void sendDoubleSelection() {
    NSOutlineView outlineView = cast(NSOutlineView)view;
    NSInteger rowIndex = outlineView.clickedRow ();
    if (rowIndex !is -1) {
        if ((style & DWT.CHECK) !is 0) {
            NSArray columns = outlineView.tableColumns ();
            NSInteger columnIndex = outlineView.clickedColumn ();
            cocoa.id column = columns.objectAtIndex (columnIndex);
            if (column.id is checkColumn.id) return;
        }
        TreeItem item = cast(TreeItem) display.getWidget (outlineView.itemAtRow (rowIndex).id);
        Event event = new Event ();
        event.item = item;
        postEvent (DWT.DefaultSelection, event);
    }
}

bool sendKeyEvent (NSEvent nsEvent, int type) {
    bool result = super.sendKeyEvent (nsEvent, type);
    if (!result) return result;
    if (type !is DWT.KeyDown) return result;
    ushort keyCode = nsEvent.keyCode ();
    switch (keyCode) {
        case 76: /* KP Enter */
        case 36: { /* Return */
            postEvent (DWT.DefaultSelection);
            break;
        }
        default:
    }
    return result;
}

void sendMeasureItem (TreeItem item, int columnIndex, NSSize size) {
    NSOutlineView widget = cast(NSOutlineView)this.view;
    int contentWidth = cast(int)Math.ceil (size.width);
    NSSize spacing = widget.intercellSpacing();
    int itemHeight = cast(int)Math.ceil (widget.rowHeight() + spacing.height);
    GCData data = new GCData ();
    data.paintRectStruct = widget.frame ();
    data.paintRect = &data.paintRectStruct;
    GC gc = GC.cocoa_new (this, data);
    gc.setFont (item.getFont (columnIndex));
    Event event = new Event ();
    event.item = item;
    event.gc = gc;
    event.index = columnIndex;
    event.width = contentWidth;
    event.height = itemHeight;
    sendEvent (DWT.MeasureItem, event);
    gc.dispose ();
    if (!isDisposed () && !item.isDisposed ()) {
        size.width = event.width;
        size.height = event.height;
        if (itemHeight < event.height) {
            widget.setRowHeight (event.height);
        }
        if (contentWidth !is event.width) {
            if (columnCount is 0 && columnIndex is 0) {
                item.width = event.width;
                item.width += widget.indentationPerLevel () * (1 + widget.levelForItem (item.handle));
                if (setScrollWidth (item)) {
                    widget.setNeedsDisplay(true);
                }
            }
        }
    }
}

void selectItems (TreeItem[] items, bool ignoreDisposed) {
    NSOutlineView outlineView = cast(NSOutlineView) view;
    NSMutableIndexSet set = cast(NSMutableIndexSet) (new NSMutableIndexSet ()).alloc ().init ();
    int length = items.length;
    for (int i=0; i<length; i++) {
        if (items [i] !is null) {
            if (items [i].isDisposed ()) {
                if (ignoreDisposed) continue;
                error (DWT.ERROR_INVALID_ARGUMENT);
            }
            TreeItem item = items [i];
            if (!ignoreDisposed) showItem (items [i], false);
            set.addIndex (outlineView.rowForItem (item.handle));
        }
    }
    ignoreSelect = true;
    outlineView.selectRowIndexes (set, false);
    ignoreSelect = false;
    set.release();
}

NSRect titleRectForBounds (objc.id id, objc.SEL sel, NSRect cellFrame) {
    NSImage image = (new NSCell(id)).image();
    if (image !is null) {
        int imageWidth = imageBounds.width + IMAGE_GAP;
        cellFrame.x = cellFrame.x + imageWidth;
        cellFrame.width = cellFrame.width - imageWidth;
    }
    return cellFrame;
}

void updateBackground () {
    NSColor nsColor = null;
    if (backgroundImage !is null) {
        nsColor = NSColor.colorWithPatternImage(backgroundImage.handle);
    } else if (background !is null) {
        nsColor = NSColor.colorWithDeviceRed(background[0], background[1], background[2], background[3]);
    }
    ignoreSelect = true;
    NSOutlineView outlineView = cast(NSOutlineView)view;
    NSIndexSet set = cast(NSIndexSet)(new NSIndexSet()).alloc();
    outlineView.selectRowIndexes (set, false);
    ignoreSelect = false;
    set.release();
}

/**
 * Sets the order that the items in the receiver should
 * be displayed in to the given argument which is described
 * in terms of the zero-relative ordering of when the items
 * were added.
 *
 * @param order the new order to display the items
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the item order is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the item order is not the same length as the number of items</li>
 * </ul>
 *
 * @see Tree#getColumnOrder()
 * @see TreeColumn#getMoveable()
 * @see TreeColumn#setMoveable(bool)
 * @see DWT#Move
 *
 * @since 3.2
 */
public void setColumnOrder (int [] order) {
    checkWidget ();
    if (order is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (columnCount is 0) {
        if (order.length !is 0) error (DWT.ERROR_INVALID_ARGUMENT);
        return;
    }
    if (order.length !is columnCount) error (DWT.ERROR_INVALID_ARGUMENT);
    int [] oldOrder = getColumnOrder ();
    bool reorder = false;
    bool [] seen = new bool [columnCount];
    for (int i=0; i<order.length; i++) {
        int index = order [i];
        if (index < 0 || index >= columnCount) error (DWT.ERROR_INVALID_ARGUMENT);
        if (seen [index]) error (DWT.ERROR_INVALID_ARGUMENT);
        seen [index] = true;
        if (order [i] !is oldOrder [i]) reorder = true;
    }
    if (reorder) {
        NSOutlineView outlineView = cast(NSOutlineView)view;
        int [] oldX = new int [oldOrder.length];
        int check = (style & DWT.CHECK) !is 0 ? 1 : 0;
        for (int i=0; i<oldOrder.length; i++) {
            int index = oldOrder[i];
            oldX [index] = cast(int)outlineView.rectOfColumn (i + check).x;
        }
        int [] newX = new int [order.length];
        for (int i=0; i<order.length; i++) {
            int index = order [i];
            TreeColumn column = columns[index];
            int oldIndex = indexOf (column.nsColumn);
            int newIndex = i + check;
            outlineView.moveColumn (oldIndex, newIndex);
            newX [index] = cast(int)outlineView.rectOfColumn (newIndex).x;
        }

        TreeColumn[] newColumns = new TreeColumn [columnCount];
        System.arraycopy (columns, 0, newColumns, 0, columnCount);
        for (int i=0; i<columnCount; i++) {
            TreeColumn column = newColumns [i];
            if (!column.isDisposed ()) {
                if (newX [i] !is oldX [i]) {
                    column.sendEvent (DWT.Move);
                }
            }
        }
    }
}

void setFont (NSFont font) {
    super.setFont (font);
    setItemHeight (null, font, !hooks (DWT.MeasureItem));
    view.setNeedsDisplay (true);
    clearCachedWidth (items);
    setScrollWidth ();
}

/**
 * Marks the receiver's header as visible if the argument is <code>true</code>,
 * and marks it invisible otherwise.
 * <p>
 * If one of the receiver's ancestors is not visible or some
 * other condition makes the receiver not visible, marking
 * it visible may not actually cause it to be displayed.
 * </p>
 *
 * @param show the new visibility state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public void setHeaderVisible (bool show) {
    checkWidget ();
    (cast(NSOutlineView) view).setHeaderView (show ? headerView : null);
}

/**
 * Sets the number of root-level items contained in the receiver.
 *
 * @param count the number of items
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.2
 */
public void setItemCount (int count) {
    checkWidget ();
    checkItems ();
    count = Math.max (0, count);
    setItemCount (null, count);
}

void setItemCount (TreeItem parentItem, int count) {
    int itemCount = getItemCount (parentItem);
    if (count is itemCount) return;
    NSOutlineView widget = cast(NSOutlineView) view;
    int length = Math.max (4, (count + 3) / 4 * 4);
    TreeItem [] children = parentItem is null ? items : parentItem.items;
    bool expanded = parentItem is null || parentItem.getExpanded();
    if (count < itemCount) {
        /*
        * Note that the item count has to be updated before the call to reloadItem(), but
        * the items have to be released after.
        */
        if (parentItem is null) {
            this.itemCount = count;
        } else {
            parentItem.itemCount = count;
        }
        /*
        * Bug in Cocoa.  When removing selected items from an NSOutlineView, the selection
        * is not properly updated.  The fix is to ensure that the item and its subitems
        * are deselected before the item is removed by the reloadItem call.
        */
        if (expanded) {
            for (int index = count; index < itemCount; index ++) {
                TreeItem item = children [index];
                if (item !is null && !item.isDisposed ()) item.clearSelection ();
            }
        }
        TreeItem[] selectedItems = getSelection ();
        widget.reloadItem (parentItem !is null ? parentItem.handle : null, expanded);
        selectItems (selectedItems, true);
        for (int index = count; index < itemCount; index ++) {
            TreeItem item = children [index];
            if (item !is null && !item.isDisposed()) item.release (false);
        }
        TreeItem [] newItems = new TreeItem [length];
        if (children !is null) {
            System.arraycopy (children, 0, newItems, 0, count);
        }
        children = newItems;
        if (parentItem is null) {
            this.items = newItems;
        } else {
            parentItem.items = newItems;
        }
    } else {
        if ((style & DWT.VIRTUAL) is 0) {
            for (int i=itemCount; i<count; i++) {
                new TreeItem (this, parentItem, DWT.NONE, i, true);
            }
        } else {
            TreeItem [] newItems = new TreeItem [length];
            if (children !is null) {
                System.arraycopy (children, 0, newItems, 0, itemCount);
            }
            children = newItems;
            if (parentItem is null) {
                this.items = newItems;
                this.itemCount = count;
            } else {
                parentItem.items = newItems;
                parentItem.itemCount = count;
            }
            TreeItem[] selectedItems = getSelection ();
            widget.reloadItem (parentItem !is null ? parentItem.handle : null, expanded);
            selectItems (selectedItems, true);

            if (parentItem !is null && itemCount is 0 && parentItem.expanded) {
                ignoreExpand = true;
                widget.expandItem (parentItem.handle);
                ignoreExpand = false;
            }
        }
    }
}

/*public*/ void setItemHeight (int itemHeight) {
    checkWidget ();
    if (itemHeight < -1) error (DWT.ERROR_INVALID_ARGUMENT);
    if (itemHeight is -1) {
        setItemHeight (null, null, true);
    } else {
        (cast(NSOutlineView)view).setRowHeight (itemHeight);
    }
}

void setItemHeight (Image image, NSFont font, bool set) {
    if (font is null) font = getFont ().handle;
    Cocoa.CGFloat ascent = font.ascender ();
    Cocoa.CGFloat descent = -font.descender () + font.leading ();
    int height = cast(int)Math.ceil (ascent + descent) + 1;
    Rectangle bounds = image !is null ? image.getBounds () : imageBounds;
    if (bounds !is null) {
        imageBounds = bounds;
        height = Math.max (height, bounds.height);
    }
    NSTableView widget = cast(NSTableView)view;
    if (set || widget.rowHeight () < height) {
        widget.setRowHeight (height);
    }
}

/**
 * Marks the receiver's lines as visible if the argument is <code>true</code>,
 * and marks it invisible otherwise. Note that some platforms draw
 * grid lines while others may draw alternating row colors.
 * <p>
 * If one of the receiver's ancestors is not visible or some
 * other condition makes the receiver not visible, marking
 * it visible may not actually cause it to be displayed.
 * </p>
 *
 * @param show the new visibility state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public void setLinesVisible (bool show) {
    checkWidget ();
    (cast(NSOutlineView) view).setUsesAlternatingRowBackgroundColors (show);
}

public void setRedraw (bool redraw) {
    checkWidget ();
    super.setRedraw (redraw);
    if (redraw && drawCount is 0) {
        checkItems ();
        setScrollWidth ();
    }
}

bool setScrollWidth () {
    return setScrollWidth (true, items, true);
}

bool setScrollWidth (bool set, TreeItem[] items, bool recurse) {
    if (items is null) return false;
    if (ignoreRedraw || !getDrawing()) return false;
    if (columnCount !is 0) return false;
    GC gc = new GC (this);
    int newWidth = calculateWidth (items, 0, gc, recurse);
    gc.dispose ();
    if (!set) {
        int oldWidth = cast(int)firstColumn.width ();
        if (oldWidth >= newWidth) return false;
    }
    firstColumn.setWidth (newWidth);
    if (horizontalBar !is null && horizontalBar.view !is null) redrawWidget (horizontalBar.view, false);
    return true;
}

bool setScrollWidth (TreeItem item) {
    if (ignoreRedraw || !getDrawing()) return false;
    if (columnCount !is 0) return false;
    TreeItem parentItem = item.parentItem;
    if (parentItem !is null && !parentItem.getExpanded ()) return false;
    GC gc = new GC (this);
    int newWidth = item.calculateWidth (0, gc);
    gc.dispose ();
    int oldWidth = cast(int)firstColumn.width ();
    if (oldWidth < newWidth) {
        firstColumn.setWidth (newWidth);
        if (horizontalBar !is null && horizontalBar.view !is null) redrawWidget (horizontalBar.view, false);
        return true;
    }
    return false;
}

/**
 * Sets the receiver's selection to the given item.
 * The current selection is cleared before the new item is selected.
 * <p>
 * If the item is not in the receiver, then it is ignored.
 * </p>
 *
 * @param item the item to select
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the item is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the item has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.2
 */
public void setSelection (TreeItem item) {
    checkWidget ();
    if (item is null) error (DWT.ERROR_NULL_ARGUMENT);
    setSelection ([item]);
}

/**
 * Sets the receiver's selection to be the given array of items.
 * The current selection is cleared before the new items are selected.
 * <p>
 * Items that are not in the receiver are ignored.
 * If the receiver is single-select and multiple items are specified,
 * then all items are ignored.
 * </p>
 *
 * @param items the array of items
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the array of items is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if one of the items has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Tree#deselectAll()
 */
public void setSelection (TreeItem [] items) {
    checkWidget ();
    if (items is null) error (DWT.ERROR_NULL_ARGUMENT);
    checkItems ();
    deselectAll ();
    int length = items.length;
    if (length is 0 || ((style & DWT.SINGLE) !is 0 && length > 1)) return;
    selectItems (items, false);
    if (items.length > 0) {
        for (int i = 0; i < items.length; i++) {
            TreeItem item = items[i];
            if (item !is null) {
                showItem(item, true);
                break;
            }
        }
    }
}

void setSmallSize () {
    if (checkColumn is null) return;
    checkColumn.dataCell ().setControlSize (OS.NSSmallControlSize);
    checkColumn.setWidth (getCheckColumnWidth ());
}

/**
 * Sets the column used by the sort indicator for the receiver. A null
 * value will clear the sort indicator.  The current sort column is cleared
 * before the new column is set.
 *
 * @param column the column used by the sort indicator or <code>null</code>
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the column is disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.2
 */
public void setSortColumn (TreeColumn column) {
    checkWidget ();
    if (column !is null && column.isDisposed ()) error (DWT.ERROR_INVALID_ARGUMENT);
    if (column is sortColumn) return;
    sortColumn = column;
    (cast(NSOutlineView)view).setHighlightedTableColumn (column is null ? null : column.nsColumn);
}

/**
 * Sets the direction of the sort indicator for the receiver. The value
 * can be one of <code>UP</code>, <code>DOWN</code> or <code>NONE</code>.
 *
 * @param direction the direction of the sort indicator
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.2
 */
public void setSortDirection  (int direction) {
    checkWidget ();
    if (direction !is DWT.UP && direction !is DWT.DOWN && direction !is DWT.NONE) return;
    if (direction is sortDirection) return;
    sortDirection = direction;
    if (sortColumn is null) return;
    NSTableHeaderView headerView = (cast(NSOutlineView)view).headerView ();
    if (headerView is null) return;
    int index = indexOf (sortColumn.nsColumn);
    NSRect rect = headerView.headerRectOfColumn (index);
    headerView.setNeedsDisplayInRect (rect);
}

/**
 * Sets the item which is currently at the top of the receiver.
 * This item can change when items are expanded, collapsed, scrolled
 * or new items are added or removed.
 *
 * @param item the item to be shown
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the item is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the item has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Tree#getTopItem()
 *
 * @since 2.1
 */
public void setTopItem (TreeItem item) {
    checkWidget();
    if (item is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (item.isDisposed ()) error (DWT.ERROR_INVALID_ARGUMENT);
    checkItems ();
    showItem (item, false);
    NSOutlineView widget = cast(NSOutlineView) view;
    NSInteger row = widget.rowForItem (item.handle);
    if (row is -1) return;
    NSPoint pt = NSPoint();
    pt.x = scrollView.contentView().bounds().x;
    pt.y = widget.frameOfCellAtColumn(0, row).y;
    view.scrollPoint(pt);
}

/**
 * Shows the column.  If the column is already showing in the receiver,
 * this method simply returns.  Otherwise, the columns are scrolled until
 * the column is visible.
 *
 * @param column the column to be shown
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the item is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the item has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public void showColumn (TreeColumn column) {
    checkWidget ();
    if (column is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (column.isDisposed()) error (DWT.ERROR_INVALID_ARGUMENT);
    if (column.parent !is this) return;
    if (columnCount <= 1) return;
    int index = indexOf (column.nsColumn);
    if (!(0 <= index && index < columnCount + ((style & DWT.CHECK) !is 0 ? 1 : 0))) return;
    (cast(NSOutlineView)view).scrollColumnToVisible (index);
}

/**
 * Shows the item.  If the item is already showing in the receiver,
 * this method simply returns.  Otherwise, the items are scrolled
 * and expanded until the item is visible.
 *
 * @param item the item to be shown
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the item is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the item has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Tree#showSelection()
 */
public void showItem (TreeItem item) {
    checkWidget ();
    if (item is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (item.isDisposed ()) error (DWT.ERROR_INVALID_ARGUMENT);
    checkItems ();
    showItem (item, true);
}

void showItem (TreeItem item, bool scroll) {
    TreeItem parentItem = item.parentItem;
    if (parentItem !is null) {
        showItem (parentItem, false);
        parentItem.setExpanded (true);
    }
    if (scroll) {
        NSOutlineView outlineView = cast(NSOutlineView) view;
        outlineView.scrollRowToVisible (outlineView.rowForItem (item.handle));
    }
}

/**
 * Shows the selection.  If the selection is already showing in the receiver,
 * this method simply returns.  Otherwise, the items are scrolled until
 * the selection is visible.
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Tree#showItem(TreeItem)
 */
public void showSelection () {
    checkWidget ();
    checkItems ();
    //TODO - optimize
    TreeItem [] selection = getSelection ();
    if (selection.length > 0) {
        checkData(selection [0]);
        showItem (selection [0], true);
    }
}

void updateCursorRects (bool enabled) {
    updateCursorRects (enabled);
    if (headerView is null) return;
    updateCursorRects (enabled, cast(NSTableHeaderView)headerView);
}

}

