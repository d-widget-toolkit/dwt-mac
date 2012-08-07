/*******************************************************************************
 * Copyright (c) 2000, 2009 IBM Corporation and others.
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
module dwt.graphics.GCData;


import dwt.*;
import dwt.internal.cocoa.*;

import tango.core.Thread;

import dwt.dwthelper.utils;
import dwt.graphics.Device;
import dwt.graphics.Pattern;
import dwt.graphics.Image;
import dwt.graphics.Font;
import dwt.internal.c.Carbon;

/**
 * Instances of this class are descriptions of GCs in terms
 * of unallocated platform-specific data fields.
 * <p>
 * <b>IMPORTANT:</b> This class is <em>not</em> part of the public
 * API for DWT. It is marked public only so that it can be shared
 * within the packages provided by DWT. It is not available on all
 * platforms, and should never be called from application code.
 * </p>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 * @noinstantiate This class is not intended to be instantiated by clients.
 */
public final class GCData {
    public Device device;
    public int style, state = -1;
    public CGFloat[] foreground;
    public CGFloat[] background;
    public Pattern foregroundPattern;
    public Pattern backgroundPattern;
    public Font font;
    public int alpha = 0xFF;
    public CGFloat lineWidth = 0.0;
    public int lineStyle = DWT.LINE_SOLID;
    public int lineCap = DWT.CAP_FLAT;
    public int lineJoin = DWT.JOIN_MITER;
    public CGFloat lineDashesOffset = 0.0;
    public CGFloat[] lineDashes;
    public CGFloat lineMiterLimit = 10;
    public bool xorMode;
    public int antialias = DWT.DEFAULT;
    public int textAntialias = DWT.DEFAULT;
    public int fillRule = DWT.FILL_EVEN_ODD;
    public Image image;
    
    public NSColor fg, bg;
    public NSRect* paintRect;
    public NSBezierPath path;
    public NSAffineTransform transform, inverseTransform;
    public NSBezierPath clipPath, visiblePath;
    public int /*long*/ visibleRgn;
    public NSView view;
    public NSSize* size;    
    public Thread thread;
    public NSGraphicsContext flippedContext;
    public bool restoreContext;
    public NSSize sizeStruct;
    public NSRect windowRectStruct;
    public NSRect visibleRectStruct;
}
