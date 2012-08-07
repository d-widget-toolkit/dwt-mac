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
module dwt.internal.cocoa.NSPrinter;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSPrinter : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSString name() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_name);
    return result !is null ? new NSString(result) : null;
}

public static NSArray printerNames() {
    objc.id result = OS.objc_msgSend(OS.class_NSPrinter, OS.sel_printerNames);
    return result !is null ? new NSArray(result) : null;
}

public static NSPrinter printerWithName(NSString name) {
    objc.id result = OS.objc_msgSend(OS.class_NSPrinter, OS.sel_printerWithName_, name !is null ? name.id : null);
    return result !is null ? new NSPrinter(result) : null;
}

}
