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
module dwt.internal.cocoa.NSScrollView;

import dwt.dwthelper.utils;
import dwt.internal.objc.cocoa.Cocoa;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSClipView;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSScroller;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.NSView;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSScrollView : NSView {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSSize contentSize() {
    NSSize result = NSSize();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_contentSize);
    return result;
}

public static NSSize contentSizeForFrameSize(NSSize fSize, bool hFlag, bool vFlag, NSBorderType aType) {
    NSSize result = NSSize();
    OS.objc_msgSend_stret(&result, OS.class_NSScrollView, OS.sel_contentSizeForFrameSize_hasHorizontalScroller_hasVerticalScroller_borderType_, fSize, hFlag, vFlag, aType);
    return result;
}

public NSClipView contentView() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_contentView);
    return result !is null ? new NSClipView(result) : null;
}

public NSView documentView() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_documentView);
    return result !is null ? new NSView(result) : null;
}

public NSRect documentVisibleRect() {
    NSRect result = NSRect();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_documentVisibleRect);
    return result;
}

public static NSSize frameSizeForContentSize(NSSize cSize, bool hFlag, bool vFlag, NSBorderType aType) {
    NSSize result = NSSize();
    OS.objc_msgSend_stret(&result, OS.class_NSScrollView, OS.sel_frameSizeForContentSize_hasHorizontalScroller_hasVerticalScroller_borderType_, cSize, hFlag, vFlag, aType);
    return result;
}

public void reflectScrolledClipView(NSClipView cView) {
    OS.objc_msgSend(this.id, OS.sel_reflectScrolledClipView_, cView !is null ? cView.id : null);
}

public void setAutohidesScrollers(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setAutohidesScrollers_, flag);
}

public void setBorderType(NSBorderType aType) {
    OS.objc_msgSend(this.id, OS.sel_setBorderType_, aType);
}

public void setDocumentView(NSView aView) {
    OS.objc_msgSend(this.id, OS.sel_setDocumentView_, aView !is null ? aView.id : null);
}

public void setDrawsBackground(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setDrawsBackground_, flag);
}

public void setHasHorizontalScroller(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setHasHorizontalScroller_, flag);
}

public void setHasVerticalScroller(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setHasVerticalScroller_, flag);
}

public void setHorizontalScroller(NSScroller anObject) {
    OS.objc_msgSend(this.id, OS.sel_setHorizontalScroller_, anObject !is null ? anObject.id : null);
}

public void setVerticalScroller(NSScroller anObject) {
    OS.objc_msgSend(this.id, OS.sel_setVerticalScroller_, anObject !is null ? anObject.id : null);
}

}
