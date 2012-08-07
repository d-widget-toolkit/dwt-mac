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
module dwt.browser.WebBrowser;

import dwt.dwthelper.utils;

import java.util.*;


import dwt.browser.Browser;
import dwt.browser.CloseWindowListener;
import dwt.browser.LocationListener;
import dwt.browser.OpenWindowListener;
import dwt.browser.ProgressListener;
import dwt.browser.StatusTextListener;
import dwt.browser.TitleListener;
import dwt.browser.VisibilityWindowListener;

abstract class WebBrowser {
    Browser browser;
    Hashtable functions = new Hashtable ();
    AuthenticationListener[] authenticationListeners = new AuthenticationListener[0];
    CloseWindowListener[] closeWindowListeners;
    LocationListener[] locationListeners;
    OpenWindowListener[] openWindowListeners;
    ProgressListener[] progressListeners;
    StatusTextListener[] statusTextListeners;
    TitleListener[] titleListeners;
    VisibilityWindowListener[] visibilityWindowListeners;
    bool jsEnabled = true;
    bool jsEnabledChanged;
    int nextFunctionIndex = 1;
    Object evaluateResult;

    static final String ERROR_ID = "dwt.browser.error"; // $NON-NLS-1$
    static final String EXECUTE_ID = "SWTExecuteTemporaryFunction"; // $NON-NLS-1$
    static String CookieName, CookieValue, CookieUrl;
    static bool CookieResult;
    static Runnable MozillaClearSessions, NativeClearSessions;
    static Runnable MozillaGetCookie, NativeGetCookie;
    static Runnable MozillaSetCookie, NativeSetCookie;

    /* Key Mappings */
    static const int [][] KeyTable = [
        /* Keyboard and Mouse Masks */
        [18,    DWT.ALT],
        [16,    DWT.SHIFT],
        [17,    DWT.CONTROL],
        [224,   DWT.COMMAND],

        /* Literal Keys */
        [65,    'a'],
        [66,    'b'],
        [67,    'c'],
        [68,    'd'],
        [69,    'e'],
        [70,    'f'],
        [71,    'g'],
        [72,    'h'],
        [73,    'i'],
        [74,    'j'],
        [75,    'k'],
        [76,    'l'],
        [77,    'm'],
        [78,    'n'],
        [79,    'o'],
        [80,    'p'],
        [81,    'q'],
        [82,    'r'],
        [83,    's'],
        [84,    't'],
        [85,    'u'],
        [86,    'v'],
        [87,    'w'],
        [88,    'x'],
        [89,    'y'],
        [90,    'z'],
        [48,    '0'],
        [49,    '1'],
        [50,    '2'],
        [51,    '3'],
        [52,    '4'],
        [53,    '5'],
        [54,    '6'],
        [55,    '7'],
        [56,    '8'],
        [57,    '9'],
        [32,    ' '],
        [59,    ';'],
        [61,    '='],
        [188,   ','],
        [190,   '.'],
        [191,   '/'],
        [219,   '['],
        [221,   ']'],
        [222,   '\''],
        [192,   '`'],
        [220,   '\\'],
        [108,   '|'],

        /* Non-Numeric Keypad Keys */
        [37,    DWT.ARROW_LEFT],
        [39,    DWT.ARROW_RIGHT],
        [38,    DWT.ARROW_UP],
        [40,    DWT.ARROW_DOWN],
        [45,    DWT.INSERT],
        [36,    DWT.HOME],
        [35,    DWT.END],
        [46,    DWT.DEL],
        [33,    DWT.PAGE_UP],
        [34,    DWT.PAGE_DOWN],

        /* Virtual and Ascii Keys */
        [8,     DWT.BS],
        [13,    DWT.CR],
        [9,     DWT.TAB],
        [27,    DWT.ESC],
        [12,    DWT.DEL],

        /* Functions Keys */
        [112,   DWT.F1],
        [113,   DWT.F2],
        [114,   DWT.F3],
        [115,   DWT.F4],
        [116,   DWT.F5],
        [117,   DWT.F6],
        [118,   DWT.F7],
        [119,   DWT.F8],
        [120,   DWT.F9],
        [121,   DWT.F10],
        [122,   DWT.F11],
        [123,   DWT.F12],
        [124,   DWT.F13],
        [125,   DWT.F14],
        [126,   DWT.F15],
        [127,   0],
        [128,   0],
        [129,   0],
        [130,   0],
        [131,   0],
        [132,   0],
        [133,   0],
        [134,   0],
        [135,   0],

        /* Numeric Keypad Keys */
        [96,    DWT.KEYPAD_0],
        [97,    DWT.KEYPAD_1],
        [98,    DWT.KEYPAD_2],
        [99,    DWT.KEYPAD_3],
        [100,   DWT.KEYPAD_4],
        [101,   DWT.KEYPAD_5],
        [102,   DWT.KEYPAD_6],
        [103,   DWT.KEYPAD_7],
        [104,   DWT.KEYPAD_8],
        [105,   DWT.KEYPAD_9],
        [14,    DWT.KEYPAD_CR],
        [107,   DWT.KEYPAD_ADD],
        [109,   DWT.KEYPAD_SUBTRACT],
        [106,   DWT.KEYPAD_MULTIPLY],
        [111,   DWT.KEYPAD_DIVIDE],
        [110,   DWT.KEYPAD_DECIMAL],

        /* Other keys */
        [20,    DWT.CAPS_LOCK],
        [144,   DWT.NUM_LOCK],
        [145,   DWT.SCROLL_LOCK],
        [44,    DWT.PRINT_SCREEN],
        [6,     DWT.HELP],
        [19,    DWT.PAUSE],
        [3,     DWT.BREAK],

        /* Safari-specific */
        [186,   ';'],
        [187,   '='],
        [189,   '-'],
    ];

public class EvaluateFunction extends BrowserFunction {
    public EvaluateFunction (Browser browser, String name) {
        super (browser, name, false);
    }
    public Object function (Object[] arguments) {
        if (arguments[0] instanceof String) {
            String string = (String)arguments[0];
            if (string.startsWith (ERROR_ID)) {
                String errorString = ExtractError (string);
                if (errorString.length () > 0) {
                    evaluateResult = new DWTException (DWT.ERROR_FAILED_EVALUATE, errorString);
                } else {
                    evaluateResult = new DWTException (DWT.ERROR_FAILED_EVALUATE);
                }
                return null;
            }
        }
        evaluateResult = arguments[0];
        return null;
    }
}

public void addAuthenticationListener (AuthenticationListener listener) {
    AuthenticationListener[] newAuthenticationListeners = new AuthenticationListener[authenticationListeners.length + 1];
    System.arraycopy(authenticationListeners, 0, newAuthenticationListeners, 0, authenticationListeners.length);
    authenticationListeners = newAuthenticationListeners;
    authenticationListeners[authenticationListeners.length - 1] = listener;
}

public class EvaluateFunction extends BrowserFunction {
    public EvaluateFunction (Browser browser, String name) {
        super (browser, name, false);
    }
    public Object function (Object[] arguments) {
        if (arguments[0] instanceof String) {
            String string = (String)arguments[0];
            if (string.startsWith (ERROR_ID)) {
                String errorString = ExtractError (string);
                if (errorString.length () > 0) {
                    evaluateResult = new DWTException (DWT.ERROR_FAILED_EVALUATE, errorString);
                } else {
                    evaluateResult = new DWTException (DWT.ERROR_FAILED_EVALUATE);
                }
                return null;
            }
        }
        evaluateResult = arguments[0];
        return null;
    }
}

public void addAuthenticationListener (AuthenticationListener listener) {
    AuthenticationListener[] newAuthenticationListeners = new AuthenticationListener[authenticationListeners.length + 1];
    System.arraycopy(authenticationListeners, 0, newAuthenticationListeners, 0, authenticationListeners.length);
    authenticationListeners = newAuthenticationListeners;
    authenticationListeners[authenticationListeners.length - 1] = listener;
}

public void addCloseWindowListener (CloseWindowListener listener) {
    //CloseWindowListener[] newCloseWindowListeners = new CloseWindowListener[closeWindowListeners.length + 1];
    //System.arraycopy(closeWindowListeners, 0, newCloseWindowListeners, 0, closeWindowListeners.length);
    //closeWindowListeners = newCloseWindowListeners;
    closeWindowListeners ~= listener;
}

public void addLocationListener (LocationListener listener) {
    //LocationListener[] newLocationListeners = new LocationListener[locationListeners.length + 1];
    //System.arraycopy(locationListeners, 0, newLocationListeners, 0, locationListeners.length);
    //locationListeners = newLocationListeners;
    locationListeners ~= listener;
}

public void addOpenWindowListener (OpenWindowListener listener) {
    //OpenWindowListener[] newOpenWindowListeners = new OpenWindowListener[openWindowListeners.length + 1];
    //System.arraycopy(openWindowListeners, 0, newOpenWindowListeners, 0, openWindowListeners.length);
    //openWindowListeners = newOpenWindowListeners;
    openWindowListeners ~= listener;
}

public void addProgressListener (ProgressListener listener) {
    //ProgressListener[] newProgressListeners = new ProgressListener[progressListeners.length + 1];
    //System.arraycopy(progressListeners, 0, newProgressListeners, 0, progressListeners.length);
    //progressListeners = newProgressListeners;
    progressListeners ~= listener;
}

public void addStatusTextListener (StatusTextListener listener) {
    //StatusTextListener[] newStatusTextListeners = new StatusTextListener[statusTextListeners.length + 1];
    //System.arraycopy(statusTextListeners, 0, newStatusTextListeners, 0, statusTextListeners.length);
    //statusTextListeners = newStatusTextListeners;
    statusTextListeners ~= listener;
}

public void addTitleListener (TitleListener listener) {
    //TitleListener[] newTitleListeners = new TitleListener[titleListeners.length + 1];
    //System.arraycopy(titleListeners, 0, newTitleListeners, 0, titleListeners.length);
    //titleListeners = newTitleListeners;
    titleListeners ~= listener;
}

public void addVisibilityWindowListener (VisibilityWindowListener listener) {
    //VisibilityWindowListener[] newVisibilityWindowListeners = new VisibilityWindowListener[visibilityWindowListeners.length + 1];
    //System.arraycopy(visibilityWindowListeners, 0, newVisibilityWindowListeners, 0, visibilityWindowListeners.length);
    //visibilityWindowListeners = newVisibilityWindowListeners;
    visibilityWindowListeners ~= listener;
}

public abstract bool back ();

public static void clearSessions () {
    if (NativeClearSessions !is null) NativeClearSessions.run ();
    if (MozillaClearSessions !is null) MozillaClearSessions.run ();
}

public static String GetCookie (String name, String url) {
    CookieName = name; CookieUrl = url;
    if (NativeGetCookie !is null) NativeGetCookie.run ();
    if (MozillaGetCookie !is null) MozillaGetCookie.run ();
    String result = CookieValue;
    CookieName = CookieValue = CookieUrl = null;
    return result;
}

public static bool SetCookie (String value, String url) {
    CookieValue = value; CookieUrl = url;
    CookieResult = false;
    if (NativeSetCookie !is null) NativeSetCookie.run ();
    if (MozillaSetCookie !is null) MozillaSetCookie.run ();
    CookieValue = CookieUrl = null;
    return CookieResult;
}

public abstract void create (Composite parent, int style);

static String CreateErrorString (String error) {
    return ERROR_ID + error;
}

static String ExtractError (String error) {
    return error.substring (ERROR_ID.length ());
}

public void createFunction (BrowserFunction function) {
    /* 
     * If an existing function with the same name is found then
     * remove it so that it is not recreated on subsequent pages
     * (the new function overwrites the old one).
     */
    Enumeration keys = functions.keys ();
    while (keys.hasMoreElements ()) {
        Object key = keys.nextElement ();
        BrowserFunction current = (BrowserFunction)functions.get (key);
        if (current.name.equals (function.name)) {
            functions.remove (key);
            break;
        }
    }

    function.index = getNextFunctionIndex ();
    registerFunction (function);

    StringBuffer buffer = new StringBuffer ("window."); //$NON-NLS-1$
    buffer.append (function.name);
    buffer.append (" = function "); //$NON-NLS-1$
    buffer.append (function.name);
    buffer.append ("() {var result = window.external.callJava("); //$NON-NLS-1$
    buffer.append (function.index);
    buffer.append (",Array.prototype.slice.call(arguments)); if (typeof result is 'string' && result.indexOf('"); //$NON-NLS-1$
    buffer.append (ERROR_ID);
    buffer.append ("') is 0) {var error = new Error(result.substring("); //$NON-NLS-1$
    buffer.append (ERROR_ID.length ());
    buffer.append (")); throw error;} return result;};"); //$NON-NLS-1$
    buffer.append ("for (var i = 0; i < frames.length; i++) {try { frames[i]."); //$NON-NLS-1$
    buffer.append (function.name);
    buffer.append (" = window."); //$NON-NLS-1$
    buffer.append (function.name);
    buffer.append (";} catch (e) {} };"); //$NON-NLS-1$
    function.functionString = buffer.toString ();
    execute (function.functionString);
}

void deregisterFunction (BrowserFunction function) {
    functions.remove (new Integer (function.index));
}

public void destroyFunction (BrowserFunction function) {
    String deleteString = getDeleteFunctionString (function.name); 
    StringBuffer buffer = new StringBuffer ("for (var i = 0; i < frames.length; i++) {try {frames[i].eval(\""); //$NON-NLS-1$
    buffer.append (deleteString);
    buffer.append ("\");} catch (e) {}}"); //$NON-NLS-1$
    execute (buffer.toString ());
    execute (deleteString);
    deregisterFunction (function);
}

public abstract bool execute (String script);

public Object evaluate (String script) throws DWTException {
    BrowserFunction function = new EvaluateFunction (browser, ""); // $NON-NLS-1$
    int index = getNextFunctionIndex ();
    function.index = index;
    function.isEvaluate = true;
    registerFunction (function);
    String functionName = EXECUTE_ID + index;

    StringBuffer buffer = new StringBuffer ("window."); // $NON-NLS-1$
    buffer.append (functionName);
    buffer.append (" = function "); // $NON-NLS-1$
    buffer.append (functionName);
    buffer.append ("() {\n"); // $NON-NLS-1$
    buffer.append (script);
    buffer.append ("\n};"); // $NON-NLS-1$
    execute (buffer.toString ());

    buffer = new StringBuffer ("if (window."); // $NON-NLS-1$
    buffer.append (functionName);
    buffer.append (" is undefined) {window.external.callJava("); // $NON-NLS-1$
    buffer.append (index);
    buffer.append (", ['"); // $NON-NLS-1$
    buffer.append (ERROR_ID);
    buffer.append ("']);} else {try {var result = "); // $NON-NLS-1$
    buffer.append (functionName);
    buffer.append ("(); window.external.callJava("); // $NON-NLS-1$
    buffer.append (index);
    buffer.append (", [result]);} catch (e) {window.external.callJava("); // $NON-NLS-1$
    buffer.append (index);
    buffer.append (", ['"); // $NON-NLS-1$
    buffer.append (ERROR_ID);
    buffer.append ("' + e.message]);}}"); // $NON-NLS-1$
    execute (buffer.toString ());
    execute (getDeleteFunctionString (functionName));
    deregisterFunction (function);

    Object result = evaluateResult;
    evaluateResult = null;
    if (result instanceof DWTException) throw (DWTException)result;
    return result;
}

public abstract bool forward ();

String getDeleteFunctionString (String functionName) {
    return "delete window." + functionName; //$NON-NLS-1$
}

int getNextFunctionIndex () {
    return nextFunctionIndex++;
}

String getDeleteFunctionString (String functionName) {
    return "delete window." + functionName; //$NON-NLS-1$
}

int getNextFunctionIndex () {
    return nextFunctionIndex++;
}

public abstract String getText ();

public abstract String getUrl ();

public Object getWebBrowser () {
    return null;
}

public abstract bool isBackEnabled ();

public bool isFocusControl () {
    return false;
}

public abstract bool isForwardEnabled ();

public abstract void refresh ();

void registerFunction (BrowserFunction function) {
    functions.put (new Integer (function.index), function);
}

public void removeAuthenticationListener (AuthenticationListener listener) {
    if (authenticationListeners.length is 0) return;
    int index = -1;
    for (int i = 0; i < authenticationListeners.length; i++) {
        if (listener is authenticationListeners[i]) {
            index = i;
            break;
        }
    }
    if (index is -1) return;
    if (authenticationListeners.length is 1) {
        authenticationListeners = new AuthenticationListener[0];
        return;
    }
    AuthenticationListener[] newAuthenticationListeners = new AuthenticationListener[authenticationListeners.length - 1];
    System.arraycopy (authenticationListeners, 0, newAuthenticationListeners, 0, index);
    System.arraycopy (authenticationListeners, index + 1, newAuthenticationListeners, index, authenticationListeners.length - index - 1);
    authenticationListeners = newAuthenticationListeners;
}

void registerFunction (BrowserFunction function) {
    functions.put (new Integer (function.index), function);
}

public void removeAuthenticationListener (AuthenticationListener listener) {
    if (authenticationListeners.length is 0) return;
    int index = -1;
    for (int i = 0; i < authenticationListeners.length; i++) {
        if (listener is authenticationListeners[i]) {
            index = i;
            break;
        }
    }
    if (index is -1) return;
    if (authenticationListeners.length is 1) {
        authenticationListeners = new AuthenticationListener[0];
        return;
    }
    AuthenticationListener[] newAuthenticationListeners = new AuthenticationListener[authenticationListeners.length - 1];
    System.arraycopy (authenticationListeners, 0, newAuthenticationListeners, 0, index);
    System.arraycopy (authenticationListeners, index + 1, newAuthenticationListeners, index, authenticationListeners.length - index - 1);
    authenticationListeners = newAuthenticationListeners;
}

public void removeCloseWindowListener (CloseWindowListener listener) {
    if (closeWindowListeners.length is 0) return;
    int index = -1;
    for (int i = 0; i < closeWindowListeners.length; i++) {
        if (listener is closeWindowListeners[i]){
            index = i;
            break;
        }
    }
    if (index is -1) return;
    if (closeWindowListeners.length is 1) {
        closeWindowListeners = new CloseWindowListener[0];
        return;
    }
    //CloseWindowListener[] newCloseWindowListeners = new CloseWindowListener[closeWindowListeners.length - 1];
    //System.arraycopy (closeWindowListeners, 0, newCloseWindowListeners, 0, index);
    //System.arraycopy (closeWindowListeners, index + 1, newCloseWindowListeners, index, closeWindowListeners.length - index - 1);
    closeWindowListeners = closeWindowListeners[0..index] ~ closeWindowListeners[index+1..$];
}

public void removeLocationListener (LocationListener listener) {
    if (locationListeners.length is 0) return;
    int index = -1;
    for (int i = 0; i < locationListeners.length; i++) {
        if (listener is locationListeners[i]){
            index = i;
            break;
        }
    }
    if (index is -1) return;
    if (locationListeners.length is 1) {
        locationListeners = new LocationListener[0];
        return;
    }
    //LocationListener[] newLocationListeners = new LocationListener[locationListeners.length - 1];
    //System.arraycopy (locationListeners, 0, newLocationListeners, 0, index);
    //System.arraycopy (locationListeners, index + 1, newLocationListeners, index, locationListeners.length - index - 1);
    locationListeners = locationListeners[0..index] ~ locationListeners[index+1..$];
}

public void removeOpenWindowListener (OpenWindowListener listener) {
    if (openWindowListeners.length is 0) return;
    int index = -1;
    for (int i = 0; i < openWindowListeners.length; i++) {
        if (listener is openWindowListeners[i]){
            index = i;
            break;
        }
    }
    if (index is -1) return;
    if (openWindowListeners.length is 1) {
        openWindowListeners = new OpenWindowListener[0];
        return;
    }
    //OpenWindowListener[] newOpenWindowListeners = new OpenWindowListener[openWindowListeners.length - 1];
    //System.arraycopy (openWindowListeners, 0, newOpenWindowListeners, 0, index);
    //System.arraycopy (openWindowListeners, index + 1, newOpenWindowListeners, index, openWindowListeners.length - index - 1);
    openWindowListeners = openWindowListeners[0..index] ~ openWindowListeners[index+1..$];
}

public void removeProgressListener (ProgressListener listener) {
    if (progressListeners.length is 0) return;
    int index = -1;
    for (int i = 0; i < progressListeners.length; i++) {
        if (listener is progressListeners[i]){
            index = i;
            break;
        }
    }
    if (index is -1) return;
    if (progressListeners.length is 1) {
        progressListeners = new ProgressListener[0];
        return;
    }
    //ProgressListener[] newProgressListeners = new ProgressListener[progressListeners.length - 1];
    //System.arraycopy (progressListeners, 0, newProgressListeners, 0, index);
    //System.arraycopy (progressListeners, index + 1, newProgressListeners, index, progressListeners.length - index - 1);
    progressListeners = progressListeners[0..index] ~ progressListeners[index+1..$];
}

public void removeStatusTextListener (StatusTextListener listener) {
    if (statusTextListeners.length is 0) return;
    int index = -1;
    for (int i = 0; i < statusTextListeners.length; i++) {
        if (listener is statusTextListeners[i]){
            index = i;
            break;
        }
    }
    if (index is -1) return;
    if (statusTextListeners.length is 1) {
        statusTextListeners = new StatusTextListener[0];
        return;
    }
    //StatusTextListener[] newStatusTextListeners = new StatusTextListener[statusTextListeners.length - 1];
    //System.arraycopy (statusTextListeners, 0, newStatusTextListeners, 0, index);
    //System.arraycopy (statusTextListeners, index + 1, newStatusTextListeners, index, statusTextListeners.length - index - 1);
    statusTextListeners = statusTextListeners[0..index] ~ statusTextListeners[index+1..$];
}

public void removeTitleListener (TitleListener listener) {
    if (titleListeners.length is 0) return;
    int index = -1;
    for (int i = 0; i < titleListeners.length; i++) {
        if (listener is titleListeners[i]){
            index = i;
            break;
        }
    }
    if (index is -1) return;
    if (titleListeners.length is 1) {
        titleListeners = new TitleListener[0];
        return;
    }
    TitleListener[] newTitleListeners = new TitleListener[titleListeners.length - 1];
    //System.arraycopy (titleListeners, 0, newTitleListeners, 0, index);
    //System.arraycopy (titleListeners, index + 1, newTitleListeners, index, titleListeners.length - index - 1);
    titleListeners = titleListeners[0..index] ~ titleListeners[index+1..$];
}

public void removeVisibilityWindowListener (VisibilityWindowListener listener) {
    if (visibilityWindowListeners.length is 0) return;
    int index = -1;
    for (int i = 0; i < visibilityWindowListeners.length; i++) {
        if (listener is visibilityWindowListeners[i]){
            index = i;
            break;
        }
    }
    if (index is -1) return;
    if (visibilityWindowListeners.length is 1) {
        visibilityWindowListeners = new VisibilityWindowListener[0];
        return;
    }
    //VisibilityWindowListener[] newVisibilityWindowListeners = new VisibilityWindowListener[visibilityWindowListeners.length - 1];
    //System.arraycopy (visibilityWindowListeners, 0, newVisibilityWindowListeners, 0, index);
    //System.arraycopy (visibilityWindowListeners, index + 1, newVisibilityWindowListeners, index, visibilityWindowListeners.length - index - 1);
    visibilityWindowListeners = visibilityWindowListeners[0..index] ~ visibilityWindowListeners[index+1..$];
}

public void setBrowser (Browser browser) {
    this.browser = browser;
}

public abstract bool setText (String html);

public abstract bool setUrl (String url);

public abstract void stop ();

int translateKey (int key) {
    for (int i = 0; i < KeyTable.length; i++) {
        if (KeyTable[i][0] is key) return KeyTable[i][1];
    }
    return 0;
}
}
