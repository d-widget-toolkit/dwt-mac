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
module dwt.dnd.HTMLTransfer;

import dwt.dwthelper.utils;

import dwt.dnd.ByteArrayTransfer;
import dwt.dnd.DND;
import dwt.dnd.TransferData;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.OS;

/**
 * The class <code>HTMLTransfer</code> provides a platform specific mechanism
 * for converting text in HTML format represented as a java <code>String</code>
 * to a platform specific representation of the data and vice versa.
 *
 * <p>An example of a java <code>String</code> containing HTML text is shown
 * below:</p>
 *
 * <code><pre>
 *     String htmlData = "<p>This is a paragraph of text.</p>";
 * </code></pre>
 *
 * @see Transfer
 */
public class HTMLTransfer : ByteArrayTransfer {

    static HTMLTransfer _instance;
    static const String HTML;
    static const int HTMLID;

    static this ()
    {
        _instance = new HTMLTransfer();
        HTML = OS.NSHTMLPboardType.getString();
        HTMLID = registerType(HTML);
    }

this() {}

/**
 * Returns the singleton instance of the HTMLTransfer class.
 *
 * @return the singleton instance of the HTMLTransfer class
 */
public static HTMLTransfer getInstance () {
    return _instance;
}

/**
 * This implementation of <code>javaToNative</code> converts HTML-formatted text
 * represented by a java <code>String</code> to a platform specific representation.
 *
 * @param object a java <code>String</code> containing HTML text
 * @param transferData an empty <code>TransferData</code> object that will
 *      be filled in on return with the platform specific format of the data
 *
 * @see Transfer#nativeToJava
 */
public void javaToNative (Object object, TransferData transferData){
    if (!checkHTML(object) || !isSupportedType(transferData)) {
        DND.error(DND.ERROR_INVALID_DATA);
    }
    transferData.data = NSString.stringWith(stringcast(object));
}

/**
 * This implementation of <code>nativeToJava</code> converts a platform specific
 * representation of HTML text to a java <code>String</code>.
 *
 * @param transferData the platform specific representation of the data to be converted
 * @return a java <code>String</code> containing HTML text if the conversion was successful;
 *      otherwise null
 *
 * @see Transfer#javaToNative
 */
public Object nativeToJava(TransferData transferData){
    if (!isSupportedType(transferData) || transferData.data is null) return null;
    NSString string = cast(NSString) transferData.data;
    return stringcast(string.getString());
}

protected int[] getTypeIds() {
    return [HTMLID];
}

protected String[] getTypeNames() {
    return [HTML];
}

bool checkHTML(Object object) {
    auto o = stringcast(object);
    return (object !is null && o && o.length() > 0);
}

protected bool validate(Object object) {
    return checkHTML(object);
}
}
