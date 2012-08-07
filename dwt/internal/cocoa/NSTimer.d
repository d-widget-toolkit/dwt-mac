/*******************************************************************************
 * Copyright (c) 2000, 2009 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *    IBM Corporation - initial API and implementation
 *     
 * Port to the D programming language:
 *    Jacob Carlborg <doob@me.com>
 *******************************************************************************/
module dwt.internal.cocoa.NSTimer;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSDate;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

public class NSTimer : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void invalidate() {
    OS.objc_msgSend(this.id, OS.sel_invalidate);
}

public static NSTimer scheduledTimerWithTimeInterval(NSTimeInterval ti, cocoa.id aTarget, objc.SEL aSelector, cocoa.id userInfo, bool yesOrNo) {
    objc.id result = OS.objc_msgSend(OS.class_NSTimer, OS.sel_scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_, ti, aTarget !is null ? aTarget.id : null, aSelector, userInfo !is null ? userInfo.id : null, yesOrNo);
    return result !is null ? new NSTimer(result) : null;
}

public void setFireDate(NSDate date) {
    OS.objc_msgSend(this.id, OS.sel_setFireDate_, date !is null ? date.id : null);
}

public cocoa.id userInfo() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_userInfo);
    return result !is null ? new cocoa.id(result) : null;
}

}
