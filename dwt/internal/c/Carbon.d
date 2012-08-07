/**
 * Copyright: Copyright (c) 2008 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Nov 18, 2008
 * License: $(LINK2 http://opensource.org/licenses/bsd-license.php, BSD Style)
 *
 */
module dwt.internal.c.Carbon;

import dwt.dwthelper.utils;
import bindings = dwt.internal.c.bindings;
import dwt.internal.cocoa.CGRect;

// MacTypes.h

/********************************************************************************

 Base integer types for all target OS's and CPU's

 UInt8            8-bit unsigned integer
 SInt8            8-bit signed integer
 UInt16          16-bit uinteger
 SInt16          16-bit signed integer
 UInt32          32-bit uinteger
 SInt32          32-bit signed integer
 UInt64          64-bit uinteger
 SInt64          64-bit integer

 *********************************************************************************/
alias ubyte UInt8;
alias byte SInt8;
alias ushort UInt16;
alias short SInt16;
alias uint UInt32;
alias int SInt32;
alias ulong UInt64;
alias long SInt64;

alias byte uint8_t;

/********************************************************************************

 Higher level basic types

 OSErr                   16-bit result error code
 OSStatus                32-bit result error code
 LogicalAddress          Address in the clients virtual address space
 ConstLogicalAddress     Address in the clients virtual address space that will only be read
 PhysicalAddress         Real address as used on the hardware bus
 BytePtr                 Pointer to an array of bytes
 ByteCount               The size of an array of bytes
 ByteOffset              An offset into an array of bytes
 ItemCount               32-bit iteration count
 OptionBits              Standard 32-bit set of bit flags
 PBVersion               ?
 Duration                32-bit millisecond timer for drivers
 AbsoluteTime            64-bit clock
 ScriptCode              A particular set of written characters (e.g. Roman vs Cyrillic) and their encoding
 LangCode                A particular language (e.g. English), as represented using a particular ScriptCode
 RegionCode              Designates a language as used in a particular region (e.g. British vs American
 English) together with other region-dependent characteristics (e.g. date format)
 FourCharCode            A 32-bit value made by packing four 1 byte characters together
 OSType                  A FourCharCode used in the OS and file system (e.g. creator)
 ResType                 A FourCharCode used to tag resources (e.g. 'DLOG')

 *********************************************************************************/
alias SInt16 OSErr;
alias SInt32 OSStatus;
alias void* LogicalAddress;
alias /*const*/void* ConstLogicalAddress;
alias void* PhysicalAddress;
alias UInt8* BytePtr;
alias uint ByteCount;
alias uint ByteOffset;
alias SInt32 Duration;
alias UnsignedWide AbsoluteTime;
alias UInt32 OptionBits;
alias uint ItemCount;
alias UInt32 PBVersion;
alias SInt16 ScriptCode;
alias SInt16 LangCode;
alias SInt16 RegionCode;
alias UInt32 FourCharCode;
alias FourCharCode OSType;
alias FourCharCode ResType;
alias OSType* OSTypePtr;
alias ResType* ResTypePtr;

alias wchar UniChar;

static if ((void*).sizeof > int.sizeof) // 64bit target
	alias ulong UniCharCount;

else
	alias uint UniCharCount;

struct UnsignedWide
{
    uint hi;
    uint lo;
}

struct ProcessSerialNumber
{
    uint highLongOfPSN;
    uint lowLongOfPSN;
}

struct CPSProcessSerNum
{
    uint lo;
    uint hi;
}

alias ProcessSerialNumber* ProcessSerialNumberPtr;



// Appearance.h
enum ThemeCursor : uint
{
    kThemeArrowCursor = 0,
    kThemeCopyArrowCursor = 1,
    kThemeAliasArrowCursor = 2,
    kThemeContextualMenuArrowCursor = 3,
    kThemeIBeamCursor = 4,
    kThemeCrossCursor = 5,
    kThemePlusCursor = 6,
    kThemeWatchCursor = 7,
    kThemeClosedHandCursor = 8,
    kThemeOpenHandCursor = 9,
    kThemePointingHandCursor = 10,
    kThemeCountingUpHandCursor = 11,
    kThemeCountingDownHandCursor = 12,
    kThemeCountingUpAndDownHandCursor = 13,
    kThemeSpinningCursor = 14,
    kThemeResizeLeftCursor = 15,
    kThemeResizeRightCursor = 16,
    kThemeResizeLeftRightCursor = 17,
    kThemeNotAllowedCursor = 18,
    kThemeResizeUpCursor = 19,
    kThemeResizeDownCursor = 20,
    kThemeResizeUpDownCursor = 21,
    kThemePoofCursor = 22
}

alias UInt32 ThemeMetric;

alias bindings.SetThemeCursor SetThemeCursor;
alias bindings.GetThemeMetric GetThemeMetric;



// ATSFont.h
alias OptionBits ATSOptionFlags;
alias uint ATSFontContainerRef;

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



// CABase.h
static if ((void*).sizeof > int.sizeof) // 64bit target
    alias double CGFloat;

else
    alias float CGFloat;



// CarbonEventsCore.h
alias bindings.GetCurrentButtonState GetCurrentButtonState;



// CFBase.h
static if ((void*).sizeof > int.sizeof) // 64bit target
    alias long CFIndex;

else
    alias int CFIndex;

alias void* CFTypeRef;
struct __CFAllocator;
alias __CFAllocator* CFAllocatorRef;
struct __CFString;
alias __CFString* CFStringRef;
alias uint CFOptionFlags;

alias extern (C) void* function (void*) CFAllocatorRetainCallBack;
alias extern (C) void function (void*) CFAllocatorReleaseCallBack;
alias extern (C) CFStringRef function (void*) CFAllocatorCopyDescriptionCallBack;

alias bindings.CFRelease CFRelease;



// CFData.h
struct __CFData;
alias __CFData* CFDataRef;

alias bindings.CFDataGetBytePtr CFDataGetBytePtr;
alias bindings.CFDataGetLength CFDataGetLength;



// CFDate.h
alias double CFTimeInterval;



// CFNumberFormatter.h
enum
{
    kCFNumberFormatterPadBeforePrefix = 0,
    kCFNumberFormatterPadAfterPrefix = 1,
    kCFNumberFormatterPadBeforeSuffix = 2,
    kCFNumberFormatterPadAfterSuffix = 3
}

enum CFNumberFormatterRoundingMode
{
    kCFNumberFormatterRoundCeiling = 0,
    kCFNumberFormatterRoundFloor = 1,
    kCFNumberFormatterRoundDown = 2,
    kCFNumberFormatterRoundUp = 3,
    kCFNumberFormatterRoundHalfEven = 4,
    kCFNumberFormatterRoundHalfDown = 5,
    kCFNumberFormatterRoundHalfUp = 6
}

enum
{
    kCFNumberFormatterNoStyle = 0,
    kCFNumberFormatterDecimalStyle = 1,
    kCFNumberFormatterCurrencyStyle = 2,
    kCFNumberFormatterPercentStyle = 3,
    kCFNumberFormatterScientificStyle = 4,
    kCFNumberFormatterSpellOutStyle = 5
}



//CFPropertyList.h
enum CFPropertyListFormat
{
    kCFPropertyListOpenStepFormat = 1,
    kCFPropertyListXMLFormat_v1_0 = 100,
    kCFPropertyListBinaryFormat_v1_0 = 200
}

enum CFPropertyListMutabilityOptions
{
    kCFPropertyListImmutable = 0,
    kCFPropertyListMutableContainers = 1,
    kCFPropertyListMutableContainersAndLeaves = 2
}



// CFRunLoop.h
struct __CFRunLoop;
alias __CFRunLoop* CFRunLoopRef;
struct __CFRunLoopObserver;
alias __CFRunLoopObserver* CFRunLoopObserverRef;

enum CFRunLoopActivity
{
    kCFRunLoopEntry = (1 << 0),
    kCFRunLoopBeforeTimers = (1 << 1),
    kCFRunLoopBeforeSources = (1 << 2),
    kCFRunLoopBeforeWaiting = (1 << 5),
    kCFRunLoopAfterWaiting = (1 << 6),
    kCFRunLoopExit = (1 << 7),
    kCFRunLoopAllActivities = 0x0FFFFFFFU
}

alias extern (C) void function (CFRunLoopObserverRef observer, CFRunLoopActivity activity, void* info) CFRunLoopObserverCallBack;

struct CFRunLoopObserverContext
{
    CFIndex version_;
    void *info;
    CFAllocatorRetainCallBack retain;
    CFAllocatorReleaseCallBack release;
    CFAllocatorCopyDescriptionCallBack copyDescription;
}

alias bindings.CFRunLoopAddObserver CFRunLoopAddObserver;
alias bindings.CFRunLoopGetCurrent CFRunLoopGetCurrent;
alias bindings.CFRunLoopObserverCreate CFRunLoopObserverCreate;
alias bindings.CFRunLoopObserverInvalidate CFRunLoopObserverInvalidate;



// CFString.h
alias uint CFStringEncoding;



// CFURL.h
alias bindings.CFURLCreateStringByAddingPercentEscapes CFURLCreateStringByAddingPercentEscapes;



// CGColorSpace.h
alias void* CGColorSpace;
alias CGColorSpace* CGColorSpaceRef;



// CGError.h
alias int CGError;



// CGEventTypes.h
alias void* __CGEvent;
alias __CGEvent* CGEventRef;



// CGRemoteOperation.h
alias bindings.CGWarpMouseCursorPosition CGWarpMouseCursorPosition;



// Event.h
alias bindings.GetDblTime GetDblTime;
alias bindings.LMGetKbdType LMGetKbdType;


// Files.h
struct FSRef
{
	UInt8[80] hidden;
}

alias bindings.FSPathMakeRef FSPathMakeRef;



// Gestalt.h
alias bindings.Gestalt Gestalt;



// IconsCore.h
alias void* OpaqueIconRef;
alias OpaqueIconRef* IconRef;



// HITheme.h
enum HIThemeOrientation : uint
{
	kHIThemeOrientationNormal = 0,
	kHIThemeOrientationInverted = 1
}

alias CGRect HIRect;
alias bindings.HIThemeDrawFocusRect HIThemeDrawFocusRect;



// MacApplication.h
alias uint SystemUIMode;
alias bindings.SetSystemUIMode SetSystemUIMode;
alias OptionBits SystemUIOptions;



// Menus.h
struct OpaqueMenuRef;
alias OpaqueMenuRef* MenuRef;

alias bindings.AcquireRootMenu AcquireRootMenu;
alias bindings.CancelMenuTracking CancelMenuTracking;


// Processes.h
enum ProcessApplicationTransformState : uint
{
    kProcessTransformToForegroundApplication = 1
}

alias bindings.GetCurrentProcess GetCurrentProcess;
alias bindings.SetFrontProcess SetFrontProcess;
alias bindings.TransformProcessType TransformProcessType;
alias bindings.CPSSetProcessName CPSSetProcessName;



// Quickdraw.h
struct Rect
{
    short top;
    short left;
    short bottom;
    short right;
}

alias int QDRegionParseDirection;
alias extern (C) OSStatus function (ushort message, RgnHandle rgn, /*const*/ Rect* rect, void* refCon) RegionToRectsProcPtr;
alias RegionToRectsProcPtr RegionToRectsUPP;

alias bindings.NewRgn NewRgn;
alias bindings.RectRgn RectRgn;
alias bindings.OpenRgn OpenRgn;
alias bindings.OffsetRgn OffsetRgn;
alias bindings.MoveTo MoveTo;
alias bindings.LineTo LineTo;
alias bindings.UnionRgn UnionRgn;
alias bindings.CloseRgn CloseRgn;
alias bindings.DisposeRgn DisposeRgn;
alias bindings.PtInRgn PtInRgn;
alias bindings.GetRegionBounds GetRegionBounds;
alias bindings.SectRgn SectRgn;
alias bindings.EmptyRgn EmptyRgn;
alias bindings.DiffRgn DiffRgn;
alias bindings.RectInRgn RectInRgn;
alias bindings.QDRegionToRects QDRegionToRects;
alias bindings.CopyRgn CopyRgn;
alias bindings.SetRect SetRect;



// QuickdrawTypes.h
struct MacRegion
{
    ushort rgnSize; /* size in bytes; don't rely on it */
    Rect rgnBBox; /* enclosing rectangle; in Carbon use GetRegionBounds */
}

struct Point
{
    short v;
    short h;
}

alias MacRegion Region;
alias MacRegion* RgnPtr;
alias RgnPtr* RgnHandle;

alias bool Boolean;
alias bool BOOL;

enum
{
    kQDRegionToRectsMsgInit = 1,
    kQDRegionToRectsMsgParse = 2,
    kQDRegionToRectsMsgTerminate = 3
}

enum
{
    kQDParseRegionFromTop = (1 << 0),
    kQDParseRegionFromBottom = (1 << 1),
    kQDParseRegionFromLeft = (1 << 2),
    kQDParseRegionFromRight = (1 << 3),
    kQDParseRegionFromTopLeft = kQDParseRegionFromTop | kQDParseRegionFromLeft,
    kQDParseRegionFromBottomRight = kQDParseRegionFromBottom |  kQDParseRegionFromRight
}



// TextInputSources.h
struct __TISInputSource;
alias __TISInputSource* TISInputSourceRef;

alias bindings.TISCopyCurrentKeyboardInputSource TISCopyCurrentKeyboardInputSource;
alias bindings.TISGetInputSourceProperty TISGetInputSourceProperty;

extern (C)
{
	extern
	{
		/*const*/ CFStringRef kTISPropertyUnicodeKeyLayoutData;
	}
}



// UnicodeUtilities.h
struct UCKeyboardTypeHeader
{
	UInt32 keyboardTypeFirst;
	UInt32 keyboardTypeLast;
	ByteOffset keyModifiersToTableNumOffset;
	ByteOffset keyToCharTableIndexOffset;
	ByteOffset keyStateRecordsIndexOffset;
	ByteOffset keyStateTerminatorsOffset;
	ByteOffset keySequenceDataIndexOffset;
}

struct UCKeyboardLayout
{
	UInt16 keyLayoutHeaderFormat;
	UInt16 keyLayoutDataVersion;
	ByteOffset keyLayoutFeatureInfoOffset;
	ItemCount keyboardTypeCount;
	UCKeyboardTypeHeader[1] keyboardTypeList;
}

alias bindings.UCKeyTranslate UCKeyTranslate;



// Unknown
alias bindings.call call;