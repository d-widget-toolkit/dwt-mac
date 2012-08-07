/*******************************************************************************
 * Copyright (c) 2000, 2009 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *    IBM Corporation - initial API and implementation
 *******************************************************************************/
module dwt.internal.cocoa.NSToolbar;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSString;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSToolbar : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSToolbar initWithIdentifier(NSString identifier) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithIdentifier_, identifier !is null ? identifier.id : null);
    return result is this.id ? this : (result !is null ? new NSToolbar(result) : null);
}

public void insertItemWithItemIdentifier(NSString itemIdentifier, NSInteger index) {
    OS.objc_msgSend(this.id, OS.sel_insertItemWithItemIdentifier_atIndex_, itemIdentifier !is null ? itemIdentifier.id : null, index);
}

public void removeItemAtIndex(NSInteger index) {
    OS.objc_msgSend(this.id, OS.sel_removeItemAtIndex_, index);
}

public void setAllowsUserCustomization(bool allowCustomization) {
    OS.objc_msgSend(this.id, OS.sel_setAllowsUserCustomization_, allowCustomization);
}

public void setDelegate(cocoa.id delegate_) {
    OS.objc_msgSend(this.id, OS.sel_setDelegate_, delegate_ !is null ? delegate_.id : null);
}

public void setDisplayMode(NSToolbarDisplayMode displayMode) {
    OS.objc_msgSend(this.id, OS.sel_setDisplayMode_, displayMode);
}

public void setVisible(bool shown) {
    OS.objc_msgSend(this.id, OS.sel_setVisible_, shown);
}

}
