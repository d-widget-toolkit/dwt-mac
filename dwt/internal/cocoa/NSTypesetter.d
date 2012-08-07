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
module dwt.internal.cocoa.NSTypesetter;

import dwt.dwthelper.utils;
import dwt.internal.c.Carbon;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSLayoutManager;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSTypesetter : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public CGFloat baselineOffsetInLayoutManager(NSLayoutManager layoutMgr, NSUInteger glyphIndex) {
    return cast(CGFloat) OS.objc_msgSend_fpret(this.id, OS.sel_baselineOffsetInLayoutManager_glyphIndex_, layoutMgr !is null ? layoutMgr.id : null, glyphIndex);
}

}
