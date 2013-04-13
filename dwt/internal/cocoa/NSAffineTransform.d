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
module dwt.internal.cocoa.NSAffineTransform;

import dwt.internal.c.Carbon;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSAffineTransformStruct;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSAffineTransform : NSObject {

public this () {
    super();
}

public this (objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void concat() {
    OS.objc_msgSend(this.id, OS.sel_concat);
}

public NSAffineTransform initWithTransform (NSAffineTransform transform) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithTransform_, transform !is null ? transform.id : null);
    return result is this.id ? this : (result !is null ? new NSAffineTransform(result) : null);
}

public void invert() {
    OS.objc_msgSend(this.id, OS.sel_invert);
}

public void prependTransform(NSAffineTransform transform) {
    OS.objc_msgSend(this.id, OS.sel_prependTransform_, transform !is null ? transform.id : null);
}

public void rotateByDegrees(CGFloat angle) {
    OS.objc_msgSend(this.id, OS.sel_rotateByDegrees_, angle);
}

public void scaleXBy(CGFloat scaleX, CGFloat scaleY) {
    OS.objc_msgSend(this.id, OS.sel_scaleXBy_yBy_, scaleX, scaleY);
}

public void set() {
    OS.objc_msgSend(this.id, OS.sel_set);
}

public void setTransformStruct(NSAffineTransformStruct transformStruct) {
    OS.objc_msgSend(this.id, OS.sel_setTransformStruct_, transformStruct);
}

public static NSAffineTransform transform() {
    objc.id result = OS.objc_msgSend(OS.class_NSAffineTransform, OS.sel_transform);
    return result !is null ? new NSAffineTransform(result) : null;
}

public NSPoint transformPoint(NSPoint aPoint) {
    return OS.objc_msgSend_stret!(NSPoint)(this.id, OS.sel_transformPoint_, aPoint);
}

public NSSize transformSize(NSSize aSize) {
    return OS.objc_msgSend_stret!(NSSize)(this.id, OS.sel_transformSize_, aSize);
}

public NSAffineTransformStruct transformStruct() {
    return OS.objc_msgSend_stret!(NSAffineTransformStruct)(this.id, OS.sel_transformStruct);
}

public void translateXBy (CGFloat deltaX, CGFloat deltaY) {
    OS.objc_msgSend(this.id, OS.sel_translateXBy_yBy_, deltaX, deltaY);
}

}
