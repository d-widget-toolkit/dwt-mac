/*******************************************************************************
 * Copyright (c) 2000, 2008 IBM Corporation and others.
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
module dwt.custom.CCombo;

import dwt.dwthelper.utils;
import dwt.dwthelper.Runnable;

static import tango.text.convert.Utf;
static import tango.text.Unicode;
static import tango.text.convert.Format;

/**
 * The CCombo class represents a selectable user interface object
 * that combines a text field and a list and issues notification
 * when an item is selected from the list.
 * <p>
 * CCombo was written to work around certain limitations in the native
 * combo box. Specifically, on win32, the height of a CCombo can be set;
 * attempts to set the height of a Combo are ignored. CCombo can be used
 * anywhere that having the increased flexibility is more important than
 * getting native L&F, but the decision should not be taken lightly.
 * There is no is no strict requirement that CCombo look or behave
 * the same as the native combo box.
 * </p>
 * <p>
 * Note that although this class is a subclass of <code>Composite</code>,
 * it does not make sense to add children to it, or set a layout on it.
 * </p>
 * <dl>
 * <dt><b>Styles:</b>
 * <dd>BORDER, READ_ONLY, FLAT</dd>
 * <dt><b>Events:</b>
 * <dd>DefaultSelection, Modify, Selection, Verify</dd>
 * </dl>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#ccombo">CCombo snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">DWT Example: CustomControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public final class CCombo : Composite {

    alias Composite.computeSize computeSize;

    Text text;
    List list;
    int visibleItemCount = 5;
    Shell popup;
    Button arrow;
    bool hasFocus;
    Listener listener, filter;
    Color foreground, background;
    Font font;
    Shell _shell;

    static const String PACKAGE_PREFIX = "dwt.custom."; //$NON-NLS-1$

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
 * @see DWT#BORDER
 * @see DWT#READ_ONLY
 * @see DWT#FLAT
 * @see Widget#getStyle()
 */
public this (Composite parent, int style) {
    super (parent, style = checkStyle (style));
    _shell = super.getShell ();

    int textStyle = DWT.SINGLE;
    if ((style & DWT.READ_ONLY) !is 0) textStyle |= DWT.READ_ONLY;
    if ((style & DWT.FLAT) !is 0) textStyle |= DWT.FLAT;
    text = new Text (this, textStyle);
    int arrowStyle = DWT.ARROW | DWT.DOWN;
    if ((style & DWT.FLAT) !is 0) arrowStyle |= DWT.FLAT;
    arrow = new Button (this, arrowStyle);

    listener = new class () Listener {
        public void handleEvent (Event event) {
             if (isDisposed ()) return;
             if (popup is event.widget) {
                 popupEvent (event);
                 return;
             }
             if (text is event.widget) {
                 textEvent (event);
                 return;
             }
             if (list is event.widget) {
                 listEvent (event);
                 return;
             }
             if (arrow is event.widget) {
                 arrowEvent (event);
                 return;
             }
             if (CCombo.this is event.widget) {
                 comboEvent (event);
                 return;
             }
             if (getShell () is event.widget) {
                 getDisplay().asyncExec(new Runnable() {
                     public void run() {
                         if (isDisposed ()) return;
                         handleFocus (DWT.FocusOut);
                     }
                 });
             }
         }
    };

    filter = new class() Listener {
        public void handleEvent(Event event) {
            if (isDisposed ()) return;
            Shell shell = (cast(Control)event.widget).getShell ();
            if (shell is this.outer.getShell ()) {
            if (isDisposed ()) return;
                handleFocus (DWT.FocusOut);
            }
        }
    };

    int [] comboEvents = [DWT.Dispose, DWT.FocusIn, DWT.Move, DWT.Resize];
    for (int i=0; i<comboEvents.length; i++) this.addListener (comboEvents [i], listener);

    int [] textEvents = [DWT.DefaultSelection, DWT.KeyDown, DWT.KeyUp, DWT.MenuDetect, DWT.Modify, DWT.MouseDown, DWT.MouseUp, DWT.MouseDoubleClick, DWT.MouseWheel, DWT.Traverse, DWT.FocusIn, DWT.Verify];
    for (int i=0; i<textEvents.length; i++) text.addListener (textEvents [i], listener);

    int [] arrowEvents = [DWT.MouseDown, DWT.MouseUp, DWT.Selection, DWT.FocusIn];
    for (int i=0; i<arrowEvents.length; i++) arrow.addListener (arrowEvents [i], listener);

    createPopup(null, -1);
    initAccessible();
}
static int checkStyle (int style) {
    int mask = DWT.BORDER | DWT.READ_ONLY | DWT.FLAT | DWT.LEFT_TO_RIGHT | DWT.RIGHT_TO_LEFT;
    return DWT.NO_FOCUS | (style & mask);
}
/**
 * Adds the argument to the end of the receiver's list.
 *
 * @param string the new item
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #add(String,int)
 */
public void add (String string) {
    checkWidget();
    // DWT extension: allow null for zero length string
    //if (string is null) DWT.error (DWT.ERROR_NULL_ARGUMENT);
    list.add (string);
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
    checkWidget();
    // DWT extension: allow null for zero length string
    //if (string is null) DWT.error (DWT.ERROR_NULL_ARGUMENT);
    list.add (string, index);
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
    if (listener is null) DWT.error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (DWT.Modify, typedListener);
}
/**
 * Adds the listener to the collection of listeners who will
 * be notified when the user changes the receiver's selection, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * <code>widgetSelected</code> is called when the combo's list selection changes.
 * <code>widgetDefaultSelected</code> is typically called when ENTER is pressed the combo's text area.
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
    checkWidget();
    if (listener is null) DWT.error (DWT.ERROR_NULL_ARGUMENT);
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
 * @since 3.3
 */
public void addVerifyListener (VerifyListener listener) {
    checkWidget();
    if (listener is null) DWT.error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (DWT.Verify,typedListener);
}
void arrowEvent (Event event) {
    switch (event.type) {
        case DWT.FocusIn: {
            handleFocus (DWT.FocusIn);
            break;
        }
        case DWT.MouseDown: {
            Event mouseEvent = new Event ();
            mouseEvent.button = event.button;
            mouseEvent.count = event.count;
            mouseEvent.stateMask = event.stateMask;
            mouseEvent.time = event.time;
            mouseEvent.x = event.x; mouseEvent.y = event.y;
            notifyListeners (DWT.MouseDown, mouseEvent);
            event.doit = mouseEvent.doit;
            break;
        }
        case DWT.MouseUp: {
            Event mouseEvent = new Event ();
            mouseEvent.button = event.button;
            mouseEvent.count = event.count;
            mouseEvent.stateMask = event.stateMask;
            mouseEvent.time = event.time;
            mouseEvent.x = event.x; mouseEvent.y = event.y;
            notifyListeners (DWT.MouseUp, mouseEvent);
            event.doit = mouseEvent.doit;
            break;
        }
        case DWT.Selection: {
            text.setFocus();
            dropDown (!isDropped ());
            break;
        }
        default:
    }
}
protected void checkSubclass () {
    String name = this.classinfo.name ();
    int index = name.lastIndexOf ('.');
    if (!name.substring (0, index + 1).equals (PACKAGE_PREFIX)) {
        DWT.error (DWT.ERROR_INVALID_SUBCLASS);
    }
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
    checkWidget ();
    text.clearSelection ();
    list.deselectAll ();
}
void comboEvent (Event event) {
    switch (event.type) {
        case DWT.Dispose:
            removeListener(DWT.Dispose, listener);
            notifyListeners(DWT.Dispose, event);
            event.type = DWT.None;

            if (popup !is null && !popup.isDisposed ()) {
                list.removeListener (DWT.Dispose, listener);
                popup.dispose ();
            }
            Shell shell = getShell ();
            shell.removeListener (DWT.Deactivate, listener);
            Display display = getDisplay ();
            display.removeFilter (DWT.FocusIn, filter);
            popup = null;
            text = null;
            list = null;
            arrow = null;
            _shell = null;
            break;
        case DWT.FocusIn:
            Control focusControl = getDisplay ().getFocusControl ();
            if (focusControl is arrow || focusControl is list) return;
            if (isDropped()) {
                list.setFocus();
            } else {
                text.setFocus();
            }
            break;
        case DWT.Move:
            dropDown (false);
            break;
        case DWT.Resize:
            internalLayout (false);
            break;
        default:
    }
}

public override Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    int width = 0, height = 0;
    String[] items = list.getItems ();
    GC gc = new GC (text);
    int spacer = gc.stringExtent (" ").x; //$NON-NLS-1$
    int textWidth = gc.stringExtent (text.getText ()).x;
    for (int i = 0; i < items.length; i++) {
        textWidth = Math.max (gc.stringExtent (items[i]).x, textWidth);
    }
    gc.dispose ();
    Point textSize = text.computeSize (DWT.DEFAULT, DWT.DEFAULT, changed);
    Point arrowSize = arrow.computeSize (DWT.DEFAULT, DWT.DEFAULT, changed);
    Point listSize = list.computeSize (DWT.DEFAULT, DWT.DEFAULT, changed);
    int borderWidth = getBorderWidth ();

    height = Math.max (textSize.y, arrowSize.y);
    width = Math.max (textWidth + 2*spacer + arrowSize.x + 2*borderWidth, listSize.x);
    if (wHint !is DWT.DEFAULT) width = wHint;
    if (hHint !is DWT.DEFAULT) height = hHint;
    return new Point (width + 2*borderWidth, height + 2*borderWidth);
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
 * @since 3.3
 */
public void copy () {
    checkWidget ();
    text.copy ();
}
void createPopup(String[] items, int selectionIndex) {
    // create shell and list
    popup = new Shell (getShell (), DWT.NO_TRIM | DWT.ON_TOP);
    int style = getStyle ();
    int listStyle = DWT.SINGLE | DWT.V_SCROLL;
    if ((style & DWT.FLAT) !is 0) listStyle |= DWT.FLAT;
    if ((style & DWT.RIGHT_TO_LEFT) !is 0) listStyle |= DWT.RIGHT_TO_LEFT;
    if ((style & DWT.LEFT_TO_RIGHT) !is 0) listStyle |= DWT.LEFT_TO_RIGHT;
    list = new List (popup, listStyle);
    if (font !is null) list.setFont (font);
    if (foreground !is null) list.setForeground (foreground);
    if (background !is null) list.setBackground (background);

    int [] popupEvents = [DWT.Close, DWT.Paint, DWT.Deactivate];
    for (int i=0; i<popupEvents.length; i++) popup.addListener (popupEvents [i], listener);
    int [] listEvents = [DWT.MouseUp, DWT.Selection, DWT.Traverse, DWT.KeyDown, DWT.KeyUp, DWT.FocusIn, DWT.Dispose];
    for (int i=0; i<listEvents.length; i++) list.addListener (listEvents [i], listener);

    if (items !is null) list.setItems (items);
    if (selectionIndex !is -1) list.setSelection (selectionIndex);
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
 * @since 3.3
 */
public void cut () {
    checkWidget ();
    text.cut ();
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
    if (0 <= index && index < list.getItemCount () &&
            index is list.getSelectionIndex() &&
            text.getText().equals(list.getItem(index))) {
        text.setText("");  //$NON-NLS-1$
        list.deselect (index);
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
    text.setText("");  //$NON-NLS-1$
    list.deselectAll ();
}
void dropDown (bool drop) {
    if (drop is isDropped ()) return;
    if (!drop) {
        popup.setVisible (false);
        if (!isDisposed () && isFocusControl()) {
            text.setFocus();
        }
        return;
    }
    if (!isVisible()) return;
    if (getShell() !is popup.getParent ()) {
        String[] items = list.getItems ();
        int selectionIndex = list.getSelectionIndex ();
        list.removeListener (DWT.Dispose, listener);
        popup.dispose();
        popup = null;
        list = null;
        createPopup (items, selectionIndex);
    }

    Point size = getSize ();
    int itemCount = list.getItemCount ();
    itemCount = (itemCount is 0) ? visibleItemCount : Math.min(visibleItemCount, itemCount);
    int itemHeight = list.getItemHeight () * itemCount;
    Point listSize = list.computeSize (DWT.DEFAULT, itemHeight, false);
    list.setBounds (1, 1, Math.max (size.x - 2, listSize.x), listSize.y);

    int index = list.getSelectionIndex ();
    if (index !is -1) list.setTopIndex (index);
    Display display = getDisplay ();
    Rectangle listRect = list.getBounds ();
    Rectangle parentRect = display.map (getParent (), null, getBounds ());
    Point comboSize = getSize ();
    Rectangle displayRect = getMonitor ().getClientArea ();
    int width = Math.max (comboSize.x, listRect.width + 2);
    int height = listRect.height + 2;
    int x = parentRect.x;
    int y = parentRect.y + comboSize.y;
    if (y + height > displayRect.y + displayRect.height) y = parentRect.y - height;
    if (x + width > displayRect.x + displayRect.width) x = displayRect.x + displayRect.width - listRect.width;
    popup.setBounds (x, y, width, height);
    popup.setVisible (true);
    if (isFocusControl()) list.setFocus ();
}
/*
 * Return the lowercase of the first non-'&' character following
 * an '&' character in the given string. If there are no '&'
 * characters in the given string, return '\0'.
 */
dchar _findMnemonic (String string) {
    if (string is null) return '\0';
    int index = 0;
    int length = string.length;
    do {
        while (index < length && string[index] !is '&') index++;
        if (++index >= length) return '\0';
        if (string.charAt(index) !is '&') {
            dchar[1] d; uint ate;
            auto d2 = tango.text.convert.Utf.toString32( string[ index .. Math.min( index +4, string.length )], d, &ate );
            auto d3 = tango.text.Unicode.toLower( d2, d2 );
            return d3[0];
        }
        index++;
    } while (index < length);
    return '\0';
}
/*
 * Return the Label immediately preceding the receiver in the z-order,
 * or null if none.
 */
Label getAssociatedLabel () {
    Control[] siblings = getParent ().getChildren ();
    for (int i = 0; i < siblings.length; i++) {
        if (siblings [i] is this) {
            if (i > 0 && ( null !is cast(Label)siblings [i-1] )) {
                return cast(Label) siblings [i-1];
            }
        }
    }
    return null;
}
public override Control [] getChildren () {
    checkWidget();
    return new Control [0];
}
/**
 * Gets the editable state.
 *
 * @return whether or not the receiver is editable
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public bool getEditable () {
    checkWidget ();
    return text.getEditable();
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
    checkWidget();
    return list.getItem (index);
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
    return list.getItemCount ();
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
    return list.getItemHeight ();
}
/**
 * Returns an array of <code>String</code>s which are the items
 * in the receiver's list.
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
    return list.getItems ();
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
    checkWidget ();
    return isDropped();
}
public override Menu getMenu() {
    return text.getMenu();
}
/**
 * Returns a <code>Point</code> whose x coordinate is the start
 * of the selection in the receiver's text field, and whose y
 * coordinate is the end of the selection. The returned values
 * are zero-relative. An "empty" selection as indicated by
 * the the x and y coordinates having the same value.
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
    return text.getSelection ();
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
    return list.getSelectionIndex ();
}
public Shell getShell () {
    checkWidget ();
    Shell shell = super.getShell ();
    if (shell !is _shell) {
        if (_shell !is null && !_shell.isDisposed ()) {
            _shell.removeListener (DWT.Deactivate, listener);
        }
        _shell = shell;
    }
    return _shell;
}
public int getStyle () {
    int style = super.getStyle ();
    style &= ~DWT.READ_ONLY;
    if (!text.getEditable()) style |= DWT.READ_ONLY;
    return style;
}
/**
 * Returns a string containing a copy of the contents of the
 * receiver's text field.
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
    return text.getText ();
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
    checkWidget ();
    return text.getLineHeight ();
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
 */
public int getTextLimit () {
    checkWidget ();
    return text.getTextLimit ();
}
/**
 * Gets the number of items that are visible in the drop
 * down portion of the receiver's list.
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
    return visibleItemCount;
}
void handleFocus (int type) {
    switch (type) {
        case DWT.FocusIn: {
            if (hasFocus) return;
            if (getEditable ()) text.selectAll ();
            hasFocus = true;
            Shell shell = getShell ();
            shell.removeListener (DWT.Deactivate, listener);
            shell.addListener (DWT.Deactivate, listener);
            Display display = getDisplay ();
            display.removeFilter (DWT.FocusIn, filter);
            display.addFilter (DWT.FocusIn, filter);
            Event e = new Event ();
            notifyListeners (DWT.FocusIn, e);
            break;
        }
        case DWT.FocusOut: {
            if (!hasFocus) return;
            Control focusControl = getDisplay ().getFocusControl ();
            if (focusControl is arrow || focusControl is list || focusControl is text) return;
            hasFocus = false;
            Shell shell = getShell ();
            shell.removeListener(DWT.Deactivate, listener);
            Display display = getDisplay ();
            display.removeFilter (DWT.FocusIn, filter);
            Event e = new Event ();
            notifyListeners (DWT.FocusOut, e);
            break;
        }
        default:
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
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int indexOf (String string) {
    checkWidget ();
    // DWT extension: allow null for zero length string
    //if (string is null) DWT.error (DWT.ERROR_NULL_ARGUMENT);
    return list.indexOf (string);
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
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int indexOf (String string, int start) {
    checkWidget ();
    // DWT extension: allow null for zero length string
    //if (string is null) DWT.error (DWT.ERROR_NULL_ARGUMENT);
    return list.indexOf (string, start);
}

void initAccessible() {
    AccessibleAdapter accessibleAdapter = new class() AccessibleAdapter {
        public void getName (AccessibleEvent e) {
            String name = null;
            Label label = getAssociatedLabel ();
            if (label !is null) {
                name = stripMnemonic (label.getText());
            }
            e.result = name;
        }
        public void getKeyboardShortcut(AccessibleEvent e) {
            String shortcut = null;
            Label label = getAssociatedLabel ();
            if (label !is null) {
                String text = label.getText ();
                if (text !is null) {
                    dchar mnemonic = _findMnemonic (text);
                    if (mnemonic !is '\0') {
                        shortcut = tango.text.convert.Format.Format( "Alt+{}", mnemonic ); //$NON-NLS-1$
                    }
                }
            }
            e.result = shortcut;
        }
        public void getHelp (AccessibleEvent e) {
            e.result = getToolTipText ();
        }
    };
    getAccessible ().addAccessibleListener (accessibleAdapter);
    text.getAccessible ().addAccessibleListener (accessibleAdapter);
    list.getAccessible ().addAccessibleListener (accessibleAdapter);

    arrow.getAccessible ().addAccessibleListener (new class() AccessibleAdapter {
        public void getName (AccessibleEvent e) {
            e.result = isDropped () ? DWT.getMessage ("SWT_Close") : DWT.getMessage ("SWT_Open"); //$NON-NLS-1$ //$NON-NLS-2$
        }
        public void getKeyboardShortcut (AccessibleEvent e) {
            e.result = "Alt+Down Arrow"; //$NON-NLS-1$
        }
        public void getHelp (AccessibleEvent e) {
            e.result = getToolTipText ();
        }
    });

    getAccessible().addAccessibleTextListener (new class() AccessibleTextAdapter {
        public void getCaretOffset (AccessibleTextEvent e) {
            e.offset = text.getCaretPosition ();
        }
        public void getSelectionRange(AccessibleTextEvent e) {
            Point sel = text.getSelection();
            e.offset = sel.x;
            e.length = sel.y - sel.x;
        }
    });

    getAccessible().addAccessibleControlListener (new class() AccessibleControlAdapter {
        public void getChildAtPoint (AccessibleControlEvent e) {
            Point testPoint = toControl (e.x, e.y);
            if (getBounds ().contains (testPoint)) {
                e.childID = ACC.CHILDID_SELF;
            }
        }

        public void getLocation (AccessibleControlEvent e) {
            Rectangle location = getBounds ();
            Point pt = getParent().toDisplay (location.x, location.y);
            e.x = pt.x;
            e.y = pt.y;
            e.width = location.width;
            e.height = location.height;
        }

        public void getChildCount (AccessibleControlEvent e) {
            e.detail = 0;
        }

        public void getRole (AccessibleControlEvent e) {
            e.detail = ACC.ROLE_COMBOBOX;
        }

        public void getState (AccessibleControlEvent e) {
            e.detail = ACC.STATE_NORMAL;
        }

        public void getValue (AccessibleControlEvent e) {
            e.result = getText ();
        }
    });

    text.getAccessible ().addAccessibleControlListener (new class() AccessibleControlAdapter {
        public void getRole (AccessibleControlEvent e) {
            e.detail = text.getEditable () ? ACC.ROLE_TEXT : ACC.ROLE_LABEL;
        }
    });

    arrow.getAccessible ().addAccessibleControlListener (new class() AccessibleControlAdapter {
        public void getDefaultAction (AccessibleControlEvent e) {
            e.result = isDropped () ? DWT.getMessage ("SWT_Close") : DWT.getMessage ("SWT_Open"); //$NON-NLS-1$ //$NON-NLS-2$
        }
    });
}
bool isDropped () {
    return popup.getVisible ();
}
public override bool isFocusControl () {
    checkWidget();
    if (text.isFocusControl () || arrow.isFocusControl () || list.isFocusControl () || popup.isFocusControl ()) {
        return true;
    }
    return super.isFocusControl ();
}
void internalLayout (bool changed) {
    if (isDropped ()) dropDown (false);
    Rectangle rect = getClientArea ();
    int width = rect.width;
    int height = rect.height;
    Point arrowSize = arrow.computeSize (DWT.DEFAULT, height, changed);
    text.setBounds (0, 0, width - arrowSize.x, height);
    arrow.setBounds (width - arrowSize.x, 0, arrowSize.x, arrowSize.y);
}
void listEvent (Event event) {
    switch (event.type) {
        case DWT.Dispose:
            if (getShell () !is popup.getParent ()) {
                String[] items = list.getItems ();
                int selectionIndex = list.getSelectionIndex ();
                popup = null;
                list = null;
                createPopup (items, selectionIndex);
            }
            break;
        case DWT.FocusIn: {
            handleFocus (DWT.FocusIn);
            break;
        }
        case DWT.MouseUp: {
            if (event.button !is 1) return;
            dropDown (false);
            break;
        }
        case DWT.Selection: {
            int index = list.getSelectionIndex ();
            if (index is -1) return;
            text.setText (list.getItem (index));
            text.selectAll ();
            list.setSelection (index);
            Event e = new Event ();
            e.time = event.time;
            e.stateMask = event.stateMask;
            e.doit = event.doit;
            notifyListeners (DWT.Selection, e);
            event.doit = e.doit;
            break;
        }
        case DWT.Traverse: {
            switch (event.detail) {
                case DWT.TRAVERSE_RETURN:
                case DWT.TRAVERSE_ESCAPE:
                case DWT.TRAVERSE_ARROW_PREVIOUS:
                case DWT.TRAVERSE_ARROW_NEXT:
                    event.doit = false;
                    break;
                case DWT.TRAVERSE_TAB_NEXT:
                case DWT.TRAVERSE_TAB_PREVIOUS:
                    event.doit = text.traverse(event.detail);
                    event.detail = DWT.TRAVERSE_NONE;
                    if (event.doit) dropDown(false);
                    return;
                default:
            }
            Event e = new Event ();
            e.time = event.time;
            e.detail = event.detail;
            e.doit = event.doit;
            e.character = event.character;
            e.keyCode = event.keyCode;
            notifyListeners (DWT.Traverse, e);
            event.doit = e.doit;
            event.detail = e.detail;
            break;
        }
        case DWT.KeyUp: {
            Event e = new Event ();
            e.time = event.time;
            e.character = event.character;
            e.keyCode = event.keyCode;
            e.stateMask = event.stateMask;
            notifyListeners (DWT.KeyUp, e);
            break;
        }
        case DWT.KeyDown: {
            if (event.character is DWT.ESC) {
                // Escape key cancels popup list
                dropDown (false);
            }
            if ((event.stateMask & DWT.ALT) !is 0 && (event.keyCode is DWT.ARROW_UP || event.keyCode is DWT.ARROW_DOWN)) {
                dropDown (false);
            }
            if (event.character is DWT.CR) {
                // Enter causes default selection
                dropDown (false);
                Event e = new Event ();
                e.time = event.time;
                e.stateMask = event.stateMask;
                notifyListeners (DWT.DefaultSelection, e);
            }
            // At this point the widget may have been disposed.
            // If so, do not continue.
            if (isDisposed ()) break;
            Event e = new Event();
            e.time = event.time;
            e.character = event.character;
            e.keyCode = event.keyCode;
            e.stateMask = event.stateMask;
            notifyListeners(DWT.KeyDown, e);
            break;

        }
        default:
    }
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
 * @since 3.3
 */
public void paste () {
    checkWidget ();
    text.paste ();
}
void popupEvent(Event event) {
    switch (event.type) {
        case DWT.Paint:
            // draw black rectangle around list
            Rectangle listRect = list.getBounds();
            Color black = getDisplay().getSystemColor(DWT.COLOR_BLACK);
            event.gc.setForeground(black);
            event.gc.drawRectangle(0, 0, listRect.width + 1, listRect.height + 1);
            break;
        case DWT.Close:
            event.doit = false;
            dropDown (false);
            break;
        case DWT.Deactivate:
            /*
             * Bug in GTK. When the arrow button is pressed the popup control receives a
             * deactivate event and then the arrow button receives a selection event. If
             * we hide the popup in the deactivate event, the selection event will show
             * it again. To prevent the popup from showing again, we will let the selection
             * event of the arrow button hide the popup.
             * In Windows, hiding the popup during the deactivate causes the deactivate
             * to be called twice and the selection event to be disappear.
             */
            if (!"carbon".equals(DWT.getPlatform())) {
                Point point = arrow.toControl(getDisplay().getCursorLocation());
                Point size = arrow.getSize();
                Rectangle rect = new Rectangle(0, 0, size.x, size.y);
                if (!rect.contains(point)) dropDown (false);
            } else {
                dropDown(false);
            }
            break;
        default:
    }
}
public override void redraw () {
    super.redraw();
    text.redraw();
    arrow.redraw();
    if (popup.isVisible()) list.redraw();
}
public override void redraw (int x, int y, int width, int height, bool all) {
    super.redraw(x, y, width, height, true);
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
    checkWidget();
    list.remove (index);
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
    list.remove (start, end);
}
/**
 * Searches the receiver's list starting at the first item
 * until an item is found that is equal to the argument,
 * and removes that item from the list.
 *
 * @param string the item to remove
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the string is not found in the list</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void remove (String string) {
    checkWidget();
    // DWT extension: allow null for zero length string
    //if (string is null) DWT.error (DWT.ERROR_NULL_ARGUMENT);
    list.remove (string);
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
    checkWidget();
    text.setText (""); //$NON-NLS-1$
    list.removeAll ();
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
    if (listener is null) DWT.error (DWT.ERROR_NULL_ARGUMENT);
    removeListener(DWT.Modify, listener);
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
    if (listener is null) DWT.error (DWT.ERROR_NULL_ARGUMENT);
    removeListener(DWT.Selection, listener);
    removeListener(DWT.DefaultSelection,listener);
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
 * @since 3.3
 */
public void removeVerifyListener (VerifyListener listener) {
    checkWidget();
    if (listener is null) DWT.error (DWT.ERROR_NULL_ARGUMENT);
    removeListener(DWT.Verify, listener);
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
    checkWidget();
    if (index is -1) {
        list.deselectAll ();
        text.setText (""); //$NON-NLS-1$
        return;
    }
    if (0 <= index && index < list.getItemCount()) {
        if (index !is getSelectionIndex()) {
            text.setText (list.getItem (index));
            text.selectAll ();
            list.select (index);
            list.showSelection ();
        }
    }
}
public override void setBackground (Color color) {
    super.setBackground(color);
    background = color;
    if (text !is null) text.setBackground(color);
    if (list !is null) list.setBackground(color);
    if (arrow !is null) arrow.setBackground(color);
}
/**
 * Sets the editable state.
 *
 * @param editable the new editable state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public void setEditable (bool editable) {
    checkWidget ();
    text.setEditable(editable);
}
public override void setEnabled (bool enabled) {
    super.setEnabled(enabled);
    if (popup !is null) popup.setVisible (false);
    if (text !is null) text.setEnabled(enabled);
    if (arrow !is null) arrow.setEnabled(enabled);
}
public override bool setFocus () {
    checkWidget();
    if (!isEnabled () || !isVisible ()) return false;
    if (isFocusControl ()) return true;
    return text.setFocus ();
}
public override void setFont (Font font) {
    super.setFont (font);
    this.font = font;
    text.setFont (font);
    list.setFont (font);
    internalLayout (true);
}
public override void setForeground (Color color) {
    super.setForeground(color);
    foreground = color;
    if (text !is null) text.setForeground(color);
    if (list !is null) list.setForeground(color);
    if (arrow !is null) arrow.setForeground(color);
}
/**
 * Sets the text of the item in the receiver's list at the given
 * zero-relative index to the string argument. This is equivalent
 * to <code>remove</code>'ing the old item at the index, and then
 * <code>add</code>'ing the new item at that index.
 *
 * @param index the index for the item
 * @param string the new text for the item
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_RANGE - if the index is not between 0 and the number of elements in the list minus 1 (inclusive)</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setItem (int index, String string) {
    checkWidget();
    list.setItem (index, string);
}
/**
 * Sets the receiver's list to be the given array of items.
 *
 * @param items the array of items
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if an item in the items array is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setItems (String [] items) {
    checkWidget ();
    list.setItems (items);
    if (!text.getEditable ()) text.setText (""); //$NON-NLS-1$
}
/**
 * Sets the layout which is associated with the receiver to be
 * the argument which may be null.
 * <p>
 * Note: No Layout can be set on this Control because it already
 * manages the size and position of its children.
 * </p>
 *
 * @param layout the receiver's new layout or null
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public override void setLayout (Layout layout) {
    checkWidget ();
    return;
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
    dropDown(visible);
}
public override void setMenu(Menu menu) {
    text.setMenu(menu);
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
    checkWidget();
    if (selection is null) DWT.error (DWT.ERROR_NULL_ARGUMENT);
    text.setSelection (selection.x, selection.y);
}

/**
 * Sets the contents of the receiver's text field to the
 * given string.
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
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setText (String string) {
    checkWidget();
    // DWT extension: allow null for zero length string
    //if (string is null) DWT.error (DWT.ERROR_NULL_ARGUMENT);
    int index = list.indexOf (string);
    if (index is -1) {
        list.deselectAll ();
        text.setText (string);
        return;
    }
    text.setText (string);
    text.selectAll ();
    list.setSelection (index);
    list.showSelection ();
}
/**
 * Sets the maximum number of characters that the receiver's
 * text field is capable of holding to be the argument.
 *
 * @param limit new text limit
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_CANNOT_BE_ZERO - if the limit is zero</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setTextLimit (int limit) {
    checkWidget();
    text.setTextLimit (limit);
}

public override void setToolTipText (String string) {
    checkWidget();
    super.setToolTipText(string);
    arrow.setToolTipText (string);
    text.setToolTipText (string);
}

public override void setVisible (bool visible) {
    super.setVisible(visible);
    /*
     * At this point the widget may have been disposed in a FocusOut event.
     * If so then do not continue.
     */
    if (isDisposed ()) return;
    // TEMPORARY CODE
    if (popup is null || popup.isDisposed ()) return;
    if (!visible) popup.setVisible (false);
}
/**
 * Sets the number of items that are visible in the drop
 * down portion of the receiver's list.
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
    visibleItemCount = count;
}
String stripMnemonic (String string) {
    int index = 0;
    int length_ = string.length ();
    do {
        while ((index < length_) && (string.charAt(index) !is '&')) index++;
        if (++index >= length_) return string;
        if (string.charAt(index) !is '&') {
            return string[0 .. index-1] ~ string[index .. length_];
        }
        index++;
    } while (index < length_);
    return string;
}
void textEvent (Event event) {
    switch (event.type) {
        case DWT.FocusIn: {
            handleFocus (DWT.FocusIn);
            break;
        }
        case DWT.DefaultSelection: {
            dropDown (false);
            Event e = new Event ();
            e.time = event.time;
            e.stateMask = event.stateMask;
            notifyListeners (DWT.DefaultSelection, e);
            break;
        }
        case DWT.KeyDown: {
            Event keyEvent = new Event ();
            keyEvent.time = event.time;
            keyEvent.character = event.character;
            keyEvent.keyCode = event.keyCode;
            keyEvent.stateMask = event.stateMask;
            notifyListeners (DWT.KeyDown, keyEvent);
            if (isDisposed ()) break;
            event.doit = keyEvent.doit;
            if (!event.doit) break;
            if (event.keyCode is DWT.ARROW_UP || event.keyCode is DWT.ARROW_DOWN) {
                event.doit = false;
                if ((event.stateMask & DWT.ALT) !is 0) {
                    bool dropped = isDropped ();
                    text.selectAll ();
                    if (!dropped) setFocus ();
                    dropDown (!dropped);
                    break;
                }

                int oldIndex = getSelectionIndex ();
                if (event.keyCode is DWT.ARROW_UP) {
                    select (Math.max (oldIndex - 1, 0));
                } else {
                    select (Math.min (oldIndex + 1, getItemCount () - 1));
                }
                if (oldIndex !is getSelectionIndex ()) {
                    Event e = new Event();
                    e.time = event.time;
                    e.stateMask = event.stateMask;
                    notifyListeners (DWT.Selection, e);
                }
                if (isDisposed ()) break;
            }

            // Further work : Need to add support for incremental search in
            // pop up list as characters typed in text widget
            break;
        }
        case DWT.KeyUp: {
            Event e = new Event ();
            e.time = event.time;
            e.character = event.character;
            e.keyCode = event.keyCode;
            e.stateMask = event.stateMask;
            notifyListeners (DWT.KeyUp, e);
            event.doit = e.doit;
            break;
        }
        case DWT.MenuDetect: {
            Event e = new Event ();
            e.time = event.time;
            notifyListeners (DWT.MenuDetect, e);
            break;
        }
        case DWT.Modify: {
            list.deselectAll ();
            Event e = new Event ();
            e.time = event.time;
            notifyListeners (DWT.Modify, e);
            break;
        }
        case DWT.MouseDown: {
            Event mouseEvent = new Event ();
            mouseEvent.button = event.button;
            mouseEvent.count = event.count;
            mouseEvent.stateMask = event.stateMask;
            mouseEvent.time = event.time;
            mouseEvent.x = event.x; mouseEvent.y = event.y;
            notifyListeners (DWT.MouseDown, mouseEvent);
            if (isDisposed ()) break;
            event.doit = mouseEvent.doit;
            if (!event.doit) break;
            if (event.button !is 1) return;
            if (text.getEditable ()) return;
            bool dropped = isDropped ();
            text.selectAll ();
            if (!dropped) setFocus ();
            dropDown (!dropped);
            break;
        }
        case DWT.MouseUp: {
            Event mouseEvent = new Event ();
            mouseEvent.button = event.button;
            mouseEvent.count = event.count;
            mouseEvent.stateMask = event.stateMask;
            mouseEvent.time = event.time;
            mouseEvent.x = event.x; mouseEvent.y = event.y;
            notifyListeners (DWT.MouseUp, mouseEvent);
            if (isDisposed ()) break;
            event.doit = mouseEvent.doit;
            if (!event.doit) break;
            if (event.button !is 1) return;
            if (text.getEditable ()) return;
            text.selectAll ();
            break;
        }
        case DWT.MouseDoubleClick: {
            Event mouseEvent = new Event ();
            mouseEvent.button = event.button;
            mouseEvent.count = event.count;
            mouseEvent.stateMask = event.stateMask;
            mouseEvent.time = event.time;
            mouseEvent.x = event.x; mouseEvent.y = event.y;
            notifyListeners (DWT.MouseDoubleClick, mouseEvent);
            break;
        }
        case DWT.MouseWheel: {
            Event keyEvent = new Event ();
            keyEvent.time = event.time;
            keyEvent.keyCode = event.count > 0 ? DWT.ARROW_UP : DWT.ARROW_DOWN;
            keyEvent.stateMask = event.stateMask;
            notifyListeners (DWT.KeyDown, keyEvent);
            if (isDisposed ()) break;
            event.doit = keyEvent.doit;
            if (!event.doit) break;
            if (event.count !is 0) {
                event.doit = false;
                int oldIndex = getSelectionIndex ();
                if (event.count > 0) {
                    select (Math.max (oldIndex - 1, 0));
                } else {
                    select (Math.min (oldIndex + 1, getItemCount () - 1));
                }
                if (oldIndex !is getSelectionIndex ()) {
                    Event e = new Event();
                    e.time = event.time;
                    e.stateMask = event.stateMask;
                    notifyListeners (DWT.Selection, e);
                }
                if (isDisposed ()) break;
            }
            break;
        }
        case DWT.Traverse: {
            switch (event.detail) {
                case DWT.TRAVERSE_ARROW_PREVIOUS:
                case DWT.TRAVERSE_ARROW_NEXT:
                    // The enter causes default selection and
                    // the arrow keys are used to manipulate the list contents so
                    // do not use them for traversal.
                    event.doit = false;
                    break;
                case DWT.TRAVERSE_TAB_PREVIOUS:
                    event.doit = traverse(DWT.TRAVERSE_TAB_PREVIOUS);
                    event.detail = DWT.TRAVERSE_NONE;
                    return;
                default:
            }
            Event e = new Event ();
            e.time = event.time;
            e.detail = event.detail;
            e.doit = event.doit;
            e.character = event.character;
            e.keyCode = event.keyCode;
            notifyListeners (DWT.Traverse, e);
            event.doit = e.doit;
            event.detail = e.detail;
            break;
        }
        case DWT.Verify: {
            Event e = new Event ();
            e.text = event.text;
            e.start = event.start;
            e.end = event.end;
            e.character = event.character;
            e.keyCode = event.keyCode;
            e.stateMask = event.stateMask;
            notifyListeners (DWT.Verify, e);
            event.doit = e.doit;
            break;
        }
        default:
    }
}
}
