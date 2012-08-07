/**
 * Authors: Frank Benoit <keinfarbton@googlemail.com>
 *          Jacob Carlborg <jacob.carlborg@gmail.com>
 */
module dwt.dwthelper.OutputStream;

import dwt.dwthelper.utils;
static import tango.io.model.IConduit;

public abstract class OutputStream {

    protected tango.io.model.IConduit.OutputStream ostr;

    public this(){
    }

    protected this( tango.io.model.IConduit.OutputStream aOutStream) {
        this.ostr = aOutStream;
    }

    protected this(OutputStream rhs) {
        ostr = rhs.ostr;
    }

    public abstract void write( int b );

    public void write( byte[] b ){
        ostr.write(b);
    }

    public void write(char[] c) {
        ostr.write(c);
    }

    public void write( byte[] b, int off, int len ){
        ostr.write(b[off .. off + len]);
    }

    public void flush(){
        ostr.flush();
    }

    public void close(){
        ostr.flush();
        implMissing( __FILE__, __LINE__ );
    }


}


