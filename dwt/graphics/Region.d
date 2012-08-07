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
module dwt.graphics.Region;


import dwt.internal.*;
import dwt.internal.cocoa.*;
import dwt.*;

import tango.text.convert.Format;

import dwt.dwthelper.utils;
import dwt.graphics.Device;
import dwt.graphics.Point;
import dwt.graphics.Rectangle;
import dwt.graphics.Resource;
import Carbon = dwt.internal.c.Carbon;
import objc = dwt.internal.objc.runtime;

/**
 * Instances of this class represent areas of an x-y coordinate
 * system that are aggregates of the areas covered by a number
 * of polygons.
 * <p>
 * Application code must explicitly invoke the <code>Region.dispose()</code> 
 * method to release the operating system resources managed by each instance
 * when those instances are no longer required.
 * </p>
 * 
 * @see <a href="http://www.eclipse.org/swt/examples.php">DWT Example: GraphicsExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public final class Region : Resource {

    alias Resource.init_ init_;
    
    /**
     * the OS resource for the region
     * (Warning: This field is platform dependent)
     * <p>
     * <b>IMPORTANT:</b> This field is <em>not</em> part of the DWT
     * public API. It is marked public only so that it can be shared
     * within the packages provided by DWT. It is not available on all
     * platforms and should never be accessed from application code.
     * </p>
     */
    public Carbon.RgnHandle handle;

/**
 * Constructs a new empty region.
 * 
 * @exception DWTError <ul>
 *    <li>ERROR_NO_HANDLES if a handle could not be obtained for region creation</li>
 * </ul>
 */
public this() {
    this(null);
}

/**
 * Constructs a new empty region.
 * <p>
 * You must dispose the region when it is no longer required. 
 * </p>
 *
 * @param device the device on which to allocate the region
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if device is null and there is no current device</li>
 * </ul>
 * @exception DWTError <ul>
 *    <li>ERROR_NO_HANDLES if a handle could not be obtained for region creation</li>
 * </ul>
 *
 * @see #dispose
 * 
 * @since 3.0
 */
public this(Device device) {
    super(device);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        handle = OS.NewRgn();
    if (handle is null) DWT.error(DWT.ERROR_NO_HANDLES);
    init_();
    } finally {
        if (pool !is null) pool.release();
    }
}

this(Device device, Carbon.RgnHandle handle) {
    super(device);
    this.handle = handle;
}

public static Region cocoa_new(Device device, Carbon.RgnHandle handle) {
    return new Region(device, handle);
}

static Carbon.RgnHandle polyToRgn(int[] poly, int length) {
    Carbon.Rect r;
    Carbon.RgnHandle polyRgn = OS.NewRgn(), rectRgn = OS.NewRgn();
    int minY = poly[1], maxY = poly[1];
    for (int y = 3; y < length; y += 2) {
        if (poly[y] < minY) minY = poly[y];
        if (poly[y] > maxY) maxY = poly[y];
    }
    int[] inter = new int[length + 1];
    for (int y = minY; y <= maxY; y++) {
        int count = 0;
        int x1 = poly[0], y1 = poly[1];
        for (int p = 2; p < length; p += 2) {
            int x2 = poly[p], y2 = poly[p + 1];
            if (y1 !is y2 && ((y1 <= y && y < y2) || (y2 <= y && y < y1))) {
                inter[count++] = cast(int)((((y - y1) / cast(float)(y2 - y1)) * (x2 - x1)) + x1 + 0.5f);
            }
            x1 = x2;
            y1 = y2;
        }
        int x2 = poly[0], y2 = poly[1];         
        if (y1 !is y2 && ((y1 <= y && y < y2) || (y2 <= y && y < y1))) {
            inter[count++] = cast(int)((((y - y1) / cast(float)(y2 - y1)) * (x2 - x1)) + x1 + 0.5f);
        }
        for (int gap=count/2; gap>0; gap/=2) {
            for (int i=gap; i<count; i++) {
                for (int j=i-gap; j>=0; j-=gap) {
                    if ((inter[j] - inter[j + gap]) <= 0)
                        break;
                    int temp = inter[j];
                    inter[j] = inter[j + gap];
                    inter[j + gap] = temp;
                }
            }
        }
        for (int i = 0; i < count; i += 2) {
            OS.SetRect(&r, cast(short)inter[i], cast(short)y, cast(short)(inter[i + 1]), cast(short)(y + 1));
            OS.RectRgn(rectRgn, &r);
            OS.UnionRgn(polyRgn, rectRgn, polyRgn);
        }
    }
    OS.DisposeRgn(rectRgn);
    return polyRgn;
}

static Carbon.RgnHandle polyRgn(int[] pointArray, int count) {
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        Carbon.RgnHandle polyRgn;
        if (C.PTR_SIZEOF is 4) {
            polyRgn = OS.NewRgn();
            OS.OpenRgn();
            OS.MoveTo(cast(short)pointArray[0], cast(short)pointArray[1]);
            for (int i = 1; i < count / 2; i++) {
                OS.LineTo(cast(short)pointArray[2 * i], cast(short)pointArray[2 * i + 1]);
            }
            OS.LineTo(cast(short)pointArray[0], cast(short)pointArray[1]);
            OS.CloseRgn(polyRgn);
        } else {
            polyRgn = polyToRgn(pointArray, count);
        }
        return polyRgn;
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Adds the given polygon to the collection of polygons
 * the receiver maintains to describe its area.
 *
 * @param pointArray points that describe the polygon to merge with the receiver
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the argument is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.0
*
 */
public void add (int[] pointArray) {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (pointArray is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        add(pointArray, pointArray.length);
    } finally {
        if (pool !is null) pool.release();
    }
}
    
void add(int[] pointArray, int count) {
    if (count <= 2) return;
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        Carbon.RgnHandle polyRgn = polyRgn(pointArray, count);
        OS.UnionRgn(handle, polyRgn, handle);
        OS.DisposeRgn(polyRgn);
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Adds the given rectangle to the collection of polygons
 * the receiver maintains to describe its area.
 *
 * @param rect the rectangle to merge with the receiver
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the argument is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the rectangle's width or height is negative</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void add(Rectangle rect) {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (rect is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (rect.width < 0 || rect.height < 0) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        add (rect.x, rect.y, rect.width, rect.height);
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Adds the given rectangle to the collection of polygons
 * the receiver maintains to describe its area.
 *
 * @param x the x coordinate of the rectangle
 * @param y the y coordinate of the rectangle
 * @param width the width coordinate of the rectangle
 * @param height the height coordinate of the rectangle
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the rectangle's width or height is negative</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 * 
 * @since 3.1
 */
public void add(int x, int y, int width, int height) {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (width < 0 || height < 0) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        Carbon.RgnHandle rectRgn = OS.NewRgn();
        Carbon.Rect r;
        OS.SetRect(&r, cast(short)x, cast(short)y, cast(short)(x + width),cast(short)(y + height));
        OS.RectRgn(rectRgn, &r);
        OS.UnionRgn(handle, rectRgn, handle);
        OS.DisposeRgn(rectRgn);
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Adds all of the polygons which make up the area covered
 * by the argument to the collection of polygons the receiver
 * maintains to describe its area.
 *
 * @param region the region to merge
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the argument is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void add(Region region) {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (region is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (region.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        OS.UnionRgn(handle, region.handle, handle);
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Returns <code>true</code> if the point specified by the
 * arguments is inside the area specified by the receiver,
 * and <code>false</code> otherwise.
 *
 * @param x the x coordinate of the point to test for containment
 * @param y the y coordinate of the point to test for containment
 * @return <code>true</code> if the region contains the point and <code>false</code> otherwise
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public bool contains(int x, int y) {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        Carbon.Point point = {cast(short)x, cast(short)y};
        return OS.PtInRgn(point, handle);
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Returns <code>true</code> if the given point is inside the
 * area specified by the receiver, and <code>false</code>
 * otherwise.
 *
 * @param pt the point to test for containment
 * @return <code>true</code> if the region contains the point and <code>false</code> otherwise
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the argument is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public bool contains(Point pt) {
    if (pt is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    return contains(pt.x, pt.y);
}

static NSAffineTransform transform;
void convertRgn(NSAffineTransform transform) {
    Carbon.RgnHandle newRgn = OS.NewRgn();
    Carbon.RegionToRectsUPP proc = &Region.convertRgn_;
    this.transform = transform;
    OS.QDRegionToRects(handle, OS.kQDParseRegionFromTopLeft, proc, newRgn);
    this.transform = null;
    OS.CopyRgn(newRgn, handle);
    OS.DisposeRgn(newRgn);
}

extern(C) private static Carbon.OSStatus convertRgn_(ushort message, Carbon.RgnHandle rgn, Carbon.Rect* r, void* newRgn) {
    if (message is OS.kQDRegionToRectsMsgParse) {
        Carbon.Rect rect;
        OS.memmove(&rect, r, rect.sizeof);
        int i = 0;
        NSPoint point = NSPoint();
        int[] points = new int[10];
        point.x = rect.left;
        point.y = rect.top;
        point = transform.transformPoint(point);
        short startX, startY;
        points[i++] = startX = cast(short)point.x;
        points[i++] = startY = cast(short)point.y;
        point.y = rect.top;
        point = transform.transformPoint(point);
        points[i++] = cast(short)Math.round(point.x);
        points[i++] = cast(short)point.y;
        point.y = rect.bottom;
        point = transform.transformPoint(point);
        points[i++] = cast(short)Math.round(point.x);
        points[i++] = cast(short)Math.round(point.y);
        point.y = rect.bottom;
        point = transform.transformPoint(point);
        points[i++] = cast(short)point.x;
        points[i++] = cast(short)Math.round(point.y);
        points[i++] = startX;
        points[i++] = startY;
        Carbon.RgnHandle polyRgn = polyRgn(points, points.length);
        OS.DisposeRgn(polyRgn);
    }
    return 0;
}

void destroy() {
    OS.DisposeRgn(handle);
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
    if (this is object) return true;
    if (!( null !is cast(Region)object )) return false;
    Region region = cast(Region)object;
    return handle is region.handle;
}

alias opEquals equals;

/**
 * Returns a rectangle which represents the rectangular
 * union of the collection of polygons the receiver
 * maintains to describe its area.
 *
 * @return a bounding rectangle for the region
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see Rectangle#union
 */
public Rectangle getBounds() {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    NSAutoreleasePool pool = null;
    Carbon.Rect bounds;

    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
    OS.GetRegionBounds(handle, &bounds);
    int width = bounds.right - bounds.left;
    int height = bounds.bottom - bounds.left;
    return new Rectangle(bounds.left, bounds.top, width, height);
    } finally {
        if (pool !is null) pool.release();
    }
}

NSBezierPath getPath() {
    NSBezierPath path = NSBezierPath.bezierPath();
    path.retain();
    OS.QDRegionToRects(handle, OS.kQDParseRegionFromTopLeft, cast(Carbon.RegionToRectsUPP) &Region.regionToRects, path.id);
    if (path.isEmpty()) path.appendBezierPathWithRect(NSRect());
    return path;
}

static NSPoint pt = NSPoint();
static Carbon.Rect rect;
extern(C) private static Carbon.OSStatus regionToRects(ushort message, Carbon.RgnHandle rgn, Carbon.Rect* r, objc.id path) {
    if (message is OS.kQDRegionToRectsMsgParse) {
        OS.memmove(&rect, r, rect.sizeof);
        pt.x = rect.left;
        pt.y = rect.top;
        OS.objc_msgSend(path, OS.sel_moveToPoint_, pt);
        pt.x = rect.right;
        OS.objc_msgSend(path, OS.sel_lineToPoint_, pt);
        pt.x = rect.right;
        pt.y = rect.bottom;
        OS.objc_msgSend(path, OS.sel_lineToPoint_, pt);
        pt.x = rect.left;
        OS.objc_msgSend(path, OS.sel_lineToPoint_, pt);
        OS.objc_msgSend(path, OS.sel_closePath);
    }
    return 0;
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
    return cast(hash_t) handle;
}

alias toHash hashCode;

/**
 * Intersects the given rectangle to the collection of polygons
 * the receiver maintains to describe its area.
 *
 * @param rect the rectangle to intersect with the receiver
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the argument is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the rectangle's width or height is negative</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 * 
 * @since 3.0
 */
public void intersect(Rectangle rect) {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (rect is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    intersect (rect.x, rect.y, rect.width, rect.height);
}

/**
 * Intersects the given rectangle to the collection of polygons
 * the receiver maintains to describe its area.
 *
 * @param x the x coordinate of the rectangle
 * @param y the y coordinate of the rectangle
 * @param width the width coordinate of the rectangle
 * @param height the height coordinate of the rectangle
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the rectangle's width or height is negative</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 * 
 * @since 3.1
 */
public void intersect(int x, int y, int width, int height) {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (width < 0 || height < 0) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        Carbon.RgnHandle rectRgn = OS.NewRgn();
        Carbon.Rect r;
        OS.SetRect(&r, cast(short)x, cast(short)y, cast(short)(x + width),cast(short)(y + height));
        OS.RectRgn(rectRgn, &r);
        OS.SectRgn(handle, rectRgn, handle);
        OS.DisposeRgn(rectRgn);
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Intersects all of the polygons which make up the area covered
 * by the argument to the collection of polygons the receiver
 * maintains to describe its area.
 *
 * @param region the region to intersect
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the argument is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 * 
 * @since 3.0
 */
public void intersect(Region region) {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (region is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (region.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        OS.SectRgn(handle, region.handle, handle);
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Returns <code>true</code> if the rectangle described by the
 * arguments intersects with any of the polygons the receiver
 * maintains to describe its area, and <code>false</code> otherwise.
 *
 * @param x the x coordinate of the origin of the rectangle
 * @param y the y coordinate of the origin of the rectangle
 * @param width the width of the rectangle
 * @param height the height of the rectangle
 * @return <code>true</code> if the rectangle intersects with the receiver, and <code>false</code> otherwise
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see Rectangle#intersects(Rectangle)
 */
public bool intersects (int x, int y, int width, int height) {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        Carbon.Rect r;
        OS.SetRect(&r, cast(short)x, cast(short)y, cast(short)(x + width),cast(short)(y + height));
        return OS.RectInRgn(&r, handle);
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Returns <code>true</code> if the given rectangle intersects
 * with any of the polygons the receiver maintains to describe
 * its area and <code>false</code> otherwise.
 *
 * @param rect the rectangle to test for intersection
 * @return <code>true</code> if the rectangle intersects with the receiver, and <code>false</code> otherwise
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the argument is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see Rectangle#intersects(Rectangle)
 */
public bool intersects(Rectangle rect) {
    if (rect is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    return intersects(rect.x, rect.y, rect.width, rect.height);
}

/**
 * Returns <code>true</code> if the region has been disposed,
 * and <code>false</code> otherwise.
 * <p>
 * This method gets the dispose state for the region.
 * When a region has been disposed, it is an error to
 * invoke any other method using the region.
 *
 * @return <code>true</code> when the region is disposed, and <code>false</code> otherwise
 */
public bool isDisposed() {
    return handle is null;
}

/**
 * Returns <code>true</code> if the receiver does not cover any
 * area in the (x, y) coordinate plane, and <code>false</code> if
 * the receiver does cover some area in the plane.
 *
 * @return <code>true</code> if the receiver is empty, and <code>false</code> otherwise
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public bool isEmpty() {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        return OS.EmptyRgn(handle);
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Subtracts the given polygon from the collection of polygons
 * the receiver maintains to describe its area.
 *
 * @param pointArray points that describe the polygon to merge with the receiver
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the argument is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 * 
 * @since 3.0
 */
public void subtract (int[] pointArray) {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (pointArray is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (pointArray.length < 2) return;
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        Carbon.RgnHandle polyRgn = polyRgn(pointArray, pointArray.length);
        OS.DiffRgn(handle, polyRgn, handle);
        OS.DisposeRgn(polyRgn);
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Subtracts the given rectangle from the collection of polygons
 * the receiver maintains to describe its area.
 *
 * @param rect the rectangle to subtract from the receiver
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the argument is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the rectangle's width or height is negative</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 * 
 * @since 3.0
 */
public void subtract(Rectangle rect) {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (rect is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    subtract (rect.x, rect.y, rect.width, rect.height);
}

/**
 * Subtracts the given rectangle from the collection of polygons
 * the receiver maintains to describe its area.
 *
 * @param x the x coordinate of the rectangle
 * @param y the y coordinate of the rectangle
 * @param width the width coordinate of the rectangle
 * @param height the height coordinate of the rectangle
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the rectangle's width or height is negative</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 * 
 * @since 3.1
 */
public void subtract(int x, int y, int width, int height) {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (width < 0 || height < 0) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        Carbon.RgnHandle rectRgn = OS.NewRgn();
        Carbon.Rect r;
        OS.SetRect(&r, cast(short)x, cast(short)y, cast(short)(x + width),cast(short)(y + height));
        OS.RectRgn(rectRgn, &r);
        OS.DiffRgn(handle, rectRgn, handle);
        OS.DisposeRgn(rectRgn);
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Subtracts all of the polygons which make up the area covered
 * by the argument from the collection of polygons the receiver
 * maintains to describe its area.
 *
 * @param region the region to subtract
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the argument is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 * 
 * @since 3.0
 */
public void subtract(Region region) {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (region is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (region.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        OS.DiffRgn(handle, region.handle, handle);
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Translate all of the polygons the receiver maintains to describe
 * its area by the specified point.
 *
 * @param x the x coordinate of the point to translate
 * @param y the y coordinate of the point to translate
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 * 
 * @since 3.1
 */
public void translate (int x, int y) {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        OS.OffsetRgn (handle, cast(short)x, cast(short)y);
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Translate all of the polygons the receiver maintains to describe
 * its area by the specified point.
 *
 * @param pt the point to translate
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the argument is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 * 
 * @since 3.1
 */
public void translate (Point pt) {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
    if (pt is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        translate (pt.x, pt.y);
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
    if (isDisposed()) return "Region {*DISPOSED*}";
    return Format("Region {{}{}" , handle , "}");
}
}
