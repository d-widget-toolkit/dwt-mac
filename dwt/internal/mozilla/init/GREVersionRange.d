/*******************************************************************************
 * Copyright (c) 2003, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *******************************************************************************/
module dwt.internal.mozilla.init.GREVersionRange;

import dwt.dwthelper.utils;

/** @jniclass flags=cpp */
public class GREVersionRange {
    /** @field cast=(const char *) */
    public int /*long*/ lower;
    public bool lowerInclusive;
    /** @field cast=(const char *) */
    public int /*long*/ upper;
    public bool upperInclusive;
    public static final int sizeof = XPCOMInit.GREVersionRange_sizeof();
}
