﻿/*******************************************************************************
 * Copyright (c) 2000, 2008 IBM Corporation and others.
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
module dwt.graphics.Pattern;

import dwt.dwthelper.utils;

import dwt.DWT;
import dwt.DWTError;
import dwt.DWTException;
import dwt.graphics.Color;
import dwt.graphics.Device;
import dwt.graphics.GC;
import dwt.graphics.Image;
import dwt.graphics.Resource;
import dwt.internal.c.Carbon;
import dwt.internal.cocoa.NSAutoreleasePool;
import dwt.internal.cocoa.NSColor;
import dwt.internal.cocoa.NSGradient;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSThread;

import tango.text.convert.Format;

/**
 * Instances of this class represent patterns to use while drawing. Patterns
 * can be specified either as bitmaps or gradients.
 * <p>
 * Application code must explicitly invoke the <code>Pattern.dispose()</code>
 * method to release the operating system resources managed by each instance
 * when those instances are no longer required.
 * </p>
 * <p>
 * This class requires the operating system's advanced graphics subsystem
 * which may not be available on some platforms.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#path">Path, Pattern snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">DWT Example: GraphicsExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.1
 */
public class Pattern : Resource {
    alias Resource.init_ init_;

    NSColor color;
    NSGradient gradient;
    NSPoint pt1, pt2;
    Image image;
    CGFloat[] color1, color2;
    int alpha1, alpha2;

/**
 * Constructs a new Pattern given an image. Drawing with the resulting
 * pattern will cause the image to be tiled over the resulting area.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 *
 * @param device the device on which to allocate the pattern
 * @param image the image that the pattern will draw
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the device is null and there is no current device, or the image is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the image has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 * @exception DWTError <ul>
 *    <li>ERROR_NO_HANDLES if a handle for the pattern could not be obtained</li>
 * </ul>
 *
 * @see #dispose()
 */
public this(Device device, Image image) {
    super(device);
    if (image is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (image.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        this.image = image;
        color = NSColor.colorWithPatternImage(image.handle);
        color.retain();
        init_();
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Constructs a new Pattern that represents a linear, two color
 * gradient. Drawing with the pattern will cause the resulting area to be
 * tiled with the gradient specified by the arguments.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 *
 * @param device the device on which to allocate the pattern
 * @param x1 the x coordinate of the starting corner of the gradient
 * @param y1 the y coordinate of the starting corner of the gradient
 * @param x2 the x coordinate of the ending corner of the gradient
 * @param y2 the y coordinate of the ending corner of the gradient
 * @param color1 the starting color of the gradient
 * @param color2 the ending color of the gradient
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the device is null and there is no current device,
 *                              or if either color1 or color2 is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if either color1 or color2 has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 * @exception DWTError <ul>
 *    <li>ERROR_NO_HANDLES if a handle for the pattern could not be obtained</li>
 * </ul>
 *
 * @see #dispose()
 */
public this(Device device, float x1, float y1, float x2, float y2, Color color1, Color color2) {
    this(device, x1, y1, x2, y2, color1, 0xFF, color2, 0xFF);
}
/**
 * Constructs a new Pattern that represents a linear, two color
 * gradient. Drawing with the pattern will cause the resulting area to be
 * tiled with the gradient specified by the arguments.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 *
 * @param device the device on which to allocate the pattern
 * @param x1 the x coordinate of the starting corner of the gradient
 * @param y1 the y coordinate of the starting corner of the gradient
 * @param x2 the x coordinate of the ending corner of the gradient
 * @param y2 the y coordinate of the ending corner of the gradient
 * @param color1 the starting color of the gradient
 * @param alpha1 the starting alpha value of the gradient
 * @param color2 the ending color of the gradient
 * @param alpha2 the ending alpha value of the gradient
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the device is null and there is no current device,
 *                              or if either color1 or color2 is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if either color1 or color2 has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 * @exception DWTError <ul>
 *    <li>ERROR_NO_HANDLES if a handle for the pattern could not be obtained</li>
 * </ul>
 *
 * @see #dispose()
 *
 * @since 3.2
 */
public this(Device device, float x1, float y1, float x2, float y2, Color color1, int alpha1, Color color2, int alpha2) {
    super(device);
    if (color1 is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (color1.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    if (color2 is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (color2.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        pt1 = NSPoint();
        pt2 = NSPoint();
        pt1.x = x1;
        pt1.y = y1;
        pt2.x = x2;
        pt2.y = y2;
        this.color1 = color1.handle;
        this.color2 = color2.handle;
        this.alpha1 = alpha1;
        this.alpha2 = alpha2;
        NSColor start = NSColor.colorWithDeviceRed(color1.handle[0], color1.handle[1], color1.handle[2], (alpha1 / 255f));
        NSColor end = NSColor.colorWithDeviceRed(color2.handle[0], color2.handle[1], color2.handle[2], (alpha2 / 255f));
        gradient = (cast(NSGradient)(new NSGradient()).alloc()).initWithStartingColor(start, end);
        init_();
    } finally {
        if (pool !is null) pool.release();
    }
}

void destroy() {
    if (color !is null) color.release();
    color = null;
    if (gradient !is null) gradient.release();
    gradient = null;
    image = null;
    color1 = color2 = null;
}

/**
 * Returns <code>true</code> if the Pattern has been disposed,
 * and <code>false</code> otherwise.
 * <p>
 * This method gets the dispose state for the Pattern.
 * When a Pattern has been disposed, it is an error to
 * invoke any other method using the Pattern.
 *
 * @return <code>true</code> when the Pattern is disposed, and <code>false</code> otherwise
 */
public bool isDisposed() {
    return device is null;
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the receiver
 */
public String toString() {
    if (isDisposed()) return "Pattern {*DISPOSED*}";
    return Format("{}{}{}", "Pattern {" , (color !is null ? color.id : gradient.id) , "}");
}

}
