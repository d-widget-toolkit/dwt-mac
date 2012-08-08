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
module dwt.widgets.ProgressBar;

import dwt.dwthelper.utils;







import dwt.widgets.Composite;
import dwt.widgets.Control;

/**
 * Instances of the receiver represent an unselectable
 * user interface object that is used to display progress,
 * typically in the form of a bar.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>SMOOTH, HORIZONTAL, VERTICAL, INDETERMINATE</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
 * </dl>
 * <p>
 * Note: Only one of the styles HORIZONTAL and VERTICAL may be specified.
 * </p><p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the DWT implementation.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#progressbar">ProgressBar snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">DWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 * @noextend This class is not intended to be subclassed by clients.
 */
public class ProgressBar : Control {

    NSBezierPath visiblePath;

    NSBezierPath visiblePath;

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
 * @see DWT#SMOOTH
 * @see DWT#HORIZONTAL
 * @see DWT#VERTICAL
 * @see DWT#INDETERMINATE
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, checkStyle (style));
}

static int checkStyle (int style) {
    style |= DWT.NO_FOCUS;
    return checkBits (style, DWT.HORIZONTAL, DWT.VERTICAL, 0, 0, 0, 0);
}

public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget();
    int size = OS.NSProgressIndicatorPreferredThickness;
    int width = 0, height = 0;
    if ((style & DWT.HORIZONTAL) !is 0) {
        height = size;
        width = height * 10;
    } else {
        width = size;
        height = width * 10;
    }
    if (wHint !is DWT.DEFAULT) width = wHint;
    if (hHint !is DWT.DEFAULT) height = hHint;
    return new Point (width, height);
}

void createHandle () {
    NSProgressIndicator widget = cast(NSProgressIndicator)(new SWTProgressIndicator()).alloc();
    widget.init();
    widget.setUsesThreadedAnimation(false);
    widget.setIndeterminate((style & DWT.INDETERMINATE) !is 0);
    view = widget;
}

NSFont defaultNSFont () {
    return display.progressIndicatorFont;
}

void _drawThemeProgressArea (int /*long*/ id, int /*long*/ sel, int /*long*/ arg0) {
    /*
    * Bug in Cocoa.  When the threaded animation is turned off by calling
    * setUsesThreadedAnimation(), _drawThemeProgressArea() attempts to
    * access a deallocated NSBitmapGraphicsContext when drawing a zero sized
    * progress bar.  The fix is to avoid calling super when the progress bar
    * is zero sized.
    */
    NSRect frame = view.frame();
    if (frame.width is 0 || frame.height is 0) return;

    /*
    * Bug in Cocoa. When the progress bar is animating it calls
    * _drawThemeProgressArea() directly without taking into account
    * obscured areas. The fix is to clip the drawing to the visible
    * region of the progress bar before calling super.
    */
    if (visiblePath is null) {
        int /*long*/ visibleRegion = getVisibleRegion();
        visiblePath = getPath(visibleRegion);
        OS.DisposeRgn(visibleRegion);
    }
    NSGraphicsContext context = NSGraphicsContext.currentContext();
    context.saveGraphicsState();
    visiblePath.setClip();
    super._drawThemeProgressArea (id, sel, arg0);
    context.restoreGraphicsState();
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
    return cast(int)(cast(NSProgressIndicator)view).maxValue();
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
    return cast(int)(cast(NSProgressIndicator)view).minValue();
}

/**
 * Returns the single 'selection' that is the receiver's position.
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
    return cast(int)(cast(NSProgressIndicator)view).doubleValue();
}

/**
 * Returns the state of the receiver. The value will be one of:
 * <ul>
 *  <li>{@link DWT#NORMAL}</li>
 *  <li>{@link DWT#ERROR}</li>
 *  <li>{@link DWT#PAUSED}</li>
 * </ul>
 *
 * @return the state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public int getState () {
    checkWidget ();
    return DWT.NORMAL;
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
    checkWidget();
    int minimum = cast(int)(cast(NSProgressIndicator)view).minValue();
    if (value <= minimum) return;
    int selection = cast(int)(cast(NSProgressIndicator)view).doubleValue();
    int newSelection = Math.min (selection, value);
    if (selection !is newSelection) {
        (cast(NSProgressIndicator)view).setDoubleValue(newSelection);
    }
}

/**
 * Sets the minimum value that the receiver will allow.  This new
 * value will be ignored if it is negative or is not less than the receiver's
 * current maximum value.  If the new minimum is applied then the receiver's
 * selection value will be adjusted if necessary to fall within its new range.
 *
 * @param value the new minimum, which must be nonnegative and less than the current maximum
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setMinimum (int value) {
    checkWidget();
    int maximum =  cast(int)(cast(NSProgressIndicator)view).maxValue();
    if (!(0 <= value && value < maximum)) return;
    int selection = cast(int)(cast(NSProgressIndicator)view).doubleValue();
    int newSelection = Math.max (selection, value);
    if (selection !is newSelection) {
        (cast(NSProgressIndicator)view).setDoubleValue(newSelection);
    }
}

/**
 * Sets the single 'selection' that is the receiver's
 * position to the argument which must be greater than or equal
 * to zero.
 *
 * @param value the new selection (must be zero or greater)
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSelection (int value) {
    checkWidget();
    (cast(NSProgressIndicator)view).setDoubleValue(value);
    /*
    * Feature in Cocoa.  The progress bar does
    * not redraw right away when a value is
    * changed.  This is not strictly incorrect
    * but unexpected.  The fix is to force all
    * outstanding redraws to be delivered.
    */
    update(false);
}

/**
 * Sets the state of the receiver. The state must be one of these values:
 * <ul>
 *  <li>{@link DWT#NORMAL}</li>
 *  <li>{@link DWT#ERROR}</li>
 *  <li>{@link DWT#PAUSED}</li>
 * </ul>
 *
 * @param state the new state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public void setState (int state) {
    checkWidget ();
    //NOT IMPLEMENTED
}

void releaseWidget () {
    super.releaseWidget();
    if (visiblePath !is null) visiblePath.release();
    visiblePath = null;
}

void resetVisibleRegion () {
    super.resetVisibleRegion ();
    if (visiblePath !is null) visiblePath.release();
    visiblePath = null;
}

void viewDidMoveToWindow(int /*long*/ id, int /*long*/ sel) {
    /*
     * Bug in Cocoa. An indeterminate progress indicator doesn't start animating until it is in
     * a visible window.  Workaround is to catch when the bar has been added to a window and start
     * the animation there.
     */
    if (view.window() !is null) {
        if ((style & DWT.INDETERMINATE) !is 0) {
            ((NSProgressIndicator)view).startAnimation(null);
        }
    }
}
}
