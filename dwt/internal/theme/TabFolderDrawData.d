/*******************************************************************************
 * Copyright (c) 2000, 2006 IBM Corporation and others.
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
module dwt.internal.theme.TabFolderDrawData;

import dwt.DWT;
import dwt.dwthelper.utils;
import dwt.graphics.Rectangle;




import dwt.internal.theme.DrawData;

public class TabFolderDrawData : DrawData {
    public int tabsWidth;
    public int tabsHeight;
    public Rectangle tabsArea;
    public int selectedX;
    public int selectedWidth;
    public int spacing;

public this() {
    state = new int[1];
    if (DWT.getPlatform().equals("gtk")) {
        spacing = -2;
    }
}

}
