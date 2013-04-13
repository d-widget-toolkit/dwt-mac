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
module dwt.internal.cocoa.NSTextContainer;

import dwt.dwthelper.utils;
import dwt.internal.c.Carbon;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSTextContainer : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSSize containerSize() {
    return OS.objc_msgSend_stret!(NSSize)(this.id, OS.sel_containerSize);
}

public NSTextContainer initWithContainerSize(NSSize size) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithContainerSize_, size);
    return result is this.id ? this : (result !is null ? new NSTextContainer(result) : null);
}

public void setContainerSize(NSSize size) {
    OS.objc_msgSend(this.id, OS.sel_setContainerSize_, size);
}

public void setLineFragmentPadding(CGFloat pad) {
    OS.objc_msgSend(this.id, OS.sel_setLineFragmentPadding_, pad);
}

public void setWidthTracksTextView(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setWidthTracksTextView_, flag);
}

}
