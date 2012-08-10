/**
 * Authors: Frank Benoit <keinfarbton@googlemail.com>
 */
module dwt.dwthelper.InflaterInputStream;

import dwt.dwthelper.InputStream;
import dwt.dwthelper.utils;

public class InflaterInputStream : dwt.dwthelper.InputStream.InputStream {

    alias dwt.dwthelper.InputStream.InputStream.read read;
    alias dwt.dwthelper.InputStream.InputStream.skip skip;
    alias dwt.dwthelper.InputStream.InputStream.available available;
    alias dwt.dwthelper.InputStream.InputStream.close close;
    alias dwt.dwthelper.InputStream.InputStream.mark mark;
    alias dwt.dwthelper.InputStream.InputStream.reset reset;
    alias dwt.dwthelper.InputStream.InputStream.markSupported markSupported;

    protected byte[] buf;
    protected int len;
    package bool usesDefaultInflater = false;

    public this ( dwt.dwthelper.InputStream.InputStream istr ){
    }

    public int read(){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }

    public int read( byte[] b, int off, int len ){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }

    public int available(){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }

    public long skip( long n ){
        implMissing( __FILE__, __LINE__ );
        return 0L;
    }

    public void close(){
        implMissing( __FILE__, __LINE__ );
    }

    public void fill(){
        implMissing( __FILE__, __LINE__ );
    }

    public bool markSupported(){
        implMissing( __FILE__, __LINE__ );
        return false;
    }

    public synchronized void mark( int readlimit ){
        implMissing( __FILE__, __LINE__ );
    }

    public synchronized void reset(){
        implMissing( __FILE__, __LINE__ );
    }
}


