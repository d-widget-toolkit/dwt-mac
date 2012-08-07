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
module dwt.internal.cocoa.NSTextStorage;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSAttributedString;
import dwt.internal.cocoa.NSLayoutManager;
import dwt.internal.cocoa.NSMutableAttributedString;
import dwt.internal.cocoa.NSTextAttachment;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSTextStorage : NSMutableAttributedString {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void addLayoutManager(NSLayoutManager obj) {
    OS.objc_msgSend(this.id, OS.sel_addLayoutManager_, obj !is null ? obj.id : null);
}

public NSArray paragraphs() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_paragraphs);
    return result !is null ? new NSArray(result) : null;
}

public static NSAttributedString attributedStringWithAttachment(NSTextAttachment attachment) {
    objc.id result = OS.objc_msgSend(OS.class_NSTextStorage, OS.sel_attributedStringWithAttachment_, attachment !is null ? attachment.id : null);
    return result !is null ? new NSAttributedString(result) : null;
}

}
