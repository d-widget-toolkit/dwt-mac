/**
 * Authors: Frank Benoit <keinfarbton@googlemail.com>
 */
module dwt.dwthelper.ByteArrayOutputStream;

public import dwt.dwthelper.OutputStream;
import dwt.dwthelper.utils;

public class ByteArrayOutputStream : dwt.dwthelper.OutputStream.OutputStream {

    alias dwt.dwthelper.OutputStream.OutputStream.write write;

    protected byte[] buf;
    protected int count;
    public this (){
    }

    public this ( int par_size ){
    }

    public synchronized void write( int b ){
        implMissing( __FILE__, __LINE__ );
    }

    public synchronized void write( byte[] b, int off, int len ){
        implMissing( __FILE__, __LINE__ );
    }

    public synchronized void writeTo( dwt.dwthelper.OutputStream.OutputStream out_KEYWORDESCAPE ){
        implMissing( __FILE__, __LINE__ );
    }

    public synchronized void reset(){
        implMissing( __FILE__, __LINE__ );
    }

    public synchronized byte[] toByteArray(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    public int size(){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }

    public override char[] toString(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    public char[] toString( char[] enc ){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    public char[] toString( int hibyte ){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    public  override void close(){
        implMissing( __FILE__, __LINE__ );
    }


}


