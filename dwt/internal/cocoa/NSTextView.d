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
module dwt.internal.cocoa.NSTextView;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSDictionary;
import dwt.internal.cocoa.NSEvent;
import dwt.internal.cocoa.NSLayoutManager;
import dwt.internal.cocoa.NSParagraphStyle;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSRange;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSText;
import dwt.internal.cocoa.NSTextContainer;
import dwt.internal.cocoa.NSTextStorage;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSTextView : NSText {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSUInteger characterIndexForInsertionAtPoint(NSPoint point) {
    return OS.objc_msgSend(this.id, OS.sel_characterIndexForInsertionAtPoint_, point);
}

public NSParagraphStyle defaultParagraphStyle() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_defaultParagraphStyle);
    return result !is null ? new NSParagraphStyle(result) : null;
}

public bool dragSelectionWithEvent(NSEvent event, NSSize mouseOffset, bool slideBack) {
    return OS.objc_msgSend_bool(this.id, OS.sel_dragSelectionWithEvent_offset_slideBack_, event !is null ? event.id : null, mouseOffset, slideBack);
}

public NSLayoutManager layoutManager() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_layoutManager);
    return result !is null ? new NSLayoutManager(result) : null;
}

public NSDictionary linkTextAttributes() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_linkTextAttributes);
    return result !is null ? new NSDictionary(result) : null;
}

public NSDictionary markedTextAttributes() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_markedTextAttributes);
    return result !is null ? new NSDictionary(result) : null;
}

public void setDefaultParagraphStyle(NSParagraphStyle paragraphStyle) {
    OS.objc_msgSend(this.id, OS.sel_setDefaultParagraphStyle_, paragraphStyle !is null ? paragraphStyle.id : null);
}

public void setLinkTextAttributes(NSDictionary attributeDictionary) {
    OS.objc_msgSend(this.id, OS.sel_setLinkTextAttributes_, attributeDictionary !is null ? attributeDictionary.id : null);
}

public void setRichText(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setRichText_, flag);
}

public bool shouldChangeTextInRange(NSRange affectedCharRange, NSString replacementString) {
    return OS.objc_msgSend_bool(this.id, OS.sel_shouldChangeTextInRange_replacementString_, affectedCharRange, replacementString !is null ? replacementString.id : null);
}

public NSTextContainer textContainer() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_textContainer);
    return result !is null ? new NSTextContainer(result) : null;
}

public NSTextStorage textStorage() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_textStorage);
    return result !is null ? new NSTextStorage(result) : null;
}

}
