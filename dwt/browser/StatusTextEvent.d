/*******************************************************************************
 * Copyright (c) 2003, 2009 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *      John Reimer <terminal.node@gmail.com>
 *******************************************************************************/
module dwt.browser.StatusTextEvent;

import tango.text.convert.Format;

import dwt.dwthelper.utils;




/**
 * A <code>StatusTextEvent</code> is sent by a {@link Browser} to
 * {@link StatusTextListener}'s when the status text is changed.
 * The status text is typically displayed in the status bar of
 * a browser application.
 *
 * @since 3.0
 */
public class StatusTextEvent : TypedEvent {
    /** status text */
    public String text;

    static final long serialVersionUID = 3258407348371600439L;

/**
 * Constructs a new instance of this class.
 *
 * @param widget the widget that fired the event
 *
 * @since 3.5
 */
public this(Widget widget) {
    super(widget);
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the event
 */
public override String toString() {
    return Format( "{} {text = {}}",
        super.toString[1 .. $-2], text );
}

}
