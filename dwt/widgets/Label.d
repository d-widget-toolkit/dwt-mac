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
module dwt.widgets.Label;

import dwt.dwthelper.utils;





import dwt.DWT;
import dwt.accessibility.ACC;
import dwt.internal.cocoa.NSBox;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.NSCell;
import dwt.internal.cocoa.NSFont;
import dwt.internal.cocoa.NSView;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSMutableArray;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSControl;
import dwt.internal.cocoa.NSImage;
import dwt.internal.cocoa.NSColor;
import dwt.internal.cocoa.NSTextField;
import dwt.internal.cocoa.NSImageView;
import dwt.internal.cocoa.NSImageCell;
import dwt.internal.cocoa.SWTBox;
import dwt.internal.cocoa.SWTView;
import dwt.internal.cocoa.SWTImageView;
import dwt.internal.cocoa.SWTTextField;
import dwt.internal.cocoa.NSTextFieldCell;
import dwt.internal.cocoa.NSAttributedString;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import cocoa = dwt.internal.cocoa.id;
import Carbon = dwt.internal.c.Carbon;
import objc = dwt.internal.objc.runtime;
import dwt.widgets.Composite;
import dwt.widgets.Control;
import dwt.graphics.Image;
import dwt.graphics.Point;

/**
 * Instances of this class represent a non-selectable
 * user interface object that displays a string or image.
 * When SEPARATOR is specified, displays a single
 * vertical or horizontal line.
 * <p>
 * Shadow styles are hints and may not be honored
 * by the platform.  To create a separator label
 * with the default shadow style for the platform,
 * do not specify a shadow style.
 * </p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>SEPARATOR, HORIZONTAL, VERTICAL</dd>
 * <dd>SHADOW_IN, SHADOW_OUT, SHADOW_NONE</dd>
 * <dd>CENTER, LEFT, RIGHT, WRAP</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
 * </dl>
 * <p>
 * Note: Only one of SHADOW_IN, SHADOW_OUT and SHADOW_NONE may be specified.
 * SHADOW_NONE is a HINT. Only one of HORIZONTAL and VERTICAL may be specified.
 * Only one of CENTER, LEFT and RIGHT may be specified.
 * </p><p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the DWT implementation.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#label">Label snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">DWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 * @noextend This class is not intended to be subclassed by clients.
 */
public class Label : Control {
    alias Control.computeSize computeSize;
    alias Control.setBounds setBounds;
    alias Control.setBackground setBackground;
    alias Control.setForeground setForeground;
    alias Control.createString createString;

    String text;
    Image image;
    bool isImage;
    NSTextField textView;
    NSImageView imageView;

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
 * @see DWT#SEPARATOR
 * @see DWT#HORIZONTAL
 * @see DWT#VERTICAL
 * @see DWT#SHADOW_IN
 * @see DWT#SHADOW_OUT
 * @see DWT#SHADOW_NONE
 * @see DWT#CENTER
 * @see DWT#LEFT
 * @see DWT#RIGHT
 * @see DWT#WRAP
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, checkStyle (style));
}

objc.id accessibilityAttributeNames(objc.id id, objc.SEL sel) {
    if (accessible !is null) {
        if ((textView !is null && (id is textView.id || id is textView.cell().id)) || (imageView !is null && (id is imageView.id || id is imageView.cell().id))) {
            // See if the accessible will override or augment the standard list.
            // Help, title, and description can be overridden.
            NSMutableArray extraAttributes = NSMutableArray.arrayWithCapacity(3);
            extraAttributes.addObject(OS.NSAccessibilityHelpAttribute);
            extraAttributes.addObject(OS.NSAccessibilityDescriptionAttribute);
            extraAttributes.addObject(OS.NSAccessibilityTitleAttribute);

            for (NSInteger i = extraAttributes.count() - 1; i >= 0; i--) {
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

bool accessibilityIsIgnored(objc.id id, objc.SEL sel) {
    if (id is view.id) return true;
    return super.accessibilityIsIgnored(id, sel);
}

void addRelation (Control control) {
    if (!control.isDescribedByLabel ()) return;

    if (textView !is null) {
        NSObject accessibleElement = control.focusView();

        if (auto viewAsControl = cast(NSControl)accessibleElement) {
            if (viewAsControl.cell() !is null) accessibleElement = viewAsControl.cell();
        }

        accessibleElement.accessibilitySetOverrideValue(textView.cell(), OS.NSAccessibilityTitleUIElementAttribute);
        NSArray controlArray = NSArray.arrayWithObject(accessibleElement);
        textView.cell().accessibilitySetOverrideValue(controlArray, OS.NSAccessibilityServesAsTitleForUIElementsAttribute);
    }
}

static int checkStyle (int style) {
    style |= DWT.NO_FOCUS;
    if ((style & DWT.SEPARATOR) !is 0) {
        style = checkBits (style, DWT.VERTICAL, DWT.HORIZONTAL, 0, 0, 0, 0);
        return checkBits (style, DWT.SHADOW_OUT, DWT.SHADOW_IN, DWT.SHADOW_NONE, 0, 0, 0);
    }
    return checkBits (style, DWT.LEFT, DWT.CENTER, DWT.RIGHT, 0, 0, 0);
}

public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget();
    int width = DEFAULT_WIDTH;
    int height = DEFAULT_HEIGHT;
    if ((style & DWT.SEPARATOR) !is 0) {
        Cocoa.CGFloat lineWidth = (cast(NSBox)view).borderWidth ();
        if ((style & DWT.HORIZONTAL) !is 0) {
            height = cast(int)Math.ceil (lineWidth * 2);
        } else {
            width = cast(int)Math.ceil (lineWidth * 2);
        }
        if (wHint !is DWT.DEFAULT) width = wHint;
        if (hHint !is DWT.DEFAULT) height = hHint;
        int border = getBorderWidth ();
        width += border * 2; height += border * 2;
        return new Point (width, height);
    }
    if (isImage) {
        if (image !is null) {
            NSImage nsimage = image.handle;
            NSSize size = nsimage.size ();
                width = cast(int)size.width;
                height = cast(int)size.height;
        } else {
            width = height = 0;
        }
    } else {
        NSSize size;
        if ((style & DWT.WRAP) !is 0 && wHint !is DWT.DEFAULT) {
            NSRect rect = NSRect ();
            rect.width = wHint;
            rect.height = hHint !is DWT.DEFAULT ? hHint : Float.MAX_VALUE;
            size = textView.cell ().cellSizeForBounds (rect);
        } else {
            size = textView.cell ().cellSize ();
        }
        width = cast(int)Math.ceil (size.width);
        height = cast(int)Math.ceil (size.height);
    }
    if (wHint !is DWT.DEFAULT) width = wHint;
    if (hHint !is DWT.DEFAULT) height = hHint;
    return new Point (width, height);
}

void createHandle () {
    state |= THEME_BACKGROUND;
    NSBox widget = cast(NSBox)(new SWTBox()).alloc();
    widget.initWithFrame(NSRect());
    widget.init();
    widget.setTitle(NSString.stringWith(""));
    if ((style & DWT.SEPARATOR) !is 0) {
        widget.setBoxType(OS.NSBoxSeparator);
        NSView child = cast(NSView) (new SWTView()).alloc().init();
        widget.setContentView(child);
        child.release();
    } else {
        widget.setBorderType(OS.NSNoBorder);
        widget.setBorderWidth (0);
        widget.setBoxType (OS.NSBoxCustom);
        NSSize offsetSize = NSSize ();
        widget.setContentViewMargins (offsetSize);

        NSImageView imageWidget = cast(NSImageView) (new SWTImageView ()).alloc ();
        imageWidget.init();
        imageWidget.setImageScaling (OS.NSScaleNone);

        NSTextField textWidget = cast(NSTextField)(new SWTTextField()).alloc();
        textWidget.init();
        textWidget.setBordered(false);
        textWidget.setEditable(false);
        textWidget.setDrawsBackground(false);
        NSTextFieldCell cell = new NSTextFieldCell(textWidget.cell());
        cell.setWraps ((style & DWT.WRAP) !is 0);

        widget.addSubview(imageWidget);
        widget.addSubview(textWidget);
        widget.setContentView(textWidget);

        imageView = imageWidget;
        textView = textWidget;
        _setAlignment();
    }
    view = widget;
}

void createWidget() {
    text = "";
    super.createWidget ();
}

NSAttributedString createString() {
    NSAttributedString attribStr = createString(text, null, foreground, (style & DWT.WRAP) is 0 ? style : 0, true, true);
    attribStr.autorelease();
    return attribStr;
}

NSFont defaultNSFont () {
    return display.textFieldFont;
}

void deregister () {
    super.deregister ();
    if (textView !is null) {
        display.removeWidget(textView);
        display.removeWidget(textView.cell());
    }
    if (imageView !is null) {
        display.removeWidget (imageView);
        display.removeWidget (imageView.cell());
    }
}

NSView eventView () {
    return (cast(NSBox)view).contentView();
}

/**
 * Returns a value which describes the position of the
 * text or image in the receiver. The value will be one of
 * <code>LEFT</code>, <code>RIGHT</code> or <code>CENTER</code>
 * unless the receiver is a <code>SEPARATOR</code> label, in
 * which case, <code>NONE</code> is returned.
 *
 * @return the alignment
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getAlignment () {
    checkWidget();
    if ((style & DWT.SEPARATOR) !is 0) return DWT.LEFT;
    if ((style & DWT.CENTER) !is 0) return DWT.CENTER;
    if ((style & DWT.RIGHT) !is 0) return DWT.RIGHT;
    return DWT.LEFT;
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
 * Returns the receiver's text, which will be an empty
 * string if it has never been set or if the receiver is
 * a <code>SEPARATOR</code> label.
 *
 * @return the receiver's text
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String getText () {
    checkWidget();
    if ((style & DWT.SEPARATOR) !is 0) return "";
    return text;
}

bool isDescribedByLabel () {
    return false;
}

void register () {
    super.register ();
    if (textView !is null) {
        display.addWidget (textView, this);
        display.addWidget (textView.cell(), this);
    }
    if (imageView !is null) {
        display.addWidget (imageView, this);
        display.addWidget (imageView.cell(), this);
    }
}

void releaseHandle () {
    super.releaseHandle ();
    if (textView !is null) textView.release();
    if (imageView !is null) imageView.release();
    textView = null;
    imageView = null;
}

/*
 * Remove "Labeled by" relations from the receiver.
 */
void removeRelation () {
    if (textView !is null) {
        textView.cell().accessibilitySetOverrideValue(null, OS.NSAccessibilityServesAsTitleForUIElementsAttribute);
    }
}

/**
 * Controls how text and images will be displayed in the receiver.
 * The argument should be one of <code>LEFT</code>, <code>RIGHT</code>
 * or <code>CENTER</code>.  If the receiver is a <code>SEPARATOR</code>
 * label, the argument is ignored and the alignment is not changed.
 *
 * @param alignment the new alignment
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setAlignment (int alignment) {
    checkWidget();
    if ((style & DWT.SEPARATOR) !is 0) return;
    if ((alignment & (DWT.LEFT | DWT.RIGHT | DWT.CENTER)) is 0) return;
    style &= ~(DWT.LEFT | DWT.RIGHT | DWT.CENTER);
    style |= alignment & (DWT.LEFT | DWT.RIGHT | DWT.CENTER);
    _setAlignment();
}

void updateBackground () {
    if ((style & DWT.SEPARATOR) !is 0) return;
    NSColor nsColor = null;
    if (backgroundImage !is null) {
        nsColor = NSColor.colorWithPatternImage(backgroundImage.handle);
    } else if (background !is null) {
        nsColor = NSColor.colorWithDeviceRed(background[0], background[1], background[2], background[3]);
    } else {
        nsColor = NSColor.clearColor();
    }
    (cast(NSBox)view).setFillColor(nsColor);
}

void _setAlignment() {
    if (image !is null) {
        if ((style & DWT.RIGHT) !is 0) imageView.setImageAlignment(OS.NSImageAlignRight);
        if ((style & DWT.LEFT) !is 0) imageView.setImageAlignment(OS.NSImageAlignLeft);
        if ((style & DWT.CENTER) !is 0) imageView.setImageAlignment(OS.NSImageAlignCenter);
    }
    if (text !is null) {
        NSCell cell = new NSCell(textView.cell());
        cell.setAttributedStringValue(createString());
    }
}

void setFont(NSFont font) {
    if (textView !is null) {
        NSCell cell = new NSCell(textView.cell());
        cell.setAttributedStringValue(createString());
        textView.setFont (font);
    }
}

void setForeground (Carbon.CGFloat [] color) {
    if ((style & DWT.SEPARATOR) !is 0) return;
    NSCell cell = new NSCell(textView.cell());
    cell.setAttributedStringValue(createString());
}

bool setTabItemFocus () {
    return false;
}

/**
 * Sets the receiver's image to the argument, which may be
 * null indicating that no image should be displayed.
 *
 * @param image the image to display on the receiver (may be null)
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
    if ((style & DWT.SEPARATOR) !is 0) return;
    if (image !is null && image.isDisposed ()) {
        error (DWT.ERROR_INVALID_ARGUMENT);
    }
    this.image = image;
    isImage = true;

    /*
     * Feature in Cocoa.  If the NSImage object being set into the view is
     * the same NSImage object that is already there then the new image is
     * not taken.  This results in the view's image not changing even if the
     * NSImage object's content has changed since it was last set into the
     * view.  The workaround is to temporarily set the view's image to null
     * so that the new image will then be taken.
     */
    if (image !is null) {
        NSImage current = imageView.image ();
        if (current !is null && current.id is image.handle.id) {
            imageView.setImage (null);
        }
    }
    imageView.setImage(image !is null ? image.handle : null);
    (cast(NSBox)view).setContentView(imageView);
}

/**
 * Sets the receiver's text.
 * <p>
 * This method sets the widget label.  The label may include
 * the mnemonic character and line delimiters.
 * </p>
 * <p>
 * Mnemonics are indicated by an '&amp;' that causes the next
 * character to be the mnemonic.  When the user presses a
 * key sequence that matches the mnemonic, focus is assigned
 * to the control that follows the label. On most platforms,
 * the mnemonic appears underlined but may be emphasised in a
 * platform specific manner.  The mnemonic indicator character
 * '&amp;' can be escaped by doubling it in the string, causing
 * a single '&amp;' to be displayed.
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
    // DWT extension: allow null for zero length string
    //if (string is null) error (DWT.ERROR_NULL_ARGUMENT);
    if ((style & DWT.SEPARATOR) !is 0) return;
    isImage = false;
    text = string;
    NSCell cell = new NSCell(textView.cell());
    cell.setAttributedStringValue(createString());
    (cast(NSBox)view).setContentView(textView);
}


}
