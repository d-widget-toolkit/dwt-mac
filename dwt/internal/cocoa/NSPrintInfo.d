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
module dwt.internal.cocoa.NSPrintInfo;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSDictionary;
import dwt.internal.cocoa.NSMutableDictionary;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSPrinter;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSPrintInfo : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public static NSPrinter defaultPrinter() {
    objc.id result = OS.objc_msgSend(OS.class_NSPrintInfo, OS.sel_defaultPrinter);
    return result !is null ? new NSPrinter(result) : null;
}

public NSMutableDictionary dictionary() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_dictionary);
    return result !is null ? new NSMutableDictionary(result) : null;
}

public NSRect imageablePageBounds() {
    NSRect result = NSRect();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_imageablePageBounds);
    return result;
}

public NSPrintInfo initWithDictionary(NSDictionary attributes) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithDictionary_, attributes !is null ? attributes.id : null);
    return result is this.id ? this : (result !is null ? new NSPrintInfo(result) : null);
}

public NSString jobDisposition() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_jobDisposition);
    return result !is null ? new NSString(result) : null;
}

public NSPrintingOrientation orientation() {
    return cast(NSPrintingOrientation) OS.objc_msgSend(this.id, OS.sel_orientation);
}

public NSSize paperSize() {
    NSSize result = NSSize();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_paperSize);
    return result;
}

public NSPrinter printer() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_printer);
    return result !is null ? new NSPrinter(result) : null;
}

public void setJobDisposition(NSString disposition) {
    OS.objc_msgSend(this.id, OS.sel_setJobDisposition_, disposition !is null ? disposition.id : null);
}

public void setOrientation(NSPrintingOrientation orientation) {
    OS.objc_msgSend(this.id, OS.sel_setOrientation_, orientation);
}

public void setPrinter(NSPrinter printer) {
    OS.objc_msgSend(this.id, OS.sel_setPrinter_, printer !is null ? printer.id : null);
}

public void setUpPrintOperationDefaultValues() {
    OS.objc_msgSend(this.id, OS.sel_setUpPrintOperationDefaultValues);
}

public static NSPrintInfo sharedPrintInfo() {
    objc.id result = OS.objc_msgSend(OS.class_NSPrintInfo, OS.sel_sharedPrintInfo);
    return result !is null ? new NSPrintInfo(result) : null;
}

}
