/**
 * Authors: Frank Benoit <keinfarbton@googlemail.com>
 */

module dwt.dwthelper.InputStream;

import dwt.dwthelper.utils;

public abstract class InputStream {


    public this (){
    }

    public abstract int read();

    public int read( byte[] b ){
        foreach( uint idx, inout byte val; b ){
            int c = read();
            if( c is -1 ){
                return ( idx is 0 ) ? -1 : idx;
            }
            b[ idx] = cast(byte)( c & 0xFF );
        }
        return b.length;
    }

    public int read( byte[] b, int off, int len ){
        return read( b[ off .. off+len ] );
    }

    public long skip( long n ){
        implMissing( __FILE__, __LINE__ );
        return 0L;
    }

    public int available(){
        return 0;
    }

    public void close(){
        implMissing( __FILE__, __LINE__ );
    }

    public synchronized void mark( int readlimit ){
        implMissing( __FILE__, __LINE__ );
    }

    public synchronized void reset(){
        implMissing( __FILE__, __LINE__ );
    }

    public bool markSupported(){
        implMissing( __FILE__, __LINE__ );
        return false;
    }


}


