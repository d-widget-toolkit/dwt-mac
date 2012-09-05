/**
 * Copyright: Copyright (c) 2008 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: 2008
 * License: $(LINK2 http://opensource.org/licenses/bsd-license.php, BSD Style)
 *
 */
module dwt.internal.objc.runtime;

import dwt.dwthelper.utils;
import dwt.internal.c.Carbon;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSRange;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.NSRect;
import bindings = dwt.internal.objc.bindings;

alias objc_ivar* Ivar;
alias objc_method* Method;
alias objc_object Protocol;

alias char* SEL;
alias objc_class* Class;
alias objc_object* id;

alias extern (C) id function(id, SEL, ...) IMP;

version (X86)
    const int STRUCT_SIZE_LIMIT = 8;

else version (PPC)
    const int STRUCT_SIZE_LIMIT = 4;

else version (X86_64)
    const int STRUCT_SIZE_LIMIT = 16;

else version (PPC64)
    const int STRUCT_SIZE_LIMIT = 16;

struct objc_object
{
    Class isa;
}

struct objc_super
{
    id receiver;
    Class clazz;

    // for dwt compatibility
    alias clazz cls;
    alias clazz super_class;
}

struct objc_class
{
    Class isa;
    Class super_class;
    const char* name;
    int versionn;
    int info;
    int instance_size;
    objc_ivar_list* ivars;
    objc_method_list** methodLists;
    objc_cache* cache;
    objc_protocol_list* protocols;
}

struct objc_ivar
{
    char* ivar_name;
    char* ivar_type;
    int ivar_offset;

    version (X86_64)
    int space;
}

struct objc_ivar_list
{
    int ivar_count;

    version (X86_64)
    int space;

    /* variable length structure */
    objc_ivar ivar_list[1];
}

struct objc_method
{
    SEL method_name;
    char* method_types;
    IMP method_imp;
}

struct objc_method_list
{
    objc_method_list* obsolete;

    int method_count;

    version (X86_64)
    int space;

    /* variable length structure */
    objc_method method_list[1];
}

struct objc_cache
{
    uint mask /* total = mask + 1 */;
    uint occupied;
    Method buckets[1];
}

struct objc_protocol_list
{
    objc_protocol_list* next;
    long count;
    Protocol* list[1];
}



alias bindings.objc_registerClassPair objc_registerClassPair;
alias bindings.class_addProtocol class_addProtocol;
alias bindings.instrumentObjcMessageSends instrumentObjcMessageSends;
alias bindings.object_getClass object_getClass;
alias bindings.object_setClass object_setClass;
alias bindings.class_getClassMethod class_getClassMethod;
alias bindings.class_getInstanceMethod class_getInstanceMethod;
alias bindings.class_getSuperclass class_getSuperclass;
alias bindings.method_setImplementation method_setImplementation;
alias bindings.class_createInstance class_createInstance;


bool class_addIvar (Class cls, String name, size_t size, byte alignment, String types)
{
    return bindings.class_addIvar(cls, name.ptr, size, alignment, types.toStringz());
}

bool class_addIvar (Class cls, String name, size_t size, byte alignment, byte[] types)
{
    return bindings.class_addIvar(cls, name.ptr, size, alignment, cast(char*) types.ptr);
}

bool class_addMethod (Class cls, SEL name, IMP imp, String types)
{
    return bindings.class_addMethod(cls, name, imp, types.toStringz());
}

IMP class_getMethodImplementation (Class cls, SEL name)
{
     return bindings.class_getMethodImplementation(cls, name);
}

String class_getName (Class cls)
{
    return fromStringz(bindings.class_getName(cls));
}

Class objc_allocateClassPair (Class superclass, String name, size_t extraBytes)
{
    return bindings.objc_allocateClassPair(superclass, name.toStringz(), extraBytes);
}

Class objc_allocateClassPair (id superclass, String name, size_t extraBytes)
{
    return bindings.objc_allocateClassPair(cast(Class) superclass, name.toStringz(), extraBytes);
}

id objc_getClass (String name)
{
    return bindings.objc_getClass(name.toStringz());
}

Protocol* objc_getProtocol (String name)
{
    return bindings.objc_getProtocol(name.toStringz());
}

id objc_lookUpClass (String name)
{
    return bindings.objc_lookUpClass(name.toStringz());
}

SEL object_getClassName (id obj)
{
    return bindings.object_getClassName(obj);
}

Ivar object_getInstanceVariable (id obj, String name, out void* outValue)
{
    return bindings.object_getInstanceVariable(obj, name.toStringz(), &outValue);
}

Ivar object_setInstanceVariable (id obj, String name, void* value)
{
    return bindings.object_setInstanceVariable(obj, name.toStringz(), value);
}

SEL sel_registerName (String str)
{
    return bindings.sel_registerName(str.toStringz());
}

id objc_msgSend (ARGS...) (id theReceiver, SEL theSelector, ARGS args)
{
    alias extern (C) id function (id, SEL, ARGS) fp;
    return (cast(fp)&bindings.objc_msgSend)(theReceiver, theSelector, args);
}

void objc_msgSend_struct (T, ARGS...) (T* result, id theReceiver, SEL theSelector, ARGS args)
{
    alias extern (C) T* function (id, SEL, ARGS) fp;
    result = (cast(fp)&bindings.objc_msgSend)(theReceiver, theSelector, args);
    //result = cast(T*) bindings.objc_msgSend(theReceiver, theSelector, args);
}

void objc_msgSend_stret (T, ARGS...) (T* stretAddr, id theReceiver, SEL theSelector, ARGS args)
{
    if (T.sizeof > STRUCT_SIZE_LIMIT)
    {
        alias extern (C) void function (T *, id, SEL, ARGS) fp;
        (cast(fp)&bindings.objc_msgSend_stret)(stretAddr, theReceiver, theSelector, args);
    }

    else
    {
        alias extern (C) T* function (id, SEL, ARGS) fp;
        stretAddr = (cast(fp)&bindings.objc_msgSend)(theReceiver, theSelector, args);
    }
}

id objc_msgSendSuper (ARGS...) (objc_super* superr, SEL op, ARGS args)
{
    alias extern (C) id function (objc_super*, SEL, ARGS) fp;
    return (cast(fp)&bindings.objc_msgSendSuper)(superr, op, args);
}

id objc_msgSendSuper_stret (T, ARGS...) (T* stretAddr, objc_super* super_, SEL theSelector, ARGS args)
{
    if (T.sizeof > STRUCT_SIZE_LIMIT)
    {
        alias extern (C) void function (T*, objc_super*, SEL, ARGS) fp;
        objc_msgSendSuper_stret(stretAddr, super_, theSelector, args);
    }

    else
    {
        alias extern (C) T* function (objc_super*, SEL, ARGS) fp;
        stretAddr = (cast(fp)&bindings.objc_msgSendSuper)(super_, theSelector, args);
    }
    return cast(id)stretAddr;
}

bool objc_msgSend_bool (ARGS...) (id theReceiver, SEL theSelector, ARGS args)
{
    alias extern (C) bool function (id, SEL, ARGS) fp;
    return (cast(fp)&bindings.objc_msgSend)(theReceiver, theSelector, args);
}

bool objc_msgSendSuper_bool (ARGS...) (objc_super* super_, SEL theSelector, ARGS args)
{
    alias extern (C) bool function (objc_super*, SEL, ARGS) fp;
    return (cast(fp)&bindings.objc_msgSendSuper)(super_, theSelector, args);
}

version (X86)
{
    double objc_msgSend_fpret(ARGS...) (id self, SEL op, ARGS args)
    {
        alias extern (C) double function (id, SEL, ARGS) fp;
        return (cast(fp)&bindings.objc_msgSend_fpret)(self, op, args);
    }
}

else
{
    double objc_msgSend_fpret(ARGS...) (id self, SEL op, ARGS args)
    {
        alias extern (C) double function (id, SEL, ARGS) fp;
        return (cast(fp)&bindings.objc_msgSend)(self, op, args);
    }
}

id objc_getMetaClass (String name)
{
    return bindings.objc_getMetaClass(name.toStringz());
}