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
module dwt.widgets.MessageBox;

import dwt.dwthelper.utils;





import dwt.DWT;
import dwt.internal.cocoa.NSApplication;
import dwt.internal.cocoa.NSAlert;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSWindow;
import dwt.internal.cocoa.SWTPanelDelegate;
import dwt.internal.objc.cocoa.Cocoa;
import dwt.internal.cocoa.OS;
import dwt.widgets.Dialog;
import dwt.widgets.Display;
import dwt.widgets.Shell;

/**
 * Instances of this class are used to inform or warn the user.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>ICON_ERROR, ICON_INFORMATION, ICON_QUESTION, ICON_WARNING, ICON_WORKING</dd>
 * <dd>OK, OK | CANCEL</dd>
 * <dd>YES | NO, YES | NO | CANCEL</dd>
 * <dd>RETRY | CANCEL</dd>
 * <dd>ABORT | RETRY | IGNORE</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
 * </dl>
 * <p>
 * Note: Only one of the styles ICON_ERROR, ICON_INFORMATION, ICON_QUESTION,
 * ICON_WARNING and ICON_WORKING may be specified.
 * </p><p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the DWT implementation.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/examples.php">DWT Example: ControlExample, Dialog tab</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 * @noextend This class is not intended to be subclassed by clients.
 */
public  class MessageBox : Dialog {
    bool allowNullParent = false;
    String message = "";
    int returnCode;

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
    this (parent, DWT.OK | DWT.ICON_INFORMATION | DWT.APPLICATION_MODAL);
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
 * @see DWT#ICON_ERROR
 * @see DWT#ICON_INFORMATION
 * @see DWT#ICON_QUESTION
 * @see DWT#ICON_WARNING
 * @see DWT#ICON_WORKING
 * @see DWT#OK
 * @see DWT#CANCEL
 * @see DWT#YES
 * @see DWT#NO
 * @see DWT#ABORT
 * @see DWT#RETRY
 * @see DWT#IGNORE
 */
public this (Shell parent, int style) {
    super (parent, super.checkStyle (parent, checkStyle (style)));
    if (Display.getSheetEnabled ()) {
        if (parent !is null && (style & DWT.SHEET) !is 0) this.style |= DWT.SHEET;
    }
    checkSubclass ();
}
/++
 + DWT extension, a MessageBox with no parent
 +/
public this (int style) {
   allowNullParent = true;
   super (parent, super.checkStyle (parent, checkStyle (style)));
   checkSubclass ();
}
//PORT
//actually, the parent can be null
override void checkParent (Shell parent){
   if( !allowNullParent ){
       super.checkParent( parent );
   }
}

static int checkStyle (int style) {
    int mask = (DWT.YES | DWT.NO | DWT.OK | DWT.CANCEL | DWT.ABORT | DWT.RETRY | DWT.IGNORE);
    int bits = style & mask;
    if (bits is DWT.OK || bits is DWT.CANCEL || bits is (DWT.OK | DWT.CANCEL)) return style;
    if (bits is DWT.YES || bits is DWT.NO || bits is (DWT.YES | DWT.NO) || bits is (DWT.YES | DWT.NO | DWT.CANCEL)) return style;
    if (bits is (DWT.RETRY | DWT.CANCEL) || bits is (DWT.ABORT | DWT.RETRY | DWT.IGNORE)) return style;
    style = (style & ~mask) | DWT.OK;
    return style;
}

/**
 * Returns the dialog's message, or an empty string if it does not have one.
 * The message is a description of the purpose for which the dialog was opened.
 * This message will be visible in the dialog while it is open.
 *
 * @return the message
 */
public String getMessage () {
    return message;
}

/**
 * Makes the dialog visible and brings it to the front
 * of the display.
 *
 * @return the ID of the button that was selected to dismiss the
 *         message box (e.g. DWT.OK, DWT.CANCEL, etc.)
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the dialog has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the dialog</li>
 * </ul>
 */
public int open () {
    NSAlert alert = cast(NSAlert) (new NSAlert()).alloc().init();
    NSAlertStyle alertType = OS.NSInformationalAlertStyle;
    if ((style & DWT.ICON_ERROR) !is 0) alertType = OS.NSCriticalAlertStyle;
    if ((style & DWT.ICON_INFORMATION) !is 0) alertType = OS.NSInformationalAlertStyle;
    if ((style & DWT.ICON_QUESTION) !is 0) alertType = OS.NSInformationalAlertStyle;
    if ((style & DWT.ICON_WARNING) !is 0) alertType = OS.NSWarningAlertStyle;
    if ((style & DWT.ICON_WORKING) !is 0) alertType = OS.NSInformationalAlertStyle;
    alert.setAlertStyle(alertType);

    int mask = (DWT.YES | DWT.NO | DWT.OK | DWT.CANCEL | DWT.ABORT | DWT.RETRY | DWT.IGNORE);
    int bits = style & mask;
    NSString title;
    switch (bits) {
        case DWT.OK:
            title = NSString.stringWith(DWT.getMessage("DWT_OK"));
            alert.addButtonWithTitle(title);
            break;
        case DWT.CANCEL:
            title = NSString.stringWith(DWT.getMessage("DWT_Cancel"));
            alert.addButtonWithTitle(title);
            break;
        case DWT.OK | DWT.CANCEL:
            title = NSString.stringWith(DWT.getMessage("DWT_OK"));
            alert.addButtonWithTitle(title);
            title = NSString.stringWith(DWT.getMessage("DWT_Cancel"));
            alert.addButtonWithTitle(title);
            break;
        case DWT.YES:
            title = NSString.stringWith(DWT.getMessage("DWT_Yes"));
            alert.addButtonWithTitle(title);
            break;
        case DWT.NO:
            title = NSString.stringWith(DWT.getMessage("DWT_No"));
            alert.addButtonWithTitle(title);
            break;
        case DWT.YES | DWT.NO:
            title = NSString.stringWith(DWT.getMessage("DWT_Yes"));
            alert.addButtonWithTitle(title);
            title = NSString.stringWith(DWT.getMessage("DWT_No"));
            alert.addButtonWithTitle(title);
//          no.setKeyEquivalent(NSString.stringWith("\033"));
            break;
        case DWT.YES | DWT.NO | DWT.CANCEL:
            title = NSString.stringWith(DWT.getMessage("DWT_Yes"));
            alert.addButtonWithTitle(title);
            title = NSString.stringWith(DWT.getMessage("DWT_Cancel"));
            alert.addButtonWithTitle(title);
            title = NSString.stringWith(DWT.getMessage("DWT_No"));
            alert.addButtonWithTitle(title);
            break;
        case DWT.RETRY | DWT.CANCEL:
            title = NSString.stringWith(DWT.getMessage("DWT_Retry"));
            alert.addButtonWithTitle(title);
            title = NSString.stringWith(DWT.getMessage("DWT_Cancel"));
            alert.addButtonWithTitle(title);
            break;
        case DWT.ABORT | DWT.RETRY | DWT.IGNORE:
            title = NSString.stringWith(DWT.getMessage("DWT_Abort"));
            alert.addButtonWithTitle(title);
            title = NSString.stringWith(DWT.getMessage("DWT_Ignore"));
            alert.addButtonWithTitle(title);
            title = NSString.stringWith(DWT.getMessage("DWT_Retry"));
            alert.addButtonWithTitle(title);
            break;
        default:
    }
    title = NSString.stringWith(this.title !is null ? this.title : "");
    alert.window().setTitle(title);
    NSString message = NSString.stringWith(this.message !is null ? this.message : "");
    alert.setMessageText(message);
    NSInteger response = 0;
    void* jniRef = null;
    SWTPanelDelegate delegate_ = null;
    if ((style & DWT.SHEET) !is 0) {
        delegate_ = cast(SWTPanelDelegate)(new SWTPanelDelegate()).alloc().init();
        jniRef = OS.NewGlobalRef(this);
        if (jniRef is null) DWT.error(DWT.ERROR_NO_HANDLES);
        OS.object_setInstanceVariable(delegate_.id, Display.SWT_OBJECT, jniRef);
        alert.beginSheetModalForWindow(parent.window, delegate_, OS.sel_panelDidEnd_returnCode_contextInfo_, null);
        if ((style & DWT.APPLICATION_MODAL) !is 0) {
            response = alert.runModal();
        } else {
            this.returnCode = 0;
            NSWindow window = alert.window();
            NSApplication application = NSApplication.sharedApplication();
            while (window.isVisible()) application.run();
            response = this.returnCode;
        }
    } else {
        response = alert.runModal();
    }
    if (delegate_ !is null) delegate_.release();
    if (jniRef !is null) OS.DeleteGlobalRef(jniRef);
    alert.release();
    switch (bits) {
        case DWT.OK:
            switch (response) {
                case OS.NSAlertFirstButtonReturn:
                    return DWT.OK;
                default:
            }
            break;
        case DWT.CANCEL:
            switch (response) {
                case OS.NSAlertFirstButtonReturn:
                    return DWT.CANCEL;
                default:
            }
            break;
        case DWT.OK | DWT.CANCEL:
            switch (response) {
                case OS.NSAlertFirstButtonReturn:
                    return DWT.OK;
                case OS.NSAlertSecondButtonReturn:
                    return DWT.CANCEL;
                default:
            }
            break;
        case DWT.YES:
            switch (response) {
                case OS.NSAlertFirstButtonReturn:
                    return DWT.YES;
                default:
            }
            break;
        case DWT.NO:
            switch (response) {
                case OS.NSAlertFirstButtonReturn:
                    return DWT.NO;
                default:
            }
            break;
        case DWT.YES | DWT.NO:
            switch (response) {
                case OS.NSAlertFirstButtonReturn:
                    return DWT.YES;
                case OS.NSAlertSecondButtonReturn:
                    return DWT.NO;
                default:
            }
            break;
        case DWT.YES | DWT.NO | DWT.CANCEL:
            switch (response) {
                case OS.NSAlertFirstButtonReturn:
                    return DWT.YES;
                case OS.NSAlertSecondButtonReturn:
                    return DWT.CANCEL;
                case OS.NSAlertThirdButtonReturn:
                    return DWT.NO;
                default:
            }
            break;
        case DWT.RETRY | DWT.CANCEL:
            switch (response) {
                case OS.NSAlertFirstButtonReturn:
                    return DWT.RETRY;
                case OS.NSAlertSecondButtonReturn:
                    return DWT.CANCEL;
                default:
            }
            break;
        case DWT.ABORT | DWT.RETRY | DWT.IGNORE:
            switch (response) {
                case OS.NSAlertFirstButtonReturn:
                    return DWT.ABORT;
                case OS.NSAlertSecondButtonReturn:
                    return DWT.IGNORE;
                case OS.NSAlertThirdButtonReturn:
                    return DWT.RETRY;
                default:
            }
            break;
        default:
    }
    return DWT.CANCEL;
}

void panelDidEnd_returnCode_contextInfo(objc.id id, objc.SEL sel, objc.id alert, objc.id returnCode, objc.id contextInfo) {
    this.returnCode = cast(NSInteger)returnCode;
    NSApplication application = NSApplication.sharedApplication();
    application.endSheet((new NSAlert(alert)).window(), cast(NSInteger)returnCode);
    if ((style & DWT.PRIMARY_MODAL) !is 0) {
        application.stop(null);
    }
}

/**
 * Sets the dialog's message, which is a description of
 * the purpose for which it was opened. This message will be
 * visible on the dialog while it is open.
 *
 * @param string the message
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the string is null</li>
 * </ul>
 */
public void setMessage (String string) {
    // DWT extension: allow null for zero length string
    //if (string is null) error (DWT.ERROR_NULL_ARGUMENT);
    message = string;
}

/++
 + DWT extension
 +/
public static int showMessageBox(String str, String title, Shell shell, int style) {
   MessageBox msgBox = (shell is null ) ? new MessageBox( style ) : new MessageBox(shell, style);
   msgBox.setMessage(str);
   if(title !is null){
       msgBox.setText(title);
   }
   return msgBox.open();
}

/// DWT extension
public static int showInfo(String str, String title = null, Shell shell = null) {
   return showMessageBox( str, title, shell, DWT.OK | DWT.ICON_INFORMATION );
}

/// DWT extension
alias showInfo showInformation;

/// DWT extension
public static int showWarning(String str, String title = null, Shell shell = null) {
   return showMessageBox( str, title, shell, DWT.OK | DWT.ICON_WARNING );
}

/// DWT extension
public static int showError(String str, String title = null, Shell shell = null) {
   return showMessageBox( str, title, shell, DWT.OK | DWT.ICON_ERROR );
}

}
