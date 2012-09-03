## DWT Mac OS X

This is a temporarily repository for the Mac OS X port of
[DWT](https://github.com/d-widget-toolkit/dwt).

Note, this is a port of SWT 3.5.

## Contributing

The plan is to finishing the Mac OS X port in this repository using D1 and Tango. When the
port is finished we will move the repository to a new one and integrated it with the
[DWT](https://github.com/d-widget-toolkit/dwt) repository. When that is done we will port the
code to D2 and drop the support for D1.

There's an archive with prepared sources. These are the original Java files with a few
modifications:

* All trailing whitespace are removed
* All tabs are converted to spaces
* Imports are expanded
* SWT is replaced with DWT in a few places

[https://github.com/d-widget-toolkit/dwt-mac/downloads](https://github.com/d-widget-toolkit/dwt-mac/downloads)

### Types

#### 32/64 bits

We're aiming to support both 32 and 64bit systems in the same repository with this port.

#### Pointers

In Java a pointer is represented as an integer, usually declared as `int /*long*/`. This will
mean `int` is used on 32bit systems and `long` is used on 64bit systems. These integer types
are replaced with their actual native pointer type.

#### Integers

In many cases a type declared as `int /*long*/` will mean an integer type with different size
on different architectures. Here we again replace it with the actual native type, for example
`NSInteger`, declared in `dwt.internal.objc.cocoa.Cocoa`.

#### Floating points

Floating point numbers declared as `float /*double*/` should in most cases be replaced with
`CGFloat`, declared in `dwt.internal.c.Carbon`.

#### The id type

The `id` type is a native used to store Objective-C objects. This is the only way to store an
Objective-C object in D. In Objective-C this type can store any type of value, even
non-objects.

See also [The Objective-C Programming Language](http://developer.apple.com/library/ios/#documentation/cocoa/conceptual/objectivec/Chapters/ocObjectsClasses.html)

There's also type named `id` in the Java code. This is a regular class containing a pointer to
an Objective-C object, represented with an integer in Java and the native `id` type in D. This
is the base class of all Objective-C classes in D/Java.

For more info about bridging Objective-C and D see: [http://www.dsource.org/projects/dstep](http://www.dsource.org/projects/dstep)

For more info about Objective-C see:

* [The Objective-C Programming Language](http://developer.apple.com/library/ios/#documentation/cocoa/conceptual/objectivec/Chapters/ocObjectsClasses.html)
* [Objective-C Runtime Reference](https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/ObjCRuntimeRef/Reference/reference.html)

### Callbacks

The Callback class is completely remove and replaced with native function pointers.

### The dwt.internal.cocoa.OS module

All native functions declared in the Java file are replaced with aliases in the D code. The
actual function declaration are in another module, usually some of the following modules:

* dwt.internal.c.Carbon
* dwt.internal.c.custom
* dwt.internal.objc.cocoa.Cocoa
* dwt.internal.objc.runtime
* tango.stdc.*

The same approach is used for integer values representing enums, but these are replaced with
actual enums on a need to need basis.

### The binding modules

Any module named `binding` contains bindings to C functions. These modules are rarely used
directly but are instead brought into scope by aliasing or wrapping them into another module.
For example `class_addIvar` is declared in `dwt.internal.objc.bindings` but are then later
wrapped in `dwt.internal.objc.runtime`. `class_addProtocol` declared in `dwt.internal.objc.bindings`
and is then aliased into scope in `dwt.internal.objc.runtime`.

The reason for this is to be able to wrap some methods and convert the arguments, i.e.
converting D strings to C strings.
