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
module dwt.internal.cocoa.NSInputManager;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSEvent;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSInputManager : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public static NSInputManager currentInputManager() {
    objc.id result = OS.objc_msgSend(OS.class_NSInputManager, OS.sel_currentInputManager);
    return result !is null ? new NSInputManager(result) : null;
}

public bool handleMouseEvent(NSEvent theMouseEvent) {
    return OS.objc_msgSend_bool(this.id, OS.sel_handleMouseEvent_, theMouseEvent !is null ? theMouseEvent.id : null);
}

public bool wantsToHandleMouseEvents() {
    return OS.objc_msgSend_bool(this.id, OS.sel_wantsToHandleMouseEvents);
}

}
