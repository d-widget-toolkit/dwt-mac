/*******************************************************************************
 * Copyright (c) 2003, 2009 IBM Corporation and others.
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
module dwt.browser.HelperAppLauncherDialogFactory;

import dwt.dwthelper.utils;

import XPCOM = dwt.internal.mozilla.XPCOM;
import dwt.internal.mozilla.XPCOM;

import dwt.internal.mozilla.Common;

import dwt.browser.HelperAppLauncherDialog;
import dwt.browser.HelperAppLauncherDialog_1_9;

class HelperAppLauncherDialogFactory : nsIFactory {
    int refCount = 0;


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
        *ppvObject = cast(void*)cast(nsISupports)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIFactory.IID) {
        *ppvObject = cast(void*)cast(nsIFactory)this;
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

/* nsIFactory */

extern(System)
nsresult CreateInstance (nsISupports aOuter, nsID* iid, void** result) {
        if (result is null)
            return XPCOM.NS_ERROR_INVALID_ARG;
        auto helperAppLauncherDialog = new HelperAppLauncherDialog;
        nsresult rv = helperAppLauncherDialog.QueryInterface( iid, result );
        if (XPCOM.NS_FAILED(rv)) {
            *result = null;
            delete helperAppLauncherDialog;
        } else {
            if (result is null)
                return XPCOM.NS_ERROR_INVALID_ARG;
            auto helperAppLauncherDialog19 = new HelperAppLauncherDialog_1_9;
            rv = helperAppLauncherDialog19.QueryInterface( iid, result );
            if (XPCOM.NS_FAILED(rv)) {
                *result = null;
                delete helperAppLauncherDialog19;
            }
            return rv;
        }
    }
}

extern(System)
nsresult LockFactory (PRBool lock) {
    return XPCOM.NS_OK;
}
}
