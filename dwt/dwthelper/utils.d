/**
 * Authors: Frank Benoit <keinfarbton@googlemail.com>
 */
module dwt.dwthelper.utils;

public import dwt.dwthelper.System;
public import dwt.dwthelper.Runnable;
public import Math = tango.math.Math;

public import tango.core.Exception : IllegalArgumentException, IOException, PlatformException;

import tango.io.Stdout;
import tango.io.stream.FormatStream;

public import tango.text.convert.Format;

import tango.stdc.stringz;
static import tango.text.Util;
static import tango.text.Text;
import tango.text.Unicode;
public import Utf = tango.text.convert.Utf;
import tango.text.convert.Utf;
import tango.core.Exception;
import tango.stdc.stdlib : exit;

import tango.util.log.Trace;
import tango.text.UnicodeData;
//static import tango.util.collection.model.Seq;

alias bool boolean;
alias char[] String;
alias tango.text.Text.Text!(char) StringBuffer;

alias PlatformException Error;
alias Exception Throwable;

alias ClassInfo Class;

public import dwt.dwthelper.array;

void implMissing( String file, uint line ){
    Stderr.formatln( "implementation missing in file {} line {}", file, line );
    Stderr.formatln( "exiting ..." );
    exit(1);
}

abstract class ArrayWrapper{
}
abstract class ValueWrapper{
}

class ArrayWrapperT(T) : ArrayWrapper {
    public T[] array;
    public this( T[] data ){
        array = data;
    }
}

class ValueWrapperT(T) : ValueWrapper {
    public T value;
    public this( T data ){
        value = data;
    }
    public int opEquals( T other ){
        return value == other;
    }
    public int opEquals( Object other ){
        if( auto o = cast(ValueWrapperT!(T))other ){
            return value == o.value;
        }
        return false;
    }
}

class Boolean : ValueWrapperT!(bool) {
    public static Boolean TRUE;
    public static Boolean FALSE;

    static this(){
        TRUE  = new Boolean(true);
        FALSE = new Boolean(false);
    }
    public this( bool v ){
        super(v);
    }

    alias ValueWrapperT!(bool).opEquals opEquals;
    public int opEquals( int other ){
        return value == ( other !is 0 );
    }
    public int opEquals( Object other ){
        if( auto o = cast(Boolean)other ){
            return value == o.value;
        }
        return false;
    }
    public bool booleanValue(){
        return value;
    }
    public static Boolean valueOf( String s ){
        if( s == "yes" || s == "true" ){
            return TRUE;
        }
        return FALSE;
    }
    public static Boolean valueOf( bool b ){
        return b ? TRUE : FALSE;
    }
}

alias Boolean    ValueWrapperBool;


class Byte : ValueWrapperT!(byte) {
    public static byte parseByte( String s ){
        try{
            int res = tango.text.convert.Integer.parse( s );
            if( res < byte.min || res > byte.max ){
                throw new NumberFormatException( "out of range" );
            }
            return res;
        }
        catch( IllegalArgumentException e ){
            throw new NumberFormatException( e );
        }
    }
    this( byte value ){
        super( value );
    }
}
alias Byte ValueWrapperByte;


class Integer : ValueWrapperT!(int) {

    public static const int MIN_VALUE = 0x80000000;
    public static const int MAX_VALUE = 0x7fffffff;
    public static const int SIZE = 32;

    public this ( int value ){
        super( value );
    }

    public this ( String s ){
        super(parseInt(s));
    }

    public static String toString( int i, int radix ){
        switch( radix ){
        case 2:
            return toBinaryString(i);
        case 8:
            return toOctalString(i);
        case 10:
            return toString(i);
        case 16:
            return toHexString(i);
        default:
            implMissing( __FILE__, __LINE__ );
            return null;
        }

        return null;
    }

    public static String toHexString( int i ){
        return tango.text.convert.Integer.toString(i, "x" );
    }

    public static String toOctalString( int i ){
        return tango.text.convert.Integer.toString(i, "o" );
    }

    public static String toBinaryString( int i ){
        return tango.text.convert.Integer.toString(i, "b" );
    }

    public static String toString( int i ){
        return tango.text.convert.Integer.toString(i);
    }

    public static int parseInt( String s, int radix ){
        try{
            return tango.text.convert.Integer.parse( s, cast(uint)radix );
        }
        catch( IllegalArgumentException e ){
            throw new NumberFormatException( e );
        }
    }

    public static int parseInt( String s ){
        try{
            return tango.text.convert.Integer.parse( s );
        }
        catch( IllegalArgumentException e ){
            throw new NumberFormatException( e );
        }
    }

    public static Integer valueOf( String s, int radix ){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    public static Integer valueOf( String s ){
        return valueOf( parseInt(s));
    }

    public static Integer valueOf( int i ){
        return new Integer(i);
    }

    public byte byteValue(){
        return cast(byte)value;
    }

    public short shortValue(){
        return cast(short)value;
    }

    public int intValue(){
        return value;
    }

    public long longValue(){
        return cast(long)value;
    }

    public float floatValue(){
        return cast(float)value;
    }

    public double doubleValue(){
        return cast(double)value;
    }

    public override  hash_t toHash(){
        return intValue();
    }

    public override String toString(){
        return tango.text.convert.Integer.toString( value );
    }
}
alias Integer ValueWrapperInt;

class Double : ValueWrapperT!(double) {
    this( double value ){
        super(value);
    }
    this( String str ){
        implMissing( __FILE__, __LINE__ );
        super(0.0);
    }
    public double doubleValue(){
        return value;
    }
    public static String toString( double value ){
        return Format("{}", value);
    }
}

class Float : ValueWrapperT!(float) {

    public static float POSITIVE_INFINITY = (1.0f / 0.0f);
    public static float NEGATIVE_INFINITY = ((-1.0f) / 0.0f);
    public static float NaN = (0.0f / 0.0f);
    public static float MAX_VALUE = 3.4028235e+38f;
    public static float MIN_VALUE = 1.4e-45f;
    public static int SIZE = 32;

    this( float value ){
        super(value);
    }
    this( String str ){
        implMissing( __FILE__, __LINE__ );
        super(0.0);
    }
    public float floatValue(){
        return value;
    }
    public static String toString( float value ){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    public static float parseFloat( String s ){
        try{
            return tango.text.convert.Float.toFloat( s );
        }
        catch( IllegalArgumentException e ){
            throw new NumberFormatException( e );
        }
    }

}
class Long : ValueWrapperT!(long) {
    this( long value ){
        super(value);
    }
    this( String str ){
        implMissing( __FILE__, __LINE__ );
        super(0);
    }
    public long longValue(){
        return value;
    }
    public static long parseLong(String s){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }
    public static String toString( double value ){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
}
alias Long ValueWrapperLong;


// alias ValueWrapperT!(int)     ValueWrapperInt;

alias ArrayWrapperT!(byte)    ArrayWrapperByte;
alias ArrayWrapperT!(int)     ArrayWrapperInt;
alias ArrayWrapperT!(Object)  ArrayWrapperObject;
alias ArrayWrapperT!(char)    ArrayWrapperString;
alias ArrayWrapperT!(String)  ArrayWrapperString2;

Object[] StringArrayToObjectArray( String[] strs ){
    Object[] res = new Object[strs.length];
    foreach( idx, str; strs ){
        res[idx] = new ArrayWrapperString(str);
    }
    return res;
}
int codepointIndexToIndex( String str, int cpIndex ){
    int cps = cpIndex;
    int res = 0;
    while( cps > 0 ){
        cps--;
        if( str[res] < 0x80 ){
            res+=1;
        }
        else if( str[res] < 0xE0 ){
            res+=2;
        }
        else if( str[res] & 0xF0 ){
            res+=3;
        }
        else{
            res+=4;
        }
    }
    return res;
}
int indexToCodepointIndex( String str, int index ){
    int i = 0;
    int res = 0;
    while( i < index ){
        if( str[i] < 0x80 ){
            i+=1;
        }
        else if( str[i] < 0xE0 ){
            i+=2;
        }
        else if( str[i] & 0xF0 ){
            i+=3;
        }
        else{
            i+=4;
        }
        res++;
    }
    return res;
}

String firstCodePointStr( String str, out int consumed ){
    dchar[1] buf;
    uint ate;
    dchar[] res = str.toString32( buf, &ate );
    consumed = ate;
    return str[ 0 .. ate ];
}

dchar firstCodePoint( String str ){
    int dummy;
    return firstCodePoint( str, dummy );
}
dchar firstCodePoint( String str, out int consumed ){
    dchar[1] buf;
    uint ate;
    dchar[] res = str.toString32( buf, &ate );
    consumed = ate;
    if( ate is 0 || res.length is 0 ){
        Trace.formatln( "dwthelper.utils {}: str.length={} str={:X2}", __LINE__, str.length, cast(ubyte[])str );
    }
    assert( ate > 0 );
    assert( res.length is 1 );
    return res[0];
}

String dcharToString( dchar key ){
    dchar[1] buf;
    buf[0] = key;
    return tango.text.convert.Utf.toString( buf );
}

int codepointCount( String str ){
    scope dchar[] buf = new dchar[]( str.length );
    uint ate;
    dchar[] res = tango.text.convert.Utf.toString32( str, buf, &ate );
    assert( ate is str.length );
    return res.length;
}

alias tango.text.convert.Utf.toString16 toString16;
alias tango.text.convert.Utf.toString toString;

int getRelativeCodePointOffset( String str, int startIndex, int searchRelCp ){
    int ignore;
    int i = startIndex;
    if( searchRelCp > 0 ){
        while( searchRelCp !is 0 ){

            if( ( i < str.length )
                && ( str[i] & 0x80 ) is 0x00 )
            {
                i+=1;
            }
            else if( ( i+1 < str.length )
                && (( str[i+1] & 0xC0 ) is 0x80 )
                && (( str[i  ] & 0xE0 ) is 0xC0 ))
            {
                i+=2;
            }
            else if( ( i+2 < str.length )
                && (( str[i+2] & 0xC0 ) is 0x80 )
                && (( str[i+1] & 0xC0 ) is 0x80 )
                && (( str[i  ] & 0xF0 ) is 0xE0 ))
            {
                i+=3;
            }
            else if(( i+3 < str.length )
                && (( str[i+3] & 0xC0 ) is 0x80 )
                && (( str[i+2] & 0xC0 ) is 0x80 )
                && (( str[i+1] & 0xC0 ) is 0x80 )
                && (( str[i  ] & 0xF8 ) is 0xF0 ))
            {
                i+=4;
            }
            else{
                Trace.formatln( "invalid utf8 characters: {:X2}", cast(ubyte[]) str );
                tango.text.convert.Utf.onUnicodeError( "invalid utf8 input", i );
            }
            searchRelCp--;
        }
    }
    else if( searchRelCp < 0 ){
        while( searchRelCp !is 0 ){
            do{
                i--;
                if( i < 0 ){
                    Trace.formatln( "dwthelper.utils getRelativeCodePointOffset {}: str={}, startIndex={}, searchRelCp={}", __LINE__, str, startIndex, searchRelCp );
                    tango.text.convert.Utf.onUnicodeError( "invalid utf8 input", i );
                }
            } while(( str[i] & 0xC0 ) is 0x80 );
            searchRelCp++;
        }
    }
    return i - startIndex;
}
dchar getRelativeCodePoint( String str, int startIndex, int searchRelCp, out int relIndex ){
    relIndex = getRelativeCodePointOffset( str, startIndex, searchRelCp );
    int ignore;
    return firstCodePoint( str[ startIndex+relIndex .. $ ], ignore );
}

int utf8AdjustOffset( String str, int offset ){
    if( str.length <= offset || offset <= 0 ){
        return offset;
    }
    while(( str[offset] & 0xC0 ) is 0x80 ){
        offset--;
    }
    return offset;
}

bool CharacterIsDefined( dchar ch ){
    return (ch in tango.text.UnicodeData.unicodeData) !is null;
}
dchar CharacterFirstToLower( String str ){
    int consumed;
    return CharacterFirstToLower( str, consumed );
}
dchar CharacterFirstToLower( String str, out int consumed ){
    dchar[1] buf;
    buf[0] = firstCodePoint( str, consumed );
    dchar[] r = tango.text.Unicode.toLower( buf );
    return r[0];
}

dchar CharacterToLower( dchar c ){
    dchar[] r = tango.text.Unicode.toLower( [c] );
    return r[0];
}
dchar CharacterToUpper( dchar c ){
    dchar[] r = tango.text.Unicode.toUpper( [c] );
    return r[0];
}
bool CharacterIsWhitespace( dchar c ){
    return tango.text.Unicode.isWhitespace( c );
}
bool CharacterIsDigit( dchar c ){
    return tango.text.Unicode.isDigit( c );
}
bool CharacterIsLetter( dchar c ){
    return tango.text.Unicode.isLetter( c );
}

bool CharacterIsLetterOrDigit( dchar c ){
    return tango.text.Unicode.isLetterOrDigit(c);
}

bool CharacterIsSpaceChar( dchar c ){
    return tango.text.Unicode.isSpace(c);
}

struct Character
{
    static alias CharacterIsLetter isLetter;
    static alias CharacterIsLetterOrDigit isLetterOrDigit;
    static alias CharacterIsSpaceChar isSpaceChar;
    static alias CharacterIsWhitespace isWhitespace;
    static alias CharacterToUpper toUpperCase;

    static char toLowerCase (char c)
    {
        return tango.text.Unicode.toLower([c])[0];
    }

    static bool isDigit (dchar c)
    {
        return tango.text.Unicode.isDigit(c);
    }
}

struct String_
{
    static String valueOf (int i)
    {
        return tango.text.convert.Integer.toString(i);
    }
}

String new_String( String cont, int offset, int len ){
    return cont[ offset .. offset+len ].dup;
}

String new_String (String cont){
    return cont.dup;
}

wchar[] new_String( wchar[] cont, int offset, int len ){
    return cont[ offset .. offset+len ].dup;
}

wchar[] new_String (wchar[] cont){
    return cont.dup;
}

public String toUpperCase( String str ){
    return tango.text.Unicode.toUpper( str );
}

public int indexOf( String str, char searched ){
    int res = tango.text.Util.locate( str, searched );
    if( res is str.length ) res = -1;
    return res;
}

public int indexOf( String str, char searched, int startpos ){
    int res = tango.text.Util.locate( str, searched, startpos );
    if( res is str.length ) res = -1;
    return res;
}

public int indexOf(String str, String ch){
    return indexOf( str, ch, 0 );
}

public int indexOf(String str, String ch, int start){
    int res = tango.text.Util.locatePattern( str, ch, start );
    if( res is str.length ) res = -1;
    return res;
}

int indexOf (T) (T[] arr, T element)
{
    foreach (i, e ; arr)
        if (e == element)
            return i;

    return -1;
}

public int lastIndexOf(String str, char ch){
    return lastIndexOf( str, ch, str.length );
}
public int lastIndexOf(String str, char ch, int formIndex){
    int res = tango.text.Util.locatePrior( str, ch, formIndex );
    if( res is str.length ) res = -1;
    return res;
}
public int lastIndexOf(String str, String ch ){
    return lastIndexOf( str, ch, str.length );
}
public int lastIndexOf(String str, String ch, int start ){
    int res = tango.text.Util.locatePatternPrior( str, ch, start );
    if( res is str.length ) res = -1;
    return res;
}

public size_t length(T)(T arr){
    return arr.length;
}

size_t size (T) (T[] arr)
{
    return arr.length;
}

public String replace( String str, char from, char to ){
    return tango.text.Util.replace( str.dup, from, to );
}

public String substring( String str, int start ){
    return str[ start .. $ ].dup;
}

public String substring( String str, int start, int end ){
    return str[ start .. end ].dup;
}

public wchar[] substring( wchar[] str, int start ){
    return str[ start .. $ ].dup;
}

public wchar[] substring( wchar[] str, int start, int end ){
    return str[ start .. end ].dup;
}

public char charAt( String str, int pos ){
    return str[ pos ];
}

public void getChars( String src, int srcBegin, int srcEnd, String dst, int dstBegin){
    dst[ dstBegin .. dstBegin + srcEnd - srcBegin ] = src[ srcBegin .. srcEnd ];
}

public void getChars( wchar[] src, int srcBegin, int srcEnd, wchar[] dst, int dstBegin){
    dst[ dstBegin .. dstBegin + srcEnd - srcBegin ] = src[ srcBegin .. srcEnd ];
}

public wchar[] toCharArray( String str ){
    return toString16( str );
}

public String fromString16( wchar[] str ){
    return toString( str );
}

public char toChar(wchar c){
    return [c].toString()[0];
}

public wchar toWChar(char c){
    return [c].toString16()[0];
}

public bool endsWith( String src, String pattern ){
    if( src.length < pattern.length ){
        return false;
    }
    return src[ $-pattern.length .. $ ] == pattern;
}

public bool equals( String src, String other ){
    return src == other;
}

public bool equals( wchar[] src, wchar[] other ){
    return src == other;
}

public bool equalsIgnoreCase( String src, String other ){
    return tango.text.Unicode.toFold(src) == tango.text.Unicode.toFold(other);
}

public int compareToIgnoreCase( String src, String other ){
    return compareTo( tango.text.Unicode.toFold(src), tango.text.Unicode.toFold(other));
}
public int compareTo( String src, String other ){
    return typeid(String).compare( cast(void*)&src, cast(void*)&other );
}

public bool startsWith( String src, String pattern ){
    if( src.length < pattern.length ){
        return false;
    }
    return src[ 0 .. pattern.length ] == pattern;
}

public String toLowerCase( String src ){
    return tango.text.Unicode.toLower( src );
}

public hash_t toHash( String src ){
    return typeid(String).getHash(&src);
}

public String trim( String str ){
    return tango.text.Util.trim( str ).dup;
}
public String intern( String str ){
    return str;
}

public char* toStringzValidPtr( String src ){
    if( src ){
        return src.toStringz();
    }
    else{
        static const String nullPtr = "\0";
        return nullPtr.ptr;
    }
}

void addElement (T) (ref T[] arr, T element)
{
	arr ~= element;
}

void removeElementAt (T) (ref T[] arr, size_t index)
{
    arr = arr[0 .. index] ~ arr[index + 1 .. $];
}

void put (K, V) (K[V] aa, K k, V v)
{
    aa[k] = v;
}

void clear (K, V) (ref K[V] aa)
{
    aa = null;
}

public alias tango.stdc.stringz.toStringz toStringz;
public alias tango.stdc.stringz.toString16z toString16z;
public alias tango.stdc.stringz.fromStringz fromStringz;
public alias tango.stdc.stringz.fromString16z fromString16z;

static String toHex(uint value, bool prefix = true, int radix = 8){
    return tango.text.convert.Integer.toString(
           value,
           radix is 10 ? "d" :
           radix is  8 ? "o" :
           radix is 16 ? "x" :
           "d" );
}

class RuntimeException : Exception {
    this( String e = null){
        super(e);
    }
    this( Exception e ){
        super(e.toString);
        next = e;
    }
    public Exception getCause() {
        return next;
    }

}
class IndexOutOfBoundsException : Exception {
    this( String e = null){
        super(e);
    }
}

class UnsupportedOperationException : RuntimeException {
    this( String e = null){
        super(e);
    }
    this( Exception e ){
        super(e.toString);
    }
}
class NumberFormatException : IllegalArgumentException {
    this( String e ){
        super(e);
    }
    this( Exception e ){
        super(e.toString);
    }
}
class NullPointerException : Exception {
    this( String e = null ){
        super(e);
    }
    this( Exception e ){
        super(e.toString);
    }
}
class IllegalStateException : Exception {
    this( String e = null ){
        super(e);
    }
    this( Exception e ){
        super(e.toString);
    }
}
class InterruptedException : Exception {
    this( String e = null ){
        super(e);
    }
    this( Exception e ){
        super(e.toString);
    }
}
class InvocationTargetException : Exception {
    Exception cause;
    this( Exception e = null, String msg = null ){
        super(msg);
        cause = e;
    }

    alias getCause getTargetException;
    Exception getCause(){
        return cause;
    }
}
class MissingResourceException : Exception {
    String classname;
    String key;
    this( String msg, String classname, String key ){
        super(msg);
        this.classname = classname;
        this.key = key;
    }
}
class ParseException : Exception {
    this( String e = null ){
        super(e);
    }
}

interface Cloneable{
}

interface Comparable {
    int compareTo(Object o);
}
interface Comparator {
    int compare(Object o1, Object o2);
}
interface EventListener{
}

class EventObject {
    protected Object source;

    public this(Object source) {
        if (source is null)
        throw new IllegalArgumentException( "null arg" );
        this.source = source;
    }

    public Object getSource() {
        return source;
    }

    public override String toString() {
        return this.classinfo.name ~ "[source=" ~ source.toString() ~ "]";
    }
}

private struct GCStats {
    size_t poolsize;        // total size of pool
    size_t usedsize;        // bytes allocated
    size_t freeblocks;      // number of blocks marked FREE
    size_t freelistsize;    // total of memory on free lists
    size_t pageblocks;      // number of blocks marked PAGE
}
private extern(C) GCStats gc_stats();

size_t RuntimeTotalMemory(){
    GCStats s = gc_stats();
    return s.poolsize;
}

String ExceptionGetLocalizedMessage( Exception e ){
    return e.msg;
}

void ExceptionPrintStackTrace( Exception e ){
    ExceptionPrintStackTrace( e, Stderr );
}

void ExceptionPrintStackTrace( Exception e, FormatOutput!(char) print ){
    Exception exception = e;
    while( exception !is null ){
        print.formatln( "Exception in {}({}): {}", exception.file, exception.line, exception.msg );
        if( exception.info !is null ){
            foreach( msg; exception.info ){
                print.formatln( "trc {}", msg );
            }
        }
        exception = exception.next;
    }
}

interface Reader{
}
interface Writer{
}


class Collator : Comparator {
    public static Collator getInstance(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    private this(){
    }
    int compare(Object o1, Object o2){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }
}

interface Enumeration {
    public bool hasMoreElements();
    public Object nextElement();
}


template arraycast(T) {
    T[] arraycast(U) (U[] u) {
        static if (
            (is (T == interface ) && is (U == interface )) ||
            (is (T == class ) && is (U == class ))) {
            return(cast(T[])u);
        }
        else {
            int l = u.length;
            T[] res;
            res.length = l;
            for (int i = 0; i < l; i++) {
                res[i] = cast(T)u[i];
            }
            return(res);
        }
    }
}

String stringcast( Object o ){
    if( auto str = cast(ArrayWrapperString) o ){
        return str.array;
    }
    return null;
}
String[] stringcast( Object[] objs ){
    String[] res = new String[](objs.length);
    foreach( idx, obj; objs ){
        res[idx] = stringcast(obj);
    }
    return res;
}
ArrayWrapperString stringcast( String str ){
    return new ArrayWrapperString( str );
}
ArrayWrapperString[] stringcast( String[] strs ){
    ArrayWrapperString[] res = new ArrayWrapperString[ strs.length ];
    foreach( idx, str; strs ){
        res[idx] = stringcast(str);
    }
    return res;
}


bool ArrayEquals(T)( T[] a, T[] b ){
    if( a.length !is b.length ){
        return false;
    }
    for( int i = 0; i < a.length; i++ ){
        static if( is( T==class) || is(T==interface)){
            if( a[i] !is null && b[i] !is null ){
                if( a[i] != b[i] ){
                    return false;
                }
            }
            else if( a[i] is null && b[i] is null ){
            }
            else{
                return false;
            }
        }
        else{
            if( a[i] != b[i] ){
                return false;
            }
        }
    }
    return true;
}

class Arrays{
    public static bool equals(Object[] a, Object[] b){
        if( a.length !is b.length ){
            return false;
        }
        for( int i = 0; i < a.length; i++ ){
            if( a[i] is null && b[i] is null ){
                continue;
            }
            if( a[i] !is null && b[i] !is null && a[i] == b[i] ){
                continue;
            }
            return false;
        }
        return true;
    }
}

int SeqIndexOf(T)( tango.util.collection.model.Seq.Seq!(T) s, T src ){
    int idx;
    foreach( e; s ){
        if( e == src ){
            return idx;
        }
        idx++;
    }
    return -1;
}
int arrayIndexOf(T)( T[] arr, T v ){
    int res = -1;
    int idx = 0;
    foreach( p; arr ){
        if( p == v){
            res = idx;
            break;
        }
        idx++;
    }
    return res;
}

/*int seqIndexOf( tango.util.collection.model.Seq.Seq!(Object) seq, Object v ){
    int res = -1;
    int idx = 0;
    foreach( p; seq ){
        if( p == v){
            res = idx;
            break;
        }
        idx++;
    }
    return res;
}*/

void PrintStackTrace( int deepth = 100, String prefix = "trc" ){
    auto e = new Exception( null );
    int idx = 0;
    const start = 3;
    foreach( msg; e.info ){
        if( idx >= start && idx < start+deepth ) {
            Trace.formatln( "{}: {}", prefix, msg );
        }
        idx++;
    }
}

struct ImportData{
    void[] data;
    String name;

    public static ImportData opCall( void[] data, String name ){
        ImportData res;
        res.data = data;
        res.name = name;
        return res;
    }
}

template getImportData(String name ){
    const ImportData getImportData = ImportData( import(name), name );
}
