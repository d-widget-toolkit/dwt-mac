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
module dwt.custom.PaintObjectEvent;


import dwt.events.*;
import dwt.graphics.*;
import dwt.custom.StyleRange;
import dwt.custom.Bullet;
import dwt.custom.StyledTextEvent;
import dwt.widgets.Event;

/**
 * This event is sent when an object needs to be drawn.
 *
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.2
 */
public class PaintObjectEvent : TypedEvent {

    /**
     * the GC
     */
    public GC gc;

    /**
     * the x location
     */
    public int x;

    /**
     * the y location
     */
    public int y;

    /**
     * the line ascent
     */
    public int ascent;

    /**
     * the line descent
     */
    public int descent;

    /**
     * the StyleRange
     */
    public StyleRange style;

    /**
     * the Bullet
     */
    public Bullet bullet;

    /**
     * the bullet index
     */
    public int bulletIndex;

    static final long serialVersionUID = 3906081274027192855L;

/**
 * Constructs a new instance of this class based on the
 * information in the given event.
 *
 * @param e the event containing the information
 */
public this(StyledTextEvent e) {
    super(cast(Event)e);
    gc = e.gc;
    x = e.x;
    y = e.y;
    ascent = e.ascent;
    descent = e.descent;
    style = e.style;
    bullet = e.bullet;
    bulletIndex = e.bulletIndex;
}
}
