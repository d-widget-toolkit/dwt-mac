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
module dwt.graphics.TextLayout;

import dwt.dwthelper.utils;
import dwt.dwthelper.System;

import dwt.DWT;
import dwt.DWTException;
import dwt.graphics.Color;
import dwt.graphics.Device;
import dwt.graphics.Font;
import dwt.graphics.FontMetrics;
import dwt.graphics.GC;
import dwt.graphics.GCData;
import dwt.graphics.GlyphMetrics;
import dwt.graphics.Point;
import dwt.graphics.Rectangle;
import dwt.graphics.Region;
import dwt.graphics.Resource;
import dwt.graphics.TextStyle;
import dwt.internal.C;
import Carbon = dwt.internal.c.Carbon;
import dwt.internal.Compatibility;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSAutoreleasePool;
import dwt.internal.cocoa.NSBezierPath;
import dwt.internal.cocoa.NSColor;
import dwt.internal.cocoa.NSFont;
import dwt.internal.cocoa.NSLayoutManager;
import dwt.internal.cocoa.NSMutableAttributedString;
import dwt.internal.cocoa.NSMutableParagraphStyle;
import dwt.internal.cocoa.NSNumber;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSRange;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSText;
import dwt.internal.cocoa.NSTextContainer;
import dwt.internal.cocoa.NSTextStorage;
import dwt.internal.cocoa.NSTextTab;
import dwt.internal.cocoa.NSThread;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import dwt.graphics.RGB;

import tango.text.convert.Format;

/**
 * <code>TextLayout</code> is a graphic object that represents
 * styled text.
 * <p>
 * Instances of this class provide support for drawing, cursor
 * navigation, hit testing, text wrapping, alignment, tab expansion
 * line breaking, etc.  These are aspects required for rendering internationalized text.
 * </p><p>
 * Application code must explicitly invoke the <code>TextLayout#dispose()</code>
 * method to release the operating system resources managed by each instance
 * when those instances are no longer required.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#textlayout">TextLayout, TextStyle snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">DWT Example: CustomControlExample, StyledText tab</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.0
 */
public final class TextLayout : Resource {

    alias Resource.init_ init_;

    NSTextStorage textStorage;
    NSLayoutManager layoutManager;
    NSTextContainer textContainer;
    Font font;
    String text;
    StyleItem[] styles;
    int spacing, ascent, descent, indent;
    bool justify;
    int alignment;
    int[] tabs;
    int[] segments;
    int wrapWidth;
    int orientation;

    int[] lineOffsets;
    NSRect[] lineBounds;

    static const int UNDERLINE_THICK = 1 << 16;
    static final RGB LINK_FOREGROUND = new RGB (0, 51, 153);
    int[] invalidOffsets;
    static const wchar LTR_MARK = '\u200E', RTL_MARK = '\u200F', ZWS = '\u200B';

    static class StyleItem {
        TextStyle style;
        int start;

        public String toString () {
            return Format("{}{}{}{}{}", "StyleItem {" , start , ", " , style , "}");
        }
    }

/**
 * Constructs a new instance of this class on the given device.
 * <p>
 * You must dispose the text layout when it is no longer required.
 * </p>
 *
 * @param device the device on which to allocate the text layout
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if device is null and there is no current device</li>
 * </ul>
 *
 * @see #dispose()
 */
public this (Device device) {
    super(device);
    wrapWidth = ascent = descent = -1;
    alignment = DWT.LEFT;
    orientation = DWT.LEFT_TO_RIGHT;
    text = "";
    styles = new StyleItem[2];
    styles[0] = new StyleItem();
    styles[1] = new StyleItem();
    init_();
}

void checkLayout() {
    if (isDisposed()) DWT.error(DWT.ERROR_GRAPHIC_DISPOSED);
}

float[] computePolyline(int left, int top, int right, int bottom) {
    int height = bottom - top; // can be any number
    int width = 2 * height; // must be even
    int peaks = Compatibility.ceil(right - left, width);
    if (peaks is 0 && right - left > 2) {
        peaks = 1;
    }
    int length_ = ((2 * peaks) + 1) * 2;
    if (length_ < 0) return new float[0];

    float[] coordinates = new float[length_];
    for (int i = 0; i < peaks; i++) {
        int index = 4 * i;
        coordinates[index] = left + (width * i);
        coordinates[index+1] = bottom;
        coordinates[index+2] = coordinates[index] + width / 2;
        coordinates[index+3] = top;
    }
    coordinates[length_-2] = left + (width * peaks);
    coordinates[length_-1] = bottom;
    return coordinates;
}


void computeRuns() {
    if (textStorage !is null) return;
    String segmentsText = getSegmentsText();
    NSString str = NSString.stringWith(segmentsText);
    textStorage = cast(NSTextStorage)(new NSTextStorage()).alloc().init();
    layoutManager = cast(NSLayoutManager)(new NSLayoutManager()).alloc().init();
    layoutManager.setBackgroundLayoutEnabled(NSThread.isMainThread());
    textContainer = cast(NSTextContainer)(new NSTextContainer()).alloc();
    NSSize size = NSSize();
    size.width = wrapWidth !is -1 ? wrapWidth : Float.MAX_VALUE;
    size.height = Float.MAX_VALUE;
    textContainer.initWithContainerSize(size);
    textStorage.addLayoutManager(layoutManager);
    layoutManager.addTextContainer(textContainer);

    /*
    * Bug in Cocoa. Adding attributes directly to a NSTextStorage causes
    * output to the console and eventually a segmentation fault when printing
    * on a thread other than the main thread. The fix is to add attributes to
    * a separate NSMutableAttributedString and add it to text storage when done.
    */
    NSMutableAttributedString attrStr = cast(NSMutableAttributedString)(new NSMutableAttributedString()).alloc();
    attrStr.id = attrStr.initWithString(str).id;
    attrStr.beginEditing();
    Font defaultFont = font !is null ? font : device.systemFont;
    NSRange range = NSRange();
    range.length = str.length();
    attrStr.addAttribute(OS.NSFontAttributeName, defaultFont.handle, range);
    defaultFont.addTraits(attrStr, range);
    //TODO ascend descent wrap
    NSMutableParagraphStyle paragraph = cast(NSMutableParagraphStyle)(new NSMutableParagraphStyle()).alloc().init();
    NSTextAlignment align_ = cast(NSTextAlignment)OS.NSLeftTextAlignment;
    if (justify) {
        align_ = cast(NSTextAlignment)OS.NSJustifiedTextAlignment;
    } else {
        switch (alignment) {
            case DWT.CENTER:
                align_ = cast(NSTextAlignment)OS.NSCenterTextAlignment;
                break;
            case DWT.RIGHT:
                align_ = cast(NSTextAlignment)OS.NSRightTextAlignment;
            default:
        }
    }
    paragraph.setAlignment(align_);
    paragraph.setLineSpacing(spacing);
    paragraph.setFirstLineHeadIndent(indent);
    paragraph.setLineBreakMode(cast(NSLineBreakMode)(wrapWidth !is -1 ? OS.NSLineBreakByWordWrapping : OS.NSLineBreakByClipping));
    paragraph.setTabStops(NSArray.array());
    if (tabs !is null) {
        int count = tabs.length;
        for (int i = 0, pos = 0; i < count; i++) {
            pos += tabs[i];
            NSTextTab tab = cast(NSTextTab)(new NSTextTab()).alloc();
            tab = tab.initWithType(cast(NSTextTabType)OS.NSLeftTabStopType, pos);
            paragraph.addTabStop(tab);
            tab.release();
        }
        int width = count - 2 >= 0 ? tabs[count - 1] - tabs[count - 2] : tabs[count - 1];
        paragraph.setDefaultTabInterval(width);
    }
    attrStr.addAttribute(OS.NSParagraphStyleAttributeName, paragraph, range);
    paragraph.release();
    NSUInteger textLength = str.length();
    for (int i = 0; i < styles.length - 1; i++) {
        StyleItem run = styles[i];
        if (run.style is null) continue;
        TextStyle style = run.style;
        range.location = textLength !is 0 ? translateOffset(run.start) : 0;
        range.length = translateOffset(styles[i + 1].start) - range.location;
        Font font = style.font;
        if (font !is null) {
            attrStr.addAttribute(OS.NSFontAttributeName, font.handle, range);
            font.addTraits(attrStr, range);
        }
        Color foreground = style.foreground;
        if (foreground !is null) {
            NSColor color = NSColor.colorWithDeviceRed(foreground.handle[0], foreground.handle[1], foreground.handle[2], 1);
            attrStr.addAttribute(OS.NSForegroundColorAttributeName, color, range);
        }
        Color background = style.background;
        if (background !is null) {
            NSColor color = NSColor.colorWithDeviceRed(background.handle[0], background.handle[1], background.handle[2], 1);
            attrStr.addAttribute(OS.NSBackgroundColorAttributeName, color, range);
        }
        if (style.strikeout) {
            attrStr.addAttribute(OS.NSStrikethroughStyleAttributeName, NSNumber.numberWithInt(OS.NSUnderlineStyleSingle), range);
            Color strikeColor = style.strikeoutColor;
            if (strikeColor !is null) {
                NSColor color = NSColor.colorWithDeviceRed(strikeColor.handle[0], strikeColor.handle[1], strikeColor.handle[2], 1);
                attrStr.addAttribute(OS.NSStrikethroughColorAttributeName, color, range);
            }
        }
        if (isUnderlineSupported(style)) {
            int underlineStyle = 0;
            switch (style.underlineStyle) {
                case DWT.UNDERLINE_SINGLE:
                    underlineStyle = OS.NSUnderlineStyleSingle;
                    break;
                case DWT.UNDERLINE_DOUBLE:
                    underlineStyle = OS.NSUnderlineStyleDouble;
                    break;
                case UNDERLINE_THICK:
                    underlineStyle = OS.NSUnderlineStyleThick;
                    break;
                case DWT.UNDERLINE_LINK: {
                    underlineStyle = OS.NSUnderlineStyleSingle;
                    if (foreground is null) {
                        NSColor color = NSColor.colorWithDeviceRed(LINK_FOREGROUND.red / 255f, LINK_FOREGROUND.green / 255f, LINK_FOREGROUND.blue / 255f, 1);
                        attrStr.addAttribute(OS.NSForegroundColorAttributeName, color, range);
                    }
                    break;
                }
                default:
            }
            if (underlineStyle !is 0) {
                attrStr.addAttribute(OS.NSUnderlineStyleAttributeName, NSNumber.numberWithInt(underlineStyle), range);
                Color underlineColor = style.underlineColor;
                if (underlineColor !is null) {
                    NSColor color = NSColor.colorWithDeviceRed(underlineColor.handle[0], underlineColor.handle[1], underlineColor.handle[2], 1);
                    attrStr.addAttribute(OS.NSUnderlineColorAttributeName, color, range);
                }
            }
        }
        if (style.rise !is 0) {
            attrStr.addAttribute(OS.NSBaselineOffsetAttributeName, NSNumber.numberWithInt(style.rise), range);
        }
        if (style.metrics !is null) {
            //TODO implement metrics
        }
    }
    attrStr.endEditing();
    textStorage.setAttributedString(attrStr);
    attrStr.release();

    textContainer.setLineFragmentPadding(0);
    layoutManager.glyphRangeForTextContainer(textContainer);

    int numberOfLines;
    NSUInteger numberOfGlyphs = layoutManager.numberOfGlyphs(), index;
    NSRangePointer rangePtr = cast(NSRangePointer) OS.malloc(NSRange.sizeof);
    NSRange lineRange = NSRange();
    for (numberOfLines = 0, index = 0; index < numberOfGlyphs; numberOfLines++){
        layoutManager.lineFragmentUsedRectForGlyphAtIndex(index, rangePtr, true);
        OS.memmove(&lineRange, rangePtr, NSRange.sizeof);
        index = lineRange.location + lineRange.length;
    }
    if (numberOfLines is 0) numberOfLines++;
    int[] offsets = new int[numberOfLines + 1];
    NSRect[] bounds = new NSRect[numberOfLines];
    for (numberOfLines = 0, index = 0; index < numberOfGlyphs; numberOfLines++){
        bounds[numberOfLines] = layoutManager.lineFragmentUsedRectForGlyphAtIndex(index, rangePtr, true);
        if (numberOfLines < bounds.length - 1) bounds[numberOfLines].height = bounds[numberOfLines].height - spacing;
        OS.memmove(&lineRange, rangePtr, NSRange.sizeof);
        offsets[numberOfLines] = cast(int)/*64*/lineRange.location;
        index = lineRange.location + lineRange.length;
    }
    if (numberOfLines is 0) {
        Font font = this.font !is null ? this.font : device.systemFont;
        NSFont nsFont = font.handle;
        bounds[0] = NSRect();
        bounds[0].height = Math.max(layoutManager.defaultLineHeightForFont(nsFont), ascent + descent);
    }
    OS.free(rangePtr);
    offsets[numberOfLines] = cast(int)/*64*/textStorage.length();
    this.lineOffsets = offsets;
    this.lineBounds = bounds;
}

void destroy() {
    freeRuns();
    font = null;
    text = null;
    styles = null;
}

/**
 * Draws the receiver's text using the specified GC at the specified
 * point.
 *
 * @param gc the GC to draw
 * @param x the x coordinate of the top left corner of the rectangular area where the text is to be drawn
 * @param y the y coordinate of the top left corner of the rectangular area where the text is to be drawn
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the gc is null</li>
 * </ul>
 */
public void draw(GC gc, int x, int y) {
    draw(gc, x, y, -1, -1, null, null);
}

/**
 * Draws the receiver's text using the specified GC at the specified
 * point.
 *
 * @param gc the GC to draw
 * @param x the x coordinate of the top left corner of the rectangular area where the text is to be drawn
 * @param y the y coordinate of the top left corner of the rectangular area where the text is to be drawn
 * @param selectionStart the offset where the selections starts, or -1 indicating no selection
 * @param selectionEnd the offset where the selections ends, or -1 indicating no selection
 * @param selectionForeground selection foreground, or NULL to use the system default color
 * @param selectionBackground selection background, or NULL to use the system default color
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the gc is null</li>
 * </ul>
 */
public void draw(GC gc, int x, int y, int selectionStart, int selectionEnd, Color selectionForeground, Color selectionBackground) {
    draw(gc, x, y, selectionStart, selectionEnd, selectionForeground, selectionBackground, 0);
}

/**
 * Draws the receiver's text using the specified GC at the specified
 * point.
 * <p>
 * The parameter <code>flags</code> can include one of <code>DWT.DELIMITER_SELECTION</code>
 * or <code>DWT.FULL_SELECTION</code> to specify the selection behavior on all lines except
 * for the last line, and can also include <code>DWT.LAST_LINE_SELECTION</code> to extend
 * the specified selection behavior to the last line.
 * </p>
 * @param gc the GC to draw
 * @param x the x coordinate of the top left corner of the rectangular area where the text is to be drawn
 * @param y the y coordinate of the top left corner of the rectangular area where the text is to be drawn
 * @param selectionStart the offset where the selections starts, or -1 indicating no selection
 * @param selectionEnd the offset where the selections ends, or -1 indicating no selection
 * @param selectionForeground selection foreground, or NULL to use the system default color
 * @param selectionBackground selection background, or NULL to use the system default color
 * @param flags drawing options
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the gc is null</li>
 * </ul>
 *
 * @since 3.3
 */
public void draw(GC gc, int x, int y, int selectionStart, int selectionEnd, Color selectionForeground, Color selectionBackground, int flags) {
    checkLayout ();
    if (gc is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (gc.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    if (selectionForeground !is null && selectionForeground.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    if (selectionBackground !is null && selectionBackground.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    NSAutoreleasePool pool = gc.checkGC(GC.CLIPPING | GC.TRANSFORM | GC.FOREGROUND);
    try {
        computeRuns();
        int length = translateOffset(text.length);
        if (length is 0 && flags is 0) return;
        gc.handle.saveGraphicsState();
        NSPoint pt = NSPoint();
        pt.x = x;
        pt.y = y;
        NSRange range = NSRange();
        NSUInteger numberOfGlyphs = layoutManager.numberOfGlyphs();
        if (numberOfGlyphs > 0) {
            range.location = 0;
            range.length = numberOfGlyphs;
            layoutManager.drawBackgroundForGlyphRange(range, pt);
        }
        bool hasSelection = selectionStart <= selectionEnd && selectionStart !is -1 && selectionEnd !is -1;
        if (hasSelection || (flags & DWT.LAST_LINE_SELECTION) !is 0) {
            if (selectionBackground is null) selectionBackground = device.getSystemColor(DWT.COLOR_LIST_SELECTION);
            NSColor selectionColor = NSColor.colorWithDeviceRed(selectionBackground.handle[0], selectionBackground.handle[1], selectionBackground.handle[2], selectionBackground.handle[3]);
            NSBezierPath path = NSBezierPath.bezierPath();
            NSRect rect = NSRect();
            if (hasSelection) {
                NSUInteger pRectCount;
                range.location = translateOffset(selectionStart);
                range.length = translateOffset(selectionEnd - selectionStart + 1);
                NSRectArray pArray = layoutManager.rectArrayForCharacterRange(range, range, textContainer, &pRectCount);
                NSUInteger rectCount = pRectCount;
                for (NSUInteger k = 0; k < rectCount; k++, pArray += NSRect.sizeof) {
                    OS.memmove(&rect, pArray, NSRect.sizeof);
                    fixRect(rect);
                    rect.x = rect.x + pt.x;
                    rect.y = rect.y + pt.y;
                    rect.height = Math.max(rect.height, ascent + descent);
                    path.appendBezierPathWithRect(rect);
                }
            }
            //TODO draw full selection for wrapped text
            if ((flags & DWT.LAST_LINE_SELECTION) !is 0) {
                NSRect bounds = lineBounds[lineBounds.length - 1];
                rect.x = pt.x + bounds.x + bounds.width;
                rect.y = y + bounds.y;
                rect.width = (flags & DWT.FULL_SELECTION) !is 0 ? 0x7fffffff : bounds.height / 3;
                rect.height = Math.max(bounds.height, ascent + descent);
                path.appendBezierPathWithRect(rect);
            }
            selectionColor.setFill();
            path.fill();
        }
        if (numberOfGlyphs > 0) {
            range.location = 0;
            range.length = numberOfGlyphs;
            Carbon.CGFloat [] fg = gc.data.foreground;
            bool defaultFg = fg[0] is 0 && fg[1] is 0 && fg[2] is 0 && fg[3] is 1;
            if (!defaultFg) {
                for (int i = 0; i < styles.length - 1; i++) {
                    StyleItem run = styles[i];
                    if (run.style !is null && run.style.foreground !is null) continue;
                    if (run.style !is null && run.style.underline && run.style.underlineStyle is DWT.UNDERLINE_LINK) continue;
                    range.location = length !is 0 ? translateOffset(run.start) : 0;
                    range.length = translateOffset(styles[i + 1].start) - range.location;
                    layoutManager.addTemporaryAttribute(OS.NSForegroundColorAttributeName, gc.data.fg, range);
                }
            }
            range.location = 0;
            range.length = numberOfGlyphs;
            layoutManager.drawGlyphsForGlyphRange(range, pt);
            if (!defaultFg) {
                range.location = 0;
                range.length = length;
                layoutManager.removeTemporaryAttribute(OS.NSForegroundColorAttributeName, range);
            }
            NSPoint point = NSPoint();
            for (int j = 0; j < styles.length; j++) {
                StyleItem run = styles[j];
                TextStyle style = run.style;
                if (style is null) continue;
                bool drawUnderline = style.underline && !isUnderlineSupported(style);
                drawUnderline = drawUnderline && (j + 1 is styles.length || !style.isAdherentUnderline(styles[j + 1].style));
                bool drawBorder = style.borderStyle !is DWT.NONE;
                drawBorder = drawBorder && (j + 1 is styles.length || !style.isAdherentBorder(styles[j + 1].style));
                if (!drawUnderline && !drawBorder) continue;
                int end = j + 1 < styles.length ? translateOffset(styles[j + 1].start - 1) : length;
                for (int i = 0; i < lineOffsets.length - 1; i++) {
                    int lineStart = untranslateOffset(lineOffsets[i]);
                    int lineEnd = untranslateOffset(lineOffsets[i + 1] - 1);
                    if (drawUnderline) {
                        int start = run.start;
                        for (int k = j; k > 0 && style.isAdherentUnderline(styles[k - 1].style); k--) {
                            start = styles[k - 1].start;
                        }
                        start = translateOffset(start);
                        if (!(start > lineEnd || end < lineStart)) {
                            range.location = Math.max(lineStart, start);
                            range.length = Math.min(lineEnd, end) + 1 - range.location;
                            if (range.length > 0) {
                                auto pRectCount = cast(uint*)OS.malloc(C.PTR_SIZEOF);
                                NSRectArray pArray = layoutManager.rectArrayForCharacterRange(range, range, textContainer, pRectCount);
                                auto rectCount = *pRectCount;
                                NSRect rect = NSRect();
                                gc.handle.saveGraphicsState();
                                Carbon.CGFloat baseline = layoutManager.typesetter().baselineOffsetInLayoutManager(layoutManager, lineStart);
                                Carbon.CGFloat [] color = null;
                                if (style.underlineColor !is null) color = style.underlineColor.handle;
                                if (color is null && style.foreground !is null) color = style.foreground.handle;
                                if (color !is null) {
                                    NSColor.colorWithDeviceRed(color[0], color[1], color[2], color[3]).setStroke();
                                }
                                for (NSUInteger k = 0; k < rectCount; k++, pArray += NSRect.sizeof) {
                                    OS.memmove(&rect, pArray, NSRect.sizeof);
                                    fixRect(rect);
                                    Carbon.CGFloat underlineX = pt.x + rect.x;
                                    Carbon.CGFloat underlineY = pt.y + rect.y + rect.height - baseline + 1;
                                    NSBezierPath path = NSBezierPath.bezierPath();
                                    switch (style.underlineStyle) {
                                        case DWT.UNDERLINE_ERROR: {
                                            path.setLineWidth(2f);
                                            path.setLineCapStyle(cast(NSLineCapStyle)OS.NSRoundLineCapStyle);
                                            path.setLineJoinStyle(cast(NSLineJoinStyle)OS.NSRoundLineJoinStyle);
                                            path.setLineDash([1.0f, 3.0f].ptr, 2, cast(Carbon.CGFloat) 0);
                                            point.x = underlineX;
                                            point.y = underlineY + 0.5f;
                                            path.moveToPoint(point);
                                            point.x = underlineX + rect.width;
                                            point.y = underlineY + 0.5f;
                                            path.lineToPoint(point);
                                            break;
                                        }
                                        case DWT.UNDERLINE_SQUIGGLE: {
                                            gc.handle.setShouldAntialias(false);
                                            path.setLineWidth(1.0f);
                                            path.setLineCapStyle(cast(NSLineCapStyle)OS.NSButtLineCapStyle);
                                            path.setLineJoinStyle(cast(NSLineJoinStyle)OS.NSMiterLineJoinStyle);
                                            Carbon.CGFloat lineBottom = pt.y + rect.y + rect.height;
                                            float squigglyThickness = 1;
                                            float squigglyHeight = 2 * squigglyThickness;
                                            Carbon.CGFloat squigglyY = Math.min(underlineY - squigglyHeight / 2, lineBottom - squigglyHeight - 1);
                                            float[] points = computePolyline(cast(int)underlineX, cast(int)squigglyY, cast(int)(underlineX + rect.width), cast(int)(squigglyY + squigglyHeight));
                                            point.x = points[0] + 0.5f;
                                            point.y = points[1] + 0.5f;
                                            path.moveToPoint(point);
                                            for (int p = 2; p < points.length; p+=2) {
                                                point.x = points[p] + 0.5f;
                                                point.y = points[p+1] + 0.5f;
                                                path.lineToPoint(point);
                                            }
                                            break;
                                        }
                                        default:
                                    }
                                    path.stroke();
                                }
                                gc.handle.restoreGraphicsState();
                            }
                        }
                    }
                    if (drawBorder) {
                        int start = run.start;
                        for (int k = j; k > 0 && style.isAdherentBorder(styles[k - 1].style); k--) {
                            start = styles[k - 1].start;
                        }
                        start = translateOffset(start);
                        if (!(start > lineEnd || end < lineStart)) {
                            range.location = Math.max(lineStart, start);
                            range.length = Math.min(lineEnd, end) + 1 - range.location;
                            if (range.length > 0) {
                                uint* pRectCount;
                                NSRectArray pArray = layoutManager.rectArrayForCharacterRange(range, range, textContainer, pRectCount);
                                NSUInteger rectCount = *pRectCount;
                                NSRect rect = NSRect();
                                gc.handle.saveGraphicsState();
                                Carbon.CGFloat [] color = null;
                                if (style.borderColor !is null) color = style.borderColor.handle;
                                if (color is null && style.foreground !is null) color = style.foreground.handle;
                                if (color !is null) {
                                    NSColor.colorWithDeviceRed(color[0], color[1], color[2], color[3]).setStroke();
                                }
                                int width = 1;
                                Carbon.CGFloat[] dashes = null;
                                switch (style.borderStyle) {
                                    case DWT.BORDER_SOLID:  break;
                                    case DWT.BORDER_DASH: dashes = width !is 0 ? GC.LINE_DASH : GC.LINE_DASH_ZERO; break;
                                    case DWT.BORDER_DOT: dashes = width !is 0 ? GC.LINE_DOT : GC.LINE_DOT_ZERO; break;
                                default:
                                }
                                Carbon.CGFloat [] lengths = null;
                                if (dashes !is null) {
                                    lengths = new Carbon.CGFloat[dashes.length];
                                    for (int k = 0; k < lengths.length; k++) {
                                        lengths[k] = width is 0 ? dashes[k] : dashes[k] * width;
                                    }
                                }
                                for (NSUInteger k = 0; k < rectCount; k++, pArray += NSRect.sizeof) {
                                    OS.memmove(&rect, pArray, NSRect.sizeof);
                                    fixRect(rect);
                                    rect.x = rect.x + (pt.x + 0.5f);
                                    rect.y = rect.y + (pt.y + 0.5f);
                                    rect.width = rect.width - 0.5f;
                                    rect.height = rect.height - 0.5f;
                                    NSBezierPath path = NSBezierPath.bezierPath();
                                    path.setLineDash(lengths.ptr, lengths !is null ? lengths.length : 0, 0);
                                    path.appendBezierPathWithRect(rect);
                                    path.stroke();
                                }
                                gc.handle.restoreGraphicsState();
                            }
                        }
                    }
                }
            }
        }
        gc.handle.restoreGraphicsState();
    } finally {
        gc.uncheckGC(pool);
    }
}

void fixRect(NSRect rect) {
    for (int j = 0; j < lineBounds.length; j++) {
        NSRect line = lineBounds[j];
        if (line.y <= rect.y && rect.y < line.y + line.height) {
            if (rect.x + rect.width > line.x + line.width) {
                rect.width = line.x + line.width - rect.x;
            }
        }
    }
}

void freeRuns() {
    if (textStorage is null) return;
    if (textStorage !is null) {
        textStorage.release();
    }
    if (layoutManager !is null) {
        layoutManager.release();
    }
    if (textContainer !is null) {
        textContainer.release();
    }
    textStorage = null;
    layoutManager = null;
    textContainer = null;
}

/**
 * Returns the receiver's horizontal text alignment, which will be one
 * of <code>DWT.LEFT</code>, <code>DWT.CENTER</code> or
 * <code>DWT.RIGHT</code>.
 *
 * @return the alignment used to positioned text horizontally
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int getAlignment() {
    checkLayout();
    return alignment;
}

/**
 * Returns the ascent of the receiver.
 *
 * @return the ascent
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getDescent()
 * @see #setDescent(int)
 * @see #setAscent(int)
 * @see #getLineMetrics(int)
 */
public int getAscent () {
    checkLayout();
    return ascent;
}

/**
 * Returns the bounds of the receiver. The width returned is either the
 * width of the longest line or the width set using {@link TextLayout#setWidth(int)}.
 * To obtain the text bounds of a line use {@link TextLayout#getLineBounds(int)}.
 *
 * @return the bounds of the receiver
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #setWidth(int)
 * @see #getLineBounds(int)
 */
public Rectangle getBounds() {
    checkLayout();
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        computeRuns();
        NSRect rect = layoutManager.usedRectForTextContainer(textContainer);
        if (wrapWidth !is -1) rect.width = wrapWidth;
        if (text.length is 0) {
            Font font = this.font !is null ? this.font : device.systemFont;
            NSFont nsFont = font.handle;
            rect.height = layoutManager.defaultLineHeightForFont(nsFont);
        }
        rect.height = Math.max(rect.height, ascent + descent) + spacing;
        return new Rectangle(0, 0, cast(int)Math.ceil(rect.width), cast(int)Math.ceil(rect.height));
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Returns the bounds for the specified range of characters. The
 * bounds is the smallest rectangle that encompasses all characters
 * in the range. The start and end offsets are inclusive and will be
 * clamped if out of range.
 *
 * @param start the start offset
 * @param end the end offset
 * @return the bounds of the character range
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Rectangle getBounds(int start, int end) {
    checkLayout();
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        computeRuns();
        int length = text.length;
        if (length is 0) return new Rectangle(0, 0, 0, 0);
        if (start > end) return new Rectangle(0, 0, 0, 0);
        start = Math.min(Math.max(0, start), length - 1);
        end = Math.min(Math.max(0, end), length - 1);
        start = translateOffset(start);
        end = translateOffset(end);
        NSRange range = NSRange();
        range.location = start;
        range.length = end - start + 1;
        uint* pRectCount;
        NSRectArray pArray = layoutManager.rectArrayForCharacterRange(range, range, textContainer, pRectCount);
        NSUInteger rectCount = *pRectCount;
        NSRect rect = NSRect();
        int left = 0x7FFFFFFF, right = 0;
        int top = 0x7FFFFFFF, bottom = 0;
        for (NSUInteger i = 0; i < rectCount; i++, pArray += NSRect.sizeof) {
            OS.memmove(&rect, pArray, NSRect.sizeof);
            fixRect(rect);
            left = Math.min(left, cast(int)rect.x);
            right = Math.max(right, cast(int)Math.ceil(rect.x + rect.width));
            top = Math.min(top, cast(int)rect.y);
            bottom = Math.max(bottom, cast(int)Math.ceil(rect.y + rect.height));
        }
        return new Rectangle(left, top, right - left, bottom - top);
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Returns the descent of the receiver.
 *
 * @return the descent
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getAscent()
 * @see #setAscent(int)
 * @see #setDescent(int)
 * @see #getLineMetrics(int)
 */
public int getDescent () {
    checkLayout();
    return descent;
}

/**
 * Returns the default font currently being used by the receiver
 * to draw and measure text.
 *
 * @return the receiver's font
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Font getFont () {
    checkLayout();
    return font;
}

/**
* Returns the receiver's indent.
*
* @return the receiver's indent
*
* @exception DWTException <ul>
*    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
* </ul>
*
* @since 3.2
*/
public int getIndent () {
    checkLayout();
    return indent;
}

/**
* Returns the receiver's justification.
*
* @return the receiver's justification
*
* @exception DWTException <ul>
*    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
* </ul>
*
* @since 3.2
*/
public bool getJustify () {
    checkLayout();
    return justify;
}

/**
 * Returns the embedding level for the specified character offset. The
 * embedding level is usually used to determine the directionality of a
 * character in bidirectional text.
 *
 * @param offset the character offset
 * @return the embedding level
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the character offset is out of range</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 */
public int getLevel(int offset) {
    checkLayout();
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        computeRuns();
        int length = text.length;
        if (!(0 <= offset && offset <= length)) DWT.error(DWT.ERROR_INVALID_RANGE);
        offset = translateOffset(offset);
        NSUInteger glyphOffset = layoutManager.glyphIndexForCharacterAtIndex(offset);
        NSRange range  = NSRange();
        range.location = glyphOffset;
        range.length = 1;
        ubyte bidiLevels;
        NSUInteger result = layoutManager.getGlyphsInRange(range, null, null, null, null, &bidiLevels);
        return bidiLevels;
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Returns the line offsets.  Each value in the array is the
 * offset for the first character in a line except for the last
 * value, which contains the length of the text.
 *
 * @return the line offsets
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int[] getLineOffsets() {
    checkLayout ();
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        computeRuns();
        int[] offsets = new int[lineOffsets.length];
        for (int i = 0; i < offsets.length; i++) {
            offsets[i] = untranslateOffset(lineOffsets[i]);
        }
        return offsets;
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Returns the index of the line that contains the specified
 * character offset.
 *
 * @param offset the character offset
 * @return the line index
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the character offset is out of range</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int getLineIndex(int offset) {
    checkLayout ();
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        computeRuns();
        int length = text.length;
        if (!(0 <= offset && offset <= length)) DWT.error(DWT.ERROR_INVALID_RANGE);
        offset = translateOffset(offset);
        for (int line=0; line<lineOffsets.length - 1; line++) {
            if (lineOffsets[line + 1] > offset) {
                return line;
            }
        }
        return lineBounds.length - 1;
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Returns the bounds of the line for the specified line index.
 *
 * @param lineIndex the line index
 * @return the line bounds
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the line index is out of range</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Rectangle getLineBounds(int lineIndex) {
    checkLayout();
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        computeRuns();
        if (!(0 <= lineIndex && lineIndex < lineBounds.length)) DWT.error(DWT.ERROR_INVALID_RANGE);
        NSRect rect = lineBounds[lineIndex];
        int height =  Math.max(cast(int)Math.ceil(rect.height), ascent + descent);
        return new Rectangle(cast(int)rect.x, cast(int)rect.y, cast(int)Math.ceil(rect.width), height);
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Returns the receiver's line count. This includes lines caused
 * by wrapping.
 *
 * @return the line count
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int getLineCount() {
    checkLayout ();
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        computeRuns();
        return lineOffsets.length - 1;
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Returns the font metrics for the specified line index.
 *
 * @param lineIndex the line index
 * @return the font metrics
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the line index is out of range</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public FontMetrics getLineMetrics (int lineIndex) {
    checkLayout ();
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        computeRuns();
        int lineCount = getLineCount();
        if (!(0 <= lineIndex && lineIndex < lineCount)) DWT.error(DWT.ERROR_INVALID_RANGE);
        int length = text.length;
        if (length is 0) {
            Font font = this.font !is null ? this.font : device.systemFont;
            NSFont nsFont = font.handle;
            int ascent = cast(int)(0.5f + nsFont.ascender());
            int descent = cast(int)(0.5f + (-nsFont.descender() + nsFont.leading()));
            ascent = Math.max(ascent, this.ascent);
            descent = Math.max(descent, this.descent);
            return FontMetrics.cocoa_new(ascent, descent, 0, 0, ascent + descent);
        }
        Rectangle rect = getLineBounds(lineIndex);
        int baseline = cast(int)layoutManager.typesetter().baselineOffsetInLayoutManager(layoutManager, getLineOffsets()[lineIndex]);
        return FontMetrics.cocoa_new(rect.height - baseline, baseline, 0, 0, rect.height);
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Returns the location for the specified character offset. The
 * <code>trailing</code> argument indicates whether the offset
 * corresponds to the leading or trailing edge of the cluster.
 *
 * @param offset the character offset
 * @param trailing the trailing flag
 * @return the location of the character offset
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getOffset(Point, int[])
 * @see #getOffset(int, int, int[])
 */
public Point getLocation(int offset, bool trailing) {
    checkLayout();
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        computeRuns();
        int length = text.length;
        if (!(0 <= offset && offset <= length)) DWT.error(DWT.ERROR_INVALID_RANGE);
        if (length is 0) return new Point(0, 0);
        offset = translateOffset(offset);
        NSUInteger glyphIndex = layoutManager.glyphIndexForCharacterAtIndex(offset);
        NSRect rect = layoutManager.lineFragmentUsedRectForGlyphAtIndex(glyphIndex, null);
        NSPoint point = layoutManager.locationForGlyphAtIndex(glyphIndex);
        if (trailing) {
            NSRange range = NSRange();
            range.location = offset;
            range.length = 1;
            uint rectCount;
            NSRectArray pArray = layoutManager.rectArrayForCharacterRange(range, range, textContainer, &rectCount);
            if (rectCount > 0) {
                NSRect bounds = NSRect();
                OS.memmove(&bounds, pArray, NSRect.sizeof);
                fixRect(bounds);
                point.x += bounds.width;
            }
        }
        return new Point(cast(int)point.x, cast(int)rect.y);
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Returns the next offset for the specified offset and movement
 * type.  The movement is one of <code>DWT.MOVEMENT_CHAR</code>,
 * <code>DWT.MOVEMENT_CLUSTER</code>, <code>DWT.MOVEMENT_WORD</code>,
 * <code>DWT.MOVEMENT_WORD_END</code> or <code>DWT.MOVEMENT_WORD_START</code>.
 *
 * @param offset the start offset
 * @param movement the movement type
 * @return the next offset
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the offset is out of range</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getPreviousOffset(int, int)
 */
public int getNextOffset (int offset, int movement) {
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        return _getOffset(offset, movement, true);
    } finally {
        if (pool !is null) pool.release();
    }
}

int _getOffset (int offset, int movement, bool forward) {
    checkLayout();
    computeRuns();
    int length = text.length;
    if (!(0 <= offset && offset <= length)) DWT.error(DWT.ERROR_INVALID_RANGE);
    if (length is 0) return 0;
    offset = translateOffset(offset);
    length = translateOffset(length);
    switch (movement) {
        case DWT.MOVEMENT_CLUSTER://TODO cluster
        case DWT.MOVEMENT_CHAR: {
            bool invalid = false;
            do {
                int newOffset = offset;
                if (forward) {
                    if (newOffset < length) newOffset++;
                } else {
                    if (newOffset > 0) newOffset--;
                }
                if (newOffset is offset) break;
                offset = newOffset;
                invalid = false;
                if (invalidOffsets !is null) {
                    for (int i = 0; i < invalidOffsets.length; i++) {
                        if (offset is invalidOffsets[i]) {
                            invalid = true;
                            break;
                        }
                    }
                }
            } while (invalid);
            return untranslateOffset(offset);
        }
        case DWT.MOVEMENT_WORD: {
            return untranslateOffset(cast(int)/*64*/textStorage.nextWordFromIndex(offset, forward));
        }
        case DWT.MOVEMENT_WORD_END: {
            NSRange range = textStorage.doubleClickAtIndex(length is offset ? length - 1 : offset);
            return untranslateOffset(cast(int)/*64*/(range.location + range.length));
        }
        case DWT.MOVEMENT_WORD_START: {
            NSRange range = textStorage.doubleClickAtIndex(length is offset ? length - 1 : offset);
            return untranslateOffset(cast(int)/*64*/range.location);
        }
    }
    return untranslateOffset(offset);
}

/**
 * Returns the character offset for the specified point.
 * For a typical character, the trailing argument will be filled in to
 * indicate whether the point is closer to the leading edge (0) or
 * the trailing edge (1).  When the point is over a cluster composed
 * of multiple characters, the trailing argument will be filled with the
 * position of the character in the cluster that is closest to
 * the point.
 *
 * @param point the point
 * @param trailing the trailing buffer
 * @return the character offset
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the trailing length is less than <code>1</code></li>
 *    <li>ERROR_NULL_ARGUMENT - if the point is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getLocation(int, bool)
 */
public int getOffset(Point point, int[] trailing) {
    checkLayout();
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        computeRuns();
        if (point is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
        return getOffset(point.x, point.y, trailing);
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Returns the character offset for the specified point.
 * For a typical character, the trailing argument will be filled in to
 * indicate whether the point is closer to the leading edge (0) or
 * the trailing edge (1).  When the point is over a cluster composed
 * of multiple characters, the trailing argument will be filled with the
 * position of the character in the cluster that is closest to
 * the point.
 *
 * @param x the x coordinate of the point
 * @param y the y coordinate of the point
 * @param trailing the trailing buffer
 * @return the character offset
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the trailing length is less than <code>1</code></li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getLocation(int, bool)
 */
public int getOffset(int x, int y, int[] trailing) {
    checkLayout();
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        computeRuns();
        if (trailing !is null && trailing.length < 1) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
        int length = text.length;
        if (length is 0) return 0;
        NSPoint pt = NSPoint();
        pt.x = x;
        pt.y = y;
        Carbon.CGFloat partialFration;
        NSUInteger glyphIndex = layoutManager.glyphIndexForPoint(pt, textContainer, &partialFration);
        NSUInteger offset = layoutManager.characterIndexForGlyphAtIndex(glyphIndex);
    if (trailing !is null) trailing[0] = cast(int) Math.round(partialFration);
        return Math.min(untranslateOffset(cast(int)/*64*/offset), length - 1);
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Returns the orientation of the receiver.
 *
 * @return the orientation style
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int getOrientation() {
    checkLayout();
    return orientation;
}

/**
 * Returns the previous offset for the specified offset and movement
 * type.  The movement is one of <code>DWT.MOVEMENT_CHAR</code>,
 * <code>DWT.MOVEMENT_CLUSTER</code> or <code>DWT.MOVEMENT_WORD</code>,
 * <code>DWT.MOVEMENT_WORD_END</code> or <code>DWT.MOVEMENT_WORD_START</code>.
 *
 * @param offset the start offset
 * @param movement the movement type
 * @return the previous offset
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the offset is out of range</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getNextOffset(int, int)
 */
public int getPreviousOffset (int index, int movement) {
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        return _getOffset(index, movement, false);
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Gets the ranges of text that are associated with a <code>TextStyle</code>.
 *
 * @return the ranges, an array of offsets representing the start and end of each
 * text style.
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getStyles()
 *
 * @since 3.2
 */
public int[] getRanges () {
    checkLayout();
    int[] result = new int[styles.length * 2];
    int count = 0;
    for (int i=0; i<styles.length - 1; i++) {
        if (styles[i].style !is null) {
            result[count++] = styles[i].start;
            result[count++] = styles[i + 1].start - 1;
        }
    }
    if (count !is result.length) {
        int[] newResult = new int[count];
        System.arraycopy(result, 0, newResult, 0, count);
        result = newResult;
    }
    return result;
}

/**
 * Returns the text segments offsets of the receiver.
 *
 * @return the text segments offsets
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int[] getSegments() {
    checkLayout();
    return segments;
}

String getSegmentsText() {
    if (segments is null) return text;
    int nSegments = segments.length;
    if (nSegments <= 1) return text;
    int length = text.length;
    if (length is 0) return text;
    if (nSegments is 2) {
        if (segments[0] is 0 && segments[1] is length) return text;
    }
    invalidOffsets = new int[nSegments];
    char[] oldChars = new char[length];
    text.getChars(0, length, oldChars, 0);
    char[] newChars = new char[length + nSegments];
    int charCount = 0, segmentCount = 0;
    wchar separator = getOrientation() is DWT.RIGHT_TO_LEFT ? RTL_MARK : LTR_MARK;
    while (charCount < length) {
        if (segmentCount < nSegments && charCount is segments[segmentCount]) {
            invalidOffsets[segmentCount] = charCount + segmentCount;
            newChars[charCount + segmentCount++] = separator;
        } else {
            newChars[charCount + segmentCount] = oldChars[charCount++];
        }
    }
    if (segmentCount < nSegments) {
        invalidOffsets[segmentCount] = charCount + segmentCount;
        segments[segmentCount] = charCount;
        newChars[charCount + segmentCount++] = separator;
    }
    if (segmentCount !is nSegments) {
        int[] tmp = new int [segmentCount];
        System.arraycopy(invalidOffsets, 0, tmp, 0, segmentCount);
        invalidOffsets = tmp;
    }
    return new_String(newChars, 0, Math.min(charCount + segmentCount, newChars.length));
}

/**
 * Returns the line spacing of the receiver.
 *
 * @return the line spacing
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int getSpacing () {
    checkLayout();
    return spacing;
}

/**
 * Gets the style of the receiver at the specified character offset.
 *
 * @param offset the text offset
 * @return the style or <code>null</code> if not set
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the character offset is out of range</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public TextStyle getStyle (int offset) {
    checkLayout();
    int length = text.length;
    if (!(0 <= offset && offset < length)) DWT.error(DWT.ERROR_INVALID_RANGE);
    for (int i=1; i<styles.length; i++) {
        StyleItem item = styles[i];
        if (item.start > offset) {
            return styles[i - 1].style;
        }
    }
    return null;
}

/**
 * Gets all styles of the receiver.
 *
 * @return the styles
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getRanges()
 *
 * @since 3.2
 */
public TextStyle[] getStyles () {
    checkLayout();
    TextStyle[] result = new TextStyle[styles.length];
    int count = 0;
    for (int i=0; i<styles.length; i++) {
        if (styles[i].style !is null) {
            result[count++] = styles[i].style;
        }
    }
    if (count !is result.length) {
        TextStyle[] newResult = new TextStyle[count];
        System.arraycopy(result, 0, newResult, 0, count);
        result = newResult;
    }
    return result;
}

/**
 * Returns the tab list of the receiver.
 *
 * @return the tab list
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int[] getTabs() {
    checkLayout();
    return tabs;
}

/**
 * Gets the receiver's text, which will be an empty
 * string if it has never been set.
 *
 * @return the receiver's text
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public String getText () {
    checkLayout ();
    return text;
}

/**
 * Returns the width of the receiver.
 *
 * @return the width
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int getWidth () {
    checkLayout();
    return wrapWidth;
}

/**
 * Returns <code>true</code> if the text layout has been disposed,
 * and <code>false</code> otherwise.
 * <p>
 * This method gets the dispose state for the text layout.
 * When a text layout has been disposed, it is an error to
 * invoke any other method using the text layout.
 * </p>
 *
 * @return <code>true</code> when the text layout is disposed and <code>false</code> otherwise
 */
public bool isDisposed () {
    return device is null;
}

/*
 * Returns true if the underline style is supported natively
 */
bool isUnderlineSupported (TextStyle style) {
    if (style !is null && style.underline) {
        int uStyle = style.underlineStyle;
        return uStyle is DWT.UNDERLINE_SINGLE || uStyle is DWT.UNDERLINE_DOUBLE || uStyle is DWT.UNDERLINE_LINK || uStyle is UNDERLINE_THICK;
    }
    return false;
}

/**
 * Sets the text alignment for the receiver. The alignment controls
 * how a line of text is positioned horizontally. The argument should
 * be one of <code>DWT.LEFT</code>, <code>DWT.RIGHT</code> or <code>DWT.CENTER</code>.
 * <p>
 * The default alignment is <code>DWT.LEFT</code>.  Note that the receiver's
 * width must be set in order to use <code>DWT.RIGHT</code> or <code>DWT.CENTER</code>
 * alignment.
 * </p>
 *
 * @param alignment the new alignment
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #setWidth(int)
 */
public void setAlignment (int alignment) {
    checkLayout();
    int mask = DWT.LEFT | DWT.CENTER | DWT.RIGHT;
    alignment &= mask;
    if (alignment is 0) return;
    if ((alignment & DWT.LEFT) !is 0) alignment = DWT.LEFT;
    if ((alignment & DWT.RIGHT) !is 0) alignment = DWT.RIGHT;
    if (this.alignment is alignment) return;
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        freeRuns();
        this.alignment = alignment;
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Sets the ascent of the receiver. The ascent is distance in pixels
 * from the baseline to the top of the line and it is applied to all
 * lines. The default value is <code>-1</code> which means that the
 * ascent is calculated from the line fonts.
 *
 * @param ascent the new ascent
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the ascent is less than <code>-1</code></li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #setDescent(int)
 * @see #getLineMetrics(int)
 */
public void setAscent (int ascent) {
    checkLayout ();
    if (ascent < -1) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    if (this.ascent is ascent) return;
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        freeRuns();
        this.ascent = ascent;
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Sets the descent of the receiver. The descent is distance in pixels
 * from the baseline to the bottom of the line and it is applied to all
 * lines. The default value is <code>-1</code> which means that the
 * descent is calculated from the line fonts.
 *
 * @param descent the new descent
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the descent is less than <code>-1</code></li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #setAscent(int)
 * @see #getLineMetrics(int)
 */
public void setDescent (int descent) {
    checkLayout ();
    if (descent < -1) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    if (this.descent is descent) return;
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        freeRuns();
        this.descent = descent;
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Sets the default font which will be used by the receiver
 * to draw and measure text. If the
 * argument is null, then a default font appropriate
 * for the platform will be used instead. Note that a text
 * style can override the default font.
 *
 * @param font the new font for the receiver, or null to indicate a default font
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the font has been disposed</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setFont (Font font) {
    checkLayout ();
    if (font !is null && font.isDisposed()) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    Font oldFont = this.font;
    if (oldFont is font) return;
    this.font = font;
    if (oldFont !is null && oldFont.equals(font)) return;
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        freeRuns();
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Sets the indent of the receiver. This indent it applied of the first line of
 * each paragraph.
 *
 * @param indent new indent
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.2
 */
public void setIndent (int indent) {
    checkLayout ();
    if (indent < 0) return;
    if (this.indent is indent) return;
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        freeRuns();
        this.indent = indent;
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Sets the justification of the receiver. Note that the receiver's
 * width must be set in order to use justification.
 *
 * @param justify new justify
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.2
 */
public void setJustify (bool justify) {
    checkLayout ();
    if (justify is this.justify) return;
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        freeRuns();
        this.justify = justify;
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Sets the orientation of the receiver, which must be one
 * of <code>DWT.LEFT_TO_RIGHT</code> or <code>DWT.RIGHT_TO_LEFT</code>.
 *
 * @param orientation new orientation style
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setOrientation(int orientation) {
    checkLayout();
    int mask = DWT.LEFT_TO_RIGHT | DWT.RIGHT_TO_LEFT;
    orientation &= mask;
    if (orientation is 0) return;
    if ((orientation & DWT.LEFT_TO_RIGHT) !is 0) orientation = DWT.LEFT_TO_RIGHT;
    if (this.orientation is orientation) return;
    this.orientation = orientation;
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        freeRuns();
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Sets the offsets of the receiver's text segments. Text segments are used to
 * override the default behaviour of the bidirectional algorithm.
 * Bidirectional reordering can happen within a text segment but not
 * between two adjacent segments.
 * <p>
 * Each text segment is determined by two consecutive offsets in the
 * <code>segments</code> arrays. The first element of the array should
 * always be zero and the last one should always be equals to length of
 * the text.
 * </p>
 *
 * @param segments the text segments offset
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setSegments(int[] segments) {
    checkLayout();
    if (this.segments is null && segments is null) return;
    if (this.segments !is null && segments !is null) {
        if (this.segments.length is segments.length) {
            int i;
            for (i = 0; i <segments.length; i++) {
                if (this.segments[i] !is segments[i]) break;
            }
            if (i is segments.length) return;
        }
    }
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        freeRuns();
        this.segments = segments;
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Sets the line spacing of the receiver.  The line spacing
 * is the space left between lines.
 *
 * @param spacing the new line spacing
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the spacing is negative</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setSpacing (int spacing) {
    checkLayout();
    if (spacing < 0) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    if (this.spacing is spacing) return;
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        freeRuns();
        this.spacing = spacing;
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Sets the style of the receiver for the specified range.  Styles previously
 * set for that range will be overwritten.  The start and end offsets are
 * inclusive and will be clamped if out of range.
 *
 * @param style the style
 * @param start the start offset
 * @param end the end offset
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setStyle (TextStyle style, int start, int end) {
    checkLayout();
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        int length = text.length;
        if (length is 0) return;
        if (start > end) return;
        start = Math.min(Math.max(0, start), length - 1);
        end = Math.min(Math.max(0, end), length - 1);
        int low = -1;
        int high = styles.length;
        while (high - low > 1) {
            int index = (high + low) / 2;
            if (styles[index + 1].start > start) {
                high = index;
            } else {
                low = index;
            }
        }
        if (0 <= high && high < styles.length) {
            StyleItem item = styles[high];
            if (item.start is start && styles[high + 1].start - 1 is end) {
                if (style is null) {
                    if (item.style is null) return;
                } else {
                    if (style.equals(item.style)) return;
                }
            }
        }
        freeRuns();
        int modifyStart = high;
        int modifyEnd = modifyStart;
        while (modifyEnd < styles.length) {
            if (styles[modifyEnd + 1].start > end) break;
            modifyEnd++;
        }
        if (modifyStart is modifyEnd) {
            int styleStart = styles[modifyStart].start;
            int styleEnd = styles[modifyEnd + 1].start - 1;
            if (styleStart is start && styleEnd is end) {
                styles[modifyStart].style = style;
                return;
            }
            if (styleStart !is start && styleEnd !is end) {
                StyleItem[] newStyles = new StyleItem[styles.length + 2];
                System.arraycopy(styles, 0, newStyles, 0, modifyStart + 1);
                StyleItem item = new StyleItem();
                item.start = start;
                item.style = style;
                newStyles[modifyStart + 1] = item;
                item = new StyleItem();
                item.start = end + 1;
                item.style = styles[modifyStart].style;
                newStyles[modifyStart + 2] = item;
                System.arraycopy(styles, modifyEnd + 1, newStyles, modifyEnd + 3, styles.length - modifyEnd - 1);
                styles = newStyles;
                return;
            }
        }
        if (start is styles[modifyStart].start) modifyStart--;
        if (end is styles[modifyEnd + 1].start - 1) modifyEnd++;
        int newLength = styles.length + 1 - (modifyEnd - modifyStart - 1);
        StyleItem[] newStyles = new StyleItem[newLength];
        System.arraycopy(styles, 0, newStyles, 0, modifyStart + 1);
        StyleItem item = new StyleItem();
        item.start = start;
        item.style = style;
        newStyles[modifyStart + 1] = item;
        styles[modifyEnd].start = end + 1;
        System.arraycopy(styles, modifyEnd, newStyles, modifyStart + 2, styles.length - modifyEnd);
        styles = newStyles;
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Sets the receiver's tab list. Each value in the tab list specifies
 * the space in pixels from the origin of the text layout to the respective
 * tab stop.  The last tab stop width is repeated continuously.
 *
 * @param tabs the new tab list
 *
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setTabs(int[] tabs) {
    checkLayout();
    if (this.tabs is null && tabs is null) return;
    if (this.tabs !is null && tabs !is null) {
        if (this.tabs.length is tabs.length) {
            int i;
            for (i = 0; i < tabs.length; i++) {
                if (this.tabs[i] !is tabs[i]) break;
            }
            if (i is tabs.length) return;
        }
    }
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        freeRuns();
        this.tabs = tabs;
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Sets the receiver's text.
 *<p>
 * Note: Setting the text also clears all the styles. This method
 * returns without doing anything if the new text is the same as
 * the current text.
 * </p>
 *
 * @param text the new text
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the text is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setText (String text) {
    checkLayout ();
    if (text is null) DWT.error(DWT.ERROR_NULL_ARGUMENT);
    if (text.equals(this.text)) return;
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        freeRuns();
        this.text = text;
        styles = new StyleItem[2];
        styles[0] = new StyleItem();
        styles[1] = new StyleItem();
        styles[styles.length - 1].start = text.length;
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Sets the line width of the receiver, which determines how
 * text should be wrapped and aligned. The default value is
 * <code>-1</code> which means wrapping is disabled.
 *
 * @param width the new width
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the width is <code>0</code> or less than <code>-1</code></li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #setAlignment(int)
 */
public void setWidth (int width) {
    checkLayout();
    if (width < -1 || width is 0) DWT.error(DWT.ERROR_INVALID_ARGUMENT);
    if (this.wrapWidth is width) return;
    NSAutoreleasePool pool = null;
    if (!NSThread.isMainThread()) pool = cast(NSAutoreleasePool) (new NSAutoreleasePool()).alloc().init();
    try {
        freeRuns();
        this.wrapWidth = width;
    } finally {
        if (pool !is null) pool.release();
    }
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the receiver
 */
public String toString () {
    if (isDisposed()) return "TextLayout {*DISPOSED*}";
    return "TextLayout {" ~ text ~ "}";
}

/*
 *  Translate a client offset to an internal offset
 */
int translateOffset (int offset) {
    int length = text.length;
    if (length is 0) return offset;
    if (invalidOffsets is null) return offset;
    for (int i = 0; i < invalidOffsets.length; i++) {
        if (offset < invalidOffsets[i]) break;
        offset++;
    }
    return offset;
}

/*
 *  Translate an internal offset to a client offset
 */
int untranslateOffset (int offset) {
    int length = text.length;
    if (length is 0) return offset;
    if (invalidOffsets is null) return offset;
    for (int i = 0; i < invalidOffsets.length; i++) {
        if (offset is invalidOffsets[i]) {
            offset++;
            continue;
        }
        if (offset < invalidOffsets[i]) {
            return offset - i;
        }
    }
    return offset - invalidOffsets.length;
}

}
