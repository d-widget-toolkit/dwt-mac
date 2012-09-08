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
module dwt.events.TypedEvent;

import dwt.dwthelper.utils;


import dwt.internal.SWTEventObject;
import dwt.widgets.Display;
import dwt.widgets.Event;
import dwt.widgets.Widget;

import tango.text.convert.Format;
import tango.text.Util : split;

/**
 * This is the super class for all typed event classes provided
 * by DWT. Typed events contain particular information which is
 * applicable to the event occurrence.
 *
 * @see dwt.widgets.Event
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class TypedEvent : SWTEventObject {

    /**
     * the display where the event occurred
     *
     * @since 2.0
     */
    public Display display;

    /**
     * the widget that issued the event
     */
    public Widget widget;

    /**
     * the time that the event occurred.
     *
     * NOTE: This field is an unsigned integer and should
     * be AND'ed with 0xFFFFFFFFL so that it can be treated
     * as a signed long.
     */
    public int time;

    /**
     * a field for application use
     */
    public Object data;

    static const long serialVersionUID = 3257285846578377524L;

/**
 * Constructs a new instance of this class.
 *
 * @param object the object that fired the event
 */
public this(Object object) {
    super(object);
}

/**
 * Constructs a new instance of this class based on the
 * information in the argument.
 *
 * @param e the low level event to initialize the receiver with
 */
public this(Event e) {
    super(e.widget);
    this.display = e.display;
    this.widget = e.widget;
    this.time = e.time;
    this.data = e.data;
}

/**
 * Returns the name of the event. This is the name of
 * the class without the module name.
 *
 * @return the name of the event
 */
String getName () {
	String string = this.classinfo.name;
	int index = string.lastIndexOf ('.');
	if (index == -1) return string;
	return string[index + 1 .. string.length];
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the event
 */
public override String toString() {
    return Format("{}{}{}{}{}{}{}{}", getName ()
    	, "{" , widget
    	, " time=" , time
    	, " data=" , data
    	, "}");
}
}
