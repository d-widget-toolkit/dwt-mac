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
module dwt.browser.LocationEvent;

import tango.text.convert.Format;



import dwt.dwthelper.utils;

/**
 * A <code>LocationEvent</code> is sent by a {@link Browser} to
 * {@link LocationListener}'s when the <code>Browser</code>
 * navigates to a different URL. This notification typically
 * occurs when the application navigates to a new location with
 * {@link Browser#setUrl(String)} or when the user activates a
 * hyperlink.
 *
 * @since 3.0
 */
public class LocationEvent : TypedEvent {
    /** current location */
    public String location;

    /**
     * A flag indicating whether the location opens in the top frame
     * or not.
     */
    public bool top;

    /**
     * A flag indicating whether the location loading should be allowed.
     * Setting this field to <code>false</code> will cancel the operation.
     */
    public bool doit;

    static final long serialVersionUID = 3906644198244299574L;

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
    return Format( "{} {location = {}, top = {}, doit = {}}",
        super.toString[1 .. $-2], location, top, doit );
}
}
