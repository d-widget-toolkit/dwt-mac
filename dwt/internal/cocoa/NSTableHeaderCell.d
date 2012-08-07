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
module dwt.internal.cocoa.NSTableHeaderCell;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSTextFieldCell;
import dwt.internal.cocoa.NSView;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSTableHeaderCell : NSTextFieldCell {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void drawSortIndicatorWithFrame(NSRect cellFrame, NSView controlView, bool ascending, NSInteger priority) {
    OS.objc_msgSend(this.id, OS.sel_drawSortIndicatorWithFrame_inView_ascending_priority_, cellFrame, controlView !is null ? controlView.id : null, ascending, priority);
}

public NSRect sortIndicatorRectForBounds(NSRect theRect) {
    NSRect result = NSRect();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_sortIndicatorRectForBounds_, theRect);
    return result;
}

}
