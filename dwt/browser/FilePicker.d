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
module dwt.browser.FilePicker;

import dwt.dwthelper.utils;

import dwt.DWT;

import XPCOM = dwt.internal.mozilla.XPCOM;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsIFileURL;
import dwt.internal.mozilla.nsIDOMWindow;
import dwt.internal.mozilla.nsISimpleEnumerator;
import dwt.internal.mozilla.nsStringAPI;

import dwt.browser.Mozilla;

import dwt.widgets.Display;

class FilePicker : nsIFilePicker {

    int refCount = 0;
    short mode;
    nsIDOMWindow parentHandle;
    String[] files, masks;
    String defaultFilename, directory, title;

    static final String SEPARATOR = System.getProperty ("file.separator"); //$NON-NLS-1$

this () {
}

extern(System)
nsrefcnt AddRef () {
    refCount++;
    return refCount;
}

extern(System)
nsresult QueryInterface (nsID* riid, void** ppvObject) {
    if (riid is null || ppvObject is null) return XPCOM.NS_ERROR_NO_INTERFACE;

    if (*riid == nsISupports.IID) {
        *ppvObject = cast(void*)cast(nsISupports) this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIFilePicker.IID) {
        *ppvObject = cast(void*)cast(nsIFilePicker) this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIFilePicker_1_8.IID) {
        *ppvObject = cast(void*)cast(nsIFilePicker_1_8) this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    *ppvObject = null;
    return XPCOM.NS_ERROR_NO_INTERFACE;
}

extern(System)
nsrefcnt Release () {
    refCount--;
    if (refCount is 0) return 0;
    return refCount;
}

/*
 * As of Mozilla 1.8 some of nsIFilePicker's string arguments changed type.  This method
 * answers a java string based on the type of string that is appropriate for the Mozilla
 * version being used.
 */
extern(D)
String parseAString (nsAString* string) {
    return null;
}

/* nsIFilePicker */

extern(System)
nsresult Init (nsIDOMWindow parent, nsAString* title, PRInt16 mode) {
    parentHandle = parent;
    this.mode = mode;
    this.title = parseAString (title);
    return XPCOM.NS_OK;
}

extern(System)
nsresult Show (PRInt16* _retval) {
    if (mode is nsIFilePicker.modeGetFolder) {
        /* picking a directory */
        int result = showDirectoryPicker ();
        *_retval = cast(int)cast(PRInt16)result; /* PRInt16 */
        return XPCOM.NS_OK;
    }

    /* picking a file */
    int style = mode is nsIFilePicker.modeSave ? DWT.SAVE : DWT.OPEN;
    if (mode is nsIFilePicker.modeOpenMultiple) style |= DWT.MULTI;
    Display display = Display.getCurrent ();
    Shell parent = null; // TODO compute parent
    if (parent is null) {
        parent = new Shell (display);
    }
    FileDialog dialog = new FileDialog (parent, style);
    if (title !is null) dialog.setText (title);
    if (directory !is null) dialog.setFilterPath (directory);
    if (masks !is null) dialog.setFilterExtensions (masks);
    if (defaultFilename !is null) dialog.setFileName (defaultFilename);
    String filename = dialog.open ();
    files = dialog.getFileNames ();
    directory = dialog.getFilterPath ();
    title = defaultFilename = null;
    masks = null;
    int result = filename is null ? nsIFilePicker.returnCancel : nsIFilePicker.returnOK;
    *_retval = cast(int)cast(short)result;; /* PRInt16 */
    return XPCOM.NS_OK;
}

int showDirectoryPicker () {
    Display display = Display.getCurrent ();
    Shell parent = null; // TODO compute parent
    if (parent is null) {
        parent = new Shell (display);
    }
    DirectoryDialog dialog = new DirectoryDialog (parent, DWT.NONE);
    if (title !is null) dialog.setText (title);
    if (directory !is null) dialog.setFilterPath (directory);
    directory = dialog.open ();
    title = defaultFilename = null;
    files = masks = null;
    return directory is null ? nsIFilePicker.returnCancel : nsIFilePicker.returnOK;
}

extern(System)
nsresult GetFiles (nsISimpleEnumerator* aFiles) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult GetFileURL ( nsIFileURL* aFileURL ) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult GetFile (nsILocalFile* aFile) {
    String filename = "";   //$NON-NLS-1$
    if (directory !is null) filename ~= directory ~ SEPARATOR;
    if (files !is null && files.length > 0) filename ~= files[0];
    scope auto path = new nsEmbedString (toString16(filename));
    int rc = XPCOM.NS_NewLocalFile (cast(nsAString*)path, 1, aFile);
    if (rc !is XPCOM.NS_OK) Mozilla.error (rc);
    if (aFile is null) Mozilla.error (XPCOM.NS_ERROR_NULL_POINTER);
    return XPCOM.NS_OK;
}

extern(System)
nsresult SetDisplayDirectory (nsILocalFile aDisplayDirectory) {
    if (aDisplayDirectory is null) return XPCOM.NS_OK;
    scope auto pathname = new nsEmbedCString();
    aDisplayDirectory.GetNativePath (cast(nsACString*)pathname);
    // wchar[] chars = MozillaDelegate.mbcsToWcs (null, bytes);
    directory = pathname.toString;
    return XPCOM.NS_OK;
}

extern(System)
nsresult GetDisplayDirectory (nsILocalFile* aDisplayDirectory) {
    String directoryName = directory !is null ? directory : ""; //$NON-NLS-1$
    scope auto path = new nsEmbedString (Utf.toString16(directoryName));
    int rc = XPCOM.NS_NewLocalFile (cast(nsAString*)path, 1, aDisplayDirectory);
    if (rc !is XPCOM.NS_OK) Mozilla.error (rc);
    if (aDisplayDirectory is null) Mozilla.error (XPCOM.NS_ERROR_NULL_POINTER);
    return XPCOM.NS_OK;
}

extern(System)
nsresult SetFilterIndex (PRInt32 aFilterIndex) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult GetFilterIndex (PRInt32* aFilterIndex) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult SetDefaultExtension (nsAString* aDefaultExtension) {
    /* note that the type of argument 1 changed as of Mozilla 1.8 */
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult GetDefaultExtension (nsAString* aDefaultExtension) {
    /* note that the type of argument 1 changed as of Mozilla 1.8 */
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult SetDefaultString (nsAString* aDefaultString) {
    defaultFilename = parseAString (aDefaultString);
    return XPCOM.NS_OK;
}

extern(System)
nsresult GetDefaultString (nsAString* aDefaultString) {
    /* note that the type of argument 1 changed as of Mozilla 1.8 */
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult AppendFilter (nsAString* title, nsAString* filter) {
    /* note that the type of arguments 1 and 2 changed as of Mozilla 1.8 */
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult AppendFilters (PRInt32 filterMask) {
    String[] addFilters = null;
    switch (filterMask) {
        case nsIFilePicker.filterAll:
        case nsIFilePicker.filterApps:
            masks = null;           /* this is equivalent to no filter */
            break;
        case nsIFilePicker.filterHTML:
            addFilters[0] = "*.htm;*.html"; //$NON-NLS-1$
            break;
        case nsIFilePicker.filterImages:
            addFilters[0] = "*.gif;*.jpeg;*.jpg;*.png"; //$NON-NLS-1$
            break;
        case nsIFilePicker.filterText:
            addFilters[0] = "*.txt";    //$NON-NLS-1$
            break;
        case nsIFilePicker.filterXML:
            addFilters[0] = "*.xml";    //$NON-NLS-1$
            break;
        case nsIFilePicker.filterXUL:
            addFilters[0] = "*.xul";    //$NON-NLS-1$
            break;
        default:
    }
    if (masks is null) {
        masks = addFilters;
    } else {
        if (addFilters !is null) {
            masks ~= addFilters;
        }
    }
    return XPCOM.NS_OK;
}
}
