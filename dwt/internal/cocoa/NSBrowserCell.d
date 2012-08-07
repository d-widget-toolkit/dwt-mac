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
module dwt.internal.cocoa.NSBrowserCell;

import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSCell;
import dwt.internal.cocoa.NSColor;
import dwt.internal.cocoa.NSView;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSBrowserCell : NSCell {

public this () {
    super();
}

public this (objc.id id) {
    super(id);
}

public this (cocoa.id id) {
    super(id);

}

public NSColor highlightColorInView (NSView controlView) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_highlightColorInView_, controlView !is null ? controlView.id : null);
    return result !is null ? new NSColor(result) : null;
}

public void setLeaf (bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setLeaf_, flag);
}

}
