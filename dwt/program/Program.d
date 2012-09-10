/*******************************************************************************
 * Copyright (c) 2000, 2009 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *
 * Port to the D programming language:
 *     Jacob Carlborg <doob@me.com>
 *******************************************************************************/
module dwt.program.Program;

import tango.text.convert.Format;
import dwt.dwthelper.utils;
import dwt.dwthelper.System;


import dwt.internal.C;



import dwt.DWT;
import dwt.internal.cocoa.NSURL;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSBundle;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSWorkspace;
import dwt.internal.cocoa.NSAutoreleasePool;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.NSBitmapImageRep;
import dwt.internal.cocoa.NSImageRep;
import dwt.internal.cocoa.NSFileManager;
import dwt.internal.cocoa.NSEnumerator;
import dwt.internal.cocoa.NSDirectoryEnumerator;
import dwt.internal.cocoa.NSImage;
import dwt.internal.cocoa.NSMutableSet;
import dwt.internal.cocoa.NSDictionary;
import dwt.internal.cocoa.OS;
import cocoa = dwt.internal.cocoa.id;

import dwt.internal.c.Carbon;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;
import dwt.graphics.PaletteData;
import dwt.graphics.ImageData;

/**
 * Instances of this class represent programs and
 * their associated file extensions in the operating
 * system.
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#program">Program snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public final class Program {
    String name, fullPath, identifier;

    static const String PREFIX_FILE = "file:"; //$NON-NLS-1$
    static const String PREFIX_HTTP = "http://"; //$NON-NLS-1$
    static const String PREFIX_HTTPS = "https://"; //$NON-NLS-1$

/**
 * Prevents uninitialized instances from being created outside the package.
 */
this () {
}

/**
 * Finds the program that is associated with an extension.
 * The extension may or may not begin with a '.'.  Note that
 * a <code>Display</code> must already exist to guarantee that
 * this method returns an appropriate result.
 *
 * @param extension the program extension
 * @return the program or <code>null</code>
 *
 * @exception IllegalArgumentException <ul>
 *      <li>ERROR_NULL_ARGUMENT when extension is null</li>
 *  </ul>
 */
public static Program findProgram (String extension) {
    // SWT extension: allow null string
    //if (extension is null) DWT.error (DWT.ERROR_NULL_ARGUMENT);
    if (extension.length is 0) return null;
    if (extension.charAt(0) !is '.') extension = "." ~ extension;
    NSAutoreleasePool pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        NSWorkspace workspace = NSWorkspace.sharedWorkspace();
        objc.id appName = new objc.objc_object;
        objc.id type = new objc.objc_object;
        NSString temp = new NSString(OS.NSTemporaryDirectory());
        NSString fileName = NSString.stringWith("swt" ~ Format("{}", System.currentTimeMillis()) ~ extension);
        NSString fullPath = temp.stringByAppendingPathComponent(fileName);
        NSFileManager fileManager = NSFileManager.defaultManager();
        fileManager.createFileAtPath(fullPath, null, null);
        if (!workspace.getInfoForFile(fullPath, appName, type)) return null;
        fileManager.removeItemAtPath(fullPath, null);
        objc.id buffer = appName;
        objc.id buffer2;
        OS.memmove(buffer2, type, C.PTR_SIZEOF);
        OS.free(appName);
        OS.free(type);
        if (buffer !is null) {
            NSString appPath = new NSString(buffer);
            NSString appType = new NSString(buffer2);
            NSBundle bundle = NSBundle.bundleWithPath(appPath);
            if (bundle !is null) {
                NSString textEditId = NSString.stringWith("com.apple.TextEdit");
                NSString bundleId = NSString.stringWith("CFBundleIdentifier");
                NSDictionary infoDictionary = bundle.infoDictionary();
                bool textEdit = textEditId.isEqual(infoDictionary.objectForKey(bundleId));
                if (!textEdit) return getProgram(bundle);
                // if text edit, make sure we're really one of the extensions that
                // text edit says it can handle.
                NSString CFBundleDocumentTypes = NSString.stringWith("CFBundleDocumentTypes");
                NSString CFBundleTypeExtensions = NSString.stringWith("CFBundleTypeExtensions");
                cocoa.id id = infoDictionary.objectForKey(CFBundleDocumentTypes);
                if (id !is null) {
                    NSDictionary documentTypes = new NSDictionary(id.id);
                    NSEnumerator documentTypesEnumerator = documentTypes.objectEnumerator();
                    while ((id = documentTypesEnumerator.nextObject()) !is null) {
                        NSDictionary documentType = new NSDictionary(id.id);
                        NSDictionary supportedExtensions = new NSDictionary(documentType.objectForKey(CFBundleTypeExtensions));
                        if (supportedExtensions !is null) {
                            NSEnumerator supportedExtensionsEnumerator = supportedExtensions.objectEnumerator();
                            if (supportedExtensionsEnumerator !is null) {
                                cocoa.id ext = null;
                                while((ext = supportedExtensionsEnumerator.nextObject()) !is null) {
                                    NSString strExt = new NSString(ext);
                                    if (appType.isEqual(strExt)) return getProgram (bundle);
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    } finally {
        pool.release();
    }
}

/**
 * Answer all program extensions in the operating system.  Note
 * that a <code>Display</code> must already exist to guarantee
 * that this method returns an appropriate result.
 *
 * @return an array of extensions
 */
public static String [] getExtensions () {
    NSAutoreleasePool pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        NSMutableSet supportedDocumentTypes = cast(NSMutableSet)NSMutableSet.set();
        NSWorkspace workspace = NSWorkspace.sharedWorkspace();
        NSString CFBundleDocumentTypes = NSString.stringWith("CFBundleDocumentTypes");
        NSString CFBundleTypeExtensions = NSString.stringWith("CFBundleTypeExtensions");
        NSArray array = new NSArray(OS.NSSearchPathForDirectoriesInDomains(OS.NSAllApplicationsDirectory, OS.NSAllDomainsMask, true));
        NSUInteger count = array.count();
        for (NSUInteger i = 0; i < count; i++) {
            NSString path = new NSString(array.objectAtIndex(i));
            NSFileManager fileManager = NSFileManager.defaultManager();
            NSDirectoryEnumerator enumerator = fileManager.enumeratorAtPath(path);
            if (enumerator !is null) {
                cocoa.id id;
                while ((id = enumerator.nextObject()) !is null) {
                    enumerator.skipDescendents();
                    NSString filePath = new NSString(id.id);
                    NSString fullPath = path.stringByAppendingPathComponent(filePath);
                    if (workspace.isFilePackageAtPath(fullPath)) {
                        NSBundle bundle = NSBundle.bundleWithPath(fullPath);
                        id = bundle.infoDictionary().objectForKey(CFBundleDocumentTypes);
                        if (id !is null) {
                            NSDictionary documentTypes = new NSDictionary(id.id);
                            NSEnumerator documentTypesEnumerator = documentTypes.objectEnumerator();
                            while ((id = documentTypesEnumerator.nextObject()) !is null) {
                                NSDictionary documentType = new NSDictionary(id.id);
                                id = documentType.objectForKey(CFBundleTypeExtensions);
                                if (id !is null) {
                                    supportedDocumentTypes.addObjectsFromArray(new NSArray(id.id));
                                }
                            }
                        }
                    }
                }
            }
        }
        int i = 0;
        String[] exts = new String[supportedDocumentTypes.count()];
        NSEnumerator enumerator = supportedDocumentTypes.objectEnumerator();
        cocoa.id id;
        while ((id = enumerator.nextObject()) !is null) {
            String ext = (new NSString(id.id)).getString();
            if (ext != "*") exts[i++] = "." ~ ext;
        }
        if (i !is exts.length) {
            String[] temp = new String[i];
            System.arraycopy(exts, 0, temp, 0, i);
            exts = temp;
        }
        return exts;
    } finally {
        pool.release();
    }
}

static Program getProgram(NSBundle bundle) {
    NSString CFBundleName = NSString.stringWith("CFBundleName");
    NSString CFBundleDisplayName = NSString.stringWith("CFBundleDisplayName");
    NSString fullPath = bundle.bundlePath();
    NSString identifier = bundle.bundleIdentifier();
    cocoa.id bundleName = bundle.objectForInfoDictionaryKey(CFBundleDisplayName);
    if (bundleName is null) {
        bundleName = bundle.objectForInfoDictionaryKey(CFBundleName);
    }
    if (bundleName is null) {
        bundleName = fullPath.lastPathComponent().stringByDeletingPathExtension();
    }
    NSString name = new NSString(bundleName.id);
    Program program = new Program();
    program.name = name.getString();
    program.fullPath = fullPath.getString();
    program.identifier = identifier !is null ? identifier.getString() : "";
    return program;
}

/**
 * Answers all available programs in the operating system.  Note
 * that a <code>Display</code> must already exist to guarantee
 * that this method returns an appropriate result.
 *
 * @return an array of programs
 */
public static Program [] getPrograms () {
    NSAutoreleasePool pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        Program[] vector;
        NSWorkspace workspace = NSWorkspace.sharedWorkspace();
        NSArray array = new NSArray(OS.NSSearchPathForDirectoriesInDomains(OS.NSAllApplicationsDirectory, OS.NSAllDomainsMask, true));
        NSUInteger count = array.count();
        for (NSUInteger i = 0; i < count; i++) {
            NSString path = new NSString(array.objectAtIndex(i));
            NSFileManager fileManager = NSFileManager.defaultManager();
            NSDirectoryEnumerator enumerator = fileManager.enumeratorAtPath(path);
            if (enumerator !is null) {
                cocoa.id id;
                while ((id = enumerator.nextObject()) !is null) {
                    enumerator.skipDescendents();
                    NSString fullPath = path.stringByAppendingPathComponent(new NSString(id.id));
                    if (workspace.isFilePackageAtPath(fullPath)) {
                        NSBundle bundle = NSBundle.bundleWithPath(fullPath);
                        if (bundle !is null) vector ~= getProgram(bundle);
                    }
                }
            }
        }
        return vector.dup;
    } finally {
        pool.release();
    }
}

/**
 * Launches the operating system executable associated with the file or
 * URL (http:// or https://).  If the file is an executable then the
 * executable is launched.  Note that a <code>Display</code> must already
 * exist to guarantee that this method returns an appropriate result.
 *
 * @param fileName the file or program name or URL (http:// or https://)
 * @return <code>true</code> if the file is launched, otherwise <code>false</code>
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT when fileName is null</li>
 * </ul>
 */
public static bool launch (String fileName) {
    // SWT extension: allow null string
    //if (fileName is null) DWT.error (DWT.ERROR_NULL_ARGUMENT);
    NSAutoreleasePool pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        NSString unescapedStr = NSString.stringWith("%"); //$NON-NLS-1$
        String lowercaseName = fileName.toLowerCase ();
        if (lowercaseName.startsWith (PREFIX_HTTP) || lowercaseName.startsWith (PREFIX_HTTPS)) {
            unescapedStr = NSString.stringWith("%#"); //$NON-NLS-1$
        } else {
            if (!lowercaseName.startsWith (PREFIX_FILE)) {
                fileName = PREFIX_FILE + fileName;
            }
        }
        NSString fullPath = NSString.stringWith(fileName);
        CFStringRef ptr = OS.CFURLCreateStringByAddingPercentEscapes(null, cast(CFStringRef) fullPath.id, cast(CFStringRef) unescapedStr.id, null, OS.kCFStringEncodingUTF8);
        NSString escapedString = new NSString(cast(objc.id)ptr);
        NSWorkspace workspace = NSWorkspace.sharedWorkspace();
        bool result = workspace.openURL(NSURL.URLWithString(escapedString));
        OS.CFRelease(ptr);
        return result;
    } finally {
        pool.release();
    }
}

/**
 * Executes the program with the file as the single argument
 * in the operating system.  It is the responsibility of the
 * programmer to ensure that the file contains valid data for
 * this program.
 *
 * @param fileName the file or program name
 * @return <code>true</code> if the file is launched, otherwise <code>false</code>
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT when fileName is null</li>
 * </ul>
 */
public bool execute (String fileName) {
    // SWT extension: allow null string
    //if (fileName is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    NSAutoreleasePool pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        NSWorkspace workspace = NSWorkspace.sharedWorkspace();
        String lowercaseName = fileName.toLowerCase ();
        if (lowercaseName.startsWith (PREFIX_HTTP) || lowercaseName.startsWith (PREFIX_HTTPS)) {
            NSString fullPath = NSString.stringWith(fileName);
            NSString unescapedStr = NSString.stringWith("%#"); //$NON-NLS-1$
            CFStringRef ptr = OS.CFURLCreateStringByAddingPercentEscapes(null, cast(CFStringRef) fullPath.id, cast(CFStringRef) unescapedStr.id, null, OS.kCFStringEncodingUTF8);
            NSString escapedString = new NSString(cast(objc.id) ptr);
            NSArray urls = NSArray.arrayWithObject(NSURL.URLWithString(escapedString));
            OS.CFRelease(ptr);
            return workspace.openURLs(urls, NSString.stringWith(identifier), NSWorkspaceLaunchOptions.init, null, null);
        } else {
            if (fileName.startsWith (PREFIX_FILE)) {
                fileName = fileName.substring (PREFIX_FILE.length);
            }
            NSString fullPath = NSString.stringWith (fileName);
            return workspace.openFile (fullPath, NSString.stringWith (name));
        }
    } finally {
        pool.release();
    }
}

/**
 * Returns the receiver's image data.  This is the icon
 * that is associated with the receiver in the operating
 * system.
 *
 * @return the image data for the program, may be null
 */
public ImageData getImageData () {
    NSAutoreleasePool pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        NSWorkspace workspace = NSWorkspace.sharedWorkspace();
        NSString fullPath;
        if (this.fullPath !is null) {
            fullPath = NSString.stringWith(this.fullPath);
        } else {
            fullPath = workspace.fullPathForApplication(NSString.stringWith(name));
        }
        if (fullPath !is null) {
            NSImage nsImage = workspace.iconForFile(fullPath);
            if (nsImage !is null) {
                NSSize size = NSSize();
                size.width = size.height = 16;
                nsImage.setSize(size);
                NSBitmapImageRep imageRep = null;
                NSImageRep rep = nsImage.bestRepresentationForDevice(null);
                if (rep.isKindOfClass(OS.class_NSBitmapImageRep)) {
                    imageRep = new NSBitmapImageRep(rep.id);
                }
                if (imageRep !is null) {
                    int width = cast(int)/*64*/imageRep.pixelsWide();
                    int height = cast(int)/*64*/imageRep.pixelsHigh();
                    int bpr = cast(int)/*64*/imageRep.bytesPerRow();
                    int bpp = cast(int)/*64*/imageRep.bitsPerPixel();
                    int dataSize = height * bpr;
                    byte[] srcData = new byte[dataSize];
                    OS.memmove(srcData.ptr, imageRep.bitmapData(), dataSize);
                    //TODO: Image representation wrong???
                    PaletteData palette = new PaletteData(0xFF000000, 0xFF0000, 0xFF00);
                    ImageData data = new ImageData(width, height, bpp, palette, 4, srcData);
                    data.bytesPerLine = bpr;
                    data.alphaData = new byte[width * height];
                    for (int i = 3, o = 0; i < srcData.length; i+= 4, o++) {
                        data.alphaData[o] = srcData[i];
                    }
                    return data;
                }
            }
        }
        return null;
    } finally {
        pool.release();
    }
}

/**
 * Returns the receiver's name.  This is as short and
 * descriptive a name as possible for the program.  If
 * the program has no descriptive name, this string may
 * be the executable name, path or empty.
 *
 * @return the name of the program
 */
public String getName () {
    return name;
}

/**
 * Compares the argument to the receiver, and returns true
 * if they represent the <em>same</em> object using a class
 * specific comparison.
 *
 * @param other the object to compare with this object
 * @return <code>true</code> if the object is the same as this object and <code>false</code> otherwise
 *
 * @see #hashCode()
 */
public int opEquals(Object other) {
    if (this is other) return true;
    if (cast(Program) other) {
        final Program program = cast(Program) other;
        return name == program.name;
    }
    return false;
}

alias opEquals equals;

/**
 * Returns an integer hash code for the receiver. Any two
 * objects that return <code>true</code> when passed to
 * <code>equals</code> must return the same value for this
 * method.
 *
 * @return the receiver's hash
 *
 * @see #equals(Object)
 */
public hash_t toHash() {
    return .toHash(name);
}

alias toHash hashCode;

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the program
 */
public String toString () {
    return "Program {" ~ name ~ "}";
}

}
