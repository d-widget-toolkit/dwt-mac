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
module dwt.widgets.ScrollBar;








import dwt.DWT;
import dwt.dwthelper.utils;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSScroller;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import Carbon = dwt.internal.c.Carbon;
import objc = dwt.internal.objc.runtime;
import dwt.widgets.Event;
import dwt.widgets.Scrollable;
import dwt.widgets.TypedListener;
import dwt.widgets.Widget;
import dwt.events.SelectionListener;
import dwt.graphics.Point;

/**
 * Instances of this class are selectable user interface
 * objects that represent a range of positive, numeric values.
 * <p>
 * At any given moment, a given scroll bar will have a
 * single 'selection' that is considered to be its
 * value, which is constrained to be within the range of
 * values the scroll bar represents (that is, between its
 * <em>minimum</em> and <em>maximum</em> values).
 * </p><p>
 * Typically, scroll bars will be made up of five areas:
 * <ol>
 * <li>an arrow button for decrementing the value</li>
 * <li>a page decrement area for decrementing the value by a larger amount</li>
 * <li>a <em>thumb</em> for modifying the value by mouse dragging</li>
 * <li>a page increment area for incrementing the value by a larger amount</li>
 * <li>an arrow button for incrementing the value</li>
 * </ol>
 * Based on their style, scroll bars are either <code>HORIZONTAL</code>
 * (which have a left facing button for decrementing the value and a
 * right facing button for incrementing it) or <code>VERTICAL</code>
 * (which have an upward facing button for decrementing the value
 * and a downward facing buttons for incrementing it).
 * </p><p>
 * On some platforms, the size of the scroll bar's thumb can be
 * varied relative to the magnitude of the range of values it
 * represents (that is, relative to the difference between its
 * maximum and minimum values). Typically, this is used to
 * indicate some proportional value such as the ratio of the
 * visible area of a document to the total amount of space that
 * it would take to display it. DWT supports setting the thumb
 * size even if the underlying platform does not, but in this
 * case the appearance of the scroll bar will not change.
 * </p><p>
 * Scroll bars are created by specifying either <code>H_SCROLL</code>,
 * <code>V_SCROLL</code> or both when creating a <code>Scrollable</code>.
 * They are accessed from the <code>Scrollable</code> using
 * <code>getHorizontalBar</code> and <code>getVerticalBar</code>.
 * </p><p>
 * Note: Scroll bars are not Controls.  On some platforms, scroll bars
 * that appear as part of some standard controls such as a text or list
 * have no operating system resources and are not children of the control.
 * For this reason, scroll bars are treated specially.  To create a control
 * that looks like a scroll bar but has operating system resources, use
 * <code>Slider</code>.
 * </p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>HORIZONTAL, VERTICAL</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Selection</dd>
 * </dl>
 * <p>
 * Note: Only one of the styles HORIZONTAL and VERTICAL may be specified.
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see Slider
 * @see Scrollable
 * @see Scrollable#getHorizontalBar
 * @see Scrollable#getVerticalBar
 * @see <a href="http://www.eclipse.org/swt/examples.php">DWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 * @noextend This class is not intended to be subclassed by clients.
 */
public class ScrollBar : Widget {
    NSScroller view;
    Scrollable parent;
    int minimum, maximum = 100, thumb = 10;
    int increment = 1;
    int pageIncrement = 10;
    cocoa.id target;
    objc.SEL actionSelector;

this () {
    /* Do nothing */
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the user changes the receiver's value, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * When <code>widgetSelected</code> is called, the event object detail field contains one of the following values:
 * <code>DWT.NONE</code> - for the end of a drag.
 * <code>DWT.DRAG</code>.
 * <code>DWT.HOME</code>.
 * <code>DWT.END</code>.
 * <code>DWT.ARROW_DOWN</code>.
 * <code>DWT.ARROW_UP</code>.
 * <code>DWT.PAGE_DOWN</code>.
 * <code>DWT.PAGE_UP</code>.
 * <code>widgetDefaultSelected</code> is not called.
 * </p>
 *
 * @param listener the listener which should be notified when the user changes the receiver's value
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
    TypedListener typedListener = new TypedListener(listener);
    addListener(DWT.Selection,typedListener);
    addListener(DWT.DefaultSelection,typedListener);
}

static int checkStyle (int style) {
    return checkBits (style, DWT.HORIZONTAL, DWT.VERTICAL, 0, 0, 0, 0);
}

void deregister () {
    super.deregister ();
    display.removeWidget (view);
}

bool getDrawing () {
    return parent.getDrawing ();
}

/**
 * Returns <code>true</code> if the receiver is enabled, and
 * <code>false</code> otherwise. A disabled control is typically
 * not selectable from the user interface and draws with an
 * inactive or "grayed" look.
 *
 * @return the receiver's enabled state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #isEnabled
 */
public bool getEnabled () {
    checkWidget();
    return (state & DISABLED) is 0;
}

/**
 * Returns the amount that the receiver's value will be
 * modified by when the up/down (or right/left) arrows
 * are pressed.
 *
 * @return the increment
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getIncrement () {
    checkWidget();
    return increment;
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
    checkWidget();
    return maximum;
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
    checkWidget();
    return minimum;
}

/**
 * Returns the amount that the receiver's value will be
 * modified by when the page increment/decrement areas
 * are selected.
 *
 * @return the page increment
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getPageIncrement () {
    checkWidget();
    return pageIncrement;
}

/**
 * Returns the receiver's parent, which must be a Scrollable.
 *
 * @return the receiver's parent
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Scrollable getParent () {
    checkWidget ();
    return parent;
}

/**
 * Returns the single 'selection' that is the receiver's value.
 *
 * @return the selection
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getSelection () {
    checkWidget();
    NSScroller widget = cast(NSScroller)view;
    double value = widget.doubleValue();
    return cast(int)(0.5f + ((maximum - thumb - minimum) * value + minimum));
}

/**
 * Returns a point describing the receiver's size. The
 * x coordinate of the result is the width of the receiver.
 * The y coordinate of the result is the height of the
 * receiver.
 *
 * @return the receiver's size
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Point getSize () {
    checkWidget();
    NSRect rect = (cast(NSScroller)view).frame();
    return new Point(cast(int)rect.width, cast(int)rect.height);
}

/**
 * Returns the size of the receiver's thumb relative to the
 * difference between its maximum and minimum values.
 *
 * @return the thumb value
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see ScrollBar
 */
public int getThumb () {
    checkWidget();
    return thumb;
}

/**
 * Returns <code>true</code> if the receiver is visible, and
 * <code>false</code> otherwise.
 * <p>
 * If one of the receiver's ancestors is not visible or some
 * other condition makes the receiver not visible, this method
 * may still indicate that it is considered visible even though
 * it may not actually be showing.
 * </p>
 *
 * @return the receiver's visibility state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool getVisible () {
    checkWidget();
    return (state & HIDDEN) is 0;
}

/**
 * Returns <code>true</code> if the receiver is enabled and all
 * of the receiver's ancestors are enabled, and <code>false</code>
 * otherwise. A disabled control is typically not selectable from the
 * user interface and draws with an inactive or "grayed" look.
 *
 * @return the receiver's enabled state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #getEnabled
 */
public bool isEnabled () {
    checkWidget();
    return getEnabled () && parent.isEnabled ();
}

bool isDrawing () {
    return getDrawing() && parent.isDrawing ();
}

/**
 * Returns <code>true</code> if the receiver is visible and all
 * of the receiver's ancestors are visible and <code>false</code>
 * otherwise.
 *
 * @return the receiver's visibility state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #getVisible
 */
public bool isVisible () {
    checkWidget();
    return getVisible () && parent.isVisible ();
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the user changes the receiver's value.
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
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook(DWT.Selection, listener);
    eventTable.unhook(DWT.DefaultSelection,listener);
}

void register () {
    super.register ();
    display.addWidget (view, this);
}

void releaseHandle () {
    super.releaseHandle ();
    if (view !is null) view.release();
    view = null;
}

void releaseParent () {
    super.releaseParent ();
    if (parent.horizontalBar is this) parent.horizontalBar = null;
    if (parent.verticalBar is this) parent.verticalBar = null;
}

void releaseWidget () {
    super.releaseWidget ();
    parent = null;
}

void sendSelection () {
    int value = 0;
    if (target !is null) {
        view.sendAction(actionSelector, cast(cocoa.id)target);
    } else {
        value = getSelection ();
    }
    Event event = new Event();
    NSScrollerPart hitPart = (cast(NSScroller)view).hitPart();
    switch (hitPart) {
        case OS.NSScrollerDecrementLine:
            value -= increment;
            event.detail = DWT.ARROW_UP;
            break;
        case OS.NSScrollerDecrementPage:
            value -= pageIncrement;
            event.detail = DWT.PAGE_UP;
            break;
        case OS.NSScrollerIncrementLine:
            value += increment;
            event.detail = DWT.ARROW_DOWN;
            break;
        case OS.NSScrollerIncrementPage:
            value += pageIncrement;
            event.detail = DWT.PAGE_DOWN;
            break;
        case OS.NSScrollerKnob:
            event.detail = DWT.DRAG;
            break;
        default:
    }
    if (target is null) {
        if (event.detail !is DWT.DRAG) {
            setSelection(value);
        }
    }
    sendEvent(DWT.Selection, event);
}

/**
 * Sets the amount that the receiver's value will be
 * modified by when the up/down (or right/left) arrows
 * are pressed to the argument, which must be at least
 * one.
 *
 * @param value the new increment (must be greater than zero)
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setIncrement (int value) {
    checkWidget();
    if (value < 1) return;
    increment = value;
}

void setClipRegion (Cocoa.CGFloat x, Cocoa.CGFloat y) {
    NSRect frame = view.frame();
    parent.setClipRegion(frame.x + x, frame.y + y);
}

/**
 * Enables the receiver if the argument is <code>true</code>,
 * and disables it otherwise. A disabled control is typically
 * not selectable from the user interface and draws with an
 * inactive or "grayed" look.
 *
 * @param enabled the new enabled state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setEnabled (bool enabled) {
    checkWidget();
    if (enabled) {
        if ((state & DISABLED) is 0) return;
        state &= ~DISABLED;
    } else {
        if ((state & DISABLED) !is 0) return;
        state |= DISABLED;
    }
    enableWidget (enabled);
}

void enableWidget (bool enabled) {
    if (!enabled || (state & DISABLED) is 0) {
        view.setEnabled (enabled);
    }
}

/**
 * Sets the maximum. If this value is negative or less than or
 * equal to the minimum, the value is ignored. If necessary, first
 * the thumb and then the selection are adjusted to fit within the
 * new range.
 *
 * @param value the new maximum
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setMaximum (int value) {
    checkWidget();
    if (value < 0) return;
    if (value <= minimum) return;
    if (value - minimum < thumb) {
        thumb = value - minimum;
    }
    int selection = Math.max(minimum, Math.min (getSelection (), value - thumb));
    this.maximum = value;
    updateBar(selection, minimum, value, thumb);
}

/**
 * Sets the minimum value. If this value is negative or greater
 * than or equal to the maximum, the value is ignored. If necessary,
 * first the thumb and then the selection are adjusted to fit within
 * the new range.
 *
 * @param value the new minimum
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setMinimum (int value) {
    checkWidget();
    if (value < 0) return;
    if (value >= maximum) return;
    if (maximum - value < thumb) {
        thumb = maximum - value;
    }
    int selection = Math.min(maximum - thumb, Math.max (getSelection (), value));
    this.minimum = value;
    updateBar(selection, value, maximum, thumb);
}

/**
 * Sets the amount that the receiver's value will be
 * modified by when the page increment/decrement areas
 * are selected to the argument, which must be at least
 * one.
 *
 * @param value the page increment (must be greater than zero)
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setPageIncrement (int value) {
    checkWidget();
    if (value < 1) return;
    pageIncrement = value;
}

/**
 * Sets the single <em>selection</em> that is the receiver's
 * value to the argument which must be greater than or equal
 * to zero.
 *
 * @param selection the new selection (must be zero or greater)
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSelection (int value) {
    checkWidget();
    updateBar(value, minimum, maximum, thumb);
}

/**
 * Sets the size of the receiver's thumb relative to the
 * difference between its maximum and minimum values.  This new
 * value will be ignored if it is less than one, and will be
 * clamped if it exceeds the receiver's current range.
 *
 * @param value the new thumb value, which must be at least one and not
 * larger than the size of the current range
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setThumb (int value) {
    checkWidget();
    if (value < 1) return;
    value = Math.min (value, maximum - minimum);
    updateBar(getSelection(), minimum, maximum, value);
    this.thumb = value;
}

/**
 * Sets the receiver's selection, minimum value, maximum
 * value, thumb, increment and page increment all at once.
 * <p>
 * Note: This is similar to setting the values individually
 * using the appropriate methods, but may be implemented in a
 * more efficient fashion on some platforms.
 * </p>
 *
 * @param selection the new selection value
 * @param minimum the new minimum value
 * @param maximum the new maximum value
 * @param thumb the new thumb value
 * @param increment the new increment value
 * @param pageIncrement the new pageIncrement value
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setValues (int selection, int minimum, int maximum, int thumb, int increment, int pageIncrement) {
    checkWidget();
    if (minimum < 0) return;
    if (maximum < 0) return;
    if (thumb < 1) return;
    if (increment < 1) return;
    if (pageIncrement < 1) return;
    this.thumb = thumb = Math.min (thumb, maximum - minimum);
    this.maximum = maximum;
    this.minimum = minimum;
    this.increment = increment;
    this.pageIncrement = pageIncrement;
    updateBar (selection, minimum, maximum, thumb);
}

/**
 * Marks the receiver as visible if the argument is <code>true</code>,
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
 */
public void setVisible (bool visible) {
    checkWidget();
    parent.setScrollBarVisible (this, visible);
}

void updateBar (int selection, int minimum, int maximum, int thumb) {
    NSScroller widget = cast(NSScroller) view;
    selection = Math.max (minimum, Math.min (maximum - thumb, selection));
    int range = maximum - thumb - minimum;
    float fraction = range <= 0 ? 1 : cast(float) (selection - minimum) / range;
    Carbon.CGFloat knob = range <= 0 ? 1 : cast(Carbon.CGFloat) thumb / (maximum - minimum);
    widget.setFloatValue (fraction, knob);
    widget.setEnabled (range > 0);
}

}
