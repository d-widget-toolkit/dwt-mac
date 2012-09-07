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
module dwt.widgets.Decorations;






import dwt.DWT;
import dwt.dwthelper.utils;
import dwt.dwthelper.System;
import dwt.internal.cocoa.NSButton;
import dwt.internal.cocoa.NSButtonCell;
import dwt.widgets.Button;
import dwt.widgets.Canvas;
import dwt.widgets.Composite;
import dwt.widgets.Control;
import dwt.widgets.Display;
import dwt.widgets.Menu;
import dwt.widgets.Widget;
import dwt.graphics.Image;
import dwt.graphics.ImageData;

/**
 * Instances of this class provide the appearance and
 * behavior of <code>Shells</code>, but are not top
 * level shells or dialogs. Class <code>Shell</code>
 * shares a significant amount of code with this class,
 * and is a subclass.
 * <p>
 * IMPORTANT: This class was intended to be abstract and
 * should <em>never</em> be referenced or instantiated.
 * Instead, the class <code>Shell</code> should be used.
 * </p>
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
 * </p>
 * Note: The styles supported by this class must be treated
 * as <em>HINT</em>s, since the window manager for the
 * desktop on which the instance is visible has ultimate
 * control over the appearance and behavior of decorations.
 * For example, some window managers only support resizable
 * windows and will always assume the RESIZE style, even if
 * it is not set.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>BORDER, CLOSE, MIN, MAX, NO_TRIM, RESIZE, TITLE, ON_TOP, TOOL</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
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
 * <p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the DWT implementation.
 * </p>
 *
 * @see #getMinimized
 * @see #getMaximized
 * @see Shell
 * @see DWT
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 * @noextend This class is not intended to be subclassed by clients.
 */
public class Decorations : Canvas {
    Image image;
    Image [] images;
    Menu menuBar;
    String text = "";
    bool minimized, maximized;
    Control savedFocus;
    Button defaultButton;

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
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, checkStyle (style));
    images = new Image [0];
}

static int checkStyle (int style) {
    if ((style & DWT.NO_TRIM) !is 0) {
        style &= ~(DWT.CLOSE | DWT.TITLE | DWT.MIN | DWT.MAX | DWT.RESIZE | DWT.BORDER);
    }
    if ((style & (DWT.MENU | DWT.MIN | DWT.MAX | DWT.CLOSE)) !is 0) {
        style |= DWT.TITLE;
    }
    return style;
}

void bringToTop (bool force) {
    moveAbove (null);
}

protected void checkSubclass () {
    if (!isValidSubclass ()) error (DWT.ERROR_INVALID_SUBCLASS);
}

int compare (ImageData data1, ImageData data2) {
    if (data1.width is data2.width && data1.height is data2.height) {
        int transparent1 = data1.getTransparencyType ();
        int transparent2 = data2.getTransparencyType ();
        if (transparent1 is DWT.TRANSPARENCY_ALPHA) return -1;
        if (transparent2 is DWT.TRANSPARENCY_ALPHA) return 1;
        if (transparent1 is DWT.TRANSPARENCY_MASK) return -1;
        if (transparent2 is DWT.TRANSPARENCY_MASK) return 1;
        if (transparent1 is DWT.TRANSPARENCY_PIXEL) return -1;
        if (transparent2 is DWT.TRANSPARENCY_PIXEL) return 1;
        return 0;
    }
    return data1.width > data2.width || data1.height > data2.height ? -1 : 1;
}

Widget computeTabGroup () {
    return this;
}

Control computeTabRoot () {
    return this;
}

void fixDecorations (Decorations newDecorations, Control control, Menu [] menus) {
    if (this is newDecorations) return;
    if (control is savedFocus) savedFocus = null;
    if (control is defaultButton) defaultButton = null;
    if (menus is null) return;
    Menu menu = control.menu;
    if (menu !is null) {
        int index = 0;
        while (index < menus.length) {
            if (menus [index] is menu) {
                control.setMenu (null);
                return;
            }
            index++;
        }
        menu.fixMenus (newDecorations);
    }
}

/**
 * Returns the receiver's default button if one had
 * previously been set, otherwise returns null.
 *
 * @return the default button or null
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setDefaultButton(Button)
 */
public Button getDefaultButton () {
    checkWidget();
    return defaultButton;
}

/**
 * Returns the receiver's image if it had previously been
 * set using <code>setImage()</code>. The image is typically
 * displayed by the window manager when the instance is
 * marked as iconified, and may also be displayed somewhere
 * in the trim when the instance is in normal or maximized
 * states.
 * <p>
 * Note: This method will return null if called before
 * <code>setImage()</code> is called. It does not provide
 * access to a window manager provided, "default" image
 * even if one exists.
 * </p>
 *
 * @return the image
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

/**
 * Returns the receiver's images if they had previously been
 * set using <code>setImages()</code>. Images are typically
 * displayed by the window manager when the instance is
 * marked as iconified, and may also be displayed somewhere
 * in the trim when the instance is in normal or maximized
 * states. Depending where the icon is displayed, the platform
 * chooses the icon with the "best" attributes.  It is expected
 * that the array will contain the same icon rendered at different
 * sizes, with different depth and transparency attributes.
 *
 * <p>
 * Note: This method will return an empty array if called before
 * <code>setImages()</code> is called. It does not provide
 * access to a window manager provided, "default" image
 * even if one exists.
 * </p>
 *
 * @return the images
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public Image [] getImages () {
    checkWidget ();
    if (images is null) return new Image [0];
    Image [] result = new Image [images.length];
    System.arraycopy (images, 0, result, 0, images.length);
    return result;
}

/**
 * Returns <code>true</code> if the receiver is currently
 * maximized, and false otherwise.
 * <p>
 *
 * @return the maximized state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setMaximized
 */
public bool getMaximized () {
    checkWidget();
    return maximized;
}

/**
 * Returns the receiver's menu bar if one had previously
 * been set, otherwise returns null.
 *
 * @return the menu bar or null
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Menu getMenuBar () {
    checkWidget();
    return menuBar;
}

/**
 * Returns <code>true</code> if the receiver is currently
 * minimized, and false otherwise.
 * <p>
 *
 * @return the minimized state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setMinimized
 */
public bool getMinimized () {
    checkWidget();
    return minimized;
}

String getNameText () {
    return getText ();
}

/**
 * Returns the receiver's text, which is the string that the
 * window manager will typically display as the receiver's
 * <em>title</em>. If the text has not previously been set,
 * returns an empty string.
 *
 * @return the text
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String getText () {
    checkWidget();
    return text;
}

public bool isReparentable () {
    checkWidget();
    return false;
}

bool isTabGroup () {
    return true;
}

bool isTabItem () {
    return false;
}

Decorations menuShell () {
    return this;
}

void releaseChildren (bool destroy) {
    if (menuBar !is null) {
        menuBar.dispose ();
        menuBar = null;
    }
    Display display = this.display;
    super.releaseChildren (destroy);
    Menu [] menus = display.getMenus (this);
    if (menus !is null) {
        for (int i=0; i<menus.length; i++) {
            Menu menu = menus [i];
            if (menu !is null && !menu.isDisposed ()) {
                menu.dispose ();
            }
        }
        menus = null;
    }
}
void releaseWidget () {
    super.releaseWidget ();
    image = null;
    images = null;
    savedFocus = null;
    defaultButton = null;
}

bool restoreFocus () {
    if (savedFocus !is null && savedFocus.isDisposed ()) savedFocus = null;
    if (savedFocus is null) return false;
    return savedFocus.forceFocus ();
}

void saveFocus () {
//  int window = OS.GetControlOwner (handle);
//  Control control = display.getFocusControl (window, false);
//  if (control !is null && control !is this && this is control.menuShell ()) {
//      setSavedFocus (control);
//  }
}

/**
 * If the argument is not null, sets the receiver's default
 * button to the argument, and if the argument is null, sets
 * the receiver's default button to the first button which
 * was set as the receiver's default button (called the
 * <em>saved default button</em>). If no default button had
 * previously been set, or the saved default button was
 * disposed, the receiver's default button will be set to
 * null.
 * <p>
 * The default button is the button that is selected when
 * the receiver is active and the user presses ENTER.
 * </p>
 *
 * @param button the new default button
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the button has been disposed</li>
 *    <li>ERROR_INVALID_PARENT - if the control is not in the same widget tree</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setDefaultButton (Button button) {
    checkWidget();
    if (button !is null) {
        if (button.isDisposed ()) error (DWT.ERROR_INVALID_ARGUMENT);
        if (button.menuShell () !is this) error (DWT.ERROR_INVALID_PARENT);
        if ((button.style & DWT.PUSH) is 0) return;
    }
    if (button is defaultButton) return;
    defaultButton = button;
    NSButtonCell cell = null;
    if (defaultButton !is null && (defaultButton.style & DWT.PUSH) !is 0) {
        cell = new NSButtonCell ((cast(NSButton)defaultButton.view).cell ());
    }
    view.window().setDefaultButtonCell (cell);
    display.updateDefaultButton();
}

/**
 * Sets the receiver's image to the argument, which may
 * be null. The image is typically displayed by the window
 * manager when the instance is marked as iconified, and
 * may also be displayed somewhere in the trim when the
 * instance is in normal or maximized states.
 *
 * @param image the new image (or null)
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
    if (image !is null && image.isDisposed()) error(DWT.ERROR_INVALID_ARGUMENT);
    this.image = image;
    if (parent !is null) return;
    if (display.dockImage is null) {
        display.application.setApplicationIconImage (image !is null ? image.handle : null);
    }
}

/**
 * Sets the receiver's images to the argument, which may
 * be an empty array. Images are typically displayed by the
 * window manager when the instance is marked as iconified,
 * and may also be displayed somewhere in the trim when the
 * instance is in normal or maximized states. Depending where
 * the icon is displayed, the platform chooses the icon with
 * the "best" attributes. It is expected that the array will
 * contain the same icon rendered at different sizes, with
 * different depth and transparency attributes.
 *
 * @param images the new image array
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the array of images is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if one of the images is null or has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public void setImages (Image [] images) {
    checkWidget();
    if (images is null) error(DWT.ERROR_INVALID_ARGUMENT);
    for (int i = 0; i < images.length; i++) {
        if (images [i] is null || images [i].isDisposed ()) error (DWT.ERROR_INVALID_ARGUMENT);
    }
    this.images = images;
    if (parent !is null) return;
    if (display.dockImage is null) {
        if (images !is null && images.length > 1) {
            Image [] bestImages = new Image [images.length];
            System.arraycopy (images, 0, bestImages, 0, images.length);
            sort (bestImages);
            images = bestImages;
        }
        if (images !is null && images.length > 0) {
            display.application.setApplicationIconImage (images [0].handle);
        } else {
            display.application.setApplicationIconImage (null);
        }
    }
}

/**
 * Sets the maximized state of the receiver.
 * If the argument is <code>true</code> causes the receiver
 * to switch to the maximized state, and if the argument is
 * <code>false</code> and the receiver was previously maximized,
 * causes the receiver to switch back to either the minimized
 * or normal states.
 * <p>
 * Note: The result of intermixing calls to <code>setMaximized(true)</code>
 * and <code>setMinimized(true)</code> will vary by platform. Typically,
 * the behavior will match the platform user's expectations, but not
 * always. This should be avoided if possible.
 * </p>
 *
 * @param maximized the new maximized state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setMinimized
 */
public void setMaximized (bool maximized) {
    checkWidget();
    this.maximized = maximized;
}

/**
 * Sets the receiver's menu bar to the argument, which
 * may be null.
 *
 * @param menu the new menu bar
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the menu has been disposed</li>
 *    <li>ERROR_INVALID_PARENT - if the menu is not in the same widget tree</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setMenuBar (Menu menu) {
    checkWidget();
    if (menuBar is menu) return;
    if (menu !is null) {
        if (menu.isDisposed()) error(DWT.ERROR_INVALID_ARGUMENT);
        if ((menu.style & DWT.BAR) is 0) error (DWT.ERROR_MENU_NOT_BAR);
        if (menu.parent !is this) error (DWT.ERROR_INVALID_PARENT);
    }
    menuBar = menu;
}

/**
 * Sets the minimized stated of the receiver.
 * If the argument is <code>true</code> causes the receiver
 * to switch to the minimized state, and if the argument is
 * <code>false</code> and the receiver was previously minimized,
 * causes the receiver to switch back to either the maximized
 * or normal states.
 * <p>
 * Note: The result of intermixing calls to <code>setMaximized(true)</code>
 * and <code>setMinimized(true)</code> will vary by platform. Typically,
 * the behavior will match the platform user's expectations, but not
 * always. This should be avoided if possible.
 * </p>
 *
 * @param minimized the new maximized state
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setMaximized
 */
public void setMinimized (bool minimized) {
    checkWidget();
    this.minimized = minimized;
}

void setSavedFocus (Control control) {
    savedFocus = control;
}

/**
 * Sets the receiver's text, which is the string that the
 * window manager will typically display as the receiver's
 * <em>title</em>, to the argument, which must not be null.
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
public void setText (String str) {
    checkWidget();
    //if (str is null) error (DWT.ERROR_NULL_ARGUMENT);
    text = str;
}

void sort (Image [] images) {
    /* Shell Sort from K&R, pg 108 */
    int length = images.length;
    if (length <= 1) return;
    ImageData [] datas = new ImageData [length];
    for (int i = 0; i < length; i++) {
        datas [i] = images [i].getImageData ();
    }
    for (int gap=length/2; gap>0; gap/=2) {
        for (int i=gap; i<length; i++) {
            for (int j=i-gap; j>=0; j-=gap) {
                if (compare (datas [j], datas [j + gap]) >= 0) {
                    Image swap = images [j];
                    images [j] = images [j + gap];
                    images [j + gap] = swap;
                    ImageData swapData = datas [j];
                    datas [j] = datas [j + gap];
                    datas [j + gap] = swapData;
                }
            }
        }
    }
}

bool traverseItem (bool next) {
    return false;
}

bool traverseReturn () {
    if (defaultButton is null || defaultButton.isDisposed ()) return false;
    if (!defaultButton.isVisible () || !defaultButton.isEnabled ()) return false;
    defaultButton.click ();
    return true;
}

}
