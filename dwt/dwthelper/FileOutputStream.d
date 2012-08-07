/**
 * Authors: Frank Benoit <keinfarbton@googlemail.com>
 */
module dwt.dwthelper.FileOutputStream;

public import dwt.dwthelper.File;
public import dwt.dwthelper.OutputStream;

import dwt.dwthelper.utils;

public class FileOutputStream : dwt.dwthelper.OutputStream.OutputStream {

    alias dwt.dwthelper.OutputStream.OutputStream.write write;
    alias dwt.dwthelper.OutputStream.OutputStream.close close;

    public this ( char[] name ){
        implMissing( __FILE__, __LINE__ );
    }

    public this ( char[] name, bool append ){
        implMissing( __FILE__, __LINE__ );
    }

    public this ( dwt.dwthelper.File.File file ){
        implMissing( __FILE__, __LINE__ );
    }

    public this ( dwt.dwthelper.File.File file, bool append ){
        implMissing( __FILE__, __LINE__ );
    }

    public void write( int b ){
        implMissing( __FILE__, __LINE__ );
    }

    public void write( byte[] b ){
        implMissing( __FILE__, __LINE__ );
    }

    public void write( byte[] b, int off, int len ){
        implMissing( __FILE__, __LINE__ );
    }

    public void close(){
        implMissing( __FILE__, __LINE__ );
    }

    public void finalize(){
        implMissing( __FILE__, __LINE__ );
    }


}


