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
module dwt.graphics.GC;

import dwt.dwthelper.utils;

import dwt.SWT;
import dwt.SWTError;
import dwt.SWTException;
import dwt.graphics.Color;
import dwt.graphics.Device;
import dwt.graphics.Drawable;
import dwt.graphics.Font;
import dwt.graphics.FontMetrics;
import dwt.graphics.GCData;
import dwt.graphics.Image;
import dwt.graphics.ImageData;
import dwt.graphics.LineAttributes;
import dwt.graphics.Path;
import dwt.graphics.Pattern;
import dwt.graphics.Point;
import dwt.graphics.Rectangle;
import dwt.graphics.Region;
import dwt.graphics.Resource;
import dwt.graphics.RGB;
import dwt.graphics.Transform;
import Carbon = dwt.internal.c.Carbon;
import dwt.internal.cocoa.CGPathElement;
import dwt.internal.cocoa.CGPoint;
import dwt.internal.cocoa.CGRect;
import dwt.internal.cocoa.NSAffineTransform;
import dwt.internal.cocoa.NSAffineTransformStruct;
import dwt.internal.cocoa.NSApplication;
import dwt.internal.cocoa.NSAttributedString;
import dwt.internal.cocoa.NSAutoreleasePool;
import dwt.internal.cocoa.NSBezierPath;
import dwt.internal.cocoa.NSBitmapImageRep;
import dwt.internal.cocoa.NSColor;
import dwt.internal.cocoa.NSFont;
import dwt.internal.cocoa.NSGradient;
import dwt.internal.cocoa.NSGraphicsContext;
import dwt.internal.cocoa.NSImage;
import dwt.internal.cocoa.NSMutableDictionary;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSThread;
import dwt.internal.cocoa.NSView;
import dwt.internal.cocoa.NSWindow;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

import tango.core.Thread;
import tango.text.convert.Format;

/**
 * Class <code>GC</code> is where all of the drawing capabilities that are
 * supported by DWT are located. Instances are used to draw on either an
 * <code>Image</code>, a <code>Control</code>, or directly on a <code>Display</code>.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>LEFT_TO_RIGHT, RIGHT_TO_LEFT</dd>
 * </dl>
 *
 * <p>
 * The DWT drawing coordinate system is the two-dimensional space with the origin
 * (0,0) at the top left corner of the drawing area and with (x,y) values increasing
 * to the right and downward respectively.
 * </p>
 *
 * <p>
 * The result of drawing on an image that was created with an indexed
 * palette using a color that is not in the palette is platform specific.
 * Some platforms will match to the nearest color while other will draw
 * the color itself. This happens because the allocated image might use
 * a direct palette on platforms that do not support indexed palette.
 * </p>
 *
 * <p>
 * Application code must explicitly invoke the <code>GC.dispose()</code>
 * method to release the operating system resources managed by each instance
 * when those instances are no longer required. This is <em>particularly</em>
 * important on Windows95 and Windows98 where the operating system has a limited
 * number of device contexts available.
 * </p>
 *
 * <p>
 * Note: Only one of LEFT_TO_RIGHT and RIGHT_TO_LEFT may be specified.
 * </p>
 *
 * @see dwt.events.PaintEvent
 * @see <a href="http://www.eclipse.org/swt/snippets/#gc">GC snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">DWT Examples: GraphicsExample, PaintExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public final class GC : Resource {

    alias Resource.init_ init_;

    /**
     * the handle to the OS device context
     * (Warning: This field is platform dependent)
     * <p>
     * <b>IMPORTANT:</b> This field is <em>not</em> part of the DWT
     * public API. It is marked public only so that it can be shared
     * within the packages provided by DWT. It is not available on all
     * platforms and should never be accessed from application code.
     * </p>
     */
    public NSGraphicsContext handle;

    Drawable drawable;
    GCData data;

    CGPathElement element;
    int count, typeCount;
    byte[] types;
    Carbon.CGFloat[] points;
    Carbon.CGFloat[] point;

    static const int TAB_COUNT = 32;

    const static int FOREGROUND = 1 << 0;
    const static int BACKGROUND = 1 << 1;
    const static int FONT = 1 << 2;
    const static int LINE_STYLE = 1 << 3;
    const static int LINE_CAP = 1 << 4;
    const static int LINE_JOIN = 1 << 5;
    const static int LINE_WIDTH = 1 << 6;
    const static int LINE_MITERLIMIT = 1 << 7;
    const static int FOREGROUND_FILL = 1 << 8;
    const static int DRAW_OFFSET = 1 << 9;
    const static int CLIPPING = 1 << 10;
    const static int TRANSFORM = 1 << 11;
    const static int VISIBLE_REGION = 1 << 12;
    const static int DRAW = CLIPPING | TRANSFORM | FOREGROUND | LINE_WIDTH | LINE_STYLE  | LINE_CAP  | LINE_JOIN | LINE_MITERLIMIT | DRAW_OFFSET;
    const static int FILL = CLIPPING | TRANSFORM | BACKGROUND;

    static const Carbon.CGFloat[] LINE_DOT = [1, 1];
    static const Carbon.CGFloat[] LINE_DASH = [3, 1];
    static const Carbon.CGFloat[] LINE_DASHDOT = [3, 1, 1, 1];
    static const Carbon.CGFloat[] LINE_DASHDOTDOT = [3, 1, 1, 1, 1, 1];
    static const Carbon.CGFloat[] LINE_DOT_ZERO = [3, 3];
    static const Carbon.CGFloat[] LINE_DASH_ZERO = [18, 6];
    static const Carbon.CGFloat[] LINE_DASHDOT_ZERO = [9, 6, 3, 6];
    static const Carbon.CGFloat[] LINE_DASHDOTDOT_ZERO = [9, 3, 3, 3, 3, 3];

this() {
}

/**
 * Constructs a new instance of this class which has been
 * configured to draw on the specified drawable. Sets the
 * foreground color, background color and font in the GC
 * to match those in the drawable.
 * <p>
 * You must dispose the graphics context when it is no longer required.
 * </p>
 * @param drawable the drawable to draw on
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the drawable is null</li>
 *    <li>ERROR_NULL_ARGUMENT - if there is no current device</li>
 *    <li>ERROR_INVALID_ARGUMENT
 *          - if the drawable is an image that is not a bitmap or an icon
 *          - if the drawable is an image or printer that is already selected
 *            into another graphics context</li>
 * </ul>
 * @exception DWTError <ul>
 *    <li>ERROR_NO_HANDLES if a handle could not be obtained for GC creation</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS if not called from the thread that created the drawable</li>
 * </ul>
 */
public this(Drawable drawable) {
    this(drawable, 0);
}

/**
 * Constructs a new instance of this class which has been
 * configured to draw on the specified drawable. Sets the
 * foreground color, background color and font in the GC
 * to match those in the drawable.
 * <p>
 * You must dispose the graphics context when it is no longer required.
 * </p>
 *
 * @param drawable the drawable to draw on
 * @param style the style of GC to construct
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the drawable is null</li>
 *    <li>ERROR_NULL_ARGUMENT - if there is no current device</li>
 *    <li>ERROR_INVALID_ARGUMENT
 *          - if the drawable is an image that is not a bitmap or an icon
 *          - if the drawable is an image or printer that is already selected
 *            into another graphics context</li>
 * </ul>
 * @exception DWTError <ul>
 *    <li>ERROR_NO_HANDLES if a handle could not be obtained for GC creation</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS if not called from the thread that created the drawable</li>
 * </ul>
 *
 * @since 2.1.2
 */
public this(Drawable drawable, int style) {
    if (drawable is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = (NSAutoreleasePool) new NSAutoreleasePool().alloc().init();
    try {
        GCData data = new GCData();
        data.style = checkStyle(style);
        objc.id contextId = drawable.internal_new_GC(data);
        Device device = data.device;
        if (device is null) device = Device.getDevice();
        if (device is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
        this.device = data.device = device;
        init_(drawable, data, contextId);
        init_();
    } finally {
        if (pool !is null) pool.release();
    }
}

static int checkStyle (int style) {
    if ((style & DWT.LEFT_TO_RIGHT) !is 0) style &= ~DWT.RIGHT_TO_LEFT;
    return style & (DWT.LEFT_TO_RIGHT | DWT.RIGHT_TO_LEFT);
}

/**
 * Invokes platform specific functionality to allocate a new graphics context.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>GC</code>. It is marked public only so that it
 * can be shared within the packages provided by DWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param drawable the Drawable for the receiver.
 * @param data the data for the receiver.
 *
 * @return a new <code>GC</code>
 *
 * @private
 */
public static GC cocoa_new(Drawable drawable, GCData data) {
    GC gc = new GC();
    objc.id context = drawable.internal_new_GC(data);
    gc.device = data.device;
    gc.init_(drawable, data, context);
    return gc;
}

objc.id applierFunc(objc.id info, objc.id elementPtr) {
    OS.memmove(element, elementPtr, CGPathElement.sizeof);
    int type = 0, length = 1;
    switch (element.type) {
        case OS.kCGPathElementMoveToPoint: type = DWT.PATH_MOVE_TO; break;
        case OS.kCGPathElementAddLineToPoint: type = DWT.PATH_LINE_TO; break;
        case OS.kCGPathElementAddQuadCurveToPoint: type = DWT.PATH_QUAD_TO; length = 2; break;
        case OS.kCGPathElementAddCurveToPoint: type = DWT.PATH_CUBIC_TO; length = 3; break;
        case OS.kCGPathElementCloseSubpath: type = DWT.PATH_CLOSE; length = 0; break;
    }
    if (types !is null) {
        types[typeCount] = (byte)type;
        if (length > 0) {
            OS.memmove(point, element.points, length * CGPoint.sizeof);
            System.arraycopy(point, 0, points, count, length * 2);
        }
    }
    typeCount++;
    count += length * 2;
    return 0;
}

NSAutoreleasePool checkGC (int mask) {
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    if (data.flippedContext !is null && !handle.isEqual(NSGraphicsContext.currentContext())) {
        data.restoreContext = true;
        NSGraphicsContext.static_saveGraphicsState();
        NSGraphicsContext.setCurrentContext(handle);
    }
    if ((mask & (CLIPPING | TRANSFORM)) !is 0) {
        NSView view = data.view;
        if ((data.state & CLIPPING) is 0 || (data.state & TRANSFORM) is 0 || (data.state & VISIBLE_REGION) is 0) {
            bool antialias = handle.shouldAntialias();
            handle.restoreGraphicsState();
            handle.saveGraphicsState();
            handle.setShouldAntialias(antialias);
            if (view !is null && (data.paintRect is null || !view.isFlipped())) {
                NSAffineTransform transform = NSAffineTransform.transform();
                NSRect rect = view.convertRect_toView_(view.bounds(), null);
                if (data.paintRect is null) {
                    transform.translateXBy(rect.x, rect.y + rect.height);
                } else {
                    transform.translateXBy(0, rect.height);
                }
                transform.scaleXBy(1, -1);
                transform.concat();
                if (data.visibleRgn !is 0) {
                    if (data.visiblePath is null || (data.state & VISIBLE_REGION) is 0) {
                        if (data.visiblePath !is null) data.visiblePath.release();
                        data.visiblePath = Region.cocoa_new(device, data.visibleRgn).getPath();
                    }
                    data.visiblePath.addClip();
                    data.state |= VISIBLE_REGION;
                }
            }
            if (data.clipPath !is null) data.clipPath.addClip();
            if (data.transform !is null) data.transform.concat();
            mask &= ~(TRANSFORM | CLIPPING);
            data.state |= TRANSFORM | CLIPPING;
            data.state &= ~(BACKGROUND | FOREGROUND);
        }
    }

    int state = data.state;
    if ((state & mask) is mask) return pool;
    state = (state ^ mask) & mask;
    data.state |= mask;

    if ((state & FOREGROUND) !is 0) {
        Pattern pattern = data.foregroundPattern;
        if (pattern !is null) {
            if (pattern.color !is null) pattern.color.setStroke();
        } else {
            Carbon.CGFloat[] color = data.foreground;
            if (data.fg !is null) data.fg.release();
            NSColor fg = data.fg = NSColor.colorWithDeviceRed(color[0], color[1], color[2], data.alpha / 255f);
            fg.retain();
            fg.setStroke();
        }
    }
    if ((state & FOREGROUND_FILL) !is 0) {
        Pattern pattern = data.foregroundPattern;
        if (pattern !is null) {
            if (pattern.color !is null) pattern.color.setFill();
        } else {
            Carbon.CGFloat[] color = data.foreground;
            if (data.fg !is null) data.fg.release();
            NSColor fg = data.fg = NSColor.colorWithDeviceRed(color[0], color[1], color[2], data.alpha / 255f);
            fg.retain();
            fg.setFill();
        }
        data.state &= ~BACKGROUND;
    }
    if ((state & BACKGROUND) !is 0) {
        Pattern pattern = data.backgroundPattern;
        if (pattern !is null) {
            if (pattern.color !is null) pattern.color.setFill();
        } else {
            Carbon.CGFloat[] color = data.background;
            if (data.bg !is null) data.bg.release();
            NSColor bg = data.bg = NSColor.colorWithDeviceRed(color[0], color[1], color[2], data.alpha / 255f);
            bg.retain();
            bg.setFill();
        }
        data.state &= ~FOREGROUND_FILL;
    }
    NSBezierPath path = data.path;
    if ((state & LINE_WIDTH) !is 0) {
        path.setLineWidth(data.lineWidth is 0 ?  1 : data.lineWidth);
        switch (data.lineStyle) {
            case DWT.LINE_DOT:
            case DWT.LINE_DASH:
            case DWT.LINE_DASHDOT:
            case DWT.LINE_DASHDOTDOT:
                state |= LINE_STYLE;
            default:
        }
    }
    if ((state & LINE_STYLE) !is 0) {
        Carbon.CGFloat[] dashes = null;
        Carbon.CGFloat width = data.lineWidth;
        switch (data.lineStyle) {
            case DWT.LINE_SOLID: break;
            case DWT.LINE_DASH: dashes = width !is 0 ? LINE_DASH : LINE_DASH_ZERO; break;
            case DWT.LINE_DOT: dashes = width !is 0 ? LINE_DOT : LINE_DOT_ZERO; break;
            case DWT.LINE_DASHDOT: dashes = width !is 0 ? LINE_DASHDOT : LINE_DASHDOT_ZERO; break;
            case DWT.LINE_DASHDOTDOT: dashes = width !is 0 ? LINE_DASHDOTDOT : LINE_DASHDOTDOT_ZERO; break;
            case DWT.LINE_CUSTOM: dashes = data.lineDashes; break;
            default:
        }
        if (dashes !is null) {
            Carbon.CGFloat[] lengths = new Carbon.CGFloat[dashes.length];
            for (int i = 0; i < lengths.length; i++) {
                lengths[i] = width is 0 || data.lineStyle is DWT.LINE_CUSTOM ? dashes[i] : dashes[i] * width;
            }
            path.setLineDash(lengths.ptr, lengths.length, data.lineDashesOffset);
        } else {
            path.setLineDash(null, 0, 0);
        }
    }
    if ((state & LINE_MITERLIMIT) !is 0) {
        path.setMiterLimit(data.lineMiterLimit);
    }
    if ((state & LINE_JOIN) !is 0) {
        NSLineJoinStyle joinStyle;
        switch (data.lineJoin) {
            case DWT.JOIN_MITER: joinStyle = OS.NSMiterLineJoinStyle; break;
            case DWT.JOIN_ROUND: joinStyle = OS.NSRoundLineJoinStyle; break;
            case DWT.JOIN_BEVEL: joinStyle = OS.NSBevelLineJoinStyle; break;
            default:
        }
        path.setLineJoinStyle(joinStyle);
    }
    if ((state & LINE_CAP) !is 0) {
        NSLineCapStyle capStyle = 0;
        switch (data.lineCap) {
            case DWT.CAP_ROUND: capStyle = OS.NSRoundLineCapStyle; break;
            case DWT.CAP_FLAT: capStyle = OS.NSButtLineCapStyle; break;
            case DWT.CAP_SQUARE: capStyle = OS.NSSquareLineCapStyle; break;
            default:
        }
        path.setLineCapStyle(capStyle);
    }
    if ((state & DRAW_OFFSET) !is 0) {
        data.drawXOffset = data.drawYOffset = 0;
        NSSize size = NSSize();
        size.width = size.height = 1;
        if (data.transform !is null) {
            size = data.transform.transformSize(size);
        }
        Carbon.CGFloat scaling = size.width;
        if (scaling < 0) scaling = -scaling;
        Carbon.CGFloat strokeWidth = data.lineWidth * scaling;
        if (strokeWidth is 0 || (cast(size_t)strokeWidth % 2) is 1) {
            data.drawXOffset = 0.5f / scaling;
        }
        scaling = size.height;
        if (scaling < 0) scaling = -scaling;
        strokeWidth = data.lineWidth * scaling;
        if (strokeWidth is 0 || (cast(size_t)strokeWidth % 2) is 1) {
            data.drawYOffset = 0.5f / scaling;
        }
    }
    return pool;
}

/**
 * Copies a rectangular area of the receiver at the specified
 * position into the image, which must be of type <code>DWT.BITMAP</code>.
 *
 * @param image the image to copy into
 * @param x the x coordinate in the receiver of the area to be copied
 * @param y the y coordinate in the receiver of the area to be copied
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the image is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the image is not a bitmap or has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void copyArea(Image image, int x, int y) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (image is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (image.type !is DWT.BITMAP || image.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    NSAutoreleasePool pool = checkGC(TRANSFORM | CLIPPING);
    try {
        if (data.image !is null) {
            int srcX = x, srcY = y, destX = 0, destY = 0;
            NSSize srcSize = data.image.handle.size();
            int imgHeight = (int)srcSize.height;
            int destWidth = (int)srcSize.width - x, destHeight = (int)srcSize.height - y;
            int srcWidth = destWidth, srcHeight = destHeight;
            NSGraphicsContext context = NSGraphicsContext.graphicsContextWithBitmapImageRep(image.getRepresentation());
            NSGraphicsContext.static_saveGraphicsState();
            NSGraphicsContext.setCurrentContext(context);
            NSAffineTransform transform = NSAffineTransform.transform();
            NSSize size = image.handle.size();
            transform.translateXBy(0, size.height-(destHeight + 2 * destY));
            transform.concat();
            NSRect srcRect = new NSRect();
            srcRect.x = srcX;
            srcRect.y = imgHeight - (srcY + srcHeight);
            srcRect.width = srcWidth;
            srcRect.height = srcHeight;
            NSRect destRect = new NSRect();
            destRect.x = destX;
            destRect.y = destY;
            destRect.width = destWidth;
            destRect.height = destHeight;
            data.image.handle.drawInRect(destRect, srcRect, OS.NSCompositeCopy, 1);
            NSGraphicsContext.static_restoreGraphicsState();
            return;
        }
        if (data.view !is null) {
            NSPoint pt = new NSPoint();
            pt.x = x;
            pt.y = y;
            NSWindow window = data.view.window();
            pt = data.view.convertPoint_toView_(pt, window.contentView().superview());
            NSRect frame = window.frame();
            pt.y = frame.height - pt.y;
            NSSize size = image.handle.size();
            CGRect destRect = CGRect();
            destRect.size.width = size.width;
            destRect.size.height = size.height;
            CGRect srcRect = CGRect();
            srcRect.origin.x = pt.x;
            srcRect.origin.y = pt.y;
            srcRect.size.width = size.width;
            srcRect.size.height = size.height;
            NSBitmapImageRep imageRep = image.getRepresentation();
            NSGraphicsContext context = NSGraphicsContext.graphicsContextWithBitmapImageRep(imageRep);
            NSGraphicsContext.static_saveGraphicsState();
            NSGraphicsContext.setCurrentContext(context);
            objc.id contextID = OS.objc_msgSend(NSApplication.sharedApplication().id, OS.sel_contextID);
            OS.CGContextCopyWindowContentsToRect(context.graphicsPort(), destRect, contextID, window.windowNumber(), srcRect);
            NSGraphicsContext.static_restoreGraphicsState();
            return;
        }
        if (handle.isDrawingToScreen()) {
            NSImage imageHandle = image.handle;
            NSSize size = imageHandle.size();
            CGRect rect = CGRect();
            rect.origin.x = x;
            rect.origin.y = y;
            rect.size.width = size.width;
            rect.size.height = size.height;
            int displayCount = 16;
            void* displays = OS.malloc(4 * displayCount), countPtr = OS.malloc(4);
            if (OS.CGGetDisplaysWithRect(rect, displayCount, displays, countPtr) !is 0) return;
            int[] count = new int[1], display = new int[1];
            OS.memmove(count, countPtr, OS.PTR_SIZEOF);
            for (int i = 0; i < count[0]; i++) {
                OS.memmove(display, displays + (i * 4), 4);
                OS.CGDisplayBounds(display[0], rect);
                void* address = OS.CGDisplayBaseAddress(display[0]);
                if (address !is 0) {
                    size_t width = OS.CGDisplayPixelsWide(display[0]);
                    size_t height = OS.CGDisplayPixelsHigh(display[0]);
                    size_t bpr = OS.CGDisplayBytesPerRow(display[0]);
                    size_t bpp = OS.CGDisplayBitsPerPixel(display[0]);
                    size_t bps = OS.CGDisplayBitsPerSample(display[0]);
                    int bitmapInfo = OS.kCGImageAlphaNoneSkipFirst;
                    switch ((int)/*63*/bpp) {
                        case 16: bitmapInfo |= OS.kCGBitmapByteOrder16Host; break;
                        case 32: bitmapInfo |= OS.kCGBitmapByteOrder32Host; break;
                    }
                    CGImageRef srcImage = null;
                    if (OS.__BIG_ENDIAN__() && OS.VERSION >= 0x1040) {
                        CGColorSpaceRef colorspace = OS.CGColorSpaceCreateDeviceRGB();
                        CGContextRef context = OS.CGBitmapContextCreate(address, width, height, bps, bpr, colorspace, bitmapInfo);
                        OS.CGColorSpaceRelease(colorspace);
                        srcImage = OS.CGBitmapContextCreateImage(context);
                        OS.CGContextRelease(context);
                    } else {
                        CGDataProviderRef provider = OS.CGDataProviderCreateWithData(0, address, bpr * height, 0);
                        CGColorSpaceRef colorspace = OS.CGColorSpaceCreateDeviceRGB();
                        srcImage = OS.CGImageCreate(width, height, bps, bpp, bpr, colorspace, bitmapInfo, provider, 0, true, 0);
                        OS.CGColorSpaceRelease(colorspace);
                        OS.CGDataProviderRelease(provider);
                    }
                    copyArea(image, x - (int)rect.origin.x, y - (int)rect.origin.y, srcImage);
                    if (srcImage !is 0) OS.CGImageRelease(srcImage);
                }
            }
            OS.free(displays);
            OS.free(countPtr);
        }
    } finally {
        uncheckGC(pool);
    }
}

void copyArea (Image image, int x, int y, CGImageRef srcImage) {
    if (srcImage is 0) return;
    NSBitmapImageRep rep = image.getRepresentation();
    auto bpc = rep.bitsPerSample();
    auto width = rep.pixelsWide();
    auto height = rep.pixelsHigh();
    auto bpr = rep.bytesPerRow();
    auto alphaInfo = rep.hasAlpha() ? OS.kCGImageAlphaFirst : OS.kCGImageAlphaNoneSkipFirst;
    auto colorspace = OS.CGColorSpaceCreateDeviceRGB();
    auto context = OS.CGBitmapContextCreate(rep.bitmapData(), width, height, bpc, bpr, colorspace, alphaInfo);
    OS.CGColorSpaceRelease(colorspace);
    if (context !is null) {
        CGRect rect = CGRect();
        rect.origin.x = -x;
        rect.origin.y = y;
        rect.size.width = OS.CGImageGetWidth(srcImage);
        rect.size.height = OS.CGImageGetHeight(srcImage);
        OS.CGContextTranslateCTM(context, 0, -(rect.size.height - height));
        OS.CGContextDrawImage(context, rect, srcImage);
        OS.CGContextRelease(context);
    }
}

/**
 * Copies a rectangular area of the receiver at the source
 * position onto the receiver at the destination position.
 *
 * @param srcX the x coordinate in the receiver of the area to be copied
 * @param srcY the y coordinate in the receiver of the area to be copied
 * @param width the width of the area to copy
 * @param height the height of the area to copy
 * @param destX the x coordinate in the receiver of the area to copy to
 * @param destY the y coordinate in the receiver of the area to copy to
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void copyArea(int srcX, int srcY, int width, int height, int destX, int destY) {
    copyArea(srcX, srcY, width, height, destX, destY, true);
}
/**
 * Copies a rectangular area of the receiver at the source
 * position onto the receiver at the destination position.
 *
 * @param srcX the x coordinate in the receiver of the area to be copied
 * @param srcY the y coordinate in the receiver of the area to be copied
 * @param width the width of the area to copy
 * @param height the height of the area to copy
 * @param destX the x coordinate in the receiver of the area to copy to
 * @param destY the y coordinate in the receiver of the area to copy to
 * @param paint if <code>true</code> paint events will be generated for old and obscured areas
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.1
 */
public void copyArea(int srcX, int srcY, int width, int height, int destX, int destY, bool paint) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (width <= 0 || height <= 0) return;
    int deltaX = destX - srcX, deltaY = destY - srcY;
    if (deltaX is 0 && deltaY is 0) return;
    NSAutoreleasePool pool = checkGC(TRANSFORM | CLIPPING);
    try {
        Image image = data.image;
        if (image !is null) {
            NSImage imageHandle = image.handle;
            NSSize size = imageHandle.size();
            int imgHeight = (int)size.height;
            handle.saveGraphicsState();
            NSAffineTransform transform = NSAffineTransform.transform();
            transform.scaleXBy(1, -1);
            transform.translateXBy(0, -(height + 2 * destY));
            transform.concat();
            NSRect srcRect = new NSRect();
            srcRect.x = srcX;
            srcRect.y = imgHeight - (srcY + height);
            srcRect.width = width;
            srcRect.height = height;
            NSRect destRect = new NSRect();
            destRect.x = destX;
            destRect.y = destY;
            destRect.width = width;
            destRect.height = height;
            imageHandle.drawInRect(destRect, srcRect, OS.NSCompositeCopy, 1);
            handle.restoreGraphicsState();
            return;
        }
        if (data.view !is null) {
            NSView view = data.view;
            NSRect visibleRect = view.visibleRect();
            if (visibleRect.width <= 0 || visibleRect.height <= 0) return;
            NSRect damage = new NSRect();
            damage.x = srcX;
            damage.y = srcY;
            damage.width = width;
            damage.height = height;
            NSPoint dest = new NSPoint();
            dest.x = destX;
            dest.y = destY;

            view.lockFocus();
            OS.NSCopyBits(0, damage , dest);
            view.unlockFocus();

            if (paint) {
                bool disjoint = (destX + width < srcX) || (srcX + width < destX) || (destY + height < srcY) || (srcY + height < destY);
                if (disjoint) {
                    view.setNeedsDisplayInRect(damage);
                } else {
                    if (deltaX !is 0) {
                        int newX = destX - deltaX;
                        if (deltaX < 0) newX = destX + width;
                        damage.x = newX;
                        damage.width = Math.abs(deltaX);
                        view.setNeedsDisplayInRect(damage);
                    }
                    if (deltaY !is 0) {
                        int newY = destY - deltaY;
                        if (deltaY < 0) newY = destY + height;
                        damage.x = srcX;
                        damage.y = newY;
                        damage.width = width;
                        damage.height =  Math.abs (deltaY);
                        view.setNeedsDisplayInRect(damage);
                    }
                }

                NSRect srcRect = new NSRect();
                srcRect.x = srcX;
                srcRect.y = srcY;
                srcRect.width = width;
                srcRect.height = height;
                OS.NSIntersectionRect(visibleRect, visibleRect, srcRect);

                if (!OS.NSEqualRects(visibleRect, srcRect)) {
                    if (srcRect.x !is visibleRect.x) {
                        damage.x = srcRect.x + deltaX;
                        damage.y = srcRect.y + deltaY;
                        damage.width = visibleRect.x - srcRect.x;
                        damage.height = srcRect.height;
                        view.setNeedsDisplayInRect(damage);
                    }
                    if (visibleRect.x + visibleRect.width !is srcRect.x + srcRect.width) {
                        damage.x = srcRect.x + visibleRect.width + deltaX;
                        damage.y = srcRect.y + deltaY;
                        damage.width = srcRect.width - visibleRect.width;
                        damage.height = srcRect.height;
                        view.setNeedsDisplayInRect(damage);
                    }
                    if (visibleRect.y !is srcRect.y) {
                        damage.x = visibleRect.x + deltaX;
                        damage.y = srcRect.y + deltaY;
                        damage.width = visibleRect.width;
                        damage.height = visibleRect.y - srcRect.y;
                        view.setNeedsDisplayInRect(damage);
                    }
                    if (visibleRect.y + visibleRect.height !is srcRect.y + srcRect.height) {
                        damage.x = visibleRect.x + deltaX;
                        damage.y = visibleRect.y + visibleRect.height + deltaY;
                        damage.width = visibleRect.width;
                        damage.height = srcRect.y + srcRect.height - (visibleRect.y + visibleRect.height);
                        view.setNeedsDisplayInRect(damage);
                    }
                }
            }
            return;
        }
    } finally {
        uncheckGC(pool);
    }
}

static CGMutablePathRef createCGPathRef(NSBezierPath nsPath) {
    auto count = nsPath.elementCount();
    if (count > 0) {
        auto cgPath = OS.CGPathCreateMutable();
        if (cgPath is 0) DWT.error(DWT.ERROR_NO_HANDLES);
        auto points = OS.malloc(NSPoint.sizeof * 3);
        if (points is 0) DWT.error(DWT.ERROR_NO_HANDLES);
        auto [] pt = new Carbon.CGFloat[6];
        for (int i = 0; i < count; i++) {
            auto element = nsPath.elementAtIndex(i, points);
            switch (element) {
                case OS.NSMoveToBezierPathElement:
                    OS.memmove(pt, points, NSPoint.sizeof);
                    OS.CGPathMoveToPoint(cgPath, 0, pt[0], pt[1]);
                    break;
                case OS.NSLineToBezierPathElement:
                    OS.memmove(pt, points, NSPoint.sizeof);
                    OS.CGPathAddLineToPoint(cgPath, 0, pt[0], pt[1]);
                    break;
                 case OS.NSCurveToBezierPathElement:
                     OS.memmove(pt, points, NSPoint.sizeof * 3);
                     OS.CGPathAddCurveToPoint(cgPath, 0, pt[0], pt[1], pt[2], pt[3], pt[4], pt[5]);
                     break;
                case OS.NSClosePathBezierPathElement:
                     OS.CGPathCloseSubpath(cgPath);
                     break;
            }
        }
        OS.free(points);
        return cgPath;
    }
    return 0;
}



NSBezierPath createNSBezierPath (CGMutablePathRef  cgPath) {
    auto proc = &applierFunc;
    count = typeCount = 0;
    element = new CGPathElement();
    OS.CGPathApply(cgPath, 0, proc);
    types = new byte[typeCount];
    points = new Carbon.CGFloat [count];
    point = new Carbon.CGFloat [6];
    count = typeCount = 0;
    OS.CGPathApply(cgPath, 0, proc);
    callback.dispose();

    NSBezierPath bezierPath = NSBezierPath.bezierPath();
    NSPoint nsPoint = new NSPoint(), nsPoint2 = new NSPoint(), nsPoint3 = new NSPoint();
    for (int i = 0, j = 0; i < types.length; i++) {
        switch (types[i]) {
            case DWT.PATH_MOVE_TO:
                nsPoint.x = points[j++];
                nsPoint.y = points[j++];
                bezierPath.moveToPoint(nsPoint);
                break;
            case DWT.PATH_LINE_TO:
                nsPoint.x = points[j++];
                nsPoint.y = points[j++];
                bezierPath.lineToPoint(nsPoint);
                break;
            case DWT.PATH_CUBIC_TO:
                nsPoint2.x = points[j++];
                nsPoint2.y = points[j++];
                nsPoint3.x = points[j++];
                nsPoint3.y = points[j++];
                nsPoint.x = points[j++];
                nsPoint.y = points[j++];
                bezierPath.curveToPoint(nsPoint, nsPoint2, nsPoint3);
                break;
            case DWT.PATH_QUAD_TO:
                Carbon.CGFloat currentX = nsPoint.x;
                Carbon.CGFloat currentY = nsPoint.y;
                nsPoint2.x = points[j++];
                nsPoint2.y = points[j++];
                nsPoint.x = points[j++];
                nsPoint.y = points[j++];
                Carbon.CGFloat x0 = currentX;
                Carbon.CGFloat y0 = currentY;
                Carbon.CGFloat cx1 = x0 + 2 * (nsPoint2.x - x0) / 3;
                Carbon.CGFloat cy1 = y0 + 2 * (nsPoint2.y - y0) / 3;
                Carbon.CGFloat cx2 = cx1 + (nsPoint.x - x0) / 3;
                Carbon.CGFloat cy2 = cy1 + (nsPoint.y - y0) / 3;
                nsPoint2.x = cx1;
                nsPoint2.y = cy1;
                nsPoint3.x = cx2;
                nsPoint3.y = cy2;
                bezierPath.curveToPoint(nsPoint, nsPoint2, nsPoint3);
                break;
            case DWT.PATH_CLOSE:
                bezierPath.closePath();
                break;
            default:
                dispose();
                DWT.error(DWT.ERROR_INVALID_ARGUMENT);
        }
    }
    element = null;
    types = null;
    points = null;
    nsPoint = null;
    return bezierPath;
}

NSAttributedString createString(String string, int flags, bool draw) {
    NSMutableDictionary dict = ((NSMutableDictionary)new NSMutableDictionary().alloc()).initWithCapacity(5);
    Font font = data.font;
    dict.setObject(font.handle, OS.NSFontAttributeName);
    font.addTraits(dict);
    if (draw) {
        Pattern pattern = data.foregroundPattern;
        if (pattern !is null) {
            if (pattern.color !is null) dict.setObject(pattern.color, OS.NSForegroundColorAttributeName);
        } else {
            NSColor fg = data.fg;
            if (fg is null) {
                Carbon.CGFloat [] color = data.foreground;
                fg = data.fg = NSColor.colorWithDeviceRed(color[0], color[1], color[2], data.alpha / 255f);
                fg.retain();
            }
            dict.setObject(fg, OS.NSForegroundColorAttributeName);
        }
    }
    if ((flags & DWT.DRAW_TAB) is 0) {
        dict.setObject(device.paragraphStyle, OS.NSParagraphStyleAttributeName);
    }
    size_t length = string.length();
    wchar[] chars = new wchar[length]
    string.getChars(0, length, chars, 0);
    int breakCount = 0;
    int[] breaks = null;
    if ((flags & DWT.DRAW_MNEMONIC) !is 0 || (flags & DWT.DRAW_DELIMITER) is 0) {
        int i=0, j=0;
        while (i < chars.length) {
            char c = chars [j++] = chars [i++];
            switch (c) {
                case '&': {
                    if ((flags & DWT.DRAW_MNEMONIC) !is 0) {
                        if (i is chars.length) {continue;}
                        if (chars [i] is '&') {i++; continue;}
                        j--;
                    }
                    break;
                }
                case '\r':
                case '\n': {
                    if ((flags & DWT.DRAW_DELIMITER) is 0) {
                        if (c is '\r' && i !is chars.length && chars[i] is '\n') i++;
                        j--;
                        if (breaks is null) {
                            breaks = new int[4];
                        } else if (breakCount is breaks.length) {
                            int[] newBreaks = new int[breaks.length + 4];
                            System.arraycopy(breaks, 0, newBreaks, 0, breaks.length);
                            breaks = newBreaks;
                        }
                        breaks[breakCount++] = j;
                    }
                    break;
                }
                default:
            }
        }
        length = j;
    }
    NSString str = (cast(NSString)new NSString().alloc()).initWithCharacters(chars, length);
    NSAttributedString attribStr = (cast(NSAttributedString)new NSAttributedString().alloc()).initWithString(str, dict);
    dict.release();
    str.release();
    return attribStr;
}

void destroy() {
    /* Free resources */
    Image image = data.image;
    if (image !is null) {
        image.memGC = null;
        image.createAlpha();
    }
    if (data.fg !is null) data.fg.release();
    if (data.bg !is null) data.bg.release();
    if (data.path !is null) data.path.release();
    if (data.clipPath !is null) data.clipPath.release();
    if (data.visiblePath !is null) data.visiblePath.release();
    if (data.transform !is null) data.transform.release();
    if (data.inverseTransform !is null) data.inverseTransform.release();
    data.path = data.clipPath = data.visiblePath = null;
    data.transform = data.inverseTransform = null;
    data.fg = data.bg = null;

    /* Dispose the GC */
    if (drawable !is null) drawable.internal_dispose_GC(handle.id, data);
    handle.restoreGraphicsState();
    handle.release();

    drawable = null;
    data.image = null;
    data = null;
    handle = null;
}

/**
 * Draws the outline of a circular or elliptical arc
 * within the specified rectangular area.
 * <p>
 * The resulting arc begins at <code>startAngle</code> and extends
 * for <code>arcAngle</code> degrees, using the current color.
 * Angles are interpreted such that 0 degrees is at the 3 o'clock
 * position. A positive value indicates a counter-clockwise rotation
 * while a negative value indicates a clockwise rotation.
 * </p><p>
 * The center of the arc is the center of the rectangle whose origin
 * is (<code>x</code>, <code>y</code>) and whose size is specified by the
 * <code>width</code> and <code>height</code> arguments.
 * </p><p>
 * The resulting arc covers an area <code>width + 1</code> pixels wide
 * by <code>height + 1</code> pixels tall.
 * </p>
 *
 * @param x the x coordinate of the upper-left corner of the arc to be drawn
 * @param y the y coordinate of the upper-left corner of the arc to be drawn
 * @param width the width of the arc to be drawn
 * @param height the height of the arc to be drawn
 * @param startAngle the beginning angle
 * @param arcAngle the angular extent of the arc, relative to the start angle
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void drawArc(int x, int y, int width, int height, int startAngle, int arcAngle) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (width < 0) {
        x = x + width;
        width = -width;
    }
    if (height < 0) {
        y = y + height;
        height = -height;
    }
    if (width is 0 || height is 0 || arcAngle is 0) return;
    NSAutoreleasePool pool = checkGC(DRAW);
    try {
        handle.saveGraphicsState();
        NSAffineTransform transform = NSAffineTransform.transform();
        Carbon.CGFloat xOffset = data.drawXOffset, yOffset = data.drawYOffset;
        transform.translateXBy(x + xOffset + width / 2f, y + yOffset + height / 2f);
        transform.scaleXBy(width / 2f, height / 2f);
        NSBezierPath path = data.path;
        NSPoint center = NSPoint();
        Carbon.CGFloat sAngle = -startAngle;
        Carbon.CGFloat eAngle = -(startAngle + arcAngle);
        path.appendBezierPathWithArcWithCenter(center, 1, sAngle,  eAngle, arcAngle>0);
        path.transformUsingAffineTransform(transform);
        Pattern pattern = data.foregroundPattern;
        if (pattern !is null && pattern.gradient !is null) {
            strokePattern(path, pattern);
        } else {
            path.stroke();
        }
        path.removeAllPoints();
        handle.restoreGraphicsState();
    } finally {
        uncheckGC(pool);
    }
}

/**
 * Draws a rectangle, based on the specified arguments, which has
 * the appearance of the platform's <em>focus rectangle</em> if the
 * platform supports such a notion, and otherwise draws a simple
 * rectangle in the receiver's foreground color.
 *
 * @param x the x coordinate of the rectangle
 * @param y the y coordinate of the rectangle
 * @param width the width of the rectangle
 * @param height the height of the rectangle
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #drawRectangle(int, int, int, int)
 */
public void drawFocus(int x, int y, int width, int height) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    NSAutoreleasePool pool = checkGC(CLIPPING | TRANSFORM);
    try {
        int[] metric = new int[1];
        OS.GetThemeMetric(OS.kThemeMetricFocusRectOutset, metric);
        CGRect rect = CGRect();
        rect.origin.x = x + metric[0];
        rect.origin.y = y + metric[0];
        rect.size.width = width - metric[0] * 2;
        rect.size.height = height - metric[0] * 2;
        OS.HIThemeDrawFocusRect(rect, true, handle.graphicsPort(), OS.kHIThemeOrientationNormal);
    } finally {
        uncheckGC(pool);
    }
}

/**
 * Draws the given image in the receiver at the specified
 * coordinates.
 *
 * @param image the image to draw
 * @param x the x coordinate of where to draw
 * @param y the y coordinate of where to draw
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the image is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the image has been disposed</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the given coordinates are outside the bounds of the image</li>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 * @exception DWTError <ul>
 *    <li>ERROR_NO_HANDLES - if no handles are available to perform the operation</li>
 * </ul>
 */
public void drawImage(Image image, int x, int y) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (image is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (image.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    drawImage(image, 0, 0, -1, -1, x, y, -1, -1, true);
}

/**
 * Copies a rectangular area from the source image into a (potentially
 * different sized) rectangular area in the receiver. If the source
 * and destination areas are of differing sizes, then the source
 * area will be stretched or shrunk to fit the destination area
 * as it is copied. The copy fails if any part of the source rectangle
 * lies outside the bounds of the source image, or if any of the width
 * or height arguments are negative.
 *
 * @param image the source image
 * @param srcX the x coordinate in the source image to copy from
 * @param srcY the y coordinate in the source image to copy from
 * @param srcWidth the width in pixels to copy from the source
 * @param srcHeight the height in pixels to copy from the source
 * @param destX the x coordinate in the destination to copy to
 * @param destY the y coordinate in the destination to copy to
 * @param destWidth the width in pixels of the destination rectangle
 * @param destHeight the height in pixels of the destination rectangle
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the image is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the image has been disposed</li>
 *    <li>ERROR_INVALID_ARGUMENT - if any of the width or height arguments are negative.
 *    <li>ERROR_INVALID_ARGUMENT - if the source rectangle is not contained within the bounds of the source image</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 * @exception DWTError <ul>
 *    <li>ERROR_NO_HANDLES - if no handles are available to perform the operation</li>
 * </ul>
 */
public void drawImage(Image image, int srcX, int srcY, int srcWidth, int srcHeight, int destX, int destY, int destWidth, int destHeight) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (srcWidth is 0 || srcHeight is 0 || destWidth is 0 || destHeight is 0) return;
    if (srcX < 0 || srcY < 0 || srcWidth < 0 || srcHeight < 0 || destWidth < 0 || destHeight < 0) {
        DWT.error (DWT.ERROR_INVALID_ARGUMENT);
    }
    if (image is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (image.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    drawImage(image, srcX, srcY, srcWidth, srcHeight, destX, destY, destWidth, destHeight, false);
}

void drawImage(Image srcImage, int srcX, int srcY, int srcWidth, int srcHeight, int destX, int destY, int destWidth, int destHeight, bool simple) {
    NSImage imageHandle = srcImage.handle;
    NSSize size = imageHandle.size();
    int imgWidth = cast(int)size.width;
    int imgHeight = cast(int)size.height;
    if (simple) {
        srcWidth = destWidth = imgWidth;
        srcHeight = destHeight = imgHeight;
    } else {
        simple = srcX is 0 && srcY is 0 &&
            srcWidth is destWidth && destWidth is imgWidth &&
            srcHeight is destHeight && destHeight is imgHeight;
        if (srcX + srcWidth > imgWidth || srcY + srcHeight > imgHeight) {
            DWT.error(DWT.ERROR_INVALID_ARGUMENT);
        }
    }
    NSAutoreleasePool pool = checkGC(CLIPPING | TRANSFORM);
    try {
        if (srcImage.memGC !is null) {
            srcImage.createAlpha();
        }
        handle.saveGraphicsState();
        NSAffineTransform transform = NSAffineTransform.transform();
        transform.scaleXBy(1, -1);
        transform.translateXBy(0, -(destHeight + 2 * destY));
        transform.concat();
        NSRect srcRect = NSRect();
        srcRect.x = srcX;
        srcRect.y = imgHeight - (srcY + srcHeight);
        srcRect.width = srcWidth;
        srcRect.height = srcHeight;
        NSRect destRect = NSRect();
        destRect.x = destX;
        destRect.y = destY;
        destRect.width = destWidth;
        destRect.height = destHeight;
        imageHandle.drawInRect(destRect, srcRect, OS.NSCompositeSourceOver, 1);
        handle.restoreGraphicsState();
    } finally {
        uncheckGC(pool);
    }
}

/**
 * Draws a line, using the foreground color, between the points
 * (<code>x1</code>, <code>y1</code>) and (<code>x2</code>, <code>y2</code>).
 *
 * @param x1 the first point's x coordinate
 * @param y1 the first point's y coordinate
 * @param x2 the second point's x coordinate
 * @param y2 the second point's y coordinate
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void drawLine(int x1, int y1, int x2, int y2) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    NSAutoreleasePool pool = checkGC(DRAW);
    try {
        NSBezierPath path = data.path;
    	NSPoint pt = NSPoint();
        pt.x = x1 + data.drawXOffset;
        pt.y = y1 + data.drawYOffset;
        path.moveToPoint(pt);
        pt.x = x2 + data.drawXOffset;
        pt.y = y2 + data.drawYOffset;
        path.lineToPoint(pt);
        Pattern pattern = data.foregroundPattern;
        if (pattern !is null && pattern.gradient !is null) {
            strokePattern(path, pattern);
        } else {
            path.stroke();
        }
        path.removeAllPoints();
    } finally {
        uncheckGC(pool);
    }
}

/**
 * Draws the outline of an oval, using the foreground color,
 * within the specified rectangular area.
 * <p>
 * The result is a circle or ellipse that fits within the
 * rectangle specified by the <code>x</code>, <code>y</code>,
 * <code>width</code>, and <code>height</code> arguments.
 * </p><p>
 * The oval covers an area that is <code>width + 1</code>
 * pixels wide and <code>height + 1</code> pixels tall.
 * </p>
 *
 * @param x the x coordinate of the upper left corner of the oval to be drawn
 * @param y the y coordinate of the upper left corner of the oval to be drawn
 * @param width the width of the oval to be drawn
 * @param height the height of the oval to be drawn
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void drawOval(int x, int y, int width, int height) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    NSAutoreleasePool pool = checkGC(DRAW);
    try {
        if (width < 0) {
            x = x + width;
            width = -width;
        }
        if (height < 0) {
            y = y + height;
            height = -height;
        }
        NSBezierPath path = data.path;
    	NSRect rect = NSRect();
        rect.x = x + data.drawXOffset;
        rect.y = y + data.drawXOffset;
        rect.width = width;
        rect.height = height;
        path.appendBezierPathWithOvalInRect(rect);
        Pattern pattern = data.foregroundPattern;
        if (pattern !is null && pattern.gradient !is null) {
            strokePattern(path, pattern);
        } else {
            path.stroke();
        }
        path.removeAllPoints();
    } finally {
        uncheckGC(pool);
    }
}

/**
 * Draws the path described by the parameter.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 *
 * @param path the path to draw
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parameter is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the parameter has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 *
 * @see Path
 *
 * @since 3.1
 */
public void drawPath(Path path) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (path is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (path.handle is null) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    NSAutoreleasePool pool = checkGC(DRAW);
    try {
        handle.saveGraphicsState();
        NSAffineTransform transform = NSAffineTransform.transform();
        transform.translateXBy(data.drawXOffset, data.drawYOffset);
        transform.concat();
        NSBezierPath drawPath = data.path;
        drawPath.appendBezierPath(path.handle);
        Pattern pattern = data.foregroundPattern;
        if (pattern !is null && pattern.gradient !is null) {
            strokePattern(drawPath, pattern);
        } else {
            drawPath.stroke();
        }
        drawPath.removeAllPoints();
        handle.restoreGraphicsState();
    } finally {
        uncheckGC(pool);
    }
}

/**
 * Draws a pixel, using the foreground color, at the specified
 * point (<code>x</code>, <code>y</code>).
 * <p>
 * Note that the receiver's line attributes do not affect this
 * operation.
 * </p>
 *
 * @param x the point's x coordinate
 * @param y the point's y coordinate
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.0
 */
public void drawPoint(int x, int y) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    NSAutoreleasePool pool = checkGC(FOREGROUND_FILL | CLIPPING | TRANSFORM);
    try {
        NSRect rect = NSRect();
        rect.x = x;
        rect.y = y;
        rect.width = 1;
        rect.height = 1;
        NSBezierPath path = data.path;
        path.appendBezierPathWithRect(rect);
        path.fill();
        path.removeAllPoints();
    } finally {
        uncheckGC(pool);
    }
}

/**
 * Draws the closed polygon which is defined by the specified array
 * of integer coordinates, using the receiver's foreground color. The array
 * contains alternating x and y values which are considered to represent
 * points which are the vertices of the polygon. Lines are drawn between
 * each consecutive pair, and between the first pair and last pair in the
 * array.
 *
 * @param pointArray an array of alternating x and y values which are the vertices of the polygon
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT if pointArray is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void drawPolygon(int[] pointArray) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (pointArray is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (pointArray.length < 4) return;
    NSAutoreleasePool pool = checkGC(DRAW);
    try {
        Carbon.CGFloat xOffset = data.drawXOffset, yOffset = data.drawYOffset;
        NSBezierPath path = data.path;
        NSPoint pt = NSPoint();
        pt.x = pointArray[0] + xOffset;
        pt.y = pointArray[1] + yOffset;
        path.moveToPoint(pt);
        int end = pointArray.length / 2 * 2;
        for (int i = 2; i < end; i+=2) {
            pt.x = pointArray[i] + xOffset;
            pt.y = pointArray[i+1] + yOffset;
            path.lineToPoint(pt);
        }
        path.closePath();
        Pattern pattern = data.foregroundPattern;
        if (pattern !is null && pattern.gradient !is null) {
            strokePattern(path, pattern);
        } else {
            path.stroke();
        }
        path.removeAllPoints();
    } finally {
        uncheckGC(pool);
    }
}

/**
 * Draws the polyline which is defined by the specified array
 * of integer coordinates, using the receiver's foreground color. The array
 * contains alternating x and y values which are considered to represent
 * points which are the corners of the polyline. Lines are drawn between
 * each consecutive pair, but not between the first pair and last pair in
 * the array.
 *
 * @param pointArray an array of alternating x and y values which are the corners of the polyline
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the point array is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void drawPolyline(int[] pointArray) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (pointArray is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (pointArray.length < 4) return;
    NSAutoreleasePool pool = checkGC(DRAW);
    try {
        Carbon.CGFloat xOffset = data.drawXOffset, yOffset = data.drawYOffset;
        NSBezierPath path = data.path;
        NSPoint pt = NSPoint();
        pt.x = pointArray[0] + xOffset;
        pt.y = pointArray[1] + yOffset;
        path.moveToPoint(pt);
        int end = pointArray.length / 2 * 2;
        for (int i = 2; i < end; i+=2) {
            pt.x = pointArray[i] + xOffset;
            pt.y = pointArray[i+1] + yOffset;
            path.lineToPoint(pt);
        }
        Pattern pattern = data.foregroundPattern;
        if (pattern !is null && pattern.gradient !is null) {
            strokePattern(path, pattern);
        } else {
            path.stroke();
        }
        path.removeAllPoints();
    } finally {
        uncheckGC(pool);
    }
}

/**
 * Draws the outline of the rectangle specified by the arguments,
 * using the receiver's foreground color. The left and right edges
 * of the rectangle are at <code>x</code> and <code>x + width</code>.
 * The top and bottom edges are at <code>y</code> and <code>y + height</code>.
 *
 * @param x the x coordinate of the rectangle to be drawn
 * @param y the y coordinate of the rectangle to be drawn
 * @param width the width of the rectangle to be drawn
 * @param height the height of the rectangle to be drawn
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void drawRectangle(int x, int y, int width, int height) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    NSAutoreleasePool pool = checkGC(DRAW);
    try {
        if (width < 0) {
            x = x + width;
            width = -width;
        }
        if (height < 0) {
            y = y + height;
            height = -height;
        }
    	NSRect rect = NSRect();
        rect.x = x + data.drawXOffset;
        rect.y = y + data.drawYOffset;
        rect.width = width;
        rect.height = height;
        NSBezierPath path = data.path;
        path.appendBezierPathWithRect(rect);
        Pattern pattern = data.foregroundPattern;
        if (pattern !is null && pattern.gradient !is null) {
            strokePattern(path, pattern);
        } else {
            path.stroke();
        }
        path.removeAllPoints();
    } finally {
        uncheckGC(pool);
    }
}

/**
 * Draws the outline of the specified rectangle, using the receiver's
 * foreground color. The left and right edges of the rectangle are at
 * <code>rect.x</code> and <code>rect.x + rect.width</code>. The top
 * and bottom edges are at <code>rect.y</code> and
 * <code>rect.y + rect.height</code>.
 *
 * @param rect the rectangle to draw
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the rectangle is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void drawRectangle(Rectangle rect) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (rect is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    drawRectangle (rect.x, rect.y, rect.width, rect.height);
}

/**
 * Draws the outline of the round-cornered rectangle specified by
 * the arguments, using the receiver's foreground color. The left and
 * right edges of the rectangle are at <code>x</code> and <code>x + width</code>.
 * The top and bottom edges are at <code>y</code> and <code>y + height</code>.
 * The <em>roundness</em> of the corners is specified by the
 * <code>arcWidth</code> and <code>arcHeight</code> arguments, which
 * are respectively the width and height of the ellipse used to draw
 * the corners.
 *
 * @param x the x coordinate of the rectangle to be drawn
 * @param y the y coordinate of the rectangle to be drawn
 * @param width the width of the rectangle to be drawn
 * @param height the height of the rectangle to be drawn
 * @param arcWidth the width of the arc
 * @param arcHeight the height of the arc
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void drawRoundRectangle(int x, int y, int width, int height, int arcWidth, int arcHeight) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (arcWidth is 0 || arcHeight is 0) {
        drawRectangle(x, y, width, height);
        return;
    }
    NSAutoreleasePool pool = checkGC(DRAW);
    try {
        NSBezierPath path = data.path;
    	NSRect rect = NSRect();
        rect.x = x + data.drawXOffset;
        rect.y = y + data.drawYOffset;
        rect.width = width;
        rect.height = height;
        path.appendBezierPathWithRoundedRect(rect, arcWidth / 2f, arcHeight / 2f);
        Pattern pattern = data.foregroundPattern;
        if (pattern !is null && pattern.gradient !is null) {
            strokePattern(path, pattern);
        } else {
            path.stroke();
        }
        path.removeAllPoints();
    } finally {
        uncheckGC(pool);
    }
}

/**
 * Draws the given string, using the receiver's current font and
 * foreground color. No tab expansion or carriage return processing
 * will be performed. The background of the rectangular area where
 * the string is being drawn will be filled with the receiver's
 * background color.
 *
 * @param string the string to be drawn
 * @param x the x coordinate of the top left corner of the rectangular area where the string is to be drawn
 * @param y the y coordinate of the top left corner of the rectangular area where the string is to be drawn
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the string is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void drawString (String string, int x, int y) {
    drawString(string, x, y, false);
}

/**
 * Draws the given string, using the receiver's current font and
 * foreground color. No tab expansion or carriage return processing
 * will be performed. If <code>isTransparent</code> is <code>true</code>,
 * then the background of the rectangular area where the string is being
 * drawn will not be modified, otherwise it will be filled with the
 * receiver's background color.
 *
 * @param string the string to be drawn
 * @param x the x coordinate of the top left corner of the rectangular area where the string is to be drawn
 * @param y the y coordinate of the top left corner of the rectangular area where the string is to be drawn
 * @param isTransparent if <code>true</code> the background will be transparent, otherwise it will be opaque
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the string is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void drawString(String string, int x, int y, bool isTransparent) {
    drawText(string, x, y, isTransparent ? DWT.DRAW_TRANSPARENT : 0);
}

/**
 * Draws the given string, using the receiver's current font and
 * foreground color. Tab expansion and carriage return processing
 * are performed. The background of the rectangular area where
 * the text is being drawn will be filled with the receiver's
 * background color.
 *
 * @param string the string to be drawn
 * @param x the x coordinate of the top left corner of the rectangular area where the text is to be drawn
 * @param y the y coordinate of the top left corner of the rectangular area where the text is to be drawn
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the string is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void drawText(String string, int x, int y) {
    drawText(string, x, y, DWT.DRAW_DELIMITER | DWT.DRAW_TAB);
}

/**
 * Draws the given string, using the receiver's current font and
 * foreground color. Tab expansion and carriage return processing
 * are performed. If <code>isTransparent</code> is <code>true</code>,
 * then the background of the rectangular area where the text is being
 * drawn will not be modified, otherwise it will be filled with the
 * receiver's background color.
 *
 * @param string the string to be drawn
 * @param x the x coordinate of the top left corner of the rectangular area where the text is to be drawn
 * @param y the y coordinate of the top left corner of the rectangular area where the text is to be drawn
 * @param isTransparent if <code>true</code> the background will be transparent, otherwise it will be opaque
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the string is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void drawText(String string, int x, int y, bool isTransparent) {
    int flags = DWT.DRAW_DELIMITER | DWT.DRAW_TAB;
    if (isTransparent) flags |= DWT.DRAW_TRANSPARENT;
    drawText(string, x, y, flags);
}

/**
 * Draws the given string, using the receiver's current font and
 * foreground color. Tab expansion, line delimiter and mnemonic
 * processing are performed according to the specified flags. If
 * <code>flags</code> includes <code>DRAW_TRANSPARENT</code>,
 * then the background of the rectangular area where the text is being
 * drawn will not be modified, otherwise it will be filled with the
 * receiver's background color.
 * <p>
 * The parameter <code>flags</code> may be a combination of:
 * <dl>
 * <dt><b>DRAW_DELIMITER</b></dt>
 * <dd>draw multiple lines</dd>
 * <dt><b>DRAW_TAB</b></dt>
 * <dd>expand tabs</dd>
 * <dt><b>DRAW_MNEMONIC</b></dt>
 * <dd>underline the mnemonic character</dd>
 * <dt><b>DRAW_TRANSPARENT</b></dt>
 * <dd>transparent background</dd>
 * </dl>
 * </p>
 *
 * @param string the string to be drawn
 * @param x the x coordinate of the top left corner of the rectangular area where the text is to be drawn
 * @param y the y coordinate of the top left corner of the rectangular area where the text is to be drawn
 * @param flags the flags specifying how to process the text
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the string is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void drawText (String string, int x, int y, int flags) {
	if (handle == null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
	//if (string == null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
	NSAutoreleasePool pool = checkGC(CLIPPING | TRANSFORM | FONT);
	try {
		handle.saveGraphicsState();
		boolean mode = true;
		switch (data.textAntialias) {
			case SWT.DEFAULT:
				/* Printer is off by default */
				if (!handle.isDrawingToScreen()) mode = false;
				break;
			case SWT.OFF: mode = false; break;
			case SWT.ON: mode = true; break;
		}
		handle.setShouldAntialias(mode);
		NSAttributedString str = createString(string, flags, true);
		if ((flags & SWT.DRAW_TRANSPARENT) == 0) {
			NSSize size = str.size();
			NSRect rect = NSRect();
			rect.x = x;
			rect.y = y;
			rect.width = size.width;
			rect.height = size.height;
			NSColor bg = data.bg;
			if (bg == null) {
				Carbon.CGFloat [] color = data.background;
				bg = data.bg = NSColor.colorWithDeviceRed(color[0], color[1], color[2], data.alpha / 255f);
				bg.retain();
			}
			bg.setFill();
			NSBezierPath.fillRect(rect);
			str.drawInRect(rect);
		} else {
			NSPoint pt = NSPoint();
			pt.x = x;
			pt.y = y;
			str.drawAtPoint(pt);
		}
		str.release();
		handle.restoreGraphicsState();
	} finally {
		uncheckGC(pool);
	}
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
    if (!( null !is cast(GC)object )) return false;
    return handle is (cast(GC)object).handle;
}

alias opEquals equals;

/**
 * Fills the interior of a circular or elliptical arc within
 * the specified rectangular area, with the receiver's background
 * color.
 * <p>
 * The resulting arc begins at <code>startAngle</code> and extends
 * for <code>arcAngle</code> degrees, using the current color.
 * Angles are interpreted such that 0 degrees is at the 3 o'clock
 * position. A positive value indicates a counter-clockwise rotation
 * while a negative value indicates a clockwise rotation.
 * </p><p>
 * The center of the arc is the center of the rectangle whose origin
 * is (<code>x</code>, <code>y</code>) and whose size is specified by the
 * <code>width</code> and <code>height</code> arguments.
 * </p><p>
 * The resulting arc covers an area <code>width + 1</code> pixels wide
 * by <code>height + 1</code> pixels tall.
 * </p>
 *
 * @param x the x coordinate of the upper-left corner of the arc to be filled
 * @param y the y coordinate of the upper-left corner of the arc to be filled
 * @param width the width of the arc to be filled
 * @param height the height of the arc to be filled
 * @param startAngle the beginning angle
 * @param arcAngle the angular extent of the arc, relative to the start angle
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #drawArc
 */
public void fillArc(int x, int y, int width, int height, int startAngle, int arcAngle) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (width < 0) {
        x = x + width;
        width = -width;
    }
    if (height < 0) {
        y = y + height;
        height = -height;
    }
    if (width is 0 || height is 0 || arcAngle is 0) return;
    NSAutoreleasePool pool = checkGC(FILL);
    try {
        handle.saveGraphicsState();
        NSAffineTransform transform = NSAffineTransform.transform();
    	Carbon.CGFloat xOffset = data.drawXOffset, yOffset = data.drawYOffset;
        transform.translateXBy(x + xOffset + width / 2f, y + yOffset + height / 2f);
        transform.scaleXBy(width / 2f, height / 2f);
        NSBezierPath path = data.path;
    	NSPoint center = NSPoint();
        path.moveToPoint(center);
    	Carbon.CGFloat sAngle = -startAngle;
    	Carbon.CGFloat eAngle = -(startAngle + arcAngle);
        path.appendBezierPathWithArcWithCenter(center, 1, sAngle,  eAngle, arcAngle>0);
        path.closePath();
        path.transformUsingAffineTransform(transform);
        Pattern pattern = data.backgroundPattern;
        if (pattern !is null && pattern.gradient !is null) {
            fillPattern(path, pattern);
        } else {
            path.fill();
        }
        path.removeAllPoints();
        handle.restoreGraphicsState();
    } finally {
        uncheckGC(pool);
    }
}

/**
 * Fills the interior of the specified rectangle with a gradient
 * sweeping from left to right or top to bottom progressing
 * from the receiver's foreground color to its background color.
 *
 * @param x the x coordinate of the rectangle to be filled
 * @param y the y coordinate of the rectangle to be filled
 * @param width the width of the rectangle to be filled, may be negative
 *        (inverts direction of gradient if horizontal)
 * @param height the height of the rectangle to be filled, may be negative
 *        (inverts direction of gradient if vertical)
 * @param vertical if true sweeps from top to bottom, else
 *        sweeps from left to right
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #drawRectangle(int, int, int, int)
 */
public void fillGradientRectangle(int x, int y, int width, int height, bool vertical) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if ((width is 0) || (height is 0)) return;
    NSAutoreleasePool pool = checkGC(CLIPPING | TRANSFORM);
    try {
        RGB backgroundRGB, foregroundRGB;
        backgroundRGB = getBackground().getRGB();
        foregroundRGB = getForeground().getRGB();

        RGB fromRGB, toRGB;
        fromRGB = foregroundRGB;
        toRGB   = backgroundRGB;
        bool swapColors = false;
        if (width < 0) {
            x += width; width = -width;
            if (! vertical) swapColors = true;
        }
        if (height < 0) {
            y += height; height = -height;
            if (vertical) swapColors = true;
        }
        if (swapColors) {
            fromRGB = backgroundRGB;
            toRGB   = foregroundRGB;
        }
        if (fromRGB.equals(toRGB)) {
            fillRectangle(x, y, width, height);
        } else {
            NSColor startingColor = NSColor.colorWithDeviceRed(fromRGB.red / 255f, fromRGB.green / 255f, fromRGB.blue / 255f, data.alpha / 255f);
            NSColor endingColor = NSColor.colorWithDeviceRed(toRGB.red / 255f, toRGB.green / 255f, toRGB.blue / 255f, data.alpha / 255f);
        	NSGradient gradient = (cast(NSGradient)(new NSGradient()).alloc()).initWithStartingColor(startingColor, endingColor);
        	NSRect rect = NSRect();
            rect.x = x;
            rect.y = y;
            rect.width = width;
            rect.height = height;
            gradient.drawInRect(rect, vertical ? 90 : 0);
            gradient.release();
        }
    } finally {
        uncheckGC(pool);
    }
}

/**
 * Fills the interior of an oval, within the specified
 * rectangular area, with the receiver's background
 * color.
 *
 * @param x the x coordinate of the upper left corner of the oval to be filled
 * @param y the y coordinate of the upper left corner of the oval to be filled
 * @param width the width of the oval to be filled
 * @param height the height of the oval to be filled
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #drawOval
 */
public void fillOval(int x, int y, int width, int height) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    NSAutoreleasePool pool = checkGC(FILL);
    try {
        if (width < 0) {
            x = x + width;
            width = -width;
        }
        if (height < 0) {
            y = y + height;
            height = -height;
        }
        NSBezierPath path = data.path;
    	NSRect rect = NSRect();
        rect.x = x;
        rect.y = y;
        rect.width = width;
        rect.height = height;
        path.appendBezierPathWithOvalInRect(rect);
        Pattern pattern = data.backgroundPattern;
        if (pattern !is null && pattern.gradient !is null) {
            fillPattern(path, pattern);
        } else {
            path.fill();
        }
        path.removeAllPoints();
    } finally {
        uncheckGC(pool);
    }
}

void fillPattern(NSBezierPath path, Pattern pattern) {
    handle.saveGraphicsState();
    path.addClip();
    NSRect bounds = path.bounds();
    NSPoint start = new NSPoint();
    start.x = pattern.pt1.x;
    start.y = pattern.pt1.y;
    NSPoint end = new NSPoint();
    end.x = pattern.pt2.x;
    end.y = pattern.pt2.y;
    Carbon.CGFloat difx = end.x - start.x;
    Carbon.CGFloat dify = end.y - start.y;
    if (difx is 0 && dify is 0) {
        Carbon.CGFloat [] color = pattern.color1;
        NSColor.colorWithDeviceRed(color[0], color[1], color[2], data.alpha / 255f).setFill();
        path.fill();
        handle.restoreGraphicsState();
        return;
    }
    Carbon.CGFloat startx, starty, endx, endy;
    if (difx is 0 || dify is 0) {
        startx = bounds.x;
        starty = bounds.y;
        endx = bounds.x + bounds.width;
        endy = bounds.y + bounds.height;
        if (difx < 0 || dify < 0) {
            startx = endx;
            starty = endy;
            endx = bounds.x;
            endy = bounds.y;
        }
    } else {
        Carbon.CGFloat m = (end.y-start.y)/(end.x - start.x);
        Carbon.CGFloat b = end.y - (m * end.x);
        Carbon.CGFloat m2 = -1/m; //perpendicular slope
        Carbon.CGFloat b2 = bounds.y - (m2 * bounds.x);
        startx = endx = (b - b2) / (m2 - m);
        b2 = (bounds.y + bounds.height) - (m2 * bounds.x);
        Carbon.CGFloat x2 = (b - b2) / (m2 - m);
        startx = difx > 0 ? Math.min(startx, x2) : Math.max(startx, x2);
        endx = difx < 0 ? Math.min(endx, x2) : Math.max(endx, x2);
        b2 = bounds.y - (m2 * (bounds.x + bounds.width));
        x2 = (b - b2) / (m2 - m);
        startx = difx > 0 ? Math.min(startx, x2) : Math.max(startx, x2);
        endx = difx < 0 ? Math.min(endx, x2) : Math.max(endx, x2);
        b2 = (bounds.y + bounds.height) - (m2 * (bounds.x + bounds.width));
        x2 = (b - b2) / (m2 - m);
        startx = difx > 0 ? Math.min(startx, x2) : Math.max(startx, x2);
        endx = difx < 0 ? Math.min(endx, x2) : Math.max(endx, x2);
        starty = (m * startx) + b;
        endy = (m * endx) + b;
    }
    if (difx !is 0) {
        while ((difx > 0 && start.x >= startx) || (difx < 0 && start.x <= startx)) {
            start.x -= difx;
            start.y -= dify;
        }
    } else {
        while ((dify > 0 && start.y >= starty) || (dify < 0 && start.y <= starty)) {
            start.x -= difx;
            start.y -= dify;
        }
    }
    end.x = start.x;
    end.y = start.y;
    do {
        end.x += difx;
        end.y += dify;
        pattern.gradient.drawFromPoint(start, end, 0);
        start.x = end.x;
        start.y = end.y;
    } while (
                (difx > 0  && end.x <= endx) ||
                (difx < 0  && end.x >= endx) ||
                (difx is 0 && ((dify > 0  && end.y <= endy) || (dify < 0  && end.y >= endy)))
            );
    handle.restoreGraphicsState();
}

/**
 * Fills the path described by the parameter.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 *
 * @param path the path to fill
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parameter is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the parameter has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 *
 * @see Path
 *
 * @since 3.1
 */
public void fillPath(Path path) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (path is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (path.handle is null) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    NSAutoreleasePool pool = checkGC(FILL);
    try {
        NSBezierPath drawPath = data.path;
        drawPath.appendBezierPath(path.handle);
        Pattern pattern = data.backgroundPattern;
        if (pattern !is null && pattern.gradient !is null) {
            fillPattern(drawPath, pattern);
        } else {
            drawPath.fill();
        }
        drawPath.removeAllPoints();
    } finally {
        uncheckGC(pool);
    }
}

/**
 * Fills the interior of the closed polygon which is defined by the
 * specified array of integer coordinates, using the receiver's
 * background color. The array contains alternating x and y values
 * which are considered to represent points which are the vertices of
 * the polygon. Lines are drawn between each consecutive pair, and
 * between the first pair and last pair in the array.
 *
 * @param pointArray an array of alternating x and y values which are the vertices of the polygon
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT if pointArray is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #drawPolygon
 */
public void fillPolygon(int[] pointArray) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (pointArray is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (pointArray.length < 4) return;
    NSAutoreleasePool pool = checkGC(FILL);
    try {
        NSBezierPath path = data.path;
   		NSPoint pt = NSPoint();
        pt.x = pointArray[0];
        pt.y = pointArray[1];
        path.moveToPoint(pt);
        int end = pointArray.length / 2 * 2;
        for (int i = 2; i < end; i+=2) {
            pt.x = pointArray[i];
            pt.y = pointArray[i+1];
            path.lineToPoint(pt);
        }
        path.closePath();
        Pattern pattern = data.backgroundPattern;
        if (pattern !is null && pattern.gradient !is null) {
            fillPattern(path, pattern);
        } else {
            path.fill();
        }
        path.removeAllPoints();
    } finally {
        uncheckGC(pool);
    }
}

/**
 * Fills the interior of the rectangle specified by the arguments,
 * using the receiver's background color.
 *
 * @param x the x coordinate of the rectangle to be filled
 * @param y the y coordinate of the rectangle to be filled
 * @param width the width of the rectangle to be filled
 * @param height the height of the rectangle to be filled
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #drawRectangle(int, int, int, int)
 */
public void fillRectangle(int x, int y, int width, int height) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    NSAutoreleasePool pool = checkGC(FILL);
    try {
        if (width < 0) {
            x = x + width;
            width = -width;
        }
        if (height < 0) {
            y = y + height;
            height = -height;
        }
    	NSRect rect = NSRect();
        rect.x = x;
        rect.y = y;
        rect.width = width;
        rect.height = height;
        NSBezierPath path = data.path;
        path.appendBezierPathWithRect(rect);
        Pattern pattern = data.backgroundPattern;
        if (pattern !is null && pattern.gradient !is null) {
            fillPattern(path, pattern);
        } else {
            path.fill();
        }
        path.removeAllPoints();
    } finally {
        uncheckGC(pool);
    }
}

/**
 * Fills the interior of the specified rectangle, using the receiver's
 * background color.
 *
 * @param rect the rectangle to be filled
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the rectangle is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #drawRectangle(int, int, int, int)
 */
public void fillRectangle(Rectangle rect) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (rect is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    fillRectangle(rect.x, rect.y, rect.width, rect.height);
}

/**
 * Fills the interior of the round-cornered rectangle specified by
 * the arguments, using the receiver's background color.
 *
 * @param x the x coordinate of the rectangle to be filled
 * @param y the y coordinate of the rectangle to be filled
 * @param width the width of the rectangle to be filled
 * @param height the height of the rectangle to be filled
 * @param arcWidth the width of the arc
 * @param arcHeight the height of the arc
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #drawRoundRectangle
 */
public void fillRoundRectangle(int x, int y, int width, int height, int arcWidth, int arcHeight) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (arcWidth is 0 || arcHeight is 0) {
        fillRectangle(x, y, width, height);
        return;
    }
    NSAutoreleasePool pool = checkGC(FILL);
    try {
        NSBezierPath path = data.path;
    	NSRect rect = NSRect();
        rect.x = x;
        rect.y = y;
        rect.width = width;
        rect.height = height;
        path.appendBezierPathWithRoundedRect(rect, arcWidth / 2f, arcHeight / 2f);
        Pattern pattern = data.backgroundPattern;
        if (pattern !is null && pattern.gradient !is null) {
            fillPattern(path, pattern);
        } else {
            path.fill();
        }
        path.removeAllPoints();
    } finally {
        uncheckGC(pool);
    }
}

void strokePattern(NSBezierPath path, Pattern pattern) {
    handle.saveGraphicsState();
    auto cgPath = createCGPathRef(path);
    auto cgContext = handle.graphicsPort();
    OS.CGContextSaveGState(cgContext);
    initCGContext(cgContext);
    OS.CGContextAddPath(cgContext, cgPath);
    OS.CGContextReplacePathWithStrokedPath(cgContext);
    OS.CGPathRelease(cgPath);
    cgPath = 0;
    cgPath = OS.CGContextCopyPath(cgContext);
    if (cgPath is 0) DWT.error(DWT.ERROR_NO_HANDLES);
    OS.CGContextRestoreGState(cgContext);
    NSBezierPath strokePath = createNSBezierPath(cgPath);
    OS.CGPathRelease(cgPath);
    fillPattern(strokePath, pattern);
    handle.restoreGraphicsState();
}

void flush () {
    handle.flushGraphics();
}

/**
 * Returns the <em>advance width</em> of the specified character in
 * the font which is currently selected into the receiver.
 * <p>
 * The advance width is defined as the horizontal distance the cursor
 * should move after printing the character in the selected font.
 * </p>
 *
 * @param ch the character to measure
 * @return the distance in the x direction to move past the character before painting the next
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int getAdvanceWidth(char ch) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    //NOT DONE
    return stringExtent([ch]).x;
}

/**
 * Returns the background color.
 *
 * @return the receiver's background color
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Color getBackground() {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    return Color.cocoa_new (data.device, data.background);
}

/**
 * Returns the background pattern. The default value is
 * <code>null</code>.
 *
 * @return the receiver's background pattern
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see Pattern
 *
 * @since 3.1
 */
public Pattern getBackgroundPattern() {
    if (handle is null) DWT.error(DWT.ERROR_WIDGET_DISPOSED);
    return data.backgroundPattern;
}

/**
 * Returns <code>true</code> if receiver is using the operating system's
 * advanced graphics subsystem.  Otherwise, <code>false</code> is returned
 * to indicate that normal graphics are in use.
 * <p>
 * Advanced graphics may not be installed for the operating system.  In this
 * case, <code>false</code> is always returned.  Some operating system have
 * only one graphics subsystem.  If this subsystem supports advanced graphics,
 * then <code>true</code> is always returned.  If any graphics operation such
 * as alpha, antialias, patterns, interpolation, paths, clipping or transformation
 * has caused the receiver to switch from regular to advanced graphics mode,
 * <code>true</code> is returned.  If the receiver has been explicitly switched
 * to advanced mode and this mode is supported, <code>true</code> is returned.
 * </p>
 *
 * @return the advanced value
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #setAdvanced
 *
 * @since 3.1
 */
public bool getAdvanced() {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    return true;
}

/**
 * Returns the receiver's alpha value. The alpha value
 * is between 0 (transparent) and 255 (opaque).
 *
 * @return the alpha value
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.1
 */
public int getAlpha() {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    return data.alpha;
}

/**
 * Returns the receiver's anti-aliasing setting value, which will be
 * one of <code>DWT.DEFAULT</code>, <code>DWT.OFF</code> or
 * <code>DWT.ON</code>. Note that this controls anti-aliasing for all
 * <em>non-text drawing</em> operations.
 *
 * @return the anti-aliasing setting
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getTextAntialias
 *
 * @since 3.1
 */
public int getAntialias() {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    return data.antialias;
}

/**
 * Returns the width of the specified character in the font
 * selected into the receiver.
 * <p>
 * The width is defined as the space taken up by the actual
 * character, not including the leading and tailing whitespace
 * or overhang.
 * </p>
 *
 * @param ch the character to measure
 * @return the width of the character
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int getCharWidth(char ch) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    //NOT DONE
    return stringExtent([ch]).x;
}

/**
 * Returns the bounding rectangle of the receiver's clipping
 * region. If no clipping region is set, the return value
 * will be a rectangle which covers the entire bounds of the
 * object the receiver is drawing on.
 *
 * @return the bounding rectangle of the clipping region
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Rectangle getClipping() {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool().alloc()).init();
    try {
        NSRect rect = void;
        if (data.view !is null) {
            rect = data.view.visibleRect();
        } else {
            rect = NSRect();
            if (data.image !is null) {
                NSSize size = data.image.handle.size();
                rect.width = size.width;
                rect.height = size.height;
            } else if (data.size !is null) {
                rect.width = data.size.width;
                rect.height = data.size.height;
            }
        }
        if (data.paintRect !is null || data.clipPath !is null || data.inverseTransform !is null) {
            if (data.paintRect !is null) {
                rect = OS.NSIntersectionRect(rect, *data.paintRect);
            }
            if (data.clipPath !is null) {
                NSRect clip = data.clipPath.bounds();
                rect = OS.NSIntersectionRect(rect, clip);
            }
            if (data.inverseTransform !is null && rect.width > 0 && rect.height > 0) {
                NSPoint pt = NSPoint();
                pt.x = rect.x;
                pt.y = rect.y;
                NSSize size = NSSize();
                size.width = rect.width;
                size.height = rect.height;
                pt = data.inverseTransform.transformPoint(pt);
                size =  data.inverseTransform.transformSize(size);
                rect.x = pt.x;
                rect.y = pt.y;
                rect.width = size.width;
                rect.height = size.height;
            }
        }
        return new Rectangle(cast(int)rect.x, cast(int)rect.y, cast(int)rect.width, cast(int)rect.height);
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Sets the region managed by the argument to the current
 * clipping region of the receiver.
 *
 * @param region the region to fill with the clipping region
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the region is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the region is disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void getClipping(Region region) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (region is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (region.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = (NSAutoreleasePool) new NSAutoreleasePool().alloc().init();
    try {
        region.subtract(region);
        NSRect rect = void;
        if (data.view !is null) {
            rect = data.view.visibleRect();
        } else {
            rect = NSRect();
            if (data.image !is null) {
                NSSize size = data.image.handle.size();
                rect.width = size.width;
                rect.height = size.height;
            } else if (data.size !is null) {
                rect.width = data.size.width;
                rect.height = data.size.height;
            }
        }
        region.add(cast(int)rect.x, cast(int)rect.y, cast(int)rect.width, cast(int)rect.height);
        NSRect* paintRect = data.paintRect;
        if (paintRect !is null) {
            region.intersect(cast(int)paintRect.x, cast(int)paintRect.y, cast(int)paintRect.width, cast(int)paintRect.height);
        }
        if (data.clipPath !is null) {
            NSBezierPath clip = data.clipPath.bezierPathByFlatteningPath();
            NSInteger count = clip.elementCount();
            int pointCount = 0;
            Region clipRgn = new Region(device);
            int[] pointArray = new int[count * 2];
            NSPointArray points = cast(NSPointArray) OS.malloc(NSPoint.sizeof);
            if (points is null) DWT.error(DWT.ERROR_NO_HANDLES);
            NSPoint pt = NSPoint();
            for (NSInteger  i = 0; i < count; i++) {
                NSBezierPathElement element = clip.elementAtIndex(i, points);
                switch (element) {
                    case OS.NSMoveToBezierPathElement:
                        if (pointCount !is 0) clipRgn.add(pointArray, pointCount);
                        pointCount = 0;
                        OS.memmove(&pt, points, NSPoint.sizeof);
                        pointArray[pointCount++] = cast(int)pt.x;
                        pointArray[pointCount++] = cast(int)pt.y;
                        break;
                    case OS.NSLineToBezierPathElement:
                        OS.memmove(&pt, points, NSPoint.sizeof);
                        pointArray[pointCount++] = cast(int)pt.x;
                        pointArray[pointCount++] = cast(int)pt.y;
                        break;
                    case OS.NSClosePathBezierPathElement:
                        if (pointCount !is 0) clipRgn.add(pointArray, pointCount);
                        pointCount = 0;
                        break;
                default:
                }
            }
            if (pointCount !is 0) clipRgn.add(pointArray, pointCount);
            OS.free(points);
            region.intersect(clipRgn);
            clipRgn.dispose();
        }
        if (data.inverseTransform !is null) {
            region.convertRgn(data.inverseTransform);
        }
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Returns the receiver's fill rule, which will be one of
 * <code>DWT.FILL_EVEN_ODD</code> or <code>DWT.FILL_WINDING</code>.
 *
 * @return the receiver's fill rule
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.1
 */
public int getFillRule() {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    return data.fillRule;
}

/**
 * Returns the font currently being used by the receiver
 * to draw and measure text.
 *
 * @return the receiver's font
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Font getFont() {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    return data.font;
}

/**
 * Returns a FontMetrics which contains information
 * about the font currently being used by the receiver
 * to draw and measure text.
 *
 * @return font metrics for the receiver's font
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public FontMetrics getFontMetrics() {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    NSAutoreleasePool pool = checkGC(FONT);
    try {
        NSFont font = data.font.handle;
    	int ascent = cast(int)(0.5f + font.ascender());
    	int descent = cast(int)(0.5f + (-font.descender() + font.leading()));
        String s = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        int averageCharWidth = stringExtent(s).x / s.length();
        return FontMetrics.cocoa_new(ascent, descent, averageCharWidth, 0, ascent + descent);
    } finally {
        uncheckGC(pool);
    }
}

/**
 * Returns the receiver's foreground color.
 *
 * @return the color used for drawing foreground things
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Color getForeground() {
    if (handle is null) DWT.error(DWT.ERROR_WIDGET_DISPOSED);
    return Color.cocoa_new(data.device, data.foreground);
}

/**
 * Returns the foreground pattern. The default value is
 * <code>null</code>.
 *
 * @return the receiver's foreground pattern
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see Pattern
 *
 * @since 3.1
 */
public Pattern getForegroundPattern() {
    if (handle is null) DWT.error(DWT.ERROR_WIDGET_DISPOSED);
    return data.foregroundPattern;
}

/**
 * Returns the GCData.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>GC</code>. It is marked public only so that it
 * can be shared within the packages provided by DWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @return the receiver's GCData
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see GCData
 *
 * @since 3.2
 * @noreference This method is not intended to be referenced by clients.
 */
public GCData getGCData() {
    if (handle is null) DWT.error(DWT.ERROR_WIDGET_DISPOSED);
    return data;
}

/**
 * Returns the receiver's interpolation setting, which will be one of
 * <code>DWT.DEFAULT</code>, <code>DWT.NONE</code>,
 * <code>DWT.LOW</code> or <code>DWT.HIGH</code>.
 *
 * @return the receiver's interpolation setting
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.1
 */
public int getInterpolation() {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    int interpolation = cast(int)/*64*/handle.imageInterpolation();
    switch (interpolation) {
        case OS.NSImageInterpolationDefault: return DWT.DEFAULT;
        case OS.NSImageInterpolationNone: return DWT.NONE;
        case OS.NSImageInterpolationLow: return DWT.LOW;
        case OS.NSImageInterpolationHigh: return DWT.HIGH;
        default:
    }
    return DWT.DEFAULT;
}

/**
 * Returns the receiver's line attributes.
 *
 * @return the line attributes used for drawing lines
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.3
 */
public LineAttributes getLineAttributes() {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    Carbon.CGFloat[] dashes = null;
    if (data.lineDashes !is null) {
        dashes = new Carbon.CGFloat[data.lineDashes.length];
        System.arraycopy(data.lineDashes, 0, dashes, 0, dashes.length);
    }
    return new LineAttributes(data.lineWidth, data.lineCap, data.lineJoin, data.lineStyle, dashes, data.lineDashesOffset, data.lineMiterLimit);
}

/**
 * Returns the receiver's line cap style, which will be one
 * of the constants <code>DWT.CAP_FLAT</code>, <code>DWT.CAP_ROUND</code>,
 * or <code>DWT.CAP_SQUARE</code>.
 *
 * @return the cap style used for drawing lines
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.1
 */
public int getLineCap() {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    return data.lineCap;
}

/**
 * Returns the receiver's line dash style. The default value is
 * <code>null</code>.
 *
 * @return the line dash style used for drawing lines
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.1
 */
public int[] getLineDash() {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (data.lineDashes is null) return null;
    int[] lineDashes = new int[data.lineDashes.length];
    for (int i = 0; i < lineDashes.length; i++) {
        lineDashes[i] = cast(int)data.lineDashes[i];
    }
    return lineDashes;
}

/**
 * Returns the receiver's line join style, which will be one
 * of the constants <code>DWT.JOIN_MITER</code>, <code>DWT.JOIN_ROUND</code>,
 * or <code>DWT.JOIN_BEVEL</code>.
 *
 * @return the join style used for drawing lines
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.1
 */
public int getLineJoin() {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    return data.lineJoin;
}

/**
 * Returns the receiver's line style, which will be one
 * of the constants <code>DWT.LINE_SOLID</code>, <code>DWT.LINE_DASH</code>,
 * <code>DWT.LINE_DOT</code>, <code>DWT.LINE_DASHDOT</code> or
 * <code>DWT.LINE_DASHDOTDOT</code>.
 *
 * @return the style used for drawing lines
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int getLineStyle() {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    return data.lineStyle;
}

/**
 * Returns the width that will be used when drawing lines
 * for all of the figure drawing operations (that is,
 * <code>drawLine</code>, <code>drawRectangle</code>,
 * <code>drawPolyline</code>, and so forth.
 *
 * @return the receiver's line width
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int getLineWidth() {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    return cast(int)data.lineWidth;
}

/**
 * Returns the receiver's style information.
 * <p>
 * Note that the value which is returned by this method <em>may
 * not match</em> the value which was provided to the constructor
 * when the receiver was created. This can occur when the underlying
 * operating system does not support a particular combination of
 * requested styles.
 * </p>
 *
 * @return the style bits
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 2.1.2
 */
public int getStyle () {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    return data.style;
}

/**
 * Returns the receiver's text drawing anti-aliasing setting value,
 * which will be one of <code>DWT.DEFAULT</code>, <code>DWT.OFF</code> or
 * <code>DWT.ON</code>. Note that this controls anti-aliasing
 * <em>only</em> for text drawing operations.
 *
 * @return the anti-aliasing setting
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getAntialias
 *
 * @since 3.1
 */
public int getTextAntialias() {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    return data.textAntialias;
}

/**
 * Sets the parameter to the transform that is currently being
 * used by the receiver.
 *
 * @param transform the destination to copy the transform into
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parameter is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the parameter has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see Transform
 *
 * @since 3.1
 */
public void getTransform (Transform transform) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (transform is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (transform.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    NSAffineTransform cmt = data.transform;
    if (cmt !is null) {
        NSAffineTransformStruct struct_ = cmt.transformStruct();
        transform.handle.setTransformStruct(struct_);
    } else {
        transform.setElements(1, 0, 0, 1, 0, 0);
    }
}

/**
 * Returns <code>true</code> if this GC is drawing in the mode
 * where the resulting color in the destination is the
 * <em>exclusive or</em> of the color values in the source
 * and the destination, and <code>false</code> if it is
 * drawing in the mode where the destination color is being
 * replaced with the source color value.
 *
 * @return <code>true</code> true if the receiver is in XOR mode, and false otherwise
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public bool getXORMode() {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    return data.xorMode;
}

/**
 * Returns an integer hash code for the receiver. Any two
 * objects that return <code>true</code> when passed to
 * <code>equals</code> must return the same value for this
 * method.
 *
 * @return the receiver's hash
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #equals
 */
public hash_t toHash() {
    return handle !is null ? cast(hash_t)handle.id : 0;
}

alias toHash hashCode;

void init_(Drawable drawable, GCData data, objc.id context) {
    if (data.foreground !is null) data.state &= ~(FOREGROUND | FOREGROUND_FILL);
    if (data.background !is null)  data.state &= ~BACKGROUND;
    if (data.font !is null) data.state &= ~FONT;
    data.state &= ~DRAW_OFFSET;

    Image image = data.image;
    if (image !is null) image.memGC = this;
    this.drawable = drawable;
    this.data = data;
    handle = new NSGraphicsContext(context);
    handle.retain();
    handle.saveGraphicsState();
    data.path = NSBezierPath.bezierPath();
    data.path.setWindingRule(data.fillRule is DWT.FILL_WINDING ? OS.NSNonZeroWindingRule : OS.NSEvenOddWindingRule);
    data.path.retain();
}

void initCGContext(void* cgContext) {
    int state = data.state;
    if ((state & LINE_WIDTH) !is 0) {
        OS.CGContextSetLineWidth(cgContext, data.lineWidth is 0 ?  1 : data.lineWidth);
        switch (data.lineStyle) {
            case DWT.LINE_DOT:
            case DWT.LINE_DASH:
            case DWT.LINE_DASHDOT:
            case DWT.LINE_DASHDOTDOT:
                state |= LINE_STYLE;
        }
    }
    if ((state & LINE_STYLE) !is 0) {
        float[] dashes = null;
        float width = data.lineWidth;
        switch (data.lineStyle) {
            case DWT.LINE_SOLID: break;
            case DWT.LINE_DASH: dashes = width !is 0 ? LINE_DASH : LINE_DASH_ZERO; break;
            case DWT.LINE_DOT: dashes = width !is 0 ? LINE_DOT : LINE_DOT_ZERO; break;
            case DWT.LINE_DASHDOT: dashes = width !is 0 ? LINE_DASHDOT : LINE_DASHDOT_ZERO; break;
            case DWT.LINE_DASHDOTDOT: dashes = width !is 0 ? LINE_DASHDOTDOT : LINE_DASHDOTDOT_ZERO; break;
            case DWT.LINE_CUSTOM: dashes = data.lineDashes; break;
        }
        if (dashes !is null) {
            float[] lengths = new float[dashes.length];
            for (int i = 0; i < lengths.length; i++) {
                lengths[i] = width is 0 || data.lineStyle is DWT.LINE_CUSTOM ? dashes[i] : dashes[i] * width;
            }
            OS.CGContextSetLineDash(cgContext, data.lineDashesOffset, lengths, lengths.length);
        } else {
            OS.CGContextSetLineDash(cgContext, 0, null, 0);
        }
    }
    if ((state & LINE_MITERLIMIT) !is 0) {
        OS.CGContextSetMiterLimit(cgContext, data.lineMiterLimit);
    }
    if ((state & LINE_JOIN) !is 0) {
        int joinStyle = 0;
        switch (data.lineJoin) {
            case DWT.JOIN_MITER: joinStyle = OS.kCGLineJoinMiter; break;
            case DWT.JOIN_ROUND: joinStyle = OS.kCGLineJoinRound; break;
            case DWT.JOIN_BEVEL: joinStyle = OS.kCGLineJoinBevel; break;
        }
        OS.CGContextSetLineJoin(cgContext, joinStyle);
    }
    if ((state & LINE_CAP) !is 0) {
        int capStyle = 0;
        switch (data.lineCap) {
            case DWT.CAP_ROUND: capStyle = OS.kCGLineCapRound; break;
            case DWT.CAP_FLAT: capStyle = OS.kCGLineCapButt; break;
            case DWT.CAP_SQUARE: capStyle = OS.kCGLineCapSquare; break;
        }
        OS.CGContextSetLineCap(cgContext, capStyle);
    }
}

/**
 * Returns <code>true</code> if the receiver has a clipping
 * region set into it, and <code>false</code> otherwise.
 * If this method returns false, the receiver will draw on all
 * available space in the destination. If it returns true,
 * it will draw only in the area that is covered by the region
 * that can be accessed with <code>getClipping(region)</code>.
 *
 * @return <code>true</code> if the GC has a clipping region, and <code>false</code> otherwise
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public bool isClipped() {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    return data.clipPath !is null;
}

/**
 * Returns <code>true</code> if the GC has been disposed,
 * and <code>false</code> otherwise.
 * <p>
 * This method gets the dispose state for the GC.
 * When a GC has been disposed, it is an error to
 * invoke any other method using the GC.
 *
 * @return <code>true</code> when the GC is disposed and <code>false</code> otherwise
 */
public bool isDisposed() {
    return handle is null;
}

bool isIdentity(float[] transform) {
    return transform[0] is 1 && transform[1] is 0 && transform[2] is 0
        && transform[3] is 1 && transform[4] is 0 && transform[5] is 0;
}

/**
 * Sets the receiver to always use the operating system's advanced graphics
 * subsystem for all graphics operations if the argument is <code>true</code>.
 * If the argument is <code>false</code>, the advanced graphics subsystem is
 * no longer used, advanced graphics state is cleared and the normal graphics
 * subsystem is used from now on.
 * <p>
 * Normally, the advanced graphics subsystem is invoked automatically when
 * any one of the alpha, antialias, patterns, interpolation, paths, clipping
 * or transformation operations in the receiver is requested.  When the receiver
 * is switched into advanced mode, the advanced graphics subsystem performs both
 * advanced and normal graphics operations.  Because the two subsystems are
 * different, their output may differ.  Switching to advanced graphics before
 * any graphics operations are performed ensures that the output is consistent.
 * </p><p>
 * Advanced graphics may not be installed for the operating system.  In this
 * case, this operation does nothing.  Some operating system have only one
 * graphics subsystem, so switching from normal to advanced graphics does
 * nothing.  However, switching from advanced to normal graphics will always
 * clear the advanced graphics state, even for operating systems that have
 * only one graphics subsystem.
 * </p>
 *
 * @param advanced the new advanced graphics state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #setAlpha
 * @see #setAntialias
 * @see #setBackgroundPattern
 * @see #setClipping(Path)
 * @see #setForegroundPattern
 * @see #setLineAttributes
 * @see #setInterpolation
 * @see #setTextAntialias
 * @see #setTransform
 * @see #getAdvanced
 *
 * @since 3.1
 */
public void setAdvanced(bool advanced) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (!advanced) {
        setAlpha(0xFF);
        setAntialias(DWT.DEFAULT);
        setBackgroundPattern(null);
        setClipping(cast(Rectangle)null);
        setForegroundPattern(null);
        setInterpolation(DWT.DEFAULT);
        setTextAntialias(DWT.DEFAULT);
        setTransform(null);
    }
}

/**
 * Sets the receiver's alpha value which must be
 * between 0 (transparent) and 255 (opaque).
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 * @param alpha the alpha value
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 *
 * @see #getAdvanced
 * @see #setAdvanced
 *
 * @since 3.1
 */
public void setAlpha(int alpha) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    data.alpha = alpha & 0xFF;
    data.state &= ~(BACKGROUND | FOREGROUND | FOREGROUND_FILL);

}

/**
 * Sets the receiver's anti-aliasing value to the parameter,
 * which must be one of <code>DWT.DEFAULT</code>, <code>DWT.OFF</code>
 * or <code>DWT.ON</code>. Note that this controls anti-aliasing for all
 * <em>non-text drawing</em> operations.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 *
 * @param antialias the anti-aliasing setting
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the parameter is not one of <code>DWT.DEFAULT</code>,
 *                                 <code>DWT.OFF</code> or <code>DWT.ON</code></li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 *
 * @see #getAdvanced
 * @see #setAdvanced
 * @see #setTextAntialias
 *
 * @since 3.1
 */
public void setAntialias(int antialias) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    bool mode = true;
    switch (antialias) {
        case DWT.DEFAULT:
            /* Printer is off by default */
            if (!handle.isDrawingToScreen()) mode = false;
            break;
        case DWT.OFF: mode = false; break;
        case DWT.ON: mode = true; break;
        default:
            DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    }
    data.antialias = antialias;
    handle.setShouldAntialias(mode);
}

/**
 * Sets the background color. The background color is used
 * for fill operations and as the background color when text
 * is drawn.
 *
 * @param color the new background color for the receiver
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the color is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the color has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setBackground(Color color) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (color is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (color.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    data.background = color.handle;
    data.backgroundPattern = null;
    if (data.bg !is null) data.bg.release();
    data.bg = null;
    data.state &= ~BACKGROUND;
}

/**
 * Sets the background pattern. The default value is <code>null</code>.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 *
 * @param pattern the new background pattern
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the parameter has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 *
 * @see Pattern
 * @see #getAdvanced
 * @see #setAdvanced
 *
 * @since 3.1
 */
public void setBackgroundPattern(Pattern pattern) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (pattern !is null && pattern.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    if (data.backgroundPattern is pattern) return;
    data.backgroundPattern = pattern;
    data.state &= ~BACKGROUND;
}

/**
 * Sets the area of the receiver which can be changed
 * by drawing operations to the rectangular area specified
 * by the arguments.
 *
 * @param x the x coordinate of the clipping rectangle
 * @param y the y coordinate of the clipping rectangle
 * @param width the width of the clipping rectangle
 * @param height the height of the clipping rectangle
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setClipping(int x, int y, int width, int height) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = (NSAutoreleasePool) new NSAutoreleasePool().alloc().init();
    try {
        if (width < 0) {
            x = x + width;
            width = -width;
        }
        if (height < 0) {
            y = y + height;
            height = -height;
        }
        NSRect rect = NSRect();
        rect.x = x;
        rect.y = y;
        rect.width = width;
        rect.height = height;
        NSBezierPath path = NSBezierPath.bezierPathWithRect(rect);
        path.retain();
        setClipping(path);
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Sets the area of the receiver which can be changed
 * by drawing operations to the path specified
 * by the argument.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 *
 * @param path the clipping path.
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the path has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 *
 * @see Path
 * @see #getAdvanced
 * @see #setAdvanced
 *
 * @since 3.1
 */
public void setClipping(Path path) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (path !is null && path.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = (NSAutoreleasePool) new NSAutoreleasePool().alloc().init();
    try {
        setClipping(new NSBezierPath(path.handle.copy().id));
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Sets the area of the receiver which can be changed
 * by drawing operations to the rectangular area specified
 * by the argument.  Specifying <code>null</code> for the
 * rectangle reverts the receiver's clipping area to its
 * original value.
 *
 * @param rect the clipping rectangle or <code>null</code>
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setClipping(Rectangle rect) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (rect is null) {
        setClipping(cast(NSBezierPath)null);
    } else {
        setClipping(rect.x, rect.y, rect.width, rect.height);
    }
}

/**
 * Sets the area of the receiver which can be changed
 * by drawing operations to the region specified
 * by the argument.  Specifying <code>null</code> for the
 * region reverts the receiver's clipping area to its
 * original value.
 *
 * @param region the clipping region or <code>null</code>
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the region has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setClipping(Region region) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (region !is null && region.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = (NSAutoreleasePool) new NSAutoreleasePool().alloc().init();
    try {
        setClipping(region !is null ? region.getPath() : null);
    } finally {
        if (pool !is null) pool.release();
    }
}

void setClipping(NSBezierPath path) {
    if (data.clipPath !is null) {
        data.clipPath.release();
        data.clipPath = null;
    }
    if (path !is null) {
        data.clipPath = path;
        if (data.transform !is null) {
            data.clipPath.transformUsingAffineTransform(data.transform);
        }
    }
    data.state &= ~CLIPPING;
}

/**
 * Sets the receiver's fill rule to the parameter, which must be one of
 * <code>DWT.FILL_EVEN_ODD</code> or <code>DWT.FILL_WINDING</code>.
 *
 * @param rule the new fill rule
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the rule is not one of <code>DWT.FILL_EVEN_ODD</code>
 *                                 or <code>DWT.FILL_WINDING</code></li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.1
 */
public void setFillRule(int rule) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    switch (rule) {
        case DWT.FILL_WINDING:
        case DWT.FILL_EVEN_ODD: break;
        default:
            DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    }
    data.fillRule = rule;
    data.path.setWindingRule(rule is DWT.FILL_WINDING ? OS.NSNonZeroWindingRule : OS.NSEvenOddWindingRule);
}

/**
 * Sets the font which will be used by the receiver
 * to draw and measure text to the argument. If the
 * argument is null, then a default font appropriate
 * for the platform will be used instead.
 *
 * @param font the new font for the receiver, or null to indicate a default font
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the font has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setFont(Font font) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (font !is null && font.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    data.font = font !is null ? font : data.device.systemFont;
    data.state &= ~FONT;
}

/**
 * Sets the foreground color. The foreground color is used
 * for drawing operations including when text is drawn.
 *
 * @param color the new foreground color for the receiver
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the color is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the color has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setForeground(Color color) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (color is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (color.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    data.foreground = color.handle;
    data.foregroundPattern = null;
    if (data.fg !is null) data.fg.release();
    data.fg = null;
    data.state &= ~(FOREGROUND | FOREGROUND_FILL);
}

/**
 * Sets the foreground pattern. The default value is <code>null</code>.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 * @param pattern the new foreground pattern
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the parameter has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 *
 * @see Pattern
 * @see #getAdvanced
 * @see #setAdvanced
 *
 * @since 3.1
 */
public void setForegroundPattern(Pattern pattern) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (pattern !is null && pattern.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    if (data.foregroundPattern is pattern) return;
    data.foregroundPattern = pattern;
    data.state &= ~(FOREGROUND | FOREGROUND_FILL);
}

/**
 * Sets the receiver's interpolation setting to the parameter, which
 * must be one of <code>DWT.DEFAULT</code>, <code>DWT.NONE</code>,
 * <code>DWT.LOW</code> or <code>DWT.HIGH</code>.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 *
 * @param interpolation the new interpolation setting
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the rule is not one of <code>DWT.DEFAULT</code>,
 *                                 <code>DWT.NONE</code>, <code>DWT.LOW</code> or <code>DWT.HIGH</code>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 *
 * @see #getAdvanced
 * @see #setAdvanced
 *
 * @since 3.1
 */
public void setInterpolation(int interpolation) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    NSImageInterpolation quality = 0;
    switch (interpolation) {
        case DWT.DEFAULT: quality = OS.NSImageInterpolationDefault; break;
        case DWT.NONE: quality = OS.NSImageInterpolationNone; break;
        case DWT.LOW: quality = OS.NSImageInterpolationLow; break;
        case DWT.HIGH: quality = OS.NSImageInterpolationHigh; break;
        default:
            DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    }
    handle.setImageInterpolation(quality);
}

/**
 * Sets the receiver's line attributes.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 * @param attributes the line attributes
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the attributes is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if any of the line attributes is not valid</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 *
 * @see LineAttributes
 * @see #getAdvanced
 * @see #setAdvanced
 *
 * @since 3.3
 */
public void setLineAttributes(LineAttributes attributes) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (attributes is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    int mask = 0;
    Carbon.CGFloat lineWidth = attributes.width;
    if (lineWidth !is data.lineWidth) {
        mask |= LINE_WIDTH | DRAW_OFFSET;
    }
    int lineStyle = attributes.style;
    if (lineStyle !is data.lineStyle) {
        mask |= LINE_STYLE;
        switch (lineStyle) {
            case DWT.LINE_SOLID:
            case DWT.LINE_DASH:
            case DWT.LINE_DOT:
            case DWT.LINE_DASHDOT:
            case DWT.LINE_DASHDOTDOT:
                break;
            case DWT.LINE_CUSTOM:
                if (attributes.dash is null) lineStyle = DWT.LINE_SOLID;
                break;
            default:
                DWT.error(DWT.ERROR_INVALID_ARGUMENT);
        }
    }
    int join = attributes.join;
    if (join !is data.lineJoin) {
        mask |= LINE_JOIN;
        switch (join) {
            case DWT.CAP_ROUND:
            case DWT.CAP_FLAT:
            case DWT.CAP_SQUARE:
                break;
            default:
                DWT.error(DWT.ERROR_INVALID_ARGUMENT);
        }
    }
    int cap = attributes.cap;
    if (cap !is data.lineCap) {
        mask |= LINE_CAP;
        switch (cap) {
            case DWT.JOIN_MITER:
            case DWT.JOIN_ROUND:
            case DWT.JOIN_BEVEL:
                break;
            default:
                DWT.error(DWT.ERROR_INVALID_ARGUMENT);
        }
    }
    Carbon.CGFloat[] dashes = attributes.dash;
    Carbon.CGFloat[] lineDashes = data.lineDashes;
    if (dashes !is null && dashes.length > 0) {
        bool changed = lineDashes is null || lineDashes.length !is dashes.length;
        for (int i = 0; i < dashes.length; i++) {
            float dash = dashes[i];
            if (dash <= 0) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
            if (!changed && lineDashes[i] !is dash) changed = true;
        }
        if (changed) {
            Carbon.CGFloat[] newDashes = new Carbon.CGFloat[dashes.length];
            System.arraycopy(dashes, 0, newDashes, 0, dashes.length);
            dashes = newDashes;
            mask |= LINE_STYLE;
        } else {
            dashes = lineDashes;
        }
    } else {
        if (lineDashes !is null && lineDashes.length > 0) {
            mask |= LINE_STYLE;
        } else {
            dashes = lineDashes;
        }
    }
    Carbon.CGFloat dashOffset = attributes.dashOffset;
    if (dashOffset !is data.lineDashesOffset) {
        mask |= LINE_STYLE;
    }
    float miterLimit = attributes.miterLimit;
    if (miterLimit !is data.lineMiterLimit) {
        mask |= LINE_MITERLIMIT;
    }
    if (mask is 0) return;
    data.lineWidth = lineWidth;
    data.lineStyle = lineStyle;
    data.lineCap = cap;
    data.lineJoin = join;
    data.lineDashes = dashes;
    data.lineDashesOffset = dashOffset;
    data.lineMiterLimit = miterLimit;
    data.state &= ~mask;
}

/**
 * Sets the receiver's line cap style to the argument, which must be one
 * of the constants <code>DWT.CAP_FLAT</code>, <code>DWT.CAP_ROUND</code>,
 * or <code>DWT.CAP_SQUARE</code>.
 *
 * @param cap the cap style to be used for drawing lines
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the style is not valid</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.1
 */
public void setLineCap(int cap) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (data.lineCap is cap) return;
    switch (cap) {
        case DWT.CAP_ROUND:
        case DWT.CAP_FLAT:
        case DWT.CAP_SQUARE:
            break;
        default:
            DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    }
    data.lineCap = cap;
    data.state &= ~LINE_CAP;
}

/**
 * Sets the receiver's line dash style to the argument. The default
 * value is <code>null</code>. If the argument is not <code>null</code>,
 * the receiver's line style is set to <code>DWT.LINE_CUSTOM</code>, otherwise
 * it is set to <code>DWT.LINE_SOLID</code>.
 *
 * @param dashes the dash style to be used for drawing lines
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if any of the values in the array is less than or equal 0</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.1
 */
public void setLineDash(int[] dashes) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    Carbon.CGFloat[] lineDashes = data.lineDashes;
    if (dashes !is null && dashes.length > 0) {
        bool changed = data.lineStyle !is DWT.LINE_CUSTOM || lineDashes is null || lineDashes.length !is dashes.length;
        for (int i = 0; i < dashes.length; i++) {
            int dash = dashes[i];
            if (dash <= 0) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
            if (!changed && lineDashes[i] !is dash) changed = true;
        }
        if (!changed) return;
        data.lineDashes = new Carbon.CGFloat[dashes.length];
        for (int i = 0; i < dashes.length; i++) {
            data.lineDashes[i] = dashes[i];
        }
        data.lineStyle = DWT.LINE_CUSTOM;
    } else {
        if (data.lineStyle is DWT.LINE_SOLID && (lineDashes is null || lineDashes.length is 0)) return;
        data.lineDashes = null;
        data.lineStyle = DWT.LINE_SOLID;
    }
    data.state &= ~LINE_STYLE;
}

/**
 * Sets the receiver's line join style to the argument, which must be one
 * of the constants <code>DWT.JOIN_MITER</code>, <code>DWT.JOIN_ROUND</code>,
 * or <code>DWT.JOIN_BEVEL</code>.
 *
 * @param join the join style to be used for drawing lines
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the style is not valid</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.1
 */
public void setLineJoin(int join) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (data.lineJoin is join) return;
    switch (join) {
        case DWT.JOIN_MITER:
        case DWT.JOIN_ROUND:
        case DWT.JOIN_BEVEL:
            break;
        default:
            DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    }
    data.lineJoin = join;
    data.state &= ~LINE_JOIN;
}

/**
 * Sets the receiver's line style to the argument, which must be one
 * of the constants <code>DWT.LINE_SOLID</code>, <code>DWT.LINE_DASH</code>,
 * <code>DWT.LINE_DOT</code>, <code>DWT.LINE_DASHDOT</code> or
 * <code>DWT.LINE_DASHDOTDOT</code>.
 *
 * @param lineStyle the style to be used for drawing lines
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the style is not valid</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setLineStyle(int lineStyle) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (data.lineStyle is lineStyle) return;
    switch (lineStyle) {
        case DWT.LINE_SOLID:
        case DWT.LINE_DASH:
        case DWT.LINE_DOT:
        case DWT.LINE_DASHDOT:
        case DWT.LINE_DASHDOTDOT:
            break;
        case DWT.LINE_CUSTOM:
            if (data.lineDashes is null) lineStyle = DWT.LINE_SOLID;
            break;
        default:
            DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    }
    data.lineStyle = lineStyle;
    data.state &= ~LINE_STYLE;
}

/**
 * Sets the width that will be used when drawing lines
 * for all of the figure drawing operations (that is,
 * <code>drawLine</code>, <code>drawRectangle</code>,
 * <code>drawPolyline</code>, and so forth.
 * <p>
 * Note that line width of zero is used as a hint to
 * indicate that the fastest possible line drawing
 * algorithms should be used. This means that the
 * output may be different from line width one.
 * </p>
 *
 * @param lineWidth the width of a line
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setLineWidth(int lineWidth) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (data.lineWidth is lineWidth) return;
    data.lineWidth = lineWidth;
    data.state &= ~(LINE_WIDTH | DRAW_OFFSET);
}

/**
 * If the argument is <code>true</code>, puts the receiver
 * in a drawing mode where the resulting color in the destination
 * is the <em>exclusive or</em> of the color values in the source
 * and the destination, and if the argument is <code>false</code>,
 * puts the receiver in a drawing mode where the destination color
 * is replaced with the source color value.
 * <p>
 * Note that this mode in fundamentally unsupportable on certain
 * platforms, notably Carbon (Mac OS X). Clients that want their
 * code to run on all platforms need to avoid this method.
 * </p>
 *
 * @param xor if <code>true</code>, then <em>xor</em> mode is used, otherwise <em>source copy</em> mode is used
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @deprecated this functionality is not supported on some platforms
 */
public void setXORMode(bool xor) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    data.xorMode = xor;
}

/**
 * Sets the receiver's text anti-aliasing value to the parameter,
 * which must be one of <code>DWT.DEFAULT</code>, <code>DWT.OFF</code>
 * or <code>DWT.ON</code>. Note that this controls anti-aliasing only
 * for all <em>text drawing</em> operations.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 *
 * @param antialias the anti-aliasing setting
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the parameter is not one of <code>DWT.DEFAULT</code>,
 *                                 <code>DWT.OFF</code> or <code>DWT.ON</code></li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 *
 * @see #getAdvanced
 * @see #setAdvanced
 * @see #setAntialias
 *
 * @since 3.1
 */
public void setTextAntialias(int antialias) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    switch (antialias) {
        case DWT.DEFAULT:
        case DWT.OFF:
        case DWT.ON:
            break;
        default:
            DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    }
    data.textAntialias = antialias;
}

/**
 * Sets the transform that is currently being used by the receiver. If
 * the argument is <code>null</code>, the current transform is set to
 * the identity transform.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 *
 * @param transform the transform to set
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the parameter has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 *
 * @see Transform
 * @see #getAdvanced
 * @see #setAdvanced
 *
 * @since 3.1
 */
public void setTransform(Transform transform) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (transform !is null && transform.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    if (transform !is null) {
        if (data.transform !is null) data.transform.release();
        if (data.inverseTransform !is null) data.inverseTransform.release();
        data.transform = (cast(NSAffineTransform)(new NSAffineTransform()).alloc()).initWithTransform(transform.handle);
        data.inverseTransform = (cast(NSAffineTransform)(new NSAffineTransform()).alloc()).initWithTransform(transform.handle);
        NSAffineTransformStruct struct_ = data.inverseTransform.transformStruct();
        if ((struct_.m11 * struct_.m22 - struct_.m12 * struct_.m21) !is 0) {
            data.inverseTransform.invert();
        }
    } else {
        data.transform = data.inverseTransform = null;
    }
    data.state &= ~(TRANSFORM | DRAW_OFFSET);
}

/**
 * Returns the extent of the given string. No tab
 * expansion or carriage return processing will be performed.
 * <p>
 * The <em>extent</em> of a string is the width and height of
 * the rectangular area it would cover if drawn in a particular
 * font (in this case, the current font in the receiver).
 * </p>
 *
 * @param string the string to measure
 * @return a point containing the extent of the string
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the string is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Point stringExtent(String string) {
    return textExtent(string, 0);
}

/**
 * Returns the extent of the given string. Tab expansion and
 * carriage return processing are performed.
 * <p>
 * The <em>extent</em> of a string is the width and height of
 * the rectangular area it would cover if drawn in a particular
 * font (in this case, the current font in the receiver).
 * </p>
 *
 * @param string the string to measure
 * @return a point containing the extent of the string
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the string is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Point textExtent(String string) {
    return textExtent(string, DWT.DRAW_DELIMITER | DWT.DRAW_TAB);
}

/**
 * Returns the extent of the given string. Tab expansion, line
 * delimiter and mnemonic processing are performed according to
 * the specified flags, which can be a combination of:
 * <dl>
 * <dt><b>DRAW_DELIMITER</b></dt>
 * <dd>draw multiple lines</dd>
 * <dt><b>DRAW_TAB</b></dt>
 * <dd>expand tabs</dd>
 * <dt><b>DRAW_MNEMONIC</b></dt>
 * <dd>underline the mnemonic character</dd>
 * <dt><b>DRAW_TRANSPARENT</b></dt>
 * <dd>transparent background</dd>
 * </dl>
 * <p>
 * The <em>extent</em> of a string is the width and height of
 * the rectangular area it would cover if drawn in a particular
 * font (in this case, the current font in the receiver).
 * </p>
 *
 * @param string the string to measure
 * @param flags the flags specifying how to process the text
 * @return a point containing the extent of the string
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the string is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Point textExtent(String string, int flags) {
    if (handle is null) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (string is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    NSAutoreleasePool pool = checkGC(FONT);
    try {
        NSAttributedString str = createString(string, flags, false);
        NSSize size = str.size();
        str.release();
    	return new Point(cast(int)size.width, cast(int)size.height);
    } finally {
        uncheckGC(pool);
    }
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the receiver
 */
public String toString () {
	if (isDisposed()) return "GC {*DISPOSED*}";
	return Format("{}{}{}", "GC {" , handle , "}");
}

void uncheckGC(NSAutoreleasePool pool) {
    if (data.flippedContext !is null && data.restoreContext) {
        NSGraphicsContext.static_restoreGraphicsState();
        data.restoreContext = false;
    }
    NSView view = data.view;
    if (view !is null && data.paintRect is null) {
        if (data.thread !is Thread.getThis()) flush();
    }
    if (pool !is null) pool.release();
}

}
