/*******************************************************************************
 * Copyright (c) 2000, 2009 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *    IBM Corporation - initial API and implementation
 *******************************************************************************/
module dwt.internal.cocoa.NSSegmentedCell;

import dwt.dwthelper.utils;
import dwt.internal.c.Carbon;
import cocoa = dwt.internal.cocoa.id;
import dwt.internal.cocoa.NSActionCell;
import dwt.internal.cocoa.NSImage;
import dwt.internal.cocoa.NSMenu;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.OS;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class NSSegmentedCell : NSActionCell {

public this() {
    super();
}

public this(objc.id id) {
    super(id);
}

public this(cocoa.id id) {
    super(id);
}

public void setEnabled(bool enabled, NSInteger segment) {
    OS.objc_msgSend(this.id, OS.sel_setEnabled_forSegment_, enabled, segment);
}

public void setImage(NSImage image, NSInteger segment) {
    OS.objc_msgSend(this.id, OS.sel_setImage_forSegment_, image !is null ? image.id : null, segment);
}

public void setLabel(NSString label, NSInteger segment) {
    OS.objc_msgSend(this.id, OS.sel_setLabel_forSegment_, label !is null ? label.id : null, segment);
}

public void setMenu(NSMenu menu, NSInteger segment) {
    OS.objc_msgSend(this.id, OS.sel_setMenu_forSegment_, menu !is null ? menu.id : null, segment);
}

public void setSegmentCount(NSInteger count) {
    OS.objc_msgSend(this.id, OS.sel_setSegmentCount_, count);
}

public void setSegmentStyle(NSInteger segmentStyle) {
    OS.objc_msgSend(this.id, OS.sel_setSegmentStyle_, segmentStyle);
}

public void setSelected(bool selected, NSInteger segment) {
    OS.objc_msgSend(this.id, OS.sel_setSelected_forSegment_, selected, segment);
}

public void setSelectedSegment(NSInteger selectedSegment) {
    OS.objc_msgSend(this.id, OS.sel_setSelectedSegment_, selectedSegment);
}

public void setTag(NSInteger tag, NSInteger segment) {
    OS.objc_msgSend(this.id, OS.sel_setTag_forSegment_, tag, segment);
}

public void setToolTip(NSString toolTip, NSInteger segment) {
    OS.objc_msgSend(this.id, OS.sel_setToolTip_forSegment_, toolTip !is null ? toolTip.id : null, segment);
}

public void setTrackingMode(NSSegmentSwitchTracking trackingMode) {
    OS.objc_msgSend(this.id, OS.sel_setTrackingMode_, trackingMode);
}

public void setWidth(CGFloat width, NSInteger segment) {
    OS.objc_msgSend(this.id, OS.sel_setWidth_forSegment_, width, segment);
}

}
