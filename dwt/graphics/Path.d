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
module dwt.graphics.Path;


import dwt.*;
import dwt.internal.cocoa.*;

import tango.text.convert.Format;

import dwt.dwthelper.utils;
import dwt.graphics.Device;
import dwt.graphics.Font;
import dwt.graphics.GC;
import dwt.graphics.GCData;
import dwt.graphics.PathData;
import dwt.graphics.Resource;
import dwt.internal.c.Carbon;
import dwt.internal.cocoa.NSFont : NSGlyph;
import dwt.internal.objc.cocoa.Cocoa;

/**
 * Instances of this class represent paths through the two-dimensional
 * coordinate system. Paths do not have to be continuous, and can be
 * described using lines, rectangles, arcs, cubic or quadratic bezier curves,
 * glyphs, or other paths.
 * <p>
 * Application code must explicitly invoke the <code>Path.dispose()</code>
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
public class Path : Resource {

    alias Resource.init_ init_;

    /**
     * the OS resource for the Path
     * (Warning: This field is platform dependent)
     * <p>
     * <b>IMPORTANT:</b> This field is <em>not</em> part of the DWT
     * public API. It is marked public only so that it can be shared
     * within the packages provided by DWT. It is not available on all
     * platforms and should never be accessed from application code.
     * </p>
     */
    public NSBezierPath handle;

/**
 * Constructs a new empty Path.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 *
 * @param device the device on which to allocate the path
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the device is null and there is no current device</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 * @exception DWTError <ul>
 *    <li>ERROR_NO_HANDLES if a handle for the path could not be obtained</li>
 * </ul>
 *
 * @see #dispose()
 */
public this (Device device) {
    super(device);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        handle = NSBezierPath.bezierPath();
        if (handle is null) DWT.error(DWT.ERROR_NO_HANDLES);
        handle.retain();
    handle.moveToPoint(NSPoint());
    init_();
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Constructs a new Path that is a copy of <code>path</code>. If
 * <code>flatness</code> is less than or equal to zero, an unflatten
 * copy of the path is created. Otherwise, it specifies the maximum
 * error between the path and its flatten copy. Smaller numbers give
 * better approximation.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 *
 * @param device the device on which to allocate the path
 * @param path the path to make a copy
 * @param flatness the flatness value
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the device is null and there is no current device</li>
 *    <li>ERROR_NULL_ARGUMENT - if the path is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the path has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 * @exception DWTError <ul>
 *    <li>ERROR_NO_HANDLES if a handle for the path could not be obtained</li>
 * </ul>
 *
 * @see #dispose()
 * @since 3.4
 */
public this (Device device, Path path, float flatness) {
    super(device);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        if (path is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
        if (path.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
        flatness = Math.max(0, flatness);
        if (flatness is 0) {
        handle = new NSBezierPath(path.handle.copy().id);
        } else {
            CGFloat defaultFlatness = NSBezierPath.defaultFlatness();
            NSBezierPath.setDefaultFlatness(flatness);
            handle = path.handle.bezierPathByFlatteningPath();
            handle.retain();
            NSBezierPath.setDefaultFlatness(defaultFlatness);
        }
        if (handle is null) DWT.error(DWT.ERROR_NO_HANDLES);
    init_();
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Constructs a new Path with the specifed PathData.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 *
 * @param device the device on which to allocate the path
 * @param data the data for the path
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the device is null and there is no current device</li>
 *    <li>ERROR_NULL_ARGUMENT - if the data is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 * @exception DWTError <ul>
 *    <li>ERROR_NO_HANDLES if a handle for the path could not be obtained</li>
 * </ul>
 *
 * @see #dispose()
 * @since 3.4
 */
public this (Device device, PathData data) {
    this(device);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        if (data is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    init_(data);
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Adds to the receiver a circular or elliptical arc that lies within
 * the specified rectangular area.
 * <p>
 * The resulting arc begins at <code>startAngle</code> and extends
 * for <code>arcAngle</code> degrees.
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
 * @param x the x coordinate of the upper-left corner of the arc
 * @param y the y coordinate of the upper-left corner of the arc
 * @param width the width of the arc
 * @param height the height of the arc
 * @param startAngle the beginning angle
 * @param arcAngle the angular extent of the arc, relative to the start angle
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void addArc(float x, float y, float width, float height, float startAngle, float arcAngle) {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        NSAffineTransform transform = NSAffineTransform.transform();
        transform.translateXBy(x + width / 2f, y + height / 2f);
        transform.scaleXBy(width / 2f, height / 2f);
        NSBezierPath path = NSBezierPath.bezierPath();
    NSPoint center = NSPoint();
    CGFloat sAngle = -startAngle;
    CGFloat eAngle = -(startAngle + arcAngle);
        path.appendBezierPathWithArcWithCenter(center, 1, sAngle,  eAngle, arcAngle>0);
        path.transformUsingAffineTransform(transform);
        handle.appendBezierPath(path);
        if (Math.abs(arcAngle) >= 360) handle.closePath();
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Adds to the receiver the path described by the parameter.
 *
 * @param path the path to add to the receiver
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parameter is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the parameter has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void addPath(Path path) {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (path is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (path.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        handle.appendBezierPath(path.handle);
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Adds to the receiver the rectangle specified by x, y, width and height.
 *
 * @param x the x coordinate of the rectangle to add
 * @param y the y coordinate of the rectangle to add
 * @param width the width of the rectangle to add
 * @param height the height of the rectangle to add
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void addRectangle(float x, float y, float width, float height) {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    NSRect rect = NSRect();
    rect.x = x;
    rect.y = y;
    rect.width = width;
    rect.height = height;
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        handle.appendBezierPathWithRect(rect);
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Adds to the receiver the pattern of glyphs generated by drawing
 * the given string using the given font starting at the point (x, y).
 *
 * @param stri the text to use
 * @param x the x coordinate of the starting point
 * @param y the y coordinate of the starting point
 * @param font the font to use
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the font is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the font has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void addString(String stri, float x, float y, Font font) {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (font is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (font.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        NSString str = NSString.stringWith(stri);
        NSTextStorage textStorage = (NSTextStorage)new NSTextStorage().alloc().init();
    NSLayoutManager layoutManager = cast(NSLayoutManager)(new NSLayoutManager()).alloc().init();
    NSTextContainer textContainer = cast(NSTextContainer)(new NSTextContainer()).alloc();
    NSSize size = NSSize();
    size.width = CGFloat.max; //Float.MAX_VALUE;
    size.height = CGFloat.max; //Float.MAX_VALUE;
        textContainer.initWithContainerSize(size);
        textStorage.addLayoutManager(layoutManager);
        layoutManager.addTextContainer(textContainer);
    NSRange range = NSRange();
        range.length = str.length();
        /*
        * Feature in Cocoa. Adding attributes directly to a NSTextStorage causes
        * output to the console and eventually a segmentation fault when printing
        * on a thread other than the main thread. The fix is to add attributes to
        * a separate NSMutableAttributedString and add it to text storage when done.
        */
        NSMutableAttributedString attrStr = (NSMutableAttributedString)new NSMutableAttributedString().alloc();
        attrStr.id = attrStr.initWithString(str).id;
        attrStr.beginEditing();
        attrStr.addAttribute(OS.NSFontAttributeName, font.handle, range);
        font.addTraits(attrStr, range);
        attrStr.endEditing();
        textStorage.setAttributedString(attrStr);
        attrStr.release();
        range = layoutManager.glyphRangeForTextContainer(textContainer);
        if (range.length !is 0) {
        NSGlyph* glyphs = cast(NSGlyph*) OS.malloc(4 * range.length * 2);
            layoutManager.getGlyphs(glyphs, range);
            NSBezierPath path = NSBezierPath.bezierPath();
        NSPoint point = NSPoint();
            path.moveToPoint(point);
            path.appendBezierPathWithGlyphs(glyphs, range.length, font.handle);
            NSAffineTransform transform = NSAffineTransform.transform();
            transform.scaleXBy(1, -1);
            float /*double*/ baseline = layoutManager.defaultBaselineOffsetForFont(font.handle);
            transform.translateXBy(x, -(y + baseline));
            path.transformUsingAffineTransform(transform);
            OS.free(glyphs);
            handle.appendBezierPath(path);
        }
        textContainer.release();
        layoutManager.release();
        textStorage.release();
    } finally  {
        if (pool !is null) pool.release();
    }
}

/**
 * Closes the current sub path by adding to the receiver a line
 * from the current point of the path back to the starting point
 * of the sub path.
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void close() {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        handle.closePath();
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Returns <code>true</code> if the specified point is contained by
 * the receiver and false otherwise.
 * <p>
 * If outline is <code>true</code>, the point (x, y) checked for containment in
 * the receiver's outline. If outline is <code>false</code>, the point is
 * checked to see if it is contained within the bounds of the (closed) area
 * covered by the receiver.
 *
 * @param x the x coordinate of the point to test for containment
 * @param y the y coordinate of the point to test for containment
 * @param gc the GC to use when testing for containment
 * @param outline controls whether to check the outline or contained area of the path
 * @return <code>true</code> if the path contains the point and <code>false</code> otherwise
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the gc is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the gc has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public bool contains(float x, float y, GC gc, bool outline) {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (gc is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (gc.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        //TODO - see windows
        if (outline) {
            int /*long*/ pixel = OS.malloc(4);
            if (pixel is 0) DWT.error(DWT.ERROR_NO_HANDLES);
            int[] buffer = new int[]{0xFFFFFFFF};
            OS.memmove(pixel, buffer, 4);
            int /*long*/ colorspace = OS.CGColorSpaceCreateDeviceRGB();
            int /*long*/ context = OS.CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorspace, OS.kCGImageAlphaNoneSkipFirst);
            OS.CGColorSpaceRelease(colorspace);
            if (context is 0) {
                OS.free(pixel);
                DWT.error(DWT.ERROR_NO_HANDLES);
            }
            GCData data = gc.data;
            int capStyle = 0;
            switch (data.lineCap) {
                case DWT.CAP_ROUND: capStyle = OS.kCGLineCapRound; break;
                case DWT.CAP_FLAT: capStyle = OS.kCGLineCapButt; break;
                case DWT.CAP_SQUARE: capStyle = OS.kCGLineCapSquare; break;
            }
            OS.CGContextSetLineCap(context, capStyle);
            int joinStyle = 0;
            switch (data.lineJoin) {
                case DWT.JOIN_MITER: joinStyle = OS.kCGLineJoinMiter; break;
                case DWT.JOIN_ROUND: joinStyle = OS.kCGLineJoinRound; break;
                case DWT.JOIN_BEVEL: joinStyle = OS.kCGLineJoinBevel; break;
            }
            OS.CGContextSetLineJoin(context, joinStyle);
            OS.CGContextSetLineWidth(context, data.lineWidth);
            OS.CGContextTranslateCTM(context, -x + 0.5f, -y + 0.5f);
            int /*long*/ path = GC.createCGPathRef(handle);
            OS.CGContextAddPath(context, path);
            OS.CGPathRelease(path);
            OS.CGContextStrokePath(context);
            OS.CGContextRelease(context);
            OS.memmove(buffer, pixel, 4);
            OS.free(pixel);
            return buffer[0] !is 0xFFFFFFFF;
        } else {
            NSPoint point = NSPoint();
            point.x = x;
            point.y = y;
            return handle.containsPoint(point);
        }
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Adds to the receiver a cubic bezier curve based on the parameters.
 *
 * @param cx1 the x coordinate of the first control point of the spline
 * @param cy1 the y coordinate of the first control of the spline
 * @param cx2 the x coordinate of the second control of the spline
 * @param cy2 the y coordinate of the second control of the spline
 * @param x the x coordinate of the end point of the spline
 * @param y the y coordinate of the end point of the spline
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void cubicTo(float cx1, float cy1, float cx2, float cy2, float x, float y) {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        NSPoint pt = NSPoint();
        pt.x = x;
        pt.y = y;
    NSPoint ct1 = NSPoint();
        ct1.x = cx1;
        ct1.y = cy1;
    NSPoint ct2 = NSPoint();
        ct2.x = cx2;
        ct2.y = cy2;
        handle.curveToPoint(pt, ct1, ct2);
    } finally {
        if (pool !is null) pool.release();
    }
}

void destroy() {
    handle.release();
    handle = null;
}

/**
 * Replaces the first four elements in the parameter with values that
 * describe the smallest rectangle that will completely contain the
 * receiver (i.e. the bounding box).
 *
 * @param bounds the array to hold the result
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parameter is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the parameter is too small to hold the bounding box</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void getBounds(float[] bounds) {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (bounds is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (bounds.length < 4) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        NSRect rect = handle.controlPointBounds();
        bounds[0] = cast(float)/*64*/rect.x;
        bounds[1] = cast(float)/*64*/rect.y;
        bounds[2] = cast(float)/*64*/rect.width;
        bounds[3] = cast(float)/*64*/rect.height;
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Replaces the first two elements in the parameter with values that
 * describe the current point of the path.
 *
 * @param point the array to hold the result
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parameter is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the parameter is too small to hold the end point</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void getCurrentPoint(float[] point) {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (point is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (point.length < 2) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        NSPoint pt = handle.currentPoint();
        point[0] = cast(float)/*64*/pt.x;
        point[1] = cast(float)/*64*/pt.y;
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Returns a device independent representation of the receiver.
 *
 * @return the PathData for the receiver
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see PathData
 */
public PathData getPathData() {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        int count = cast(int)/*64*/handle.elementCount();
        int pointCount = 0, typeCount = 0;
        byte[] types = new byte[count];
        float[] pointArray = new float[count * 6];
    NSPointArray points = cast(NSPointArray) OS.malloc(3 * NSPoint.sizeof);
    if (points is null) DWT.error(DWT.ERROR_NO_HANDLES);
    NSPoint pt = NSPoint();
    for (NSInteger i = 0; i < count; i++) {
        NSBezierPathElement element = handle.elementAtIndex(i, points);
            switch (element) {
            case OS.NSMoveToBezierPathElement:
                    types[typeCount++] = DWT.PATH_MOVE_TO;
                OS.memmove(&pt, points, NSPoint.sizeof);
                pointArray[pointCount++] = cast(int)pt.x;
                pointArray[pointCount++] = cast(int)pt.y;
                    break;
            case OS.NSLineToBezierPathElement:
                    types[typeCount++] = DWT.PATH_LINE_TO;
                OS.memmove(&pt, points, NSPoint.sizeof);
                pointArray[pointCount++] = cast(int)pt.x;
                pointArray[pointCount++] = cast(int)pt.y;
                    break;
            case OS.NSCurveToBezierPathElement:
                    types[typeCount++] = DWT.PATH_CUBIC_TO;
                OS.memmove(&pt, points, NSPoint.sizeof);
                pointArray[pointCount++] = cast(int)pt.x;
                pointArray[pointCount++] = cast(int)pt.y;
                OS.memmove(&pt, points + NSPoint.sizeof, NSPoint.sizeof);
                pointArray[pointCount++] = cast(int)pt.x;
                pointArray[pointCount++] = cast(int)pt.y;
                OS.memmove(&pt, points + NSPoint.sizeof + NSPoint.sizeof, NSPoint.sizeof);
                pointArray[pointCount++] = cast(int)pt.x;
                pointArray[pointCount++] = cast(int)pt.y;
                    break;
            case OS.NSClosePathBezierPathElement:
                    types[typeCount++] = DWT.PATH_CLOSE;
                    break;
            default:
            }
        }
        OS.free(points);
        if (pointCount !is pointArray.length) {
            float[] temp = new float[pointCount];
            System.arraycopy(pointArray, 0, temp, 0, pointCount);
            pointArray = temp;
        }
        PathData data = new PathData();
        data.types = types;
        data.points = pointArray;
        return data;
    } finally {
        if (pool !is null)  pool.release();
    }
}

void init_(PathData data) {
    byte[] types = data.types;
    float[] points = data.points;
    for (int i = 0, j = 0; i < types.length; i++) {
        switch (types[i]) {
            case DWT.PATH_MOVE_TO:
                moveTo(points[j++], points[j++]);
                break;
            case DWT.PATH_LINE_TO:
                lineTo(points[j++], points[j++]);
                break;
            case DWT.PATH_CUBIC_TO:
                cubicTo(points[j++], points[j++], points[j++], points[j++], points[j++], points[j++]);
                break;
            case DWT.PATH_QUAD_TO:
                quadTo(points[j++], points[j++], points[j++], points[j++]);
                break;
            case DWT.PATH_CLOSE:
                close();
                break;
            default:
                dispose();
                DWT.error(DWT.ERROR_INVALID_ARGUMENT);
        }
    }
}

/**
 * Returns <code>true</code> if the Path has been disposed,
 * and <code>false</code> otherwise.
 * <p>
 * This method gets the dispose state for the Path.
 * When a Path has been disposed, it is an error to
 * invoke any other method using the Path.
 *
 * @return <code>true</code> when the Path is disposed, and <code>false</code> otherwise
 */
public bool isDisposed() {
    return handle is null;
}

/**
 * Adds to the receiver a line from the current point to
 * the point specified by (x, y).
 *
 * @param x the x coordinate of the end of the line to add
 * @param y the y coordinate of the end of the line to add
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void lineTo(float x, float y) {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        NSPoint pt = NSPoint();
        pt.x = x;
        pt.y = y;
        handle.lineToPoint(pt);
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Sets the current point of the receiver to the point
 * specified by (x, y). Note that this starts a new
 * sub path.
 *
 * @param x the x coordinate of the new end point
 * @param y the y coordinate of the new end point
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void moveTo(float x, float y) {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        NSPoint pt = NSPoint();
        pt.x = x;
        pt.y = y;
        handle.moveToPoint(pt);
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Adds to the receiver a quadratic curve based on the parameters.
 *
 * @param cx the x coordinate of the control point of the spline
 * @param cy the y coordinate of the control point of the spline
 * @param x the x coordinate of the end point of the spline
 * @param y the y coordinate of the end point of the spline
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void quadTo(float cx, float cy, float x, float y) {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        NSPoint pt = NSPoint();
        pt.x = x;
        pt.y = y;
    NSPoint ct = NSPoint();
        ct.x = cx;
        ct.y = cy;
        handle.curveToPoint(pt, ct, ct);
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the receiver
 */
public String toString () {
    if (isDisposed()) return "Path {*DISPOSED*}";
    return Format("Path {{}{}" , handle , "}");
}

}
