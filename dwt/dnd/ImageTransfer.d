/*******************************************************************************
 * Copyright (c) 2007, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Outhink - support for typeFileURL
 *     
 * Port to the D programming language:
 *     Jacob Carlborg <doob@me.com>
 *******************************************************************************/
module dwt.dnd.ImageTransfer;

import dwt.dwthelper.utils;

import dwt.DWT;
import dwt.graphics.*;
import dwt.internal.cocoa.*;
import dwt.widgets.*;

import dwt.dnd.DND;
import dwt.dnd.ByteArrayTransfer;
import dwt.dnd.TransferData;

/**
 * The class <code>ImageTransfer</code> provides a platform specific mechanism 
 * for converting an Image represented as a java <code>ImageData</code> to a 
 * platform specific representation of the data and vice versa.  
 * 
 * <p>An example of a java <code>ImageData</code> is shown below:</p>
 * 
 * <code><pre>
 *     Image image = new Image(display, "C:\temp\img1.gif");
 *     ImageData imgData = image.getImageData();
 * </code></pre>
 *
 * @see Transfer
 * 
 * @since 3.4
 */
public class ImageTransfer : ByteArrayTransfer {

static ImageTransfer _instance;
static const String TIFF;
static const int TIFFID;

static this ()
{
    _instance = new ImageTransfer();
    TIFF = OS.NSTIFFPboardType.getString();
    TIFFID = registerType(TIFF);
}

this() {
}

/**
 * Returns the singleton instance of the ImageTransfer class.
 *
 * @return the singleton instance of the ImageTransfer class
 */
public static ImageTransfer getInstance() {
    return _instance;
}

/**
 * This implementation of <code>javaToNative</code> converts an ImageData object represented
 * by java <code>ImageData</code> to a platform specific representation.
 * 
 * @param object a java <code>ImageData</code> containing the ImageData to be converted
 * @param transferData an empty <code>TransferData</code> object that will
 *      be filled in on return with the platform specific format of the data
 * 
 * @see Transfer#nativeToJava
 */
public void javaToNative(Object object, TransferData transferData) {
    if (!checkImage(object) || !isSupportedType(transferData)) {
        DND.error(DND.ERROR_INVALID_DATA);
    }
    ImageData imgData = cast(ImageData) object;
    Image image = new Image(Display.getCurrent(), imgData);
    NSImage handle = image.handle;
    transferData.data = handle.TIFFRepresentation();
    image.dispose();
}

/**
 * This implementation of <code>nativeToJava</code> converts a platform specific 
 * representation of an image to java <code>ImageData</code>.  
 * 
 * @param transferData the platform specific representation of the data to be converted
 * @return a java <code>ImageData</code> of the image if the conversion was successful;
 *      otherwise null
 * 
 * @see Transfer#javaToNative
 */
public Object nativeToJava(TransferData transferData) {
    if (!isSupportedType(transferData) || transferData.data is null) return null;
    NSData data = cast(NSData) transferData.data;
    if (data.length() is 0) return null;
    NSImage nsImage = cast(NSImage) (new NSImage()).alloc();
    nsImage.initWithData(data);
    //TODO: Image representation wrong???
    Image image = Image.cocoa_new(Display.getCurrent(), DWT.BITMAP, nsImage);
    ImageData imageData = image.getImageData();
    image.dispose();
    return imageData;
}

protected int[] getTypeIds() {
    return [ TIFFID ];
}

protected String[] getTypeNames() {
    return [ TIFF ];
}

bool checkImage(Object object) {
    if (object is null || !(cast(ImageData) object)) return false;
    return true;
}

protected bool validate(Object object) {
    return checkImage(object);
}
}
