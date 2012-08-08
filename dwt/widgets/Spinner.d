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
module dwt.widgets.Spinner;

import dwt.dwthelper.utils;






import Carbon = dwt.internal.c.Carbon;
import objc = dwt.internal.objc.runtime;
import dwt.widgets.Composite;
import dwt.widgets.Event;
import dwt.widgets.TypedListener;

/**
 * Instances of this class are selectable user interface
 * objects that allow the user to enter and modify numeric
 * values.
 * <p>
 * Note that although this class is a subclass of <code>Composite</code>,
 * it does not make sense to add children to it, or set a layout on it.
 * </p><p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>READ_ONLY, WRAP</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Selection, Modify, Verify</dd>
 * </dl>
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#spinner">Spinner snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">DWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.1
 * @noextend This class is not intended to be subclassed by clients.
 */
public class Spinner : Composite {
    NSTextField textView;
    NSNumberFormatter textFormatter;
    NSStepper buttonView;
    int pageIncrement = 10;
    int digits = 0;
    int textLimit = LIMIT;
    static int GAP = 0;

    /**
     * the operating system limit for the number of characters
     * that the text field in an instance of this class can hold
     *
     * @since 3.4
     */
    public static final int LIMIT;

    /*
    * These values can be different on different platforms.
    * Therefore they are not initialized in the declaration
    * to stop the compiler from inlining.
    */
    static {
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
 * @see DWT#READ_ONLY
 * @see DWT#WRAP
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, checkStyle (style));
}

bool acceptsFirstResponder(objc.id id, objc.SEL sel) {
    if (id is view.id) return false;
    return super.acceptsFirstResponder (id, sel);
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
 * <code>widgetDefaultSelected</code> is typically called when ENTER is pressed in a single-line text.
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
    TypedListener typedListener = new TypedListener(listener);
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
void addVerifyListener (VerifyListener listener) {
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (DWT.Verify, typedListener);
}

static int checkStyle (int style) {
    /*
     * Even though it is legal to create this widget
     * with scroll bars, they serve no useful purpose
     * because they do not automatically scroll the
     * widget's client area.  The fix is to clear
     * the DWT style.
     */
    return style & ~(DWT.H_SCROLL | DWT.V_SCROLL);
}

protected void checkSubclass () {
    if (!isValidSubclass ()) error (DWT.ERROR_INVALID_SUBCLASS);
}

public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    Carbon.CGFloat width = 0, height = 0;
    String string = Double.toString (buttonView.maxValue ());
    Font font = Font.cocoa_new(display, textView.font ());
    NSAttributedString str = parent.createString(string, font, null, 0, true, false);
    NSSize size = str.size ();
    str.release ();
    width = size.width;
    height = size.height;
    NSRect frameRect = textView.frame();
    NSCell cell = new NSCell (textView.cell ());
    NSRect cellRect = cell.drawingRectForBounds(frameRect);
    width += frameRect.width - cellRect.width;
    height += frameRect.height - cellRect.height;
    width += GAP;
    size = buttonView.cell ().cellSize ();
    width += (int)/*64*/size.width;
    height = Math.max (height, size.height);
    if (wHint !is DWT.DEFAULT) width = wHint;
    if (hHint !is DWT.DEFAULT) height = hHint;
    Rectangle trim = computeTrim (0, 0, (int)Math.ceil (width), (int)Math.ceil (height));
    return new Point (trim.width, trim.height);
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
    NSText fieldEditor = textView.currentEditor();
    if (fieldEditor !is null) {
        fieldEditor.copy(null);
    } else {
        //TODO
    }
}

void createHandle () {
    NSView widget = cast(NSView)(new SWTView()).alloc();
    widget.init();
    //  widget.setDrawsBackground(false);
    NSStepper buttonWidget = cast(NSStepper)(new SWTStepper()).alloc();
    buttonWidget.init();
    buttonWidget.setValueWraps((style & DWT.WRAP) !is 0);
    buttonWidget.setTarget(buttonWidget);
    buttonWidget.setAction(OS.sel_sendSelection);
    buttonWidget.setMaxValue(100);
    textWidget.initWithFrame(NSRect());
    textWidget.init();
    //  textWidget.setTarget(widget);
    textWidget.setEditable((style & DWT.READ_ONLY) is 0);
    textFormatter = (NSNumberFormatter)new NSNumberFormatter().alloc();
    textFormatter.init();
    widget.addSubview(textWidget);
    widget.addSubview(buttonWidget);
    buttonView = buttonWidget;
    textView = textWidget;
    view = widget;
    setSelection (0, false, true, false);
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
    NSText fieldEditor = textView.currentEditor();
    if (fieldEditor !is null) {
        fieldEditor.cut(null);
    } else {
        //TODO
    }
}

void enableWidget (bool enabled) {
    super.enableWidget(enabled);
    buttonView.setEnabled(enabled);
    textView.setEnabled(enabled);
}

NSFont defaultNSFont () {
    return display.textFieldFont;
}

void deregister () {
    super.deregister ();
    if (textView !is null) {
        display.removeWidget (textView);
        display.removeWidget (textView.cell());
    }

    if (buttonView !is null) {
        display.removeWidget (buttonView);
        display.removeWidget (buttonView.cell());
    }
}

NSView focusView () {
    return textView;
}

/**
 * Returns the number of decimal places used by the receiver.
 *
 * @return the digits
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getDigits () {
    checkWidget ();
    return digits;
}

/**
 * Returns the amount that the receiver's value will be
 * modified by when the up/down arrows are pressed.
 *
 * @return the increment
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getIncrement () {
    checkWidget ();
    return cast(int)buttonView.increment();
}

/**
 * Returns the maximum value which the receiver will allow.
 *
 * @return the maximum
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getMaximum () {
    checkWidget ();
    return cast(int)buttonView.maxValue();
}

/**
 * Returns the minimum value which the receiver will allow.
 *
 * @return the minimum
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getMinimum () {
    checkWidget ();
    return cast(int)buttonView.minValue();
}

/**
 * Returns the amount that the receiver's position will be
 * modified by when the page up/down keys are pressed.
 *
 * @return the page increment
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getPageIncrement () {
    checkWidget ();
    return pageIncrement;
}

/**
 * Returns the <em>selection</em>, which is the receiver's position.
 *
 * @return the selection
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getSelection () {
    checkWidget ();
    return cast(int)(cast(NSStepper)buttonView).doubleValue();
}

int getSelectionText (bool[] parseFail) {
    String string = textView.stringValue().getString();
    try {
        int value;
        if (digits > 0) {
            String decimalSeparator = textFormatter.decimalSeparator().getString();
            int index = string.indexOf (decimalSeparator);
            if (index !is -1)  {
                int startIndex = string.startsWith ("+") || string.startsWith ("-") ? 1 : 0;
                String wholePart = startIndex !is index ? string.substring (startIndex, index) : "0";
                String decimalPart = string.substring (index + 1);
                if (decimalPart.length () > digits) {
                    decimalPart = decimalPart.substring (0, digits);
                } else {
                    int i = digits - decimalPart.length ();
                    for (int j = 0; j < i; j++) {
                        decimalPart = decimalPart ~ "0";
                    }
                }
                int wholeValue = Integer.parseInt (wholePart);
                int decimalValue = Integer.parseInt (decimalPart);
                for (int i = 0; i < digits; i++) wholeValue *= 10;
                value = wholeValue + decimalValue;
                if (string.startsWith ("-")) value = -value;
            } else {
                value = Integer.parseInt (string);
                for (int i = 0; i < digits; i++) value *= 10;
            }
        } else {
            value = Integer.parseInt (string);
        }
        int max = getMaximum();
        int min = getMinimum();
        if (min <= value && value <= max) return value;
    } catch (NumberFormatException e) {
    }
    parseFail [0] = true;
    return -1;
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
 *
 * @since 3.4
 */
public String getText () {
    checkWidget ();
    NSString str = new NSTextFieldCell (textView.cell ()).title ();
    return str.getString ();
}

/**
 * Returns the maximum number of characters that the receiver's
 * text field is capable of holding. If this has not been changed
 * by <code>setTextLimit()</code>, it will be the constant
 * <code>Spinner.LIMIT</code>.
 *
 * @return the text limit
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #LIMIT
 *
 * @since 3.4
 */
public int getTextLimit () {
    checkWidget();
    return textLimit;
}

bool isEventView (int /*long*/ id) {
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
    NSText fieldEditor = textView.currentEditor();
    if (fieldEditor !is null) {
        fieldEditor.paste(null);
    } else {
        //TODO
    }
}

void register () {
    super.register ();
    if (textView !is null) {
        display.addWidget (textView, this);
        display.addWidget (textView.cell(), this);
    }

    if (buttonView !is null) {
        display.addWidget (buttonView, this);
        display.addWidget (buttonView.cell(), this);
    }
}

void releaseHandle () {
    super.releaseHandle();
    if (textFormatter !is null) textFormatter.release();
    if (buttonView !is null) buttonView.release();
    if (textView !is null) textView.release();
    textFormatter = null;
    buttonView = null;
    textView = null;
}

void releaseWidget () {
    super.releaseWidget ();
    if (textView !is null) textView.abortEditing();
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
 * @see #addVerifyListener
 */
void removeVerifyListener (VerifyListener listener) {
    checkWidget ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (DWT.Verify, listener);
}

void resized () {
    super.resized ();
    buttonView.sizeToFit();
    NSSize textSize = textView.cell ().cellSize ();
    NSRect buttonFrame = buttonView.bounds();
    NSRect frame = view.frame();
    buttonFrame.x = frame.width - buttonFrame.width;
    buttonFrame.y = (frame.height - buttonFrame.height) / 2;
    int textHeight = (int)Math.min(textSize.height, frame.height);
    frame.x = 0;
    frame.y = (frame.height - textHeight) / 2;
    frame.size.width -= buttonFrame.width + GAP;
    frame.height = textHeight;
    textView.setFrame(frame);
    buttonView.setFrame(buttonFrame);
}

bool sendKeyEvent (NSEvent nsEvent, int type) {
    bool result = super.sendKeyEvent (nsEvent, type);
    if (!result) return result;
    if (type !is DWT.KeyDown) return result;
    int delta = 0;
    short keyCode = nsEvent.keyCode ();
    switch (keyCode) {
        case 76: /* KP Enter */
        case 36: { /* Return */
            postEvent (DWT.DefaultSelection);
            return true;
        }

        case 116: delta = pageIncrement; break; /* Page Up */
        case 121: delta = -pageIncrement; break; /* Page Down */
        case 125: delta = -getIncrement(); break; /* Down arrow */
        case 126: delta = getIncrement(); break; /* Up arrow */
    }

    if (delta !is 0) {
        bool [] parseFail = new bool [1];
        int value = getSelectionText (parseFail);
        if (parseFail [0]) {
            value = (int)buttonView.doubleValue();
        }
        int newValue = value + delta;
        int max = (int)buttonView.maxValue();
        int min = (int)buttonView.minValue();
        if ((style & DWT.WRAP) !is 0) {
            if (newValue > max) newValue = min;
            if (newValue < min) newValue = max;
        }
        newValue = Math.min (Math.max (min, newValue), max);
        if (value !is newValue) setSelection (newValue, true, true, true);
        // Prevent the arrow or page up/down from being handled by the text field.
        result = false;
    } else {
        bool [] parseFail = new bool [1];
        int value = getSelectionText (parseFail);
        if (!parseFail [0]) {
            int pos = (int)buttonView.doubleValue();
            if (pos !is value) setSelection (value, true, false, true);
        }
    }

    return result;
}

void sendSelection () {
    setSelection (getSelection(), false, true, true);
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
    ((NSTextField) textView).setBackgroundColor (nsColor);
}

/**
 * Sets the number of decimal places used by the receiver.
 * <p>
 * The digit setting is used to allow for floating point values in the receiver.
 * For example, to set the selection to a floating point value of 1.37 call setDigits() with
 * a value of 2 and setSelection() with a value of 137. Similarly, if getDigits() has a value
 * of 2 and getSelection() returns 137 this should be interpreted as 1.37. This applies to all
 * numeric APIs.
 * </p>
 *
 * @param value the new digits (must be greater than or equal to zero)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the value is less than zero</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setDigits (int value) {
    checkWidget ();
    if (value < 0) error (DWT.ERROR_INVALID_ARGUMENT);
    if (value is digits) return;
    digits = value;
    int pos = cast(int)buttonView.doubleValue();
    setSelection (pos, false, true, false);
}

void setFont(NSFont font) {
    textView.setFont(font);
}

void setForeground (float /*double*/ [] color) {
    NSColor nsColor;
    if (color is null) {
        nsColor = NSColor.textColor ();
    } else {
        nsColor = NSColor.colorWithDeviceRed (color [0], color [1], color [2], 1);
    }
    ((NSTextField) textView).setTextColor (nsColor);
}

/**
 * Sets the amount that the receiver's value will be
 * modified by when the up/down arrows are pressed to
 * the argument, which must be at least one.
 *
 * @param value the new increment (must be greater than zero)
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setIncrement (int value) {
    checkWidget ();
    if (value < 1) return;
    buttonView.setIncrement(value);
}

/**
 * Sets the maximum value that the receiver will allow.  This new
 * value will be ignored if it is not greater than the receiver's current
 * minimum value.  If the new maximum is applied then the receiver's
 * selection value will be adjusted if necessary to fall within its new range.
 *
 * @param value the new maximum, which must be greater than the current minimum
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setMaximum (int value) {
    checkWidget ();
    int min = getMinimum ();
    if (value <= min) return;
    int pos = getSelection();
    buttonView.setMaxValue(value);
    if (pos > value) setSelection (value, true, true, false);
}

/**
 * Sets the minimum value that the receiver will allow.  This new
 * value will be ignored if it is not less than the receiver's
 * current maximum value.  If the new minimum is applied then the receiver's
 * selection value will be adjusted if necessary to fall within its new range.
 *
 * @param value the new minimum, which must be less than the current maximum
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setMinimum (int value) {
    checkWidget ();
    int max = getMaximum();
    if (value >= max) return;
    int pos = getSelection();
    buttonView.setMinValue(value);
    if (pos < value) setSelection (value, true, true, false);
}

/**
 * Sets the amount that the receiver's position will be
 * modified by when the page up/down keys are pressed
 * to the argument, which must be at least one.
 *
 * @param value the page increment (must be greater than zero)
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setPageIncrement (int value) {
    checkWidget ();
    if (value < 1) return;
    pageIncrement = value;
}

/**
 * Sets the <em>selection</em>, which is the receiver's
 * position, to the argument. If the argument is not within
 * the range specified by minimum and maximum, it will be
 * adjusted to fall within this range.
 *
 * @param value the new selection (must be zero or greater)
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSelection (int value) {
    checkWidget ();
    int min = getMinimum();
    int max = getMaximum();
    value = Math.min (Math.max (min, value), max);
    setSelection (value, true, true, false);
}

void setSelection (int value, bool setPos, bool setText, bool notify) {
    if (setPos) {
        (cast(NSStepper)buttonView).setDoubleValue(value);
    }
    if (setText) {
        String string = String_.valueOf (value);
        if (digits > 0) {
            String decimalSeparator = textFormatter.decimalSeparator().getString();
            int index = string.length () - digits;
            StringBuffer buffer = new StringBuffer ();
            if (index > 0) {
                buffer.append (string.substring (0, index));
                buffer.append (decimalSeparator);
                buffer.append (string.substring (index));
            } else {
                buffer.append ("0");
                buffer.append (decimalSeparator);
                while (index++ < 0) buffer.append ("0");
                buffer.append (string);
            }
            string = buffer.toString ();
        }
        NSCell cell = new NSCell(textView.cell());
        if (hooks (DWT.Verify) || filters (DWT.Verify)) {
            int length = cast(int)/*64*/cell.title().length();
            string = verifyText (string, 0, length, null);
            if (string is null) return;
        }
        textView.setStringValue(NSString.stringWith(string));
        NSRange selection = new NSRange();
        selection.location = 0;
        selection.length = string.length();
        NSText fieldEditor = textView.currentEditor();
        if (fieldEditor !is null) fieldEditor.setSelectedRange(selection);
        sendEvent (DWT.Modify);
    }
    if (notify) postEvent (DWT.Selection);
}

void setSmallSize () {
    textView.cell ().setControlSize (OS.NSSmallControlSize);
    buttonView.cell ().setControlSize (OS.NSSmallControlSize);
}

/**
 * Sets the maximum number of characters that the receiver's
 * text field is capable of holding to be the argument.
 * <p>
 * To reset this value to the default, use <code>setTextLimit(Spinner.LIMIT)</code>.
 * Specifying a limit value larger than <code>Spinner.LIMIT</code> sets the
 * receiver's limit to <code>Spinner.LIMIT</code>.
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
 *
 * @since 3.4
 */
public void setTextLimit (int limit) {
    checkWidget();
    if (limit is 0) error (DWT.ERROR_CANNOT_BE_ZERO);
    textLimit = limit;
}

/**
 * Sets the receiver's selection, minimum value, maximum
 * value, digits, increment and page increment all at once.
 * <p>
 * Note: This is similar to setting the values individually
 * using the appropriate methods, but may be implemented in a
 * more efficient fashion on some platforms.
 * </p>
 *
 * @param selection the new selection value
 * @param minimum the new minimum value
 * @param maximum the new maximum value
 * @param digits the new digits value
 * @param increment the new increment value
 * @param pageIncrement the new pageIncrement value
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.2
 */
public void setValues (int selection, int minimum, int maximum, int digits, int increment, int pageIncrement) {
    checkWidget ();
    if (maximum <= minimum) return;
    if (digits < 0) return;
    if (increment < 1) return;
    if (pageIncrement < 1) return;
    selection = Math.min (Math.max (minimum, selection), maximum);
    this.pageIncrement = pageIncrement;
    this.digits = digits;
    buttonView.setIncrement(increment);
    buttonView.setMaxValue(maximum);
    buttonView.setMinValue(minimum);
    setSelection (selection, true, true, false);
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
            int length = newText.length();
            NSText fieldEditor = textView.currentEditor ();
            if (fieldEditor !is null) {
                NSRange selectedRange = fieldEditor.selectedRange();
                if (textLimit !is LIMIT) {
                    int /*long*/ charCount = fieldEditor.string().length();
                    if (charCount - selectedRange.length + length > textLimit) {
                        length = (int)/*64*/(textLimit - charCount + selectedRange.length);
                    }
                }
                char [] buffer = new char [length];
                newText.getChars (0, buffer.length, buffer, 0);
                NSString nsstring = NSString.stringWithCharacters (buffer, buffer.length);
                fieldEditor.replaceCharactersInRange (fieldEditor.selectedRange (), nsstring);
                result = false;
            }
        }
        if (!result) sendEvent (DWT.Modify);
    }
    return result;
}

    super.textDidChange (id, sel, aNotification);
    bool [] parseFail = new bool [1];
    int value = getSelectionText (parseFail);
    if (!parseFail [0]) {
        int pos = (int)buttonView.doubleValue();
        if (value !is pos) {
            setSelection (value, true, false, true);
        }
    }
    }
    postEvent (DWT.Modify);
}

NSRange textView_willChangeSelectionFromCharacterRange_toCharacterRange (int /*long*/ id, int /*long*/ sel, int /*long*/ aTextView, int /*long*/ oldSelectedCharRange, int /*long*/ newSelectedCharRange) {
    /* allow the selection change to proceed */
    NSRange result = new NSRange ();
    OS.memmove(result, newSelectedCharRange, NSRange.sizeof);
    return result;
}

    bool [] parseFail = new bool [1];
    int value = getSelectionText (parseFail);
    if (parseFail [0]) {
        value = cast(int)buttonView.doubleValue();
        setSelection (value, false, true, false);
    }
    super.textDidEndEditing(id, sel, aNotification);
}

void updateCursorRects (bool enabled) {
    super.updateCursorRects (enabled);
    updateCursorRects (enabled, textView);
    updateCursorRects (enabled, buttonView);
}

String verifyText (String string, int start, int end, NSEvent keyEvent) {
    Event event = new Event ();
    if (keyEvent !is null) setKeyState(event, DWT.MouseDown, keyEvent);
    event.text = string;
    event.start = start;
    event.end = end;
    int index = 0;
    if (digits > 0) {
        String decimalSeparator = ".";//getDecimalSeparator ();
        index = string.indexOf (decimalSeparator);
        if (index !is -1) {
            string = string.substring (0, index) ~ string.substring (index + 1);
        }
        index = 0;
    }
    while (index < string.length ()) {
        if (!Character.isDigit (string.charAt (index))) break;
        index++;
    }
    event.doit = index is string.length ();
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
