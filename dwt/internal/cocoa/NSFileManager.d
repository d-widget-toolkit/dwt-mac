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
module dwt.internal.cocoa.NSFileManager;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSData;
import dwt.internal.cocoa.NSDictionary;
import dwt.internal.cocoa.NSDirectoryEnumerator;
import dwt.internal.cocoa.NSError;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSFileManager : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public bool createFileAtPath(NSString path, NSData data, NSDictionary attr) {
    return OS.objc_msgSend_bool(this.id, OS.sel_createFileAtPath_contents_attributes_, path !is null ? path.id : null, data !is null ? data.id : null, attr !is null ? attr.id : null);
}

public static NSFileManager defaultManager() {
    objc.id result = OS.objc_msgSend(OS.class_NSFileManager, OS.sel_defaultManager);
    return result !is null ? new NSFileManager(result) : null;
}

public NSDirectoryEnumerator enumeratorAtPath(NSString path) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_enumeratorAtPath_, path !is null ? path.id : null);
    return result !is null ? new NSDirectoryEnumerator(result) : null;
}

public bool fileExistsAtPath(NSString path, bool* isDirectory) {
    return OS.objc_msgSend_bool(this.id, OS.sel_fileExistsAtPath_isDirectory_, path !is null ? path.id : null, isDirectory);
}

public bool removeItemAtPath(NSString path, /*NSError** */ objc.id** error) {
    return OS.objc_msgSend_bool(this.id, OS.sel_removeItemAtPath_error_, path !is null ? path.id : null, error);
}

}
