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
module dwt.widgets.TreeItem;

import dwt.dwthelper.utils;







import dwt.internal.objc.cocoa.Cocoa;
import dwt.widgets.Event;
import dwt.widgets.Item;
import dwt.widgets.Tree;
import dwt.widgets.TreeColumn;

/**
 * Instances of this class represent a selectable user interface object
 * that represents a hierarchy of tree items in a tree widget.
 *
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>(none)</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
 * </dl>
 * <p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#tree">Tree, TreeItem, TreeColumn snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 * @noextend This class is not intended to be subclassed by clients.
 */
public class TreeItem : Item {
    Tree parent;
    TreeItem parentItem;
    TreeItem[] items;
    int itemCount;
    String [] strings;
    Image [] images;
    bool checked, grayed, cached, expanded;
    Color foreground, background;
    Color [] cellForeground, cellBackground;
    Font font;
    Font [] cellFont;
    int width = -1;
    /**
     * the handle to the OS resource
     * (Warning: This field is platform dependent)
     * <p>
     * <b>IMPORTANT:</b> This field is <em>not</em> part of the DWT
     * public API. It is marked public only so that it can be shared
     * within the packages provided by DWT. It is not available on all
     * platforms and should never be accessed from application code.
     * </p>
     */
    public SWTTreeItem handle;

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>Tree</code> or a <code>TreeItem</code>)
 * and a style value describing its behavior and appearance.
 * The item is added to the end of the items maintained by its parent.
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
 * @param parent a tree control which will be the parent of the new instance (cannot be null)
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
 * @see DWT
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Tree parent, int style) {
    this (checkNull (parent), null, style, -1, true);
}

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>Tree</code> or a <code>TreeItem</code>),
 * a style value describing its behavior and appearance, and the index
 * at which to place it in the items maintained by its parent.
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
 * @param parent a tree control which will be the parent of the new instance (cannot be null)
 * @param style the style of control to construct
 * @param index the zero-relative index to store the receiver in its parent
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 *    <li>ERROR_INVALID_RANGE - if the index is not between 0 and the number of elements in the parent (inclusive)</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see DWT
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Tree parent, int style, int index) {
    this (checkNull (parent), null, style, checkIndex (index), true);
}

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>Tree</code> or a <code>TreeItem</code>)
 * and a style value describing its behavior and appearance.
 * The item is added to the end of the items maintained by its parent.
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
 * @param parentItem a tree control which will be the parent of the new instance (cannot be null)
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
 * @see DWT
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (TreeItem parentItem, int style) {
    this (checkNull (parentItem).parent, parentItem, style, -1, true);
}

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>Tree</code> or a <code>TreeItem</code>),
 * a style value describing its behavior and appearance, and the index
 * at which to place it in the items maintained by its parent.
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
 * @param parentItem a tree control which will be the parent of the new instance (cannot be null)
 * @param style the style of control to construct
 * @param index the zero-relative index to store the receiver in its parent
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 *    <li>ERROR_INVALID_RANGE - if the index is not between 0 and the number of elements in the parent (inclusive)</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see DWT
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (TreeItem parentItem, int style, int index) {
    this (checkNull (parentItem).parent, parentItem, style, checkIndex (index), true);
}

this (Tree parent, TreeItem parentItem, int style, int index, bool create) {
    super (parent, style);
    this.parent = parent;
    this.parentItem = parentItem;
    if (create) {
        parent.createItem (this, parentItem, index);
    } else {
        handle = cast(SWTTreeItem) (new SWTTreeItem ()).alloc ().init ();
        createJNIRef ();
        register ();
        items = new TreeItem[4];
    }
}

static TreeItem checkNull (TreeItem item) {
    if (item is null) DWT.error (DWT.ERROR_NULL_ARGUMENT);
    return item;
}

static Tree checkNull (Tree parent) {
    if (parent is null) DWT.error (DWT.ERROR_NULL_ARGUMENT);
    return parent;
}

static int checkIndex (int index) {
    if (index < 0) DWT.error (DWT.ERROR_INVALID_RANGE);
    return index;
}

int calculateWidth (int index, GC gc) {
    if (index is 0 && width !is -1) return width;
    Font font = null;
    if (cellFont !is null) font = cellFont[index];
    if (font is null) font = this.font;
    if (font is null) font = parent.font;
    if (font is null) font = parent.defaultFont();
    String text = index is 0 ? this.text : (strings is null ? "" : strings [index]);
    Image image = index is 0 ? this.image : (images is null ? null : images [index]);
    NSCell cell = parent.dataCell;
    if (font.extraTraits !is 0) {
        NSAttributedString attribStr = parent.createString(text, font, null, 0, true, false);
        cell.setAttributedStringValue(attribStr);
        attribStr.release();
    } else {
        cell.setFont (font.handle);
        cell.setTitle (NSString.stringWith(text !is null ? text : ""));
    }

    /* This code is inlined for performance */
    objc_super super_struct = objc_super();
    super_struct.receiver = cell.id;
    super_struct.super_class = OS.objc_msgSend(cell.id, OS.sel_superclass);
    NSSize size = new NSSize();
    OS.objc_msgSendSuper_stret(size, super_struct, OS.sel_cellSize);
    if (image !is null) size.width += parent.imageBounds.width + Table.IMAGE_GAP;
//  cell.setImage (image !is null ? image.handle : null);
//  NSSize size = cell.cellSize ();

    int width = (int)Math.ceil (size.width);
    bool sendMeasure = true;
    if ((parent.style & DWT.VIRTUAL) !is 0) {
        sendMeasure = cached;
    }
    if (sendMeasure && parent.hooks (DWT.MeasureItem)) {
        gc.setFont (font);
        Event event = new Event ();
        event.item = this;
        event.index = index;
        event.gc = gc;
        NSTableView widget = (NSTableView)parent.view;
        int height = (int)widget.rowHeight ();
        event.width = width;
        event.height = height;
        parent.sendEvent (DWT.MeasureItem, event);
        if (height < event.height) {
            widget.setRowHeight (event.height);
            widget.setNeedsDisplay (true);
        }
        width = event.width;
    }
    if (index is 0) {
        NSOutlineView outlineView = cast(NSOutlineView)parent.view;
        width += outlineView.indentationPerLevel () * (1 + outlineView.levelForItem (handle));
        this.width = width;
    }
    return width;
}

protected void checkSubclass () {
    if (!isValidSubclass ()) error (DWT.ERROR_INVALID_SUBCLASS);
}

void clear () {
    cached = false;
    text = "";
    image = null;
    strings = null;
    images = null;
    checked = grayed = false;
    foreground = background = null;
    cellForeground = cellBackground = null;
    font = null;
    cellFont = null;
    width = -1;
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
    if (index < 0 || index >= count)
        DWT.error (DWT.ERROR_INVALID_RANGE);
    parent.clear (this, index, all);
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
    parent.clearAll (this, all);
}

void clearSelection () {
    NSOutlineView widget = (NSOutlineView) parent.view;
    int /*long*/ row = widget.rowForItem (handle);
    if (widget.isRowSelected(row)) widget.deselectRow (row);
    if (items !is null && getExpanded ()) {
        for (int i = 0; i < items.length; i++) {
            TreeItem item = items [i];
            if (item !is null && !item.isDisposed ()) item.clearSelection ();
        }
    }
}

NSObject createString(int index) {
    String text = index is 0 ? this.text : (strings is null ? "" : strings [index]);
    return NSString.stringWith(text !is null ? text : "");
}

void deregister () {
    super.deregister ();
    display.removeWidget (handle);
}

void destroyWidget () {
    parent.destroyItem (this);
    releaseHandle ();
}

/**
 * Returns the receiver's background color.
 *
 * @return the background color
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.0
 *
 */
public Color getBackground () {
    checkWidget ();
    if (!parent.checkData (this)) error (DWT.ERROR_WIDGET_DISPOSED);
    return background !is null ? background : parent.getBackground ();
}

/**
 * Returns the background color at the given column index in the receiver.
 *
 * @param index the column index
 * @return the background color
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public Color getBackground (int index) {
    checkWidget ();
    if (!parent.checkData (this)) error (DWT.ERROR_WIDGET_DISPOSED);
    int count = Math.max (1, parent.columnCount);
    if (0 > index || index > count -1) return getBackground ();
    if (cellBackground is null || cellBackground [index] is null) return getBackground ();
    return cellBackground [index];
}

/**
 * Returns a rectangle describing the receiver's size and location
 * relative to its parent.
 *
 * @return the receiver's bounding rectangle
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Rectangle getBounds () {
    checkWidget ();
    if (!parent.checkData (this)) error (DWT.ERROR_WIDGET_DISPOSED);
    parent.checkItems ();
    NSRect rect = outlineView.rectOfRow (outlineView.rowForItem (handle));
    return new Rectangle(cast(int) rect.x, cast(int) rect.y, cast(int) rect.width, cast(int) rect.height);
}

/**
 * Returns a rectangle describing the receiver's size and location
 * relative to its parent at a column in the tree.
 *
 * @param index the index that specifies the column
 * @return the receiver's bounding column rectangle
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public Rectangle getBounds (int index) {
    checkWidget ();
    if (!parent.checkData (this)) error (DWT.ERROR_WIDGET_DISPOSED);
    if (!(0 <= index && index < Math.max (1, parent.columnCount))) return new Rectangle (0, 0, 0, 0);

    parent.checkItems ();
    if (parent.columnCount is 0) {
        index = (parent.style & DWT.CHECK) !is 0 ? 1 : 0;
    } else {
        TreeColumn column = parent.getColumn (index);
        index = parent.indexOf (column.nsColumn);
    }
    NSRect rect = outlineView.frameOfCellAtColumn (index, outlineView.rowForItem (handle));
    return new Rectangle (cast(int) rect.x, cast(int) rect.y, cast(int) rect.width, cast(int) rect.height);
}

/**
 * Returns <code>true</code> if the receiver is checked,
 * and false otherwise.  When the parent does not have
 * the <code>CHECK style, return false.
 * <p>
 *
 * @return the checked state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool getChecked () {
    checkWidget ();
    if (!parent.checkData (this)) error (DWT.ERROR_WIDGET_DISPOSED);
    if ((parent.style & DWT.CHECK) is 0) return false;
    return checked;
}

/**
 * Returns <code>true</code> if the receiver is expanded,
 * and false otherwise.
 * <p>
 *
 * @return the expanded state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool getExpanded () {
    checkWidget ();
    return expanded;
}

/**
 * Returns the font that the receiver will use to paint textual information for this item.
 *
 * @return the receiver's font
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public Font getFont () {
    checkWidget ();
    if (!parent.checkData (this)) error (DWT.ERROR_WIDGET_DISPOSED);
    return font !is null ? font : parent.getFont ();
}

/**
 * Returns the font that the receiver will use to paint textual information
 * for the specified cell in this item.
 *
 * @param index the column index
 * @return the receiver's font
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public Font getFont (int index) {
    checkWidget ();
    if (!parent.checkData (this)) error (DWT.ERROR_WIDGET_DISPOSED);
    int count = Math.max (1, parent.columnCount);
    if (0 > index || index > count -1) return getFont ();
    if (cellFont is null || cellFont [index] is null) return getFont ();
    return cellFont [index];
}

/**
 * Returns the foreground color that the receiver will use to draw.
 *
 * @return the receiver's foreground color
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.0
 *
 */
public Color getForeground () {
    checkWidget ();
    if (!parent.checkData (this)) error (DWT.ERROR_WIDGET_DISPOSED);
    return foreground !is null ? foreground : parent.getForeground ();
}

/**
 *
 * Returns the foreground color at the given column index in the receiver.
 *
 * @param index the column index
 * @return the foreground color
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public Color getForeground (int index) {
    checkWidget ();
    if (!parent.checkData (this)) error (DWT.ERROR_WIDGET_DISPOSED);
    int count = Math.max (1, parent.columnCount);
    if (0 > index || index > count -1) return getForeground ();
    if (cellForeground is null || cellForeground [index] is null) return getForeground ();
    return cellForeground [index];
}

/**
 * Returns <code>true</code> if the receiver is grayed,
 * and false otherwise. When the parent does not have
 * the <code>CHECK style, return false.
 * <p>
 *
 * @return the grayed state of the checkbox
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool getGrayed () {
    checkWidget ();
    if (!parent.checkData (this)) error (DWT.ERROR_WIDGET_DISPOSED);
    if ((parent.style & DWT.CHECK) is 0) return false;
    return grayed;
}

public Image getImage () {
    checkWidget ();
    if (!parent.checkData (this)) error (DWT.ERROR_WIDGET_DISPOSED);
    return super.getImage ();
}

/**
 * Returns the image stored at the given column index in the receiver,
 * or null if the image has not been set or if the column does not exist.
 *
 * @param index the column index
 * @return the image stored at the given column index in the receiver
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public Image getImage (int index) {
    checkWidget ();
    if (!parent.checkData (this)) error (DWT.ERROR_WIDGET_DISPOSED);
    if (index is 0) return getImage ();
    if (images !is null) {
        if (0 <= index && index < images.length) return images [index];
    }
    return null;
}

/**
 * Returns a rectangle describing the size and location
 * relative to its parent of an image at a column in the
 * tree.
 *
 * @param index the index that specifies the column
 * @return the receiver's bounding image rectangle
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public Rectangle getImageBounds (int index) {
    checkWidget ();
    if (!parent.checkData (this)) error (DWT.ERROR_WIDGET_DISPOSED);
    if (!(0 <= index && index < Math.max (1, parent.columnCount))) return new Rectangle (0, 0, 0, 0);

    parent.checkItems ();
    Image image = index is 0 ? this.image : (images !is null) ? images [index] : null;
    if (parent.columnCount is 0) {
        index = (parent.style & DWT.CHECK) !is 0 ? 1 : 0;
    } else {
        TreeColumn column = parent.getColumn (index);
        index = parent.indexOf (column.nsColumn);
    }
    NSRect rect = outlineView.frameOfCellAtColumn (index, outlineView.rowForItem (handle));
    rect.x += Tree.IMAGE_GAP;
    if (image !is null) {
        rect.width = parent.imageBounds.width;
    } else {
        rect.width = 0;
    }
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
    if (index < 0) error (DWT.ERROR_INVALID_RANGE);
    if (!parent.checkData (this)) error (DWT.ERROR_WIDGET_DISPOSED);
    if (index >= itemCount) error (DWT.ERROR_INVALID_RANGE);
    return parent._getItem (this, index, true);
}

/**
 * Returns the number of items contained in the receiver
 * that are direct item children of the receiver.
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
    if (!parent.checkData (this)) error (DWT.ERROR_WIDGET_DISPOSED);
    return itemCount;
}

/**
 * Returns a (possibly empty) array of <code>TreeItem</code>s which
 * are the direct item children of the receiver.
 * <p>
 * Note: This is not the actual structure used by the receiver
 * to maintain its list of items, so modifying the array will
 * not affect the receiver.
 * </p>
 *
 * @return the receiver's items
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public TreeItem [] getItems () {
    checkWidget ();
    if (!parent.checkData (this)) error (DWT.ERROR_WIDGET_DISPOSED);
    TreeItem [] result = new TreeItem [itemCount];
    for (int i=0; i<itemCount; i++) {
        result [i] = parent._getItem (this, i, true);
    }
    return result;
}

String getNameText () {
    if ((parent.style & DWT.VIRTUAL) !is 0) {
        if (!cached) return "*virtual*"; //$NON-NLS-1$
    }
    return super.getNameText ();
}

/**
 * Returns the receiver's parent, which must be a <code>Tree</code>.
 *
 * @return the receiver's parent
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Tree getParent () {
    checkWidget ();
    return parent;
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
    return parentItem;
}

public String getText () {
    checkWidget ();
    if (!parent.checkData (this)) error (DWT.ERROR_WIDGET_DISPOSED);
    return super.getText ();
}

/**
 * Returns the text stored at the given column index in the receiver,
 * or empty string if the text has not been set.
 *
 * @param index the column index
 * @return the text stored at the given column index in the receiver
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public String getText (int index) {
    checkWidget ();
    if (!parent.checkData (this)) error (DWT.ERROR_WIDGET_DISPOSED);
    if (index is 0) return getText ();
    if (strings !is null) {
        if (0 <= index && index < strings.length) {
            String string = strings [index];
            return string !is null ? string : "";
        }
    }
    return "";
}

/**
 * Returns a rectangle describing the size and location
 * relative to its parent of the text at a column in the
 * tree.
 *
 * @param index the index that specifies the column
 * @return the receiver's bounding text rectangle
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.3
 */
public Rectangle getTextBounds (int index) {
    checkWidget ();
    if (!parent.checkData (this)) error (DWT.ERROR_WIDGET_DISPOSED);
    if (!(0 <= index && index < Math.max (1, parent.columnCount))) return new Rectangle (0, 0, 0, 0);

    parent.checkItems ();
    Image image = index is 0 ? this.image : (images !is null) ? images [index] : null;
    if (parent.columnCount is 0) {
        index = (parent.style & DWT.CHECK) !is 0 ? 1 : 0;
    } else {
        TreeColumn column = parent.getColumn (index);
        index = parent.indexOf (column.nsColumn);
    }
    NSRect rect = outlineView.frameOfCellAtColumn (index, outlineView.rowForItem (handle));
    rect.x += Tree.TEXT_GAP;
    rect.width -= Tree.TEXT_GAP;
    if (image !is null) {
        int offset = parent.imageBounds.width + Tree.IMAGE_GAP;
        rect.x += offset;
        rect.width -= offset;
    }
    return new Rectangle(cast(int) rect.x, cast(int) rect.y, cast(int) rect.width, cast(int) rect.height);
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
    if (item.parentItem !is this) return -1;
    for (int i = 0; i < itemCount; i++) {
        if (item is items [i]) return i;
    }
    return -1;
}

void redraw (int columnIndex) {
    if (parent.ignoreRedraw || !isDrawing()) return;
    /* redraw the full item if columnIndex is -1 */
    NSOutlineView outlineView = (NSOutlineView) parent.view;
    NSRect rect;
    if (columnIndex is -1 || parent.hooks (DWT.MeasureItem) || parent.hooks (DWT.EraseItem) || parent.hooks (DWT.PaintItem)) {
        rect = outlineView.rectOfRow (outlineView.rowForItem (handle));
    } else {
        int index;
        if (parent.columnCount is 0) {
            index = (parent.style & DWT.CHECK) !is 0 ? 1 : 0;
        } else {
            if (0 <= columnIndex && columnIndex < parent.columnCount) {
                index = parent.indexOf (parent.columns[columnIndex].nsColumn);
            } else {
                return;
            }
        }
        rect = outlineView.frameOfCellAtColumn (index, outlineView.rowForItem (handle));
    }
    outlineView.setNeedsDisplayInRect (rect);
}

void register () {
    super.register ();
    display.addWidget (handle, this);
}

void release(bool destroy) {
    /*
    * Bug in Cocoa.  When removing selected items from an NSOutlineView, the selection
    * is not properly updated.  The fix is to ensure that the item and its subitems
    * are deselected before the item is removed by the reloadItem call.
    *
    * This has to be done in release to avoid traversing the tree twice when items are
    * removed from the tree by setItemCount.
    */
    if (destroy) clearSelection ();
    super.release(destroy);
}

void releaseChildren (bool destroy) {
    for (int i=0; i<items.length; i++) {
        TreeItem item = items [i];
        if (item !is null && !item.isDisposed ()) {
            item.release (false);
        }
    }
    items = null;
    itemCount = 0;
    super.releaseChildren (destroy);
}

void releaseHandle () {
    super.releaseHandle ();
    if (handle !is null) handle.release ();
    handle = null;
    parentItem = null;
    parent = null;
}

void releaseWidget () {
    super.releaseWidget ();
    strings = null;
    images = null;
    background = foreground = null;
    font = null;
    cellBackground = cellForeground = null;
    cellFont = null;
}

/**
 * Removes all of the items from the receiver.
 * <p>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public void removeAll () {
    checkWidget ();
    parent.setItemCount (0);
}

void sendExpand (bool expand, bool recurse) {
    if (itemCount is 0) return;
    if (expanded !is expand) {
        Event event = new Event ();
        event.item = this;
        parent.sendEvent (expand ? DWT.Expand : DWT.Collapse, event);
        if (isDisposed ()) return;
        expanded = expand;
    }
    if (recurse) {
        for (int i = 0; i < itemCount; i++) {
            if (items[i] !is null) items[i].sendExpand (expand, recurse);
        }
    }
}

/**
 * Sets the receiver's background color to the color specified
 * by the argument, or to the default system color for the item
 * if the argument is null.
 *
 * @param color the new color (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.0
 *
 */
public void setBackground (Color color) {
    checkWidget ();
    if (color !is null && color.isDisposed ()) {
        DWT.error (DWT.ERROR_INVALID_ARGUMENT);
    }
    Color oldColor = background;
    if (oldColor is color) return;
    background = color;
    if (oldColor !is null && oldColor.equals (color)) return;
    cached = true;
    redraw (-1);
}

/**
 * Sets the background color at the given column index in the receiver
 * to the color specified by the argument, or to the default system color for the item
 * if the argument is null.
 *
 * @param index the column index
 * @param color the new color (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 *
 */
public void setBackground (int index, Color color) {
    checkWidget ();
    if (color !is null && color.isDisposed ()) {
        DWT.error (DWT.ERROR_INVALID_ARGUMENT);
    }
    int count = Math.max (1, parent.columnCount);
    if (0 > index || index > count - 1) return;
    if (cellBackground is null) {
        if (color is null) return;
        cellBackground = new Color [count];
    }
    Color oldColor = cellBackground [index];
    if (oldColor is color) return;
    cellBackground [index] = color;
    if (oldColor !is null && oldColor.equals (color)) return;
    cached = true;
    redraw (index);
}

/**
 * Sets the checked state of the receiver.
 * <p>
 *
 * @param checked the new checked state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setChecked (bool checked) {
    checkWidget ();
    if ((parent.style & DWT.CHECK) is 0) return;
    if (this.checked is checked) return;
    this.checked = checked;
    cached = true;
    redraw (-1);
}

/**
 * Sets the expanded state of the receiver.
 * <p>
 *
 * @param expanded the new expanded state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setExpanded (bool expanded) {
    checkWidget ();

    /* Do nothing when the item is a leaf or already expanded */
    if (itemCount is 0 || expanded is getExpanded ()) return;

    parent.checkItems ();
    parent.ignoreExpand = true;
    this.expanded = expanded;
    if (expanded) {
        (cast(NSOutlineView) parent.view).expandItem (handle);
    } else {
        (cast(NSOutlineView) parent.view).collapseItem (handle);
    }
    parent.ignoreExpand = false;
    cached = true;
    if (!expanded) {
        parent.setScrollWidth ();
    }
}

/**
 * Sets the font that the receiver will use to paint textual information
 * for this item to the font specified by the argument, or to the default font
 * for that kind of control if the argument is null.
 *
 * @param font the new font (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public void setFont (Font font) {
    checkWidget ();
    if (font !is null && font.isDisposed ()) {
        DWT.error (DWT.ERROR_INVALID_ARGUMENT);
    }
    Font oldFont = this.font;
    if (oldFont is font) return;
    this.font = font;
    if (oldFont !is null && oldFont.equals (font)) return;
    width = -1;
    cached = true;
    redraw (-1);
}

/**
 * Sets the font that the receiver will use to paint textual information
 * for the specified cell in this item to the font specified by the
 * argument, or to the default font for that kind of control if the
 * argument is null.
 *
 * @param index the column index
 * @param font the new font (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public void setFont (int index, Font font) {
    checkWidget ();
    if (font !is null && font.isDisposed ()) {
        DWT.error (DWT.ERROR_INVALID_ARGUMENT);
    }
    int count = Math.max (1, parent.columnCount);
    if (0 > index || index > count - 1) return;
    if (cellFont is null) {
        if (font is null) return;
        cellFont = new Font [count];
    }
    Font oldFont = cellFont [index];
    if (oldFont is font) return;
    cellFont [index] = font;
    if (oldFont !is null && oldFont.equals (font)) return;
    width = -1;
    cached = true;
    redraw (index);
}

/**
 * Sets the receiver's foreground color to the color specified
 * by the argument, or to the default system color for the item
 * if the argument is null.
 *
 * @param color the new color (or null)
 *
 * @since 2.0
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.0
 *
 */
public void setForeground (Color color) {
    checkWidget ();
    if (color !is null && color.isDisposed ()) {
        DWT.error (DWT.ERROR_INVALID_ARGUMENT);
    }
    Color oldColor = foreground;
    if (oldColor is color) return;
    foreground = color;
    if (oldColor !is null && oldColor.equals (color)) return;
    cached = true;
    redraw (-1);
}

/**
 * Sets the foreground color at the given column index in the receiver
 * to the color specified by the argument, or to the default system color for the item
 * if the argument is null.
 *
 * @param index the column index
 * @param color the new color (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 *
 */
public void setForeground (int index, Color color){
    checkWidget ();
    if (color !is null && color.isDisposed ()) {
        DWT.error (DWT.ERROR_INVALID_ARGUMENT);
    }
    int count = Math.max (1, parent.columnCount);
    if (0 > index || index > count - 1) return;
    if (cellForeground is null) {
        if (color is null) return;
        cellForeground = new Color [count];
    }
    Color oldColor = cellForeground [index];
    if (oldColor is color) return;
    cellForeground [index] = color;
    if (oldColor !is null && oldColor.equals (color)) return;
    cached = true;
    redraw (index);
}

/**
 * Sets the grayed state of the checkbox for this item.  This state change
 * only applies if the Tree was created with the DWT.CHECK style.
 *
 * @param grayed the new grayed state of the checkbox
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setGrayed (bool grayed) {
    checkWidget ();
    if ((parent.style & DWT.CHECK) is 0) return;
    if (this.grayed is grayed) return;
    this.grayed = grayed;
    cached = true;
    redraw (-1);
}

/**
 * Sets the image for multiple columns in the tree.
 *
 * @param images the array of new images
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the array of images is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if one of the images has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public void setImage (Image [] images) {
    checkWidget ();
    if (images is null) error (DWT.ERROR_NULL_ARGUMENT);
    for (int i=0; i<images.length; i++) {
        setImage (i, images [i]);
    }
}

/**
 * Sets the receiver's image at a column.
 *
 * @param index the column index
 * @param image the new image
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the image has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public void setImage (int index, Image image) {
    checkWidget ();
    if (image !is null && image.isDisposed ()) {
        error (DWT.ERROR_INVALID_ARGUMENT);
    }
    if (parent.imageBounds is null && image !is null) {
        parent.setItemHeight (image, null, false);
    }
    if (index is 0)  {
        if (image !is null && image.type is DWT.ICON) {
            if (image.equals (this.image)) return;
        }
        width = -1;
        super.setImage (image);
    }
    int count = Math.max (1, parent.columnCount);
    if (0 <= index && index < count) {
        if (images is null) images = new Image [count];
        if (image !is null && image.type is DWT.ICON) {
            if (image.equals (images [index])) return;
        }
        images [index] = image;
    }
    cached = true;
    if (index is 0) parent.setScrollWidth (this);
    if (0 <= index && index < count) redraw (index);
}

public void setImage (Image image) {
    checkWidget ();
    setImage (0, image);
}

/**
 * Sets the number of child items contained in the receiver.
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
    count = Math.max (0, count);
    parent.setItemCount (this, count);
}

/**
 * Sets the text for multiple columns in the tree.
 *
 * @param strings the array of new strings
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the text is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public void setText (String [] strings) {
    checkWidget ();
    if (strings is null) error (DWT.ERROR_NULL_ARGUMENT);
    for (int i=0; i<strings.length; i++) {
        String string = strings [i];
        if (string !is null) setText (i, string);
    }
}

/**
 * Sets the receiver's text at a column
 *
 * @param index the column index
 * @param string the new text
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the text is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public void setText (int index, String string) {
    checkWidget ();
    if (string is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (index is 0) {
        if (string.equals (text)) return;
        width = -1;
        super.setText (string);
    }
    int count = Math.max (1, parent.columnCount);
    if (0 <= index && index < count) {
        if (strings is null) strings = new String [count];
        if (string.equals (strings [index])) return;
        strings [index] = string;
    }
    cached = true;
    if (index is 0) parent.setScrollWidth (this);
    if (0 <= index && index < count) redraw (index);
}

public void setText (String string) {
    checkWidget ();
    setText (0, string);
}

void updateExpanded () {
    if (itemCount is 0) return;
    NSOutlineView outlineView = (NSOutlineView)parent.view;
    if (expanded !is outlineView.isItemExpanded (handle)) {
        if (expanded) {
            outlineView.expandItem (handle);
        } else {
            outlineView.collapseItem (handle);
        }
    }
    for (int i = 0; i < itemCount; i++) {
        if (items[i] !is null) items[i].updateExpanded ();
    }
}
}
