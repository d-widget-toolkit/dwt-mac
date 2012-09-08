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
module dwt.custom.SashForm;

import dwt.dwthelper.utils;
import dwt.dwthelper.System;


import dwt.DWT;
import dwt.DWTException;
import dwt.custom.SashFormLayout;
import dwt.custom.SashFormData;
import dwt.graphics.Color;
import dwt.graphics.Rectangle;
import dwt.widgets.Composite;
import dwt.widgets.Control;
import dwt.widgets.Event;
import dwt.widgets.Layout;
import dwt.widgets.Listener;
import dwt.widgets.Sash;

/**
 * The SashForm is a composite control that lays out its children in a
 * row or column arrangement (as specified by the orientation) and places
 * a Sash between each child. One child may be maximized to occupy the
 * entire size of the SashForm.  The relative sizes of the children may
 * be specified using weights.
 * <p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>HORIZONTAL, VERTICAL, SMOOTH</dd>
 * </dl>
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#sashform">SashForm snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">DWT Example: CustomControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class SashForm : Composite {

    /**
    * The width of all sashes in the form.
    */
    public int SASH_WIDTH = 3;

    int sashStyle;
    Sash[] sashes;
    // Remember background and foreground
    // colors to determine whether to set
    // sashes to the default color (null) or
    // a specific color
    Color background = null;
    Color foreground = null;
    Control[] controls;
    Control maxControl = null;
    Listener sashListener;
    static const int DRAG_MINIMUM = 20;

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
 * @see DWT#HORIZONTAL
 * @see DWT#VERTICAL
 * @see #getStyle()
 */
public this(Composite parent, int style) {
    super(parent, checkStyle(style));
    super.setLayout(new SashFormLayout());
    sashStyle = ((style & DWT.VERTICAL) !is 0) ? DWT.HORIZONTAL : DWT.VERTICAL;
    if ((style & DWT.BORDER) !is 0) sashStyle |= DWT.BORDER;
    if ((style & DWT.SMOOTH) !is 0) sashStyle |= DWT.SMOOTH;
    sashListener = new class() Listener {
        public void handleEvent(Event e) {
            onDragSash(e);
        }
    };
}
static int checkStyle (int style) {
    int mask = DWT.BORDER | DWT.LEFT_TO_RIGHT | DWT.RIGHT_TO_LEFT;
    return style & mask;
}
Sash createSash() {
    Sash sash = new Sash(this, sashStyle);
    sash.setBackground(background);
    sash.setForeground(foreground);
    sash.setToolTipText(getToolTipText());
    sash.addListener(DWT.Selection, sashListener);
    return sash;
}
/**
 * Returns DWT.HORIZONTAL if the controls in the SashForm are laid out side by side
 * or DWT.VERTICAL   if the controls in the SashForm are laid out top to bottom.
 *
 * @return DWT.HORIZONTAL or DWT.VERTICAL
 */
public int getOrientation() {
    //checkWidget();
    return (sashStyle & DWT.VERTICAL) !is 0 ? DWT.HORIZONTAL : DWT.VERTICAL;
}
/**
 * Returns the width of the sashes when the controls in the SashForm are
 * laid out.
 *
 * @return the width of the sashes
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public int getSashWidth() {
    checkWidget();
    return SASH_WIDTH;
}
public override int getStyle() {
    int style = super.getStyle();
    style |= getOrientation() is DWT.VERTICAL ? DWT.VERTICAL : DWT.HORIZONTAL;
    if ((sashStyle & DWT.SMOOTH) !is 0) style |= DWT.SMOOTH;
    return style;
}
/**
 * Answer the control that currently is maximized in the SashForm.
 * This value may be null.
 *
 * @return the control that currently is maximized or null
 */
public Control getMaximizedControl(){
    //checkWidget();
    return this.maxControl;
}
/**
 * Answer the relative weight of each child in the SashForm.  The weight represents the
 * percent of the total width (if SashForm has Horizontal orientation) or
 * total height (if SashForm has Vertical orientation) each control occupies.
 * The weights are returned in order of the creation of the widgets (weight[0]
 * corresponds to the weight of the first child created).
 *
 * @return the relative weight of each child
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */

public int[] getWeights() {
    checkWidget();
    Control[] cArray = getControls(false);
    int[] ratios = new int[cArray.length];
    for (int i = 0; i < cArray.length; i++) {
        Object data = cArray[i].getLayoutData();
        if ( auto sfd = cast(SashFormData)data ) {
            ratios[i] = cast(int)(sfd.weight * 1000 >> 16);
        } else {
            ratios[i] = 200;
        }
    }
    return ratios;
}
Control[] getControls(bool onlyVisible) {
    Control[] children = getChildren();
    Control[] result = new Control[0];
    for (int i = 0; i < children.length; i++) {
        if ( null !is cast(Sash)children[i]) continue;
        if (onlyVisible && !children[i].getVisible()) continue;

        Control[] newResult = new Control[result.length + 1];
        System.arraycopy(result, 0, newResult, 0, result.length);
        newResult[result.length] = children[i];
        result = newResult;
    }
    return result;
}
void onDragSash(Event event) {
    Sash sash = cast(Sash)event.widget;
    int sashIndex = -1;
    for (int i= 0; i < sashes.length; i++) {
        if (sashes[i] is sash) {
            sashIndex = i;
            break;
        }
    }
    if (sashIndex is -1) return;

    Control c1 = controls[sashIndex];
    Control c2 = controls[sashIndex + 1];
    Rectangle b1 = c1.getBounds();
    Rectangle b2 = c2.getBounds();

    Rectangle sashBounds = sash.getBounds();
    Rectangle area = getClientArea();
    bool correction = false;
    if (getOrientation() is DWT.HORIZONTAL) {
        correction = b1.width < DRAG_MINIMUM || b2.width < DRAG_MINIMUM;
        int totalWidth = b2.x + b2.width - b1.x;
        int shift = event.x - sashBounds.x;
        b1.width += shift;
        b2.x += shift;
        b2.width -= shift;
        if (b1.width < DRAG_MINIMUM) {
            b1.width = DRAG_MINIMUM;
            b2.x = b1.x + b1.width + sashBounds.width;
            b2.width = totalWidth - b2.x;
            event.x = b1.x + b1.width;
            event.doit = false;
        }
        if (b2.width < DRAG_MINIMUM) {
            b1.width = totalWidth - DRAG_MINIMUM - sashBounds.width;
            b2.x = b1.x + b1.width + sashBounds.width;
            b2.width = DRAG_MINIMUM;
            event.x = b1.x + b1.width;
            event.doit = false;
        }
        Object data1 = c1.getLayoutData();
        if (data1 is null || !( null !is cast(SashFormData)data1 )) {
            data1 = new SashFormData();
            c1.setLayoutData(data1);
        }
        Object data2 = c2.getLayoutData();
        if (data2 is null || !( null !is cast(SashFormData)data2 )) {
            data2 = new SashFormData();
            c2.setLayoutData(data2);
        }
        (cast(SashFormData)data1).weight = ((cast(long)b1.width << 16) + area.width - 1) / area.width;
        (cast(SashFormData)data2).weight = ((cast(long)b2.width << 16) + area.width - 1) / area.width;
    } else {
        correction = b1.height < DRAG_MINIMUM || b2.height < DRAG_MINIMUM;
        int totalHeight = b2.y + b2.height - b1.y;
        int shift = event.y - sashBounds.y;
        b1.height += shift;
        b2.y += shift;
        b2.height -= shift;
        if (b1.height < DRAG_MINIMUM) {
            b1.height = DRAG_MINIMUM;
            b2.y = b1.y + b1.height + sashBounds.height;
            b2.height = totalHeight - b2.y;
            event.y = b1.y + b1.height;
            event.doit = false;
        }
        if (b2.height < DRAG_MINIMUM) {
            b1.height = totalHeight - DRAG_MINIMUM - sashBounds.height;
            b2.y = b1.y + b1.height + sashBounds.height;
            b2.height = DRAG_MINIMUM;
            event.y = b1.y + b1.height;
            event.doit = false;
        }
        Object data1 = c1.getLayoutData();
        if (data1 is null || !( null !is cast(SashFormData)data1 )) {
            data1 = new SashFormData();
            c1.setLayoutData(data1);
        }
        Object data2 = c2.getLayoutData();
        if (data2 is null || !(null !is cast(SashFormData)data2 )) {
            data2 = new SashFormData();
            c2.setLayoutData(data2);
        }
        (cast(SashFormData)data1).weight = ((cast(long)b1.height << 16) + area.height - 1) / area.height;
        (cast(SashFormData)data2).weight = ((cast(long)b2.height << 16) + area.height - 1) / area.height;
    }
    if (correction || (event.doit && event.detail !is DWT.DRAG)) {
        c1.setBounds(b1);
        sash.setBounds(event.x, event.y, event.width, event.height);
        c2.setBounds(b2);
    }
}
/**
 * If orientation is DWT.HORIZONTAL, lay the controls in the SashForm
 * out side by side.  If orientation is DWT.VERTICAL, lay the
 * controls in the SashForm out top to bottom.
 *
 * @param orientation DWT.HORIZONTAL or DWT.VERTICAL
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the value of orientation is not DWT.HORIZONTAL or DWT.VERTICAL
 * </ul>
 */
public void setOrientation(int orientation) {
    checkWidget();
    if (getOrientation() is orientation) return;
    if (orientation !is DWT.HORIZONTAL && orientation !is DWT.VERTICAL) {
        DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    }
    sashStyle &= ~(DWT.HORIZONTAL | DWT.VERTICAL);
    sashStyle |= orientation is DWT.VERTICAL ? DWT.HORIZONTAL : DWT.VERTICAL;
    for (int i = 0; i < sashes.length; i++) {
        sashes[i].dispose();
        sashes[i] = createSash();
    }
    layout(false);
}
public override void setBackground (Color color) {
    super.setBackground(color);
    background = color;
    for (int i = 0; i < sashes.length; i++) {
        sashes[i].setBackground(background);
    }
}
public override void setForeground (Color color) {
    super.setForeground(color);
    foreground = color;
    for (int i = 0; i < sashes.length; i++) {
        sashes[i].setForeground(foreground);
    }
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
    checkWidget();
    return;
}
/**
 * Specify the control that should take up the entire client area of the SashForm.
 * If one control has been maximized, and this method is called with a different control,
 * the previous control will be minimized and the new control will be maximized.
 * If the value of control is null, the SashForm will minimize all controls and return to
 * the default layout where all controls are laid out separated by sashes.
 *
 * @param control the control to be maximized or null
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setMaximizedControl(Control control){
    checkWidget();
    if (control is null) {
        if (maxControl !is null) {
            this.maxControl = null;
            layout(false);
            for (int i= 0; i < sashes.length; i++){
                sashes[i].setVisible(true);
            }
        }
        return;
    }

    for (int i= 0; i < sashes.length; i++){
        sashes[i].setVisible(false);
    }
    maxControl = control;
    layout(false);
}

/**
 * Specify the width of the sashes when the controls in the SashForm are
 * laid out.
 *
 * @param width the width of the sashes
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public void setSashWidth(int width) {
    checkWidget();
    if (SASH_WIDTH is width) return;
    SASH_WIDTH = width;
    layout(false);
}
public void setToolTipText(String string) {
    super.setToolTipText(string);
    for (int i = 0; i < sashes.length; i++) {
        sashes[i].setToolTipText(string);
    }
}
/**
 * Specify the relative weight of each child in the SashForm.  This will determine
 * what percent of the total width (if SashForm has Horizontal orientation) or
 * total height (if SashForm has Vertical orientation) each control will occupy.
 * The weights must be positive values and there must be an entry for each
 * non-sash child of the SashForm.
 *
 * @param weights the relative weight of each child
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the weights value is null or of incorrect length (must match the number of children)</li>
 * </ul>
 */
public void setWeights(int[] weights) {
    checkWidget();
    Control[] cArray = getControls(false);
    if (weights is null || weights.length !is cArray.length) {
        DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    }

    int total = 0;
    for (int i = 0; i < weights.length; i++) {
        if (weights[i] < 0) {
            DWT.error(DWT.ERROR_INVALID_ARGUMENT);
        }
        total += weights[i];
    }
    if (total is 0) {
        DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    }
    for (int i = 0; i < cArray.length; i++) {
        Object data = cArray[i].getLayoutData();
        if (data is null || !( null !is cast(SashFormData)data )) {
            data = new SashFormData();
            cArray[i].setLayoutData(data);
        }
        (cast(SashFormData)data).weight = ((cast(long)weights[i] << 16) + total - 1) / total;
    }

    layout(false);
}
}
