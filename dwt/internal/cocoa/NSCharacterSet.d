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
module dwt.internal.cocoa.NSCharacterSet;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSCharacterSet : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public bool characterIsMember(wchar aCharacter) {
    return OS.objc_msgSend_bool(this.id, OS.sel_characterIsMember_, aCharacter);
}

public static cocoa.id decimalDigitCharacterSet() {
    objc.id result = OS.objc_msgSend(OS.class_NSCharacterSet, OS.sel_decimalDigitCharacterSet);
    return result !is null ? new cocoa.id(result) : null;
}

}
