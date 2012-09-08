/*******************************************************************************
 * Copyright (c) 20007 IBM Corporation and others.
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
module dwt.dnd.URLTransfer;

import dwt.dwthelper.utils;

import dwt.dnd.ByteArrayTransfer;
import dwt.dnd.DND;
import dwt.dnd.TransferData;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSURL;
import dwt.internal.cocoa.OS;

/**
 * The class <code>URLTransfer</code> provides a platform specific mechanism
 * for converting text in URL format represented as a java <code>String</code>
 * to a platform specific representation of the data and vice versa. The string
 * must contain a fully specified url.
 *
 * <p>An example of a java <code>String</code> containing a URL is shown below:</p>
 *
 * <code><pre>
 *     String url = "http://www.eclipse.org";
 * </code></pre>
 *
 * @see Transfer
 * @since 3.4
 */
public class URLTransfer : ByteArrayTransfer {

    static URLTransfer _instance;
    static const String URL;
    static const int URL_ID;

    static this ()
    {
        _instance = new URLTransfer();
        URL = OS.NSURLPboardType.getString();
        URL_ID = registerType(URL);
    }

private this() {}

/**
 * Returns the singleton instance of the URLTransfer class.
 *
 * @return the singleton instance of the URLTransfer class
 */
public static URLTransfer getInstance () {
    return _instance;
}

/**
 * This implementation of <code>javaToNative</code> converts a URL
 * represented by a java <code>String</code> to a platform specific representation.
 *
 * @param object a java <code>String</code> containing a URL
 * @param transferData an empty <code>TransferData</code> object that will
 *      be filled in on return with the platform specific format of the data
 *
 * @see Transfer#nativeToJava
 */
public void javaToNative (Object object, TransferData transferData){
    if (!checkURL(object) || !isSupportedType(transferData)) {
        DND.error(DND.ERROR_INVALID_DATA);
    }
    String url = stringcast(object);
    NSString nsString = NSString.stringWith(url);
    NSString escapedString = nsString.stringByAddingPercentEscapesUsingEncoding(OS.NSUTF8StringEncoding);
    transferData.data = NSURL.URLWithString(escapedString);
}

/**
 * This implementation of <code>nativeToJava</code> converts a platform
 * specific representation of a URL to a java <code>String</code>.
 *
 * @param transferData the platform specific representation of the data to be converted
 * @return a java <code>String</code> containing a URL if the conversion was successful;
 *      otherwise null
 *
 * @see Transfer#javaToNative
 */
public Object nativeToJava(TransferData transferData){
    if (!isSupportedType(transferData) || transferData.data is null) return null;
    NSURL nsUrl = cast(NSURL) transferData.data;
    NSString nsString = nsUrl.absoluteString();
    return stringcast(nsString.getString());
}

protected int[] getTypeIds(){
    return [URL_ID];
}

protected String[] getTypeNames(){
    return [URL];
}

bool checkURL(Object object) {
    auto o = stringcast(object);
    return object !is null && o && o.length() > 0;
}

protected bool validate(Object object) {
    return checkURL(object);
}
}