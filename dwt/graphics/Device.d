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
module dwt.graphics.Device;

import dwt.SWT;
import dwt.SWTException;
import dwt.dwthelper.System;
import dwt.dwthelper.utils;
import dwt.graphics.Drawable;
import dwt.graphics.Color;
import dwt.graphics.DeviceData;
import dwt.graphics.Font;
import dwt.graphics.FontData;
import dwt.graphics.GCData;
import dwt.graphics.Point;
import dwt.graphics.Rectangle;
import dwt.internal.Compatibility;
import Carbon = dwt.internal.c.Carbon;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSAutoreleasePool;
import dwt.internal.cocoa.NSDictionary;
import dwt.internal.cocoa.NSFont;
import dwt.internal.cocoa.NSFontManager;
import dwt.internal.cocoa.NSMutableDictionary;
import dwt.internal.cocoa.NSMutableParagraphStyle;
import dwt.internal.cocoa.NSNumber;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSScreen;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSThread;
import dwt.internal.cocoa.NSValue;
import dwt.internal.cocoa.OS;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

import tango.io.Stdout;

/**
 * This class is the abstract superclass of all device objects,
 * such as the Display device and the Printer device. Devices
 * can have a graphics context cast(GC) created for them, and they
 * can be drawn on by sending messages to the associated GC.
 *
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public abstract class Device : Drawable {

    /* Debugging */
    public static const bool DEBUG = true;
    bool debug_ = DEBUG;
    bool tracking = DEBUG;
    Error [] errors;
    Object [] objects;
    Object trackingLock;

    /* Disposed flag */
    bool disposed, warnings;

    Color COLOR_BLACK, COLOR_DARK_RED, COLOR_DARK_GREEN, COLOR_DARK_YELLOW, COLOR_DARK_BLUE;
    Color COLOR_DARK_MAGENTA, COLOR_DARK_CYAN, COLOR_GRAY, COLOR_DARK_GRAY, COLOR_RED;
    Color COLOR_GREEN, COLOR_YELLOW, COLOR_BLUE, COLOR_MAGENTA, COLOR_CYAN, COLOR_WHITE;

    /* System Font */
    Font systemFont;

    NSMutableParagraphStyle paragraphStyle;

    /* Device DPI */
    Point dpi;

    /*
    * TEMPORARY CODE. When a graphics object is
    * created and the device parameter is null,
    * the current Display is used. This presents
    * a problem because DWT graphics does not
    * reference classes in DWT widgets. The correct
    * fix is to remove this feature. Unfortunately,
    * too many application programs rely on this
    * feature.
    */
    protected static Device CurrentDevice;
    protected static Runnable DeviceFinder;
    static this (){
        try {
            ClassInfo.find ("dwt.widgets.Display.Display");
        } catch (ClassNotFoundException e) {}
    }

/*
* TEMPORARY CODE.
*/
static synchronized Device getDevice () {
    if (DeviceFinder !is null) DeviceFinder.run();
    Device device = CurrentDevice;
    CurrentDevice = null;
    return device;
}

/**
 * Constructs a new instance of this class.
 * <p>
 * You must dispose the device when it is no longer required.
 * </p>
 *
 * @see #create
 * @see #init
 *
 * @since 3.1
 */
public this() {
    this(null);
}

/**
 * Constructs a new instance of this class.
 * <p>
 * You must dispose the device when it is no longer required.
 * </p>
 *
 * @param data the DeviceData which describes the receiver
 *
 * @see #create
 * @see #init
 * @see DeviceData
 */
public this(DeviceData data) {
    synchronized (Device.classinfo) {
        if (data !is null) {
            debug_ = data.debug_;
            tracking = data.tracking;
        }
        if (tracking) {
            errors = new Error [128];
            objects = new Object [128];
            trackingLock = new Object ();
        }
        if (NSThread.isMainThread()) {
            NSAutoreleasePool pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
            NSThread nsthread = NSThread.currentThread();
            NSMutableDictionary dictionary = nsthread.threadDictionary();
            NSString key = NSString.stringWith("SWT_NSAutoreleasePool");
            cocoa.id obj = dictionary.objectForKey(key);
            if (obj is null) {
                NSNumber nsnumber = NSNumber.numberWithInteger(cast(NSInteger) pool.id);
                dictionary.setObject(nsnumber, key);
            } else {
                pool.release();
            }
        }
        //check and create pool
        create (data);
        init_ ();
    }
}

/**
 * Throws an <code>DWTException</code> if the receiver can not
 * be accessed by the caller. This may include both checks on
 * the state of the receiver and more generally on the entire
 * execution context. This method <em>should</em> be called by
 * device implementors to enforce the standard DWT invariants.
 * <p>
 * Currently, it is an error to invoke any method (other than
 * <code>isDisposed()</code> and <code>dispose()</code>) on a
 * device that has had its <code>dispose()</code> method called.
 * </p><p>
 * In future releases of DWT, there may be more or fewer error
 * checks and exceptions may be thrown for different reasons.
 * <p>
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
protected void checkDevice () {
    if (disposed) DWT.error(DWT.ERROR_DEVICE_DISPOSED);
}

/**
 * Creates the device in the operating system.  If the device
 * does not have a handle, this method may do nothing depending
 * on the device.
 * <p>
 * This method is called before <code>init</code>.
 * </p><p>
 * Subclasses are supposed to reimplement this method and not
 * call the <code>super</code> implementation.
 * </p>
 *
 * @param data the DeviceData which describes the receiver
 *
 * @see #init
 */
protected void create (DeviceData data) {
}

/**
 * Disposes of the operating system resources associated with
 * the receiver. After this method has been invoked, the receiver
 * will answer <code>true</code> when sent the message
 * <code>isDisposed()</code>.
 *
 * @see #release
 * @see #destroy
 * @see #checkDevice
 */
public void dispose () {
    synchronized (Device.classinfo) {
        if (isDisposed()) return;
        checkDevice ();
        release ();
        destroy ();
        disposed = true;
        if (tracking) {
            synchronized (trackingLock) {
                printErrors ();
                objects = null;
                errors = null;
                trackingLock = null;
            }
        }
    }
}

void dispose_Object (Object object) {
    synchronized (trackingLock) {
        for (int i=0; i<objects.length; i++) {
            if (objects [i] is object) {
                objects [i] = null;
                errors [i] = null;
                return;
            }
        }
    }
}

/**
 * Destroys the device in the operating system and releases
 * the device's handle.  If the device does not have a handle,
 * this method may do nothing depending on the device.
 * <p>
 * This method is called after <code>release</code>.
 * </p><p>
 * Subclasses are supposed to reimplement this method and not
 * call the <code>super</code> implementation.
 * </p>
 *
 * @see #dispose
 * @see #release
 */
protected void destroy () {
}

/**
 * Returns a rectangle describing the receiver's size and location.
 *
 * @return the bounding rectangle
 *
 * @exception DWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Rectangle getBounds () {
    checkDevice ();
    NSRect frame = getPrimaryScreen().frame();
    return new Rectangle(cast(int)frame.x, cast(int)frame.y, cast(int)frame.width, cast(int)frame.height);
}

/**
 * Returns a <code>DeviceData</code> based on the receiver.
 * Modifications made to this <code>DeviceData</code> will not
 * affect the receiver.
 *
 * @return a <code>DeviceData</code> containing the device's data and attributes
 *
 * @exception DWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see DeviceData
 */
public DeviceData getDeviceData () {
    checkDevice();
    DeviceData data = new DeviceData ();
    data.debug_ = debug_;
    data.tracking = tracking;
    if (tracking) {
        synchronized (trackingLock) {
            int count = 0, length = objects.length;
            for (int i=0; i<length; i++) {
                if (objects [i] !is null) count++;
            }
            int index = 0;
            data.objects = new Object [count];
            data.errors = new Error [count];
            for (int i=0; i<length; i++) {
                if (objects [i] !is null) {
                    data.objects [index] = objects [i];
                    data.errors [index] = errors [i];
                    index++;
                }
            }
        }
    } else {
        data.objects = new Object [0];
        data.errors = new Error [0];
    }
    return data;
}

/**
 * Returns a rectangle which describes the area of the
 * receiver which is capable of displaying data.
 *
 * @return the client area
 *
 * @exception DWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getBounds
 */
public Rectangle getClientArea () {
    checkDevice ();
    return getBounds ();
}

/**
 * Returns the bit depth of the screen, which is the number of
 * bits it takes to represent the number of unique colors that
 * the screen is currently capable of displaying. This number
 * will typically be one of 1, 8, 15, 16, 24 or 32.
 *
 * @return the depth of the screen
 *
 * @exception DWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int getDepth () {
    checkDevice ();
    return cast(int)/*64*/OS.NSBitsPerPixelFromDepth(getPrimaryScreen().depth());
}

/**
 * Returns a point whose x coordinate is the horizontal
 * dots per inch of the display, and whose y coordinate
 * is the vertical dots per inch of the display.
 *
 * @return the horizontal and vertical DPI
 *
 * @exception DWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Point getDPI () {
    checkDevice ();
    return getScreenDPI();
}

NSScreen getPrimaryScreen () {
    NSArray screens = NSScreen.screens();
    return new NSScreen(screens.objectAtIndex(0));
}

/**
 * Returns <code>FontData</code> objects which describe
 * the fonts that match the given arguments. If the
 * <code>faceName</code> is null, all fonts will be returned.
 *
 * @param faceName the name of the font to look for, or null
 * @param scalable if true only scalable fonts are returned, otherwise only non-scalable fonts are returned.
 * @return the matching font data
 *
 * @exception DWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public FontData[] getFontList (String faceName, bool scalable) {
    checkDevice ();
    if (!scalable) return new FontData[0];
    int count = 0;
    NSArray families = NSFontManager.sharedFontManager().availableFontFamilies();
    NSUInteger familyCount = families.count();
    FontData[] fds = new FontData[100];
    for (NSUInteger i = 0; i < familyCount; i++) {
        NSString nsFamily = new NSString(families.objectAtIndex(i));
        String name = nsFamily.getString();
        NSArray fonts = NSFontManager.sharedFontManager().availableMembersOfFontFamily(nsFamily);
        NSUInteger fontCount = fonts.count();
        for (NSUInteger j = 0; j < fontCount; j++) {
            NSArray fontDetails = new NSArray(fonts.objectAtIndex(j));
            String nsName = new NSString(fontDetails.objectAtIndex(0)).getString();
            NSInteger weight = new NSNumber(fontDetails.objectAtIndex(2)).integerValue();
            NSInteger traits = new NSNumber(fontDetails.objectAtIndex(3)).integerValue();
            int style = DWT.NORMAL;
            if ((traits & OS.NSItalicFontMask) !is 0) style |= DWT.ITALIC;
            if (weight is 9) style |= DWT.BOLD;
            if (faceName is null || Compatibility.equalsIgnoreCase(faceName, name)) {
                FontData data = new FontData(name, 0, style);
                data.nsName = nsName;
                if (count is fds.length) {
                    FontData[] newFds = new FontData[fds.length + 100];
                    System.arraycopy(fds, 0, newFds, 0, fds.length);
                    fds = newFds;
                }
                fds[count++] = data;
            }
        }
    }
    if (count is fds.length) return fds;
    FontData[] result = new FontData[count];
    System.arraycopy(fds, 0, result, 0, count);
    return result;
}

Point getScreenDPI () {
    NSDictionary dictionary = getPrimaryScreen().deviceDescription();
    NSValue value = new NSValue(dictionary.objectForKey(new cocoa.id(OS.NSDeviceResolution)).id);
    NSSize size = value.sizeValue();
    return new Point(cast(int)size.width, cast(int)size.height);
}

/**
 * Returns the matching standard color for the given
 * constant, which should be one of the color constants
 * specified in class <code>DWT</code>. Any value other
 * than one of the DWT color constants which is passed
 * in will result in the color black. This color should
 * not be freed because it was allocated by the system,
 * not the application.
 *
 * @param id the color constant
 * @return the matching color
 *
 * @exception DWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see DWT
 */
public Color getSystemColor (int id) {
    checkDevice ();
    switch (id) {
        case DWT.COLOR_BLACK:               return COLOR_BLACK;
        case DWT.COLOR_DARK_RED:            return COLOR_DARK_RED;
        case DWT.COLOR_DARK_GREEN:          return COLOR_DARK_GREEN;
        case DWT.COLOR_DARK_YELLOW:         return COLOR_DARK_YELLOW;
        case DWT.COLOR_DARK_BLUE:           return COLOR_DARK_BLUE;
        case DWT.COLOR_DARK_MAGENTA:        return COLOR_DARK_MAGENTA;
        case DWT.COLOR_DARK_CYAN:           return COLOR_DARK_CYAN;
        case DWT.COLOR_GRAY:                return COLOR_GRAY;
        case DWT.COLOR_DARK_GRAY:           return COLOR_DARK_GRAY;
        case DWT.COLOR_RED:                 return COLOR_RED;
        case DWT.COLOR_GREEN:               return COLOR_GREEN;
        case DWT.COLOR_YELLOW:              return COLOR_YELLOW;
        case DWT.COLOR_BLUE:                return COLOR_BLUE;
        case DWT.COLOR_MAGENTA:             return COLOR_MAGENTA;
        case DWT.COLOR_CYAN:                return COLOR_CYAN;
        case DWT.COLOR_WHITE:               return COLOR_WHITE;
        default:
    }
    return COLOR_BLACK;
}

/**
 * Returns a reasonable font for applications to use.
 * On some platforms, this will match the "default font"
 * or "system font" if such can be found.  This font
 * should not be freed because it was allocated by the
 * system, not the application.
 * <p>
 * Typically, applications which want the default look
 * should simply not set the font on the widgets they
 * create. Widgets are always created with the correct
 * default font for the class of user-interface component
 * they represent.
 * </p>
 *
 * @return a font
 *
 * @exception DWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Font getSystemFont () {
    checkDevice ();
    return systemFont;
}

/**
 * Returns <code>true</code> if the underlying window system prints out
 * warning messages on the console, and <code>setWarnings</code>
 * had previously been called with <code>true</code>.
 *
 * @return <code>true</code>if warnings are being handled, and <code>false</code> otherwise
 *
 * @exception DWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public bool getWarnings () {
    checkDevice ();
    return warnings;
}

/**
 * Initializes any internal resources needed by the
 * device.
 * <p>
 * This method is called after <code>create</code>.
 * </p><p>
 * If subclasses reimplement this method, they must
 * call the <code>super</code> implementation.
 * </p>
 *
 * @see #create
 */
protected void init_ () {
    /* Create the standard colors */
    COLOR_BLACK = new Color (this, 0,0,0);
    COLOR_DARK_RED = new Color (this, 0x80,0,0);
    COLOR_DARK_GREEN = new Color (this, 0,0x80,0);
    COLOR_DARK_YELLOW = new Color (this, 0x80,0x80,0);
    COLOR_DARK_BLUE = new Color (this, 0,0,0x80);
    COLOR_DARK_MAGENTA = new Color (this, 0x80,0,0x80);
    COLOR_DARK_CYAN = new Color (this, 0,0x80,0x80);
    COLOR_GRAY = new Color (this, 0xC0,0xC0,0xC0);
    COLOR_DARK_GRAY = new Color (this, 0x80,0x80,0x80);
    COLOR_RED = new Color (this, 0xFF,0,0);
    COLOR_GREEN = new Color (this, 0,0xFF,0);
    COLOR_YELLOW = new Color (this, 0xFF,0xFF,0);
    COLOR_BLUE = new Color (this, 0,0,0xFF);
    COLOR_MAGENTA = new Color (this, 0xFF,0,0xFF);
    COLOR_CYAN = new Color (this, 0,0xFF,0xFF);
    COLOR_WHITE = new Color (this, 0xFF,0xFF,0xFF);

    paragraphStyle = (NSMutableParagraphStyle)new NSMutableParagraphStyle().alloc().init();
    paragraphStyle.setAlignment(OS.NSLeftTextAlignment);
    paragraphStyle.setLineBreakMode(OS.NSLineBreakByClipping);
    NSArray tabs = new NSArray(new NSArray().alloc().init());
    paragraphStyle.setTabStops(tabs);
    tabs.release();

    /* Initialize the system font slot */
    bool smallFonts = System.getProperty("org.eclipse.swt.internal.carbon.smallFonts") !is null;
    Carbon.CGFloat systemFontSize = smallFonts ? NSFont.smallSystemFontSize() : NSFont.systemFontSize();
    Point dpi = this.dpi = getDPI(), screenDPI = getScreenDPI();
    NSFont font = NSFont.systemFontOfSize(systemFontSize * dpi.y / screenDPI.y);
    font.retain();
    systemFont = Font.cocoa_new(this, font);
}

/**
 * Invokes platform specific functionality to allocate a new GC handle.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>Device</code>. It is marked public only so that it
 * can be shared within the packages provided by DWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param data the platform specific GC data
 * @return the platform specific GC handle
 */
public abstract objc.id internal_new_GC (GCData data);

/**
 * Invokes platform specific functionality to dispose a GC handle.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>Device</code>. It is marked public only so that it
 * can be shared within the packages provided by DWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param hDC the platform specific GC handle
 * @param data the platform specific GC data
 */
public abstract void internal_dispose_GC (objc.id handle, GCData data);

/**
 * Returns <code>true</code> if the device has been disposed,
 * and <code>false</code> otherwise.
 * <p>
 * This method gets the dispose state for the device.
 * When a device has been disposed, it is an error to
 * invoke any other method using the device.
 *
 * @return <code>true</code> when the device is disposed and <code>false</code> otherwise
 */
public bool isDisposed () {
    synchronized (Device.classinfo) {
        return disposed;
    }
}

/**
 * Loads the font specified by a file.  The font will be
 * present in the list of fonts available to the application.
 *
 * @param path the font file path
 * @return whether the font was successfully loaded
 *
 * @exception DWTException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if path is null</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see Font
 *
 * @since 3.3
 */
public bool loadFont (String path) {
    checkDevice();
    if (path is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    bool result = false;
    NSString nsPath = NSString.stringWith(path);
    char* fsRepresentation = nsPath.fileSystemRepresentation();

    if (fsRepresentation !is null) {
        byte [] fsRef = new byte [80];
        bool [] isDirectory = new bool[1];
        if (OS.FSPathMakeRef (fsRepresentation, fsRef, isDirectory) is OS.noErr) {
            result = OS.ATSFontActivateFromFileReference (fsRef, OS.kATSFontContextLocal, OS.kATSFontFormatUnspecified, 0, OS.kATSOptionFlagsDefault, null) is OS.noErr;
        }
    }

    return result;
}

void new_Object (Object object) {
    synchronized (trackingLock) {
        for (int i=0; i<objects.length; i++) {
            if (objects [i] is null) {
                objects [i] = object;
                errors [i] = new Error ("");
                return;
            }
        }
        Object [] newObjects = new Object [objects.length + 128];
        System.arraycopy (objects, 0, newObjects, 0, objects.length);
        newObjects [objects.length] = object;
        objects = newObjects;
        Error [] newErrors = new Error [errors.length + 128];
        System.arraycopy (errors, 0, newErrors, 0, errors.length);
        newErrors [errors.length] = new Error ("");
        errors = newErrors;
    }
}

void printErrors () {
    if (!DEBUG) return;
    if (tracking) {
        synchronized (trackingLock) {
            if (objects is null || errors is null) return;
            int objectCount = 0;
            int colors = 0, cursors = 0, fonts = 0, gcs = 0, images = 0;
            int paths = 0, patterns = 0, regions = 0, textLayouts = 0, transforms = 0;
            for (int i=0; i<objects.length; i++) {
                Object object = objects [i];
                if (object !is null) {
                    objectCount++;
                    if (object instanceof Color) colors++;
                    if (object instanceof Cursor) cursors++;
                    if (object instanceof Font) fonts++;
                    if (object instanceof GC) gcs++;
                    if (object instanceof Image) images++;
                    if (object instanceof Path) paths++;
                    if (object instanceof Pattern) patterns++;
                    if (object instanceof Region) regions++;
                    if (object instanceof TextLayout) textLayouts++;
                    if (object instanceof Transform) transforms++;
                }
            }
            if (objectCount !is 0) {
                String string = "Summary: ";
                if (colors !is 0) string ~= Format("{}{}, ", colors, " Color(s), ");
                if (cursors !is 0) string ~= Format("{}{}", cursors , " Cursor(s), ");
                if (fonts !is 0) string ~= Format("{}{}", fonts , " Font(s), ");
                if (gcs !is 0) string ~= Format("{}{}", gcs , " GC(s), ");
                if (images !is 0) string ~= Format("{}{}", images , " Image(s), ");
                if (paths !is 0) string ~= Format("{}{}", paths , " Path(s), ");
                if (patterns !is 0) string ~= Format("{}{}", patterns , " Pattern(s), ");
                if (regions !is 0) string ~= Format("{}{}", regions , " Region(s), ");
                if (textLayouts !is 0) string ~= Format("{}{}", textLayouts , " TextLayout(s), ");
                if (transforms !is 0) string ~= Format("{}{}", transforms , " Transforms(s), ");
                if (string.length () !is 0) {
                    string = string.substring (0, string.length () - 2);
                    System.out_.println (string);
                }
                for (int i=0; i<errors.length; i++) {
                    if (errors [i] !is null) errors [i].printStackTrace (System.Out);
                }
            }
        }
    }
}

/**
 * Releases any internal resources back to the operating
 * system and clears all fields except the device handle.
 * <p>
 * When a device is destroyed, resources that were acquired
 * on behalf of the programmer need to be returned to the
 * operating system.  For example, if the device allocated a
 * font to be used as the system font, this font would be
 * freed in <code>release</code>.  Also,to assist the garbage
 * collector and minimize the amount of memory that is not
 * reclaimed when the programmer keeps a reference to a
 * disposed device, all fields except the handle are zero'd.
 * The handle is needed by <code>destroy</code>.
 * </p>
 * This method is called before <code>destroy</code>.
 * </p><p>
 * If subclasses reimplement this method, they must
 * call the <code>super</code> implementation.
 * </p>
 *
 * @see #dispose
 * @see #destroy
 */
protected void release () {
    if (paragraphStyle !is null) paragraphStyle.release();
    paragraphStyle = null;

    if (systemFont !is null) systemFont.dispose();
    systemFont = null;

    if (COLOR_BLACK !is null) COLOR_BLACK.dispose();
    if (COLOR_DARK_RED !is null) COLOR_DARK_RED.dispose();
    if (COLOR_DARK_GREEN !is null) COLOR_DARK_GREEN.dispose();
    if (COLOR_DARK_YELLOW !is null) COLOR_DARK_YELLOW.dispose();
    if (COLOR_DARK_BLUE !is null) COLOR_DARK_BLUE.dispose();
    if (COLOR_DARK_MAGENTA !is null) COLOR_DARK_MAGENTA.dispose();
    if (COLOR_DARK_CYAN !is null) COLOR_DARK_CYAN.dispose();
    if (COLOR_GRAY !is null) COLOR_GRAY.dispose();
    if (COLOR_DARK_GRAY !is null) COLOR_DARK_GRAY.dispose();
    if (COLOR_RED !is null) COLOR_RED.dispose();
    if (COLOR_GREEN !is null) COLOR_GREEN.dispose();
    if (COLOR_YELLOW !is null) COLOR_YELLOW.dispose();
    if (COLOR_BLUE !is null) COLOR_BLUE.dispose();
    if (COLOR_MAGENTA !is null) COLOR_MAGENTA.dispose();
    if (COLOR_CYAN !is null) COLOR_CYAN.dispose();
    if (COLOR_WHITE !is null) COLOR_WHITE.dispose();
    COLOR_BLACK = COLOR_DARK_RED = COLOR_DARK_GREEN = COLOR_DARK_YELLOW = COLOR_DARK_BLUE =
    COLOR_DARK_MAGENTA = COLOR_DARK_CYAN = COLOR_GRAY = COLOR_DARK_GRAY = COLOR_RED =
    COLOR_GREEN = COLOR_YELLOW = COLOR_BLUE = COLOR_MAGENTA = COLOR_CYAN = COLOR_WHITE = null;
}

/**
 * If the underlying window system supports printing warning messages
 * to the console, setting warnings to <code>false</code> prevents these
 * messages from being printed. If the argument is <code>true</code> then
 * message printing is not blocked.
 *
 * @param warnings <code>true</code>if warnings should be printed, and <code>false</code> otherwise
 *
 * @exception DWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setWarnings (bool warnings) {
    checkDevice ();
    this.warnings = warnings;
}

}
