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
module dwt.widgets.Widget;





import dwt.DWT;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSMutableArray;
import dwt.internal.cocoa.NSValue;
import dwt.internal.cocoa.NSView;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSRange;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.NSEvent;
import dwt.internal.cocoa.NSGraphicsContext;
import dwt.internal.cocoa.NSPasteboard;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.OS;
import dwt.internal.cocoa.objc_super;

import tango.core.Thread;

import dwt.dwthelper.utils;
import dwt.dwthelper.System;
import dwt.internal.c.Carbon;
import dwt.internal.objc.cocoa.Cocoa;
import dwt.internal.SWTEventListener;
import objc = dwt.internal.objc.runtime;
import dwt.widgets.Display;
import dwt.widgets.Event;
import dwt.widgets.EventTable;
import dwt.widgets.Listener;
import dwt.widgets.TypedListener;
import dwt.events.DisposeListener;

/**
 * This class is the abstract superclass of all user interface objects.
 * Widgets are created, disposed and issue notification to listeners
 * when events occur which affect them.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>(none)</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Dispose</dd>
 * </dl>
 * <p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the DWT implementation. However, it has not been marked
 * final to allow those outside of the DWT development team to implement
 * patched versions of the class in order to get around specific
 * limitations in advance of when those limitations can be addressed
 * by the team.  Any class built using subclassing to access the internals
 * of this class will likely fail to compile or run between releases and
 * may be strongly platform specific. Subclassing should not be attempted
 * without an intimate and detailed understanding of the workings of the
 * hierarchy. No support is provided for user-written classes which are
 * implemented as subclasses of this class.
 * </p>
 *
 * @see #checkSubclass
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public abstract class Widget {
    int style, state;
    Display display;
    EventTable eventTable;
    Object data;

    void* jniRef;

    /* Global state flags */
    static const int DISPOSED         = 1 << 0;
    static const int CANVAS           = 1 << 1;
    static const int KEYED_DATA       = 1 << 2;
    static const int DISABLED         = 1 << 3;
    static const int HIDDEN           = 1 << 4;
    static const int GRAB                = 1 << 5;
    static const int MOVED            = 1 << 6;
    static const int RESIZED          = 1 << 7;
    static const int EXPANDING        = 1 << 8;
    static const int IGNORE_WHEEL     = 1 << 9;
    static const int PARENT_BACKGROUND = 1 << 10;
    static const int THEME_BACKGROUND = 1 << 11;

    /* A layout was requested on this widget */
    static const int LAYOUT_NEEDED  = 1<<12;

    /* The preferred size of a child has changed */
    static const int LAYOUT_CHANGED = 1<<13;

    /* A layout was requested in this widget hierachy */
    static const int LAYOUT_CHILD = 1<<14;

    /* More global state flags */
    static const int RELEASED = 1<<15;
    static const int DISPOSE_SENT = 1<<16;
    static const int FOREIGN_HANDLE = 1<<17;
    static const int DRAG_DETECT = 1<<18;

    /* Safari fixes */
    static const int SAFARI_EVENTS_FIX = 1<<19;
    static const String SAFARI_EVENTS_FIX_KEY = "dwt.internal.safariEventsFix"; //$NON-NLS-1$
    static final String GLCONTEXT_KEY = "dwt.internal.cocoa.glcontext"; //$NON-NLS-1$

    /* Default size for widgets */
    static const int DEFAULT_WIDTH  = 64;
    static const int DEFAULT_HEIGHT = 64;

this () {
    /* Do nothing */
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
 * @param parent a widget which will be the parent of the new instance (cannot be null)
 * @param style the style of widget to construct
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the parent is disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see DWT
 * @see #checkSubclass
 * @see #getStyle
 */
public this (Widget parent, int style) {
    checkSubclass ();
    checkParent (parent);
    this.style = style;
    display = parent.display;
}

objc.id accessibilityActionDescription(objc.id id, objc.SEL sel, objc.id arg0) {
    return callSuperObject(id, sel, arg0);
}

objc.id accessibilityActionNames(objc.id id, objc.SEL sel) {
    return callSuperObject(id, sel);
}

objc.id accessibilityAttributeNames(objc.id id, objc.SEL sel) {
    return callSuperObject(id, sel);
}

objc.id accessibilityAttributeValue(objc.id id, objc.SEL sel, objc.id arg0) {
    return callSuperObject(id, sel, arg0);
}

objc.id accessibilityAttributeValue_forParameter(objc.id id, objc.SEL sel, objc.id arg0, objc.id arg1) {
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    return OS.objc_msgSendSuper(&super_struct, sel, arg0, arg1);
}

objc.id accessibilityFocusedUIElement(objc.id id, objc.SEL sel) {
    return callSuperObject(id, sel);
}

objc.id accessibilityHitTest(objc.id id, objc.SEL sel, NSPoint point) {
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    return OS.objc_msgSendSuper(&super_struct, sel, point);
}

bool accessibilityIsIgnored(objc.id id, objc.SEL sel) {
    return callSuperBoolean(id, sel);
}

objc.id accessibilityParameterizedAttributeNames(objc.id id, objc.SEL sel) {
    return callSuperObject(id, sel);
}

void accessibilityPerformAction(objc.id id, objc.SEL sel, objc.id arg0) {
    callSuper(id, sel, arg0);
}

String getClipboardText () {
    NSPasteboard pasteboard = NSPasteboard.generalPasteboard ();
    NSString string = pasteboard.stringForType (OS.NSStringPboardType);
    return string !is null ? string.getString () : null;
}

void setClipRegion (CGFloat x, CGFloat y) {
}

objc.id attributedSubstringFromRange (objc.id id, objc.SEL sel, NSRangePointer range) {
    return null;
}

void callSuper(objc.id id, objc.SEL sel) {
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    OS.objc_msgSendSuper(&super_struct, sel);
}

void callSuper(objc.id id, objc.SEL sel, objc.id arg0) {
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    OS.objc_msgSendSuper(&super_struct, sel);
}

void callSuper(objc.id id, objc.SEL sel, NSRect arg0) {
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    OS.objc_msgSendSuper(&super_struct, sel, arg0);
}

void callSuper(objc.id id, objc.SEL sel, NSRect arg0, objc.id arg1) {
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    OS.objc_msgSendSuper(&super_struct, sel, arg0, arg1);
}

objc.id callSuper(objc.id id, objc.SEL sel, objc.id arg0, NSRect arg1, objc.id arg2) {
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    return OS.objc_msgSendSuper(&super_struct, sel, arg0, arg1, arg2);
}

boolean callSuperBoolean(objc.id id, objc.SEL sel) {
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    return OS.objc_msgSendSuper_bool(&super_struct, sel);
}

boolean canBecomeKeyWindow (objc.id id, objc.SEL sel) {
    return callSuperBoolean (id, sel);
}

NSSize cellSize (objc.id id, objc.SEL sel) {
    NSSize result = NSSize();
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    OS.objc_msgSendSuper_stret(&result, &super_struct, sel);
    return result;
}

NSSize cellSizeForBounds (objc.id id, objc.SEL sel, NSRect cellFrame) {
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    NSSize result = NSSize();
    OS.objc_msgSendSuper_stret(&result, &super_struct, sel);
    return result;
}

boolean callSuperBoolean(objc.id id, objc.SEL sel, objc.id arg0) {
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    return OS.objc_msgSendSuper_bool(&super_struct, sel, arg0);
}

bool callSuperBoolean(objc.id id, objc.SEL sel, NSRange range, objc.id arg1) {
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    return OS.objc_msgSendSuper_bool(&super_struct, sel, range, arg1);
}

objc.id callSuperObject(objc.id id, objc.SEL sel) {
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    return OS.objc_msgSendSuper(&super_struct, sel);
}

objc.id callSuperObject(objc.id id, objc.SEL sel, objc.id arg0) {
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    return OS.objc_msgSendSuper(&super_struct, sel, arg0);
}

boolean canDragRowsWithIndexes_atPoint(objc.id id, objc.SEL sel, objc.id arg0, objc.id arg1) {
    // Trees/tables are not draggable unless explicitly told they are.
    return false;
}

NSInteger characterIndexForPoint (objc.id id, objc.SEL sel, NSPointPointer point) {
    return OS.NSNotFound;
}
objc.id columnAtPoint(objc.id id, objc.SEL sel, NSPoint point) {
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    return OS.objc_msgSendSuper(&super_struct, sel, point);
}

boolean acceptsFirstMouse (objc.id id, objc.SEL sel, objc.id theEvent) {
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    return OS.objc_msgSendSuper_bool(&super_struct, sel, theEvent);
}

boolean acceptsFirstResponder (objc.id id, objc.SEL sel) {
    return callSuperBoolean(id, sel);
}

bool becomeFirstResponder (objc.id id, objc.SEL sel) {
    return callSuperBoolean(id, sel);
}

void becomeKeyWindow (objc.id id, objc.SEL sel) {
    callSuper(id, sel);
}

boolean resignFirstResponder (objc.id id, objc.SEL sel) {
    return callSuperBoolean(id, sel);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when an event of the given type occurs. When the
 * event does occur in the widget, the listener is notified by
 * sending it the <code>handleEvent()</code> message. The event
 * type is one of the event constants defined in class <code>DWT</code>.
 *
 * @param eventType the type of event to listen for
 * @param listener the listener which should be notified when the event occurs
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Listener
 * @see DWT
 * @see #getListeners(int)
 * @see #removeListener(int, Listener)
 * @see #notifyListeners
 */
public void addListener (int eventType, Listener listener) {
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    _addListener (eventType, listener);
}

void _addListener (int eventType, Listener listener) {
    if (eventTable is null) eventTable = new EventTable ();
    eventTable.hook (eventType, listener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the widget is disposed. When the widget is
 * disposed, the listener is notified by sending it the
 * <code>widgetDisposed()</code> message.
 *
 * @param listener the listener which should be notified when the receiver is disposed
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see DisposeListener
 * @see #removeDisposeListener
 */
public void addDisposeListener (DisposeListener listener) {
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (DWT.Dispose, typedListener);
}

bool canBecomeKeyView(objc.id id, objc.SEL sel) {
    return true;
}

static int checkBits (int style, int int0, int int1, int int2, int int3, int int4, int int5) {
    int mask = int0 | int1 | int2 | int3 | int4 | int5;
    if ((style & mask) is 0) style |= int0;
    if ((style & int0) !is 0) style = (style & ~mask) | int0;
    if ((style & int1) !is 0) style = (style & ~mask) | int1;
    if ((style & int2) !is 0) style = (style & ~mask) | int2;
    if ((style & int3) !is 0) style = (style & ~mask) | int3;
    if ((style & int4) !is 0) style = (style & ~mask) | int4;
    if ((style & int5) !is 0) style = (style & ~mask) | int5;
    return style;
}

void checkOpen () {
    /* Do nothing */
}

void checkOrientation (Widget parent) {
    style &= ~DWT.MIRRORED;
    if ((style & (DWT.LEFT_TO_RIGHT | DWT.RIGHT_TO_LEFT)) is 0) {
        if (parent !is null) {
            if ((parent.style & DWT.LEFT_TO_RIGHT) !is 0) style |= DWT.LEFT_TO_RIGHT;
            if ((parent.style & DWT.RIGHT_TO_LEFT) !is 0) style |= DWT.RIGHT_TO_LEFT;
        }
    }
    style = checkBits (style, DWT.LEFT_TO_RIGHT, DWT.RIGHT_TO_LEFT, 0, 0, 0, 0);
}

void checkParent (Widget parent) {
    if (parent is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (parent.isDisposed ()) error (DWT.ERROR_INVALID_ARGUMENT);
    parent.checkWidget ();
    parent.checkOpen ();
}

/**
 * Checks that this class can be subclassed.
 * <p>
 * The DWT class library is intended to be subclassed
 * only at specific, controlled points (most notably,
 * <code>Composite</code> and <code>Canvas</code> when
 * implementing new widgets). This method enforces this
 * rule unless it is overridden.
 * </p><p>
 * <em>IMPORTANT:</em> By providing an implementation of this
 * method that allows a subclass of a class which does not
 * normally allow subclassing to be created, the implementer
 * agrees to be fully responsible for the fact that any such
 * subclass will likely fail between DWT releases and will be
 * strongly platform specific. No support is provided for
 * user-written classes which are implemented in this fashion.
 * </p><p>
 * The ability to subclass outside of the allowed DWT classes
 * is intended purely to enable those not on the DWT development
 * team to implement patches in order to get around specific
 * limitations in advance of when those limitations can be
 * addressed by the team. Subclassing should not be attempted
 * without an intimate and detailed understanding of the hierarchy.
 * </p>
 *
 * @exception DWTException <ul>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 */
protected void checkSubclass () {
    if (!isValidSubclass ()) error (DWT.ERROR_INVALID_SUBCLASS);
}

/**
 * Throws an <code>DWTException</code> if the receiver can not
 * be accessed by the caller. This may include both checks on
 * the state of the receiver and more generally on the entire
 * execution context. This method <em>should</em> be called by
 * widget implementors to enforce the standard DWT invariants.
 * <p>
 * Currently, it is an error to invoke any method (other than
 * <code>isDisposed()</code>) on a widget that has had its
 * <code>dispose()</code> method called. It is also an error
 * to call widget methods from any thread that is different
 * from the thread that created the widget.
 * </p><p>
 * In future releases of DWT, there may be more or fewer error
 * checks and exceptions may be thrown for different reasons.
 * </p>
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void checkWidget () {
    Display display = this.display;
    if (display is null) error (DWT.ERROR_WIDGET_DISPOSED);
    if (display.thread !is Thread.getThis () && !display.isEmbedded) error (DWT.ERROR_THREAD_INVALID_ACCESS);
    if ((state & DISPOSED) !is 0) error (DWT.ERROR_WIDGET_DISPOSED);
}

bool textView_clickOnLink_atIndex(objc.id id, objc.SEL sel, objc.id textView, objc.id link, objc.id charIndex) {
    return true;
}

void collapseItem_collapseChildren (objc.id id, objc.SEL sel, objc.id item, bool children) {
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    OS.objc_msgSendSuper(&super_struct, sel, item, children);
}

void copyToClipboard (char [] buffer) {
    if (buffer.length is 0) return;
    wchar[] buf = buffer.toString16();
    NSPasteboard pasteboard = NSPasteboard.generalPasteboard ();
    pasteboard.declareTypes (NSArray.arrayWithObject (OS.NSStringPboardType), null);
    pasteboard.setString (NSString.stringWithCharacters (buf.ptr, buf.length), OS.NSStringPboardType);
}

void copyToClipboard (wchar [] buffer) {
    if (buffer.length is 0) return;
    NSPasteboard pasteboard = NSPasteboard.generalPasteboard ();
    pasteboard.declareTypes (NSArray.arrayWithObject (OS.NSStringPboardType), null);
    pasteboard.setString (NSString.stringWithCharacters (buffer.ptr, buffer.length), OS.NSStringPboardType);
}

void createHandle () {
}

void createJNIRef () {
    jniRef = OS.NewGlobalRef(this);
    if (jniRef is null) error (DWT.ERROR_NO_HANDLES);
}

void createWidget () {
    createJNIRef ();
    createHandle ();
    register ();
}

void deregister () {
}

void destroyJNIRef () {
    if (jniRef !is null) OS.DeleteGlobalRef (jniRef);
    jniRef = null;
}

void destroyWidget () {
    releaseHandle ();
}

/**
 * Disposes of the operating system resources associated with
 * the receiver and all its descendants. After this method has
 * been invoked, the receiver and all descendants will answer
 * <code>true</code> when sent the message <code>isDisposed()</code>.
 * Any internal connections between the widgets in the tree will
 * have been removed to facilitate garbage collection.
 * <p>
 * NOTE: This method is not called recursively on the descendants
 * of the receiver. This means that, widget implementers can not
 * detect when a widget is being disposed of by re-implementing
 * this method, but should instead listen for the <code>Dispose</code>
 * event.
 * </p>
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #addDisposeListener
 * @see #removeDisposeListener
 * @see #checkWidget
 */
public void dispose () {
    /*
    * Note:  It is valid to attempt to dispose a widget
    * more than once.  If this happens, fail silently.
    */
    if (isDisposed ()) return;
    if (!isValidThread ()) error (DWT.ERROR_THREAD_INVALID_ACCESS);
    release (true);
}

void doCommandBySelector (objc.id id, objc.SEL sel, objc.SEL aSelector) {
    callSuper (id, sel, cast(objc.id) aSelector);
}

bool dragSelectionWithEvent(objc.id id, objc.SEL sel, objc.id arg0, objc.id arg1, objc.id arg2) {
    return false;
}

void drawBackground (objc.id id, NSGraphicsContext context, NSRect rect) {
    /* Do nothing */
}

void drawImageWithFrameInView (objc.id id, objc.SEL sel, objc.id image, NSRect rect, objc.id view) {
}

void drawInteriorWithFrame_inView (objc.id id, objc.SEL sel, NSRect cellFrame, objc.id view) {
    callSuper(id, sel, cellFrame, view);
}

void drawWithExpansionFrame_inView (objc.id id, objc.SEL sel, NSRect cellFrame, objc.id view) {
    callSuper(id, sel, cellFrame, view);
}

void drawRect (objc.id id, objc.SEL sel, NSRect rect) {
    if (!isDrawing()) return;
    Display display = this.display;
    NSView view = new NSView(id);
    display.isPainting.addObject(view);
    NSGraphicsContext context = NSGraphicsContext.currentContext();
    context.saveGraphicsState();
    setClipRegion(0, 0);
    drawBackground (id, context, rect);
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    OS.objc_msgSendSuper(&super_struct, sel, rect);
    if (!isDisposed()) {
        /*
        * Feature in Cocoa. There are widgets that draw outside of the UI thread,
        * such as the progress bar and default button.  The fix is to draw the
        * widget but not send paint events.
        */
        drawWidget (id, context, rect);
    }
    context.restoreGraphicsState();
    display.isPainting.removeObjectIdenticalTo(view);
}

void _drawThemeProgressArea (objc.id id, objc.SEL sel, objc.id arg0) {
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    OS.objc_msgSendSuper(&super_struct, sel, arg0);
}

void drawWidget (objc.id id, NSGraphicsContext context, NSRect rect) {
}

void redrawWidget (NSView view, bool children) {
    view.setNeedsDisplay(true);
}

void redrawWidget (NSView view, NSInteger x, NSInteger y, NSInteger width, NSInteger height, bool children) {
    NSRect rect = NSRect();
    rect.x = x;
    rect.y = y;
    rect.width = width;
    rect.height = height;
    view.setNeedsDisplayInRect(rect);
}

void error (int code) {
    DWT.error(code);
}

void expandItem_expandChildren (objc.id id, objc.SEL sel, objc.id item, bool children) {
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    OS.objc_msgSendSuper(&super_struct, sel, item, children);
}

NSRect expansionFrameWithFrame_inView(objc.id id, objc.SEL sel, NSRect cellRect, objc.id view) {
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    NSRect result = NSRect();
    OS.objc_msgSendSuper_stret(&result, &super_struct, sel, cellRect, view);
    return result;
}

bool filters (int eventType) {
    return display.filters (eventType);
}

NSRect firstRectForCharacterRange(objc.id id, objc.SEL sel, objc.id range) {
    return NSRect ();
}

int fixMnemonic (char [] buffer) {
    int i=0, j=0;
    while (i < buffer.length) {
        if ((buffer [j++] = buffer [i++]) is '&') {
            if (i is buffer.length) {continue;}
            if (buffer [i] is '&') {i++; continue;}
            j--;
        }
    }
    return j;
}

/**
 * Returns the application defined widget data associated
 * with the receiver, or null if it has not been set. The
 * <em>widget data</em> is a single, unnamed field that is
 * stored with every widget.
 * <p>
 * Applications may put arbitrary objects in this field. If
 * the object stored in the widget data needs to be notified
 * when the widget is disposed of, it is the application's
 * responsibility to hook the Dispose event on the widget and
 * do so.
 * </p>
 *
 * @return the widget data
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - when the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - when called from the wrong thread</li>
 * </ul>
 *
 * @see #setData(Object)
 */
public Object getData () {
    checkWidget();
    return (state & KEYED_DATA) !is 0 ? (cast(ArrayWrapperObject) data).array [0] : data;
}

/**
 * Returns the application defined property of the receiver
 * with the specified name, or null if it has not been set.
 * <p>
 * Applications may have associated arbitrary objects with the
 * receiver in this fashion. If the objects stored in the
 * properties need to be notified when the widget is disposed
 * of, it is the application's responsibility to hook the
 * Dispose event on the widget and do so.
 * </p>
 *
 * @param   key the name of the property
 * @return the value of the property or null if it has not been set
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the key is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setData(String, Object)
 */
public Object getData (String key) {
    checkWidget();
    //if (key is null) error (DWT.ERROR_NULL_ARGUMENT);
    if ((state & KEYED_DATA) !is 0) {
        Object [] table = (cast(ArrayWrapperObject) data).array;
        for (int i=1; i<table.length; i+=2) {
            String tablekey = (cast(ArrayWrapperString) table[i]).array;
            if (key.equals (tablekey)) return table [i+1];
        }
    }
    return null;
}

/**
 * Returns the <code>Display</code> that is associated with
 * the receiver.
 * <p>
 * A widget's display is either provided when it is created
 * (for example, top level <code>Shell</code>s) or is the
 * same as its parent's display.
 * </p>
 *
 * @return the receiver's display
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Display getDisplay () {
    Display display = this.display;
    if (display is null) error (DWT.ERROR_WIDGET_DISPOSED);
    return display;
}

bool getDrawing () {
    return true;
}

/**
 * Returns an array of listeners who will be notified when an event
 * of the given type occurs. The event type is one of the event constants
 * defined in class <code>DWT</code>.
 *
 * @param eventType the type of event to listen for
 * @return an array of listeners that will be notified when the event occurs
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Listener
 * @see DWT
 * @see #addListener(int, Listener)
 * @see #removeListener(int, Listener)
 * @see #notifyListeners
 *
 * @since 3.4
 */
public Listener[] getListeners (int eventType) {
    checkWidget();
    if (eventTable is null) return new Listener[0];
    return eventTable.getListeners(eventType);
}

String getName () {
    String string = this.classinfo.name;
    int index = string.lastIndexOf ('.');
    if (index is -1) return string;
    return string.substring (index + 1, string.length);
}

String getNameText () {
    return "";
}

/**
 * Returns the receiver's style information.
 * <p>
 * Note that the value which is returned by this method <em>may
 * not match</em> the value which was provided to the constructor
 * when the receiver was created. This can occur when the underlying
 * operating system does not support a particular combination of
 * requested styles. For example, if the platform widget used to
 * implement a particular DWT widget always has scroll bars, the
 * result of calling this method would always have the
 * <code>DWT.H_SCROLL</code> and <code>DWT.V_SCROLL</code> bits set.
 * </p>
 *
 * @return the style bits
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getStyle () {
    checkWidget();
    return style;
}

bool hasMarkedText (objc.id id, objc.SEL sel) {
    return false;
}

void helpRequested(objc.id id, objc.SEL sel, objc.id theEvent) {
}

void highlightSelectionInClipRect(objc.id id, objc.SEL sel, objc.id rect) {
}

objc.id hitTest (objc.id id, objc.SEL sel, NSPoint point) {
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    return OS.objc_msgSendSuper(&super_struct, sel, point);
}

objc.id hitTestForEvent (objc.id id, objc.SEL sel, objc.id event, NSRect rect, objc.id controlView) {
    return null;
}

objc.id hitTestForEvent (objc.id id, objc.SEL sel, objc.id event, NSRect rect, objc.id controlView) {
    return 0;
}

bool hooks (int eventType) {
    if (eventTable is null) return false;
    return eventTable.hooks (eventType);
}

objc.id image (objc.id id, objc.SEL sel) {
    return null;
}

NSRect imageRectForBounds (objc.id id, objc.SEL sel, NSRect cellFrame) {
    return NSRect();
}

bool insertText (objc.id id, objc.SEL sel, objc.id string) {
    callSuper (id, sel, string);
    return true;
}

/**
 * Returns <code>true</code> if the widget has been disposed,
 * and <code>false</code> otherwise.
 * <p>
 * This method gets the dispose state for the widget.
 * When a widget has been disposed, it is an error to
 * invoke any other method using the widget.
 * </p>
 *
 * @return <code>true</code> when the widget is disposed and <code>false</code> otherwise
 */
public bool isDisposed () {
    return (state & DISPOSED) !is 0;
}

bool isDrawing () {
    return true;
}

bool isFlipped(objc.id id, objc.SEL sel) {
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    return OS.objc_msgSendSuper(&super_struct, sel) !is null;
}

/**
 * Returns <code>true</code> if there are any listeners
 * for the specified event type associated with the receiver,
 * and <code>false</code> otherwise. The event type is one of
 * the event constants defined in class <code>DWT</code>.
 *
 * @param eventType the type of event
 * @return true if the event is hooked
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see DWT
 */
public bool isListening (int eventType) {
    checkWidget();
    return hooks (eventType);
}

bool isOpaque(objc.id id, objc.SEL sel) {
    return false;
}

bool isValidSubclass () {
    return Display.isValidClass (this.classinfo);
}

bool isValidThread () {
    return getDisplay ().isValidThread ();
}

void flagsChanged (objc.id id, objc.SEL sel, objc.id theEvent) {
    callSuper (id, sel, theEvent);
}

void keyDown (objc.id id, objc.SEL sel, objc.id theEvent) {
    superKeyDown(id, sel, theEvent);
}

void keyUp (objc.id id, objc.SEL sel, objc.id theEvent) {
    superKeyUp(id, sel, theEvent);
}

void mouseDown(objc.id id, objc.SEL sel, objc.id theEvent) {
}

void mouseUp(objc.id id, objc.SEL sel, objc.id theEvent) {
    superKeyUp(id, sel, theEvent);
}

void mouseMoved(objc.id id, objc.SEL sel, objc.id theEvent) {
    callSuper(id, sel, theEvent);
}

void mouseDragged(objc.id id, objc.SEL sel, objc.id theEvent) {
    callSuper(id, sel, theEvent);
}

void mouseEntered(objc.id id, objc.SEL sel, objc.id theEvent) {
    callSuper(id, sel, theEvent);
}

void mouseExited(objc.id id, objc.SEL sel, objc.id theEvent) {
    callSuper(id, sel, theEvent);
}

void cursorUpdate(objc.id id, objc.SEL sel, objc.id theEvent) {
    callSuper(id, sel, theEvent);
}

void rightMouseDown(objc.id id, objc.SEL sel, objc.id theEvent) {
    callSuper(id, sel, theEvent);
}

void rightMouseUp(objc.id id, objc.SEL sel, objc.id theEvent) {
    callSuper(id, sel, theEvent);
}

void rightMouseDragged(objc.id id, objc.SEL sel, objc.id theEvent) {
    callSuper(id, sel, theEvent);
}

void otherMouseDown(objc.id id, objc.SEL sel, objc.id theEvent) {
    callSuper(id, sel, theEvent);
}

void otherMouseUp(objc.id id, objc.SEL sel, objc.id theEvent) {
    callSuper(id, sel, theEvent);
}

void otherMouseDragged(objc.id id, objc.SEL sel, objc.id theEvent) {
    callSuper(id, sel, theEvent);
}

bool shouldDelayWindowOrderingForEvent (objc.id id, objc.SEL sel, objc.id theEvent) {
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    return OS.objc_msgSendSuper_bool(&super_struct, sel, theEvent);
}

boolean menuHasKeyEquivalent_forEvent_target_action(objc.id id, objc.SEL sel, objc.id menu, objc.id event, objc.id target, objc.id action) {
    return true;
}

objc.id menuForEvent (objc.id id, objc.SEL sel, objc.id theEvent) {
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    return OS.objc_msgSendSuper(&super_struct, sel, theEvent);
}

void menuNeedsUpdate(objc.id id, objc.SEL sel, objc.id menu) {
}

bool makeFirstResponder(objc.id id, objc.SEL sel, objc.id notification) {
    return callSuperBoolean(id, sel, notification);
}

NSRange markedRange (objc.id id, objc.SEL sel) {
    return NSRange ();
}

void menu_willHighlightItem(objc.id id, objc.SEL sel, objc.id menu, objc.id item) {
}

void menuDidClose(objc.id id, objc.SEL sel, objc.id menu) {
    callSuper(id, sel, menu);
}

void menuWillOpen(objc.id id, objc.SEL sel, objc.id menu) {
}

void noResponderFor(objc.id id, objc.SEL sel, objc.id selector) {
    callSuper(id, sel, selector);
}

NSInteger numberOfRowsInTableView(objc.id id, objc.SEL sel, objc.id aTableView) {
    return 0;
}

objc.id outlineView_child_ofItem(objc.id id, objc.SEL sel, objc.id outlineView, objc.id index, objc.id item) {
    return null;
}

void outlineView_didClickTableColumn(objc.id id, objc.SEL sel, objc.id outlineView, objc.id tableColumn) {
}

objc.id outlineView_objectValueForTableColumn_byItem(objc.id id, objc.SEL sel, objc.id outlineView, objc.id tableColumn, objc.id item) {
    return null;
}

bool outlineView_isItemExpandable(objc.id id, objc.SEL sel, objc.id outlineView, objc.id item) {
    return false;
}

NSInteger outlineView_numberOfChildrenOfItem(objc.id id, objc.SEL sel, objc.id outlineView, objc.id item) {
    return 0;
}

void outlineView_willDisplayCell_forTableColumn_item(objc.id id, objc.SEL sel, objc.id outlineView, objc.id cell, objc.id tableColumn, objc.id item) {
}

void outlineViewColumnDidMove (objc.id id, objc.SEL sel, objc.id aNotification) {
}

void outlineViewColumnDidResize (objc.id id, objc.SEL sel, objc.id aNotification) {
}

void outlineViewSelectionDidChange(objc.id id, objc.SEL sel, objc.id notification) {
}

void outlineView_setObjectValue_forTableColumn_byItem(objc.id id, objc.SEL sel, objc.id outlineView, objc.id object, objc.id tableColumn, objc.id item) {
}

bool outlineView_writeItems_toPasteboard(objc.id id, objc.SEL sel, objc.id arg0, objc.id arg1, objc.id arg2) {
    return false;
}


/**
 * Notifies all of the receiver's listeners for events
 * of the given type that one such event has occurred by
 * invoking their <code>handleEvent()</code> method.  The
 * event type is one of the event constants defined in class
 * <code>DWT</code>.
 *
 * @param eventType the type of event which has occurred
 * @param event the event data
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see DWT
 * @see #addListener
 * @see #getListeners(int)
 * @see #removeListener(int, Listener)
 */
public void notifyListeners (int eventType, Event event) {
    checkWidget();
    if (event is null) event = new Event ();
    sendEvent (eventType, event);
}

void pageDown (objc.id id, objc.SEL sel, objc.id sender) {
    callSuper(id, sel, sender);
}

void pageUp (objc.id id, objc.SEL sel, objc.id sender) {
    callSuper(id, sel, sender);
}

void postEvent (int eventType) {
    sendEvent (eventType, null, false);
}

void postEvent (int eventType, Event event) {
    sendEvent (eventType, event, false);
}

void reflectScrolledClipView (objc.id id, objc.SEL sel, objc.id aClipView) {
    callSuper (id, sel, aClipView);
}

void register () {
}

void release (bool destroy) {
    if ((state & DISPOSE_SENT) is 0) {
        state |= DISPOSE_SENT;
        sendEvent (DWT.Dispose);
    }
    if ((state & DISPOSED) is 0) {
        releaseChildren (destroy);
    }
    if ((state & RELEASED) is 0) {
        state |= RELEASED;
        if (destroy) {
            releaseParent ();
            releaseWidget ();
            destroyWidget ();
        } else {
            releaseWidget ();
            releaseHandle ();
        }
    }
}

void releaseChildren (bool destroy) {
}

void releaseHandle () {
    state |= DISPOSED;
    display = null;
    destroyJNIRef ();
}

void releaseParent () {
    /* Do nothing */
}

void releaseWidget () {
    deregister ();
    if (display.tooltipTarget is this) display.tooltipTarget = null;
    eventTable = null;
    data = null;
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when an event of the given type occurs. The event
 * type is one of the event constants defined in class <code>DWT</code>.
 *
 * @param eventType the type of event to listen for
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
 * @see Listener
 * @see DWT
 * @see #addListener
 * @see #getListeners(int)
 * @see #notifyListeners
 */
public void removeListener (int eventType, Listener handler) {
    checkWidget();
    if (handler is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (eventType, handler);
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when an event of the given type occurs.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the DWT
 * public API. It is marked public only so that it can be shared
 * within the packages provided by DWT. It should never be
 * referenced from application code.
 * </p>
 *
 * @param eventType the type of event to listen for
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
 * @see Listener
 * @see #addListener
 */
protected void removeListener (int eventType, SWTEventListener handler) {
    checkWidget();
    if (handler is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (eventType, handler);
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the widget is disposed.
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
 * @see DisposeListener
 * @see #addDisposeListener
 */
public void removeDisposeListener (DisposeListener listener) {
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (DWT.Dispose, listener);
}

void scrollWheel (objc.id id, objc.SEL sel, objc.id theEvent) {
    callSuper(id, sel, theEvent);
}

NSRange selectedRange (objc.id id, objc.SEL sel) {
    return NSRange ();
}

objc.id nextValidKeyView (objc.id id, objc.SEL sel) {
    return callSuperObject(id, sel);
}

objc.id previousValidKeyView (objc.id id, objc.SEL sel) {
    return callSuperObject(id, sel);
}

objc.id nextValidKeyView (objc.id id, objc.SEL sel) {
    return callSuperObject(id, sel);
}

objc.id previousValidKeyView (objc.id id, objc.SEL sel) {
    return callSuperObject(id, sel);
}

void sendDoubleSelection() {
}

void sendEvent (Event event) {
    display.sendEvent (eventTable, event);
}

void sendEvent (int eventType) {
    sendEvent (eventType, null, true);
}

void sendEvent (int eventType, Event event) {
    sendEvent (eventType, event, true);
}

void sendEvent (int eventType, Event event, bool send) {
    if (eventTable is null && !display.filters (eventType)) {
        return;
    }
    if (event is null) event = new Event ();
    event.type = eventType;
    event.display = display;
    event.widget = this;
    if (event.time is 0) {
        event.time = display.getLastEventTime ();
    }
    if (send) {
        sendEvent (event);
    } else {
        display.postEvent (event);
    }
}

bool sendKeyEvent (NSEvent nsEvent, int type) {
    if ((state & SAFARI_EVENTS_FIX) !is 0) return true;
    Event event = new Event ();
    if (!setKeyState (event, type, nsEvent)) return true;
    return sendKeyEvent (type, event);
}

bool sendKeyEvent (int type, Event event) {
    sendEvent (type, event);
    // widget could be disposed at this point

    /*
    * It is possible (but unlikely), that application
    * code could have disposed the widget in the key
    * events.  If this happens, end the processing of
    * the key by returning false.
    */
    if (isDisposed ()) return false;
    return event.doit;
}

void sendHorizontalSelection () {
}

void sendCancelSelection () {
}

void sendSearchSelection () {
}

void sendSelection () {
}

void sendVerticalSelection () {
}

/**
 * Sets the application defined widget data associated
 * with the receiver to be the argument. The <em>widget
 * data</em> is a single, unnamed field that is stored
 * with every widget.
 * <p>
 * Applications may put arbitrary objects in this field. If
 * the object stored in the widget data needs to be notified
 * when the widget is disposed of, it is the application's
 * responsibility to hook the Dispose event on the widget and
 * do so.
 * </p>
 *
 * @param data the widget data
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - when the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - when called from the wrong thread</li>
 * </ul>
 *
 * @see #getData()
 */
public void setData (Object data) {
    checkWidget();
    /*if (SAFARI_EVENTS_FIX_KEY.equals (data)) {
        state |= SAFARI_EVENTS_FIX;
        return;
    }*/
    if ((state & KEYED_DATA) !is 0) {
        (cast(ArrayWrapperObject) this.data).array [0] = data;
    } else {
        this.data = data;
    }
}

/**
 * Sets the application defined property of the receiver
 * with the specified name to the given value.
 * <p>
 * Applications may associate arbitrary objects with the
 * receiver in this fashion. If the objects stored in the
 * properties need to be notified when the widget is disposed
 * of, it is the application's responsibility to hook the
 * Dispose event on the widget and do so.
 * </p>
 *
 * @param key the name of the property
 * @param value the new value for the property
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the key is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #getData(String)
 */
public void setData (String key, Object value) {
    checkWidget();
    //if (key is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (GLCONTEXT_KEY.equals (key)) {
        setOpenGLContext(value);
        return;
    }
    int index = 1;
    Object [] table = null;
    if ((state & KEYED_DATA) !is 0) {
        table = (cast(ArrayWrapperObject) data).array;
        while (index < table.length) {
            String tablekey = (cast(ArrayWrapperString)table[index]).array;
            if (key.equals (tablekey)) break;
            index += 2;
        }
    }
    if (value !is null) {
        if ((state & KEYED_DATA) !is 0) {
            if (index is table.length) {
                Object [] newTable = new Object [table.length + 2];
                System.arraycopy (table, 0, newTable, 0, table.length);
                table = newTable;
                data = new ArrayWrapperObject( table );
            }
        } else {
            table = new Object [3];
            table [0] = data;
            data = new ArrayWrapperObject( table );
            state |= KEYED_DATA;
        }
        table [index] = new ArrayWrapperString( key );
        table [index + 1] = value;
    } else {
        if ((state & KEYED_DATA) !is 0) {
            if (index !is table.length) {
                int length = table.length - 2;
                if (length is 1) {
                    data = table [0];
                    state &= ~KEYED_DATA;
                } else {
                    Object [] newTable = new Object [length];
                    System.arraycopy (table, 0, newTable, 0, index);
                    System.arraycopy (table, index + 2, newTable, index, length - index);
                    data = new ArrayWrapperObject( newTable );
                }
            }
        }
    }
}

void setOpenGLContext(Object value) {
}

void setFrameOrigin (objc.id id, objc.SEL sel, NSPoint point) {
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    OS.objc_msgSendSuper(&super_struct, sel, point);
}

void setFrameSize (objc.id id, objc.SEL sel, NSSize size) {
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    OS.objc_msgSendSuper(&super_struct, sel, size);
}

void setImage (objc.id id, objc.SEL sel, objc.id arg0) {
}

bool setInputState (Event event, NSEvent nsEvent, int type) {
    if (nsEvent is null) return true;
    NSUInteger modifierFlags = nsEvent.modifierFlags();
    if ((modifierFlags & OS.NSAlternateKeyMask) !is 0) event.stateMask |= DWT.ALT;
    if ((modifierFlags & OS.NSShiftKeyMask) !is 0) event.stateMask |= DWT.SHIFT;
    if ((modifierFlags & OS.NSControlKeyMask) !is 0) event.stateMask |= DWT.CONTROL;
    if ((modifierFlags & OS.NSCommandKeyMask) !is 0) event.stateMask |= DWT.COMMAND;
    //TODO multiple mouse buttons pressed
    switch (cast(int)nsEvent.type()) {
        case OS.NSLeftMouseDragged:
        case OS.NSRightMouseDragged:
        case OS.NSOtherMouseDragged:
            switch (nsEvent.buttonNumber()) {
                case 0: event.stateMask |= DWT.BUTTON1; break;
                case 1: event.stateMask |= DWT.BUTTON3; break;
                case 2: event.stateMask |= DWT.BUTTON2; break;
                case 3: event.stateMask |= DWT.BUTTON4; break;
                case 4: event.stateMask |= DWT.BUTTON5; break;
                default:
            }
            break;
        case OS.NSScrollWheel:
        case OS.NSKeyDown:
        case OS.NSKeyUp:
            int state = OS.GetCurrentButtonState ();
            if ((state & 0x1) !is 0) event.stateMask |= DWT.BUTTON1;
            if ((state & 0x2) !is 0) event.stateMask |= DWT.BUTTON3;
            if ((state & 0x4) !is 0) event.stateMask |= DWT.BUTTON2;
            if ((state & 0x8) !is 0) event.stateMask |= DWT.BUTTON4;
            if ((state & 0x10) !is 0) event.stateMask |= DWT.BUTTON5;
            break;
        default:
    }
    switch (type) {
        case DWT.MouseDown:
        case DWT.MouseDoubleClick:
            if (event.button is 1) event.stateMask &= ~DWT.BUTTON1;
            if (event.button is 2) event.stateMask &= ~DWT.BUTTON2;
            if (event.button is 3) event.stateMask &= ~DWT.BUTTON3;
            if (event.button is 4) event.stateMask &= ~DWT.BUTTON4;
            if (event.button is 5) event.stateMask &= ~DWT.BUTTON5;
            break;
        case DWT.MouseUp:
            if (event.button is 1) event.stateMask |= DWT.BUTTON1;
            if (event.button is 2) event.stateMask |= DWT.BUTTON2;
            if (event.button is 3) event.stateMask |= DWT.BUTTON3;
            if (event.button is 4) event.stateMask |= DWT.BUTTON4;
            if (event.button is 5) event.stateMask |= DWT.BUTTON5;
            break;
        case DWT.KeyDown:
        case DWT.Traverse:
            if (event.keyCode is DWT.ALT) event.stateMask &= ~DWT.ALT;
            if (event.keyCode is DWT.SHIFT) event.stateMask &= ~DWT.SHIFT;
            if (event.keyCode is DWT.CONTROL) event.stateMask &= ~DWT.CONTROL;
            if (event.keyCode is DWT.COMMAND) event.stateMask &= ~DWT.COMMAND;
            break;
        case DWT.KeyUp:
            if (event.keyCode is DWT.ALT) event.stateMask |= DWT.ALT;
            if (event.keyCode is DWT.SHIFT) event.stateMask |= DWT.SHIFT;
            if (event.keyCode is DWT.CONTROL) event.stateMask |= DWT.CONTROL;
            if (event.keyCode is DWT.COMMAND) event.stateMask |= DWT.COMMAND;
            break;
        default:
    }
    return true;
}

bool setKeyState (Event event, int type, NSEvent nsEvent) {
    bool isNull = false;
    int keyCode = nsEvent.keyCode ();
    event.keyCode = Display.translateKey (keyCode);
    switch (event.keyCode) {
        case DWT.LF: {
            /*
            * Feature in the Macintosh.  When the numeric key pad
            * Enter key is pressed, it generates '\n'.  This is the
            * correct platform behavior but is not portable.  The
            * fix is to convert the '\n' into '\r'.
            */
            event.keyCode = DWT.KEYPAD_CR;
            event.character = '\r';
            break;
        }
        case DWT.BS: event.character = '\b'; break;
        case DWT.CR: event.character = '\r'; break;
        case DWT.DEL: event.character = 0x7F; break;
        case DWT.ESC: event.character = 0x1B; break;
        case DWT.TAB: event.character = '\t'; break;
        default:
            if (event.keyCode is 0 || (DWT.KEYPAD_MULTIPLY <= event.keyCode && event.keyCode <= DWT.KEYPAD_CR)) {
                NSString chars = nsEvent.characters ();
                if (chars.length() > 0) event.character = cast(wchar)chars.characterAtIndex (0);
            }
            if (event.keyCode is 0) {
                ubyte* uchrPtr = null;
                TISInputSourceRef currentKbd = OS.TISCopyCurrentKeyboardInputSource();
                CFDataRef uchrCFData = cast(CFDataRef) OS.TISGetInputSourceProperty(currentKbd, OS.kTISPropertyUnicodeKeyLayoutData);

                if (uchrCFData !is null) {
                    // If the keyboard changed since the last keystroke clear the dead key state.
                    if (uchrCFData !is display.currentKeyboardUCHRdata) display.deadKeyState[0] = 0;
                    uchrPtr = OS.CFDataGetBytePtr(uchrCFData);

                    if (uchrPtr !is null && OS.CFDataGetLength(uchrCFData) > 0) {
                        CGEventRef cgEvent = nsEvent.CGEvent();
                        long keyboardType = OS.CGEventGetIntegerValueField(cgEvent, OS.kCGKeyboardEventKeyboardType);

                        UniCharCount maxStringLength = 256;
                        wchar [] output = new wchar [maxStringLength];
                        UniCharCount [] actualStringLength = new UniCharCount [1];
                        OS.UCKeyTranslate (cast(UCKeyboardLayout*) uchrPtr, cast(ushort)keyCode, cast(ushort)OS.kUCKeyActionDown, cast(uint) 0, cast(uint)keyboardType, cast(uint) 0, cast(uint*) display.deadKeyState.ptr, maxStringLength, actualStringLength.ptr, output.ptr);
                        if (actualStringLength[0] < 1) {
                            // part of a multi-key key
                            event.keyCode = 0;
                        } else {
                            event.keyCode = output[0];
                        }
                    }
                } else {
                    // KCHR keyboard layouts are no longer supported, so fall back to the basic but flawed
                    // method of determining which key was pressed.
                    NSString unmodifiedChars = nsEvent.charactersIgnoringModifiers ().lowercaseString();
                    if (unmodifiedChars.length() > 0) event.keyCode = cast(char)unmodifiedChars.characterAtIndex(0);
                }

                if (currentKbd !is null) OS.CFRelease(currentKbd);
            }
    }
    if (event.keyCode is 0 && event.character is 0) {
        if (!isNull) return false;
    }
    setInputState (event, nsEvent, type);
    return true;
}

bool setMarkedText_selectedRange (objc.id id, objc.SEL sel, objc.id string, objc.id range) {
    return true;
}

void setNeedsDisplay (objc.id id, objc.SEL sel, bool flag) {
    if (flag && !isDrawing()) return;
    NSView view = new NSView(id);
    if (flag && display.isPainting.containsObject(view)) {
        NSMutableArray needsDisplay = display.needsDisplay;
        if (needsDisplay is null) {
            needsDisplay = cast(NSMutableArray)(new NSMutableArray()).alloc();
            display.needsDisplay = needsDisplay = needsDisplay.initWithCapacity(12);
        }
        needsDisplay.addObject(view);
        return;
    }
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    OS.objc_msgSendSuper(&super_struct, sel, flag);
}

void setNeedsDisplayInRect (objc.id id, objc.SEL sel, objc.id arg0) {
    if (!isDrawing()) return;
    NSRect rect = NSRect();
    OS.memmove(&rect, arg0, NSRect.sizeof);
    NSView view = new NSView(id);
    if (display.isPainting.containsObject(view)) {
        NSMutableArray needsDisplayInRect = display.needsDisplayInRect;
        if (needsDisplayInRect is null) {
            needsDisplayInRect = cast(NSMutableArray)(new NSMutableArray()).alloc();
            display.needsDisplayInRect = needsDisplayInRect = needsDisplayInRect.initWithCapacity(12);
        }
        needsDisplayInRect.addObject(view);
        needsDisplayInRect.addObject(NSValue.valueWithRect(rect));
        return;
    }
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    OS.objc_msgSendSuper(&super_struct, sel, rect);
}

void setObjectValue(objc.id id, objc.SEL sel, objc.id arg0) {
    callSuper(id, sel, arg0);
}

bool setTabGroupFocus () {
    return setTabItemFocus ();
}

bool setTabItemFocus () {
    return false;
}

bool shouldChangeTextInRange_replacementString(objc.id id, objc.SEL sel, objc.id arg0, objc.id arg1) {
    return true;
}

void superKeyDown (objc.id id, objc.SEL sel, objc.id theEvent) {
    callSuper (id, sel, theEvent);
}

void superKeyUp (objc.id id, objc.SEL sel, objc.id theEvent) {
    callSuper (id, sel, theEvent);
}

void tableViewColumnDidMove (objc.id id, objc.SEL sel, objc.id aNotification) {
}

void tableViewColumnDidResize (objc.id id, objc.SEL sel, objc.id aNotification) {
}

void tableViewSelectionDidChange (objc.id id, objc.SEL sel, objc.id aNotification) {
}

void tableView_didClickTableColumn(objc.id id, objc.SEL sel, objc.id tableView, objc.id tableColumn) {
}

objc.id tableView_objectValueForTableColumn_row(objc.id id, objc.SEL sel, objc.id aTableView, objc.id aTableColumn, objc.id rowIndex) {
    return null;
}

void tableView_setObjectValue_forTableColumn_row(objc.id id, objc.SEL sel, objc.id aTableView, objc.id anObject, objc.id aTableColumn, objc.id rowIndex) {
}

bool tableView_shouldEditTableColumn_row(objc.id id, objc.SEL sel, objc.id aTableView, objc.id aTableColumn, objc.id rowIndex) {
    return true;
}

void tableView_willDisplayCell_forTableColumn_row(objc.id id, objc.SEL sel, objc.id aTableView, objc.id aCell, objc.id aTableColumn, objc.id rowIndex) {
}

void textViewDidChangeSelection(objc.id id, objc.SEL sel, objc.id aNotification) {
}

void textDidChange(objc.id id, objc.SEL sel, objc.id aNotification) {
    callSuper (id, sel, aNotification);
}

void textDidEndEditing(objc.id id, objc.SEL sel, objc.id aNotification) {
    callSuper(id, sel, aNotification);
}

NSRange textView_willChangeSelectionFromCharacterRange_toCharacterRange(objc.id id, objc.SEL sel, objc.id aTextView, objc.id oldSelectedCharRange, objc.id newSelectedCharRange) {
    return NSRange();
}

NSRect titleRectForBounds (objc.id id, objc.SEL sel, NSRect cellFrame) {
    objc_super super_struct = objc_super();
    super_struct.receiver = id;
    super_struct.super_class = cast(objc.Class) OS.objc_msgSend(id, OS.sel_superclass);
    NSRect result = NSRect();
    OS.objc_msgSendSuper_stret(&result, &super_struct, sel, cellFrame);
    return result;
}

String tooltipText () {
    return null;
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the receiver
 */
public String toString () {
    String string = "*Disposed*";
    if (!isDisposed ()) {
        string = "*Wrong Thread*";
        if (isValidThread ()) string = getNameText ();
    }
    return getName () ~ " {" ~ string ~ "}";
}

void resetCursorRects (objc.id id, objc.SEL sel) {
    callSuper (id, sel);
}

void updateTrackingAreas (objc.id id, objc.SEL sel) {
    callSuper (id, sel);
}

objc.id validAttributesForMarkedText (objc.id id, objc.SEL sel) {
    return null;
}


void tabView_didSelectTabViewItem(objc.id id, objc.SEL sel, objc.id tabView, objc.id tabViewItem) {
}

objc.id view_stringForToolTip_point_userData (objc.id id, objc.SEL sel, objc.id view, objc.id tag, objc.id point, objc.id userData) {
    return null;
}

void viewDidMoveToWindow(objc.id id, objc.SEL sel) {
}

void viewWillMoveToWindow(objc.id id, objc.SEL sel, objc.id arg0) {
}

void tabView_willSelectTabViewItem(objc.id id, objc.SEL sel, objc.id tabView, objc.id tabViewItem) {
}

bool tableView_writeRowsWithIndexes_toPasteboard(objc.id id, objc.SEL sel, objc.id arg0, objc.id arg1, objc.id arg2) {
    return false;
}

void windowDidMove(objc.id id, objc.SEL sel, objc.id notification) {
}

void windowDidResize(objc.id id, objc.SEL sel, objc.id notification) {
}

void windowDidResignKey(objc.id id, objc.SEL sel, objc.id notification) {
}

void windowDidBecomeKey(objc.id id, objc.SEL sel, objc.id notification) {
}

void windowSendEvent(objc.id id, objc.SEL sel, objc.id event) {
    callSuper(id, sel, event);
}

bool windowShouldClose(objc.id id, objc.SEL sel, objc.id window) {
    return false;
}

void windowWillClose(objc.id id, objc.SEL sel, objc.id notification) {
}

objc.id nextState(objc.id id, objc.SEL sel) {
    return callSuperObject(id, sel);
}

void updateOpenGLContext(objc.id id, objc.SEL sel, objc.id notification) {
}



}
