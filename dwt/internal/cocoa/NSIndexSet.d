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
module dwt.internal.cocoa.NSIndexSet;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSRange;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSIndexSet : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public bool containsIndex(NSUInteger value) {
    return OS.objc_msgSend_bool(this.id, OS.sel_containsIndex_, value);
}

public NSUInteger count() {
    return cast(NSUInteger) OS.objc_msgSend(this.id, OS.sel_count);
}

public NSUInteger firstIndex() {
    return cast(NSUInteger) OS.objc_msgSend(this.id, OS.sel_firstIndex);
}

public NSUInteger getIndexes(NSUInteger* indexBuffer, NSUInteger bufferSize, NSRangePointer range) {
    return cast(NSUInteger) OS.objc_msgSend(this.id, OS.sel_getIndexes_maxCount_inIndexRange_, indexBuffer, bufferSize, range);
}

public NSIndexSet initWithIndex(NSUInteger value) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithIndex_, value);
    return result is this.id ? this : (result !is null ? new NSIndexSet(result) : null);
}

public NSIndexSet initWithIndexesInRange(NSRange range) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithIndexesInRange_, range);
    return result is this.id ? this : (result !is null ? new NSIndexSet(result) : null);
}

}
