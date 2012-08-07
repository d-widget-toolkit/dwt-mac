/*******************************************************************************
 * Copyright (c) 2003, 2007 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *      John Reimer <terminal.node@gmail.com>
 *******************************************************************************/
module dwt.browser.FilePickerFactory_1_8;

import dwt.dwthelper.utils;

import XPCOM = dwt.internal.mozilla.XPCOM;
import dwt.browser.FilePickerFactory;
import dwt.browser.FilePicker_1_8;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsID;
import dwt.internal.mozilla.nsISupports;


class FilePickerFactory_1_8 : FilePickerFactory {

extern(System)
nsresult CreateInstance (nsISupports aOuter, nsID* iid, void** result) { 
     if (result is null) 
        return XPCOM.NS_ERROR_INVALID_ARG;
    auto picker = new FilePicker_1_8;
    nsresult rv = picker.QueryInterface( iid, result );
    if (XPCOM.NS_FAILED(rv)) {
        *result = null;
        delete picker;
    }
    return rv;
}

}
