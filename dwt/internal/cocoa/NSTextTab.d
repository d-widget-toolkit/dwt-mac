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
module dwt.internal.cocoa.NSTextTab;

import dwt.dwthelper.utils;
import dwt.internal.c.Carbon;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSParagraphStyle;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSTextTab : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSTextTab initWithType(NSTextTabType type, CGFloat loc) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithType_location_, type, loc);
    return result is this.id ? this : (result !is null ? new NSTextTab(result) : null);
}

public CGFloat location() {
    return cast(CGFloat) OS.objc_msgSend_fpret(this.id, OS.sel_location);
}

public NSTextTabType tabStopType() {
    return cast(NSTextTabType) OS.objc_msgSend(this.id, OS.sel_tabStopType);
}

}
