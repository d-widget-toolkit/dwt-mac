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
module dwt.internal.cocoa.CGPoint;

import dwt.internal.c.Carbon;

/* this shouldn't be needed but CGFloat is not recognized*/
static if ((void*).sizeof > int.sizeof) // 64bit target
    alias double CGFloat;
    
else
    alias float CGFloat;

struct CGPoint {
    CGFloat x = 0.0;
    CGFloat y = 0.0;
}