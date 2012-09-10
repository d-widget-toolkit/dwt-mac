/*******************************************************************************
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
module dwt.graphics.Color;

import dwt.dwthelper.utils;


import dwt.DWT;
import dwt.DWTException;
import dwt.graphics.Device;
import dwt.graphics.Resource;
import dwt.graphics.RGB;
import dwt.internal.c.Carbon;

import tango.text.convert.Format;

/**
 * Instances of this class manage the operating system resources that
 * implement DWT's RGB color model. To create a color you can either
 * specify the individual color components as integers in the range
 * 0 to 255 or provide an instance of an <code>RGB</code>.
 * <p>
 * Application code must explicitly invoke the <code>Color.dispose()</code>
 * method to release the operating system resources managed by each instance
 * when those instances are no longer required.
 * </p>
 *
 * @see RGB
 * @see Device#getSystemColor
 * @see <a href="http://www.eclipse.org/swt/snippets/#color">Color and RGB snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">DWT Example: PaintExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public final class Color : Resource {

    alias Resource.init_ init_;

    /**
     * the handle to the OS color resource
     * (Warning: This field is platform dependent)
     * <p>
     * <b>IMPORTANT:</b> This field is <em>not</em> part of the DWT
     * public API. It is marked public only so that it can be shared
     * within the packages provided by DWT. It is not available on all
     * platforms and should never be accessed from application code.
     * </p>
     */
    public CGFloat[] handle;

this(Device device) {
    super(device);
}

/**
 * Constructs a new instance of this class given a device and the
 * desired red, green and blue values expressed as ints in the range
 * 0 to 255 (where 0 is black and 255 is full brightness). On limited
 * color devices, the color instance created by this call may not have
 * the same RGB values as the ones specified by the arguments. The
 * RGB values on the returned instance will be the color values of
 * the operating system color.
 * <p>
 * You must dispose the color when it is no longer required.
 * </p>
 *
 * @param device the device on which to allocate the color
 * @param red the amount of red in the color
 * @param green the amount of green in the color
 * @param blue the amount of blue in the color
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if device is null and there is no current device</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the red, green or blue argument is not between 0 and 255</li>
 * </ul>
 *
 * @see #dispose
 */
public this(Device device, int red, int green, int blue) {
    super(device);
    init_(red, green, blue);
    init_();
}

/**
 * Constructs a new instance of this class given a device and an
 * <code>RGB</code> describing the desired red, green and blue values.
 * On limited color devices, the color instance created by this call
 * may not have the same RGB values as the ones specified by the
 * argument. The RGB values on the returned instance will be the color
 * values of the operating system color.
 * <p>
 * You must dispose the color when it is no longer required.
 * </p>
 *
 * @param device the device on which to allocate the color
 * @param rgb the RGB values of the desired color
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if device is null and there is no current device</li>
 *    <li>ERROR_NULL_ARGUMENT - if the rgb argument is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the red, green or blue components of the argument are not between 0 and 255</li>
 * </ul>
 *
 * @see #dispose
 */
public this(Device device, RGB rgb) {
    super(device);
    if (rgb is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    init_(rgb.red, rgb.green, rgb.blue);
    init_();
}

void destroy() {
    handle = null;
}

/**
 * Compares the argument to the receiver, and returns true
 * if they represent the <em>same</em> object using a class
 * specific comparison.
 *
 * @param object the object to compare with this object
 * @return <code>true</code> if the object is the same as this object and <code>false</code> otherwise
 *
 * @see #hashCode
 */
public bool equals(Object object) {
    if (object is this) return true;
    Color o = cast(Color)object;
    if (!o) return false;
    Color color = o;
    CGFloat[] rgbColor = color.handle;
    if (handle is rgbColor) return true;
    return device is color.device &&
        cast(int)(handle[0] * 255) is cast(int)(rgbColor[0] * 255) &&
        cast(int)(handle[1] * 255) is cast(int)(rgbColor[1] * 255) &&
        cast(int)(handle[2] * 255) is cast(int)(rgbColor[2] * 255);
}

alias equals opEquals;

/**
 * Returns the amount of blue in the color, from 0 to 255.
 *
 * @return the blue component of the color
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int getBlue() {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    return cast(int)(handle[2] * 255);
}

/**
 * Returns the amount of green in the color, from 0 to 255.
 *
 * @return the green component of the color
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int getGreen() {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    return cast(int)(handle[1] * 255);
}

/**
 * Returns the amount of red in the color, from 0 to 255.
 *
 * @return the red component of the color
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int getRed() {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    return cast(int)(handle[0] * 255);
}

/**
 * Returns an integer hash code for the receiver. Any two
 * objects that return <code>true</code> when passed to
 * <code>equals</code> must return the same value for this
 * method.
 *
 * @return the receiver's hash
 *
 * @see #equals
 */
public hash_t toHash() {
    if (isDisposed()) return 0;
    return cast(int)(handle[0] * 255) ^ cast(int)(handle[1] * 255) ^ cast(int)(handle[2] * 255);
}

alias toHash hashCode;

/**
 * Returns an <code>RGB</code> representing the receiver.
 *
 * @return the RGB for the color
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public RGB getRGB () {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    return new RGB(getRed(), getGreen(), getBlue());
}

/**
 * Invokes platform specific functionality to allocate a new color.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>Color</code>. It is marked public only so that it
 * can be shared within the packages provided by DWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param device the device on which to allocate the color
 * @param handle the handle for the color
 *
 * @private
 */
public static Color cocoa_new(Device device, CGFloat[] rgbColor) {
    Color color = new Color(device);
    color.handle = rgbColor;
    return color;
}

void init_(int red, int green, int blue) {
    if ((red > 255) || (red < 0) ||
        (green > 255) || (green < 0) ||
        (blue > 255) || (blue < 0)) {
            DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    }
    CGFloat[] rgbColor = new CGFloat[4];
    rgbColor[0] = red / 255f;
    rgbColor[1] = green / 255f;
    rgbColor[2] = blue / 255f;
    rgbColor[3] = 1;
    handle = rgbColor;
}

/**
 * Returns <code>true</code> if the color has been disposed,
 * and <code>false</code> otherwise.
 * <p>
 * This method gets the dispose state for the color.
 * When a color has been disposed, it is an error to
 * invoke any other method using the color.
 *
 * @return <code>true</code> when the color is disposed and <code>false</code> otherwise
 */
public bool isDisposed() {
    return handle is null;
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the receiver
 */
public String toString () {
    if (isDisposed()) return "Color {*DISPOSED*}";
    return Format("Color {{}{}{}{}{}{}" , getRed() , ", " , getGreen() , ", " , getBlue() , "}");
}

}
