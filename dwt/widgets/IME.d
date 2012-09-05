/*******************************************************************************
 * Copyright (c) 2007, 2009 IBM Corporation and others.
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
module dwt.widgets.IME;

import dwt.DWT;



import dwt.dwthelper.utils;
import dwt.dwthelper.System;
import dwt.internal.cocoa.NSFont;
import dwt.internal.cocoa.NSColor;
import dwt.internal.cocoa.NSNumber;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSView;
import dwt.internal.cocoa.NSMutableArray;
import dwt.internal.cocoa.NSAttributedString;
import dwt.internal.cocoa.OS;
import dwt.internal.c.Carbon;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;
import dwt.internal.cocoa.NSRange;
import dwt.internal.cocoa.NSDictionary;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSPoint;
import dwt.widgets.Canvas;
import dwt.widgets.Caret;
import dwt.widgets.Event;
import dwt.widgets.Widget;
import dwt.widgets.Shell;
import dwt.graphics.TextStyle;
import dwt.graphics.Font;
import dwt.graphics.Color;

/**
 * Instances of this class represent input method editors.
 * These are typically in-line pre-edit text areas that allow
 * the user to compose characters from Far Eastern languages
 * such as Japanese, Chinese or Korean.
 *
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>(none)</dd>
 * <dt><b>Events:</b></dt>
 * <dd>ImeComposition</dd>
 * </dl>
 * <p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.4
 * @noextend This class is not intended to be subclassed by clients.
 */
public class IME : Widget {
    Canvas parent;
    int caretOffset;
    int startOffset;
    int commitCount;
    String text;
    int [] ranges;
    TextStyle [] styles;

    static final int UNDERLINE_THICK = 1 << 16;

/**
 * Prevents uninitialized instances from being created outside the package.
 */
this () {
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
 * @param parent a canvas control which will be the parent of the new instance (cannot be null)
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
public this (Canvas parent, int style) {
    super (parent, style);
    this.parent = parent;
    createWidget ();
}

objc.id attributedSubstringFromRange (objc.id id, objc.SEL sel, NSRangePointer rangePtr) {
    Event event = new Event ();
    event.detail = DWT.COMPOSITION_SELECTION;
    sendEvent (DWT.ImeComposition, event);
    NSRange range = NSRange ();
    OS.memmove (&range, rangePtr, NSRange.sizeof);
    int start = cast(int)/*64*/range.location;
    int end = cast(int)/*64*/(range.location + range.length);
    if (event.start <= start && start <= event.end && event.start <= end && end <= event.end) {
        NSString str = NSString.stringWith (event.text.substring(start - event.start, end - event.start));
        NSAttributedString attriStr = (cast(NSAttributedString)(new NSAttributedString()).alloc()).initWithString(str, null);
        attriStr.autorelease ();
        return attriStr.id;
    }
    return null;
}

NSInteger characterIndexForPoint (objc.id id, objc.SEL sel, NSPointPointer point) {
    if (!isInlineEnabled ()) return OS.NSNotFound;
    NSPoint pt = NSPoint ();
    OS.memmove (&pt, point, NSPoint.sizeof);
    NSView view = parent.view;
    pt = view.window ().convertScreenToBase (pt);
    pt = view.convertPoint_fromView_ (pt, null);
    Event event = new Event ();
    event.detail = DWT.COMPOSITION_OFFSET;
    event.x = cast(int) pt.x;
    event.y = cast(int) pt.y;
    sendEvent (DWT.ImeComposition, event);
    NSInteger offset = event.index + event.count;
    return offset !is -1 ? offset : OS.NSNotFound;
}

void createWidget () {
    text = "";
    startOffset = -1;
    if (parent.getIME () is null) {
        parent.setIME (this);
    }
}

NSRect firstRectForCharacterRange(objc.id id, objc.SEL sel, objc.id range) {
    NSRect rect = NSRect ();
    Caret caret = parent.caret;
    if (caret !is null) {
        NSView view = parent.view;
        NSPoint pt = NSPoint ();
        pt.x = caret.x;
        pt.y = caret.y + caret.height;
        pt = view.convertPoint_toView_ (pt, null);
        pt = view.window ().convertBaseToScreen (pt);
        rect.x = pt.x;
        rect.y = pt.y;
        rect.width = caret.width;
        rect.height = caret.height;
    }
    return rect;
}

/**
 * Returns the offset of the caret from the start of the document.
 * The caret is within the current composition.
 *
 * @return the caret offset
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getCaretOffset () {
    checkWidget ();
    return startOffset + caretOffset;
}

/**
 * Returns the commit count of the composition.  This is the
 * number of characters that have been composed.  When the
 * commit count is equal to the length of the composition
 * text, then the in-line edit operation is complete.
 *
 * @return the commit count
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see IME#getText
 */
public int getCommitCount () {
    checkWidget ();
    return commitCount;
}

/**
 * Returns the offset of the composition from the start of the document.
 * This is the start offset of the composition within the document and
 * in not changed by the input method editor itself during the in-line edit
 * session.
 *
 * @return the offset of the composition
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getCompositionOffset () {
    checkWidget ();
    return startOffset;
}

/**
 * Returns the ranges for the style that should be applied during the
 * in-line edit session.
 * <p>
 * The ranges array contains start and end pairs.  Each pair refers to
 * the corresponding style in the styles array.  For example, the pair
 * that starts at ranges[n] and ends at ranges[n+1] uses the style
 * at styles[n/2] returned by <code>getStyles()</code>.
 * </p>
 * @return the ranges for the styles
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see IME#getStyles
 */
public int [] getRanges () {
    checkWidget ();
    if (ranges is null) return new int [0];
    int [] result = new int [ranges.length];
    for (int i = 0; i < result.length; i++) {
        result [i] = ranges [i] + startOffset;
    }
    return result;
}

/**
 * Returns the styles for the ranges.
 * <p>
 * The ranges array contains start and end pairs.  Each pair refers to
 * the corresponding style in the styles array.  For example, the pair
 * that starts at ranges[n] and ends at ranges[n+1] uses the style
 * at styles[n/2].
 * </p>
 *
 * @return the ranges for the styles
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see IME#getRanges
 */
public TextStyle [] getStyles () {
    checkWidget ();
    if (styles is null) return new TextStyle [0];
    TextStyle [] result = new TextStyle [styles.length];
    System.arraycopy (styles, 0, result, 0, styles.length);
    return result;
}

TextStyle getStyle (NSDictionary attribs) {
    NSArray keys = attribs.allKeys ();
    NSUInteger count = keys.count ();
    TextStyle style = new TextStyle ();
    for (NSUInteger j = 0; j < count; j++) {
        NSString key = new NSString (keys.objectAtIndex (j));
        if (key.isEqualTo (OS.NSBackgroundColorAttributeName)) {
            NSColor color = (new NSColor (attribs.objectForKey (key))).colorUsingColorSpaceName (OS.NSCalibratedRGBColorSpace);
            CGFloat [] rgbColor = [color.redComponent(), color.greenComponent(), color.blueComponent(), color.alphaComponent()];
            style.background = Color.cocoa_new (display, rgbColor);
        } else if (key.isEqualTo (OS.NSForegroundColorAttributeName)) {
            NSColor color = (new NSColor (attribs.objectForKey (key))).colorUsingColorSpaceName (OS.NSCalibratedRGBColorSpace);
            CGFloat [] rgbColor = [color.redComponent(), color.greenComponent(), color.blueComponent(), color.alphaComponent()];
            style.foreground = Color.cocoa_new (display, rgbColor);
        } else if (key.isEqualTo (OS.NSUnderlineColorAttributeName)) {
            NSColor color = (new NSColor (attribs.objectForKey (key))).colorUsingColorSpaceName (OS.NSCalibratedRGBColorSpace);
            CGFloat [] rgbColor = [color.redComponent(), color.greenComponent(), color.blueComponent(), color.alphaComponent()];
            style.underlineColor = Color.cocoa_new (display, rgbColor);
        } else if (key.isEqualTo (OS.NSUnderlineStyleAttributeName)) {
            NSNumber value = new NSNumber (attribs.objectForKey (key));
            switch (value.intValue ()) {
                case OS.NSUnderlineStyleSingle: style.underlineStyle = DWT.UNDERLINE_SINGLE; break;
                case OS.NSUnderlineStyleDouble: style.underlineStyle = DWT.UNDERLINE_DOUBLE; break;
                case OS.NSUnderlineStyleThick: style.underlineStyle = UNDERLINE_THICK; break;
                default:
            }
            style.underline = value.intValue () !is OS.NSUnderlineStyleNone;
        } else if (key.isEqualTo (OS.NSStrikethroughColorAttributeName)) {
            NSColor color = (new NSColor (attribs.objectForKey (key))).colorUsingColorSpaceName (OS.NSCalibratedRGBColorSpace);
            CGFloat [] rgbColor = [color.redComponent(), color.greenComponent(), color.blueComponent(), color.alphaComponent()];
            style.strikeoutColor = Color.cocoa_new (display, rgbColor);
        } else if (key.isEqualTo (OS.NSStrikethroughStyleAttributeName)) {
            NSNumber value = new NSNumber (attribs.objectForKey (key));
            style.strikeout = value.intValue () !is OS.NSUnderlineStyleNone;
        } else if (key.isEqualTo (OS.NSFontAttributeName)) {
            NSFont font = new NSFont (attribs.objectForKey (key));
            font.retain();
            style.font = Font.cocoa_new (display, font);
        }
    }
    return style;
}

/**
 * Returns the composition text.
 * <p>
 * The text for an IME is the characters in the widget that
 * are in the current composition. When the commit count is
 * equal to the length of the composition text, then the
 * in-line edit operation is complete.
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
    return text;
}

/**
 * Returns <code>true</code> if the caret should be wide, and
 * <code>false</code> otherwise.  In some languages, for example
 * Korean, the caret is typically widened to the width of the
 * current character in the in-line edit session.
 *
 * @return the wide caret state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool getWideCaret() {
    return false;
}

bool hasMarkedText (objc.id id, objc.SEL sel) {
    return text.length !is 0;
}

bool insertText (objc.id id, objc.SEL sel, objc.id string) {
    if (startOffset is -1) return true;
    NSString str = new NSString (string);
    if (str.isKindOfClass (cast(objc.Class) OS.objc_getClass ("NSAttributedString"))) {
        str = (new NSAttributedString (string)).string ();
    }
    NSUInteger length = str.length ();
    NSUInteger end = startOffset + text.length;
    resetStyles ();
    caretOffset = commitCount = length;
    Event event = new Event ();
    event.detail = DWT.COMPOSITION_CHANGED;
    event.start = startOffset;
    event.end = end;
    event.text = text = str.getString();
    sendEvent (DWT.ImeComposition, event);
    text = "";
    caretOffset = commitCount = 0;
    startOffset = -1;
    return event.doit;
}

bool isInlineEnabled () {
    return hooks (DWT.ImeComposition);
}

NSRange markedRange (objc.id id, objc.SEL sel) {
    NSRange range = NSRange ();
    if (startOffset !is -1) {
        range.location = startOffset;
        range.length = text.length;
    } else {
        range.location = OS.NSNotFound;
    }
    return range;
}

void resetStyles () {
    if (styles !is null) {
        for (int i = 0; i < styles.length; i++) {
            TextStyle style = styles [i];
            Font font = style.font;
            if (font !is null) font.handle.release ();
        }
    }
    styles = null;
    ranges = null;
}

void releaseParent () {
    super.releaseParent ();
    if (this is parent.getIME ()) parent.setIME (null);
}

void releaseWidget () {
    super.releaseWidget ();
    parent = null;
    text = null;
    resetStyles ();
}

NSRange selectedRange (objc.id id, objc.SEL sel) {
    Event event = new Event ();
    event.detail = DWT.COMPOSITION_SELECTION;
    sendEvent (DWT.ImeComposition, event);
    NSRange range = NSRange ();
    range.location = event.start;
    range.length = event.text.length;
    return range;
}

/**
 * Sets the offset of the composition from the start of the document.
 * This is the start offset of the composition within the document and
 * in not changed by the input method editor itself during the in-line edit
 * session but may need to be changed by clients of the IME.  For example,
 * if during an in-line edit operation, a text editor inserts characters
 * above the IME, then the IME must be informed that the composition
 * offset has changed.
 *
 * @param offset the offset of the composition
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setCompositionOffset (int offset) {
    checkWidget ();
    if (offset < 0) return;
    if (startOffset !is -1) {
        startOffset = offset;
    }
}

bool setMarkedText_selectedRange (objc.id id, objc.SEL sel, objc.id string, objc.id selRange) {
    if (!isInlineEnabled ()) return true;
    resetStyles ();
    caretOffset = commitCount = 0;
    int end = startOffset + text.length;
    if (startOffset is -1) {
        Event event = new Event ();
        event.detail = DWT.COMPOSITION_SELECTION;
        sendEvent (DWT.ImeComposition, event);
        startOffset = event.start;
        end = event.end;
    }
    NSString str = new NSString (string);
    if (str.isKindOfClass (cast(objc.Class) OS.objc_getClass ("NSAttributedString"))) {
        NSAttributedString attribStr = new NSAttributedString (string);
        str = attribStr.string ();
        NSUInteger length = str.length ();
        styles = new TextStyle [length];
        ranges = new int [length * 2];
        NSRange rangeLimit = NSRange (), effectiveRange = NSRange ();
        rangeLimit.length = length;
        int rangeCount = 0;
        NSRangePointer ptr = cast(NSRangePointer) OS.malloc (NSRange.sizeof);
        for (NSUInteger i = 0; i < length;) {
            NSDictionary attribs = attribStr.attributesAtIndex(i, ptr, rangeLimit);
            OS.memmove (&effectiveRange, ptr, NSRange.sizeof);
            i = effectiveRange.location + effectiveRange.length;
            ranges [rangeCount * 2] = cast(int)/*64*/effectiveRange.location;
            ranges [rangeCount * 2 + 1] = cast(int)/*64*/(effectiveRange.location + effectiveRange.length - 1);
            styles [rangeCount++] = getStyle (attribs);
        }
        OS.free (ptr);
        if (rangeCount !is styles.length) {
            TextStyle [] newStyles = new TextStyle [rangeCount];
            System.arraycopy (styles, 0, newStyles, 0, newStyles.length);
            styles = newStyles;
            int [] newRanges = new int [rangeCount * 2];
            System.arraycopy (ranges, 0, newRanges, 0, newRanges.length);
            ranges = newRanges;
        }
    }
    NSUInteger length = str.length ();
    if (ranges is null && length > 0) {
        styles = [getStyle (display.markedAttributes)];
        ranges = [0, length - 1];
    }
    NSRange range = NSRange ();
    OS.memmove (&range, selRange, NSRange.sizeof);
    caretOffset = cast(int)/*64*/range.location;
    Event event = new Event ();
    event.detail = DWT.COMPOSITION_CHANGED;
    event.start = startOffset;
    event.end = end;
    event.text = text = str.getString();
    sendEvent (DWT.ImeComposition, event);
    if (isDisposed ()) return false;
    if (text.length is 0) {
        Shell s = parent.getShell ();
        s.keyInputHappened = true;
        startOffset = -1;
        resetStyles ();
    }
    return true;
}

objc.id validAttributesForMarkedText (objc.id id, objc.SEL sel) {
    NSMutableArray attribs = NSMutableArray.arrayWithCapacity (6);
    attribs.addObject (new NSString (OS.NSForegroundColorAttributeName_ ));
    attribs.addObject (new NSString (OS.NSBackgroundColorAttributeName_ ));
    attribs.addObject (new NSString (OS.NSUnderlineStyleAttributeName_ ));
    attribs.addObject (new NSString (OS.NSUnderlineColorAttributeName_ ));
    attribs.addObject (new NSString (OS.NSStrikethroughStyleAttributeName_ ));
    attribs.addObject (new NSString (OS.NSStrikethroughColorAttributeName_ ));
    return attribs.id;
}

}
