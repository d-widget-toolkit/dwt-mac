/*******************************************************************************
 * Copyright (c) 2003, 2009 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *******************************************************************************/
module dwt.internal.mozilla.nsDynamicFunctionLoad;

import dwt.dwthelper.utils;

public class nsDynamicFunctionLoad {
    /** @field cast=(const char *) */
    public int /*long*/ functionName;
    /** @field cast=(NSFuncPtr  *) */
    public int /*long*/ function;
}
