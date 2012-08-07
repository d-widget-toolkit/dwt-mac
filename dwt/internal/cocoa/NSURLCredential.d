/*******************************************************************************
 * Copyright (c) 2000, 2009 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *    IBM Corporation - initial API and implementation
 *******************************************************************************/
module dwt.internal.cocoa.NSURLCredential;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSString;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSURLCredential : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public static NSURLCredential credentialWithUser(NSString user, NSString password, NSURLCredentialPersistence persistence) {
    objc.id result = OS.objc_msgSend(OS.class_NSURLCredential, OS.sel_credentialWithUser_password_persistence_, user !is null ? user.id : null, password !is null ? password.id : null, persistence);
    return result !is null ? new NSURLCredential(result) : null;
}

public bool hasPassword() {
    return OS.objc_msgSend_bool(this.id, OS.sel_hasPassword);
}

public NSString password() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_password);
    return result !is null ? new NSString(result) : null;
}

public NSString user() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_user);
    return result !is null ? new NSString(result) : null;
}

}
