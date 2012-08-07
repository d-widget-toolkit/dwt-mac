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
module dwt.internal.cocoa.NSFont;

import dwt.dwthelper.utils;
import dwt.internal.c.Carbon;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSCell;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

alias uint NSGlyph;

public class NSFont : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public CGFloat ascender() {
    return cast(CGFloat) OS.objc_msgSend_fpret(this.id, OS.sel_ascender);
}

public static NSFont controlContentFontOfSize(float /*double*/ fontSize) {
    int /*long*/ result = OS.objc_msgSend(OS.class_NSFont, OS.sel_controlContentFontOfSize_, fontSize);
    return result !is 0 ? new NSFont(result) : null;
}

public static NSFont controlContentFontOfSize(CGFloat fontSize) {
    objc.id result = OS.objc_msgSend(OS.class_NSFont, OS.sel_controlContentFontOfSize_, fontSize);
    return result !is null ? new NSFont(result) : null;
}

public CGFloat descender() {
    return cast(CGFloat) OS.objc_msgSend_fpret(this.id, OS.sel_descender);
}

public NSString familyName() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_familyName);
    return result !is null ? new NSString(result) : null;
}

public NSString fontName() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_fontName);
    return result !is null ? new NSString(result) : null;
}

public static NSFont fontWithName(NSString fontName, CGFloat fontSize) {
    objc.id result = OS.objc_msgSend(OS.class_NSFont, OS.sel_fontWithName_size_, fontName !is null ? fontName.id : null, fontSize);
    return result !is null ? new NSFont(result) : null;
}

public CGFloat leading() {
    return cast(CGFloat) OS.objc_msgSend_fpret(this.id, OS.sel_leading);
}

public CGFloat pointSize() {
    return cast(CGFloat) OS.objc_msgSend_fpret(this.id, OS.sel_pointSize);
}

public static CGFloat smallSystemFontSize() {
    return cast(CGFloat) OS.objc_msgSend_fpret(OS.class_NSFont, OS.sel_smallSystemFontSize);
}

public static NSFont systemFontOfSize(CGFloat fontSize) {
    objc.id result = OS.objc_msgSend(OS.class_NSFont, OS.sel_systemFontOfSize_, fontSize);
    return result !is null ? new NSFont(result) : null;
}

public static CGFloat systemFontSize() {
    return cast(CGFloat) OS.objc_msgSend_fpret(OS.class_NSFont, OS.sel_systemFontSize);
}

public static CGFloat systemFontSizeForControlSize(NSControlSize controlSize) {
    return cast(CGFloat) OS.objc_msgSend_fpret(OS.class_NSFont, OS.sel_systemFontSizeForControlSize_, controlSize);
}

}
