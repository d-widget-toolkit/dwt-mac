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
module dwt.internal.cocoa.NSStatusBar;

import dwt.dwthelper.utils;
import dwt.internal.c.Carbon;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSStatusItem;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSStatusBar : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void removeStatusItem(NSStatusItem item) {
    OS.objc_msgSend(this.id, OS.sel_removeStatusItem_, item !is null ? item.id : null);
}

public NSStatusItem statusItemWithLength(CGFloat length) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_statusItemWithLength_, length);
    return result !is null ? new NSStatusItem(result) : null;
}

public static NSStatusBar systemStatusBar() {
    objc.id result = OS.objc_msgSend(OS.class_NSStatusBar, OS.sel_systemStatusBar);
    return result !is null ? new NSStatusBar(result) : null;
}

}
