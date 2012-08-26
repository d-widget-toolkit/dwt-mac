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
module dwt.internal.cocoa.NSImageRep;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSImageRep : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSInteger bitsPerSample() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_bitsPerSample);
}

public NSString colorSpaceName() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_colorSpaceName);
    return result !is null ? new NSString(result) : null;
}

public bool drawInRect(NSRect rect) {
    return OS.objc_msgSend_bool(this.id, OS.sel_drawInRect_, rect);
}

public bool hasAlpha() {
    return OS.objc_msgSend_bool(this.id, OS.sel_hasAlpha);
}

public NSInteger pixelsHigh() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_pixelsHigh);
}

public NSInteger pixelsWide() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_pixelsWide);
}

public void setAlpha(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setAlpha_, flag);
}

}
