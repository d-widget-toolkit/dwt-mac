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
module dwt.internal.cocoa.NSSearchField;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSTextField;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSSearchField : NSTextField {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSArray recentSearches() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_recentSearches);
    return result !is null ? new NSArray(result) : null;
}

public static objc.Class cellClass() {
    return cast(objc.Class) OS.objc_msgSend(OS.class_NSSearchField, OS.sel_cellClass);
}

public static void setCellClass(objc.Class factoryId) {
    OS.objc_msgSend(OS.class_NSSearchField, OS.sel_setCellClass_, factoryId);
}

}
