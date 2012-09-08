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
module dwt.internal.cocoa.NSURLAuthenticationChallenge;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSURLCredential;
import dwt.internal.cocoa.NSURLProtectionSpace;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSURLAuthenticationChallenge : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSInteger previousFailureCount() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_previousFailureCount);
}

public NSURLCredential proposedCredential() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_proposedCredential);
    return result !is null ? new NSURLCredential(result) : null;
}

public NSURLProtectionSpace protectionSpace() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_protectionSpace);
    return result !is null ? new NSURLProtectionSpace(result) : null;
}

public cocoa.id sender() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_sender);
    return result !is null ? new cocoa.id(result) : null;
}

}
