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
module dwt.internal.cocoa.WebFrameView;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSPrintInfo;
import dwt.internal.cocoa.NSPrintOperation;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class WebFrameView : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public bool documentViewShouldHandlePrint() {
    return OS.objc_msgSend_bool(this.id, OS.sel_documentViewShouldHandlePrint);
}

public void printDocumentView() {
    OS.objc_msgSend(this.id, OS.sel_printDocumentView);
}

public NSPrintOperation printOperationWithPrintInfo(NSPrintInfo printInfo) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_printOperationWithPrintInfo_, printInfo !is null ? printInfo.id : null);
    return result !is null ? new NSPrintOperation(result) : null;
}

}
