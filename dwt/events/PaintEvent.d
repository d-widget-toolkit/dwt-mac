/*******************************************************************************
 * Copyright (c) 2000, 2008 IBM Corporation and others.
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
module dwt.events.PaintEvent;

import dwt.dwthelper.utils;


import dwt.events.TypedEvent;
import dwt.graphics.GC;
import dwt.widgets.Event;

import tango.text.convert.Format;

/**
 * Instances of this class are sent as a result of
 * visible areas of controls requiring re-painting.
 *
 * @see PaintListener
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */

public final class PaintEvent : TypedEvent {

    /**
     * the graphics context to use when painting
     * that is configured to use the colors, font and
     * damaged region of the control.  It is valid
     * only during the paint and must not be disposed
     */
    public GC gc;

    /**
     * the x offset of the bounding rectangle of the
     * region that requires painting
     */
    public int x;

    /**
     * the y offset of the bounding rectangle of the
     * region that requires painting
     */
    public int y;

    /**
     * the width of the bounding rectangle of the
     * region that requires painting
     */
    public int width;

    /**
     * the height of the bounding rectangle of the
     * region that requires painting
     */
    public int height;

    /**
     * the number of following paint events which
     * are pending which may always be zero on
     * some platforms
     */
    public int count;

    static const long serialVersionUID = 3256446919205992497L;

/**
 * Constructs a new instance of this class based on the
 * information in the given untyped event.
 *
 * @param e the untyped event containing the information
 */
public this(Event e) {
    super(e);
    this.gc = e.gc;
    this.x = e.x;
    this.y = e.y;
    this.width = e.width;
    this.height = e.height;
    this.count = e.count;
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the event
 */
public override String toString() {
	String string = super.toString ();
    return Format("{}{}{}{}{}{}{}{}{}{}{}{}{}{}", string[0 .. string.length() - 1] // remove trailing '}'
    	, " gc=" , gc
    	, " x=" , x
    	, " y=" , y
    	, " width=" , width
    	, " height=" , height
    	, " count=" , count
    	, "}");
}
}

