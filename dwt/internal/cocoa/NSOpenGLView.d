/*******************************************************************************
 * Copyright (c) 2000, 2008 IBM Corporation and others.
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
module dwt.internal.cocoa.NSOpenGLView;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSOpenGLContext;
import dwt.internal.cocoa.NSOpenGLPixelFormat;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSView;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSOpenGLView : NSView {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void clearGLContext() {
    OS.objc_msgSend(this.id, OS.sel_clearGLContext);
}

public cocoa.id initWithFrame(NSRect frameRect, NSOpenGLPixelFormat format) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithFrame_pixelFormat_, frameRect, format !is null ? format.id : null);
    return result !is null ? new cocoa.id(result) : null;
}

public NSOpenGLContext openGLContext() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_openGLContext);
    return result !is null ? new NSOpenGLContext(result) : null;
}

public void setPixelFormat(NSOpenGLPixelFormat pixelFormat) {
    OS.objc_msgSend(this.id, OS.sel_setPixelFormat_, pixelFormat !is null ? pixelFormat.id : null);
}

}
