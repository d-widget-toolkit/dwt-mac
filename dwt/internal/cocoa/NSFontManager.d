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
module dwt.internal.cocoa.NSFontManager;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.c.Carbon;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSFont;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSFontManager : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSArray availableFontFamilies() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_availableFontFamilies);
    return result !is null ? new NSArray(result) : null;
}

public NSArray availableFonts() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_availableFonts);
    return result !is null ? new NSArray(result) : null;
}

public NSArray availableMembersOfFontFamily(NSString fam) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_availableMembersOfFontFamily_, fam !is null ? fam.id : null);
    return result !is null ? new NSArray(result) : null;
}

public NSFont convertFont(NSFont fontObj, NSFontTraitMask trait) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_convertFont_toHaveTrait_, fontObj !is null ? fontObj.id : null, trait);
    return result !is null ? new NSFont(result) : null;
}

public NSFont fontWithFamily(NSString family, NSFontTraitMask traits, NSInteger weight, CGFloat size) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_fontWithFamily_traits_weight_size_, family !is null ? family.id : null, traits, weight, size);
    return result !is null ? new NSFont(result) : null;
}

public static NSFontManager sharedFontManager() {
    objc.id result = OS.objc_msgSend(OS.class_NSFontManager, OS.sel_sharedFontManager);
    return result !is null ? new NSFontManager(result) : null;
}

public NSFontTraitMask traitsOfFont(NSFont fontObj) {
    return cast(NSFontTraitMask) OS.objc_msgSend(this.id, OS.sel_traitsOfFont_, fontObj !is null ? fontObj.id : null);
}

public NSInteger weightOfFont(NSFont fontObj) {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_weightOfFont_, fontObj !is null ? fontObj.id : null);
}

}
