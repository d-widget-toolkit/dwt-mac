/**
 * Authors: Frank Benoit <keinfarbton@googlemail.com>
 */
module dwt.dwthelper.System;

import tango.core.Exception;
import tango.io.Stdout;
import tango.io.model.IFile;
import tango.io.stream.Format;
import tango.stdc.locale;
import tango.stdc.stdlib : exit;
import tango.sys.Environment;
import tango.time.Clock;

template SimpleType(T) {
    debug{
        static void validCheck(uint SrcLen, uint DestLen, uint copyLen){
            if(SrcLen < copyLen || DestLen < copyLen|| SrcLen < 0 || DestLen < 0){
                //Util.trace("Error : SimpleType.arraycopy(), out of bounds.");
                assert(0);
            }
        }
    }

    static void remove(inout T[] items, int index) {
        if(items.length is 0)
            return;

        if(index < 0 || index >= items.length){
            throw new ArrayBoundsException(__FILE__, __LINE__);
        }

        T element = items[index];

        int length = items.length;
        if(length is 1){
            items.length = 0;
            return;// element;
        }

        if(index is 0)
            items = items[1 .. $];
        else if(index is length - 1)
            items = items[0 .. index];
        else
            items = items[0 .. index] ~ items[index + 1 .. $];
    }

    static void insert(inout T[] items, T item, int index = -1) {
        if(index is -1)
            index = items.length;

        if(index < 0 || index > items.length ){
            throw new ArrayBoundsException(__FILE__, __LINE__);
        }

        if(index is items.length){
            items ~= item;
        }else if(index is 0){
            T[] newVect;
            newVect ~= item;
            items = newVect ~ items;
        }else if(index < items.length ){
            T[] arr1 = items[0 .. index];
            T[] arr2 = items[index .. $];

            // Important : if you write like the following commented,
            // you get wrong data
            // code:  T[] arr1 = items[0..index];
            //        T[] arr2 = items[index..$];
            //        items = arr1 ~ item;      // error, !!!
            //        items ~= arr2;            // item replace the arrr2[0] here
            items = arr1 ~ item ~ arr2;
        }
    }

    static void arraycopy(T[] src, uint srcPos, T[] dest, uint destPos, uint len)
    {
        if(len is 0) return;

        assert(src);
        assert(dest);
        debug{validCheck(src.length - srcPos, dest.length - destPos, len);}

        if(src is dest){
            for(int i=0; i<len; ++i){
                dest[destPos+i] = src[srcPos+i];
            }
        }else{
            dest[destPos..(len+destPos)] = src[srcPos..(len+srcPos)];
        }
    }
}

struct Out
{

    static FormatOutput!(char) delegate(char[] fmt,...) println;
    static FormatOutput!(char) delegate(char[] fmt,...) print;

    static this ()
    {
        println = &Stdout.formatln;
        print = &Stdout.format;
    }
}

struct Err
{
    static FormatOutput!(char) delegate(char[] fmt,...) println;
    static FormatOutput!(char) delegate(char[] fmt,...) print;

    static this ()
    {
        println = &Stderr.formatln;
        print = &Stderr.format;
    }
}

class System {

    static void arraycopy(T)(T[] src, uint srcPos, T[] dest, uint destPos, uint len)
    {
        return SimpleType!(T).arraycopy(src, srcPos, dest, destPos, len);
    }

    static long currentTimeMillis(){
        return Clock.now().ticks() / 10000;
    }

    static void exit( int code ){
        .exit(code);
    }
    public static int identityHashCode(Object x){
        if( x is null ){
            return 0;
        }
        return (*cast(Object *)&x).toHash();
    }

    public static char[] getProperty( char[] key, char[] defval ){
        char[] res = getProperty(key);
        if( res ){
            return res;
        }
        return defval;
    }

    public static char[] getProperty( char[] key ){
        /* get values for global system keys (environment) */
        switch( key ) {
                // Ubuntu Gutsy:Environment.get for OSTYPE is not working
                // Force default to "linux" for now -JJR
            case "os.name":
                version (linux) return Environment.get("OSTYPE","linux");
                version (darwin) return Environment.get("OSTYPE","darwin");

            case "user.name": return Environment.get("USER");
            case "user.home": return Environment.get("HOME");
            case "user.dir" : return Environment.get("PWD");
            case "file.separator" : return FileConst.PathSeparatorString ;
            case "file.encoding" :
                char* encoding;
                encoding = setlocale(LC_CTYPE, null);
                if (encoding is null)
                    version (linux) return "CP1252"; //default
                    version (darwin) return "UTF-8"; //default
                else
                    return encoding[0..strlen(encoding)].dup;
            default: return null;
        }

        /* Get values for local dwt specific keys */
        char[]* p;
        return ((p = key in localProperties) != null) ? *p : null;
    }

    public static void setProperty ( char[] key, char[] value ) {
        /* set property for LOCAL dwt keys */
        if (key !is null && value !is null)
            localProperties[ key ] = value;
    }

    static Out out_;
    static Err err;

    private static char[][char[]] localProperties;
}
