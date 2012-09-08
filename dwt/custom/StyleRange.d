﻿/*******************************************************************************
 * Copyright (c) 2000, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *     Frank Benoit <benoit@tionex.de>
 *******************************************************************************/
module dwt.custom.StyleRange;

import dwt.dwthelper.utils;

import dwt.DWT;
import dwt.custom.StyleRange;
import dwt.custom.TextChangedEvent;
import dwt.custom.TextChangingEvent;
import dwt.graphics.Color;
import dwt.graphics.TextStyle;
import dwt.internal.CloneableCompatibility;

static import tango.text.Text;
alias tango.text.Text.Text!(char) StringBuffer;

/**
 * <code>StyleRange</code> defines a set of styles for a specified
 * range of text.
 * <p>
 * The hashCode() method in this class uses the values of the public
 * fields to compute the hash value. When storing instances of the
 * class in hashed collections, do not modify these fields after the
 * object has been inserted.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class StyleRange : TextStyle, CloneableCompatibility {

    /**
     * the start offset of the range, zero-based from the document start
     */
    public int start;

    /**
     * the length of the range
     */
    public int length;

    /**
     * the font style of the range. It may be a combination of
     * DWT.NORMAL, DWT.ITALIC or DWT.BOLD
     *
     * Note: the font style is not used if the <code>font</code> attribute
     * is set
     */
    public int fontStyle = DWT.NORMAL;

/**
 * Create a new style range with no styles
 *
 * @since 3.2
 */
public this() {
}
/++
 + DWT extension for clone implementation
 +/
protected this( StyleRange other ){
    super( other );
    start = other.start;
    length = other.length;
    fontStyle = other.fontStyle;
}

/**
 * Create a new style range from an existing text style.
 *
 * @param style the text style to copy
 *
 * @since 3.4
 */
public this(TextStyle style) {
    super(style);
}

/**
 * Create a new style range.
 *
 * @param start start offset of the style
 * @param length length of the style
 * @param foreground foreground color of the style, null if none
 * @param background background color of the style, null if none
 */
public this(int start, int length, Color foreground, Color background) {
    super(null, foreground, background);
    this.start = start;
    this.length = length;
}

/**
 * Create a new style range.
 *
 * @param start start offset of the style
 * @param length length of the style
 * @param foreground foreground color of the style, null if none
 * @param background background color of the style, null if none
 * @param fontStyle font style of the style, may be DWT.NORMAL, DWT.ITALIC or DWT.BOLD
 */
public this(int start, int length, Color foreground, Color background, int fontStyle) {
    this(start, length, foreground, background);
    this.fontStyle = fontStyle;
}

/**
 * Compares the argument to the receiver, and returns true
 * if they represent the <em>same</em> object using a class
 * specific comparison.
 *
 * @param object the object to compare with this object
 * @return <code>true</code> if the object is the same as this object and <code>false</code> otherwise
 *
 * @see #hashCode()
 */
public override int opEquals(Object object) {
    if (object is this) return true;
    if (auto style = cast(StyleRange) object ) {
        if (start !is style.start) return false;
        if (length !is style.length) return false;
        return similarTo(style);
    }
    return false;
}

/**
 * Returns an integer hash code for the receiver. Any two
 * objects that return <code>true</code> when passed to
 * <code>equals</code> must return the same value for this
 * method.
 *
 * @return the receiver's hash
 *
 * @see #equals(Object)
 */
public override hash_t toHash() {
    return super.toHash() ^ fontStyle;
}
bool isVariableHeight() {
    return font !is null || metrics !is null || rise !is 0;
}
/**
 * Returns whether or not the receiver is unstyled (i.e., does not have any
 * style attributes specified).
 *
 * @return true if the receiver is unstyled, false otherwise.
 */
public bool isUnstyled() {
    if (font !is null) return false;
    if (rise !is 0) return false;
    if (metrics !is null) return false;
    if (foreground !is null) return false;
    if (background !is null) return false;
    if (fontStyle !is DWT.NORMAL) return false;
    if (underline) return false;
    if (strikeout) return false;
    if (borderStyle !is DWT.NONE) return false;
    return true;
}

/**
 * Compares the specified object to this StyleRange and answer if the two
 * are similar. The object must be an instance of StyleRange and have the
 * same field values for except for start and length.
 *
 * @param style the object to compare with this object
 * @return true if the objects are similar, false otherwise
 */
public bool similarTo(StyleRange style) {
    if (!super.opEquals(style)) return false;
    if (fontStyle !is style.fontStyle) return false;
    return true;
}

/**
 * Returns a new StyleRange with the same values as this StyleRange.
 *
 * @return a shallow copy of this StyleRange
 */
public /+override+/ Object clone() {
    return new StyleRange( this );
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the StyleRange
 */
public override String toString() {
    StringBuffer buffer = new StringBuffer();
    buffer.format("{}", "StyleRange {");
    buffer.format("{}", start);
    buffer.format("{}", ", ");
    buffer.format("{}", length);
    buffer.format("{}", ", fontStyle=");
    switch (fontStyle) {
        case DWT.BOLD:
            buffer.format("{}", "bold");
            break;
        case DWT.ITALIC:
            buffer.format("{}", "italic");
            break;
        case DWT.BOLD | DWT.ITALIC:
            buffer.format("{}", "bold-italic");
            break;
        default:
            buffer.format("{}", "normal");
    }
    String str = super.toString();
    int index = str.indexOf('{');
    if( index is str.length ) index = -1;
    str = str[ index + 1 .. $ ];
    if (str.length > 1) buffer.format("{}", ", ");
    buffer.format("{}", str);
    return buffer.toString();
}
}
