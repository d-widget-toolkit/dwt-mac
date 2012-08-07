/*******************************************************************************
 * Copyright (c) 2000, 2005 IBM Corporation and others.
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
module dwt.internal.image.JPEGAppn;

import dwt.internal.image.JPEGVariableSizeSegment;
import dwt.internal.image.JPEGFileFormat;
import dwt.internal.image.LEDataInputStream;

final class JPEGAppn : JPEGVariableSizeSegment {

    public this(byte[] reference) {
        super(reference);
    }

    public this(LEDataInputStream byteStream) {
        super(byteStream);
    }

    public override bool verify() {
        int marker = getSegmentMarker();
        return marker >= JPEGFileFormat.APP0 && marker <= JPEGFileFormat.APP15;
    }
}
