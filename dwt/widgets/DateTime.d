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
module dwt.widgets.DateTime;

import dwt.dwthelper.utils;






import tango.text.convert.Format;

import dwt.DWT;
import Carbon = dwt.internal.c.Carbon;
import dwt.internal.cocoa.NSFont;
import dwt.internal.cocoa.NSCalendarDate;
import dwt.internal.cocoa.NSEvent;
import dwt.internal.cocoa.NSColor;
import dwt.internal.cocoa.NSDate;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.NSControl;
import dwt.internal.cocoa.NSDatePicker;
import dwt.internal.cocoa.SWTDatePicker;
import dwt.internal.cocoa.NSApplication;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import dwt.widgets.Composite;
import dwt.widgets.TypedListener;
import dwt.graphics.Point;
import dwt.events.SelectionListener;

/**
 * Instances of this class are selectable user interface
 * objects that allow the user to enter and modify date
 * or time values.
 * <p>
 * Note that although this class is a subclass of <code>Composite</code>,
 * it does not make sense to add children to it, or set a layout on it.
 * </p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>DATE, TIME, CALENDAR, SHORT, MEDIUM, LONG, DROP_DOWN</dd>
 * <dt><b>Events:</b></dt>
 * <dd>DefaultSelection, Selection</dd>
 * </dl>
 * <p>
 * Note: Only one of the styles DATE, TIME, or CALENDAR may be specified,
 * and only one of the styles SHORT, MEDIUM, or LONG may be specified.
 * The DROP_DOWN style is a <em>HINT</em>, and it is only valid with the DATE style.
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#datetime">DateTime snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">DWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.3
 * @noextend This class is not intended to be subclassed by clients.
 */
public class DateTime : Composite {
    static final int MIN_YEAR = 1752; // Gregorian switchover in North America: September 19, 1752
    static final int MAX_YEAR = 9999;

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
 * @see DWT#DATE
 * @see DWT#TIME
 * @see DWT#CALENDAR
 * @see DWT#SHORT
 * @see DWT#MEDIUM
 * @see DWT#LONG
 * @see DWT#DROP_DOWN
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, checkStyle (style));
}

static int checkStyle (int style) {
    /*
     * Even though it is legal to create this widget
     * with scroll bars, they serve no useful purpose
     * because they do not automatically scroll the
     * widget's client area.  The fix is to clear
     * the DWT style.
     */
    style &= ~(DWT.H_SCROLL | DWT.V_SCROLL);
    style = checkBits (style, DWT.MEDIUM, DWT.SHORT, DWT.LONG, 0, 0, 0);
    return checkBits (style, DWT.DATE, DWT.TIME, DWT.CALENDAR, 0, 0, 0);
}

protected void checkSubclass () {
    if (!isValidSubclass ()) error (DWT.ERROR_INVALID_SUBCLASS);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the control is selected by the user, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * <code>widgetSelected</code> is called when the user changes the control's value.
 * <code>widgetDefaultSelected</code> is typically called when ENTER is pressed.
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

public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    int width = 0, height = 0;
    NSControl widget = cast(NSControl)view;
    NSSize size = widget.cell ().cellSize ();
    width = cast(int)Math.ceil (size.width);
    height = cast(int)Math.ceil (size.height);
    if (width is 0) width = DEFAULT_WIDTH;
    if (height is 0) height = DEFAULT_HEIGHT;
    if (wHint !is DWT.DEFAULT) width = wHint;
    if (hHint !is DWT.DEFAULT) height = hHint;
    int border = getBorderWidth ();
    width += border * 2; height += border * 2;
    return new Point (width, height);
}

void createHandle () {
    NSDatePicker widget = cast(NSDatePicker)(new SWTDatePicker()).alloc();
    widget.init();
    NSDatePickerStyle pickerStyle = OS.NSTextFieldAndStepperDatePickerStyle;
    NSDatePickerElementFlags elementFlags;
    if ((style & DWT.CALENDAR) !is 0) {
        pickerStyle = OS.NSClockAndCalendarDatePickerStyle;
        elementFlags = OS.NSYearMonthDayDatePickerElementFlag;
    } else {
        if ((style & DWT.TIME) !is 0) {
            elementFlags = cast(NSDatePickerElementFlags)((style & DWT.SHORT) !is 0 ? OS.NSHourMinuteDatePickerElementFlag : OS.NSHourMinuteSecondDatePickerElementFlag);
        }
        if ((style & DWT.DATE) !is 0) {
            elementFlags = cast(NSDatePickerElementFlags)((style & DWT.SHORT) !is 0 ? OS.NSYearMonthDatePickerElementFlag : OS.NSYearMonthDayDatePickerElementFlag);
        }
    }
    widget.setDrawsBackground(true);
    widget.setDatePickerStyle(pickerStyle);
    widget.setDatePickerElements(elementFlags);
    NSDate date = NSCalendarDate.calendarDate();
    widget.setDateValue(date);
    widget.setTarget(widget);
    widget.setAction(OS.sel_sendSelection);
    view = widget;
}

NSFont defaultNSFont() {
    return display.datePickerFont;
}

NSCalendarDate getCalendarDate () {
    NSDate date = (cast(NSDatePicker)view).dateValue();
    return date.dateWithCalendarFormat(null, null);
}

/**
 * Returns the receiver's date, or day of the month.
 * <p>
 * The first day of the month is 1, and the last day depends on the month and year.
 * </p>
 *
 * @return a positive integer beginning with 1
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getDay () {
    checkWidget ();
    return cast(int)/*64*/getCalendarDate().dayOfMonth();
}

/**
 * Returns the receiver's hours.
 * <p>
 * Hours is an integer between 0 and 23.
 * </p>
 *
 * @return an integer between 0 and 23
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getHours () {
    checkWidget ();
    return cast(int)/*64*/getCalendarDate().hourOfDay();
}

/**
 * Returns the receiver's minutes.
 * <p>
 * Minutes is an integer between 0 and 59.
 * </p>
 *
 * @return an integer between 0 and 59
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getMinutes () {
    checkWidget ();
    return cast(int)/*64*/getCalendarDate().minuteOfHour();
}

/**
 * Returns the receiver's month.
 * <p>
 * The first month of the year is 0, and the last month is 11.
 * </p>
 *
 * @return an integer between 0 and 11
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getMonth () {
    checkWidget ();
    return cast(int)/*64*/getCalendarDate().monthOfYear() - 1;
}

String getNameText() {
    return (style & DWT.TIME) !is 0 ? Format("{}{}{}{}{}", getHours() , ":" , getMinutes() , ":" , getSeconds())
    : Format("{}{}{}{}{}", (getMonth() + 1) , "/" , getDay() , "/" , getYear());
}

/**
 * Returns the receiver's seconds.
 * <p>
 * Seconds is an integer between 0 and 59.
 * </p>
 *
 * @return an integer between 0 and 59
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getSeconds () {
    checkWidget ();
    return cast(int)/*64*/getCalendarDate().secondOfMinute();
}

/**
 * Returns the receiver's year.
 * <p>
 * The first year is 1752 and the last year is 9999.
 * </p>
 *
 * @return an integer between 1752 and 9999
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getYear () {
    checkWidget ();
    return cast(int)/*64*/getCalendarDate().yearOfCommonEra();
}

bool isEventView (objc.id id) {
    return true;
}

bool isFlipped (objc.id id, objc.SEL sel) {
    if ((style & DWT.CALENDAR) !is 0) return super.isFlipped (id, sel);
    return true;
}

bool isEventView (objc.id id) {
    return true;
}

bool isFlipped (objc.id id, objc.SEL sel) {
    if ((style & DWT.CALENDAR) !is 0) return super.isFlipped (id, sel);
    return true;
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

bool sendKeyEvent (NSEvent nsEvent, int type) {
    bool result = super.sendKeyEvent (nsEvent, type);
    if (!result) return result;
    if (type !is DWT.KeyDown) return result;
    if ((style & DWT.CALENDAR) is 0) {
        short keyCode = nsEvent.keyCode ();
        switch (keyCode) {
            case 76: /* KP Enter */
            case 36: /* Return */
                postEvent (DWT.DefaultSelection);
        }
    }
    return result;
}

void sendSelection () {
    NSEvent event = NSApplication.sharedApplication().currentEvent();
    if (event !is null && (style & DWT.CALENDAR) !is 0) {
        if (event.clickCount() is 2) {
            postEvent (DWT.DefaultSelection);
        } else if (event.type() is OS.NSLeftMouseUp) {
            postEvent (DWT.Selection);
        }
    } else { // DWT.DATE or DWT.TIME
        postEvent (DWT.Selection);
    }
}

void updateBackground () {
    NSColor nsColor = null;
    if (backgroundImage !is null) {
        nsColor = NSColor.colorWithPatternImage(backgroundImage.handle);
    } else if (background !is null) {
        nsColor = NSColor.colorWithDeviceRed(background[0], background[1], background[2], background[3]);
    } else {
        if ((style & DWT.CALENDAR) !is 0) {
            nsColor = NSColor.controlBackgroundColor ();
        } else {
            nsColor = NSColor.textBackgroundColor ();
        }

    }

}

void setBackgroundColor(NSColor nsColor) {
    (cast(NSDatePicker)view).setBackgroundColor(nsColor);
}

/**
 * Sets the receiver's year, month, and day in a single operation.
 * <p>
 * This is the recommended way to set the date, because setting the year,
 * month, and day separately may result in invalid intermediate dates.
 * </p>
 *
 * @param year an integer between 1752 and 9999
 * @param month an integer between 0 and 11
 * @param day a positive integer beginning with 1
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public void setDate (int year, int month, int day) {
    checkWidget ();
    if (year < MIN_YEAR || year > MAX_YEAR) return;
    NSCalendarDate date = getCalendarDate();
    NSCalendarDate newDate = NSCalendarDate.dateWithYear(year, month + 1, day,
                                                         date.hourOfDay(), date.minuteOfHour(), date.secondOfMinute(), date.timeZone());
    if (newDate.yearOfCommonEra() is year && newDate.monthOfYear() is month + 1 && newDate.dayOfMonth() is day) {
        (cast(NSDatePicker)view).setDateValue(newDate);
    }
}

/**
 * Sets the receiver's date, or day of the month, to the specified day.
 * <p>
 * The first day of the month is 1, and the last day depends on the month and year.
 * If the specified day is not valid for the receiver's month and year, then it is ignored.
 * </p>
 *
 * @param day a positive integer beginning with 1
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setDate
 */
public void setDay (int day) {
    checkWidget ();
    NSCalendarDate date = getCalendarDate();
    NSCalendarDate newDate = NSCalendarDate.dateWithYear(date.yearOfCommonEra(), date.monthOfYear(), day,
                                                         date.hourOfDay(), date.minuteOfHour(), date.secondOfMinute(), date.timeZone());
    if (newDate.yearOfCommonEra() is date.yearOfCommonEra() && newDate.monthOfYear() is date.monthOfYear() && newDate.dayOfMonth() is day) {
        (cast(NSDatePicker)view).setDateValue(newDate);
    }
}

void setForeground (Carbon.CGFloat [] color) {
    NSColor nsColor;
    if (color is null) {
        if ((style & DWT.CALENDAR) !is 0) {
            nsColor = NSColor.controlTextColor ();
        } else {
            nsColor = NSColor.textColor ();
        }
    } else {
        nsColor = NSColor.colorWithDeviceRed(color[0], color[1], color[2], 1);
    }
    (cast(NSDatePicker)view).setTextColor(nsColor);
}

/**
 * Sets the receiver's hours.
 * <p>
 * Hours is an integer between 0 and 23.
 * </p>
 *
 * @param hours an integer between 0 and 23
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setHours (int hours) {
    checkWidget ();
    if (hours < 0 || hours > 23) return;
    NSCalendarDate date = getCalendarDate();
    NSCalendarDate newDate = NSCalendarDate.dateWithYear(date.yearOfCommonEra(), date.monthOfYear(), date.dayOfMonth(),
                                                         hours, date.minuteOfHour(), date.secondOfMinute(), date.timeZone());
    (cast(NSDatePicker)view).setDateValue(newDate);
}

/**
 * Sets the receiver's minutes.
 * <p>
 * Minutes is an integer between 0 and 59.
 * </p>
 *
 * @param minutes an integer between 0 and 59
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setMinutes (int minutes) {
    checkWidget ();
    if (minutes < 0 || minutes > 59) return;
    NSCalendarDate date = getCalendarDate();
    NSCalendarDate newDate = NSCalendarDate.dateWithYear(date.yearOfCommonEra(), date.monthOfYear(), date.dayOfMonth(),
                                                         date.hourOfDay(), minutes, date.secondOfMinute(), date.timeZone());
    (cast(NSDatePicker)view).setDateValue(newDate);
}

/**
 * Sets the receiver's month.
 * <p>
 * The first month of the year is 0, and the last month is 11.
 * If the specified month is not valid for the receiver's day and year, then it is ignored.
 * </p>
 *
 * @param month an integer between 0 and 11
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setDate
 */
public void setMonth (int month) {
    checkWidget ();
    NSCalendarDate date = getCalendarDate();
    NSCalendarDate newDate = NSCalendarDate.dateWithYear(date.yearOfCommonEra(), month + 1, date.dayOfMonth(),
                                                         date.hourOfDay(), date.minuteOfHour(), date.secondOfMinute(), date.timeZone());
    if (newDate.yearOfCommonEra() is date.yearOfCommonEra() && newDate.monthOfYear() is month + 1 && newDate.dayOfMonth() is date.dayOfMonth()) {
        (cast(NSDatePicker)view).setDateValue(newDate);
    }
}

/**
 * Sets the receiver's seconds.
 * <p>
 * Seconds is an integer between 0 and 59.
 * </p>
 *
 * @param seconds an integer between 0 and 59
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSeconds (int seconds) {
    checkWidget ();
    if (seconds < 0 || seconds > 59) return;
    NSCalendarDate date = getCalendarDate();
    NSCalendarDate newDate = NSCalendarDate.dateWithYear(date.yearOfCommonEra(), date.monthOfYear(), date.dayOfMonth(),
                                                         date.hourOfDay(), date.minuteOfHour(), seconds, date.timeZone());
    (cast(NSDatePicker)view).setDateValue(newDate);
}

/**
 * Sets the receiver's hours, minutes, and seconds in a single operation.
 *
 * @param hours an integer between 0 and 23
 * @param minutes an integer between 0 and 59
 * @param seconds an integer between 0 and 59
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public void setTime (int hours, int minutes, int seconds) {
    checkWidget ();
    if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59 || seconds < 0 || seconds > 59) return;
    NSCalendarDate date = getCalendarDate();
    NSCalendarDate newDate = NSCalendarDate.dateWithYear(date.yearOfCommonEra(), date.monthOfYear(), date.dayOfMonth(),
                                                         hours, minutes, seconds, date.timeZone());
    (cast(NSDatePicker)view).setDateValue(newDate);
}

/**
 * Sets the receiver's year.
 * <p>
 * The first year is 1752 and the last year is 9999.
 * If the specified year is not valid for the receiver's day and month, then it is ignored.
 * </p>
 *
 * @param year an integer between 1752 and 9999
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setDate
 */
public void setYear (int year) {
    checkWidget ();
    if (year < MIN_YEAR || year > MAX_YEAR) return;
    NSCalendarDate date = getCalendarDate();
    NSCalendarDate newDate = NSCalendarDate.dateWithYear(year, date.monthOfYear(), date.dayOfMonth(),
                                                         date.hourOfDay(), date.minuteOfHour(), date.secondOfMinute(), date.timeZone());
    if (newDate.yearOfCommonEra() is year && newDate.monthOfYear() is date.monthOfYear() && newDate.dayOfMonth() is date.dayOfMonth()) {
        (cast(NSDatePicker)view).setDateValue(newDate);
    }
}
}
