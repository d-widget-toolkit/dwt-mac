/*******************************************************************************
 * Copyright (c) 2000, 2009 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *
 * Port to the D programming language:
 *     Jacob Carlborg <doob@me.com>
 *******************************************************************************/
module dwt.accessibility.SWTAccessibleDelegate;

import dwt.dwthelper.utils;

import dwt.accessibility.Accessible;
import dwt.DWT;
import dwt.internal.C;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.OS;
import cocoa = dwt.internal.cocoa.id;
import objc = dwt.internal.objc.runtime;

class SWTAccessibleDelegate : NSObject {

    /**
     * Accessible Key: The string constant for looking up the accessible
     * for a control using <code>getData(String)</code>. When an accessible
     * is created for a control, it is stored as a property in the control
     * using <code>setData(String, Object)</code>.
     */
    static const String ACCESSIBLE_KEY = "Accessible"; //$NON-NLS-1$
    static const String SWT_OBJECT = "SWT_OBJECT";

    static objc.IMP proc2Args, proc3Args, proc4Args;

    Accessible accessibleParent;
    void* delegateJniRef;
    int childID;

    NSArray attributeNames = null;
    NSArray parameterizedAttributeNames = null;
    NSArray actionNames = null;

    static this (){
        ClassInfo clazz = SWTAccessibleDelegate.classinfo;

        proc2Args = cast(objc.IMP) &accessibleProc2;

        proc3Args = cast(objc.IMP) &accessibleProc3;

        proc4Args = cast(objc.IMP) &accessibleProc4;

        // Accessible custom controls need to implement the NSAccessibility protocol. To do that,
        // we dynamically add the methods to the control's class that are required
        // by NSAccessibility. Then, when external assistive technology services are used,
        // those methods get called to provide the needed information.

        String className = "SWTAccessibleDelegate";

        // TODO: These should either move out of Display or be accessible to this class.
        byte[] types = ['*','\0'];
        size_t size = C.PTR_SIZEOF, align_ = C.PTR_SIZEOF is 4 ? 2 : 3;

        objc.Class cls = OS.objc_allocateClassPair(OS.class_NSObject, className, 0);
        OS.class_addIvar(cls, SWT_OBJECT, size, cast(byte)align_, cast(char[])types);

        // Add the NSAccessibility overrides
        OS.class_addMethod(cls, OS.sel_accessibilityActionNames, proc2Args, "@:");
        OS.class_addMethod(cls, OS.sel_accessibilityAttributeNames, proc2Args, "@:");
        OS.class_addMethod(cls, OS.sel_accessibilityParameterizedAttributeNames, proc2Args, "@:");
        OS.class_addMethod(cls, OS.sel_accessibilityIsIgnored, proc2Args, "@:");
        OS.class_addMethod(cls, OS.sel_accessibilityFocusedUIElement, proc2Args, "@:");

        OS.class_addMethod(cls, OS.sel_accessibilityAttributeValue_, proc3Args, "@:@");
        OS.class_addMethod(cls, OS.sel_accessibilityHitTest_, proc3Args, "@:{NSPoint}");
        OS.class_addMethod(cls, OS.sel_accessibilityIsAttributeSettable_, proc3Args, "@:@");
        OS.class_addMethod(cls, OS.sel_accessibilityActionDescription_, proc3Args, "@:@");
        OS.class_addMethod(cls, OS.sel_accessibilityPerformAction_, proc3Args, "@:@");

        OS.class_addMethod(cls, OS.sel_accessibilityAttributeValue_forParameter_, proc4Args, "@:@@");
        OS.class_addMethod(cls, OS.sel_accessibilitySetValue_forAttribute_, proc4Args, "@:@@");

        OS.objc_registerClassPair(cls);
    }


    public this(Accessible accessible, int childID) {
        super(cast(objc.id) null);
        this.accessibleParent = accessible;
        this.childID = childID;
        alloc().init();
        delegateJniRef = OS.NewGlobalRef(this);
        if (delegateJniRef is null) DWT.error(DWT.ERROR_NO_HANDLES);
        OS.object_setInstanceVariable(this.id, SWT_OBJECT, delegateJniRef);
    }

    NSArray accessibilityActionNames() {

        if (actionNames !is null)
            return retainedAutoreleased(actionNames);

        actionNames = accessibleParent.internal_accessibilityActionNames(childID);
        actionNames.retain();
        return retainedAutoreleased(actionNames);
    }

    NSArray accessibilityAttributeNames() {

        if (attributeNames !is null)
            return retainedAutoreleased(attributeNames);

        attributeNames = accessibleParent.internal_accessibilityAttributeNames(childID);
        attributeNames.retain();
        return retainedAutoreleased(attributeNames);
    }

    cocoa.id accessibilityAttributeValue(NSString attribute) {
        return accessibleParent.internal_accessibilityAttributeValue(attribute, childID);
    }

    // parameterized attribute methods
    NSArray accessibilityParameterizedAttributeNames() {

        if (parameterizedAttributeNames !is null)
            return retainedAutoreleased(parameterizedAttributeNames);

        parameterizedAttributeNames = accessibleParent.internal_accessibilityParameterizedAttributeNames(childID);
        parameterizedAttributeNames.retain();
        return retainedAutoreleased(parameterizedAttributeNames);
    }

    cocoa.id accessibilityAttributeValue_forParameter(NSString attribute, cocoa.id parameter) {
        return accessibleParent.internal_accessibilityAttributeValue_forParameter(attribute, parameter, childID);
    }

    // Return YES if the UIElement doesn't show up to the outside world - i.e. its parent should return the UIElement's children as its own - cutting the UIElement out. E.g. NSControls are ignored when they are single-celled.
    bool accessibilityIsIgnored() {
        return accessibleParent.internal_accessibilityIsIgnored(childID);
    }

    bool accessibilityIsAttributeSettable(NSString attribute) {
        return false;
    }

    // Returns the deepest descendant of the UIElement hierarchy that contains the point. You can assume the point has already been determined to lie within the receiver. Override this method to do deeper hit testing within a UIElement - e.g. a NSMatrix would test its cells. The point is bottom-left relative screen coordinates.
    cocoa.id accessibilityHitTest(NSPoint point) {
        return accessibleParent.internal_accessibilityHitTest(point, childID);
    }

    // Returns the UI Element that has the focus. You can assume that the search for the focus has already been narrowed down to the reciever. Override this method to do a deeper search with a UIElement - e.g. a NSMatrix would determine if one of its cells has the focus.
    cocoa.id accessibilityFocusedUIElement() {
        return accessibleParent.internal_accessibilityFocusedUIElement(childID);
    }

    void accessibilityPerformAction(NSString action) {
        accessibleParent.internal_accessibilityPerformAction(action, childID);
    }

    cocoa.id accessibilityActionDescription(NSString action) {
        return accessibleParent.internal_accessibilityActionDescription(action, childID);
    }


    void accessibilitySetValue_forAttribute(cocoa.id value, NSString attribute) {
    }

    static NSArray retainedAutoreleased(NSArray inObject) {
        cocoa.id temp = inObject.retain();
        cocoa.id temp2 = (new NSObject(temp.id)).autorelease();
        return new NSArray(temp2.id);
    }
    extern (C){
    static objc.id accessibleProc2(objc.id id, objc.SEL sel) {
        SWTAccessibleDelegate swtAcc = getAccessibleDelegate(id);
        if (swtAcc is null) return null;

        if (sel is OS.sel_accessibilityAttributeNames) {
            NSArray retObject = swtAcc.accessibilityAttributeNames();
            return (retObject is null ? null : retObject.id);
        } else if (sel is OS.sel_accessibilityActionNames) {
            NSArray retObject = swtAcc.accessibilityActionNames();
            return (retObject is null ? null : retObject.id);
        } else if (sel is OS.sel_accessibilityParameterizedAttributeNames) {
            NSArray retObject = swtAcc.accessibilityParameterizedAttributeNames();
            return (retObject is null ? null : retObject.id);
        } else if (sel is OS.sel_accessibilityIsIgnored) {
            bool retVal = swtAcc.accessibilityIsIgnored();
            return (retVal ? cast(objc.id)1 : null);
        } else if (sel is OS.sel_accessibilityFocusedUIElement) {
            cocoa.id retObject = swtAcc.accessibilityFocusedUIElement();
            return (retObject is null ? null : retObject.id);
        }

        return null;
    }

    static objc.id accessibleProc3(objc.id id, objc.SEL sel, objc.id arg0) {
        SWTAccessibleDelegate swtAcc = getAccessibleDelegate(id);
        if (swtAcc is null) return null;

        if (sel is OS.sel_accessibilityAttributeValue_) {
            NSString attribute = new NSString(arg0);
            cocoa.id retObject = swtAcc.accessibilityAttributeValue(attribute);
            return (retObject is null ? null : retObject.id);
        } else if (sel is OS.sel_accessibilityHitTest_) {
            NSPoint point= NSPoint();
            OS.memmove(&point, arg0, NSPoint.sizeof);
            cocoa.id retObject = swtAcc.accessibilityHitTest(point);
            return (retObject is null ? null : retObject.id);
        } else if (sel is OS.sel_accessibilityIsAttributeSettable_) {
            NSString attribute = new NSString(arg0);
            return (swtAcc.accessibilityIsAttributeSettable(attribute) ? cast(objc.id) 1 : null);
        } else if (sel is OS.sel_accessibilityActionDescription_) {
            NSString action = new NSString(arg0);
            cocoa.id retObject = swtAcc.accessibilityActionDescription(action);
            return (retObject is null ? null : retObject.id);
        } else if (sel is OS.sel_accessibilityPerformAction_) {
            NSString action = new NSString(arg0);
            swtAcc.accessibilityPerformAction(action);
        }

        return null;
    }

    static objc.id accessibleProc4(objc.id id, objc.SEL sel, objc.id arg0, objc.id arg1) {
        SWTAccessibleDelegate swtAcc = getAccessibleDelegate(id);
        if (swtAcc is null) return null;

        if (sel is OS.sel_accessibilityAttributeValue_forParameter_) {
            NSString attribute = new NSString(arg0);
            cocoa.id parameter = new cocoa.id(arg1);
            cocoa.id retObject = swtAcc.accessibilityAttributeValue_forParameter(attribute, parameter);
            return (retObject is null ? null : retObject.id);
        } else if (sel is OS.sel_accessibilitySetValue_forAttribute_) {
            cocoa.id value = new cocoa.id(arg0);
            NSString attribute = new NSString(arg1);
            swtAcc.accessibilitySetValue_forAttribute(value, attribute);
        }

        return null;
    }
    }
    static SWTAccessibleDelegate getAccessibleDelegate(objc.id id) {
        if (id is null) return null;
        void* jniRef;
        OS.object_getInstanceVariable(id, SWT_OBJECT, jniRef);
        if (jniRef is null) return null;
        return cast(SWTAccessibleDelegate)OS.JNIGetObject(jniRef);
    }

    public void internal_dispose_SWTAccessibleDelegate() {
        if (actionNames !is null) actionNames.release();
        actionNames = null;
        if (attributeNames !is null) attributeNames.release();
        attributeNames = null;
        if (parameterizedAttributeNames !is null) parameterizedAttributeNames.release();
        parameterizedAttributeNames = null;

        if (delegateJniRef !is null) OS.DeleteGlobalRef(delegateJniRef);
        delegateJniRef = null;
        OS.object_setInstanceVariable(this.id, SWT_OBJECT, null);
    }

}
