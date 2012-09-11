/*******************************************************************************
 * Copyright (c) 2000, 2006 IBM Corporation and others.
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
module dwt.internal.image.FileFormat;

import dwt.dwthelper.utils;


import dwt.DWT;
import dwt.dwthelper.InputStream;
import dwt.dwthelper.OutputStream;
import dwt.graphics.ImageData;
import dwt.graphics.ImageLoader;
import dwt.internal.image.GIFFileFormat;
import dwt.internal.image.JPEGFileFormat;
import dwt.internal.image.LEDataInputStream;
import dwt.internal.image.LEDataOutputStream;
import dwt.internal.image.OS2BMPFileFormat;
import dwt.internal.image.PNGFileFormat;
import dwt.internal.image.TIFFFileFormat;
import dwt.internal.image.WinBMPFileFormat;
import dwt.internal.image.WinICOFileFormat;

import tango.core.Exception;
import tango.core.Tuple;

/**
 * Abstract factory class for loading/unloading images from files or streams
 * in various image file formats.
 *
 */
public abstract class FileFormat {
    static const String FORMAT_PACKAGE = "dwt.internal.image"; //$NON-NLS-1$
    static const String FORMAT_SUFFIX = "FileFormat"; //$NON-NLS-1$
    static const String[] FORMATS = [ "WinBMP"[], "WinBMP", "GIF", "WinICO", "JPEG", "PNG", "TIFF", "OS2BMP" ]; //$NON-NLS-1$//$NON-NLS-2$ //$NON-NLS-3$ //$NON-NLS-4$//$NON-NLS-5$ //$NON-NLS-6$//$NON-NLS-7$//$NON-NLS-8$
    LEDataInputStream inputStream;
    LEDataOutputStream outputStream;
    ImageLoader loader;
    int compression;

/**
 * Return whether or not the specified input stream
 * represents a supported file format.
 */
abstract bool isFileFormat(LEDataInputStream stream);

abstract ImageData[] loadFromByteStream();

/**
 * Read the specified input stream, and return the
 * device independent image array represented by the stream.
 */
public ImageData[] loadFromStream(LEDataInputStream stream) {
    try {
        inputStream = stream;
        return loadFromByteStream();
    } catch (Exception e) {
        if (auto c = cast(IOException) e) {
            DWT.error(DWT.ERROR_IO, c);
        } else {
            DWT.error(DWT.ERROR_INVALID_IMAGE, e);
        }
        return null;
    }
}

/**
 * Read the specified input stream using the specified loader, and
 * return the device independent image array represented by the stream.
 */
public static ImageData[] load(InputStream is_, ImageLoader loader) {
    FileFormat fileFormat = null;
    LEDataInputStream stream = new LEDataInputStream(is_);
    bool isSupported = false;
    for (int i = 1; i < FORMATS.length; i++) {
        if (FORMATS[i] != null) {
            try {
                Class clazz = Class_forName(FORMAT_PACKAGE ~ '.' ~ FORMATS[i] ~ '.' ~ FORMATS[i] ~ FORMAT_SUFFIX);
                Object instance = clazz.create();
                if (cast(FileFormat) instance) {
                    fileFormat = cast(FileFormat) instance;
                    if (fileFormat.isFileFormat(stream)) {
                        isSupported = true;
                        break;
                    }
                }
            } catch (ClassNotFoundException e) {
                FORMATS[i] = null;
            } catch (Exception e) {
            }
        }
    }
    if (!isSupported) DWT.error(DWT.ERROR_UNSUPPORTED_FORMAT);
    fileFormat.loader = loader;
    return fileFormat.loadFromStream(stream);
}

/**
 * Write the device independent image array stored in the specified loader
 * to the specified output stream using the specified file format.
 */
public static void save(OutputStream os, int format, ImageLoader loader) {
    if (format < 0 || format >= FORMATS.length) DWT.error(DWT.ERROR_UNSUPPORTED_FORMAT);
    if (FORMATS[format] is null) DWT.error(DWT.ERROR_UNSUPPORTED_FORMAT);
    if (loader.data is null || loader.data.length < 1) DWT.error(DWT.ERROR_INVALID_ARGUMENT);

    LEDataOutputStream stream = new LEDataOutputStream(os);
    FileFormat fileFormat = null;
    try {
        Class clazz = Class_forName(FORMAT_PACKAGE ~ '.' ~ FORMATS[format] ~ '.' ~ FORMATS[format] ~ FORMAT_SUFFIX);
        fileFormat = cast(FileFormat) clazz.create();
    } catch (Exception e) {
        DWT.error(DWT.ERROR_UNSUPPORTED_FORMAT);
    }
    if (format is DWT.IMAGE_BMP_RLE) {
        switch (loader.data[0].depth) {
            case 8: fileFormat.compression = 1; break;
            case 4: fileFormat.compression = 2; break;
            default:
        }
    }
    fileFormat.unloadIntoStream(loader, stream);
}

abstract void unloadIntoByteStream(ImageLoader loader);

/**
 * Write the device independent image array stored in the specified loader
 * to the specified output stream.
 */
public void unloadIntoStream(ImageLoader loader, LEDataOutputStream stream) {
    try {
        outputStream = stream;
        unloadIntoByteStream(loader);
        outputStream.flush();
    } catch (Exception e) {
        try {outputStream.flush();} catch (Exception f) {}
        DWT.error(DWT.ERROR_IO, e);
    }
}
}
