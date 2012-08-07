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
module dwt.internal.cocoa.NSPasteboard;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSData;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSPasteboard : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSInteger addTypes(NSArray newTypes, cocoa.id newOwner) {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_addTypes_owner_, newTypes !is null ? newTypes.id : null, newOwner !is null ? newOwner.id : null);
}

public NSString availableTypeFromArray(NSArray types) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_availableTypeFromArray_, types !is null ? types.id : null);
    return result !is null ? new NSString(result) : null;
}

public NSData dataForType(NSString dataType) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_dataForType_, dataType !is null ? dataType.id : null);
    return result !is null ? new NSData(result) : null;
}

public NSInteger declareTypes(NSArray newTypes, cocoa.id newOwner) {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_declareTypes_owner_, newTypes !is null ? newTypes.id : null, newOwner !is null ? newOwner.id : null);
}

public static NSPasteboard generalPasteboard() {
    objc.id result = OS.objc_msgSend(OS.class_NSPasteboard, OS.sel_generalPasteboard);
    return result !is null ? new NSPasteboard(result) : null;
}

public static NSPasteboard pasteboardWithName(NSString name) {
    objc.id result = OS.objc_msgSend(OS.class_NSPasteboard, OS.sel_pasteboardWithName_, name !is null ? name.id : null);
    return result !is null ? new NSPasteboard(result) : null;
}

public cocoa.id propertyListForType(NSString dataType) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_propertyListForType_, dataType !is null ? dataType.id : null);
    return result !is null ? new cocoa.id(result) : null;
}

public bool setData(NSData data, NSString dataType) {
    return OS.objc_msgSend_bool(this.id, OS.sel_setData_forType_, data !is null ? data.id : null, dataType !is null ? dataType.id : null);
}

public bool setPropertyList(cocoa.id plist, NSString dataType) {
    return OS.objc_msgSend_bool(this.id, OS.sel_setPropertyList_forType_, plist !is null ? plist.id : null, dataType !is null ? dataType.id : null);
}

public bool setString(NSString string, NSString dataType) {
    return OS.objc_msgSend_bool(this.id, OS.sel_setString_forType_, string !is null ? string.id : null, dataType !is null ? dataType.id : null);
}

public NSString stringForType(NSString dataType) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_stringForType_, dataType !is null ? dataType.id : null);
    return result !is null ? new NSString(result) : null;
}

public NSArray types() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_types);
    return result !is null ? new NSArray(result) : null;
}

}
