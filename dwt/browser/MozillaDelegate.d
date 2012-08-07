/*******************************************************************************
 * Copyright (c) 2003, 2009 IBM Corporation and others.
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
module dwt.browser.MozillaDelegate;

import dwt.dwthelper.utils;

import dwt.DWT;

import dwt.browser.Browser;
import dwt.browser.Mozilla;
import objc = dwt.internal.objc.runtime;
import dwt.widgets.*;

class MozillaDelegate {
    Browser browser;
    Listener listener;
    boolean hasFocus;

this (Browser browser) {
    this.browser = browser;
}

static Browser findBrowser (objc.id handle) {
    Display display = Display.getCurrent ();
    return cast(Browser)display.findWidget (handle);
}

/+static char[] mbcsToWcs (String codePage, byte [] buffer) {
//  int encoding = OS.CFStringGetSystemEncoding ();
//  int cfstring = OS.CFStringCreateWithBytes (OS.kCFAllocatorDefault, buffer, buffer.length, encoding, false);
//  char[] chars = null;
//  if (cfstring != 0) {
//      int length = OS.CFStringGetLength (cfstring);
//      chars = new char [length];
//      if (length != 0) {
//          CFRange range = new CFRange ();
//          range.length = length;
//          OS.CFStringGetCharacters (cfstring, range, chars);
//      }
//      OS.CFRelease (cfstring);
//  }
//  return chars;
    // TODO implement mbcsToWcs
    return new_String(buffer).toCharArray();
}+/

/+static byte[] wcsToMbcs (String codePage, String string, boolean terminate) {
//  char[] chars = new char [string.length()];
//  string.getChars (0, chars.length, chars, 0);
//  int cfstring = OS.CFStringCreateWithCharacters (OS.kCFAllocatorDefault, chars, chars.length);
//  byte[] buffer = null;
//  if (cfstring != 0) {
//      CFRange range = new CFRange ();
//      range.length = chars.length;
//      int encoding = OS.CFStringGetSystemEncoding ();
//      int[] size = new int[1];
//      int numChars = OS.CFStringGetBytes (cfstring, range, encoding, (byte)'?', true, null, 0, size);
//      buffer = new byte [size[0] + (terminate ? 1 : 0)];
//      if (numChars != 0) {
//          numChars = OS.CFStringGetBytes (cfstring, range, encoding, (byte)'?', true, buffer, size[0], size);
//      }
//      OS.CFRelease (cfstring);
//  }
//  return buffer;
    // TODO implement wcsToMbcs
    if (terminate) string += "\0";
    return string.getBytes();
}+/

void addWindowSubclass () {
}

void addWindowSubclass () {
}

int createBaseWindow (nsIBaseWindow baseWindow) {
    /*
    * Feature of Mozilla on OSX.  Mozilla replaces the OSX application menu whenever
    * a browser's base window is created.  The workaround is to restore the previous
    * menu after creating the base window.
    */
    NSApplication application = NSApplication.sharedApplication ();
    NSMenu mainMenu = application.mainMenu ();
    mainMenu.retain ();
    int rc = baseWindow.Create ();
    application.setMainMenu (mainMenu);
    mainMenu.release ();
    return rc;
}

    return browser.view.id;
}

String getJSLibraryName () {
    return "libmozjs.dylib"; //$NON-NLS-1$
}

String getLibraryName () {
    return "libxpcom.dylib"; //$NON-NLS-1$
}

String getSWTInitLibraryName () {
    return "swt-xulrunner"; //$NON-NLS-1$
}

void handleFocus () {
    if (hasFocus) return;
    hasFocus = true;
    (cast(Mozilla)browser.webBrowser).Activate ();
    browser.setFocus ();
    listener = new class () Listener {
        public void handleEvent (Event event) {
            if (event.widget == browser) return;
            (cast(Mozilla)browser.webBrowser).Deactivate ();
            hasFocus = false;
            browser.getDisplay ().removeFilter (DWT.FocusIn, this);
            browser.getShell ().removeListener (DWT.Deactivate, this);
            listener = null;
        }

    };
    browser.getDisplay ().addFilter (DWT.FocusIn, listener);
    browser.getShell ().addListener (DWT.Deactivate, listener);
}

void handleMouseDown () {
}

boolean hookEnterExit () {
    return true;
}

void init () {
}

boolean needsSpinup () {
    return false;
}

void onDispose (objc.id embedHandle) {
    if (listener !is null) {
        browser.getDisplay ().removeFilter (DWT.FocusIn, listener);
        browser.getShell ().removeListener (DWT.Deactivate, listener);
        listener = null;
    }
    browser = null;
}

void removeWindowSubclass () {
}

void removeWindowSubclass () {
}

void setSize (objc.id embedHandle, int width, int height) {
    // TODO
}

}
