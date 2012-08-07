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
module dwt.custom.LineBackgroundEvent;

import dwt.dwthelper.utils;

import dwt.events.*;
import dwt.graphics.*;
import dwt.custom.StyledTextEvent;
import dwt.widgets.Event;

/**
 * This event is sent when a line is about to be drawn.
 *
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class LineBackgroundEvent : TypedEvent {

    /**
     * line start offset
     */
    public int lineOffset;

    /**
     * line text
     */
    public String lineText;

    /**
     * line background color
     */
    public Color lineBackground;

    static final long serialVersionUID = 3978711687853324342L;

/**
 * Constructs a new instance of this class based on the
 * information in the given event.
 *
 * @param e the event containing the information
 */
public this(StyledTextEvent e) {
    super(cast(Event)e);
    lineOffset = e.detail;
    lineText = e.text;
    lineBackground = e.lineBackground;
}
}


