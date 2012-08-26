/*******************************************************************************
 * Copyright (c) 2000, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *     Frank Benoit <benoit@tionex.de>
 *******************************************************************************/
module dwt.internal.LONG;

import dwt.dwthelper.utils;

import tango.stdc.config;

/** @jniclass flags=no_gen */
public class LONG {
    public c_long value;

    public this (c_long value)
    {
        this.value = value;
    }

    public override int opEquals (Object object)
    {
        if (object is this) return true;
        if (auto obj = cast(LONG) object)
            return obj.value is this.value;

        return false;
    }

    public override hash_t toHash () {
        return /*64*/value;
    }

    alias toHash hashCode;
}
