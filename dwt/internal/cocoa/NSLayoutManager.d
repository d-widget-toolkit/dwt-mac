/*******************************************************************************
 * Copyright (c) 2000, 2009 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *    IBM Corporation - initial API and implementation
 *
 * Port to the D programming language:
 *    Jacob Carlborg <doob@me.com>
 *******************************************************************************/
module dwt.internal.cocoa.NSLayoutManager;

import dwt.dwthelper.utils;
import dwt.internal.c.Carbon;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSFont;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSRange;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSTextContainer;
import dwt.internal.cocoa.NSTextStorage;
import dwt.internal.cocoa.NSTypesetter;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSLayoutManager : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void addTemporaryAttribute(NSString attrName, cocoa.id value, NSRange charRange) {
    OS.objc_msgSend(this.id, OS.sel_addTemporaryAttribute_value_forCharacterRange_, attrName !is null ? attrName.id : null, value !is null ? value.id : null, charRange);
}

public void addTextContainer(NSTextContainer container) {
    OS.objc_msgSend(this.id, OS.sel_addTextContainer_, container !is null ? container.id : null);
}

public NSRect boundingRectForGlyphRange(NSRange glyphRange, NSTextContainer container) {
    NSRect result = NSRect();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_boundingRectForGlyphRange_inTextContainer_, glyphRange, container !is null ? container.id : null);
    return result;
}

public NSUInteger characterIndexForGlyphAtIndex(NSUInteger glyphIndex) {
    return cast(NSUInteger) OS.objc_msgSend(this.id, OS.sel_characterIndexForGlyphAtIndex_, glyphIndex);
}

public CGFloat defaultBaselineOffsetForFont(NSFont theFont) {
    return cast(CGFloat)OS.objc_msgSend_fpret(this.id, OS.sel_defaultBaselineOffsetForFont_, theFont !is null ? theFont.id : null);
}

public CGFloat defaultLineHeightForFont(NSFont theFont) {
    return cast(CGFloat) OS.objc_msgSend_fpret(this.id, OS.sel_defaultLineHeightForFont_, theFont !is null ? theFont.id : null);
}

public void drawBackgroundForGlyphRange(NSRange glyphsToShow, NSPoint origin) {
    OS.objc_msgSend(this.id, OS.sel_drawBackgroundForGlyphRange_atPoint_, glyphsToShow, origin);
}

public void drawGlyphsForGlyphRange(NSRange glyphsToShow, NSPoint origin) {
    OS.objc_msgSend(this.id, OS.sel_drawGlyphsForGlyphRange_atPoint_, glyphsToShow, origin);
}

public NSUInteger getGlyphs(NSGlyph* glyphArray, NSRange glyphRange) {
    return cast(NSUInteger) OS.objc_msgSend(this.id, OS.sel_getGlyphs_range_, glyphArray, glyphRange);
}

public NSUInteger getGlyphsInRange(NSRange glyphRange, NSGlyph* glyphBuffer, NSUInteger* charIndexBuffer, NSGlyphInscription* inscribeBuffer, bool* elasticBuffer, ubyte* bidiLevelBuffer) {
    return OS.objc_msgSend(this.id, OS.sel_getGlyphsInRange_glyphs_characterIndexes_glyphInscriptions_elasticBits_bidiLevels_, glyphRange, glyphBuffer, charIndexBuffer, inscribeBuffer, elasticBuffer, bidiLevelBuffer);
}

}

public NSUInteger glyphIndexForCharacterAtIndex(NSUInteger charIndex) {
    return cast(NSUInteger) OS.objc_msgSend(this.id, OS.sel_glyphIndexForCharacterAtIndex_, charIndex);
}

public NSUInteger glyphIndexForPoint(NSPoint point, NSTextContainer container, CGFloat* partialFraction) {
    return cast(NSUInteger) OS.objc_msgSend(this.id, OS.sel_glyphIndexForPoint_inTextContainer_fractionOfDistanceThroughGlyph_, point, container !is null ? container.id : null, partialFraction);
}

public NSRange glyphRangeForCharacterRange(NSRange charRange, NSRangePointer actualCharRange) {

    NSRange result = new NSRange();
    OS.objc_msgSend_stret(result, this.id, OS.sel_glyphRangeForCharacterRange_actualCharacterRange_, charRange, actualCharRange);
    return result;
}

public NSRange glyphRangeForTextContainer(NSTextContainer container) {
    NSRange result = NSRange();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_glyphRangeForTextContainer_, container !is null ? container.id : null);
    return result;
}

public NSRect lineFragmentUsedRectForGlyphAtIndex(NSUInteger glyphIndex, NSRangePointer effectiveGlyphRange) {
    NSRect result = NSRect();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_lineFragmentUsedRectForGlyphAtIndex_effectiveRange_, glyphIndex, effectiveGlyphRange);
    return result;
}

public NSRect lineFragmentUsedRectForGlyphAtIndex(NSUInteger glyphIndex, NSRangePointer effectiveGlyphRange, bool flag) {
    NSRect result = NSRect();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_lineFragmentUsedRectForGlyphAtIndex_effectiveRange_withoutAdditionalLayout_, glyphIndex, effectiveGlyphRange, flag);
    return result;
}

public NSPoint locationForGlyphAtIndex(NSUInteger glyphIndex) {
    NSPoint result = NSPoint();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_locationForGlyphAtIndex_, glyphIndex);
    return result;
}

public NSUInteger numberOfGlyphs() {
    return cast(NSUInteger) OS.objc_msgSend(this.id, OS.sel_numberOfGlyphs);
}

public NSRectArray rectArrayForCharacterRange(NSRange charRange, NSRange selCharRange, NSTextContainer container, NSUInteger* rectCount) {
    return OS.objc_msgSend(this.id, OS.sel_rectArrayForCharacterRange_withinSelectedCharacterRange_inTextContainer_rectCount_, charRange, selCharRange, container !is null ? container.id : null, rectCount);
}

public void removeTemporaryAttribute(NSString attrName, NSRange charRange) {
    OS.objc_msgSend(this.id, OS.sel_removeTemporaryAttribute_forCharacterRange_, attrName !is null ? attrName.id : null, charRange);
}

public void setBackgroundLayoutEnabled(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setBackgroundLayoutEnabled_, flag);
}

public void setBackgroundLayoutEnabled(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setBackgroundLayoutEnabled_, flag);
}

public void setLineFragmentRect(NSRect fragmentRect, NSRange glyphRange, NSRect usedRect) {
    OS.objc_msgSend(this.id, OS.sel_setLineFragmentRect_forGlyphRange_usedRect_, fragmentRect, glyphRange, usedRect);
}

public void setTextStorage(NSTextStorage textStorage) {
    OS.objc_msgSend(this.id, OS.sel_setTextStorage_, textStorage !is null ? textStorage.id : 0);
}

public void setTextStorage(NSTextStorage textStorage) {
    OS.objc_msgSend(this.id, OS.sel_setTextStorage_, textStorage !is null ? textStorage.id : null);
}

public NSTypesetter typesetter() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_typesetter);
    return result !is null ? new NSTypesetter(result) : null;
}

public NSRect usedRectForTextContainer(NSTextContainer container) {
    NSRect result = NSRect();
    OS.objc_msgSend_stret(&result, this.id, OS.sel_usedRectForTextContainer_, container !is null ? container.id : null);
    return result;
}

}
