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
module dwt.internal.image.JPEGStartOfImage;

import dwt.internal.image.JPEGFixedSizeSegment;
import dwt.internal.image.LEDataInputStream;
import dwt.internal.image.JPEGFileFormat;

final class JPEGStartOfImage : JPEGFixedSizeSegment {

    public this() {
        super();
    }

    public this(byte[] reference) {
        super(reference);
    }

    public this(LEDataInputStream byteStream) {
        super(byteStream);
    }

    public override int signature() {
        return JPEGFileFormat.SOI;
    }

    public override int fixedSize() {
        return 2;
    }
}
