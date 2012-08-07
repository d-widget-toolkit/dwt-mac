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
module dwt.internal.cocoa.NSKeyedArchiver;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSCoder;
import dwt.internal.cocoa.NSData;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSKeyedArchiver : NSCoder {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public static NSData archivedDataWithRootObject(cocoa.id rootObject) {
    objc.id result = OS.objc_msgSend(OS.class_NSKeyedArchiver, OS.sel_archivedDataWithRootObject_, rootObject !is null ? rootObject.id : null);
    return result !is null ? new NSData(result) : null;
}

}
