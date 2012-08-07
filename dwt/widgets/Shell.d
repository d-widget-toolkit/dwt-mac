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
module dwt.widgets.Shell;

import dwt.DWT;
import dwt.events.*;
import dwt.graphics.*;
import dwt.internal.cocoa.*;

import dwt.dwthelper.utils;
import Carbon = dwt.internal.c.Carbon;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;
import dwt.widgets.Composite;
import dwt.widgets.Control;
import dwt.widgets.Decorations;
import dwt.widgets.Display;
import dwt.widgets.Event;
import dwt.widgets.EventTable;
import dwt.widgets.Layout;
import dwt.widgets.Listener;
import dwt.widgets.Menu;
import dwt.widgets.Monitor;
import dwt.widgets.TypedListener;
import dwt.widgets.Widget;

/**
 * Instances of this class represent the "windows"
 * which the desktop or "window manager" is managing.
 * Instances that do not have a parent (that is, they
 * are built using the constructor, which takes a 
 * <code>Display</code> as the argument) are described
 * as <em>top level</em> shells. Instances that do have
 * a parent are described as <em>secondary</em> or
 * <em>dialog</em> shells.
 * <p>
 * Instances are always displayed in one of the maximized, 
 * minimized or normal states:
 * <ul>
 * <li>
 * When an instance is marked as <em>maximized</em>, the
 * window manager will typically resize it to fill the
 * entire visible area of the display, and the instance
 * is usually put in a state where it can not be resized 
 * (even if it has style <code>RESIZE</code>) until it is
 * no longer maximized.
 * </li><li>
 * When an instance is in the <em>normal</em> state (neither
 * maximized or minimized), its appearance is controlled by
 * the style constants which were specified when it was created
 * and the restrictions of the window manager (see below).
 * </li><li>
 * When an instance has been marked as <em>minimized</em>,
 * its contents (client area) will usually not be visible,
 * and depending on the window manager, it may be
 * "iconified" (that is, replaced on the desktop by a small
 * simplified representation of itself), relocated to a
 * distinguished area of the screen, or hidden. Combinations
 * of these changes are also possible.
 * </li>
 * </ul>
 * </p><p>
 * The <em>modality</em> of an instance may be specified using
 * style bits. The modality style bits are used to determine
 * whether input is blocked for other shells on the display.
 * The <code>PRIMARY_MODAL</code> style allows an instance to block
 * input to its parent. The <code>APPLICATION_MODAL</code> style
 * allows an instance to block input to every other shell in the
 * display. The <code>SYSTEM_MODAL</code> style allows an instance
 * to block input to all shells, including shells belonging to
 * different applications.
 * </p><p>
 * Note: The styles supported by this class are treated
 * as <em>HINT</em>s, since the window manager for the
 * desktop on which the instance is visible has ultimate
 * control over the appearance and behavior of decorations
 * and modality. For example, some window managers only
 * support resizable windows and will always assume the
 * RESIZE style, even if it is not set. In addition, if a
 * modality style is not supported, it is "upgraded" to a
 * more restrictive modality style that is supported. For
 * example, if <code>PRIMARY_MODAL</code> is not supported,
 * it would be upgraded to <code>APPLICATION_MODAL</code>.
 * A modality style may also be "downgraded" to a less
 * restrictive style. For example, most operating systems
 * no longer support <code>SYSTEM_MODAL</code> because
 * it can freeze up the desktop, so this is typically
 * downgraded to <code>APPLICATION_MODAL</code>.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>BORDER, CLOSE, MIN, MAX, NO_TRIM, RESIZE, TITLE, ON_TOP, TOOL, SHEET</dd>
 * <dd>APPLICATION_MODAL, MODELESS, PRIMARY_MODAL, SYSTEM_MODAL</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Activate, Close, Deactivate, Deiconify, Iconify</dd>
 * </dl>
 * Class <code>DWT</code> provides two "convenience constants"
 * for the most commonly required style combinations:
 * <dl>
 * <dt><code>SHELL_TRIM</code></dt>
 * <dd>
 * the result of combining the constants which are required
 * to produce a typical application top level shell: (that 
 * is, <code>CLOSE | TITLE | MIN | MAX | RESIZE</code>)
 * </dd>
 * <dt><code>DIALOG_TRIM</code></dt>
 * <dd>
 * the result of combining the constants which are required
 * to produce a typical application dialog shell: (that 
 * is, <code>TITLE | CLOSE | BORDER</code>)
 * </dd>
 * </dl>
 * </p>
 * <p>
 * Note: Only one of the styles APPLICATION_MODAL, MODELESS, 
 * PRIMARY_MODAL and SYSTEM_MODAL may be specified.
 * </p><p>
 * IMPORTANT: This class is not intended to be subclassed.
 * </p>
 *
 * @see Decorations
 * @see DWT
 * @see <a href="http://www.eclipse.org/swt/snippets/#shell">Shell snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">DWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class Shell : Decorations {

    alias Decorations.createHandle createHandle;
    alias Decorations.setBounds setBounds;
    alias Decorations.setCursor setCursor;
    alias Decorations.setToolTipText setToolTipText;
    alias Decorations.setZOrder setZOrder;

    NSWindow window;
    SWTWindowDelegate windowDelegate;
    int /*long*/ tooltipOwner, tooltipTag, tooltipUserData;
    bool opened, moved, resized, fullScreen, center;
    Control lastActive;
    Rectangle normalBounds;
    bool keyInputHappened;
    NSRect currentFrame;
    NSRect fullScreenFrame;
    
    static int DEFAULT_CLIENT_WIDTH = -1;
    static int DEFAULT_CLIENT_HEIGHT = -1;

/**
 * Constructs a new instance of this class. This is equivalent
 * to calling <code>Shell(cast(Display) null)</code>.
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 */
public this () {
    this (cast(Display) null);
}

/**
 * Constructs a new instance of this class given only the style
 * value describing its behavior and appearance. This is equivalent
 * to calling <code>Shell(cast(Display) null, style)</code>.
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
 * @param style the style of control to construct
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 * 
 * @see DWT#BORDER
 * @see DWT#CLOSE
 * @see DWT#MIN
 * @see DWT#MAX
 * @see DWT#RESIZE
 * @see DWT#TITLE
 * @see DWT#TOOL
 * @see DWT#NO_TRIM
 * @see DWT#SHELL_TRIM
 * @see DWT#DIALOG_TRIM
 * @see DWT#ON_TOP
 * @see DWT#MODELESS
 * @see DWT#PRIMARY_MODAL
 * @see DWT#APPLICATION_MODAL
 * @see DWT#SYSTEM_MODAL
 * @see DWT#SHEET
 */
public this (int style) {
    this (cast(Display) null, style);
}

/**
 * Constructs a new instance of this class given only the display
 * to create it on. It is created with style <code>DWT.SHELL_TRIM</code>.
 * <p>
 * Note: Currently, null can be passed in for the display argument.
 * This has the effect of creating the shell on the currently active
 * display if there is one. If there is no current display, the 
 * shell is created on a "default" display. <b>Passing in null as
 * the display argument is not considered to be good coding style,
 * and may not be supported in a future release of DWT.</b>
 * </p>
 *
 * @param display the display to create the shell on
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 */
public this (Display display) {
    this (display, DWT.SHELL_TRIM);
}

/**
 * Constructs a new instance of this class given the display
 * to create it on and a style value describing its behavior
 * and appearance.
 * <p>
 * The style value is either one of the style constants defined in
 * class <code>DWT</code> which is applicable to instances of this
 * class, or must be built by <em>bitwise OR</em>'ing together 
 * (that is, using the <code>int</code> "|" operator) two or more
 * of those <code>DWT</code> style constants. The class description
 * lists the style constants that are applicable to the class.
 * Style bits are also inherited from superclasses.
 * </p><p>
 * Note: Currently, null can be passed in for the display argument.
 * This has the effect of creating the shell on the currently active
 * display if there is one. If there is no current display, the 
 * shell is created on a "default" display. <b>Passing in null as
 * the display argument is not considered to be good coding style,
 * and may not be supported in a future release of DWT.</b>
 * </p>
 *
 * @param display the display to create the shell on
 * @param style the style of control to construct
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 * 
 * @see DWT#BORDER
 * @see DWT#CLOSE
 * @see DWT#MIN
 * @see DWT#MAX
 * @see DWT#RESIZE
 * @see DWT#TITLE
 * @see DWT#TOOL
 * @see DWT#NO_TRIM
 * @see DWT#SHELL_TRIM
 * @see DWT#DIALOG_TRIM
 * @see DWT#ON_TOP
 * @see DWT#MODELESS
 * @see DWT#PRIMARY_MODAL
 * @see DWT#APPLICATION_MODAL
 * @see DWT#SYSTEM_MODAL
 * @see DWT#SHEET
 */
public this (Display display, int style) {
    this (display, null, style, null, false);
}

this (Display display, Shell parent, int style, objc.id handle, bool embedded) {
    super ();
    checkSubclass ();
    if (display is null) display = Display.getCurrent ();
    if (display is null) display = Display.getDefault ();
    if (!display.isValidThread ()) {
        error (DWT.ERROR_THREAD_INVALID_ACCESS);
    }
    if (parent !is null && parent.isDisposed ()) {
        error (DWT.ERROR_INVALID_ARGUMENT); 
    }
    if (!Display.getSheetEnabled ()) {
        this.center = parent !is null && (style & DWT.SHEET) !is 0;
    }
    this.style = checkStyle (parent, style);
    this.parent = parent;
    this.display = display;
    if (handle !is null) {
        if (embedded) {
            view = new NSView(handle);
        } else {
            window = new NSWindow(handle);
            state |= FOREIGN_HANDLE;
        }
    }
    createWidget ();
}

/**
 * Constructs a new instance of this class given only its
 * parent. It is created with style <code>DWT.DIALOG_TRIM</code>.
 * <p>
 * Note: Currently, null can be passed in for the parent.
 * This has the effect of creating the shell on the currently active
 * display if there is one. If there is no current display, the 
 * shell is created on a "default" display. <b>Passing in null as
 * the parent is not considered to be good coding style,
 * and may not be supported in a future release of DWT.</b>
 * </p>
 *
 * @param parent a shell which will be the parent of the new instance
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the parent is disposed</li> 
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 */
public this (Shell parent) {
    this (parent, DWT.DIALOG_TRIM);
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
 * </p><p>
 * Note: Currently, null can be passed in for the parent.
 * This has the effect of creating the shell on the currently active
 * display if there is one. If there is no current display, the 
 * shell is created on a "default" display. <b>Passing in null as
 * the parent is not considered to be good coding style,
 * and may not be supported in a future release of DWT.</b>
 * </p>
 *
 * @param parent a shell which will be the parent of the new instance
 * @param style the style of control to construct
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the parent is disposed</li> 
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 * 
 * @see DWT#BORDER
 * @see DWT#CLOSE
 * @see DWT#MIN
 * @see DWT#MAX
 * @see DWT#RESIZE
 * @see DWT#TITLE
 * @see DWT#NO_TRIM
 * @see DWT#SHELL_TRIM
 * @see DWT#DIALOG_TRIM
 * @see DWT#ON_TOP
 * @see DWT#TOOL
 * @see DWT#MODELESS
 * @see DWT#PRIMARY_MODAL
 * @see DWT#APPLICATION_MODAL
 * @see DWT#SYSTEM_MODAL
 * @see DWT#SHEET
 */
public this (Shell parent, int style) {
    this (parent !is null ? parent.display : null, parent, style, null, false);
}

/**  
 * Invokes platform specific functionality to allocate a new shell
 * that is not embedded.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>Shell</code>. It is marked public only so that it
 * can be shared within the packages provided by DWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param display the display for the shell
 * @param handle the handle for the shell
 * @return a new shell object containing the specified display and handle
 * 
 * @since 3.3
 */
public static Shell internal_new (Display display, objc.id handle) {
    return new Shell (display, null, DWT.NO_TRIM, handle, false);
}

/**  
 * Invokes platform specific functionality to allocate a new shell
 * that is 'embedded'.  In this case, the handle represents an NSView
 * that acts as an embedded DWT Shell in an AWT Canvas.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>Shell</code>. It is marked public only so that it
 * can be shared within the packages provided by DWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param display the display for the shell
 * @param handle the handle for the shell
 * @return a new shell object containing the specified display and handle
 * 
 * @since 3.5
 */
public static Shell cocoa_new (Display display, objc.id handle) {
    return new Shell (display, null, DWT.NO_TRIM, handle, true);
}

static int checkStyle (Shell parent, int style) {
    style = Decorations.checkStyle (style);
    style &= ~DWT.TRANSPARENT;
    int mask = DWT.SYSTEM_MODAL | DWT.APPLICATION_MODAL | DWT.PRIMARY_MODAL;
    if ((style & DWT.SHEET) !is 0) {
        if (Display.getSheetEnabled ()) {
            style &= ~(DWT.CLOSE | DWT.TITLE | DWT.MIN | DWT.MAX);
            if (parent is null) {
                style &= ~DWT.SHEET;
                style |= DWT.SHELL_TRIM;
            }
        } else {
            style &= ~DWT.SHEET;
            style |= parent is null ? DWT.SHELL_TRIM : DWT.DIALOG_TRIM;
        }
        if ((style & mask) is 0) {
            style |= parent is null ? DWT.APPLICATION_MODAL : DWT.PRIMARY_MODAL;
        }
    }
    int bits = style & ~mask;
    if ((style & DWT.SYSTEM_MODAL) !is 0) return bits | DWT.SYSTEM_MODAL;
    if ((style & DWT.APPLICATION_MODAL) !is 0) return bits | DWT.APPLICATION_MODAL;
    if ((style & DWT.PRIMARY_MODAL) !is 0) return bits | DWT.PRIMARY_MODAL;
    return bits;
}

bool accessibilityIsIgnored(objc.id id, objc.SEL sel) {
    // The content view of a shell is always ignored.
    if (id is view.id) return true;
    return super.accessibilityIsIgnored(id, sel);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when operations are performed on the receiver,
 * by sending the listener one of the messages defined in the
 * <code>ShellListener</code> interface.
 *
 * @param listener the listener which should be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see ShellListener
 * @see #removeShellListener
 */
public void addShellListener(ShellListener listener) {
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener(DWT.Activate,typedListener);
    addListener(DWT.Close,typedListener);
    addListener(DWT.Deactivate,typedListener);
    addListener(DWT.Iconify,typedListener);
    addListener(DWT.Deiconify,typedListener);
}

void becomeKeyWindow (int /*long*/ id, int /*long*/ sel) {
    Display display = this.display;
    display.keyWindow = window;
    super.becomeKeyWindow(id, sel);
    display.checkFocus();
    display.keyWindow = null;
}

void bringToTop (bool force) {
    if (getMinimized ()) return;
    if (force) {
        forceActive ();
    } else {
        setActive ();
    }
}

bool canBecomeKeyWindow (objc.id id, objc.SEL sel) {
    if (window.styleMask () is OS.NSBorderlessWindowMask) return true;
    return super.canBecomeKeyWindow (id, sel);
}

void checkOpen () {
    if (!opened) resized = false;
}

void center () {
    if (parent is null) return;
    Rectangle rect = getBounds ();
    Rectangle parentRect = display.map (parent, null, parent.getClientArea());
    int x = Math.max (parentRect.x, parentRect.x + (parentRect.width - rect.width) / 2);
    int y = Math.max (parentRect.y, parentRect.y + (parentRect.height - rect.height) / 2);
    Rectangle monitorRect = parent.getMonitor ().getClientArea();
    if (x + rect.width > monitorRect.x + monitorRect.width) {
        x = Math.max (monitorRect.x, monitorRect.x + monitorRect.width - rect.width);
    } else {
        x = Math.max (x, monitorRect.x);
    }
    if (y + rect.height > monitorRect.y + monitorRect.height) {
        y = Math.max (monitorRect.y, monitorRect.y + monitorRect.height - rect.height);
    } else {
        y = Math.max (y, monitorRect.y);
    }
    setLocation (x, y);
}

/**
 * Requests that the window manager close the receiver in
 * the same way it would be closed when the user clicks on
 * the "close box" or performs some other platform specific
 * key or mouse combination that indicates the window
 * should be removed.
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see DWT#Close
 * @see #dispose
 */
public void close () {
    checkWidget();
    closeWidget ();
}

void closeWidget () {
    Event event = new Event ();
    sendEvent (DWT.Close, event);
    if (event.doit && !isDisposed ()) dispose ();
}

public Rectangle computeTrim (int x, int y, int width, int height) {
    checkWidget();
    Rectangle trim = super.computeTrim(x, y, width, height);
    NSRect rect = NSRect ();
    rect.x = trim.x;
    rect.y = trim.y;
    rect.width = trim.width;
    rect.height = trim.height;
    if (window !is null) {
        if (!fixResize()) {
            rect = window.frameRectForContentRect(rect);
        }
    }
}

void createHandle () {
    state |= HIDDEN;
    if (window is null) {
        window = cast(NSWindow) (new SWTWindow ()).alloc ();
        NSUInteger styleMask = NSBorderlessWindowMask;
        if ((style & DWT.NO_TRIM) is 0) {
            if ((style & DWT.TITLE) !is 0) styleMask |= OS.NSTitledWindowMask;
            if ((style & DWT.CLOSE) !is 0) styleMask |= NSClosableWindowMask;
            if ((style & DWT.MIN) !is 0) styleMask |= NSMiniaturizableWindowMask;
            if ((style & DWT.MAX) !is 0) styleMask |= NSResizableWindowMask;
            if ((style & DWT.RESIZE) !is 0) styleMask |= NSResizableWindowMask;
        }
        NSScreen screen = null;
        NSScreen primaryScreen = new NSScreen(NSScreen.screens().objectAtIndex(0));
        if (parent !is null) screen = parent.getShell().window.screen();
        if (screen is null) screen = primaryScreen;
        window = window.initWithContentRect(NSRect(), styleMask, OS.NSBackingStoreBuffered, false, screen);
        if ((style & (DWT.NO_TRIM | DWT.BORDER | DWT.SHELL_TRIM)) is 0 || (style & (DWT.TOOL | DWT.SHEET)) !is 0) {
            window.setHasShadow (true);
        }
        if ((style & DWT.NO_TRIM) is 0) {
            NSSize size = window.minSize();
            size.width = NSWindow.minFrameWidthWithTitle(NSString.stringWith(""), styleMask);
            window.setMinSize(size);
        }
        if (fixResize ()) {
            if (window.respondsToSelector(OS.sel_setMovable_)) {
                OS.objc_msgSend(window.id, OS.sel_setMovable_, 0);
            }
        }
        display.cascadeWindow(window, screen);
        NSRect screenFrame = screen.frame();
        Carbon.CGFloat width = screenFrame.width * 5 / 8, height = screenFrame.height * 5 / 8;;
        NSRect frame = window.frame();
        NSRect primaryFrame = primaryScreen.frame();
        frame.y = primaryFrame.height - ((primaryFrame.height - (frame.y + frame.height)) + height);
        frame.width = width;
        frame.height = height;
        window.setFrame(frame, false);
        if ((style & DWT.ON_TOP) !is 0) {
            window.setLevel(OS.NSStatusWindowLevel);
        }
        super.createHandle ();
        topView ().setHidden (true);
    } else {
//      int /*long*/ cls = OS.objc_lookUpClass ("SWTWindow");
//      OS.object_setClass(window.id, cls);
        state &= ~HIDDEN;
        //TODO - get the content of the foreign window instead of creating it
        super.createHandle ();
        style |= DWT.NO_BACKGROUND;
    }
    window.setAcceptsMouseMovedEvents(true);
    windowDelegate = cast(SWTWindowDelegate)(new SWTWindowDelegate()).alloc().init();
    window.setDelegate(windowDelegate);
    id id = window.fieldEditor (true, null);
    if (id !is null) {
        OS.object_setClass (id.id, cast(objc.Class) OS.objc_getClass ("SWTEditorView"));
    }
}

void deregister () {
    super.deregister ();
    if (window !is null) display.removeWidget (window);
    if (windowDelegate !is null) display.removeWidget (windowDelegate);
}

void destroyWidget () {
    NSWindow window = this.window;
    Display display = this.display;
    bool sheet = (style & (DWT.SHEET)) !is 0;
    releaseHandle ();
    if (window !is null) {
        if (sheet) {
            NSApplication application = NSApplication.sharedApplication();
            application.endSheet(window, 0);
        }
        window.close();
    }
    //If another shell is not going to become active, clear the menu bar.
    if (!display.isDisposed () && display.getShells ().length is 0) {
        display.setMenuBar (null);
    }
}

void drawBackground (int /*long*/ id, NSGraphicsContext context, NSRect rect) {
    if (id !is view.id) return;
    if (regionPath !is null && background is null) {
        context.saveGraphicsState();
        NSColor.windowBackgroundColor().setFill();
        NSBezierPath.fillRect(rect);
        context.restoreGraphicsState();
        return;
    }
    super.drawBackground (id, context, rect);
}

Control findBackgroundControl () {
    return background !is null || backgroundImage !is null ? this : null;
}

Composite findDeferredControl () {
    return layoutCount > 0 ? this : null;
}

Cursor findCursor () {
    return cursor;
}

bool fixResize () {
    /*
    * Feature in Cocoa.  It is not possible to have a resizable window
    * without the title bar.  The fix is to resize the content view on
    * top of the title bar.
    */
    if ((style & DWT.NO_TRIM) is 0) {
        if ((style & DWT.RESIZE) !is 0 && (style & (DWT.TITLE | DWT.CLOSE | DWT.MIN | DWT.MAX)) is 0) {
            return true;
        }
    }
    return false;
}

void fixShell (Shell newShell, Control control) {
    if (this is newShell) return;
    if (control is lastActive) setActiveControl (null);
}

/**
 * If the receiver is visible, moves it to the top of the 
 * drawing order for the display on which it was created 
 * (so that all other shells on that display, which are not 
 * the receiver's children will be drawn behind it) and forces 
 * the window manager to make the shell active.
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.0
 * @see Control#moveAbove
 * @see Control#setFocus
 * @see Control#setVisible
 * @see Display#getActiveShell
 * @see Decorations#setDefaultButton(Button)
 * @see Shell#open
 * @see Shell#setActive
 */
public void forceActive () {
    checkWidget ();
    if (!isVisible()) return;
    if (window is null) return;
    makeKeyAndOrderFront ();
    NSApplication application = NSApplication.sharedApplication ();
    application.activateIgnoringOtherApps (true);
}

/**
 * Returns the receiver's alpha value. The alpha value
 * is between 0 (transparent) and 255 (opaque).
 *
 * @return the alpha value
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * 
 * @since 3.4
 */
public int getAlpha () {
    checkWidget ();
    // TODO: Should we support embedded frame alpha?
    if (window is null) return 255;
}

public Rectangle getBounds () {
    checkWidget();
    NSRect frame = (window is null ? view.frame() : window.frame());
    Carbon.CGFloat y = display.getPrimaryFrame().height - cast(int)(frame.y + frame.height);
    return new Rectangle (cast(int)frame.x, cast(int)y, cast(int)frame.width, cast(int)frame.height);
}

public Rectangle getClientArea () {
    checkWidget();
    NSRect rect;
    if (window !is null) {
        rect = window.frame();
        if (!fixResize ()) {
            rect = window.contentRectForFrameRect(rect);
    } else {
        rect = scrollView !is null ? scrollView.frame() : view.frame();
        }
    } else {
        rect = scrollView !is null ? scrollView.frame() : view.frame();
    }
    int width = cast(int)rect.width, height = cast(int)rect.height;
    if (scrollView !is null) {
        NSSize size = NSSize();
        size.width = width;
        size.height = height;
        size = NSScrollView.contentSizeForFrameSize(size, (style & DWT.H_SCROLL) !is 0, (style & DWT.V_SCROLL) !is 0, OS.NSNoBorder);
        width = cast(int)size.width;
        height = cast(int)size.height;
    }
    return new Rectangle (0, 0, width, height);
}

/**
 * Returns <code>true</code> if the receiver is currently
 * in fullscreen state, and false otherwise. 
 * <p>
 *
 * @return the fullscreen state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public bool getFullScreen () {
    checkWidget();
    return fullScreen;
}

/**
 * Returns the receiver's input method editor mode. This
 * will be the result of bitwise OR'ing together one or
 * more of the following constants defined in class
 * <code>DWT</code>:
 * <code>NONE</code>, <code>ROMAN</code>, <code>DBCS</code>, 
 * <code>PHONETIC</code>, <code>NATIVE</code>, <code>ALPHA</code>.
 *
 * @return the IME mode
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see DWT
 */
public int getImeInputMode () {
    checkWidget();
    return DWT.NONE;
}

public Point getLocation () {
    checkWidget();
    // TODO: frame is relative to superview. What does getLocation mean in the embedded case?
    NSRect frame = (window !is null ? window.frame() : view.frame());
    Carbon.CGFloat y = display.getPrimaryFrame().height - cast(int)(frame.y + frame.height);
    return new Point (cast(int)frame.x, cast(int)y);
}

public bool getMaximized () {
    checkWidget();
    if (window is null) return false;
    return !fullScreen && window.isZoomed();
}

Shell getModalShell () {
    Shell shell = null;
    Shell [] modalShells = display.modalShells;
    if (modalShells !is null) {
        int bits = DWT.APPLICATION_MODAL | DWT.SYSTEM_MODAL;
        int index = modalShells.length;
        while (--index >= 0) {
            Shell modal = modalShells [index];
            if (modal !is null) {
                if ((modal.style & bits) !is 0) {
                    Control control = this;
                    while (control !is null) {
                        if (control is modal) break;
                        control = control.parent;
                    }
                    if (control !is modal) return modal;
                    break;
                }
                if ((modal.style & DWT.PRIMARY_MODAL) !is 0) {
                    if (shell is null) shell = getShell ();
                    if (modal.parent is shell) return modal;
                }
            }
        }
    }
    return null;
}

/**
 * Gets the receiver's modified state.
 *
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * 
 * @since 3.5
 */
public bool getModified () {
    checkWidget ();
    return window.isDocumentEdited ();
}

public bool getMinimized () {
    checkWidget();
    if (!getVisible ()) return super.getMinimized ();
    if (window is null) return false;
    return window.isMiniaturized();
}

/**
 * Returns a point describing the minimum receiver's size. The
 * x coordinate of the result is the minimum width of the receiver.
 * The y coordinate of the result is the minimum height of the
 * receiver.
 *
 * @return the receiver's size
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * 
 * @since 3.1
 */
public Point getMinimumSize () {
    checkWidget();
    if (window is null) return new Point(0, 0);
    NSSize size = window.minSize();
    return new Point((int)size.width, (int)size.height);
}

/** 
 * Returns the region that defines the shape of the shell,
 * or null if the shell has the default shape.
 *
 * @return the region that defines the shape of the shell (or null)
 *  
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 *
 */
public Region getRegion () {
    /* This method is needed for the @since 3.0 Javadoc */
    checkWidget ();
    return region;
}

public Shell getShell () {
    checkWidget();
    return this;
}

/**
 * Returns an array containing all shells which are 
 * descendants of the receiver.
 * <p>
 * @return the dialog shells
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Shell [] getShells () {
    checkWidget();
    int count = 0;
    Shell [] shells = display.getShells ();
    for (int i=0; i<shells.length; i++) {
        Control shell = shells [i];
        do {
            shell = shell.parent;
        } while (shell !is null && shell !is this);
        if (shell is this) count++;
    }
    int index = 0;
    Shell [] result = new Shell [count];
    for (int i=0; i<shells.length; i++) {
        Control shell = shells [i];
        do {
            shell = shell.parent;
        } while (shell !is null && shell !is this);
        if (shell is this) {
            result [index++] = shells [i];
        }
    }
    return result;
}

public Point getSize () {
    checkWidget();
    NSRect frame = (window !is null ? window.frame() : view.frame());
    return new Point (cast(int) frame.width, cast(int) frame.height);
}

float getThemeAlpha () {
    return 1;
}

bool hasBorder () {
    return false;
}

void helpRequested(objc.id id, objc.SEL sel, objc.id theEvent) {
    Control control = display.getFocusControl();
    while (control !is null) {
        if (control.hooks (DWT.Help)) {
            control.postEvent (DWT.Help);
            break;
        }
        control = control.parent;
    }
}

void invalidateVisibleRegion () {
    resetVisibleRegion ();
    invalidateChildrenVisibleRegion ();
}

bool isDrawing () {
    return getDrawing ();
}

public bool isEnabled () {
    checkWidget();
    return getEnabled ();
}

bool isEnabledCursor () {
    return true;
}

public bool isVisible () {
    checkWidget();
    return getVisible ();
}

bool makeFirstResponder (objc.id id, objc.SEL sel, objc.id responder) {
    Display display = this.display;
    bool result = super.makeFirstResponder(id, sel, responder);
    display.checkFocus();
    return result;
}

void makeKeyAndOrderFront() {
    /*
    * Bug in Cocoa.  If a child window becomes the key window when its
    * parent window is miniaturized, the parent window appears as if
    * restored to its full size without actually being restored. In this
    * case the parent window does become active when its child is closed
    * and the user is forced to restore the window from the dock.
    * The fix is to be sure that the parent window is deminiaturized before
    * making the child a key window. 
    */
    if (parent !is null) {
        Shell shell = (Shell) parent;
        if (shell.window.isMiniaturized()) shell.window.deminiaturize(null);
    }
    window.makeKeyAndOrderFront (null);
void makeKeyAndOrderFront() {
    /*
    * Bug in Cocoa.  If a child window becomes the key window when its
    * parent window is miniaturized, the parent window appears as if
    * restored to its full size without actually being restored. In this
    * case the parent window does become active when its child is closed
    * and the user is forced to restore the window from the dock.
    * The fix is to be sure that the parent window is deminiaturized before
    * making the child a key window. 
    */
    if (parent !is null) {
        Shell shell = (Shell) parent;
        if (shell.window.isMiniaturized()) shell.window.deminiaturize(null);
}

void noResponderFor(int /*long*/ id, int /*long*/ sel, int /*long*/ selector) {
    /**
     * Feature in Cocoa.  If the selector is keyDown and nothing has handled the event
     * a system beep is generated.  There's no need to beep, as many keystrokes in the DWT
     * are listened for and acted upon but not explicitly handled in a keyDown handler.  Fix is to
     * not call the default implementation when a keyDown: is being handled. 
     */
    if (selector !is OS.sel_keyDown_) super.noResponderFor(id, sel, selector);
     */
    if (selector !is OS.sel_keyDown_) super.noResponderFor(id, sel, selector);
}

/**
 * Moves the receiver to the top of the drawing order for
 * the display on which it was created (so that all other
 * shells on that display, which are not the receiver's
 * children will be drawn behind it), marks it visible,
 * sets the focus and asks the window manager to make the
 * shell active.
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Control#moveAbove
 * @see Control#setFocus
 * @see Control#setVisible
 * @see Display#getActiveShell
 * @see Decorations#setDefaultButton(Button)
 * @see Shell#setActive
 * @see Shell#forceActive
 */
public void open () {
    checkWidget();
    int mask = DWT.PRIMARY_MODAL | DWT.APPLICATION_MODAL | DWT.SYSTEM_MODAL;
    if ((style & mask) !is 0) {
        display.setModalShell (this);
    } else {
        updateModal ();
    }
    bringToTop (false);
    setWindowVisible (true, true);
    if (isDisposed ()) return;
    if (!restoreFocus () && !traverseGroup (true)) {
        // if the parent shell is minimized, setting focus will cause it
        // to become unminimized.
        if (parent is null || !((Shell)parent).window.isMiniaturized()) {
            setFocus ();
        }
    }
}

public bool print (GC gc) {
    checkWidget ();
    if (gc is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (gc.isDisposed ()) error (DWT.ERROR_INVALID_ARGUMENT);
    return false;
}

void register () {
    super.register ();
    if (window !is null) display.addWidget (window, this);
    if (windowDelegate !is null) display.addWidget (windowDelegate, this);
}

void releaseChildren (bool destroy) {
    Shell [] shells = getShells ();
    for (int i=0; i<shells.length; i++) {
        Shell shell = shells [i];
        if (shell !is null && !shell.isDisposed ()) {
            shell.dispose ();
        }
    }
    super.releaseChildren (destroy);
}

void releaseHandle () {
    if (window !is null) window.setDelegate(null);
    if (windowDelegate !is null) windowDelegate.release();
    windowDelegate = null;
    super.releaseHandle ();
    window = null;
}

void releaseParent () {
    /* Do nothing */
}

void releaseWidget () {
    super.releaseWidget ();
    display.clearModal (this);
    updateParent (false);
    display.updateQuitMenu();
    lastActive = null;
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when operations are performed on the receiver.
 *
 * @param listener the listener which should no longer be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see ShellListener
 * @see #addShellListener
 */
public void removeShellListener(ShellListener listener) {
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook(DWT.Activate, listener);
    eventTable.unhook(DWT.Close, listener);
    eventTable.unhook(DWT.Deactivate, listener);
    eventTable.unhook(DWT.Iconify,listener);
    eventTable.unhook(DWT.Deiconify,listener);
}

void sendToolTipEvent (bool enter) {
    if (!isVisible()) return;
    if (tooltipTag is 0) {
        NSView view = window.contentView();
        tooltipTag = view.addToolTipRect(new NSRect(), window, 0);
        if (tooltipTag !is 0) {
            NSTrackingArea trackingArea = new NSTrackingArea(tooltipTag);
            id owner = trackingArea.owner();
            if (owner !is null) tooltipOwner = owner.id;
            id userInfo = trackingArea.userInfo();
            if (userInfo !is null) {
                tooltipUserData = userInfo.id;
            } else {
                int /*long*/ [] value = new int /*long*/ [1];
                OS.object_getInstanceVariable(tooltipTag, new byte[]{'_','u', 's', 'e', 'r', 'I', 'n', 'f', 'o'}, value);
                tooltipUserData = value[0];
            }
        }
    }
    if (tooltipTag is 0 || tooltipOwner is 0 || tooltipUserData is 0) return;
    NSPoint pt = window.convertScreenToBase(NSEvent.mouseLocation());
    NSEvent event = NSEvent.enterExitEventWithType(enter ? OS.NSMouseEntered : OS.NSMouseExited, pt, 0, 0, window.windowNumber(), null, 0, tooltipTag, tooltipUserData);
    OS.objc_msgSend(tooltipOwner, enter ? OS.sel_mouseEntered_ : OS.sel_mouseExited_, event.id);
}

/**
 * If the receiver is visible, moves it to the top of the 
 * drawing order for the display on which it was created 
 * (so that all other shells on that display, which are not 
 * the receiver's children will be drawn behind it) and asks 
 * the window manager to make the shell active 
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.0
 * @see Control#moveAbove
 * @see Control#setFocus
 * @see Control#setVisible
 * @see Display#getActiveShell
 * @see Decorations#setDefaultButton(Button)
 * @see Shell#open
 * @see Shell#setActive
 */
public void setActive () {
    if (window is null) return; 
    checkWidget ();
    if (!isVisible()) return;
    makeKeyAndOrderFront ();
}

void setActiveControl (Control control) {
    if (control !is null && control.isDisposed ()) control = null;
    if (lastActive !is null && lastActive.isDisposed ()) lastActive = null;
    if (lastActive is control) return;
    
    /*
    * Compute the list of controls to be activated and
    * deactivated by finding the first common parent
    * control.
    */
    Control [] activate = (control is null) ? new Control[0] : control.getPath ();
    Control [] deactivate = (lastActive is null) ? new Control[0] : lastActive.getPath ();
    lastActive = control;
    int index = 0, length = Math.min (activate.length, deactivate.length);
    while (index < length) {
        if (activate [index] !is deactivate [index]) break;
        index++;
    }
    
    /*
    * It is possible (but unlikely), that application
    * code could have destroyed some of the widgets. If
    * this happens, keep processing those widgets that
    * are not disposed.
    */
    for (int i=deactivate.length-1; i>=index; --i) {
        if (!deactivate [i].isDisposed ()) {
            deactivate [i].sendEvent (DWT.Deactivate);
        }
    }
    for (int i=activate.length-1; i>=index; --i) {
        if (!activate [i].isDisposed ()) {
            activate [i].sendEvent (DWT.Activate);
        }
    }
}

/**
 * Sets the receiver's alpha value which must be
 * between 0 (transparent) and 255 (opaque).
 * <p>
 * This operation requires the operating system's advanced
 * widgets subsystem which may not be available on some
 * platforms.
 * </p>
 * @param alpha the alpha value
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * 
 * @since 3.4
 */
public void setAlpha (int alpha) {
    if (window is null) return; 
    checkWidget ();
    alpha &= 0xFF;
    window.setAlphaValue (alpha / 255f);
}

void setBounds (int x, int y, int width, int height, bool move, bool resize) {
    // Embedded Shells are not resizable.
    if (window is null) return;
    if (fullScreen) setFullScreen (false);
    bool sheet = window.isSheet();
    if (sheet && move && !resize) return;
    NSRect frame = window.frame();
    if (!move) {
        x = cast(int)frame.x;
        y = screenHeight - cast(int)(frame.y + frame.height);
    }
    if (resize) {
        NSSize minSize = window.minSize();
        width = Math.max(width, (int)minSize.width);
        height = Math.max(height, (int)minSize.height);
    } else {
    }
    if (sheet) {
        y = screenHeight - (int)(frame.y + frame.height);
        NSRect parentRect = parent.getShell().window.frame();
        frame.width = width;
        frame.height = height;
        frame.x = parentRect.x + (parentRect.width - frame.width) / 2;
        frame.y = screenHeight - (int)(y + frame.height);
        window.setFrame(frame, isVisible(), true);
    } else {
        frame.x = x;
        frame.y = screenHeight - cast(int)(y + height);
        frame.width = width;
        frame.height = height;
        window.setFrame(frame, isVisible());
    }
}

void setClipRegion (float /*double*/ x, float /*double*/ y) {
    if (regionPath !is null) {
        NSAffineTransform transform = NSAffineTransform.transform();
        transform.translateXBy(-x, -y);
        regionPath.transformUsingAffineTransform(transform);
        regionPath.addClip();
        transform.translateXBy(2*x, 2*y);
        regionPath.transformUsingAffineTransform(transform);
    }
}

public void setEnabled (bool enabled) {
    checkWidget();
    if (((state & DISABLED) is 0) is enabled) return;
    super.setEnabled (enabled);
//  if (enabled && OS.IsWindowActive (shellHandle)) {
//      if (!restoreFocus ()) traverseGroup (false);
//  }
}

/**
 * Sets the full screen state of the receiver.
 * If the argument is <code>true</code> causes the receiver
 * to switch to the full screen state, and if the argument is
 * <code>false</code> and the receiver was previously switched
 * into full screen state, causes the receiver to switch back
 * to either the maximized or normal states.
 * <p>
 * Note: The result of intermixing calls to <code>setFullScreen(true)</code>, 
 * <code>setMaximized(true)</code> and <code>setMinimized(true)</code> will 
 * vary by platform. Typically, the behavior will match the platform user's 
 * expectations, but not always. This should be avoided if possible.
 * </p>
 * 
 * @param fullScreen the new fullscreen state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public void setFullScreen (bool fullScreen) {
    checkWidget ();
    if (this.fullScreen is fullScreen) return;
    this.fullScreen = fullScreen; 

    if (fullScreen) {
        currentFrame = window.frame();
        window.setShowsResizeIndicator(false); //only hides resize indicator
        if (window.respondsToSelector(OS.sel_setMovable_)) {
            OS.objc_msgSend(window.id, OS.sel_setMovable_, 0);
        }
        
        fullScreenFrame = NSScreen.mainScreen().frame();
        if (getMonitor().equals(display.getPrimaryMonitor ())) {
            if (menuBar !is null) {
                float /*double*/ menuBarHt = currentFrame.height - contentView().frame().height;
                fullScreenFrame.height -= menuBarHt;
                OS.SetSystemUIMode(OS.kUIModeContentHidden, 0);
            } 
            else {
                OS.SetSystemUIMode(OS.kUIModeAllHidden, 0);
            }
        }
        window.setFrame(fullScreenFrame, true);
        window.contentView().setFrame(fullScreenFrame);
    } else {
        window.setShowsResizeIndicator(true);
        if (window.respondsToSelector(OS.sel_setMovable_)) {
            OS.objc_msgSend(window.id, OS.sel_setMovable_, 1);
        }
        OS.SetSystemUIMode(OS.kUIModeNormal, 0);
        window.setFrame(currentFrame, true);
    }
}

public void setMenuBar (Menu menu) {
    checkWidget();
    super.setMenuBar (menu);
    if (display.getActiveShell () is this) {
        display.setMenuBar (menuBar);
    }
}

/**
 * Sets the input method editor mode to the argument which 
 * should be the result of bitwise OR'ing together one or more
 * of the following constants defined in class <code>DWT</code>:
 * <code>NONE</code>, <code>ROMAN</code>, <code>DBCS</code>, 
 * <code>PHONETIC</code>, <code>NATIVE</code>, <code>ALPHA</code>.
 *
 * @param mode the new IME mode
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see DWT
 */
public void setImeInputMode (int mode) {
    checkWidget();
}

public void setMaximized (bool maximized) {
    checkWidget();
    super.setMaximized (maximized);
    if (window is null) return;
    if (window.isZoomed () is maximized) return;
    window.zoom (null);
}

public void setMinimized (bool minimized) {
    checkWidget();
    super.setMinimized (minimized);
    if (window is null) return;
    if (minimized) {
        window.miniaturize (null);
    } else {
        window.deminiaturize (null);
    }
}

/**
 * Sets the receiver's minimum size to the size specified by the arguments.
 * If the new minimum size is larger than the current size of the receiver,
 * the receiver is resized to the new minimum size.
 *
 * @param width the new minimum width for the receiver
 * @param height the new minimum height for the receiver
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * 
 * @since 3.1
 */
public void setMinimumSize (int width, int height) {
    checkWidget();
    if (window is null) return;
    NSSize size = new NSSize();
    size.width = width;
    size.height = height;
    window.setMinSize(size);
    NSRect frame = window.frame();
    if (width > frame.width || height > frame.height) {
        width = (int)(width > frame.width ? width : frame.width);
        height = (int)(height > frame.height ? height : frame.height);
        setBounds(0, 0, width, height, false, true);
    }
}

/**
 * Sets the receiver's minimum size to the size specified by the argument.
 * If the new minimum size is larger than the current size of the receiver,
 * the receiver is resized to the new minimum size.
 *
 * @param size the new minimum size for the receiver
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the point is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * 
 * @since 3.1
 */
public void setMinimumSize (Point size) {
    checkWidget();
    if (size is null) error (DWT.ERROR_NULL_ARGUMENT);
    setMinimumSize (size.x, size.y);
}

/**
 * Sets the receiver's modified state as specified by the argument.
 *
 * @param modified the new modified state for the receiver
 *
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * 
 * @since 3.5
 */
public void setModified (bool modified) {
    checkWidget ();
    window.setDocumentEdited (modified);
}

/**
 * Sets the shape of the shell to the region specified
 * by the argument.  When the argument is null, the
 * default shape of the shell is restored.  The shell
 * must be created with the style DWT.NO_TRIM in order
 * to specify a region.
 *
 * @param region the region that defines the shape of the shell (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the region has been disposed</li>
 * </ul>  
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 *
 */
public void setRegion (Region region) {
    checkWidget ();
    if ((style & DWT.NO_TRIM) is 0) return;
    if (window is null) return;
    if (region !is null && region.isDisposed()) error (DWT.ERROR_INVALID_ARGUMENT);
    this.region = region;
    if (regionPath !is null) regionPath.release();
    regionPath = getPath(region);
    if (region !is null) {
        window.setBackgroundColor(NSColor.clearColor());
        window.setOpaque(false);
    } else {
        window.setBackgroundColor(NSColor.windowBackgroundColor());
        window.setOpaque(true);
    }
    window.contentView().setNeedsDisplay(true);
    if (isVisible() && window.hasShadow()) {
        window.display();
        window.invalidateShadow();
    }
}

public void setText (String str) {
    checkWidget();
    //if (str is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (window is null) return;
    NSString nsStr = NSString.stringWith(str);
    window.setTitle(nsStr);
}

public void setVisible (bool visible) {
    checkWidget();
    int mask = DWT.PRIMARY_MODAL | DWT.APPLICATION_MODAL | DWT.SYSTEM_MODAL;
    if ((style & mask) !is 0) {
        if (visible) {
            display.setModalShell (this);
        } else {
            display.clearModal (this);
        }
    } else {
        updateModal ();
    }
    if (window is null) {
        super.setVisible(visible);
    } else {
        setWindowVisible (visible, false);
    }
}

void setWindowVisible (bool visible, bool key) {
    if (visible) {
        if ((state & HIDDEN) is 0) return;
        state &= ~HIDDEN;
    } else {
        if ((state & HIDDEN) !is 0) return;
        state |= HIDDEN;
    }
    if (window !is null && (window.isVisible() is visible)) return;
    if (visible) {
        display.clearPool ();
        if (center && !moved) {
            if (isDisposed ()) return;          
            center ();
        }
        sendEvent (DWT.Show);
        if (isDisposed ()) return;
        topView ().setHidden (false);
        invalidateVisibleRegion();
        if ((style & (DWT.SHEET)) !is 0) {
            NSApplication application = NSApplication.sharedApplication();
            application.beginSheet(window, ((Shell)parent).window, null, 0, 0);
            if (OS.VERSION <= 0x1060 && window.respondsToSelector(OS.sel__setNeedsToUseHeartBeatWindow_)) {
                OS.objc_msgSend(window.id, OS.sel__setNeedsToUseHeartBeatWindow_, 0);
            }
        } else {
            // If the parent window is miniaturized, the window will be shown
            // when its parent is shown.
            bool parentMinimized = parent !is null && ((Shell)parent).window.isMiniaturized();
            if (!parentMinimized) {
                if (key) {
                    makeKeyAndOrderFront ();
                } else {
                    window.orderFront (null);
                }
            }
        }
        updateParent (visible);
        opened = true;
        if (!moved) {
            moved = true;
            sendEvent (DWT.Move);
            if (isDisposed ()) return;
        }
        if (!resized) {
            resized = true;
            sendEvent (DWT.Resize);
            if (isDisposed ()) return;
            if (layout_ !is null) {
                markLayout (false, false);
                updateLayout (false);
            }
        }
    } else {
        updateParent (visible);
        if ((style & (DWT.SHEET)) !is 0) {
            NSApplication application = NSApplication.sharedApplication();
            application.endSheet(window, 0);
        }
        window.orderOut (null);
        topView ().setHidden (true);
        invalidateVisibleRegion();
        sendEvent (DWT.Hide);
    }
    
    display.updateQuitMenu();
}

void setZOrder () {
    if (scrollView !is null) scrollView.setDocumentView (view);
    if (window is null) return;
    window.setContentView (scrollView !is null ? scrollView : view);
    if (fixResize ()) {
        NSRect rect = window.frame();
        rect.x = rect.y = 0;
        window.contentView().setFrame(rect);
    }
}

void setZOrder (Control control, bool above) {
    if (window is null) return;
    if (control is null) {
        if (above) {
            window.orderFront(null);
        } else {
            window.orderBack(null);
        }
    } else {
        NSWindow otherWindow = control.getShell().window;
        window.orderWindow(above ? OS.NSWindowAbove : OS.NSWindowBelow, otherWindow.windowNumber());
    }
}

bool traverseEscape () {
    if (parent is null) return false;
    if (!isVisible () || !isEnabled ()) return false;
    close ();
    return true;
}

void updateModal () {
    // do nothing
}

void updateParent (bool visible) {
    if (visible) {
        if (parent !is null && parent.getVisible ()) {
            ((Shell)parent).window.addChildWindow (window, OS.NSWindowAbove);
        }       
    } else {
        NSWindow parentWindow = window.parentWindow ();
        if (parentWindow !is null) parentWindow.removeChildWindow (window);
    }
    Shell [] shells = getShells ();
    for (int i = 0; i < shells.length; i++) {
        Shell shell = shells [i];
        if (shell.parent is this && shell.getVisible ()) {
            shell.updateParent (visible);
        }
    }
}

void updateSystemUIMode () {
    if (!getMonitor ().equals (display.getPrimaryMonitor ())) return;
    if (fullScreen) {
        int mode = OS.kUIModeAllHidden;
        if (menuBar !is null) {
            mode = OS.kUIModeContentHidden;
        }
        OS.SetSystemUIMode (mode, 0);
        window.setFrame(fullScreenFrame, true);
    } else {
        OS.SetSystemUIMode (OS.kUIModeNormal, 0);
    }
    char[] chars = new char [string.length ()];
    string.getChars (0, chars.length, chars, 0);
    int length = fixMnemonic (chars);
    return NSString.stringWithCharacters (chars, length).id;
}

int /*long*/ view_stringForToolTip_point_userData (int /*long*/ id, int /*long*/ sel, int /*long*/ view, int /*long*/ tag, int /*long*/ point, int /*long*/ userData) {
    NSPoint pt = new NSPoint();
    OS.memmove (pt, point, NSPoint.sizeof);
    Control control = display.findControl (false);
    if (control is null) return 0;
    Widget target = control.findTooltip (new NSView (view).convertPoint_toView_ (pt, null));
    String string = target.tooltipText ();
    if (string is null) return 0;
    char[] chars = new char [string.length ()];
    string.getChars (0, chars.length, chars, 0);
    int length = fixMnemonic (chars);
    return NSString.stringWithCharacters (chars, length).id;
}

void windowDidBecomeKey(objc.id id, objc.SEL sel, objc.id notification) {
    super.windowDidBecomeKey(id, sel, notification);
    Display display = this.display;
    display.setMenuBar (menuBar);
    sendEvent (DWT.Activate);
    if (isDisposed ()) return;
    Shell parentShell = this;
    while (parentShell.parent !is null) {
        parentShell = (Shell) parentShell.parent;
        if (parentShell.fullScreen) {
            break;
        }
    }
    if (!parentShell.fullScreen || menuBar !is null) {
        updateSystemUIMode ();
    } else {
        parentShell.updateSystemUIMode ();
    }
}

void windowDidMove(objc.id id, objc.SEL sel, objc.id notification) {
    moved = true;
    sendEvent(DWT.Move);
}

void windowDidResize(objc.id id, objc.SEL sel, objc.id notification) {
    if (fullScreen) {
        window.setFrame(fullScreenFrame, true);
        window.contentView().setFrame(fullScreenFrame);
    }
    if (fixResize ()) {
        NSRect rect = window.frame ();
        rect.x = rect.y = 0;
        window.contentView ().setFrame (rect);
    }
    resized = true;
    sendEvent (DWT.Resize);
    if (isDisposed ()) return;
    if (layout_ !is null) {
        markLayout (false, false);
        updateLayout (false);
    }
}

void windowDidResignKey(objc.id id, objc.SEL sel, objc.id notification) {
    super.windowDidResignKey(id, sel, notification);
    sendEvent (DWT.Deactivate);
                Control trimControl = control;
                if (trimControl !is null && trimControl.isTrim (hitView[0])) trimControl = null;
                display.checkEnterExit (trimControl, nsEvent, false);
                if (trimControl !is null) trimControl.sendMouseEvent (nsEvent, type, false);
            }
            Widget target = null;
            if (control !is null) target = control.findTooltip (nsEvent.locationInWindow());
            if (display.tooltipControl !is control || display.tooltipTarget !is target) {
                Control oldControl = display.tooltipControl;
                Shell oldShell = oldControl !is null && !oldControl.isDisposed() ? oldControl.getShell() : null;
                Shell shell = control !is null && !control.isDisposed() ? control.getShell() : null;
                if (oldShell !is null) oldShell.sendToolTipEvent (false);
                if (shell !is null) shell.sendToolTipEvent (true);
            }
            display.tooltipControl = control;
            display.tooltipTarget = target;
            break;
            
        case OS.NSKeyDown:
            /**
             * Feature in cocoa.  Control+Tab, Ctrl+Shift+Tab, Ctrl+PageDown and Ctrl+PageUp are
             * swallowed to handle native traversal. If we find that, force the key event to
             * the first responder.
             */
            if ((nsEvent.modifierFlags() & OS.NSControlKeyMask) !is 0) {
                NSString chars = nsEvent.characters();
                
                if (chars !is null && chars.length() is 1) {
                    int firstChar = (int)/*64*/chars.characterAtIndex(0);

                    // Shift-tab appears as control-Y.
                    switch (firstChar) {
                        case '\t':
                        case 25:
                        case OS.NSPageDownFunctionKey:
                        case OS.NSPageUpFunctionKey:
                            window.firstResponder().keyDown(nsEvent);
                            return;
                    }
                }
            }
            break;
    }
    super.windowSendEvent (id, sel, event);
}

void windowSendEvent (int /*long*/ id, int /*long*/ sel, int /*long*/ event) {
    NSEvent nsEvent = new NSEvent (event);
    int type = (int)/*64*/nsEvent.type ();
    switch (type) {
        case OS.NSLeftMouseUp:
        case OS.NSRightMouseUp:
        case OS.NSOtherMouseUp:
        case OS.NSMouseMoved:
            NSView[] hitView = new NSView[1];
            Control control = display.findControl (false, hitView);
            if (control !is null && (!control.isActive() || !control.isEnabled())) control = null;
            if (type is OS.NSMouseMoved) {
                Control trimControl = control;
                if (trimControl !is null && trimControl.isTrim (hitView[0])) trimControl = null;
                display.checkEnterExit (trimControl, nsEvent, false);
                if (trimControl !is null) trimControl.sendMouseEvent (nsEvent, type, false);
            }
            Widget target = null;
            if (control !is null) target = control.findTooltip (nsEvent.locationInWindow());
            if (display.tooltipControl !is control || display.tooltipTarget !is target) {
                Control oldControl = display.tooltipControl;
                Shell oldShell = oldControl !is null && !oldControl.isDisposed() ? oldControl.getShell() : null;
                Shell shell = control !is null && !control.isDisposed() ? control.getShell() : null;
                if (oldShell !is null) oldShell.sendToolTipEvent (false);
                if (shell !is null) shell.sendToolTipEvent (true);
            }
            display.tooltipControl = control;
            display.tooltipTarget = target;
            break;
            
        case OS.NSKeyDown:
            /**
             * Feature in cocoa.  Control+Tab, Ctrl+Shift+Tab, Ctrl+PageDown and Ctrl+PageUp are
             * swallowed to handle native traversal. If we find that, force the key event to
             * the first responder.
             */
            if ((nsEvent.modifierFlags() & OS.NSControlKeyMask) !is 0) {
                NSString chars = nsEvent.characters();
                
                if (chars !is null && chars.length() is 1) {
                    int firstChar = (int)/*64*/chars.characterAtIndex(0);

                    // Shift-tab appears as control-Y.
                    switch (firstChar) {
                        case '\t':
                        case 25:
                        case OS.NSPageDownFunctionKey:
                        case OS.NSPageUpFunctionKey:
                            window.firstResponder().keyDown(nsEvent);
                            return;
                    }
                }
            }
            break;
    }
    super.windowSendEvent (id, sel, event);
}

bool windowShouldClose(objc.id id, objc.SEL sel, objc.id window) {
    closeWidget ();
    return false;
}

}
