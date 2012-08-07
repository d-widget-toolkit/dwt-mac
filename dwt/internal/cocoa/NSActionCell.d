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
module dwt.internal.cocoa.NSActionCell;

import dwt.dwthelper.utils;

import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSCell;
import dwt.internal.cocoa.NSImage;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSActionCell : NSCell {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public objc.SEL action() {
    return cast(objc.SEL) OS.objc_msgSend(this.id, OS.sel_action);
}

public void setAction(objc.SEL aSelector) {
    OS.objc_msgSend(this.id, OS.sel_setAction_, aSelector);
}

public void setTarget(cocoa.id anObject) {
    OS.objc_msgSend(this.id, OS.sel_setTarget_, anObject !is null ? anObject.id : null);
}

public cocoa.id target() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_target);
    return result !is null ? new cocoa.id(result) : null;
}

}
