/*******************************************************************************
 * Copyright (c) 2007, 2009 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *******************************************************************************/
module dwt.internal.cocoa.SWTCanvasView;

import dwt.dwthelper.utils;
import dwt.internal.cocoa.NSView;
import objc = dwt.internal.objc.runtime;

public class SWTCanvasView : NSView {

public this() {
    super(cast(objc.id) null);
}
    
public this(objc.id id) {
    super(id);
}

}
