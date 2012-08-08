﻿/*******************************************************************************
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
module dwt.dnd.DragSourceEvent;

import dwt.dwthelper.utils;

import dwt.events.TypedEvent;


import dwt.dnd.DNDEvent;
import dwt.dnd.TransferData;
import dwt.widgets.Event;

/**
 * The DragSourceEvent contains the event information passed in the methods of the DragSourceListener.
 *
 * @see DragSourceListener
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class DragSourceEvent : TypedEvent {
    /**
     * The operation that was performed.
     * @see DND#DROP_NONE
     * @see DND#DROP_MOVE
     * @see DND#DROP_COPY
     * @see DND#DROP_LINK
     * @see DND#DROP_TARGET_MOVE
     */
    public int detail;

    /**
     * In dragStart, the doit field determines if the drag and drop operation
     * should proceed; in dragFinished, the doit field indicates whether
     * the operation was performed successfully.
     * <p></p>
     * In dragStart:
     * <p>Flag to determine if the drag and drop operation should proceed.
     * The application can set this value to false to prevent the drag from starting.
     * Set to true by default.</p>
     * <p>In dragSetData:</p>
     * <p>This will be set to true when the call to dragSetData is made.  Set it to
     * false to cancel the drag.</p>
     * <p>In dragFinished:</p>
     * <p>Flag to indicate if the operation was performed successfully.
     * True if the operation was performed successfully.</p>
     */
    public bool doit;

    /**
     * In dragStart, the x coordinate (relative to the control) of the
     * position the mouse went down to start the drag.
     *
     * @since 3.2
     */
    public int x;
    /**
     * In dragStart, the y coordinate (relative to the control) of the
     * position the mouse went down to start the drag.
     *
     * @since 3.2
     */
    public int y;

    /**
     * The type of data requested.
     * Data provided in the data field must be of the same type.
     */
    public TransferData dataType;

    /**
     * The drag source image to be displayed during the drag.
     * <p>A value of null indicates that no drag image will be displayed.</p>
     * <p>The default value is null.</p>
     *
     * @since 3.3
     */
    public Image image;

    /**
     * In dragStart, the x offset (relative to the image) where the drag source image will be displayed.
     *
     * @since 3.5
     */
    public int offsetX;
    /**
     * In dragStart, the y offset (relative to the image) where the drag source image will be displayed.
     *
     * @since 3.5
     */
    public int offsetY;

    static const long serialVersionUID = 3257002142513770808L;

/**
 * Constructs a new instance of this class based on the
 * information in the given untyped event.
 *
 * @param e the untyped event containing the information
 */
public this(DNDEvent e) {
    super(cast(Event) e);
    this.data = e.data;
    this.detail = e.detail;
    this.doit = e.doit;
    this.dataType = e.dataType;
    this.x = e.x;
    this.y = e.y;
    this.image = e.image;
    this.offsetX = e.offsetX;
    this.offsetY = e.offsetY;
}
void updateEvent(DNDEvent e) {
    e.widget = this.widget;
    e.time = this.time;
    e.data = this.data;
    e.detail = this.detail;
    e.doit = this.doit;
    e.dataType = this.dataType;
    e.x = this.x;
    e.y = this.y;
    e.image = this.image;
    e.offsetX = this.offsetX;
    e.offsetY = this.offsetY;
}
/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the event
 */
public String toString() {
    String string = super.toString ();
    return Format("{}{}{}{}{}{}{}", string.substring (0, string.length() - 1) // remove trailing '}'
        , " operation=" , detail
        , " type=" , (dataType !is null ? dataType.type : 0)
        , " doit=" , doit
        , "}");
}
}
