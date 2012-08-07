﻿/*******************************************************************************
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
module dwt.events.MenuDetectEvent;


import dwt.widgets.Event;
import dwt.events.TypedEvent;

import tango.text.convert.Format;
import dwt.dwthelper.utils;

/**
 * Instances of this class are sent whenever the platform-
 * specific trigger for showing a context menu is detected.
 *
 * @see MenuDetectListener
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.3
 */

public final class MenuDetectEvent : TypedEvent {

    /**
     * the display-relative x coordinate of the pointer
     * at the time the context menu trigger occurred
     */
    public int x;

    /**
     * the display-relative y coordinate of the pointer
     * at the time the context menu trigger occurred
     */
    public int y;

    /**
     * A flag indicating whether the operation should be allowed.
     * Setting this field to <code>false</code> will cancel the operation.
     */
    public bool doit;

    //private static final long serialVersionUID = -3061660596590828941L;

/**
 * Constructs a new instance of this class based on the
 * information in the given untyped event.
 *
 * @param e the untyped event containing the information
 */
public this(Event e) {
    super(e);
    this.x = e.x;
    this.y = e.y;
    this.doit = e.doit;
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the event
 */
public override String toString() {
    return Format( "{} x={} y={} doit={}}", super.toString[ 0 .. $-2 ], x, y, doit );
}
}
