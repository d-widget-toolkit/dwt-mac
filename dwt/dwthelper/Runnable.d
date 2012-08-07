/**
 * Authors: Frank Benoit <benoit@tionex.de>
 */
module dwt.dwthelper.Runnable;


import tango.core.Tuple;
import tango.core.Traits;

public interface Runnable  {

    public abstract void run();

}

class _DgRunnableT(Dg,T...) : Runnable {

    alias ParameterTupleOf!(Dg) DgArgs;
    static assert( is(DgArgs == Tuple!(T)),
                "Delegate args not correct" );

    Dg dg;
    T t;

    private this( Dg dg, T t ){
        this.dg = dg;
        static if( T.length > 0 ){
            this.t = t;
        }
    }

    void run( ){
        dg(t);
    }
}

_DgRunnableT!(Dg,T) dgRunnable(Dg,T...)( Dg dg, T args ){
    return new _DgRunnableT!(Dg,T)(dg,args);
}