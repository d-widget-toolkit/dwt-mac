module dwt.dwthelper.XmlTranscode;

import dwt.dwthelper.utils;
import tango.core.Exception;
import Math = tango.math.Math;

/++
 + Decode XML entities into UTF8 String.
 + Eg. "&amp;" -> "&", "&#38;" -> "&", "&#x26;" -> "&"
 + Throws TextException on failure
 + The given String is modified.
 +/
char[] xmlUnescape( char[] str ){

    void error(){
        throw new TextException( "xmlUnescape" );
    }
    // &lt; ...
    // &#1234;
    // &#x12AF;
    char[] src = str;
    char[] trg = str;
    while( src.length ){
        if( src[0] !is '&' ){
            trg[0] = src[0];
            trg = trg[1..$];
            src = src[1..$];
        }
        else{
            src = src[1..$]; //  go past '&'
            if( src.length < 2 ) error();

            // search semi
            int len = Math.min( src.length, 10 ); // limit semi search to possible longest entityname
            int semi = tango.text.Util.locate( src[0 .. len ], ';' );
            if( semi is len ) error(); // no semi found

            char[] entityName = src[ 0 .. semi ]; // name without semi
            dchar entityValue = 0;
            switch( entityName ){
                case "lt":   entityValue = '<'; break;
                case "gt":   entityValue = '>'; break;
                case "amp":  entityValue = '&'; break;
                case "quot": entityValue = '\"'; break;
                case "apos": entityValue = '\''; break;
                default:
                    if( entityName[0] is 'x' ){
                        if( semi < 2 ) error();
                        if( semi > 9 ) error();
                        foreach( hex; entityName[1..$] ){
                            entityValue <<= 4;
                            if( hex >= '0' && hex <= '9' ){
                                entityValue |= ( hex - '0' );
                            }
                            else if( hex >= 'a' && hex <= 'f' ){
                                entityValue |= ( hex - 'a' );
                            }
                            else if( hex >= 'A' && hex <= 'F' ){
                                entityValue |= ( hex - 'A' );
                            }
                            else{
                                error();
                            }
                        }
                    }
                    else{
                        if( semi < 1 ) error();
                        if( semi > 9 ) error();
                        foreach( dec; entityName[1..$] ){
                            if( dec >= '0' && dec <= '9' ){
                                entityValue *= 10;
                                entityValue += ( dec - '0' );
                            }
                            else{
                                error();
                            }
                        }
                    }
            }
            dchar[1] arr;
            arr[0] = entityValue;
            uint ate = 0;
            char[] res = tango.text.convert.Utf.toString( arr, trg, &ate );
            trg = trg[ res.length .. $ ];
            src = src[ semi +1 .. $ ]; // go past semi
        }
    }
    return str[ 0 .. trg.ptr-str.ptr ];
}


/++
 + Encode XML entities into UTF8 String.
 + First checks if processing is needed.
 + If not, the original String is returned.
 + If processing is needed, a new String is allocated.
 +/
char[] xmlEscape( char[] xml ){
    bool needsReplacement( dchar c ){
        switch( c ){
            case '<':
            case '>':
            case '&':
            case '\"':
            case '\'':
            case '\r':
            case '\n':
            case '\u0009':
                return true;
            default:
                return c > 0x7F;
        }
    }

    // Check if processing is needed
    foreach( char c; xml ){
        if( needsReplacement( c )){
            goto Lprocess;
        }
    }
    return xml;
Lprocess:

    // yes, do a new String, start with +20 chars
    char[] res = new char[ xml.length + 20 ];
    res.length = 0;

    foreach( dchar c; xml ){

        if( !needsReplacement( c )){
            res ~= c;
        }
        else{
            res ~= '&';
            switch( c ){
                case '<': res ~= "lt"; break;
                case '>': res ~= "gt"; break;
                case '&': res ~= "amp"; break;
                case '\"': res ~= "quot"; break;
                case '\'': res ~= "apos"; break;
                case '\r': case '\n': case '\u0009':
                default:
                    char toHexDigit( int i ){
                        if( i < 10 ) return '0'+i;
                        return 'A'+i-10;
                    }
                    res ~= "#x";
                    if( c <= 0xFF ){
                        res ~= toHexDigit(( c >> 4 ) & 0x0F );
                        res ~= toHexDigit(( c >> 0 ) & 0x0F );
                    }
                    else if( c <= 0xFFFF ){
                        res ~= toHexDigit(( c >> 12 ) & 0x0F );
                        res ~= toHexDigit(( c >> 8 ) & 0x0F );
                        res ~= toHexDigit(( c >> 4 ) & 0x0F );
                        res ~= toHexDigit(( c >> 0 ) & 0x0F );
                    }
                    else if( c <= 0xFFFFFF ){
                        res ~= toHexDigit(( c >> 20 ) & 0x0F );
                        res ~= toHexDigit(( c >> 16 ) & 0x0F );
                        res ~= toHexDigit(( c >> 12 ) & 0x0F );
                        res ~= toHexDigit(( c >> 8 ) & 0x0F );
                        res ~= toHexDigit(( c >> 4 ) & 0x0F );
                        res ~= toHexDigit(( c >> 0 ) & 0x0F );
                    }
                    else {
                        res ~= toHexDigit(( c >> 28 ) & 0x0F );
                        res ~= toHexDigit(( c >> 24 ) & 0x0F );
                        res ~= toHexDigit(( c >> 20 ) & 0x0F );
                        res ~= toHexDigit(( c >> 16 ) & 0x0F );
                        res ~= toHexDigit(( c >> 12 ) & 0x0F );
                        res ~= toHexDigit(( c >> 8 ) & 0x0F );
                        res ~= toHexDigit(( c >> 4 ) & 0x0F );
                        res ~= toHexDigit(( c >> 0 ) & 0x0F );
                    }
                    break;
            }
            res ~= ';';
        }
    }
}

