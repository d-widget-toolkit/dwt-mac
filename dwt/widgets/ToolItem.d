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
module dwt.widgets.ToolItem;

import dwt.dwthelper.utils;


import dwt.*;
import dwt.events.*;
import dwt.graphics.*;
import dwt.internal.cocoa.*;

import objc = dwt.internal.objc.runtime;
import dwt.widgets.Control;
import dwt.widgets.Display;
import dwt.widgets.Event;
import dwt.widgets.Item;
import dwt.widgets.ToolBar;
import dwt.widgets.TypedListener;

/**
 * Instances of this class represent a selectable user interface object
 * that represents a button in a tool bar.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>PUSH, CHECK, RADIO, SEPARATOR, DROP_DOWN</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Selection</dd>
 * </dl>
 * <p>
 * Note: Only one of the styles CHECK, PUSH, RADIO, SEPARATOR and DROP_DOWN 
 * may be specified.
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#toolbar">ToolBar, ToolItem snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 * @noextend This class is not intended to be subclassed by clients.
 */
public class ToolItem : Item {
    NSView view;
    NSButton button;
    int width = DEFAULT_SEPARATOR_WIDTH;
    ToolBar parent;
    Image hotImage, disabledImage;
    String toolTipText;
    Control control;
    bool selection;
    
    static const int DEFAULT_WIDTH = 24;
    static const int DEFAULT_HEIGHT = 22;
    static const int DEFAULT_SEPARATOR_WIDTH = 6;
    static const int INSET = 3;
    static const int ARROW_WIDTH = 5;
    
/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>ToolBar</code>) and a style value
 * describing its behavior and appearance. The item is added
 * to the end of the items maintained by its parent.
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
 * @see DWT#PUSH
 * @see DWT#CHECK
 * @see DWT#RADIO
 * @see DWT#SEPARATOR
 * @see DWT#DROP_DOWN
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (ToolBar parent, int style) {
    super (parent, checkStyle (style));
    this.parent = parent;
    parent.createItem (this, parent.getItemCount ());
}

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>ToolBar</code>), a style value
 * describing its behavior and appearance, and the index
 * at which to place it in the items maintained by its parent.
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
 * @param index the zero-relative index to store the receiver in its parent
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 *    <li>ERROR_INVALID_RANGE - if the index is not between 0 and the number of elements in the parent (inclusive)</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see DWT#PUSH
 * @see DWT#CHECK
 * @see DWT#RADIO
 * @see DWT#SEPARATOR
 * @see DWT#DROP_DOWN
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (ToolBar parent, int style, int index) {
    super (parent, checkStyle (style));
    this.parent = parent;
    parent.createItem (this, index);
}

objc.id accessibilityAttributeValue(objc.id id, objc.SEL sel, objc.id arg0) {
    NSString nsAttributeName = new NSString(arg0);
    
    if (nsAttributeName.isEqualToString (OS.NSAccessibilityRoleAttribute) || nsAttributeName.isEqualToString (OS.NSAccessibilityRoleDescriptionAttribute)) {
        NSString roleText = ((style & DWT.PUSH) !is 0) ? OS.NSAccessibilityButtonRole
        : ((style & DWT.RADIO) !is 0) ? OS.NSAccessibilityRadioButtonRole
        : ((style & DWT.CHECK) !is 0) ? OS.NSAccessibilityCheckBoxRole
        : ((style & DWT.DROP_DOWN) !is 0) ? OS.NSAccessibilityMenuButtonRole
        : null; // SEPARATOR
        if (roleText !is null) {
            if (nsAttributeName.isEqualToString (OS.NSAccessibilityRoleAttribute)) {
                return roleText.id;
            } else { // NSAccessibilityRoleDescriptionAttribute
                objc.id description = OS.NSAccessibilityRoleDescription (roleText.id, null);
                return description;
            }
        }
    } else if (nsAttributeName.isEqualToString (OS.NSAccessibilityTitleAttribute) || nsAttributeName.isEqualToString (OS.NSAccessibilityDescriptionAttribute)) {
        String accessibleText = toolTipText;
        if (accessibleText is null || accessibleText.equals("")) accessibleText = text;
        if (!(accessibleText is null || accessibleText.equals(""))) {
            return NSString.stringWith(accessibleText).id;
        } else {
            return NSString.stringWith("").id;
        }
    } else if (nsAttributeName.isEqualToString (OS.NSAccessibilityValueAttribute) && (style & (DWT.CHECK | DWT.RADIO)) !is 0) {
        NSNumber value = NSNumber.numberWithInt(selection ? 1 : 0);
        return value.id;
    } else if (nsAttributeName.isEqualToString(OS.NSAccessibilityEnabledAttribute)) {
        NSNumber value = NSNumber.numberWithInt(getEnabled() ? 1 : 0);
        return value.id;
    }
    
    return super.accessibilityAttributeValue(id, sel, arg0);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the control is selected by the user, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * When <code>widgetSelected</code> is called when the mouse is over the arrow portion of a drop-down tool,
 * the event object detail field contains the value <code>DWT.ARROW</code>.
 * <code>widgetDefaultSelected</code> is not called.
 * </p>
 *
 * @param listener the listener which should be notified when the control is selected by the user,
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
    return checkBits (style, DWT.PUSH, DWT.CHECK, DWT.RADIO, DWT.SEPARATOR, DWT.DROP_DOWN, 0);
}

protected void checkSubclass () {
    if (!isValidSubclass ()) error (DWT.ERROR_INVALID_SUBCLASS);
}

Point computeSize () {
    checkWidget();
    int width = 0, height = 0;
    if ((style & DWT.SEPARATOR) !is 0) {
        if ((parent.style & DWT.HORIZONTAL) !is 0) {
            width = getWidth ();
            height = DEFAULT_HEIGHT;
        } else {
            width = DEFAULT_WIDTH;
            height = getWidth ();
        }
        if (control !is null) {
            height = Math.max (height, control.getMininumHeight ());
        }
    } else {
        if (text.length () !is 0 || image !is null) {
            NSButton widget = cast(NSButton)button;
            NSSize size = widget.cell().cellSize();
            width = (int)Math.ceil(size.width);
            height = (int)Math.ceil(size.height);
        } else {
            width = DEFAULT_WIDTH;
            height = DEFAULT_HEIGHT;
        }
        if ((style & DWT.DROP_DOWN) !is 0) {
            width += ARROW_WIDTH + INSET;
        }
        width += INSET * 2;
        height += INSET * 2;
    }
    return new Point (width, height);
}

void createHandle () {
    if ((style & DWT.SEPARATOR) !is 0) {
        NSBox widget = cast(NSBox)(new SWTBox()).alloc();
        widget.init();
        widget.setBoxType(OS.NSBoxSeparator);
        widget.setBorderWidth(0);
        view = widget;
    } else {
        NSView widget = cast(NSView)(new SWTView()).alloc();
        widget.init();
        button = cast(NSButton)(new SWTButton()).alloc();
        button.init();
        /*
        * Feature in Cocoa.  NSButtons without borders do not leave any margin
        * between their edge and their image.  The workaround is to provide a
        * custom cell that displays the image in a better position. 
        */
        NSButtonCell cell = (NSButtonCell)new SWTButtonCell ().alloc ().init ();
        button.setCell (cell);
        cell.release();
        cell.release();
        button.setBordered(false);
        button.setAction(OS.sel_sendSelection);
        button.setTarget(button);
        Font font = parent.font !is null ? parent.font : parent.defaultFont ();
        button.setFont(font.handle);
        button.setImagePosition(OS.NSImageOverlaps);
        NSString emptyStr = NSString.stringWith("");
        button.setTitle(emptyStr);
        button.setEnabled(parent.getEnabled());
        widget.addSubview(button);
        view = widget;
    }
}

NSAttributedString createString() {
    NSAttributedString attribStr = parent.createString(text, null, parent.foreground, DWT.CENTER, true, true);
    attribStr.autorelease();
    return attribStr;
}

void deregister () {
    super.deregister ();
    display.removeWidget(view);
    
    if (button !is null) {
        display.removeWidget (button);
        display.removeWidget (button.cell());
    }
}

void destroyWidget() {
    parent.destroyItem(this);
    super.destroyWidget();
}

void drawImageWithFrameInView (int /*long*/ id, int /*long*/ sel, int /*long*/ image, NSRect rect, int /*long*/ view) {
    if (text.length () > 0) {
        if ((parent.style & DWT.RIGHT) !is 0) {
            rect.x += 3;
        } else {
            rect.y += 3;            
        }
    }
    callSuper (id, sel, image, rect, view);
}

void drawWidget (int /*long*/ id, NSGraphicsContext context, NSRect rect) {
    if (id is view.id) {
        if (getSelection ()) {
            NSRect bounds = view.bounds();
            context.saveGraphicsState();
            NSColor.colorWithDeviceRed(0.1f, 0.1f, 0.1f, 0.1f).setFill();
            NSColor.colorWithDeviceRed(0.2f, 0.2f, 0.2f, 0.2f).setStroke();
            NSBezierPath.fillRect(bounds);
            bounds.origin.x += 0.5f;
            bounds.origin.y += 0.5f;
            bounds.size.width -= 1;
            bounds.size.height -= 1;
            NSBezierPath.strokeRect(bounds);
            context.restoreGraphicsState();
        }
        if ((style & DWT.DROP_DOWN) !is 0) {
            NSRect bounds = view.bounds();
            context.saveGraphicsState();
            NSBezierPath path = NSBezierPath.bezierPath();
            NSPoint pt = NSPoint();
            path.moveToPoint(pt);
            pt.x += ARROW_WIDTH;
            path.lineToPoint(pt);
            pt.y += ARROW_WIDTH - 1;
            pt.x -= ARROW_WIDTH / 2f;
            path.lineToPoint(pt);
            path.closePath();
            NSAffineTransform transform = NSAffineTransform.transform();
            transform.translateXBy(cast(int)bounds.width - ARROW_WIDTH - INSET, cast(int)(bounds.height - ARROW_WIDTH / 2) / 2);
            transform.concat();
            NSColor color = isEnabled() ? NSColor.blackColor() : NSColor.disabledControlTextColor();
            color.set();
            path.fill();
            context.restoreGraphicsState();
        }
    }
}

void enableWidget(bool enabled) {
    if ((style & DWT.SEPARATOR) is 0) {
        (cast(NSButton)button).setEnabled(enabled);
    }
}

/**
 * Returns a rectangle describing the receiver's size and location
 * relative to its parent.
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
    NSRect rect = view.frame();
    return new Rectangle(cast(int)rect.x, cast(int)rect.y, cast(int)rect.width, cast(int)rect.height);
}

void setClipRegion (float /*double*/ x, float /*double*/ y) {
    NSRect frame = view.frame();
    parent.setClipRegion(frame.x + x, frame.y + y);
}

/**
 * Returns the control that is used to fill the bounds of
 * the item when the item is a <code>SEPARATOR</code>.
 *
 * @return the control
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Control getControl () {
    checkWidget();
    return control;
}

/**
 * Returns the receiver's disabled image if it has one, or null
 * if it does not.
 * <p>
 * The disabled image is displayed when the receiver is disabled.
 * </p>
 *
 * @return the receiver's disabled image
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Image getDisabledImage () {
    checkWidget();
    return disabledImage;
}

bool getDrawing () {
    return parent.getDrawing ();
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
 * Returns the receiver's hot image if it has one, or null
 * if it does not.
 * <p>
 * The hot image is displayed when the mouse enters the receiver.
 * </p>
 *
 * @return the receiver's hot image
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Image getHotImage () {
    checkWidget();
    return hotImage;
}

/**
 * Returns the receiver's parent, which must be a <code>ToolBar</code>.
 *
 * @return the receiver's parent
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public ToolBar getParent () {
    checkWidget();
    return parent;
}

/**
 * Returns <code>true</code> if the receiver is selected,
 * and false otherwise.
 * <p>
 * When the receiver is of type <code>CHECK</code> or <code>RADIO</code>,
 * it is selected when it is checked (which some platforms draw as a
 * pushed in button). If the receiver is of any other type, this method
 * returns false.
 * </p>
 *
 * @return the selection state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool getSelection () {
    checkWidget();
    if ((style & (DWT.CHECK | DWT.RADIO)) is 0) return false;
    return selection;
}

/**
 * Returns the receiver's tool tip text, or null if it has not been set.
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
 * Gets the width of the receiver.
 *
 * @return the width
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getWidth () {
    checkWidget();
    return width;
}

/**
 * Returns <code>true</code> if the receiver is enabled and all
 * of the receiver's ancestors are enabled, and <code>false</code>
 * otherwise. A disabled control is typically not selectable from the
 * user interface and draws with an inactive or "grayed" look.
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

bool isDrawing () {
    return getDrawing() && parent.isDrawing ();
}

    return parent.menuForEvent (id, sel, theEvent);
}

void mouseDown(objc.id id, objc.SEL sel, objc.id theEvent) {
    if (!parent.mouseEvent(parent.view.id, sel, theEvent, DWT.MouseDown)) return;
    Display display = this.display;
    display.trackingControl = parent;
    super.mouseDown(id, sel, theEvent);
    display.trackingControl = null;
    if ((style & DWT.DROP_DOWN) !is 0 && id is view.id) {
        NSRect frame = view.frame();
        Event event = new Event ();
        event.detail = DWT.ARROW;
        event.x = cast(int)frame.x;
        event.y = cast(int)(frame.y + frame.height);
        postEvent (DWT.Selection, event);
    }
}

void mouseUp(int /*long*/ id, int /*long*/ sel, int /*long*/ theEvent) {
    if (!parent.mouseEvent(parent.view.id, sel, theEvent, DWT.MouseUp)) return;
    super.mouseUp(id, sel, theEvent);
}

void mouseDragged(int /*long*/ id, int /*long*/ sel, int /*long*/ theEvent) {
    if (!parent.mouseEvent(parent.view.id, sel, theEvent, DWT.MouseMove)) return;
    super.mouseDragged(id, sel, theEvent);
}

void rightMouseDown(int /*long*/ id, int /*long*/ sel, int /*long*/ theEvent) {
    if (!parent.mouseEvent(parent.view.id, sel, theEvent, DWT.MouseDown)) return;
    super.rightMouseDown(id, sel, theEvent);
}

void rightMouseUp(int /*long*/ id, int /*long*/ sel, int /*long*/ theEvent) {
    if (!parent.mouseEvent(parent.view.id, sel, theEvent, DWT.MouseUp)) return;
    super.rightMouseUp(id, sel, theEvent);
}

void rightMouseDragged(int /*long*/ id, int /*long*/ sel, int /*long*/ theEvent) {
    if (!parent.mouseEvent(parent.view.id, sel, theEvent, DWT.MouseMove)) return;
    super.rightMouseDragged(id, sel, theEvent);
}

void otherMouseDown(int /*long*/ id, int /*long*/ sel, int /*long*/ theEvent) {
    if (!parent.mouseEvent(parent.view.id, sel, theEvent, DWT.MouseDown)) return;
    super.otherMouseDown(id, sel, theEvent);
}

void otherMouseUp(int /*long*/ id, int /*long*/ sel, int /*long*/ theEvent) {
    if (!parent.mouseEvent(parent.view.id, sel, theEvent, DWT.MouseUp)) return;
    super.otherMouseUp(id, sel, theEvent);
}

void otherMouseDragged(int /*long*/ id, int /*long*/ sel, int /*long*/ theEvent) {
    if (!parent.mouseEvent(parent.view.id, sel, theEvent, DWT.MouseMove)) return;
    super.otherMouseDragged(id, sel, theEvent);
}

void register () {
    super.register ();
    display.addWidget (view, this);
    
    if (button !is null) {
        display.addWidget (button, this);
        display.addWidget (button.cell(), this);
    }
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

void releaseParent () {
    super.releaseParent ();
    setVisible (false);
}

void releaseHandle () {
    super.releaseHandle ();
    if (view !is null) view.release ();
    if (button !is null) button.release ();
    view = button = null;
    parent = null;
}

void releaseWidget () {
    super.releaseWidget ();
    control = null;
    toolTipText = null;
    image = disabledImage = hotImage = null; 
}

void selectRadio () {
    int index = 0;
    ToolItem [] items = parent.getItems ();
    while (index < items.length && items [index] !is this) index++;
    int i = index - 1;
    while (i >= 0 && items [i].setRadioSelection (false)) --i;
    int j = index + 1;
    while (j < items.length && items [j].setRadioSelection (false)) j++;
    setSelection (true);
}

void sendSelection () {
    if ((style & DWT.RADIO) !is 0) {
        if ((parent.getStyle () & DWT.NO_RADIO_GROUP) is 0) {
            selectRadio ();
        }
    }
    if ((style & DWT.CHECK) !is 0) setSelection (!getSelection ());
    postEvent (DWT.Selection);
}

void setBounds (int x, int y, int width, int height) {
    NSRect rect = NSRect();
    rect.x = x;
    rect.y = y;
    rect.width = width;
    rect.height = height;
    view.setFrame(rect);
    if (button !is null) {
        rect.x = 0;
        rect.y = 0;
        rect.width = width;
        rect.height = height;
        if ((style & DWT.DROP_DOWN) !is 0) rect.size.width -= ARROW_WIDTH + INSET;
        button.setFrame(rect);
    }
}

/**
 * Sets the control that is used to fill the bounds of
 * the item when the item is a <code>SEPARATOR</code>.
 *
 * @param control the new control
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the control has been disposed</li> 
 *    <li>ERROR_INVALID_PARENT - if the control is not in the same widget tree</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setControl (Control control) {
    checkWidget();
    if (control !is null) {
        if (control.isDisposed()) error (DWT.ERROR_INVALID_ARGUMENT);
        if (control.parent !is parent) error (DWT.ERROR_INVALID_PARENT);
    }
    if ((style & DWT.SEPARATOR) is 0) return;
    if (this.control is control) return;
    NSBox widget = (NSBox)view;
    if (control is null) {
        widget.setBoxType(OS.NSBoxSeparator);
    } else {
        widget.setBoxType(OS.NSBoxCustom);
    }
    this.control = control;
    view.setHidden(control !is null);
    if (control !is null && !control.isDisposed ()) {
        control.moveAbove (null);
    }
    parent.relayout ();
}

/**
 * Enables the receiver if the argument is <code>true</code>,
 * and disables it otherwise.
 * <p>
 * A disabled control is typically
 * not selectable from the user interface and draws with an
 * inactive or "grayed" look.
 * </p>
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
    if ((state & DISABLED) is 0 && enabled) return;
    if (enabled) {
        state &= ~DISABLED;     
    } else {
        state |= DISABLED;
    }
    enableWidget(enabled);
}

/**
 * Sets the receiver's disabled image to the argument, which may be
 * null indicating that no disabled image should be displayed.
 * <p>
 * The disabled image is displayed when the receiver is disabled.
 * </p>
 *
 * @param image the disabled image to display on the receiver (may be null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the image has been disposed</li> 
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setDisabledImage (Image image) {
    checkWidget();
    if (image !is null && image.isDisposed()) error(DWT.ERROR_INVALID_ARGUMENT);
    if ((style & DWT.SEPARATOR) !is 0) return;
    disabledImage = image;
    updateImage (true);
}

/**
 * Sets the receiver's hot image to the argument, which may be
 * null indicating that no hot image should be displayed.
 * <p>
 * The hot image is displayed when the mouse enters the receiver.
 * </p>
 *
 * @param image the hot image to display on the receiver (may be null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the image has been disposed</li> 
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setHotImage (Image image) {
    checkWidget();
    if (image !is null && image.isDisposed()) error(DWT.ERROR_INVALID_ARGUMENT);
    if ((style & DWT.SEPARATOR) !is 0) return;
    hotImage = image;
    updateImage (true);
}

public void setImage (Image image) {
    checkWidget();
    if (image !is null && image.isDisposed()) error(DWT.ERROR_INVALID_ARGUMENT);
    if ((style & DWT.SEPARATOR) !is 0) return;
    super.setImage (image);
    updateImage (true);
}

bool setRadioSelection (bool value) {
    if ((style & DWT.RADIO) is 0) return false;
    if (getSelection () !is value) {
        setSelection (value);
        postEvent (DWT.Selection);
    }
    return true;
}

/**
 * Sets the selection state of the receiver.
 * <p>
 * When the receiver is of type <code>CHECK</code> or <code>RADIO</code>,
 * it is selected when it is checked (which some platforms draw as a
 * pushed in button).
 * </p>
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
    if ((style & (DWT.CHECK | DWT.RADIO)) is 0) return;
    this.selection = selected;
    view.setNeedsDisplay(true);
}

/**
 * Sets the receiver's text. The string may include
 * the mnemonic character.
 * </p>
 * <p>
 * Mnemonics are indicated by an '&amp;' that causes the next
 * character to be the mnemonic.  When the user presses a
 * key sequence that matches the mnemonic, a selection
 * event occurs. On most platforms, the mnemonic appears
 * underlined but may be emphasised in a platform specific
 * manner.  The mnemonic indicator character '&amp;' can be
 * escaped by doubling it in the string, causing a single
 * '&amp;' to be displayed.
 * </p>
 * 
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
    if (string is null) error (DWT.ERROR_NULL_ARGUMENT);
    if ((style & DWT.SEPARATOR) !is 0) return;
    super.setText (string);
    NSButton widget = cast(NSButton)button;
    widget.setAttributedTitle(createString());
    if (text.length() !is 0 && image !is null) {
        if ((parent.style & DWT.RIGHT) !is 0) {
            widget.setImagePosition(OS.NSImageLeft);
        } else {
            widget.setImagePosition(OS.NSImageAbove);       
        }
    } else {
        widget.setImagePosition(text.length() !is 0 ? OS.NSNoImage : OS.NSImageOnly);
    }
    parent.relayout ();
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
    parent.checkToolTip (this);
}

void setVisible (bool visible) {
    if (visible) {
        if ((state & HIDDEN) is 0) return;
        state &= ~HIDDEN;
    } else {
        if ((state & HIDDEN) !is 0) return;
        state |= HIDDEN;
    }
    view.setHidden(!visible);
}

/**
 * Sets the width of the receiver, for <code>SEPARATOR</code> ToolItems.
 *
 * @param width the new width
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setWidth (int width) {
    checkWidget();
    if ((style & DWT.SEPARATOR) is 0) return;
    if (width < 0 || this.width is width) return;
    this.width = width;
    parent.relayout();
}

String tooltipText () {
    return toolTipText;
}

void updateImage (bool layout) {
    if ((style & DWT.SEPARATOR) !is 0) return;
    Image image = null;
    if (hotImage !is null) {
        image = hotImage;
    } else {
        if (this.image !is null) {
            image = this.image;
        } else {
            image = disabledImage;
        }
    }
    NSButton widget = cast(NSButton)button;
    /*
     * Feature in Cocoa.  If the NSImage object being set into the button is
     * the same NSImage object that is already there then the button does not
     * redraw itself.  This results in the button's image not visually updating
     * if the NSImage object's content has changed since it was last set
     * into the button.  The workaround is to explicitly redraw the button.
     */
    widget.setImage(image !is null ? image.handle : null);
    widget.setNeedsDisplay(true);
    if (text.length() !is 0 && image !is null) {
        if ((parent.style & DWT.RIGHT) !is 0) {
            widget.setImagePosition(OS.NSImageLeft);
        } else {
            (cast(NSButton)button).setImagePosition(OS.NSImageAbove);       
        }
    } else {    
        widget.setImagePosition(text.length() !is 0 ? OS.NSNoImage : OS.NSImageOnly);       
    }
    parent.relayout();
}

}
