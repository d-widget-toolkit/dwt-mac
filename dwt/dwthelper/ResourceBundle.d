/**
 * Authors: Frank Benoit <keinfarbton@googlemail.com>
 */
module dwt.dwthelper.ResourceBundle;

import tango.text.Util;
import tango.io.Stdout;

import dwt.DWT;
import dwt.dwthelper.utils;
import tango.io.device.File;
import tango.text.locale.Core;

import tango.util.log.Trace;

class ResourceBundle {

    String[ String ] map;

    /++
     + First entry is the default entry if no maching locale is found
     +/
    public this( ImportData[] data ){
        char[] name = Culture.current().name.dup;
        if( name.length is 5 && name[2] is '-' ){
            name[2] = '_';
            char[] end = "_" ~ name ~ ".properties";
            foreach( entry; data ){
                if( entry.name.length > end.length && entry.name[ $-end.length .. $ ] == end ){
                    Trace.formatln( "ResourceBundle {}", entry.name );
                    initialize( cast(char[])entry.data );
                    return;
                }
            }
        }
        char[] end = "_" ~ name[0..2] ~ ".properties";
        foreach( entry; data ){
            if( entry.name.length > end.length && entry.name[ $-end.length .. $ ] == end ){
                Trace.formatln( "ResourceBundle {}", entry.name );
                initialize( cast(char[])entry.data );
                return;
            }
        }
        //Trace.formatln( "ResourceBundle default" );
        initialize( cast(char[])data[0].data );
    }
    public this( ImportData data ){
        initialize( cast(char[])data.data );
    }
    public this( String data ){
        initialize( data );
    }
    private void initialize( String data ){
        String line;
        int dataIndex;

        //tango.io.Stdout.Stdout.formatln( "properties put ..." );
        void readLine(){
            line.length = 0;
            char i = data[ dataIndex++ ];
            while( dataIndex < data.length && i !is '\n' && i !is '\r' ){
                line ~= i;
                i = data[ dataIndex++ ];
            }
        }

        //tango.io.Stdout.Stdout.formatln( "properties put {}", __LINE__ );
        bool linecontinue = false;
        bool iskeypart = true;
        String key;
        String value;
nextline:
        while( dataIndex < data.length ){
            //tango.io.Stdout.Stdout.formatln( "properties put {} startline", __LINE__ );
            readLine();
            line = dwt.dwthelper.utils.trim(line);
            if( line.length is 0 ){
                //tango.io.Stdout.Stdout.formatln( "properties put {} was 0 length", __LINE__ );
                continue;
            }
            if( line[0] == '#' ){
                //tango.io.Stdout.Stdout.formatln( "properties put {} was comment", __LINE__ );
                continue;
            }
            int pos = 0;
            bool esc = false;
            if( !linecontinue ){
                iskeypart = true;
                key = null;
                value = null;
            }
            else{
                linecontinue = false;
            }
            while( pos < line.length ){
                char[] c = line[pos .. pos +1];
                if( esc ){
                    esc = false;
                    switch( c[0] ){
                    case 't' : c[0] = '\t'; break;
                    case 'n' : c[0] = '\n'; break;
                    case '\\': c[0] = '\\'; break;
                    case '\"': c[0] = '\"'; break;
                    case 'u' :
                        dchar d = Integer.parseInt( line[ pos+1 .. pos+5 ], 16 );
                        c = dcharToString(d);
                        pos += 4;
                       break;
                    default: break;
                    }
                }
                else{
                    if( c == "\\" ){
                        if( pos == line.length -1 ){
                            linecontinue = true;
                            goto nextline;
                        }
                        esc = true;
                        pos++;
                        continue;
                    }
                    else if( iskeypart && c == "=" ){
                        pos++;
                        iskeypart = false;
                        continue;
                    }
                }
                pos++;
                if( iskeypart ){
                    key ~= c;
                }
                else{
                    value ~= c;
                }
            }
            if( iskeypart ){
                // Cannot find '=' in record
                DWT.error( __FILE__, __LINE__, DWT.ERROR_INVALID_ARGUMENT );
                continue;
            }
            key = dwt.dwthelper.utils.trim(key);
            value = dwt.dwthelper.utils.trim(value);
            //tango.io.Stdout.Stdout.formatln( "properties put {}=>{}", key, value );

            map[ key.dup ] = value.dup;
            //tango.io.Stdout.Stdout.formatln( "properties put {}", __LINE__ );
        }
    }

    public bool hasString( String key ){
        return ( key in map ) !is null;
    }

    public String getString( String key ){
        if( auto v = key in map ){
            return (*v).dup;
        }
        throw new MissingResourceException( "key not found", this.classinfo.name, key );
    }

    public String[] getKeys(){
        return map.keys;
    }

    public static ResourceBundle getBundle( ImportData[] data ){
        return new ResourceBundle( data );
    }
    public static ResourceBundle getBundle( ImportData data ){
        return new ResourceBundle( data );
    }
    public static ResourceBundle getBundle( String name ){
        try{
            return new ResourceBundle( cast(String) File.get(name) );
        }
        catch( IOException e){
            e.msg ~= " file:" ~ name;
            throw e;
        }
    }
    public static ResourceBundle getBundleFromData( String data ){
        return new ResourceBundle( data );
    }
}
