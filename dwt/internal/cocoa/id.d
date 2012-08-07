/*******************************************************************************
 * Copyright (c) 2007, 2009 IBM Corporation and others.
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
module dwt.internal.cocoa.id;

import dwt.dwthelper.utils;

import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

/**
 * @jniclass flags=no_gen
 */
public class id {

public objc.id id;

public this() {
}

public this(objc.id id) {
    this.id = id;
}

public this(dwt.internal.cocoa.id.id id) {
    this.id = id !is null ? id.id : null;
}

public objc.id objc_getClass() {
    String name = this.classinfo.name;
    int index = name.lastIndexOf('.');
    if (index !is -1) name = name.substring(index + 1);
    return OS.objc_getClass(name);
}

public String toString() {
    return getClass().getName() + "{" + id +  "}";
}

public String toString() {
    return Format(this.classinfo.name, "{", id,  "}");
}
}