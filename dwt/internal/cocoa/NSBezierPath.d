/*******************************************************************************
 * Copyright (c) 2000, 2009 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *    IBM Corporation - initial API and implementation
 *     
 * Port to the D programming language:
 *     Jacob Carlborg <doob@me.com>
 *******************************************************************************/
module dwt.internal.cocoa.NSBezierPath;

import dwt.dwthelper.utils;
import dwt.internal.c.Carbon;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSAffineTransform;
import dwt.internal.cocoa.NSFont;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSBezierPath : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void addClip() {
    OS.objc_msgSend(this.id, OS.sel_addClip);
}

public void appendBezierPath(NSBezierPath path) {
    OS.objc_msgSend(this.id, OS.sel_appendBezierPath_, path !is null ? path.id : null);
}

public void appendBezierPathWithArcWithCenter(NSPoint center, CGFloat radius, CGFloat startAngle, CGFloat endAngle) {
    OS.objc_msgSend(this.id, OS.sel_appendBezierPathWithArcWithCenter_radius_startAngle_endAngle_, center, radius, startAngle, endAngle);
}

public void appendBezierPathWithArcWithCenter(NSPoint center, CGFloat radius, CGFloat startAngle, CGFloat endAngle, bool clockwise) {
    OS.objc_msgSend(this.id, OS.sel_appendBezierPathWithArcWithCenter_radius_startAngle_endAngle_clockwise_, center, radius, startAngle, endAngle, clockwise);
}

public void appendBezierPathWithGlyphs(NSGlyph* glyphs, NSInteger count, NSFont font) {
    OS.objc_msgSend(this.id, OS.sel_appendBezierPathWithGlyphs_count_inFont_, glyphs, count, font !is null ? font.id : null);
}

public void appendBezierPathWithOvalInRect(NSRect rect) {
    OS.objc_msgSend(this.id, OS.sel_appendBezierPathWithOvalInRect_, rect);
}

public void appendBezierPathWithRect(NSRect rect) {
    OS.objc_msgSend(this.id, OS.sel_appendBezierPathWithRect_, rect);
}

public void appendBezierPathWithRoundedRect(NSRect rect, CGFloat xRadius, CGFloat yRadius) {
    OS.objc_msgSend(this.id, OS.sel_appendBezierPathWithRoundedRect_xRadius_yRadius_, rect, xRadius, yRadius);
}

public static NSBezierPath bezierPath() {
    objc.id result = OS.objc_msgSend(OS.class_NSBezierPath, OS.sel_bezierPath);
    return result !is null ? new NSBezierPath(result) : null;
}

public NSBezierPath bezierPathByFlatteningPath() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_bezierPathByFlatteningPath);
    return result is this.id ? this : (result !is null ? new NSBezierPath(result) : null);
}

public static NSBezierPath bezierPathWithRect(NSRect rect) {
    objc.id result = OS.objc_msgSend(OS.class_NSBezierPath, OS.sel_bezierPathWithRect_, rect);
    return result !is null ? new NSBezierPath(result) : null;
}

public NSRect bounds() {
    NSRect result = NSRect();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_bounds);
    return result;
}

public void closePath() {
    OS.objc_msgSend(this.id, OS.sel_closePath);
}

public bool containsPoint(NSPoint point) {
    return OS.objc_msgSend_bool(this.id, OS.sel_containsPoint_, point);
}

public NSRect controlPointBounds() {
    NSRect result = NSRect();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_controlPointBounds);
    return result;
}

public NSPoint currentPoint() {
    NSPoint result = NSPoint();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_currentPoint);
    return result;
}

public void curveToPoint(NSPoint endPoint, NSPoint controlPoint1, NSPoint controlPoint2) {
    OS.objc_msgSend(this.id, OS.sel_curveToPoint_controlPoint1_controlPoint2_, endPoint, controlPoint1, controlPoint2);
}

public static CGFloat defaultFlatness() {
    return cast(CGFloat) OS.objc_msgSend_fpret(OS.class_NSBezierPath, OS.sel_defaultFlatness);
}

public NSBezierPathElement elementAtIndex(NSInteger index, NSPointArray points) {
    return cast(NSBezierPathElement) OS.objc_msgSend(this.id, OS.sel_elementAtIndex_associatedPoints_, index, points);
}

public NSInteger elementCount() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_elementCount);
}

public void fill() {
    OS.objc_msgSend(this.id, OS.sel_fill);
}

public static void fillRect(NSRect rect) {
    OS.objc_msgSend(OS.class_NSBezierPath, OS.sel_fillRect_, rect);
}

public bool isEmpty() {
    return OS.objc_msgSend_bool(this.id, OS.sel_isEmpty);
}

public void lineToPoint(NSPoint point) {
    OS.objc_msgSend(this.id, OS.sel_lineToPoint_, point);
}

public void moveToPoint(NSPoint point) {
    OS.objc_msgSend(this.id, OS.sel_moveToPoint_, point);
}

public void removeAllPoints() {
    OS.objc_msgSend(this.id, OS.sel_removeAllPoints);
}

public void setClip() {
    OS.objc_msgSend(this.id, OS.sel_setClip);
}

public static void setDefaultFlatness(CGFloat flatness) {
    OS.objc_msgSend(OS.class_NSBezierPath, OS.sel_setDefaultFlatness_, flatness);
}

public void setLineCapStyle(NSLineCapStyle lineCapStyle) {
    OS.objc_msgSend(this.id, OS.sel_setLineCapStyle_, lineCapStyle);
}

public void setLineDash(/*const*/CGFloat* pattern, NSInteger count, CGFloat phase) {
    OS.objc_msgSend(this.id, OS.sel_setLineDash_count_phase_, pattern, count, phase);
}

public void setLineJoinStyle(NSLineJoinStyle lineJoinStyle) {
    OS.objc_msgSend(this.id, OS.sel_setLineJoinStyle_, lineJoinStyle);
}

public void setLineWidth(CGFloat lineWidth) {
    OS.objc_msgSend(this.id, OS.sel_setLineWidth_, lineWidth);
}

public void setMiterLimit(CGFloat miterLimit) {
    OS.objc_msgSend(this.id, OS.sel_setMiterLimit_, miterLimit);
}

public void setWindingRule(NSWindingRule windingRule) {
    OS.objc_msgSend(this.id, OS.sel_setWindingRule_, windingRule);
}

public void stroke() {
    OS.objc_msgSend(this.id, OS.sel_stroke);
}

public static void strokeRect(NSRect rect) {
    OS.objc_msgSend(OS.class_NSBezierPath, OS.sel_strokeRect_, rect);
}

public void transformUsingAffineTransform(NSAffineTransform transform) {
    OS.objc_msgSend(this.id, OS.sel_transformUsingAffineTransform_, transform !is null ? transform.id : null);
}

}
