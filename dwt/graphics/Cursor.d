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
module dwt.graphics.Cursor;

import dwt.dwthelper.utils;


import dwt.DWT;
import dwt.DWTError;
import dwt.graphics.Device;
import dwt.graphics.ImageData;
import dwt.graphics.PaletteData;
import dwt.graphics.Resource;
import dwt.graphics.RGB;
import dwt.internal.cocoa.NSAutoreleasePool;
import dwt.internal.cocoa.NSBitmapImageRep;
import dwt.internal.cocoa.NSCursor;
import dwt.internal.cocoa.NSImage;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSThread;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;

import tango.text.convert.Format;

/**
 * Instances of this class manage operating system resources that
 * specify the appearance of the on-screen pointer. To create a
 * cursor you specify the device and either a simple cursor style
 * describing one of the standard operating system provided cursors
 * or the image and mask data for the desired appearance.
 * <p>
 * Application code must explicitly invoke the <code>Cursor.dispose()</code>
 * method to release the operating system resources managed by each instance
 * when those instances are no longer required.
 * </p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>
 *   CURSOR_ARROW, CURSOR_WAIT, CURSOR_CROSS, CURSOR_APPSTARTING, CURSOR_HELP,
 *   CURSOR_SIZEALL, CURSOR_SIZENESW, CURSOR_SIZENS, CURSOR_SIZENWSE, CURSOR_SIZEWE,
 *   CURSOR_SIZEN, CURSOR_SIZES, CURSOR_SIZEE, CURSOR_SIZEW, CURSOR_SIZENE, CURSOR_SIZESE,
 *   CURSOR_SIZESW, CURSOR_SIZENW, CURSOR_UPARROW, CURSOR_IBEAM, CURSOR_NO, CURSOR_HAND
 * </dd>
 * </dl>
 * <p>
 * Note: Only one of the above styles may be specified.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#cursor">Cursor snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */

public final class Cursor : Resource {

    alias Resource.init_ init_;
    static const byte[] WAIT_SOURCE = [
        cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00,
        cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00,
        cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00,
        cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00,
        cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00,
        cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00,
        cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00,
        cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00,
        cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00,
        cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00,
        cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00,
        cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00,
        cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00,
        cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00,
        cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0xFF, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00,
        cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00
    ];

    /**
     * the handle to the OS cursor resource
     * (Warning: This field is platform dependent)
     * <p>
     * <b>IMPORTANT:</b> This field is <em>not</em> part of the DWT
     * public API. It is marked public only so that it can be shared
     * within the packages provided by DWT. It is not available on all
     * platforms and should never be accessed from application code.
     * </p>
     */
    public NSCursor handle;

/**
 * Prevents uninitialized instances from being created outside the package.
 */
this(Device device) {
    super(device);
}

/**
 * Constructs a new cursor given a device and a style
 * constant describing the desired cursor appearance.
 * <p>
 * You must dispose the cursor when it is no longer required.
 * </p>
 *
 * @param device the device on which to allocate the cursor
 * @param style the style of cursor to allocate
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if device is null and there is no current device</li>
 *    <li>ERROR_INVALID_ARGUMENT - when an unknown style is specified</li>
 * </ul>
 * @exception DWTError <ul>
 *    <li>ERROR_NO_HANDLES - if a handle could not be obtained for cursor creation</li>
 * </ul>
 *
 * @see DWT#CURSOR_ARROW
 * @see DWT#CURSOR_WAIT
 * @see DWT#CURSOR_CROSS
 * @see DWT#CURSOR_APPSTARTING
 * @see DWT#CURSOR_HELP
 * @see DWT#CURSOR_SIZEALL
 * @see DWT#CURSOR_SIZENESW
 * @see DWT#CURSOR_SIZENS
 * @see DWT#CURSOR_SIZENWSE
 * @see DWT#CURSOR_SIZEWE
 * @see DWT#CURSOR_SIZEN
 * @see DWT#CURSOR_SIZES
 * @see DWT#CURSOR_SIZEE
 * @see DWT#CURSOR_SIZEW
 * @see DWT#CURSOR_SIZENE
 * @see DWT#CURSOR_SIZESE
 * @see DWT#CURSOR_SIZESW
 * @see DWT#CURSOR_SIZENW
 * @see DWT#CURSOR_UPARROW
 * @see DWT#CURSOR_IBEAM
 * @see DWT#CURSOR_NO
 * @see DWT#CURSOR_HAND
 */
public this(Device device, int style) {
    super(device);
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        switch (style) {
            case DWT.CURSOR_HAND:           handle = NSCursor.pointingHandCursor(); break;
            case DWT.CURSOR_ARROW:          handle = NSCursor.arrowCursor(); break;
            case DWT.CURSOR_WAIT:           break;
            case DWT.CURSOR_CROSS:          handle = NSCursor.crosshairCursor(); break;
            case DWT.CURSOR_APPSTARTING:    handle = NSCursor.arrowCursor(); break;
            case DWT.CURSOR_HELP:           handle = NSCursor.crosshairCursor(); break;
            case DWT.CURSOR_SIZEALL:        handle = NSCursor.crosshairCursor(); break;
            case DWT.CURSOR_SIZENESW:       handle = NSCursor.crosshairCursor(); break;
            case DWT.CURSOR_SIZENS:         handle = NSCursor.resizeUpDownCursor(); break;
            case DWT.CURSOR_SIZENWSE:       handle = NSCursor.crosshairCursor(); break;
            case DWT.CURSOR_SIZEWE:         handle = NSCursor.resizeLeftRightCursor(); break;
            case DWT.CURSOR_SIZEN:          handle = NSCursor.resizeUpCursor(); break;
            case DWT.CURSOR_SIZES:          handle = NSCursor.resizeDownCursor(); break;
            case DWT.CURSOR_SIZEE:          handle = NSCursor.resizeRightCursor(); break;
            case DWT.CURSOR_SIZEW:          handle = NSCursor.resizeLeftCursor(); break;
            case DWT.CURSOR_SIZENE:         handle = NSCursor.crosshairCursor(); break;
            case DWT.CURSOR_SIZESE:         handle = NSCursor.crosshairCursor(); break;
            case DWT.CURSOR_SIZESW:         handle = NSCursor.crosshairCursor(); break;
            case DWT.CURSOR_SIZENW:         handle = NSCursor.crosshairCursor(); break;
            case DWT.CURSOR_UPARROW:        handle = NSCursor.crosshairCursor(); break;
            case DWT.CURSOR_IBEAM:          handle = NSCursor.IBeamCursor(); break;
            case DWT.CURSOR_NO:             handle = NSCursor.crosshairCursor(); break;
            default:
                DWT.error(DWT.ERROR_INVALID_ARGUMENT);
        }
        if (handle is null && style is DWT.CURSOR_WAIT) {
            NSImage nsImage = cast(NSImage)(new NSImage()).alloc();
            NSBitmapImageRep nsImageRep = cast(NSBitmapImageRep)(new NSBitmapImageRep()).alloc();
            handle = cast(NSCursor)(new NSCursor()).alloc();
            int width = 16, height = 16;
            NSSize size = NSSize();
            size.width = width;
            size.height =  height;
            nsImage = nsImage.initWithSize(size);
            nsImageRep = nsImageRep.initWithBitmapDataPlanes(null, width, height, 8, 4, true, false, OS.NSDeviceRGBColorSpace,
                    OS.NSAlphaFirstBitmapFormat | OS.NSAlphaNonpremultipliedBitmapFormat, width*4, 32);
            OS.memmove(nsImageRep.bitmapData(), WAIT_SOURCE.ptr, WAIT_SOURCE.length);
            nsImage.addRepresentation(nsImageRep);
            NSPoint point = NSPoint();
            point.x = 0;
            point.y = 0;
            handle = handle.initWithImage(nsImage, point);
            nsImageRep.release();
            nsImage.release();
        } else {
            handle.retain();
        }
        handle.setOnMouseEntered(true);
        init_();
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Constructs a new cursor given a device, image and mask
 * data describing the desired cursor appearance, and the x
 * and y coordinates of the <em>hotspot</em> (that is, the point
 * within the area covered by the cursor which is considered
 * to be where the on-screen pointer is "pointing").
 * <p>
 * The mask data is allowed to be null, but in this case the source
 * must be an ImageData representing an icon that specifies both
 * color data and mask data.
 * <p>
 * You must dispose the cursor when it is no longer required.
 * </p>
 *
 * @param device the device on which to allocate the cursor
 * @param source the color data for the cursor
 * @param mask the mask data for the cursor (or null)
 * @param hotspotX the x coordinate of the cursor's hotspot
 * @param hotspotY the y coordinate of the cursor's hotspot
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if device is null and there is no current device</li>
 *    <li>ERROR_NULL_ARGUMENT - if the source is null</li>
 *    <li>ERROR_NULL_ARGUMENT - if the mask is null and the source does not have a mask</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the source and the mask are not the same
 *          size, or if the hotspot is outside the bounds of the image</li>
 * </ul>
 * @exception DWTError <ul>
 *    <li>ERROR_NO_HANDLES - if a handle could not be obtained for cursor creation</li>
 * </ul>
 */
public this(Device device, ImageData source, ImageData mask, int hotspotX, int hotspotY) {
    super(device);
    if (source is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (mask is null) {
        if (source.getTransparencyType() !is DWT.TRANSPARENCY_MASK) {
            DWT.error(DWT.ERROR_NULL_ARGUMENT);
        }
        mask = source.getTransparencyMask();
    }
    /* Check the bounds. Mask must be the same size as source */
    if (mask.width !is source.width || mask.height !is source.height) {
        DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    }
    /* Check the hotspots */
    if (hotspotX >= source.width || hotspotX < 0 ||
        hotspotY >= source.height || hotspotY < 0) {
        DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    }
    byte[] data = new byte[source.width * source.height * 4];
    for (int y = 0; y < source.height; y++) {
        int offset = y * source.width * 4;
        for (int x = 0; x < source.width; x++) {
            int pixel = source.getPixel(x, y);
            int maskPixel = mask.getPixel(x, y);
            if (pixel is 0 && maskPixel is 0) {
                // BLACK
                data[offset] = cast(byte)0xFF;
            } else if (pixel is 0 && maskPixel is 1) {
                // WHITE - cursor color
                data[offset] = data[offset + 1] = data[offset + 2] = data[offset + 3] = cast(byte)0xFF;
            } else if (pixel is 1 && maskPixel is 0) {
                // SCREEN
            } else {
                /*
                * Feature in the Macintosh. It is not possible to have
                * the reverse screen case using NSCursor.
                * Reverse screen will be the same as screen.
                */
                // REVERSE SCREEN -> SCREEN
            }
            offset += 4;
        }
    }
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        createNSCursor(hotspotX, hotspotY, data, source.width, source.height);
        init_();
    } finally {
        if (pool !is null) pool.release();
    }
}

void createNSCursor(int hotspotX, int hotspotY, byte[] buffer, int width, int height) {
    NSImage nsImage = cast(NSImage)(new NSImage()).alloc();
    NSBitmapImageRep nsImageRep = cast(NSBitmapImageRep)(new NSBitmapImageRep()).alloc();
    handle = cast(NSCursor)(new NSCursor()).alloc();
    NSSize size = NSSize();
    size.width = width;
    size.height =  height;
    nsImage = nsImage.initWithSize(size);
    nsImageRep = nsImageRep.initWithBitmapDataPlanes(null, width, height,
            8, 4, true, false, OS.NSDeviceRGBColorSpace,
            OS.NSAlphaFirstBitmapFormat | OS.NSAlphaNonpremultipliedBitmapFormat, width * 4, 32);
    OS.memmove(cast(void*) nsImageRep.bitmapData(), buffer.ptr, buffer.length);
    nsImage.addRepresentation(nsImageRep);
    NSPoint point = NSPoint();
    point.x = hotspotX;
    point.y = hotspotY;
    handle = handle.initWithImage(nsImage, point);
    nsImageRep.release();
    nsImage.release();
}

/**
 * Constructs a new cursor given a device, image data describing
 * the desired cursor appearance, and the x and y coordinates of
 * the <em>hotspot</em> (that is, the point within the area
 * covered by the cursor which is considered to be where the
 * on-screen pointer is "pointing").
 * <p>
 * You must dispose the cursor when it is no longer required.
 * </p>
 *
 * @param device the device on which to allocate the cursor
 * @param source the image data for the cursor
 * @param hotspotX the x coordinate of the cursor's hotspot
 * @param hotspotY the y coordinate of the cursor's hotspot
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if device is null and there is no current device</li>
 *    <li>ERROR_NULL_ARGUMENT - if the image is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the hotspot is outside the bounds of the
 *       image</li>
 * </ul>
 * @exception DWTError <ul>
 *    <li>ERROR_NO_HANDLES - if a handle could not be obtained for cursor creation</li>
 * </ul>
 *
 * @since 3.0
 */
public this(Device device, ImageData source, int hotspotX, int hotspotY) {
    super(device);
    if (source is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (hotspotX >= source.width || hotspotX < 0 ||
        hotspotY >= source.height || hotspotY < 0) {
        DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    }
    byte[] data = new byte[source.width * source.height * 4];
    PaletteData palette = source.palette;
    if (palette.isDirect) {
        ImageData.blit(ImageData.BLIT_SRC,
            source.data, source.depth, source.bytesPerLine, source.getByteOrder(), 0, 0, source.width, source.height, palette.redMask, palette.greenMask, palette.blueMask,
            ImageData.ALPHA_OPAQUE, null, 0, 0, 0,
            data, 32, source.width * 4, ImageData.MSB_FIRST, 0, 0, source.width, source.height, 0xFF0000, 0xFF00, 0xFF,
            false, false);
    } else {
        RGB[] rgbs = palette.getRGBs();
        int length = rgbs.length;
        byte[] srcReds = new byte[length];
        byte[] srcGreens = new byte[length];
        byte[] srcBlues = new byte[length];
        for (int i = 0; i < rgbs.length; i++) {
            RGB rgb = rgbs[i];
            if (rgb is null) continue;
            srcReds[i] = cast(byte)rgb.red;
            srcGreens[i] = cast(byte)rgb.green;
            srcBlues[i] = cast(byte)rgb.blue;
        }
        ImageData.blit(ImageData.BLIT_SRC,
            source.data, source.depth, source.bytesPerLine, source.getByteOrder(), 0, 0, source.width, source.height, srcReds, srcGreens, srcBlues,
            ImageData.ALPHA_OPAQUE, null, 0, 0, 0,
            data, 32, source.width * 4, ImageData.MSB_FIRST, 0, 0, source.width, source.height, 0xFF0000, 0xFF00, 0xFF,
            false, false);
    }
    if (source.maskData !is null || source.transparentPixel !is -1) {
        ImageData mask = source.getTransparencyMask();
        byte[] maskData = mask.data;
        int maskBpl = mask.bytesPerLine;
        int offset = 0, maskOffset = 0;
        for (int y = 0; y<source.height; y++) {
            for (int x = 0; x<source.width; x++) {
                data[offset] = ((maskData[maskOffset + (x >> 3)]) & (1 << (7 - (x & 0x7)))) !is 0 ? cast(byte)0xff : 0;
                offset += 4;
            }
            maskOffset += maskBpl;
        }
    } else if (source.alpha !is -1) {
        byte alpha = cast(byte)source.alpha;
        for (int i=0; i<data.length; i+=4) {
            data[i] = alpha;
        }
    } else if (source.alphaData !is null) {
        byte[] alphaData = source.alphaData;
        for (int i=0; i<data.length; i+=4) {
            data[i] = alphaData[i/4];
        }
    }
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        createNSCursor(hotspotX, hotspotY, data, source.width, source.height);
        init_();
    } finally {
        if (pool !is null) pool.release();
    }
}

void destroy() {
    handle.release();
    handle = null;
}

/**
 * Compares the argument to the receiver, and returns true
 * if they represent the <em>same</em> object using a class
 * specific comparison.
 *
 * @param object the object to compare with this object
 * @return <code>true</code> if the object is the same as this object and <code>false</code> otherwise
 *
 * @see #hashCode
 */
public int opEquals (Object object) {
    if (object is this) return true;
    if (!( null !is cast(Cursor)object )) return false;
    Cursor cursor = cast(Cursor) object;
    return device is cursor.device && handle is cursor.handle;
}

alias opEquals equals;

/**
 * Returns an integer hash code for the receiver. Any two
 * objects that return <code>true</code> when passed to
 * <code>equals</code> must return the same value for this
 * method.
 *
 * @return the receiver's hash
 *
 * @see #equals
 */
public hash_t toHash () {
    return handle !is null ? cast(hash_t) handle.id : 0;
}

alias toHash hashCode;

/**
 * Returns <code>true</code> if the cursor has been disposed,
 * and <code>false</code> otherwise.
 * <p>
 * This method gets the dispose state for the cursor.
 * When a cursor has been disposed, it is an error to
 * invoke any other method using the cursor.
 *
 * @return <code>true</code> when the cursor is disposed and <code>false</code> otherwise
 */
public bool isDisposed() {
    return handle is null;
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the receiver
 */
public String toString () {
    if (isDisposed()) return "Cursor {*DISPOSED*}";
    return Format("{}{}{}", "Cursor {" , handle , "}");
}

/**
 * Invokes platform specific functionality to allocate a new cursor.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>Cursor</code>. It is marked public only so that it
 * can be shared within the packages provided by DWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param device the device on which to allocate the color
 * @param handle the handle for the cursor
 *
 * @private
 */
public static Cursor cocoa_new(Device device, NSCursor handle) {
    Cursor cursor = new Cursor(device);
    cursor.handle = handle;
    return cursor;
}

}
