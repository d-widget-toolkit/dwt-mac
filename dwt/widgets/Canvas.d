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
module dwt.widgets.Canvas;







import dwt.DWT;
import dwt.dwthelper.utils;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSRange;
import dwt.internal.cocoa.NSEvent;
import dwt.internal.cocoa.NSImage;
import dwt.internal.cocoa.NSImageRep;
import dwt.internal.cocoa.NSColor;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.NSBezierPath;
import dwt.internal.cocoa.NSGraphicsContext;
import dwt.internal.cocoa.NSOpenGLContext;
import dwt.internal.cocoa.NSBitmapImageRep;
import dwt.internal.cocoa.NSCursor;
import dwt.internal.cocoa.OS;
import dwt.internal.cocoa.CGRect;
import dwt.internal.objc.cocoa.Cocoa;
import dwt.internal.c.Carbon;
import objc = dwt.internal.objc.runtime;
import dwt.widgets.Caret;
import dwt.widgets.Composite;
import dwt.widgets.Control;
import dwt.widgets.IME;
import dwt.graphics.Image;
import dwt.graphics.GC;
import dwt.graphics.GCData;
import dwt.graphics.Font;
import dwt.graphics.Rectangle;
/**
 * Instances of this class provide a surface for drawing
 * arbitrary graphics.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>(none)</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
 * </dl>
 * <p>
 * This class may be subclassed by custom control implementors
 * who are building controls that are <em>not</em> constructed
 * from aggregates of other controls. That is, they are either
 * painted using DWT graphics calls or are handled by native
 * methods.
 * </p>
 *
 * @see Composite
 * @see <a href="http://www.eclipse.org/swt/snippets/#canvas">Canvas snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">DWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class Canvas : Composite {
    Caret caret;
    IME ime;
    NSOpenGLContext context;

this () {
    /* Do nothing */
}

objc.id attributedSubstringFromRange (objc.id id, objc.SEL sel, NSRange range) {
    if (ime !is null) return ime.attributedSubstringFromRange (id, sel, range);
    return super.attributedSubstringFromRange(id, sel, range);
}

void sendFocusEvent(int type) {
    if (caret !is null) {
        if (type is DWT.FocusIn) {
            caret.setFocus();
        } else {
            caret.killFocus();
        }
    }
    super.sendFocusEvent(type);
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
 * </ul>
 *
 * @see DWT
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, style);
}

NSUInteger characterIndexForPoint (objc.id id, objc.SEL sel, NSPoint point) {
    if (ime !is null) return ime.characterIndexForPoint (id, sel, point);
    return super.characterIndexForPoint (id, sel, point);
}

/**
 * Fills the interior of the rectangle specified by the arguments,
 * with the receiver's background.
 *
 * @param gc the gc where the rectangle is to be filled
 * @param x the x coordinate of the rectangle to be filled
 * @param y the y coordinate of the rectangle to be filled
 * @param width the width of the rectangle to be filled
 * @param height the height of the rectangle to be filled
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
 * @since 3.2
 */
public void drawBackground (GC gc, int x, int y, int width, int height) {
    checkWidget ();
    if (gc is null) error (DWT.ERROR_NULL_ARGUMENT);
    if (gc.isDisposed ()) error (DWT.ERROR_INVALID_ARGUMENT);
    Control control = findBackgroundControl ();
    if (control !is null) {
        NSRect rect = NSRect();
        rect.x = x;
        rect.y = y;
        rect.width = width;
        rect.height = height;
        int imgHeight = -1;
        GCData data = gc.getGCData();
        if (data.image !is null) imgHeight =  data.image.getBounds().height;
        NSGraphicsContext context = gc.handle;
        if (data.flippedContext !is null) {
            NSGraphicsContext.static_saveGraphicsState();
            NSGraphicsContext.setCurrentContext(context);
        }
        control.fillBackground (view, context, rect, imgHeight);
        if (data.flippedContext !is null) {
            NSGraphicsContext.static_restoreGraphicsState();
        }
    } else {
        gc.fillRectangle (x, y, width, height);
    }
}
void drawBackground (objc.id id, NSGraphicsContext context, NSRect rect) {
    /* Do nothing */
}

void drawRect (objc.id id, objc.SEL sel, NSRect rect) {
    if (context !is null && context.view() is null) context.setView(view);
    super.drawRect(id, sel, rect);
}

void drawWidget (objc.id id, NSGraphicsContext context, NSRect rect) {
    if (id !is view.id) return;
    super.drawWidget (id, context, rect);
    if (caret is null) return;
    if (caret.isShowing) {
        Image image = caret.image;
        if (image !is null) {
            NSImage imageHandle = image.handle;
            NSImageRep imageRep = imageHandle.bestRepresentationForDevice(null);
            if (!imageRep.isKindOfClass(OS.class_NSBitmapImageRep)) return;
            NSBitmapImageRep rep = new NSBitmapImageRep(imageRep);
            CGRect destRect = CGRect ();
            destRect.origin.x = caret.x;
            destRect.origin.y = caret.y;
            NSSize size = imageHandle.size();
            destRect.size.width = size.width;
            destRect.size.height = size.height;
            ubyte* data = rep.bitmapData();
            NSInteger bpr = rep.bytesPerRow();
            CGBitmapInfo alphaInfo = rep.hasAlpha() ? OS.kCGImageAlphaFirst : OS.kCGImageAlphaNoneSkipFirst;
            CGDataProviderRef provider = OS.CGDataProviderCreateWithData(null, data, bpr * cast(int)size.height, null);
            CGColorSpaceRef colorspace = OS.CGColorSpaceCreateDeviceRGB();
            CGImageRef cgImage = OS.CGImageCreate(cast(int)size.width, cast(int)size.height, rep.bitsPerSample(), rep.bitsPerPixel(), bpr, colorspace, alphaInfo, provider, null, true, cast(CGColorRenderingIntent)0);
            OS.CGColorSpaceRelease(colorspace);
            OS.CGDataProviderRelease(provider);
            CGContext* ctx = cast(CGContext*)context.graphicsPort();
            OS.CGContextSaveGState(ctx);
            OS.CGContextScaleCTM (ctx, 1, -1);
            OS.CGContextTranslateCTM (ctx, 0, -(size.height + 2 * destRect.origin.y));
            OS.CGContextSetBlendMode (ctx, OS.kCGBlendModeDifference);
            OS.CGContextDrawImage (ctx, destRect, cgImage);
            OS.CGContextRestoreGState(ctx);
            OS.CGImageRelease(cgImage);
        } else {
            context.saveGraphicsState();
            context.setCompositingOperation(OS.NSCompositeXOR);
            NSRect drawRect = NSRect();
            drawRect.x = caret.x;
            drawRect.y = caret.y;
            drawRect.width = caret.width !is 0 ? caret.width : Caret.DEFAULT_WIDTH;
            drawRect.height = caret.height;
            context.setShouldAntialias(false);
            NSColor color = NSColor.colorWithDeviceRed(1, 1, 1, 1);
            color.set();
            NSBezierPath.fillRect(drawRect);
            context.restoreGraphicsState();
        }
    }
}

NSRect firstRectForCharacterRange (objc.id id, objc.SEL sel, NSRange range) {
    if (ime !is null) return ime.firstRectForCharacterRange (id, sel, range);
    return super.firstRectForCharacterRange (id, sel, range);
}

/**
 * Returns the caret.
 * <p>
 * The caret for the control is automatically hidden
 * and shown when the control is painted or resized,
 * when focus is gained or lost and when an the control
 * is scrolled.  To avoid drawing on top of the caret,
 * the programmer must hide and show the caret when
 * drawing in the window any other time.
 * </p>
 *
 * @return the caret for the receiver, may be null
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Caret getCaret () {
    checkWidget();
    return caret;
}

/**
 * Returns the IME.
 *
 * @return the IME
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public IME getIME () {
    checkWidget();
    return ime;
}

bool hasMarkedText (objc.id id, objc.SEL sel) {
    if (ime !is null) return ime.hasMarkedText (id, sel);
    return super.hasMarkedText (id, sel);
}

bool imeInComposition () {
    return ime !is null && ime.isInlineEnabled () && ime.startOffset !is -1;
}

bool insertText (objc.id id, objc.SEL sel, objc.id string) {
    if (ime !is null) {
        if (!ime.insertText (id, sel, string)) return false;
    }
    return super.insertText (id, sel, string);
}

bool isOpaque (objc.id id, objc.SEL sel) {
    if (context !is null) return true;
    return super.isOpaque(id, sel);
}

NSRange markedRange (objc.id id, objc.SEL sel) {
    if (ime !is null) return ime.markedRange (id, sel);
    return super.markedRange (id, sel);
}

void releaseChildren (bool destroy) {
    if (caret !is null) {
        caret.release (false);
        caret = null;
    }
    if (ime !is null) {
        ime.release (false);
        ime = null;
    }
    super.releaseChildren (destroy);
}

/**
 * Scrolls a rectangular area of the receiver by first copying
 * the source area to the destination and then causing the area
 * of the source which is not covered by the destination to
 * be repainted. Children that intersect the rectangle are
 * optionally moved during the operation. In addition, outstanding
 * paint events are flushed before the source area is copied to
 * ensure that the contents of the canvas are drawn correctly.
 *
 * @param destX the x coordinate of the destination
 * @param destY the y coordinate of the destination
 * @param x the x coordinate of the source
 * @param y the y coordinate of the source
 * @param width the width of the area
 * @param height the height of the area
 * @param all <code>true</code>if children should be scrolled, and <code>false</code> otherwise
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void scroll (int destX, int destY, int x, int y, int width, int height, bool all) {
    checkWidget();
    if (width <= 0 || height <= 0) return;
    int deltaX = destX - x, deltaY = destY - y;
    if (deltaX is 0 && deltaY is 0) return;
    if (!isDrawing ()) return;
    NSRect visibleRect = view.visibleRect();
    if (visibleRect.width <= 0 || visibleRect.height <= 0) return;
    bool isFocus = caret !is null && caret.isFocusCaret ();
    if (isFocus) caret.killFocus ();
    Rectangle clientRect = getClientArea ();
    Rectangle sourceRect = new Rectangle (x, y, width, height);
    if (sourceRect.intersects (clientRect)) {
        update (all);
    }
    Control control = findBackgroundControl ();
    bool redraw = control !is null && control.backgroundImage !is null;
    if (!redraw) redraw = isObscured ();
    if (redraw) {
        redrawWidget (view, x, y, width, height, false);
        redrawWidget (view, destX, destY, width, height, false);
    } else {
        NSRect damage = NSRect();
        damage.x = x;
        damage.y = y;
        damage.width = width;
        damage.height = height;
        NSPoint dest = NSPoint();
        dest.x = destX;
        dest.y = destY;

        view.lockFocus();
        OS.NSCopyBits(0, damage , dest);
        view.unlockFocus();

        bool disjoint = (destX + width < x) || (x + width < destX) || (destY + height < y) || (y + height < destY);
        if (disjoint) {
            view.setNeedsDisplayInRect(damage);
        } else {
            if (deltaX !is 0) {
                int newX = destX - deltaX;
                if (deltaX < 0) newX = destX + width;
                damage.x = newX;
                damage.width = Math.abs(deltaX);
                view.setNeedsDisplayInRect(damage);
            }
            if (deltaY !is 0) {
                int newY = destY - deltaY;
                if (deltaY < 0) newY = destY + height;
                damage.x = x;
                damage.y = newY;
                damage.width = width;
                damage.height =  Math.abs (deltaY);
                view.setNeedsDisplayInRect(damage);
            }
        }

        NSRect srcRect = NSRect();
        srcRect.x = sourceRect.x;
        srcRect.y = sourceRect.y;
        srcRect.width = sourceRect.width;
        srcRect.height = sourceRect.height;
        visibleRect = OS.NSIntersectionRect(visibleRect, srcRect);

        if (!OS.NSEqualRects(visibleRect, srcRect)) {
            if (srcRect.x !is visibleRect.x) {
                damage.x = srcRect.x + deltaX;
                damage.y = srcRect.y + deltaY;
                damage.width = visibleRect.x - srcRect.x;
                damage.height = srcRect.height;
                view.setNeedsDisplayInRect(damage);
            }
            if (visibleRect.x + visibleRect.width !is srcRect.x + srcRect.width) {
                damage.x = srcRect.x + visibleRect.width + deltaX;
                damage.y = srcRect.y + deltaY;
                damage.width = srcRect.width - visibleRect.width;
                damage.height = srcRect.height;
                view.setNeedsDisplayInRect(damage);
            }
            if (visibleRect.y !is srcRect.y) {
                damage.x = visibleRect.x + deltaX;
                damage.y = srcRect.y + deltaY;
                damage.width = visibleRect.width;
                damage.height = visibleRect.y - srcRect.y;
                view.setNeedsDisplayInRect(damage);
            }
            if (visibleRect.y + visibleRect.height !is srcRect.y + srcRect.height) {
                damage.x = visibleRect.x + deltaX;
                damage.y = visibleRect.y + visibleRect.height + deltaY;
                damage.width = visibleRect.width;
                damage.height = srcRect.y + srcRect.height - (visibleRect.y + visibleRect.height);
                view.setNeedsDisplayInRect(damage);
            }
        }
    }

    if (all) {
        Control [] children = _getChildren ();
        for (int i=0; i<children.length; i++) {
            Control child = children [i];
            Rectangle rect = child.getBounds ();
            if (Math.min(x + width, rect.x + rect.width) >= Math.max (x, rect.x) &&
                Math.min(y + height, rect.y + rect.height) >= Math.max (y, rect.y)) {
                    child.setLocation (rect.x + deltaX, rect.y + deltaY);
            }
        }
    }
    if (isFocus) caret.setFocus ();
}

NSRange selectedRange (objc.id id, objc.SEL sel) {
    if (ime !is null) return ime.selectedRange (id, sel);
    return super.selectedRange (id, sel);
}

bool sendKeyEvent (NSEvent nsEvent, int type) {
    if (caret !is null) NSCursor.setHiddenUntilMouseMoves (true);
    return super.sendKeyEvent (nsEvent, type);
}

/**
 * Sets the receiver's caret.
 * <p>
 * The caret for the control is automatically hidden
 * and shown when the control is painted or resized,
 * when focus is gained or lost and when an the control
 * is scrolled.  To avoid drawing on top of the caret,
 * the programmer must hide and show the caret when
 * drawing in the window any other time.
 * </p>
 * @param caret the new caret for the receiver, may be null
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the caret has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setCaret (Caret caret) {
    checkWidget();
    Caret newCaret = caret;
    Caret oldCaret = this.caret;
    this.caret = newCaret;
    if (hasFocus ()) {
        if (oldCaret !is null) oldCaret.killFocus ();
        if (newCaret !is null) {
            if (newCaret.isDisposed()) error(DWT.ERROR_INVALID_ARGUMENT);
            newCaret.setFocus ();
        }
    }
}

public void setFont (Font font) {
    checkWidget ();
    if (caret !is null) caret.setFont (font);
    super.setFont (font);
}

void setOpenGLContext(Object value) {
    context = cast(NSOpenGLContext)value;
}

/**
 * Sets the receiver's IME.
 *
 * @param ime the new IME for the receiver, may be null
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the IME has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public void setIME (IME ime) {
    checkWidget ();
    if (ime !is null && ime.isDisposed()) error(DWT.ERROR_INVALID_ARGUMENT);
    this.ime = ime;
}

bool setMarkedText_selectedRange (objc.id id, objc.SEL sel, objc.id string, NSRange range) {
    if (ime !is null) {
        if (!ime.setMarkedText_selectedRange (id, sel, string, range)) return false;
    }
    return super.setMarkedText_selectedRange (id, sel, string, range);
}

objc.id validAttributesForMarkedText (objc.id id, objc.SEL sel) {
    if (ime !is null) return ime.validAttributesForMarkedText (id, sel);
    return super.validAttributesForMarkedText(id, sel);
}

void updateOpenGLContext(objc.id id, objc.SEL sel, objc.id notification) {
    if (context !is null) (cast(NSOpenGLContext)context).update();
}

}
