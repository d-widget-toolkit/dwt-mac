module dwt.dwthelper.WeakHashMap;


/+
    Is not yet 'weak'
+/
class WeakHashMap {

    static class Ref {
        size_t ptr;
        this(Object k){
            ptr = cast(size_t)cast(void*)k;
        }
    }

    Object[ Ref ] data;

    public void add (Object key, Object element){
        auto k = new Ref(key);
        data[ k ] = element;
    }
    public void removeKey (Object key){
        scope k = new Ref(key);
        data.remove( k );
    }
    public Object get(Object key){
        scope k = new Ref(key);
        if( auto p = k in data ){
            return *p;
        }
        return null;
    }
}
