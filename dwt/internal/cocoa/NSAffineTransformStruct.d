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
module dwt.internal.cocoa.NSAffineTransformStruct;

import dwt.internal.c.Carbon;

struct NSAffineTransformStruct {
    public CGFloat m11, m12, m21, m22;
    public CGFloat tX, tY;
    //public static final int sizeof = OS.NSAffineTransformStruct_sizeof();
}
