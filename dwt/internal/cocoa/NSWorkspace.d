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
module dwt.internal.cocoa.NSWorkspace;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSAppleEventDescriptor;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSImage;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSURL;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

enum NSWorkspaceLaunchOptions : uint
{
    NSWorkspaceLaunchAndPrint = 0x00000002,
    NSWorkspaceLaunchInhibitingBackgroundOnly = 0x00000080,
    NSWorkspaceLaunchWithoutAddingToRecents = 0x00000100,
    NSWorkspaceLaunchWithoutActivation = 0x00000200,
    NSWorkspaceLaunchAsync = 0x00010000,
    NSWorkspaceLaunchAllowingClassicStartup = 0x00020000,
    NSWorkspaceLaunchPreferringClassic = 0x00040000,
    NSWorkspaceLaunchNewInstance = 0x00080000,
    NSWorkspaceLaunchAndHide = 0x00100000,
    NSWorkspaceLaunchAndHideOthers = 0x00200000,
    NSWorkspaceLaunchDefault = NSWorkspaceLaunchAsync | NSWorkspaceLaunchAllowingClassicStartup
}

public class NSWorkspace : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSString fullPathForApplication(NSString appName) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_fullPathForApplication_, appName !is null ? appName.id : null);
    return result !is null ? new NSString(result) : null;
}

public bool getInfoForFile(NSString fullPath, ref objc.id appName, ref objc.id type) {
    return OS.objc_msgSend_bool(this.id, OS.sel_getInfoForFile_application_type_, fullPath !is null ? fullPath.id : null, &appName, &type);
}

public NSImage iconForFile(NSString fullPath) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_iconForFile_, fullPath !is null ? fullPath.id : null);
    return result !is null ? new NSImage(result) : null;
}

public NSImage iconForFileType(NSString fileType) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_iconForFileType_, fileType !is null ? fileType.id : null);
    return result !is null ? new NSImage(result) : null;
}

public bool isFilePackageAtPath(NSString fullPath) {
    return OS.objc_msgSend_bool(this.id, OS.sel_isFilePackageAtPath_, fullPath !is null ? fullPath.id : null);
}

public bool openFile(NSString fullPath, NSString appName) {
    return OS.objc_msgSend_bool(this.id, OS.sel_openFile_withApplication_, fullPath !is null ? fullPath.id : null, appName !is null ? appName.id : null);
}

public bool openURL(NSURL url) {
    return OS.objc_msgSend_bool(this.id, OS.sel_openURL_, url !is null ? url.id : null);
}

public bool openURLs(NSArray urls, NSString bundleIdentifier, NSWorkspaceLaunchOptions options, NSAppleEventDescriptor descriptor, /*NSArray** */ objc.id** identifiers) {
    return OS.objc_msgSend_bool(this.id, OS.sel_openURLs_withAppBundleIdentifier_options_additionalEventParamDescriptor_launchIdentifiers_, urls !is null ? urls.id : null, bundleIdentifier !is null ? bundleIdentifier.id : null, options, descriptor !is null ? descriptor.id : null, identifiers);
}

public static NSWorkspace sharedWorkspace() {
    objc.id result = OS.objc_msgSend(OS.class_NSWorkspace, OS.sel_sharedWorkspace);
    return result !is null ? new NSWorkspace(result) : null;
}

}
