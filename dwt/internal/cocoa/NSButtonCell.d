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
module dwt.internal.cocoa.NSButtonCell;

import dwt.internal.c.Carbon;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSActionCell;
import dwt.internal.cocoa.NSColor;
import dwt.internal.cocoa.NSImage;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSView;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSButtonCell : NSActionCell {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void drawImage(NSImage image, NSRect frame, NSView controlView) {
    OS.objc_msgSend(this.id, OS.sel_drawImage_withFrame_inView_, image !is null ? image.id : 0, frame, controlView !is null ? controlView.id : 0);
}

public void drawImage(NSImage image, NSRect frame, NSView controlView) {
    OS.objc_msgSend(this.id, OS.sel_drawImage_withFrame_inView_, image !is null ? image.id : null, frame, controlView !is null ? controlView.id : null);
}

public void setBackgroundColor(NSColor color) {
    OS.objc_msgSend(this.id, OS.sel_setBackgroundColor_, color !is null ? color.id : null);
}

public void setButtonType(NSButtonType aType) {
    OS.objc_msgSend(this.id, OS.sel_setButtonType_, aType);
}

public void setImagePosition(NSCellImagePosition aPosition) {
    OS.objc_msgSend(this.id, OS.sel_setImagePosition_, aPosition);
}

public NSString title() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_title);
    return result !is null ? new NSString(result) : null;
}

}
