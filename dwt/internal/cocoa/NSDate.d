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
 *     Jacob Carlborg <doob@me.com>
 *******************************************************************************/
module dwt.internal.cocoa.NSDate;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSCalendarDate;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSTimeZone;
import dwt.internal.cocoa.OS;
import objc = dwt.internal.objc.runtime;

alias double NSTimeInterval;

public class NSDate : NSObject {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public NSCalendarDate dateWithCalendarFormat(NSString format, NSTimeZone aTimeZone) {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_dateWithCalendarFormat_timeZone_, format !is null ? format.id : null, aTimeZone !is null ? aTimeZone.id : null);
    return result !is null ? new NSCalendarDate(result) : null;
}

public static NSDate dateWithTimeIntervalSinceNow(double secs) {
    objc.id result = OS.objc_msgSend(OS.class_NSDate, OS.sel_dateWithTimeIntervalSinceNow_, secs);
    return result !is null ? new NSDate(result) : null;
}

public static NSDate distantFuture() {
    objc.id result = OS.objc_msgSend(OS.class_NSDate, OS.sel_distantFuture);
    return result !is null ? new NSDate(result) : null;
}

}
