/**
 * Copyright: Copyright (c) 2008 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Nov 18, 2008
 * License: $(LINK2 http://opensource.org/licenses/bsd-license.php, BSD Style)
 *
 */
module dwt.internal.objc.cocoa.bindings;

import tango.stdc.config;

import dwt.internal.c.Carbon;
import dwt.internal.cocoa.CGPoint;
import dwt.internal.cocoa.CGRect;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSRect;
import dwt.internal.objc.cocoa.Cocoa;
import dwt.internal.objc.runtime;

extern (C):

// ATSFont.h
OSStatus ATSFontActivateFromFileReference (/*const*/ FSRef* iFile, ATSFontContext iContext, ATSFontFormat iFormat, void* iRefCon, ATSOptionFlags iOptions, ATSFontContainerRef* oContainer);



// CGBitmapContext.h
CGContextRef CGBitmapContextCreate (void* data, size_t width, size_t height, size_t bitsPerComponent, size_t bytesPerRow, CGColorSpaceRef colorspace, CGBitmapInfo bitmapInfo);
CGImageRef CGBitmapContextCreateImage (CGContextRef c);
void* CGBitmapContextGetData (CGContextRef c);



// CGColorSpace.h
CGColorSpaceRef CGColorSpaceCreateDeviceRGB ();
void CGColorSpaceRelease (CGColorSpaceRef cs);



// CGContext.h
CGPathRef CGContextCopyPath (CGContextRef context);
void CGContextAddPath (CGContextRef context, CGPathRef path);
void CGContextDrawImage (CGContextRef c, CGRect rect, CGImageRef image);
void CGContextRelease (CGContextRef c);
void CGContextReplacePathWithStrokedPath (CGContextRef c);
void CGContextRestoreGState (CGContextRef c);
void CGContextSaveGState (CGContextRef c);
void CGContextScaleCTM (CGContextRef c, CGFloat sx, CGFloat sy);
void CGContextSetBlendMode (CGContextRef context, CGBlendMode mode);
void CGContextSetLineCap (CGContextRef c, CGLineCap cap);
void CGContextSetLineDash (CGContextRef c, CGFloat phase, /*const*/ CGFloat*/*[]*/ lengths, size_t count);
void CGContextSetLineJoin (CGContextRef c, CGLineJoin join);
void CGContextSetLineWidth (CGContextRef c, CGFloat width);
void CGContextSetMiterLimit (CGContextRef c, CGFloat limit);
void CGContextStrokePath (CGContextRef c);
void CGContextTranslateCTM (CGContextRef c, CGFloat tx, CGFloat ty);



// CGDataProvider.h
CGDataProviderRef CGDataProviderCreateWithData (void* info, /*const*/ void* data, size_t size, CGDataProviderReleaseDataCallback releaseData);
void CGDataProviderRelease (CGDataProviderRef provider);



// CGDirectDisplay.h
CGRect CGDisplayBounds (CGDirectDisplayID display, CGRect rect);
void* CGDisplayBaseAddress (CGDirectDisplayID display);
size_t CGDisplayBitsPerPixel (CGDirectDisplayID display);
size_t CGDisplayBitsPerSample (CGDirectDisplayID display);
size_t CGDisplayBytesPerRow (CGDirectDisplayID display);
size_t CGDisplayPixelsHigh (CGDirectDisplayID display);
size_t CGDisplayPixelsWide (CGDirectDisplayID display);
CGDisplayErr CGGetDisplaysWithRect (CGRect rect, CGDisplayCount maxDisplays,  CGDirectDisplayID* dspys, CGDisplayCount* dspyCnt);



// CGEvent.h
CGEventRef CGEventCreateKeyboardEvent (CGEventSourceRef source, CGKeyCode virtualKey, bool keyDown);
long CGEventGetIntegerValueField (CGEventRef event, CGEventField field);
void CGEventKeyboardSetUnicodeString (CGEventRef event, UniCharCount stringLength, /*const*/ UniChar*/*[]*/ unicodeString);
void CGEventPost (CGEventTapLocation tap, CGEventRef event);



// CGImage.h
CGImageRef CGImageCreate (size_t width, size_t height, size_t bitsPerComponent, size_t bitsPerPixel, size_t bytesPerRow, CGColorSpaceRef colorspace, CGBitmapInfo bitmapInfo, CGDataProviderRef provider, /*const*/ CGFloat*/*[]*/ decode, bool shouldInterpolate, CGColorRenderingIntent intent);
size_t CGImageGetHeight (CGImageRef image);
size_t CGImageGetWidth (CGImageRef image);
void CGImageRelease (CGImageRef image);



// CGPath.h
void CGPathAddCurveToPoint (CGMutablePathRef path, /*const*/ CGAffineTransform* m, CGFloat cp1x, CGFloat cp1y, CGFloat cp2x, CGFloat cp2y, CGFloat x, CGFloat y);
void CGPathAddLineToPoint (CGMutablePathRef path, /*const*/ CGAffineTransform* m,  CGFloat x, CGFloat y);
void CGPathApply (CGPathRef path, void* info, CGPathApplierFunction function_);
void CGPathCloseSubpath (CGMutablePathRef path);
CGPathRef CGPathCreateCopy (CGPathRef path);
CGMutablePathRef CGPathCreateMutable ();
void CGPathMoveToPoint (CGMutablePathRef path, /*const*/ CGAffineTransform* m, CGFloat x, CGFloat y);
void CGPathRelease (CGPathRef path);



// CGRemoteOperation.h
CGError CGEnableEventStateCombining (bool doCombineState);
CGError CGPostKeyboardEvent (CGCharCode keyChar, CGKeyCode virtualKey, bool keyDown);
CGError CGPostMouseEvent (CGPoint mouseCursorPosition, bool updateMouseCursorPosition, CGButtonCount buttonCount, bool mouseButtonDown, ...);
CGError CGPostScrollWheelEvent (CGWheelCount wheelCount, int wheel1, ...);
CGError CGSetLocalEventsFilterDuringSuppressionState (CGEventFilterMask filter, CGEventSuppressionState state);
CGError CGSetLocalEventsSuppressionInterval (CFTimeInterval seconds);



//NSAccessibility.h
id NSAccessibilityActionDescription (id action);
void NSAccessibilityPostNotification (id element, id notification);
void NSAccessibilityRaiseBadArgumentException (id element, id attribute, id value);
id NSAccessibilityRoleDescription (id role, id subrole);
id NSAccessibilityRoleDescriptionForUIElement (id element);
id NSAccessibilityUnignoredAncestor (id element);
id NSAccessibilityUnignoredChildren (id originalChildren);
id NSAccessibilityUnignoredChildrenForOnlyChild (id originalChild);
id NSAccessibilityUnignoredDescendant (id element);

//NSGraphics.h
void NSBeep ();
NSInteger NSBitsPerPixelFromDepth (NSWindowDepth depth);
void NSCopyBits (NSInteger srcGState, NSRect srcRect, NSPoint destPoint);
NSInteger NSNumberOfColorComponents (id colorSpaceName);



// NSGeometry.h
bool NSEqualRects (NSRect aRect, NSRect bRect);
bool NSPointInRect (NSPoint aPoint, NSRect aRect);
NSRect NSIntersectionRect (NSRect aRect, NSRect bRect);
NSRect NSIntersectionRect (NSRect arg0, NSRect arg1, NSRect arg2) {
    return NSIntersectionRect(arg1, arg2);
}



// NSHFSFileTypes.h
id NSFileTypeForHFSTypeCode (OSType hfsFileTypeCode);



// NSObjCRuntime.h
/*const*/ char* NSGetSizeAndAlignment (/*const*/ char* typePtr, NSUInteger* sizep, NSUInteger* alignp);



// NSPathUtilities.h
id NSSearchPathForDirectoriesInDomains (NSSearchPathDirectory directory, NSSearchPathDomainMask domainMask,BOOL expandTilde);
id NSTemporaryDirectory ();



// Unknown
void CGContextCopyWindowContentsToRect (void* context, CGRect destRect, void* contextID, void* windowNumber, CGRect srcRect);