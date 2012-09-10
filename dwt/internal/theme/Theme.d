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
module dwt.internal.theme.Theme;

import dwt.DWT;
import dwt.dwthelper.utils;
import dwt.graphics.Image;
import dwt.graphics.Rectangle;
import dwt.graphics.Point;
import dwt.graphics.GC;
import dwt.graphics.Device;




import dwt.internal.theme.DrawData;
import dwt.internal.theme.RangeDrawData;

public class Theme {
    Device device;

public this(Device device) {
    this.device = device;
}

void checkTheme() {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
}

public Rectangle computeTrim(GC gc, DrawData data) {
    if (gc is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (data is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (gc.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    return data.computeTrim(this, gc);
}

public void dispose () {
    device = null;
}

public void drawBackground(GC gc, Rectangle bounds, DrawData data) {
    checkTheme();
    if (gc is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (bounds is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (data is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (gc.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    data.draw(this, gc, bounds);
}

public void drawFocus(GC gc, Rectangle bounds, DrawData data) {
    checkTheme();
    if (gc is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (bounds is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (data is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (gc.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    gc.drawFocus(bounds.x, bounds.y, bounds.width, bounds.height);
}

public void drawImage(GC gc, Rectangle bounds, DrawData data, Image image, int flags) {
    checkTheme();
    if (gc is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (bounds is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (data is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (image is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (gc.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    data.drawImage(this, image, gc, bounds);
}

public void drawText(GC gc, Rectangle bounds, DrawData data, String text, int flags) {
    checkTheme();
    if (gc is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (bounds is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (data is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (text is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (gc.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    data.drawText(this, text, flags, gc, bounds);
}

public Rectangle getBounds(int part, Rectangle bounds, DrawData data) {
    checkTheme();
    if (bounds is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (data is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    return data.getBounds(part, bounds);
}

public int getSelection(Point offset, Rectangle bounds, RangeDrawData data) {
    checkTheme();
    if (offset is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (bounds is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (data is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    return data.getSelection(offset, bounds);
}

public int hitBackground(Point position, Rectangle bounds, DrawData data) {
    checkTheme();
    if (position is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (bounds is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (data is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    return data.hit(this, position, bounds);
}

public bool isDisposed() {
    return device is null;
}

public Rectangle measureText(GC gc, Rectangle bounds, DrawData data, String text, int flags) {
    checkTheme();
    if (gc is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (data is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    // DWT extension: allow null for zero length string
    //if (text is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (gc.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    return data.measureText(this, text, flags, gc, bounds);
}
}
