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
module dwt.internal.cocoa.NSButton;

import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSAttributedString;
import dwt.internal.cocoa.NSButtonCell;
import dwt.internal.cocoa.NSCell;
import dwt.internal.cocoa.NSControl;
import dwt.internal.cocoa.NSEvent;
import dwt.internal.cocoa.NSImage;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSButton : NSControl {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSAttributedString attributedTitle() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_attributedTitle);
    return result !is null ? new NSAttributedString(result) : null;
}

public void setAllowsMixedState(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setAllowsMixedState_, flag);
}

public void setAttributedTitle(NSAttributedString aString) {
    OS.objc_msgSend(this.id, OS.sel_setAttributedTitle_, aString !is null ? aString.id : null);
}

public void setBezelStyle(NSBezelStyle bezelStyle) {
    OS.objc_msgSend(this.id, OS.sel_setBezelStyle_, bezelStyle);
}

public void setBordered(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setBordered_, flag);
}

public void setButtonType(NSButtonType aType) {
    OS.objc_msgSend(this.id, OS.sel_setButtonType_, aType);
}

public void setImage(NSImage image) {
    OS.objc_msgSend(this.id, OS.sel_setImage_, image !is null ? image.id : null);
}

public void setImagePosition(NSCellImagePosition aPosition) {
    OS.objc_msgSend(this.id, OS.sel_setImagePosition_, aPosition);
}

public void setKeyEquivalent(NSString charCode) {
    OS.objc_msgSend(this.id, OS.sel_setKeyEquivalent_, charCode !is null ? charCode.id : null);
}

public void setState(NSInteger value) {
    OS.objc_msgSend(this.id, OS.sel_setState_, value);
}

public void setTitle(NSString aString) {
    OS.objc_msgSend(this.id, OS.sel_setTitle_, aString !is null ? aString.id : null);
}

public NSInteger state() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_state);
}

public static objc.Class cellClass() {
    return cast(objc.Class)OS.objc_msgSend(OS.class_NSButton, OS.sel_cellClass);
}

public static void setCellClass(objc.Class factoryId) {
    OS.objc_msgSend(OS.class_NSButton, OS.sel_setCellClass_, factoryId);
}

}
