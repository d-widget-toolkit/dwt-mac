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
module dwt.widgets.Combo;

import dwt.dwthelper.utils;







import Carbon = dwt.internal.c.Carbon;
import objc = dwt.internal.objc.runtime;
import dwt.widgets.Composite;
import dwt.widgets.Event;
import dwt.widgets.TypedListener;

/**
 * Instances of this class are controls that allow the user
 * to choose an item from a list of items, or optionally
 * enter a new value by typing it into an editable text
 * field. Often, <code>Combo</code>s are used in the same place
 * where a single selection <code>List</code> widget could
 * be used but space is limited. A <code>Combo</code> takes
 * less space than a <code>List</code> widget and shows
 * similar information.
 * <p>
 * Note: Since <code>Combo</code>s can contain both a list
 * and an editable text field, it is possible to confuse methods
 * which access one versus the other (compare for example,
 * <code>clearSelection()</code> and <code>deselectAll()</code>).
 * The API documentation is careful to indicate either "the
 * receiver's list" or the "the receiver's text field" to
 * distinguish between the two cases.
 * </p><p>
 * Note that although this class is a subclass of <code>Composite</code>,
 * it does not make sense to add children to it, or set a layout on it.
 * </p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>DROP_DOWN, READ_ONLY, SIMPLE</dd>
 * <dt><b>Events:</b></dt>
 * <dd>DefaultSelection, Modify, Selection, Verify</dd>
 * </dl>
 * <p>
 * Note: Only one of the styles DROP_DOWN and SIMPLE may be specified.
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see List
 * @see <a href="http://www.eclipse.org/swt/snippets/#combo">Combo snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">DWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 * @noextend This class is not intended to be subclassed by clients.
 */
public class Combo : Composite {
    int textLimit;
    bool receivingFocus;
    bool ignoreVerify, ignoreSelection;
    NSRange selectionRangeStruct;

    /**
     * the operating system limit for the number of characters
     * that the text field in an instance of this class can hold
     */
    public static const int LIMIT;

    /*
     * These values can be different on different platforms.
     * Therefore they are not initialized in the declaration
     * to stop the compiler from inlining.
     */
    static this () {
        LIMIT = 0x7FFFFFFF;
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
 * @see DWT#DROP_DOWN
 * @see DWT#READ_ONLY
 * @see DWT#SIMPLE
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, checkStyle (style));
    textLimit = LIMIT;
}

/**
 * Adds the argument to the end of the receiver's list.
 *
 * @param string the new item
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the string is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #add(String,int)
 */
public void add (String string) {
    checkWidget ();
    if (string is null) error (DWT.ERROR_NULL_ARGUMENT);
    NSString str = NSString.stringWith(string);
    if ((style & DWT.READ_ONLY) !is 0) {
        NSPopUpButton widget = (NSPopUpButton)view;
        int /*long*/ selection = widget.indexOfSelectedItem();
        NSMenu nsMenu = widget.menu();
        nsMenu.addItem(nsItem);
        nsItem.release();
        if (selection is -1) widget.selectItemAtIndex(-1);
    } else {
        (cast(NSComboBox)view).addItemWithObjectValue(str);
    }
}

/**
 * Adds the argument to the receiver's list at the given
 * zero-relative index.
 * <p>
 * Note: To add an item at the end of the list, use the
 * result of calling <code>getItemCount()</code> as the
 * index or use <code>add(String)</code>.
 * </p>
 *
 * @param string the new item
 * @param index the index for the item
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the string is null</li>
 *    <li>ERROR_INVALID_RANGE - if the index is not between 0 and the number of elements in the list (inclusive)</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #add(String)
 */
public void add (String string, int index) {
    checkWidget ();
    if (string is null) error (DWT.ERROR_NULL_ARGUMENT);
    int count = getItemCount ();
    if (0 > index || index > count) error (DWT.ERROR_INVALID_RANGE);
    NSString str = NSString.stringWith(string);
    if ((style & DWT.READ_ONLY) !is 0) {
        NSPopUpButton widget = (NSPopUpButton)view;
        int /*long*/ selection = widget.indexOfSelectedItem();
        NSMenu nsMenu = widget.menu();
        nsMenu.insertItem(nsItem, index);
        nsItem.release();
        if (selection is -1) widget.selectItemAtIndex(-1);
    } else {
        (cast(NSComboBox)view).insertItemWithObjectValue(str, index);
    }
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the receiver's text is modified, by sending
 * it one of the messages defined in the <code>ModifyListener</code>
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
 * @see ModifyListener
 * @see #removeModifyListener
 */
public void addModifyListener (ModifyListener listener) {
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (DWT.Modify, typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the user changes the receiver's selection, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * <code>widgetSelected</code> is called when the user changes the combo's list selection.
 * <code>widgetDefaultSelected</code> is typically called when ENTER is pressed the combo's text area.
 * </p>
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
 * @see SelectionListener
 * @see #removeSelectionListener
 * @see SelectionEvent
 */
public void addSelectionListener(SelectionListener listener) {
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (DWT.Selection,typedListener);
    addListener (DWT.DefaultSelection,typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the receiver's text is verified, by sending
 * it one of the messages defined in the <code>VerifyListener</code>
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
 * @see VerifyListener
 * @see #removeVerifyListener
 *
 * @since 3.1
 */
public void addVerifyListener (VerifyListener listener) {
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (DWT.Verify, typedListener);
}

bool becomeFirstResponder (objc.id id, objc.SEL sel) {
    receivingFocus = true;
    bool result = super.becomeFirstResponder (id, sel);
    receivingFocus = false;
    return result;
}

static int checkStyle (int style) {
    /*
     * Feature in Windows.  It is not possible to create
     * a combo box that has a border using Windows style
     * bits.  All combo boxes draw their own border and
     * do not use the standard Windows border styles.
     * Therefore, no matter what style bits are specified,
     * clear the BORDER bits so that the DWT style will
     * match the Windows widget.
     *
     * The Windows behavior is currently implemented on
     * all platforms.
     */
    style &= ~DWT.BORDER;

    /*
     * Even though it is legal to create this widget
     * with scroll bars, they serve no useful purpose
     * because they do not automatically scroll the
     * widget's client area.  The fix is to clear
     * the DWT style.
     */
    style &= ~(DWT.H_SCROLL | DWT.V_SCROLL);
    style = checkBits (style, DWT.DROP_DOWN, DWT.SIMPLE, 0, 0, 0, 0);
    if ((style & DWT.SIMPLE) !is 0) return style & ~DWT.READ_ONLY;
    return style;
}

protected void checkSubclass () {
    if (!isValidSubclass ()) error (DWT.ERROR_INVALID_SUBCLASS);
}

/**
 * Sets the selection in the receiver's text field to an empty
 * selection starting just before the first character. If the
 * text field is editable, this has the effect of placing the
 * i-beam at the start of the text.
 * <p>
 * Note: To clear the selected items in the receiver's list,
 * use <code>deselectAll()</code>.
 * </p>
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #deselectAll
 */
public void clearSelection () {
    checkWidget();
    if ((style & DWT.READ_ONLY) is 0) {
        Point selection = getSelection ();
        selection.y = selection.x;
        setSelection (selection);
    }
}

public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    int width = 0, height = 0;
    NSControl widget = cast(NSControl)view;
    NSCell viewCell = widget.cell ();
    NSSize size = viewCell.cellSize ();
    width = cast(int)Math.ceil (size.width);
    height = cast(int)Math.ceil (size.height);

    if ((style & DWT.READ_ONLY) is 0) {
        ignoreVerify = true;
        NSComboBoxCell cell = new NSComboBoxCell (viewCell.id);
        NSArray array = cell.objectValues ();
        int length = (int)/*64*/array.count ();
        if (length > 0) {
            cell = new NSComboBoxCell (cell.copy ());
            for (int i = 0; i < length; i++) {
                id object = array.objectAtIndex (i);
                cell.setTitle (new NSString (object));
                size = cell.cellSize ();
                width = Math.max (width, (int)Math.ceil (size.width));
            }
            cell.release ();
        }
        ignoreVerify = false;
    }


    /*
     * Feature in Cocoa.  Attempting to create an NSComboBox with a
     * height > 27 spews a very long warning message to stdout and
     * often draws the combo incorrectly.  The workaround is to limit
     * the returned height of editable Combos to the height that is
     * required to display their text, even if a larger hHint is specified.
     */
    if (hHint !is DWT.DEFAULT) {
        if ((style & DWT.READ_ONLY) !is 0 || hHint < height) height = hHint;
    }
    if (wHint !is DWT.DEFAULT) width = wHint;
    return new Point (width, height);
}

/**
 * Copies the selected text.
 * <p>
 * The current selection is copied to the clipboard.
 * </p>
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.1
 */
public void copy () {
    checkWidget ();
    Point selection = getSelection ();
    if (selection.x is selection.y) return;
    copyToClipboard (getText (selection.x, selection.y));
}

void createHandle () {
    if ((style & DWT.READ_ONLY) !is 0) {
        NSPopUpButton widget = cast(NSPopUpButton)(new SWTPopUpButton()).alloc();
        widget.initWithFrame(NSRect(), false);
        widget.menu().setAutoenablesItems(false);
        widget.setTarget(widget);
        widget.setAction(OS.sel_sendSelection);
        view = widget;
    } else {
        NSComboBox widget = cast(NSComboBox)(new SWTComboBox()).alloc();
        widget.init();
        widget.setDelegate(widget);
        widget.setTarget(widget);
        widget.setAction(OS.sel_sendSelection);
        view = widget;
    }
}

/**
 * Cuts the selected text.
 * <p>
 * The current selection is first copied to the
 * clipboard and then deleted from the widget.
 * </p>
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.1
 */
public void cut () {
    checkWidget ();
    if ((style & DWT.READ_ONLY) !is 0) return;
    Point selection = getSelection ();
    if (selection.x is selection.y) return;
    int start = selection.x, end = selection.y;
    String text = getText ();
    String leftText = text.substring (0, start);
    String rightText = text.substring (end, text.length ());
    String oldText = text.substring (start, end);
    String newText = "";
    if (hooks (DWT.Verify) || filters (DWT.Verify)) {
        newText = verifyText (newText, start, end, null);
        if (newText is null) return;
    }
    char [] buffer = new char [oldText.length ()];
    oldText.getChars (0, buffer.length, buffer, 0);
    copyToClipboard (buffer);
    setText (leftText ~ newText ~ rightText, false);
    start += newText.length ();
    setSelection (new Point (start, start));
    sendEvent (DWT.Modify);
}

Color defaultBackground () {
    return display.getWidgetColor (DWT.COLOR_LIST_BACKGROUND);
}

NSFont defaultNSFont() {
    if ((style & DWT.READ_ONLY) !is 0) return display.popUpButtonFont;
    return display.comboBoxFont;
}

Color defaultForeground () {
    return display.getWidgetColor (DWT.COLOR_LIST_FOREGROUND);
}

void deregister() {
    super.deregister();
    display.removeWidget((cast(NSControl)view).cell());
}

/**
 * Deselects the item at the given zero-relative index in the receiver's
 * list.  If the item at the index was already deselected, it remains
 * deselected. Indices that are out of range are ignored.
 *
 * @param index the index of the item to deselect
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void deselect (int index) {
    checkWidget ();
    if (index is -1) return;
    if (index is getSelectionIndex ()) {
        if ((style & DWT.READ_ONLY) !is 0) {
            (cast(NSPopUpButton)view).selectItem(null);
            sendEvent (DWT.Modify);
        } else {
            (cast(NSComboBox)view).deselectItemAtIndex(index);
        }
    }
}

/**
 * Deselects all selected items in the receiver's list.
 * <p>
 * Note: To clear the selection in the receiver's text field,
 * use <code>clearSelection()</code>.
 * </p>
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #clearSelection
 */
public void deselectAll () {
    checkWidget ();
    if ((style & DWT.READ_ONLY) !is 0) {
        (cast(NSPopUpButton)view).selectItem(null);
        sendEvent (DWT.Modify);
    } else {
        NSComboBox widget = (NSComboBox)view;
        int /*long*/ index = widget.indexOfSelectedItem();
        if (index !is -1) widget.deselectItemAtIndex(index);
    }
}

bool dragDetect(int x, int y, bool filter, bool[] consume) {
    if ((style & DWT.READ_ONLY) is 0) {
        NSText fieldEditor = ((NSControl)view).currentEditor();
        if (fieldEditor !is null) {
            NSRange selectedRange = fieldEditor.selectedRange();
            if (selectedRange.length > 0) {
                NSPoint mouseLocation = NSEvent.mouseLocation();
                NSTextView feAsTextView = new NSTextView(fieldEditor);
                int /*long*/ charPosition = feAsTextView.characterIndexForInsertionAtPoint(mouseLocation);
                if (charPosition !is OS.NSNotFound && charPosition >= selectedRange.location && charPosition < (selectedRange.location + selectedRange.length)) {
                    if (super.dragDetect(x, y, filter, consume)) {
                        if (consume !is null) consume[0] = true;
                        return true;
                    }
                }
            }
        }
        return false;
    }

    return super.dragDetect(x, y, filter, consume);
}

bool dragDetect(int x, int y, bool filter, bool[] consume) {
    if ((style & DWT.READ_ONLY) is 0) {
        NSText fieldEditor = ((NSControl)view).currentEditor();
        if (fieldEditor !is null) {
            NSRange selectedRange = fieldEditor.selectedRange();
            if (selectedRange.length > 0) {
                NSPoint mouseLocation = NSEvent.mouseLocation();
                NSTextView feAsTextView = new NSTextView(fieldEditor);
                int /*long*/ charPosition = feAsTextView.characterIndexForInsertionAtPoint(mouseLocation);
                if (charPosition !is OS.NSNotFound && charPosition >= selectedRange.location && charPosition < (selectedRange.location + selectedRange.length)) {
                    if (super.dragDetect(x, y, filter, consume)) {
                        if (consume !is null) consume[0] = true;
                        return true;
                    }
                }
            }
        }
        return false;
    }

    return super.dragDetect(x, y, filter, consume);
}

NSUInteger getCharCount() {
    NSString str;
    if ((style & DWT.READ_ONLY) !is 0) {
        str = (cast(NSPopUpButton)view).titleOfSelectedItem();
    } else {
        str = (new NSCell((cast(NSComboBox)view).cell())).title();
    }
    if (str is null) return 0;
    return str.length();
}

/**
 * Returns the item at the given, zero-relative index in the
 * receiver's list. Throws an exception if the index is out
 * of range.
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
public String getItem (int index) {
    checkWidget ();
    int count = getItemCount ();
    if (0 > index || index >= count) error (DWT.ERROR_INVALID_RANGE);
    NSString str;
    if ((style & DWT.READ_ONLY) !is 0) {
        str = (cast(NSPopUpButton)view).itemTitleAtIndex(index);
    } else {
        str = new NSString((cast(NSComboBox)view).itemObjectValueAtIndex(index));
    }
    if (str is null) error(DWT.ERROR_CANNOT_GET_ITEM);
    return str.getString();
}

/**
 * Returns the number of items contained in the receiver's list.
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
    if ((style & DWT.READ_ONLY) !is 0) {
        return cast(int)/*64*/(cast(NSPopUpButton)view).numberOfItems();
    } else {
        return cast(int)/*64*/(cast(NSComboBox)view).numberOfItems();
    }
}

/**
 * Returns the height of the area which would be used to
 * display <em>one</em> of the items in the receiver's list.
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
    //TODO - not supported by the OS
    return 26;
}

/**
 * Returns a (possibly empty) array of <code>String</code>s which are
 * the items in the receiver's list.
 * <p>
 * Note: This is not the actual structure used by the receiver
 * to maintain its list of items, so modifying the array will
 * not affect the receiver.
 * </p>
 *
 * @return the items in the receiver's list
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String [] getItems () {
    checkWidget ();
    NSUInteger count = getItemCount ();
    String [] result = new String [count];
    for (NSUInteger i=0; i<count; i++) result [i] = getItem (i);
    return result;
}

/**
 * Returns <code>true</code> if the receiver's list is visible,
 * and <code>false</code> otherwise.
 * <p>
 * If one of the receiver's ancestors is not visible or some
 * other condition makes the receiver not visible, this method
 * may still indicate that it is considered visible even though
 * it may not actually be showing.
 * </p>
 *
 * @return the receiver's list's visibility state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public bool getListVisible () {
    //TODO
    return false;
}

int getMininumHeight () {
    return getTextHeight ();
}

/**
 * Returns the orientation of the receiver.
 *
 * @return the orientation style
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.1.2
 */
public int getOrientation () {
    checkWidget();
    return style & (DWT.LEFT_TO_RIGHT | DWT.RIGHT_TO_LEFT);
}

/**
 * Returns a <code>Point</code> whose x coordinate is the
 * character position representing the start of the selection
 * in the receiver's text field, and whose y coordinate is the
 * character position representing the end of the selection.
 * An "empty" selection is indicated by the x and y coordinates
 * having the same value.
 * <p>
 * Indexing is zero based.  The range of a selection is from
 * 0..N where N is the number of characters in the widget.
 * </p>
 *
 * @return a point representing the selection start and end
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Point getSelection () {
    checkWidget ();
    if ((style & DWT.READ_ONLY) !is 0) {
        return new Point (0, cast(int) getCharCount ());
    } else {
        if (selectionRange is null) {
            NSString str = (new NSTextFieldCell ((cast(NSTextField) view).cell ())).title ();
            return new Point(cast(int)/*64*/str.length (), cast(int)/*64*/str.length ());
        }
        return new Point(cast(int)/*64*/selectionRange.location, cast(int)/*64*/(selectionRange.location + selectionRange.length));
    }
}

/**
 * Returns the zero-relative index of the item which is currently
 * selected in the receiver's list, or -1 if no item is selected.
 *
 * @return the index of the selected item
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getSelectionIndex () {
    checkWidget ();
    if ((style & DWT.READ_ONLY) !is 0) {
        return cast(int)/*64*/(cast(NSPopUpButton)view).indexOfSelectedItem();
    } else {
        return (int)/*64*/((NSComboBox)view).indexOfSelectedItem();
    }
}

/**
 * Returns a string containing a copy of the contents of the
 * receiver's text field, or an empty string if there are no
 * contents.
 *
 * @return the receiver's text
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String getText () {
    checkWidget ();
    return new_String (getText(0, -1));
}

char [] getText (int start, int end) {
    NSString str;
    if ((style & DWT.READ_ONLY) !is 0) {
        str = (cast(NSPopUpButton)view).titleOfSelectedItem();
    } else {
        str = (new NSCell((cast(NSComboBox)view).cell())).title();
    }
    if (str is null) return new char[0];
    NSRange range = NSRange ();
    range.location = start;
    if (end is -1) {
        NSUInteger length = str.length();
        range.length = length - start;
    } else {
        range.length = end - start;
    }
    wchar [] buffer= new wchar [range.length];
    str.getCharacters(buffer.ptr, range);
    return buffer.fromString16();
}

/**
 * Returns the height of the receivers's text field.
 *
 * @return the text height
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getTextHeight () {
    checkWidget();
    NSCell cell;
    if ((style & DWT.READ_ONLY) !is 0) {
        cell = ((NSPopUpButton)view).cell();
    } else {
        cell = ((NSComboBox)view).cell();
    }
    return (int)cell.cellSize().height;
}

/**
 * Returns the maximum number of characters that the receiver's
 * text field is capable of holding. If this has not been changed
 * by <code>setTextLimit()</code>, it will be the constant
 * <code>Combo.LIMIT</code>.
 *
 * @return the text limit
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #LIMIT
 */
public int getTextLimit () {
    checkWidget();
    return textLimit;
}

/**
 * Gets the number of items that are visible in the drop
 * down portion of the receiver's list.
 * <p>
 * Note: This operation is a hint and is not supported on
 * platforms that do not have this concept.
 * </p>
 *
 * @return the number of items that are visible
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public int getVisibleItemCount () {
    checkWidget ();
    if ((style & DWT.READ_ONLY) !is 0) {
        return getItemCount ();
    } else {
        return cast(int)/*64*/(cast(NSComboBox)view).numberOfVisibleItems();
    }
}

/**
 * Searches the receiver's list starting at the first item
 * (index 0) until an item is found that is equal to the
 * argument, and returns the index of that item. If no item
 * is found, returns -1.
 *
 * @param string the search item
 * @return the index of the item
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the string is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int indexOf (String string) {
    return indexOf (string, 0);
}

/**
 * Searches the receiver's list starting at the given,
 * zero-relative index until an item is found that is equal
 * to the argument, and returns the index of that item. If
 * no item is found or the starting index is out of range,
 * returns -1.
 *
 * @param string the search item
 * @param start the zero-relative index at which to begin the search
 * @return the index of the item
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the string is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int indexOf (String string, int start) {
    checkWidget();
    if (string is null) error (DWT.ERROR_NULL_ARGUMENT);
    int count = getItemCount ();
    if (!(0 <= start && start < count)) return -1;
    for (int i=start; i<count; i++) {
        if (string.equals (getItem (i))) {
            return i;
        }
    }
    return -1;
}

void insertEditText (String string) {
    ignoreVerify = true;
    NSUInteger length_ = string.length ();
    Point selection = getSelection ();
    if (hasFocus ()) {
        if (textLimit !is LIMIT) {
            int charCount = getCharCount();
            if (charCount - (selection.y - selection.x) + length_ > textLimit) {
                length_ = textLimit - charCount + (selection.y - selection.x);
            }
        }
        char [] buffer = new char [length_];
        string.getChars (0, buffer.length, buffer, 0);
        NSString nsstring = NSString.stringWithCharacters (buffer.toString16().ptr, buffer.length);
        NSText fieldEditor = ((NSTextField) view).currentEditor ();
        fieldEditor.replaceCharactersInRange (fieldEditor.selectedRange (), nsstring);
        selectionRange = null;
    } else {
        String oldText = getText ();
        if (textLimit !is LIMIT) {
            int charCount = oldText.length ();
            if (charCount - (selection.y - selection.x) + length_ > textLimit) {
                string = string.substring(0, textLimit - charCount + (selection.y - selection.x));
            }
        }
        String newText = oldText.substring (0, selection.x) ~ string ~ oldText.substring (selection.y);
        NSString nsstring = NSString.stringWith(newText);
        (new NSCell ((cast(NSTextField) view).cell ())).setTitle (nsstring);
        selectionRange = null;
        setSelection (new Point(selection.x + string.length (), 0));
    }
    ignoreVerify = false;
}

bool isEventView (int /*long*/ id) {
    return true;
}

void mouseDown(int /*long*/ id, int /*long*/ sel, int /*long*/ theEvent) {
    // If this is a combo box with an editor field and the control is disposed
    // while the view's cell editor is open we crash while tearing down the
    // popup window. Fix is to retain the view before letting Cocoa track
    // the mouse events.

    // 'view' will be cleared if disposed during the mouseDown so cache it.
    NSView viewCopy = view;
    viewCopy.retain();
    super.mouseDown(id, sel, theEvent);
    viewCopy.release();
}

/**
 * Pastes text from clipboard.
 * <p>
 * The selected text is deleted from the widget
 * and new text inserted from the clipboard.
 * </p>
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.1
 */
public void paste () {
    checkWidget ();
    if ((style & DWT.READ_ONLY) !is 0) return;
    Point selection = getSelection ();
    int start = selection.x, end = selection.y;
    String text = getText ();
    String leftText = text.substring (0, start);
    String rightText = text.substring (end, text.length ());
    String newText = getClipboardText ();
    if (newText is null) return;
    if (hooks (DWT.Verify) || filters (DWT.Verify)) {
        newText = verifyText (newText, start, end, null);
        if (newText is null) return;
    }
    if (textLimit !is LIMIT) {
        int charCount = text.length ();
        if (charCount - (end - start) + newText.length() > textLimit) {
            newText = newText.substring(0, textLimit - charCount + (end - start));
        }
    }
    setText (leftText ~ newText ~ rightText, false);
    start += newText.length ();
    setSelection (new Point (start, start));
    sendEvent (DWT.Modify);
}

void register() {
    super.register();
    display.addWidget((cast(NSControl)view).cell(), this);
}

void releaseWidget () {
    super.releaseWidget ();
    if ((style & DWT.READ_ONLY) is 0) {
        ((NSControl)view).abortEditing();
    }
    selectionRange = null;
}

/**
 * Removes the item from the receiver's list at the given
 * zero-relative index.
 *
 * @param index the index for the item
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_RANGE - if the index is not between 0 and the number of elements in the list minus 1 (inclusive)</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void remove (int index) {
    checkWidget ();
    if (index is -1) error (DWT.ERROR_INVALID_RANGE);
    int count = getItemCount ();
    if (0 > index || index >= count) error (DWT.ERROR_INVALID_RANGE);
    if ((style & DWT.READ_ONLY) !is 0) {
        (cast(NSPopUpButton)view).removeItemAtIndex(index);
    } else {
        (cast(NSComboBox)view).removeItemAtIndex(index);
    }
}

/**
 * Removes the items from the receiver's list which are
 * between the given zero-relative start and end
 * indices (inclusive).
 *
 * @param start the start of the range
 * @param end the end of the range
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_RANGE - if either the start or end are not between 0 and the number of elements in the list minus 1 (inclusive)</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void remove (int start, int end) {
    checkWidget();
    if (start > end) return;
    int count = getItemCount ();
    if (!(0 <= start && start <= end && end < count)) {
        error (DWT.ERROR_INVALID_RANGE);
    }
    int newEnd = Math.min (end, count - 1);
    for (int i=newEnd; i>=start; i--) {
        remove(i);
    }
}

/**
 * Searches the receiver's list starting at the first item
 * until an item is found that is equal to the argument,
 * and removes that item from the list.
 *
 * @param string the item to remove
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the string is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the string is not found in the list</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void remove (String string) {
    checkWidget ();
    if (string is null) error (DWT.ERROR_NULL_ARGUMENT);
    int index = indexOf (string, 0);
    if (index is -1) error (DWT.ERROR_INVALID_ARGUMENT);
    remove (index);
}

/**
 * Removes all of the items from the receiver's list and clear the
 * contents of receiver's text field.
 * <p>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void removeAll () {
    checkWidget ();
    if ((style & DWT.READ_ONLY) !is 0) {
        (cast(NSPopUpButton)view).removeAllItems();
    } else {
        setText ("", true);
        (cast(NSComboBox)view).removeAllItems();
    }
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the receiver's text is modified.
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
 * @see ModifyListener
 * @see #addModifyListener
 */
public void removeModifyListener (ModifyListener listener) {
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (DWT.Modify, listener);
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
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (DWT.Selection, listener);
    eventTable.unhook (DWT.DefaultSelection,listener);
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the control is verified.
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
 * @see VerifyListener
 * @see #addVerifyListener
 *
 * @since 3.1
 */
public void removeVerifyListener (VerifyListener listener) {
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (DWT.Verify, listener);
}

/**
 * Selects the item at the given zero-relative index in the receiver's
 * list.  If the item at the index was already selected, it remains
 * selected. Indices that are out of range are ignored.
 *
 * @param index the index of the item to select
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void select (int index) {
    checkWidget ();
    int count = getItemCount ();
    ignoreSelection = true;
    if (0 <= index && index < count) {
        if ((style & DWT.READ_ONLY) !is 0) {
            (cast(NSPopUpButton)view).selectItemAtIndex(index);
        } else {
            (cast(NSComboBox)view).selectItemAtIndex(index);
        }
    }
    ignoreSelection = false;
    sendEvent (DWT.Modify);
}

void sendSelection () {
    sendEvent(DWT.Modify);
    if (!ignoreSelection) postEvent(DWT.Selection);
}

bool sendKeyEvent (NSEvent nsEvent, int type) {
    bool result = super.sendKeyEvent (nsEvent, type);
    if (!result) return result;
    int stateMask = 0;
    NSUInteger modifierFlags = nsEvent.modifierFlags();
    if ((modifierFlags & OS.NSAlternateKeyMask) !is 0) stateMask |= DWT.ALT;
    if ((modifierFlags & OS.NSShiftKeyMask) !is 0) stateMask |= DWT.SHIFT;
    if ((modifierFlags & OS.NSControlKeyMask) !is 0) stateMask |= DWT.CONTROL;
    if ((modifierFlags & OS.NSCommandKeyMask) !is 0) stateMask |= DWT.COMMAND;
    if (type !is DWT.KeyDown)  return result;
    ushort keyCode = nsEvent.keyCode ();
    if (stateMask is DWT.COMMAND) {
        switch (keyCode) {
            case 7: /* X */
                cut ();
                return false;
            case 8: /* C */
                copy ();
                return false;
            case 9: /* V */
                paste ();
                return false;
            case 0: /* A */
                if ((style & DWT.READ_ONLY) is 0) {
                    ((NSComboBox)view).selectText(null);
                    return false;
                }
            default:
        }
    }
    switch (keyCode) {
    case 76: /* KP Enter */
    case 36: /* Return */
        postEvent (DWT.DefaultSelection);
            default:
    return result;
}

void updateBackground () {
    NSColor nsColor = null;
    if (backgroundImage !is null) {
        nsColor = NSColor.colorWithPatternImage(backgroundImage.handle);
    } else if (background !is null) {
        nsColor = NSColor.colorWithDeviceRed(background[0], background[1], background[2], background[3]);
    } else {
        nsColor = NSColor.textBackgroundColor ();
    }

    if ((style & DWT.READ_ONLY) !is 0) {
        //TODO
    } else {
        (cast(NSTextField)view).setBackgroundColor(nsColor);
    }
}

void setBounds (int x, int y, int width, int height, bool move, bool resize) {
    /*
     * Feature in Cocoa.  Attempting to create an NSComboBox with a
     * height > 27 spews a very long warning message to stdout and
     * often draws the combo incorrectly.  The workaround is to limit
     * the height of editable Combos to the height that is required
     * to display their text.
     */
    if ((style & DWT.READ_ONLY) is 0) {
        NSControl widget = cast(NSControl)view;
        NSSize size = widget.cell ().cellSize ();
        height = Math.min (height, cast(int)Math.ceil (size.height));
    }
    super.setBounds (x, y, width, height, move, resize);
}

void setForeground (Carbon.CGFloat [] color) {
    NSColor nsColor;
    if (color is null) {
        nsColor = NSColor.textColor ();
    } else {
        nsColor = NSColor.colorWithDeviceRed(color[0], color[1], color[2], 1);
    }
    if ((style & DWT.READ_ONLY) !is 0) {
        //TODO
    } else {
        (cast(NSTextField)view).setTextColor(nsColor);
    }
}

/**
 * Sets the text of the item in the receiver's list at the given
 * zero-relative index to the string argument.
 *
 * @param index the index for the item
 * @param string the new text for the item
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_RANGE - if the index is not between 0 and the number of elements in the list minus 1 (inclusive)</li>
 *    <li>ERROR_NULL_ARGUMENT - if the string is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setItem (int index, String string) {
    checkWidget ();
    //if (string is null) error (DWT.ERROR_NULL_ARGUMENT);
    int count = getItemCount ();
    if (0 > index || index >= count) error (DWT.ERROR_INVALID_RANGE);
    NSString str = NSString.stringWith(string);
    if ((style & DWT.READ_ONLY) !is 0) {
        NSMenuItem nsItem = (cast(NSPopUpButton)view).itemAtIndex(index);
        nsItem.setTitle(str);
    } else {
        NSComboBox widget = cast(NSComboBox)view;
        widget.insertItemWithObjectValue(str, index);
        widget.removeItemAtIndex(index + 1);
    }
}

/**
 * Sets the receiver's list to be the given array of items.
 *
 * @param items the array of items
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the items array is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if an item in the items array is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setItems (String [] items) {
    checkWidget();
    if (items is null) error (DWT.ERROR_NULL_ARGUMENT);
    for (int i=0; i<items.length; i++) {
        if (items [i] is null) error (DWT.ERROR_INVALID_ARGUMENT);
    }
    removeAll();
    if (items.length is 0) return;
    for (int i= 0; i < items.length; i++) {
        NSString str = NSString.stringWith(items[i]);
        if ((style & DWT.READ_ONLY) !is 0) {
            NSMenu nsMenu = (cast(NSPopUpButton)view).menu();
            NSMenuItem nsItem = cast(NSMenuItem)(new NSMenuItem()).alloc();
            nsItem.initWithTitle(str, null, NSString.stringWith(""));
            nsMenu.addItem(nsItem);
            nsItem.release();
            //clear the selection
            ((NSPopUpButton)view).selectItemAtIndex(-1);
        } else {
            (cast(NSComboBox)view).addItemWithObjectValue(str);
        }
    }
}

/**
 * Marks the receiver's list as visible if the argument is <code>true</code>,
 * and marks it invisible otherwise.
 * <p>
 * If one of the receiver's ancestors is not visible or some
 * other condition makes the receiver not visible, marking
 * it visible may not actually cause it to be displayed.
 * </p>
 *
 * @param visible the new visibility state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public void setListVisible (bool visible) {
    checkWidget ();
    if ((style & DWT.READ_ONLY) !is 0) {
        (cast(NSPopUpButton)view).setPullsDown(visible);
    } else {
    }
}

/**
 * Sets the orientation of the receiver, which must be one
 * of the constants <code>DWT.LEFT_TO_RIGHT</code> or <code>DWT.RIGHT_TO_LEFT</code>.
 * <p>
 *
 * @param orientation new orientation style
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.1.2
 */
public void setOrientation (int orientation) {
    checkWidget();
}

/**
 * Sets the selection in the receiver's text field to the
 * range specified by the argument whose x coordinate is the
 * start of the selection and whose y coordinate is the end
 * of the selection.
 *
 * @param selection a point representing the new selection start and end
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the point is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSelection (Point selection) {
    checkWidget ();
    if (selection is null) error (DWT.ERROR_NULL_ARGUMENT);
    if ((style & DWT.READ_ONLY) is 0) {
        NSComboBox widget = (NSComboBox)view;
        NSString str = (new NSCell((cast(NSComboBox)view).cell())).title();
        NSUInteger length = str.length();
        NSUInteger start = Math.min (Math.max (Math.min (selection.x, selection.y), 0), length);
        NSUInteger end = Math.min (Math.max (Math.max (selection.x, selection.y), 0), length);
        selectionRangeStruct = NSRange();
        selectionRange = &selectionRangeStruct;
        selectionRange.location = start;
        selectionRange.length = end - start;
        NSText fieldEditor = widget.currentEditor();
        if (fieldEditor !is null) fieldEditor.setSelectedRange(selectionRangeStruct);
    }
}

/**
 * Sets the contents of the receiver's text field to the
 * given string.
 * <p>
 * This call is ignored when the receiver is read only and
 * the given string is not in the receiver's list.
 * </p>
 * <p>
 * Note: The text field in a <code>Combo</code> is typically
 * only capable of displaying a single line of text. Thus,
 * setting the text to a string containing line breaks or
 * other special characters will probably cause it to
 * display incorrectly.
 * </p>
 *
 * @param string the new text
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the string is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setText (String string) {
    checkWidget ();
    if (string is null) error (DWT.ERROR_NULL_ARGUMENT);
    setText (string, true);
}

void setText (String string, bool notify) {
    ignoreVerify = true;
    if (notify) {
        if (hooks (DWT.Verify) || filters (DWT.Verify)) {
            string = verifyText (string, 0, getCharCount (), null);
            if (string is null) return;
        }
    }
    if ((style & DWT.READ_ONLY) !is 0) {
        int index = indexOf (string);
        if (index !is -1 && index !is getSelectionIndex ()) {
            select (index);
            if (notify) sendEvent (DWT.Modify);
        }
    } else {
        char[] buffer = new char [Math.min(string.length (), textLimit)];
        string.getChars (0, buffer.length, buffer, 0);
        NSString nsstring = NSString.stringWithCharacters (buffer, buffer.length);
        new NSCell(((NSComboBox)view).cell()).setTitle(nsstring);
        if (notify) sendEvent (DWT.Modify);
    }
    selectionRange = null;
    ignoreVerify = false;
}

/**
 * Sets the maximum number of characters that the receiver's
 * text field is capable of holding to be the argument.
 * <p>
 * To reset this value to the default, use <code>setTextLimit(Combo.LIMIT)</code>.
 * Specifying a limit value larger than <code>Combo.LIMIT</code> sets the
 * receiver's limit to <code>Combo.LIMIT</code>.
 * </p>
 * @param limit new text limit
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_CANNOT_BE_ZERO - if the limit is zero</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #LIMIT
 */
public void setTextLimit (int limit) {
    checkWidget ();
    if (limit is 0) error (DWT.ERROR_CANNOT_BE_ZERO);
    textLimit = limit;
}

/**
 * Sets the number of items that are visible in the drop
 * down portion of the receiver's list.
 * <p>
 * Note: This operation is a hint and is not supported on
 * platforms that do not have this concept.
 * </p>
 *
 * @param count the new number of items to be visible
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public void setVisibleItemCount (int count) {
    checkWidget ();
    if (count < 0) return;
    if ((style & DWT.READ_ONLY) !is 0) {
        //TODO
    } else {
        (cast(NSComboBox)view).setNumberOfVisibleItems(count);
    }
}

bool shouldChangeTextInRange_replacementString(int /*long*/ id, int /*long*/ sel, int /*long*/ affectedCharRange, int /*long*/ replacementString) {
    NSRange range = new NSRange();
    OS.memmove(range, affectedCharRange, NSRange.sizeof);
    bool result = callSuperBoolean(id, sel, range, replacementString);
    if (hooks (DWT.Verify)) {
        String text = new NSString(replacementString).getString();
        NSEvent currentEvent = display.application.currentEvent();
        int /*long*/ type = currentEvent.type();
        if (type !is OS.NSKeyDown && type !is OS.NSKeyUp) currentEvent = null;
        String newText = verifyText(text, (int)/*64*/range.location, (int)/*64*/(range.location+range.length), currentEvent);
        if (newText is null) return false;
        if (text !is newText) {
            insertEditText(newText);
            result = false;
        }
        if (!result) sendEvent (DWT.Modify);
    }
    return result;
}

    NSNotification notification = new NSNotification(aNotification);
    NSText editor = new NSText(notification.object().id);
    selectionRangeStruct = editor.selectedRange();
}

void textDidChange (objc.id id, objc.SEL sel, objc.id aNotification) {
    super.textDidChange (id, sel, aNotification);
    postEvent (DWT.Modify);
}

NSRange textView_willChangeSelectionFromCharacterRange_toCharacterRange(objc.id id, objc.SEL sel, objc.id aTextView, objc.id oldSelectedCharRange, objc.id newSelectedCharRange) {
    /*
     * If the selection is changing as a result of the receiver getting focus
     * then return the receiver's last selection range, otherwise the full
     * text will be automatically selected.
     */
    if (receivingFocus && selectionRange !is null) return selectionRangeStruct;

    /* allow the selection change to proceed */
    NSRange result = NSRange();
    OS.memmove(&result, newSelectedCharRange, NSRange.sizeof);
    return result;
}

String verifyText (String string, int start, int end, NSEvent keyEvent) {
    Event event = new Event ();
    if (keyEvent !is null) setKeyState(event, DWT.MouseDown, keyEvent);
    event.text = string;
    event.start = start;
    event.end = end;
    /*
     * It is possible (but unlikely), that application
     * code could have disposed the widget in the verify
     * event.  If this happens, answer null to cancel
     * the operation.
     */
    sendEvent (DWT.Verify, event);
    if (!event.doit || isDisposed ()) return null;
    return event.text;
}

}
