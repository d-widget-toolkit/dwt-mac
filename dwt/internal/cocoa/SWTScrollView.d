/*******************************************************************************
 * Copyright (c) 2007, 2008 IBM Corporation and others.
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
module dwt.internal.cocoa.SWTScrollView;

import dwt.dwthelper.utils;
import dwt.internal.cocoa.NSScrollView;
import objc = dwt.internal.objc.runtime;

public class SWTScrollView : NSScrollView {

public this() {
    super(cast(objc.id) null);
}
    
public this(objc.id id) {
    super(id);
}

}
