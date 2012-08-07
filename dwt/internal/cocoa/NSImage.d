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
 *    Jacob Carlborg <doob@me.com>
 *******************************************************************************/
module dwt.internal.cocoa.NSImage;

import dwt.dwthelper.utils;
import dwt.internal.c.Carbon;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSData;
import dwt.internal.cocoa.NSDictionary;
import dwt.internal.cocoa.NSImageRep;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSImage : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSData TIFFRepresentation() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_TIFFRepresentation);
    return result !is null ? new NSData(result) : null;
}

public void addRepresentation(NSImageRep imageRep) {
    OS.objc_msgSend(this.id, OS.sel_addRepresentation_, imageRep !is null ? imageRep.id : null);
}

public NSImageRep bestRepresentationForDevice(NSDictionary deviceDescription) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_bestRepresentationForDevice_, deviceDescription !is null ? deviceDescription.id : null);
    return result !is null ? new NSImageRep(result) : null;
}

public void drawAtPoint(NSPoint point, NSRect fromRect, NSCompositingOperation op, CGFloat delta) {
    OS.objc_msgSend(this.id, OS.sel_drawAtPoint_fromRect_operation_fraction_, point, fromRect, op, delta);
}

public void drawInRect(NSRect rect, NSRect fromRect, NSCompositingOperation op, CGFloat delta) {
    OS.objc_msgSend(this.id, OS.sel_drawInRect_fromRect_operation_fraction_, rect, fromRect, op, delta);
}

public static NSImage imageNamed(NSString name) {
    objc.id result = OS.objc_msgSend(OS.class_NSImage, OS.sel_imageNamed_, name !is null ? name.id : null);
    return result !is null ? new NSImage(result) : null;
}

public NSImage initByReferencingFile(NSString fileName) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initByReferencingFile_, fileName !is null ? fileName.id : null);
    return result is this.id ? this : (result !is null ? new NSImage(result) : null);
}

public NSImage initWithContentsOfFile(NSString fileName) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithContentsOfFile_, fileName !is null ? fileName.id : null);
    return result is this.id ? this : (result !is null ? new NSImage(result) : null);
}

public cocoa.id initWithData(NSData data) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithData_, data !is null ? data.id : null);
    return result !is null ? new cocoa.id(result) : null;
}

public NSImage initWithSize(NSSize aSize) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithSize_, aSize);
    return result is this.id ? this : (result !is null ? new NSImage(result) : null);
}

public void lockFocus() {
    OS.objc_msgSend(this.id, OS.sel_lockFocus);
}

public void removeRepresentation(NSImageRep imageRep) {
    OS.objc_msgSend(this.id, OS.sel_removeRepresentation_, imageRep !is null ? imageRep.id : null);
}

public NSArray representations() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_representations);
    return result !is null ? new NSArray(result) : null;
}

public void setCacheMode(NSImageCacheMode mode) {
    OS.objc_msgSend(this.id, OS.sel_setCacheMode_, mode);
}

public void setSize(NSSize aSize) {
    OS.objc_msgSend(this.id, OS.sel_setSize_, aSize);
}

public NSSize size() {
    NSSize result = NSSize();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_size);
    return result;
}

public void unlockFocus() {
    OS.objc_msgSend(this.id, OS.sel_unlockFocus);
}

}
