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
module dwt.widgets.MenuItem;


import dwt.internal.cocoa.*;

import dwt.*;
import dwt.graphics.*;
import dwt.events.*;

import dwt.dwthelper.utils;
import dwt.internal.objc.cocoa.Cocoa;
import dwt.widgets.Decorations;
import dwt.widgets.Display;
import dwt.widgets.Event;
import dwt.widgets.Item;
import dwt.widgets.Menu;
import dwt.widgets.TypedListener;

/**
 * Instances of this class represent a selectable user interface object
 * that issues notification when pressed and released.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>CHECK, CASCADE, PUSH, RADIO, SEPARATOR</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Arm, Help, Selection</dd>
 * </dl>
 * <p>
 * Note: Only one of the styles CHECK, CASCADE, PUSH, RADIO and SEPARATOR
 * may be specified.
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 * @noextend This class is not intended to be subclassed by clients.
 */
public class MenuItem : Item {
    NSMenuItem nsItem;
    Menu parent, menu;
    int accelerator;

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>Menu</code>) and a style value
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
 * @param parent a menu control which will be the parent of the new instance (cannot be null)
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
 * @see DWT#CHECK
 * @see DWT#CASCADE
 * @see DWT#PUSH
 * @see DWT#RADIO
 * @see DWT#SEPARATOR
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Menu parent, int style) {
    super (parent, checkStyle (style));
    this.parent = parent;
    parent.createItem (this, parent.getItemCount ());
}

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>Menu</code>), a style value
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
 * @param parent a menu control which will be the parent of the new instance (cannot be null)
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
 * @see DWT#CHECK
 * @see DWT#CASCADE
 * @see DWT#PUSH
 * @see DWT#RADIO
 * @see DWT#SEPARATOR
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Menu parent, int style, int index) {
    super (parent, checkStyle (style));
    this.parent = parent;
    parent.createItem (this, index);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the arm events are generated for the control, by sending
 * it one of the messages defined in the <code>ArmListener</code>
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
 * @see ArmListener
 * @see #removeArmListener
 */
public void addArmListener (ArmListener listener) {
    checkWidget ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (DWT.Arm, typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the help events are generated for the control, by sending
 * it one of the messages defined in the <code>HelpListener</code>
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
 * @see HelpListener
 * @see #removeHelpListener
 */
public void addHelpListener (HelpListener listener) {
    checkWidget ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (DWT.Help, typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the menu item is selected by the user, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * When <code>widgetSelected</code> is called, the stateMask field of the event object is valid.
 * <code>widgetDefaultSelected</code> is not called.
 * </p>
 *
 * @param listener the listener which should be notified when the menu item is selected by the user
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
public void addSelectionListener (SelectionListener listener) {
    checkWidget ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener(listener);
    addListener (DWT.Selection,typedListener);
    addListener (DWT.DefaultSelection,typedListener);
}

protected void checkSubclass () {
    if (!isValidSubclass ()) error (DWT.ERROR_INVALID_SUBCLASS);
}

static int checkStyle (int style) {
    return checkBits (style, DWT.PUSH, DWT.CHECK, DWT.RADIO, DWT.SEPARATOR, DWT.CASCADE, 0);
}

NSMenu createEmptyMenu () {
    if ((parent.style & DWT.BAR) !is 0) {
        return cast(NSMenu) (new SWTMenu ()).alloc ().init ();
    }
    return null;
}

void deregister () {
    super.deregister ();
    display.removeWidget (nsItem);
}

void destroyWidget () {
    parent.destroyItem (this);
    releaseHandle ();
}

/**
 * Returns the widget accelerator.  An accelerator is the bit-wise
 * OR of zero or more modifier masks and a key. Examples:
 * <code>DWT.CONTROL | DWT.SHIFT | 'T', DWT.ALT | DWT.F2</code>.
 * The default value is zero, indicating that the menu item does
 * not have an accelerator.
 *
 * @return the accelerator or 0
 *
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getAccelerator () {
    checkWidget ();
    return accelerator;
}

/**
 * Returns <code>true</code> if the receiver is enabled, and
 * <code>false</code> otherwise. A disabled menu item is typically
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
 * Returns the receiver's cascade menu if it has one or null
 * if it does not. Only <code>CASCADE</code> menu items can have
 * a pull down menu. The sequence of key strokes, button presses
 * and/or button releases that are used to request a pull down
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
    checkWidget ();
    return menu;
}

String getNameText () {
    if ((style & DWT.SEPARATOR) !is 0) return "|";
    return super.getNameText ();
}

/**
 * Returns the receiver's parent, which must be a <code>Menu</code>.
 *
 * @return the receiver's parent
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Menu getParent () {
    checkWidget ();
    return parent;
}

/**
 * Returns <code>true</code> if the receiver is selected,
 * and false otherwise.
 * <p>
 * When the receiver is of type <code>CHECK</code> or <code>RADIO</code>,
 * it is selected when it is checked.
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
    if ((style & (DWT.CHECK | DWT.RADIO)) is 0) return false;
    return nsItem.state() is OS.NSOnState;
}

/**
 * Returns <code>true</code> if the receiver is enabled and all
 * of the receiver's ancestors are enabled, and <code>false</code>
 * otherwise. A disabled menu item is typically not selectable from the
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
    return getEnabled () && parent.isEnabled ();
}

int keyChar (int key) {
    //TODO - use the NS key constants
    switch (key) {
        case DWT.BS: return OS.NSBackspaceCharacter;
        case DWT.CR: return OS.NSCarriageReturnCharacter;
        case DWT.DEL: return OS.NSDeleteCharacter;
        case DWT.ESC: return DWT.ESC;
        case DWT.LF: return OS.NSNewlineCharacter;
        case DWT.TAB: return OS.NSTabCharacter;
//      case ' ': return OS.kMenuBlankGlyph;
//      case ' ': return OS.kMenuSpaceGlyph;
        case DWT.ALT: return 0x2325;
        case DWT.SHIFT: return 0x21E7;
        case DWT.CONTROL: return 0xF2303;
        case DWT.COMMAND: return 0x2318;
        case DWT.ARROW_UP: return 0x2191;
        case DWT.ARROW_DOWN: return 0x2193;
        case DWT.ARROW_LEFT: return 0x2190;
        case DWT.ARROW_RIGHT: return 0x2192;
        case DWT.PAGE_UP: return 0x21DE;
        case DWT.PAGE_DOWN: return 0x21DF;
        case DWT.KEYPAD_CR: return OS.NSEnterCharacter;
        case DWT.HELP: return OS.NSHelpFunctionKey;
        case DWT.HOME: return 0xF729;
        case DWT.END: return 0xF72B;
//      case DWT.CAPS_LOCK: return ??;
        case DWT.F1: return 0xF704;
        case DWT.F2: return 0xF705;
        case DWT.F3: return 0xF706;
        case DWT.F4: return 0xF707;
        case DWT.F5: return 0xF708;
        case DWT.F6: return 0xF709;
        case DWT.F7: return 0xF70A;
        case DWT.F8: return 0xF70B;
        case DWT.F9: return 0xF70C;
        case DWT.F10: return 0xF70D;
        case DWT.F11: return 0xF70E;
        case DWT.F12: return 0xF70F;
        case DWT.F13: return 0xF710;
        case DWT.F14: return 0xF711;
        case DWT.F15: return 0xF712;
        /*
        * The following lines are intentionally commented.
        */
//      case DWT.INSERT: return ??;
        default:
    }
    return 0;
}


void register () {
    super.register ();
    display.addWidget (nsItem, this);
}

void releaseHandle () {
    super.releaseHandle ();
    if (nsItem !is null) nsItem.release();
    nsItem = null;
    parent = null;
}

void releaseChildren (bool destroy) {
    if (menu !is null) {
        menu.release (false);
        menu = null;
    }
    super.releaseChildren (destroy);
}

void releaseWidget () {
    super.releaseWidget ();
    accelerator = 0;
    if (this is parent.defaultItem) parent.defaultItem = null;
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the arm events are generated for the control.
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
 * @see ArmListener
 * @see #addArmListener
 */
public void removeArmListener (ArmListener listener) {
    checkWidget ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (DWT.Arm, listener);
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
    checkWidget ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (DWT.Help, listener);
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
public void removeSelectionListener (SelectionListener listener) {
    checkWidget ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (DWT.Selection, listener);
    eventTable.unhook (DWT.DefaultSelection,listener);
}

void selectRadio () {
    int index = 0;
    MenuItem [] items = parent.getItems ();
    while (index < items.length && items [index] !is this) index++;
    int i = index - 1;
    while (i >= 0 && items [i].setRadioSelection (false)) --i;
    int j = index + 1;
    while (j < items.length && items [j].setRadioSelection (false)) j++;
    setSelection (true);
}

void sendSelection () {
    if ((style & DWT.CHECK) !is 0) {
        setSelection (!getSelection ());
    } else {
        if ((style & DWT.RADIO) !is 0) {
            if ((parent.getStyle () & DWT.NO_RADIO_GROUP) !is 0) {
                setSelection (!getSelection ());
            } else {
                selectRadio ();
            }
        }
    }
    Event event = new Event ();
    NSEvent nsEvent = NSApplication.sharedApplication ().currentEvent ();
    if (nsEvent !is null) setInputState (event, nsEvent, 0);
    postEvent (DWT.Selection, event);
}

/**
 * Sets the widget accelerator.  An accelerator is the bit-wise
 * OR of zero or more modifier masks and a key. Examples:
 * <code>DWT.MOD1 | DWT.MOD2 | 'T', DWT.MOD3 | DWT.F2</code>.
 * <code>DWT.CONTROL | DWT.SHIFT | 'T', DWT.ALT | DWT.F2</code>.
 * The default value is zero, indicating that the menu item does
 * not have an accelerator.
 *
 * @param accelerator an integer that is the bit-wise OR of masks and a key
 *
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setAccelerator (int accelerator) {
    checkWidget ();
    if (this.accelerator is accelerator) return;
    this.accelerator = accelerator;
    int key = accelerator & DWT.KEY_MASK;
    int virtualKey = keyChar (key);
    NSString str = null;
    if (virtualKey !is 0) {
        str = NSString.stringWith (cast(char)virtualKey ~ "");
    } else {
        str = NSString.stringWith (cast(char)key ~ "");
    }
    nsItem.setKeyEquivalent (str.lowercaseString());
    int mask = 0;
    if ((accelerator & DWT.SHIFT) !is 0) mask |= OS.NSShiftKeyMask;
    if ((accelerator & DWT.CONTROL) !is 0) mask |= OS.NSControlKeyMask;
    if ((accelerator & DWT.COMMAND) !is 0) mask |= OS.NSCommandKeyMask;
    if ((accelerator & DWT.ALT) !is 0) mask |= OS.NSAlternateKeyMask;
    nsItem.setKeyEquivalentModifierMask (cast(NSUInteger) mask);
}

/**
 * Enables the receiver if the argument is <code>true</code>,
 * and disables it otherwise. A disabled menu item is typically
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
    checkWidget ();
    if (enabled) {
        state &= ~DISABLED;
    } else {
        state |= DISABLED;
    }
    nsItem.setEnabled(enabled);
}

/**
 * Sets the image the receiver will display to the argument.
 * <p>
 * Note: This operation is a hint and is not supported on
 * platforms that do not have this concept (for example, Windows NT).
 * Furthermore, some platforms (such as GTK), cannot display both
 * a check box and an image at the same time.  Instead, they hide
 * the image and display the check box.
 * </p>
 *
 * @param image the image to display
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setImage (Image image) {
    checkWidget ();
    if ((style & DWT.SEPARATOR) !is 0) return;
    super.setImage (image);
    nsItem.setImage(image !is null? image.handle : null);
}

/**
 * Sets the receiver's pull down menu to the argument.
 * Only <code>CASCADE</code> menu items can have a
 * pull down menu. The sequence of key strokes, button presses
 * and/or button releases that are used to request a pull down
 * menu is platform specific.
 * <p>
 * Note: Disposing of a menu item that has a pull down menu
 * will dispose of the menu.  To avoid this behavior, set the
 * menu to null before the menu item is disposed.
 * </p>
 *
 * @param menu the new pull down menu
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_MENU_NOT_DROP_DOWN - if the menu is not a drop down menu</li>
 *    <li>ERROR_MENUITEM_NOT_CASCADE - if the menu item is not a <code>CASCADE</code></li>
 *    <li>ERROR_INVALID_ARGUMENT - if the menu has been disposed</li>
 *    <li>ERROR_INVALID_PARENT - if the menu is not in the same widget tree</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setMenu (Menu menu) {
    checkWidget ();

    /* Check to make sure the new menu is valid */
    if ((style & DWT.CASCADE) is 0) {
        error (DWT.ERROR_MENUITEM_NOT_CASCADE);
    }
    if (menu !is null) {
        if (menu.isDisposed()) error(DWT.ERROR_INVALID_ARGUMENT);
        if ((menu.style & DWT.DROP_DOWN) is 0) {
            error (DWT.ERROR_MENU_NOT_DROP_DOWN);
        }
        if (menu.parent !is parent.parent) {
            error (DWT.ERROR_INVALID_PARENT);
        }
    }
    /* Assign the new menu */
    Menu oldMenu = this.menu;
    if (oldMenu is menu) return;
    if (oldMenu !is null) oldMenu.cascade = null;
    this.menu = menu;

    /* Update the menu in the OS */
    if (menu is null) {
        NSMenu emptyMenu = createEmptyMenu ();
        if (emptyMenu !is null) {
            nsItem.setSubmenu (emptyMenu);
            emptyMenu.release();
        }
    } else {
        menu.cascade = this;
        nsItem.setSubmenu (menu.nsMenu);
    }

    if (menu !is null) {
        nsItem.setTarget(null);
        nsItem.setAction(0);
    } else {
        nsItem.setTarget(nsItem);
        nsItem.setAction(OS.sel_sendSelection);
    }

    /* Update menu title with parent item title */
    updateText ();
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
 * it is selected when it is checked.
 *
 * @param selected the new selection state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSelection (bool selected) {
    checkWidget ();
    if ((style & (DWT.CHECK | DWT.RADIO)) is 0) return;
    nsItem.setState(selected ? OS.NSOnState : OS.NSOffState);
}

/**
 * Sets the receiver's text. The string may include
 * the mnemonic character and accelerator text.
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
 * <p>
 * Accelerator text is indicated by the '\t' character.
 * On platforms that support accelerator text, the text
 * that follows the '\t' character is displayed to the user,
 * typically indicating the key stroke that will cause
 * the item to become selected.  On most platforms, the
 * accelerator text appears right aligned in the menu.
 * Setting the accelerator text does not install the
 * accelerator key sequence. The accelerator key sequence
 * is installed using #setAccelerator.
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
 *
 * @see #setAccelerator
 */
public void setText (String string) {
    checkWidget ();
    if (string is null) error (DWT.ERROR_NULL_ARGUMENT);
    if ((style & DWT.SEPARATOR) !is 0) return;
    if (text.equals (string)) return;
    super.setText (string);
    updateText ();
}

void updateText () {
    char [] buffer = new char [text.length ()];
    text.getChars (0, buffer.length, buffer, 0);
    int i=0, j=0;
    while (i < buffer.length) {
        if (buffer [i] is '\t') break;
        if ((buffer [j++] = buffer [i++]) is '&') {
            if (i is buffer.length) {continue;}
            if (buffer [i] is '&') {i++; continue;}
            j--;
        }
    }
    String text = new_String (buffer, 0, j);
    NSMenu submenu = nsItem.submenu ();
    NSString label = NSString.stringWith (text);
    if(submenu !is null && (parent.getStyle () & DWT.BAR) !is 0) {
        submenu.setTitle (label);
    } else {
        nsItem.setTitle (label);
    }
}

void updateAccelerator (bool show) {
    if (accelerator !is 0) return;
    int mask = 0, key = 0;
    if (show) {
        char [] buffer = new char [text.length ()];
        text.getChars (0, buffer.length, buffer, 0);
        int i=0, j=0;
        while (i < buffer.length) {
            if (buffer [i] is '\t') break;
            if ((buffer [j++] = buffer [i++]) is '&') {
                if (i is buffer.length) {continue;}
                if (buffer [i] is '&') {i++; continue;}
                j--;
            }
        }
        if (i < buffer.length && buffer [i] is '\t') {
            for (j = i + 1; j < buffer.length; j++) {
                switch (buffer [j]) {
                    case '\u2303': mask |= OS.NSControlKeyMask; i++; break;
                    case '\u2325': mask |= OS.NSAlternateKeyMask; i++; break;
                    case '\u21E7': mask |= OS.NSShiftKeyMask; i++; break;
                    case '\u2318': mask |= OS.NSCommandKeyMask; i++; break;
                    default:
                        j = buffer.length;
                        break;
                }
            }
            switch (buffer.length - i - 1) {
                case 1:
                    key = buffer [i + 1];
                    if (key is 0x2423) key = ' ';
                    break;
                case 2:
                    if (buffer [i + 1] is 'F') {
                        switch (buffer [i + 2]) {
                            case '1': key = 0xF704; break;
                            case '2': key = 0xF705; break;
                            case '3': key = 0xF706; break;
                            case '4': key = 0xF707; break;
                            case '5': key = 0xF708; break;
                            case '6': key = 0xF709; break;
                            case '7': key = 0xF70A; break;
                            case '8': key = 0xF70B; break;
                            case '9': key = 0xF70C; break;
                            default:
                        }
                    }
                    break;
                case 3:
                    if (buffer [i + 1] is 'F' && buffer [i + 2] is '1') {
                        switch (buffer [i + 3]) {
                            case '0': key = 0xF70D; break;
                            case '1': key = 0xF70E; break;
                            case '2': key = 0xF70F; break;
                            case '3': key = 0xF710; break;
                            case '4': key = 0xF711; break;
                            case '5': key = 0xF712; break;
                            default:
                        }
                    }
                    break;
                default:
            }
        }
    }
    NSString string = NSString.stringWith (key is 0 ? "" : String.valueOf ((char)key));
    nsItem.setKeyEquivalentModifierMask (mask);
    nsItem.setKeyEquivalent (string.lowercaseString ());
}

}

