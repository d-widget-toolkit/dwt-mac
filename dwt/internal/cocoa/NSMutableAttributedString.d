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
module dwt.internal.cocoa.NSMutableAttributedString;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSAttributedString;
import dwt.internal.cocoa.NSMutableString;
import dwt.internal.cocoa.NSRange;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSTextAttachment;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSMutableAttributedString : NSAttributedString {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void appendAttributedString(NSAttributedString attrString) {
    OS.objc_msgSend(this.id, OS.sel_appendAttributedString_, attrString !is null ? attrString.id : null);
}

public NSMutableString mutableString() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_mutableString);
    return result !is null ? new NSMutableString(result) : null;
}

public void replaceCharactersInRange(NSRange range, NSString str) {
    OS.objc_msgSend(this.id, OS.sel_replaceCharactersInRange_withString_, range, str !is null ? str.id : null);
}

public void addAttribute(NSString name, cocoa.id value, NSRange range) {
    OS.objc_msgSend(this.id, OS.sel_addAttribute_value_range_, name !is null ? name.id : null, value !is null ? value.id : null, range);
}

public void beginEditing() {
    OS.objc_msgSend(this.id, OS.sel_beginEditing);
}

public void endEditing() {
    OS.objc_msgSend(this.id, OS.sel_endEditing);
}

public void removeAttribute(NSString name, NSRange range) {
    OS.objc_msgSend(this.id, OS.sel_removeAttribute_range_, name !is null ? name.id : null, range);
}

public void setAttributedString(NSAttributedString attrString) {
    OS.objc_msgSend(this.id, OS.sel_setAttributedString_, attrString !is null ? attrString.id : null);
}

public static NSAttributedString attributedStringWithAttachment(NSTextAttachment attachment) {
    objc.id result = OS.objc_msgSend(OS.class_NSMutableAttributedString, OS.sel_attributedStringWithAttachment_, attachment !is null ? attachment.id : null);
    return result !is null ? new NSAttributedString(result) : null;
}

}
