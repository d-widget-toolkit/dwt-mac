/**
 * Copyright: Copyright (c) 2008 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Nov 18, 2008
 * License: $(LINK2 http://opensource.org/licenses/bsd-license.php, BSD Style)
 *
 */
module dwt.internal.c.bindings;

import dwt.internal.c.Carbon;
import dwt.internal.objc.cocoa.Cocoa;
public import dwt.internal.cocoa.CGPoint;

extern (C):

// Appearance.h
int SetThemeCursor (ThemeCursor inCursor);
OSStatus GetThemeMetric (ThemeMetric inMetric, SInt32* outMetric);



// ATSFont.h
OSStatus ATSFontActivateFromFileReference (FSRef *iFile, ATSFontContext iContext, ATSFontFormat iFormat, void* iRefCon, ATSOptionFlags iOptions, ATSFontContainerRef *oContainer);


// CarbonEventsCore.h
uint GetCurrentButtonState ();



// CFBase.h
void CFRelease (CFTypeRef cf);



// CFData.h
UInt8* CFDataGetBytePtr (CFDataRef theData);
CFIndex CFDataGetLength (CFDataRef theData);



// CFRunLoop.h
void CFRunLoopAddObserver (CFRunLoopRef rl, CFRunLoopObserverRef observer, CFStringRef mode);
CFRunLoopRef CFRunLoopGetCurrent ();
CFRunLoopObserverRef CFRunLoopObserverCreate (CFAllocatorRef allocator, CFOptionFlags activities, Boolean repeats, CFIndex order, CFRunLoopObserverCallBack callout, CFRunLoopObserverContext* context);
void CFRunLoopObserverInvalidate (CFRunLoopObserverRef observer);



// CFURL.h
CFStringRef CFURLCreateStringByAddingPercentEscapes (CFAllocatorRef allocator, CFStringRef originalString,  CFStringRef charactersToLeaveUnescaped, CFStringRef legalURLCharactersToBeEscaped, CFStringEncoding encoding);



// CGRemoteOperation.h
CGError CGWarpMouseCursorPosition (CGPoint newCursorPosition);



// Event.h
uint GetDblTime ();
UInt8 LMGetKbdType ();


// Files.h
OSStatus FSPathMakeRef (/*const*/ UInt8* path, FSRef* ref_, bool* isDirectory);



// Gestalt.h
short Gestalt (uint selector, int* response);



// HITheme.h
OSStatus HIThemeDrawFocusRect(/*const*/ HIRect* inRect, bool inHasFocus, CGContextRef inContext, HIThemeOrientation inOrientation);



// MacApplication.h
OSStatus SetSystemUIMode (SystemUIMode inMode, SystemUIOptions inOptions);



// Menus.h
MenuRef AcquireRootMenu ();
OSStatus CancelMenuTracking (MenuRef inRootMenu, Boolean inImmediate, UInt32 inDismissalReason);



// Processes.h
short CPSSetProcessName (ProcessSerialNumber* PSN, char* processname);
short GetCurrentProcess (ProcessSerialNumber* PSN);
short SetFrontProcess (/*const*/ ProcessSerialNumber* PSN);
int TransformProcessType (/*const*/ ProcessSerialNumber* psn, ProcessApplicationTransformState transformState);



// Quickdraw.h
RgnHandle NewRgn ();
void RectRgn (RgnHandle rgn, /*const*/Rect* r);
void OpenRgn ();
void OffsetRgn (RgnHandle rgn, short dh, short dv);
void MoveTo (short h, short v);
void LineTo (short h, short v);
void UnionRgn (RgnHandle srcRgnA, RgnHandle srcRgnB, RgnHandle dstRgn);
void CloseRgn (RgnHandle dstRgn);
void DisposeRgn (RgnHandle rgn);
Boolean PtInRgn (Point pt, RgnHandle rgn);
Rect* GetRegionBounds (RgnHandle region, Rect* bounds);
void SectRgn (RgnHandle srcRgnA, RgnHandle srcRgnB, RgnHandle dstRgn);
Boolean EmptyRgn (RgnHandle rgn);
void DiffRgn (RgnHandle srcRgnA, RgnHandle srcRgnB, RgnHandle dstRgn);
Boolean RectInRgn (/*const*/Rect* r, RgnHandle rgn);
OSStatus QDRegionToRects (RgnHandle rgn, QDRegionParseDirection dir, RegionToRectsUPP proc, void* userData);
void CopyRgn (RgnHandle srcRgn, RgnHandle dstRgn);
void SetRect (Rect* r, short left, short top, short right, short bottom);



// TextInputSources.h
TISInputSourceRef TISCopyCurrentKeyboardInputSource ();
void* TISGetInputSourceProperty (TISInputSourceRef inputSource, CFStringRef propertyKey);



// UnicodeUtilities.h
OSStatus UCKeyTranslate (/*const*/ UCKeyboardLayout* keyLayoutPtr, UInt16 virtualKeyCode, UInt16 keyAction, UInt32 modifierKeyState, UInt32 keyboardType, OptionBits keyTranslateOptions, UInt32* deadKeyState, UniCharCount maxStringLength, UniCharCount* actualStringLength, UniChar* unicodeString);
//void call (void* proc, void* id, void* sel);