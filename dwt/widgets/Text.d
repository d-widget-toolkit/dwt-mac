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
module dwt.widgets.Text;

import dwt.dwthelper.utils;

import dwt.*;
import dwt.events.*;
import dwt.graphics.*;
import dwt.internal.*;
import dwt.internal.cocoa.*;

import Carbon = dwt.internal.c.Carbon;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;
import dwt.widgets.Composite;
import dwt.widgets.Event;
import dwt.widgets.Scrollable;
import dwt.widgets.TypedListener;

/**
 * Instances of this class are selectable user interface
 * objects that allow the user to enter and modify text.
 * Text controls can be either single or multi-line.
 * When a text control is created with a border, the
 * operating system includes a platform specific inset
 * around the contents of the control.  When created
 * without a border, an effort is made to remove the
 * inset such that the preferred size of the control
 * is the same size as the contents.
 * <p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>CENTER, ICON_CANCEL, ICON_SEARCH, LEFT, MULTI, PASSWORD, SEARCH, SINGLE, RIGHT, READ_ONLY, WRAP</dd>
 * <dt><b>Events:</b></dt>
 * <dd>DefaultSelection, Modify, Verify</dd>
 * </dl>
 * <p>
 * Note: Only one of the styles MULTI and SINGLE may be specified,
 * and only one of the styles LEFT, CENTER, and RIGHT may be specified.
 * </p>
 * <p>
 * Note: The styles ICON_CANCEL and ICON_SEARCH are hints used in combination with SEARCH.
 * When the platform supports the hint, the text control shows these icons.  When an icon
 * is selected, a default selection event is sent with the detail field set to one of
 * ICON_CANCEL or ICON_SEARCH.  Normally, application code does not need to check the
 * detail.  In the case of ICON_CANCEL, the text is cleared before the default selection
 * event is sent causing the application to search for an empty string.
 * </p>
 * <p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#text">Text snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">DWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 * @noextend This class is not intended to be subclassed by clients.
 */
public class Text : Scrollable {

    alias Scrollable.computeSize computeSize;
    alias Scrollable.dragDetect dragDetect;    
    alias Scrollable.setBackground setBackground;
    alias Scrollable.setFont setFont;
    alias Scrollable.setForeground setForeground;
    alias Scrollable.translateTraversal translateTraversal;
    
    int textLimit, tabs = 8;
    wchar echoCharacter = '\0';
    bool doubleClick, receivingFocus;
    wchar[] hiddenText, message;
    NSRange* selectionRange;
    id targetSearch, targetCancel;
    int /*long*/ actionSearch, actionCancel;
    
    /**
    * The maximum number of characters that can be entered
    * into a text widget.
    * <p>
    * Note that this value is platform dependent, based upon
    * the native widget implementation.
    * </p>
    */
	public static const int LIMIT;

    /**
    * The delimiter used by multi-line text widgets.  When text
    * is queried and from the widget, it will be delimited using
    * this delimiter.
    */
	public static const wchar[] DELIMITER;
	static const wchar PASSWORD = '\u2022';

	/*
    * These values can be different on different platforms.
    * Therefore they are not initialized in the declaration
    * to stop the compiler from inlining.
    */
    static this () {
        LIMIT = 0x7FFFFFFF;
        DELIMITER = "\r";
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
 * @see DWT#SINGLE
 * @see DWT#MULTI
 * @see DWT#READ_ONLY
 * @see DWT#WRAP
 * @see DWT#LEFT
 * @see DWT#RIGHT
 * @see DWT#CENTER
 * @see DWT#PASSWORD
 * @see DWT#SEARCH
 * @see DWT#ICON_SEARCH
 * @see DWT#ICON_CANCEL
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    textLimit = LIMIT;
    
    super (parent, checkStyle (style));
    if ((style & DWT.SEARCH) !is 0) {
        /*
        * Ensure that DWT.ICON_CANCEL and ICON_SEARCH are set.
        * NOTE: ICON_CANCEL has the same value as H_SCROLL and
        * ICON_SEARCH has the same value as V_SCROLL so it is
         * necessary to first clear these bits to avoid a scroll
         * bar and then reset the bit using the original style
         * supplied by the programmer.
         */
        NSSearchFieldCell cell = new NSSearchFieldCell (((NSSearchField) view).cell ());
        if ((style & DWT.ICON_CANCEL) !is 0) {
            this.style |= DWT.ICON_CANCEL;
            NSButtonCell cancelCell = cell.cancelButtonCell();
            targetCancel = cancelCell.target();
            actionCancel = cancelCell.action();
            cancelCell.setTarget (view);
            cancelCell.setAction (OS.sel_sendCancelSelection);
        } else {
            cell.setCancelButtonCell (null);
        }
        if ((style & DWT.ICON_SEARCH) !is 0) {
            this.style |= DWT.ICON_SEARCH;
            NSButtonCell searchCell = cell.searchButtonCell();
            targetSearch = searchCell.target();
            actionSearch = searchCell.action();
            searchCell.setTarget (view);
            searchCell.setAction (OS.sel_sendSearchSelection);
        } else {
            cell.setSearchButtonCell (null);
        }
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
    checkWidget ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (DWT.Modify, typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the control is selected by the user, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * <code>widgetSelected</code> is not called for texts.
 * <code>widgetDefaultSelected</code> is typically called when ENTER is pressed in a single-line text,
 * or when ENTER is pressed in a search text. If the receiver has the <code>DWT.SEARCH | DWT.CANCEL</code> style
 * and the user cancels the search, the event object detail field contains the value <code>DWT.CANCEL</code>.
 * </p>
 *
 * @param listener the listener which should be notified when the control is selected by the user
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
 */
public void addVerifyListener (VerifyListener listener) {
    checkWidget ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (DWT.Verify, typedListener);
}

/**
 * Appends a string.
 * <p>
 * The new text is appended to the text at
 * the end of the widget.
 * </p>
 *
 * @param string the string to be appended
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the string is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void append (String stri) {
    wchar[] string = stri.toString16();
    checkWidget ();
    //if (string is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (hooks (DWT.Verify) || filters (DWT.Verify)) {
        int charCount = getCharCount ();
        string = verifyText (string, charCount, charCount, null);
        if (string is null) return;
    }
    NSString str = NSString.stringWith16 (string);
    if ((style & DWT.SINGLE) !is 0) {
        setSelection (getCharCount ());
        insertEditText (string);
    } else {
        NSTextView widget = cast(NSTextView) view;
        NSTextStorage storage = widget.textStorage ();
        NSRange range = NSRange();
        range.location = storage.length();
        storage.replaceCharactersInRange (range, str);
        range.location = storage.length();
        range.location = storage.length();
        widget.scrollRangeToVisible (range);
        widget.setSelectedRange(range);
    }
    if (string.length () !is 0) sendEvent (DWT.Modify);
}

bool becomeFirstResponder (objc.id id, objc.SEL sel) {
    receivingFocus = true;
    bool result = super.becomeFirstResponder (id, sel);
    receivingFocus = false;
    return result;
}

static int checkStyle (int style) {
    if ((style & DWT.SEARCH) !is 0) {
        style |= DWT.SINGLE | DWT.BORDER;
        style &= ~DWT.PASSWORD;
        /* 
        * NOTE: ICON_CANCEL has the same value as H_SCROLL and
        * ICON_SEARCH has the same value as V_SCROLL so they are
        * cleared because DWT.SINGLE is set. 
        */
    }
    if ((style & DWT.SINGLE) !is 0 && (style & DWT.MULTI) !is 0) {
        style &= ~DWT.MULTI;
    }
    style = checkBits (style, DWT.LEFT, DWT.CENTER, DWT.RIGHT, 0, 0, 0);
    if ((style & DWT.SINGLE) !is 0) style &= ~(DWT.H_SCROLL | DWT.V_SCROLL | DWT.WRAP);
    if ((style & DWT.WRAP) !is 0) {
        style |= DWT.MULTI;
        style &= ~DWT.H_SCROLL;
    }
    if ((style & DWT.MULTI) !is 0) style &= ~DWT.PASSWORD;
    if ((style & (DWT.SINGLE | DWT.MULTI)) !is 0) return style;
    if ((style & (DWT.H_SCROLL | DWT.V_SCROLL)) !is 0) return style | DWT.MULTI;
    return style | DWT.SINGLE;
}

/**
 * Clears the selection.
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void clearSelection () {
    checkWidget ();
    Point selection = getSelection ();
    setSelection (selection.x); 
}

public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    int width = 0, height = 0;
    if ((style & DWT.SINGLE) !is 0) {
        NSTextField widget = cast(NSTextField) view;
        NSSize size = widget.cell ().cellSize ();
        width = cast(int)Math.ceil (size.width);
        height = cast(int)Math.ceil (size.height);

        Point border = null;
        if ((style & DWT.BORDER) !is 0 && (wHint !is DWT.DEFAULT || hHint !is DWT.DEFAULT)) {
            /* determine the size of the cell without its border */
            NSRect insets = widget.cell ().titleRectForBounds (new NSRect ());
            border = new Point (-(int)Math.ceil (insets.width), -(int)Math.ceil (insets.height));
            width -= border.x;
            height -= border.y;
        }
        if (width <= 0) width = DEFAULT_WIDTH;
        if (height <= 0) height = DEFAULT_HEIGHT;
        if (wHint !is DWT.DEFAULT) width = wHint;
        if (hHint !is DWT.DEFAULT) height = hHint;
        if (border !is null) {
            /* re-add the border size (if any) now that wHint/hHint is taken */
            width += border.x;
            height += border.y;
        }
    } else {
        NSLayoutManager layoutManager = (NSLayoutManager)new NSLayoutManager ().alloc ().init ();
        NSTextContainer textContainer = (NSTextContainer)new NSTextContainer ().alloc ();
        NSSize size = new NSSize ();
        size.width = size.height = Float.MAX_VALUE;
        if ((style & DWT.WRAP) !is 0) {
            if (wHint !is DWT.DEFAULT) size.width = wHint;
            if (hHint !is DWT.DEFAULT) size.height = hHint;
        }
        textContainer.initWithContainerSize (size);
        layoutManager.addTextContainer (textContainer);

        NSTextStorage textStorage = (NSTextStorage)new NSTextStorage ().alloc ().init ();
        textStorage.setAttributedString (((NSTextView)view).textStorage ());
        layoutManager.setTextStorage (textStorage);
        layoutManager.glyphRangeForTextContainer (textContainer);

        NSRect rect = layoutManager.usedRectForTextContainer (textContainer);
        width = layoutManager.numberOfGlyphs () is 0 ? DEFAULT_WIDTH : (int)Math.ceil (rect.width);
        height = (int)Math.ceil (rect.height);
        textStorage.release ();
        textContainer.release ();
        layoutManager.release ();

        if (width <= 0) width = DEFAULT_WIDTH;
        if (height <= 0) height = DEFAULT_HEIGHT;
        if (wHint !is DWT.DEFAULT) width = wHint;
        if (hHint !is DWT.DEFAULT) height = hHint;
        Rectangle trim = computeTrim (0, 0, width, height);
        width = trim.width;
        height = trim.height;
    }
    return new Point (width, height);
}

public Rectangle computeTrim (int x, int y, int width, int height) {
    Rectangle result = super.computeTrim (x, y, width, height);
    if ((style & DWT.SINGLE) !is 0) {
        NSTextField widget = (NSTextField) view;
        if ((style & DWT.SEARCH) !is 0) {
            NSSearchFieldCell cell = new NSSearchFieldCell (widget.cell ());
            int testWidth = 100;
            NSRect rect = new NSRect ();
            rect.width = testWidth;
            rect = cell.searchTextRectForBounds (rect);
            int leftIndent = (int)rect.x;
            int rightIndent = testWidth - leftIndent - (int)Math.ceil (rect.width);
            result.x -= leftIndent;
            result.width += leftIndent + rightIndent;
        }
        NSRect inset = widget.cell ().titleRectForBounds (new NSRect ());
        result.x -= inset.x;
        result.y -= inset.y;
        result.width -= inset.width;
        result.height -= inset.height;
    }
    return result;
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
 */
public void copy () {
    checkWidget ();
    if ((style & DWT.SINGLE) !is 0) {
        Point selection = getSelection ();
        if (selection.x is selection.y) return;
        copyToClipboard (getEditText (selection.x, selection.y - 1));
    } else {
        NSText text = cast(NSText) view;
        if (text.selectedRange ().length is 0) return;
        text.copy (null);
    }
}

void createHandle () {
    if ((style & DWT.READ_ONLY) !is 0) {
        if ((style & (DWT.BORDER | DWT.H_SCROLL | DWT.V_SCROLL)) is 0) {
            state |= THEME_BACKGROUND;
        }
    }
    if ((style & DWT.SINGLE) !is 0) {
        NSTextField widget;
        if ((style & DWT.PASSWORD) !is 0) {
            widget = cast(NSTextField) (new SWTSecureTextField ()).alloc ();
        } else if ((style & DWT.SEARCH) !is 0) {
            widget = cast(NSTextField) (new SWTSearchField ()).alloc ();
        } else {
            widget = cast(NSTextField) (new SWTTextField ()).alloc ();
        }
        widget.init ();
        widget.setSelectable (true);
        widget.setEditable((style & DWT.READ_ONLY) is 0);
        if ((style & DWT.BORDER) is 0) {
            widget.setFocusRingType (OS.NSFocusRingTypeNone);
            widget.setBordered (false);
        }
        NSTextAlignment align_ = OS.NSLeftTextAlignment;
        if ((style & DWT.CENTER) !is 0) align_ = OS.NSCenterTextAlignment;
        if ((style & DWT.RIGHT) !is 0) align_ = OS.NSRightTextAlignment;
        widget.setAlignment (align_);
        NSCell cell = widget.cell();
        cell.setWraps(false);
        cell.setScrollable(true);
//      widget.setTarget(widget);
//      widget.setAction(OS.sel_sendSelection);
        view = widget;
    } else {
        NSScrollView scrollWidget = cast(NSScrollView) (new SWTScrollView ()).alloc ();
        scrollWidget.init ();
        scrollWidget.setHasVerticalScroller ((style & DWT.VERTICAL) !is 0);
        scrollWidget.setHasHorizontalScroller ((style & DWT.HORIZONTAL) !is 0);
        scrollWidget.setAutoresizesSubviews (true);
        if ((style & DWT.BORDER) !is 0) scrollWidget.setBorderType (OS.NSBezelBorder);
        
        NSTextView widget = cast(NSTextView) (new SWTTextView ()).alloc ();
        widget.init ();
        widget.setEditable ((style & DWT.READ_ONLY) is 0);
        
        NSSize size = NSSize ();
        size.width = size.height = Float.MAX_VALUE;
        widget.setMaxSize (size);
        widget.setAutoresizingMask (OS.NSViewWidthSizable | OS.NSViewHeightSizable);

        if ((style & DWT.WRAP) is 0) {
            NSTextContainer textContainer = widget.textContainer ();
            widget.setHorizontallyResizable (true);
            textContainer.setWidthTracksTextView (false);
            NSSize csize = NSSize ();
            csize.width = csize.height = Float.MAX_VALUE;
            textContainer.setContainerSize (csize);
        }

        NSTextAlignment align_ = OS.NSLeftTextAlignment;
        if ((style & DWT.CENTER) !is 0) align_ = OS.NSCenterTextAlignment;
        if ((style & DWT.RIGHT) !is 0) align_ = OS.NSRightTextAlignment;
        widget.setAlignment (align_);
//      widget.setTarget(widget);
//      widget.setAction(OS.sel_sendSelection);
        widget.setRichText (false);
        widget.setDelegate(widget);
        widget.setFont (display.getSystemFont ().handle);

        view = widget;
        scrollView = scrollWidget;
    }
}

void createWidget () {
    super.createWidget ();
    doubleClick = true;
    message = "";
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
 */
public void cut () {
    checkWidget ();
    if ((style & DWT.READ_ONLY) !is 0) return;
    bool cut = true;
    wchar [] oldText = null;
    Point oldSelection = getSelection ();
    if (hooks (DWT.Verify) || filters (DWT.Verify)) {
        if (oldSelection.x !is oldSelection.y) {
            oldText = getEditText (oldSelection.x, oldSelection.y - 1);
            wchar[] newText = verifyText ("", oldSelection.x, oldSelection.y, null);
            if (newText is null) return;
            if (newText.length () !is 0) {
                copyToClipboard (oldText);
                if ((style & DWT.SINGLE) !is 0) {
                    insertEditText (newText);
                } else {
                    NSTextView widget = cast(NSTextView) view;
                    widget.replaceCharactersInRange (widget.selectedRange (), NSString.stringWith16 (newText));
                }
                cut = false;
            }
        }
    }
    if (cut) {
        if ((style & DWT.SINGLE) !is 0) {
            if (oldText is null) oldText = getEditText (oldSelection.x, oldSelection.y - 1);
            copyToClipboard (oldText);
            insertEditText ("");
        } else {
            (cast(NSTextView) view).cut (null);
        }
    }
    Point newSelection = getSelection ();
    if (!cut || !oldSelection.equals (newSelection)) sendEvent (DWT.Modify);
}

Color defaultBackground () {
    return display.getWidgetColor (DWT.COLOR_LIST_BACKGROUND);
}

NSFont defaultNSFont () {
    if ((style & DWT.MULTI) !is 0) return display.textViewFont;
    if ((style & DWT.SEARCH) !is 0) return display.searchFieldFont;
    if ((style & DWT.PASSWORD) !is 0) return display.secureTextFieldFont;
    return display.textFieldFont;
}

Color defaultForeground () {
    return display.getWidgetColor (DWT.COLOR_LIST_FOREGROUND);
}

void deregister() {
    super.deregister();
    
    if ((style & DWT.SINGLE) !is 0) {
        display.removeWidget((cast(NSControl)view).cell());
    }
}

bool dragDetect (int x, int y, bool filter, bool [] consume) {
    Point selection = getSelection ();
    if (selection.x !is selection.y) {
        int /*long*/ position = getPosition (x, y);
        if (selection.x <= position && position < selection.y) {
            if (super.dragDetect (x, y, filter, consume)) {
                if (consume !is null) consume [0] = true;
                return true;
            }
        }
    }
    return false;
}

/**
 * Returns the line number of the caret.
 * <p>
 * The line number of the caret is returned.
 * </p>
 *
 * @return the line number
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getCaretLineNumber () {
    checkWidget ();
    if ((style & DWT.SINGLE) !is 0) return 0;
    return (getTopPixel () + getCaretLocation ().y) / getLineHeight ();
}

bool acceptsFirstResponder(int /*long*/ id, int /*long*/ sel) {
    if ((style & DWT.READ_ONLY) !is 0) return true;
    return super.acceptsFirstResponder(id, sel);
}

/**
 * Returns a point describing the receiver's location relative
 * to its parent (or its display if its parent is null).
 * <p>
 * The location of the caret is returned.
 * </p>
 *
 * @return a point, the location of the caret
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Point getCaretLocation () {
    checkWidget ();
    if ((style & DWT.SINGLE) !is 0) {
        //TODO - caret location for single text
        return new Point (0, 0);
    }
    NSTextView widget = (NSTextView)view;
    NSLayoutManager layoutManager = widget.layoutManager();
    NSTextContainer container = widget.textContainer();
    NSRange range = widget.selectedRange();
    int /*long*/ pRectCount = OS.malloc(C.PTR_SIZEOF);
    int /*long*/ pArray = layoutManager.rectArrayForCharacterRange(range, range, container, pRectCount);
    int /*long*/ [] rectCount = new int /*long*/ [1];
    OS.memmove(rectCount, pRectCount, C.PTR_SIZEOF);
    OS.free(pRectCount);
    NSRect rect = new NSRect();
    if (rectCount[0] > 0) OS.memmove(rect, pArray, NSRect.sizeof);
    return new Point((int)rect.x, (int)rect.y);
}

/**
 * Returns the character position of the caret.
 * <p>
 * Indexing is zero based.
 * </p>
 *
 * @return the position of the caret
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getCaretPosition () {
    checkWidget ();
    if ((style & DWT.SINGLE) !is 0) {
        return selectionRange !is null ? (int)/*64*/selectionRange.location : 0;
    } else {
        NSRange range = (cast(NSTextView)view).selectedRange();
        return cast(int)/*64*/range.location;
    }
}

/**
 * Returns the number of characters.
 *
 * @return number of characters in the widget
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getCharCount () {
    checkWidget ();
    if ((style & DWT.SINGLE) !is 0) {
        return cast(int)/*64*/(new NSCell ((cast(NSControl) view).cell ())).title ().length ();
    } else {
        return cast(int)/*64*/(cast(NSTextView) view).textStorage ().length ();
    }
}

/**
 * Returns the double click enabled flag.
 * <p>
 * The double click flag enables or disables the
 * default action of the text widget when the user
 * double clicks.
 * </p>
 * 
 * @return whether or not double click is enabled
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool getDoubleClickEnabled () {
    checkWidget ();
    return doubleClick;
}

/**
 * Returns the echo character.
 * <p>
 * The echo character is the character that is
 * displayed when the user enters text or the
 * text is changed by the programmer.
 * </p>
 * 
 * @return the echo character
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * 
 * @see #setEchoChar
 */
public char getEchoChar () {
    checkWidget ();
    return toChar(echoCharacter);
}

/**
 * Returns the editable state.
 *
 * @return whether or not the receiver is editable
 * 
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool getEditable () {
    checkWidget ();
    return (style & DWT.READ_ONLY) is 0;
}

wchar [] getEditText () {
    NSString str = null;
    if ((style & DWT.SINGLE) !is 0) {
        str = (new NSTextFieldCell ((cast(NSTextField) view).cell ())).title ();
    } else {
        str = (cast(NSTextView)view).textStorage().string();
    }

    NSUInteger length_ = str.length ();
    wchar [] buffer = new wchar [length_];
    if (hiddenText !is null) {
        hiddenText.getChars (0, length_, buffer, 0);
    } else {
        NSRange range = NSRange ();
        range.length = length_;
        str.getCharacters (buffer.ptr, range);
    }
    return buffer;//.fromString16();
}

wchar [] getEditText (int start, int end) {
    NSString str = null;
    if ((style & DWT.SINGLE) !is 0) {
        str = (new NSTextFieldCell ((cast(NSTextField) view).cell ())).title ();
    } else {
        str = (cast(NSTextView)view).textStorage().string();
    }

    int length = cast(int)/*64*/str.length ();
    end = Math.min (end, length - 1);
    if (start > end) return new wchar [0];
    start = Math.max (0, start);
    NSRange range = NSRange ();
    range.location = start;
    range.length = Math.max (0, end - start + 1);
    wchar [] buffer = new wchar [range.length];
    if (hiddenText !is null) {
        hiddenText.getChars (cast(int)/*64*/range.location, cast(int)/*64*/(range.location + range.length), buffer, 0);
    } else {
        str.getCharacters (buffer.ptr, range);
    }
    return buffer;//.fromString16();
}

/**
 * Returns the number of lines.
 *
 * @return the number of lines in the widget
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getLineCount () {
    checkWidget ();
    if ((style & DWT.SINGLE) !is 0) return 1;
    NSTextStorage storage = ((NSTextView) view).textStorage ();
    int count = (int)/*64*/storage.paragraphs ().count ();
    NSString string = storage.string();
    int /*long*/ length = string.length(), c;
    if (length is 0 || (c = string.characterAtIndex(length - 1)) is '\n' || c is '\r') {
        count++;
    }
    return count;
}

/**
 * Returns the line delimiter.
 *
 * @return a string that is the line delimiter
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * 
 * @see #DELIMITER
 */
public String getLineDelimiter () {
    checkWidget ();
    return DELIMITER.fromString16();
}

/**
 * Returns the height of a line.
 *
 * @return the height of a row of text
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getLineHeight () {
    checkWidget ();
    Font font = this.font !is null ? this.font : defaultFont();
    if ((style & DWT.SINGLE) !is 0) {
        NSDictionary dict = NSDictionary.dictionaryWithObject(font.handle, OS.NSFontAttributeName);
        NSString str = NSString.stringWith(" ");
        NSAttributedString attribStr = ((NSAttributedString)new NSAttributedString().alloc()).initWithString(str, dict);
        NSSize size = attribStr.size();
        attribStr.release();
        return (int) size.height;
    } else {
        NSTextView widget = (NSTextView)view;
        return (int)Math.ceil(widget.layoutManager().defaultLineHeightForFont(font.handle));
    }
}

/**
 * Returns the orientation of the receiver, which will be one of the
 * constants <code>DWT.LEFT_TO_RIGHT</code> or <code>DWT.RIGHT_TO_LEFT</code>.
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
    checkWidget ();
    return style & (DWT.LEFT_TO_RIGHT | DWT.RIGHT_TO_LEFT);
}

/**
 * Returns the widget message.  The message text is displayed
 * as a hint for the user, indicating the purpose of the field.
 * <p>
 * Typically this is used in conjunction with <code>DWT.SEARCH</code>.
 * </p>
 * 
 * @return the widget message
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * 
 * @since 3.3
 */
public String getMessage () {
    checkWidget ();
    return message.fromString16();
}

int /*long*/ getPosition (int /*long*/ x, int /*long*/ y) {
//  checkWidget ();
    if ((style & DWT.MULTI) !is 0) {
        NSTextView widget = (NSTextView) view;
        NSPoint viewLocation = new NSPoint();
        viewLocation.x = x;
        viewLocation.y = y;
        return widget.characterIndexForInsertionAtPoint(viewLocation);
    } else {
        //TODO 
        return 0;
    }
}

/**
 * Returns a <code>Point</code> whose x coordinate is the
 * character position representing the start of the selected
 * text, and whose y coordinate is the character position
 * representing the end of the selection. An "empty" selection
 * is indicated by the x and y coordinates having the same value.
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
    if ((style & DWT.SINGLE) !is 0) {
        if (selectionRange is null) {
            NSString str = (new NSTextFieldCell ((cast(NSTextField) view).cell ())).title ();
            return new Point(cast(int)/*64*/str.length (), cast(int)/*64*/str.length ());
        }
        return new Point (cast(int)/*64*/selectionRange.location, cast(int)/*64*/(selectionRange.location + selectionRange.length));
    } else {
        NSTextView widget = cast(NSTextView) view;
        NSRange range = widget.selectedRange ();
        return new Point (cast(int)/*64*/range.location, cast(int)/*64*/(range.location + range.length));
    }
}

/**
 * Returns the number of selected characters.
 *
 * @return the number of selected characters.
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getSelectionCount () {
    checkWidget ();
    if ((style & DWT.SINGLE) !is 0) {
        return selectionRange !is null ? cast(int)/*64*/selectionRange.length : 0;
    } else {
        NSTextView widget = cast(NSTextView) view;
        NSRange range = widget.selectedRange ();
        return cast(int)/*64*/range.length;
    }
}

/**
 * Gets the selected text, or an empty string if there is no current selection.
 *
 * @return the selected text
 * 
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String getSelectionText () {
    checkWidget ();
    if ((style & DWT.SINGLE) !is 0) {
        Point selection = getSelection ();
        if (selection.x is selection.y) return "";
        return new_String (getEditText (selection.x, selection.y - 1).fromString16());
    } else {
        NSTextView widget = cast(NSTextView) view;
        NSRange range = widget.selectedRange ();
        NSString str = widget.textStorage ().string ();
        wchar[] buffer = new wchar [range.length];        
        str.getCharacters (buffer.ptr, range);
        return buffer.fromString16();
    }
}

/**
 * Returns the number of tabs.
 * <p>
 * Tab stop spacing is specified in terms of the
 * space (' ') character.  The width of a single
 * tab stop is the pixel width of the spaces.
 * </p>
 *
 * @return the number of tab characters
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getTabs () {
    checkWidget ();
    return tabs;
}

/**
 * Returns the widget text.
 * <p>
 * The text for a text widget is the characters in the widget, or
 * an empty string if this has never been set.
 * </p>
 *
 * @return the widget text
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String getText () {
    checkWidget ();
    NSString str;
    if ((style & DWT.SINGLE) !is 0) {
        return new_String (getEditText ().fromString16());
    } else {
        str = (cast(NSTextView)view).textStorage ().string ();
    }
    return str.getString();
}

private wchar[] getText16 () {
    checkWidget ();
    NSString str;
    if ((style & DWT.SINGLE) !is 0) {
        return getEditText ().dup;
    } else {
        str = (cast(NSTextView)view).textStorage ().string ();
    }
    return str.getString16();
}

/**
 * Returns a range of text.  Returns an empty string if the
 * start of the range is greater than the end.
 * <p>
 * Indexing is zero based.  The range of
 * a selection is from 0..N-1 where N is
 * the number of characters in the widget.
 * </p>
 *
 * @param start the start of the range
 * @param end the end of the range
 * @return the range of text
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String getText (int start, int end) {
    checkWidget ();
    if (!(start <= end && 0 <= end)) return ""; //$NON-NLS-1$
    if ((style & DWT.SINGLE) !is 0) {
        return new_String (getEditText (start, end).fromString16());
    }
    NSTextStorage storage = (cast(NSTextView) view).textStorage ();
    end = Math.min (end, cast(int)/*64*/storage.length () - 1);
    if (start > end) return ""; //$NON-NLS-1$
    start = Math.max (0, start);
    NSRange range = NSRange ();
    range.location = start;
    range.length = end - start + 1;
    NSAttributedString substring = storage.attributedSubstringFromRange (range);
    NSString string = substring.string ();
    return string.getString();
}

/**
 * Returns the maximum number of characters that the receiver is capable of holding. 
 * <p>
 * If this has not been changed by <code>setTextLimit()</code>,
 * it will be the constant <code>Text.LIMIT</code>.
 * </p>
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
    checkWidget ();
    return textLimit;
}

/**
 * Returns the zero-relative index of the line which is currently
 * at the top of the receiver.
 * <p>
 * This index can change when lines are scrolled or new lines are added or removed.
 * </p>
 *
 * @return the index of the top line
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getTopIndex () {
    checkWidget ();
    if ((style & DWT.SINGLE) !is 0) return 0;
    return getTopPixel () / getLineHeight ();
}

/**
 * Returns the top pixel.
 * <p>
 * The top pixel is the pixel position of the line
 * that is currently at the top of the widget.  On
 * some platforms, a text widget can be scrolled by
 * pixels instead of lines so that a partial line
 * is displayed at the top of the widget.
 * </p><p>
 * The top pixel changes when the widget is scrolled.
 * The top pixel does not include the widget trimming.
 * </p>
 *
 * @return the pixel position of the top line
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getTopPixel () {
    checkWidget ();
    if ((style & DWT.SINGLE) !is 0) return 0;
    return (int)scrollView.contentView().bounds().y;
}

/**
 * Inserts a string.
 * <p>
 * The old selection is replaced with the new text.
 * </p>
 *
 * @param string the string
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the string is <code>null</code></li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void insert (String stri) {
    wchar[] string = stri.toString16();
    checkWidget ();
    //if (string is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (hooks (DWT.Verify) || filters (DWT.Verify)) {
        Point selection = getSelection ();
        string = verifyText (string, selection.x, selection.y, null);
        if (string is null) return;
    }
    if ((style & DWT.SINGLE) !is 0) {
        insertEditText (string);
    } else {
        NSString str = NSString.stringWith16 (string);
        NSTextView widget = cast(NSTextView) view;
        NSRange range = widget.selectedRange ();
        widget.textStorage ().replaceCharactersInRange (range, str);
    }
    if (string.length () !is 0) sendEvent (DWT.Modify);
}

void insertEditText (wchar[] string) {
    int length_ = string.length ();
    Point selection = getSelection ();
    if (hasFocus () && hiddenText is null) {
        if (textLimit !is LIMIT) {
            int charCount = getCharCount();
            if (charCount - (selection.y - selection.x) + length_ > textLimit) {
                length_ = textLimit - charCount + (selection.y - selection.x);
            }
        }
        wchar [] buffer = new wchar [length_];
        string.getChars (0, buffer.length, buffer, 0);
        NSString nsstring = NSString.stringWithCharacters (buffer.ptr, buffer.length);
        NSText fieldEditor = ((NSTextField) view).currentEditor ();
        if (fieldEditor !is null) fieldEditor.replaceCharactersInRange (fieldEditor.selectedRange (), nsstring);
        selectionRange = null;
    } else {
        wchar[] oldText = getText16 ();
        if (textLimit !is LIMIT) {
            int charCount = oldText.length ();
            if (charCount - (selection.y - selection.x) + length_ > textLimit) {
                string = string.substring(0, textLimit - charCount + (selection.y - selection.x));
            }
        }
        wchar[] newText = oldText.substring (0, selection.x) ~ string ~ oldText.substring (selection.y);
        setEditText (newText);
        setSelection (selection.x + string.length ());
    }
}

bool isEventView (int /*long*/ id) {
    if ((style & DWT.MULTI) !is 0) return super.isEventView (id);
    return true;
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
 */
public void paste () {
    checkWidget ();
    if ((style & DWT.READ_ONLY) !is 0) return;
    bool paste = true;
    wchar[] oldText = null;
    if (hooks (DWT.Verify) || filters (DWT.Verify)) {
        oldText = getClipboardText16 ();
        if (oldText !is null) {
            Point selection = getSelection ();
            wchar[] newText = verifyText (oldText, selection.x, selection.y, null);
            if (newText is null) return;
            if (!newText.equals (oldText)) {
                if ((style & DWT.SINGLE) !is 0) {
                    insertEditText (newText);
                } else {
                    NSTextView textView = cast(NSTextView) view;
                    textView.replaceCharactersInRange (textView.selectedRange (), NSString.stringWith16 (newText));
                }
                paste = false;
            }
        }
    }
    if (paste) {
        if ((style & DWT.SINGLE) !is 0) {
            if (oldText is null) oldText = getClipboardText16 ();
            if (oldText is null) return;
            insertEditText (oldText);
        } else {
            //TODO check text limit
            (cast(NSTextView) view).paste (null);
        }
    }
    sendEvent (DWT.Modify);
}

void register() {
    super.register();
    
    if ((style & DWT.SINGLE) !is 0) {
        display.addWidget((cast(NSControl)view).cell(), this);
    }
}

void releaseWidget () {
    super.releaseWidget ();
    if ((style & DWT.SINGLE) !is 0) ((NSControl)view).abortEditing();
    hiddenText = message = null;
    selectionRange = null;
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
    checkWidget ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (DWT.Modify, listener);
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the control is selected by the user.
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
public void removeSelectionListener(SelectionListener listener) {
    checkWidget ();
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
 */
public void removeVerifyListener (VerifyListener listener) {
    checkWidget ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (DWT.Verify, listener);
}

/**
 * Selects all the text in the receiver.
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void selectAll () {
    checkWidget ();
    if ((style & DWT.SINGLE) !is 0) {
        setSelection (0, getCharCount ());
    } else {
        (cast(NSTextView) view).selectAll (null);
    }
}

bool sendKeyEvent (NSEvent nsEvent, int type) {
    bool result = super.sendKeyEvent (nsEvent, type);
    if (!result) return result;
    if (type !is DWT.KeyDown) return result;
    int stateMask = 0;
    NSUInteger modifierFlags = nsEvent.modifierFlags();
    if ((modifierFlags & OS.NSAlternateKeyMask) !is 0) stateMask |= DWT.ALT;
    if ((modifierFlags & OS.NSShiftKeyMask) !is 0) stateMask |= DWT.SHIFT;
    if ((modifierFlags & OS.NSControlKeyMask) !is 0) stateMask |= DWT.CONTROL;
    if ((modifierFlags & OS.NSCommandKeyMask) !is 0) stateMask |= DWT.COMMAND;
    if (stateMask is DWT.COMMAND) {
        ushort keyCode = nsEvent.keyCode ();
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
            default:
        }
    }
    if ((style & DWT.SINGLE) !is 0) {
        ushort keyCode = nsEvent.keyCode ();
        switch (keyCode) {
            case 76: /* KP Enter */
            case 36: /* Return */
                postEvent (DWT.DefaultSelection);
            default:
        }
    }
    return result;
}

void sendSearchSelection () {
    if (targetSearch !is null) {
        ((NSSearchField)view).sendAction(actionSearch, targetSearch);
    }
    Event event = new Event ();
    event.detail = DWT.ICON_SEARCH;
    postEvent (DWT.DefaultSelection, event);
}

void sendCancelSelection () {
    if (targetCancel !is null) {
        ((NSSearchField)view).sendAction(actionCancel, targetCancel);
    }
    Event event = new Event ();
    event.detail = DWT.ICON_CANCEL;
    postEvent (DWT.DefaultSelection, event);
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
    if ((style & DWT.SINGLE) !is 0) {
        (cast(NSTextField) view).setBackgroundColor (nsColor);
    } else {
        (cast(NSTextView) view).setBackgroundColor (nsColor);
    }
}

/**
 * Sets the double click enabled flag.
 * <p>
 * The double click flag enables or disables the
 * default action of the text widget when the user
 * double clicks.
 * </p><p>
 * Note: This operation is a hint and is not supported on
 * platforms that do not have this concept.
 * </p>
 * 
 * @param doubleClick the new double click flag
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setDoubleClickEnabled (bool doubleClick) {
    checkWidget ();
    this.doubleClick = doubleClick;
}

/**
 * Sets the echo character.
 * <p>
 * The echo character is the character that is
 * displayed when the user enters text or the
 * text is changed by the programmer. Setting
 * the echo character to '\0' clears the echo
 * character and redraws the original text.
 * If for any reason the echo character is invalid,
 * or if the platform does not allow modification
 * of the echo character, the default echo character
 * for the platform is used.
 * </p>
 *
 * @param echo the new echo character
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setEchoChar (char echo) {
    checkWidget ();
    if ((style & DWT.MULTI) !is 0) return;
    if ((style & DWT.PASSWORD) is 0) {
        Point selection = getSelection ();
        String text = getText ();
        echoCharacter = echo;
        setEditText (text);
        setSelection (selection);
    }
    echoCharacter = toWChar(echo);
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
 */
public void setEditable (bool editable) {
    checkWidget ();
    if (editable) {
        style &= ~DWT.READ_ONLY;
    } else {
        style |= DWT.READ_ONLY;
    }
    if ((style & DWT.SINGLE) !is 0) {
        (cast(NSTextField) view).setEditable (editable);
    } else {
        (cast(NSTextView) view).setEditable (editable);
    }
}

void setEditText (wchar[] string) {
    wchar [] buffer;
    if ((style & DWT.PASSWORD) is 0 && echoCharacter !is '\0') {
        hiddenText = string;
        buffer = new wchar [Math.min(hiddenText.length (), textLimit)];
        for (int i = 0; i < buffer.length; i++) buffer [i] = echoCharacter;
    } else {
        hiddenText = null;
        buffer = new wchar [Math.min(string.length (), textLimit)];
        string.getChars (0, buffer.length, buffer, 0);
    }
    NSString nsstring = NSString.stringWithCharacters (buffer.ptr, buffer.length);
    (new NSCell ((cast(NSTextField) view).cell ())).setTitle (nsstring);
    selectionRange = null;
}

void setFont(NSFont font) {
    if ((style & DWT.MULTI) !is  0) {
        (cast(NSTextView) view).setFont (font);
        return;
    }
    super.setFont (font);
}

void setForeground (Carbon.CGFloat [] color) {
    NSColor nsColor;
    if (color is null) {
        nsColor = NSColor.textColor ();
    } else {
        nsColor = NSColor.colorWithDeviceRed (color [0], color [1], color [2], 1);
    }
    if ((style & DWT.SINGLE) !is 0) {
        (cast(NSTextField) view).setTextColor (nsColor);
    } else {
        (cast(NSTextView) view).setTextColor (nsColor);
    }
}

/**
 * Sets the orientation of the receiver, which must be one
 * of the constants <code>DWT.LEFT_TO_RIGHT</code> or <code>DWT.RIGHT_TO_LEFT</code>.
 * <p>
 * Note: This operation is a hint and is not supported on
 * platforms that do not have this concept.
 * </p>
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
    checkWidget ();
}

/**
 * Sets the widget message. The message text is displayed
 * as a hint for the user, indicating the purpose of the field.
 * <p>
 * Typically this is used in conjunction with <code>DWT.SEARCH</code>.
 * </p>
 * 
 * @param message the new message
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the message is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * 
 * @since 3.3
 */
public void setMessage (String message) {
    checkWidget ();
    //if (message is null) error (DWT.ERROR_NULL_ARGUMENT);
    this.message = message.toString16();
    if ((style & DWT.SINGLE) !is 0) {
        NSString str = NSString.stringWith (message);
        NSTextFieldCell cell = new NSTextFieldCell (((NSTextField) view).cell ());
        cell.setPlaceholderString (str);
    }
}

/**
 * Sets the selection.
 * <p>
 * Indexing is zero based.  The range of
 * a selection is from 0..N where N is
 * the number of characters in the widget.
 * </p><p>
 * Text selections are specified in terms of
 * caret positions.  In a text widget that
 * contains N characters, there are N+1 caret
 * positions, ranging from 0..N.  This differs
 * from other functions that address character
 * position such as getText () that use the
 * regular array indexing rules.
 * </p>
 *
 * @param start new caret position
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSelection (int start) {
    checkWidget ();
    setSelection (start, start);
}

/**
 * Sets the selection to the range specified
 * by the given start and end indices.
 * <p>
 * Indexing is zero based.  The range of
 * a selection is from 0..N where N is
 * the number of characters in the widget.
 * </p><p>
 * Text selections are specified in terms of
 * caret positions.  In a text widget that
 * contains N characters, there are N+1 caret
 * positions, ranging from 0..N.  This differs
 * from other functions that address character
 * position such as getText () that use the
 * usual array indexing rules.
 * </p>
 *
 * @param start the start of the range
 * @param end the end of the range
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSelection (int start, int end) {
    checkWidget ();
    if ((style & DWT.SINGLE) !is 0) {
        NSString str = (new NSCell ((cast(NSTextField) view).cell ())).title ();
        int length = cast(int)/*64*/str.length ();
        int selStart = Math.min (Math.max (Math.min (start, end), 0), length);
        int selEnd = Math.min (Math.max (Math.max (start, end), 0), length);
        selectionRangeStruct = NSRange ();
        selectionRange = &selectionRangeStruct;
        selectionRange.location = selStart;
        selectionRange.length = selEnd - selStart;
        NSText fieldEditor = ((NSControl)view).currentEditor();
        if (fieldEditor !is null) {
            fieldEditor.setSelectedRange (selectionRange);
        }
    } else {
        int length = cast(int)/*64*/(cast(NSTextView) view).textStorage ().length ();
        int selStart = Math.min (Math.max (Math.min (start, end), 0), length);
        int selEnd = Math.min (Math.max (Math.max (start, end), 0), length);
        NSRange range = NSRange ();
        range.location = selStart;
        range.length = selEnd - selStart;
        (cast(NSTextView) view).setSelectedRange (range);
    }
}

/**
 * Sets the selection to the range specified
 * by the given point, where the x coordinate
 * represents the start index and the y coordinate
 * represents the end index.
 * <p>
 * Indexing is zero based.  The range of
 * a selection is from 0..N where N is
 * the number of characters in the widget.
 * </p><p>
 * Text selections are specified in terms of
 * caret positions.  In a text widget that
 * contains N characters, there are N+1 caret
 * positions, ranging from 0..N.  This differs
 * from other functions that address character
 * position such as getText () that use the
 * usual array indexing rules.
 * </p>
 *
 * @param selection the point
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
    setSelection (selection.x, selection.y);
}

/**
 * Sets the number of tabs.
 * <p>
 * Tab stop spacing is specified in terms of the
 * space (' ') character.  The width of a single
 * tab stop is the pixel width of the spaces.
 * </p>
 *
 * @param tabs the number of tabs
 *
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setTabs (int tabs) {
    checkWidget ();
    if (this.tabs is tabs) return;
    this.tabs = tabs;
    if ((style & DWT.SINGLE) !is 0) return;
    float /*double*/ size = textExtent("s").width * tabs;
    NSTextView widget = (NSTextView)view;
    NSParagraphStyle defaultStyle = widget.defaultParagraphStyle();
    NSMutableParagraphStyle paragraphStyle = new NSMutableParagraphStyle(defaultStyle.mutableCopy());
    paragraphStyle.setTabStops(NSArray.array());
    NSTextTab tab = (NSTextTab)new NSTextTab().alloc();
    tab = tab.initWithType(OS.NSLeftTabStopType, size);
    paragraphStyle.addTabStop(tab);
    tab.release();
    paragraphStyle.setDefaultTabInterval(size);
    widget.setDefaultParagraphStyle(paragraphStyle);
    paragraphStyle.release();
}

/**
 * Sets the contents of the receiver to the given string. If the receiver has style
 * SINGLE and the argument contains multiple lines of text, the result of this
 * operation is undefined and may vary from platform to platform.
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
public void setText (String stri) {
    wchar[] string = stri.toString16();
    checkWidget ();
    //if (string is null) error (DWT.ERROR_NULL_ARGUMENT);
   if (hooks (DWT.Verify) || filters (DWT.Verify)) {
        string = verifyText (string, 0, getCharCount (), null);
        if (string is null) return;
   }
    if ((style & DWT.SINGLE) !is 0) {
        setEditText (string);
    } else {
        NSTextView widget = (NSTextView)view;
        (cast(NSTextView) view).setString (str);
        widget.setString (str);
        widget.setSelectedRange(new NSRange());
    }
    sendEvent (DWT.Modify);
}

/**
 * Sets the maximum number of characters that the receiver
 * is capable of holding to be the argument.
 * <p>
 * Instead of trying to set the text limit to zero, consider
 * creating a read-only text widget.
 * </p><p>
 * To reset this value to the default, use <code>setTextLimit(Text.LIMIT)</code>.
 * Specifying a limit value larger than <code>Text.LIMIT</code> sets the
 * receiver's limit to <code>Text.LIMIT</code>.
 * </p>
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
 * 
 * @see #LIMIT
 */
public void setTextLimit (int limit) {
    checkWidget ();
    if (limit is 0) error (DWT.ERROR_CANNOT_BE_ZERO);
    textLimit = limit;
}

/**
 * Sets the zero-relative index of the line which is currently
 * at the top of the receiver. This index can change when lines
 * are scrolled or new lines are added and removed.
 *
 * @param index the index of the top item
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setTopIndex (int index) {
    checkWidget ();
    if ((style & DWT.SINGLE) !is 0) return;
    int row = Math.max(0, Math.min(index, getLineCount() - 1));
    NSPoint pt = new NSPoint();
    pt.x = scrollView.contentView().bounds().x;
    pt.y = getLineHeight() * row;
    view.scrollPoint(pt);
}

bool shouldChangeTextInRange_replacementString(int /*long*/ id, int /*long*/ sel, int /*long*/ affectedCharRange, int /*long*/ replacementString) {
    NSRange range = new NSRange();
    OS.memmove(range, affectedCharRange, NSRange.sizeof);
    bool result = callSuperBoolean(id, sel, range, replacementString);
    if (!hooks(DWT.Verify) && echoCharacter is '\0') return result;
    String text = new NSString(replacementString).getString();
    String newText = text;
    if (hooks (DWT.Verify)) {
        NSEvent currentEvent = display.application.currentEvent();
        int /*long*/ type = currentEvent.type();
        if (type !is OS.NSKeyDown && type !is OS.NSKeyUp) currentEvent = null;
        newText = verifyText(text, (int)/*64*/range.location, (int)/*64*/(range.location+range.length),  currentEvent);
    }
    if (newText is null) return false;
    if ((style & DWT.SINGLE) !is 0) {
        if (text !is newText || echoCharacter !is '\0') {
             //handle backspace and delete
            if (range.length is 1) {
                NSText editor = new NSText(id);
                editor.setSelectedRange (range);
            }
            insertEditText(newText);
            result = false;
        }
    } else {
        if (text !is newText) {
            NSTextView widget = (NSTextView) view;
            Point selection = getSelection();
            NSRange selRange = new NSRange();
            selRange.location = selection.x;
            selRange.length = selection.x + selection.y;
            widget.textStorage ().replaceCharactersInRange (selRange, NSString.stringWith(newText));
            result = false;
        }
    }
    if (!result) sendEvent (DWT.Modify);
    return result;
}

/**
 * Shows the selection.
 * <p>
 * If the selection is already showing
 * in the receiver, this method simply returns.  Otherwise,
 * lines are scrolled until the selection is visible.
 * </p>
 * 
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void showSelection () {
    checkWidget ();
    if ((style & DWT.SINGLE) !is 0)  {
        setSelection (getSelection ());
    } else {
        NSTextView widget = cast(NSTextView) view;
        widget.scrollRangeToVisible (widget.selectedRange ());
    }
}

void textViewDidChangeSelection(objc.id id, objc.SEL sel, objc.id aNotification) {
    NSNotification notification = new NSNotification (aNotification);
    NSText editor = new NSText (notification.object ().id);
    selectionRangeStruct = editor.selectedRange ();
    selectionRange = &selectionRangeStruct;
}

void textDidChange (objc.id id, objc.SEL sel, objc.id aNotification) {
    if ((style & DWT.SINGLE) !is 0) super.textDidChange (id, sel, aNotification);
    postEvent (DWT.Modify);
}

NSRange textView_willChangeSelectionFromCharacterRange_toCharacterRange (objc.id id, objc.SEL sel, objc.id aTextView, objc.id oldSelectedCharRange, objc.id newSelectedCharRange) {
    /*
    * If the selection is changing as a result of the receiver getting focus
    * then return the receiver's last selection range, otherwise the full
    * text will be automatically selected.
    */
    if (receivingFocus && selectionRange !is null) return selectionRangeStruct;

    /* allow the selection change to proceed */
    NSRange result = NSRange ();
    OS.memmove(&result, newSelectedCharRange, NSRange.sizeof);
    return result;
}

int traversalCode (int key, NSEvent theEvent) {
    int bits = super.traversalCode (key, theEvent);
    if ((style & DWT.READ_ONLY) !is 0) return bits;
    if ((style & DWT.MULTI) !is 0) {
        bits &= ~DWT.TRAVERSE_RETURN;
        if (key is 48 /* Tab */ && theEvent !is null) {
            NSUInteger modifiers = theEvent.modifierFlags ();
            bool next = (modifiers & OS.NSShiftKeyMask) is 0;
            if (next && (modifiers & OS.NSControlKeyMask) is 0) {
                bits &= ~(DWT.TRAVERSE_TAB_NEXT | DWT.TRAVERSE_TAB_PREVIOUS);
            }
        }
    }
    return bits;
}

void updateCursorRects (bool enabled) {
    super.updateCursorRects (enabled);
    if (scrollView is null) return;
    NSClipView contentView = scrollView.contentView ();
    contentView.setDocumentCursor (enabled ? NSCursor.IBeamCursor () : null);
}

void updateCursorRects (bool enabled) {
    super.updateCursorRects (enabled);
    if (scrollView is null) return;
    NSClipView contentView = scrollView.contentView ();
    contentView.setDocumentCursor (enabled ? NSCursor.IBeamCursor () : null);
}

wchar[] verifyText (wchar[] string, int start, int end, NSEvent keyEvent) {
    Event event = new Event ();
    if (keyEvent !is null) setKeyState(event, DWT.MouseDown, keyEvent);
    event.text = string.fromString16();
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
    return event.text.toString16();
}

}
