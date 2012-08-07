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
module dwt.internal.cocoa.WebDataSource;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSMutableURLRequest;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.OS;
import dwt.internal.cocoa.WebDocumentRepresentation;
import dwt.internal.cocoa.WebFrame;
import objc = dwt.internal.objc.runtime;

public class WebDataSource : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSString pageTitle() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_pageTitle);
    return result !is null ? new NSString(result) : null;
}

public WebDocumentRepresentation representation() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_representation);
    return result !is null ? new WebDocumentRepresentation(result) : null;
}

public NSMutableURLRequest request() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_request);
    return result !is null ? new NSMutableURLRequest(result) : null;
}

public WebFrame webFrame() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_webFrame);
    return result !is null ? new WebFrame(result) : null;
}

}
