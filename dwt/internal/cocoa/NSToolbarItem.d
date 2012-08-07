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
module dwt.internal.cocoa.NSToolbarItem;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSImage;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSView;
import objc = dwt.internal.objc.runtime;

public class NSToolbarItem : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSToolbarItem initWithItemIdentifier(NSString itemIdentifier) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_initWithItemIdentifier_, itemIdentifier !is null ? itemIdentifier.id : null);
    return result is this.id ? this : (result !is null ? new NSToolbarItem(result) : null);
}

public NSString itemIdentifier() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_itemIdentifier);
    return result !is null ? new NSString(result) : null;
}

public void setAction(objc.SEL action) {
    OS.objc_msgSend(this.id, OS.sel_setAction_, action);
}

public void setEnabled(bool enabled) {
    OS.objc_msgSend(this.id, OS.sel_setEnabled_, enabled);
}

public void setImage(NSImage image) {
    OS.objc_msgSend(this.id, OS.sel_setImage_, image !is null ? image.id : null);
}

public void setLabel(NSString label) {
    OS.objc_msgSend(this.id, OS.sel_setLabel_, label !is null ? label.id : null);
}

public void setMaxSize(NSSize size) {
    OS.objc_msgSend(this.id, OS.sel_setMaxSize_, size);
}

public void setMinSize(NSSize size) {
    OS.objc_msgSend(this.id, OS.sel_setMinSize_, size);
}

public void setPaletteLabel(NSString paletteLabel) {
    OS.objc_msgSend(this.id, OS.sel_setPaletteLabel_, paletteLabel !is null ? paletteLabel.id : null);
}

public void setTarget(cocoa.id target) {
    OS.objc_msgSend(this.id, OS.sel_setTarget_, target !is null ? target.id : null);
}

public void setToolTip(NSString toolTip) {
    OS.objc_msgSend(this.id, OS.sel_setToolTip_, toolTip !is null ? toolTip.id : null);
}

public void setView(NSView view) {
    OS.objc_msgSend(this.id, OS.sel_setView_, view !is null ? view.id : null);
}

}
