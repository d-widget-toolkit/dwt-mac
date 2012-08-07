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
module dwt.internal.cocoa.NSNumberFormatter;

import dwt.dwthelper.utils;
import dwt.internal.c.Carbon;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSFormatter;
import dwt.internal.cocoa.NSNumber;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSNumberFormatter : NSFormatter {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public bool allowsFloats() {
    return OS.objc_msgSend_bool(this.id, OS.sel_allowsFloats);
}

public bool alwaysShowsDecimalSeparator() {
    return OS.objc_msgSend_bool(this.id, OS.sel_alwaysShowsDecimalSeparator);
}

public NSString decimalSeparator() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_decimalSeparator);
    return result !is null ? new NSString(result) : null;
}

public NSNumber maximum() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_maximum);
    return result !is null ? new NSNumber(result) : null;
}

public NSUInteger maximumFractionDigits() {
    return cast(NSUInteger) OS.objc_msgSend(this.id, OS.sel_maximumFractionDigits);
}

public NSUInteger maximumIntegerDigits() {
    return cast(NSUInteger) OS.objc_msgSend(this.id, OS.sel_maximumIntegerDigits);
}

public NSNumber minimum() {
    objc.id result = OS.objc_msgSend(this.id, OS.sel_minimum);
    return result !is null ? new NSNumber(result) : null;
}

public void setAllowsFloats(bool flag) {
    OS.objc_msgSend(this.id, OS.sel_setAllowsFloats_, flag);
}

public void setMaximum(NSNumber number) {
    OS.objc_msgSend(this.id, OS.sel_setMaximum_, number !is null ? number.id : null);
}

public void setMaximumFractionDigits(NSUInteger number) {
    OS.objc_msgSend(this.id, OS.sel_setMaximumFractionDigits_, number);
}

public void setMaximumIntegerDigits(NSUInteger number) {
    OS.objc_msgSend(this.id, OS.sel_setMaximumIntegerDigits_, number);
}

public void setMinimum(NSNumber number) {
    OS.objc_msgSend(this.id, OS.sel_setMinimum_, number !is null ? number.id : null);
}

public void setMinimumFractionDigits(NSUInteger number) {
    OS.objc_msgSend(this.id, OS.sel_setMinimumFractionDigits_, number);
}

public void setMinimumIntegerDigits(NSUInteger number) {
    OS.objc_msgSend(this.id, OS.sel_setMinimumIntegerDigits_, number);
}

public void setNumberStyle(NSNumberFormatterStyle style) {
    OS.objc_msgSend(this.id, OS.sel_setNumberStyle_, style);
}

public void setPartialStringValidationEnabled(bool b) {
    OS.objc_msgSend(this.id, OS.sel_setPartialStringValidationEnabled_, b);
}

}
