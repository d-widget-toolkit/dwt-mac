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
module dwt.widgets.Display;



import dwt.internal.cocoa.NSFont;
import dwt.internal.cocoa.NSMutableArray;
import cocoa = dwt.internal.cocoa.id;

import tango.core.Thread;
import tango.core.Runtime;
import tango.stdc.stringz;
import tango.text.convert.Format;
import Math = tango.math.Math;

import dwt.DWT;
import dwt.dwthelper.System;
import dwt.dwthelper.Runnable;
import dwt.dwthelper.utils;
import dwt.internal.cocoa.NSDictionary;
import dwt.internal.cocoa.NSApplication;
import dwt.internal.cocoa.NSImage;
import dwt.internal.cocoa.NSWindow;
import dwt.internal.cocoa.NSAutoreleasePool;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSScreen;
import dwt.internal.cocoa.NSEvent;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSColor;
import dwt.internal.cocoa.NSView;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSTimer;
import dwt.internal.cocoa.NSMutableDictionary;
import dwt.internal.cocoa.NSThread;
import dwt.internal.cocoa.NSNumber;
import dwt.internal.cocoa.NSMenu;
import dwt.internal.cocoa.NSMenuItem;
import dwt.internal.cocoa.NSResponder;
import dwt.internal.cocoa.NSColorSpace;
import dwt.internal.cocoa.NSWorkspace;
import dwt.internal.cocoa.NSSlider;
import dwt.internal.cocoa.NSTextField;
import dwt.internal.cocoa.NSStepper;
import dwt.internal.cocoa.NSSearchField;
import dwt.internal.cocoa.NSImageView;
import dwt.internal.cocoa.NSPopUpButton;
import dwt.internal.cocoa.NSComboBox;
import dwt.internal.cocoa.NSButton;
import dwt.internal.cocoa.NSTextView;
import dwt.internal.cocoa.NSNotificationCenter;
import dwt.internal.cocoa.NSGraphicsContext;
import dwt.internal.cocoa.NSValue;
import dwt.internal.cocoa.NSBundle;
import dwt.internal.cocoa.NSRunLoop;
import dwt.internal.cocoa.NSDate;
import dwt.internal.cocoa.NSRange;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.SWTWindowDelegate;
import dwt.internal.cocoa.SWTApplicationDelegate;
import dwt.internal.cocoa.CGPoint;
import dwt.internal.cocoa.OS;
import dwt.internal.cocoa.objc_super;
//import dwt.internal.Callback;
import dwt.internal.C;
import Carbon = dwt.internal.c.Carbon;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;
import dwt.internal.c.bindings;
import dwt.widgets.Caret;
import dwt.widgets.ColorDialog;
import dwt.widgets.Control;
import dwt.widgets.Decorations;
import dwt.widgets.Dialog;
import dwt.widgets.Event;
import dwt.widgets.EventTable;
import dwt.widgets.FontDialog;
import dwt.widgets.Listener;
import dwt.widgets.Menu;
import dwt.widgets.MenuItem;
import dwt.widgets.Monitor;
import dwt.widgets.Shell;
import dwt.widgets.Synchronizer;
import dwt.widgets.Tray;
import dwt.widgets.TrayItem;
import dwt.widgets.Widget;
import dwt.widgets.Button;
import dwt.widgets.MessageBox;
import dwt.widgets.FileDialog;
import dwt.graphics.Device;
import dwt.graphics.GCData;
import dwt.graphics.Image;
import dwt.graphics.Cursor;
import dwt.graphics.DeviceData;
import dwt.graphics.Rectangle;
import dwt.graphics.Color;
import dwt.graphics.Point;

/**
 * Instances of this class are responsible for managing the
 * connection between DWT and the underlying operating
 * system. Their most important function is to implement
 * the DWT event loop in terms of the platform event model.
 * They also provide various methods for accessing information
 * about the operating system, and have overall control over
 * the operating system resources which DWT allocates.
 * <p>
 * Applications which are built with DWT will <em>almost always</em>
 * require only a single display. In particular, some platforms
 * which DWT supports will not allow more than one <em>active</em>
 * display. In other words, some platforms do not support
 * creating a new display if one already exists that has not been
 * sent the <code>dispose()</code> message.
 * <p>
 * In DWT, the thread which creates a <code>Display</code>
 * instance is distinguished as the <em>user-interface thread</em>
 * for that display.
 * </p>
 * The user-interface thread for a particular display has the
 * following special attributes:
 * <ul>
 * <li>
 * The event loop for that display must be run from the thread.
 * </li>
 * <li>
 * Some DWT API methods (notably, most of the public methods in
 * <code>Widget</code> and its subclasses), may only be called
 * from the thread. (To support multi-threaded user-interface
 * applications, class <code>Display</code> provides inter-thread
 * communication methods which allow threads other than the
 * user-interface thread to request that it perform operations
 * on their behalf.)
 * </li>
 * <li>
 * The thread is not allowed to construct other
 * <code>Display</code>s until that display has been disposed.
 * (Note that, this is in addition to the restriction mentioned
 * above concerning platform support for multiple displays. Thus,
 * the only way to have multiple simultaneously active displays,
 * even on platforms which support it, is to have multiple threads.)
 * </li>
 * </ul>
 * Enforcing these attributes allows DWT to be implemented directly
 * on the underlying operating system's event model. This has
 * numerous benefits including smaller footprint, better use of
 * resources, safer memory management, clearer program logic,
 * better performance, and fewer overall operating system threads
 * required. The down side however, is that care must be taken
 * (only) when constructing multi-threaded applications to use the
 * inter-thread communication mechanisms which this class provides
 * when required.
 * </p><p>
 * All DWT API methods which may only be called from the user-interface
 * thread are distinguished in their documentation by indicating that
 * they throw the "<code>ERROR_THREAD_INVALID_ACCESS</code>"
 * DWT exception.
 * </p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>(none)</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Close, Dispose, Settings</dd>
 * </dl>
 * <p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 * @see #syncExec
 * @see #asyncExec
 * @see #wake
 * @see #readAndDispatch
 * @see #sleep
 * @see Device#dispose
 * @see <a href="http://www.eclipse.org/swt/snippets/#display">Display snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 * @noextend This class is not intended to be subclassed by clients.
 */
public class Display : Device {

    /* Windows and Events */
    Event [] eventQueue;
    EventTable eventTable, filterTable;
    bool disposing;
    int sendEventCount;

    /* Key event management */
    uint [] deadKeyState;
    Carbon.CFDataRef currentKeyboardUCHRdata;
    bool eventSourceDelaySet;

    /* Sync/Async Widget Communication */
    Synchronizer synchronizer;
    Thread thread;
    bool allowTimers, runAsyncMessages_;

    GCData[] contexts;

    Caret currentCaret;

    bool sendEvent_;
    int clickCountButton, clickCount;
    Control currentControl, trackingControl, tooltipControl;
    Widget tooltipTarget;

    NSMutableArray isPainting, needsDisplay, needsDisplayInRect;

    NSDictionary markedAttributes;

    /* Fonts */
    bool smallFonts;
    NSFont buttonFont, popUpButtonFont, textFieldFont, secureTextFieldFont;
    NSFont searchFieldFont, comboBoxFont, sliderFont, scrollerFont;
    NSFont textViewFont, tableViewFont, outlineViewFont, datePickerFont;
    NSFont boxFont, tabViewFont, progressIndicatorFont;

    Shell [] modalShells;

    Menu menuBar;
    Menu[] menus, popups;

    NSApplication application;
    objc.Class applicationClass;
    NSImage dockImage;
    bool isEmbedded;
    static bool launched = false;

    /* Focus */
    Control focusControl, currentFocusControl;
    int focusEvent;

    NSWindow screenWindow, keyWindow;

    NSAutoreleasePool[] pools;
    int poolCount, loopCount;

    int[] screenID;
    NSPoint[] screenCascade;
    bool[] screenCascadeExists;

    Carbon.CFRunLoopObserverRef runLoopObserver;

    bool lockCursor = true;
    objc.IMP oldCursorSetProc;

    /* Display Shutdown */
    Runnable [] disposeList;

    /* System Tray */
    Tray tray;
    TrayItem currentTrayItem;
    Menu trayItemMenu;

    /* System Resources */
    Image errorImage, infoImage, warningImage;
    Cursor [] cursors;

    /* System Colors */
    Carbon.CGFloat [][] colors;
    Carbon.CGFloat [] alternateSelectedControlTextColor, selectedControlTextColor;
    Carbon.CGFloat [] alternateSelectedControlColor, secondarySelectedControlColor;

    /* Key Mappings. */
    static int [] [] KeyTable = [

                                 /* Keyboard and Mouse Masks */
                                 [58,    DWT.ALT],
                                 [56,    DWT.SHIFT],
                                 [59,    DWT.CONTROL],
                                 [55,    DWT.COMMAND],
                                 [61,    DWT.ALT],
                                 [62,    DWT.CONTROL],
                                 [60,    DWT.SHIFT],
                                 [54,    DWT.COMMAND],

                                 /* Non-Numeric Keypad Keys */
                                 [126, DWT.ARROW_UP],
                                 [125, DWT.ARROW_DOWN],
                                 [123, DWT.ARROW_LEFT],
                                 [124, DWT.ARROW_RIGHT],
                                 [116, DWT.PAGE_UP],
                                 [121, DWT.PAGE_DOWN],
                                 [115, DWT.HOME],
                                 [119, DWT.END],
                                 //   [??,    DWT.INSERT],

                                 /* Virtual and Ascii Keys */
                                 [51,    DWT.BS],
                                 [36,    DWT.CR],
                                 [117,   DWT.DEL],
                                 [53,    DWT.ESC],
                                 [76,    DWT.LF],
                                 [48,    DWT.TAB],

                                 /* Functions Keys */
                                 [122, DWT.F1],
                                 [120, DWT.F2],
                                 [99,    DWT.F3],
                                 [118, DWT.F4],
                                 [96,    DWT.F5],
                                 [97,    DWT.F6],
                                 [98,    DWT.F7],
                                 [100, DWT.F8],
                                 [101, DWT.F9],
                                 [109, DWT.F10],
                                 [103, DWT.F11],
                                 [111, DWT.F12],
                                 [105, DWT.F13],
                                 [107, DWT.F14],
                                 [113, DWT.F15],

                                 /* Numeric Keypad Keys */
                                 [67, DWT.KEYPAD_MULTIPLY],
                                 [69, DWT.KEYPAD_ADD],
                                 [76, DWT.KEYPAD_CR],
                                 [78, DWT.KEYPAD_SUBTRACT],
                                 [65, DWT.KEYPAD_DECIMAL],
                                 [75, DWT.KEYPAD_DIVIDE],
                                 [82, DWT.KEYPAD_0],
                                 [83, DWT.KEYPAD_1],
                                 [84, DWT.KEYPAD_2],
                                 [85, DWT.KEYPAD_3],
                                 [86, DWT.KEYPAD_4],
                                 [87, DWT.KEYPAD_5],
                                 [88, DWT.KEYPAD_6],
                                 [89, DWT.KEYPAD_7],
                                 [91, DWT.KEYPAD_8],
                                 [92, DWT.KEYPAD_9],
                                 [81, DWT.KEYPAD_EQUAL],

                                 /* Other keys */
                                 [57,    DWT.CAPS_LOCK],
                                 [71,    DWT.NUM_LOCK],
                                 //       [??,    DWT.SCROLL_LOCK],
                                 //       [??,    DWT.PAUSE],
                                 //       [??,    DWT.BREAK],
                                 //       [??,    DWT.PRINT_SCREEN],
                                 [114, DWT.HELP],

                                 ];

    static String APP_NAME;
    static const String ADD_WIDGET_KEY = "org.eclipse.swt.internal.addWidget";
    static const char[] SWT_OBJECT = ['S', 'W', 'T', '_', 'O', 'B', 'J', 'E', 'C', 'T', '\0'];
    static const char[] SWT_IMAGE = ['S', 'W', 'T', '_', 'I', 'M', 'A', 'G', 'E', '\0'];
    static const char[] SWT_ROW = ['S', 'W', 'T', '_', 'R', 'O', 'W', '\0'];
    static const char[] SWT_COLUMN = ['S', 'W', 'T', '_', 'C', 'O', 'L', 'U', 'M', 'N', '\0'];

    /* Multiple Displays. */
    static Display Default;
    static Display [] Displays;

    /* Package Name */
    static const String PACKAGE_PREFIX = "dwt.widgets.";

    /* Timer */
    Runnable timerList [];
    NSTimer nsTimers [];
    SWTWindowDelegate timerDelegate;
    static SWTApplicationDelegate applicationDelegate;

    /* Settings */
    bool runSettings_;
    SWTWindowDelegate settingsDelegate;

    static final int DEFAULT_BUTTON_INTERVAL = 30;

    /* Display Data */
    Object data;
    String [] keys;
    Object [] values;

    private static bool runShutdownHook;

    /*
     * TEMPORARY CODE.  Install the runnable that
     * gets the current display. This code will
     * be removed in the future.
     */
    static this () {
        Displays = new Display [4];
        DeviceFinder = new class Runnable {
            public void run () {
                Device device = getCurrent ();
                if (device is null) {
                    device = getDefault ();
                }
                setDevice (device);
            }
        };
    }

/*
 * TEMPORARY CODE.
 */
static void setDevice (Device device) {
    CurrentDevice = device;
}

static char* ascii (String name) {
    /*int length = name.length ();
     char [] chars = new char [length];
     name.getChars (0, length, chars, 0);
     byte [] buffer = new byte [length + 1];
     for (int i=0; i<length; i++) {
     buffer [i] = cast(byte) chars [i];
     }
     return buffer;*/
    return name.toStringz();
}

static int translateKey (int key) {
    for (int i=0; i<KeyTable.length; i++) {
        if (KeyTable [i] [0] is key) return KeyTable [i] [1];
    }
    return 0;
}

static int untranslateKey (int key) {
    for (int i=0; i<KeyTable.length; i++) {
        if (KeyTable [i] [1] is key) return KeyTable [i] [0];
    }
    return 0;
}

void addContext (GCData context) {
    if (contexts is null) contexts = new GCData [12];
    for (int i=0; i<contexts.length; i++) {
        if (contexts[i] !is null && contexts [i] is context) {
            contexts [i] = context;
            return;
        }
    }
    GCData [] newContexts = new GCData [contexts.length + 12];
    newContexts [contexts.length] = context;
    System.arraycopy (contexts, 0, newContexts, 0, contexts.length);
    contexts = newContexts;
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when an event of the given type occurs anywhere
 * in a widget. The event type is one of the event constants
 * defined in class <code>DWT</code>. When the event does occur,
 * the listener is notified by sending it the <code>handleEvent()</code>
 * message.
 * <p>
 * Setting the type of an event to <code>DWT.None</code> from
 * within the <code>handleEvent()</code> method can be used to
 * change the event type and stop subsequent Java listeners
 * from running. Because event filters run before other listeners,
 * event filters can both block other listeners and set arbitrary
 * fields within an event. For this reason, event filters are both
 * powerful and dangerous. They should generally be avoided for
 * performance, debugging and code maintenance reasons.
 * </p>
 *
 * @param eventType the type of event to listen for
 * @param listener the listener which should be notified when the event occurs
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see Listener
 * @see DWT
 * @see #removeFilter
 * @see #removeListener
 *
 * @since 3.0
 */
public void addFilter (int eventType, Listener listener) {
    checkDevice ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (filterTable is null) filterTable = new EventTable ();
    filterTable.hook (eventType, listener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when an event of the given type occurs. The event
 * type is one of the event constants defined in class <code>DWT</code>.
 * When the event does occur in the display, the listener is notified by
 * sending it the <code>handleEvent()</code> message.
 *
 * @param eventType the type of event to listen for
 * @param listener the listener which should be notified when the event occurs
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see Listener
 * @see DWT
 * @see #removeListener
 *
 * @since 2.0
 */
public void addListener (int eventType, Listener listener) {
    checkDevice ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) eventTable = new EventTable ();
    eventTable.hook (eventType, listener);
}

void addMenu (Menu menu) {
    if (menus is null) menus = new Menu [12];
    for (int i=0; i<menus.length; i++) {
        if (menus [i] is null) {
            menus [i] = menu;
            return;
        }
    }
    Menu [] newMenus = new Menu [menus.length + 12];
    newMenus [menus.length] = menu;
    System.arraycopy (menus, 0, newMenus, 0, menus.length);
    menus = newMenus;
}

void addPool () {
    addPool (cast(NSAutoreleasePool)(new NSAutoreleasePool()).alloc().init());
}

void addPool (NSAutoreleasePool pool) {
    if (pools is null) pools = new NSAutoreleasePool [4];
    if (poolCount is pools.length) {
        NSAutoreleasePool[] temp = new NSAutoreleasePool [poolCount + 4];
        System.arraycopy (pools, 0, temp, 0, poolCount);
        pools = temp;
    }
    if (poolCount is 0) {
        NSMutableDictionary dictionary = NSThread.currentThread().threadDictionary();
        dictionary.setObject(NSNumber.numberWithInteger(cast(int)pool.id), NSString.stringWith("SWT_NSAutoreleasePool"));
    }
    pools [poolCount++] = pool;
}

void addPopup (Menu menu) {
    if (popups is null) popups = new Menu [4];
    size_t length_ = popups.length;
    for (size_t i=0; i<length_; i++) {
        if (popups [i] is menu) return;
    }
    size_t index = 0;
    while (index < length_) {
        if (popups [index] is null) break;
        index++;
    }
    if (index is length_) {
        Menu [] newPopups = new Menu [length_ + 4];
        System.arraycopy (popups, 0, newPopups, 0, length_);
        popups = newPopups;
    }
    popups [index] = menu;
}

void addWidget (NSObject view, Widget widget) {
    if (view is null) return;
    OS.object_setInstanceVariable (view.id, SWT_OBJECT, widget.jniRef);
}

/**
 * Causes the <code>run()</code> method of the runnable to
 * be invoked by the user-interface thread at the next
 * reasonable opportunity. The caller of this method continues
 * to run in parallel, and is not notified when the
 * runnable has completed.  Specifying <code>null</code> as the
 * runnable simply wakes the user-interface thread when run.
 * <p>
 * Note that at the time the runnable is invoked, widgets
 * that have the receiver as their display may have been
 * disposed. Therefore, it is necessary to check for this
 * case inside the runnable before accessing the widget.
 * </p>
 *
 * @param runnable code to run on the user-interface thread or <code>null</code>
 *
 * @exception DWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #syncExec
 */
public void asyncExec (Runnable runnable) {
    synchronized (Device.classinfo) {
        if (isDisposed ()) error (DWT.ERROR_DEVICE_DISPOSED);
        synchronizer.asyncExec (runnable);
    }
}

/**
 * Causes the system hardware to emit a short sound
 * (if it supports this capability).
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void beep () {
    checkDevice ();
    OS.NSBeep ();
}

void cascadeWindow (NSWindow window, NSScreen screen) {
    NSDictionary dictionary = screen.deviceDescription();
    int screenNumber = (new NSNumber(dictionary.objectForKey(NSString.stringWith("NSScreenNumber")).id)).intValue();
    int index = 0;
    while (screenID[index] !is 0 && screenID[index] !is screenNumber) index++;
    screenID[index] = screenNumber;
    NSPoint cascade = screenCascade[index];
    if (screenCascadeExists[index]) {
        NSRect frame = screen.frame();
        cascade = NSPoint();
        cascade.x = frame.x;
        cascade.y = frame.y + frame.height;
    }
    screenCascade[index] = window.cascadeTopLeftFromPoint(cascade);
    screenCascadeExists[index] = true;
}

protected void checkDevice () {
    if (thread is null) error (DWT.ERROR_WIDGET_DISPOSED);
    if (thread !is Thread.getThis ()) error (DWT.ERROR_THREAD_INVALID_ACCESS);
    if (isDisposed ()) error (DWT.ERROR_DEVICE_DISPOSED);
}

void checkEnterExit (Control control, NSEvent nsEvent, bool send) {
    if (control !is currentControl) {
        if (currentControl !is null && !currentControl.isDisposed()) {
            currentControl.sendMouseEvent (nsEvent, DWT.MouseExit, send);
        }
        if (control !is null && control.isDisposed()) control = null;
        currentControl = control;
        if (control !is null) {
            control.sendMouseEvent (nsEvent, DWT.MouseEnter, send);
        }
        setCursor (control);
    }
    timerExec (control !is null && !control.isDisposed() ? getToolTipTime () : -1, hoverTimer);
}

void checkFocus () {
    Control oldControl = currentFocusControl;
    Control newControl = getFocusControl ();
    if (oldControl !is newControl) {
        if (oldControl !is null && !oldControl.isDisposed ()) {
            oldControl.sendFocusEvent (DWT.FocusOut);
        }
        currentFocusControl = newControl;
        if (newControl !is null && !newControl.isDisposed ()) {
            newControl.sendFocusEvent (DWT.FocusIn);
        }
    }
}

/**
 * Checks that this class can be subclassed.
 * <p>
 * IMPORTANT: See the comment in <code>Widget.checkSubclass()</code>.
 * </p>
 *
 * @exception DWTException <ul>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see Widget#checkSubclass
 */
protected void checkSubclass () {
    if (!Display.isValidClass (this.classinfo)) error (DWT.ERROR_INVALID_SUBCLASS);
}

/**
 * Constructs a new instance of this class.
 * <p>
 * Note: The resulting display is marked as the <em>current</em>
 * display. If this is the first display which has been
 * constructed since the application started, it is also
 * marked as the <em>default</em> display.
 * </p>
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if called from a thread that already created an existing display</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see #getCurrent
 * @see #getDefault
 * @see Widget#checkSubclass
 * @see Shell
 */
public this () {
    this (null);
}

/**
 * Constructs a new instance of this class using the parameter.
 *
 * @param data the device data
 */
public this (DeviceData data) {
	deadKeyState = new uint[1];
	screenID = new int[32];
    screenCascade = new NSPoint[32];
    screenCascadeExists = new bool[32];

    super (data);
    screenID = new int[32];
    screenCascade = new NSPoint[32];
    screenCascadeExists = new bool[32];
    cursors = new Cursor [DWT.CURSOR_HAND + 1];
    timerDelegate = cast(SWTWindowDelegate)(new SWTWindowDelegate()).alloc().init();

    caretTimer = new CaretTimer;
    hoverTimer = new HoverTimer;
    defaultButtonTimer = new DefaultButtonTimer;
}

static void checkDisplay (Thread thread, bool multiple) {
    synchronized (Device.classinfo) {
        for (int i=0; i<Displays.length; i++) {
            if (Displays [i] !is null) {
                if (!multiple) DWT.error (DWT.ERROR_NOT_IMPLEMENTED, null, " [multiple displays]");
                if (Displays [i].thread is thread) DWT.error (DWT.ERROR_THREAD_INVALID_ACCESS);
            }
        }
    }
}

static String convertToLf(String text) {
    char Cr = '\r';
    char Lf = '\n';
    int length = text.length;
    if (length is 0) return text;

    /* Check for an LF or CR/LF.  Assume the rest of the string
     * is formated that way.  This will not work if the string
     * contains mixed delimiters. */
    int i = text.indexOf (Lf, 0);
    if (i is -1 || i is 0) return text;
    if (text.charAt (i - 1) !is Cr) return text;

    /* The string is formatted with CR/LF.
     * Create a new string with the LF line delimiter. */
    i = 0;
    StringBuffer result = new StringBuffer ();
    while (i < length) {
        int j = text.indexOf (Cr, i);
        if (j is -1) j = length;
        String s = text.substring (i, j);
        result.append (s);
        i = j + 2;
        result.append (Lf);
    }
    return result.toString ();
}

void clearModal (Shell shell) {
    if (modalShells is null) return;
    int index = 0, length_ = modalShells.length;
    while (index < length_) {
        if (modalShells [index] is shell) break;
        if (modalShells [index] is null) return;
        index++;
    }
    if (index is length_) return;
    System.arraycopy (modalShells, index + 1, modalShells, index, --length_ - index);
    modalShells [length_] = null;
    if (index is 0 && modalShells [0] is null) modalShells = null;
    Shell [] shells = getShells ();
    for (int i=0; i<shells.length; i++) shells [i].updateModal ();
}

void clearPool () {
    if (sendEventCount is 0 && loopCount is poolCount - 1) {
        removePool ();
        addPool ();
    }
}

/**
 * Requests that the connection between DWT and the underlying
 * operating system be closed.
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see Device#dispose
 *
 * @since 2.0
 */
public void close () {
    checkDevice ();
    Event event = new Event ();
    sendEvent (DWT.Close, event);
    if (event.doit) dispose ();
}

/**
 * Creates the device in the operating system.  If the device
 * does not have a handle, this method may do nothing depending
 * on the device.
 * <p>
 * This method is called before <code>init</code>.
 * </p>
 *
 * @param data the DeviceData which describes the receiver
 *
 * @see #init
 */
protected void create (DeviceData data) {
    checkSubclass ();
    checkDisplay (thread = Thread.getThis (), false);
    createDisplay (data);
    register (this);
    synchronizer = new Synchronizer (this);
    if (Default is null) Default = this;
}

void createDisplay (DeviceData data) {
    if (OS.VERSION < 0x1050) {
        System.out_.println ("***WARNING: DWT requires MacOS X version {}{}{}{}" , 10 , "." , 5 , " or greater"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
        System.out_.println ("***WARNING: Detected: {}{}{}{}{}" , Integer.toHexString((OS.VERSION & 0xFF00) >> 8) , "." , Integer.toHexString((OS.VERSION & 0xF0) >> 4) , "." , Integer.toHexString(OS.VERSION & 0xF)); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
        error(DWT.ERROR_NOT_IMPLEMENTED);
    }

    NSThread nsthread = NSThread.currentThread();
    NSMutableDictionary dictionary = nsthread.threadDictionary();
    NSString key = NSString.stringWith("SWT_NSAutoreleasePool");
    NSNumber id = new NSNumber(dictionary.objectForKey(key));
    addPool(new NSAutoreleasePool(id));

    application = NSApplication.sharedApplication();

    /*
     * TODO: If an NSApplication is already running we don't want to create another NSApplication.
     * But if we don't we won't get mouse events, since we currently need to subclass NSApplication and intercept sendEvent to
     * deliver mouse events correctly to widgets.
     */
    if (!application.isRunning()) {
        /*
         * Feature in the Macintosh.  On OS 10.2, it is necessary
         * to explicitly check in with the Process Manager and set
         * the current process to be the front process in order for
         * windows to come to the front by default.  The fix is call
         * both GetCurrentProcess() and SetFrontProcess().
         *
         * NOTE: It is not actually necessary to use the process
         * serial number returned by GetCurrentProcess() in the
         * call to SetFrontProcess() (ie. kCurrentProcess can be
         * used) but both functions must be called in order for
         * windows to come to the front.
         */
        Carbon.ProcessSerialNumber psn;
        if (OS.GetCurrentProcess (&psn) is OS.noErr) {
            int pid = OS.getpid ();
            char* ptr = getAppName().UTF8String();
            if (ptr !is null) OS.CPSSetProcessName (&psn, ptr);
            OS.TransformProcessType (&psn, cast(Carbon.ProcessApplicationTransformState)OS.kProcessTransformToForegroundApplication);
            OS.SetFrontProcess (&psn);
            ptr = OS.getenv (ascii ("APP_ICON_" ~ Integer.toString(pid)));
            if (ptr !is null) {
                NSString path = NSString.stringWithUTF8String (ptr);
                NSImage image = cast(NSImage) (new NSImage()).alloc();
                image = image.initByReferencingFile(path);
                dockImage = image;
                application.setApplicationIconImage(image);
            }
        }

        String className = "SWTApplication";
        objc.Class cls;
        if ((cls = OS.objc_lookUpClass (className)) is null) {
            objc.IMP proc2 = cast(objc.IMP) &applicationProc2;
            objc.IMP proc3 = cast(objc.IMP) &applicationProc3;
            objc.IMP proc6 = cast(objc.IMP) &applicationProc6;
            cls = OS.objc_allocateClassPair(OS.class_NSApplication, className, 0);
            OS.class_addMethod(cls, OS.sel_sendEvent_, proc3, "@:@@");

            static if ((void*).sizeof > int.sizeof) // 64bit target
                OS.class_addMethod(cls, OS.sel_nextEventMatchingMask_untilDate_inMode_dequeue_, proc6, "@@:Q@@c");
            else
                OS.class_addMethod(cls, OS.sel_nextEventMatchingMask_untilDate_inMode_dequeue_, proc6, "@@:I@@c");

            OS.class_addMethod(cls, OS.sel_isRunning, proc2, "c@:");
            OS.class_addMethod(cls, OS.sel_finishLaunching, proc2, "v@:");
            OS.objc_registerClassPair(cls);
        }
        applicationClass = OS.object_setClass(application.id, cls);

        className = "SWTApplicationDelegate";
        if (OS.objc_lookUpClass (className) is null) {
            objc.IMP appProc3 = cast(objc.IMP) &applicationProc3;
            if (appProc3 is null) error (DWT.ERROR_NO_MORE_CALLBACKS);
            cls = OS.objc_allocateClassPair(OS.class_NSObject, className, 0);
            OS.class_addMethod(cls, OS.sel_applicationWillFinishLaunching_, appProc3, "v:@");
            OS.class_addMethod(cls, OS.sel_terminate_, appProc3, "v:@");
            OS.class_addMethod(cls, OS.sel_quitRequested_, appProc3, "@:@");
            OS.class_addMethod(cls, OS.sel_orderFrontStandardAboutPanel_, appProc3, "v:@");
            OS.class_addMethod(cls, OS.sel_hideOtherApplications_, appProc3, "v:@");
            OS.class_addMethod(cls, OS.sel_hide_, appProc3, "v:@");
            OS.class_addMethod(cls, OS.sel_unhideAllApplications_, appProc3, "v:@");
            OS.class_addMethod(cls, OS.sel_applicationDidBecomeActive_, appProc3, "v:@");
            OS.class_addMethod(cls, OS.sel_applicationDidResignActive_, appProc3, "v:@");
            OS.objc_registerClassPair(cls);
        }
        if (applicationDelegate is null) {
            applicationDelegate = cast(SWTApplicationDelegate)(new SWTApplicationDelegate()).alloc().init();
            application.setDelegate(applicationDelegate);
        }
    } else {
        isEmbedded = true;
    }
}

void createMainMenu () {
    NSString appName = getAppName();
    NSString emptyStr = NSString.stringWith("");
    NSMenu mainMenu = cast(NSMenu)(new NSMenu()).alloc();
    mainMenu.initWithTitle(emptyStr);

    NSMenuItem menuItem;
    NSMenu appleMenu;
    NSString format = NSString.stringWith("%@ %@"), title;

    NSMenuItem appItem = menuItem = mainMenu.addItemWithTitle(emptyStr, null, emptyStr);
    appleMenu = cast(NSMenu)(new NSMenu()).alloc();
    appleMenu.initWithTitle(emptyStr);
    OS.objc_msgSend(application.id, OS.sel_registerName("setAppleMenu:"), appleMenu.id);

    title = new NSString(OS.objc_msgSend(OS.class_NSString, OS.sel_stringWithFormat_, format.id, NSString.stringWith(DWT.getMessage("About")).id, appName.id));
    menuItem = appleMenu.addItemWithTitle(title, OS.sel_orderFrontStandardAboutPanel_, emptyStr);
    menuItem.setTarget(applicationDelegate);

    appleMenu.addItem(NSMenuItem.separatorItem());

    title = NSString.stringWith(DWT.getMessage("Preferences..."));
    menuItem = appleMenu.addItemWithTitle(title, null, NSString.stringWith(","));

    appleMenu.addItem(NSMenuItem.separatorItem());

    title = NSString.stringWith(DWT.getMessage("Services"));
    menuItem = appleMenu.addItemWithTitle(title, null, emptyStr);
    NSMenu servicesMenu = cast(NSMenu)(new NSMenu()).alloc();
    servicesMenu.initWithTitle(emptyStr);
    appleMenu.setSubmenu(servicesMenu, menuItem);
    servicesMenu.release();
    application.setServicesMenu(servicesMenu);

    appleMenu.addItem(NSMenuItem.separatorItem());

    title = new NSString(OS.objc_msgSend(OS.class_NSString, OS.sel_stringWithFormat_, format.id, NSString.stringWith(DWT.getMessage("Hide")).id, appName.id));
    menuItem = appleMenu.addItemWithTitle(title, OS.sel_hide_, NSString.stringWith("h"));
    menuItem.setTarget(applicationDelegate);

    title = NSString.stringWith(DWT.getMessage("Hide Others"));
    menuItem = appleMenu.addItemWithTitle(title, OS.sel_hideOtherApplications_, NSString.stringWith("h"));
    menuItem.setKeyEquivalentModifierMask(OS.NSCommandKeyMask | OS.NSAlternateKeyMask);
    menuItem.setTarget(applicationDelegate);

    title = NSString.stringWith(DWT.getMessage("Show All"));
    menuItem = appleMenu.addItemWithTitle(title, OS.sel_unhideAllApplications_, emptyStr);
    menuItem.setTarget(applicationDelegate);

    appleMenu.addItem(NSMenuItem.separatorItem());

    title = new NSString(OS.objc_msgSend(OS.class_NSString, OS.sel_stringWithFormat_, format.id, NSString.stringWith(DWT.getMessage("Quit")).id, appName.id));
    menuItem = appleMenu.addItemWithTitle(title, OS.sel_quitRequested_, NSString.stringWith("q"));
    menuItem.setTarget(applicationDelegate);

    mainMenu.setSubmenu(appleMenu, appItem);
    appleMenu.release();
    application.setMainMenu(mainMenu);
    mainMenu.release();
}

objc.id cursorSetProc (objc.id id, objc.SEL sel) {
    if (lockCursor) {
        if (currentControl !is null) {
            Cursor cursor = currentControl.findCursor ();
            if (cursor !is null && cursor.handle.id !is id) return null;
        }
    }
    OS.call (oldCursorSetProc, id, sel);
    return null;
}

private static extern (C) objc.id cursorSetProcFunc (objc.id id, objc.SEL sel)
{
    auto display = cast(Display) GetWidget(id);

    if (!display)
        display = Display.getCurrent();

    assert(display !is null, "Failed to get current display");

    return display.cursorSetProc(id, sel);
}

static void deregister (Display display) {
    synchronized (Device.classinfo) {
        for (int i=0; i<Displays.length; i++) {
            if (display is Displays [i]) Displays [i] = null;
        }
    }
}

/**
 * Destroys the device in the operating system and releases
 * the device's handle.  If the device does not have a handle,
 * this method may do nothing depending on the device.
 * <p>
 * This method is called after <code>release</code>.
 * </p>
 * @see Device#dispose
 * @see #release
 */
protected void destroy () {
    if (this is Default) Default = null;
    deregister (this);
    destroyDisplay ();
}

void destroyDisplay () {
    application = null;
}

/**
 * Causes the <code>run()</code> method of the runnable to
 * be invoked by the user-interface thread just before the
 * receiver is disposed.  Specifying a <code>null</code> runnable
 * is ignored.
 *
 * @param runnable code to run at dispose time.
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void disposeExec (Runnable runnable) {
    checkDevice ();
    if (disposeList is null) disposeList = new Runnable [4];
    for (int i=0; i<disposeList.length; i++) {
        if (disposeList [i] is null) {
            disposeList [i] = runnable;
            return;
        }
    }
    Runnable [] newDisposeList = new Runnable [disposeList.length + 4];
    SimpleType!(Runnable).arraycopy (disposeList, 0, newDisposeList, 0, disposeList.length);
    newDisposeList [disposeList.length] = runnable;
    disposeList = newDisposeList;
}

void error (int code) {
    DWT.error(code);
}

bool filterEvent (Event event) {
    if (filterTable !is null) filterTable.sendEvent (event);
    return false;
}

bool filters (int eventType) {
    if (filterTable is null) return false;
    return filterTable.hooks (eventType);
}

/**
 * Given the operating system handle for a widget, returns
 * the instance of the <code>Widget</code> subclass which
 * represents it in the currently running application, if
 * such exists, or null if no matching widget can be found.
 * <p>
 * <b>IMPORTANT:</b> This method should not be called from
 * application code. The arguments are platform-specific.
 * </p>
 *
 * @param handle the handle for the widget
 * @return the DWT widget that the handle represents
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Widget findWidget (objc.id handle) {
    checkDevice ();
    return getWidget (handle);
}

/**
 * Given the operating system handle for a widget,
 * and widget-specific id, returns the instance of
 * the <code>Widget</code> subclass which represents
 * the handle/id pair in the currently running application,
 * if such exists, or null if no matching widget can be found.
 * <p>
 * <b>IMPORTANT:</b> This method should not be called from
 * application code. The arguments are platform-specific.
 * </p>
 *
 * @param handle the handle for the widget
 * @param id the id for the subwidget (usually an item)
 * @return the DWT widget that the handle/id pair represents
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.1
 */
public Widget findWidget (objc.id handle, int id) {
    checkDevice ();
    return getWidget (handle);
}

/**
 * Given a widget and a widget-specific id, returns the
 * instance of the <code>Widget</code> subclass which represents
 * the widget/id pair in the currently running application,
 * if such exists, or null if no matching widget can be found.
 *
 * @param widget the widget
 * @param id the id for the subwidget (usually an item)
 * @return the DWT subwidget (usually an item) that the widget/id pair represents
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.3
 */
public Widget findWidget (Widget widget, int id) {
    checkDevice ();
    return null;
}

/**
 * Returns the display which the given thread is the
 * user-interface thread for, or null if the given thread
 * is not a user-interface thread for any display.  Specifying
 * <code>null</code> as the thread will return <code>null</code>
 * for the display.
 *
 * @param thread the user-interface thread
 * @return the display for the given thread
 */
public static Display findDisplay (Thread thread) {
    synchronized (Device.classinfo) {
        for (int i=0; i<Displays.length; i++) {
            Display display = Displays [i];
            if (display !is null && display.thread is thread) {
                return display;
            }
        }
        return null;
    }
}

/**
 * Returns the currently active <code>Shell</code>, or null
 * if no shell belonging to the currently running application
 * is active.
 *
 * @return the active shell or null
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Shell getActiveShell () {
    checkDevice ();
    NSWindow window = keyWindow !is null ? keyWindow : application.keyWindow();
    if (window !is null) {
        Widget widget = getWidget(window.contentView());
        if (cast(Shell) widget) {
            return cast(Shell)widget;
        }
    }
    return null;
}

/**
 * Returns a rectangle describing the receiver's size and location. Note that
 * on multi-monitor systems the origin can be negative.
 *
 * @return the bounding rectangle
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Rectangle getBounds () {
    checkDevice ();
    NSArray screens = NSScreen.screens();
    return getBounds (screens);
}

Rectangle getBounds (NSArray screens) {
    NSRect primaryFrame = (new NSScreen(screens.objectAtIndex(0))).frame();
    Carbon.CGFloat minX = Carbon.CGFloat.max, maxX = Carbon.CGFloat.min;
    Carbon.CGFloat minY = Carbon.CGFloat.max, maxY = Carbon.CGFloat.min;
    NSUInteger count = screens.count();
    for (NSUInteger i = 0; i < count; i++) {
        NSScreen screen = new NSScreen(screens.objectAtIndex(i));
        NSRect frame = screen.frame();
        Carbon.CGFloat x1 = frame.x, x2 = frame.x + frame.width;
        Carbon.CGFloat y1 = primaryFrame.height - frame.y, y2 = primaryFrame.height - (frame.y + frame.height);
        if (x1 < minX) minX = x1;
        if (x2 < minX) minX = x2;
        if (x1 > maxX) maxX = x1;
        if (x2 > maxX) maxX = x2;
        if (y1 < minY) minY = y1;
        if (y2 < minY) minY = y2;
        if (y1 > maxY) maxY = y1;
        if (y2 > maxY) maxY = y2;
    }
    return new Rectangle (cast(int)minX, cast(int)minY, cast(int)(maxX - minX), cast(int)(maxY - minY));
}

/**
 * Returns the display which the currently running thread is
 * the user-interface thread for, or null if the currently
 * running thread is not a user-interface thread for any display.
 *
 * @return the current display
 */
public static Display getCurrent () {
    return findDisplay (Thread.getThis ());
}

int getCaretBlinkTime () {
//  checkDevice ();
    return 560;
}

/**
 * Returns a rectangle which describes the area of the
 * receiver which is capable of displaying data.
 *
 * @return the client area
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getBounds
 */
public Rectangle getClientArea () {
    checkDevice ();
    NSArray screens = NSScreen.screens();
    if (screens.count() !is 1) return getBounds (screens);
    NSScreen screen = new NSScreen(screens.objectAtIndex(0));
    NSRect frame = screen.frame();
    NSRect visibleFrame = screen.visibleFrame();
    Carbon.CGFloat y = frame.height - (visibleFrame.y + visibleFrame.height);
    return new Rectangle(cast(int)visibleFrame.x, cast(int)y, cast(int)visibleFrame.width, cast(int)visibleFrame.height);
}

/**
 * Returns the control which the on-screen pointer is currently
 * over top of, or null if it is not currently over one of the
 * controls built by the currently running application.
 *
 * @return the control under the cursor
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Control getCursorControl () {
    checkDevice();
    return findControl(false);
}

/**
 * Returns the location of the on-screen pointer relative
 * to the top left corner of the screen.
 *
 * @return the cursor location
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Point getCursorLocation () {
    checkDevice ();
    NSPoint location = NSEvent.mouseLocation();
    NSRect primaryFrame = getPrimaryFrame();
    return new Point (cast(int) location.x, cast(int) (primaryFrame.height - location.y));
}

/**
 * Returns an array containing the recommended cursor sizes.
 *
 * @return the array of cursor sizes
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.0
 */
public Point [] getCursorSizes () {
    checkDevice ();
    return [new Point (16, 16)];
}

/**
 * Returns the default display. One is created (making the
 * thread that invokes this method its user-interface thread)
 * if it did not already exist.
 *
 * @return the default display
 */
public static Display getDefault () {
    synchronized (Device.classinfo) {
        if (Default is null) Default = new Display ();
        return Default;
    }
}

/**
 * Returns the application defined property of the receiver
 * with the specified name, or null if it has not been set.
 * <p>
 * Applications may have associated arbitrary objects with the
 * receiver in this fashion. If the objects stored in the
 * properties need to be notified when the display is disposed
 * of, it is the application's responsibility to provide a
 * <code>disposeExec()</code> handler which does so.
 * </p>
 *
 * @param key the name of the property
 * @return the value of the property or null if it has not been set
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the key is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #setData(String, Object)
 * @see #disposeExec(Runnable)
 */
public Object getData (String key) {
    checkDevice ();
    // DWT extension: allow null for zero length string
    //if (key is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (keys is null) return null;
    for (int i=0; i<keys.length; i++) {
        if (keys [i].equals (key)) return values [i];
    }
    return null;
}

/**
 * Returns the application defined, display specific data
 * associated with the receiver, or null if it has not been
 * set. The <em>display specific data</em> is a single,
 * unnamed field that is stored with every display.
 * <p>
 * Applications may put arbitrary objects in this field. If
 * the object stored in the display specific data needs to
 * be notified when the display is disposed of, it is the
 * application's responsibility to provide a
 * <code>disposeExec()</code> handler which does so.
 * </p>
 *
 * @return the display specific data
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #setData(Object)
 * @see #disposeExec(Runnable)
 */
public Object getData () {
    checkDevice ();
    return data;
}

/**
 * Returns the button dismissal align_ment, one of <code>LEFT</code> or <code>RIGHT</code>.
 * The button dismissal align_ment is the ordering that should be used when positioning the
 * default dismissal button for a dialog.  For example, in a dialog that contains an OK and
 * CANCEL button, on platforms where the button dismissal align_ment is <code>LEFT</code>, the
 * button ordering should be OK/CANCEL.  When button dismissal align_ment is <code>RIGHT</code>,
 * the button ordering should be CANCEL/OK.
 *
 * @return the button dismissal order
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 2.1
 */
public int getDismissalAlignment () {
    checkDevice ();
    return DWT.RIGHT;
}

/**
 * Returns the longest duration, in milliseconds, between
 * two mouse button clicks that will be considered a
 * <em>double click</em> by the underlying operating system.
 *
 * @return the double click time
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int getDoubleClickTime () {
    checkDevice ();
    return OS.GetDblTime () * 1000 / 60;
}

/**
 * Returns the control which currently has keyboard focus,
 * or null if keyboard events are not currently going to
 * any of the controls built by the currently running
 * application.
 *
 * @return the control under the cursor
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Control getFocusControl () {
    checkDevice ();
    if (focusControl !is null && !focusControl.isDisposed ()) {
        return focusControl;
    }
    NSWindow window = keyWindow !is null ? keyWindow : application.keyWindow();
    return _getFocusControl(window);
}

Control _getFocusControl (NSWindow window) {
    if (window !is null) {
        NSResponder responder = window.firstResponder();
        if (responder !is null && !responder.respondsToSelector(OS.sel_superview)) {
            return null;
        }
        NSView view = new NSView(responder.id);
        if (view !is null) {
            do {
                Widget widget = GetWidget (view.id);
                if (cast(Control)widget) {
                    return cast(Control)widget;
                }
                view = view.superview();
            } while (view !is null);
        }
    }
    return null;
}

/**
 * Returns true when the high contrast mode is enabled.
 * Otherwise, false is returned.
 * <p>
 * Note: This operation is a hint and is not supported on
 * platforms that do not have this concept.
 * </p>
 *
 * @return the high contrast mode
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.0
 */
public bool getHighContrast () {
    checkDevice ();
    return false;
}

/**
 * Returns the maximum allowed depth of icons on this display, in bits per pixel.
 * On some platforms, this may be different than the actual depth of the display.
 *
 * @return the maximum icon depth
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see Device#getDepth
 */
public int getIconDepth () {
    return getDepth ();
}

/**
 * Returns an array containing the recommended icon sizes.
 *
 * @return the array of icon sizes
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see Decorations#setImages(Image[])
 *
 * @since 3.0
 */
public Point [] getIconSizes () {
    checkDevice ();
    return [
            new Point (16, 16), new Point (32, 32),
            new Point (64, 64), new Point (128, 128)];
}

int getLastEventTime () {
    NSEvent event = application.currentEvent();
    return event !is null ? cast(int)(event.timestamp() * 1000) : 0;
}

Menu [] getMenus (Decorations shell) {
    if (menus is null) return new Menu [0];
    int count = 0;
    for (int i = 0; i < menus.length; i++) {
        Menu menu = menus[i];
        if (menu !is null && menu.parent is shell) count++;
    }
    int index = 0;
    Menu[] result = new Menu[count];
    for (int i = 0; i < menus.length; i++) {
        Menu menu = menus[i];
        if (menu !is null && menu.parent is shell) {
            result[index++] = menu;
        }
    }
    return result;
}

int getMessageCount () {
    return synchronizer.getMessageCount ();
}

/**
 * Returns an array of monitors attached to the device.
 *
 * @return the array of monitors
 *
 * @since 3.0
 */
public dwt.widgets.Monitor.Monitor [] getMonitors () {
    checkDevice ();
    NSArray screens = NSScreen.screens();
    NSRect primaryFrame = (new NSScreen(screens.objectAtIndex(0))).frame();
    NSUInteger count = screens.count();
    dwt.widgets.Monitor.Monitor [] monitors = new dwt.widgets.Monitor.Monitor [count];
    for (NSUInteger i=0; i<count; i++) {
        dwt.widgets.Monitor.Monitor monitor = new dwt.widgets.Monitor.Monitor ();
        NSScreen screen = new NSScreen(screens.objectAtIndex(i));
        NSRect frame = screen.frame();
        monitor.x = cast(int)frame.x;
        monitor.y = cast(int)(primaryFrame.height - (frame.y + frame.height));
        monitor.width = cast(int)frame.width;
        monitor.height = cast(int)frame.height;
        NSRect visibleFrame = screen.visibleFrame();
        monitor.clientX = cast(int)visibleFrame.x;
        monitor.clientY = cast(int)(primaryFrame.height - (visibleFrame.y + visibleFrame.height));
        monitor.clientWidth = cast(int)visibleFrame.width;
        monitor.clientHeight = cast(int)visibleFrame.height;
        monitors [i] = monitor;
    }
    return monitors;
}

NSRect getPrimaryFrame () {
    NSArray screens = NSScreen.screens();
    return (new NSScreen(screens.objectAtIndex(0))).frame();
}

/**
 * Returns the primary monitor for that device.
 *
 * @return the primary monitor
 *
 * @since 3.0
 */
public dwt.widgets.Monitor.Monitor getPrimaryMonitor () {
    checkDevice ();
    dwt.widgets.Monitor.Monitor monitor = new dwt.widgets.Monitor.Monitor ();
    NSArray screens = NSScreen.screens();
    NSScreen screen = new NSScreen(screens.objectAtIndex(0));
    NSRect frame = screen.frame();
    monitor.x = cast(int)frame.x;
    monitor.y = cast(int)(frame.height - (frame.y + frame.height));
    monitor.width = cast(int)frame.width;
    monitor.height = cast(int)frame.height;
    NSRect visibleFrame = screen.visibleFrame();
    monitor.clientX = cast(int)visibleFrame.x;
    monitor.clientY = cast(int)(frame.height - (visibleFrame.y + visibleFrame.height));
    monitor.clientWidth = cast(int)visibleFrame.width;
    monitor.clientHeight = cast(int)visibleFrame.height;
    return monitor;
}

/**
 * Returns a (possibly empty) array containing all shells which have
 * not been disposed and have the receiver as their display.
 *
 * @return the receiver's shells
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Shell [] getShells () {
    checkDevice ();
    NSArray windows = application.windows();
    int index = 0;
    Shell [] result = new Shell [windows.count()];
    for (int i = 0; i < result.length; i++) {
        NSWindow window = new NSWindow(windows.objectAtIndex(i));
        Widget widget = getWidget(window.contentView());
        if (cast(Shell) widget) {
            result[index++] = cast(Shell)widget;
        }
    }
    if (index is result.length) return result;
    Shell [] newResult = new Shell [index];
    System.arraycopy (result, 0, newResult, 0, index);
    return newResult;
}

static bool getSheetEnabled () {
    return !"false".equals(System.getProperty("org.eclipse.swt.sheet"));
}

/**
 * Gets the synchronizer used by the display.
 *
 * @return the receiver's synchronizer
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.4
 */
public Synchronizer getSynchronizer () {
    checkDevice ();
    return synchronizer;
}

/**
 * Returns the thread that has invoked <code>syncExec</code>
 * or null if no such runnable is currently being invoked by
 * the user-interface thread.
 * <p>
 * Note: If a runnable invoked by asyncExec is currently
 * running, this method will return null.
 * </p>
 *
 * @return the receiver's sync-interface thread
 *
 * @exception DWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Thread getSyncThread () {
    synchronized (Device.classinfo) {
        if (isDisposed ()) error (DWT.ERROR_DEVICE_DISPOSED);
        return synchronizer.syncThread;
    }
}

/**
 * Returns the matching standard color for the given
 * constant, which should be one of the color constants
 * specified in class <code>DWT</code>. Any value other
 * than one of the DWT color constants which is passed
 * in will result in the color black. This color should
 * not be free'd because it was allocated by the system,
 * not the application.
 *
 * @param id the color constant
 * @return the matching color
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see DWT
 */
public Color getSystemColor (int id) {
    checkDevice ();
    Color color = getWidgetColor (id);
    if (color !is null) return color;
    return super.getSystemColor (id);
}

Color getWidgetColor (int id) {
    if (0 <= id && id < colors.length && colors [id] !is null) {
        return Color.cocoa_new (this, colors [id]);
    }
    return null;
}

Carbon.CGFloat [] getWidgetColorRGB (int id) {
    NSColor color = null;
    switch (id) {
        case DWT.COLOR_INFO_FOREGROUND: color = NSColor.blackColor (); break;
        case DWT.COLOR_INFO_BACKGROUND: return cast(Carbon.CGFloat[]) [0xFF / 255f, 0xFF / 255f, 0xE1 / 255f, 1];
        case DWT.COLOR_TITLE_FOREGROUND: color = NSColor.windowFrameTextColor(); break;
        case DWT.COLOR_TITLE_BACKGROUND: color = NSColor.alternateSelectedControlColor(); break;
        case DWT.COLOR_TITLE_BACKGROUND_GRADIENT: color = NSColor.selectedControlColor(); break;
        case DWT.COLOR_TITLE_INACTIVE_FOREGROUND: color = NSColor.disabledControlTextColor();  break;
        case DWT.COLOR_TITLE_INACTIVE_BACKGROUND: color = NSColor.secondarySelectedControlColor(); break;
        case DWT.COLOR_TITLE_INACTIVE_BACKGROUND_GRADIENT: color = NSColor.secondarySelectedControlColor(); break;
        case DWT.COLOR_WIDGET_DARK_SHADOW: color = NSColor.controlDarkShadowColor(); break;
        case DWT.COLOR_WIDGET_NORMAL_SHADOW: color = NSColor.controlShadowColor(); break;
        case DWT.COLOR_WIDGET_LIGHT_SHADOW: color = NSColor.controlHighlightColor(); break;
        case DWT.COLOR_WIDGET_HIGHLIGHT_SHADOW: color = NSColor.controlLightHighlightColor(); break;
        case DWT.COLOR_WIDGET_BACKGROUND: color = NSColor.controlHighlightColor(); break;
        case DWT.COLOR_WIDGET_FOREGROUND: color = NSColor.controlTextColor(); break;
        case DWT.COLOR_WIDGET_BORDER: color = NSColor.blackColor (); break;
        case DWT.COLOR_LIST_FOREGROUND: color = NSColor.textColor(); break;
        case DWT.COLOR_LIST_BACKGROUND: color = NSColor.textBackgroundColor(); break;
        case DWT.COLOR_LIST_SELECTION_TEXT: color = NSColor.selectedTextColor(); break;
        case DWT.COLOR_LIST_SELECTION: color = NSColor.selectedTextBackgroundColor(); break;
    }
    return getWidgetColorRGB (color);
}

Carbon.CGFloat [] getWidgetColorRGB (NSColor color) {
    if (color is null) return null;
    color = color.colorUsingColorSpace(NSColorSpace.deviceRGBColorSpace());
    if (color is null) return null;
    Carbon.CGFloat[] components = new Carbon.CGFloat[color.numberOfComponents()];
    color.getComponents(components.ptr);
    return [components[0], components[1], components[2], components[3]];
}

/**
 * Returns the matching standard platform cursor for the given
 * constant, which should be one of the cursor constants
 * specified in class <code>DWT</code>. This cursor should
 * not be free'd because it was allocated by the system,
 * not the application.  A value of <code>null</code> will
 * be returned if the supplied constant is not an DWT cursor
 * constant.
 *
 * @param id the DWT cursor constant
 * @return the corresponding cursor or <code>null</code>
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see DWT#CURSOR_ARROW
 * @see DWT#CURSOR_WAIT
 * @see DWT#CURSOR_CROSS
 * @see DWT#CURSOR_APPSTARTING
 * @see DWT#CURSOR_HELP
 * @see DWT#CURSOR_SIZEALL
 * @see DWT#CURSOR_SIZENESW
 * @see DWT#CURSOR_SIZENS
 * @see DWT#CURSOR_SIZENWSE
 * @see DWT#CURSOR_SIZEWE
 * @see DWT#CURSOR_SIZEN
 * @see DWT#CURSOR_SIZES
 * @see DWT#CURSOR_SIZEE
 * @see DWT#CURSOR_SIZEW
 * @see DWT#CURSOR_SIZENE
 * @see DWT#CURSOR_SIZESE
 * @see DWT#CURSOR_SIZESW
 * @see DWT#CURSOR_SIZENW
 * @see DWT#CURSOR_UPARROW
 * @see DWT#CURSOR_IBEAM
 * @see DWT#CURSOR_NO
 * @see DWT#CURSOR_HAND
 *
 * @since 3.0
 */
public Cursor getSystemCursor (int id) {
    checkDevice ();
    if (!(0 <= id && id < cursors.length)) return null;
    if (cursors [id] is null) {
        cursors [id] = new Cursor (this, id);
    }
    return cursors [id];
}

/**
 * Returns the matching standard platform image for the given
 * constant, which should be one of the icon constants
 * specified in class <code>DWT</code>. This image should
 * not be free'd because it was allocated by the system,
 * not the application.  A value of <code>null</code> will
 * be returned either if the supplied constant is not an
 * DWT icon constant or if the platform does not define an
 * image that corresponds to the constant.
 *
 * @param id the DWT icon constant
 * @return the corresponding image or <code>null</code>
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see DWT#ICON_ERROR
 * @see DWT#ICON_INFORMATION
 * @see DWT#ICON_QUESTION
 * @see DWT#ICON_WARNING
 * @see DWT#ICON_WORKING
 *
 * @since 3.0
 */
public Image getSystemImage (int id) {
    checkDevice ();
    switch(id) {
        case DWT.ICON_ERROR: {
            if (errorImage !is null) return errorImage;
            NSImage nsImage = NSWorkspace.sharedWorkspace ().iconForFileType (new NSString (OS.NSFileTypeForHFSTypeCode (OS.kAlertStopIcon)));
            if (nsImage is null) return null;
            nsImage.retain ();
            return errorImage = Image.cocoa_new (this, DWT.ICON, nsImage);
        }
        case DWT.ICON_INFORMATION:
        case DWT.ICON_QUESTION:
        case DWT.ICON_WORKING: {
            if (infoImage !is null) return infoImage;
            NSImage nsImage = NSWorkspace.sharedWorkspace ().iconForFileType (new NSString (OS.NSFileTypeForHFSTypeCode (OS.kAlertNoteIcon)));
            if (nsImage is null) return null;
            nsImage.retain ();
            return infoImage = Image.cocoa_new (this, DWT.ICON, nsImage);
        }
        case DWT.ICON_WARNING: {
            if (warningImage !is null) return warningImage;
            NSImage nsImage = NSWorkspace.sharedWorkspace ().iconForFileType (new NSString (OS.NSFileTypeForHFSTypeCode (OS.kAlertCautionIcon)));
            if (nsImage is null) return null;
            nsImage.retain ();
            return warningImage = Image.cocoa_new (this, DWT.ICON, nsImage);
        }

        default:
    }
    return null;
}

/**
 * Returns the single instance of the system tray or null
 * when there is no system tray available for the platform.
 *
 * @return the system tray or <code>null</code>
 *
 * @exception DWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.0
 */
public Tray getSystemTray () {
    checkDevice ();
    if (tray !is null) return tray;
    return tray = new Tray (this, DWT.NONE);
}

/**
 * Returns the user-interface thread for the receiver.
 *
 * @return the receiver's user-interface thread
 *
 * @exception DWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Thread getThread () {
    synchronized (Device.classinfo) {
        if (isDisposed ()) error (DWT.ERROR_DEVICE_DISPOSED);
        return thread;
    }
}

int getToolTipTime () {
    checkDevice ();
    //TODO get OS value (NSTooltipManager?)
    return 560;
}

Widget getWidget (objc.id id) {
    return GetWidget (id);
}

static Widget GetWidget (objc.id id) {
    if (id is null) return null;
    void* jniRef;
    OS.object_getInstanceVariable(id, SWT_OBJECT, jniRef);
    if (jniRef is null) return null;
    return cast(Widget)OS.JNIGetObject(jniRef);
}

Widget getWidget (NSView view) {
    if (view is null) return null;
    return getWidget(view.id);
}

bool hasDefaultButton () {
    NSArray windows = application.windows();
    NSUInteger count = windows.count();
    for (int i = 0; i < count; i++) {
        NSWindow window  = new NSWindow(windows.objectAtIndex(i));
        if (window.defaultButtonCell() !is null) {
            return true;
        }
    }
    return false;
}

/**
 * Initializes any internal resources needed by the
 * device.
 * <p>
 * This method is called after <code>create</code>.
 * </p>
 *
 * @see #create
 */
protected void init_ () {
    super.init_ ();
    initClasses ();
    initColors ();
    initFonts ();

    if (!isEmbedded) {
        /*
         * Feature in Cocoa:  NSApplication.finishLaunching() adds an apple menu to the menu bar that isn't accessible via NSMenu.
         * If Display objects are created and disposed of multiple times in a single process, another apple menu is added to the menu bar.
         * It must be called or the dock icon will continue to bounce. So, it should only be called once per process, not just once per
         * creation of a Display.  Use a static so creation of additional Display objects won't affect the menu bar.
         */
        if (!Display.launched) {
            application.finishLaunching();
            Display.launched = true;

            /* TODO: only add the shutdown hook once */
            runShutdownHook = true;
        }
    }

    Carbon.CFRunLoopObserverContext context;
    context.info = cast(void*) this;

    Carbon.CFRunLoopObserverCallBack observerProc = &observerProcFunc;
    Carbon.CFOptionFlags activities = OS.kCFRunLoopBeforeWaiting;
    runLoopObserver = OS.CFRunLoopObserverCreate (null, activities, true, 0, observerProc, &context);
    if (runLoopObserver is null) error (DWT.ERROR_NO_HANDLES);
    OS.CFRunLoopAddObserver (OS.CFRunLoopGetCurrent (), runLoopObserver, cast(Carbon.CFStringRef)OS.kCFRunLoopCommonModes_);

    objc.IMP cursorSetProc = cast(objc.IMP) &cursorSetProcFunc;
    objc.Method method = OS.class_getInstanceMethod(OS.class_NSCursor, OS.sel_set);
    if (method !is null) oldCursorSetProc = OS.method_setImplementation(method, cursorSetProc);

    settingsDelegate = cast(SWTWindowDelegate)(new SWTWindowDelegate()).alloc().init();
    NSNotificationCenter defaultCenter = NSNotificationCenter.defaultCenter();
    defaultCenter.addObserver(settingsDelegate, OS.sel_systemSettingsChanged_, OS.NSSystemColorsDidChangeNotification, null);
    defaultCenter.addObserver(settingsDelegate, OS.sel_systemSettingsChanged_, OS.NSApplicationDidChangeScreenParametersNotification, null);

    NSTextView textView = cast(NSTextView)(new NSTextView()).alloc();
    textView.init ();
    markedAttributes = textView.markedTextAttributes ();
    markedAttributes.retain ();
    textView.release ();

    isPainting = cast(NSMutableArray)(new NSMutableArray()).alloc();
    isPainting = isPainting.initWithCapacity(12);
}

static ~this ()
{
    if (runShutdownHook)
        NSApplication.sharedApplication().terminate(null);
}

void addEventMethods (objc.Class cls, objc.IMP proc2, objc.IMP proc3, objc.IMP drawRectProc, objc.IMP hitTestProc, objc.IMP needsDisplayInRectProc) {
    if (proc3 !is null) {
        OS.class_addMethod(cls, OS.sel_mouseDown_, proc3, "v@:@");
        OS.class_addMethod(cls, OS.sel_mouseUp_, proc3, "v@:@");
        OS.class_addMethod(cls, OS.sel_scrollWheel_, proc3, "v@:@");
        OS.class_addMethod(cls, OS.sel_rightMouseDown_, proc3, "v@:@");
        OS.class_addMethod(cls, OS.sel_rightMouseUp_, proc3, "v@:@");
        OS.class_addMethod(cls, OS.sel_rightMouseDragged_, proc3, "v@:@");
        OS.class_addMethod(cls, OS.sel_otherMouseDown_, proc3, "v@:@");
        OS.class_addMethod(cls, OS.sel_otherMouseUp_, proc3, "v@:@");
        OS.class_addMethod(cls, OS.sel_otherMouseDragged_, proc3, "v@:@");
        OS.class_addMethod(cls, OS.sel_mouseDragged_, proc3, "v@:@");
        OS.class_addMethod(cls, OS.sel_mouseMoved_, proc3, "v@:@");
        OS.class_addMethod(cls, OS.sel_mouseEntered_, proc3, "v@:@");
        OS.class_addMethod(cls, OS.sel_mouseExited_, proc3, "v@:@");
        OS.class_addMethod(cls, OS.sel_menuForEvent_, proc3, "v@:@");
        OS.class_addMethod(cls, OS.sel_keyDown_, proc3, "v@:@");
        OS.class_addMethod(cls, OS.sel_keyUp_, proc3, "v@:@");
        OS.class_addMethod(cls, OS.sel_flagsChanged_, proc3, "v@:@");
        OS.class_addMethod(cls, OS.sel_cursorUpdate_, proc3, "v@:@");
        OS.class_addMethod(cls, OS.sel_setNeedsDisplay_, proc3, "v@:c");
        OS.class_addMethod(cls, OS.sel_shouldDelayWindowOrderingForEvent_, proc3, "c@:@");
        OS.class_addMethod(cls, OS.sel_acceptsFirstMouse_, proc3, "v@:@");
    }
    if (proc2 !is null) {
        OS.class_addMethod(cls, OS.sel_resignFirstResponder, proc2, "c@:");
        OS.class_addMethod(cls, OS.sel_becomeFirstResponder, proc2, "c@:");
        OS.class_addMethod(cls, OS.sel_resetCursorRects, proc2, "v@:");
        OS.class_addMethod(cls, OS.sel_updateTrackingAreas, proc2, "v@:");
    }
    if (needsDisplayInRectProc !is null) {
        OS.class_addMethod!("v@:{NSRect}")(cls, OS.sel_setNeedsDisplayInRect_, needsDisplayInRectProc);
    }
    if (drawRectProc !is null) {
        OS.class_addMethod!("v@:{NSRect}")(cls, OS.sel_drawRect_, drawRectProc);
    }
    if (hitTestProc !is null) {
        OS.class_addMethod!("@@:{NSPoint}")(cls, OS.sel_hitTest_, hitTestProc);
    }
}

void addFrameMethods(objc.Class cls, objc.IMP setFrameOriginProc, objc.IMP setFrameSizeProc) {
    OS.class_addMethod!("v@:{NSPoint}")(cls, OS.sel_setFrameOrigin_, setFrameOriginProc);
   	OS.class_addMethod!("v@:{NSSize}")(cls, OS.sel_setFrameSize_, setFrameSizeProc);
}

void addAccessibilityMethods(objc.Class cls, objc.IMP proc2, objc.IMP proc3, objc.IMP proc4, objc.IMP accessibilityHitTestProc) {
    OS.class_addMethod(cls, OS.sel_accessibilityActionNames, proc2, "@@:");
    OS.class_addMethod(cls, OS.sel_accessibilityAttributeNames, proc2, "@@:");
    OS.class_addMethod(cls, OS.sel_accessibilityParameterizedAttributeNames, proc2, "@@:");
    OS.class_addMethod(cls, OS.sel_accessibilityFocusedUIElement, proc2, "@@:");
    OS.class_addMethod(cls, OS.sel_accessibilityIsIgnored, proc2, "c@:");
    OS.class_addMethod(cls, OS.sel_accessibilityAttributeValue_, proc3, "@@:@");
    OS.class_addMethod!("@@:{NSPoint}")(cls, OS.sel_accessibilityHitTest_, accessibilityHitTestProc);
    OS.class_addMethod(cls, OS.sel_accessibilityAttributeValue_forParameter_, proc4, "@@:@@");
    OS.class_addMethod(cls, OS.sel_accessibilityPerformAction_, proc3, "v@:@");
    OS.class_addMethod(cls, OS.sel_accessibilityActionDescription_, proc3, "@@:@");
}

objc.Class registerCellSubclass(objc.Class cellClass, size_t size, ubyte align_, char[] types) {
    String cellClassName = OS.class_getName(cellClass);
    objc.Class cls = OS.objc_allocateClassPair(cellClass, "SWTAccessible" ~ cellClassName, 0);
    OS.class_addIvar(cls, SWT_OBJECT, size, align_, types);
    OS.objc_registerClassPair(cls);
    return cls;
}

void initClasses () {
    if (OS.objc_lookUpClass ("SWTView") !is null) return;

    Class clazz = this.classinfo;
    objc.IMP dialogProc3 = cast(objc.IMP) &dialogProc3;
    objc.IMP dialogProc4 = cast(objc.IMP) &dialogProc4;
    objc.IMP dialogProc5 = cast(objc.IMP) &dialogProc5;
    objc.IMP proc3 = cast(objc.IMP) &windowProc3;
    objc.IMP proc2 = cast(objc.IMP) &windowProc2;
    objc.IMP proc4 = cast(objc.IMP) &windowProc4;
    objc.IMP proc5 = cast(objc.IMP) &windowProc5;
    objc.IMP proc6 = cast(objc.IMP) &windowProc6;
    objc.IMP fieldEditorProc3 = cast(objc.IMP) &fieldEditorProc3;
    objc.IMP fieldEditorProc4 = cast(objc.IMP) &fieldEditorProc4;

    objc.IMP isFlippedProc = cast(objc.IMP) &isFlipped_CALLBACK;
    objc.IMP drawRectProc = cast(objc.IMP) &CALLBACK_drawRect_;
    objc.IMP drawInteriorWithFrameInViewProc = cast(objc.IMP) &CALLBACK_drawInteriorWithFrame_inView_;
    objc.IMP drawWithExpansionFrameProc = cast(objc.IMP) &CALLBACK_drawWithExpansionFrame_inView_;
    objc.IMP imageRectForBoundsProc = cast(objc.IMP) &CALLBACK_imageRectForBounds_;
    objc.IMP titleRectForBoundsProc = cast(objc.IMP) &CALLBACK_titleRectForBounds_;
    objc.IMP hitTestForEvent_inRect_ofViewProc = cast(objc.IMP) &CALLBACK_hitTestForEvent_inRect_ofView_;
    objc.IMP cellSizeProc = cast(objc.IMP) &CALLBACK_cellSize;
    objc.IMP drawImageWithFrameInViewProc = cast(objc.IMP) &CALLBACK_drawImage_withFrame_inView_;
    objc.IMP setFrameOriginProc = cast(objc.IMP) &CALLBACK_setFrameOrigin_;
    objc.IMP setFrameSizeProc = cast(objc.IMP) &CALLBACK_setFrameSize_;
    objc.IMP hitTestProc = cast(objc.IMP) &CALLBACK_hitTest_;
    objc.IMP markedRangeProc = cast(objc.IMP) &CALLBACK_markedRange;
    objc.IMP selectedRangeProc = cast(objc.IMP) &CALLBACK_selectedRange;
    objc.IMP highlightSelectionInClipRectProc = cast(objc.IMP) &CALLBACK_highlightSelectionInClipRect_;
    objc.IMP setMarkedText_selectedRangeProc = cast(objc.IMP) &CALLBACK_setMarkedText_selectedRange_;
    objc.IMP attributedSubstringFromRangeProc = cast(objc.IMP) &CALLBACK_attributedSubstringFromRange_;
    objc.IMP characterIndexForPointProc = cast(objc.IMP) &CALLBACK_characterIndexForPoint_;
    objc.IMP firstRectForCharacterRangeProc = cast(objc.IMP) &CALLBACK_firstRectForCharacterRange_;
    objc.IMP textWillChangeSelectionProc = cast(objc.IMP) &CALLBACK_textView_willChangeSelectionFromCharacterRange_toCharacterRange_;
    objc.IMP accessibilityHitTestProc = cast(objc.IMP) &CALLBACK_accessibilityHitTest_;
    objc.IMP shouldChangeTextInRange_replacementString_Proc = cast(objc.IMP) &CALLBACK_shouldChangeTextInRange_replacementString_;
    objc.IMP shouldChangeTextInRange_replacementString_fieldEditorProc = shouldChangeTextInRange_replacementString_Proc;
    objc.IMP view_stringForToolTip_point_userDataProc = cast(objc.IMP) &CALLBACK_view_stringForToolTip_point_userData_;
    objc.IMP canDragRowsWithIndexes_atPoint_Proc = cast(objc.IMP) &CALLBACK_canDragRowsWithIndexes_atPoint_;
    objc.IMP setNeedsDisplayInRectProc = cast(objc.IMP) &CALLBACK_setNeedsDisplayInRect_;
    objc.IMP expansionFrameWithFrameProc = cast(objc.IMP) &CALLBACK_expansionFrameWithFrame_inView_;

    String types = "^v";
    size_t size = C.PTR_SIZEOF;
    ubyte align_ = cast(ubyte) Math.log2((void*).sizeof);

    String className;
    objc.Class cls;

    className = "SWTBox";
    cls = OS.objc_allocateClassPair(OS.class_NSBox, className, 0);
    OS.class_addIvar(cls, SWT_OBJECT, size, align_, types);
    addEventMethods(cls, proc2, proc3, drawRectProc, hitTestProc, setNeedsDisplayInRectProc);
    addFrameMethods(cls, setFrameOriginProc, setFrameSizeProc);
    addAccessibilityMethods(cls, proc2, proc3, proc4, accessibilityHitTestProc);
    OS.objc_registerClassPair(cls);

    className = "SWTButton";
    cls = OS.objc_allocateClassPair(OS.class_NSButton, className, 0);
    OS.class_addIvar(cls, SWT_OBJECT, size, align_, types);
    OS.class_addMethod(cls, OS.sel_sendSelection, proc2, "@:");
    addEventMethods(cls, proc2, proc3, drawRectProc, hitTestProc, setNeedsDisplayInRectProc);
    addFrameMethods(cls, setFrameOriginProc, setFrameSizeProc);
    OS.objc_registerClassPair(cls);

    cls = registerCellSubclass(NSButton.cellClass(), size, align_, types);
    addAccessibilityMethods(cls, proc2, proc3, proc4, accessibilityHitTestProc);
    OS.class_addMethod(cls, OS.sel_nextState, proc2, "@:");
    NSButton.setCellClass(cls);

    className = "SWTButtonCell";
    cls = OS.objc_allocateClassPair (OS.class_NSButtonCell, className, 0);
    OS.class_addIvar (cls, SWT_OBJECT, size, align_, types);
    addAccessibilityMethods(cls, proc2, proc3, proc4, accessibilityHitTestProc);
    OS.class_addMethod!("v@:@{NSRect}@")(cls, OS.sel_drawImage_withFrame_inView_, drawImageWithFrameInViewProc);
    OS.class_addMethod(cls, OS.sel_cellSize, cellSizeProc, "@:");
    OS.class_addMethod!("v@:{NSRect}@")(cls, OS.sel_drawInteriorWithFrame_inView_, drawInteriorWithFrameInViewProc);
    OS.class_addMethod!("{NSRect}@:{NSRect}")(cls, OS.sel_titleRectForBounds_, titleRectForBoundsProc);
    OS.objc_registerClassPair (cls);

    className = "SWTCanvasView";
    cls = OS.objc_allocateClassPair(OS.class_NSView, className, 0);
    OS.class_addIvar(cls, SWT_OBJECT, size, align_, types);
    //NSTextInput protocol
    OS.class_addProtocol(cls, OS.objc_getProtocol("NSTextInput"));
    OS.class_addMethod(cls, OS.sel_hasMarkedText, proc2, "c@:");
    OS.class_addMethod!("{NSRange}@:")(cls, OS.sel_markedRange, markedRangeProc);
    OS.class_addMethod!("{NSRange}@:")(cls, OS.sel_selectedRange, selectedRangeProc);
    OS.class_addMethod!("v@:@{NSRange}")(cls, OS.sel_setMarkedText_selectedRange_, setMarkedText_selectedRangeProc);
    OS.class_addMethod(cls, OS.sel_unmarkText, proc2, "v@:");
    OS.class_addMethod(cls, OS.sel_validAttributesForMarkedText, proc2, "@@:");
    OS.class_addMethod!("@@:{NSRange}")(cls, OS.sel_attributedSubstringFromRange_, attributedSubstringFromRangeProc);
    OS.class_addMethod(cls, OS.sel_insertText_, proc3, "v@:@");

    static if ((void*).sizeof > int.sizeof) // 64bit target
        OS.class_addMethod!("Q@:{NSPoint}")(cls, OS.sel_characterIndexForPoint_, characterIndexForPointProc);

    else
        OS.class_addMethod!("I@:{NSPoint}")(cls, OS.sel_characterIndexForPoint_, characterIndexForPointProc);

    OS.class_addMethod!("{NSRect}@:{NSRange}")(cls, OS.sel_firstRectForCharacterRange_, firstRectForCharacterRangeProc);
    OS.class_addMethod(cls, OS.sel_doCommandBySelector_, proc3, "v@::");
    //NSTextInput protocol end
    OS.class_addMethod(cls, OS.sel_canBecomeKeyView, proc2, "c@:");
    OS.class_addMethod(cls, OS.sel_isFlipped, isFlippedProc, "c@:");
    OS.class_addMethod(cls, OS.sel_acceptsFirstResponder, proc2, "c@:");
    OS.class_addMethod(cls, OS.sel_isOpaque, proc2, "c@:");
    OS.class_addMethod(cls, OS.sel_updateOpenGLContext_, proc3, "@:@");
    addEventMethods(cls, proc2, proc3, drawRectProc, hitTestProc, setNeedsDisplayInRectProc);
    addFrameMethods(cls, setFrameOriginProc, setFrameSizeProc);
    addAccessibilityMethods(cls, proc2, proc3, proc4, accessibilityHitTestProc);
    OS.objc_registerClassPair(cls);

    className = "SWTComboBox";
    cls = OS.objc_allocateClassPair(OS.class_NSComboBox, className, 0);
    OS.class_addIvar(cls, SWT_OBJECT, size, align_, types);
    OS.class_addMethod(cls, OS.sel_sendSelection, proc2, "@:");
    OS.class_addMethod(cls, OS.sel_textDidChange_, proc3, "v@:@");
    OS.class_addMethod(cls, OS.sel_textViewDidChangeSelection_, proc3, "@:@");
    OS.class_addMethod!("@:@{NSRange}{NSRange}")(cls, OS.sel_textView_willChangeSelectionFromCharacterRange_toCharacterRange_, textWillChangeSelectionProc);
    addEventMethods(cls, proc2, proc3, drawRectProc, hitTestProc, setNeedsDisplayInRectProc);
    addFrameMethods(cls, setFrameOriginProc, setFrameSizeProc);
    addAccessibilityMethods(cls, proc2, proc3, proc4, accessibilityHitTestProc);
    OS.objc_registerClassPair(cls);

    cls = registerCellSubclass(NSComboBox.cellClass(), size, align_, types);
    addAccessibilityMethods(cls, proc2, proc3, proc4, accessibilityHitTestProc);
    NSComboBox.setCellClass(cls);

    className = "SWTDatePicker";
    cls = OS.objc_allocateClassPair(OS.class_NSDatePicker, className, 0);
    OS.class_addIvar(cls, SWT_OBJECT, size, align_, types);
    OS.class_addMethod(cls, OS.sel_isFlipped, proc2, "c@:");
    OS.class_addMethod(cls, OS.sel_sendSelection, proc2, "@:");
    addEventMethods(cls, proc2, proc3, drawRectProc, hitTestProc, setNeedsDisplayInRectProc);
    addFrameMethods(cls, setFrameOriginProc, setFrameSizeProc);
    addAccessibilityMethods(cls, proc2, proc3, proc4, accessibilityHitTestProc);
    OS.objc_registerClassPair(cls);

    className = "SWTEditorView";
    cls = OS.objc_allocateClassPair(OS.class_NSTextView, className, 0);
    //TODO hitTestProc and drawRectProc should be set Control.setRegion()?
    addEventMethods(cls, null, fieldEditorProc3, null, null, null);
    OS.class_addMethod(cls, OS.sel_insertText_, fieldEditorProc3, "v@:@");
    OS.class_addMethod(cls, OS.sel_doCommandBySelector_, fieldEditorProc3, "v@::");
    OS.class_addMethod!("c@:{NSRange}@")(cls, OS.sel_shouldChangeTextInRange_replacementString_, shouldChangeTextInRange_replacementString_fieldEditorProc);
    OS.objc_registerClassPair(cls);

    className = "SWTImageView";
    cls = OS.objc_allocateClassPair(OS.class_NSImageView, className, 0);
    OS.class_addIvar(cls, SWT_OBJECT, size, align_, types);
    OS.class_addMethod(cls, OS.sel_isFlipped, isFlippedProc, "c@:");
    addEventMethods(cls, proc2, proc3, drawRectProc, hitTestProc, setNeedsDisplayInRectProc);
    addFrameMethods(cls, setFrameOriginProc, setFrameSizeProc);
    addAccessibilityMethods(cls, proc2, proc3, proc4, accessibilityHitTestProc);
    OS.objc_registerClassPair(cls);

    cls = registerCellSubclass(NSImageView.cellClass(), size, align_, types);
    addAccessibilityMethods(cls, proc2, proc3, proc4, accessibilityHitTestProc);
    NSImageView.setCellClass(cls);

    className = "SWTImageTextCell";
    cls = OS.objc_allocateClassPair (OS.class_NSTextFieldCell, className, 0);
    OS.class_addIvar (cls, SWT_OBJECT, size, align_, types);
    OS.class_addIvar (cls, SWT_IMAGE, size, align_, types);
    OS.class_addIvar (cls, SWT_ROW, size, align_, types);
    OS.class_addIvar (cls, SWT_COLUMN, size, align_, types);
    OS.class_addMethod!("v@:{NSRect}@")(cls, OS.sel_drawInteriorWithFrame_inView_, drawInteriorWithFrameInViewProc);
    OS.class_addMethod!("v@:{NSRect}@")(cls, OS.sel_drawWithExpansionFrame_inView_, drawWithExpansionFrameProc);
    OS.class_addMethod!("{NSRect}@:{NSRect}")(cls, OS.sel_imageRectForBounds_, imageRectForBoundsProc);
    OS.class_addMethod!("{NSRect}@:{NSRect}")(cls, OS.sel_titleRectForBounds_, titleRectForBoundsProc);

    static if ((void*).sizeof > int.sizeof) // 64bit target
        OS.class_addMethod!("Q@:@{NSRect}@")(cls, OS.sel_hitTestForEvent_inRect_ofView_, hitTestForEvent_inRect_ofViewProc);

    else
        OS.class_addMethod!("I@:@{NSRect}@")(cls, OS.sel_hitTestForEvent_inRect_ofView_, hitTestForEvent_inRect_ofViewProc);

    OS.class_addMethod!("{NSSize}@:")(cls, OS.sel_cellSize, cellSizeProc);
    OS.class_addMethod (cls, OS.sel_image, proc2, "@@:");
    OS.class_addMethod (cls, OS.sel_setImage_, proc3, "v@:@");
    OS.class_addMethod!("{NSRect}@:{NSRect}@")(cls, OS.sel_expansionFrameWithFrame_inView_, expansionFrameWithFrameProc);
    OS.objc_registerClassPair (cls);

    className = "SWTMenu";
    cls = OS.objc_allocateClassPair(OS.class_NSMenu, className, 0);
    OS.class_addIvar (cls, SWT_OBJECT, size, align_, types);
    OS.class_addMethod(cls, OS.sel_menuWillOpen_, proc3, "c@:@");
    OS.class_addMethod(cls, OS.sel_menuDidClose_, proc3, "c@:@");
    OS.class_addMethod(cls, OS.sel_menu_willHighlightItem_, proc4, "c@:@@");
    OS.class_addMethod(cls, OS.sel_menuNeedsUpdate_, proc3, "c@:@");
    OS.objc_registerClassPair(cls);

    className = "SWTMenuItem";
    cls = OS.objc_allocateClassPair(OS.class_NSMenuItem, className, 0);
    OS.class_addIvar(cls, SWT_OBJECT, size, align_, types);
    OS.class_addMethod(cls, OS.sel_sendSelection, proc2, "@:");
    OS.objc_registerClassPair(cls);

    className = "SWTOutlineView";
    cls = OS.objc_allocateClassPair(OS.class_NSOutlineView, className, 0);
    OS.class_addIvar(cls, SWT_OBJECT, size, align_, types);
    OS.class_addMethod!("@:{NSRect}")(cls, OS.sel_highlightSelectionInClipRect_, highlightSelectionInClipRectProc);
    OS.class_addMethod(cls, OS.sel_sendDoubleSelection, proc2, "@:");
    OS.class_addMethod(cls, OS.sel_outlineViewSelectionDidChange_, proc3, "@:@");
    OS.class_addMethod(cls, OS.sel_outlineView_child_ofItem_, proc5, "@:@i@");
    OS.class_addMethod(cls, OS.sel_outlineView_isItemExpandable_, proc4, "@:@@");
    OS.class_addMethod(cls, OS.sel_outlineView_numberOfChildrenOfItem_, proc4, "@:@@");
    OS.class_addMethod(cls, OS.sel_outlineView_objectValueForTableColumn_byItem_, proc5, "@:@@@");
    OS.class_addMethod(cls, OS.sel_outlineView_willDisplayCell_forTableColumn_item_, proc6, "@:@@@@");
    OS.class_addMethod(cls, OS.sel_outlineView_setObjectValue_forTableColumn_byItem_, proc6, "@:@@@@");
    OS.class_addMethod(cls, OS.sel_outlineViewColumnDidMove_, proc3, "@:@");
    OS.class_addMethod(cls, OS.sel_outlineViewColumnDidResize_, proc3, "@:@");
    OS.class_addMethod(cls, OS.sel_outlineView_didClickTableColumn_, proc4, "@:@@");
    OS.class_addMethod(cls, OS.sel_canDragRowsWithIndexes_atPoint_, canDragRowsWithIndexes_atPoint_Proc, "@:@{NSPoint=ff}");
    OS.class_addMethod(cls, OS.sel_outlineView_writeItems_toPasteboard_, proc5, "@:@@@");
    OS.class_addMethod(cls, OS.sel_expandItem_expandChildren_, proc4, "@:@Z");
    OS.class_addMethod(cls, OS.sel_collapseItem_collapseChildren_, proc4, "@:@Z");
    addEventMethods(cls, proc2, proc3, drawRectProc, hitTestProc, setNeedsDisplayInRectProc);
    addFrameMethods(cls, setFrameOriginProc, setFrameSizeProc);
    addAccessibilityMethods(cls, proc2, proc3, proc4, accessibilityHitTestProc);
    OS.objc_registerClassPair(cls);

    className = "SWTPanelDelegate";
    cls = OS.objc_allocateClassPair(OS.class_NSObject, className, 0);
    OS.class_addIvar(cls, SWT_OBJECT, size, align_, types);
    OS.class_addMethod(cls, OS.sel_windowWillClose_, dialogProc3, "@:@");
    OS.class_addMethod(cls, OS.sel_changeColor_, dialogProc3, "@:@");
    OS.class_addMethod(cls, OS.sel_changeFont_, dialogProc3, "@:@");
    OS.class_addMethod(cls, OS.sel_sendSelection_, dialogProc3, "@:@");
    OS.class_addMethod(cls, OS.sel_panel_shouldShowFilename_, dialogProc4, "@:@@");
    OS.class_addMethod(cls, OS.sel_panelDidEnd_returnCode_contextInfo_, dialogProc5, "@:@i@");
    OS.objc_registerClassPair(cls);

    className = "SWTPopUpButton";
    cls = OS.objc_allocateClassPair(OS.class_NSPopUpButton, className, 0);
    OS.class_addIvar(cls, SWT_OBJECT, size, align_, types);
    OS.class_addMethod(cls, OS.sel_sendSelection, proc2, "@:");
    addEventMethods(cls, proc2, proc3, drawRectProc, hitTestProc, setNeedsDisplayInRectProc);
    addFrameMethods(cls, setFrameOriginProc, setFrameSizeProc);
    addAccessibilityMethods(cls, proc2, proc3, proc4, accessibilityHitTestProc);
    OS.objc_registerClassPair(cls);

    cls = registerCellSubclass(NSPopUpButton.cellClass(), size, align_, types);
    addAccessibilityMethods(cls, proc2, proc3, proc4, accessibilityHitTestProc);
    NSPopUpButton.setCellClass(cls);

    className = "SWTProgressIndicator";
    cls = OS.objc_allocateClassPair(OS.class_NSProgressIndicator, className, 0);
    OS.class_addIvar(cls, SWT_OBJECT, size, align_, types);
    OS.class_addMethod(cls, OS.sel_viewDidMoveToWindow, proc2, "@:");
    OS.class_addMethod(cls, OS.sel__drawThemeProgressArea_, proc3, "@:c");
    addEventMethods(cls, proc2, proc3, drawRectProc, hitTestProc, setNeedsDisplayInRectProc);
    addFrameMethods(cls, setFrameOriginProc, setFrameSizeProc);
    addAccessibilityMethods(cls, proc2, proc3, proc4, accessibilityHitTestProc);
    OS.objc_registerClassPair(cls);

    className = "SWTScroller";
    cls = OS.objc_allocateClassPair(OS.class_NSScroller, className, 0);
    OS.class_addIvar(cls, SWT_OBJECT, size, align_, types);
    OS.class_addMethod(cls, OS.sel_sendSelection, proc2, "@:");
    addEventMethods(cls, proc2, proc3, drawRectProc, hitTestProc, setNeedsDisplayInRectProc);
    addFrameMethods(cls, setFrameOriginProc, setFrameSizeProc);
    addAccessibilityMethods(cls, proc2, proc3, proc4, accessibilityHitTestProc);
    OS.objc_registerClassPair(cls);

    className = "SWTScrollView";
    cls = OS.objc_allocateClassPair(OS.class_NSScrollView, className, 0);
    OS.class_addIvar(cls, SWT_OBJECT, size, align_, types);
    OS.class_addMethod(cls, OS.sel_sendVerticalSelection, proc2, "@:");
    OS.class_addMethod(cls, OS.sel_sendHorizontalSelection, proc2, "@:");
    OS.class_addMethod(cls, OS.sel_pageDown_, proc3, "@:@");
    OS.class_addMethod(cls, OS.sel_pageUp_, proc3, "@:@");
    OS.class_addMethod(cls, OS.sel_reflectScrolledClipView_, proc3, "@:@");
    addEventMethods(cls, proc2, proc3, drawRectProc, hitTestProc, setNeedsDisplayInRectProc);
    addFrameMethods(cls, setFrameOriginProc, setFrameSizeProc);
    addAccessibilityMethods(cls, proc2, proc3, proc4, accessibilityHitTestProc);
    OS.objc_registerClassPair(cls);

    className = "SWTSearchField";
    cls = OS.objc_allocateClassPair(OS.class_NSSearchField, className, 0);
    OS.class_addIvar(cls, SWT_OBJECT, size, align_, types);
    addEventMethods(cls, proc2, proc3, drawRectProc, hitTestProc, setNeedsDisplayInRectProc);
    addFrameMethods(cls, setFrameOriginProc, setFrameSizeProc);
    addAccessibilityMethods(cls, proc2, proc3, proc4, accessibilityHitTestProc);
    OS.class_addMethod(cls, OS.sel_textDidChange_, proc3, "@:@");
    OS.class_addMethod(cls, OS.sel_textViewDidChangeSelection_, proc3, "@:@");
    OS.class_addMethod!("@:@{NSRange}{NSRange}")(cls, OS.sel_textView_willChangeSelectionFromCharacterRange_toCharacterRange_, textWillChangeSelectionProc);
    OS.class_addMethod(cls, OS.sel_sendSearchSelection, proc2, "@:");
    OS.class_addMethod(cls, OS.sel_sendCancelSelection, proc2, "@:");
    OS.objc_registerClassPair(cls);

    cls = registerCellSubclass(NSSearchField.cellClass(), size, align_, types);
    addAccessibilityMethods(cls, proc2, proc3, proc4, accessibilityHitTestProc);
    NSSearchField.setCellClass(cls);

    // Don't subclass NSSecureTextFieldCell -- you'll get an NSException from [NSSecureTextField setCellClass:]!
    className = "SWTSecureTextField";
    cls = OS.objc_allocateClassPair(OS.class_NSSecureTextField, className, 0);
    OS.class_addIvar(cls, SWT_OBJECT, size, align_, types);
    addEventMethods(cls, proc2, proc3, drawRectProc, hitTestProc, setNeedsDisplayInRectProc);
    addFrameMethods(cls, setFrameOriginProc, setFrameSizeProc);
    addAccessibilityMethods(cls, proc2, proc3, proc4, accessibilityHitTestProc);
    OS.class_addMethod(cls, OS.sel_textDidChange_, proc3, "@:@");
    OS.class_addMethod(cls, OS.sel_textViewDidChangeSelection_, proc3, "@:@");
    OS.class_addMethod!("@:@{NSRange}{NSRange}")(cls, OS.sel_textView_willChangeSelectionFromCharacterRange_toCharacterRange_, textWillChangeSelectionProc);
    OS.objc_registerClassPair(cls);

    className = "SWTSlider";
    cls = OS.objc_allocateClassPair(OS.class_NSSlider, className, 0);
    OS.class_addIvar(cls, SWT_OBJECT, size, align_, types);
    OS.class_addMethod(cls, OS.sel_sendSelection, proc2, "@:");
    addEventMethods(cls, proc2, proc3, drawRectProc, hitTestProc, setNeedsDisplayInRectProc);
    addFrameMethods(cls, setFrameOriginProc, setFrameSizeProc);
    addAccessibilityMethods(cls, proc2, proc3, proc4, accessibilityHitTestProc);
    OS.objc_registerClassPair(cls);

    cls = registerCellSubclass(NSSlider.cellClass(), size, align_, types);
    addAccessibilityMethods(cls, proc2, proc3, proc4, accessibilityHitTestProc);
    NSSlider.setCellClass(cls);

    className = "SWTStepper";
    cls = OS.objc_allocateClassPair(OS.class_NSStepper, className, 0);
    OS.class_addIvar(cls, SWT_OBJECT, size, align_, types);
    OS.class_addMethod(cls, OS.sel_sendSelection, proc2, "@:");
    addEventMethods(cls, proc2, proc3, drawRectProc, hitTestProc, setNeedsDisplayInRectProc);
    addFrameMethods(cls, setFrameOriginProc, setFrameSizeProc);
    addAccessibilityMethods(cls, proc2, proc3, proc4, accessibilityHitTestProc);
    OS.objc_registerClassPair(cls);

    cls = registerCellSubclass(NSStepper.cellClass(), size, align_, types);
    addAccessibilityMethods(cls, proc2, proc3, proc4, accessibilityHitTestProc);
    NSStepper.setCellClass(cls);

    className = "SWTTableHeaderCell";
    cls = OS.objc_allocateClassPair (OS.class_NSTableHeaderCell, className, 0);
    OS.class_addIvar (cls, SWT_OBJECT, size, align_, types);
    OS.class_addMethod!("@:{NSRect}@")(cls, OS.sel_drawInteriorWithFrame_inView_, drawInteriorWithFrameInViewProc);
    OS.objc_registerClassPair (cls);

    className = "SWTTableHeaderView";
    cls = OS.objc_allocateClassPair(OS.class_NSTableHeaderView, className, 0);
    OS.class_addIvar(cls, SWT_OBJECT, size, align_, types);
    OS.class_addMethod(cls, OS.sel_mouseDown_, proc3, "@:@");
    OS.class_addMethod(cls, OS.sel_resetCursorRects, proc2, "@:");
    OS.class_addMethod(cls, OS.sel_updateTrackingAreas, proc2, "@:");
    OS.class_addMethod(cls, OS.sel_menuForEvent_, proc3, "@:@");
    //TODO hitTestProc and drawRectProc should be set Control.setRegion()?
    OS.objc_registerClassPair(cls);

    className = "SWTTableView";
    cls = OS.objc_allocateClassPair(OS.class_NSTableView, className, 0);
    OS.class_addIvar(cls, SWT_OBJECT, size, align_, types);
    OS.class_addMethod!("@:{NSRect}")(cls, OS.sel_highlightSelectionInClipRect_, highlightSelectionInClipRectProc);
    OS.class_addMethod(cls, OS.sel_sendDoubleSelection, proc2, "@:");
    OS.class_addMethod(cls, OS.sel_numberOfRowsInTableView_, proc3, "@:@");
    OS.class_addMethod(cls, OS.sel_tableView_objectValueForTableColumn_row_, proc5, "@:@:@:@");
    OS.class_addMethod(cls, OS.sel_tableView_shouldEditTableColumn_row_, proc5, "@:@:@:@");
    OS.class_addMethod(cls, OS.sel_tableViewSelectionDidChange_, proc3, "@:@");
    OS.class_addMethod(cls, OS.sel_tableView_willDisplayCell_forTableColumn_row_, proc6, "@:@@@i");
    OS.class_addMethod(cls, OS.sel_tableView_setObjectValue_forTableColumn_row_, proc6, "@:@@@i");
    OS.class_addMethod(cls, OS.sel_tableViewColumnDidMove_, proc3, "@:@");
    OS.class_addMethod(cls, OS.sel_tableViewColumnDidResize_, proc3, "@:@");
    OS.class_addMethod(cls, OS.sel_tableView_didClickTableColumn_, proc4, "@:@");
    OS.class_addMethod(cls, OS.sel_canDragRowsWithIndexes_atPoint_, canDragRowsWithIndexes_atPoint_Proc, "@:@{NSPoint=ff}");
    OS.class_addMethod(cls, OS.sel_tableView_writeRowsWithIndexes_toPasteboard_, proc5, "@:@@@");
    addEventMethods(cls, proc2, proc3, drawRectProc, hitTestProc, setNeedsDisplayInRectProc);
    addFrameMethods(cls, setFrameOriginProc, setFrameSizeProc);
    addAccessibilityMethods(cls, proc2, proc3, proc4, accessibilityHitTestProc);
    OS.objc_registerClassPair(cls);

    className = "SWTTabView";
    cls = OS.objc_allocateClassPair(OS.class_NSTabView, className, 0);
    OS.class_addIvar(cls, SWT_OBJECT, size, align_, types);
    OS.class_addMethod(cls, OS.sel_tabView_willSelectTabViewItem_, proc4, "@:@@");
    OS.class_addMethod(cls, OS.sel_tabView_didSelectTabViewItem_, proc4, "@:@@");
    addEventMethods(cls, proc2, proc3, drawRectProc, hitTestProc, setNeedsDisplayInRectProc);
    addFrameMethods(cls, setFrameOriginProc, setFrameSizeProc);
    addAccessibilityMethods(cls, proc2, proc3, proc4, accessibilityHitTestProc);
    OS.objc_registerClassPair(cls);

    className = "SWTTextView";
    cls = OS.objc_allocateClassPair(OS.class_NSTextView, className, 0);
    OS.class_addIvar(cls, SWT_OBJECT, size, align_, types);
    addEventMethods(cls, proc2, proc3, drawRectProc, hitTestProc, setNeedsDisplayInRectProc);
    addFrameMethods(cls, setFrameOriginProc, setFrameSizeProc);
    addAccessibilityMethods(cls, proc2, proc3, proc4, accessibilityHitTestProc);
    OS.class_addMethod(cls, OS.sel_insertText_, proc3, "@:@");
    OS.class_addMethod(cls, OS.sel_doCommandBySelector_, proc3, "@::");
    OS.class_addMethod(cls, OS.sel_textDidChange_, proc3, "@:@");
    OS.class_addMethod(cls, OS.sel_textView_clickedOnLink_atIndex_, proc5, "@:@@@");
    OS.class_addMethod(cls, OS.sel_dragSelectionWithEvent_offset_slideBack_, proc5, "@:@@@");
    OS.class_addMethod!("@:{NSRange}@")(cls, OS.sel_shouldChangeTextInRange_replacementString_, shouldChangeTextInRange_replacementString_Proc);
    OS.objc_registerClassPair(cls);

    className = "SWTTextField";
    cls = OS.objc_allocateClassPair(OS.class_NSTextField, className, 0);
    OS.class_addIvar(cls, SWT_OBJECT, size, align_, types);
    addEventMethods(cls, proc2, proc3, drawRectProc, hitTestProc, setNeedsDisplayInRectProc);
    addFrameMethods(cls, setFrameOriginProc, setFrameSizeProc);
    addAccessibilityMethods(cls, proc2, proc3, proc4, accessibilityHitTestProc);
    OS.class_addMethod(cls, OS.sel_acceptsFirstResponder, proc2, "@:");
    OS.class_addMethod(cls, OS.sel_textDidChange_, proc3, "@:@");
    OS.class_addMethod(cls, OS.sel_textDidEndEditing_, proc3, "@:@");
    OS.class_addMethod(cls, OS.sel_textViewDidChangeSelection_, proc3, "@:@");
    OS.class_addMethod!("@:@{NSRange}{NSRange}")(cls, OS.sel_textView_willChangeSelectionFromCharacterRange_toCharacterRange_, textWillChangeSelectionProc);
    OS.objc_registerClassPair(cls);

    cls = registerCellSubclass(NSTextField.cellClass(), size, align_, types);
    addAccessibilityMethods(cls, proc2, proc3, proc4, accessibilityHitTestProc);
    NSTextField.setCellClass(cls);

    className = "SWTTreeItem";
    cls = OS.objc_allocateClassPair(OS.class_NSObject, className, 0);
    OS.class_addIvar(cls, SWT_OBJECT, size, align_, types);
    OS.objc_registerClassPair(cls);

    className = "SWTView";
    cls = OS.objc_allocateClassPair(OS.class_NSView, className, 0);
    OS.class_addIvar(cls, SWT_OBJECT, size, align_, types);
    OS.class_addMethod(cls, OS.sel_canBecomeKeyView, proc2, "@:");
    OS.class_addMethod(cls, OS.sel_isFlipped, isFlippedProc, "@:");
    OS.class_addMethod(cls, OS.sel_acceptsFirstResponder, proc2, "@:");
    OS.class_addMethod(cls, OS.sel_isOpaque, proc2, "@:");
    addEventMethods(cls, proc2, proc3, drawRectProc, hitTestProc, setNeedsDisplayInRectProc);
    addFrameMethods(cls, setFrameOriginProc, setFrameSizeProc);
    addAccessibilityMethods(cls, proc2, proc3, proc4, accessibilityHitTestProc);
    OS.objc_registerClassPair(cls);

    className = "SWTWindow";
    cls = OS.objc_allocateClassPair(OS.class_NSWindow, className, 0);
    OS.class_addIvar(cls, SWT_OBJECT, size, align_, types);
    OS.class_addMethod(cls, OS.sel_sendEvent_, proc3, "@:@");
    OS.class_addMethod(cls, OS.sel_helpRequested_, proc3, "@:@");
    OS.class_addMethod(cls, OS.sel_canBecomeKeyWindow, proc2, "@:");
    OS.class_addMethod(cls, OS.sel_becomeKeyWindow, proc2, "@:");
    OS.class_addMethod(cls, OS.sel_makeFirstResponder_, proc3, "@:@");
    OS.class_addMethod(cls, OS.sel_noResponderFor_, proc3, "@:@");
    OS.class_addMethod!("@:@i{NSPoint}@")(cls, OS.sel_view_stringForToolTip_point_userData_, view_stringForToolTip_point_userDataProc);
    addAccessibilityMethods(cls, proc2, proc3, proc4, accessibilityHitTestProc);
    OS.objc_registerClassPair(cls);

    className = "SWTWindowDelegate";
    cls = OS.objc_allocateClassPair(OS.class_NSObject, className, 0);
    OS.class_addIvar(cls, SWT_OBJECT, size, align_, types);
    OS.class_addMethod(cls, OS.sel_windowDidResize_, proc3, "@:@");
    OS.class_addMethod(cls, OS.sel_windowDidMove_, proc3, "@:@");
    OS.class_addMethod(cls, OS.sel_windowShouldClose_, proc3, "@:@");
    OS.class_addMethod(cls, OS.sel_windowWillClose_, proc3, "@:@");
    OS.class_addMethod(cls, OS.sel_windowDidResignKey_, proc3, "@:@");
    OS.class_addMethod(cls, OS.sel_windowDidBecomeKey_, proc3, "@:@");
    OS.class_addMethod(cls, OS.sel_timerProc_, proc3, "@:@");
    OS.class_addMethod(cls, OS.sel_systemSettingsChanged_, proc3, "@:@");
    OS.objc_registerClassPair(cls);
}

NSFont getFont (objc.Class cls, objc.SEL sel) {
    objc.id widget = OS.objc_msgSend (OS.objc_msgSend (cls, OS.sel_alloc), OS.sel_initWithFrame_, NSRect());
    objc.id font = null;
    if (OS.objc_msgSend_bool (widget, OS.sel_respondsToSelector_, sel)) {
        font = OS.objc_msgSend (widget, sel);
    }
    NSFont result = null;
    if (font !is null) {
        result = new NSFont (font);
    } else {
        result = NSFont.systemFontOfSize (NSFont.systemFontSizeForControlSize (OS.NSRegularControlSize));
    }
    result.retain ();
    OS.objc_msgSend (widget, OS.sel_release);
    return result;
}

void initColors () {
    colors = new Carbon.CGFloat [][DWT.COLOR_TITLE_INACTIVE_BACKGROUND_GRADIENT + 1];
    colors[DWT.COLOR_INFO_FOREGROUND] = getWidgetColorRGB(DWT.COLOR_INFO_FOREGROUND);
    colors[DWT.COLOR_INFO_BACKGROUND] = getWidgetColorRGB(DWT.COLOR_INFO_BACKGROUND);
    colors[DWT.COLOR_TITLE_FOREGROUND] = getWidgetColorRGB(DWT.COLOR_TITLE_FOREGROUND);
    colors[DWT.COLOR_TITLE_BACKGROUND] = getWidgetColorRGB(DWT.COLOR_TITLE_BACKGROUND);
    colors[DWT.COLOR_TITLE_BACKGROUND_GRADIENT] = getWidgetColorRGB(DWT.COLOR_TITLE_BACKGROUND_GRADIENT);
    colors[DWT.COLOR_TITLE_INACTIVE_FOREGROUND] = getWidgetColorRGB(DWT.COLOR_TITLE_INACTIVE_FOREGROUND);
    colors[DWT.COLOR_TITLE_INACTIVE_BACKGROUND] = getWidgetColorRGB(DWT.COLOR_TITLE_INACTIVE_BACKGROUND);
    colors[DWT.COLOR_TITLE_INACTIVE_BACKGROUND_GRADIENT] = getWidgetColorRGB(DWT.COLOR_TITLE_INACTIVE_BACKGROUND_GRADIENT);
    colors[DWT.COLOR_WIDGET_DARK_SHADOW] = getWidgetColorRGB(DWT.COLOR_WIDGET_DARK_SHADOW);
    colors[DWT.COLOR_WIDGET_NORMAL_SHADOW] = getWidgetColorRGB(DWT.COLOR_WIDGET_NORMAL_SHADOW);
    colors[DWT.COLOR_WIDGET_LIGHT_SHADOW] = getWidgetColorRGB(DWT.COLOR_WIDGET_LIGHT_SHADOW);
    colors[DWT.COLOR_WIDGET_HIGHLIGHT_SHADOW] = getWidgetColorRGB(DWT.COLOR_WIDGET_HIGHLIGHT_SHADOW);
    colors[DWT.COLOR_WIDGET_BACKGROUND] = getWidgetColorRGB(DWT.COLOR_WIDGET_BACKGROUND);
    colors[DWT.COLOR_WIDGET_FOREGROUND] = getWidgetColorRGB(DWT.COLOR_WIDGET_FOREGROUND);
    colors[DWT.COLOR_WIDGET_BORDER] = getWidgetColorRGB(DWT.COLOR_WIDGET_BORDER);
    colors[DWT.COLOR_LIST_FOREGROUND] = getWidgetColorRGB(DWT.COLOR_LIST_FOREGROUND);
    colors[DWT.COLOR_LIST_BACKGROUND] = getWidgetColorRGB(DWT.COLOR_LIST_BACKGROUND);
    colors[DWT.COLOR_LIST_SELECTION_TEXT] = getWidgetColorRGB(DWT.COLOR_LIST_SELECTION_TEXT);
    colors[DWT.COLOR_LIST_SELECTION] = getWidgetColorRGB(DWT.COLOR_LIST_SELECTION);

    alternateSelectedControlColor = getWidgetColorRGB(NSColor.alternateSelectedControlColor());
    alternateSelectedControlTextColor = getWidgetColorRGB(NSColor.alternateSelectedControlTextColor());
    secondarySelectedControlColor = getWidgetColorRGB(NSColor.secondarySelectedControlColor());
    selectedControlTextColor = getWidgetColorRGB(NSColor.selectedControlTextColor());
}

void initFonts () {
    smallFonts = System.getProperty("org.eclipse.swt.internal.carbon.smallFonts") !is null;
    buttonFont = getFont (OS.class_NSButton, OS.sel_font);
    popUpButtonFont = getFont (OS.class_NSPopUpButton, OS.sel_font);
    textFieldFont = getFont (OS.class_NSTextField, OS.sel_font);
    secureTextFieldFont = getFont (OS.class_NSSecureTextField, OS.sel_font);
    searchFieldFont = getFont (OS.class_NSSearchField, OS.sel_font);
    comboBoxFont = getFont (OS.class_NSComboBox, OS.sel_font);
    sliderFont = getFont (OS.class_NSSlider, OS.sel_font);
    scrollerFont = getFont (OS.class_NSScroller, OS.sel_font);
    textViewFont = getFont (OS.class_NSTextView, OS.sel_font);
    tableViewFont = getFont (OS.class_NSTableView, OS.sel_font);
    outlineViewFont = getFont (OS.class_NSOutlineView, OS.sel_font);
    datePickerFont = getFont (OS.class_NSDatePicker, OS.sel_font);
    boxFont = getFont (OS.class_NSBox, OS.sel_titleFont);
    tabViewFont = getFont (OS.class_NSTabView, OS.sel_font);
    progressIndicatorFont = getFont (OS.class_NSProgressIndicator, OS.sel_font);
    }

/**
 * Invokes platform specific functionality to allocate a new GC handle.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>Display</code>. It is marked public only so that it
 * can be shared within the packages provided by DWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param data the platform specific GC data
 * @return the platform specific GC handle
 *
 * @exception DWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 * @exception DWTError <ul>
 *    <li>ERROR_NO_HANDLES if a handle could not be obtained for gc creation</li>
 * </ul>
 */
public objc.id internal_new_GC (GCData data) {
    if (isDisposed()) DWT.error(DWT.ERROR_DEVICE_DISPOSED);
    if (screenWindow is null) {
        NSWindow window = cast(NSWindow) (new NSWindow ()).alloc ();
        NSRect rect = NSRect();
        window = window.initWithContentRect(rect, OS.NSBorderlessWindowMask, OS.NSBackingStoreBuffered, false);
        window.setReleasedWhenClosed(false);
        screenWindow = window;
    }
    NSGraphicsContext context = screenWindow.graphicsContext();
    //  NSAffineTransform transform = NSAffineTransform.transform();
    //  NSSize size = handle.size();
    //  transform.translateXBy(0, size.height);
    //  transform.scaleXBy(1, -1);
    //  transform.set();
    if (data !is null) {
        int mask = DWT.LEFT_TO_RIGHT | DWT.RIGHT_TO_LEFT;
        if ((data.style & mask) is 0) {
            data.style |= DWT.LEFT_TO_RIGHT;
        }
        data.device = this;
        data.background = getSystemColor(DWT.COLOR_WHITE).handle;
        data.foreground = getSystemColor(DWT.COLOR_BLACK).handle;
        data.font = getSystemFont();
    }
    return context.id;
}

/**
 * Invokes platform specific functionality to dispose a GC handle.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>Display</code>. It is marked public only so that it
 * can be shared within the packages provided by DWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param hDC the platform specific GC handle
 * @param data the platform specific GC data
 */
public void internal_dispose_GC (objc.id context, GCData data) {
    if (isDisposed()) DWT.error(DWT.ERROR_DEVICE_DISPOSED);

}

static bool isValidClass (ClassInfo clazz) {
    String name = clazz.name;
    int index = name.lastIndexOf ('.');
    name = name[0 .. index];
    index = name.lastIndexOf ('.');
    return name.substring (0, index + 1).equals (PACKAGE_PREFIX);
}

bool isValidThread () {
    return thread is Thread.getThis ();
}

/**
 * Generate a low level system event.
 *
 * <code>post</code> is used to generate low level keyboard
 * and mouse events. The intent is to enable automated UI
 * testing by simulating the input from the user.  Most
 * DWT applications should never need to call this method.
 * <p>
 * Note that this operation can fail when the operating system
 * fails to generate the event for any reason.  For example,
 * this can happen when there is no such key or mouse button
 * or when the system event queue is full.
 * </p>
 * <p>
 * <b>Event Types:</b>
 * <p>KeyDown, KeyUp
 * <p>The following fields in the <code>Event</code> apply:
 * <ul>
 * <li>(in) type KeyDown or KeyUp</li>
 * <p> Either one of:
 * <li>(in) character a character that corresponds to a keyboard key</li>
 * <li>(in) keyCode the key code of the key that was typed,
 *          as defined by the key code constants in class <code>DWT</code></li>
 * </ul>
 * <p>MouseDown, MouseUp</p>
 * <p>The following fields in the <code>Event</code> apply:
 * <ul>
 * <li>(in) type MouseDown or MouseUp
 * <li>(in) button the button that is pressed or released
 * </ul>
 * <p>MouseMove</p>
 * <p>The following fields in the <code>Event</code> apply:
 * <ul>
 * <li>(in) type MouseMove
 * <li>(in) x the x coordinate to move the mouse pointer to in screen coordinates
 * <li>(in) y the y coordinate to move the mouse pointer to in screen coordinates
 * </ul>
 * <p>MouseWheel</p>
 * <p>The following fields in the <code>Event</code> apply:
 * <ul>
 * <li>(in) type MouseWheel
 * <li>(in) detail either DWT.SCROLL_LINE or DWT.SCROLL_PAGE
 * <li>(in) count the number of lines or pages to scroll
 * </ul>
 * </dl>
 *
 * @param event the event to be generated
 *
 * @return true if the event was generated or false otherwise
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the event is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.0
 *
 */
public bool post(Event event) {
    synchronized (Device.classinfo) {
        if (isDisposed ()) error (DWT.ERROR_DEVICE_DISPOSED);
        if (event is null) error (DWT.ERROR_NULL_ARGUMENT);

        // TODO: Not sure if these calls have any effect on event posting.
        if (!eventSourceDelaySet) {
            OS.CGSetLocalEventsSuppressionInterval(0.0);
            OS.CGEnableEventStateCombining(1);
            OS.CGSetLocalEventsFilterDuringSuppressionState(OS.kCGEventFilterMaskPermitLocalKeyboardEvents | OS.kCGEventFilterMaskPermitLocalMouseEvents | OS.kCGEventFilterMaskPermitSystemDefinedEvents, OS.kCGEventSuppressionStateSuppressionInterval);
            OS.CGSetLocalEventsFilterDuringSuppressionState(OS.kCGEventFilterMaskPermitLocalKeyboardEvents | OS.kCGEventFilterMaskPermitLocalMouseEvents | OS.kCGEventFilterMaskPermitSystemDefinedEvents, OS.kCGEventSuppressionStateRemoteMouseDrag);
            eventSourceDelaySet = true;
        }

	    int type = event.type;
	    switch (type) {
	        case DWT.KeyDown:
	        case DWT.KeyUp: {
	            short vKey = cast(short)Display.untranslateKey (event.keyCode);
	            if (vKey is 0) {
	                ubyte* uchrPtr = null;
	                Carbon.TISInputSourceRef currentKbd = OS.TISCopyCurrentKeyboardInputSource();
	                Carbon.CFDataRef uchrCFData = cast(Carbon.CFDataRef) OS.TISGetInputSourceProperty(currentKbd, OS.kTISPropertyUnicodeKeyLayoutData);

	                if (uchrCFData is null) return false;
	                uchrPtr = OS.CFDataGetBytePtr(uchrCFData);
	                if (uchrPtr is null) return false;
	                if (OS.CFDataGetLength(uchrCFData) is 0) return false;
	                int maxStringLength = 256;
	                vKey = -1;
	                wchar [] output = new wchar [maxStringLength];
	                uint [] actualStringLength = new uint [1];
	                for (short i = 0 ; i <= 0x7F ; i++) {
	                    OS.UCKeyTranslate (cast(Carbon.UCKeyboardLayout*) uchrPtr, cast(ushort) i, cast(ushort)(type is DWT.KeyDown ? OS.kUCKeyActionDown : OS.kUCKeyActionUp), cast(uint) 0, OS.LMGetKbdType(), cast(uint) 0, deadKeyState.ptr, maxStringLength, actualStringLength.ptr, output.ptr);
	                    if (output[0] is event.character) {
	                        vKey = i;
	                        break;
	                    }
	                }
	                if (vKey is -1) {
	                    for (short i = 0 ; i <= 0x7F ; i++) {
	                        OS.UCKeyTranslate (cast(Carbon.UCKeyboardLayout*) uchrPtr, i, cast(short)(type is DWT.KeyDown ? OS.kUCKeyActionDown : OS.kUCKeyActionUp), OS.shiftKey, OS.LMGetKbdType(), 0, deadKeyState.ptr, maxStringLength, actualStringLength.ptr, output.ptr);
	                        if (output[0] is event.character) {
	                            vKey = i;
	                            break;
	                        }
	                    }
	                }
	            }

	            /**
	             * Bug(?) in UCKeyTranslate:  If event.keyCode doesn't map to a valid DWT constant and event.characer is 0 we still need to post an event.
	             * In Carbon, KeyTranslate eventually found a key that generated 0 but UCKeyTranslate never generates 0.
	             * When that happens, post an event from key 127, which does nothing.
	             */
	            if (vKey is -1 && event.character is 0) {
	                vKey = 127;
	            }

	            if (vKey is -1) return false;

	            return OS.CGPostKeyboardEvent(cast(short)0, vKey, type is DWT.KeyDown) is 0;
	        }
	        case DWT.MouseDown:
	        case DWT.MouseMove:
	        case DWT.MouseUp: {
	            CGPoint mouseCursorPosition = CGPoint ();
	            int chord = OS.GetCurrentButtonState ();

	            if (type is DWT.MouseMove) {
	                mouseCursorPosition.x = event.x;
	                mouseCursorPosition.y = event.y;
	                return OS.CGPostMouseEvent (mouseCursorPosition, true, 5, (chord & 0x1) !is 0, (chord & 0x2) !is 0, (chord & 0x4) !is 0, (chord & 0x8) !is 0, (chord & 0x10) !is 0) is 0;
	            } else {
	                int button = event.button;
	                if (button < 1 || button > 5) return false;
	                bool button1 = false, button2 = false, button3 = false, button4 = false, button5 = false;
	                switch (button) {
	                    case 1: {
	                        button1 = type is DWT.MouseDown;
	                        button2 = (chord & 0x4) !is 0;
	                        button3 = (chord & 0x2) !is 0;
	                        button4 = (chord & 0x8) !is 0;
	                        button5 = (chord & 0x10) !is 0;
	                        break;
	                    }
	                    case 2: {
	                        button1 = (chord & 0x1) !is 0;
	                        button2 = type is DWT.MouseDown;
	                        button3 = (chord & 0x2) !is 0;
	                        button4 = (chord & 0x8) !is 0;
	                        button5 = (chord & 0x10) !is 0;
	                        break;
	                    }
	                    case 3: {
	                        button1 = (chord & 0x1) !is 0;
	                        button2 = (chord & 0x4) !is 0;
	                        button3 = type is DWT.MouseDown;
	                        button4 = (chord & 0x8) !is 0;
	                        button5 = (chord & 0x10) !is 0;
	                        break;
	                    }
	                    case 4: {
	                        button1 = (chord & 0x1) !is 0;
	                        button2 = (chord & 0x4) !is 0;
	                        button3 = (chord & 0x2) !is 0;
	                        button4 = type is DWT.MouseDown;
	                        button5 = (chord & 0x10) !is 0;
	                        break;
	                    }
	                    case 5: {
	                        button1 = (chord & 0x1) !is 0;
	                        button2 = (chord & 0x4) !is 0;
	                        button3 = (chord & 0x2) !is 0;
	                        button4 = (chord & 0x8) !is 0;
	                        button5 = type is DWT.MouseDown;
	                        break;
	                    }
	                    default:
	                }

	                NSPoint nsCursorPosition = NSEvent.mouseLocation();
	                NSRect primaryFrame = getPrimaryFrame();
	                mouseCursorPosition.x = nsCursorPosition.x;
	                mouseCursorPosition.y = cast(int) (primaryFrame.height - nsCursorPosition.y);
	                return OS.CGPostMouseEvent (mouseCursorPosition, true, 5, button1, button3, button2, button4, button5) is 0;
	            }
	        }
	        case DWT.MouseWheel: {
	            return OS.CGPostScrollWheelEvent(1, event.count) is 0;
	        }
	        default:
	    }
        return false;
    }
}

void postEvent (Event event) {
    /*
     * Place the event at the end of the event queue.
     * This code is always called in the Display's
     * thread so it must be re-enterant but does not
     * need to be synchronized.
     */
    if (eventQueue is null) eventQueue = new Event [4];
    int index = 0;
    int length = eventQueue.length;
    while (index < length) {
        if (eventQueue [index] is null) break;
        index++;
    }
    if (index is length) {
        Event [] newQueue = new Event [length + 4];
        System.arraycopy (eventQueue, 0, newQueue, 0, length);
        eventQueue = newQueue;
    }
    eventQueue [index] = event;
}

/**
 * Maps a point from one coordinate system to another.
 * When the control is null, coordinates are mapped to
 * the display.
 * <p>
 * NOTE: On right-to-left platforms where the coordinate
 * systems are mirrored, special care needs to be taken
 * when mapping coordinates from one control to another
 * to ensure the result is correctly mirrored.
 *
 * Mapping a point that is the origin of a rectangle and
 * then adding the width and height is not equivalent to
 * mapping the rectangle.  When one control is mirrored
 * and the other is not, adding the width and height to a
 * point that was mapped causes the rectangle to extend
 * in the wrong direction.  Mapping the entire rectangle
 * instead of just one point causes both the origin and
 * the corner of the rectangle to be mapped.
 * </p>
 *
 * @param from the source <code>Control</code> or <code>null</code>
 * @param to the destination <code>Control</code> or <code>null</code>
 * @param point to be mapped
 * @return point with mapped coordinates
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the point is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the Control from or the Control to have been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 2.1.2
 */
public Point map (Control from, Control to, Point point) {
    checkDevice ();
    if (point is null) error (DWT.ERROR_NULL_ARGUMENT);
    return map (from, to, point.x, point.y);
}

/**
 * Maps a point from one coordinate system to another.
 * When the control is null, coordinates are mapped to
 * the display.
 * <p>
 * NOTE: On right-to-left platforms where the coordinate
 * systems are mirrored, special care needs to be taken
 * when mapping coordinates from one control to another
 * to ensure the result is correctly mirrored.
 *
 * Mapping a point that is the origin of a rectangle and
 * then adding the width and height is not equivalent to
 * mapping the rectangle.  When one control is mirrored
 * and the other is not, adding the width and height to a
 * point that was mapped causes the rectangle to extend
 * in the wrong direction.  Mapping the entire rectangle
 * instead of just one point causes both the origin and
 * the corner of the rectangle to be mapped.
 * </p>
 *
 * @param from the source <code>Control</code> or <code>null</code>
 * @param to the destination <code>Control</code> or <code>null</code>
 * @param x coordinates to be mapped
 * @param y coordinates to be mapped
 * @return point with mapped coordinates
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the Control from or the Control to have been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 2.1.2
 */
public Point map (Control from, Control to, int x, int y) {
    checkDevice ();
    if (from !is null && from.isDisposed()) error (DWT.ERROR_INVALID_ARGUMENT);
    if (to !is null && to.isDisposed()) error (DWT.ERROR_INVALID_ARGUMENT);
    Point point = new Point (x, y);
    if (from is to) return point;
    NSPoint pt = NSPoint();
    pt.x = x;
    pt.y = y;
    NSWindow fromWindow = from !is null ? from.view.window() : null;
    NSWindow toWindow = to !is null ? to.view.window() : null;
    if (toWindow !is null && fromWindow !is null && toWindow.id is fromWindow.id) {
        if (!from.view.isFlipped ()) {
            pt.y = from.view.bounds().height - pt.y;
        }
        pt = from.view.convertPoint_toView_(pt, to.view);
        if (!to.view.isFlipped ()) {
            pt.y = to.view.bounds().height - pt.y;
        }
    } else {
        NSRect primaryFrame = getPrimaryFrame();
        if (from !is null) {
            NSView view = from.eventView ();
            if (!view.isFlipped ()) {
                pt.y = view.bounds().height - pt.y;
            }
            pt = view.convertPoint_toView_(pt, null);
            pt = fromWindow.convertBaseToScreen(pt);
            pt.y = primaryFrame.height - pt.y;
        }
        if (to !is null) {
            NSView view = to.eventView ();
            pt.y = primaryFrame.height - pt.y;
            pt = toWindow.convertScreenToBase(pt);
            pt = view.convertPoint_fromView_(pt, null);
            if (!view.isFlipped ()) {
                pt.y = view.bounds().height - pt.y;
            }
        }
    }
    point.x = cast(int)pt.x;
    point.y = cast(int)pt.y;
    return point;
}

/**
 * Maps a point from one coordinate system to another.
 * When the control is null, coordinates are mapped to
 * the display.
 * <p>
 * NOTE: On right-to-left platforms where the coordinate
 * systems are mirrored, special care needs to be taken
 * when mapping coordinates from one control to another
 * to ensure the result is correctly mirrored.
 *
 * Mapping a point that is the origin of a rectangle and
 * then adding the width and height is not equivalent to
 * mapping the rectangle.  When one control is mirrored
 * and the other is not, adding the width and height to a
 * point that was mapped causes the rectangle to extend
 * in the wrong direction.  Mapping the entire rectangle
 * instead of just one point causes both the origin and
 * the corner of the rectangle to be mapped.
 * </p>
 *
 * @param from the source <code>Control</code> or <code>null</code>
 * @param to the destination <code>Control</code> or <code>null</code>
 * @param rectangle to be mapped
 * @return rectangle with mapped coordinates
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the rectangle is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the Control from or the Control to have been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 2.1.2
 */
public Rectangle map (Control from, Control to, Rectangle rectangle) {
    checkDevice ();
    if (rectangle is null) error (DWT.ERROR_NULL_ARGUMENT);
    return map (from, to, rectangle.x, rectangle.y, rectangle.width, rectangle.height);
}

/**
 * Maps a point from one coordinate system to another.
 * When the control is null, coordinates are mapped to
 * the display.
 * <p>
 * NOTE: On right-to-left platforms where the coordinate
 * systems are mirrored, special care needs to be taken
 * when mapping coordinates from one control to another
 * to ensure the result is correctly mirrored.
 *
 * Mapping a point that is the origin of a rectangle and
 * then adding the width and height is not equivalent to
 * mapping the rectangle.  When one control is mirrored
 * and the other is not, adding the width and height to a
 * point that was mapped causes the rectangle to extend
 * in the wrong direction.  Mapping the entire rectangle
 * instead of just one point causes both the origin and
 * the corner of the rectangle to be mapped.
 * </p>
 *
 * @param from the source <code>Control</code> or <code>null</code>
 * @param to the destination <code>Control</code> or <code>null</code>
 * @param x coordinates to be mapped
 * @param y coordinates to be mapped
 * @param width coordinates to be mapped
 * @param height coordinates to be mapped
 * @return rectangle with mapped coordinates
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the Control from or the Control to have been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 2.1.2
 */
public Rectangle map (Control from, Control to, int x, int y, int width, int height) {
    checkDevice ();
    if (from !is null && from.isDisposed()) error (DWT.ERROR_INVALID_ARGUMENT);
    if (to !is null && to.isDisposed()) error (DWT.ERROR_INVALID_ARGUMENT);
    Rectangle rectangle = new Rectangle (x, y, width, height);
    if (from is to) return rectangle;
    NSPoint pt = NSPoint();
    pt.x = x;
    pt.y = y;
    NSWindow fromWindow = from !is null ? from.view.window() : null;
    NSWindow toWindow = to !is null ? to.view.window() : null;
    if (toWindow !is null && fromWindow !is null && toWindow.id is fromWindow.id) {
        if (!from.view.isFlipped ()) {
            pt.y = from.view.bounds().height - pt.y;
        }
        pt = from.view.convertPoint_toView_(pt, to.view);
        if (!to.view.isFlipped ()) {
            pt.y = to.view.bounds().height - pt.y;
        }
    } else {
        NSRect primaryFrame = getPrimaryFrame();
        if (from !is null) {
            NSView view = from.eventView ();
            if (!view.isFlipped ()) {
                pt.y = view.bounds().height - pt.y;
            }
            pt = view.convertPoint_toView_(pt, null);
            pt = fromWindow.convertBaseToScreen(pt);
            pt.y = primaryFrame.height - pt.y;
        }
        if (to !is null) {
            NSView view = to.eventView ();
            pt.y = primaryFrame.height - pt.y;
            pt = toWindow.convertScreenToBase(pt);
            pt = view.convertPoint_fromView_(pt, null);
            if (!view.isFlipped ()) {
                pt.y = view.bounds().height - pt.y;
            }
        }
    }
    rectangle.x = cast(int)pt.x;
    rectangle.y = cast(int)pt.y;
    return rectangle;
}

void observerProc (Carbon.CFRunLoopObserverRef observer, Carbon.CFRunLoopActivity activity, void* info) {
    switch (activity) {
        case OS.kCFRunLoopBeforeWaiting:
            if (runAsyncMessages_) {
                if (runAsyncMessages (false)) wakeThread ();
            }
            break;
        default:
    }
}

private static extern (C) void observerProcFunc (Carbon.CFRunLoopObserverRef observer, Carbon.CFRunLoopActivity activity, void* info)
{
    auto display = cast(Display) info;
    assert(display !is null, "The callback data is null or not a Display");
    display.observerProc(observer, activity, info);
}

/**
 * Reads an event from the operating system's event queue,
 * dispatches it appropriately, and returns <code>true</code>
 * if there is potentially more work to do, or <code>false</code>
 * if the caller can sleep until another event is placed on
 * the event queue.
 * <p>
 * In addition to checking the system event queue, this method also
 * checks if any inter-thread messages (created by <code>syncExec()</code>
 * or <code>asyncExec()</code>) are waiting to be processed, and if
 * so handles them before returning.
 * </p>
 *
 * @return <code>false</code> if the caller can sleep upon return from this method
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_FAILED_EXEC - if an exception occurred while running an inter-thread message</li>
 * </ul>
 *
 * @see #sleep
 * @see #wake
 */
public bool readAndDispatch () {
    checkDevice ();
    if (sendEventCount == 0 && loopCount == poolCount - 1) removePool ();
    addPool ();
    loopCount++;
    bool events = false;
    try {
        events |= runSettings ();
        events |= runTimers ();
        events |= runContexts ();
        events |= runPopups ();
        NSEvent event = application.nextEventMatchingMask(0, null, OS.NSDefaultRunLoopMode, true);
        if (event !is null) {
            events = true;
            application.sendEvent(event);
        }
        events |= runPaint ();
        events |= runDeferredEvents ();
        if (!events) {
            events = isDisposed () || runAsyncMessages (false);
        }
    } finally {
        removePool ();
        loopCount--;
        if (sendEventCount == 0 && loopCount == poolCount) addPool ();
    }
    return events;
}

static void register (Display display) {
    synchronized (Device.classinfo) {
        for (int i=0; i<Displays.length; i++) {
            if (Displays [i] is null) {
                Displays [i] = display;
                return;
            }
        }
        Display [] newDisplays = new Display [Displays.length + 4];
        System.arraycopy (Displays, 0, newDisplays, 0, Displays.length);
        newDisplays [Displays.length] = display;
        Displays = newDisplays;
    }
}

/**
 * Releases any internal resources back to the operating
 * system and clears all fields except the device handle.
 * <p>
 * Disposes all shells which are currently open on the display.
 * After this method has been invoked, all related related shells
 * will answer <code>true</code> when sent the message
 * <code>isDisposed()</code>.
 * </p><p>
 * When a device is destroyed, resources that were acquired
 * on behalf of the programmer need to be returned to the
 * operating system.  For example, if the device allocated a
 * font to be used as the system font, this font would be
 * freed in <code>release</code>.  Also,to assist the garbage
 * collector and minimize the amount of memory that is not
 * reclaimed when the programmer keeps a reference to a
 * disposed device, all fields except the handle are zero'd.
 * The handle is needed by <code>destroy</code>.
 * </p>
 * This method is called before <code>destroy</code>.
 *
 * @see Device#dispose
 * @see #destroy
 */
protected void release () {
    disposing = true;
    sendEvent (DWT.Dispose, new Event ());
    Shell [] shells = getShells ();
    for (int i=0; i<shells.length; i++) {
        Shell shell = shells [i];
        if (!shell.isDisposed ()) shell.dispose ();
    }
    if (tray !is null) tray.dispose ();
    tray = null;
    while (readAndDispatch ()) {}
    if (disposeList !is null) {
        for (int i=0; i<disposeList.length; i++) {
            if (disposeList [i] !is null) disposeList [i].run ();
        }
    }
    disposeList = null;
    synchronizer.releaseSynchronizer ();
    synchronizer = null;
    releaseDisplay ();
    super.release ();
}

void releaseDisplay () {
    /* Release the System Images */
    if (errorImage !is null) errorImage.dispose ();
    if (infoImage !is null) infoImage.dispose ();
    if (warningImage !is null) warningImage.dispose ();
    errorImage = infoImage = warningImage = null;

    currentCaret = null;

    /* Release Timers */
    if (hoverTimer !is null) timerExec(-1, hoverTimer);
    hoverTimer = null;
    if (caretTimer !is null) timerExec(-1, caretTimer);
    caretTimer = null;
    if (nsTimers !is null) {
        for (int i=0; i<nsTimers.length; i++) {
            if (nsTimers [i] !is null) {
                nsTimers [i].invalidate();
                nsTimers [i].release();
            }
        }
    }
    nsTimers = null;
    if (timerDelegate !is null) timerDelegate.release();
    timerDelegate = null;

    /* Release the System Cursors */
    for (int i = 0; i < cursors.length; i++) {
        if (cursors [i] !is null) cursors [i].dispose ();
    }
    cursors = null;

    /* Release default fonts */
    if (buttonFont !is null) buttonFont.release ();
    if (popUpButtonFont !is null) popUpButtonFont.release ();
    if (textFieldFont !is null) textFieldFont.release ();
    if (secureTextFieldFont !is null) secureTextFieldFont.release ();
    if (searchFieldFont !is null) searchFieldFont.release ();
    if (comboBoxFont !is null) comboBoxFont.release ();
    if (sliderFont !is null) sliderFont.release ();
    if (scrollerFont !is null) scrollerFont.release ();
    if (textViewFont !is null) textViewFont.release ();
    if (tableViewFont !is null) tableViewFont.release ();
    if (outlineViewFont !is null) outlineViewFont.release ();
    if (datePickerFont !is null) datePickerFont.release ();
    if (boxFont !is null) boxFont.release ();
    if (tabViewFont !is null) tabViewFont.release ();
    if (progressIndicatorFont !is null) progressIndicatorFont.release ();
    buttonFont = popUpButtonFont = textFieldFont = secureTextFieldFont = null;
    searchFieldFont = comboBoxFont = sliderFont = scrollerFont;
    textViewFont = tableViewFont = outlineViewFont = datePickerFont = null;
    boxFont = tabViewFont = progressIndicatorFont = null;

    /* Release Dock image */
    if (dockImage !is null) dockImage.release();
    dockImage = null;

    if (screenWindow !is null) screenWindow.release();
    screenWindow = null;

    if (needsDisplay !is null) needsDisplay.release();
    if (needsDisplayInRect !is null) needsDisplayInRect.release();
    if (isPainting !is null) isPainting.release();
    needsDisplay = needsDisplayInRect = isPainting = null;

    modalShells = null;
    menuBar = null;
    menus = null;

    if (markedAttributes !is null) markedAttributes.release();
    markedAttributes = null;

    if (oldCursorSetProc !is null) {
        objc.Method method = OS.class_getInstanceMethod(OS.class_NSCursor, OS.sel_set);
        OS.method_setImplementation(method, oldCursorSetProc);
    }

    deadKeyState = null;

    if (settingsDelegate !is null) {
        NSNotificationCenter.defaultCenter().removeObserver(settingsDelegate);
        settingsDelegate.release();
    }
    settingsDelegate = null;

    // Clear the menu bar if we created it.
    if (!isEmbedded) {
        //remove all existing menu items except the application menu
        NSMenu menubar = application.mainMenu();
        NSInteger count = menubar.numberOfItems();
        while (count > 1) {
            menubar.removeItemAtIndex(count - 1);
            count--;
        }
    }

    // The autorelease pool is cleaned up when we call NSApplication.terminate().

    if (application !is null && applicationClass !is null) {
        OS.object_setClass (application.id, applicationClass);
    }
    application = null;
    applicationClass = null;

    if (runLoopObserver !is null) {
        OS.CFRunLoopObserverInvalidate (runLoopObserver);
        OS.CFRelease (runLoopObserver);
    }
    runLoopObserver = null;
}

void removeContext (GCData context) {
    if (contexts is null) return;
    int count = 0;
    for (int i = 0; i < contexts.length; i++) {
        if (contexts[i] !is null) {
            if (contexts [i] is context) {
                contexts[i] = null;
            } else {
                count++;
            }
        }
    }
    if (count is 0) contexts = null;
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when an event of the given type occurs anywhere in
 * a widget. The event type is one of the event constants defined
 * in class <code>DWT</code>.
 *
 * @param eventType the type of event to listen for
 * @param listener the listener which should no longer be notified when the event occurs
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Listener
 * @see DWT
 * @see #addFilter
 * @see #addListener
 *
 * @since 3.0
 */
public void removeFilter (int eventType, Listener listener) {
    checkDevice ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (filterTable is null) return;
    filterTable.unhook (eventType, listener);
    if (filterTable.size () is 0) filterTable = null;
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when an event of the given type occurs. The event type
 * is one of the event constants defined in class <code>DWT</code>.
 *
 * @param eventType the type of event to listen for
 * @param listener the listener which should no longer be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see Listener
 * @see DWT
 * @see #addListener
 *
 * @since 2.0
 */
public void removeListener (int eventType, Listener listener) {
    checkDevice ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (eventType, listener);
}

Widget removeWidget (NSObject view) {
    if (view is null) return null;
    void* jniRef;
    OS.object_getInstanceVariable(view.id, SWT_OBJECT, jniRef);
    if (jniRef is null) return null;
    Widget widget = cast(Widget)OS.JNIGetObject(jniRef);
    OS.object_setInstanceVariable(view.id, SWT_OBJECT, null);
    return widget;
}

void removeMenu (Menu menu) {
    if (menus is null) return;
    for (int i = 0; i < menus.length; i++) {
        if (menus [i] is menu) {
            menus[i] = null;
            break;
        }
    }
}

void removePool () {
    NSAutoreleasePool pool = pools [poolCount - 1];
    pools [--poolCount] = null;
    if (poolCount is 0) {
        NSMutableDictionary dictionary = NSThread.currentThread().threadDictionary();
        dictionary.removeObjectForKey(NSString.stringWith("SWT_NSAutoreleasePool"));
    }
    pool.release ();
}

void removePopup (Menu menu) {
    if (popups is null) return;
    for (int i=0; i<popups.length; i++) {
        if (popups [i] is menu) {
            popups [i] = null;
            return;
        }
    }
}

bool runAsyncMessages (bool all) {
    return synchronizer.runAsyncMessages (all);
}

bool runContexts () {
    if (contexts !is null) {
        for (int i = 0; i < contexts.length; i++) {
            if (contexts[i] !is null && contexts[i].flippedContext !is null) {
                contexts[i].flippedContext.flushGraphics();
            }
        }
    }
    return false;
}

bool runDeferredEvents () {
    bool run = false;
    /*
     * Run deferred events.  This code is always
     * called  in the Display's thread so it must
     * be re-enterant need not be synchronized.
     */
    while (eventQueue !is null) {

        /* Take an event off the queue */
        Event event = eventQueue [0];
        if (event is null) break;
        int length_ = eventQueue.length;
        System.arraycopy (eventQueue, 1, eventQueue, 0, --length_);
        eventQueue [length_] = null;

        /* Run the event */
        Widget widget = event.widget;
        if (widget !is null && !widget.isDisposed ()) {
            Widget item = event.item;
            if (item is null || !item.isDisposed ()) {
            run = true;
                widget.notifyListeners (event.type, event);
            }
        }

        /*
         * At this point, the event queue could
         * be null due to a recursive invokation
         * when running the event.
         */
    }

    /* Clear the queue */
    eventQueue = null;
    return run;
}

bool runPaint () {
    if (needsDisplay is null && needsDisplayInRect is null) return false;
    if (needsDisplay !is null) {
        NSUInteger count = needsDisplay.count();
        for (int i = 0; i < count; i++) {
            OS.objc_msgSend(needsDisplay.objectAtIndex(i).id, OS.sel_setNeedsDisplay_, true);
        }
        needsDisplay.release();
        needsDisplay = null;
    }
    if (needsDisplayInRect !is null) {
        NSUInteger count = needsDisplayInRect.count();
        for (int i = 0; i < count; i+=2) {
            NSValue value = new NSValue(needsDisplayInRect.objectAtIndex(i+1));
            OS.objc_msgSend(needsDisplayInRect.objectAtIndex(i).id, OS.sel_setNeedsDisplayInRect_, value.rectValue());
        }
        needsDisplayInRect.release();
        needsDisplayInRect = null;
    }
    return true;
}

bool runPopups () {
    if (popups is null) return false;
    bool result = false;
    while (popups !is null) {
        Menu menu = popups [0];
        if (menu is null) break;
        int length_ = popups.length;
        System.arraycopy (popups, 1, popups, 0, --length_);
        popups [length_] = null;
        runDeferredEvents ();
        if (!menu.isDisposed ()) menu._setVisible (true);
        result = true;
    }
    popups = null;
    return result;
}

bool runSettings () {
    if (!runSettings_) return false;
    runSettings_ = false;
    initColors ();
    sendEvent (DWT.Settings, null);
    Shell [] shells = getShells ();
    for (int i=0; i<shells.length; i++) {
        Shell shell = shells [i];
        if (!shell.isDisposed ()) {
            shell.redraw (true);
            shell.layout (true, true);
        }
    }
    return true;
}

bool runTimers () {
    if (timerList is null) return false;
    bool result = false;
    for (int i=0; i<timerList.length; i++) {
        if (nsTimers [i] is null && timerList [i] !is null) {
            Runnable runnable = timerList [i];
            timerList [i] = null;
            if (runnable !is null) {
                result = true;
                runnable.run ();
            }
        }
    }
    return result;
}

void sendEvent (int eventType, Event event) {
    if (eventTable is null && filterTable is null) {
        return;
    }
    if (event is null) event = new Event ();
    event.display = this;
    event.type = eventType;
    if (event.time == 0) event.time = getLastEventTime ();
    sendEvent(eventTable, event);
}

void sendEvent (EventTable table, Event event) {
    try {
        sendEventCount++;
        if (!filterEvent (event)) {
            if (table !is null) table.sendEvent (event);
        }
    } finally {
        sendEventCount--;
    }
}

static NSString getAppName() {
    NSString name = null;
    int pid = OS.getpid ();
    char* ptr = OS.getenv (ascii (Format("APP_NAME_{}", pid)));
    if (ptr !is null) name = NSString.stringWithUTF8String(ptr);
    if (name is null && APP_NAME !is null) name = NSString.stringWith(APP_NAME);
    if (name is null) {
        cocoa.id value = NSBundle.mainBundle().objectForInfoDictionaryKey(NSString.stringWith("CFBundleName"));
        if (value !is null) {
            name = new NSString(value);
        }
    }
    if (name is null) name = NSString.stringWith("SWT");
    return name;
}

/**
 * On platforms which support it, sets the application name
 * to be the argument. On Motif, for example, this can be used
 * to set the name used for resource lookup.  Specifying
 * <code>null</code> for the name clears it.
 *
 * @param name the new app name or <code>null</code>
 */
public static void setAppName (String name) {
    APP_NAME = name;
}

//TODO use custom timer instead of timerExec
Runnable hoverTimer;

class HoverTimer : Runnable
{
    public void run () {
        if (currentControl !is null && !currentControl.isDisposed()) {
            currentControl.sendMouseEvent (NSApplication.sharedApplication().currentEvent(), DWT.MouseHover, trackingControl !is null && !trackingControl.isDisposed());
        }
    }
}

//TODO - use custom timer instead of timerExec
Runnable caretTimer;

class CaretTimer : Runnable
{
    public void run () {
        if (currentCaret !is null) {
            if (this.outer.currentCaret is null || this.outer.currentCaret.isDisposed()) return;
            if (currentCaret.blinkCaret ()) {
                int blinkRate = currentCaret.blinkRate;
                if (blinkRate !is 0) timerExec (blinkRate, this);
            } else {
                currentCaret = null;
            }
        }
    }
}

//TODO - use custom timer instead of timerExec
Runnable defaultButtonTimer;

class DefaultButtonTimer : Runnable {
    public void run() {
        if (isDisposed ()) return;
        Shell shell = getActiveShell();
        if (shell !is null && !shell.isDisposed()) {
            Button defaultButton = shell.defaultButton;
            if (defaultButton !is null && !defaultButton.isDisposed()) {
                NSView view = defaultButton.view;
                view.display();
            }
        }
        if (isDisposed ()) return;
        if (hasDefaultButton()) timerExec(DEFAULT_BUTTON_INTERVAL, this);
    }
}

void setCurrentCaret (Caret caret) {
    currentCaret = caret;
    int blinkRate = currentCaret !is null ? currentCaret.blinkRate : -1;
    timerExec (blinkRate, caretTimer);
}

void setCursor (Control control) {
    Cursor cursor = null;
    if (control !is null && !control.isDisposed()) cursor = control.findCursor ();
    if (cursor is null) {
        NSWindow window = application.keyWindow();
        if (window !is null) {
            if (window.areCursorRectsEnabled ()) {
                window.disableCursorRects ();
                window.enableCursorRects ();
            }
            return;
        }
        cursor = getSystemCursor (DWT.CURSOR_ARROW);
    }
    lockCursor = false;
    cursor.handle.set ();
    lockCursor = true;
}

/**
 * Sets the location of the on-screen pointer relative to the top left corner
 * of the screen.  <b>Note: It is typically considered bad practice for a
 * program to move the on-screen pointer location.</b>
 *
 * @param x the new x coordinate for the cursor
 * @param y the new y coordinate for the cursor
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 2.1
 */
public void setCursorLocation (int x, int y) {
    checkDevice ();
    CGPoint pt = CGPoint ();
    pt.x = x;  pt.y = y;
    Carbon.CGWarpMouseCursorPosition (pt);
}

/**
 * Sets the location of the on-screen pointer relative to the top left corner
 * of the screen.  <b>Note: It is typically considered bad practice for a
 * program to move the on-screen pointer location.</b>
 *
 * @param point new position
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_NULL_ARGUMENT - if the point is null
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 2.0
 */
public void setCursorLocation (Point point) {
    checkDevice ();
    if (point is null) error (DWT.ERROR_NULL_ARGUMENT);
    setCursorLocation (point.x, point.y);
}

/**
 * Sets the application defined property of the receiver
 * with the specified name to the given argument.
 * <p>
 * Applications may have associated arbitrary objects with the
 * receiver in this fashion. If the objects stored in the
 * properties need to be notified when the display is disposed
 * of, it is the application's responsibility provide a
 * <code>disposeExec()</code> handler which does so.
 * </p>
 *
 * @param key the name of the property
 * @param value the new value for the property
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the key is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getData(String)
 * @see #disposeExec(Runnable)
 */
public void setData (String key, Object value) {
    checkDevice ();
    // DWT extension: allow null for zero length string
    //if (key is null) error (DWT.ERROR_NULL_ARGUMENT);

    if (key.equals (ADD_WIDGET_KEY)) {
        ArrayWrapperObject wrap = cast(ArrayWrapperObject) value;

        if (wrap is null)
            DWT.error(DWT.ERROR_INVALID_ARGUMENT, null, " []");

        Object [] data = wrap.array;
        NSObject object = cast(NSObject)data [0];
        Widget widget = cast(Widget)data [1];
        if (widget is null) {
            removeWidget (object);
        } else {
            addWidget (object, widget);
        }
    }

    /* Remove the key/value pair */
    if (value is null) {
        if (keys is null) return;
        int index = 0;
        while (index < keys.length && !keys [index].equals (key)) index++;
        if (index is keys.length) return;
        if (keys.length is 1) {
            keys = null;
            values = null;
        } else {
            String [] newKeys = new String [keys.length - 1];
            Object [] newValues = new Object [values.length - 1];
            System.arraycopy (keys, 0, newKeys, 0, index);
            System.arraycopy (keys, index + 1, newKeys, index, newKeys.length - index);
            System.arraycopy (values, 0, newValues, 0, index);
            System.arraycopy (values, index + 1, newValues, index, newValues.length - index);
            keys = newKeys;
            values = newValues;
        }
        return;
    }

    /* Add the key/value pair */
    if (keys is null) {
        keys = [key];
        values = [value];
        return;
    }
    for (int i=0; i<keys.length; i++) {
        if (keys [i].equals (key)) {
            values [i] = value;
            return;
        }
    }
    String [] newKeys = new String [keys.length + 1];
    Object [] newValues = new Object [values.length + 1];
    System.arraycopy (keys, 0, newKeys, 0, keys.length);
    System.arraycopy (values, 0, newValues, 0, values.length);
    newKeys [keys.length] = key;
    newValues [values.length] = value;
    keys = newKeys;
    values = newValues;
}

void setMenuBar (Menu menu) {
    if (menu is menuBar) return;
    menuBar = menu;
    //remove all existing menu items except the application menu
    NSMenu menubar = application.mainMenu();
    /*
    * For some reason, NSMenu.cancelTracking() does not dismisses
    * the menu right away when the menu bar is set in a stacked
    * event loop. The fix is to use CancelMenuTracking() instead.
    */
//  menubar.cancelTracking();
    OS.CancelMenuTracking (OS.AcquireRootMenu (), true, 0);
    NSInteger count = menubar.numberOfItems();
    while (count > 1) {
        menubar.removeItemAtIndex(count - 1);
        count--;
    }
    //set parent of each item to NULL and add them to menubar
    if (menu !is null) {
        MenuItem[] items = menu.getItems();
        for (int i = 0; i < items.length; i++) {
        MenuItem item = items[i];
        NSMenuItem nsItem = item.nsItem;
        nsItem.setMenu(null);
        menubar.addItem(nsItem);

        /*
        * Bug in Cocoa: Calling NSMenuItem.setEnabled() for menu item of a menu bar only
        * works when the menu bar is the current menu bar.  The underline OS menu does get
        * enabled/disable when that menu is set later on.  The fix is to toggle the
        * item enabled state to force the underline menu to be updated.
        */
        bool enabled = menu.getEnabled () && item.getEnabled ();
        nsItem.setEnabled(!enabled);
        nsItem.setEnabled(enabled);
        }
    }
}

void setModalShell (Shell shell) {
    if (modalShells is null) modalShells = new Shell [4];
    int index = 0, length = modalShells.length;
    while (index < length) {
        if (modalShells [index] is shell) return;
        if (modalShells [index] is null) break;
        index++;
    }
    if (index is length) {
        Shell [] newModalShells = new Shell [length + 4];
        System.arraycopy (modalShells, 0, newModalShells, 0, length);
        modalShells = newModalShells;
    }
    modalShells [index] = shell;
    Shell [] shells = getShells ();
    for (int i=0; i<shells.length; i++) shells [i].updateModal ();
}

/**
 * Sets the application defined, display specific data
 * associated with the receiver, to the argument.
 * The <em>display specific data</em> is a single,
 * unnamed field that is stored with every display.
 * <p>
 * Applications may put arbitrary objects in this field. If
 * the object stored in the display specific data needs to
 * be notified when the display is disposed of, it is the
 * application's responsibility provide a
 * <code>disposeExec()</code> handler which does so.
 * </p>
 *
 * @param data the new display specific data
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getData()
 * @see #disposeExec(Runnable)
 */
public void setData (Object data) {
    checkDevice ();
    this.data = data;
}

/**
 * Sets the synchronizer used by the display to be
 * the argument, which can not be null.
 *
 * @param synchronizer the new synchronizer for the display (must not be null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the synchronizer is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_FAILED_EXEC - if an exception occurred while running an inter-thread message</li>
 * </ul>
 */
public void setSynchronizer (Synchronizer synchronizer) {
    checkDevice ();
    if (synchronizer is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (synchronizer is this.synchronizer) return;
    Synchronizer oldSynchronizer;
    synchronized (Device.classinfo) {
        oldSynchronizer = this.synchronizer;
        this.synchronizer = synchronizer;
    }
    if (oldSynchronizer !is null) {
        oldSynchronizer.runAsyncMessages(true);
    }
}

/**
 * Causes the user-interface thread to <em>sleep</em> (that is,
 * to be put in a state where it does not consume CPU cycles)
 * until an event is received or it is otherwise awakened.
 *
 * @return <code>true</code> if an event requiring dispatching was placed on the queue.
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #wake
 */
public bool sleep () {
    checkDevice ();
    if (getMessageCount () !is 0) return true;
    try {
        addPool();
        allowTimers = runAsyncMessages = false;
        NSRunLoop.currentRunLoop().runMode(OS.NSDefaultRunLoopMode, NSDate.distantFuture());
        allowTimers = runAsyncMessages = true;
    } finally {
        removePool();
    }
    return true;
}

int sourceProc (int info) {
    return 0;
}

/**
 * Causes the <code>run()</code> method of the runnable to
 * be invoked by the user-interface thread at the next
 * reasonable opportunity. The thread which calls this method
 * is suspended until the runnable completes.  Specifying <code>null</code>
 * as the runnable simply wakes the user-interface thread.
 * <p>
 * Note that at the time the runnable is invoked, widgets
 * that have the receiver as their display may have been
 * disposed. Therefore, it is necessary to check for this
 * case inside the runnable before accessing the widget.
 * </p>
 *
 * @param runnable code to run on the user-interface thread or <code>null</code>
 *
 * @exception DWTException <ul>
 *    <li>ERROR_FAILED_EXEC - if an exception occurred when executing the runnable</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #asyncExec
 */
public void syncExec (Runnable runnable) {
    Synchronizer synchronizer;
    synchronized (Device.classinfo) {
        if (isDisposed ()) error (DWT.ERROR_DEVICE_DISPOSED);
        synchronizer = this.synchronizer;
    }
    synchronizer.syncExec (runnable);
}

/**
 * Causes the <code>run()</code> method of the runnable to
 * be invoked by the user-interface thread after the specified
 * number of milliseconds have elapsed. If milliseconds is less
 * than zero, the runnable is not executed.
 * <p>
 * Note that at the time the runnable is invoked, widgets
 * that have the receiver as their display may have been
 * disposed. Therefore, it is necessary to check for this
 * case inside the runnable before accessing the widget.
 * </p>
 *
 * @param milliseconds the delay before running the runnable
 * @param runnable code to run on the user-interface thread
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the runnable is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #asyncExec
 */
public void timerExec (int milliseconds, Runnable runnable) {
    checkDevice ();
    //TODO - remove a timer, reschedule a timer not tested
    if (runnable is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (timerList is null) timerList = new Runnable [4];
    if (nsTimers is null) nsTimers = new NSTimer [4];
    int index = 0;
    while (index < timerList.length) {
        if (timerList [index] is runnable) break;
        index++;
    }
    if (index !is timerList.length) {
        NSTimer timer = nsTimers [index];
        if (timer is null) {
            timerList [index] = null;
        } else {
            if (milliseconds < 0) {
                timer.invalidate();
            timer.release();
                timerList [index] = null;
                nsTimers [index] = null;
            } else {
                timer.setFireDate(NSDate.dateWithTimeIntervalSinceNow (milliseconds / 1000.0));
            }
            return;
        }
    }
    if (milliseconds < 0) return;
    index = 0;
    while (index < timerList.length) {
        if (timerList [index] is null) break;
        index++;
    }
    if (index is timerList.length) {
        Runnable [] newTimerList = new Runnable [timerList.length + 4];
        SimpleType!(Runnable).arraycopy (timerList, 0, newTimerList, 0, timerList.length);
        timerList = newTimerList;
        NSTimer [] newTimerIds = new NSTimer [nsTimers.length + 4];
        System.arraycopy (nsTimers, 0, newTimerIds, 0, nsTimers.length);
        nsTimers = newTimerIds;
    }
    NSNumber userInfo = NSNumber.numberWithInt(index);
    NSTimer timer = NSTimer.scheduledTimerWithTimeInterval(milliseconds / 1000.0, timerDelegate, OS.sel_timerProc_, userInfo, false);
    NSRunLoop.currentRunLoop().addTimer(timer, OS.NSEventTrackingRunLoopMode);
    timer.retain();
    if (timer !is null) {
        nsTimers [index] = timer;
        timerList [index] = runnable;
    }
}

objc.id timerProc (objc.id id, objc.SEL sel, objc.id timerID) {
    NSTimer timer = new NSTimer (timerID);
    NSNumber number = new NSNumber(timer.userInfo());
    int index = number.intValue();
    if (timerList is null) return null;
    if (0 <= index && index < timerList.length) {
        if (allowTimers) {
            Runnable runnable = timerList [index];
            timerList [index] = null;
            nsTimers [index] = null;
            if (runnable !is null) runnable.run ();
        } else {
            nsTimers [index] = null;
            wakeThread ();
        }
    }
    timer.invalidate();
    timer.release();
    return null;
}

/**
 * Forces all outstanding paint requests for the display
 * to be processed before this method returns.
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see Control#update()
 */
public void update () {
    checkDevice ();
    Shell [] shells = getShells ();
    for (int i=0; i<shells.length; i++) {
        Shell shell = shells [i];
        if (!shell.isDisposed ()) shell.update (true);
    }
}

void updateDefaultButton () {
    timerExec(hasDefaultButton() ? DEFAULT_BUTTON_INTERVAL : -1, defaultButtonTimer);
}

void updateQuitMenu () {
    bool enabled = true;
    Shell [] shells = getShells ();
    int mask = DWT.PRIMARY_MODAL | DWT.APPLICATION_MODAL | DWT.SYSTEM_MODAL;
    for (int i=0; i<shells.length; i++) {
        Shell shell = shells [i];
        if ((shell.style & mask) !is 0 && shell.isVisible ()) {
            enabled = false;
            break;
        }
    }

    NSMenu mainmenu = application.mainMenu();
    NSMenuItem appitem = mainmenu.itemAtIndex(0);
    if (appitem !is null) {
        NSMenu sm = appitem.submenu();

        // Normally this would be sel_terminate_ but we changed it so terminate: doesn't kill the app.
        NSInteger quitIndex = sm.indexOfItemWithTarget(applicationDelegate, OS.sel_quitRequested_);

        if (quitIndex !is -1) {
            NSMenuItem quitItem = sm.itemAtIndex(quitIndex);
            quitItem.setEnabled(enabled);
        }
    }
}


/**
 * If the receiver's user-interface thread was <code>sleep</code>ing,
 * causes it to be awakened and start running again. Note that this
 * method may be called from any thread.
 *
 * @exception DWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #sleep
 */
public void wake () {
    synchronized (Device.classinfo) {
        if (isDisposed ()) error (DWT.ERROR_DEVICE_DISPOSED);
        if (thread is Thread.getThis ()) return;
        wakeThread ();
    }
}

void wakeThread () {
//new pool?
    NSObject object = (new NSObject()).alloc().init();
    object.performSelectorOnMainThread(OS.sel_release, null, false);
}

Control findControl (bool checkTrim) {
    return findControl(checkTrim, null);
}

Control findControl (bool checkTrim, NSView[] hitView) {
    NSView view = null;
    NSPoint screenLocation = NSEvent.mouseLocation();
    NSArray windows = application.orderedWindows();
    for (NSUInteger i = 0, count = windows.count(); i < count && view is null; i++) {
        NSWindow window = new NSWindow(windows.objectAtIndex(i));
        NSView contentView = window.contentView();
        if (contentView !is null && OS.NSPointInRect(screenLocation, window.frame())) {
            NSPoint location = window.convertScreenToBase(screenLocation);
            view = contentView.hitTest (location);
            if (view is null && !checkTrim) {
                view = contentView;
            }
            break;
        }
    }
    Control control = null;
    if (view !is null) {
        do {
            objc.id vi = view.id;
            Widget widget = getWidget (view);
            if (cast(Control) widget) {
                control = cast(Control)widget;
                break;
            }
            view = view.superview();
        } while (view !is null);
    }
    if (checkTrim) {
        if (control !is null && control.isTrim (view)) control = null;
    }
    if (control !is null && hitView !is null) hitView[0] = view;
    return control;
}

void finishLaunching (objc.id id, objc.SEL sel) {
    /*
    * [NSApplication finishLaunching] cannot run multiple times otherwise
    * multiple main menus are added.
    */
    if (launched) return;
    launched = true;
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    OS.objc_msgSendSuper(&super_struct, sel);
}

void applicationDidBecomeActive (objc.id id, objc.SEL sel, objc.id notification) {
    checkFocus();
    checkEnterExit(findControl(true), null, false);
}

void applicationDidResignActive (objc.id id, objc.SEL sel, objc.id notification) {
    checkFocus();
    checkEnterExit(null, null, false);
}

objc.id applicationNextEventMatchingMask (objc.id id, objc.SEL sel, NSUInteger mask, objc.id expiration, objc.id mode, bool dequeue) {
    if (dequeue !is 0 && trackingControl !is null && !trackingControl.isDisposed()) runDeferredEvents();
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    objc.id result = OS.objc_msgSendSuper(&super_struct, sel, mask, expiration, mode, dequeue !is 0);
    if (result !is null) {
        if (dequeue !is 0 && trackingControl !is null && !trackingControl.isDisposed()) {
            applicationSendTrackingEvent(new NSEvent(result), trackingControl);
        }
    }
    return result;
}

void applicationSendTrackingEvent (NSEvent nsEvent, Control trackingControl) {
    NSEventType type = nsEvent.type();
    switch (type) {
        case OS.NSLeftMouseDown:
        case OS.NSRightMouseDown:
        case OS.NSOtherMouseDown:
            trackingControl.sendMouseEvent (nsEvent, DWT.MouseDown, true);
            break;
        case OS.NSLeftMouseUp:
        case OS.NSRightMouseUp:
        case OS.NSOtherMouseUp:
            checkEnterExit (findControl (true), nsEvent, true);
            if (trackingControl.isDisposed()) return;
            trackingControl.sendMouseEvent (nsEvent, DWT.MouseUp, true);
            break;
        case OS.NSLeftMouseDragged:
        case OS.NSRightMouseDragged:
        case OS.NSOtherMouseDragged:
            checkEnterExit (trackingControl, nsEvent, true);
            if (trackingControl.isDisposed()) return;
            //FALL THROUGH
        case OS.NSMouseMoved:
            trackingControl.sendMouseEvent (nsEvent, DWT.MouseMove, true);
            break;
    default:
    }
}

void applicationSendEvent (objc.id id, objc.SEL sel, objc.id event) {
    NSEvent nsEvent = new NSEvent(event);
    NSWindow window = nsEvent.window ();
    NSEventType type = nsEvent.type ();
    bool down = false;
    switch (type) {
        case OS.NSLeftMouseDown:
        case OS.NSRightMouseDown:
        case OS.NSOtherMouseDown:
            down = true;
        case OS.NSLeftMouseUp:
        case OS.NSRightMouseUp:
        case OS.NSOtherMouseUp:
        case OS.NSLeftMouseDragged:
        case OS.NSRightMouseDragged:
        case OS.NSOtherMouseDragged:
        case OS.NSMouseMoved:
        case OS.NSMouseEntered:
        case OS.NSMouseExited:
        case OS.NSKeyDown:
        case OS.NSKeyUp:
        case OS.NSScrollWheel:
            if (window !is null) {
                Shell shell = cast(Shell) getWidget (window.id);
                if (shell !is null) {
                    Shell modalShell = shell.getModalShell ();
                    if (modalShell !is null) {
                        if (down) {
                            if (!application.isActive()) {
                                application.activateIgnoringOtherApps(true);
                            }
                            NSRect rect = window.contentRectForFrameRect(window.frame());
                            NSPoint pt = window.convertBaseToScreen(nsEvent.locationInWindow());
                            if (OS.NSPointInRect(pt, rect)) beep ();
                        }
                        return;
                    }
                }
            }
            break;
        default:
    }
    sendEvent_ = true;

    /*
     * Feature in Cocoa. The help key triggers context-sensitive help but doesn't get forwarded to the window as a key event.
     * If the event is destined for the key window, is the help key, and is an NSKeyDown, send it directly to the window first.
     */
    if (window !is null && window.isKeyWindow() && nsEvent.type() is OS.NSKeyDown && (nsEvent.modifierFlags() & OS.NSHelpKeyMask) !is 0)    {
        window.sendEvent(nsEvent);
    }

    /*
     * Feature in Cocoa. NSKeyUp events are not delivered to the window if the command key is down.
     * If the event is destined for the key window, and it's a key up and the command key is down, send it directly to the window.
     */
    if (window !is null && window.isKeyWindow() && nsEvent.type() is OS.NSKeyUp && (nsEvent.modifierFlags() & OS.NSCommandKeyMask) !is 0)   {
        window.sendEvent(nsEvent);
    } else {
        objc.objc_super super_struct = objc.objc_super ();
        super_struct.receiver = id;
        super_struct.super_class = cast(objc.Class) OS.objc_msgSend (id, OS.sel_superclass);
        OS.objc_msgSendSuper (&super_struct, sel, event);
    }
    sendEvent_ = false;
}

void applicationWillFinishLaunching (objc.id id, objc.SEL sel, objc.id notification) {
    bool loaded = false;
    // FIXME is this code really necessary - Jacob Carlborg
    // NSBundle bundle = NSBundle.bundleWithIdentifier(NSString.stringWith("com.apple.JavaVM"));
    // NSDictionary dict = NSDictionary.dictionaryWithObject(applicationDelegate, NSString.stringWith("NSOwner"));
    // NSString path = bundle.pathForResource(NSString.stringWith("DefaultApp"), NSString.stringWith("nib"));
    // if (!loaded) loaded = path !is null && NSBundle.loadNibFile(path, dict, null);
    // if (!loaded) {
    //     NSString resourcePath = bundle.resourcePath();
    //     path = resourcePath !is null ? resourcePath.stringByAppendingString(NSString.stringWith("/English.lproj/DefaultApp.nib")) : null;
    //     loaded = path !is null && NSBundle.loadNibFile(path, dict, null);
    // }
    // if (!loaded) {
    //     path = NSString.stringWith(System.getProperty("java.home") ~ "/../Resources/English.lproj/DefaultApp.nib");
    //     loaded = path !is null && NSBundle.loadNibFile(path, dict, null);
    // }
    if (!loaded) {
        createMainMenu();
    }
    //replace %@ with application name
    NSMenu mainmenu = application.mainMenu();
    NSMenuItem appitem = mainmenu.itemAtIndex(0);
    if (appitem !is null) {
        NSString name = getAppName();
        NSString match = NSString.stringWith("%@");
        appitem.setTitle(name);
        NSMenu sm = appitem.submenu();
        NSArray ia = sm.itemArray();
        for(int i = 0; i < ia.count(); i++) {
            NSMenuItem ni = new NSMenuItem(ia.objectAtIndex(i));
            NSString title = ni.title().stringByReplacingOccurrencesOfString(match, name);
            ni.setTitle(title);
        }
        sendEvent_ = true;

        NSInteger quitIndex = sm.indexOfItemWithTarget(applicationDelegate, OS.sel_terminate_);

        if (quitIndex !is -1) {
            NSMenuItem quitItem = sm.itemAtIndex(quitIndex);
            quitItem.setAction(OS.sel_quitRequested_);
        }
    }
}

private:
extern (C):

static objc.id applicationProc2(objc.id id, objc.SEL sel) {
    //TODO optimize getting the display
    Display display = getCurrent ();
    if (display is null) return null;
    if (sel is OS.sel_isRunning) {
        // #245724: [NSApplication isRunning] must return true to allow the AWT to load correctly.
        return display.isDisposed() ? cast(objc.id)0 : cast(objc.id)1;
    }
    if (sel is OS.sel_finishLaunching) {
        display.finishLaunching (id, sel);
    }
    return null;
}

static objc.id applicationProc3(objc.id id, objc.SEL sel, objc.id arg0) {
    //TODO optimize getting the display
    Display display = getCurrent ();
    if (display is null) return null;
    NSApplication application = display.application;
    if (sel is OS.sel_sendEvent_) {
        display.applicationSendEvent (id, sel, arg0);
    } else if (sel is OS.sel_applicationWillFinishLaunching_) {
        display.applicationWillFinishLaunching(id, sel, arg0);
    } else if (sel is OS.sel_terminate_) {
    // Do nothing here -- without a definition of sel_terminate we get a warning dumped to the console.
    } else if (sel is OS.sel_orderFrontStandardAboutPanel_) {
//      application.orderFrontStandardAboutPanel(application);
    } else if (sel is OS.sel_hideOtherApplications_) {
        application.hideOtherApplications(application);
    } else if (sel is OS.sel_hide_) {
        application.hide(application);
    } else if (sel is OS.sel_unhideAllApplications_) {
        application.unhideAllApplications(application);
    } else if (sel is OS.sel_quitRequested_) {
        if (!display.disposing) {
            Event event = new Event ();
            display.sendEvent (DWT.Close, event);
            if (event.doit) {
                display.dispose();
            }
        }
    } else if (sel is OS.sel_applicationDidBecomeActive_) {
        display.applicationDidBecomeActive(id, sel, arg0);
    } else if (sel is OS.sel_applicationDidResignActive_) {
        display.applicationDidResignActive(id, sel, arg0);
    }
    return null;
}

static objc.id applicationProc6(objc.id id, objc.SEL sel, NSUInteger arg0, objc.id arg1, objc.id arg2, bool arg3) {
    //TODO optimize getting the display
    Display display = getCurrent ();
    if (display is null) return null;
    if (sel is OS.sel_nextEventMatchingMask_untilDate_inMode_dequeue_) {
        return display.applicationNextEventMatchingMask(id, sel, arg0, arg1, arg2, arg3);
    }
    return null;
}

static objc.id dialogProc3(objc.id id, objc.SEL sel, objc.id arg0) {
    void* jniRef;
    OS.object_getInstanceVariable(id, SWT_OBJECT, jniRef);
    if (jniRef is null) return null;
    if (sel is OS.sel_changeColor_) {
        ColorDialog dialog = cast(ColorDialog)OS.JNIGetObject(jniRef);
        if (jniRef is null) return null;
        dialog.changeColor(id, sel, arg0);
    } else if (sel is OS.sel_changeFont_) {
        FontDialog dialog = cast(FontDialog)OS.JNIGetObject(jniRef);
        if (dialog is null) return null;
        dialog.changeFont(id, sel, arg0);
    } else if (sel is OS.sel_sendSelection_) {
        FileDialog dialog = cast(FileDialog)OS.JNIGetObject(jniRef);
        if (dialog is null) return null;
        dialog.sendSelection(id, sel, arg0);
    } else if (sel is OS.sel_windowWillClose_) {
        Object object = OS.JNIGetObject(jniRef);
        if (cast(FontDialog) object) {
            (cast(FontDialog)object).windowWillClose(id, sel, arg0);
        } else if (cast(ColorDialog) object) {
            (cast(ColorDialog)object).windowWillClose(id, sel, arg0);
        }
    }
    return null;
}

static objc.id dialogProc4(objc.id id, objc.SEL sel, objc.id arg0, objc.id arg1) {
    void* jniRef;
    OS.object_getInstanceVariable(id, SWT_OBJECT, jniRef);
    if (jniRef is null) return null;
    if (sel is OS.sel_panel_shouldShowFilename_) {
        FileDialog dialog = cast(FileDialog)OS.JNIGetObject(jniRef);
        if (dialog is null) return null;
        return dialog.panel_shouldShowFilename(id, sel, arg0, arg1);
    }
    return null;
}

static objc.id dialogProc5(objc.id id, objc.SEL sel, objc.id arg0, objc.id arg1, objc.id arg2) {
    void* jniRef;
    OS.object_getInstanceVariable(id, SWT_OBJECT, jniRef);
    if (jniRef is null) return null;
    if (sel is OS.sel_panelDidEnd_returnCode_contextInfo_) {
        MessageBox dialog = cast(MessageBox)OS.JNIGetObject(jniRef);
        if (dialog is null) return null;
        dialog.panelDidEnd_returnCode_contextInfo(id, sel, arg0, arg1, arg2);
    }
    return null;
}

static objc.id fieldEditorProc3(objc.id id, objc.SEL sel, objc.id arg0) {
    Widget widget = null;
    NSView view = new NSView (id);
    do {
        widget = GetWidget (view.id);
        if (widget !is null) break;
        view = view.superview ();
    } while (view !is null);
    if (widget is null) return null;
    if (sel is OS.sel_keyDown_) {
        widget.keyDown (id, sel, arg0);
    } else if (sel is OS.sel_keyUp_) {
        widget.keyUp (id, sel, arg0);
    } else if (sel is OS.sel_flagsChanged_) {
        widget.flagsChanged(id, sel, arg0);
    } else if (sel is OS.sel_insertText_) {
        return widget.insertText (id, sel, arg0) ? cast(objc.id)1 : cast(objc.id)0;
    } else if (sel is OS.sel_doCommandBySelector_) {
        widget.doCommandBySelector (id, sel, cast(char*)arg0);
    } else if (sel is OS.sel_menuForEvent_) {
        return widget.menuForEvent (id, sel, arg0);
    } else if (sel is OS.sel_mouseDown_) {
        widget.mouseDown(id, sel, arg0);
    } else if (sel is OS.sel_mouseUp_) {
        widget.mouseUp(id, sel, arg0);
    } else if (sel is OS.sel_mouseMoved_) {
        widget.mouseMoved(id, sel, arg0);
    } else if (sel is OS.sel_mouseDragged_) {
        widget.mouseDragged(id, sel, arg0);
    } else if (sel is OS.sel_mouseEntered_) {
        widget.mouseEntered(id, sel, arg0);
    } else if (sel is OS.sel_mouseExited_) {
        widget.mouseExited(id, sel, arg0);
    } else if (sel is OS.sel_cursorUpdate_) {
        widget.cursorUpdate(id, sel, arg0);
    } else if (sel is OS.sel_rightMouseDown_) {
        widget.rightMouseDown(id, sel, arg0);
    } else if (sel is OS.sel_rightMouseDragged_) {
        widget.rightMouseDragged(id, sel, arg0);
    } else if (sel is OS.sel_rightMouseUp_) {
        widget.rightMouseUp(id, sel, arg0);
    } else if (sel is OS.sel_otherMouseDown_) {
        widget.otherMouseDown(id, sel, arg0);
    } else if (sel is OS.sel_otherMouseUp_) {
        widget.otherMouseUp(id, sel, arg0);
    } else if (sel is OS.sel_otherMouseDragged_) {
        widget.otherMouseDragged(id, sel, arg0);
    }
    return null;
}

static objc.id fieldEditorProc4(objc.id id, objc.SEL sel, objc.id arg0, objc.id arg1) {
    Widget widget = null;
    NSView view = new NSView (id);
    do {
        widget = GetWidget (view.id);
        if (widget !is null) break;
        view = view.superview ();
    } while (view !is null);
    return null;
}

static objc.id windowProc2(objc.id id, objc.SEL sel) {
    /*
    * Feature in Cocoa.  In Cocoa, the default button animation is done
    * in a separate thread that calls drawRect() and isOpaque() from
    * outside the UI thread.  This means that those methods, and application
    * code that runs as a result of those methods, must be thread safe.
    * In DWT, paint events must happen in the UI thread.  The fix is
    * to detect a non-UI thread and avoid the drawing. Instead, the
    * default button is animated by a timer.
    */
    if (!NSThread.isMainThread()) {
        if (sel is OS.sel_isOpaque) {
            return cast(objc.id)1;
        }
    }
    Widget widget = GetWidget(id);
    if (widget is null) return null;
    if (sel is OS.sel_sendSelection) {
        widget.sendSelection();
    } else if (sel is OS.sel_sendDoubleSelection) {
        widget.sendDoubleSelection();
    } else if (sel is OS.sel_sendVerticalSelection) {
        widget.sendVerticalSelection();
    } else if (sel is OS.sel_sendHorizontalSelection) {
        widget.sendHorizontalSelection();
    } else if (sel is OS.sel_sendSearchSelection) {
        widget.sendSearchSelection();
    } else if (sel is OS.sel_sendCancelSelection) {
        widget.sendCancelSelection();
    } else if (sel is OS.sel_acceptsFirstResponder) {
        return widget.acceptsFirstResponder(id, sel) ? cast(objc.id) 1 : null;
    } else if (sel is OS.sel_becomeFirstResponder) {
        return widget.becomeFirstResponder(id, sel) ? cast(objc.id) 1 : null;
    } else if (sel is OS.sel_resignFirstResponder) {
        return widget.resignFirstResponder(id, sel) ? cast(objc.id) 1 : null;
    } else if (sel is OS.sel_isOpaque) {
        return widget.isOpaque(id, sel) ? cast(objc.id)1 : cast(objc.id)0;
    } else if (sel is OS.sel_isFlipped) {
        return widget.isFlipped(id, sel) ? cast(objc.id)1 : cast(objc.id)0;
    } else if (sel is OS.sel_canBecomeKeyView) {
        return widget.canBecomeKeyView(id,sel) ? cast(objc.id)1 : cast(objc.id)0;
    } else if (sel is OS.sel_becomeKeyWindow) {
        widget.becomeKeyWindow(id, sel);
    } else if (sel is OS.sel_unmarkText) {
        //TODO not called?
    } else if (sel is OS.sel_validAttributesForMarkedText) {
        return widget.validAttributesForMarkedText (id, sel);
    } else if (sel is OS.sel_hasMarkedText) {
        return widget.hasMarkedText (id, sel) ? cast(objc.id) 1 : null;
    } else if (sel is OS.sel_canBecomeKeyWindow) {
        return widget.canBecomeKeyWindow (id, sel) ? cast(objc.id) 1 : null;
    } else if (sel is OS.sel_accessibilityActionNames) {
        return widget.accessibilityActionNames(id, sel);
    } else if (sel is OS.sel_accessibilityAttributeNames) {
        return widget.accessibilityAttributeNames(id, sel);
    } else if (sel is OS.sel_accessibilityParameterizedAttributeNames) {
        return widget.accessibilityParameterizedAttributeNames(id, sel);
    } else if (sel is OS.sel_accessibilityFocusedUIElement) {
        return widget.accessibilityFocusedUIElement(id, sel);
    } else if (sel is OS.sel_accessibilityIsIgnored) {
        return (widget.accessibilityIsIgnored(id, sel) ? cast(objc.id) 1 : null);
    } else if (sel is OS.sel_nextState) {
        return widget.nextState(id, sel);
    } else if (sel is OS.sel_resetCursorRects) {
        widget.resetCursorRects(id, sel);
    } else if (sel is OS.sel_updateTrackingAreas) {
        widget.updateTrackingAreas(id, sel);
    } else if (sel is OS.sel_viewDidMoveToWindow) {
        widget.viewDidMoveToWindow(id, sel);
    } else if (sel is OS.sel_image) {
        return widget.image(id, sel);
    }
    return null;
}

static objc.id windowProc3(objc.id id, objc.SEL sel, objc.id arg0) {
    /*
    * Feature in Cocoa.  In Cocoa, the default button animation is done
    * in a separate thread that calls drawRect() and isOpaque() from
    * outside the UI thread.  This means that those methods, and application
    * code that runs as a result of those methods, must be thread safe.
    * In DWT, paint events must happen in the UI thread.  The fix is
    * to detect a non-UI thread and avoid the drawing. Instead, the
    * default button is animated by a timer.
    */
    if (!NSThread.isMainThread()) {
        if (sel is OS.sel_drawRect_) {
            return null;
        }
    }
    if (sel is OS.sel_timerProc_) {
        //TODO optimize getting the display
        Display display = getCurrent ();
        if (display is null) return null;
        return display.timerProc (id, sel, arg0);
    }
    if (sel is OS.sel_systemSettingsChanged_) {
        //TODO optimize getting the display
        Display display = getCurrent ();
        if (display is null) return null;
        display.runSettings_ = true;
        return null;
    }
    Widget widget = GetWidget(id);
    if (widget is null) return null;
    if (sel is OS.sel_windowWillClose_) {
        widget.windowWillClose(id, sel, arg0);
    } else if (sel is OS.sel__drawThemeProgressArea_) {
        widget._drawThemeProgressArea(id, sel, arg0);
    } else if (sel is OS.sel_windowShouldClose_) {
        return widget.windowShouldClose(id, sel, arg0) ? cast(objc.id) 1 : null;
    } else if (sel is OS.sel_mouseDown_) {
        widget.mouseDown(id, sel, arg0);
    } else if (sel is OS.sel_keyDown_) {
        widget.keyDown(id, sel, arg0);
    } else if (sel is OS.sel_keyUp_) {
        widget.keyUp(id, sel, arg0);
    } else if (sel is OS.sel_flagsChanged_) {
        widget.flagsChanged(id, sel, arg0);
    } else if (sel is OS.sel_mouseUp_) {
        widget.mouseUp(id, sel, arg0);
    } else if (sel is OS.sel_rightMouseDown_) {
        widget.rightMouseDown(id, sel, arg0);
    } else if (sel is OS.sel_rightMouseDragged_) {
        widget.rightMouseDragged(id, sel, arg0);
    } else if (sel is OS.sel_rightMouseUp_) {
        widget.rightMouseUp(id, sel, arg0);
    } else if (sel is OS.sel_otherMouseDown_) {
        widget.otherMouseDown(id, sel, arg0);
    } else if (sel is OS.sel_otherMouseUp_) {
        widget.otherMouseUp(id, sel, arg0);
    } else if (sel is OS.sel_otherMouseDragged_) {
        widget.otherMouseDragged(id, sel, arg0);
    } else if (sel is OS.sel_mouseMoved_) {
        widget.mouseMoved(id, sel, arg0);
    } else if (sel is OS.sel_mouseDragged_) {
        widget.mouseDragged(id, sel, arg0);
    } else if (sel is OS.sel_mouseEntered_) {
        widget.mouseEntered(id, sel, arg0);
    } else if (sel is OS.sel_mouseExited_) {
        widget.mouseExited(id, sel, arg0);
    } else if (sel is OS.sel_cursorUpdate_) {
        widget.cursorUpdate(id, sel, arg0);
    } else if (sel is OS.sel_menuForEvent_) {
        return widget.menuForEvent(id, sel, arg0);
    } else if (sel is OS.sel_noResponderFor_) {
        widget.noResponderFor(id, sel, cast(objc.SEL)arg0);
    } else if (sel is OS.sel_shouldDelayWindowOrderingForEvent_) {
        return widget.shouldDelayWindowOrderingForEvent(id, sel, arg0) ? cast(objc.id)1 : cast(objc.id)0;
    } else if (sel is OS.sel_acceptsFirstMouse_) {
        return widget.acceptsFirstMouse(id, sel, arg0) ? cast(objc.id)1 : cast(objc.id)0;
    } else if (sel is OS.sel_numberOfRowsInTableView_) {
        return cast(objc.id) widget.numberOfRowsInTableView(id, sel, arg0);
    } else if (sel is OS.sel_tableViewSelectionDidChange_) {
        widget.tableViewSelectionDidChange(id, sel, arg0);
    } else if (sel is OS.sel_windowDidResignKey_) {
        widget.windowDidResignKey(id, sel, arg0);
    } else if (sel is OS.sel_windowDidBecomeKey_) {
        widget.windowDidBecomeKey(id, sel, arg0);
    } else if (sel is OS.sel_windowDidResize_) {
        widget.windowDidResize(id, sel, arg0);
    } else if (sel is OS.sel_windowDidMove_) {
        widget.windowDidMove(id, sel, arg0);
    } else if (sel is OS.sel_menuWillOpen_) {
        widget.menuWillOpen(id, sel, arg0);
    } else if (sel is OS.sel_menuDidClose_) {
        widget.menuDidClose(id, sel, arg0);
    } else if (sel is OS.sel_menuNeedsUpdate_) {
        widget.menuNeedsUpdate(id, sel, arg0);
    } else if (sel is OS.sel_outlineViewSelectionDidChange_) {
        widget.outlineViewSelectionDidChange(id, sel, arg0);
    } else if (sel is OS.sel_sendEvent_) {
        widget.windowSendEvent(id, sel, arg0);
    } else if (sel is OS.sel_helpRequested_) {
        widget.helpRequested(id, sel, arg0);
    } else if (sel is OS.sel_scrollWheel_) {
        widget.scrollWheel(id, sel, arg0);
    } else if (sel is OS.sel_pageDown_) {
        widget.pageDown(id, sel, arg0);
    } else if (sel is OS.sel_pageUp_) {
        widget.pageUp(id, sel, arg0);
    } else if (sel is OS.sel_textViewDidChangeSelection_) {
        widget.textViewDidChangeSelection(id, sel, arg0);
    } else if (sel is OS.sel_textDidChange_) {
        widget.textDidChange(id, sel, arg0);
    } else if (sel is OS.sel_textDidEndEditing_) {
        widget.textDidEndEditing(id, sel, arg0);
    } else if (sel is OS.sel_insertText_) {
        return widget.insertText (id, sel, arg0) ? cast(objc.id)1 : cast(objc.id)0;
    } else if (sel is OS.sel_doCommandBySelector_) {
        widget.doCommandBySelector (id, sel, cast(objc.SEL) arg0);
    } else if (sel is OS.sel_reflectScrolledClipView_) {
        widget.reflectScrolledClipView (id, sel, arg0);
    } else if (sel is OS.sel_accessibilityAttributeValue_) {
        return widget.accessibilityAttributeValue(id, sel, arg0);
    } else if (sel is OS.sel_accessibilityPerformAction_) {
        widget.accessibilityPerformAction(id, sel, arg0);
    } else if (sel is OS.sel_accessibilityActionDescription_) {
        widget.accessibilityActionDescription(id, sel, arg0);
    } else if (sel is OS.sel_makeFirstResponder_) {
        return widget.makeFirstResponder(id, sel, arg0) ? cast(objc.id) 1 : null;
    } else if (sel is OS.sel_tableViewColumnDidMove_) {
        widget.tableViewColumnDidMove(id, sel, arg0);
    } else if (sel is OS.sel_tableViewColumnDidResize_) {
        widget.tableViewColumnDidResize(id, sel, arg0);
    } else if (sel is OS.sel_outlineViewColumnDidMove_) {
        widget.outlineViewColumnDidMove(id, sel, arg0);
    } else if (sel is OS.sel_outlineViewColumnDidResize_) {
        widget.outlineViewColumnDidResize(id, sel, arg0);
    } else if (sel is OS.sel_setNeedsDisplay_) {
        widget.setNeedsDisplay(id, sel, arg0 !is null);
    } else if (sel is OS.sel_setImage_) {
        widget.setImage(id, sel, arg0);
    } else if (sel is OS.sel_setObjectValue_) {
        widget.setObjectValue(id, sel, arg0);
    } else if (sel is OS.sel_updateOpenGLContext_) {
        widget.updateOpenGLContext(id, sel, arg0);
    }
    return null;
}

static objc.id windowProc4(objc.id id, objc.SEL sel, objc.id arg0, objc.id arg1) {
    Widget widget = GetWidget(id);
    if (widget is null) return null;
    if (sel is OS.sel_tabView_willSelectTabViewItem_) {
        widget.tabView_willSelectTabViewItem(id, sel, arg0, arg1);
    } else if (sel is OS.sel_tabView_didSelectTabViewItem_) {
        widget.tabView_didSelectTabViewItem(id, sel, arg0, arg1);
    } else if (sel is OS.sel_outlineView_isItemExpandable_) {
        return widget.outlineView_isItemExpandable(id, sel, arg0, arg1) ? cast(objc.id) 1 : null;
    } else if (sel is OS.sel_outlineView_numberOfChildrenOfItem_) {
        return cast(objc.id) widget.outlineView_numberOfChildrenOfItem(id, sel, arg0, arg1);
    } else if (sel is OS.sel_menu_willHighlightItem_) {
        widget.menu_willHighlightItem(id, sel, arg0, arg1);
    } else if (sel is OS.sel_accessibilityAttributeValue_forParameter_) {
        return widget.accessibilityAttributeValue_forParameter(id, sel, arg0, arg1);
    } else if (sel is OS.sel_tableView_didClickTableColumn_) {
        widget.tableView_didClickTableColumn (id, sel, arg0, arg1);
    } else if (sel is OS.sel_outlineView_didClickTableColumn_) {
        widget.outlineView_didClickTableColumn (id, sel, arg0, arg1);
    } else if (sel is OS.sel_expandItem_expandChildren_) {
        widget.expandItem_expandChildren(id, sel, arg0, arg1 !is null);
    } else if (sel is OS.sel_collapseItem_collapseChildren_) {
        widget.collapseItem_collapseChildren(id, sel, arg0, arg1 !is null);
    }
    return null;
}

static objc.id windowProc5(objc.id id, objc.SEL sel, objc.id arg0, objc.id arg1, objc.id arg2) {
     Widget widget = GetWidget(id);
    if (widget is null) return null;
    if (sel is OS.sel_tableView_objectValueForTableColumn_row_) {
        return widget.tableView_objectValueForTableColumn_row(id, sel, arg0, arg1, arg2);
    } else if (sel is OS.sel_tableView_shouldEditTableColumn_row_) {
        return widget.tableView_shouldEditTableColumn_row(id, sel, arg0, arg1, arg2) ? cast(objc.id) 1 : null;
    } else if (sel is OS.sel_textView_clickedOnLink_atIndex_) {
        return widget.textView_clickOnLink_atIndex(id, sel, arg0, arg1, arg2) ? cast(objc.id) 1 : null;
    } else if (sel is OS.sel_outlineView_child_ofItem_) {
        return widget.outlineView_child_ofItem(id, sel, arg0, arg1, arg2);
    } else if (sel is OS.sel_outlineView_objectValueForTableColumn_byItem_) {
        return widget.outlineView_objectValueForTableColumn_byItem(id, sel, arg0, arg1, arg2);
    } else if (sel is OS.sel_dragSelectionWithEvent_offset_slideBack_) {
        NSSize offset = NSSize();
        OS.memmove(&offset, arg0, NSSize.sizeof);
        return (widget.dragSelectionWithEvent(id, sel, arg0, arg1, arg2) ? cast(objc.id)1 : cast(objc.id)0);
    } else if (sel is OS.sel_tableView_writeRowsWithIndexes_toPasteboard_) {
        return (widget.tableView_writeRowsWithIndexes_toPasteboard(id, sel, arg0, arg1, arg2) ? cast(objc.id)1 : cast(objc.id)0);
    } else if (sel is OS.sel_outlineView_writeItems_toPasteboard_) {
        return (widget.outlineView_writeItems_toPasteboard(id, sel, arg0, arg1, arg2) ? cast(objc.id)1 : cast(objc.id)0);
    }
    return null;
}

static objc.id windowProc6(objc.id id, objc.SEL sel, objc.id arg0, objc.id arg1, objc.id arg2, objc.id arg3) {
    Widget widget = GetWidget(id);
    if (widget is null) return null;
    if (sel is OS.sel_tableView_willDisplayCell_forTableColumn_row_) {
        widget.tableView_willDisplayCell_forTableColumn_row(id, sel, arg0, arg1, arg2, arg3);
    } else if (sel is OS.sel_outlineView_willDisplayCell_forTableColumn_item_) {
        widget.outlineView_willDisplayCell_forTableColumn_item(id, sel, arg0, arg1, arg2, arg3);
    } else  if (sel is OS.sel_outlineView_setObjectValue_forTableColumn_byItem_) {
        widget.outlineView_setObjectValue_forTableColumn_byItem(id, sel, arg0, arg1, arg2, arg3);
    } else if (sel is OS.sel_tableView_setObjectValue_forTableColumn_row_) {
        widget.tableView_setObjectValue_forTableColumn_row(id, sel, arg0, arg1, arg2, arg3);
    }
    return null;
}

static:

void CALLBACK_drawRect_ (objc.id id, objc.SEL sel, NSRect rect)
{
    Widget widget = GetWidget(id);
    if (widget is null) return;
    widget.drawRect(id, sel, rect);
}

void CALLBACK_drawInteriorWithFrame_inView_ (objc.id id, objc.SEL sel, NSRect rect, objc.id arg1)
{
    Widget widget = GetWidget(id);
    if (widget is null) return;
    widget.drawInteriorWithFrame_inView (id, sel, rect, arg1);
}

void CALLBACK_drawWithExpansionFrame_inView_ (objc.id id, objc.SEL sel, NSRect rect, objc.id arg1)
{
    Widget widget = GetWidget(id);
    if (widget is null) return;
    widget.drawWithExpansionFrame_inView (id, sel, rect, arg1);
}

NSRect CALLBACK_imageRectForBounds_ (objc.id id, objc.SEL sel, NSRect rect)
{
    Widget widget = GetWidget(id);
    if (widget is null) return NSRect.init;
    return widget.imageRectForBounds(id, sel, rect);
}

NSRect CALLBACK_titleRectForBounds_ (objc.id id, objc.SEL sel, NSRect rect)
{
    Widget widget = GetWidget(id);
    if (widget is null) return NSRect.init;
    return widget.titleRectForBounds(id, sel, rect);
}

NSUInteger CALLBACK_hitTestForEvent_inRect_ofView_ (objc.id id, objc.SEL sel, objc.id arg0, NSRect rect, objc.id arg2)
{
    Widget widget = GetWidget(id);
    if (widget is null) return NSUInteger.init;
    return widget.hitTestForEvent(id, sel, arg0, rect, arg2);
}

NSSize CALLBACK_cellSize (objc.id id, objc.SEL sel)
{
    Widget widget = GetWidget(id);
    if (widget is null) return NSSize.init;
    return widget.cellSize (id, sel);
}

void CALLBACK_drawImage_withFrame_inView_ (objc.id id, objc.SEL sel, objc.id arg0, NSRect rect, objc.id arg2)
{
    Widget widget = GetWidget(id);
    if (widget is null) return;
    widget.drawImageWithFrameInView (id, sel, arg0, rect, arg2);
}

void CALLBACK_setFrameOrigin_ (objc.id id, objc.SEL sel, NSPoint point)
{
    Widget widget = GetWidget(id);
    if (widget is null) return;
    widget.setFrameOrigin(id, sel, point);
}

void CALLBACK_setFrameSize_ (objc.id id, objc.SEL sel, NSSize size)
{
    Widget widget = GetWidget(id);
    if (widget is null) return;
    widget.setFrameSize(id, sel, size);
}

objc.id CALLBACK_hitTest_ (objc.id id, objc.SEL sel, NSPoint point)
{
    Widget widget = GetWidget(id);
    if (widget is null) return null;
    return widget.hitTest(id, sel, point);
}

NSRange CALLBACK_markedRange (objc.id id, objc.SEL sel)
{
    Widget widget = GetWidget(id);
    if (widget is null) return NSRange.init;
    return widget.markedRange (id, sel);
}

NSRange CALLBACK_selectedRange (objc.id id, objc.SEL sel)
{
    Widget widget = GetWidget(id);
    if (widget is null) return NSRange.init;
    return widget.selectedRange (id, sel);
}

void CALLBACK_highlightSelectionInClipRect_ (objc.id id, objc.SEL sel, NSRect arg0)
{
    Widget widget = GetWidget(id);
    if (widget is null) return;
    widget.highlightSelectionInClipRect (id, sel, arg0);
}

void CALLBACK_setMarkedText_selectedRange_ (objc.id id, objc.SEL sel, objc.id arg0, NSRange arg1)
{
    Widget widget = GetWidget(id);
    if (widget is null) return;
    widget.setMarkedText_selectedRange (id, sel, arg0, arg1);
}

objc.id CALLBACK_attributedSubstringFromRange_ (objc.id id, objc.SEL sel, NSRange arg0)
{
    Widget widget = GetWidget(id);
    if (widget is null) return null;
    return widget.attributedSubstringFromRange (id, sel, arg0);
}

NSUInteger CALLBACK_characterIndexForPoint_ (objc.id id, objc.SEL sel, NSPoint arg0)
{
    Widget widget = GetWidget(id);
    if (widget is null) return 0;
    return widget.characterIndexForPoint (id, sel, arg0);
}

NSRect CALLBACK_firstRectForCharacterRange_ (objc.id id, objc.SEL sel, NSRange arg0)
{
    Widget widget = GetWidget(id);
    if (widget is null) return NSRect.init;
    widget.firstRectForCharacterRange (id, sel, arg0);
}

NSRange CALLBACK_textView_willChangeSelectionFromCharacterRange_toCharacterRange_ (objc.id id, objc.SEL sel, objc.id arg0, NSRange arg1, NSRange arg2)
{
    Widget widget = GetWidget(id);
    if (widget is null) return NSRange.init;
    return widget.textView_willChangeSelectionFromCharacterRange_toCharacterRange(id, sel, arg0, arg1, arg2);
}

objc.id CALLBACK_accessibilityHitTest_ (objc.id id, objc.SEL sel, NSPoint point)
{
    Widget widget = GetWidget(id);
    if (widget is null) return null;
    return widget.accessibilityHitTest(id, sel, point);
}

bool CALLBACK_shouldChangeTextInRange_replacementString_ (objc.id id, objc.SEL sel, objc.id arg0, NSRange arg1, objc.id arg2)
{
    Widget widget = null;
    NSView view = new NSView (id);
    do {
        widget = GetWidget (view.id);
        if (widget !is null) break;
        view = view.superview ();
    } while (view !is null);
    return widget.shouldChangeTextInRange_replacementString(id, sel, arg0, arg1, arg2);
    return false;
}

bool CALLBACK_shouldChangeTextInRange_replacementString_2 (objc.id id, objc.SEL sel, objc.id arg0, NSRange arg1, objc.id arg2)
{
    Widget widget = GetWidget(id);
    if (widget is null) return false;
    return widget.shouldChangeTextInRange_replacementString(id, sel, arg0, arg1, arg2);
}

objc.id CALLBACK_view_stringForToolTip_point_userData_ (objc.id id, objc.SEL sel, objc.id arg0, NSToolTipTag arg1, NSPoint arg2, void* arg3)
{
    Widget widget = GetWidget(id);
    if (widget is null) return null;
    return widget.view_stringForToolTip_point_userData(id, sel, arg0, arg1, arg2, arg3);
}

bool CALLBACK_canDragRowsWithIndexes_atPoint_ (objc.id id, objc.SEL sel, objc.id arg0, NSPoint arg1)
{
    Widget widget = GetWidget(id);
    if (widget is null) return false;
    return widget.canDragRowsWithIndexes_atPoint(id, sel, arg0, arg1);
}

void CALLBACK_setNeedsDisplayInRect_ (objc.id id, objc.SEL sel, NSRect arg0)
{
    Widget widget = GetWidget(id);
    if (widget is null) return;
    widget.setNeedsDisplayInRect(id, sel, arg0);
}

NSRect CALLBACK_expansionFrameWithFrame_inView_ (objc.id id, objc.SEL sel, NSRect rect, objc.id arg1)
{
    Widget widget = GetWidget(id);
    if (widget is null) return NSRect.init;
    return widget.expansionFrameWithFrame_inView(id, sel, rect, arg1);
}

bool isFlipped_CALLBACK (objc.id id, objc.SEL sel)
{
    return true;
}

}