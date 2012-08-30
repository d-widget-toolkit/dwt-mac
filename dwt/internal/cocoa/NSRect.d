/*******************************************************************************
 * Copyright (c) 2008, 2009 IBM Corporation and others.
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
module dwt.internal.cocoa.NSRect;

import dwt.dwthelper.utils;
import dwt.internal.c.Carbon;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSSize;


public struct NSRect {
    /** @field accessor=origin.x */
    CGFloat x ()
    {
        return origin.x;
    }

    CGFloat x (CGFloat x)
    {
        return origin.x = x;
    }
    /** @field accessor=origin.y */
    CGFloat y ()
    {
        return origin.y;
    }

    CGFloat y (CGFloat y)
    {
        return origin.y = y;
    }
    /** @field accessor=size.width */
    CGFloat width ()
    {
        return size.width;
    }

    CGFloat width (CGFloat width)
    {
        return size.width = width;
    }
    /** @field accessor=size.height */
    CGFloat height ()
    {
        return size.height;
    }

    CGFloat height (CGFloat height)
    {
        return size.height = height;
    }

    public String toString() {
        return Format("{}{}{}{}{}{}{}{}{}", "NSRect{" , x , "," , y , "," , width , "," , height , "}");
    }

    NSPoint origin;
    NSSize size;
}
