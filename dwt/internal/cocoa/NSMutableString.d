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
module dwt.internal.cocoa.NSMutableString;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSMutableString : NSString {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void appendString(NSString aString) {
    OS.objc_msgSend(this.id, OS.sel_appendString_, aString !is null ? aString.id : null);
}

public static NSString stringWithCharacters(/*const*/wchar* characters, NSUInteger length) {
    objc.id result = OS.objc_msgSend(OS.class_NSMutableString, OS.sel_stringWithCharacters_length_, characters, length);
    return result !is null ? new NSMutableString(result) : null;
}

public static NSString stringWithFormat(NSString stringWithFormat) {
    objc.id result = OS.objc_msgSend(OS.class_NSMutableString, OS.sel_stringWithFormat_, stringWithFormat !is null ? stringWithFormat.id : null);
    return result !is null ? new NSString(result) : null;
}

public static NSString stringWithUTF8String(/*const*/char* nullTerminatedCString) {
    objc.id result = OS.objc_msgSend(OS.class_NSMutableString, OS.sel_stringWithUTF8String_, nullTerminatedCString);
    return result !is null ? new NSString(result) : null;
}

}
