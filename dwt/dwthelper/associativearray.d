/**
 * Copyright: Copyright (c) 2008 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: 2008
 * License: $(LINK2 http://opensource.org/licenses/bsd-license.php, BSD Style)
 *
 */
module dwt.dwthelper.associativearray;

/**
 * Returns the value to which the specified key is mapped,
 * or ($D_CODE null) if this associative array contains no mapping for the key.
 *
 * $(P More formally, if the specified associative array contains a mapping from a key
 * $(D_CODE k) to a value $(D_CODE v) such that $(D_CODE (key==null ? k==null :
 * key.equals(k))), then this method returns $(D_CODE v); otherwise
 * it returns $(D_CODE null).  (There can be at most one such mapping.))
 *
 * Params:
 *     aa = the associative array to get the value from
 *     key = the key whose associated value is to be returned
 *
 *
 * Returns: the value to which the specified key is mapped, or
 * 			$(D_CODE null) if this map contains no mapping for the key
 *
 * Throws: AssertException if any paramter is invalid
 */
V get (K, V) (ref V[K] aa, K key)
in
{
	assert(aa.length > 0);
}
body
{
	return aa[key];
}

/**
 * Associates the specified value with the specified key in the specified
 * associative array. If the associative array previously contained a mapping for
 * the key, the old value is replaced by the specified value.  (An associative array
 * <tt>aa</tt> is said to contain a mapping for a key <tt>k</tt> if and only
 * if $(LINK2 #containsKey(Object), m.containsKey(k)) would return
 * <tt>true</tt>.)
 *
 * Params:
 *     aa = the associative array to add the key/value pair to
 *     key = key with which the specified value is to be associated
 *     value = value to be associated with the specified key
 *
 * Returns: the previous value associated with <tt>key</tt>, or
 *         <tt>null</tt> if there was no mapping for <tt>key</tt>.
 *         (A <tt>null</tt> return can also indicate that the
 *         associative array previously associated <tt>null</tt>
 *         with <tt>key</tt>.)
 */
V put (K, V) (ref V[K] aa, K key, V value)
{
	return aa[key] = value;
}

/**
 * Removes the mapping for a key from the specified
 * associative array if it is present. More formally,
 * if the associative array contains a mapping
 * from key <tt>k</tt> to value <tt>v</tt> such that
 * $(D_CODE (key==null ?  k==null : key.equals(k))), that mapping
 * is removed.  (The associative array can contain at most one such mapping.)
 *
 * $(P Returns the value to which the associative array previously associated the key,
 * or <tt>null</tt> if the map contained no mapping for the key.)
 *
 * Params:
 *     aa = the associative array to remove the key/value pair from
 *     key = key whose mapping is to be removed from the associative array
 *
 * Returns:
 */
V remove (K, V) (ref V[K] aa, K key)
{
	V v = aa[key];
	aa.remove(k);

	return v;
}

/**
 * Returns <tt>true</tt> if the specified
 * associative array contains no key-value mappings.
 *
 * Params:
 *     aa = the associative array to check if it's empty
 *
 * Returns: <tt>true</tt> if the specified
 * 			associative array contains no key-value mappings
 */
bool isEmpty (K, V) (ref V[K] aa)
{
	return aa.length == 0;
}


/**
 * Returns a array of the values contained in the
 * specifed associative array. The array is backed by
 * the associative array(if it contains classes or pointers),
 * so changes to the associative array are reflected in
 * the array, and vice-versa. If the associative array is
 * modified while an iteration over the collection is in progress
 * (except through the iterator's own <tt>remove</tt> operation),
 * the results of the iteration are undefined.  The collection
 * supports element removal, which removes the corresponding
 * mapping from the map, via the <tt>Iterator.remove</tt>,
 * <tt>Collection.remove</tt>, <tt>removeAll</tt>,
 * <tt>retainAll</tt> and <tt>clear</tt> operations.  It does not
 * support the <tt>add</tt> or <tt>addAll</tt> operations.
 *
 * Params:
 *     aa = the associative array to get the values from
 *
 * Returns: a collection view of the values contained in this map
 */
V[] values (K, V) (ref V[K] aa)
{
	return aa.values;
}

/**
 * Removes all mappings from this map
 */
void clear (K, V) (ref V[K] aa)
{
    foreach (k, v ; aa)
        aa.remove(k);
}

/**
 * Returns the number of key-value mappings in
 * the specifed associative array
 *
 * Params:
 *     aa = the associative array to get the number of key-value mappings from
 *
 * Returns: the number of key-value mappings in the associative array
 */
/*int size (K, V) (V[K] aa)
{
	aa.length;
}*/