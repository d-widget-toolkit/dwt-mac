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
module dwt.internal.cocoa.NSOpenGLContext;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSOpenGLPixelFormat;
import dwt.internal.cocoa.NSView;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSOpenGLContext : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public static void clearCurrentContext() {
    OS.objc_msgSend(OS.class_NSOpenGLContext, OS.sel_clearCurrentContext);
}

public void clearDrawable() {
    OS.objc_msgSend(this.id, OS.sel_clearDrawable);
}

public static NSOpenGLContext currentContext() {
    objc.id result = OS.objc_msgSend(OS.class_NSOpenGLContext, OS.sel_currentContext);
    return result !is null ? new NSOpenGLContext(result) : null;
}

public void flushBuffer() {
    OS.objc_msgSend(this.id, OS.sel_flushBuffer);
}

public NSOpenGLContext initWithFormat(NSOpenGLPixelFormat format, NSOpenGLContext share) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithFormat_shareContext_, format !is null ? format.id : null, share !is null ? share.id : null);
    return result is this.id ? this : (result !is null ? new NSOpenGLContext(result) : null);
}

public void makeCurrentContext() {
    OS.objc_msgSend(this.id, OS.sel_makeCurrentContext);
}

public void setView(NSView view) {
    OS.objc_msgSend(this.id, OS.sel_setView_, view !is null ? view.id : null);
}

public void update() {
    OS.objc_msgSend(this.id, OS.sel_update);
}

public NSView view() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_view);
    return result !is null ? new NSView(result) : null;
}

}
