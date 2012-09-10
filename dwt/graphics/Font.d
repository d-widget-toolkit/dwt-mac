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
module dwt.graphics.Font;

import dwt.dwthelper.utils;


import dwt.DWT;
import dwt.DWTError;
import dwt.DWTException;
import dwt.graphics.Device;
import dwt.graphics.FontData;
import dwt.graphics.Point;
import dwt.graphics.Resource;
import Carbon = dwt.internal.c.Carbon;
import dwt.internal.objc.cocoa.Cocoa;
import dwt.internal.cocoa.NSAutoreleasePool;
import dwt.internal.cocoa.NSFont;
import dwt.internal.cocoa.NSFontManager;
import dwt.internal.cocoa.NSMutableAttributedString;
import dwt.internal.cocoa.NSMutableDictionary;
import dwt.internal.cocoa.NSNumber;
import dwt.internal.cocoa.NSRange;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSThread;
import dwt.internal.cocoa.OS;

import tango.stdc.stringz;
import tango.text.convert.Format;
static import tango.text.convert.Utf;

/**
 * Instances of this class manage operating system resources that
 * define how text looks when it is displayed. Fonts may be constructed
 * by providing a device and either name, size and style information
 * or a <code>FontData</code> object which encapsulates this data.
 * <p>
 * Application code must explicitly invoke the <code>Font.dispose()</code>
 * method to release the operating system resources managed by each instance
 * when those instances are no longer required.
 * </p>
 *
 * @see FontData
 * @see <a href="http://www.eclipse.org/swt/snippets/#font">Font snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">DWT Examples: GraphicsExample, PaintExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public final class Font : Resource {

    alias Resource.init_ init_;

    /**
     * the handle to the OS font resource
     * (Warning: This field is platform dependent)
     * <p>
     * <b>IMPORTANT:</b> This field is <em>not</em> part of the DWT
     * public API. It is marked public only so that it can be shared
     * within the packages provided by DWT. It is not available on all
     * platforms and should never be accessed from application code.
     * </p>
     */
    public NSFont handle;

    /**
     * the traits not supported to the OS font resource
     * (Warning: This field is platform dependent)
     * <p>
     * <b>IMPORTANT:</b> This field is <em>not</em> part of the DWT
     * public API. It is marked public only so that it can be shared
     * within the packages provided by DWT. It is not available on all
     * platforms and should never be accessed from application code.
     * </p>
     */
    public int extraTraits;

    static final double SYNTHETIC_BOLD = -2.5;
    static final double SYNTHETIC_ITALIC = 0.2;

this(Device device) {
    super(device);
}

/**
 * Constructs a new font given a device and font data
 * which describes the desired font's appearance.
 * <p>
 * You must dispose the font when it is no longer required.
 * </p>
 *
 * @param device the device to create the font on
 * @param fd the FontData that describes the desired font (must not be null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if device is null and there is no current device</li>
 *    <li>ERROR_NULL_ARGUMENT - if the fd argument is null</li>
 * </ul>
 * @exception DWTError <ul>
 *    <li>ERROR_NO_HANDLES - if a font could not be created from the given font data</li>
 * </ul>
 */
public this(Device device, FontData fd) {
    super(device);
    if (fd is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        init_(fd.getName(), fd.getHeightF(), fd.getStyle(), fd.nsName);
        init_();
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Constructs a new font given a device and an array
 * of font data which describes the desired font's
 * appearance.
 * <p>
 * You must dispose the font when it is no longer required.
 * </p>
 *
 * @param device the device to create the font on
 * @param fds the array of FontData that describes the desired font (must not be null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if device is null and there is no current device</li>
 *    <li>ERROR_NULL_ARGUMENT - if the fds argument is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the length of fds is zero</li>
 *    <li>ERROR_NULL_ARGUMENT - if any fd in the array is null</li>
 * </ul>
 * @exception DWTError <ul>
 *    <li>ERROR_NO_HANDLES - if a font could not be created from the given font data</li>
 * </ul>
 *
 * @since 2.1
 */
public this(Device device, FontData[] fds) {
    super(device);
    if (fds is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (fds.length is 0) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    for (int i=0; i<fds.length; i++) {
        if (fds[i] is null) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    }
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        FontData fd = fds[0];
        init_(fd.getName(), fd.getHeightF(), fd.getStyle(), fd.nsName);
        init_();
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Constructs a new font given a device, a font name,
 * the height of the desired font in points, and a font
 * style.
 * <p>
 * You must dispose the font when it is no longer required.
 * </p>
 *
 * @param device the device to create the font on
 * @param name the name of the font (must not be null)
 * @param height the font height in points
 * @param style a bit or combination of NORMAL, BOLD, ITALIC
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if device is null and there is no current device</li>
 *    <li>ERROR_NULL_ARGUMENT - if the name argument is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the height is negative</li>
 * </ul>
 * @exception DWTError <ul>
 *    <li>ERROR_NO_HANDLES - if a font could not be created from the given arguments</li>
 * </ul>
 */
public this(Device device, String name, int height, int style) {
    super(device);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        init_(name, height, style, null);
        init_();
    } finally {
        if (pool !is null) pool.release();
    }
}

/*public*/ this(Device device, String name, float height, int style) {
    super(device);
    init_(name, height, style, null);
    init_();
}

void addTraits(NSMutableAttributedString attrStr, NSRange range) {
    if ((extraTraits & OS.NSBoldFontMask) !is 0) {
        attrStr.addAttribute(OS.NSStrokeWidthAttributeName, NSNumber.numberWithDouble(SYNTHETIC_BOLD), range);
    }
    if ((extraTraits & OS.NSItalicFontMask) !is 0) {
        attrStr.addAttribute(OS.NSObliquenessAttributeName, NSNumber.numberWithDouble(SYNTHETIC_ITALIC), range);
    }
}

void addTraits(NSMutableDictionary dict) {
    if ((extraTraits & OS.NSBoldFontMask) !is 0) {
        dict.setObject(NSNumber.numberWithDouble(SYNTHETIC_BOLD), OS.NSStrokeWidthAttributeName);
    }
    if ((extraTraits & OS.NSItalicFontMask) !is 0) {
        dict.setObject(NSNumber.numberWithDouble(SYNTHETIC_ITALIC), OS.NSObliquenessAttributeName);
    }
}

void destroy() {
    handle.release();
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
public int opEquals(Object object) {
    if (object is this) return true;
    if (!( null !is cast(Font)object )) return false;
    Font font = cast(Font)object;
    return handle is font.handle;
}

alias opEquals equals;

/**
 * Returns an array of <code>FontData</code>s representing the receiver.
 * On Windows, only one FontData will be returned per font. On X however,
 * a <code>Font</code> object <em>may</em> be composed of multiple X
 * fonts. To support this case, we return an array of font data objects.
 *
 * @return an array of font data objects describing the receiver
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public FontData[] getFontData() {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        NSString family = handle.familyName();
        String name = family.getString();
        NSString str = handle.fontName();
        String nsName = str.getString();
        NSFontManager manager = NSFontManager.sharedFontManager();
        NSFontTraitMask traits = manager.traitsOfFont(handle);
        int style = DWT.NORMAL;
        if ((traits & OS.NSItalicFontMask) !is 0) style |= DWT.ITALIC;
        if ((traits & OS.NSBoldFontMask) !is 0) style |= DWT.BOLD;
        if ((extraTraits & OS.NSItalicFontMask) !is 0) style |= DWT.ITALIC;
        if ((extraTraits & OS.NSBoldFontMask) !is 0) style |= DWT.BOLD;
        Point dpi = device.dpi, screenDPI = device.getScreenDPI();
        FontData data = new FontData(name, cast(Cocoa.CGFloat)handle.pointSize() * screenDPI.y / dpi.y, style);
        data.nsName = nsName;
        return [data];
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Invokes platform specific functionality to allocate a new font.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>Font</code>. It is marked public only so that it
 * can be shared within the packages provided by DWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param device the device on which to allocate the color
 * @param handle the handle for the font
 * @param style the style for the font
 * @param size the size for the font
 *
 * @private
 */
public static Font cocoa_new(Device device, NSFont handle) {
    Font font = new Font(device);
    font.handle = handle;
    return font;
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
    return handle !is null ? cast(hash_t) handle.id : 0;
}

alias toHash hashCode;

void init_(String name, float height, int style, String nsName) {
    // DWT extension: allow null for zero length string
    //if (name is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (height < 0) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    Point dpi = device.dpi, screenDPI = device.getScreenDPI();
    float size = height * dpi.y / screenDPI.y;
    if (nsName !is null) {
        handle = NSFont.fontWithName(NSString.stringWith(nsName), size);
    } else {
        NSString family = NSString.stringWith(name);
        NSFont nsFont = NSFont.fontWithName(family, size);
        if (nsFont is null) nsFont = NSFont.systemFontOfSize(size);
        NSFontManager manager = NSFontManager.sharedFontManager();
        if (nsFont !is null) {
            if ((style & (DWT.BOLD | DWT.ITALIC)) is 0) {
                handle = nsFont;
            } else {
                int traits = 0;
                if ((style & DWT.ITALIC) !is 0) traits |= OS.NSItalicFontMask;
                if ((style & DWT.BOLD) !is 0) traits |= OS.NSBoldFontMask;
                handle = manager.convertFont(nsFont, cast(NSFontTraitMask)traits);
                if ((style & DWT.ITALIC) !is 0 && (handle is null || (manager.traitsOfFont(handle) & OS.NSItalicFontMask) is 0)) {
                    traits &= ~OS.NSItalicFontMask;
                    handle = null;
                    if ((style & DWT.BOLD) !is 0) {
                        handle = manager.convertFont(nsFont, cast(NSFontTraitMask)traits);
                    }
                }
                if ((style & DWT.BOLD) !is 0 && handle is null) {
                    traits &= ~OS.NSBoldFontMask;
                    if ((style & DWT.ITALIC) !is 0) {
                        traits |= OS.NSItalicFontMask;
                        handle = manager.convertFont(nsFont, cast(NSFontTraitMask)traits);
                    }
                }
                if (handle is null) handle = nsFont;
            }
        }
        if (handle is null) {
            handle = NSFont.systemFontOfSize(size);
        }
        if ((style & DWT.ITALIC) !is 0 && (manager.traitsOfFont(handle) & OS.NSItalicFontMask) is 0) {
            extraTraits |= OS.NSItalicFontMask;
        }
        if ((style & DWT.BOLD) !is 0 && (manager.traitsOfFont(handle) & OS.NSBoldFontMask) is 0) {
            extraTraits |= OS.NSBoldFontMask;
        }
    }
    if (handle is null) {
        handle = device.systemFont.handle;
    }
    handle.retain();
}

/**
 * Returns <code>true</code> if the font has been disposed,
 * and <code>false</code> otherwise.
 * <p>
 * This method gets the dispose state for the font.
 * When a font has been disposed, it is an error to
 * invoke any other method using the font.
 *
 * @return <code>true</code> when the font is disposed and <code>false</code> otherwise
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
    if (isDisposed()) return "Font {*DISPOSED*}";
    return Format("{}{}{}", "Font {", handle, "}");
}

}
