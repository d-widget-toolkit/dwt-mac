/**
 * Authors: Frank Benoit <keinfarbton@googlemail.com>
 */
module dwt.dwthelper.File;

import dwt.dwthelper.utils;

static import tango.io.model.IFile;
static import tango.io.FilePath;
static import tango.io.FileSystem;
import tango.sys.Environment;

public class File {

    public static char separatorChar;
    public static char[] separator;
    public static char pathSeparatorChar;
    public static char[] pathSeparator;

    private tango.io.FilePath.FilePath mFilePath;

    static this(){
        separator = tango.io.model.IFile.FileConst.PathSeparatorString;
        separatorChar = tango.io.model.IFile.FileConst.PathSeparatorChar;
        pathSeparator = tango.io.model.IFile.FileConst.SystemPathString;
        pathSeparatorChar = tango.io.model.IFile.FileConst.SystemPathChar;
    }

    public this ( char[] pathname ){
        mFilePath = new tango.io.FilePath.FilePath( pathname );
    }

    public this ( char[] parent, char[] child ){
        mFilePath = new tango.io.FilePath.FilePath( tango.io.FilePath.FilePath.join( parent, child ) );
    }

    public this ( dwt.dwthelper.File.File parent, char[] child ){
        mFilePath = new tango.io.FilePath.FilePath( tango.io.FilePath.FilePath.join( parent.mFilePath.toString, child ) );
    }

    public int getPrefixLength(){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }

    public char[] getName(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    public char[] getParent(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    public dwt.dwthelper.File.File getParentFile(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    public char[] getPath(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    public bool isAbsolute(){
        implMissing( __FILE__, __LINE__ );
        return false;
    }

    public char[] getAbsolutePath(){
        return mFilePath.absolute(Environment.cwd).toString;
    }
    public dwt.dwthelper.File.File getAbsoluteFile(){
        return new File( getAbsolutePath() );
    }

    public char[] getCanonicalPath(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    public dwt.dwthelper.File.File getCanonicalFile(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    public bool canRead(){
        implMissing( __FILE__, __LINE__ );
        return false;
    }

    public bool canWrite(){
        return mFilePath.isWritable;
    }

    public bool exists(){
        return mFilePath.exists;
    }

    public bool isDirectory(){
        return mFilePath.isFolder;
    }

    public bool isFile(){
        implMissing( __FILE__, __LINE__ );
        return false;
    }

    public bool isHidden(){
        implMissing( __FILE__, __LINE__ );
        return false;
    }

    public long lastModified(){
        implMissing( __FILE__, __LINE__ );
        return 0L;
    }

    public long length(){
        implMissing( __FILE__, __LINE__ );
        return 0L;
    }

    public bool createNewFile(){
        implMissing( __FILE__, __LINE__ );
        return false;
    }

    public bool delete_KEYWORDESCAPE(){
        implMissing( __FILE__, __LINE__ );
        return false;
    }

    public void deleteOnExit(){
        implMissing( __FILE__, __LINE__ );
    }

    public char[][] list(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    public dwt.dwthelper.File.File[] listFiles(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    public bool mkdir(){
        implMissing( __FILE__, __LINE__ );
        return false;
    }

    public bool mkdirs(){
        implMissing( __FILE__, __LINE__ );
        return false;
    }

    public bool renameTo( dwt.dwthelper.File.File dest ){
        implMissing( __FILE__, __LINE__ );
        return false;
    }

    public bool setLastModified( long time ){
        implMissing( __FILE__, __LINE__ );
        return false;
    }

    public bool setReadOnly(){
        implMissing( __FILE__, __LINE__ );
        return false;
    }

    public static dwt.dwthelper.File.File[] listRoots(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    public static dwt.dwthelper.File.File createTempFile( char[] prefix, char[] suffix, dwt.dwthelper.File.File directory ){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    public static dwt.dwthelper.File.File createTempFile( char[] prefix, char[] suffix ){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    public int compareTo( dwt.dwthelper.File.File pathname ){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }

    public char[] toString(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }


}


