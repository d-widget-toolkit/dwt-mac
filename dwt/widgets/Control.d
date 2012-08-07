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
module dwt.widgets.Control;


import dwt.*;
import dwt.accessibility.*;
import dwt.events.*;
import dwt.graphics.*;
import dwt.internal.*;
import dwt.internal.cocoa.*;
import cocoa = dwt.internal.cocoa.id;

import tango.core.Thread;

import dwt.dwthelper.utils;
import dwt.dwthelper.System;
import Carbon = dwt.internal.c.Carbon;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;
import dwt.widgets.Composite;
import dwt.widgets.Decorations;
import dwt.widgets.Display;
import dwt.widgets.Event;
import dwt.widgets.Listener;
import dwt.widgets.Menu;
import dwt.widgets.Monitor;
import dwt.widgets.Shell;
import dwt.widgets.TypedListener;
import dwt.widgets.Widget;

/**
 * Control is the abstract superclass of all windowed user interface classes.
 * <p>
 * <dl>
 * <dt><b>Styles:</b>
 * <dd>BORDER</dd>
 * <dd>LEFT_TO_RIGHT, RIGHT_TO_LEFT</dd>
 * <dt><b>Events:</b>
 * <dd>DragDetect, FocusIn, FocusOut, Help, KeyDown, KeyUp, MenuDetect, MouseDoubleClick, MouseDown, MouseEnter,
 *     MouseExit, MouseHover, MouseUp, MouseMove, Move, Paint, Resize, Traverse</dd>
 * </dl>
 * </p><p>
 * Only one of LEFT_TO_RIGHT or RIGHT_TO_LEFT may be specified.
 * </p><p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the DWT implementation.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#control">Control snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">DWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 * @noextend This class is not intended to be subclassed by clients.
 */
public abstract class Control : Widget , Drawable {

    alias Widget.setInputState setInputState;

    /**
     * the handle to the OS resource
     * (Warning: This field is platform dependent)
     * <p>
     * <b>IMPORTANT:</b> This field is <em>not</em> part of the DWT
     * public API. It is marked public only so that it can be shared
     * within the packages provided by DWT. It is not available on all
     * platforms and should never be accessed from application code.
     * </p>
     */
    public NSView view;
    Composite parent;
    String toolTipText;
    Object layoutData;
    int drawCount;
    Menu menu;
    float /*double*/ [] foreground, background;
    Image backgroundImage;
    Font font;
    Cursor cursor;
    Region region;
    NSBezierPath regionPath;
    int /*long*/ visibleRgn;
    Accessible accessible;

    final static int CLIPPING = 1 << 10;
    final static int VISIBLE_REGION = 1 << 12;

    /**
     * Magic number comes from experience. There's no API for this value in Cocoa or Carbon.
     */
    static final int DEFAULT_DRAG_HYSTERESIS = 5;

    /**
     * Magic number comes from experience. There's no API for this value in Cocoa or Carbon.
     */
    static final int DEFAULT_DRAG_HYSTERESIS = 5;

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
 * @see DWT#BORDER
 * @see DWT#LEFT_TO_RIGHT
 * @see DWT#RIGHT_TO_LEFT
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, style);
    this.parent = parent;
    createWidget ();
}

bool acceptsFirstMouse (int /*long*/ id, int /*long*/ sel, int /*long*/ theEvent) {
    Shell shell = getShell ();
    if ((shell.style & DWT.ON_TOP) !is 0) return true;
    return super.acceptsFirstMouse (id, sel, theEvent);
}

int /*long*/ accessibilityActionNames(int /*long*/ id, int /*long*/ sel) {
    if (accessible !is null) {
        NSArray returnValue = accessible.internal_accessibilityActionNames(ACC.CHILDID_SELF);
        if (returnValue !is null) return returnValue.id;
    }

    return super.accessibilityActionNames(id, sel);
}

objc.id accessibilityAttributeNames(objc.id id, objc.SEL sel) {

    if (id is view.id || (cast(NSControl)view && (cast(NSControl)view).cell() !is null && (cast(NSControl)view).cell().id is id)) {
        if (accessible !is null) {

            // First, see if the accessible is going to define a set of attributes for the control.
            // If it does, return that.
            NSArray returnValue = accessible.internal_accessibilityAttributeNames(ACC.CHILDID_SELF);
            if (returnValue !is null) return returnValue.id;

            // If not, see if it will override or augment the standard list.
            // Help, title, and description can be overridden.
            NSMutableArray extraAttributes = NSMutableArray.arrayWithCapacity(3);
            extraAttributes.addObject(OS.NSAccessibilityHelpAttribute);
            extraAttributes.addObject(OS.NSAccessibilityDescriptionAttribute);
            extraAttributes.addObject(OS.NSAccessibilityTitleAttribute);

            for (int i = (int)/*64*/extraAttributes.count() - 1; i >= 0; i--) {
                NSString attribute = new NSString(extraAttributes.objectAtIndex(i).id);
                if (accessible.internal_accessibilityAttributeValue(attribute, ACC.CHILDID_SELF) is null) {
                    extraAttributes.removeObjectAtIndex(i);
                }
            }

            if (extraAttributes.count() > 0) {
                objc.id superResult = super.accessibilityAttributeNames(id, sel);
                NSArray baseAttributes = new NSArray(superResult);
                NSMutableArray mutableAttributes = NSMutableArray.arrayWithCapacity(baseAttributes.count() + 1);
                mutableAttributes.addObjectsFromArray(baseAttributes);

                for (int i = 0; i < extraAttributes.count(); i++) {
                    cocoa.id currAttribute = extraAttributes.objectAtIndex(i);
                    if (!mutableAttributes.containsObject(currAttribute)) {
                        mutableAttributes.addObject(currAttribute);
                    }
                }

                return mutableAttributes.id;
            }
        }
    }

    return super.accessibilityAttributeNames(id, sel);
}

objc.id accessibilityParameterizedAttributeNames(objc.id id, objc.SEL sel) {

    if (id is view.id || (cast(NSControl)view && (cast(NSControl)view).cell() !is null && (cast(NSControl)view).cell().id is id)) {
        if (accessible !is null) {
            NSArray returnValue = accessible.internal_accessibilityParameterizedAttributeNames(ACC.CHILDID_SELF);
            if (returnValue !is null) return returnValue.id;
        }
    }

    return super.accessibilityParameterizedAttributeNames(id, sel);
}

int /*long*/ accessibilityFocusedUIElement(int /*long*/ id, int /*long*/ sel) {
    cocoa.id returnValue = null;
    if (id is view.id || (cast(NSControl)view && (cast(NSControl)view).cell() !is null && (cast(NSControl)view).cell().id is id)) {
        if (accessible !is null) {
            returnValue = accessible.internal_accessibilityFocusedUIElement(ACC.CHILDID_SELF);
        }
    }

    // If we had an accessible and it didn't handle the attribute request, let the
    // superclass handle it.
    if (returnValue is null)
        return super.accessibilityFocusedUIElement(id, sel);
    else
        return returnValue.id;
}

objc.id accessibilityHitTest(objc.id id, objc.SEL sel, NSPoint point) {
    cocoa.id returnValue = null;

    if (id is view.id || (cast(NSControl)view && (cast(NSControl)view).cell() !is null && (cast(NSControl)view).cell().id is id)) {
        if (accessible !is null) {
            returnValue = accessible.internal_accessibilityHitTest(point, ACC.CHILDID_SELF);
        }
    }

    // If we had an accessible and it didn't handle the attribute request, let the
    // superclass handle it.
    if (returnValue is null)
        return super.accessibilityHitTest(id, sel, point);
    else
        return returnValue.id;
}

objc.id accessibilityAttributeValue(objc.id id, objc.SEL sel, objc.id arg0) {
    NSString attribute = new NSString(arg0);
    objc.id returnValue = null;
    cocoa.id returnObject = null;

    if (accessible !is null) {
        returnObject = accessible.internal_accessibilityAttributeValue(attribute, ACC.CHILDID_SELF);
    }

    // If we had an accessible and it didn't handle the attribute request, let the
    // superclass handle it.
    if (returnObject is null) {
        returnValue = super.accessibilityAttributeValue(id, sel, arg0);
    } else {
        returnValue = returnObject.id;
    }

    return returnValue;
}

objc.id accessibilityAttributeValue_forParameter(objc.id id, objc.SEL sel, objc.id arg0, objc.id arg1) {
    NSString attribute = new NSString(arg0);

    cocoa.id returnValue = null;

    if (accessible !is null) {
        cocoa.id parameter = new cocoa.id(arg1);
        returnValue = accessible.internal_accessibilityAttributeValue_forParameter(attribute, parameter, ACC.CHILDID_SELF);
    }

    // If we had an accessible and it didn't handle the attribute request, let the
    // superclass handle it.
    if (returnValue is null)
        return super.accessibilityAttributeValue_forParameter(id, sel, arg0, arg1);
    else
        return returnValue.id;
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the control is moved or resized, by sending
 * it one of the messages defined in the <code>ControlListener</code>
 * interface.
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
 * @see ControlListener
 * @see #removeControlListener
 */
public void addControlListener(ControlListener listener) {
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (DWT.Resize,typedListener);
    addListener (DWT.Move,typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when a drag gesture occurs, by sending it
 * one of the messages defined in the <code>DragDetectListener</code>
 * interface.
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
 * @see DragDetectListener
 * @see #removeDragDetectListener
 *
 * @since 3.3
 */
public void addDragDetectListener (DragDetectListener listener) {
    checkWidget ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (DWT.DragDetect,typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the control gains or loses focus, by sending
 * it one of the messages defined in the <code>FocusListener</code>
 * interface.
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
 * @see FocusListener
 * @see #removeFocusListener
 */
public void addFocusListener(FocusListener listener) {
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener(DWT.FocusIn,typedListener);
    addListener(DWT.FocusOut,typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when help events are generated for the control,
 * by sending it one of the messages defined in the
 * <code>HelpListener</code> interface.
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
 * @see HelpListener
 * @see #removeHelpListener
 */
public void addHelpListener (HelpListener listener) {
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (DWT.Help, typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when keys are pressed and released on the system keyboard, by sending
 * it one of the messages defined in the <code>KeyListener</code>
 * interface.
 * <p>
 * When a key listener is added to a control, the control
 * will take part in widget traversal.  By default, all
 * traversal keys (such as the tab key and so on) are
 * delivered to the control.  In order for a control to take
 * part in traversal, it should listen for traversal events.
 * Otherwise, the user can traverse into a control but not
 * out.  Note that native controls such as table and tree
 * implement key traversal in the operating system.  It is
 * not necessary to add traversal listeners for these controls,
 * unless you want to override the default traversal.
 * </p>
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
 * @see KeyListener
 * @see #removeKeyListener
 */
public void addKeyListener(KeyListener listener) {
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener(DWT.KeyUp,typedListener);
    addListener(DWT.KeyDown,typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the platform-specific context menu trigger
 * has occurred, by sending it one of the messages defined in
 * the <code>MenuDetectListener</code> interface.
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
 * @see MenuDetectListener
 * @see #removeMenuDetectListener
 *
 * @since 3.3
 */
public void addMenuDetectListener (MenuDetectListener listener) {
    checkWidget ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (DWT.MenuDetect, typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when mouse buttons are pressed and released, by sending
 * it one of the messages defined in the <code>MouseListener</code>
 * interface.
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
 * @see MouseListener
 * @see #removeMouseListener
 */
public void addMouseListener(MouseListener listener) {
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener(DWT.MouseDown,typedListener);
    addListener(DWT.MouseUp,typedListener);
    addListener(DWT.MouseDoubleClick,typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the mouse passes or hovers over controls, by sending
 * it one of the messages defined in the <code>MouseTrackListener</code>
 * interface.
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
 * @see MouseTrackListener
 * @see #removeMouseTrackListener
 */
public void addMouseTrackListener (MouseTrackListener listener) {
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (DWT.MouseEnter,typedListener);
    addListener (DWT.MouseExit,typedListener);
    addListener (DWT.MouseHover,typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the mouse moves, by sending it one of the
 * messages defined in the <code>MouseMoveListener</code>
 * interface.
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
 * @see MouseMoveListener
 * @see #removeMouseMoveListener
 */
public void addMouseMoveListener(MouseMoveListener listener) {
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener(DWT.MouseMove,typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the mouse wheel is scrolled, by sending
 * it one of the messages defined in the
 * <code>MouseWheelListener</code> interface.
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
 * @see MouseWheelListener
 * @see #removeMouseWheelListener
 *
 * @since 3.3
 */
public void addMouseWheelListener (MouseWheelListener listener) {
    checkWidget ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (DWT.MouseWheel, typedListener);
}

void addRelation (Control control) {
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the receiver needs to be painted, by sending it
 * one of the messages defined in the <code>PaintListener</code>
 * interface.
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
 * @see PaintListener
 * @see #removePaintListener
 */
public void addPaintListener(PaintListener listener) {
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener(DWT.Paint,typedListener);
}

static final double SYNTHETIC_BOLD = -2.5;
static final double SYNTHETIC_ITALIC = 0.2;

void addTraits(NSMutableDictionary dict, Font font) {
    if ((font.extraTraits & OS.NSBoldFontMask) !is 0) {
        dict.setObject(NSNumber.numberWithDouble(SYNTHETIC_BOLD), OS.NSStrokeWidthAttributeName);
    }
    if ((font.extraTraits & OS.NSItalicFontMask) !is 0) {
        dict.setObject(NSNumber.numberWithDouble(SYNTHETIC_ITALIC), OS.NSObliquenessAttributeName);
    }
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when traversal events occur, by sending it
 * one of the messages defined in the <code>TraverseListener</code>
 * interface.
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
 * @see TraverseListener
 * @see #removeTraverseListener
 */
public void addTraverseListener (TraverseListener listener) {
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (DWT.Traverse,typedListener);
}

bool becomeFirstResponder (int /*long*/ id, int /*long*/ sel) {
    if ((state & DISABLED) !is 0) return false;
    return super.becomeFirstResponder (id, sel);
}

void calculateVisibleRegion (NSView view, int /*long*/ visibleRgn, bool clipChildren) {
    int /*long*/ tempRgn = OS.NewRgn ();
    if (!view.isHiddenOrHasHiddenAncestor() && isDrawing()) {
        int /*long*/ childRgn = OS.NewRgn ();
        NSWindow window = view.window ();
        NSView contentView = window.contentView();
        NSView frameView = contentView.superview();
        NSRect bounds = contentView.visibleRect();
        bounds = contentView.convertRect_toView_(bounds, view);
        short[] rect = new short[4];
        OS.SetRect(rect, (short)bounds.x, (short)bounds.y, (short)(bounds.x + bounds.width), (short)(bounds.y + bounds.height));
        OS.RectRgn(visibleRgn, rect);
        NSView tempView = view, lastControl = null;
        while (tempView.id !is frameView.id) {
            bounds = tempView.visibleRect();
            bounds = tempView.convertRect_toView_(bounds, view);
            OS.SetRect(rect, (short)bounds.x, (short)bounds.y, (short)(bounds.x + bounds.width), (short)(bounds.y + bounds.height));
            OS.RectRgn(tempRgn, rect);
            OS.SectRgn (tempRgn, visibleRgn, visibleRgn);
            if (OS.EmptyRgn (visibleRgn)) break;
            if (clipChildren || tempView.id !is view.id) {
                NSArray subviews = tempView.subviews();
                int /*long*/ count = subviews.count();
                for (int i = 0; i < count; i++) {
                    NSView child = new NSView (subviews.objectAtIndex(count - i - 1));
                    if (lastControl !is null && child.id is lastControl.id) break;
                    if (child.isHidden()) continue;
                    bounds = child.visibleRect();
                    bounds = child.convertRect_toView_(bounds, view);
                    OS.SetRect(rect, (short)bounds.x, (short)bounds.y, (short)(bounds.x + bounds.width), (short)(bounds.y + bounds.height));
                    OS.RectRgn(tempRgn, rect);
                    OS.UnionRgn (tempRgn, childRgn, childRgn);
                }
            }
            lastControl = tempView;
            tempView = tempView.superview();
        }
        OS.DiffRgn (visibleRgn, childRgn, visibleRgn);
        OS.DisposeRgn (childRgn);
    } else {
        OS.CopyRgn (tempRgn, visibleRgn);
    }
    OS.DisposeRgn (tempRgn);
}

void checkBackground () {
    Shell shell = getShell ();
    if (this is shell) return;
    state &= ~PARENT_BACKGROUND;
    Composite composite = parent;
    do {
        int mode = composite.backgroundMode;
        if (mode !is 0) {
            if (mode is DWT.INHERIT_DEFAULT) {
                Control control = this;
                do {
                    if ((control.state & THEME_BACKGROUND) is 0) {
                        return;
                    }
                    control = control.parent;
                } while (control !is composite);
            }
            state |= PARENT_BACKGROUND;
            return;
        }
        if (composite is shell) break;
        composite = composite.parent;
    } while (true);
}

void checkBuffered () {
    style |= DWT.DOUBLE_BUFFERED;
}

void checkToolTip (Widget target) {
    if (isVisible () && display.tooltipControl is this && (target is null || display.tooltipTarget is target)) {
        Shell shell = getShell ();
        shell.sendToolTipEvent (false);
        shell.sendToolTipEvent (true);
    }
}

/**
 * Returns the preferred size of the receiver.
 * <p>
 * The <em>preferred size</em> of a control is the size that it would
 * best be displayed at. The width hint and height hint arguments
 * allow the caller to ask a control questions such as "Given a particular
 * width, how high does the control need to be to show all of the contents?"
 * To indicate that the caller does not wish to constrain a particular
 * dimension, the constant <code>DWT.DEFAULT</code> is passed for the hint.
 * </p>
 *
 * @param wHint the width hint (can be <code>DWT.DEFAULT</code>)
 * @param hHint the height hint (can be <code>DWT.DEFAULT</code>)
 * @return the preferred size of the control
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Layout
 * @see #getBorderWidth
 * @see #getBounds
 * @see #getSize
 * @see #pack(bool)
 * @see "computeTrim, getClientArea for controls that implement them"
 */
public Point computeSize (int wHint, int hHint) {
    return computeSize (wHint, hHint, true);
}

/**
 * Returns the preferred size of the receiver.
 * <p>
 * The <em>preferred size</em> of a control is the size that it would
 * best be displayed at. The width hint and height hint arguments
 * allow the caller to ask a control questions such as "Given a particular
 * width, how high does the control need to be to show all of the contents?"
 * To indicate that the caller does not wish to constrain a particular
 * dimension, the constant <code>DWT.DEFAULT</code> is passed for the hint.
 * </p><p>
 * If the changed flag is <code>true</code>, it indicates that the receiver's
 * <em>contents</em> have changed, therefore any caches that a layout manager
 * containing the control may have been keeping need to be flushed. When the
 * control is resized, the changed flag will be <code>false</code>, so layout
 * manager caches can be retained.
 * </p>
 *
 * @param wHint the width hint (can be <code>DWT.DEFAULT</code>)
 * @param hHint the height hint (can be <code>DWT.DEFAULT</code>)
 * @param changed <code>true</code> if the control's contents have changed, and <code>false</code> otherwise
 * @return the preferred size of the control.
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Layout
 * @see #getBorderWidth
 * @see #getBounds
 * @see #getSize
 * @see #pack(bool)
 * @see "computeTrim, getClientArea for controls that implement them"
 */
public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    int width = DEFAULT_WIDTH;
    int height = DEFAULT_HEIGHT;
    if (wHint !is DWT.DEFAULT) width = wHint;
    if (hHint !is DWT.DEFAULT) height = hHint;
    int border = getBorderWidth ();
    width += border * 2;
    height += border * 2;
    return new Point (width, height);
}

Widget computeTabGroup () {
    if (isTabGroup()) return this;
    return parent.computeTabGroup ();
}

Widget[] computeTabList() {
    if (isTabGroup()) {
        if (getVisible() && getEnabled()) {
            return [this];
        }
    }
    return new Widget[0];
}

Control computeTabRoot () {
    Control[] tabList = parent._getTabList();
    if (tabList !is null) {
        int index = 0;
        while (index < tabList.length) {
            if (tabList [index] is this) break;
            index++;
        }
        if (index is tabList.length) {
            if (isTabGroup ()) return this;
        }
    }
    return parent.computeTabRoot ();
}

NSView contentView () {
    return view;
}

NSAttributedString createString (String string, Font font, float /*double*/ [] foreground, int style, bool enabled, bool mnemonics) {
    NSMutableDictionary dict = ((NSMutableDictionary)new NSMutableDictionary().alloc()).initWithCapacity(5);
    if (font is null) font = this.font !is null ? this.font : defaultFont();
    dict.setObject (font.handle, OS.NSFontAttributeName);
    addTraits(dict, font);
    if (enabled) {
        if (foreground !is null) {
            NSColor color = NSColor.colorWithDeviceRed(foreground[0], foreground[1], foreground[2], foreground[3]);
            dict.setObject (color, OS.NSForegroundColorAttributeName);
        }
    } else {
        dict.setObject (NSColor.disabledControlTextColor (), OS.NSForegroundColorAttributeName);
    }
    if (style !is 0) {
        NSMutableParagraphStyle paragraphStyle = (NSMutableParagraphStyle)new NSMutableParagraphStyle ().alloc ().init ();
        paragraphStyle.setLineBreakMode (OS.NSLineBreakByClipping);
        int alignment = DWT.LEFT;
        if ((style & DWT.CENTER) !is 0) {
            alignment = OS.NSCenterTextAlignment;
        } else if ((style & DWT.RIGHT) !is 0) {
            alignment = OS.NSRightTextAlignment;
        }
        paragraphStyle.setAlignment (alignment);
        dict.setObject (paragraphStyle, OS.NSParagraphStyleAttributeName);
        paragraphStyle.release ();
    }
    int length = string.length ();
    char [] chars = new char [length];
    string.getChars (0, chars.length, chars, 0);
    if (mnemonics) length = fixMnemonic (chars);
    NSString str = ((NSString)new NSString().alloc()).initWithCharacters(chars, length);
    NSAttributedString attribStr = ((NSAttributedString) new NSAttributedString ().alloc ()).initWithString (str, dict);
    str.release();
    dict.release();
    return attribStr;
}

void createWidget () {
    state |= DRAG_DETECT;
    checkOrientation (parent);
    super.createWidget ();
    checkBackground ();
    checkBuffered ();
    setDefaultFont ();
    setZOrder ();
    setRelations ();
    display.clearPool ();
}

Color defaultBackground () {
    return display.getWidgetColor (DWT.COLOR_WIDGET_BACKGROUND);
}

Font defaultFont () {
    if (display.smallFonts) return display.getSystemFont ();
    return Font.cocoa_new (display, defaultNSFont ());
}

Color defaultForeground () {
    return display.getWidgetColor (DWT.COLOR_WIDGET_FOREGROUND);
}

NSFont defaultNSFont () {
    return display.getSystemFont().handle;
}

void deregister () {
    super.deregister ();
    display.removeWidget (view);
}

void destroyWidget () {
    NSView view = topView ();
    view.removeFromSuperview ();
    releaseHandle ();
}

void doCommandBySelector (objc.id id, objc.SEL sel, objc.SEL selector) {
    if (view.window ().firstResponder ().id is id) {
        if (imeInComposition ()) return;
        Shell s = this.getShell();
        NSEvent nsEvent = NSApplication.sharedApplication ().currentEvent ();
        if (nsEvent !is null && nsEvent.type () is OS.NSKeyDown) {
            /*
             * Feature in Cocoa.  Pressing Alt+UpArrow invokes doCommandBySelector
             * twice, with selectors moveBackward and moveToBeginningOfParagraph
             * (Alt+DownArrow behaves similarly).  In order to avoid sending
             * multiple events for these keys, do not send a KeyDown if we already sent one
             * during this keystroke. This rule does not apply if the command key
             * is down, because we likely triggered the current key sequence via flagsChanged.
             */
            int /*long*/ modifiers = nsEvent.modifierFlags();
            if (s.keyInputHappened is false || (modifiers & OS.NSCommandKeyMask) !is 0) {
                s.keyInputHappened = true;
                bool [] consume = new bool [1];
                if (translateTraversal (nsEvent.keyCode (), nsEvent, consume)) return;
                if (isDisposed ()) return;
                if (!sendKeyEvent (nsEvent, DWT.KeyDown)) return;
                if (consume [0]) return;
            }
        }
        if ((state & CANVAS) !is 0) return;
    }
    super.doCommandBySelector (id, sel, selector);
}

/**
 * Detects a drag and drop gesture.  This method is used
 * to detect a drag gesture when called from within a mouse
 * down listener.
 *
 * <p>By default, a drag is detected when the gesture
 * occurs anywhere within the client area of a control.
 * Some controls, such as tables and trees, override this
 * behavior.  In addition to the operating system specific
 * drag gesture, they require the mouse to be inside an
 * item.  Custom widget writers can use <code>setDragDetect</code>
 * to disable the default detection, listen for mouse down,
 * and then call <code>dragDetect()</code> from within the
 * listener to conditionally detect a drag.
 * </p>
 *
 * @param event the mouse down event
 *
 * @return <code>true</code> if the gesture occurred, and <code>false</code> otherwise.
 *
 * @exception IllegalArgumentException <ul>
 *   <li>ERROR_NULL_ARGUMENT when the event is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see DragDetectListener
 * @see #addDragDetectListener
 *
 * @see #getDragDetect
 * @see #setDragDetect
 *
 * @since 3.3
 */
public bool dragDetect (Event event) {
    checkWidget ();
    if (event is null) error (DWT.ERROR_NULL_ARGUMENT);
    return dragDetect (event.button, event.count, event.stateMask, event.x, event.y);
}

/**
 * Detects a drag and drop gesture.  This method is used
 * to detect a drag gesture when called from within a mouse
 * down listener.
 *
 * <p>By default, a drag is detected when the gesture
 * occurs anywhere within the client area of a control.
 * Some controls, such as tables and trees, override this
 * behavior.  In addition to the operating system specific
 * drag gesture, they require the mouse to be inside an
 * item.  Custom widget writers can use <code>setDragDetect</code>
 * to disable the default detection, listen for mouse down,
 * and then call <code>dragDetect()</code> from within the
 * listener to conditionally detect a drag.
 * </p>
 *
 * @param event the mouse down event
 *
 * @return <code>true</code> if the gesture occurred, and <code>false</code> otherwise.
 *
 * @exception IllegalArgumentException <ul>
 *   <li>ERROR_NULL_ARGUMENT when the event is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see DragDetectListener
 * @see #addDragDetectListener
 *
 * @see #getDragDetect
 * @see #setDragDetect
 *
 * @since 3.3
 */
public bool dragDetect (MouseEvent event) {
    checkWidget ();
    if (event is null) error (DWT.ERROR_NULL_ARGUMENT);
    return dragDetect (event.button, event.count, event.stateMask, event.x, event.y);
}

bool dragDetect (int button, int count, int stateMask, int x, int y) {
    if (button !is 1 || count !is 1) return false;
    if (!dragDetect (x, y, false, null)) return false;
    return sendDragEvent (button, stateMask, x, y);
}

bool dragDetect (int x, int y, bool filter, bool [] consume) {
    /**
     * Feature in Cocoa. Mouse drag events do not account for hysteresis.
     * As soon as the mouse drags a mouse dragged event is fired.  Fix is to
     * check for another mouse drag event that is at least 5 pixels away
     * from the start of the drag.
     */
    NSApplication application = NSApplication.sharedApplication();
    bool dragging = false;
    int /*long*/ eventType = OS.NSLeftMouseDown;
    float /*double*/ dragX = x;
    float /*double*/ dragY = y;

    /**
     * To check for an actual drag we need to pull off mouse moved and mouse up events
     * to detect if the user dragged outside of a 10 x 10 box centered on the mouse down location.
     * We still want the view to see the events, so save them and re-post when done checking.
     */
    NSEvent mouseUpEvent = null;
    NSMutableArray dragEvents = NSMutableArray.arrayWithCapacity(10);

    while (eventType !is OS.NSLeftMouseUp) {
        NSEvent event = application.nextEventMatchingMask((OS.NSLeftMouseUpMask | OS.NSLeftMouseDraggedMask),
                NSDate.distantFuture(), OS.NSEventTrackingRunLoopMode, true);
        eventType = event.type();

        if (eventType is OS.NSLeftMouseDragged) {
            dragEvents.addObject(event);
            NSPoint windowLoc = event.locationInWindow();
            NSPoint viewLoc = view.convertPoint_fromView_(windowLoc, null);
            if (!view.isFlipped ()) {
                viewLoc.y = view.bounds().height - viewLoc.y;
            }
            if ((Math.abs(viewLoc.x - dragX) > DEFAULT_DRAG_HYSTERESIS) || (Math.abs(viewLoc.y - dragY) > DEFAULT_DRAG_HYSTERESIS)) {
                dragging = true;
                break;
            }
        } else if (eventType is OS.NSLeftMouseUp) {
            mouseUpEvent = event;
        }
    }

    // Push back any events we took out of the queue so the control can receive them.
    if (mouseUpEvent !is null) application.postEvent(mouseUpEvent, true);

    if (dragEvents.count() > 0) {
        while (dragEvents.count() > 0) {
            NSEvent currEvent = new NSEvent(dragEvents.objectAtIndex(dragEvents.count() - 1).id);
            dragEvents.removeLastObject();
            application.postEvent(currEvent, true);
        }
    }

    return dragging;
}

bool drawGripper (int x, int y, int width, int height, bool vertical) {
    return false;
}

void drawWidget (objc.id id, NSGraphicsContext context, NSRect rect) {
    if (id !is paintView().id) return;
    if (!hooks (DWT.Paint) && !filters (DWT.Paint)) return;

    /* Send paint event */
    GCData data = new GCData ();
    data.paintRectStruct = rect;
    data.paintRect = &data.paintRectStruct;
    GC gc = GC.cocoa_new (this, data);
    Event event = new Event ();
    event.gc = gc;
    event.x = cast(int)rect.x;
    event.y = cast(int)rect.y;
    event.width = cast(int)rect.width;
    event.height = cast(int)rect.height;
    sendEvent (DWT.Paint, event);
    event.gc = null;
    gc.dispose ();
}

void enableWidget (bool enabled) {
    if (cast(NSControl) view) {
        (cast(NSControl)view).setEnabled(enabled);
    }
    updateCursorRects (isEnabled ());
}

bool equals(float /*double*/ [] color1, float /*double*/ [] color2) {
    if (color1 is color2) return true;
    if (color1 is null) return color2 is null;
    if (color2 is null) return color1 is null;
    for (int i = 0; i < color1.length; i++) {
        if (color1 [i] !is color2 [i]) return false;
    }
    return true;
}

NSView eventView () {
    return view;
}

void fillBackground (NSView view, NSGraphicsContext context, NSRect rect, int imgHeight) {
    Control control = findBackgroundControl();
    if (control is null) control = this;
    Image image = control.backgroundImage;
    if (image !is null && !image.isDisposed()) {
        context.saveGraphicsState();
        NSColor.colorWithPatternImage(image.handle).setFill();
        NSPoint phase = NSPoint();
        NSView controlView = control.view;
        if (imgHeight is -1) {
            NSView contentView = controlView.window().contentView();
            phase = controlView.convertPoint_toView_(phase, contentView);
            phase.y = contentView.bounds().height - phase.y;
        } else {
            phase = view.convertPoint_toView_(phase, controlView);
            phase.y += imgHeight - backgroundImage.getBounds().height;
        }
        context.setPatternPhase(phase);
        NSBezierPath.fillRect(rect);
        context.restoreGraphicsState();
        return;
    }

    float /*double*/ [] background = control.background;
    float /*double*/ alpha;
    if (background is null) {
        background = control.defaultBackground ().handle;
        alpha = getThemeAlpha ();
    } else {
        alpha = background[3];
    }
    context.saveGraphicsState ();
    NSColor.colorWithDeviceRed (background [0], background [1], background [2], alpha).setFill ();
    NSBezierPath.fillRect (rect);
    context.restoreGraphicsState ();
}

Cursor findCursor () {
    if (cursor !is null) return cursor;
    return parent.findCursor ();
}

Control findBackgroundControl () {
    if (backgroundImage !is null || background !is null) return this;
    return (state & PARENT_BACKGROUND) !is 0 ? parent.findBackgroundControl () : null;
}

Menu [] findMenus (Control control) {
    if (menu !is null && this !is control) return [menu];
    return new Menu [0];
}

Widget findTooltip (NSPoint pt) {
    return this;
}

void fixChildren (Shell newShell, Shell oldShell, Decorations newDecorations, Decorations oldDecorations, Menu [] menus) {
    oldShell.fixShell (newShell, this);
    oldDecorations.fixDecorations (newDecorations, this, menus);
}

void fixFocus (Control focusControl) {
    Shell shell = getShell ();
    Control control = this;
    while (control !is shell && (control = control.parent) !is null) {
        if (control.setFocus ()) return;
    }
    shell.setSavedFocus (focusControl);
//  int window = OS.GetControlOwner (handle);
//  OS.ClearKeyboardFocus (window);
}

void flagsChanged (objc.id id, objc.SEL sel, objc.id theEvent) {
    if (view.window ().firstResponder ().id is id) {
        if ((state & SAFARI_EVENTS_FIX) is 0) {
            Shell s = this.getShell();
            s.keyInputHappened = false;
            int mask = 0;
            NSEvent nsEvent = new NSEvent (theEvent);
            NSUInteger modifiers = nsEvent.modifierFlags ();
            int keyCode = Display.translateKey (nsEvent.keyCode ());
            switch (keyCode) {
                case DWT.ALT: mask = OS.NSAlternateKeyMask; break;
                case DWT.CONTROL: mask = OS.NSControlKeyMask; break;
                case DWT.COMMAND: mask = OS.NSCommandKeyMask; break;
                case DWT.SHIFT: mask = OS.NSShiftKeyMask; break;
                case DWT.CAPS_LOCK:
                    Event event = new Event();
                    event.keyCode = keyCode;
                    setInputState (event, nsEvent, DWT.KeyDown);
                    sendKeyEvent (DWT.KeyDown, event);
                    setInputState (event, nsEvent, DWT.KeyUp);
                    sendKeyEvent (DWT.KeyUp, event);
                    break;
                default:
            }
            if (mask !is 0) {
                s.keyInputHappened = true;
                int type = (mask & modifiers) !is 0 ? DWT.KeyDown : DWT.KeyUp;
                if (type is DWT.KeyDown) s.keyInputHappened = true;
                Event event = new Event();
                event.keyCode = keyCode;
                setInputState (event, nsEvent, type);
                if (!sendKeyEvent (type, event)) return;
            }
        }
    }
    super.flagsChanged (id, sel, theEvent);
}

NSView focusView () {
    return view;
}

/**
 * Forces the receiver to have the <em>keyboard focus</em>, causing
 * all keyboard events to be delivered to it.
 *
 * @return <code>true</code> if the control got focus, and <code>false</code> if it was unable to.
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setFocus
 */
public bool forceFocus () {
    checkWidget();
    if (display.focusEvent is DWT.FocusOut) return false;
    Decorations shell = menuShell ();
    shell.setSavedFocus (this);
    if (!isEnabled () || !isVisible () || !isActive ()) return false;
    if (isFocusControl ()) return true;
    shell.setSavedFocus (null);
    NSView focusView = focusView ();
    if (!focusView.canBecomeKeyView()) return false;
    bool result = view.window ().makeFirstResponder (focusView);
    if (isDisposed ()) return false;
    shell.bringToTop (false);
    if (isDisposed ()) return false;
    shell.setSavedFocus (this);
    return result;
}

/**
 * Returns the accessible object for the receiver.
 * If this is the first time this object is requested,
 * then the object is created and returned.
 *
 * @return the accessible object
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Accessible#addAccessibleListener
 * @see Accessible#addAccessibleControlListener
 *
 * @since 2.0
 */
public Accessible getAccessible () {
    checkWidget ();
    if (accessible is null) accessible = new_Accessible (this);
    return accessible;
}

/**
 * Returns the receiver's background color.
 * <p>
 * Note: This operation is a hint and may be overridden by the platform.
 * For example, on some versions of Windows the background of a TabFolder,
 * is a gradient rather than a solid color.
 * </p>
 * @return the background color
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Color getBackground () {
    checkWidget();
    Control control = findBackgroundControl ();
    if (control is null) control = this;
    return control.getBackgroundColor ();
}

Color getBackgroundColor () {
    return background !is null ? Color.cocoa_new (display, background) : defaultBackground ();
}

/**
 * Returns the receiver's background image.
 *
 * @return the background image
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.2
 */
public Image getBackgroundImage () {
    checkWidget();
    Control control = findBackgroundControl ();
    if (control is null) control = this;
    return control.backgroundImage;
}

/**
 * Returns the receiver's border width.
 *
 * @return the border width
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getBorderWidth () {
    checkWidget();
    return 0;
}

/**
 * Returns a rectangle describing the receiver's size and location
 * relative to its parent (or its display if its parent is null),
 * unless the receiver is a shell. In this case, the location is
 * relative to the display.
 *
 * @return the receiver's bounding rectangle
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Rectangle getBounds () {
    checkWidget();
    NSRect rect = topView().frame();
    return new Rectangle(cast(int)rect.x, cast(int)rect.y, cast(int)rect.width, cast(int)rect.height);
}

/**
 * Returns <code>true</code> if the receiver is detecting
 * drag gestures, and  <code>false</code> otherwise.
 *
 * @return the receiver's drag detect state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.3
 */
public bool getDragDetect () {
    checkWidget ();
    return (state & DRAG_DETECT) !is 0;
}

bool getDrawing () {
    return drawCount <= 0;
}

/**
 * Returns the receiver's cursor, or null if it has not been set.
 * <p>
 * When the mouse pointer passes over a control its appearance
 * is changed to match the control's cursor.
 * </p>
 *
 * @return the receiver's cursor or <code>null</code>
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.3
 */
public Cursor getCursor () {
    checkWidget();
    return cursor;
}

/**
 * Returns <code>true</code> if the receiver is enabled, and
 * <code>false</code> otherwise. A disabled control is typically
 * not selectable from the user interface and draws with an
 * inactive or "grayed" look.
 *
 * @return the receiver's enabled state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #isEnabled
 */
public bool getEnabled () {
    checkWidget();
    return (state & DISABLED) is 0;
}

/**
 * Returns the font that the receiver will use to paint textual information.
 *
 * @return the receiver's font
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Font getFont () {
    checkWidget();
    return font !is null ? font : defaultFont ();
}

/**
 * Returns the foreground color that the receiver will use to draw.
 *
 * @return the receiver's foreground color
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Color getForeground () {
    checkWidget();
    return getForegroundColor ();
}

Color getForegroundColor () {
    return foreground !is null ? Color.cocoa_new (display, foreground) : defaultForeground ();
}

/**
 * Returns layout data which is associated with the receiver.
 *
 * @return the receiver's layout data
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Object getLayoutData () {
    checkWidget();
    return layoutData;
}

/**
 * Returns a point describing the receiver's location relative
 * to its parent (or its display if its parent is null), unless
 * the receiver is a shell. In this case, the point is
 * relative to the display.
 *
 * @return the receiver's location
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Point getLocation () {
    checkWidget();
    NSRect rect = topView().frame();
    return new Point(cast(int)rect.x, cast(int)rect.y);
}

/**
 * Returns the receiver's pop up menu if it has one, or null
 * if it does not. All controls may optionally have a pop up
 * menu that is displayed when the user requests one for
 * the control. The sequence of key strokes, button presses
 * and/or button releases that are used to request a pop up
 * menu is platform specific.
 *
 * @return the receiver's menu
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Menu getMenu () {
    checkWidget();
    return menu;
}

int getMininumHeight () {
    return 0;
}

/**
 * Returns the receiver's monitor.
 *
 * @return the receiver's monitor
 *
 * @since 3.0
 */
public dwt.widgets.Monitor.Monitor getMonitor () {
    checkWidget();
    dwt.widgets.Monitor.Monitor [] monitors = display.getMonitors ();
    if (monitors.length is 1) return monitors [0];
    int index = -1, value = -1;
    Rectangle bounds = getBounds ();
    if (this !is getShell ()) {
        bounds = display.map (this.parent, null, bounds);
    }
    for (int i=0; i<monitors.length; i++) {
        Rectangle rect = bounds.intersection (monitors [i].getBounds ());
        int area = rect.width * rect.height;
        if (area > 0 && area > value) {
            index = i;
            value = area;
        }
    }
    if (index >= 0) return monitors [index];
    int centerX = bounds.x + bounds.width / 2, centerY = bounds.y + bounds.height / 2;
    for (int i=0; i<monitors.length; i++) {
        Rectangle rect = monitors [i].getBounds ();
        int x = centerX < rect.x ? rect.x - centerX : centerX > rect.x + rect.width ? centerX - rect.x - rect.width : 0;
        int y = centerY < rect.y ? rect.y - centerY : centerY > rect.y + rect.height ? centerY - rect.y - rect.height : 0;
        int distance = x * x + y * y;
        if (index is -1 || distance < value) {
            index = i;
            value = distance;
        }
    }
    return monitors [index];
}

/**
 * Returns the receiver's parent, which must be a <code>Composite</code>
 * or null when the receiver is a shell that was created with null or
 * a display for a parent.
 *
 * @return the receiver's parent
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Composite getParent () {
    checkWidget();
    return parent;
}

Control [] getPath () {
    int count = 0;
    Shell shell = getShell ();
    Control control = this;
    while (control !is shell) {
        count++;
        control = control.parent;
    }
    control = this;
    Control [] result = new Control [count];
    while (control !is shell) {
        result [--count] = control;
        control = control.parent;
    }
    return result;
}

NSBezierPath getPath(Region region) {
    if (region is null) return null;
    return getPath(region.handle);
}

NSBezierPath getPath(int /*long*/ region) {
    Callback callback = new Callback(this, "regionToRects", 4);
    if (callback.getAddress() is 0) DWT.error(DWT.ERROR_NO_MORE_CALLBACKS);
    NSBezierPath path = NSBezierPath.bezierPath();
    path.retain();
    OS.QDRegionToRects(region, OS.kQDParseRegionFromTopLeft, callback.getAddress(), path.id);
    callback.dispose();
    if (path.isEmpty()) path.appendBezierPathWithRect(new NSRect());
    return path;
}

/**
 * Returns the region that defines the shape of the control,
 * or null if the control has the default shape.
 *
 * @return the region that defines the shape of the shell (or null)
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public Region getRegion () {
    checkWidget ();
    return region;
}

/**
 * Returns the receiver's shell. For all controls other than
 * shells, this simply returns the control's nearest ancestor
 * shell. Shells return themselves, even if they are children
 * of other shells.
 *
 * @return the receiver's shell
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #getParent
 */
public Shell getShell () {
    checkWidget();
    return parent.getShell ();
}

/**
 * Returns a point describing the receiver's size. The
 * x coordinate of the result is the width of the receiver.
 * The y coordinate of the result is the height of the
 * receiver.
 *
 * @return the receiver's size
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Point getSize () {
    checkWidget();
    NSRect rect = topView().frame();
    return new Point(cast(int)rect.width, cast(int)rect.height);
}

float getThemeAlpha () {
    return 1 * parent.getThemeAlpha ();
}

/**
 * Returns the receiver's tool tip text, or null if it has
 * not been set.
 *
 * @return the receiver's tool tip text
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String getToolTipText () {
    checkWidget();
    return toolTipText;
}

/**
 * Returns <code>true</code> if the receiver is visible, and
 * <code>false</code> otherwise.
 * <p>
 * If one of the receiver's ancestors is not visible or some
 * other condition makes the receiver not visible, this method
 * may still indicate that it is considered visible even though
 * it may not actually be showing.
 * </p>
 *
 * @return the receiver's visibility state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool getVisible () {
    checkWidget();
    return (state & HIDDEN) is 0;
}

int /*long*/ getVisibleRegion () {
    if (visibleRgn is 0) {
        visibleRgn = OS.NewRgn ();
        calculateVisibleRegion (view, visibleRgn, true);
    }
    int /*long*/ result = OS.NewRgn ();
    OS.CopyRgn (visibleRgn, result);
    return result;
}

bool hasBorder () {
    return (style & DWT.BORDER) !is 0;
}

bool hasFocus () {
    return display.getFocusControl() is this;
}

objc.id hitTest (objc.id id, objc.SEL sel, NSPoint point) {
    if ((state & DISABLED) !is 0) return null;
    if (!isActive ()) return 0;
    if (regionPath !is null) {
        NSView superview = new NSView(id).superview();
        if (superview !is null) {
            NSPoint pt = superview.convertPoint_toView_(point, view);
            if (!view.isFlipped ()) {
                pt.y = view.bounds().height - pt.y;
            }
            if (!regionPath.containsPoint(pt)) return 0;
        }
    }
    return super.hitTest(id, sel, point);
}

bool imeInComposition () {
    return false;
}

    if (view.window ().firstResponder ().id is id) {
        Shell s = this.getShell();
        NSEvent nsEvent = NSApplication.sharedApplication ().currentEvent ();
        if (nsEvent !is null) {
            int /*long*/ type = nsEvent.type ();
            if ((!s.keyInputHappened && type is OS.NSKeyDown) || type is OS.NSSystemDefined) {
                NSString str = new NSString (string);
                if (str.isKindOfClass (cast(objc.Class)OS.objc_getClass ("NSAttributedString"))) {
                    str = (new NSAttributedString (string)).string ();
                }
                NSUInteger length = str.length ();
                wchar[] buffer = new wchar [length];
                str.getCharacters(buffer.ptr);
                for (int i = 0; i < buffer.length; i++) {
                    s.keyInputHappened = true;
                    Event event = new Event ();
                    if (i is 0 && type is OS.NSKeyDown) setKeyState (event, DWT.KeyDown, nsEvent);
                    event.character = buffer [i];
                    if (!sendKeyEvent (DWT.KeyDown, event)) return false;
                }
            }
        }
        if ((state & CANVAS) !is 0) return true;
    }
    return super.insertText (id, sel, string);
}

/**
 * Invokes platform specific functionality to allocate a new GC handle.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>Control</code>. It is marked public only so that it
 * can be shared within the packages provided by DWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param data the platform specific GC data
 * @return the platform specific GC handle
 */
public objc.id internal_new_GC (GCData data) {
    checkWidget();
    NSView view = paintView();
    objc.id context = null;
    if (data !is null && data.paintRect !is null) {
        NSGraphicsContext graphicsContext = NSGraphicsContext.currentContext();
        context = graphicsContext.id;
        if (!view.isFlipped()) data.state &= ~VISIBLE_REGION;
    } else {
        NSGraphicsContext graphicsContext = NSGraphicsContext.graphicsContextWithWindow (view.window ());
        NSGraphicsContext flippedContext = NSGraphicsContext.graphicsContextWithGraphicsPort(graphicsContext.graphicsPort(), true);
        graphicsContext = flippedContext;
        context = graphicsContext.id;
        if (data !is null) {
            data.flippedContext = flippedContext;
            data.state &= ~VISIBLE_REGION;
            data.visibleRgn = getVisibleRegion();
            display.addContext (data);
        }
    }
    if (data !is null) {
        int mask = DWT.LEFT_TO_RIGHT | DWT.RIGHT_TO_LEFT;
        if ((data.style & mask) is 0) {
            data.style |= style & (mask | DWT.MIRRORED);
        }
        data.device = display;
        data.thread = display.thread;
        data.view = view;
        data.foreground = getForegroundColor ().handle;
        Control control = findBackgroundControl ();
        if (control is null) control = this;
        data.background = control.getBackgroundColor ().handle;
        data.font = font !is null ? font : defaultFont ();
    }
    return context;
}

/**
 * Invokes platform specific functionality to dispose a GC handle.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>Control</code>. It is marked public only so that it
 * can be shared within the packages provided by DWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param hDC the platform specific GC handle
 * @param data the platform specific GC data
 */
public void internal_dispose_GC (objc.id context, GCData data) {
    checkWidget ();
    NSGraphicsContext graphicsContext = new NSGraphicsContext (context);
    display.removeContext (data);
    if (data !is null) {
        if (data.paintRect is null) graphicsContext.flushGraphics ();
        if (data.visibleRgn !is 0) OS.DisposeRgn(data.visibleRgn);
        data.visibleRgn = 0;
    }
}

void invalidateChildrenVisibleRegion () {
}

void invalidateVisibleRegion () {
    int index = 0;
    Control[] siblings = parent._getChildren ();
    while (index < siblings.length && siblings [index] !is this) index++;
    for (int i=index; i<siblings.length; i++) {
        Control sibling = siblings [i];
        sibling.resetVisibleRegion ();
        sibling.invalidateChildrenVisibleRegion ();
    }
    parent.resetVisibleRegion ();
}

bool isActive () {
    return getShell().getModalShell() is null;
}

/*
 * Answers a bool indicating whether a Label that precedes the receiver in
 * a layout should be read by screen readers as the recevier's label.
 */
bool isDescribedByLabel () {
    return true;
}

bool isDrawing () {
    return getDrawing() && parent.isDrawing();

bool isDrawing () {
    return getDrawing() && parent.isDrawing();
}

/**
 * Returns <code>true</code> if the receiver is enabled and all
 * ancestors up to and including the receiver's nearest ancestor
 * shell are enabled.  Otherwise, <code>false</code> is returned.
 * A disabled control is typically not selectable from the user
 * interface and draws with an inactive or "grayed" look.
 *
 * @return the receiver's enabled state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #getEnabled
 */
public bool isEnabled () {
    checkWidget();
    return getEnabled () && parent.isEnabled ();
}

bool isEnabledCursor () {
    return isEnabled ();
}

bool isFocusAncestor (Control control) {
    while (control !is null && control !is this && !(cast(Shell) control)) {
        control = control.parent;
    }
    return control is this;
}

/**
 * Returns <code>true</code> if the receiver has the user-interface
 * focus, and <code>false</code> otherwise.
 *
 * @return the receiver's focus state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool isFocusControl () {
    checkWidget();
    Control focusControl = display.focusControl;
    if (focusControl !is null && !focusControl.isDisposed ()) {
        return this is focusControl;
    }
    return hasFocus ();
}

bool isObscured () {
    int /*long*/ visibleRgn = getVisibleRegion(), boundsRgn = OS.NewRgn();
    short[] rect = new short[4];
    NSRect bounds = view.visibleRect();
    OS.SetRect(rect, (short)bounds.x, (short)bounds.y, (short)(bounds.x + bounds.width), (short)(bounds.y + bounds.height));
    OS.RectRgn(boundsRgn, rect);
    OS.DiffRgn(boundsRgn, visibleRgn, boundsRgn);
    bool obscured = !OS.EmptyRgn (boundsRgn);
    OS.DisposeRgn(boundsRgn);
    OS.DisposeRgn(visibleRgn);
    return obscured;
}

/**
 * Returns <code>true</code> if the underlying operating
 * system supports this reparenting, otherwise <code>false</code>
 *
 * @return <code>true</code> if the widget can be reparented, otherwise <code>false</code>
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool isReparentable () {
    checkWidget();
    return true;
}

bool isShowing () {
    /*
    * This is not complete.  Need to check if the
    * widget is obscurred by a parent or sibling.
    */
    if (!isVisible ()) return false;
    Control control = this;
    while (control !is null) {
        Point size = control.getSize ();
        if (size.x is 0 || size.y is 0) {
            return false;
        }
        control = control.parent;
    }
    return true;
}

bool isTabGroup () {
    Control [] tabList = parent._getTabList ();
    if (tabList !is null) {
        for (int i=0; i<tabList.length; i++) {
            if (tabList [i] is this) return true;
        }
    }
    int code = traversalCode (0, null);
    if ((code & (DWT.TRAVERSE_ARROW_PREVIOUS | DWT.TRAVERSE_ARROW_NEXT)) !is 0) return false;
    return (code & (DWT.TRAVERSE_TAB_PREVIOUS | DWT.TRAVERSE_TAB_NEXT)) !is 0;
}

bool isTabItem () {
    Control [] tabList = parent._getTabList ();
    if (tabList !is null) {
        for (int i=0; i<tabList.length; i++) {
            if (tabList [i] is this) return false;
        }
    }
    int code = traversalCode (0, null);
    return (code & (DWT.TRAVERSE_ARROW_PREVIOUS | DWT.TRAVERSE_ARROW_NEXT)) !is 0;
}

bool isTrim (NSView view) {
    return false;
}

/**
 * Returns <code>true</code> if the receiver is visible and all
 * ancestors up to and including the receiver's nearest ancestor
 * shell are visible. Otherwise, <code>false</code> is returned.
 *
 * @return the receiver's visibility state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #getVisible
 */
public bool isVisible () {
    checkWidget();
    return getVisible () && parent.isVisible ();
}

void keyDown (objc.id id, objc.SEL sel, objc.id theEvent) {
    if (view.window ().firstResponder ().id is id) {
        Shell s = this.getShell();
        s.keyInputHappened = false;
        bool textInput = OS.objc_msgSend (id, OS.sel_conformsToProtocol_, OS.objc_getProtocol ("NSTextInput")) !is null;
        if (!textInput) {
            // Not a text field, so send a key event here.
            NSEvent nsEvent = new NSEvent (theEvent);
            bool [] consume = new bool [1];
            if (translateTraversal (nsEvent.keyCode (), nsEvent, consume)) return;
            if (isDisposed ()) return;
            if (!sendKeyEvent (nsEvent, DWT.KeyDown)) return;
            if (consume [0]) return;
        } else {
            // Control is some kind of text field, so the key event will be sent from insertText: or doCommandBySelector:
            super.keyDown (id, sel, theEvent);

            if (imeInComposition ()) return;
            // If none of those methods triggered a key event send one now.
            if (!s.keyInputHappened) {
                NSEvent nsEvent = new NSEvent (theEvent);
                bool [] consume = new bool [1];
                if (translateTraversal (nsEvent.keyCode (), nsEvent, consume)) return;
                if (isDisposed ()) return;
                if (!sendKeyEvent (nsEvent, DWT.KeyDown)) return;
                if (consume [0]) return;
        } else {
            // Control is some kind of text field, so the key event will be sent from insertText: or doCommandBySelector:
            super.keyDown (id, sel, theEvent);

            if (imeInComposition ()) return;
            // If none of those methods triggered a key event send one now.
            if (!s.keyInputHappened) {
                NSEvent nsEvent = new NSEvent (theEvent);
                bool [] consume = new bool [1];
                if (translateTraversal (nsEvent.keyCode (), nsEvent, consume)) return;
                if (isDisposed ()) return;
                if (!sendKeyEvent (nsEvent, DWT.KeyDown)) return;
                if (consume [0]) return;
            }

            return;
            }

            return;
        }
    }
    super.keyDown (id, sel, theEvent);
}

void keyUp (objc.id id, objc.SEL sel, objc.id theEvent) {
    if (view.window ().firstResponder ().id is id) {
        NSEvent nsEvent = new NSEvent (theEvent);
        if (!sendKeyEvent (nsEvent, DWT.KeyUp)) return;
    }
    super.keyUp (id, sel, theEvent);
}

void markLayout (bool changed, bool all) {
    /* Do nothing */
}

objc.id menuForEvent (objc.id id, objc.SEL sel, objc.id theEvent) {
    if (!isEnabled ()) return 0;

    NSPoint pt = NSEvent.mouseLocation();
    pt.y = cast(int) (display.getPrimaryFrame().height - pt.y);
    int x = cast(int) pt.x;
    int y = cast(int) pt.y;
    Event event = new Event ();
    event.x = x;
    event.y = y;
    sendEvent (DWT.MenuDetect, event);
    //widget could be disposed at this point
    if (isDisposed ()) return null;
    if (!event.doit) return null;
    Menu menu = getMenu ();
    if (menu !is null && !menu.isDisposed ()) {
        if (x !is event.x || y !is event.y) {
            menu.setLocation (event.x, event.y);
        }
        menu.setVisible(true);
        return 0;
    }
    return super.menuForEvent (id, sel, theEvent);
}

Decorations menuShell () {
    return parent.menuShell ();
}

void scrollWheel (objc.id id, objc.SEL sel, objc.id theEvent) {
    if (id is view.id) {
        if (hooks (DWT.MouseWheel) || filters (DWT.MouseWheel)) {
            NSEvent nsEvent = new NSEvent(theEvent);
            if (nsEvent.deltaY() !is 0) {
                if (!sendMouseEvent(nsEvent, DWT.MouseWheel, true)) {
                    return;
                }
            }
        }
    }
    super.scrollWheel(id, sel, theEvent);
}

bool isEventView (int /*long*/ id) {
    return true;
}

bool mouseEvent (int /*long*/ id, int /*long*/ sel, int /*long*/ theEvent, int type) {
    if (!display.sendEvent) return true;
    display.sendEvent = false;
    if (!isEventView (id)) return true;
    bool dragging = false;
    bool[] consume = null;
    NSEvent nsEvent = new NSEvent(theEvent);
    int nsType = (int)/*64*/nsEvent.type();
    NSInputManager manager = NSInputManager.currentInputManager ();
    if (manager !is null && manager.wantsToHandleMouseEvents ()) {
        if (manager.handleMouseEvent (nsEvent)) {
            return true;
        }
    }
    switch (nsType) {
        case OS.NSLeftMouseDown:
            if (nsEvent.clickCount() is 1 && (state & DRAG_DETECT) !is 0 && hooks (DWT.DragDetect)) {
                consume = new bool[1];
                NSPoint location = view.convertPoint_fromView_(nsEvent.locationInWindow(), null);
                if (!view.isFlipped ()) {
                    location.y = view.bounds().height - location.y;
                }
                dragging = dragDetect((int)location.x, (int)location.y, false, consume);
            }
            break;
        case OS.NSLeftMouseDragged:
        case OS.NSRightMouseDragged:
        case OS.NSOtherMouseDragged:
            display.checkEnterExit (this, nsEvent, false);
            break;
        case OS.NSLeftMouseUp:
        case OS.NSRightMouseUp:
        case OS.NSOtherMouseUp:
            display.checkEnterExit (display.findControl(true), nsEvent, false);
            break;
    }
    sendMouseEvent (nsEvent, type, false);
    if (type is DWT.MouseDown && nsEvent.clickCount() is 2) {
        sendMouseEvent (nsEvent, DWT.MouseDoubleClick, false);
    }
    if (dragging) sendMouseEvent(nsEvent, DWT.DragDetect, false);
    if (consume !is null && consume[0]) return false;
    return true;
}

    if (!mouseEvent(id, sel, theEvent, DWT.MouseDown)) return;
    if (!mouseEvent(id, sel, theEvent, DWT.MouseDown)) return;
    bool tracking = isEventView (id);
    Display display = this.display;
    if (tracking) display.trackingControl = this;
    super.mouseDown(id, sel, theEvent);
    if (tracking) display.trackingControl = null;
}

void mouseUp(int /*long*/ id, int /*long*/ sel, int /*long*/ theEvent) {
    if (!mouseEvent(id, sel, theEvent, DWT.MouseUp)) return;
    super.mouseUp(id, sel, theEvent);
}

void mouseDragged(int /*long*/ id, int /*long*/ sel, int /*long*/ theEvent) {
    if (!mouseEvent(id, sel, theEvent, DWT.MouseMove)) return;
    super.mouseDragged(id, sel, theEvent);
}

void rightMouseDown(int /*long*/ id, int /*long*/ sel, int /*long*/ theEvent) {
    if (!mouseEvent(id, sel, theEvent, DWT.MouseDown)) return;
    super.rightMouseDown(id, sel, theEvent);
}

void rightMouseUp(int /*long*/ id, int /*long*/ sel, int /*long*/ theEvent) {
    if (!mouseEvent(id, sel, theEvent, DWT.MouseUp)) return;
    super.rightMouseUp(id, sel, theEvent);
}

void rightMouseDragged(int /*long*/ id, int /*long*/ sel, int /*long*/ theEvent) {
    if (!mouseEvent(id, sel, theEvent, DWT.MouseMove)) return;
    super.rightMouseDragged(id, sel, theEvent);
}

void otherMouseDown(int /*long*/ id, int /*long*/ sel, int /*long*/ theEvent) {
    if (!mouseEvent(id, sel, theEvent, DWT.MouseDown)) return;
    super.otherMouseDown(id, sel, theEvent);
}

void otherMouseUp(int /*long*/ id, int /*long*/ sel, int /*long*/ theEvent) {
    if (!mouseEvent(id, sel, theEvent, DWT.MouseUp)) return;
    super.otherMouseUp(id, sel, theEvent);
}

void otherMouseDragged(int /*long*/ id, int /*long*/ sel, int /*long*/ theEvent) {
    if (!mouseEvent(id, sel, theEvent, DWT.MouseMove)) return;
    super.otherMouseDragged(id, sel, theEvent);
}

void moved () {
    sendEvent (DWT.Move);
}

/**
 * Moves the receiver above the specified control in the
 * drawing order. If the argument is null, then the receiver
 * is moved to the top of the drawing order. The control at
 * the top of the drawing order will not be covered by other
 * controls even if they occupy intersecting areas.
 *
 * @param control the sibling control (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the control has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Control#moveBelow
 * @see Composite#getChildren
 */
public void moveAbove (Control control) {
    checkWidget();
    if (control !is null) {
        if (control.isDisposed ()) error (DWT.ERROR_INVALID_ARGUMENT);
        if (parent !is control.parent) return;
    }
    setZOrder (control, true);
}

/**
 * Moves the receiver below the specified control in the
 * drawing order. If the argument is null, then the receiver
 * is moved to the bottom of the drawing order. The control at
 * the bottom of the drawing order will be covered by all other
 * controls which occupy intersecting areas.
 *
 * @param control the sibling control (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the control has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Control#moveAbove
 * @see Composite#getChildren
 */
public void moveBelow (Control control) {
    checkWidget();
    if (control !is null) {
        if (control.isDisposed ()) error (DWT.ERROR_INVALID_ARGUMENT);
        if (parent !is control.parent) return;
    }
    setZOrder (control, false);
}

Accessible new_Accessible (Control control) {
    return Accessible.internal_new_Accessible (this);
}

/**
 * Causes the receiver to be resized to its preferred size.
 * For a composite, this involves computing the preferred size
 * from its layout, if there is one.
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #computeSize(int, int, bool)
 */
public void pack () {
    checkWidget();
    pack (true);
}

/**
 * Causes the receiver to be resized to its preferred size.
 * For a composite, this involves computing the preferred size
 * from its layout, if there is one.
 * <p>
 * If the changed flag is <code>true</code>, it indicates that the receiver's
 * <em>contents</em> have changed, therefore any caches that a layout manager
 * containing the control may have been keeping need to be flushed. When the
 * control is resized, the changed flag will be <code>false</code>, so layout
 * manager caches can be retained.
 * </p>
 *
 * @param changed whether or not the receiver's contents have changed
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #computeSize(int, int, bool)
 */
public void pack (bool changed) {
    checkWidget();
    setSize (computeSize (DWT.DEFAULT, DWT.DEFAULT, changed));
}

NSView paintView () {
    return eventView ();
}

/**
 * Prints the receiver and all children.
 *
 * @param gc the gc where the drawing occurs
 * @return <code>true</code> if the operation was successful and <code>false</code> otherwise
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the gc is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the gc has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public bool print (GC gc) {
    checkWidget ();
    if (gc is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (gc.isDisposed ()) error (DWT.ERROR_INVALID_ARGUMENT);

    gc.handle.saveGraphicsState();
    NSGraphicsContext.setCurrentContext(gc.handle);
    NSAffineTransform transform = NSAffineTransform.transform ();
    transform.translateXBy (0, view.bounds().height);
    transform.scaleXBy (1, -1);
    transform.concat ();
    view.displayRectIgnoringOpacity(view.bounds(), gc.handle);
    gc.handle.restoreGraphicsState();
    return true;
}

/**
 * Causes the entire bounds of the receiver to be marked
 * as needing to be redrawn. The next time a paint request
 * is processed, the control will be completely painted,
 * including the background.
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #update()
 * @see PaintListener
 * @see DWT#Paint
 * @see DWT#NO_BACKGROUND
 * @see DWT#NO_REDRAW_RESIZE
 * @see DWT#NO_MERGE_PAINTS
 * @see DWT#DOUBLE_BUFFERED
 */
public void redraw () {
    checkWidget();
    view.setNeedsDisplay(true);
}

void redraw (bool children) {
//  checkWidget();
    view.setNeedsDisplay(true);
}

/**
 * Causes the rectangular area of the receiver specified by
 * the arguments to be marked as needing to be redrawn.
 * The next time a paint request is processed, that area of
 * the receiver will be painted, including the background.
 * If the <code>all</code> flag is <code>true</code>, any
 * children of the receiver which intersect with the specified
 * area will also paint their intersecting areas. If the
 * <code>all</code> flag is <code>false</code>, the children
 * will not be painted.
 *
 * @param x the x coordinate of the area to draw
 * @param y the y coordinate of the area to draw
 * @param width the width of the area to draw
 * @param height the height of the area to draw
 * @param all <code>true</code> if children should redraw, and <code>false</code> otherwise
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #update()
 * @see PaintListener
 * @see DWT#Paint
 * @see DWT#NO_BACKGROUND
 * @see DWT#NO_REDRAW_RESIZE
 * @see DWT#NO_MERGE_PAINTS
 * @see DWT#DOUBLE_BUFFERED
 */
public void redraw (int x, int y, int width, int height, bool all) {
    checkWidget ();
    NSRect rect = NSRect();
    rect.x = x;
    rect.y = y;
    rect.width = width;
    rect.height = height;
    view.setNeedsDisplayInRect(rect);
}

int /*long*/ regionToRects(int /*long*/ message, int /*long*/ rgn, int /*long*/ r, int /*long*/ path) {
    NSPoint pt = new NSPoint();
    short[] rect = new short[4];
    if (message is OS.kQDRegionToRectsMsgParse) {
        OS.memmove(rect, r, rect.length * 2);
        pt.x = rect[1];
        pt.y = rect[0];
        OS.objc_msgSend(path, OS.sel_moveToPoint_, pt);
        pt.x = rect[3];
        OS.objc_msgSend(path, OS.sel_lineToPoint_, pt);
        pt.x = rect[3];
        pt.y = rect[2];
        OS.objc_msgSend(path, OS.sel_lineToPoint_, pt);
        pt.x = rect[1];
        OS.objc_msgSend(path, OS.sel_lineToPoint_, pt);
        OS.objc_msgSend(path, OS.sel_closePath);
    }
    return 0;
}

void register () {
    super.register ();
    display.addWidget (view, this);
}

void release (bool destroy) {
    Control next = null, previous = null;
    if (destroy && parent !is null) {
        Control[] children = parent._getChildren ();
        int index = 0;
        while (index < children.length) {
            if (children [index] is this) break;
            index++;
        }
        if (0 < index && (index + 1) < children.length) {
            next = children [index + 1];
            previous = children [index - 1];
        }
    }
    super.release (destroy);
    if (destroy) {
        if (previous !is null) previous.addRelation (next);
    }
}

void releaseHandle () {
    super.releaseHandle ();
    if (view !is null) view.release();
    view = null;
    parent = null;
}

void releaseParent () {
    invalidateVisibleRegion ();
    parent.removeControl (this);
}

void releaseWidget () {
    super.releaseWidget ();
    if (display.currentControl is this) {
        display.currentControl = null;
        display.timerExec(-1, display.hoverTimer);
    }
    if (display.trackingControl is this) display.trackingControl = null;
    if (display.tooltipControl is this) display.tooltipControl = null;
    if (menu !is null && !menu.isDisposed ()) {
        menu.dispose ();
    }
    menu = null;
    if (visibleRgn !is 0) OS.DisposeRgn (visibleRgn);
    visibleRgn = 0;
    layoutData = null;
    if (accessible !is null) {
        accessible.internal_dispose_Accessible ();
    }
    accessible = null;
    region = null;
    if (regionPath !is null) regionPath.release();
    regionPath = null;
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the control is moved or resized.
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
 * @see ControlListener
 * @see #addControlListener
 */
public void removeControlListener (ControlListener listener) {
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (DWT.Move, listener);
    eventTable.unhook (DWT.Resize, listener);
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when a drag gesture occurs.
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
 * @see DragDetectListener
 * @see #addDragDetectListener
 *
 * @since 3.3
 */
public void removeDragDetectListener(DragDetectListener listener) {
    checkWidget ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (DWT.DragDetect, listener);
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the control gains or loses focus.
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
 * @see FocusListener
 * @see #addFocusListener
 */
public void removeFocusListener(FocusListener listener) {
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook(DWT.FocusIn, listener);
    eventTable.unhook(DWT.FocusOut, listener);
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the help events are generated for the control.
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
 * @see HelpListener
 * @see #addHelpListener
 */
public void removeHelpListener (HelpListener listener) {
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (DWT.Help, listener);
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when keys are pressed and released on the system keyboard.
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
 * @see KeyListener
 * @see #addKeyListener
 */
public void removeKeyListener(KeyListener listener) {
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook(DWT.KeyUp, listener);
    eventTable.unhook(DWT.KeyDown, listener);
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the platform-specific context menu trigger has
 * occurred.
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
 * @see MenuDetectListener
 * @see #addMenuDetectListener
 *
 * @since 3.3
 */
public void removeMenuDetectListener (MenuDetectListener listener) {
    checkWidget ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (DWT.MenuDetect, listener);
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when mouse buttons are pressed and released.
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
 * @see MouseListener
 * @see #addMouseListener
 */
public void removeMouseListener(MouseListener listener) {
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook(DWT.MouseDown, listener);
    eventTable.unhook(DWT.MouseUp, listener);
    eventTable.unhook(DWT.MouseDoubleClick, listener);
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the mouse moves.
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
 * @see MouseMoveListener
 * @see #addMouseMoveListener
 */
public void removeMouseMoveListener(MouseMoveListener listener) {
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook(DWT.MouseMove, listener);
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the mouse passes or hovers over controls.
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
 * @see MouseTrackListener
 * @see #addMouseTrackListener
 */
public void removeMouseTrackListener(MouseTrackListener listener) {
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (DWT.MouseEnter, listener);
    eventTable.unhook (DWT.MouseExit, listener);
    eventTable.unhook (DWT.MouseHover, listener);
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the mouse wheel is scrolled.
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
 * @see MouseWheelListener
 * @see #addMouseWheelListener
 *
 * @since 3.3
 */
public void removeMouseWheelListener (MouseWheelListener listener) {
    checkWidget ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (DWT.MouseWheel, listener);
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the receiver needs to be painted.
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
 * @see PaintListener
 * @see #addPaintListener
 */
public void removePaintListener(PaintListener listener) {
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook(DWT.Paint, listener);
}

/*
 * Remove "Labeled by" relations from the receiver.
 */
void removeRelation () {
    if (!isDescribedByLabel()) return;
    NSObject accessibleElement = focusView();

    if (accessibleElement instanceof NSControl) {
        NSControl viewAsControl = (NSControl) accessibleElement;
        if (viewAsControl.cell() !is null) accessibleElement = viewAsControl.cell();
    }

    accessibleElement.accessibilitySetOverrideValue(accessibleElement, OS.NSAccessibilityTitleUIElementAttribute);
}


/**
 * Removes the listener from the collection of listeners who will
 * be notified when traversal events occur.
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
 * @see TraverseListener
 * @see #addTraverseListener
 */
public void removeTraverseListener(TraverseListener listener) {
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (DWT.Traverse, listener);
}

void resetVisibleRegion () {
    if (visibleRgn !is 0) {
        OS.DisposeRgn (visibleRgn);
        visibleRgn = 0;
    }
    GCData[] gcs = display.contexts;
    if (gcs !is null) {
        int /*long*/ visibleRgn = 0;
        for (int i=0; i<gcs.length; i++) {
            GCData data = gcs [i];
            if (data !is null) {
                if (data.view is view) {
                    if (visibleRgn is 0) visibleRgn = getVisibleRegion ();
                    data.state &= ~VISIBLE_REGION;
                    OS.CopyRgn (visibleRgn, data.visibleRgn);
                }
            }
        }
        if (visibleRgn !is 0) OS.DisposeRgn (visibleRgn);
    }
}

void resized () {
    sendEvent (DWT.Resize);
}

bool sendDragEvent (int button, int stateMask, int x, int y) {
    Event event = new Event ();
    event.button = button;
    event.x = x;
    event.y = y;
    event.stateMask = stateMask;
    postEvent (DWT.DragDetect, event);
    return event.doit;
}

void sendFocusEvent (int type) {
    Display display = this.display;
    Shell shell = getShell ();

    display.focusEvent = type;
    display.focusControl = this;
    sendEvent (type);
    // widget could be disposed at this point
    display.focusEvent = DWT.None;
    display.focusControl = null;

    /*
    * It is possible that the shell may be
    * disposed at this point.  If this happens
    * don't send the activate and deactivate
    * events.
    */
    if (!shell.isDisposed ()) {
        switch (type) {
            case DWT.FocusIn:
                shell.setActiveControl (this);
                break;
            case DWT.FocusOut:
                if (shell !is display.getActiveShell ()) {
                    shell.setActiveControl (null);
                }
                break;
            default:
        }
    }
}

bool sendMouseEvent (NSEvent nsEvent, int type, bool send) {
    Shell shell = null;
    Event event = new Event ();
    switch (type) {
        case DWT.MouseDown:
            shell = getShell ();
            //FALL THROUGH
        case DWT.MouseUp:
        case DWT.MouseDoubleClick:
        case DWT.DragDetect:
            int button = cast(int)/*64*/nsEvent.buttonNumber();
            switch (button) {
                case 0: event.button = 1; break;
                case 1: event.button = 3; break;
                case 2: event.button = 2; break;
                case 3: event.button = 4; break;
                case 4: event.button = 5; break;
                    default:
            }
            break;
        case DWT.MouseWheel:
            event.detail = DWT.SCROLL_LINE;
            Carbon.CGFloat delta = nsEvent.deltaY();
            event.count = delta > 0 ? Math.max (1, cast(int)delta) : Math.min (-1, cast(int)delta);
            break;
        default:
    }
    if (event.button !is 0) event.count = cast(int)/*64*/nsEvent.clickCount();
    NSPoint windowPoint;
    NSView view = eventView ();
    if (nsEvent is null || nsEvent.type() is OS.NSMouseMoved) {
        NSWindow window = view.window();
        windowPoint = window.convertScreenToBase(NSEvent.mouseLocation());
    } else {
        windowPoint = nsEvent.locationInWindow();
    }
    NSPoint point = view.convertPoint_fromView_(windowPoint, null);
    if (!view.isFlipped ()) {
        point.y = view.bounds().height - point.y;
    }
    event.x = cast(int) point.x;
    event.y = cast(int) point.y;
    setInputState (event, nsEvent, type);
    if (send) {
        sendEvent (type, event);
        if (isDisposed ()) return false;
    } else {
        postEvent (type, event);
    }
    if (shell !is null) shell.setActiveControl(this);
    return event.doit;
}

void setBackground () {
//  redrawWidget (handle, false);
}

/**
 * Sets the receiver's background color to the color specified
 * by the argument, or to the default system color for the control
 * if the argument is null.
 * <p>
 * Note: This operation is a hint and may be overridden by the platform.
 * For example, on Windows the background of a Button cannot be changed.
 * </p>
 * @param color the new color (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setBackground (Color color) {
    checkWidget();
    if (color !is null) {
        if (color.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    }
    float /*double*/ [] background = color !is null ? color.handle : null;
    if (equals (background, this.background)) return;
    this.background = background;
    updateBackground ();
    redrawWidget(view, true);
}

/**
 * Sets the receiver's background image to the image specified
 * by the argument, or to the default system color for the control
 * if the argument is null.  The background image is tiled to fill
 * the available space.
 * <p>
 * Note: This operation is a hint and may be overridden by the platform.
 * For example, on Windows the background of a Button cannot be changed.
 * </p>
 * @param image the new image (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument is not a bitmap</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.2
 */
public void setBackgroundImage (Image image) {
    checkWidget();
    if (image !is null && image.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    if (image is backgroundImage) return;
    backgroundImage = image;
    updateBackground();
    redrawWidget(view, false);
}

void updateBackground () {
}

void setBackground (NSColor nsColor) {
}

/**
 * Sets the receiver's size and location to the rectangular
 * area specified by the arguments. The <code>x</code> and
 * <code>y</code> arguments are relative to the receiver's
 * parent (or its display if its parent is null), unless
 * the receiver is a shell. In this case, the <code>x</code>
 * and <code>y</code> arguments are relative to the display.
 * <p>
 * Note: Attempting to set the width or height of the
 * receiver to a negative number will cause that
 * value to be set to zero instead.
 * </p>
 *
 * @param x the new x coordinate for the receiver
 * @param y the new y coordinate for the receiver
 * @param width the new width for the receiver
 * @param height the new height for the receiver
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setBounds (int x, int y, int width, int height) {
    checkWidget();
    setBounds (x, y, Math.max (0, width), Math.max (0, height), true, true);
}

void setBounds (int x, int y, int width, int height, bool move, bool resize) {
    NSView topView = topView();
    if (move && resize) {
        NSRect rect = NSRect();
        rect.x = x;
        rect.y = y;
        rect.width = width;
        rect.height = height;
        topView.setFrame (rect);
    } else if (move) {
            NSPoint point = NSPoint();
        point.x = x;
        point.y = y;
        topView.setFrameOrigin(point);
    } else if (resize) {
            NSSize size = NSSize();
        size.width = width;
        size.height = height;
        topView.setFrameSize(size);
    }
}

/**
 * Sets the receiver's size and location to the rectangular
 * area specified by the argument. The <code>x</code> and
 * <code>y</code> fields of the rectangle are relative to
 * the receiver's parent (or its display if its parent is null).
 * <p>
 * Note: Attempting to set the width or height of the
 * receiver to a negative number will cause that
 * value to be set to zero instead.
 * </p>
 *
 * @param rect the new bounds for the receiver
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setBounds (Rectangle rect) {
    checkWidget ();
    if (rect is null) error (DWT.ERROR_NULL_ARGUMENT);
    setBounds (rect.x, rect.y, Math.max (0, rect.width), Math.max (0, rect.height), true, true);
}

/**
 * If the argument is <code>true</code>, causes the receiver to have
 * all mouse events delivered to it until the method is called with
 * <code>false</code> as the argument.  Note that on some platforms,
 * a mouse button must currently be down for capture to be assigned.
 *
 * @param capture <code>true</code> to capture the mouse, and <code>false</code> to release it
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setCapture (bool capture) {
    checkWidget();
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
    NSRect frame = topView().frame();
    parent.setClipRegion(frame.x + x, frame.y + y);
}

/**
 * Sets the receiver's cursor to the cursor specified by the
 * argument, or to the default cursor for that kind of control
 * if the argument is null.
 * <p>
 * When the mouse pointer passes over a control its appearance
 * is changed to match the control's cursor.
 * </p>
 *
 * @param cursor the new cursor (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setCursor (Cursor cursor) {
    checkWidget();
    if (cursor !is null && cursor.isDisposed ()) error (DWT.ERROR_INVALID_ARGUMENT);
    this.cursor = cursor;
    if (!isEnabled()) return;
    if (!view.window().areCursorRectsEnabled()) return;
    display.setCursor (display.currentControl);
}

void setDefaultFont () {
    if (display.smallFonts) {
        setFont (defaultFont ().handle);
        setSmallSize ();
    }
}

/**
 * Sets the receiver's drag detect state. If the argument is
 * <code>true</code>, the receiver will detect drag gestures,
 * otherwise these gestures will be ignored.
 *
 * @param dragDetect the new drag detect state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.3
 */
public void setDragDetect (bool dragDetect) {
    checkWidget ();
    if (dragDetect) {
        state |= DRAG_DETECT;
    } else {
        state &= ~DRAG_DETECT;
    }
}

/**
 * Enables the receiver if the argument is <code>true</code>,
 * and disables it otherwise. A disabled control is typically
 * not selectable from the user interface and draws with an
 * inactive or "grayed" look.
 *
 * @param enabled the new enabled state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setEnabled (bool enabled) {
    checkWidget();
    if (((state & DISABLED) is 0) is enabled) return;
    Control control = null;
    bool fixFocus_ = false;
    if (!enabled) {
        if (display.focusEvent !is DWT.FocusOut) {
            control = display.getFocusControl ();
            fixFocus_ = isFocusAncestor (control);
        }
        }
    }
    if (enabled) {
        state &= ~DISABLED;
    } else {
        state |= DISABLED;
    }
    enableWidget (enabled);
    if (fixFocus_) fixFocus (control);
}

/**
 * Causes the receiver to have the <em>keyboard focus</em>,
 * such that all keyboard events will be delivered to it.  Focus
 * reassignment will respect applicable platform constraints.
 *
 * @return <code>true</code> if the control got focus, and <code>false</code> if it was unable to.
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #forceFocus
 */
public bool setFocus () {
    checkWidget();
    if ((style & DWT.NO_FOCUS) !is 0) return false;
    return forceFocus ();
}

/**
 * Sets the font that the receiver will use to paint textual information
 * to the font specified by the argument, or to the default font for that
 * kind of control if the argument is null.
 *
 * @param font the new font (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setFont (Font font) {
    checkWidget();
    if (font !is null) {
        if (font.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    }
    this.font = font;
    setFont (font !is null ? font.handle : defaultFont().handle);
}

void setFont (NSFont font) {
    if (cast(NSControl) view) {
        (cast(NSControl)view).setFont(font);
    }
}

/**
 * Sets the receiver's foreground color to the color specified
 * by the argument, or to the default system color for the control
 * if the argument is null.
 * <p>
 * Note: This operation is a hint and may be overridden by the platform.
 * </p>
 * @param color the new color (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setForeground (Color color) {
    checkWidget();
    if (color !is null) {
        if (color.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    }
    float /*double*/ [] foreground = color !is null ? color.handle : null;
    if (equals (foreground, this.foreground)) return;
    this.foreground = foreground;
    setForeground (foreground);
    redrawWidget (view, false);
}

void setForeground (float /*double*/ [] color) {
}

void setFrameOrigin (objc.id id, objc.SEL sel, NSPoint point) {
    NSView topView = topView ();
    if (topView.id !is id) {
        super.setFrameOrigin(id, sel, point);
        return;
    }
    NSRect frame = topView.frame();
    super.setFrameOrigin(id, sel, point);
    if (frame.x !is point.x || frame.y !is point.y) {
        invalidateVisibleRegion();
        moved ();
    }
}

void setFrameSize (objc.id id, objc.SEL sel, NSSize size) {
    NSView topView = topView ();
    if (topView.id !is id) {
        super.setFrameSize(id, sel, size);
        return;
    }
    NSRect frame = topView.frame();
    super.setFrameSize(id, sel, size);
    if (frame.width !is size.width || frame.height !is size.height) {
        invalidateVisibleRegion();
        resized ();
    }
}

/**
 * Sets the layout data associated with the receiver to the argument.
 *
 * @param layoutData the new layout data for the receiver.
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setLayoutData (Object layoutData) {
    checkWidget();
    this.layoutData = layoutData;
}

/**
 * Sets the receiver's location to the point specified by
 * the arguments which are relative to the receiver's
 * parent (or its display if its parent is null), unless
 * the receiver is a shell. In this case, the point is
 * relative to the display.
 *
 * @param x the new x coordinate for the receiver
 * @param y the new y coordinate for the receiver
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setLocation (int x, int y) {
    checkWidget();
    setBounds (x, y, 0, 0, true, false);
}

/**
 * Sets the receiver's location to the point specified by
 * the arguments which are relative to the receiver's
 * parent (or its display if its parent is null), unless
 * the receiver is a shell. In this case, the point is
 * relative to the display.
 *
 * @param location the new location for the receiver
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setLocation (Point location) {
    checkWidget();
    if (location is null) error (DWT.ERROR_NULL_ARGUMENT);
    setBounds (location.x, location.y, 0, 0, true, false);
}

/**
 * Sets the receiver's pop up menu to the argument.
 * All controls may optionally have a pop up
 * menu that is displayed when the user requests one for
 * the control. The sequence of key strokes, button presses
 * and/or button releases that are used to request a pop up
 * menu is platform specific.
 * <p>
 * Note: Disposing of a control that has a pop up menu will
 * dispose of the menu.  To avoid this behavior, set the
 * menu to null before the control is disposed.
 * </p>
 *
 * @param menu the new pop up menu
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_MENU_NOT_POP_UP - the menu is not a pop up menu</li>
 *    <li>ERROR_INVALID_PARENT - if the menu is not in the same widget tree</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the menu has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setMenu (Menu menu) {
    checkWidget();
    if (menu !is null) {
        if (menu.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
        if ((menu.style & DWT.POP_UP) is 0) {
            error (DWT.ERROR_MENU_NOT_POP_UP);
        }
        if (menu.parent !is menuShell ()) {
            error (DWT.ERROR_INVALID_PARENT);
        }
    }
    this.menu = menu;
}

/**
 * Changes the parent of the widget to be the one provided if
 * the underlying operating system supports this feature.
 * Returns <code>true</code> if the parent is successfully changed.
 *
 * @param parent the new parent for the control.
 * @return <code>true</code> if the parent is changed and <code>false</code> otherwise.
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is <code>null</code></li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *  </ul>
 */
public bool setParent (Composite parent) {
    checkWidget();
    if (parent is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (parent.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    if (this.parent is parent) return true;
    if (!isReparentable ()) return false;
    releaseParent ();
    Shell newShell = parent.getShell (), oldShell = getShell ();
    Decorations newDecorations = parent.menuShell (), oldDecorations = menuShell ();
    if (oldShell !is newShell || oldDecorations !is newDecorations) {
        Menu [] menus = oldShell.findMenus (this);
        fixChildren (newShell, oldShell, newDecorations, oldDecorations, menus);
    }
    NSView topView = topView ();
    topView.retain();
    topView.removeFromSuperview();
    parent.contentView().addSubview(topView, OS.NSWindowBelow, null);
    topView.release();
    this.parent = parent;
    return true;
}

/**
 * If the argument is <code>false</code>, causes subsequent drawing
 * operations in the receiver to be ignored. No drawing of any kind
 * can occur in the receiver until the flag is set to true.
 * Graphics operations that occurred while the flag was
 * <code>false</code> are lost. When the flag is set to <code>true</code>,
 * the entire widget is marked as needing to be redrawn.  Nested calls
 * to this method are stacked.
 * <p>
 * Note: This operation is a hint and may not be supported on some
 * platforms or for some widgets.
 * </p>
 *
 * @param redraw the new redraw state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #redraw(int, int, int, int, bool)
 * @see #update()
 */
public void setRedraw (bool redraw) {
    checkWidget();
    if (redraw) {
        if (--drawCount is 0) {
            invalidateVisibleRegion ();
            redrawWidget(topView (), true);
        }
    } else {
        if (drawCount is 0) {
            invalidateVisibleRegion ();
        }
        drawCount++;
    }
}

/**
 * Sets the shape of the control to the region specified
 * by the argument.  When the argument is null, the
 * default shape of the control is restored.
 *
 * @param region the region that defines the shape of the control (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the region has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public void setRegion (Region region) {
    checkWidget ();
    if (region !is null && region.isDisposed()) error (DWT.ERROR_INVALID_ARGUMENT);
    this.region = region;
    if (regionPath !is null) regionPath.release();
    regionPath = getPath(region);
    redrawWidget(view, true);
}

void setRelations () {
    if (parent is null) return;
    Control [] children = parent._getChildren ();
    int count = children.length;
    if (count > 1) {
        /*
         * the receiver is the last item in the list, so its predecessor will
         * be the second-last item in the list
         */
        Control child = children [count - 2];
        if (child !is this) {
            child.addRelation (this);
        }
    }
}

bool setRadioSelection (bool value){
    return false;
}

/**
 * Sets the receiver's size to the point specified by the arguments.
 * <p>
 * Note: Attempting to set the width or height of the
 * receiver to a negative number will cause that
 * value to be set to zero instead.
 * </p>
 *
 * @param width the new width for the receiver
 * @param height the new height for the receiver
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSize (int width, int height) {
    checkWidget();
    setBounds (0, 0, Math.max (0, width), Math.max (0, height), false, true);
}

/**
 * Sets the receiver's size to the point specified by the argument.
 * <p>
 * Note: Attempting to set the width or height of the
 * receiver to a negative number will cause them to be
 * set to zero instead.
 * </p>
 *
 * @param size the new size for the receiver
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the point is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSize (Point size) {
    checkWidget ();
    if (size is null) error (DWT.ERROR_NULL_ARGUMENT);
    setBounds (0, 0, Math.max (0, size.x), Math.max (0, size.y), false, true);
}

void setSmallSize () {
    if (view instanceof NSControl) {
        NSCell cell = ((NSControl)view).cell();
        if (cell !is null) cell.setControlSize (OS.NSSmallControlSize);
    }
}

bool setTabItemFocus () {
    if (!isShowing ()) return false;
    return forceFocus ();
}

/**
 * Sets the receiver's tool tip text to the argument, which
 * may be null indicating that the default tool tip for the
 * control will be shown. For a control that has a default
 * tool tip, such as the Tree control on Windows, setting
 * the tool tip text to an empty string replaces the default,
 * causing no tool tip text to be shown.
 * <p>
 * The mnemonic indicator (character '&amp;') is not displayed in a tool tip.
 * To display a single '&amp;' in the tool tip, the character '&amp;' can be
 * escaped by doubling it in the string.
 * </p>
 *
 * @param string the new tool tip text (or null)
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setToolTipText (String string) {
    checkWidget();
    toolTipText = string;
    checkToolTip (null);
}

/**
 * Marks the receiver as visible if the argument is <code>true</code>,
 * and marks it invisible otherwise.
 * <p>
 * If one of the receiver's ancestors is not visible or some
 * other condition makes the receiver not visible, marking
 * it visible may not actually cause it to be displayed.
 * </p>
 *
 * @param visible the new visibility state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setVisible (bool visible) {
    checkWidget();
    if (visible) {
        if ((state & HIDDEN) is 0) return;
        state &= ~HIDDEN;
    } else {
        if ((state & HIDDEN) !is 0) return;
        state |= HIDDEN;
    }
    if (visible) {
        /*
        * It is possible (but unlikely), that application
        * code could have disposed the widget in the show
        * event.  If this happens, just return.
        */
        sendEvent (DWT.Show);
        if (isDisposed ()) return;
    }

    /*
    * Feature in the Macintosh.  If the receiver has focus, hiding
    * the receiver causes no control to have focus.  Also, the focus
    * needs to be cleared from any TXNObject so that it stops blinking
    * the caret.  The fix is to assign focus to the first ancestor
    * control that takes focus.  If no control will take focus, clear
    * the focus control.
    */
    Control control = null;
    bool fixFocus_ = false;
    if (!visible) {
        if (display.focusEvent !is DWT.FocusOut) {
            control = display.getFocusControl ();
            fixFocus_ = isFocusAncestor (control);
        }
        }
    }
    topView().setHidden(!visible);
    invalidateVisibleRegion();
    if (!visible) {
        /*
        * It is possible (but unlikely), that application
        * code could have disposed the widget in the show
        * event.  If this happens, just return.
        */
        sendEvent (DWT.Hide);
        if (isDisposed ()) return;
    }
    if (fixFocus_) fixFocus (control);
}

void setZOrder () {
    NSView topView = topView ();
    parent.contentView().addSubview(topView, OS.NSWindowBelow, null);
}

bool shouldDelayWindowOrderingForEvent (int /*long*/ id, int /*long*/ sel, int /*long*/ theEvent) {
    Shell shell = getShell ();
    if ((shell.style & DWT.ON_TOP) !is 0) return false;
    return super.shouldDelayWindowOrderingForEvent (id, sel, theEvent);
}

void setZOrder (Control sibling, bool above) {
    int index = 0, siblingIndex = 0, oldNextIndex = -1;
    Control[] children = null;
    /* determine the receiver's and sibling's indexes in the parent */
    children = parent._getChildren ();
    while (index < children.length) {
        if (children [index] is this) break;
        index++;
    }
    if (sibling !is null) {
        while (siblingIndex < children.length) {
            if (children [siblingIndex] is sibling) break;
            siblingIndex++;
        }
    }
    /* remove "Labeled by" relationships that will no longer be valid */
    removeRelation ();
    if (index + 1 < children.length) {
        oldNextIndex = index + 1;
        children [oldNextIndex].removeRelation ();
    }
    if (sibling !is null) {
        if (above) {
            sibling.removeRelation ();
        } else {
            if (siblingIndex + 1 < children.length) {
                children [siblingIndex + 1].removeRelation ();
            }
        }
    }

    NSView otherView = sibling is null ? null : sibling.topView ();
    view.retain();
    view.removeFromSuperview();
    parent.contentView().addSubview(view, above ? OS.NSWindowAbove : OS.NSWindowBelow, otherView);
    view.release();
    invalidateVisibleRegion();

    /* determine the receiver's new index in the parent */
    if (sibling !is null) {
        if (above) {
            index = siblingIndex - (index < siblingIndex ? 1 : 0);
        } else {
            index = siblingIndex + (siblingIndex < index ? 1 : 0);
        }
    } else {
        if (above) {
            index = 0;
        } else {
            index = children.length - 1;
        }
    }

    /* add new "Labeled by" relations as needed */
    children = parent._getChildren ();
    if (0 < index) {
        children [index - 1].addRelation (this);
    }
    if (index + 1 < children.length) {
        addRelation (children [index + 1]);
    }
    if (oldNextIndex !is -1) {
        if (oldNextIndex <= index) oldNextIndex--;
        /* the last two conditions below ensure that duplicate relations are not hooked */
        if (0 < oldNextIndex && oldNextIndex !is index && oldNextIndex !is index + 1) {
            children [oldNextIndex - 1].addRelation (children [oldNextIndex]);
        }
    }
}

void sort (int [] items) {
    /* Shell Sort from K&R, pg 108 */
    int length = items.length;
    for (int gap=length/2; gap>0; gap/=2) {
        for (int i=gap; i<length; i++) {
            for (int j=i-gap; j>=0; j-=gap) {
                if (items [j] <= items [j + gap]) {
                    int swap = items [j];
                    items [j] = items [j + gap];
                    items [j + gap] = swap;
                }
            }
        }
    }
}

NSSize textExtent (String string) {
    NSAttributedString attribStr = createString(string, null, null, 0, true, false);
    NSSize size = attribStr.size();
    attribStr.release();
    return size;
}

String tooltipText () {
    return toolTipText;
}

/**
 * Returns a point which is the result of converting the
 * argument, which is specified in display relative coordinates,
 * to coordinates relative to the receiver.
 * <p>
 * @param x the x coordinate to be translated
 * @param y the y coordinate to be translated
 * @return the translated coordinates
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.1
 */
public Point toControl (int x, int y) {
    checkWidget();
    return display.map (null, this, x, y);
}

/**
 * Returns a point which is the result of converting the
 * argument, which is specified in display relative coordinates,
 * to coordinates relative to the receiver.
 * <p>
 * @param point the point to be translated (must not be null)
 * @return the translated coordinates
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the point is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Point toControl (Point point) {
    checkWidget();
    if (point is null) error (DWT.ERROR_NULL_ARGUMENT);
    return toControl (point.x, point.y);
}

/**
 * Returns a point which is the result of converting the
 * argument, which is specified in coordinates relative to
 * the receiver, to display relative coordinates.
 * <p>
 * @param x the x coordinate to be translated
 * @param y the y coordinate to be translated
 * @return the translated coordinates
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.1
 */
public Point toDisplay (int x, int y) {
    checkWidget();
    return display.map (this, null, x, y);
}

/**
 * Returns a point which is the result of converting the
 * argument, which is specified in coordinates relative to
 * the receiver, to display relative coordinates.
 * <p>
 * @param point the point to be translated (must not be null)
 * @return the translated coordinates
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the point is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Point toDisplay (Point point) {
    checkWidget();
    if (point is null) error (DWT.ERROR_NULL_ARGUMENT);
    return toDisplay (point.x, point.y);
}

NSView topView () {
    return view;
}

bool translateTraversal (short key, NSEvent theEvent, bool [] consume) {
    int detail = DWT.TRAVERSE_NONE;
    int code = traversalCode (key, theEvent);
    bool all = false;
    switch (key) {
        case 53: /* Esc */ {
            all = true;
            detail = DWT.TRAVERSE_ESCAPE;
            break;
        }
        case 76: /* KP Enter */
        case 36: /* Return */ {
            all = true;
            detail = DWT.TRAVERSE_RETURN;
            break;
        }
        case 48: /* Tab */ {
            NSUInteger modifiers = theEvent.modifierFlags ();
            bool next = (modifiers & OS.NSShiftKeyMask) is 0;
            detail = next ? DWT.TRAVERSE_TAB_NEXT : DWT.TRAVERSE_TAB_PREVIOUS;
            break;
        }
        case 126: /* Up arrow */
        case 123: /* Left arrow */
        case 125: /* Down arrow */
        case 124: /* Right arrow */ {
            bool next = key is 125 /* Down arrow */ || key is 124 /* Right arrow */;
            detail = next ? DWT.TRAVERSE_ARROW_NEXT : DWT.TRAVERSE_ARROW_PREVIOUS;
            break;
        }
        case 116: /* Page up */
        case 121: /* Page down */ {
            all = true;
            NSUInteger modifiers = theEvent.modifierFlags ();
            if ((modifiers & OS.NSControlKeyMask) is 0) return false;
            detail = key is 121 /* Page down */ ? DWT.TRAVERSE_PAGE_NEXT : DWT.TRAVERSE_PAGE_PREVIOUS;
            break;
        }
        default:
            return false;
    }
    Event event = new Event ();
    event.doit = consume [0] = (code & detail) !is 0;
    event.detail = detail;
    if (!setKeyState (event, DWT.Traverse, theEvent)) return false;
    Shell shell = getShell ();
    Control control = this;
    do {
        if (control.traverse (event)) return true;
        if (!event.doit && control.hooks (DWT.Traverse)) {
            return false;
        }
        if (control is shell) return false;
        control = control.parent;
    } while (all && control !is null);
    return false;
}

int traversalCode (short key, NSEvent theEvent) {
    int code = DWT.TRAVERSE_RETURN | DWT.TRAVERSE_TAB_NEXT | DWT.TRAVERSE_TAB_PREVIOUS | DWT.TRAVERSE_PAGE_NEXT | DWT.TRAVERSE_PAGE_PREVIOUS;
    Shell shell = getShell ();
    if (shell.parent !is null) code |= DWT.TRAVERSE_ESCAPE;
    return code;
}

bool traverseMnemonic (char key) {
    return false;
}

/**
 * Based on the argument, perform one of the expected platform
 * traversal action. The argument should be one of the constants:
 * <code>DWT.TRAVERSE_ESCAPE</code>, <code>DWT.TRAVERSE_RETURN</code>,
 * <code>DWT.TRAVERSE_TAB_NEXT</code>, <code>DWT.TRAVERSE_TAB_PREVIOUS</code>,
 * <code>DWT.TRAVERSE_ARROW_NEXT</code> and <code>DWT.TRAVERSE_ARROW_PREVIOUS</code>.
 *
 * @param traversal the type of traversal
 * @return true if the traversal succeeded
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool traverse (int traversal) {
    checkWidget();
    Event event = new Event ();
    event.doit = true;
    event.detail = traversal;
    return traverse (event);
}

bool traverse (Event event) {
    sendEvent (DWT.Traverse, event);
    if (isDisposed ()) return true;
    if (!event.doit) return false;
    switch (event.detail) {
        case DWT.TRAVERSE_NONE:             return true;
        case DWT.TRAVERSE_ESCAPE:           return traverseEscape ();
        case DWT.TRAVERSE_RETURN:           return traverseReturn ();
        case DWT.TRAVERSE_TAB_NEXT:         return traverseGroup (true);
        case DWT.TRAVERSE_TAB_PREVIOUS:     return traverseGroup (false);
        case DWT.TRAVERSE_ARROW_NEXT:       return traverseItem (true);
        case DWT.TRAVERSE_ARROW_PREVIOUS:   return traverseItem (false);
        case DWT.TRAVERSE_MNEMONIC:         return traverseMnemonic (event);
        case DWT.TRAVERSE_PAGE_NEXT:        return traversePage (true);
        case DWT.TRAVERSE_PAGE_PREVIOUS:    return traversePage (false);
            default:
    }
    return false;
}

bool traverseEscape () {
    return false;
}

bool traverseGroup (bool next) {
    Control root = computeTabRoot ();
    Widget group = computeTabGroup ();
    Widget [] list = root.computeTabList ();
    int length = list.length;
    int index = 0;
    while (index < length) {
        if (list [index] is group) break;
        index++;
    }
    /*
    * It is possible (but unlikely), that application
    * code could have disposed the widget in focus in
    * or out events.  Ensure that a disposed widget is
    * not accessed.
    */
    if (index is length) return false;
    int start = index, offset = (next) ? 1 : -1;
    while ((index = ((index + offset + length) % length)) !is start) {
        Widget widget = list [index];
        if (!widget.isDisposed () && widget.setTabGroupFocus ()) {
            return true;
        }
    }
    if (group.isDisposed ()) return false;
    return group.setTabGroupFocus ();
}

bool traverseItem (bool next) {
    Control [] children = parent._getChildren ();
    int length = children.length;
    int index = 0;
    while (index < length) {
        if (children [index] is this) break;
        index++;
    }
    /*
    * It is possible (but unlikely), that application
    * code could have disposed the widget in focus in
    * or out events.  Ensure that a disposed widget is
    * not accessed.
    */
    if (index is length) return false;
    int start = index, offset = (next) ? 1 : -1;
    while ((index = (index + offset + length) % length) !is start) {
        Control child = children [index];
        if (!child.isDisposed () && child.isTabItem ()) {
            if (child.setTabItemFocus ()) return true;
        }
    }
    return false;
}

bool traverseReturn () {
    return false;
}

bool traversePage (bool next) {
    return false;
}

bool traverseMnemonic (Event event) {
    return false;
}

/**
 * Forces all outstanding paint requests for the widget
 * to be processed before this method returns. If there
 * are no outstanding paint request, this method does
 * nothing.
 * <p>
 * Note: This method does not cause a redraw.
 * </p>
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #redraw()
 * @see #redraw(int, int, int, int, bool)
 * @see PaintListener
 * @see DWT#Paint
 */
public void update () {
    checkWidget();
    update (false);
}

void update (bool all) {
//  checkWidget();
    if (display.isPainting.containsObject(view)) return;
    //TODO - not all
    view.displayIfNeeded ();
}

void updateBackgroundMode () {
    int oldState = state & PARENT_BACKGROUND;
    checkBackground ();
    if (oldState !is (state & PARENT_BACKGROUND)) {
        setBackground ();
    }
}

void resetCursorRects (int /*long*/ id, int /*long*/ sel) {
    if (isEnabled ()) callSuper (id, sel);
}

void updateTrackingAreas (int /*long*/ id, int /*long*/ sel) {
    if (isEnabled ()) callSuper (id, sel);
}

void updateCursorRects (bool enabled) {
    updateCursorRects (enabled, view);
}

void updateCursorRects (bool enabled, NSView widget) {
    if (enabled) {
        widget.resetCursorRects ();
        widget.updateTrackingAreas ();
    } else {
        widget.discardCursorRects ();
        NSArray areas = widget.trackingAreas ();
        for (int i = 0; i < areas.count(); i++) {
            widget.removeTrackingArea (new NSTrackingArea (areas.objectAtIndex (i)));
        }
    }
}

void updateLayout (bool all) {
    /* Do nothing */
}

}
