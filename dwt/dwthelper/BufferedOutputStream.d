/*
 * @(#)BufferedInputStream.java 1.50 04/05/03
 *
 * Copyright 2004 Sun Microsystems, Inc. All rights reserved.
 * SUN PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 * 
 * Port to the D programming language:
 *      Jacob Carlborg <jacob.carlborg@gmail.com>
 */
module dwt.dwthelper.BufferedOutputStream;

import tango.core.Exception;

import dwt.dwthelper.OutputStream;
import dwt.dwthelper.System;

/**
 * The class : a buffered output stream. By setting up such 
 * an output stream, an application can write bytes to the underlying 
 * output stream without necessarily causing a call to the underlying 
 * system for each byte written.
 *
 * Authors: Arthur van Hoff, Jacob Carlborg
 * Version: 1.33, 12/19/03
 * Since: JDK1.0
 */
class BufferedOutputStream : OutputStream
{
    /// The internal buffer where data is stored.
    protected byte buf[];

    /**
     * The number of valid bytes in the buffer. This value is always 
     * in the range <tt>0</tt> through <tt>buf.length</tt>; elements 
     * <tt>buf[0]</tt> through <tt>buf[count-1]</tt> contain valid 
     * byte data.
     */
    protected int count;

    /**
     * Creates a new buffered output stream to write data to the
     * specified underlying output stream.
     * 
     * Params:
     *     ostr = the underlying output stream.
     */
    public this (OutputStream ostr)
    {
        this(ostr, 8192);
    }

    /**
     * Creates a new buffered output stream to write data to the 
     * specified underlying output stream with the specified buffer 
     * size.
     * 
     * Params:
     *     ostr = the underlying output stream
     *     size = the buffer size.
     *     
     * Throws: IllegalArgumentException if size &lt;= 0.
     */
    public this (OutputStream ostr, int size)
    {
        super(ostr);

        if (size <= 0)
            throw new IllegalArgumentException("Buffer size <= 0");

        buf = new byte[size];
    }

    /**
     * Flush the internal buffer
     *
     * Throws: IOException
     */
    private void flushBuffer ()
    {
        if (count > 0)
        {
            write(buf, 0, count);
            count = 0;
        }
    }

    /**
     * Writes the specified byte to this buffered output stream.
     * 
     * Params:
     *     b = he byte to be written.
     *     
     * Throws: IOException if an I/O error occurs.
     */
    public synchronized void write (int b)
    {
        if (count >= buf.length)
            flushBuffer();

        buf[count] = cast(byte) b;
        count++;
    }

    /**
     * Writes $(D_CODE len) bytes from the specified byte array 
     * starting at offset $(D_CODE off) to this buffered output stream.
     * 
     * $(P Ordinarily this method stores bytes from the given array into this
     * stream's buffer, flushing the buffer to the underlying output stream as
     * needed.  If the requested length is at least as large as this stream's
     * buffer, however, then this method will flush the buffer and write the
     * bytes directly to the underlying output stream.  Thus redundant
     * $(D_CODE BufferedOutputStream)s will not copy data unnecessarily.)
     * 
     * Params:
     *     b = the data
     *     off = the start offset in the data
     *     len = the number of bytes to write
     *     
     * Throws: IOException if an I/O error occurs
     */
    public synchronized void write (byte b[], int off, int len)
    {
        if (len >= buf.length)
        {
            /* If the request length exceeds the size of the output buffer,
             flush the output buffer and then write the data directly.
             In this way buffered streams will cascade harmlessly. */
            flushBuffer();
            write(b, off, len);
            return;
        }

        if (len > buf.length - count)
            flushBuffer();

        System.arraycopy(b, off, buf, count, len);
        count += len;
    }

    /**
     * 
     * Flushes this buffered output stream. This forces any buffered 
     * output bytes to be written out to the underlying output stream.
     * 
     * Throws: IOException if an I/O error occurs
     * See_Also: java.io.FilterOutputStream#out
     */
    public synchronized void flush ()
    {
        flushBuffer();
        ostr.flush();
    }
}
