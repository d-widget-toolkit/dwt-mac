/*******************************************************************************
 * Copyright (c) 2000, 2009 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *    IBM Corporation - initial API and implementation
 *******************************************************************************/
module dwt.internal.cocoa.NSTrackingArea;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSDictionary;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSRect;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSTrackingArea : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSTrackingArea initWithRect(NSRect rect, NSTrackingAreaOptions options, cocoa.id owner, NSDictionary userInfo) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithRect_options_owner_userInfo_, rect, options, owner !is null ? owner.id : null, userInfo !is null ? userInfo.id : null);
    return result is this.id ? this : (result !is null ? new NSTrackingArea(result) : null);
}

public cocoa.id owner() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_owner);
    return result !is null ? new cocoa.id(result) : null;
}

public NSDictionary userInfo() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_userInfo);
    return result !is null ? new NSDictionary(result) : null;
}

}
