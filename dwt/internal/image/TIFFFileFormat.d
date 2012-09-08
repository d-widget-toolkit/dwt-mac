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
module dwt.internal.image.TIFFFileFormat;

import dwt.DWT;
import dwt.internal.image.TIFFRandomFileAccess;
import dwt.internal.image.TIFFDirectory;
import dwt.internal.image.FileFormat;
import dwt.internal.image.LEDataInputStream;
import dwt.graphics.ImageLoader;
import dwt.graphics.ImageData;

import tango.core.Exception;

/**
 * Baseline TIFF decoder revision 6.0
 * Extension T4-encoding CCITT T.4 1D
 */
final class TIFFFileFormat : FileFormat {

override bool isFileFormat(LEDataInputStream stream) {
    try {
        byte[] header = new byte[4];
        stream.read(header);
        stream.unread(header);
        if (header[0] !is header[1]) return false;
        if (!(header[0] is 0x49 && header[2] is 42 && header[3] is 0) &&
            !(header[0] is 0x4d && header[2] is 0 && header[3] is 42)) {
            return false;
        }
        return true;
    } catch (Exception e) {
        return false;
    }
}

override ImageData[] loadFromByteStream() {
    byte[] header = new byte[8];
    bool isLittleEndian;
    ImageData[] images = new ImageData[0];
    TIFFRandomFileAccess file = new TIFFRandomFileAccess(inputStream);
    try {
        file.read(header);
        if (header[0] !is header[1]) DWT.error(DWT.ERROR_INVALID_IMAGE);
        if (!(header[0] is 0x49 && header[2] is 42 && header[3] is 0) &&
            !(header[0] is 0x4d && header[2] is 0 && header[3] is 42)) {
            DWT.error(DWT.ERROR_INVALID_IMAGE);
        }
        isLittleEndian = header[0] is 0x49;
        int offset = isLittleEndian ?
            (header[4] & 0xFF) | ((header[5] & 0xFF) << 8) | ((header[6] & 0xFF) << 16) | ((header[7] & 0xFF) << 24) :
            (header[7] & 0xFF) | ((header[6] & 0xFF) << 8) | ((header[5] & 0xFF) << 16) | ((header[4] & 0xFF) << 24);
        file.seek(offset);
        TIFFDirectory directory = new TIFFDirectory(file, isLittleEndian, loader);
        ImageData image = directory.read();
        /* A baseline reader is only expected to read the first directory */
        images = [image];
    } catch (IOException e) {
        DWT.error(DWT.ERROR_IO, e);
    }
    return images;
}

override void unloadIntoByteStream(ImageLoader loader) {
    /* We do not currently support writing multi-page tiff,
     * so we use the first image data in the loader's array. */
    ImageData image = loader.data[0];
    TIFFDirectory directory = new TIFFDirectory(image);
    try {
        directory.writeToStream(outputStream);
    } catch (IOException e) {
        DWT.error(DWT.ERROR_IO, e);
    }
}

}
