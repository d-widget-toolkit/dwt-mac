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
module dwt.internal.cocoa.NSScreen;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSDictionary;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSScreen : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSWindowDepth depth() {
    return cast(NSWindowDepth)/*64*/OS.objc_msgSend(this.id, OS.sel_depth);
}

public NSDictionary deviceDescription() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_deviceDescription);
    return result !is null ? new NSDictionary(result) : null;
}

public NSRect frame() {
    NSRect result = NSRect();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_frame);
    return result;
}

public static NSScreen mainScreen() {
    objc.id result = OS.objc_msgSend(OS.class_NSScreen, OS.sel_mainScreen);
    return result !is null ? new NSScreen(result) : null;
}

public static NSArray screens() {
    objc.id result = OS.objc_msgSend(OS.class_NSScreen, OS.sel_screens);
    return result !is null ? new NSArray(result) : null;
}

public NSRect visibleFrame() {
    NSRect result = NSRect();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_visibleFrame);
    return result;
}

}
