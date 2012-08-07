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
module dwt.internal.cocoa.NSMutableSet;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSSet;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSMutableSet : NSSet {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void addObjectsFromArray(NSArray array) {
    OS.objc_msgSend(this.id, OS.sel_addObjectsFromArray_, array !is null ? array.id : null);
}

public static NSSet set() {
    objc.id result = OS.objc_msgSend(OS.class_NSMutableSet, OS.sel_set);
    return result !is null ? new NSMutableSet(result) : null;
}

}
