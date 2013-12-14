/**
 * Copyright: Copyright (c) 2008 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Nov 18, 2008
 * License: $(LINK2 http://opensource.org/licenses/bsd-license.php, BSD Style)
 *
 */
module dwt.internal.objc.cocoa.Cocoa;

import tango.stdc.config;
import bindings = dwt.internal.objc.cocoa.bindings;

// static if( (void*).sizeof > int.sizeof)
// {
//     alias long NSInteger;
//     alias ulong NSUInteger;
// }
//
// else
// {
    alias int NSInteger;
    alias uint NSUInteger;
// }

import dwt.internal.c.Carbon;
import dwt.internal.objc.runtime;
import dwt.internal.cocoa.CGRect;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.CGPathElement;

// ATSFont.h
enum ATSFontContext : uint
{
	kATSFontContextUnspecified = 0,
	kATSFontContextGlobal = 1,
	kATSFontContextLocal = 2
}

enum ATSFontFormat : uint
{
	kATSFontFilterCurrentVersion = 0
}

alias bindings.ATSFontActivateFromFileReference ATSFontActivateFromFileReference;



// CGAffineTransform.h
struct CGAffineTransform
{
    CGFloat a;
    CGFloat b;
    CGFloat c;
    CGFloat d;
    CGFloat tx;
    CGFloat ty;
}



// CGBitmapContext.h
alias bindings.CGBitmapContextCreate CGBitmapContextCreate;
alias bindings.CGBitmapContextCreateImage CGBitmapContextCreateImage;
alias bindings.CGBitmapContextGetData CGBitmapContextGetData;



// CGColorSpace.h
struct CGColorSpace;
alias CGColorSpace* CGColorSpaceRef;

enum CGColorRenderingIntent
{
    kCGRenderingIntentDefault,
    kCGRenderingIntentAbsoluteColorimetric,
    kCGRenderingIntentRelativeColorimetric,
    kCGRenderingIntentPerceptual,
    kCGRenderingIntentSaturation
}

alias bindings.CGColorSpaceCreateDeviceRGB CGColorSpaceCreateDeviceRGB;
alias bindings.CGColorSpaceRelease CGColorSpaceRelease;



// CGContext.h
struct CGContext;
alias CGContext* CGContextRef;

enum CGBlendMode
{
    kCGBlendModeNormal,
    kCGBlendModeMultiply,
    kCGBlendModeScreen,
    kCGBlendModeOverlay,
    kCGBlendModeDarken,
    kCGBlendModeLighten,
    kCGBlendModeColorDodge,
    kCGBlendModeColorBurn,
    kCGBlendModeSoftLight,
    kCGBlendModeHardLight,
    kCGBlendModeDifference,
    kCGBlendModeExclusion,
    kCGBlendModeHue,
    kCGBlendModeSaturation,
    kCGBlendModeColor,
    kCGBlendModeLuminosity,
    kCGBlendModeClear,
    kCGBlendModeCopy,
    kCGBlendModeSourceIn,
    kCGBlendModeSourceOut,
    kCGBlendModeSourceAtop,
    kCGBlendModeDestinationOver,
    kCGBlendModeDestinationIn,
    kCGBlendModeDestinationOut,
    kCGBlendModeDestinationAtop,
    kCGBlendModeXOR,
    kCGBlendModePlusDarker,
    kCGBlendModePlusLighter
}

enum CGLineCap
{
    kCGLineCapButt,
    kCGLineCapRound,
    kCGLineCapSquare
}

enum CGLineJoin
{
    kCGLineJoinMiter,
    kCGLineJoinRound,
    kCGLineJoinBevel
}

alias bindings.CGContextCopyPath CGContextCopyPath;
alias bindings.CGContextAddPath CGContextAddPath;
alias bindings.CGContextDrawImage CGContextDrawImage;
alias bindings.CGContextRelease CGContextRelease;
alias bindings.CGContextReplacePathWithStrokedPath CGContextReplacePathWithStrokedPath;
alias bindings.CGContextRestoreGState CGContextRestoreGState;
alias bindings.CGContextSaveGState CGContextSaveGState;
alias bindings.CGContextScaleCTM CGContextScaleCTM;
alias bindings.CGContextSetBlendMode CGContextSetBlendMode;
alias bindings.CGContextSetLineCap CGContextSetLineCap;
alias bindings.CGContextSetLineDash CGContextSetLineDash;
alias bindings.CGContextSetLineJoin CGContextSetLineJoin;
alias bindings.CGContextSetLineWidth CGContextSetLineWidth;
alias bindings.CGContextSetMiterLimit CGContextSetMiterLimit;
alias bindings.CGContextStrokePath CGContextStrokePath;
alias bindings.CGContextTranslateCTM CGContextTranslateCTM;



// CGDataProvider.h
struct CGDataProvider;
alias CGDataProvider* CGDataProviderRef;

alias extern (C) void function (void* info, /*const*/ void* data, size_t size) CGDataProviderReleaseDataCallback;

alias bindings.CGDataProviderCreateWithData CGDataProviderCreateWithData;
alias bindings.CGDataProviderRelease CGDataProviderRelease;



// CGDirectDisplay.h
alias uint CGDirectDisplayID;
alias uint CGDisplayCount;
alias CGError CGDisplayErr;

alias bindings.CGDisplayBounds CGDisplayBounds;
alias bindings.CGDisplayBaseAddress CGDisplayBaseAddress;
alias bindings.CGDisplayBitsPerPixel CGDisplayBitsPerPixel;
alias bindings.CGDisplayBitsPerSample CGDisplayBitsPerSample;
alias bindings.CGDisplayBytesPerRow CGDisplayBytesPerRow;
alias bindings.CGDisplayPixelsHigh CGDisplayPixelsHigh;
alias bindings.CGDisplayPixelsWide CGDisplayPixelsWide;
alias bindings.CGGetDisplaysWithRect CGGetDisplaysWithRect;



// CGError.h
alias int CGError;



// CGEvent.h
alias bindings.CGEventCreateKeyboardEvent CGEventCreateKeyboardEvent;
alias bindings.CGEventGetIntegerValueField CGEventGetIntegerValueField;
alias bindings.CGEventKeyboardSetUnicodeString CGEventKeyboardSetUnicodeString;
alias bindings.CGEventPost CGEventPost;



// CGEventTypes.h
struct __CGEvent;
struct __CGEventSource;
alias __CGEventSource* CGEventSourceRef;

enum CGEventField : uint
{
    kCGMouseEventNumber = 0,
    kCGMouseEventClickState = 1,
    kCGMouseEventPressure = 2,
    kCGMouseEventButtonNumber = 3,
    kCGMouseEventDeltaX = 4,
    kCGMouseEventDeltaY = 5,
    kCGMouseEventInstantMouser = 6,
    kCGMouseEventSubtype = 7,
    kCGKeyboardEventAutorepeat = 8,
    kCGKeyboardEventKeycode = 9,
    kCGKeyboardEventKeyboardType = 10,
    kCGScrollWheelEventDeltaAxis1 = 11,
    kCGScrollWheelEventDeltaAxis2 = 12,
    kCGScrollWheelEventDeltaAxis3 = 13,
    kCGScrollWheelEventFixedPtDeltaAxis1 = 93,
    kCGScrollWheelEventFixedPtDeltaAxis2 = 94,
    kCGScrollWheelEventFixedPtDeltaAxis3 = 95,
    kCGScrollWheelEventPointDeltaAxis1 = 96,
    kCGScrollWheelEventPointDeltaAxis2 = 97,
    kCGScrollWheelEventPointDeltaAxis3 = 98,
    kCGScrollWheelEventInstantMouser = 14,
    kCGTabletEventPointX = 15,
    kCGTabletEventPointY = 16,
    kCGTabletEventPointZ = 17,
    kCGTabletEventPointButtons = 18,
    kCGTabletEventPointPressure = 19,
    kCGTabletEventTiltX = 20,
    kCGTabletEventTiltY = 21,
    kCGTabletEventRotation = 22,
    kCGTabletEventTangentialPressure = 23,
    kCGTabletEventDeviceID = 24,
    kCGTabletEventVendor1 = 25,
    kCGTabletEventVendor2 = 26,
    kCGTabletEventVendor3 = 27,
    kCGTabletProximityEventVendorID = 28,
    kCGTabletProximityEventTabletID = 29,
    kCGTabletProximityEventPointerID = 30,
    kCGTabletProximityEventDeviceID = 31,
    kCGTabletProximityEventSystemTabletID = 32,
    kCGTabletProximityEventVendorPointerType = 33,
    kCGTabletProximityEventVendorPointerSerialNumber = 34,
    kCGTabletProximityEventVendorUniqueID = 35,
    kCGTabletProximityEventCapabilityMask = 36,
    kCGTabletProximityEventPointerType = 37,
    kCGTabletProximityEventEnterProximity = 38,
    kCGEventTargetProcessSerialNumber = 39,
    kCGEventTargetUnixProcessID = 40,
    kCGEventSourceUnixProcessID = 41,
    kCGEventSourceUserData = 42,
    kCGEventSourceUserID = 43,
    kCGEventSourceGroupID = 44,
    kCGEventSourceStateID = 45,
    kCGScrollWheelEventIsContinuous = 88
}

enum CGEventTapLocation : uint
{
    kCGHIDEventTap = 0,
    kCGSessionEventTap,
    kCGAnnotatedSessionEventTap
}

enum CGEventFilterMask : uint
{
    kCGEventFilterMaskPermitLocalMouseEvents = 0x00000001,
    kCGEventFilterMaskPermitLocalKeyboardEvents = 0x00000002,
    kCGEventFilterMaskPermitSystemDefinedEvents = 0x00000004,
    kCGEventFilterMaskPermitAllEvents = kCGEventFilterMaskPermitLocalMouseEvents  | kCGEventFilterMaskPermitLocalKeyboardEvents |  kCGEventFilterMaskPermitSystemDefinedEvents
}

enum CGEventSuppressionState : uint
{
    kCGEventSuppressionStateSuppressionInterval = 0,
    kCGEventSuppressionStateRemoteMouseDrag = 1,
    kCGNumberOfEventSuppressionStates = 2
}



// CGImage.h
struct CGImage;
alias CGImage* CGImageRef;

enum CGBitmapInfo : uint
{
    kCGBitmapAlphaInfoMask = 0x1F,
    kCGBitmapFloatComponents = (1 << 8),
    kCGBitmapByteOrderMask = 0x7000,
    kCGBitmapByteOrderDefault = (0 << 12),
    kCGBitmapByteOrder16Little = (1 << 12),
    kCGBitmapByteOrder32Little = (2 << 12),
    kCGBitmapByteOrder16Big = (3 << 12),
    kCGBitmapByteOrder32Big = (4 << 12)
}

alias bindings.CGImageCreate CGImageCreate;
alias bindings.CGImageGetHeight CGImageGetHeight;
alias bindings.CGImageGetWidth CGImageGetWidth;
alias bindings.CGImageRelease CGImageRelease;



// CGPath.h
struct CGPath;
alias /*const*/ CGPath* CGPathRef;
alias CGPath* CGMutablePathRef;
alias extern (C) void function (void* info, /*const*/ CGPathElement* element) CGPathApplierFunction;

enum CGPathElementType
{
    kCGPathElementMoveToPoint,
    kCGPathElementAddLineToPoint,
    kCGPathElementAddQuadCurveToPoint,
    kCGPathElementAddCurveToPoint,
    kCGPathElementCloseSubpath
}

alias bindings.CGPathAddCurveToPoint CGPathAddCurveToPoint;
alias bindings.CGPathAddLineToPoint CGPathAddLineToPoint;
alias bindings.CGPathApply CGPathApply;
alias bindings.CGPathCloseSubpath CGPathCloseSubpath;
alias bindings.CGPathCreateCopy CGPathCreateCopy;
alias bindings.CGPathCreateMutable CGPathCreateMutable;
alias bindings.CGPathMoveToPoint CGPathMoveToPoint;
alias bindings.CGPathRelease CGPathRelease;



// CGRemoteOperation.h
alias uint CGKeyCode;
alias uint CGButtonCount;
alias ushort CGCharCode;
alias uint CGWheelCount;

alias bindings.CGEnableEventStateCombining CGEnableEventStateCombining;
alias bindings.CGPostKeyboardEvent CGPostKeyboardEvent;
alias bindings.CGPostMouseEvent CGPostMouseEvent;
alias bindings.CGPostScrollWheelEvent CGPostScrollWheelEvent;
alias bindings.CGSetLocalEventsFilterDuringSuppressionState CGSetLocalEventsFilterDuringSuppressionState;
alias bindings.CGSetLocalEventsSuppressionInterval CGSetLocalEventsSuppressionInterval;



// gl.h
alias int GLint;



// NSPathUtilities.h
enum NSSearchPathDirectory
{
    NSApplicationDirectory = 1,
    NSDemoApplicationDirectory,
    NSDeveloperApplicationDirectory,
    NSAdminApplicationDirectory,
    NSLibraryDirectory,
    NSDeveloperDirectory,
    NSUserDirectory,
    NSDocumentationDirectory,
    NSDocumentDirectory,
    NSCoreServiceDirectory,
    NSDesktopDirectory = 12,
    NSCachesDirectory = 13,
    NSApplicationSupportDirectory = 14,
    NSDownloadsDirectory = 15,
    NSAllApplicationsDirectory = 100,
    NSAllLibrariesDirectory = 101
}

enum NSSearchPathDomainMask
{
    NSUserDomainMask = 1,
    NSLocalDomainMask = 2,
    NSNetworkDomainMask = 4,
    NSSystemDomainMask = 8,
    NSAllDomainsMask = 0x0ffff,
}

// This needs to be down here otherwise the above enums will cause forward reference errors
import bindings = dwt.internal.objc.cocoa.bindings;

extern (C)
{
    // *.h
    extern
    {
        id NSAccessibilityButtonRole;
        id NSAccessibilityCheckBoxRole;
        id NSAccessibilityChildrenAttribute;
        id NSAccessibilityColumnRole;
        id NSAccessibilityComboBoxRole;
        id NSAccessibilityConfirmAction;
        id NSAccessibilityContentsAttribute;
        id NSAccessibilityDescriptionAttribute;
        id NSAccessibilityDialogSubrole;
        id NSAccessibilityEnabledAttribute;
        id NSAccessibilityExpandedAttribute;
        id NSAccessibilityFloatingWindowSubrole;
        id NSAccessibilityFocusedAttribute;
        id NSAccessibilityFocusedUIElementChangedNotification;
        id NSAccessibilityGridRole;
        id NSAccessibilityGroupRole;
        id NSAccessibilityHelpAttribute;
        id NSAccessibilityHelpTagRole;
        id NSAccessibilityHorizontalOrientationValue;
        id NSAccessibilityHorizontalScrollBarAttribute;
        id NSAccessibilityImageRole;
        id NSAccessibilityIncrementorRole;
        id NSAccessibilityInsertionPointLineNumberAttribute;
        id NSAccessibilityLabelValueAttribute;
        id NSAccessibilityLineForIndexParameterizedAttribute;
        id NSAccessibilityLinkRole;
        id NSAccessibilityLinkTextAttribute;
        id NSAccessibilityListRole;
        id NSAccessibilityMaxValueAttribute;
        id NSAccessibilityMenuBarRole;
        id NSAccessibilityMenuButtonRole;
        id NSAccessibilityMenuItemRole;
        id NSAccessibilityMenuRole;
        id NSAccessibilityMinValueAttribute;
        id NSAccessibilityNextContentsAttribute;
        id NSAccessibilityNumberOfCharactersAttribute;
        id NSAccessibilityOrientationAttribute;
        id NSAccessibilityOutlineRole;
        id NSAccessibilityOutlineRowSubrole;
        id NSAccessibilityParentAttribute;
        id NSAccessibilityPopUpButtonRole;
        id NSAccessibilityPositionAttribute;
        id NSAccessibilityPressAction;
        id NSAccessibilityPreviousContentsAttribute;
        id NSAccessibilityProgressIndicatorRole;
        id NSAccessibilityRTFForRangeParameterizedAttribute;
        id NSAccessibilityRadioButtonRole;
        id NSAccessibilityRadioGroupRole;
        id NSAccessibilityRangeForIndexParameterizedAttribute;
        id NSAccessibilityRangeForLineParameterizedAttribute;
        id NSAccessibilityRangeForPositionParameterizedAttribute;
        id NSAccessibilityRoleAttribute;
        id NSAccessibilityRoleDescriptionAttribute;
        id NSAccessibilityRowRole;
        id NSAccessibilityScrollAreaRole;
        id NSAccessibilityScrollBarRole;
        id NSAccessibilitySelectedAttribute;
        id NSAccessibilitySelectedChildrenAttribute;
        id NSAccessibilitySelectedChildrenChangedNotification;
        id NSAccessibilitySelectedTextAttribute;
        id NSAccessibilitySelectedTextChangedNotification;
        id NSAccessibilitySelectedTextRangeAttribute;
        id NSAccessibilitySelectedTextRangesAttribute;
        id NSAccessibilitySizeAttribute;
        id NSAccessibilitySliderRole;
        id NSAccessibilitySortButtonRole;
        id NSAccessibilitySplitterRole;
        id NSAccessibilityStandardWindowSubrole;
        id NSAccessibilityStaticTextRole;
        id NSAccessibilityStringForRangeParameterizedAttribute;
        id NSAccessibilityStyleRangeForIndexParameterizedAttribute;
        id NSAccessibilitySubroleAttribute;
        id NSAccessibilitySystemDialogSubrole;
        id NSAccessibilityTabGroupRole;
        id NSAccessibilityTableRole;
        id NSAccessibilityTableRowSubrole;
        id NSAccessibilityTabsAttribute;
        id NSAccessibilityTextAreaRole;
        id NSAccessibilityTextFieldRole;
        id NSAccessibilityTextLinkSubrole;
        id NSAccessibilityTitleAttribute;
        id NSAccessibilityTitleUIElementAttribute;
        id NSAccessibilityToolbarRole;
        id NSAccessibilityTopLevelUIElementAttribute;
        id NSAccessibilityUnknownRole;
        id NSAccessibilityUnknownSubrole;
        id NSAccessibilityValueAttribute;
        id NSAccessibilityValueChangedNotification;
        id NSAccessibilityValueDescriptionAttribute;
        id NSAccessibilityValueIndicatorRole;
        id NSAccessibilityVerticalOrientationValue;
        id NSAccessibilityVerticalScrollBarAttribute;
        id NSAccessibilityVisibleCharacterRangeAttribute;
        id NSAccessibilityVisibleChildrenAttribute;
        id NSAccessibilityWindowAttribute;
        id NSAccessibilityWindowRole;
        id NSBackgroundColorAttributeName;
        id NSBaselineOffsetAttributeName;
        id NSCalibratedRGBColorSpace;
        id NSDeviceRGBColorSpace;
        id NSDeviceResolution;
        id NSDragPboard;
        id NSFilenamesPboardType;
        id NSFontAttributeName;
        id NSForegroundColorAttributeName;
        id NSHTMLPboardType;
        id NSLinkAttributeName;
        id NSParagraphStyleAttributeName;
        id NSPrintAllPages;
        id NSPrintCopies;
        id NSPrintFirstPage;
        id NSPrintJobDisposition;
        id NSPrintLastPage;
        id NSPrintMustCollate;
        id NSPrintPreviewJob;
        id NSPrintSaveJob;
        id NSPrintSavePath;
        id NSPrintSpoolJob;
        id NSRTFPboardType;
        id NSStrikethroughColorAttributeName;
        id NSStrikethroughStyleAttributeName;
        id NSStringPboardType;
        id NSTIFFPboardType;
        id NSURLPboardType;
        id NSUnderlineColorAttributeName;
        id NSUnderlineStyleAttributeName;
        id NSDefaultRunLoopMode;
        id NSErrorFailingURLStringKey;

        id kCFRunLoopCommonModes;
        id NSViewGlobalFrameDidChangeNotification;
        id NSToolbarWillAddItemNotification;
        id NSToolbarSpaceItemIdentifier;
        id NSToolbarShowFontsItemIdentifier;
        id NSToolbarShowColorsItemIdentifier;
        id NSToolbarSeparatorItemIdentifier;
        id NSToolbarPrintItemIdentifier;
        id NSToolbarFlexibleSpaceItemIdentifier;
        id NSToolbarDidRemoveItemNotification;
        id NSToolbarCustomizeToolbarItemIdentifier;
        id NSSystemColorsDidChangeNotification;
        id NSStrokeWidthAttributeName;
        id NSPrintScalingFactor;
        id NSAccessibilityServesAsTitleForUIElementsAttribute;
        id NSObliquenessAttributeName;
        id NSEventTrackingRunLoopMode;
        id NSApplicationDidChangeScreenParametersNotification;
    }
}




//NSAccessibility.h
alias bindings.NSAccessibilityActionDescription NSAccessibilityActionDescription;
alias bindings.NSAccessibilityPostNotification NSAccessibilityPostNotification;
alias bindings.NSAccessibilityRaiseBadArgumentException NSAccessibilityRaiseBadArgumentException;
alias bindings.NSAccessibilityRoleDescription NSAccessibilityRoleDescription;
alias bindings.NSAccessibilityRoleDescriptionForUIElement NSAccessibilityRoleDescriptionForUIElement;
alias bindings.NSAccessibilityUnignoredAncestor NSAccessibilityUnignoredAncestor;
alias bindings.NSAccessibilityUnignoredChildren NSAccessibilityUnignoredChildren;
alias bindings.NSAccessibilityUnignoredChildrenForOnlyChild NSAccessibilityUnignoredChildrenForOnlyChild;
alias bindings.NSAccessibilityUnignoredDescendant NSAccessibilityUnignoredDescendant;



// NSAlert.h
enum NSAlertStyle : NSUInteger
{
    NSWarningAlertStyle = 0,
    NSInformationalAlertStyle = 1,
    NSCriticalAlertStyle = 2
}



// NSApplication.h
enum NSApplicationTerminateReply
{
    NSTerminateCancel = 0,
    NSTerminateNow    = 1,
    NSTerminateLater  = 2
}



// NSBezierPath.h
enum NSBezierPathElement
{
    NSMoveToBezierPathElement,
    NSLineToBezierPathElement,
    NSCurveToBezierPathElement,
    NSClosePathBezierPathElement
}

enum NSLineCapStyle
{
    NSButtLineCapStyle = 0,
    NSRoundLineCapStyle = 1,
    NSSquareLineCapStyle = 2
}

enum NSLineJoinStyle
{
    NSMiterLineJoinStyle = 0,
    NSRoundLineJoinStyle = 1,
    NSBevelLineJoinStyle = 2
}

enum NSWindingRule
{
    NSNonZeroWindingRule = 0,
    NSEvenOddWindingRule = 1
}



// NSBox.h
enum NSTitlePosition
{
    NSNoTitle = 0,
    NSAboveTop = 1,
    NSAtTop = 2,
    NSBelowTop = 3,
    NSAboveBottom = 4,
    NSAtBottom = 5,
    NSBelowBottom = 6
}



// NSButtonCell.h
enum NSBezelStyle : NSUInteger {
    NSRoundedBezelStyle = 1,
    NSRegularSquareBezelStyle = 2,
    NSThickSquareBezelStyle = 3,
    NSThickerSquareBezelStyle = 4,
    NSDisclosureBezelStyle = 5,
    NSShadowlessSquareBezelStyle = 6,
    NSCircularBezelStyle = 7,
    NSTexturedSquareBezelStyle = 8,
    NSHelpButtonBezelStyle = 9,
    NSSmallSquareBezelStyle = 10,
    NSTexturedRoundedBezelStyle = 11,
    NSRoundRectBezelStyle = 12,
    NSRecessedBezelStyle = 13,
    NSRoundedDisclosureBezelStyle = 14,
}

enum NSButtonType : NSUInteger {
    NSMomentaryLightButton = 0,
    NSPushOnPushOffButton = 1,
    NSToggleButton = 2,
    NSSwitchButton = 3,
    NSRadioButton = 4,
    NSMomentaryChangeButton = 5,
    NSOnOffButton = 6,
    NSMomentaryPushInButton = 7,
    NSMomentaryPushButton = 0,
    NSMomentaryLight = 7
}

// NSCell.h
enum NSControlSize : NSUInteger
{
    NSRegularControlSize,
    NSSmallControlSize,
    NSMiniControlSize
}

enum NSImageScaling : NSUInteger
{
    NSImageScaleProportionallyDown = 0,
    NSImageScaleAxesIndependently,
    NSImageScaleNone,
    NSImageScaleProportionallyUpOrDown,

    // Deprecated, only for dwt compatibility
    NSScaleProportionally = NSImageScaleProportionallyDown,
    NSScaleToFit = NSImageScaleAxesIndependently,
    NSScaleNone = NSImageScaleNone
}

enum NSCellImagePosition : NSUInteger
{
    NSNoImage       = 0,
    NSImageOnly     = 1,
    NSImageLeft     = 2,
    NSImageRight    = 3,
    NSImageBelow    = 4,
    NSImageAbove    = 5,
    NSImageOverlaps = 6
}



// NSDatePicker.h
enum NSDatePickerElementFlags : NSUInteger
{
    NSHourMinuteDatePickerElementFlag = 0x000c,
    NSHourMinuteSecondDatePickerElementFlag = 0x000e,
    NSTimeZoneDatePickerElementFlag = 0x0010,
    NSYearMonthDatePickerElementFlag = 0x00c0,
    NSYearMonthDayDatePickerElementFlag = 0x00e0,
    NSEraDatePickerElementFlag = 0x0100,
}

enum NSDatePickerStyle : NSUInteger
{
    NSTextFieldAndStepperDatePickerStyle = 0,
    NSClockAndCalendarDatePickerStyle = 1,
    NSTextFieldDatePickerStyle = 2
}



// NSDragging.h
enum NSDragOperation : uint
{
    NSDragOperationNone = 0,
    NSDragOperationCopy = 1,
    NSDragOperationLink = 2,
    NSDragOperationGeneric = 4,
    NSDragOperationPrivate = 8,
    NSDragOperationAll_Obsolete = 15,
    NSDragOperationMove = 16,
    NSDragOperationDelete = 32,
    NSDragOperationEvery = uint.max // UINT_MAX
}



// NSEvent.h
enum NSEventType
{
    NSLeftMouseDown      = 1,
    NSLeftMouseUp        = 2,
    NSRightMouseDown     = 3,
    NSRightMouseUp       = 4,
    NSMouseMoved         = 5,
    NSLeftMouseDragged   = 6,
    NSRightMouseDragged  = 7,
    NSMouseEntered       = 8,
    NSMouseExited        = 9,
    NSKeyDown            = 10,
    NSKeyUp              = 11,
    NSFlagsChanged       = 12,
    NSAppKitDefined      = 13,
    NSSystemDefined      = 14,
    NSApplicationDefined = 15,
    NSPeriodic           = 16,
    NSCursorUpdate       = 17,
    NSScrollWheel        = 22,
    NSTabletPoint        = 23,
    NSTabletProximity    = 24,
    NSOtherMouseDown     = 25,
    NSOtherMouseUp       = 26,
    NSOtherMouseDragged  = 27
}



// NSFontManager.h
enum NSFontTraitMask : uint
{
    NSItalicFontMask = 0x00000001,
    NSBoldFontMask = 0x00000002,
    NSUnboldFontMask = 0x00000004,
    NSNonStandardCharacterSetFontMask = 0x00000008,
    NSNarrowFontMask = 0x00000010,
    NSExpandedFontMask = 0x00000020,
    NSCondensedFontMask = 0x00000040,
    NSSmallCapsFontMask = 0x00000080,
    NSPosterFontMask = 0x00000100,
    NSCompressedFontMask = 0x00000200,
    NSFixedPitchFontMask = 0x00000400,
    NSUnitalicFontMask = 0x01000000
}



// NSGraphics.h
alias int NSWindowDepth;

alias bindings.NSBeep NSBeep;
alias bindings.NSBitsPerPixelFromDepth NSBitsPerPixelFromDepth;
alias bindings.NSCopyBits NSCopyBits;
alias bindings.NSNumberOfColorComponents NSNumberOfColorComponents;

enum NSCompositingOperation
{
    NSCompositeClear = 0,
    NSCompositeCopy = 1,
    NSCompositeSourceOver = 2,
    NSCompositeSourceIn = 3,
    NSCompositeSourceOut = 4,
    NSCompositeSourceAtop = 5,
    NSCompositeDestinationOver = 6,
    NSCompositeDestinationIn = 7,
    NSCompositeDestinationOut = 8,
    NSCompositeDestinationAtop = 9,
    NSCompositeXOR = 10,
    NSCompositePlusDarker = 11,
    NSCompositeHighlight = 12,
    NSCompositePlusLighter = 13
}

enum NSWindowOrderingMode
{
    NSWindowAbove = 1,
    NSWindowBelow = -1,
    NSWindowOut = 0
}

enum NSFocusRingType
{
    NSFocusRingTypeDefault = 0,
    NSFocusRingTypeNone = 1,
    NSFocusRingTypeExterior = 2
}

enum NSBackingStoreType
{
    NSBackingStoreRetained     = 0,
    NSBackingStoreNonretained  = 1,
    NSBackingStoreBuffered     = 2
}



//NSGeometry.h
alias NSRect* NSRectArray;

alias bindings.NSIntersectionRect NSIntersectionRect;
alias bindings.NSEqualRects NSEqualRects;
alias bindings.NSPointInRect NSPointInRect;



// NSGradient.h
enum NSGradientDrawingOptions : NSUInteger
{
    NSGradientDrawsBeforeStartingLocation = (1 << 0),
    NSGradientDrawsAfterEndingLocation = (1 << 1),
}



// NSGraphicsContext.h
enum NSImageInterpolation
{
    NSImageInterpolationDefault,
    NSImageInterpolationNone,
    NSImageInterpolationLow,
    NSImageInterpolationHigh
}



// NSHFSFileTypes.h
alias bindings.NSFileTypeForHFSTypeCode NSFileTypeForHFSTypeCode;



//IKPictureTaker.h
//alias c_long NSInteger;
//alias c_ulong NSUInteger;



// NSImage.h
enum NSImageCacheMode
{
    NSImageCacheDefault,
    NSImageCacheAlways,
    NSImageCacheBySize,
    NSImageCacheNever
}



// NSBitmapImageRep.h
enum NSTIFFCompression : NSUInteger {
    NSTIFFCompressionNone = 1,
    NSTIFFCompressionCCITTFAX3 = 3,
    NSTIFFCompressionCCITTFAX4 = 4,
    NSTIFFCompressionLZW = 5,
    NSTIFFCompressionJPEG = 6,
    NSTIFFCompressionNEXT = 32766,
    NSTIFFCompressionPackBits = 32773,
    NSTIFFCompressionOldJPEG = 32865
}

enum NSBitmapFormat : NSUInteger {
    NSAlphaFirstBitmapFormat = 1 << 0,
    NSAlphaNonpremultipliedBitmapFormat = 1 << 1,
    NSFloatingPointSamplesBitmapFormat = 1 << 2
}



// NSLayoutManager.h
enum NSGlyphInscription
{
    NSGlyphInscribeBase = 0,
    NSGlyphInscribeBelow = 1,
    NSGlyphInscribeAbove = 2,
    NSGlyphInscribeOverstrike = 3,
    NSGlyphInscribeOverBelow = 4
}



// NSNumberFormatter.h
enum NSNumberFormatterStyle
{
    NSNumberFormatterNoStyle = kCFNumberFormatterNoStyle,
    NSNumberFormatterDecimalStyle = kCFNumberFormatterDecimalStyle,
    NSNumberFormatterCurrencyStyle = kCFNumberFormatterCurrencyStyle,
    NSNumberFormatterPercentStyle = kCFNumberFormatterPercentStyle,
    NSNumberFormatterScientificStyle = kCFNumberFormatterScientificStyle,
    NSNumberFormatterSpellOutStyle = kCFNumberFormatterSpellOutStyle
}



// NSObjCRuntime.h
alias bindings.NSGetSizeAndAlignment NSGetSizeAndAlignment;

enum
{
    NSNotFound = 0x7fffffff
}

enum NSComparisonResult : NSInteger
{
    NSOrderedAscending = -1,
    NSOrderedSame,
    NSOrderedDescending
}



// NSOpenGL.h
enum NSOpenGLPixelFormatAttribute : uint
{
    NSOpenGLPFAAllRenderers = 1,
    NSOpenGLPFADoubleBuffer = 5,
    NSOpenGLPFAStereo = 6,
    NSOpenGLPFAAuxBuffers = 7,
    NSOpenGLPFAColorSize = 8,
    NSOpenGLPFAAlphaSize = 11,
    NSOpenGLPFADepthSize = 12,
    NSOpenGLPFAStencilSize = 13,
    NSOpenGLPFAAccumSize = 14,
    NSOpenGLPFAMinimumPolicy = 51,
    NSOpenGLPFAMaximumPolicy = 52,
    NSOpenGLPFAOffScreen = 53,
    NSOpenGLPFAFullScreen = 54,
    NSOpenGLPFASampleBuffers = 55,
    NSOpenGLPFASamples = 56,
    NSOpenGLPFAAuxDepthStencil = 57,
    NSOpenGLPFAColorFloat = 58,
    NSOpenGLPFAMultisample = 59,
    NSOpenGLPFASupersample = 60,
    NSOpenGLPFASampleAlpha = 61,
    NSOpenGLPFARendererID = 70,
    NSOpenGLPFASingleRenderer = 71,
    NSOpenGLPFANoRecovery = 72,
    NSOpenGLPFAAccelerated = 73,
    NSOpenGLPFAClosestPolicy = 74,
    NSOpenGLPFARobust = 75,
    NSOpenGLPFABackingStore = 76,
    NSOpenGLPFAMPSafe = 78,
    NSOpenGLPFAWindow = 80,
    NSOpenGLPFAMultiScreen = 81,
    NSOpenGLPFACompliant = 83,
    NSOpenGLPFAScreenMask = 84,
    NSOpenGLPFAPixelBuffer = 90,
    NSOpenGLPFAAllowOfflineRenderers = 96,
    NSOpenGLPFAVirtualScreenCount = 128
}



// NSParagraphStyle.h
enum NSLineBreakMode
{
    NSLineBreakByWordWrapping = 0,
    NSLineBreakByCharWrapping,
    NSLineBreakByClipping,
    NSLineBreakByTruncatingHead,
    NSLineBreakByTruncatingTail,
    NSLineBreakByTruncatingMiddle
}

enum NSTextTabType
{
    NSLeftTabStopType = 0,
    NSRightTabStopType,
    NSCenterTabStopType,
    NSDecimalTabStopType
}



// NSPathUtilities.h
//enum NSSearchPathDirectory
//{
//    NSApplicationDirectory = 1,
//    NSDemoApplicationDirectory,
//    NSDeveloperApplicationDirectory,
//    NSAdminApplicationDirectory,
//    NSLibraryDirectory,
//    NSDeveloperDirectory,
//    NSUserDirectory,
//    NSDocumentationDirectory,
//    NSDocumentDirectory,
//    NSCoreServiceDirectory,
//    NSDesktopDirectory = 12,
//    NSCachesDirectory = 13,
//    NSApplicationSupportDirectory = 14,
//    NSDownloadsDirectory = 15,
//    NSAllApplicationsDirectory = 100,
//    NSAllLibrariesDirectory = 101
//}
//
//enum NSSearchPathDomainMask
//{
//    NSUserDomainMask = 1,
//    NSLocalDomainMask = 2,
//    NSNetworkDomainMask = 4,
//    NSSystemDomainMask = 8,
//    NSAllDomainsMask = 0x0ffff,
//}

alias bindings.NSSearchPathForDirectoriesInDomains NSSearchPathForDirectoriesInDomains;
alias bindings.NSTemporaryDirectory NSTemporaryDirectory;



// NSPrintInfo.h
enum NSPrintingOrientation : NSUInteger
{
    NSPortraitOrientation  = 0,
    NSLandscapeOrientation = 1
}



// NSPrintPanle.h
enum NSPrintPanelOptions : NSInteger
{
    NSPrintPanelShowsCopies = 0x01,
    NSPrintPanelShowsPageRange = 0x02,
    NSPrintPanelShowsPaperSize = 0x04,
    NSPrintPanelShowsOrientation = 0x08,
    NSPrintPanelShowsScaling = 0x10,
    NSPrintPanelShowsPageSetupAccessory = 0x100,
    NSPrintPanelShowsPreview = 0x20000
}



// NSSegmentedCell.h
enum  NSSegmentSwitchTracking
{
    NSSegmentSwitchTrackingSelectOne = 0,
    NSSegmentSwitchTrackingSelectAny = 1,
    NSSegmentSwitchTrackingMomentary = 2
}



// NSString.h
enum NSStringEncoding : NSUInteger
{
    NSASCIIStringEncoding = 1,
    NSNEXTSTEPStringEncoding = 2,
    NSJapaneseEUCStringEncoding = 3,
    NSUTF8StringEncoding = 4,
    NSISOLatin1StringEncoding = 5,
    NSSymbolStringEncoding = 6,
    NSNonLossyASCIIStringEncoding = 7,
    NSShiftJISStringEncoding = 8,
    NSISOLatin2StringEncoding = 9,
    NSUnicodeStringEncoding = 10,
    NSWindowsCP1251StringEncoding = 11,
    NSWindowsCP1252StringEncoding = 12,
    NSWindowsCP1253StringEncoding = 13,
    NSWindowsCP1254StringEncoding = 14,
    NSWindowsCP1250StringEncoding = 15,
    NSISO2022JPStringEncoding = 21,
    NSMacOSRomanStringEncoding = 30,
    NSUTF16BigEndianStringEncoding = 0x90000100,
    NSUTF16LittleEndianStringEncoding = 0x94000100,
    NSUTF32StringEncoding = 0x8c000100,
    NSUTF32BigEndianStringEncoding = 0x98000100,
    NSUTF32LittleEndianStringEncoding = 0x9c000100,
    NSProprietaryStringEncoding = 65536
}

enum NSStringEncodingConversionOptions : NSUInteger
{
    NSStringEncodingConversionAllowLossy = 1,
    NSStringEncodingConversionExternalRepresentation = 2
}


// NSTableView.h
enum NSTableViewColumnAutoresizingStyle : NSUInteger
{
    NSTableViewNoColumnAutoresizing = 0,
    NSTableViewUniformColumnAutoresizingStyle,
    NSTableViewSequentialColumnAutoresizingStyle,
    NSTableViewReverseSequentialColumnAutoresizingStyle,
    NSTableViewLastColumnOnlyAutoresizingStyle,
    NSTableViewFirstColumnOnlyAutoresizingStyle
}

enum NSTableViewDropOperation : NSUInteger
{
    NSTableViewDropOn,
    NSTableViewDropAbove
}



// NSTabView.h
enum NSTabViewType
{
    NSTopTabsBezelBorder     = 0,
    NSLeftTabsBezelBorder    = 1,
    NSBottomTabsBezelBorder  = 2,
    NSRightTabsBezelBorder   = 3,
    NSNoTabsBezelBorder      = 4,
    NSNoTabsLineBorder       = 5,
    NSNoTabsNoBorder         = 6
}



// NSText.h
enum NSTextAlignment
{
    NSLeftTextAlignment = 0,
    NSRightTextAlignment = 1,
    NSCenterTextAlignment = 2,
    NSJustifiedTextAlignment = 3,
    NSNaturalTextAlignment = 4
}



// NSToolbar.h
enum NSToolbarDisplayMode : NSUInteger
{
    NSToolbarDisplayModeDefault,
    NSToolbarDisplayModeIconAndLabel,
    NSToolbarDisplayModeIconOnly,
    NSToolbarDisplayModeLabelOnly
}



// NSTrackingArea.h
alias NSUInteger NSTrackingAreaOptions;



// NSURLCredential.h
enum NSURLCredentialPersistence
{
    NSURLCredentialPersistenceNone,
    NSURLCredentialPersistenceForSession,
    NSURLCredentialPersistencePermanent
}



// NSURLRequest.h
enum NSURLRequestCachePolicy : NSUInteger
{
   NSURLRequestUseProtocolCachePolicy = 0,
   NSURLRequestReloadIgnoringLocalCacheData = 1,
   NSURLRequestReloadIgnoringLocalAndRemoteCacheData =4,
   NSURLRequestReloadIgnoringCacheData = NSURLRequestReloadIgnoringLocalCacheData,
   NSURLRequestReturnCacheDataElseLoad = 2,
   NSURLRequestReturnCacheDataDontLoad = 3,
   NSURLRequestReloadRevalidatingCacheData = 5
}


// NSView.h
alias NSInteger NSToolTipTag;


// NSWindow.h
enum : NSUInteger
{
    NSBorderlessWindowMask = 0,
    NSTitledWindowMask = 1 << 0,
    NSClosableWindowMask = 1 << 1,
    NSMiniaturizableWindowMask = 1 << 2,
    NSResizableWindowMask = 1 << 3,
    NSTexturedBackgroundWindowMask = 1 << 8
}

enum NSWindowButton : NSUInteger
{
    NSWindowCloseButton,
    NSWindowMiniaturizeButton,
    NSWindowZoomButton,
    NSWindowToolbarButton,
    NSWindowDocumentIconButton
}


// NSZone.h
alias void* _NSZone;
alias _NSZone NSZone;

// Unknown
alias bindings.CGContextCopyWindowContentsToRect CGContextCopyWindowContentsToRect;

enum NSBorderType {
    NSNoBorder = 0,
    NSLineBorder = 1,
    NSBezelBorder = 2,
    NSGrooveBorder = 3
}

enum NSScrollerPart {
    NSScrollerNoPart = 0,
    NSScrollerDecrementPage = 1,
    NSScrollerKnob = 2,
    NSScrollerIncrementPage = 3,
    NSScrollerDecrementLine = 4,
    NSScrollerIncrementLine = 5,
    NSScrollerKnobSlot = 6
}
