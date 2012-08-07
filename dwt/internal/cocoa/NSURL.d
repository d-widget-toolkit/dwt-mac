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
module dwt.internal.cocoa.NSURL;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSPasteboard;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSURL : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public static NSURL URLFromPasteboard(NSPasteboard pasteBoard) {
    objc.id result = OS.objc_msgSend(OS.class_NSURL, OS.sel_URLFromPasteboard_, pasteBoard !is null ? pasteBoard.id : null);
    return result !is null ? new NSURL(result) : null;
}

public void writeToPasteboard(NSPasteboard pasteBoard) {
    OS.objc_msgSend(this.id, OS.sel_writeToPasteboard_, pasteBoard !is null ? pasteBoard.id : null);
}

public static NSURL URLWithString(NSString URLString) {
    objc.id result = OS.objc_msgSend(OS.class_NSURL, OS.sel_URLWithString_, URLString !is null ? URLString.id : null);
    return result !is null ? new NSURL(result) : null;
}

public NSString absoluteString() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_absoluteString);
    return result !is null ? new NSString(result) : null;
}

public static NSURL fileURLWithPath(NSString path) {
    objc.id result = OS.objc_msgSend(OS.class_NSURL, OS.sel_fileURLWithPath_, path !is null ? path.id : null);
    return result !is null ? new NSURL(result) : null;
}

public bool isFileURL() {
    return OS.objc_msgSend_bool(this.id, OS.sel_isFileURL);
}

}
