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
module dwt.internal.cocoa.NSBundle;

import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSDictionary;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSBundle : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public static bool loadNibFile(NSString fileName, NSDictionary context, NSZone* zone) {
    return OS.objc_msgSend_bool(OS.class_NSBundle, OS.sel_loadNibFile_externalNameTable_withZone_, fileName !is null ? fileName.id : null, context !is null ? context.id : null, zone);
}

public NSString bundleIdentifier() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_bundleIdentifier);
    return result !is null ? new NSString(result) : null;
}

public NSString bundlePath() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_bundlePath);
    return result !is null ? new NSString(result) : null;
}

public static NSBundle bundleWithIdentifier(NSString identifier) {
    objc.id result = OS.objc_msgSend(OS.class_NSBundle, OS.sel_bundleWithIdentifier_, identifier !is null ? identifier.id : null);
    return result !is null ? new NSBundle(result) : null;
}

public static NSBundle bundleWithPath(NSString path) {
    objc.id result = OS.objc_msgSend(OS.class_NSBundle, OS.sel_bundleWithPath_, path !is null ? path.id : null);
    return result !is null ? new NSBundle(result) : null;
}

public NSDictionary infoDictionary() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_infoDictionary);
    return result !is null ? new NSDictionary(result) : null;
}

public static NSBundle mainBundle() {
    objc.id result = OS.objc_msgSend(OS.class_NSBundle, OS.sel_mainBundle);
    return result !is null ? new NSBundle(result) : null;
}

public objc.id objectForInfoDictionaryKey(NSString key) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_objectForInfoDictionaryKey_, key !is null ? key.id : null);
    return result !is null ? new id(result) : null;
}

public NSString pathForResource(NSString name, NSString ext) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_pathForResource_ofType_, name !is null ? name.id : null, ext !is null ? ext.id : null);
    return result !is null ? new NSString(result) : null;
}

public NSString resourcePath() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_resourcePath);
    return result !is null ? new NSString(result) : null;
}

}
