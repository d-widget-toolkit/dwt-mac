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
 *    Jacob Carlborg <doob@me.com>
 *******************************************************************************/
module dwt.internal.cocoa.NSSize;

import dwt.dwthelper.utils;
import dwt.internal.c.Carbon;


public struct NSSize {
    public CGFloat width = 0.0;
    public CGFloat height = 0.0;
    //public static final int sizeof = OS.NSSize_sizeof();

    public String toString() {
        return Format("{}{}{}{}{}", "NSSize{" , width , "," , height , "}");
    }
}
