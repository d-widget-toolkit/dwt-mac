/**
 * Authors: Frank Benoit <keinfarbton@googlemail.com>
 */
module dwt.dwthelper.FileInputStream;

import dwt.dwthelper.utils;
import dwt.dwthelper.File;
import dwt.dwthelper.InputStream;
import TangoFile = tango.io.device.File;
import tango.core.Exception;
import tango.text.convert.Format;

public class FileInputStream : dwt.dwthelper.InputStream.InputStream {

    alias dwt.dwthelper.InputStream.InputStream.read read;

    private TangoFile.File conduit;
    private ubyte[] buffer;
    private int buf_pos;
    private int buf_size;
    private const int BUFFER_SIZE = 0x10000;
    private bool eof;

    public this ( char[] name ){
        conduit = new TangoFile.File( name );
        buffer = new ubyte[]( BUFFER_SIZE );
    }

    public this ( dwt.dwthelper.File.File file ){
        implMissing( __FILE__, __LINE__ );
        conduit = new TangoFile.File( file.getAbsolutePath(), TangoFile.File.ReadExisting);
        buffer = new ubyte[]( BUFFER_SIZE );
    }

    public override int read(){
        if( eof ){
            return -1;
        }
        try{
            if( buf_pos is buf_size ){
                buf_pos = 0;
                buf_size = conduit.input.read( buffer );
            }
            if( buf_size <= 0 ){
                eof = true;
                return -1;
            }
            assert( buf_pos < BUFFER_SIZE, Format( "{0} {1}", buf_pos, buf_size ) );
            assert( buf_size <= BUFFER_SIZE );
            int res = cast(int) buffer[ buf_pos ];
            buf_pos++;
            return res;
        }
        catch( IOException e ){
            eof = true;
            return -1;
        }
    }

    public long skip( long n ){
        implMissing( __FILE__, __LINE__ );
        return 0L;
    }

    public int available(){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }

    public override void close(){
        conduit.close();
    }
}


