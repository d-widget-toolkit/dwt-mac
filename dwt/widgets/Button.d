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
module dwt.widgets.Button;







import dwt.internal.cocoa.NSSize;
import cocoa = dwt.internal.cocoa.id;

import dwt.DWT;
import dwt.dwthelper.utils;
import dwt.accessibility.ACC;
import Carbon = dwt.internal.c.Carbon;
import dwt.internal.cocoa.OS;
import dwt.internal.cocoa.NSCell;
import dwt.internal.cocoa.NSText;
import dwt.internal.cocoa.NSEvent;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSFont;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSGraphicsContext;
import dwt.internal.cocoa.NSAttributedString;
import dwt.internal.cocoa.NSButton;
import dwt.internal.cocoa.SWTButton;
import dwt.internal.cocoa.NSButtonCell;
import dwt.internal.cocoa.SWTButtonCell;
import dwt.internal.cocoa.NSControl;
import dwt.internal.cocoa.NSAffineTransform;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSBezierPath;
import dwt.internal.cocoa.NSColor;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;
import dwt.widgets.Composite;
import dwt.widgets.Control;
import dwt.widgets.Decorations;
import dwt.widgets.TypedListener;
import dwt.events.SelectionListener;
import dwt.graphics.Image;
import dwt.graphics.Point;

/**
 * Instances of this class represent a selectable user interface object that
 * issues notification when pressed and released.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>ARROW, CHECK, PUSH, RADIO, TOGGLE, FLAT</dd>
 * <dd>UP, DOWN, LEFT, RIGHT, CENTER</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Selection</dd>
 * </dl>
 * <p>
 * Note: Only one of the styles ARROW, CHECK, PUSH, RADIO, and TOGGLE
 * may be specified.
 * </p><p>
 * Note: Only one of the styles LEFT, RIGHT, and CENTER may be specified.
 * </p><p>
 * Note: Only one of the styles UP, DOWN, LEFT, and RIGHT may be specified
 * when the ARROW style is specified.
 * </p><p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the DWT implementation.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#button">Button snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">DWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 * @noextend This class is not intended to be subclassed by clients.
 */
public class Button : Control {
    String text;
    alias Control.setBackground setBackground;
    alias Control.setForeground setForeground;
    alias Control.computeSize computeSize;
    alias Control.createString createString;

    Image image;
    bool grayed;

    static final int EXTRA_HEIGHT = 2;
    static final int EXTRA_WIDTH = 6;
    static final int IMAGE_GAP = 2;

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
 * @see DWT#ARROW
 * @see DWT#CHECK
 * @see DWT#PUSH
 * @see DWT#RADIO
 * @see DWT#TOGGLE
 * @see DWT#FLAT
 * @see DWT#UP
 * @see DWT#DOWN
 * @see DWT#LEFT
 * @see DWT#RIGHT
 * @see DWT#CENTER
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, checkStyle (style));
}

objc.id accessibilityAttributeValue (objc.id id, objc.SEL sel, objc.id arg0) {
    NSString nsAttributeName = new NSString(arg0);

    if (accessible !is null) {
        cocoa.id returnObject = accessible.internal_accessibilityAttributeValue(nsAttributeName, ACC.CHILDID_SELF);
        if (returnObject !is null) return returnObject.id;
    }

    if (nsAttributeName.isEqualToString (OS.NSAccessibilityRoleAttribute) || nsAttributeName.isEqualToString (OS.NSAccessibilityRoleDescriptionAttribute)) {
        NSString role = null;

        if ((style & DWT.RADIO) !is 0) {
            role = OS.NSAccessibilityRadioButtonRole;
        } else if ((style & DWT.ARROW) !is 0) {
            role = OS.NSAccessibilityButtonRole;
        }

        if (role !is null) {
            if (nsAttributeName.isEqualToString (OS.NSAccessibilityRoleAttribute))
                return role.id;
            else {
                return OS.NSAccessibilityRoleDescription(role.id, null);
            }
        }
    }

    return super.accessibilityAttributeValue(id, sel, arg0);
}


/**
 * Adds the listener to the collection of listeners who will
 * be notified when the control is selected by the user, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * <code>widgetSelected</code> is called when the control is selected by the user.
 * <code>widgetDefaultSelected</code> is not called.
 * </p>
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

NSSize cellSize (objc.id id, objc.SEL sel) {
    NSSize size = super.cellSize(id, sel);
    if (image !is null && ((style & (DWT.CHECK|DWT.RADIO)) !is 0)) {
        NSSize imageSize = image.handle.size();
        size.width += imageSize.width + IMAGE_GAP;
        size.height = Math.max(size.height, imageSize.height);
    }
    return size;
}

static int checkStyle (int style) {
    style = checkBits (style, DWT.PUSH, DWT.ARROW, DWT.CHECK, DWT.RADIO, DWT.TOGGLE, 0);
    if ((style & (DWT.PUSH | DWT.TOGGLE)) !is 0) {
        return checkBits (style, DWT.CENTER, DWT.LEFT, DWT.RIGHT, 0, 0, 0);
    }
    if ((style & (DWT.CHECK | DWT.RADIO)) !is 0) {
        return checkBits (style, DWT.LEFT, DWT.RIGHT, DWT.CENTER, 0, 0, 0);
    }
    if ((style & DWT.ARROW) !is 0) {
        style |= DWT.NO_FOCUS;
        return checkBits (style, DWT.UP, DWT.DOWN, DWT.LEFT, DWT.RIGHT, 0, 0);
    }
    return style;
}

void click () {
    postEvent (DWT.Selection);
}

public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget();
    if ((style & DWT.ARROW) !is 0) {
        // TODO use some OS metric instead of hardcoded values
        int width = wHint !is DWT.DEFAULT ? wHint : 14;
        int height = hHint !is DWT.DEFAULT ? hHint : 14;
        return new Point (width, height);
    }
    NSSize size = (cast(NSButton)view).cell ().cellSize ();
    int width = cast(int)Math.ceil (size.width);
    int height = cast(int)Math.ceil (size.height);
    if (wHint !is DWT.DEFAULT) width = wHint;
    if (hHint !is DWT.DEFAULT) height = hHint;
    if ((style & (DWT.PUSH | DWT.TOGGLE)) !is 0 && (style & DWT.FLAT) is 0) {
        if (display.smallFonts) height += EXTRA_HEIGHT;
        width += EXTRA_WIDTH;
    }
    return new Point (width, height);
}

NSAttributedString createString() {
    NSAttributedString attribStr = createString(text, null, foreground, style, true, true);
    attribStr.autorelease();
    return attribStr;
}

void createHandle () {
    if ((style & DWT.PUSH) is 0) state |= THEME_BACKGROUND;
    NSButton widget = cast(NSButton)(new SWTButton()).alloc();
    widget.init();
    /*
    * Feature in Cocoa.  Images touch the edge of rounded buttons
    * when set to small size. The fix to subclass the button cell
    * and offset the image drawing.
    */
//  if (display.smallFonts && (style & (DWT.PUSH | DWT.TOGGLE)) !is 0 && (style & DWT.FLAT) is 0) {
        NSButtonCell cell = cast(NSButtonCell)(new SWTButtonCell ()).alloc ().init ();
        widget.setCell (cell);
        cell.release ();
//  }
    int type = OS.NSMomentaryLightButton;
    if ((style & DWT.PUSH) !is 0) {
        if ((style & DWT.FLAT) !is 0) {
            widget.setBezelStyle(OS.NSShadowlessSquareBezelStyle);
//          if ((style & DWT.BORDER) is 0) widget.setShowsBorderOnlyWhileMouseInside(true);
        } else {
            widget.setBezelStyle(OS.NSRoundedBezelStyle);
        }
    } else if ((style & DWT.CHECK) !is 0) {
        type = OS.NSSwitchButton;
    } else if ((style & DWT.RADIO) !is 0) {
        type = OS.NSRadioButton;
    } else if ((style & DWT.TOGGLE) !is 0) {
        type = OS.NSPushOnPushOffButton;
        if ((style & DWT.FLAT) !is 0) {
            widget.setBezelStyle(OS.NSShadowlessSquareBezelStyle);
//          if ((style & DWT.BORDER) is 0) widget.setShowsBorderOnlyWhileMouseInside(true);
        } else {
            widget.setBezelStyle(OS.NSRoundedBezelStyle);
        }
    } else if ((style & DWT.ARROW) !is 0) {
        widget.setBezelStyle(OS.NSShadowlessSquareBezelStyle);
    }
    widget.setButtonType(cast(NSButtonType)type);
    widget.setTitle(NSString.stringWith(""));
    widget.setImagePosition(OS.NSImageLeft);
    widget.setTarget(widget);
    widget.setAction(OS.sel_sendSelection);
    view = widget;
    _setAlignment(style);
}

void createWidget() {
    text = "";
    super.createWidget ();
}

NSFont defaultNSFont() {
    return display.buttonFont;
}

void deregister () {
    super.deregister ();
    display.removeWidget((cast(NSControl)view).cell());
}

bool dragDetect(int x, int y, bool filter, bool[] consume) {
    bool dragging = super.dragDetect(x, y, filter, consume);
    consume[0] = dragging;
    return dragging;
}

void drawImageWithFrameInView (objc.id id, objc.SEL sel, objc.id image, NSRect rect, objc.id view) {
    /*
    * Feature in Cocoa.  Images touch the edge of rounded buttons
    * when set to small size. The fix to subclass the button cell
    * and offset the image drawing.
    */
    if (display.smallFonts && (style & (DWT.PUSH | DWT.TOGGLE)) !is 0 && (style & DWT.FLAT) is 0) {
        rect.y = rect.y + EXTRA_HEIGHT / 2;
        rect.height = rect.height + EXTRA_HEIGHT;
    }
    callSuper (id, sel, image, rect, view);
}

void drawInteriorWithFrame_inView (objc.id id, objc.SEL sel, NSRect cellRect, objc.id viewid) {
    super.drawInteriorWithFrame_inView(id, sel, cellRect, viewid);
    if (image !is null && ((style & (DWT.CHECK|DWT.RADIO)) !is 0)) {
        NSSize imageSize = image.handle.size();
        NSCell nsCell = new NSCell(id);
        Cocoa.CGFloat x = 0;
        Cocoa.CGFloat y = (imageSize.height - cellRect.height)/2f;
        NSRect imageRect = nsCell.imageRectForBounds(cellRect);
        NSSize stringSize = (cast(NSButton)view).attributedTitle().size();
        switch (style & (DWT.LEFT|DWT.RIGHT|DWT.CENTER)) {
            case DWT.LEFT:
                x = imageRect.x + imageRect.width + IMAGE_GAP;
                break;
            case DWT.CENTER:
                x = cellRect.x + imageRect.x + imageRect.width + ((cellRect.width-stringSize.width)/2f) - imageSize.width - IMAGE_GAP;
                break;
            case DWT.RIGHT:
                x = cellRect.x + cellRect.width - stringSize.width - imageSize.width - IMAGE_GAP;
                break;
        }
        NSRect destRect = NSRect();
        destRect.x = x;
        destRect.y = y;
        destRect.width = imageSize.width;
        destRect.height = imageSize.height;
        NSGraphicsContext.static_saveGraphicsState();
        NSAffineTransform transform = NSAffineTransform.transform();
        transform.scaleXBy(1, -1);
        transform.translateXBy(0, -imageSize.height);
        transform.concat();
        image.handle.drawInRect(destRect, NSRect(), OS.NSCompositeSourceOver, 1);
        NSGraphicsContext.static_restoreGraphicsState();
    }

}

void drawWidget (objc.id id, NSGraphicsContext context, NSRect rect) {
    if ((style & DWT.ARROW) !is 0) {
        NSRect frame = view.frame();
        int arrowSize = Math.min(cast(int)frame.height, cast(int)frame.width) / 2;
        context.saveGraphicsState();
        NSPoint p1 = NSPoint();
        p1.x = -arrowSize / 2;
        p1.y = -arrowSize / 2;
        NSPoint p2 = NSPoint();
        p2.x = arrowSize / 2;
        p2.y = p1.y;
        NSPoint p3 = NSPoint();
        p3.y = arrowSize / 2;

        NSBezierPath path = NSBezierPath.bezierPath();
        path.moveToPoint(p1);
        path.lineToPoint(p2);
        path.lineToPoint(p3);
        path.closePath();

        NSAffineTransform transform = NSAffineTransform.transform();
        if ((style & DWT.LEFT) !is 0) {
            transform.rotateByDegrees(90);
        } else if ((style & DWT.UP) !is 0) {
            transform.rotateByDegrees(180);
        } else if ((style & DWT.RIGHT) !is 0) {
            transform.rotateByDegrees(-90);
        }
        path.transformUsingAffineTransform(transform);
        transform = NSAffineTransform.transform();
        transform.translateXBy(frame.width / 2, frame.height / 2);
        path.transformUsingAffineTransform(transform);

        NSColor color = isEnabled() ? NSColor.blackColor() : NSColor.disabledControlTextColor();
        color.set();
        path.fill();
        context.restoreGraphicsState();
    }
    super.drawWidget (id, context, rect);
}

/**
 * Returns a value which describes the position of the
 * text or image in the receiver. The value will be one of
 * <code>LEFT</code>, <code>RIGHT</code> or <code>CENTER</code>
 * unless the receiver is an <code>ARROW</code> button, in
 * which case, the alignment will indicate the direction of
 * the arrow (one of <code>LEFT</code>, <code>RIGHT</code>,
 * <code>UP</code> or <code>DOWN</code>).
 *
 * @return the alignment
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getAlignment () {
    checkWidget ();
    if ((style & DWT.ARROW) !is 0) {
        if ((style & DWT.UP) !is 0) return DWT.UP;
        if ((style & DWT.DOWN) !is 0) return DWT.DOWN;
        if ((style & DWT.LEFT) !is 0) return DWT.LEFT;
        if ((style & DWT.RIGHT) !is 0) return DWT.RIGHT;
        return DWT.UP;
    }
    if ((style & DWT.LEFT) !is 0) return DWT.LEFT;
    if ((style & DWT.CENTER) !is 0) return DWT.CENTER;
    if ((style & DWT.RIGHT) !is 0) return DWT.RIGHT;
    return DWT.LEFT;
}

/**
 * Returns <code>true</code> if the receiver is grayed,
 * and false otherwise. When the widget does not have
 * the <code>CHECK</code> style, return false.
 *
 * @return the grayed state of the checkbox
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public bool getGrayed() {
    checkWidget ();
    if ((style & DWT.CHECK) is 0) return false;
    return grayed;
}

/**
 * Returns the receiver's image if it has one, or null
 * if it does not.
 *
 * @return the receiver's image
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Image getImage () {
    checkWidget();
    return image;
}

String getNameText () {
    return getText ();
}

/**
 * Returns <code>true</code> if the receiver is selected,
 * and false otherwise.
 * <p>
 * When the receiver is of type <code>CHECK</code> or <code>RADIO</code>,
 * it is selected when it is checked. When it is of type <code>TOGGLE</code>,
 * it is selected when it is pushed in. If the receiver is of any other type,
 * this method returns false.
 *
 * @return the selection state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool getSelection () {
    checkWidget ();
    if ((style & (DWT.CHECK | DWT.RADIO | DWT.TOGGLE)) is 0) return false;
    if ((style & DWT.CHECK) !is 0 && grayed) return (cast(NSButton)view).state() is OS.NSMixedState;
    return (cast(NSButton)view).state() is OS.NSOnState;
}

/**
 * Returns the receiver's text, which will be an empty
 * string if it has never been set or if the receiver is
 * an <code>ARROW</code> button.
 *
 * @return the receiver's text
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String getText () {
    checkWidget ();
    return text;
}

bool isDescribedByLabel () {
    return false;
}

/*
 * Feature in Cocoa.  If a checkbox is in multi-state mode, nextState cycles from off to mixed to on and back to off again.
 * This will cause the on state to momentarily appear while clicking on the checkbox. To avoid this, we override [NSCell nextState]
 * to go directly to the desired state if we have a grayed checkbox.
 */
objc.id nextState(objc.id id, objc.SEL sel) {
    if ((style & DWT.CHECK) !is 0 && grayed) {
        return cast(objc.id)((cast(NSButton)view).state() is OS.NSMixedState ? OS.NSOffState : OS.NSMixedState);
    }

    return super.nextState(id, sel);
}

void register() {
    super.register();
    display.addWidget((cast(NSControl)view).cell(), this);
}

void releaseWidget () {
    super.releaseWidget ();
    image = null;
    text = null;
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

void selectRadio () {
    /*
    * This code is intentionally commented.  When two groups
    * of radio buttons with the same parent are separated by
    * another control, the correct behavior should be that
    * the two groups act independently.  This is consistent
    * with radio tool and menu items.  The commented code
    * implements this behavior.
    */
//  int index = 0;
//  Control [] children = parent._getChildren ();
//  while (index < children.length && children [index] !is this) index++;
//  int i = index - 1;
//  while (i >= 0 && children [i].setRadioSelection (false)) --i;
//  int j = index + 1;
//  while (j < children.length && children [j].setRadioSelection (false)) j++;
//  setSelection (true);
    Control [] children = parent._getChildren ();
    for (int i=0; i<children.length; i++) {
        Control child = children [i];
        if (this !is child) child.setRadioSelection (false);
    }
    setSelection (true);
}

void sendSelection () {
    if ((style & DWT.RADIO) !is 0) {
        if ((parent.getStyle () & DWT.NO_RADIO_GROUP) is 0) {
            selectRadio ();
        }
    }
    if ((style & DWT.CHECK) !is 0) {
        if (grayed && (cast(NSButton)view).state() is OS.NSOnState) {
            (cast(NSButton)view).setState(OS.NSOffState);
        }
        if (!grayed && (cast(NSButton)view).state() is OS.NSMixedState) {
            (cast(NSButton)view).setState(OS.NSOnState);
        }
    }
    postEvent (DWT.Selection);
}


/**
 * Controls how text, images and arrows will be displayed
 * in the receiver. The argument should be one of
 * <code>LEFT</code>, <code>RIGHT</code> or <code>CENTER</code>
 * unless the receiver is an <code>ARROW</code> button, in
 * which case, the argument indicates the direction of
 * the arrow (one of <code>LEFT</code>, <code>RIGHT</code>,
 * <code>UP</code> or <code>DOWN</code>).
 *
 * @param alignment the new alignment
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setAlignment (int alignment) {
    checkWidget ();
    _setAlignment (alignment);
    redraw ();
}

void _setAlignment (int alignment) {
    if ((style & DWT.ARROW) !is 0) {
        if ((style & (DWT.UP | DWT.DOWN | DWT.LEFT | DWT.RIGHT)) is 0) return;
        style &= ~(DWT.UP | DWT.DOWN | DWT.LEFT | DWT.RIGHT);
        style |= alignment & (DWT.UP | DWT.DOWN | DWT.LEFT | DWT.RIGHT);
//      int orientation = OS.kThemeDisclosureRight;
//      if ((style & DWT.UP) !is 0) orientation = OS.kThemeDisclosureUp;
//      if ((style & DWT.DOWN) !is 0) orientation = OS.kThemeDisclosureDown;
//      if ((style & DWT.LEFT) !is 0) orientation = OS.kThemeDisclosureLeft;
//      OS.SetControl32BitValue (handle, orientation);
        return;
    }
    if ((alignment & (DWT.LEFT | DWT.RIGHT | DWT.CENTER)) is 0) return;
    style &= ~(DWT.LEFT | DWT.RIGHT | DWT.CENTER);
    style |= alignment & (DWT.LEFT | DWT.RIGHT | DWT.CENTER);
    /* text is still null when this is called from createHandle() */
    if (text !is null) {
        (cast(NSButton)view).setAttributedTitle(createString());
    }
//  /* Alignment not honoured when image and text is visible */
//  bool bothVisible = text !is null && text.length () > 0 && image !is null;
//  if (bothVisible) {
//      if ((style & (DWT.RADIO | DWT.CHECK)) !is 0) alignment = DWT.LEFT;
//      if ((style & (DWT.PUSH | DWT.TOGGLE)) !is 0) alignment = DWT.CENTER;
//  }
//  int textAlignment = 0;
//  int graphicAlignment = 0;
//  if ((alignment & DWT.LEFT) !is 0) {
//      textAlignment = OS.kControlBevelButtonAlignTextFlushLeft;
//      graphicAlignment = OS.kControlBevelButtonAlignLeft;
//  }
//  if ((alignment & DWT.CENTER) !is 0) {
//      textAlignment = OS.kControlBevelButtonAlignTextCenter;
//      graphicAlignment = OS.kControlBevelButtonAlignCenter;
//  }
//  if ((alignment & DWT.RIGHT) !is 0) {
//      textAlignment = OS.kControlBevelButtonAlignTextFlushRight;
//      graphicAlignment = OS.kControlBevelButtonAlignRight;
//  }
//  OS.SetControlData (handle, OS.kControlEntireControl, OS.kControlBevelButtonTextAlignTag, 2, new short [] {cast(short)textAlignment});
//  OS.SetControlData (handle, OS.kControlEntireControl, OS.kControlBevelButtonGraphicAlignTag, 2, new short [] {cast(short)graphicAlignment});
//  if (bothVisible) {
//      OS.SetControlData (handle, OS.kControlEntireControl, OS.kControlBevelButtonTextPlaceTag, 2, new short [] {cast(short)OS.kControlBevelButtonPlaceToRightOfGraphic});
//  }
}

void updateBackground () {
    NSColor nsColor = null;
    if (backgroundImage !is null) {
        nsColor = NSColor.colorWithPatternImage(backgroundImage.handle);
    } else if (background !is null) {
        nsColor = NSColor.colorWithDeviceRed(background[0], background[1], background[2], background[3]);
    } else {
        return; // TODO set to OS default
    }
    NSButtonCell cell = new NSButtonCell((cast(NSButton)view).cell());
    cell.setBackgroundColor(nsColor);
}

void setFont (NSFont font) {
    if (text !is null) {
        (cast(NSButton)view).setAttributedTitle(createString());
    }
}

void setForeground (Cocoa.CGFloat [] color) {
    (cast(NSButton)view).setAttributedTitle(createString());
}

/**
 * Sets the grayed state of the receiver.  This state change
 * only applies if the control was created with the DWT.CHECK
 * style.
 *
 * @param grayed the new grayed state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public void setGrayed(bool grayed) {
    checkWidget ();
    if ((style & DWT.CHECK) is 0) return;
    bool checked = getSelection ();
    this.grayed = grayed;
    (cast(NSButton) view).setAllowsMixedState(grayed);

    if (checked) {
        if (grayed) {
            (cast(NSButton) view).setState (OS.NSMixedState);
        } else {
            (cast(NSButton) view).setState (OS.NSOnState);
        }
    }
}

/**
 * Sets the receiver's image to the argument, which may be
 * <code>null</code> indicating that no image should be displayed.
 * <p>
 * Note that a Button can display an image and text simultaneously
 * on Windows (starting with XP), GTK+ and OSX.  On other platforms,
 * a Button that has an image and text set into it will display the
 * image or text that was set most recently.
 * </p>
 * @param image the image to display on the receiver (may be <code>null</code>)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the image has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setImage (Image image) {
    checkWidget();
    if (image !is null && image.isDisposed ()) {
        error (DWT.ERROR_INVALID_ARGUMENT);
    }
    if ((style & DWT.ARROW) !is 0) return;
    this.image = image;
    if ((style & (DWT.RADIO|DWT.CHECK)) is 0) {
        /*
         * Feature in Cocoa.  If the NSImage object being set into the button is
         * the same NSImage object that is already there then the button does not
         * redraw itself.  This results in the button's image not visually updating
         * if the NSImage object's content has changed since it was last set
         * into the button.  The workaround is to explicitly redraw the button.
         */
        (cast(NSButton)view).setImage(image !is null ? image.handle : null);
        view.setNeedsDisplay(true);
    } else {
        (cast(NSButton)view).setAttributedTitle(createString());
    }
    updateAlignment ();
}

bool setRadioSelection (bool value){
    if ((style & DWT.RADIO) is 0) return false;
    if (getSelection () !is value) {
        setSelection (value);
        postEvent (DWT.Selection);
    }
    return true;
}

/**
 * Sets the selection state of the receiver, if it is of type <code>CHECK</code>,
 * <code>RADIO</code>, or <code>TOGGLE</code>.
 *
 * <p>
 * When the receiver is of type <code>CHECK</code> or <code>RADIO</code>,
 * it is selected when it is checked. When it is of type <code>TOGGLE</code>,
 * it is selected when it is pushed in.
 *
 * @param selected the new selection state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSelection (bool selected) {
    checkWidget();
    if ((style & (DWT.CHECK | DWT.RADIO | DWT.TOGGLE)) is 0) return;
    if (grayed) {
        (cast(NSButton)view).setState (selected ? OS.NSMixedState : OS.NSOffState);
    } else {
        (cast(NSButton)view).setState (selected ? OS.NSOnState : OS.NSOffState);
    }
}

/**
 * Sets the receiver's text.
 * <p>
 * This method sets the button label.  The label may include
 * the mnemonic character but must not contain line delimiters.
 * </p>
 * <p>
 * Mnemonics are indicated by an '&amp;' that causes the next
 * character to be the mnemonic.  When the user presses a
 * key sequence that matches the mnemonic, a selection
 * event occurs. On most platforms, the mnemonic appears
 * underlined but may be emphasized in a platform specific
 * manner.  The mnemonic indicator character '&amp;' can be
 * escaped by doubling it in the string, causing a single
 * '&amp;' to be displayed.
 * </p><p>
 * Note that a Button can display an image and text simultaneously
 * on Windows (starting with XP), GTK+ and OSX.  On other platforms,
 * a Button that has an image and text set into it will display the
 * image or text that was set most recently.
 * </p>
 * @param string the new text
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the text is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setText (String string) {
    checkWidget();
    // DWT extension: allow null for zero length string
    //if (string is null) error (DWT.ERROR_NULL_ARGUMENT);
    if ((style & DWT.ARROW) !is 0) return;
    text = string;
    (cast(NSButton)view).setAttributedTitle(createString());
    updateAlignment ();
}

NSRect titleRectForBounds (objc.id id, objc.SEL sel, NSRect cellFrame) {
    NSRect rect = super.titleRectForBounds(id, sel, cellFrame);
    if (image !is null && ((style & (DWT.CHECK|DWT.RADIO)) !is 0)) {
        NSSize imageSize = image.handle.size();
        rect.x = rect.x + imageSize.width + IMAGE_GAP;
        rect.width = rect.width - (imageSize.width + IMAGE_GAP);
        rect.width = Math.max(0f, rect.width);
    }
    return rect;
}

int traversalCode (int key, NSEvent theEvent) {
    int code = super.traversalCode (key, theEvent);
    if ((style & DWT.ARROW) !is 0) code &= ~(DWT.TRAVERSE_TAB_NEXT | DWT.TRAVERSE_TAB_PREVIOUS);
    if ((style & DWT.RADIO) !is 0) code |= DWT.TRAVERSE_ARROW_NEXT | DWT.TRAVERSE_ARROW_PREVIOUS;
    return code;
}

void updateAlignment () {
    NSButton widget = cast(NSButton)view;
    if ((style & (DWT.PUSH | DWT.TOGGLE)) !is 0) {
        if (text.length !is 0 && image !is null) {
            widget.setImagePosition(OS.NSImageLeft);
        } else {
            widget.setImagePosition(cast(NSCellImagePosition)(text.length !is 0 ? OS.NSNoImage : OS.NSImageOnly));
        }
    }
}

}
