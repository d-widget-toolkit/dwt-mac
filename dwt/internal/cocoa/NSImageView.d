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
module dwt.internal.cocoa.NSImageView;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSCell;
import dwt.internal.cocoa.NSControl;
import dwt.internal.cocoa.NSImage;
import dwt.internal.cocoa.NSImageCell;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSImageView : NSControl {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSImage image() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_image);
    return result !is null ? new NSImage(result) : null;
}

public void setImage(NSImage newImage) {
    OS.objc_msgSend(this.id, OS.sel_setImage_, newImage !is null ? newImage.id : null);
}

public void setImageAlignment(NSImageAlignment newAlign) {
    OS.objc_msgSend(this.id, OS.sel_setImageAlignment_, newAlign);
}

public void setImageScaling(NSImageScaling newScaling) {
    OS.objc_msgSend(this.id, OS.sel_setImageScaling_, newScaling);
}

public static objc.Class cellClass() {
    return cast(objc.Class)OS.objc_msgSend(OS.class_NSImageView, OS.sel_cellClass);
}

public static void setCellClass(objc.Class factoryId) {
    OS.objc_msgSend(OS.class_NSImageView, OS.sel_setCellClass_, factoryId);
}

}
