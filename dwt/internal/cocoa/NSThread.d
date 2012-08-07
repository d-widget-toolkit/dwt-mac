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
module dwt.internal.cocoa.NSThread;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSMutableDictionary;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSThread : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public static NSThread currentThread() {
    objc.id result = OS.objc_msgSend(OS.class_NSThread, OS.sel_currentThread);
    return result !is null ? new NSThread(result) : null;
}

public static bool isMainThread() {
    return OS.objc_msgSend_bool(OS.class_NSThread, OS.sel_isMainThread);
}

public NSMutableDictionary threadDictionary() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_threadDictionary);
    return result !is null ? new NSMutableDictionary(result) : null;
}

}
