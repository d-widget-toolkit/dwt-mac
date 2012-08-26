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
module dwt.internal.cocoa.NSArray;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSArray : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public static NSArray array() {
    objc.id result = OS.objc_msgSend(OS.class_NSArray, OS.sel_array);
    return result !is null ? new NSArray(result) : null;
}

public static NSArray arrayWithObject(cocoa.id anObject) {
    objc.id result = OS.objc_msgSend(OS.class_NSArray, OS.sel_arrayWithObject_, anObject !is null ? anObject.id : null);
    return result !is null ? new NSArray(result) : null;
}

public bool containsObject(cocoa.id anObject) {
    return OS.objc_msgSend_bool(this.id, OS.sel_containsObject_, anObject !is null ? anObject.id : null);
}

public NSUInteger count() {
    return cast(NSUInteger) OS.objc_msgSend(this.id, OS.sel_count);
}

public NSUInteger indexOfObjectIdenticalTo(cocoa.id anObject) {
    return cast(NSUInteger) OS.objc_msgSend(this.id, OS.sel_indexOfObjectIdenticalTo_, anObject !is null ? anObject.id : null);
}

public cocoa.id objectAtIndex(NSUInteger index) {
	objc.id result = OS.objc_msgSend(this.id, OS.sel_objectAtIndex_, index);
	return result !is null ? new cocoa.id(result) : null;

}

}
