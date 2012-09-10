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
module dwt.widgets.Link;

import dwt.dwthelper.utils;



static import tango.text.Text;

import dwt.DWT;
import dwt.dwthelper.System;
import dwt.internal.cocoa.NSFont;
import dwt.internal.cocoa.NSView;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSColor;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSTextView;
import dwt.internal.cocoa.NSScrollView;
import dwt.internal.cocoa.NSDictionary;
import dwt.internal.cocoa.NSMutableDictionary;
import dwt.internal.cocoa.NSTextStorage;
import dwt.internal.cocoa.NSRange;
import dwt.internal.cocoa.NSClipView;
import dwt.internal.cocoa.NSCursor;
import dwt.internal.cocoa.SWTTextView;
import dwt.internal.cocoa.SWTScrollView;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;
import dwt.widgets.Event;
import dwt.widgets.Composite;
import dwt.widgets.Control;
import dwt.widgets.TypedListener;
import dwt.graphics.Point;
import dwt.events.SelectionListener;





/**
 * Instances of this class represent a selectable
 * user interface object that displays a text with
 * links.
 * <p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>(none)</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Selection</dd>
 * </dl>
 * <p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#link">Link snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">DWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.1
 * @noextend This class is not intended to be subclassed by clients.
 */
public class Link : Control {
    alias Control.updateCursorRects updateCursorRects;

    NSScrollView scrollView;
    String text;
    Point [] offsets;
    Point selection;
    String [] ids;
    int [] mnemonics;
    NSColor linkColor;

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
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, style);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the control is selected by the user, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * <code>widgetSelected</code> is called when the control is selected by the user.
 * <code>widgetDefaultSelected</code> is not called.
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
public void addSelectionListener (SelectionListener listener) {
    checkWidget ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (DWT.Selection, typedListener);
    addListener (DWT.DefaultSelection, typedListener);
}

bool textView_clickOnLink_atIndex(objc.id id, objc.SEL sel, objc.id  textView, objc.id  link, objc.id charIndex) {
    NSString str = new NSString (link);
    Event event = new Event ();
    event.text = str.getString();
    sendEvent (DWT.Selection, event);
    return true;
}

public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    if (wHint !is DWT.DEFAULT && wHint < 0) wHint = 0;
    if (hHint !is DWT.DEFAULT && hHint < 0) hHint = 0;
    int width, height;
    //TODO wrapping, wHint
    NSBorderType borderStyle = cast(NSBorderType)(hasBorder() ? OS.NSBezelBorder : OS.NSNoBorder);
    NSSize borderSize = NSScrollView.frameSizeForContentSize(NSSize(), false, false, borderStyle);
    NSTextView widget = cast(NSTextView)view;
    NSSize size = widget.textStorage().size();
    width = cast(int)(size.width + borderSize.width);
    height = cast(int)(size.height + borderSize.height);
    if (wHint !is DWT.DEFAULT) width = wHint;
    if (hHint !is DWT.DEFAULT) height = hHint;
    int border = getBorderWidth ();
    width += border * 2;
    height += border * 2;

    // TODO is this true?  if so, can this rounding be turned off?
    /*
     * Bug in Cocoa.  NSTextStorage.size() seems to return a width
     * value that is rounded down, because its result is never
     * fractional.  The workaround is to increment width by 1
     * to ensure that it is wide enough to show the full text.
     */
    width += 1;
    return new Point (width, height);
}

void createHandle () {
    state |= THEME_BACKGROUND;
    NSScrollView scrollWidget = cast(NSScrollView)(new SWTScrollView()).alloc();
    scrollWidget.initWithFrame(NSRect ());
    scrollWidget.init();
    scrollWidget.setDrawsBackground(false);
    scrollWidget.setBorderType(cast(NSBorderType)(hasBorder() ? OS.NSBezelBorder : OS.NSNoBorder));

    NSTextView widget = cast(NSTextView)(new SWTTextView()).alloc();
    widget.init();
    widget.setEditable(false);
    widget.setDrawsBackground(false);
    widget.setDelegate(widget);
    widget.setAutoresizingMask (OS.NSViewWidthSizable | OS.NSViewHeightSizable);
    widget.textContainer().setLineFragmentPadding(0);

    scrollView = scrollWidget;
    view = widget;
}

void createWidget () {
    super.createWidget ();
    text = "";
    NSDictionary dict = (cast(NSTextView)view).linkTextAttributes();
    linkColor = new NSColor(dict.valueForKey(OS.NSForegroundColorAttributeName));
}

NSFont defaultNSFont () {
    return display.textViewFont;
}

void deregister () {
    super.deregister ();
    if (scrollView !is null) display.removeWidget (scrollView);
}

void enableWidget (bool enabled) {
    super.enableWidget (enabled);
    NSColor nsColor = null;
    if (enabled) {
        if (foreground is null) {
            nsColor = NSColor.textColor ();
        } else {
            nsColor = NSColor.colorWithDeviceRed (foreground [0], foreground [1], foreground [2], foreground[3]);
        }
    } else {
        nsColor = NSColor.disabledControlTextColor();
    }
    NSTextView widget = cast(NSTextView)view;
    widget.setTextColor(nsColor);
    NSDictionary linkTextAttributes = widget.linkTextAttributes();
    NSUInteger count = linkTextAttributes.count();
    NSMutableDictionary dict = NSMutableDictionary.dictionaryWithCapacity(count);
    dict.setDictionary(linkTextAttributes);
    dict.setValue(enabled ? linkColor : nsColor, OS.NSForegroundColorAttributeName);
    widget.setLinkTextAttributes(dict);
}

String getNameText () {
    return getText ();
}


/**
 * Returns the receiver's text, which will be an empty
 * string if it has never been set.
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
    return text;
}

void register () {
    super.register ();
    if (scrollView !is null) display.addWidget (scrollView, this);
}

void releaseWidget () {
    super.releaseWidget ();
    offsets = null;
    ids = null;
    mnemonics = null;
    text = null;
    linkColor = null;
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
public void removeSelectionListener (SelectionListener listener) {
    checkWidget ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (DWT.Selection, listener);
    eventTable.unhook (DWT.DefaultSelection, listener);
}

String parse (String string) {
    int length_ = string.length;
    offsets = new Point [length_ / 4];
    ids = new String [length_ / 4];
    mnemonics = new int [length_ / 4 + 1];
    StringBuffer result = new StringBuffer ();
    char [] buffer = new char [length_];
    string.getChars (0, string.length, buffer, 0);
    int index = 0, state = 0, linkIndex = 0;
    int start = 0, tagStart = 0, linkStart = 0, endtagStart = 0, refStart = 0;
    while (index < length_) {
        char c = Character.toLowerCase (buffer [index]);
        switch (state) {
            case 0:
                if (c is '<') {
                    tagStart = index;
                    state++;
                }
                break;
            case 1:
                if (c is 'a') state++;
                break;
            case 2:
                switch (c) {
                    case 'h':
                        state = 7;
                        break;
                    case '>':
                        linkStart = index  + 1;
                        state++;
                        break;
                    default:
                        if (Character.isWhitespace(c)) break;
                        else state = 13;
                }
                break;
            case 3:
                if (c is '<') {
                    endtagStart = index;
                    state++;
                }
                break;
            case 4:
                state = c is '/' ? state + 1 : 3;
                break;
            case 5:
                state = c is 'a' ? state + 1 : 3;
                break;
            case 6:
                if (c is '>') {
                    mnemonics [linkIndex] = parseMnemonics (buffer, start, tagStart, result);
                    int offset = result.length ();
                    parseMnemonics (buffer, linkStart, endtagStart, result);
                    offsets [linkIndex] = new Point (offset, result.length () - 1);
                    if (ids [linkIndex] is null) {
                        ids [linkIndex] = new_String (buffer, linkStart, endtagStart - linkStart);
                    }
                    linkIndex++;
                    start = tagStart = linkStart = endtagStart = refStart = index + 1;
                    state = 0;
                } else {
                    state = 3;
                }
                break;
            case 7:
                state = c is 'r' ? state + 1 : 0;
                break;
            case 8:
                state = c is 'e' ? state + 1 : 0;
                break;
            case 9:
                state = c is 'f' ? state + 1 : 0;
                break;
            case 10:
                state = c is '=' ? state + 1 : 0;
                break;
            case 11:
                if (c is '"') {
                    state++;
                    refStart = index + 1;
                } else {
                    state = 0;
                }
                break;
            case 12:
                if (c is '"') {
                    ids[linkIndex] = new_String (buffer, refStart, index - refStart);
                    state = 2;
                }
                break;
            case 13:
                if (Character.isWhitespace (c)) {
                    state = 0;
                } else if (c is '='){
                    state++;
                }
                break;
            case 14:
                state = c is '"' ? state + 1 : 0;
                break;
            case 15:
                if (c is '"') state = 2;
                break;
            default:
                state = 0;
                break;
        }
        index++;
    }
    if (start < length_) {
        int tmp = parseMnemonics (buffer, start, tagStart, result);
        int mnemonic = parseMnemonics (buffer, Math.max (tagStart, linkStart), length_, result);
        if (mnemonic is -1) mnemonic = tmp;
        mnemonics [linkIndex] = mnemonic;
    } else {
        mnemonics [linkIndex] = -1;
    }
    if (offsets.length !is linkIndex) {
        Point [] newOffsets = new Point [linkIndex];
        System.arraycopy (offsets, 0, newOffsets, 0, linkIndex);
        offsets = newOffsets;
        String [] newIDs = new String [linkIndex];
        System.arraycopy (ids, 0, newIDs, 0, linkIndex);
        ids = newIDs;
        int [] newMnemonics = new int [linkIndex + 1];
        System.arraycopy (mnemonics, 0, newMnemonics, 0, linkIndex + 1);
        mnemonics = newMnemonics;
    }
    return result.toString ();
}

int parseMnemonics (char[] buffer, int start, int end, StringBuffer result) {
    int mnemonic = -1, index = start;
    while (index < end) {
        if (buffer [index] is '&') {
            if (index + 1 < end && buffer [index + 1] is '&') {
                result.append (buffer [index]);
                index++;
            } else {
                mnemonic = result.length();
            }
        } else {
            result.append (buffer [index]);
        }
        index++;
    }
    return mnemonic;
}

void updateBackground () {
    NSColor nsColor = null;
    if (backgroundImage !is null) {
        nsColor = NSColor.colorWithPatternImage(backgroundImage.handle);
    } else if (background !is null) {
        nsColor = NSColor.colorWithDeviceRed(background[0], background[1], background[2], background[3]);
    }
    setBackground(nsColor);
}

void setBackground(NSColor nsColor) {
    NSTextView widget = cast(NSTextView)view;
    if (nsColor is null) {
        widget.setDrawsBackground(false);
    } else {
        widget.setDrawsBackground(true);
        widget.setBackgroundColor (nsColor);
    }
}

void setFont(NSFont font) {
    (cast(NSTextView) view).setFont(font);
}

void setForeground (Cocoa.CGFloat [] color) {
    if (!getEnabled ()) return;
    NSColor nsColor;
    if (color is null) {
        nsColor = NSColor.textColor ();
    } else {
        nsColor = NSColor.colorWithDeviceRed (color [0], color [1], color [2], 1);
    }
    (cast(NSTextView) view).setTextColor (nsColor);
}

void setForeground (Cocoa.CGFloat [] color) {
    if (!getEnabled ()) return;
    NSColor nsColor;
    if (color is null) {
        nsColor = NSColor.textColor ();
    } else {
        nsColor = NSColor.colorWithDeviceRed (color [0], color [1], color [2], 1);
    }
    (cast(NSTextView) view).setTextColor (nsColor);
}

/**
 * Sets the receiver's text.
 * <p>
 * The string can contain both regular text and hyperlinks.  A hyperlink
 * is delimited by an anchor tag, &lt;A&gt; and &lt;/A&gt;.  Within an
 * anchor, a single HREF attribute is supported.  When a hyperlink is
 * selected, the text field of the selection event contains either the
 * text of the hyperlink or the value of its HREF, if one was specified.
 * In the rare case of identical hyperlinks within the same string, the
 * HREF attribute can be used to distinguish between them.  The string may
 * include the mnemonic character and line delimiters. The only delimiter
 * the HREF attribute supports is the quotation mark (").
 * </p>
 *
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
public void setText (String string) {
    checkWidget ();
    // DWT extension: allow null for zero length string
    //if (string is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (string == text) return;
    text = string;
    NSTextView widget = cast(NSTextView)view;
    widget.setString(NSString.stringWith(parse(string)));
    NSTextStorage textStorage = widget.textStorage();
    NSRange range = NSRange();
    for (int i = 0; i < offsets.length; i++) {
        range.location = offsets[i].x;
        range.length = offsets[i].y - offsets[i].x + 1;
        textStorage.addAttribute(OS.NSLinkAttributeName, NSString.stringWith(ids[i]), range);
    }
}

void setZOrder () {
    super.setZOrder ();
    if (scrollView !is null) scrollView.setDocumentView (view);
}

NSView topView () {
    return scrollView;
}

void updateCursorRects (bool enabled) {
    updateCursorRects (enabled);
    if (scrollView is null) return;
    updateCursorRects (enabled, scrollView);
    NSClipView contentView = scrollView.contentView ();
    updateCursorRects (enabled, contentView);
    contentView.setDocumentCursor (enabled ? NSCursor.IBeamCursor () : null);
}

//int traversalCode (int key, int theEvent) {
//  if (offsets.length is 0) return 0;
//  int bits = super.traversalCode (key, theEvent);
//  if (key is 48 /* Tab */ && theEvent !is 0) {
//      int [] modifiers = new int [1];
//      OS.GetEventParameter (theEvent, OS.kEventParamKeyModifiers, OS.typeUInt32, null, 4, null, modifiers);
//      bool next = (modifiers [0] & OS.shiftKey) is 0;
//      if (next && focusIndex < offsets.length - 1) {
//          return bits & ~ DWT.TRAVERSE_TAB_NEXT;
//      }
//      if (!next && focusIndex > 0) {
//          return bits & ~ DWT.TRAVERSE_TAB_PREVIOUS;
//      }
//  }
//  return bits;
//}

}
