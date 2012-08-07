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
module dwt.DWTError;

import tango.io.Stdout;

import dwt.DWT;
import dwt.dwthelper.utils;

alias toString getMessage;

/**
 * This error is thrown whenever an unrecoverable error
 * occurs internally in DWT. The message text and error code
 * provide a further description of the problem. The exception
 * has a <code>throwable</code> field which holds the underlying
 * throwable that caused the problem (if this information is
 * available (i.e. it may be null)).
 * <p>
 * DWTErrors are thrown when something fails internally which
 * either leaves DWT in an unknown state (eg. the o/s call to
 * remove an item from a list returns an error code) or when DWT
 * is left in a known-to-be-unrecoverable state (eg. it runs out
 * of callback resources). DWTErrors should not occur in typical
 * programs, although "high reliability" applications should
 * still catch them.
 * </p><p>
 * This class also provides support methods used by DWT to match
 * error codes to the appropriate exception class (DWTError,
 * DWTException, or IllegalArgumentException) and to provide
 * human readable strings for DWT error codes.
 * </p>
 *
 * @see DWTException
 * @see DWT#error(int)
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */

public class DWTError : Error {
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

    static const long serialVersionUID = 3833467327105808433L;

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
public Throwable getCause() {
    return throwable;
}

/**
 *  Returns the string describing this DWTError object.
 *  <p>
 *  It is combined with the message string of the Throwable
 *  which caused this DWTError (if this information is available).
 *  </p>
 *  @return the error message string of this DWTError object
 */
public String getMessage () {
    if (throwable is null) return super.toString();
    return super.toString () ~ " (" ~ throwable.toString () ~ ")"; //$NON-NLS-1$ //$NON-NLS-2$
}

/**
 * Outputs a printable representation of this error's
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
        Stderr.formatln ("*** Stack trace of contained error ***"); //$NON-NLS-1$
        foreach( msg; throwable.info ){
            Stderr.formatln( "{}", msg );
        }
    }
}

}
