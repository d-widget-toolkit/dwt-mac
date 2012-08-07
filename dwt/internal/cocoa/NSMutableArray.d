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
module dwt.internal.cocoa.NSMutableArray;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSMutableArray : NSArray {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void addObject(cocoa.id anObject) {
    OS.objc_msgSend(this.id, OS.sel_addObject_, anObject !is null ? anObject.id : null);
}

public void addObjectsFromArray(NSArray otherArray) {
    OS.objc_msgSend(this.id, OS.sel_addObjectsFromArray_, otherArray !is null ? otherArray.id : null);
}

public static NSMutableArray arrayWithCapacity(NSUInteger numItems) {
    objc.id result = OS.objc_msgSend(OS.class_NSMutableArray, OS.sel_arrayWithCapacity_, numItems);
    return result !is null ? new NSMutableArray(result) : null;
}

public NSMutableArray initWithCapacity(NSUInteger numItems) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithCapacity_, numItems);
    return result is this.id ? this : (result !is null ? new NSMutableArray(result) : null);
}

public void removeLastObject() {
    OS.objc_msgSend(this.id, OS.sel_removeLastObject);
}

}

public void removeLastObject() {
    OS.objc_msgSend(this.id, OS.sel_removeLastObject);
}

public void removeObject(cocoa.id anObject) {
    OS.objc_msgSend(this.id, OS.sel_removeObject_, anObject !is null ? anObject.id : null);
}

public void removeObjectAtIndex(NSUInteger index) {
    OS.objc_msgSend(this.id, OS.sel_removeObjectAtIndex_, index);
}

public void removeObjectIdenticalTo(id anObject) {
    OS.objc_msgSend(this.id, OS.sel_removeObjectIdenticalTo_, anObject !is null ? anObject.id : 0);
}

public void removeObjectIdenticalTo(cocoa.id anObject) {
    OS.objc_msgSend(this.id, OS.sel_removeObjectIdenticalTo_, anObject !is null ? anObject.id : null);
}

public static NSArray array() {
    objc.id result = OS.objc_msgSend(OS.class_NSMutableArray, OS.sel_array);
    return result !is null ? new NSArray(result) : null;
}

public static NSArray arrayWithObject(cocoa.id anObject) {
    objc.id result = OS.objc_msgSend(OS.class_NSMutableArray, OS.sel_arrayWithObject_, anObject !is null ? anObject.id : null);
    return result !is null ? new NSMutableArray(result) : null;
}

}
