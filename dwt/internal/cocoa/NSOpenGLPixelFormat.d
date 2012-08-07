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
module dwt.internal.cocoa.NSOpenGLPixelFormat;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSOpenGLPixelFormat : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void getValues(int[] /*long[]*/ vals, int attrib, int screen) {
    OS.objc_msgSend(this.id, OS.sel_getValues_forAttribute_forVirtualScreen_, vals, attrib, screen);
}

public void getValues(GLint* vals, NSOpenGLPixelFormatAttribute attrib, GLint screen) {
    OS.objc_msgSend(this.id, OS.sel_getValues_forAttribute_forVirtualScreen_, vals, attrib, screen);
}

public cocoa.id initWithAttributes(/*const*/NSOpenGLPixelFormatAttribute* attribs) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithAttributes_, attribs);
    return result !is null ? new cocoa.id(result) : null;
}

}
