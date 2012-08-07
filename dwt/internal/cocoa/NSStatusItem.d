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
module dwt.internal.cocoa.NSStatusItem;

import dwt.dwthelper.utils;
import dwt.internal.c.Carbon;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSMenu;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSView;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSStatusItem : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void drawStatusBarBackgroundInRect(NSRect rect, bool highlight) {
    OS.objc_msgSend(this.id, OS.sel_drawStatusBarBackgroundInRect_withHighlight_, rect, highlight);
}

public void popUpStatusItemMenu(NSMenu menu) {
    OS.objc_msgSend(this.id, OS.sel_popUpStatusItemMenu_, menu !is null ? menu.id : 0);
}

public void popUpStatusItemMenu(NSMenu menu) {
    OS.objc_msgSend(this.id, OS.sel_popUpStatusItemMenu_, menu !is null ? menu.id : null);
}

public void setHighlightMode(bool highlightMode) {
    OS.objc_msgSend(this.id, OS.sel_setHighlightMode_, highlightMode);
}

public void setLength(CGFloat length) {
    OS.objc_msgSend(this.id, OS.sel_setLength_, length);
}

public void setView(NSView view) {
    OS.objc_msgSend(this.id, OS.sel_setView_, view !is null ? view.id : null);
}

}
