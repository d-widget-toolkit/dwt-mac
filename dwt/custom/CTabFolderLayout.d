/*******************************************************************************
 * Copyright (c) 2000, 2005 IBM Corporation and others.
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
module dwt.custom.CTabFolderLayout;

import dwt.dwthelper.utils;

import dwt.*;
import dwt.graphics.*;
import dwt.widgets.*;
import dwt.custom.CTabFolder;
import dwt.custom.CTabItem;

/**
 * This class provides the layout for CTabFolder
 *
 * @see CTabFolder
 */
class CTabFolderLayout : Layout {
protected override Point computeSize(Composite composite, int wHint, int hHint, bool flushCache) {
    CTabFolder folder = cast(CTabFolder)composite;
    CTabItem[] items = folder.items;
    // preferred width of tab area to show all tabs
    int tabW = 0;
    GC gc = new GC(folder);
    for (int i = 0; i < items.length; i++) {
        if (folder.single) {
            tabW = Math.max(tabW, items[i].preferredWidth(gc, true, false));
        } else {
            tabW += items[i].preferredWidth(gc, i is folder.selectedIndex, false);
        }
    }
    gc.dispose();
    tabW += 3;
    if (folder.showMax) tabW += CTabFolder.BUTTON_SIZE;
    if (folder.showMin) tabW += CTabFolder.BUTTON_SIZE;
    if (folder.single) tabW += 3*CTabFolder.BUTTON_SIZE/2; //chevron
    if (folder.topRight !is null) {
        Point pt = folder.topRight.computeSize(DWT.DEFAULT, folder.tabHeight, flushCache);
        tabW += 3 + pt.x;
    }
    if (!folder.single && !folder.simple) tabW += folder.curveWidth - 2*folder.curveIndent;

    int controlW = 0;
    int controlH = 0;
    // preferred size of controls in tab items
    for (int i = 0; i < items.length; i++) {
        Control control = items[i].getControl();
        if (control !is null && !control.isDisposed()){
            Point size = control.computeSize (wHint, hHint, flushCache);
            controlW = Math.max (controlW, size.x);
            controlH = Math.max (controlH, size.y);
        }
    }

    int minWidth = Math.max(tabW, controlW);
    int minHeight = (folder.minimized) ? 0 : controlH;
    if (minWidth is 0) minWidth = CTabFolder.DEFAULT_WIDTH;
    if (minHeight is 0) minHeight = CTabFolder.DEFAULT_HEIGHT;

    if (wHint !is DWT.DEFAULT) minWidth  = wHint;
    if (hHint !is DWT.DEFAULT) minHeight = hHint;

    return new Point (minWidth, minHeight);
}
protected override bool flushCache(Control control) {
    return true;
}
protected override void layout(Composite composite, bool flushCache) {
    CTabFolder folder = cast(CTabFolder)composite;
    // resize content
    if (folder.selectedIndex !is -1) {
        Control control = folder.items[folder.selectedIndex].getControl();
        if (control !is null && !control.isDisposed()) {
            control.setBounds(folder.getClientArea());
        }
    }
}
}
