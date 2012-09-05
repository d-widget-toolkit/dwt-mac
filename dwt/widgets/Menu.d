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
module dwt.widgets.Menu;








import dwt.DWT;
import dwt.dwthelper.System;
import dwt.dwthelper.utils;
import dwt.internal.objc.cocoa.Cocoa;
import dwt.internal.cocoa.NSApplication;
import dwt.internal.cocoa.NSMenu;
import dwt.internal.cocoa.NSView;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSWindow;
import dwt.internal.cocoa.NSEvent;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSMenuItem;
import dwt.internal.cocoa.SWTMenu;
import dwt.internal.cocoa.SWTMenuItem;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;
import dwt.widgets.TypedListener;
import dwt.widgets.Event;
import dwt.widgets.MenuItem;
import dwt.widgets.Widget;
import dwt.widgets.Control;
import dwt.widgets.Decorations;
import dwt.widgets.Shell;
import dwt.widgets.TrayItem;
import dwt.events.HelpListener;
import dwt.events.MenuListener;
import dwt.graphics.Point;

/**
 * Instances of this class are user interface objects that contain
 * menu items.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>BAR, DROP_DOWN, POP_UP, NO_RADIO_GROUP</dd>
 * <dd>LEFT_TO_RIGHT, RIGHT_TO_LEFT</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Help, Hide, Show </dd>
 * </dl>
 * <p>
 * Note: Only one of BAR, DROP_DOWN and POP_UP may be specified.
 * Only one of LEFT_TO_RIGHT or RIGHT_TO_LEFT may be specified.
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#menu">Menu snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">DWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 * @noextend This class is not intended to be subclassed by clients.
 */
public class Menu : Widget {
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
    NSMenu nsMenu;
    int x, y, itemCount;
    bool hasLocation, visible;
    MenuItem [] items;
    MenuItem cascade, defaultItem;
    Decorations parent;

/**
 * Constructs a new instance of this class given its parent,
 * and sets the style for the instance so that the instance
 * will be a popup menu on the given parent's shell.
 * <p>
 * After constructing a menu, it can be set into its parent
 * using <code>parent.setMenu(menu)</code>.  In this case, the parent may
 * be any control in the same widget tree as the parent.
 * </p>
 *
 * @param parent a control which will be the parent of the new instance (cannot be null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see DWT#POP_UP
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Control parent) {
    this (checkNull (parent).menuShell (), DWT.POP_UP);
}

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>Decorations</code>) and a style value
 * describing its behavior and appearance.
 * <p>
 * The style value is either one of the style constants defined in
 * class <code>DWT</code> which is applicable to instances of this
 * class, or must be built by <em>bitwise OR</em>'ing together
 * (that is, using the <code>int</code> "|" operator) two or more
 * of those <code>DWT</code> style constants. The class description
 * lists the style constants that are applicable to the class.
 * Style bits are also inherited from superclasses.
 * </p><p>
 * After constructing a menu or menuBar, it can be set into its parent
 * using <code>parent.setMenu(menu)</code> or <code>parent.setMenuBar(menuBar)</code>.
 * </p>
 *
 * @param parent a decorations control which will be the parent of the new instance (cannot be null)
 * @param style the style of menu to construct
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see DWT#BAR
 * @see DWT#DROP_DOWN
 * @see DWT#POP_UP
 * @see DWT#NO_RADIO_GROUP
 * @see DWT#LEFT_TO_RIGHT
 * @see DWT#RIGHT_TO_LEFT
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Decorations parent, int style) {
    super (parent, checkStyle (style));
    this.parent = parent;
    createWidget ();
}

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>Menu</code>) and sets the style
 * for the instance so that the instance will be a drop-down
 * menu on the given parent's parent.
 * <p>
 * After constructing a drop-down menu, it can be set into its parentMenu
 * using <code>parentMenu.setMenu(menu)</code>.
 * </p>
 *
 * @param parentMenu a menu which will be the parent of the new instance (cannot be null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see DWT#DROP_DOWN
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Menu parentMenu) {
    this (checkNull (parentMenu).parent, DWT.DROP_DOWN);
}

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>MenuItem</code>) and sets the style
 * for the instance so that the instance will be a drop-down
 * menu on the given parent's parent menu.
 * <p>
 * After constructing a drop-down menu, it can be set into its parentItem
 * using <code>parentItem.setMenu(menu)</code>.
 * </p>
 *
 * @param parentItem a menu item which will be the parent of the new instance (cannot be null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see DWT#DROP_DOWN
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (MenuItem parentItem) {
    this (checkNull (parentItem).parent);
}

static Control checkNull (Control control) {
    if (control is null) DWT.error (DWT.ERROR_NULL_ARGUMENT);
    return control;
}

static Menu checkNull (Menu menu) {
    if (menu is null) DWT.error (DWT.ERROR_NULL_ARGUMENT);
    return menu;
}

static MenuItem checkNull (MenuItem item) {
    if (item is null) DWT.error (DWT.ERROR_NULL_ARGUMENT);
    return item;
}

static int checkStyle (int style) {
    return checkBits (style, DWT.POP_UP, DWT.BAR, DWT.DROP_DOWN, 0, 0, 0);
}

void _setVisible (bool visible) {
    if ((style & (DWT.BAR | DWT.DROP_DOWN)) !is 0) return;
    TrayItem trayItem = display.currentTrayItem;
    if (trayItem !is null && visible) {
        trayItem.showMenu (this);
        return;
    }
    if (visible) {
        Shell shell = getShell ();
        NSWindow window = shell.window;
        NSPoint location;
        if (hasLocation) {
            NSView topView = window.contentView();
            Point shellCoord = display.map(null, shell, new Point(x,y));
            location = NSPoint ();
            location.x = shellCoord.x;
            location.y = topView.frame().height - shellCoord.y;
        } else {
            location = window.mouseLocationOutsideOfEventStream();
        }

        // Hold on to window in case it is disposed while the popup is open.
        window.retain();
        NSEvent nsEvent = NSEvent.otherEventWithType(cast(NSEventType)OS.NSApplicationDefined, location, 0, 0.0, window.windowNumber(), window.graphicsContext(), cast(short)0, 0, 0);
        NSMenu.popUpContextMenu(nsMenu, nsEvent, shell.view);
        window.release();
    } else {
        nsMenu.cancelTracking ();
    }
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
    checkWidget ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (DWT.Help, typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when menus are hidden or shown, by sending it
 * one of the messages defined in the <code>MenuListener</code>
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
 * @see MenuListener
 * @see #removeMenuListener
 */
public void addMenuListener (MenuListener listener) {
    checkWidget ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (DWT.Hide,typedListener);
    addListener (DWT.Show,typedListener);
}

void createHandle () {
    display.addMenu (this);
    NSMenu widget = cast(NSMenu)(new SWTMenu()).alloc();
    widget = widget.initWithTitle(NSString.stringWith(""));
    widget.setAutoenablesItems(false);
    widget.setDelegate(widget);
    nsMenu = widget;
}

void createItem (MenuItem item, int index) {
    if (!(0 <= index && index <= itemCount)) error (DWT.ERROR_INVALID_RANGE);
    NSMenuItem nsItem = null;
    if ((item.style & DWT.SEPARATOR) !is 0) {
        nsItem = NSMenuItem.separatorItem();
        nsItem.retain();
    } else {
        nsItem = cast(NSMenuItem)(new SWTMenuItem()).alloc();
        nsItem.initWithTitle(NSString.stringWith(""), null, NSString.stringWith(""));
        nsItem.setTarget(nsItem);
        nsItem.setAction(OS.sel_sendSelection);
    }
    item.nsItem = nsItem;
    item.createJNIRef();
    item.register();
    nsMenu.insertItem(nsItem, index);
    if (itemCount is items.length) {
        MenuItem [] newItems = new MenuItem [items.length + 4];
        System.arraycopy (items, 0, newItems, 0, items.length);
        items = newItems;
    }
    System.arraycopy (items, index, items, index + 1, itemCount++ - index);
    items [index] = item;
    NSMenu emptyMenu = item.createEmptyMenu ();
    if (emptyMenu !is null) {
        nsItem.setSubmenu (emptyMenu);
        emptyMenu.release();
    }
    if (display.menuBar is this) {
        NSApplication application = display.application;
        NSMenu menubar = application.mainMenu();
        if (menubar !is null) {
            nsItem.setMenu(null);
            menubar.insertItem(nsItem, index + 1);
        }
    }
    //TODO - find a way to disable the menu instead of each item
    if (!getEnabled ()) nsItem.setEnabled (false);
}

void createWidget () {
    checkOrientation (parent);
    super.createWidget ();
    items = new MenuItem [4];
}

void deregister () {
    super.deregister ();
    display.removeWidget (nsMenu);
}

void destroyItem (MenuItem item) {
    int index = 0;
    while (index < itemCount) {
        if (items [index] is item) break;
        index++;
    }
    if (index is itemCount) return;
    System.arraycopy (items, index + 1, items, index, --itemCount - index);
    items [itemCount] = null;
    if (itemCount is 0) items = new MenuItem [4];
    nsMenu.removeItem (item.nsItem);
    if (display.menuBar is this) {
        NSApplication application = display.application;
        NSMenu menubar = application.mainMenu();
        if (menubar !is null) {
            NSMenuItem nsItem = item.nsItem;
            menubar.removeItem(nsItem);
        }
    }
}

void fixMenus (Decorations newParent) {
    this.parent = newParent;
}

/**
 * Returns the default menu item or null if none has
 * been previously set.
 *
 * @return the default menu item.
 *
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public MenuItem getDefaultItem () {
    checkWidget();
    return defaultItem;
}

/**
 * Returns <code>true</code> if the receiver is enabled, and
 * <code>false</code> otherwise. A disabled menu is typically
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
 * Returns the item at the given, zero-relative index in the
 * receiver. Throws an exception if the index is out of range.
 *
 * @param index the index of the item to return
 * @return the item at the given index
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_RANGE - if the index is not between 0 and the number of elements in the list minus 1 (inclusive)</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public MenuItem getItem (int index) {
    checkWidget ();
    if (!(0 <= index && index < itemCount)) error (DWT.ERROR_INVALID_RANGE);
    return items [index];
}

/**
 * Returns the number of items contained in the receiver.
 *
 * @return the number of items
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getItemCount () {
    checkWidget ();
    return itemCount;
}

/**
 * Returns a (possibly empty) array of <code>MenuItem</code>s which
 * are the items in the receiver.
 * <p>
 * Note: This is not the actual structure used by the receiver
 * to maintain its list of items, so modifying the array will
 * not affect the receiver.
 * </p>
 *
 * @return the items in the receiver
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public MenuItem [] getItems () {
    checkWidget ();
    MenuItem [] result = new MenuItem [itemCount];
    int index = 0;
    if (items !is null) {
        for (int i = 0; i < itemCount; i++) {
            MenuItem item = items [i];
            if (item !is null && !item.isDisposed ()) {
                result [index++] = item;
            }
        }
    }
    if (index !is result.length) {
        MenuItem [] newItems = new MenuItem[index];
        System.arraycopy(result, 0, newItems, 0, index);
        result = newItems;
    }
    return result;
}

String getNameText () {
    String result = "";
    MenuItem [] items = getItems ();
    size_t length_ = items.length;
    if (length_ > 0) {
        for (size_t i=0; i<length_-1; i++) {
            result = result ~ items [i].getNameText() ~ ", ";
        }
        result = result ~ items [length_-1].getNameText ();
    }
    return result;
}

/**
 * Returns the receiver's parent, which must be a <code>Decorations</code>.
 *
 * @return the receiver's parent
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Decorations getParent () {
    checkWidget ();
    return parent;
}

/**
 * Returns the receiver's parent item, which must be a
 * <code>MenuItem</code> or null when the receiver is a
 * root.
 *
 * @return the receiver's parent item
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public MenuItem getParentItem () {
    checkWidget ();
    return cascade;
}

/**
 * Returns the receiver's parent item, which must be a
 * <code>Menu</code> or null when the receiver is a
 * root.
 *
 * @return the receiver's parent item
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Menu getParentMenu () {
    checkWidget ();
    if (cascade !is null) return cascade.parent;
    return null;
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
    checkWidget ();
    return parent.getShell ();
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
    checkWidget ();
    if ((style & DWT.BAR) !is 0) {
        return this is parent.menuShell ().menuBar;
    }
    if ((style & DWT.POP_UP) !is 0) {
        Menu [] popups = display.popups;
        if (popups is null) return false;
        for (int i=0; i<popups.length; i++) {
            if (popups [i] is this) return true;
        }
    }
    return visible;
}

/**
 * Searches the receiver's list starting at the first item
 * (index 0) until an item is found that is equal to the
 * argument, and returns the index of that item. If no item
 * is found, returns -1.
 *
 * @param item the search item
 * @return the index of the item
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the item is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int indexOf (MenuItem item) {
    checkWidget ();
    if (item is null) error (DWT.ERROR_NULL_ARGUMENT);
    for (int i=0; i<itemCount; i++) {
        if (items [i] is item) return i;
    }
    return -1;
}

/**
 * Returns <code>true</code> if the receiver is enabled and all
 * of the receiver's ancestors are enabled, and <code>false</code>
 * otherwise. A disabled menu is typically not selectable from the
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
    checkWidget ();
    Menu parentMenu = getParentMenu ();
    if (parentMenu is null) {
        return getEnabled () && parent.isEnabled ();
    }
    return getEnabled () && parentMenu.isEnabled ();
}

/**
 * Returns <code>true</code> if the receiver is visible and all
 * of the receiver's ancestors are visible and <code>false</code>
 * otherwise.
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
    checkWidget ();
    return getVisible ();
}

void menu_willHighlightItem(objc.id id, objc.SEL sel, objc.id menu, objc.id itemID) {
    Widget widget = display.getWidget(itemID);
    if (cast(MenuItem) widget) {
        MenuItem item = cast(MenuItem)widget;
        item.sendEvent (DWT.Arm);
    }
}

void menuNeedsUpdate(objc.id id, objc.SEL sel, objc.id menu) {
    //This code is intentionally commented
    //sendEvent (DWT.Show);
}

void menuWillOpen(objc.id id, objc.SEL sel, objc.id menu) {
    visible = true;
    sendEvent (DWT.Show);
    for (int i=0; i<items.length; i++) {
        MenuItem item = items [i];
        if (item !is null)  item.updateAccelerator (true);
    }
}

void menuDidClose(objc.id id, objc.SEL sel, objc.id menu) {
    sendEvent (DWT.Hide);
    visible = false;
    for (int i=0; i<items.length; i++) {
        MenuItem item = items [i];
        if (item !is null)  item.updateAccelerator (false);
    }
}

void register () {
    super.register ();
    display.addWidget (nsMenu, this);
}

void releaseChildren (bool destroy) {
    if (items !is null) {
        for (int i=0; i<items.length; i++) {
            MenuItem item = items [i];
            if (item !is null && !item.isDisposed ()) {
                item.release (false);
            }
        }
        items = null;
    }
    super.releaseChildren (destroy);
}

void releaseHandle () {
    super.releaseHandle ();
    if (nsMenu !is null) nsMenu.release();
    nsMenu = null;
}

void releaseParent () {
    super.releaseParent ();
    if (cascade !is null) cascade.setMenu (null);
    if ((style & DWT.BAR) !is 0 && this is parent.menuBar) {
        parent.setMenuBar (null);
    }
}

void releaseWidget () {
    super.releaseWidget ();
    display.removeMenu (this);
    parent = null;
    cascade = defaultItem = null;
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
 * be notified when the menu events are generated for the control.
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
 * @see MenuListener
 * @see #addMenuListener
 */
public void removeMenuListener (MenuListener listener) {
    checkWidget ();
    if (listener is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (DWT.Hide, listener);
    eventTable.unhook (DWT.Show, listener);
}

/**
 * Sets the default menu item to the argument or removes
 * the default emphasis when the argument is <code>null</code>.
 *
 * @param item the default menu item or null
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the menu item has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setDefaultItem (MenuItem item) {
    checkWidget();
    if (item !is null && item.isDisposed()) error(DWT.ERROR_INVALID_ARGUMENT);
    defaultItem = item;
}

/**
 * Enables the receiver if the argument is <code>true</code>,
 * and disables it otherwise. A disabled menu is typically
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
    if (enabled) {
        state &= ~DISABLED;
    } else {
        state |= DISABLED;
    }
    //TODO - find a way to disable the menu instead of each item
    for (int i=0; i<items.length; i++) {
        MenuItem item = items [i];
        if (item !is null) {
            /*
            * Feature in the Macintosh.  When a cascade menu
            * item is disabled, rather than disabling the item,
            * the submenu is disabled.
            *
            * There is no fix for this at this time.
            */
            item.nsItem.setEnabled (enabled && item.getEnabled ());
        }
    }
}

/**
 * Sets the location of the receiver, which must be a popup,
 * to the point specified by the arguments which are relative
 * to the display.
 * <p>
 * Note that this is different from most widgets where the
 * location of the widget is relative to the parent.
 * </p><p>
 * Note that the platform window manager ultimately has control
 * over the location of popup menus.
 * </p>
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
    checkWidget ();
    this.x = x;
    this.y = y;
    hasLocation = true;
}

/**
 * Sets the location of the receiver, which must be a popup,
 * to the point specified by the argument which is relative
 * to the display.
 * <p>
 * Note that this is different from most widgets where the
 * location of the widget is relative to the parent.
 * </p><p>
 * Note that the platform window manager ultimately has control
 * over the location of popup menus.
 * </p>
 *
 * @param location the new location for the receiver
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the point is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.1
 */
public void setLocation (Point location) {
    checkWidget ();
    if (location is null) error (DWT.ERROR_NULL_ARGUMENT);
    setLocation (location.x, location.y);
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
    checkWidget ();
    if ((style & (DWT.BAR | DWT.DROP_DOWN)) !is 0) return;
    if (visible) {
        display.addPopup (this);
    } else {
        display.removePopup (this);
    }
}

}
