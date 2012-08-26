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
module dwt.internal.cocoa.NSBitmapImageRep;

import dwt.internal.c.Carbon;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSColor;
import dwt.internal.cocoa.NSData;
import dwt.internal.cocoa.NSDictionary;
import dwt.internal.cocoa.NSImageRep;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSBitmapImageRep : NSImageRep {

public this () {
    super();
}

public this (objc.id id) {
    super(id);
}

public this (cocoa.id id) {
    super(id);
}

public NSData TIFFRepresentation() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_TIFFRepresentation);
    return result !is null ? new NSData(result) : null;
}

public ubyte* bitmapData () {
    return cast(ubyte*) OS.objc_msgSend(this.id, OS.sel_bitmapData);
}

public NSBitmapFormat bitmapFormat() {
    return cast(NSBitmapFormat) OS.objc_msgSend(this.id, OS.sel_bitmapFormat);
}

public NSInteger bitsPerPixel () {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_bitsPerPixel);
}

public NSInteger bytesPerPlane () {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_bytesPerPlane);
}

public NSInteger bytesPerRow () {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_bytesPerRow);
}

public NSColor colorAtX(NSInteger x, NSInteger y) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_colorAtX_y_, x, y);
    return result !is null ? new NSColor(result) : null;
}

public void getBitmapDataPlanes(ubyte** data) {
    OS.objc_msgSend(this.id, OS.sel_getBitmapDataPlanes_, data);
}

public static cocoa.id imageRepWithData(NSData data) {
    objc.id result = OS.objc_msgSend(OS.class_NSBitmapImageRep, OS.sel_imageRepWithData_, data !is null ? data.id : null);
    return result !is null ? new cocoa.id(result) : null;
}

public NSBitmapImageRep initWithBitmapDataPlanes (ubyte** planes, NSInteger width, NSInteger height, NSInteger bps, NSInteger spp, bool alpha, bool isPlanar, NSString colorSpaceName, NSBitmapFormat bitmapFormat, NSInteger rBytes, NSInteger pBits) {
	objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithBitmapDataPlanes_pixelsWide_pixelsHigh_bitsPerSample_samplesPerPixel_hasAlpha_isPlanar_colorSpaceName_bitmapFormat_bytesPerRow_bitsPerPixel_, planes, width, height, bps, spp, alpha, isPlanar, colorSpaceName !is null ? colorSpaceName.id : null, bitmapFormat, rBytes, pBits);
	return result is this.id ? this : (result !is null ? new NSBitmapImageRep(result) : null);
}

public NSBitmapImageRep initWithBitmapDataPlanes (ubyte** planes, NSInteger width, NSInteger height, NSInteger bps, NSInteger spp, bool alpha, bool isPlanar, NSString colorSpaceName, NSInteger rBytes, NSInteger pBits) {
	objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithBitmapDataPlanes_pixelsWide_pixelsHigh_bitsPerSample_samplesPerPixel_hasAlpha_isPlanar_colorSpaceName_bytesPerRow_bitsPerPixel_, planes, width, height, bps, spp, alpha, isPlanar, colorSpaceName !is null ? colorSpaceName.id : null, rBytes, pBits);
	return result is this.id ? this : (result !is null ? new NSBitmapImageRep(result) : null);
}

public NSBitmapImageRep initWithData(NSData data) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithData_, data !is null ? data.id : null);
    return result is this.id ? this : (result !is null ? new NSBitmapImageRep(result) : null);
}

public NSBitmapImageRep initWithFocusedViewRect(NSRect rect) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithFocusedViewRect_, rect);
    return result is this.id ? this : (result !is 0 ? new NSBitmapImageRep(result) : null);
}

public bool isPlanar () {
    return OS.objc_msgSend_bool(this.id, OS.sel_isPlanar);
}

public NSInteger numberOfPlanes() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_numberOfPlanes);
}

public NSInteger samplesPerPixel () {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_samplesPerPixel);
}

}
