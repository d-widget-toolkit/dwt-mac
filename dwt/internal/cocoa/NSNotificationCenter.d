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
module dwt.internal.cocoa.NSNotificationCenter;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSNotificationCenter : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void addObserver(cocoa.id observer, objc.SEL aSelector, NSString aName, cocoa.id anObject) {
    OS.objc_msgSend(this.id, OS.sel_addObserver_selector_name_object_, observer !is null ? observer.id : null, aSelector, aName !is null ? aName.id : null, anObject !is null ? anObject.id : null);
}

public static NSNotificationCenter defaultCenter() {
    objc.id result = OS.objc_msgSend(OS.class_NSNotificationCenter, OS.sel_defaultCenter);
    return result !is null ? new NSNotificationCenter(result) : null;
}

public void removeObserver(cocoa.id observer) {
    OS.objc_msgSend(this.id, OS.sel_removeObserver_, observer !is null ? observer.id : null);
}

}
