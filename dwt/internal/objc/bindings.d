/**
 * Copyright: Copyright (c) 2008 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: 2008
 * License: $(LINK2 http://opensource.org/licenses/bsd-license.php, BSD Style)
 * 
 */
module dwt.internal.objc.bindings;

import dwt.internal.c.Carbon;
import dwt.internal.objc.runtime;

extern (C):

BOOL class_addIvar (Class cls, /*const*/char* name, size_t size, byte alignment, /*const*/char* types);
BOOL class_addMethod (Class cls, SEL name, IMP imp, /*const*/char* types);
BOOL class_addProtocol(Class cls, Protocol* protocol);
IMP class_getMethodImplementation(Class cls, SEL name);
/*const*/ char* class_getName(Class cls);
Class objc_allocateClassPair (Class superclass, /*const*/char* name, size_t extraBytes);
id objc_getClass (/*const*/char* name);
Protocol* objc_getProtocol(/*const*/ char* name);
id objc_lookUpClass (/*const*/char* name);
void objc_registerClassPair (Class cls);
Class object_getClass (id object);
/*const*/char* object_getClassName (id obj);
Class object_setClass (id object, Class cls);
Ivar object_getInstanceVariable (id obj, /*const*/char* name, void** outValue);
Ivar object_setInstanceVariable (id obj, /*const*/char* name, void* value);
SEL sel_registerName (/*const*/char* str);
id objc_msgSend (id theReceiver, SEL theSelector, ...);
void objc_msgSend_stret(void* stretAddr, id theReceiver, SEL theSelector, ...);
id objc_msgSendSuper (objc_super* superr, SEL op, ...);
Method class_getClassMethod (Class aClass, SEL aSelector);
Method class_getInstanceMethod (Class aClass, SEL aSelector);
Class class_getSuperclass (Class cls);
IMP method_setImplementation (Method method, IMP imp);
id class_createInstance (Class cls, size_t extraBytes);
id objc_getMetaClass (char* name);

void instrumentObjcMessageSends(bool val);

version (X86)
    double objc_msgSend_fpret(id self, SEL op, ...);
