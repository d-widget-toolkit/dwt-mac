/**
 * Copyright: Copyright (c) 2008 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: 2008
 * License: $(LINK2 http://opensource.org/licenses/bsd-license.php, BSD Style)
 * 
 */
module dwt.dwthelper.array;

version (Tango)
{
    static import tango.text.Util;
    static import tango.core.Array;
}

else
    version = Phobos;

/**
 * Appends the specified element to the end of the array.
 * 
 * Params:
 *     arr = the array to add the element to
 *     element = element to be appended to this list
 *     
 * Returns: the modified array
 * 
 */
T[] add (T) (ref T[] arr, T element)
{
    return arr ~= element;
}

/**
 * Appends the specified element to the end of the array.
 * 
 * Params:
 *     arr = the array to add the element to
 *     element = element to be appended to this list
 *     
 * Returns: the modified array
 *
 */
alias add addElement;

/**
 * Gets the element at the specified index
 * 
 * Params:
 *     arr = the array to get the element from
 *     index = the index of the element to get
 *     
 * Returns: the element at the specified index
 */
T elementAt (T) (T[] arr, int index)
in
{
    assert(index > -1 && index < arr.length);
}
body
{
    return arr[index];
}

/**
 * Gets the element at the specified index
 * 
 * Params:
 *     arr = the array to get the element from
 *     index = the index of the element to get
 *     
 * Returns: the element at the specified index
 */
alias elementAt get;

/**
 * Returns the number of elements in the specified array. 
 * 
 * Params:
 *     arr = the array to get the number of elements from
 *     
 * Returns: the number of elements in this list
 */
size_t size (T) (T[] arr)
{
    return arr.length;
}

/**
 * Removes the element at the specified position in the array
 * if it could find it and returns it.
 * Shifts any subsequent elements to the left.
 * 
 * Params:
 *     arr = the array to remove the element from
 *     index = the index of the element to be removed
 *     
 * Returns: the element that was removed or $(D_CODE null)
 * 
 * Throws: AssertException if the $(D_CODE index) argument is
 *         negative or not less than the length of this array.
 */
T remove (T) (ref T[] arr, int index)
in
{
    assert(index > -1 && index < arr.length);
}
body
{
    T ret = arr[index];

    // NOTE: Indexes are passed instead of references because DMD does
    //       not inline the reference-based version.
    void exch (size_t p1, size_t p2)
    {
        T t = arr[p1];
        arr[p1] = arr[p2];
        arr[p2] = t;
    }

    size_t cnt = 0;

    for (size_t pos = 0, len = arr.length; pos < len; ++pos)
    {
        if (pos == index)
            ++cnt;
        else
            exch(pos, pos - cnt);
    }
    
    arr = arr[0 .. $ - cnt];
    
	return ret;
}

/**
 * Removes the specified element from the array
 * if it could find it and returns it.
 * Shifts any subsequent elements to the left.
 * 
 * Params:
 *     arr = the array to remove the element from
 *     element = the element to be removed
 *     
 * Returns: the element that was removed or $(null null)
 *
 */
T remove (T) (ref T[] arr, T element)
out (result)
{
    assert(result is element);
}
body
{
    int index = arr.indexOf(element);

    if (index == -1)
        return null;

    return arr.remove(index);
}

/**
 * Removes the specified element from the array
 * if it could find it and returns it.
 * Shifts any subsequent elements to the left.
 * 
 * Params:
 *     arr = the array to remove the element from
 *     element = the element to be removed
 *     
 * Returns: the element that was removed or $(null null)
 * 
 * Throws: AssertException if the length of the array is 0
 */
alias remove removeElement;

T[] arrayIndexRemove(T, U = size_t)(T[] arr, U n) {
    if (n is 0)
        return arr[1..$];
    if (n > arr.length)
        return arr;
    if (n is arr.length-1)
        return arr[0..n-1];
    // else
    return arr[0..n] ~ arr[n+1..$];
}

/**
 * Returns the index of the first occurrence of the specified element
 * in the array, or -1 if the array does not contain the element. 
 * 
 * Params:
 *     arr = the array to get the index of the element from
 *     element = the element to find
 *     start = the index of where to start searching from
 *     
 * Returns: the index of the element or -1 if it's not in the array
 * 
 * Throws: AssertException if the return value is less than -1 or
 *         greater than the length of the array - 1.
 */
size_t indexOf (T, U = size_t) (T[] arr, T[] match, U start = 0)
in
{
    assert(start >= 0);
}
body
{
    size_t index = tango.text.Util.locatePattern(arr, match, start);
    
    if (index != arr.length)
        return index;

    else
        return -1;
}

/**
 * Returns the index of the first occurrence of the specified element
 * in the array, or -1 if the array does not contain the element. 
 * 
 * Params:
 *     arr = the array to get the index of the element from
 *     element = the element to find
 *     start = the index of where to start searching from
 *     
 * Returns: the index of the element or -1 if it's not in the array
 * 
 * Throws: AssertException if the return value is less than -1 or
 *         greater than the length of the array - 1.
 */
size_t indexOf (T, U = size_t) (T[] arr, T element, U start = 0)
in
{
    assert(start >= 0);
}
body
{
    size_t index;

    version (Tango)
        index = cast(size_t) tango.text.Util.locate(arr, element, start);

    else
    {
        if (start > arr.length)
            start = arr.length;

        index = cast(size_t) privateIndexOf(arr.ptr, element, arr.length - start) + start;
    }

    if (index != arr.length)
        return index;
    else
        return -1;

    version (Phobos)
    {
        // tango.text.Util.locate
        uint privateIndexOf (T* str, T match, uint length)
        {
            version (D_InlineAsm_X86)
            {
                static if (T.sizeof == 1)
                {
                    asm 
                    {
                            mov   EDI, str;
                            mov   ECX, length;
                            movzx EAX, match;
                            mov   ESI, ECX;
                            and   ESI, ESI;            
                            jz    end;        
                        
                            cld;
                            repnz;
                            scasb;
                            jnz   end;
                            sub   ESI, ECX;
                            dec   ESI;
                        end:;
                            mov   EAX, ESI;
                    }
                }
                else static if (T.sizeof == 2)
                {
                    asm
                    {
                            mov   EDI, str;
                            mov   ECX, length;
                            movzx EAX, match;
                            mov   ESI, ECX;
                            and   ESI, ESI;            
                            jz    end;        
                        
                            cld;
                            repnz;
                            scasw;
                            jnz   end;
                            sub   ESI, ECX;
                            dec   ESI;
                        end:;
                            mov   EAX, ESI;
                    }
                }
                
                else static if (T.sizeof == 4)
                {
                    asm
                    {
                            mov   EDI, str;
                            mov   ECX, length;
                            mov   EAX, match;
                            mov   ESI, ECX;
                            and   ESI, ESI;            
                            jz    end;        
                        
                            cld;
                            repnz;
                            scasd;
                            jnz   end;
                            sub   ESI, ECX;
                            dec   ESI;
                        end:;
                            mov   EAX, ESI;
                    }
                }
                
                else
                {
                    auto len = length;
                    
                    for (auto p = str - 1; len--; )
                        if (*++p is match)
                            return p - str;
                    
                    return length;
                }
            }
            
            else
            {
                auto len = length;
                
                for (auto p = str - 1; len--; )
                    if (*++p is match)
                        return p - str;
                
                return length;
            }
        }
    }
}