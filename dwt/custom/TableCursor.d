/*******************************************************************************
 * Copyright (c) 2000, 2009 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *     Frank Benoit <benoit@tionex.de>
 *******************************************************************************/
module dwt.custom.TableCursor;

import dwt.dwthelper.utils;


import dwt.graphics.*;
import dwt.widgets.*;
import dwt.accessibility.*;
import dwt.events.*;

/**
 * A TableCursor provides a way for the user to navigate around a Table
 * using the keyboard.  It also provides a mechanism for selecting an
 * individual cell in a table.
 *
 * <p> Here is an example of using a TableCursor to navigate to a cell and then edit it.
 *
 * <code><pre>
 *  public static void main(String[] args) {
 *      Display display = new Display();
 *      Shell shell = new Shell(display);
 *      shell.setLayout(new GridLayout());
 *
 *      // create a a table with 3 columns and fill with data
 *      final Table table = new Table(shell, DWT.BORDER | DWT.MULTI | DWT.FULL_SELECTION);
 *      table.setLayoutData(new GridData(GridData.FILL_BOTH));
 *      TableColumn column1 = new TableColumn(table, DWT.NONE);
 *      TableColumn column2 = new TableColumn(table, DWT.NONE);
 *      TableColumn column3 = new TableColumn(table, DWT.NONE);
 *      for (int i = 0; i &lt; 100; i++) {
 *          TableItem item = new TableItem(table, DWT.NONE);
 *          item.setText(new String[] { "cell "+i+" 0", "cell "+i+" 1", "cell "+i+" 2"});
 *      }
 *      column1.pack();
 *      column2.pack();
 *      column3.pack();
 *
 *      // create a TableCursor to navigate around the table
 *      final TableCursor cursor = new TableCursor(table, DWT.NONE);
 *      // create an editor to edit the cell when the user hits "ENTER"
 *      // while over a cell in the table
 *      final ControlEditor editor = new ControlEditor(cursor);
 *      editor.grabHorizontal = true;
 *      editor.grabVertical = true;
 *
 *      cursor.addSelectionListener(new SelectionAdapter() {
 *          // when the TableEditor is over a cell, select the corresponding row in
 *          // the table
 *          public void widgetSelected(SelectionEvent e) {
 *              table.setSelection(new TableItem[] {cursor.getRow()});
 *          }
 *          // when the user hits "ENTER" in the TableCursor, pop up a text editor so that
 *          // they can change the text of the cell
 *          public void widgetDefaultSelected(SelectionEvent e){
 *              final Text text = new Text(cursor, DWT.NONE);
 *              TableItem row = cursor.getRow();
 *              int column = cursor.getColumn();
 *              text.setText(row.getText(column));
 *              text.addKeyListener(new KeyAdapter() {
 *                  public void keyPressed(KeyEvent e) {
 *                      // close the text editor and copy the data over
 *                      // when the user hits "ENTER"
 *                      if (e.character is DWT.CR) {
 *                          TableItem row = cursor.getRow();
 *                          int column = cursor.getColumn();
 *                          row.setText(column, text.getText());
 *                          text.dispose();
 *                      }
 *                      // close the text editor when the user hits "ESC"
 *                      if (e.character is DWT.ESC) {
 *                          text.dispose();
 *                      }
 *                  }
 *              });
 *              editor.setEditor(text);
 *              text.setFocus();
 *          }
 *      });
 *      // Hide the TableCursor when the user hits the "MOD1" or "MOD2" key.
 *      // This allows the user to select multiple items in the table.
 *      cursor.addKeyListener(new KeyAdapter() {
 *          public void keyPressed(KeyEvent e) {
 *              if (e.keyCode is DWT.MOD1 ||
 *                  e.keyCode is DWT.MOD2 ||
 *                  (e.stateMask & DWT.MOD1) !is 0 ||
 *                  (e.stateMask & DWT.MOD2) !is 0) {
 *                  cursor.setVisible(false);
 *              }
 *          }
 *      });
 *      // Show the TableCursor when the user releases the "MOD2" or "MOD1" key.
 *      // This signals the end of the multiple selection task.
 *      table.addKeyListener(new KeyAdapter() {
 *          public void keyReleased(KeyEvent e) {
 *              if (e.keyCode is DWT.MOD1 && (e.stateMask & DWT.MOD2) !is 0) return;
 *              if (e.keyCode is DWT.MOD2 && (e.stateMask & DWT.MOD1) !is 0) return;
 *              if (e.keyCode !is DWT.MOD1 && (e.stateMask & DWT.MOD1) !is 0) return;
 *              if (e.keyCode !is DWT.MOD2 && (e.stateMask & DWT.MOD2) !is 0) return;
 *
 *              TableItem[] selection = table.getSelection();
 *              TableItem row = (selection.length is 0) ? table.getItem(table.getTopIndex()) : selection[0];
 *              table.showItem(row);
 *              cursor.setSelection(row, 0);
 *              cursor.setVisible(true);
 *              cursor.setFocus();
 *          }
 *      });
 *
 *      shell.open();
 *      while (!shell.isDisposed()) {
 *          if (!display.readAndDispatch())
 *              display.sleep();
 *      }
 *      display.dispose();
 *  }
 * </pre></code>
 *
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>BORDER</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Selection, DefaultSelection</dd>
 * </dl>
 *
 * @since 2.0
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#tablecursor">TableCursor snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a> 
 */
public class TableCursor : Canvas {

    alias Canvas.dispose dispose;

    Table table;
    TableItem row = null;
    TableColumn column = null;
    Listener tableListener, resizeListener, disposeItemListener, disposeColumnListener;

    Color background = null;
    Color foreground = null;

    // By default, invert the list selection colors
    static final int BACKGROUND = DWT.COLOR_LIST_SELECTION_TEXT;
    static final int FOREGROUND = DWT.COLOR_LIST_SELECTION;

/**
 * Constructs a new instance of this class given its parent
 * table and a style value describing its behavior and appearance.
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
 * @param parent a Table control which will be the parent of the new instance (cannot be null)
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
 * @see DWT#BORDER
 * @see Widget#checkSubclass()
 * @see Widget#getStyle()
 */
public this(Table parent, int style) {
    super(parent, style);
    table = parent;
    setBackground(null);
    setForeground(null);

    Listener listener = new class(this) Listener {
        TableCursor tc;
        
        this (TableCursor tc) {
            this.tc = tc;
        }
        
        public void handleEvent(Event event) {
            switch (event.type) {
                case DWT.Dispose :
                    tc.dispose(event);
                    break;
                case DWT.FocusIn :
                case DWT.FocusOut :
                    tc.redraw();
                    break;
                case DWT.KeyDown :
                    tc.keyDown(event);
                    break;
                case DWT.Paint :
                    tc.paint(event);
                    break;
                case DWT.Traverse : {
                    event.doit = true;
                    switch (event.detail) {
                        case DWT.TRAVERSE_ARROW_NEXT :
                        case DWT.TRAVERSE_ARROW_PREVIOUS :
                        case DWT.TRAVERSE_RETURN :
                            event.doit = false;
                            break;
                        default:
                    }
                    break;
                }
                default:
            }
        }
    };
    int[] events = [DWT.Dispose, DWT.FocusIn, DWT.FocusOut, DWT.KeyDown, DWT.Paint, DWT.Traverse];
    for (int i = 0; i < events.length; i++) {
        addListener(events[i], listener);
    }

    tableListener = new class(this) Listener {
        TableCursor tc;
        
        this (TableCursor tc) {
            this.tc = tc;
        }
        
        public void handleEvent(Event event) {
            switch (event.type) {
                case DWT.MouseDown :
                    tc.tableMouseDown(event);
                    break;
                case DWT.FocusIn :
                    tc.tableFocusIn(event);
                    break;
                default:
            }
        }
    };
    table.addListener(DWT.FocusIn, tableListener);
    table.addListener(DWT.MouseDown, tableListener);

    disposeItemListener = new class(this) Listener {
        TableCursor tc;
        
        this (TableCursor tc) {
            this.tc = tc;
        }
        
        public void handleEvent(Event event) {
            tc.unhookRowColumnListeners();
            tc.row = null;
            tc.column = null;
            tc._resize();
        }
    };
    disposeColumnListener = new class(this) Listener {
        TableCursor tc;
        
        this (TableCursor tc) {
            this.tc = tc;
        }
        
        public void handleEvent(Event event) {
            tc.unhookRowColumnListeners();
            tc.row = null;
            tc.column = null;
            tc._resize();
        }
    };
    resizeListener = new class(this) Listener {
        TableCursor tc;
        
        this (TableCursor tc) {
            this.tc = tc;
        }
        
        public void handleEvent(Event event) {
            tc._resize();
        }
    };
    ScrollBar hBar = table.getHorizontalBar();
    if (hBar !is null) {
        hBar.addListener(DWT.Selection, resizeListener);
    }
    ScrollBar vBar = table.getVerticalBar();
    if (vBar !is null) {
        vBar.addListener(DWT.Selection, resizeListener);
    }

    getAccessible().addAccessibleControlListener(new AccessibleControlAdapter() {
        public void getRole(AccessibleControlEvent e) {
            e.detail = ACC.ROLE_TABLECELL;
        }
    });
    getAccessible().addAccessibleListener(new AccessibleAdapter() {
        public void getName(AccessibleEvent e) {
            if (row is null) return;
            int columnIndex = column is null ? 0 : table.indexOf(column);
            e.result = row.getText(columnIndex);
        }
    });
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the user changes the receiver's selection, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * When <code>widgetSelected</code> is called, the item field of the event object is valid.
 * If the receiver has <code>DWT.CHECK</code> style set and the check selection changes,
 * the event object detail field contains the value <code>DWT.CHECK</code>.
 * <code>widgetDefaultSelected</code> is typically called when an item is double-clicked.
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
 * @see SelectionEvent
 * @see #removeSelectionListener(SelectionListener)
 *
 */
public void addSelectionListener(SelectionListener listener) {
    checkWidget();
    if (listener is null)
        DWT.error(DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener(listener);
    addListener(DWT.Selection, typedListener);
    addListener(DWT.DefaultSelection, typedListener);
}

void dispose(Event event) {
    table.removeListener(DWT.FocusIn, tableListener);
    table.removeListener(DWT.MouseDown, tableListener);
    unhookRowColumnListeners();
    ScrollBar hBar = table.getHorizontalBar();
    if (hBar !is null) {
        hBar.removeListener(DWT.Selection, resizeListener);
    }
    ScrollBar vBar = table.getVerticalBar();
    if (vBar !is null) {
        vBar.removeListener(DWT.Selection, resizeListener);
    }
}

void keyDown(Event event) {
    if (row is null) return;
    switch (event.character) {
        case DWT.CR :
            notifyListeners(DWT.DefaultSelection, new Event());
            return;
        default:
    }
    int rowIndex = table.indexOf(row);
    int columnIndex = column is null ? 0 : table.indexOf(column);
    switch (event.keyCode) {
        case DWT.ARROW_UP :
            setRowColumn(Math.max(0, rowIndex - 1), columnIndex, true);
            break;
        case DWT.ARROW_DOWN :
            setRowColumn(Math.min(rowIndex + 1, table.getItemCount() - 1), columnIndex, true);
            break;
        case DWT.ARROW_LEFT :
        case DWT.ARROW_RIGHT :
            {
                int columnCount = table.getColumnCount();
                if (columnCount is 0) break;
                int[] order = table.getColumnOrder();
                int index = 0;
                while (index < order.length) {
                    if (order[index] is columnIndex) break;
                    index++;
                }
                if (index is order.length) index = 0;
                int leadKey = (getStyle() & DWT.RIGHT_TO_LEFT) !is 0 ? DWT.ARROW_RIGHT : DWT.ARROW_LEFT;
                if (event.keyCode is leadKey) {
                   setRowColumn(rowIndex, order[Math.max(0, index - 1)], true);
                } else {
                   setRowColumn(rowIndex, order[Math.min(columnCount - 1, index + 1)], true);
                }
                break;
            }
        case DWT.HOME :
            setRowColumn(0, columnIndex, true);
            break;
        case DWT.END :
            {
                int i = table.getItemCount() - 1;
                setRowColumn(i, columnIndex, true);
                break;
            }
        case DWT.PAGE_UP :
            {
                int index = table.getTopIndex();
                if (index is rowIndex) {
                    Rectangle rect = table.getClientArea();
                    TableItem item = table.getItem(index);
                    Rectangle itemRect = item.getBounds(0);
                    rect.height -= itemRect.y;
                    int height = table.getItemHeight();
                    int page = Math.max(1, rect.height / height);
                    index = Math.max(0, index - page + 1);
                }
                setRowColumn(index, columnIndex, true);
                break;
            }
        case DWT.PAGE_DOWN :
            {
                int index = table.getTopIndex();
                Rectangle rect = table.getClientArea();
                TableItem item = table.getItem(index);
                Rectangle itemRect = item.getBounds(0);
                rect.height -= itemRect.y;
                int height = table.getItemHeight();
                int page = Math.max(1, rect.height / height);
                int end = table.getItemCount() - 1;
                index = Math.min(end, index + page - 1);
                if (index is rowIndex) {
                    index = Math.min(end, index + page - 1);
                }
                setRowColumn(index, columnIndex, true);
                break;
            }
        default:
    }
}

void paint(Event event) {
    if (row is null) return;
    int columnIndex = column is null ? 0 : table.indexOf(column);
    GC gc = event.gc;
    Display display = getDisplay();
    gc.setBackground(getBackground());
    gc.setForeground(getForeground());
    gc.fillRectangle(event.x, event.y, event.width, event.height);
    int x = 0;
    Point size = getSize();
    Image image = row.getImage(columnIndex);
    if (image !is null) {
        Rectangle imageSize = image.getBounds();
        int imageY = (size.y - imageSize.height) / 2;
        gc.drawImage(image, x, imageY);
        x += imageSize.width;
    }
    String text = row.getText(columnIndex);
    if (text.length > 0) {
        Rectangle bounds = row.getBounds(columnIndex);
        Point extent = gc.stringExtent(text);
        // Temporary code - need a better way to determine table trim
        String platform = DWT.getPlatform();
        if ("win32"==platform) { //$NON-NLS-1$
            if (table.getColumnCount() is 0 || columnIndex is 0) {
                x += 2;
            } else {
                int alignmnent = column.getAlignment();
                switch (alignmnent) {
                    case DWT.LEFT:
                        x += 6;
                        break;
                    case DWT.RIGHT:
                        x = bounds.width - extent.x - 6;
                        break;
                    case DWT.CENTER:
                        x += (bounds.width - x - extent.x) / 2;
                        break;
                    default:
                }
            }
        }  else {
            if (table.getColumnCount() is 0) {
                x += 5;
            } else {
                int alignmnent = column.getAlignment();
                switch (alignmnent) {
                    case DWT.LEFT:
                        x += 5;
                        break;
                    case DWT.RIGHT:
                        x = bounds.width- extent.x - 2;
                        break;
                    case DWT.CENTER:
                        x += (bounds.width - x - extent.x) / 2 + 2;
                        break;
                    default:
                }
            }
        }
        int textY = (size.y - extent.y) / 2;
        gc.drawString(text, x, textY);
    }
    if (isFocusControl()) {
        gc.setBackground(display.getSystemColor(DWT.COLOR_BLACK));
        gc.setForeground(display.getSystemColor(DWT.COLOR_WHITE));
        gc.drawFocus(0, 0, size.x, size.y);
    }
}

void tableFocusIn(Event event) {
    if (isDisposed()) return;
    if (isVisible()) {
        if (row is null && column is null) return;
        setFocus();
    }
}

void tableMouseDown(Event event) {
    if (isDisposed() || !isVisible()) return;
    Point pt = new Point(event.x, event.y);
    int lineWidth = table.getLinesVisible() ? table.getGridLineWidth() : 0;
    TableItem item = table.getItem(pt);
    if ((table.getStyle() & DWT.FULL_SELECTION) !is 0) {
        if (item is null) return;
    } else {
        int start = item !is null ? table.indexOf(item) : table.getTopIndex();
        int end = table.getItemCount();
        Rectangle clientRect = table.getClientArea();
        for (int i = start; i < end; i++) {
            TableItem nextItem = table.getItem(i);
            Rectangle rect = nextItem.getBounds(0);
            if (pt.y >= rect.y && pt.y < rect.y + rect.height + lineWidth) {
                item = nextItem;
                break;
            }
            if (rect.y > clientRect.y + clientRect.height)  return;
        }
        if (item is null) return;
    }
    TableColumn newColumn = null;
    int columnCount = table.getColumnCount();
    if (columnCount is 0) {
        if ((table.getStyle() & DWT.FULL_SELECTION) is 0) {
            Rectangle rect = item.getBounds(0);
            rect.width += lineWidth;
            rect.height += lineWidth;
            if (!rect.contains(pt)) return;
        }
    } else {
        for (int i = 0; i < columnCount; i++) {
            Rectangle rect = item.getBounds(i);
            rect.width += lineWidth;
            rect.height += lineWidth;
            if (rect.contains(pt)) {
                newColumn = table.getColumn(i);
                break;
            }
        }
        if (newColumn is null) {
            if ((table.getStyle() & DWT.FULL_SELECTION) is 0) return;
            newColumn = table.getColumn(0);
        }
    }
    setRowColumn(item, newColumn, true);
    setFocus();
    return;
}
void setRowColumn(int row, int column, bool notify) {
    TableItem item = row is -1 ? null : table.getItem(row);
    TableColumn col = column is -1 || table.getColumnCount() is 0 ? null : table.getColumn(column);
    setRowColumn(item, col, notify);
}
void setRowColumn(TableItem row, TableColumn column, bool notify) {
    if (this.row is row && this.column is column) {
        return;
    }
    if (this.row !is null && this.row !is row) {
        this.row.removeListener(DWT.Dispose, disposeItemListener);
        this.row = null;
    }
    if (this.column !is null && this.column !is column) {
        this.column.removeListener(DWT.Dispose, disposeColumnListener);
        this.column.removeListener(DWT.Move, resizeListener);
        this.column.removeListener(DWT.Resize, resizeListener);
        this.column = null;
    }
    if (row !is null) {
        if (this.row !is row) {
            this.row = row;
            row.addListener(DWT.Dispose, disposeItemListener);
            table.showItem(row);
        }
        if (this.column !is column && column !is null) {
            this.column = column;
            column.addListener(DWT.Dispose, disposeColumnListener);
            column.addListener(DWT.Move, resizeListener);
            column.addListener(DWT.Resize, resizeListener);
            table.showColumn(column);
        }
        int columnIndex = column is null ? 0 : table.indexOf(column);
        setBounds(row.getBounds(columnIndex));
        redraw();
        if (notify) {
            notifyListeners(DWT.Selection, new Event());
        }
    }
    getAccessible().setFocus(ACC.CHILDID_SELF);
}

public override void setVisible(bool visible) {
    checkWidget();
    if (visible) _resize();
    super.setVisible(visible);
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
 * @see #addSelectionListener(SelectionListener)
 *
 * @since 3.0
 */
public void removeSelectionListener(SelectionListener listener) {
    checkWidget();
    if (listener is null) {
        DWT.error(DWT.ERROR_NULL_ARGUMENT);
    }
    removeListener(DWT.Selection, listener);
    removeListener(DWT.DefaultSelection, listener);
}

void _resize() {
    if (row is null) {
        setBounds(-200, -200, 0, 0);
    } else {
        int columnIndex = column is null ? 0 : table.indexOf(column);
        setBounds(row.getBounds(columnIndex));
    }
}
/**
 * Returns the column over which the TableCursor is positioned.
 *
 * @return the column for the current position
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getColumn() {
    checkWidget();
    return column is null ? 0 : table.indexOf(column);
}
/**
 * Returns the background color that the receiver will use to draw.
 *
 * @return the receiver's background color
 */
public Color getBackground() {
    checkWidget();
    if (background is null) {
        return getDisplay().getSystemColor(BACKGROUND);
    }
    return background;
}
/**
 * Returns the foreground color that the receiver will use to draw.
 *
 * @return the receiver's foreground color
 */
public Color getForeground() {
    checkWidget();
    if (foreground is null) {
        return getDisplay().getSystemColor(FOREGROUND);
    }
    return foreground;
}
/**
 * Returns the row over which the TableCursor is positioned.
 *
 * @return the item for the current position
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public TableItem getRow() {
    checkWidget();
    return row;
}
/**
 * Sets the receiver's background color to the color specified
 * by the argument, or to the default system color for the control
 * if the argument is null.
 * <p>
 * Note: This operation is a hint and may be overridden by the platform.
 * For example, on Windows the background of a Button cannot be changed.
 * </p>
 * @param color the new color (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li> 
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public override void setBackground (Color color) {
    background = color;
    super.setBackground(getBackground());
    redraw();
}
/**
 * Sets the receiver's foreground color to the color specified
 * by the argument, or to the default system color for the control
 * if the argument is null.
 * <p>
 * Note: This operation is a hint and may be overridden by the platform.
 * </p>
 * @param color the new color (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li> 
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public override void setForeground (Color color) {
    foreground = color;
    super.setForeground(getForeground());
    redraw();
}
/**
 * Positions the TableCursor over the cell at the given row and column in the parent table.
 *
 * @param row the index of the row for the cell to select
 * @param column the index of column for the cell to select
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 */
public void setSelection(int row, int column) {
    checkWidget();
    int columnCount = table.getColumnCount();
    int maxColumnIndex =  columnCount is 0 ? 0 : columnCount - 1;
    if (row < 0
        || row >= table.getItemCount()
        || column < 0
        || column > maxColumnIndex)
        DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    setRowColumn(row, column, false);
}
/**
 * Positions the TableCursor over the cell at the given row and column in the parent table.
 *
 * @param row the TableItem of the row for the cell to select
 * @param column the index of column for the cell to select
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 */
public void setSelection(TableItem row, int column) {
    checkWidget();
    int columnCount = table.getColumnCount();
    int maxColumnIndex =  columnCount is 0 ? 0 : columnCount - 1;
    if (row is null
        || row.isDisposed()
        || column < 0
        || column > maxColumnIndex)
        DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    setRowColumn(table.indexOf(row), column, false);
}
void unhookRowColumnListeners() {
    if (column !is null) {
        column.removeListener(DWT.Dispose, disposeColumnListener);
        column.removeListener(DWT.Move, resizeListener);
        column.removeListener(DWT.Resize, resizeListener);
        column = null;
    }
    if (row !is null) {
        row.removeListener(DWT.Dispose, disposeItemListener);
        row = null;
    }
}
}
