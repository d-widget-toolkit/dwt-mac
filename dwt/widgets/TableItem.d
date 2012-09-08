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
module dwt.widgets.TableItem;

import dwt.dwthelper.utils;







import dwt.DWT;
import dwt.internal.cocoa.NSCell;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSTableView;
import dwt.internal.cocoa.NSAttributedString;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import dwt.internal.cocoa.objc_super;
import objc = dwt.internal.objc.runtime;
import dwt.widgets.Event;
import dwt.widgets.Item;
import dwt.widgets.Table;
import dwt.widgets.TableColumn;
import dwt.widgets.Tree;
import dwt.graphics.Image;
import dwt.graphics.Color;
import dwt.graphics.Rectangle;
import dwt.graphics.Font;
import dwt.graphics.GC;

/**
 * Instances of this class represent a selectable user interface object
 * that represents an item in a table.
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
 * @see <a href="http://www.eclipse.org/swt/snippets/#table">Table, TableItem, TableColumn snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 * @noextend This class is not intended to be subclassed by clients.
 */
public class TableItem : Item {
    Table parent;
    String [] strings;
    Image [] images;
    bool checked, grayed, cached;
    Color foreground, background;
    Color[] cellForeground, cellBackground;
    Font font;
    Font[] cellFont;
    int width = -1;

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>Table</code>) and a style value
 * describing its behavior and appearance. The item is added
 * to the end of the items maintained by its parent.
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
 * @see DWT
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Table parent, int style) {
    this (parent, style, checkNull (parent).getItemCount (), true);
}

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>Table</code>), a style value
 * describing its behavior and appearance, and the index
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
 * @param parent a composite control which will be the parent of the new instance (cannot be null)
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
public this (Table parent, int style, int index) {
    this (parent, style, index, true);
}

this (Table parent, int style, int index, bool create) {
    super (parent, style);
    this.parent = parent;
    if (create) parent.createItem (this, index);
}

static Table checkNull (Table control) {
    if (control is null) DWT.error (DWT.ERROR_NULL_ARGUMENT);
    return control;
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
    super_struct.super_class = cast(objc.Class)OS.objc_msgSend(cell.id, OS.sel_superclass);
    NSSize size = NSSize();
    OS.objc_msgSendSuper_stret(&size, &super_struct, OS.sel_cellSize);
    if (image !is null) size.width += parent.imageBounds.width + Table.IMAGE_GAP;
//  cell.setImage (image !is null ? image.handle : null);
//  NSSize size = cell.cellSize ();

    int width = cast(int)Math.ceil (size.width);
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
        NSTableView widget = cast(NSTableView)parent.view;
        int height = cast(int)widget.rowHeight ();
        event.width = width;
        event.height = height;
        parent.sendEvent (DWT.MeasureItem, event);
        if (height < event.height) {
            widget.setRowHeight (event.height);
            widget.setNeedsDisplay (true);
        }
        width = event.width;
    }
    if (index is 0) this.width = width;
    return width;
}

protected void checkSubclass () {
    if (!isValidSubclass ()) error (DWT.ERROR_INVALID_SUBCLASS);
}

void clear () {
    text = "";
    image = null;
    strings = null;
    images = null;
    checked = grayed = cached = false;
    foreground = background = null;
    cellForeground = cellBackground = null;
    font = null;
    cellFont = null;
    width = -1;
}

NSObject createString (int index) {
    String text = index is 0 ? this.text : (strings is null ? "" : strings [index]);
    return NSString.stringWith(text !is null ? text : "");
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
 * @since 3.0
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
 *
 * @since 3.2
 */
public Rectangle getBounds () {
    checkWidget ();
    if (!parent.checkData (this)) error (DWT.ERROR_WIDGET_DISPOSED);
    NSTableView tableView = cast(NSTableView) parent.view;
    NSRect rect = tableView.rectOfRow (parent.indexOf (this));
    return new Rectangle(cast(int) rect.x, cast(int) rect.y, cast(int) rect.width, cast(int) rect.height);
}

/**
 * Returns a rectangle describing the receiver's size and location
 * relative to its parent at a column in the table.
 *
 * @param index the index that specifies the column
 * @return the receiver's bounding column rectangle
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Rectangle getBounds (int index) {
    checkWidget ();
    if (!parent.checkData (this)) error (DWT.ERROR_WIDGET_DISPOSED);
    if (!(0 <= index && index < Math.max (1, parent.columnCount))) return new Rectangle (0, 0, 0, 0);

    NSTableView tableView = cast(NSTableView) parent.view;
    if (parent.columnCount is 0) {
        index = (parent.style & DWT.CHECK) !is 0 ? 1 : 0;
    } else {
        TableColumn column = parent.getColumn (index);
        index = parent.indexOf (column.nsColumn);
    }
    NSRect rect = tableView.frameOfCellAtColumn (index, parent.indexOf (this));
    return new Rectangle (cast(int) rect.x, cast(int) rect.y, cast(int) rect.width, cast(int) rect.height);
}

/**
 * Returns <code>true</code> if the receiver is checked,
 * and false otherwise.  When the parent does not have
 * the <code>CHECK</code> style, return false.
 *
 * @return the checked state of the checkbox
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
 * @since 3.0
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
 * @since 3.0
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
 * the <code>CHECK</code> style, return false.
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
 * table.  An empty rectangle is returned if index exceeds
 * the index of the table's last column.
 *
 * @param index the index that specifies the column
 * @return the receiver's bounding image rectangle
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Rectangle getImageBounds (int index) {
    checkWidget ();
    if (!parent.checkData (this)) error (DWT.ERROR_WIDGET_DISPOSED);
    if (!(0 <= index && index < Math.max (1, parent.columnCount))) return new Rectangle (0, 0, 0, 0);

    NSTableView tableView = cast(NSTableView) parent.view;
    Image image = index is 0 ? this.image : (images !is null) ? images [index] : null;
    if (parent.columnCount is 0) {
        index = (parent.style & DWT.CHECK) !is 0 ? 1 : 0;
    } else {
        TableColumn column = parent.getColumn (index);
        index = parent.indexOf (column.nsColumn);
    }
    NSRect rect = tableView.frameOfCellAtColumn (index, parent.indexOf (this));
    rect.x = rect.x + Tree.IMAGE_GAP;
    if (image !is null) {
        rect.width = parent.imageBounds.width;
    } else {
        rect.width = 0;
    }
}

/**
 * Gets the image indent.
 *
 * @return the indent
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getImageIndent () {
    checkWidget ();
    if (!parent.checkData (this)) error (DWT.ERROR_WIDGET_DISPOSED);
    return 0;
}

String getNameText () {
    if ((parent.style & DWT.VIRTUAL) !is 0) {
        if (!cached) return "*virtual*"; //$NON-NLS-1$
    }
    return super.getNameText ();
}

/**
 * Returns the receiver's parent, which must be a <code>Table</code>.
 *
 * @return the receiver's parent
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Table getParent () {
    checkWidget ();
    return parent;
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
 * table.  An empty rectangle is returned if index exceeds
 * the index of the table's last column.
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

    NSTableView tableView = cast(NSTableView) parent.view;
    Image image = index is 0 ? this.image : (images !is null) ? images [index] : null;
    if (parent.columnCount is 0) {
        index = (parent.style & DWT.CHECK) !is 0 ? 1 : 0;
    } else {
        TableColumn column = parent.getColumn (index);
        index = parent.indexOf (column.nsColumn);
    }
    NSRect rect = tableView.frameOfCellAtColumn (index, parent.indexOf (this));
    rect.x = rect.x + Tree.TEXT_GAP;
    rect.width = rect.width - Tree.TEXT_GAP;
    if (image !is null) {
        int offset = parent.imageBounds.width + Tree.IMAGE_GAP;
        rect.x = rect.x + offset;
        rect.width = rect.width - offset;
    }
    return new Rectangle(cast(int) rect.x, cast(int) rect.y, cast(int) rect.width, cast(int) rect.height);
}

void redraw (int columnIndex) {
    if (parent.currentItem is this || !isDrawing()) return;
    /* redraw the full item if columnIndex is -1 */
    NSTableView tableView = cast(NSTableView) parent.view;
    NSRect rect;
    if (columnIndex is -1 || parent.hooks (DWT.MeasureItem) || parent.hooks (DWT.EraseItem) || parent.hooks (DWT.PaintItem)) {
        rect = tableView.rectOfRow (parent.indexOf (this));
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
        rect = tableView.frameOfCellAtColumn (index, parent.indexOf (this));
    }
    tableView.setNeedsDisplayInRect (rect);
}

void releaseHandle () {
    super.releaseHandle ();
    parent = null;
}

void releaseParent () {
    super.releaseParent ();
    //  parent.checkItems (true);
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
 * @since 3.0
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
 * Sets the checked state of the checkbox for this item.  This state change
 * only applies if the Table was created with the DWT.CHECK style.
 *
 * @param checked the new checked state of the checkbox
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
 * @since 3.0
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
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.0
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
 * @since 3.0
 */
public void setForeground (int index, Color color) {
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
 * only applies if the Table was created with the DWT.CHECK style.
 *
 * @param grayed the new grayed state of the checkbox;
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
 * Sets the image for multiple columns in the table.
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
 */
public void setImage (int index, Image image) {
    checkWidget ();
    if (image !is null && image.isDisposed ()) {
        error(DWT.ERROR_INVALID_ARGUMENT);
    }
    int itemIndex = parent.indexOf (this);
    if (itemIndex is -1) return;
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
    redraw (index);
}

public void setImage (Image image) {
    checkWidget ();
    setImage (0, image);
}

/**
 * Sets the indent of the first column's image, expressed in terms of the image's width.
 *
 * @param indent the new indent
 *
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @deprecated this functionality is not supported on most platforms
 */
public void setImageIndent (int indent) {
    checkWidget ();
    if (indent < 0) return;
    cached = true;
    /* Image indent is not supported on the Macintosh */
}

/**
 * Sets the text for multiple columns in the table.
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
    redraw (index);
}

public void setText (String string) {
    checkWidget ();
    setText (0, string);
}

}
