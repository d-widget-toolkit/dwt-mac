/*******************************************************************************
 * Copyright (c) 2000, 2008 IBM Corporation and others.
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
module dwt.graphics.TextStyle;



import dwt.dwthelper.utils;
import dwt.graphics.Color;
import dwt.graphics.Font;
import dwt.graphics.GlyphMetrics;

/**
 * <code>TextStyle</code> defines a set of styles that can be applied
 * to a range of text.
 * <p>
 * The hashCode() method in this class uses the values of the public
 * fields to compute the hash value. When storing instances of the
 * class in hashed collections, do not modify these fields after the
 * object has been inserted.
 * </p>
 * <p>
 * Application code does <em>not</em> need to explicitly release the
 * resources managed by each instance when those instances are no longer
 * required, and thus no <code>dispose()</code> method is provided.
 * </p>
 *
 * @see TextLayout
 * @see Font
 * @see Color
 * @see <a href="http://www.eclipse.org/swt/snippets/#textlayout">TextLayout, TextStyle snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.0
 */
public class TextStyle {

    /**
     * the font of the style
     */
    public Font font;

    /**
     * the foreground of the style
     */
    public Color foreground;

    /**
     * the background of the style
     */
    public Color background;

    /**
     * the underline flag of the style. The default underline
     * style is <code>DWT.UNDERLINE_SINGLE</code>.
     *
     *
     * @since 3.1
     */
    public bool underline;

    /**
     * the underline color of the style
     *
     * @since 3.4
     */
    public Color underlineColor;

    /**
     * the underline style. This style is ignored when
     * <code>underline</code> is false.
     * <p>
     * This value should be one of <code>DWT.UNDERLINE_SINGLE</code>,
     * <code>DWT.UNDERLINE_DOUBLE</code>, <code>DWT.UNDERLINE_ERROR</code>,
     * or <code>DWT.UNDERLINE_SQUIGGLE</code>.
     * </p>
     *
     * @see DWT#UNDERLINE_SINGLE
     * @see DWT#UNDERLINE_DOUBLE
     * @see DWT#UNDERLINE_ERROR
     * @see DWT#UNDERLINE_SQUIGGLE
     * @see DWT#UNDERLINE_LINK
     *
     * @since 3.4
     */
    public int underlineStyle;

    /**
     * the strikeout flag of the style
     *
     * @since 3.1
     */
    public bool strikeout;

    /**
     * the strikeout color of the style
     *
     * @since 3.4
     */
    public Color strikeoutColor;

    /**
     * the border style. The default border style is <code>DWT.NONE</code>.
     * <p>
     * This value should be one of <code>DWT.BORDER_SOLID</code>,
     * <code>DWT.BORDER_DASH</code>,<code>DWT.BORDER_DOT</code> or
     * <code>DWT.NONE</code>.
     * </p>
     *
     * @see DWT#BORDER_SOLID
     * @see DWT#BORDER_DASH
     * @see DWT#BORDER_DOT
     * @see DWT#NONE
     *
     * @since 3.4
     */
    public int borderStyle;

    /**
     * the border color of the style
     *
     * @since 3.4
     */
    public Color borderColor;

    /**
     * the GlyphMetrics of the style
     *
     * @since 3.2
     */
    public GlyphMetrics metrics;

    /**
     * the baseline rise of the style.
     *
     * @since 3.2
     */
    public int rise;


    /**
     * the data. An user data field. It can be used to hold the HREF when the range
     * is used as a link or the embed object when the range is used with <code>GlyphMetrics</code>.
     * <p>
     *
     * @since 3.5
     */
    public Object data;


/**
 * Create an empty text style.
 *
 * @since 3.4
 */
public this () {
}

/**
 * Create a new text style with the specified font, foreground
 * and background.
 *
 * @param font the font of the style, <code>null</code> if none
 * @param foreground the foreground color of the style, <code>null</code> if none
 * @param background the background color of the style, <code>null</code> if none
 */
public this (Font font, Color foreground, Color background) {
    if (font !is null && font.isDisposed()) DWT.error (DWT.ERROR_INVALID_ARGUMENT);
    if (foreground !is null && foreground.isDisposed()) DWT.error (DWT.ERROR_INVALID_ARGUMENT);
    if (background !is null && background.isDisposed()) DWT.error (DWT.ERROR_INVALID_ARGUMENT);
    this.font = font;
    this.foreground = foreground;
    this.background = background;
}


/**
 * Create a new text style from an existing text style.
 *
 * @param style the style to copy
 *
 * @since 3.4
 */
public this (TextStyle style) {
    if (style is null) DWT.error (DWT.ERROR_INVALID_ARGUMENT);
    font = style.font;
    foreground = style.foreground;
    background = style.background;
    underline = style.underline;
    underlineColor = style.underlineColor;
    underlineStyle = style.underlineStyle;
    strikeout = style.strikeout;
    strikeoutColor = style.strikeoutColor;
    borderStyle = style.borderStyle;
    borderColor = style.borderColor;
    metrics = style.metrics;
    rise = style.rise;
    data = style.data;
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
public int opEquals(Object object) {
    if (object is this) return true;
    if (object is null) return false;
    if (!( null !is cast(TextStyle)object )) return false;
    TextStyle style = cast(TextStyle)object;
    if (foreground !is null) {
        if (!foreground.equals(style.foreground)) return false;
    } else if (style.foreground !is null) return false;
    if (background !is null) {
        if (!background.equals(style.background)) return false;
    } else if (style.background !is null) return false;
    if (font !is null) {
        if (!font.equals(style.font)) return false;
    } else if (style.font !is null) return false;
    if (metrics !is null || style.metrics !is null) return false;
    if (underline !is style.underline) return false;
    if (underlineStyle !is style.underlineStyle) return false;
    if (borderStyle !is style.borderStyle) return false;
    if (strikeout !is style.strikeout) return false;
    if (rise !is style.rise) return false;
    if (underlineColor !is null) {
        if (!underlineColor.equals(style.underlineColor)) return false;
    } else if (style.underlineColor !is null) return false;
    if (strikeoutColor !is null) {
        if (!strikeoutColor.equals(style.strikeoutColor)) return false;
    } else if (style.strikeoutColor !is null) return false;
    if (underlineStyle !is style.underlineStyle) return false;
    if (borderColor !is null) {
        if (!borderColor.equals(style.borderColor)) return false;
    } else if (style.borderColor !is null) return false;
    if (data !is null) {
        if (!data.equals(style.data)) return false;
    } else if (style.data !is null) return false;
    return true;
}

alias opEquals equals;

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
public hash_t toHash() {
    hash_t hash = 0;
    if (foreground !is null) hash ^= foreground.hashCode();
    if (background !is null) hash ^= background.hashCode();
    if (font !is null) hash ^= font.hashCode();
    if (metrics !is null) hash ^= metrics.hashCode();
    if (underline) hash ^= hash;
    if (strikeout) hash ^= hash;
    hash ^= rise;
    if (underlineColor !is null) hash ^= underlineColor.hashCode();
    if (strikeoutColor !is null) hash ^= strikeoutColor.hashCode();
    if (borderColor !is null) hash ^= borderColor.hashCode();
    hash ^= underlineStyle;
    return hash;
}

alias toHash hashCode;

bool isAdherentBorder(TextStyle style) {
    if (this is style) return true;
    if (style is null) return false;
    if (borderStyle !is style.borderStyle) return false;
    if (borderColor !is null) {
        if (!borderColor.equals(style.borderColor)) return false;
    } else {
        if (style.borderColor !is null) return false;
        if (foreground !is null) {
            if (!foreground.equals(style.foreground)) return false;
        } else if (style.foreground !is null) return false;
    }
    return true;
}

bool isAdherentUnderline(TextStyle style) {
    if (this is style) return true;
    if (style is null) return false;
    if (underline !is style.underline) return false;
    if (underlineStyle !is style.underlineStyle) return false;
    if (underlineColor !is null) {
        if (!underlineColor.equals(style.underlineColor)) return false;
    } else {
        if (style.underlineColor !is null) return false;
        if (foreground !is null) {
            if (!foreground.equals(style.foreground)) return false;
        } else if (style.foreground !is null) return false;
    }
    return true;
}

bool isAdherentStrikeout(TextStyle style) {
    if (this is style) return true;
    if (style is null) return false;
    if (strikeout !is style.strikeout) return false;
    if (strikeoutColor !is null) {
        if (!strikeoutColor.equals(style.strikeoutColor)) return false;
    } else {
        if (style.strikeoutColor !is null) return false;
        if (foreground !is null) {
            if (!foreground.equals(style.foreground)) return false;
        } else if (style.foreground !is null) return false;
    }
    return true;
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the <code>TextStyle</code>
 */
public String toString () {
    StringBuffer buffer = new StringBuffer("TextStyle {"); //$NON-NLS-1$
    int startLength = buffer.length();
    if (font !is null) {
        if (buffer.length() > startLength) buffer.format("{}", ", ");
        buffer.format("{}", "font=");
        buffer.format("{}", font.toString);
    }
    if (foreground !is null) {
        if (buffer.length() > startLength) buffer.format("{}", ", ");
        buffer.format("{}", "foreground=");
        buffer.format("{}", foreground.toString);
    }
    if (background !is null) {
        if (buffer.length() > startLength) buffer.format("{}", ", ");
        buffer.format("{}", "background=");
        buffer.format("{}", background.toString);
    }
    if (underline) {
        if (buffer.length() > startLength) buffer.format("{}", ", ");
        buffer.format("{}", "underlined");
        switch (underlineStyle) {
            case DWT.UNDERLINE_SINGLE: buffer.append("single"); break; //$NON-NLS-1$
            case DWT.UNDERLINE_DOUBLE: buffer.append("double"); break; //$NON-NLS-1$
            case DWT.UNDERLINE_SQUIGGLE: buffer.append("squiggle"); break; //$NON-NLS-1$
            case DWT.UNDERLINE_ERROR: buffer.append("error"); break; //$NON-NLS-1$
            case DWT.UNDERLINE_LINK: buffer.append("link"); break; //$NON-NLS-1$
        }
        if (underlineColor !is null) {
            buffer.append(", underlineColor="); //$NON-NLS-1$
            buffer.append(underlineColor);
        }
    }
    if (strikeout) {
        if (buffer.length() > startLength) buffer.format("{}", ", ");
        buffer.format("{}", "striked out");
        if (strikeoutColor !is null) {
            buffer.append(", strikeoutColor="); //$NON-NLS-1$
            buffer.append(strikeoutColor);
        }
    }
    if (borderStyle !is DWT.NONE) {
        if (buffer.length() > startLength) buffer.append(", "); //$NON-NLS-1$
        buffer.append("border="); //$NON-NLS-1$
        switch (borderStyle) {
            case DWT.BORDER_SOLID:  buffer.append("solid"); break; //$NON-NLS-1$
            case DWT.BORDER_DOT:    buffer.append("dot"); break; //$NON-NLS-1$
            case DWT.BORDER_DASH:   buffer.append("dash"); break; //$NON-NLS-1$
        }
        if (borderColor !is null) {
            buffer.append(", borderColor="); //$NON-NLS-1$
            buffer.append(borderColor);
        }
    }
    if (rise !is 0) {
        if (buffer.length() > startLength) buffer.format("{}", ", ");
        buffer.format("{}", "rise=");
        buffer.format("{}", rise);
    }
    if (metrics !is null) {
        if (buffer.length() > startLength) buffer.format("{}", ", ");
        buffer.format("{}", "metrics=");
        buffer.format("{}", metrics.toString);
    }
    buffer.format("{}", "}");
    return buffer.toString();
}

}
