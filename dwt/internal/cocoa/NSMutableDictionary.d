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
module dwt.internal.cocoa.NSMutableDictionary;

import dwt.dwthelper.utils;

import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSDictionary;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSMutableDictionary : NSDictionary {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public static NSMutableDictionary dictionaryWithCapacity(NSUInteger numItems) {
    objc.id result = OS.objc_msgSend(OS.class_NSMutableDictionary, OS.sel_dictionaryWithCapacity_, numItems);
    return result !is null ? new NSMutableDictionary(result) : null;
}

public NSMutableDictionary initWithCapacity(NSUInteger numItems) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithCapacity_, numItems);
    return result is this.id ? this : (result !is null ? new NSMutableDictionary(result) : null);
}

public void removeObjectForKey(cocoa.id aKey) {
    OS.objc_msgSend(this.id, OS.sel_removeObjectForKey_, aKey !is null ? aKey.id : null);
}

public void setDictionary(NSDictionary otherDictionary) {
    OS.objc_msgSend(this.id, OS.sel_setDictionary_, otherDictionary !is null ? otherDictionary.id : null);
}

public void setObject(cocoa.id anObject, cocoa.id aKey) {
    OS.objc_msgSend(this.id, OS.sel_setObject_forKey_, anObject !is null ? anObject.id : null, aKey !is null ? aKey.id : null);
}

public void setValue(cocoa.id value, NSString key) {
    OS.objc_msgSend(this.id, OS.sel_setValue_forKey_, value !is null ? value.id : null, key !is null ? key.id : null);
}

public static NSDictionary dictionaryWithObject(cocoa.id object, cocoa.id key) {
    objc.id result = OS.objc_msgSend(OS.class_NSMutableDictionary, OS.sel_dictionaryWithObject_forKey_, object !is null ? object.id : null, key !is null ? key.id : null);
    return result !is null ? new NSMutableDictionary(result) : null;
}

}
