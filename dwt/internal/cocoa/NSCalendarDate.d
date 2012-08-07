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
module dwt.internal.cocoa.NSCalendarDate;

import dwt.dwthelper.utils;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSDate;
import dwt.internal.cocoa.NSTimeZone;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSCalendarDate : NSDate {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public static NSCalendarDate calendarDate() {
    objc.id result = OS.objc_msgSend(OS.class_NSCalendarDate, OS.sel_calendarDate);
    return result !is null ? new NSCalendarDate(result) : null;
}

public static NSCalendarDate dateWithYear(NSInteger year, NSUInteger month, NSUInteger day, NSUInteger hour, NSUInteger minute, NSUInteger second, NSTimeZone aTimeZone) {
    objc.id result = OS.objc_msgSend(OS.class_NSCalendarDate, OS.sel_dateWithYear_month_day_hour_minute_second_timeZone_, year, month, day, hour, minute, second, aTimeZone !is null ? aTimeZone.id : null);
    return result !is null ? new NSCalendarDate(result) : null;
}

public NSInteger dayOfMonth() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_dayOfMonth);
}

public NSInteger hourOfDay() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_hourOfDay);
}

public NSInteger minuteOfHour() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_minuteOfHour);
}

public NSInteger monthOfYear() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_monthOfYear);
}

public NSInteger secondOfMinute() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_secondOfMinute);
}

public NSTimeZone timeZone() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_timeZone);
    return result !is null ? new NSTimeZone(result) : null;
}

public NSInteger yearOfCommonEra() {
    return cast(NSInteger) OS.objc_msgSend(this.id, OS.sel_yearOfCommonEra);
}

public static NSDate dateWithTimeIntervalSinceNow(double secs) {
    objc.id result = OS.objc_msgSend(OS.class_NSCalendarDate, OS.sel_dateWithTimeIntervalSinceNow_, secs);
    return result !is null ? new NSCalendarDate(result) : null;
}

public static NSDate distantFuture() {
    objc.id result = OS.objc_msgSend(OS.class_NSCalendarDate, OS.sel_distantFuture);
    return result !is null ? new NSCalendarDate(result) : null;
}

}
