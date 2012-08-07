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
module dwt.internal.cocoa.NSSet;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSEnumerator;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSSet : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSUInteger count() {
    return cast(NSUInteger) OS.objc_msgSend(this.id, OS.sel_count);
}

public NSEnumerator objectEnumerator() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_objectEnumerator);
    return result !is null ? new NSEnumerator(result) : null;
}

public static NSSet set() {
    objc.id result = OS.objc_msgSend(OS.class_NSSet, OS.sel_set);
    return result !is null ? new NSSet(result) : null;
}

}
