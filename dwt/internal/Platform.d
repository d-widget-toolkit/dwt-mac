/*******************************************************************************
 * Copyright (c) 2000, 2008 IBM Corporation and others.
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
module dwt.internal.Platform;

import dwt.dwthelper.utils;
import dwt.internal.Lock;

public class Platform {
    
public static const String PLATFORM = "cocoa"; //$NON-NLS-1$
public static const Lock lock;
    
    static this ()
    {
        lock = new Lock ();
    }
}
