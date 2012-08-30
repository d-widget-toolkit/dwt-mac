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
module dwt.internal.cocoa.NSRunLoop;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSDate;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSTimer;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSRunLoop : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void addTimer(NSTimer timer, NSString mode) {
    OS.objc_msgSend(this.id, OS.sel_addTimer_forMode_, timer !is null ? timer.id : null, mode !is null ? mode.id : null);
}

public static NSRunLoop currentRunLoop() {
    objc.id result = OS.objc_msgSend(OS.class_NSRunLoop, OS.sel_currentRunLoop);
    return result !is null ? new NSRunLoop(result) : null;
}

public static NSRunLoop mainRunLoop() {
    objc.id result = OS.objc_msgSend(OS.class_NSRunLoop, OS.sel_mainRunLoop);
    return result !is null ? new NSRunLoop(result) : null;
}

public bool runMode(NSString mode, NSDate limitDate) {
    return OS.objc_msgSend_bool(this.id, OS.sel_runMode_beforeDate_, mode !is null ? mode.id : null, limitDate !is null ? limitDate.id : null);
}

}
