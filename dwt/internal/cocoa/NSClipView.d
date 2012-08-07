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
module dwt.internal.cocoa.NSClipView;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSCursor;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSView;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSClipView : NSView {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public bool copiesOnScroll() {
    return OS.objc_msgSend_bool(this.id, OS.sel_copiesOnScroll);
}

public NSCursor documentCursor() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_documentCursor);
    return result !is null ? new NSCursor(result) : null;
}

public void scrollToPoint(NSPoint newOrigin) {
    OS.objc_msgSend(this.id, OS.sel_scrollToPoint_, newOrigin);
}

public void setCopiesOnScroll(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setCopiesOnScroll_, flag);
}

public void setDocumentCursor(NSCursor anObj) {
    OS.objc_msgSend(this.id, OS.sel_setDocumentCursor_, anObj !is null ? anObj.id : null);
}

public void setDrawsBackground(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setDrawsBackground_, flag);
}

}
