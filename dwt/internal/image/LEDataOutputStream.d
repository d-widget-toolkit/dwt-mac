/*******************************************************************************
 * Copyright (c) 2000, 2005 IBM Corporation and others.
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
module dwt.internal.image.LEDataOutputStream;


import dwt.dwthelper.OutputStream;

final class LEDataOutputStream : OutputStream {
    alias OutputStream.write write;
    OutputStream out_;

public this(OutputStream output) {
    this.out_ = output;
}
/**
 * Write the specified number of bytes of the given byte array,
 * starting at the specified offset, to the output stream.
 */
public override void write(byte b[], int off, int len) {
    out_.write(b, off, len);
}
/**
 * Write the given byte to the output stream.
 */
public override void write(int b) {
    out_.write(b);
}
/**
 * Write the given byte to the output stream.
 */
public void writeByte(byte b) {
    out_.write(b);
}
/**
 * Write the four bytes of the given integer
 * to the output stream.
 */
public void writeInt(int theInt) {
    out_.write(theInt & 0xFF);
    out_.write((theInt >> 8) & 0xFF);
    out_.write((theInt >> 16) & 0xFF);
    out_.write((theInt >> 24) & 0xFF);
}
/**
 * Write the two bytes of the given short
 * to the output stream.
 */
public void writeShort(int theShort) {
    out_.write(theShort & 0xFF);
    out_.write((theShort >> 8) & 0xFF);
}
}
