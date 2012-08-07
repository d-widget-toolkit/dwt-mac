/*******************************************************************************
 * Copyright (c) 2000, 2008 IBM Corporation and others.
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
module dwt.dnd.DNDEvent;

import dwt.dwthelper.utils;


import dwt.graphics.*;
import dwt.widgets.*;

import dwt.dnd.TransferData;

class DNDEvent : Event {
    public TransferData dataType;
    public TransferData[] dataTypes;
    public int operations;
    public int feedback;
    public Image image;
    public int offsetX;
    public int offsetY;
}
