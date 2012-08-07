﻿/*******************************************************************************
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
module dwt.internal.cocoa.DOMWheelEvent;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class DOMWheelEvent : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public bool altKey() {
    return OS.objc_msgSend_bool(this.id, OS.sel_altKey);
}

public int clientX() {
    return cast(int)/*64*/OS.objc_msgSend(this.id, OS.sel_clientX);
}

public int clientY() {
    return cast(int)/*64*/OS.objc_msgSend(this.id, OS.sel_clientY);
}

public bool ctrlKey() {
    return OS.objc_msgSend_bool(this.id, OS.sel_ctrlKey);
}

public bool metaKey() {
    return OS.objc_msgSend_bool(this.id, OS.sel_metaKey);
}

public bool shiftKey() {
    return OS.objc_msgSend_bool(this.id, OS.sel_shiftKey);
}

public int wheelDelta() {
    return cast(int)/*64*/OS.objc_msgSend(this.id, OS.sel_wheelDelta);
}

}
