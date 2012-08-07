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
module dwt.internal.cocoa.WebFrame;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.DOMDocument;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSURL;
import dwt.internal.cocoa.NSURLRequest;
import dwt.internal.cocoa.OS;
import dwt.internal.cocoa.WebDataSource;
import objc = dwt.internal.objc.runtime;

public class WebFrame : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public DOMDocument DOMDocument_() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_DOMDocument);
    return result !is null ? new DOMDocument(result) : null;
}

public WebDataSource dataSource() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_dataSource);
    return result !is null ? new WebDataSource(result) : null;
}

public void loadHTMLString(NSString string, NSURL URL) {
    OS.objc_msgSend(this.id, OS.sel_loadHTMLString_baseURL_, string !is null ? string.id : null, URL !is null ? URL.id : null);
}

public void loadRequest(NSURLRequest request) {
    OS.objc_msgSend(this.id, OS.sel_loadRequest_, request !is null ? request.id : null);
}

}
