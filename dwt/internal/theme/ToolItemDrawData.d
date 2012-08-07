/*******************************************************************************
 * Copyright (c) 2000, 2006 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
b *     
 * Port to the D programming language:
 *     Jacob Carlborg <doob@me.com>
 *******************************************************************************/
module dwt.internal.theme.ToolItemDrawData;

import dwt.dwthelper.utils;
import dwt.internal.theme.DrawData;
import dwt.internal.theme.ToolBarDrawData;

public class ToolItemDrawData : DrawData {

    public ToolBarDrawData parent;

public this() {
    state = new int[2];
}

}
