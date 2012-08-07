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
module dwt.internal.cocoa.NSDictionary;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSEnumerator;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSDictionary : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSArray allKeys() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_allKeys);
    return result !is null ? new NSArray(result) : null;
}

public NSUInteger count() {
    return cast(NSUInteger) OS.objc_msgSend(this.id, OS.sel_count);
}

public static NSDictionary dictionaryWithObject(cocoa.id object, cocoa.id key) {
    objc.id result = OS.objc_msgSend(OS.class_NSDictionary, OS.sel_dictionaryWithObject_forKey_, object !is null ? object.id : null, key !is null ? key.id : null);
    return result !is null ? new NSDictionary(result) : null;
}

public NSEnumerator objectEnumerator() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_objectEnumerator);
    return result !is null ? new NSEnumerator(result) : null;
}

public cocoa.id objectForKey(cocoa.id aKey) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_objectForKey_, aKey !is null ? aKey.id : null);
    return result !is null ? new cocoa.id(result) : null;
}

public cocoa.id valueForKey(NSString key) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_valueForKey_, key !is null ? key.id : null);
    return result !is null ? new cocoa.id(result) : null;
}

}
