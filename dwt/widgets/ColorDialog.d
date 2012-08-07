﻿/*******************************************************************************
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
module dwt.widgets.ColorDialog;



import dwt.*;
import dwt.graphics.*;
import dwt.internal.cocoa.*;

import dwt.dwthelper.utils;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;
import dwt.widgets.Dialog;
import dwt.widgets.Display;
import dwt.widgets.Shell;
/**
 * Instances of this class allow the user to select a color
 * from a predefined set of available colors.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>(none)</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
 * </dl>
 * <p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the DWT implementation.
 * </p>
 * 
 * @see <a href="http://www.eclipse.org/swt/examples.php">DWT Example: ControlExample, Dialog tab</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 * @noextend This class is not intended to be subclassed by clients.
 */
public class ColorDialog : Dialog {
    RGB rgb;
    bool selected;

/**
 * Constructs a new instance of this class given only its parent.
 *
 * @param parent a composite control which will be the parent of the new instance
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see DWT
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this(Shell parent) {
    this(parent, DWT.APPLICATION_MODAL);
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
 * @see DWT
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this(Shell parent, int style) {
    super (parent, checkStyle (parent, style));
    checkSubclass ();
}
    
void changeColor(objc.id id, objc.SEL sel, objc.id sender) {
    selected = true;
}

/**
 * Returns the currently selected color in the receiver.
 *
 * @return the RGB value for the selected color, may be null
 *
 * @see PaletteData#getRGBs
 */
public RGB getRGB() {
    return rgb;
}

/**
 * Makes the receiver visible and brings it to the front
 * of the display.
 *
 * @return the selected color, or null if the dialog was
 *         cancelled, no color was selected, or an error
 *         occurred
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public RGB open() { 
    NSColorPanel panel = NSColorPanel.sharedColorPanel();
    if (rgb !is null) {
        NSColor color = NSColor.colorWithDeviceRed(rgb.red / 255f, rgb.green / 255f, rgb.blue / 255f, 1);
        panel.setColor(color);
    }
    SWTPanelDelegate delegate_ = cast(SWTPanelDelegate)(new SWTPanelDelegate()).alloc().init();
    void* jniRef = OS.NewGlobalRef(this);
    if (jniRef is null) DWT.error(DWT.ERROR_NO_HANDLES);
    OS.object_setInstanceVariable(delegate_.id, Display.SWT_OBJECT, jniRef);
    panel.setDelegate(delegate_);
    rgb = null;
    selected = false;
    panel.orderFront(null);
    NSApplication.sharedApplication().runModalForWindow(panel);
    panel.setDelegate(null);
    delegate_.release();
    if (selected) {
    if (selected) {
        NSColor color = panel.color();
        if (color !is null) {
            color = color.colorUsingColorSpaceName(OS.NSCalibratedRGBColorSpace);
            rgb = new RGB(cast(int)(color.redComponent() * 255), cast(int)(color.greenComponent() * 255), cast(int)(color.blueComponent() * 255));
        }
    }
    return rgb;
}

/**
 * Sets the receiver's selected color to be the argument.
 *
 * @param rgb the new RGB value for the selected color, may be
 *        null to let the platform select a default when
 *        open() is called
 * @see PaletteData#getRGBs
 */
public void setRGB(RGB rgb) {
    this.rgb = rgb;
}
    
void windowWillClose(objc.id id, objc.SEL sel, objc.id sender) {
    NSApplication.sharedApplication().stop(null);
}
}
