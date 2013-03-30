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
module dwt.widgets.Sash;

import dwt.dwthelper.utils;






import cocoa = dwt.internal.cocoa.id;

import dwt.DWT;
import dwt.accessibility.ACC;
import dwt.internal.cocoa.NSView;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSEvent;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSNumber;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSMutableArray;
import dwt.internal.cocoa.NSGraphicsContext;
import dwt.internal.cocoa.SWTView;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;
import dwt.widgets.Composite;
import dwt.widgets.Control;
import dwt.widgets.Event;
import dwt.widgets.TypedListener;
import dwt.graphics.Cursor;
import dwt.graphics.Point;
import dwt.graphics.Rectangle;
import dwt.events.SelectionListener;

/**
 * Instances of the receiver represent a selectable user interface object
 * that allows the user to drag a rubber banded outline of the sash within
 * the parent control.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>HORIZONTAL, VERTICAL, SMOOTH</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Selection</dd>
 * </dl>
 * <p>
 * Note: Only one of the styles HORIZONTAL and VERTICAL may be specified.
 * </p><p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the DWT implementation.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#sash">Sash snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">DWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 * @noextend This class is not intended to be subclassed by clients.
 */
public class Sash : Control {
    Cursor sizeCursor;
    bool dragging;
    int lastX, lastY, startX, startY;
    private final static int INCREMENT = 1;
    private final static int PAGE_INCREMENT = 9;
    NSArray accessibilityAttributes = null;

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
 * @see DWT#HORIZONTAL
 * @see DWT#VERTICAL
 * @see DWT#SMOOTH
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, checkStyle (style));
    int cursorStyle = (style & DWT.VERTICAL) !is 0 ? DWT.CURSOR_SIZEWE : DWT.CURSOR_SIZENS;
    sizeCursor = new Cursor (display, cursorStyle);
}

objc.id accessibilityAttributeNames(objc.id id, objc.SEL sel) {
    if (accessibilityAttributes is null) {
        NSMutableArray ourAttributes = NSMutableArray.arrayWithCapacity(10);
        ourAttributes.addObject(OS.NSAccessibilityRoleAttribute);
        ourAttributes.addObject(OS.NSAccessibilityRoleDescriptionAttribute);
        ourAttributes.addObject(OS.NSAccessibilityParentAttribute);
        ourAttributes.addObject(OS.NSAccessibilityPositionAttribute);
        ourAttributes.addObject(OS.NSAccessibilitySizeAttribute);
        ourAttributes.addObject(OS.NSAccessibilityWindowAttribute);
        ourAttributes.addObject(OS.NSAccessibilityTopLevelUIElementAttribute);
        ourAttributes.addObject(OS.NSAccessibilityFocusedAttribute);
        ourAttributes.addObject(OS.NSAccessibilityValueAttribute);
        ourAttributes.addObject(OS.NSAccessibilityMaxValueAttribute);
        ourAttributes.addObject(OS.NSAccessibilityMinValueAttribute);
        // The accessibility documentation says that these next two are optional, but the
        // Accessibility Verifier says they are required.
        ourAttributes.addObject(OS.NSAccessibilityNextContentsAttribute);
        ourAttributes.addObject(OS.NSAccessibilityPreviousContentsAttribute);
        ourAttributes.addObject(OS.NSAccessibilityOrientationAttribute);

        if (accessible !is null) {
            // See if the accessible will override or augment the standard list.
            // Help, title, and description can be overridden.
            NSMutableArray extraAttributes = NSMutableArray.arrayWithCapacity(3);
            extraAttributes.addObject(OS.NSAccessibilityHelpAttribute);
            extraAttributes.addObject(OS.NSAccessibilityDescriptionAttribute);
            extraAttributes.addObject(OS.NSAccessibilityTitleAttribute);

            for (NSInteger i = extraAttributes.count() - 1; i >= 0; i--) {
                NSString attribute = new NSString(extraAttributes.objectAtIndex(i).id);
                if (accessible.internal_accessibilityAttributeValue(attribute, ACC.CHILDID_SELF) !is null) {
                    ourAttributes.addObject(extraAttributes.objectAtIndex(i));
                }
            }
        }

        accessibilityAttributes = ourAttributes;
        accessibilityAttributes.retain();
    }

    return accessibilityAttributes.id;
}

objc.id accessibilityAttributeValue(objc.id id, objc.SEL sel, objc.id arg0) {
    objc.id returnValue = null;
    NSString attributeName = new NSString(arg0);

    if (accessible !is null) {
        cocoa.id returnObject = accessible.internal_accessibilityAttributeValue(attributeName, ACC.CHILDID_SELF);

        if (returnObject !is null) returnValue = returnObject.id;
    }

    if (returnValue !is null) return returnValue;

    if (attributeName.isEqualToString (OS.NSAccessibilityRoleAttribute) || attributeName.isEqualToString (OS.NSAccessibilityRoleDescriptionAttribute)) {
        NSString roleText = OS.NSAccessibilitySplitterRole;

        if (attributeName.isEqualToString (OS.NSAccessibilityRoleAttribute)) {
            return roleText.id;
        } else { // NSAccessibilityRoleDescriptionAttribute
            return OS.NSAccessibilityRoleDescription (roleText.id, null);
        }
    } else if (attributeName.isEqualToString (OS.NSAccessibilityEnabledAttribute)) {
        return NSNumber.numberWithBool(isEnabled()).id;
    } else if (attributeName.isEqualToString (OS.NSAccessibilityOrientationAttribute)) {
        NSString orientation = (style & DWT.VERTICAL) !is 0 ? OS.NSAccessibilityVerticalOrientationValue : OS.NSAccessibilityHorizontalOrientationValue;
        return orientation.id;
    } else if (attributeName.isEqualToString (OS.NSAccessibilityValueAttribute)) {
        Point location = getLocation();
        int value = (style & DWT.VERTICAL) !is 0 ? location.x : location.y;
        return NSNumber.numberWithInt(value).id;
    } else if (attributeName.isEqualToString (OS.NSAccessibilityMaxValueAttribute)) {
        NSRect parentBounds = view.bounds();
        Cocoa.CGFloat maxValue = (style & DWT.VERTICAL) !is 0 ?
        parentBounds.width :
        parentBounds.height;
        return NSNumber.numberWithInt(cast(int)maxValue).id;
    } else if (attributeName.isEqualToString (OS.NSAccessibilityMinValueAttribute)) {
        return NSNumber.numberWithInt(0).id;
    } else if (attributeName.isEqualToString (OS.NSAccessibilityNextContentsAttribute)) {
        Control[] children =  parent._getChildren();
        Control nextView = null;
        for (int i = 0; i < children.length; i++) {
            if (children[i] is this) {
                if (i < children.length - 1) {
                    nextView = children[i + 1];
                    break;
                }
            }
        }

        if (nextView !is null)
            return NSArray.arrayWithObject(nextView.view).id;
        else
            return NSArray.array().id;
    } else if (attributeName.isEqualToString (OS.NSAccessibilityPreviousContentsAttribute)) {
        Control[] children =  parent._getChildren();
        Control nextView = null;
        for (int i = 0; i < children.length; i++) {
            if (children[i] is this) {
                if (i > 0) {
                    nextView = children[i - 1];
                    break;
                }
            }
        }

        if (nextView !is null)
            return NSArray.arrayWithObject(nextView.view).id;
        else
            return NSArray.array().id;
    }

    return super.accessibilityAttributeValue(id, sel, arg0);
}

bool accessibilityIsIgnored(objc.id id, objc.SEL sel) {
    return false;
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the control is selected by the user, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * When <code>widgetSelected</code> is called, the x, y, width, and height fields of the event object are valid.
 * If the receiver is being dragged, the event object detail field contains the value <code>DWT.DRAG</code>.
 * <code>widgetDefaultSelected</code> is not called.
 * </p>
 *
 * @param listener the listener which should be notified when the control is selected by the user
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see SelectionListener
 * @see #removeSelectionListener
 * @see SelectionEvent
 */
public void addSelectionListener(SelectionListener listener) {
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener(listener);
    addListener(DWT.Selection,typedListener);
    addListener(DWT.DefaultSelection,typedListener);
}

static int checkStyle (int style) {
    /*
     * Macintosh only supports smooth dragging.
     */
    style |= DWT.SMOOTH;
    return checkBits (style, DWT.HORIZONTAL, DWT.VERTICAL, 0, 0, 0, 0);
}

bool becomeFirstResponder (objc.id id, objc.SEL sel) {
    bool result = super.becomeFirstResponder(id, sel);
    NSRect frame = view.frame();
    lastX = cast(int)frame.x;
    lastY = cast(int)frame.y;
    return result;
}

public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget();
    int width = 0, height = 0;
    if ((style & DWT.HORIZONTAL) !is 0) {
        width += DEFAULT_WIDTH;  height += 5;
    } else {
        width += 5; height += DEFAULT_HEIGHT;
    }
    if (wHint !is DWT.DEFAULT) width = wHint;
    if (hHint !is DWT.DEFAULT) height = hHint;
    return new Point (width, height);
}

void createHandle () {
    state |= THEME_BACKGROUND;
    NSView widget = cast(NSView)(new SWTView()).alloc();
    widget.initWithFrame (NSRect());
    widget.init ();
    view = widget;
}

void drawBackground (objc.id id, NSGraphicsContext context, NSRect rect) {
    if (id !is view.id) return;
    fillBackground (view, context, rect, -1);
}

Cursor findCursor () {
    Cursor cursor = super.findCursor ();
    if (cursor is null) {
        int cursorType = (style & DWT.HORIZONTAL) !is 0 ? DWT.CURSOR_SIZENS : DWT.CURSOR_SIZEWE;
        cursor = display.getSystemCursor (cursorType);
    }
    return cursor;
}

bool sendKeyEvent(NSEvent nsEvent, int type) {
    super.sendKeyEvent (nsEvent, type);
    if (type is DWT.KeyDown) {
        int keyCode = nsEvent.keyCode();
        switch (keyCode) {
            case 126: /* Up arrow */
            case 123: /* Left arrow */
            case 125: /* Down arrow */
            case 124: /* Right arrow */ {
                int xChange = 0, yChange = 0;
                int stepSize = PAGE_INCREMENT;
            NSUInteger modifiers = nsEvent.modifierFlags();
                if ((modifiers & OS.NSControlKeyMask) !is 0) stepSize = INCREMENT;
                if ((style & DWT.VERTICAL) !is 0) {
                    if (keyCode is 126 || keyCode is 125) break;
                    xChange = keyCode is 123 ? -stepSize : stepSize;
                } else {
                    if (keyCode is 123 || keyCode  is 124) break;
                    yChange = keyCode is 126 ? -stepSize : stepSize;
                }

                Rectangle bounds = getBounds ();
                int width = bounds.width, height = bounds.height;
                Rectangle parentBounds = parent.getBounds ();
                int parentWidth = parentBounds.width;
                int parentHeight = parentBounds.height;
                int newX = lastX, newY = lastY;
                if ((style & DWT.VERTICAL) !is 0) {
                    newX = Math.min (Math.max (0, lastX + xChange), parentWidth - width);
                } else {
                    newY = Math.min (Math.max (0, lastY + yChange), parentHeight - height);
                }
                if (newX is lastX && newY is lastY) return true;
                Event event = new Event ();
                event.x = newX;
                event.y = newY;
                event.width = width;
                event.height = height;
                sendEvent (DWT.Selection, event);
                if (isDisposed ()) break;
                if (event.doit) {
                    setBounds (event.x, event.y, width, height);
                    if (isDisposed ()) break;
                    lastX = event.x;
                    lastY = event.y;
                    if (isDisposed ()) return false;
                    int cursorX = event.x, cursorY = event.y;
                    if ((style & DWT.VERTICAL) !is 0) {
                        cursorY += height / 2;
                    } else {
                        cursorX += width / 2;
                    }
                    display.setCursorLocation (parent.toDisplay (cursorX, cursorY));
                }
                break;
                default:
            }
        }
    }
    return true;
}

void mouseDown(objc.id id, objc.SEL sel, objc.id theEvent) {
    //TODO use sendMouseEvent
    super.mouseDown(id, sel, theEvent);
    if (isDisposed()) return;
    NSEvent nsEvent = new NSEvent(theEvent);
    if (nsEvent.clickCount() !is 1) return;
    NSPoint location = nsEvent.locationInWindow();
    NSPoint point = view.convertPoint_fromView_(location, null);
    startX = cast(int)point.x;
    startY = cast(int)point.y;
    NSRect frame = view.frame();
    Event event = new Event ();
    event.x = cast(int)frame.x;
    event.y = cast(int)frame.y;
    event.width = cast(int)frame.width;
    event.height = cast(int)frame.height;
    sendEvent (DWT.Selection, event);
    if (isDisposed ()) return;
    if (event.doit) {
        lastX = event.x;
        lastY = event.y;
        dragging = true;
        setLocation(event.x, event.y);
    }
}

bool mouseEvent (objc.id id, objc.SEL sel, objc.id theEvent, int type) {
    super.mouseEvent (id, sel, theEvent, type);
    return (new NSEvent (theEvent)).type () !is OS.NSLeftMouseDown;
}

void mouseDragged(objc.id id, objc.SEL sel, objc.id theEvent) {
    //TODO use sendMouseEvent
    super.mouseDragged(id, sel, theEvent);
    if (isDisposed()) return;
    if (!dragging) return;
    NSEvent nsEvent = new NSEvent(theEvent);
    NSPoint location = nsEvent.locationInWindow();
    NSPoint point = view.convertPoint_fromView_(location, null);
    NSRect frame = view.frame();
    NSRect parentFrame = parent.topView().frame();
    int newX = lastX, newY = lastY;
    if ((style & DWT.VERTICAL) !is 0) {
        newX = Math.min (Math.max (0, cast(int)(point.x + frame.x - startX)), cast(int)(parentFrame.width - frame.width));
    } else {
        newY = Math.min (Math.max (0, cast(int)(point.y + frame.y - startY)), cast(int)(parentFrame.height - frame.height));
    }
    if (newX is lastX && newY is lastY) return;
    Event event = new Event ();
    event.x = newX;
    event.y = newY;
    event.width = cast(int)frame.width;
    event.height = cast(int)frame.height;
    sendEvent (DWT.Selection, event);
    if (isDisposed ()) return;
    if (event.doit) {
        lastX = event.x;
        lastY = event.y;
        setBounds (event.x, event.y, cast(int)frame.width, cast(int)frame.height);
    }
}

void mouseUp(objc.id id, objc.SEL sel, objc.id theEvent) {
    //TODO use sendMouseEvent
    super.mouseUp(id, sel, theEvent);
    if (isDisposed()) return;
    if (!dragging) return;
    dragging = false;
    NSRect frame = view.frame();
    Event event = new Event ();
    event.x = lastX;
    event.y = lastY;
    event.width = cast(int)frame.width;
    event.height = cast(int)frame.height;
    sendEvent (DWT.Selection, event);
    if (isDisposed ()) return;
    if (event.doit) {
        setBounds (event.x, event.y, cast(int)frame.width, cast(int)frame.height);
    }
}

void releaseHandle () {
    super.releaseHandle ();
    if (accessibilityAttributes !is null) accessibilityAttributes.release();
    accessibilityAttributes = null;
}

void releaseWidget () {
    super.releaseWidget ();
    if (sizeCursor !is null) sizeCursor.dispose ();
    sizeCursor = null;
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the control is selected by the user.
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
 * @see SelectionListener
 * @see #addSelectionListener
 */
public void removeSelectionListener(SelectionListener listener) {
    checkWidget();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook(DWT.Selection, listener);
    eventTable.unhook(DWT.DefaultSelection,listener);
}

void superKeyDown (objc.id id, objc.SEL sel, objc.id theEvent) {
}

void superKeyUp (objc.id id, objc.SEL sel, objc.id theEvent) {
}

int traversalCode (int key, NSEvent theEvent) {
    return 0;
}

}
