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
 *     Frank Benoit <benoit@tionex.de>
 *     Jacob Carlborg <jacob.carlborg@gmail.com>
 *******************************************************************************/
module dwt.DWTException;

import tango.io.Stdout;

import dwt.DWT;
import dwt.dwthelper.utils;

alias toString getMessage;

/**
 * This runtime exception is thrown whenever a recoverable error
 * occurs internally in DWT. The message text and error code
 * provide a further description of the problem. The exception
 * has a <code>throwable</code> field which holds the underlying
 * exception that caused the problem (if this information is
 * available (i.e. it may be null)).
 * <p>
 * DWTExceptions are thrown when something fails internally,
 * but DWT is left in a known stable state (eg. a widget call
 * was made from a non-u/i thread, or there is failure while
 * reading an Image because the source file was corrupt).
 * </p>
 *
 * @see DWTError
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */

public class DWTException : RuntimeException {
    /**
     * The DWT error code, one of DWT.ERROR_*.
     */
    public int code;

    /**
     * The underlying throwable that caused the problem,
     * or null if this information is not available.
     */
    public Throwable throwable( Exception e ){
        this.next = e;
        return this.next;
    }
    public Throwable throwable(){
        return this.next;
    }


    static const long serialVersionUID = 3257282552304842547L;

/**
 * Constructs a new instance of this class with its
 * stack trace filled in. The error code is set to an
 * unspecified value.
 */
public this () {
    this (DWT.ERROR_UNSPECIFIED);
}

/**
 * Constructs a new instance of this class with its
 * stack trace and message filled in. The error code is
 * set to an unspecified value.  Specifying <code>null</code>
 * as the message is equivalent to specifying an empty string.
 *
 * @param message the detail message for the exception
 */
public this (String message) {
    this (DWT.ERROR_UNSPECIFIED, message);
}

/**
 * Constructs a new instance of this class with its
 * stack trace and error code filled in.
 *
 * @param code the DWT error code
 */
public this (int code) {
    this (code, DWT.findErrorText (code));
}

/**
 * Constructs a new instance of this class with its
 * stack trace, error code and message filled in.
 * Specifying <code>null</code> as the message is
 * equivalent to specifying an empty string.
 *
 * @param code the DWT error code
 * @param message the detail message for the exception
 */
public this (int code, String message) {
    super (message);
    this.code = code;
}

/**
 * Returns the underlying throwable that caused the problem,
 * or null if this information is not available.
 * <p>
 * NOTE: This method overrides Throwable.getCause() that was
 * added to JDK1.4. It is necessary to override this method
 * in order for inherited printStackTrace() methods to work.
 * </p>
 * @return the underlying throwable
 *
 * @since 3.1
 */
public Exception getCause() {
    return throwable;
}

/**
 *  Returns the string describing this DWTException object.
 *  <p>
 *  It is combined with the message string of the Throwable
 *  which caused this DWTException (if this information is available).
 *  </p>
 *  @return the error message string of this DWTException object
 */
public String getMessage () {
    if (throwable is null) return super.toString ();
    return super.toString () ~ " (" ~ throwable.toString () ~ ")"; //$NON-NLS-1$ //$NON-NLS-2$
}

/**
 * Outputs a printable representation of this exception's
 * stack trace on the standard error stream.
 * <p>
 * Note: printStackTrace(PrintStream) and printStackTrace(PrintWriter)
 * are not provided in order to maintain compatibility with CLDC.
 * </p>
 */
public void printStackTrace () {
    Stderr.formatln( "stacktrace follows (if feature compiled in)" );
    foreach( msg; info ){
        Stderr.formatln( "{}", msg );
    }
    if ( throwable !is null) {
        Stderr.formatln ("*** Stack trace of contained exception ***"); //$NON-NLS-1$
        foreach( msg; throwable.info ){
            Stderr.formatln( "{}", msg );
        }
    }
}

}


