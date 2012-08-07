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
module dwt.internal.cocoa.NSPrintOperation;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSGraphicsContext;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSPrintInfo;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSView;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSPrintOperation : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void cleanUpOperation() {
    OS.objc_msgSend(this.id, OS.sel_cleanUpOperation);
}

public NSGraphicsContext context() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_context);
    return result !is null ? new NSGraphicsContext(result) : null;
}

public NSGraphicsContext createContext() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_createContext);
    return result !is null ? new NSGraphicsContext(result) : null;
}

public bool deliverResult() {
    return OS.objc_msgSend_bool(this.id, OS.sel_deliverResult);
}

public void destroyContext() {
    OS.objc_msgSend(this.id, OS.sel_destroyContext);
}

public static NSPrintOperation printOperationWithView(NSView view, NSPrintInfo printInfo) {
    objc.id result = OS.objc_msgSend(OS.class_NSPrintOperation, OS.sel_printOperationWithView_printInfo_, view !is null ? view.id : null, printInfo !is null ? printInfo.id : null);
    return result !is null ? new NSPrintOperation(result) : null;
}

public bool runOperation() {
    return OS.objc_msgSend_bool(this.id, OS.sel_runOperation);
}

public static void setCurrentOperation(NSPrintOperation operation) {
    OS.objc_msgSend(OS.class_NSPrintOperation, OS.sel_setCurrentOperation_, operation !is null ? operation.id : null);
}

public void setJobTitle(NSString jobTitle) {
    OS.objc_msgSend(this.id, OS.sel_setJobTitle_, jobTitle !is null ? jobTitle.id : null);
}

public void setShowsPrintPanel(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setShowsPrintPanel_, flag);
}

public void setShowsProgressPanel(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setShowsProgressPanel_, flag);
}

}
