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
module dwt.internal.theme.DrawData;

import dwt.dwthelper.utils;

import dwt.graphics.*;

import dwt.internal.theme.Theme;

public class DrawData {
    public int style;
    public int[] state;
    public Rectangle clientArea;

    /** Part states */
    public static const int SELECTED = 1 << 1;
    public static const int FOCUSED = 1 << 2;
    public static const int PRESSED = 1 << 3;
    public static const int ACTIVE = 1 << 4;
    public static const int DISABLED = 1 << 5;
    public static const int HOT = 1 << 6;
    public static const int DEFAULTED = 1 << 7;
    public static const int GRAYED = 1 << 8;

    /** Text and Image drawing flags */
    public static const int DRAW_LEFT = 1 << 4;
    public static const int DRAW_TOP = 1 << 5;
    public static const int DRAW_RIGHT = 1 << 6;
    public static const int DRAW_BOTTOM = 1 << 7;
    public static const int DRAW_HCENTER = 1 << 8;
    public static const int DRAW_VCENTER = 1 << 9;

    /** Widget parts */
    public static const int WIDGET_NOWHERE = -1;
    public static const int WIDGET_WHOLE = 0;

    /** Scrollbar parts */
    public static const int SCROLLBAR_UP_ARROW = 1;
    public static const int SCROLLBAR_DOWN_ARROW = 2;
    public static const int SCROLLBAR_LEFT_ARROW = SCROLLBAR_UP_ARROW;
    public static const int SCROLLBAR_RIGHT_ARROW = SCROLLBAR_DOWN_ARROW;
    public static const int SCROLLBAR_UP_TRACK = 3;
    public static const int SCROLLBAR_DOWN_TRACK = 4;
    public static const int SCROLLBAR_LEFT_TRACK = SCROLLBAR_UP_TRACK;
    public static const int SCROLLBAR_RIGHT_TRACK = SCROLLBAR_DOWN_TRACK;
    public static const int SCROLLBAR_THUMB = 5;

    /** Scale parts */
    public static const int SCALE_UP_TRACK = 1;
    public static const int SCALE_LEFT_TRACK = SCALE_UP_TRACK;
    public static const int SCALE_DOWN_TRACK = 2;
    public static const int SCALE_RIGHT_TRACK = SCALE_DOWN_TRACK;
    public static const int SCALE_THUMB = 3;

    /** ToolItem parts */
    public static const int TOOLITEM_ARROW = 1;

    /** Combo parts */
    public static const int COMBO_ARROW = 1;
    

public this() {
    state = new int[1];
}

Rectangle computeTrim(Theme theme, GC gc) {
    return new Rectangle(clientArea.x, clientArea.y, clientArea.width, clientArea.height);
}

void draw(Theme theme, GC gc, Rectangle bounds) {   
}

void drawImage(Theme theme, Image image, GC gc, Rectangle bounds) {
}

void drawText(Theme theme, String text, int flags, GC gc, Rectangle bounds) {
}

Rectangle getBounds(int part, Rectangle bounds) {
    return new Rectangle(bounds.x, bounds.y, bounds.width, bounds.height);
}

int hit(Theme theme, Point position, Rectangle bounds) {
    return bounds.contains(position) ? DrawData.WIDGET_WHOLE : DrawData.WIDGET_NOWHERE;
}

Rectangle measureText(Theme theme, String text, int flags, GC gc, Rectangle bounds) {
    return new Rectangle(0, 0, 0, 0);
}

}
