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
module dwt.browser.PromptService2;

import tango.stdc.stdlib;
import tango.text.convert.Format;

import dwt.dwthelper.utils;

import dwt.*;
import dwt.internal.C;
import dwt.internal.Compatibility;
import dwt.internal.mozilla.XPCOM;

import dwt.internal.mozilla.*;

import XPCOM = dwt.internal.mozilla.XPCOM;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsIEmbeddingSiteWindow;
import dwt.internal.mozilla.nsIWebBrowserChrome;
import dwt.internal.mozilla.nsIWindowWatcher;
import dwt.internal.mozilla.nsIAuthPromptCallback;
import dwt.internal.mozilla.nsICancelable;
import dwt.internal.mozilla.nsStringAPI;


import dwt.browser.Browser;
import dwt.browser.Mozilla;
import dwt.browser.PromptDialog;

class PromptService2 : nsIPromptService2 {
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
    if (*riid == nsIPromptService.IID) {
        *ppvObject = cast(void*)cast(nsIPromptService)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIPromptService2.IID) {
        *ppvObject = cast(void*)cast(nsIPromptService2)this;
        AddRef ();
        return XPCOM.NS_OK;
    }

    *ppvObject = null;
    return XPCOM.NS_ERROR_NO_INTERFACE;
}

extern(System)
nsrefcnt Release () {
    refCount--;
    //if (refCount is 0) disposeCOMInterfaces ();
    return refCount;
}

extern(D)
Browser getBrowser (nsIDOMWindow aDOMWindow) {
    if (aDOMWindow is null) return null;

    //int /*long*/[] result = new int /*long*/[1];
    nsIServiceManager serviceManager;
    auto rc = XPCOM.NS_GetServiceManager (&serviceManager);
    if (rc !is XPCOM.NS_OK) Mozilla.error (rc);
    if (serviceManager is null) Mozilla.error (XPCOM.NS_NOINTERFACE);

    //nsIServiceManager serviceManager = new nsIServiceManager (result[0]);
    //result[0] = 0;
    //byte[] aContractID = MozillaDelegate.wcsToMbcs (null, XPCOM.NS_WINDOWWATCHER_CONTRACTID, true);
    nsIWindowWatcher windowWatcher;
    rc = serviceManager.GetServiceByContractID (XPCOM.NS_WINDOWWATCHER_CONTRACTID.ptr, &nsIWindowWatcher.IID, cast(void**)&windowWatcher);
    if (rc !is XPCOM.NS_OK) Mozilla.error(rc);
    if (windowWatcher is null) Mozilla.error (XPCOM.NS_NOINTERFACE);
    serviceManager.Release ();

    //nsIWindowWatcher windowWatcher = new nsIWindowWatcher (result[0]);
    //result[0] = 0;
    /* the chrome will only be answered for the top-level nsIDOMWindow */
    //nsIDOMWindow window = new nsIDOMWindow (aDOMWindow);
    nsIDOMWindow top;
    rc = aDOMWindow.GetTop (&top);
    if (rc !is XPCOM.NS_OK) Mozilla.error (rc);
    if (top is null) Mozilla.error (XPCOM.NS_NOINTERFACE);
    //aDOMWindow = result[0];
    //result[0] = 0;
    nsIWebBrowserChrome webBrowserChrome;
    rc = windowWatcher.GetChromeForWindow (top, &webBrowserChrome);
    if (rc !is XPCOM.NS_OK) Mozilla.error (rc);
    if (webBrowserChrome is null) Mozilla.error (XPCOM.NS_NOINTERFACE);
    windowWatcher.Release ();

    //nsIWebBrowserChrome webBrowserChrome = new nsIWebBrowserChrome (result[0]);
    //result[0] = 0;
    nsIEmbeddingSiteWindow embeddingSiteWindow;
    rc = webBrowserChrome.QueryInterface (&nsIEmbeddingSiteWindow.IID, cast(void**)&embeddingSiteWindow);
    if (rc !is XPCOM.NS_OK) Mozilla.error (rc);
    if (embeddingSiteWindow is null) Mozilla.error (XPCOM.NS_NOINTERFACE);
    webBrowserChrome.Release ();

    //nsIEmbeddingSiteWindow embeddingSiteWindow = new nsIEmbeddingSiteWindow (result[0]);
    //result[0] = 0;

    void* result;
    rc = embeddingSiteWindow.GetSiteWindow (&result);
    if (rc !is XPCOM.NS_OK) Mozilla.error (rc);
    if (result is null) Mozilla.error (XPCOM.NS_NOINTERFACE);
    embeddingSiteWindow.Release ();

    return Mozilla.findBrowser (result);
}

String getLabel (int buttonFlag, int index, PRUnichar* buttonTitle) {
    String label = null;
    int flag = (buttonFlag & (0xff * index)) / index;
    switch (flag) {
        // TODO: implement with DWT.getMessage - JJR
        case nsIPromptService.BUTTON_TITLE_CANCEL : label = "Cancel"; break; //$NON-NLS-1$
        case nsIPromptService.BUTTON_TITLE_NO : label = "No"; break; //$NON-NLS-1$
        case nsIPromptService.BUTTON_TITLE_OK : label = "OK"; break; //$NON-NLS-1$
        case nsIPromptService.BUTTON_TITLE_SAVE : label = "Save"; break; //$NON-NLS-1$
        case nsIPromptService.BUTTON_TITLE_YES : label = "Yes"; break; //$NON-NLS-1$
        case nsIPromptService.BUTTON_TITLE_IS_STRING : {
            auto span = XPCOM.strlen_PRUnichar (buttonTitle);
            //char[] dest = new char[length];
            //XPCOM.memmove (dest, buttonTitle, length * 2);
            label = Utf.toString (buttonTitle[0 .. span]);
        }
        default:
    }
    return label;
}

/* nsIPromptService */

extern(System)
nsresult Alert (nsIDOMWindow aParent, PRUnichar* aDialogTitle, PRUnichar* aText) {
    Browser browser = getBrowser (aParent);

    int span = XPCOM.strlen_PRUnichar (aDialogTitle);
    //char[] dest = new char[length];
    //XPCOM.memmove (dest, aDialogTitle, length * 2);
    String titleLabel = Utf.toString (aDialogTitle[0 .. span]);

    span = XPCOM.strlen_PRUnichar (aText);
    //dest = new char[length];
    //XPCOM.memmove (dest, aText, length * 2);
    String textLabel = Utf.toString (aText[0 .. span]);

    Shell shell = browser is null ? new Shell () : browser.getShell ();
    MessageBox messageBox = new MessageBox (shell, DWT.OK | DWT.ICON_WARNING);
    messageBox.setText (titleLabel);
    messageBox.setMessage (textLabel);
    messageBox.open ();
    return XPCOM.NS_OK;
}

extern(System)
nsresult AlertCheck (nsIDOMWindow aParent, PRUnichar* aDialogTitle, PRUnichar* aText, PRUnichar* aCheckMsg, PRBool* aCheckState) {
    Browser browser = getBrowser (aParent);

    int span = XPCOM.strlen_PRUnichar (aDialogTitle);
    //char[] dest = new char[length];
    //XPCOM.memmove (dest, aDialogTitle, length * 2);
    String titleLabel = Utf.toString (aDialogTitle[0 .. span]);

    span = XPCOM.strlen_PRUnichar (aText);
    //dest = new char[length];
    //XPCOM.memmove (dest, aText, length * 2);
    String textLabel = Utf.toString (aText[0 .. span]);

    span = XPCOM.strlen_PRUnichar (aCheckMsg);
    //dest = new char[length];
    //XPCOM.memmove (dest, aCheckMsg, length * 2);
    String checkLabel = Utf.toString (aCheckMsg[0..span]);

    Shell shell = browser is null ? new Shell () : browser.getShell ();
    PromptDialog dialog = new PromptDialog (shell);
    int check;
    if (aCheckState !is null) check = *aCheckState; /* PRBool */
    dialog.alertCheck (titleLabel, textLabel, checkLabel, /*ref*/ check);
    if (aCheckState !is null) *aCheckState = check; /* PRBool */
    return XPCOM.NS_OK;
}

extern(System)
nsresult AsyncPromptAuth(nsIDOMWindow aParent, nsIChannel aChannel, nsIAuthPromptCallback aCallback, nsISupports aContext, PRUint32 level, nsIAuthInformation authInfo, PRUnichar* checkboxLabel, PRBool* checkValue, nsICancelable* _retval) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult Confirm (nsIDOMWindow aParent, PRUnichar* aDialogTitle, PRUnichar* aText, PRBool* _retval) {
    Browser browser = getBrowser (aParent);

    int span = XPCOM.strlen_PRUnichar (aDialogTitle);
    //char[] dest = new char[length];
    //XPCOM.memmove (dest, aDialogTitle, length * 2);
    String titleLabel = Utf.toString (aDialogTitle[0 .. span]);

    span = XPCOM.strlen_PRUnichar (aText);
    //dest = new char[length];
    //XPCOM.memmove (dest, aText, length * 2);
    String textLabel = Utf.toString (aText[0 .. span]);

    Shell shell = browser is null ? new Shell () : browser.getShell ();
    MessageBox messageBox = new MessageBox (shell, DWT.OK | DWT.CANCEL | DWT.ICON_QUESTION);
    messageBox.setText (titleLabel);
    messageBox.setMessage (textLabel);
    int id = messageBox.open ();
    int result = id is DWT.OK ? 1 : 0;
    *_retval = result;
    return XPCOM.NS_OK;
}

extern(System)
nsresult ConfirmCheck (nsIDOMWindow aParent, PRUnichar* aDialogTitle, PRUnichar* aText, PRUnichar* aCheckMsg, PRBool* aCheckState, PRBool* _retval) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult ConfirmEx (nsIDOMWindow aParent, PRUnichar* aDialogTitle, PRUnichar* aText, PRUint32 aButtonFlags, PRUnichar* aButton0Title, PRUnichar* aButton1Title, PRUnichar* aButton2Title, PRUnichar* aCheckMsg, PRBool* aCheckState, PRInt32* _retval) {
    Browser browser = getBrowser (aParent);

    int span = XPCOM.strlen_PRUnichar (aDialogTitle);
    //char[] dest = new char[length];
    //XPCOM.memmove (dest, aDialogTitle, length * 2);
    String titleLabel = Utf.toString (aDialogTitle[0 .. span]);

    span = XPCOM.strlen_PRUnichar (aText);
    //dest = new char[length];
    //XPCOM.memmove (dest, aText, length * 2);
    String textLabel = Utf.toString (aText[0 .. span]);

    String checkLabel = null;
    if (aCheckMsg !is null) {
        span = XPCOM.strlen_PRUnichar (aCheckMsg);
        //dest = new char[length];
        //XPCOM.memmove (dest, aCheckMsg, length * 2);
        checkLabel = Utf.toString (aCheckMsg[0 .. span]);
    }

    String button0Label = getLabel (aButtonFlags, nsIPromptService.BUTTON_POS_0, aButton0Title);
    String button1Label = getLabel (aButtonFlags, nsIPromptService.BUTTON_POS_1, aButton1Title);
    String button2Label = getLabel (aButtonFlags, nsIPromptService.BUTTON_POS_2, aButton2Title);

    int defaultIndex = 0;
    if ((aButtonFlags & nsIPromptService.BUTTON_POS_1_DEFAULT) !is 0) {
        defaultIndex = 1;
    } else if ((aButtonFlags & nsIPromptService.BUTTON_POS_2_DEFAULT) !is 0) {
        defaultIndex = 2;
    }

    Shell shell = browser is null ? new Shell () : browser.getShell ();
    PromptDialog dialog = new PromptDialog (shell);
    int check, result;
    if (aCheckState !is null) check = *aCheckState;
    dialog.confirmEx (titleLabel, textLabel, checkLabel, button0Label, button1Label, button2Label, defaultIndex, /*ref*/check, /*ref*/result);
    if (aCheckState !is null) *aCheckState = check;
    *_retval = result;
    return XPCOM.NS_OK;
}

extern(System)
nsresult Prompt (nsIDOMWindow aParent, PRUnichar* aDialogTitle, PRUnichar* aText, PRUnichar** aValue, PRUnichar* aCheckMsg, PRBool* aCheckState, PRBool* _retval) {
    Browser browser = getBrowser (aParent);
    String titleLabel = null;
    String textLabel = null, checkLabel = null;
    String valueLabel;
    //char[] dest;
    int span;
    if (aDialogTitle !is null) {
        span = XPCOM.strlen_PRUnichar (aDialogTitle);
        //dest = new char[length];
        //XPCOM.memmove (dest, aDialogTitle, length * 2);
        titleLabel = Utf.toString (aDialogTitle[0 .. span]);
    }

    span = XPCOM.strlen_PRUnichar (aText);
    //dest = new char[length];
    //XPCOM.memmove (dest, aText, length * 2);
    textLabel = Utf.toString (aText[0 .. span]);

    //int /*long*/[] valueAddr = new int /*long*/[1];
    //XPCOM.memmove (valueAddr, aValue, C.PTR_SIZEOF);
    auto valueAddr = aValue;
    if (valueAddr[0] !is null) {
        span = XPCOM.strlen_PRUnichar (valueAddr[0]);
        //dest = new char[length];
        //XPCOM.memmove (dest, valueAddr[0], length * 2);
        valueLabel = Utf.toString ((valueAddr[0])[0 .. span]);
    }

    if (aCheckMsg !is null) {
        span = XPCOM.strlen_PRUnichar (aCheckMsg);
        if (span > 0) {
            //dest = new char[length];
            //XPCOM.memmove (dest, aCheckMsg, length * 2);
            checkLabel = Utf.toString (aCheckMsg[0 .. span]);
        }
    }

    Shell shell = browser is null ? new Shell () : browser.getShell ();
    PromptDialog dialog = new PromptDialog (shell);
    int check, result;
    if (aCheckState !is null) check = *aCheckState;
    dialog.prompt (titleLabel, textLabel, checkLabel, /*ref*/valueLabel,/*ref*/ check,/*ref*/ result);
    *_retval = result;
    if (result is 1) {
        /*
        * User selected OK. User name and password are returned as PRUnichar values. Any default
        * value that we override must be freed using the nsIMemory service.
        */
            buffer = Utf.toString16(valueLabel);
            int /*long*/[] result2 = new int /*long*/[1];
            if (rc !is XPCOM.NS_OK) DWT.error (rc);
                if (serviceManager is null) DWT.error (XPCOM.NS_NOINTERFACE);

                //nsIServiceManager serviceManager = new nsIServiceManager (result2[0]);
                //result2[0] = 0;
                nsIMemory memory;
                //byte[] aContractID = MozillaDelegate.wcsToMbcs (null, XPCOM.NS_MEMORY_CONTRACTID, true);
                rc = serviceManager.GetServiceByContractID (XPCOM.NS_MEMORY_CONTRACTID.ptr, &nsIMemory.IID, cast(void**)&memory);
            if (rc !is XPCOM.NS_OK) DWT.error (rc);
                if (memory is null) DWT.error (XPCOM.NS_NOINTERFACE);
            serviceManager.Release ();

                //nsIMemory memory = new nsIMemory (result2[0]);
                //result2[0] = 0;

            int cnt = valueLabel[0].length ();
            char[] buffer = new char[cnt + 1];
            valueLabel[0].getChars (0, cnt, buffer, 0);
            int size = buffer.length * 2;
            int /*long*/ ptr = memory.Alloc (size);
            XPCOM.memmove (ptr, buffer, size);
            XPCOM.memmove (aValue, new int /*long*/[] {ptr}, C.PTR_SIZEOF);

            if (valueAddr[0] !is 0) {
                memory.Free (valueAddr[0]);
            }
            memory.Release ();
        }
    }
    if (aCheckState !is null) *aCheckState = check;
    return XPCOM.NS_OK;
}

extern(System)
nsresult PromptAuth(nsIDOMWindow aParent, nsIChannel aChannel, PRUint32 level, nsIAuthInformation authInfo, PRUnichar* checkboxLabel, PRBool* checkboxValue, PRBool* _retval) {
    nsIAuthInformation auth = new nsIAuthInformation (authInfo);

    Browser browser = getBrowser (aParent);
    if (browser !is null) {
        Mozilla mozilla = (Mozilla)browser.webBrowser;
        /*
         * Do not invoke the listeners if this challenge has been failed too many
         * times because a listener is likely giving incorrect credentials repeatedly
         * and will do so indefinitely.
         */
        if (mozilla.authCount++ < 3) {
            for (int i = 0; i < mozilla.authenticationListeners.length; i++) {
                AuthenticationEvent event = new AuthenticationEvent (browser);
                event.location = mozilla.lastNavigateURL;
                mozilla.authenticationListeners[i].authenticate (event);
                if (!event.doit) {
                    XPCOM.memmove (_retval, new int[] {0}, 4);  /* PRBool */
                    return XPCOM.NS_OK;
                }
                if (event.user !is null && event.password !is null) {
                    nsEmbedString string = new nsEmbedString (event.user);
                    int rc = auth.SetUsername (string.getAddress ());
                    if (rc !is XPCOM.NS_OK) DWT.error (rc);
                    string.dispose ();
                    string = new nsEmbedString (event.password);
                    rc = auth.SetPassword (string.getAddress ());
                    if (rc !is XPCOM.NS_OK) DWT.error (rc);
                    string.dispose ();
                    XPCOM.memmove (_retval, new int[] {1}, 4);  /* PRBool */
                    return XPCOM.NS_OK;
                }
            }
        }
    }

    /* no listener handled the challenge, so show an authentication dialog */


    /* no listener handled the challenge, so show an authentication dialog */

    String checkLabel = null;
    //int[] checkValue = new int[1];
    //String[] userLabel = new String[1], passLabel = new String[1];
    int checkValue;
    String userLabel, passLabel;
    //String title = DWT.getMessage ("SWT_Authentication_Required"); //$NON-NLS-1$
    String title = "Authentication Required";

    if (checkboxLabel !is null && checkboxValue !is null) {
        //int span = XPCOM.strlen_PRUnichar (checkboxLabel);
        //char[] dest = new char[length];
        //XPCOM.memmove (dest, checkboxLabel, length * 2);
        checkLabel = Utf.toString (fromString16z(checkboxLabel));
        checkValue = *checkboxValue; /* PRBool */
    }

    /* get initial username and password values */

    scope auto ptr1 = new nsEmbedString;
    int rc = authInfo.GetUsername (cast(nsAString*)ptr1);
    if (rc !is XPCOM.NS_OK) DWT.error (rc);
    //int length = XPCOM.nsEmbedString_Length (ptr);
    //int /*long*/ buffer = XPCOM.nsEmbedString_get (ptr);
    //char[] chars = new char[length];
    //XPCOM.memmove (chars, buffer, length * 2);
    userLabel = ptr1.toString;
    //XPCOM.nsEmbedString_delete (ptr);

    scope auto ptr2 = new nsEmbedString;
    rc = authInfo.GetPassword (cast(nsAString*)ptr2);
    if (rc !is XPCOM.NS_OK) DWT.error (rc);
    //length = XPCOM.nsEmbedString_Length (ptr);
    //buffer = XPCOM.nsEmbedString_get (ptr);
    //chars = new char[length];
    //XPCOM.memmove (chars, buffer, length * 2);
    passLabel = ptr2.toString;
    //XPCOM.nsEmbedString_delete (ptr);

    /* compute the message text */

    scope auto ptr3 = new nsEmbedString;
    rc = authInfo.GetRealm (cast(nsAString*)ptr3);
    if (rc !is XPCOM.NS_OK) DWT.error (rc);
    //length = XPCOM.nsEmbedString_Length (ptr);
    //buffer = XPCOM.nsEmbedString_get (ptr);
    //chars = new char[length];
    //XPCOM.memmove (chars, buffer, length * 2);
    String realm = ptr3.toString;
    //XPCOM.nsEmbedString_delete (ptr);

    //nsIChannel channel = new nsIChannel (aChannel);
    nsIURI uri;
    rc = aChannel.GetURI (&uri);
    if (rc !is XPCOM.NS_OK) DWT.error (rc);
    if (uri is null) Mozilla.error (XPCOM.NS_NOINTERFACE);

    //nsIURI nsURI = new nsIURI (uri[0]);
    scope auto host = new nsEmbedCString;
    rc = uri.GetHost (cast(nsACString*)host);
    if (rc !is XPCOM.NS_OK) DWT.error (rc);
    //length = XPCOM.nsEmbedCString_Length (host);
    //buffer = XPCOM.nsEmbedCString_get (host);
    //byte[] bytes = new byte[length];
    //XPCOM.memmove (bytes, buffer, length);
    String hostString = host.toString;
    //XPCOM.nsEmbedCString_delete (host);
    uri.Release ();

    String message;
    if (realm.length () > 0 && hostString.length () > 0) {
        //message = Compatibility.getMessage ("SWT_Enter_Username_and_Password", new String[] {realm, host}); //$NON-NLS-1$
        message = Format("Enter user name and password for {0} at {1}",realm, host);
    } else {
        message = ""; //$NON-NLS-1$
    }

    /* open the prompter */
    Shell shell = browser is null ? new Shell () : browser.getShell ();
    PromptDialog dialog = new PromptDialog (shell);
    int result;
    dialog.promptUsernameAndPassword (title, message, checkLabel, userLabel, passLabel, checkValue, result);

    //XPCOM.memmove (_retval, result, 4); /* PRBool */
    *_retval = result;
    if (result is 1) {   /* User selected OK */
        scope auto string1 = new nsEmbedString (toString16(userLabel));
        rc = authInfo.SetUsername(cast(nsAString*)string1);
        if (rc !is XPCOM.NS_OK) DWT.error (rc);
        //string.dispose ();

        scope auto string2 = new nsEmbedString (toString16(passLabel));
        rc = authInfo.SetPassword(cast(nsAString*)string2);
        if (rc !is XPCOM.NS_OK) DWT.error (rc);
        //string.dispose ();
    }

    if (checkboxValue !is null) *checkboxValue = checkValue; /* PRBool */
    return XPCOM.NS_OK;
}

extern(System)
nsresult PromptUsernameAndPassword (nsIDOMWindow aParent, PRUnichar* aDialogTitle, PRUnichar* aText, PRUnichar** aUsername, PRUnichar** aPassword, PRUnichar* aCheckMsg, PRBool* aCheckState, PRBool* _retval) {
    Browser browser = getBrowser (aParent);
    String user = null, password = null;

    if (browser !is null) {
        Mozilla mozilla = (Mozilla)browser.webBrowser;
        /*
         * Do not invoke the listeners if this challenge has been failed too many
         * times because a listener is likely giving incorrect credentials repeatedly
         * and will do so indefinitely.
         */
        if (mozilla.authCount++ < 3) {
            for (int i = 0; i < mozilla.authenticationListeners.length; i++) {
                AuthenticationEvent event = new AuthenticationEvent (browser);
                event.location = mozilla.lastNavigateURL;
                mozilla.authenticationListeners[i].authenticate (event);
                if (!event.doit) {
                    XPCOM.memmove (_retval, new int[] {0}, 4);  /* PRBool */
                    return XPCOM.NS_OK;
                }
                if (event.user !is null && event.password !is null) {
                    user = event.user;
                    password = event.password;
                    XPCOM.memmove (_retval, new int[] {1}, 4);  /* PRBool */
                    break;
                }
            }
        }
    }

    if (user is null) {
        /* no listener handled the challenge, so show an authentication dialog */

        String titleLabel, textLabel, checkLabel = null;
    String userLabel, passLabel;
        char[] dest;
    int span;
    if (aDialogTitle !is null) {
        //span = XPCOM.strlen_PRUnichar (aDialogTitle);
        //dest = new char[length];
        //XPCOM.memmove (dest, aDialogTitle, length * 2);
        titleLabel = Utf.toString (fromString16z(aDialogTitle));
        } else {
        //titleLabel = DWT.getMessage ("SWT_Authentication_Required");    //$NON-NLS-1$
        titleLabel = "Authentication Required";
        }

    //span = XPCOM.strlen_PRUnichar (aText);
    //dest = new char[length];
    //XPCOM.memmove (dest, aText, length * 2);
    textLabel = Utf.toString (fromString16z(aText));

    //int /*long*/[] userAddr = new int /*long*/[1];
    //XPCOM.memmove (userAddr, aUsername, C.PTR_SIZEOF);
    auto userAddr = *aUsername;
    if (*aUsername !is null) {
            //span = XPCOM.strlen_PRUnichar (userAddr[0]);
            //dest = new char[length];
            //XPCOM.memmove (dest, userAddr[0], length * 2);
            userLabel = Utf.toString(fromString16z(*aUsername));
        }

    //int /*long*/[] passAddr = new int /*long*/[1];
    //XPCOM.memmove (passAddr, aPassword, C.PTR_SIZEOF);
    auto passAddr = *aPassword;
    if (*aPassword !is null) {
            //span = XPCOM.strlen_PRUnichar (passAddr[0]);
            //dest = new char[length];
            //XPCOM.memmove (dest, passAddr[0], length * 2);
            passLabel = Utf.toString(fromString16z(*aPassword));
        }

    if (aCheckMsg !is null) {
        //span = XPCOM.strlen_PRUnichar (aCheckMsg);
        //if (span > 0) {
            //dest = new char[length];
            //XPCOM.memmove (dest, aCheckMsg, length * 2);
        checkLabel = Utf.toString (fromString16z(aCheckMsg));
        //}
        }

        Shell shell = browser is null ? new Shell () : browser.getShell ();
        PromptDialog dialog = new PromptDialog (shell);
    int check, result;
    if (aCheckState !is null) check = *aCheckState;   /* PRBool */
    dialog.promptUsernameAndPassword (titleLabel, textLabel, checkLabel, /*ref*/ userLabel, /*ref*/ passLabel, check, result);

    *_retval = result; /* PRBool */
    if (result is 1) {
            /* User selected OK */
            user = userLabel[0];
            password = passLabel[0];
        }
        if (aCheckState !is 0) XPCOM.memmove (aCheckState, check, 4); /* PRBool */
    }

    if (user !is null) {
        /*
        * User name and password are returned as PRUnichar values. Any default
        * value that we override must be freed using the nsIMemory service.
        */
        int /*long*/[] userAddr = new int /*long*/[1];
        XPCOM.memmove (userAddr, aUsername, C.PTR_SIZEOF);
        int /*long*/[] passAddr = new int /*long*/[1];
        XPCOM.memmove (passAddr, aPassword, C.PTR_SIZEOF);
            //XPCOM.memmove (ptr, buffer, size);
            *aUsername = toString16z(Utf.toString16(userLabel));
            //XPCOM.memmove (aUsername, new int /*long*/[] {ptr}, C.PTR_SIZEOF);
            nsIServiceManager serviceManager;

        int /*long*/[] result = new int /*long*/[1];
        int rc = XPCOM.NS_GetServiceManager (result);
        if (rc !is XPCOM.NS_OK) DWT.error (rc);
                if (serviceManager is null) DWT.error (XPCOM.NS_NOINTERFACE);

                //nsIServiceManager serviceManager = new nsIServiceManager (result[0]);
                //result[0] = 0;
                //byte[] aContractID = MozillaDelegate.wcsToMbcs (null, XPCOM.NS_MEMORY_CONTRACTID, true);
                nsIMemory memory;
                rc = serviceManager.GetServiceByContractID (XPCOM.NS_MEMORY_CONTRACTID.ptr, &nsIMemory.IID, cast(void**)&memory);
        if (rc !is XPCOM.NS_OK) DWT.error (rc);
                if (memory is null) DWT.error (XPCOM.NS_NOINTERFACE);
        serviceManager.Release ();

        //nsIMemory memory = new nsIMemory (result[0]);
        //result[0] = 0;
        if (userAddr !is null) memory.Free (userAddr);
        if (passAddr !is null) memory.Free (passAddr);
        memory.Release ();

        /* write the name and password values */

        int cnt = user.length ();
        char[] buffer = new char[cnt + 1];
        user.getChars (0, cnt, buffer, 0);
        int size = buffer.length * 2;
        int /*long*/ ptr = C.malloc (size);
        XPCOM.memmove (ptr, buffer, size);
        XPCOM.memmove (aUsername, new int /*long*/[] {ptr}, C.PTR_SIZEOF);

        cnt = password.length ();
        buffer = new char[cnt + 1];
        password.getChars (0, cnt, buffer, 0);
        size = buffer.length * 2;
        ptr = C.malloc (size);
        XPCOM.memmove (ptr, buffer, size);
        XPCOM.memmove (aPassword, new int /*long*/[] {ptr}, C.PTR_SIZEOF);

    }

            //(cast(wchar*)ptr)[0 .. buffer.length] = buffer[0 .. $];
            //XPCOM.memmove (ptr, buffer, size);
            *aPassword = toString16z(Utf.toString16(passLabel));
            //XPCOM.memmove (aPassword, new int /*long*/[] {ptr}, C.PTR_SIZEOF);
                int rc = XPCOM.NS_GetServiceManager (&serviceManager);
                rc = serviceManager.GetServiceByContractID (XPCOM.NS_MEMORY_CONTRACTID.ptr, &nsIMemory.IID, cast(void**)&memory);
    return XPCOM.NS_OK;
}

extern(System)
nsresult PromptPassword (nsIDOMWindow aParent, PRUnichar* aDialogTitle, PRUnichar* aText, PRUnichar** aPassword, PRUnichar* aCheckMsg, PRBool* aCheckState, PRBool* _retval) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult Select (nsIDOMWindow aParent, PRUnichar* aDialogTitle, PRUnichar* aText, PRUint32 aCount, PRUnichar** aSelectList, PRInt32* aOutSelection, PRBool* _retval) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

}
