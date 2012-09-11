﻿/*******************************************************************************
 * Copyright (c) 2000, 2009 IBM Corporation and others.
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
module dwt.widgets.FileDialog;

import dwt.dwthelper.utils;






import dwt.DWT;
import dwt.internal.cocoa.NSOpenPanel;
import dwt.internal.cocoa.NSSavePanel;
import dwt.internal.cocoa.NSPopUpButton;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSMenu;
import dwt.internal.cocoa.NSMenuItem;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSApplication;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSFileManager;
import dwt.internal.cocoa.SWTPanelDelegate;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;
import dwt.widgets.Dialog;
import dwt.widgets.Shell;
import dwt.widgets.Display;

/**
 * Instances of this class allow the user to navigate
 * the file system and select or enter a file name.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>SAVE, OPEN, MULTI</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
 * </dl>
 * <p>
 * Note: Only one of the styles SAVE and OPEN may be specified.
 * </p><p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the DWT implementation.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#filedialog">FileDialog snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">DWT Example: ControlExample, Dialog tab</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 * @noextend This class is not intended to be subclassed by clients.
 */
public class FileDialog : Dialog {
    NSSavePanel panel;
    NSPopUpButton popup;
    String [] filterNames;
    String [] filterExtensions;
    String [] fileNames;
    String filterPath = "", fileName = "";
    int filterIndex = -1;
    bool overwrite = false;
    static final char EXTENSION_SEPARATOR = ';';

/**
 * Constructs a new instance of this class given only its parent.
 *
 * @param parent a shell which will be the parent of the new instance
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 */
public this (Shell parent) {
    this (parent, DWT.APPLICATION_MODAL);
}

/**
 * Constructs a new instance of this class given its parent
 * and a style value describing its behavior and appearance.
 * <p>
 * The style value is either one of the style constants defined in
 * class <code>DWT</code> which is applicable to instances of this
 * class, or must be built by <em>bitwise OR</em>'ing together
 * (that is, using the <code>int</code> "|" operator) two or more
 * of those <code>DWT</code> style constants. The class description
 * lists the style constants that are applicable to the class.
 * Style bits are also inherited from superclasses.
 * </p>
 *
 * @param parent a shell which will be the parent of the new instance
 * @param style the style of dialog to construct
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see DWT#SAVE
 * @see DWT#OPEN
 * @see DWT#MULTI
 */
public this (Shell parent, int style) {
    super (parent, checkStyle (parent, style));
    if (Display.getSheetEnabled ()) {
        if (parent !is null && (style & DWT.SHEET) !is 0) this.style |= DWT.SHEET;
    }
    checkSubclass ();

    filterNames = new String [0];
    filterExtensions = new String [0];
    fileNames = new String [0];
}

/**
 * Returns the path of the first file that was
 * selected in the dialog relative to the filter path, or an
 * empty string if no such file has been selected.
 *
 * @return the relative path of the file
 */
public String getFileName () {
    return fileName;
}

/**
 * Returns a (possibly empty) array with the paths of all files
 * that were selected in the dialog relative to the filter path.
 *
 * @return the relative paths of the files
 */
public String [] getFileNames () {
    return fileNames;
}

/**
 * Returns the file extensions which the dialog will
 * use to filter the files it shows.
 *
 * @return the file extensions filter
 */
public String [] getFilterExtensions () {
    return filterExtensions;
}

/**
 * Get the 0-based index of the file extension filter
 * which was selected by the user, or -1 if no filter
 * was selected.
 * <p>
 * This is an index into the FilterExtensions array and
 * the FilterNames array.
 * </p>
 *
 * @return index the file extension filter index
 *
 * @see #getFilterExtensions
 * @see #getFilterNames
 *
 * @since 3.4
 */
public int getFilterIndex () {
    return filterIndex;
}

/**
 * Returns the names that describe the filter extensions
 * which the dialog will use to filter the files it shows.
 *
 * @return the list of filter names
 */
public String [] getFilterNames () {
    return filterNames;
}

/**
 * Returns the directory path that the dialog will use, or an empty
 * string if this is not set.  File names in this path will appear
 * in the dialog, filtered according to the filter extensions.
 *
 * @return the directory path string
 *
 * @see #setFilterExtensions
 */
public String getFilterPath () {
    return filterPath;
}

/**
 * Returns the flag that the dialog will use to
 * determine whether to prompt the user for file
 * overwrite if the selected file already exists.
 *
 * @return true if the dialog will prompt for file overwrite, false otherwise
 *
 * @since 3.4
 */
public bool getOverwrite () {
    return overwrite;
}

/**
 * Makes the dialog visible and brings it to the front
 * of the display.
 *
 * @return a string describing the absolute path of the first selected file,
 *         or null if the dialog was cancelled or an error occurred
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the dialog has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the dialog</li>
 * </ul>
 */
public String open () {
    String fullPath = null;
    fileNames = new String [0];
    objc.Method method = null;
    objc.IMP methodImpl = null;
    objc.IMP callback = null;
    if ((style & DWT.SAVE) !is 0) {
        NSSavePanel savePanel = NSSavePanel.savePanel();
        panel = savePanel;
        if (!overwrite) {
            callback = cast(objc.IMP)&_overwriteExistingFileCheck;
            method = OS.class_getInstanceMethod(OS.class_NSSavePanel, OS.sel_overwriteExistingFileCheck);
            if (method !is null) methodImpl = OS.method_setImplementation(method, callback);
        }
    } else {
        NSOpenPanel openPanel = NSOpenPanel.openPanel();
        openPanel.setAllowsMultipleSelection((style & DWT.MULTI) !is 0);
        panel = openPanel;
    }
    panel.setCanCreateDirectories(true);
    void* jniRef = null;
    SWTPanelDelegate delegate_ = null;
    if (filterExtensions !is null && filterExtensions.length !is 0) {
        delegate_ = cast(SWTPanelDelegate)(new SWTPanelDelegate()).alloc().init();
        jniRef = OS.NewGlobalRef(this);
        if (jniRef is null) DWT.error(DWT.ERROR_NO_HANDLES);
        OS.object_setInstanceVariable(delegate_.id, Display.SWT_OBJECT, jniRef);
        panel.setDelegate(delegate_);
        NSPopUpButton widget = cast(NSPopUpButton)(new NSPopUpButton()).alloc();
        widget.initWithFrame(NSRect(), false);
        widget.setTarget(delegate_);
        widget.setAction(OS.sel_sendSelection_);
        NSMenu menu = widget.menu();
        menu.setAutoenablesItems(false);
        for (int i = 0; i < filterExtensions.length; i++) {
            String str = filterExtensions [i];
            if (filterNames !is null && filterNames.length > i) {
                str = filterNames [i];
            }
            NSMenuItem nsItem = cast(NSMenuItem)(new NSMenuItem()).alloc();
            nsItem.initWithTitle(NSString.stringWith(str), null, NSString.stringWith(""));
            menu.addItem(nsItem);
            nsItem.release();
        }
        widget.selectItemAtIndex(0 <= filterIndex && filterIndex < filterExtensions.length ? filterIndex : 0);
        widget.sizeToFit();
        panel.setAccessoryView(widget);
        popup = widget;
    }
    panel.setTitle(NSString.stringWith(title !is null ? title : ""));
    NSApplication application = NSApplication.sharedApplication();
    if (parent !is null && (style & DWT.SHEET) !is 0) {
        application.beginSheet(panel, parent.window, null, null, null);
    }
    NSString dir = filterPath !is null ? NSString.stringWith(filterPath) : null;
    NSString file = fileName !is null ? NSString.stringWith(fileName) : null;
    NSInteger response = panel.runModalForDirectory(dir, file);
    if (parent !is null && (style & DWT.SHEET) !is 0) {
        application.endSheet(panel, 0);
    }
    if (!overwrite) {
        if (method !is null) OS.method_setImplementation(method, methodImpl);
        /+if (callback !is null) callback.dispose();+/
    }
    if (response is OS.NSFileHandlingPanelOKButton) {
        NSString filename = panel.filename();
        fullPath = filename.getString();
        if ((style & DWT.SAVE) is 0) {
            NSArray filenames = (cast(NSOpenPanel)panel).filenames();
            NSUInteger count = filenames.count();
            fileNames = new String[count];

            for (NSUInteger i = 0; i < count; i++) {
                filename = new NSString(filenames.objectAtIndex(i));
                NSString filenameOnly = filename.lastPathComponent();
                NSString pathOnly = filename.stringByDeletingLastPathComponent();

                if (i is 0) {
                    /* Filter path */
                    filterPath = pathOnly.getString();

                    /* File name */
                    fileName = fileNames [0] = filenameOnly.getString();
                } else {
                    if (pathOnly.getString().equals (filterPath)) {
                        fileNames [i] = filenameOnly.getString();
                    } else {
                        fileNames [i] = filename.getString();
                    }
                }
            }
        }
        filterIndex = -1;
    }
    if (popup !is null) {
        filterIndex = popup.indexOfSelectedItem();
        panel.setAccessoryView(null);
        popup.release();
        popup = null;
    }
    if (delegate_ !is null) {
        panel.setDelegate(null);
        delegate_.release();
    }
    if (jniRef !is null) OS.DeleteGlobalRef(jniRef);
    panel = null;
    return fullPath;
}

static extern(C) objc.id _overwriteExistingFileCheck (objc.id id, objc.SEL sel, objc.id str) {
    return cast(objc.id)1;
}

objc.id panel_shouldShowFilename (objc.id id, objc.SEL sel, objc.id arg0, objc.id arg1) {
    NSString path = new NSString(arg1);
    if (filterExtensions !is null && filterExtensions.length !is 0) {
        NSFileManager manager = NSFileManager.defaultManager();
        bool* ptr = cast(bool*)OS.malloc(1);
        bool found = manager.fileExistsAtPath(path, ptr);
        byte[] isDirectory = new byte[1];
        OS.memmove(isDirectory.ptr, ptr, 1);
        OS.free(ptr);
        if (found) {
            if (isDirectory[0] !is 0) {
                return cast(objc.id)1;
            } else {
                NSString ext = path.pathExtension();
                if (ext !is null) {
                    NSInteger filterIndex = popup.indexOfSelectedItem();
                    String extension = ext.getString();
                    String extensions = filterExtensions [filterIndex];
                    int start = 0, length = extensions.length;
                    while (start < length) {
                        int index = extensions.indexOf (EXTENSION_SEPARATOR, start);
                        if (index is -1) index = length;
                        String filter = extensions.substring (start, index).trim ();
                        if (filter.equals ("*") || filter.equals ("*.*")) return cast(objc.id)1;
                        if (filter.startsWith ("*.")) filter = filter.substring (2);
                        if (filter.toLowerCase ().equals(extension.toLowerCase ())) return cast(objc.id)1;
                        start = index + 1;
                    }
                }
                return cast(objc.id)0;
            }
        }
    }
    return cast(objc.id)1;
}

void sendSelection (objc.id id, objc.SEL sel, objc.id arg) {
    panel.validateVisibleColumns();
}

/**
 * Set the initial filename which the dialog will
 * select by default when opened to the argument,
 * which may be null.  The name will be prefixed with
 * the filter path when one is supplied.
 *
 * @param string the file name
 */
public void setFileName (String string) {
    fileName = string;
}

/**
 * Set the file extensions which the dialog will
 * use to filter the files it shows to the argument,
 * which may be null.
 * <p>
 * The strings are platform specific. For example, on
 * some platforms, an extension filter string is typically
 * of the form "*.extension", where "*.*" matches all files.
 * For filters with multiple extensions, use semicolon as
 * a separator, e.g. "*.jpg;*.png".
 * </p>
 *
 * @param extensions the file extension filter
 *
 * @see #setFilterNames to specify the user-friendly
 * names corresponding to the extensions
 */
public void setFilterExtensions (String [] extensions) {
    filterExtensions = extensions;
}

/**
 * Set the 0-based index of the file extension filter
 * which the dialog will use initially to filter the files
 * it shows to the argument.
 * <p>
 * This is an index into the FilterExtensions array and
 * the FilterNames array.
 * </p>
 *
 * @param index the file extension filter index
 *
 * @see #setFilterExtensions
 * @see #setFilterNames
 *
 * @since 3.4
 */
public void setFilterIndex (int index) {
    filterIndex = index;
}

/**
 * Sets the names that describe the filter extensions
 * which the dialog will use to filter the files it shows
 * to the argument, which may be null.
 * <p>
 * Each name is a user-friendly short description shown for
 * its corresponding filter. The <code>names</code> array must
 * be the same length as the <code>extensions</code> array.
 * </p>
 *
 * @param names the list of filter names, or null for no filter names
 *
 * @see #setFilterExtensions
 */
public void setFilterNames (String [] names) {
    filterNames = names;
}

/**
 * Sets the directory path that the dialog will use
 * to the argument, which may be null. File names in this
 * path will appear in the dialog, filtered according
 * to the filter extensions. If the string is null,
 * then the operating system's default filter path
 * will be used.
 * <p>
 * Note that the path string is platform dependent.
 * For convenience, either '/' or '\' can be used
 * as a path separator.
 * </p>
 *
 * @param string the directory path
 *
 * @see #setFilterExtensions
 */
public void setFilterPath (String string) {
    filterPath = string;
}

/**
 * Sets the flag that the dialog will use to
 * determine whether to prompt the user for file
 * overwrite if the selected file already exists.
 *
 * @param overwrite true if the dialog will prompt for file overwrite, false otherwise
 *
 * @since 3.4
 */
public void setOverwrite (bool overwrite) {
    this.overwrite = overwrite;
}
}
