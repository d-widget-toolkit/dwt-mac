/*******************************************************************************
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
module dwt.printing.PrintDialog;

import dwt.dwthelper.utils;
import dwt.dwthelper.System;



import dwt.DWT;
import dwt.internal.cocoa.NSNumber;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSPrintInfo;
import dwt.internal.cocoa.NSPrintPanel;
import dwt.internal.cocoa.NSPrinter;
import dwt.internal.cocoa.NSApplication;
import dwt.internal.cocoa.NSData;
import dwt.internal.cocoa.NSKeyedArchiver;
import dwt.internal.cocoa.NSMutableDictionary;
import dwt.internal.cocoa.SWTPrintPanelDelegate;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import dwt.internal.C;
import dwt.printing.Printer;
import dwt.printing.PrinterData;
import dwt.widgets.Dialog;
import dwt.widgets.Shell;




/**
 * Instances of this class allow the user to select
 * a printer and various print-related parameters
 * prior to starting a print job.
 * <p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the DWT implementation.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#printing">Printing snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">DWT Example: ControlExample, Dialog tab</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 * @noextend This class is not intended to be subclassed by clients.
 */
public class PrintDialog : Dialog {
    PrinterData printerData = new PrinterData();
    int returnCode;

    // the following Callbacks are never freed
/+  static Callback dialogCallback5;
+/  static final char[] DWT_OBJECT = ['S', 'W', 'T', '_', 'O', 'B', 'J', 'E', 'C', 'T', '\0'];

/**
 * Constructs a new instance of this class given only its parent.
 *
 * @param parent a composite control which will be the parent of the new instance (cannot be null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see DWT
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Shell parent) {
    this (parent, DWT.PRIMARY_MODAL);
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
 * @param parent a composite control which will be the parent of the new instance (cannot be null)
 * @param style the style of control to construct
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see DWT
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Shell parent, int style) {
    super (parent, checkStyle(parent, style));
    checkSubclass ();
}

static int checkStyle (Shell parent, int style) {
    int mask = DWT.PRIMARY_MODAL | DWT.APPLICATION_MODAL | DWT.SYSTEM_MODAL;
    if ((style & DWT.SHEET) !is 0) {
        if (getSheetEnabled ()) {
            if (parent is null) {
                style &= ~DWT.SHEET;
            }
        } else {
            style &= ~DWT.SHEET;
        }
        if ((style & mask) is 0) {
            style |= parent is null ? DWT.APPLICATION_MODAL : DWT.PRIMARY_MODAL;
        }
    }
    return style;
}

/**
 * Sets the printer data that will be used when the dialog
 * is opened.
 * <p>
 * Setting the printer data to null is equivalent to
 * resetting all data fields to their default values.
 * </p>
 *
 * @param data the data that will be used when the dialog is opened or null to use default data
 *
 * @since 3.4
 */
public void setPrinterData(PrinterData data) {
    this.printerData = data;
}

/**
 * Returns the printer data that will be used when the dialog
 * is opened.
 *
 * @return the data that will be used when the dialog is opened
 *
 * @since 3.4
 */
public PrinterData getPrinterData() {
    return printerData;
}

/**
 * Makes the receiver visible and brings it to the front
 * of the display.
 *
 * @return a printer data object describing the desired print job parameters,
 *         or null if the dialog was canceled, no printers were found, or an error occurred
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public PrinterData open() {
    PrinterData data = null;
    NSPrintPanel panel = NSPrintPanel.printPanel();
    NSPrintInfo printInfo = new NSPrintInfo(NSPrintInfo.sharedPrintInfo().copy());
    printInfo.setOrientation(cast(NSPrintingOrientation)(printerData.orientation is PrinterData.LANDSCAPE ? OS.NSLandscapeOrientation : OS.NSPortraitOrientation));
    NSMutableDictionary dict = printInfo.dictionary();
    dict.setValue(NSNumber.numberWithBool(printerData.collate), OS.NSPrintMustCollate);
    dict.setValue(NSNumber.numberWithInt(printerData.copyCount), OS.NSPrintCopies);
    if (printerData.printToFile) {
        dict.setValue(OS.NSPrintSaveJob, OS.NSPrintJobDisposition);
    }
    if (printerData.fileName !is null && printerData.fileName.length > 0) {
        dict.setValue(NSString.stringWith(printerData.fileName), OS.NSPrintSavePath);
    }
    dict.setValue(NSNumber.numberWithBool(printerData.scope_ is PrinterData.ALL_PAGES), OS.NSPrintAllPages);
    if (printerData.scope_ is PrinterData.PAGE_RANGE) {
        dict.setValue(NSNumber.numberWithInt(printerData.startPage), OS.NSPrintFirstPage);
        dict.setValue(NSNumber.numberWithInt(printerData.endPage), OS.NSPrintLastPage);
    }
    panel.setOptions(OS.NSPrintPanelShowsPageSetupAccessory | panel.options());
    int response;
    if ((getStyle () & DWT.SHEET) !is 0) {
        initClasses();
        SWTPrintPanelDelegate delegate_ = cast(SWTPrintPanelDelegate)(new SWTPrintPanelDelegate()).alloc().init();
        void* jniRef = OS.NewGlobalRef(this);
        if (jniRef is null) DWT.error(DWT.ERROR_NO_HANDLES);
        OS.object_setInstanceVariable(delegate_.id, DWT_OBJECT, jniRef);
        returnCode = -1;
        Shell parent = getParent();
        panel.beginSheetWithPrintInfo(printInfo, parent.view.window(), delegate_, OS.sel_panelDidEnd_returnCode_contextInfo_, null);
        NSApplication application = NSApplication.sharedApplication();
        while (returnCode is -1) application.run();
        if (delegate_ !is null) delegate_.release();
        if (jniRef !is null) OS.DeleteGlobalRef(jniRef);
        response = returnCode;
    } else {
        response = panel.runModalWithPrintInfo(printInfo);
    }
    if (response !is OS.NSCancelButton) {
        NSPrinter printer = printInfo.printer();
        NSString str = printer.name();
        data = new PrinterData(Printer.DRIVER, str.getString());
        data.printToFile = printInfo.jobDisposition().isEqual(OS.NSPrintSaveJob);
        if (data.printToFile) {
            NSString filename = new NSString(dict.objectForKey(OS.NSPrintSavePath));
            data.fileName = filename.getString();
        }
        data.scope_ = (new NSNumber(dict.objectForKey(OS.NSPrintAllPages))).intValue() !is 0 ? PrinterData.ALL_PAGES : PrinterData.PAGE_RANGE;
        if (data.scope_ is PrinterData.PAGE_RANGE) {
            data.startPage = (new NSNumber(dict.objectForKey(OS.NSPrintFirstPage))).intValue();
            data.endPage = (new NSNumber(dict.objectForKey(OS.NSPrintLastPage))).intValue();
        }
        data.collate = (new NSNumber(dict.objectForKey(OS.NSPrintMustCollate))).intValue() !is 0;
        data.collate = false; //TODO: Only set to false if the printer does the collate internally (most printers do)
    	data.copyCount = (new NSNumber(dict.objectForKey(OS.NSPrintCopies))).intValue();
        data.copyCount = 1; //TODO: Only set to 1 if the printer does the copy internally (most printers do)
        data.orientation = printInfo.orientation() is OS.NSLandscapeOrientation ? PrinterData.LANDSCAPE : PrinterData.PORTRAIT;
        NSData nsData = NSKeyedArchiver.archivedDataWithRootObject(printInfo);
        data.otherData = new byte[nsData.length()];
        OS.memmove(&data.otherData, nsData.bytes(), data.otherData.length);
        printerData = data;
    }
    printInfo.release();
    return data;
}

/**
 * Returns the print job scope that the user selected
 * before pressing OK in the dialog. This will be one
 * of the following values:
 * <dl>
 * <dt><code>PrinterData.ALL_PAGES</code></dt>
 * <dd>Print all pages in the current document</dd>
 * <dt><code>PrinterData.PAGE_RANGE</code></dt>
 * <dd>Print the range of pages specified by startPage and endPage</dd>
 * <dt><code>PrinterData.SELECTION</code></dt>
 * <dd>Print the current selection</dd>
 * </dl>
 *
 * @return the scope setting that the user selected
 */
public int getScope() {
    return printerData.scope_;
}

static bool getSheetEnabled () {
    return !"false".equals(System.getProperty("dwt.sheet"));
}

static objc.id dialogProc(objc.id id, objc.SEL sel, objc.id arg0, objc.id arg1, objc.id arg2) {
    void* jniRef;
    OS.object_getInstanceVariable(id, DWT_OBJECT, jniRef);
    if (jniRef is null) return null;
    if (sel is OS.sel_panelDidEnd_returnCode_contextInfo_) {
        PrintDialog dialog = cast(PrintDialog)OS.JNIGetObject(jniRef);
        if (dialog is null) return null;
        dialog.panelDidEnd_returnCode_contextInfo(id, sel, arg0, arg1, arg2);
    }
    return null;
}

void initClasses () {
    String className = "SWTPrintPanelDelegate";
    if (OS.objc_lookUpClass (className) !is null) return;

    objc.IMP dialogProc5 = cast(objc.IMP)&dialogProc;
    if (dialogProc5 is null) DWT.error (DWT.ERROR_NO_MORE_CALLBACKS);

    char[] types = ['*','\0'];
    size_t size = C.PTR_SIZEOF, align_ = C.PTR_SIZEOF is 4 ? 2 : 3;
    objc.Class cls = OS.objc_allocateClassPair(OS.class_NSObject, className, 0);
    OS.class_addIvar(cls, DWT_OBJECT, size, cast(byte)align_, types);
    OS.class_addMethod(cls, OS.sel_panelDidEnd_returnCode_contextInfo_, dialogProc5, "@:@i@");
    OS.objc_registerClassPair(cls);
}

void panelDidEnd_returnCode_contextInfo(objc.id id, objc.SEL sel, objc.id alert, objc.id returnCode, objc.id contextInfo) {
    this.returnCode = cast(int)/*64*/returnCode;
    NSApplication application = NSApplication.sharedApplication();
    application.stop(null);
}

/**
 * Sets the scope of the print job. The user will see this
 * setting when the dialog is opened. This can have one of
 * the following values:
 * <dl>
 * <dt><code>PrinterData.ALL_PAGES</code></dt>
 * <dd>Print all pages in the current document</dd>
 * <dt><code>PrinterData.PAGE_RANGE</code></dt>
 * <dd>Print the range of pages specified by startPage and endPage</dd>
 * <dt><code>PrinterData.SELECTION</code></dt>
 * <dd>Print the current selection</dd>
 * </dl>
 *
 * @param scope the scope setting when the dialog is opened
 */
public void setScope(int scope_) {
    printerData.scope_ = scope_;
}

/**
 * Returns the start page setting that the user selected
 * before pressing OK in the dialog.
 * <p>
 * This value can be from 1 to the maximum number of pages for the platform.
 * Note that it is only valid if the scope is <code>PrinterData.PAGE_RANGE</code>.
 * </p>
 *
 * @return the start page setting that the user selected
 */
public int getStartPage() {
    return printerData.startPage;
}

/**
 * Sets the start page that the user will see when the dialog
 * is opened.
 * <p>
 * This value can be from 1 to the maximum number of pages for the platform.
 * Note that it is only valid if the scope is <code>PrinterData.PAGE_RANGE</code>.
 * </p>
 *
 * @param startPage the startPage setting when the dialog is opened
 */
public void setStartPage(int startPage) {
    printerData.startPage = startPage;
}

/**
 * Returns the end page setting that the user selected
 * before pressing OK in the dialog.
 * <p>
 * This value can be from 1 to the maximum number of pages for the platform.
 * Note that it is only valid if the scope is <code>PrinterData.PAGE_RANGE</code>.
 * </p>
 *
 * @return the end page setting that the user selected
 */
public int getEndPage() {
    return printerData.endPage;
}

/**
 * Sets the end page that the user will see when the dialog
 * is opened.
 * <p>
 * This value can be from 1 to the maximum number of pages for the platform.
 * Note that it is only valid if the scope is <code>PrinterData.PAGE_RANGE</code>.
 * </p>
 *
 * @param endPage the end page setting when the dialog is opened
 */
public void setEndPage(int endPage) {
    printerData.endPage = endPage;
}

/**
 * Returns the 'Print to file' setting that the user selected
 * before pressing OK in the dialog.
 *
 * @return the 'Print to file' setting that the user selected
 */
public bool getPrintToFile() {
    return printerData.printToFile;
}

/**
 * Sets the 'Print to file' setting that the user will see
 * when the dialog is opened.
 *
 * @param printToFile the 'Print to file' setting when the dialog is opened
 */
public void setPrintToFile(bool printToFile) {
    printerData.printToFile = printToFile;
}

protected void checkSubclass() {
    String name = this.classinfo.name;
    String validName = PrintDialog.classinfo.name;
    if (!validName.equals(name)) {
        DWT.error(DWT.ERROR_INVALID_SUBCLASS);
    }
}
}
