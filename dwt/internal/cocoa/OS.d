/*******************************************************************************
 * Copyright (c) 2007, 2009 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *******************************************************************************/
module dwt.internal.cocoa.OS;

// These enums need to be up here otherwise they'll cause forward reference errors
// NSScroller.h
enum NSScrollerPart
{
    NSScrollerNoPart = 0,
    NSScrollerDecrementPage = 1,
    NSScrollerKnob = 2,
    NSScrollerIncrementPage = 3,
    NSScrollerDecrementLine = 4,
    NSScrollerIncrementLine = 5,
    NSScrollerKnobSlot = 6
}

// NSView.h
enum NSBorderType
{
    NSNoBorder = 0,
    NSLineBorder = 1,
    NSBezelBorder = 2,
    NSGrooveBorder = 3
}



import dwt.dwthelper.utils;



import tango.core.Memory;
import unistd = tango.stdc.posix.unistd;
import stdc = tango.stdc.string;

import Carbon = dwt.internal.c.Carbon;
import custom = dwt.internal.c.custom;
import dwt.internal.cocoa.CGPoint;
import dwt.internal.cocoa.CGRect;
import dwt.internal.cocoa.CGSize;
import dwt.internal.cocoa.NSAffineTransformStruct;
import dwt.internal.cocoa.NSAlert;
import dwt.internal.cocoa.NSApplication;
import dwt.internal.cocoa.NSBezierPath;
import dwt.internal.cocoa.NSBitmapImageRep;
import dwt.internal.cocoa.NSBox;
import dwt.internal.cocoa.NSButtonCell;
import dwt.internal.cocoa.NSCell;
import dwt.internal.cocoa.NSEvent;
import dwt.internal.cocoa.NSGradient;
import dwt.internal.cocoa.NSGraphicsContext;
import dwt.internal.cocoa.NSImage;
import dwt.internal.cocoa.NSImageCell;
import dwt.internal.cocoa.NSParagraphStyle;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSRange;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSScrollView;
import dwt.internal.cocoa.NSScroller;
import dwt.internal.cocoa.NSSize;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSText;
import dwt.internal.cocoa.NSView;
import NSWindowTypes = dwt.internal.cocoa.NSWindow;
import Cocoa = dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

public class OS : C {
    /*static this (){
        Library.loadLibrary("swt-pi"); //$NON-NLS-1$
    }*/

    public static const int VERSION;
    static this () {
        int [1] response;
        OS.Gestalt (OS.gestaltSystemVersion, response.ptr);
        VERSION = response [0] & 0xffff;

		sel_sendSearchSelection = sel_registerName("sendSearchSelection");
		sel_sendCancelSelection = sel_registerName("sendCancelSelection");
		sel_sendSelection = sel_registerName("sendSelection");
		sel_sendSelection_ = sel_registerName("sendSelection:");
		sel_sendDoubleSelection = sel_registerName("sendDoubleSelection");
		sel_sendVerticalSelection = sel_registerName("sendVerticalSelection");
		sel_sendHorizontalSelection = sel_registerName("sendHorizontalSelection");
		sel_timerProc_ = sel_registerName("timerProc:");
		sel_handleNotification_ = sel_registerName("handleNotification:");
		sel_callJava = sel_registerName("callJava:index:arg:");
		sel_quitRequested_ = sel_registerName("quitRequested:");
		sel_systemSettingsChanged_ = sel_registerName("systemSettingsChanged:");
		sel_panelDidEnd_returnCode_contextInfo_ = sel_registerName("panelDidEnd:returnCode:contextInfo:");
		sel_updateOpenGLContext_ = sel_registerName("updateOpenGLContext:");

		sel_overwriteExistingFileCheck = sel_registerName("_overwriteExistingFileCheck:");
		sel_setShowsHiddenFiles_ = sel_registerName("setShowsHiddenFiles:");

		sel_setMovable_ = OS.sel_registerName("setMovable:");

		sel_contextID = OS.sel_registerName("contextID");

		sel__drawThemeProgressArea_ = OS.sel_registerName("_drawThemeProgressArea:");

		sel__setNeedsToUseHeartBeatWindow_ = OS.sel_registerName("_setNeedsToUseHeartBeatWindow:");

		class_WebPanelAuthenticationHandler = OS.objc_getClass("WebPanelAuthenticationHandler");
		sel_sharedHandler = sel_registerName("sharedHandler");
		sel_startAuthentication = sel_registerName("startAuthentication:window:");

		/* These are not generated in order to avoid creating static methods on all classes */
		sel_isSelectorExcludedFromWebScript_ = sel_registerName("isSelectorExcludedFromWebScript:");
		sel_webScriptNameForSelector_ = sel_registerName("webScriptNameForSelector:");



        class_DOMDocument = objc_getClass("DOMDocument");
        class_DOMEvent = objc_getClass("DOMEvent");
        class_DOMKeyboardEvent = objc_getClass("DOMKeyboardEvent");
        class_DOMMouseEvent = objc_getClass("DOMMouseEvent");
        class_DOMUIEvent = objc_getClass("DOMUIEvent");
        class_DOMWheelEvent = objc_getClass("DOMWheelEvent");
        class_NSActionCell = objc_getClass("NSActionCell");
        class_NSAffineTransform = objc_getClass("NSAffineTransform");
        class_NSAlert = objc_getClass("NSAlert");
        class_NSAppleEventDescriptor = objc_getClass("NSAppleEventDescriptor");
        class_NSApplication = objc_getClass("NSApplication");
        class_NSArray = objc_getClass("NSArray");
        class_NSAttributedString = objc_getClass("NSAttributedString");
        class_NSAutoreleasePool = objc_getClass("NSAutoreleasePool");
        class_NSBezierPath = objc_getClass("NSBezierPath");
        class_NSBitmapImageRep = objc_getClass("NSBitmapImageRep");
        class_NSBox = objc_getClass("NSBox");
        class_NSBrowserCell = objc_getClass("NSBrowserCell");
        class_NSBundle = objc_getClass("NSBundle");
        class_NSButton = objc_getClass("NSButton");
        class_NSButtonCell = objc_getClass("NSButtonCell");
        class_NSCalendarDate = objc_getClass("NSCalendarDate");
        class_NSCell = objc_getClass("NSCell");
        class_NSCharacterSet = objc_getClass("NSCharacterSet");
        class_NSClipView = objc_getClass("NSClipView");
        class_NSCoder = objc_getClass("NSCoder");
        class_NSColor = objc_getClass("NSColor");
        class_NSColorPanel = objc_getClass("NSColorPanel");
        class_NSColorSpace = objc_getClass("NSColorSpace");
        class_NSComboBox = objc_getClass("NSComboBox");
        class_NSComboBoxCell = objc_getClass("NSComboBoxCell");
        class_NSControl = objc_getClass("NSControl");
        class_NSCursor = objc_getClass("NSCursor");
        class_NSData = objc_getClass("NSData");
        class_NSDate = objc_getClass("NSDate");
        class_NSDatePicker = objc_getClass("NSDatePicker");
        class_NSDictionary = objc_getClass("NSDictionary");
        class_NSDirectoryEnumerator = objc_getClass("NSDirectoryEnumerator");
        class_NSEnumerator = objc_getClass("NSEnumerator");
        class_NSError = objc_getClass("NSError");
        class_NSEvent = objc_getClass("NSEvent");
        class_NSFileManager = objc_getClass("NSFileManager");
        class_NSFileWrapper = objc_getClass("NSFileWrapper");
        class_NSFont = objc_getClass("NSFont");
        class_NSFontManager = objc_getClass("NSFontManager");
        class_NSFontPanel = objc_getClass("NSFontPanel");
        class_NSFormatter = objc_getClass("NSFormatter");
        class_NSGradient = objc_getClass("NSGradient");
        class_NSGraphicsContext = objc_getClass("NSGraphicsContext");
        class_NSHTTPCookie = objc_getClass("NSHTTPCookie");
        class_NSHTTPCookieStorage = objc_getClass("NSHTTPCookieStorage");
        class_NSImage = objc_getClass("NSImage");
        class_NSImageRep = objc_getClass("NSImageRep");
        class_NSImageView = objc_getClass("NSImageView");
        class_NSIndexSet = objc_getClass("NSIndexSet");
        class_NSInputManager = objc_getClass("NSInputManager");
        class_NSKeyedArchiver = objc_getClass("NSKeyedArchiver");
        class_NSKeyedUnarchiver = objc_getClass("NSKeyedUnarchiver");
        class_NSLayoutManager = objc_getClass("NSLayoutManager");
        class_NSMenu = objc_getClass("NSMenu");
        class_NSMenuItem = objc_getClass("NSMenuItem");
        class_NSMutableArray = objc_getClass("NSMutableArray");
        class_NSMutableAttributedString = objc_getClass("NSMutableAttributedString");
        class_NSMutableDictionary = objc_getClass("NSMutableDictionary");
        class_NSMutableIndexSet = objc_getClass("NSMutableIndexSet");
        class_NSMutableParagraphStyle = objc_getClass("NSMutableParagraphStyle");
        class_NSMutableSet = objc_getClass("NSMutableSet");
        class_NSMutableString = objc_getClass("NSMutableString");
        class_NSMutableURLRequest = objc_getClass("NSMutableURLRequest");
        class_NSNotification = objc_getClass("NSNotification");
        class_NSNotificationCenter = objc_getClass("NSNotificationCenter");
        class_NSNumber = objc_getClass("NSNumber");
        class_NSNumberFormatter = objc_getClass("NSNumberFormatter");
        class_NSObject = objc_getClass("NSObject");
        class_NSOpenGLContext = objc_getClass("NSOpenGLContext");
        class_NSOpenGLPixelFormat = objc_getClass("NSOpenGLPixelFormat");
        class_NSOpenGLView = objc_getClass("NSOpenGLView");
        class_NSOpenPanel = objc_getClass("NSOpenPanel");
        class_NSOutlineView = objc_getClass("NSOutlineView");
        class_NSPanel = objc_getClass("NSPanel");
        class_NSParagraphStyle = objc_getClass("NSParagraphStyle");
        class_NSPasteboard = objc_getClass("NSPasteboard");
        class_NSPopUpButton = objc_getClass("NSPopUpButton");
        class_NSPrintInfo = objc_getClass("NSPrintInfo");
        class_NSPrintOperation = objc_getClass("NSPrintOperation");
        class_NSPrintPanel = objc_getClass("NSPrintPanel");
        class_NSPrinter = objc_getClass("NSPrinter");
        class_NSProgressIndicator = objc_getClass("NSProgressIndicator");
        class_NSResponder = objc_getClass("NSResponder");
        class_NSRunLoop = objc_getClass("NSRunLoop");
        class_NSSavePanel = objc_getClass("NSSavePanel");
        class_NSScreen = objc_getClass("NSScreen");
        class_NSScrollView = objc_getClass("NSScrollView");
        class_NSScroller = objc_getClass("NSScroller");
        class_NSSearchField = objc_getClass("NSSearchField");
        class_NSSearchFieldCell = objc_getClass("NSSearchFieldCell");
        class_NSSecureTextField = objc_getClass("NSSecureTextField");
        class_NSSegmentedCell = objc_getClass("NSSegmentedCell");
        class_NSSet = objc_getClass("NSSet");
        class_NSSlider = objc_getClass("NSSlider");
        class_NSStatusBar = objc_getClass("NSStatusBar");
        class_NSStatusItem = objc_getClass("NSStatusItem");
        class_NSStepper = objc_getClass("NSStepper");
        class_NSString = objc_getClass("NSString");
        class_NSTabView = objc_getClass("NSTabView");
        class_NSTabViewItem = objc_getClass("NSTabViewItem");
        class_NSTableColumn = objc_getClass("NSTableColumn");
        class_NSTableHeaderCell = objc_getClass("NSTableHeaderCell");
        class_NSTableHeaderView = objc_getClass("NSTableHeaderView");
        class_NSTableView = objc_getClass("NSTableView");
        class_NSText = objc_getClass("NSText");
        class_NSTextAttachment = objc_getClass("NSTextAttachment");
        class_NSTextContainer = objc_getClass("NSTextContainer");
        class_NSTextField = objc_getClass("NSTextField");
        class_NSTextFieldCell = objc_getClass("NSTextFieldCell");
        class_NSTextStorage = objc_getClass("NSTextStorage");
        class_NSTextTab = objc_getClass("NSTextTab");
        class_NSTextView = objc_getClass("NSTextView");
        class_NSThread = objc_getClass("NSThread");
        class_NSTimeZone = objc_getClass("NSTimeZone");
        class_NSTimer = objc_getClass("NSTimer");
        class_NSToolbar = objc_getClass("NSToolbar");
        class_NSToolbarItem = objc_getClass("NSToolbarItem");
        class_NSTrackingArea = objc_getClass("NSTrackingArea");
        class_NSTypesetter = objc_getClass("NSTypesetter");
        class_NSURL = objc_getClass("NSURL");
        class_NSURLAuthenticationChallenge = objc_getClass("NSURLAuthenticationChallenge");
        class_NSURLCredential = objc_getClass("NSURLCredential");
        class_NSURLDownload = objc_getClass("NSURLDownload");
        class_NSURLRequest = objc_getClass("NSURLRequest");
        class_NSValue = objc_getClass("NSValue");
        class_NSView = objc_getClass("NSView");
        class_NSWindow = objc_getClass("NSWindow");
        class_NSWorkspace = objc_getClass("NSWorkspace");
        class_WebDataSource = objc_getClass("WebDataSource");
        class_WebFrame = objc_getClass("WebFrame");
        class_WebFrameView = objc_getClass("WebFrameView");
        class_WebPreferences = objc_getClass("WebPreferences");
        class_WebView = objc_getClass("WebView");
        class_NSURLProtectionSpace = objc_getClass("NSURLProtectionSpace");
        class_WebScriptObject = objc_getClass("WebScriptObject");
        class_WebUndefined = objc_getClass("WebUndefined");

        protocol_NSAccessibility = objc_getProtocol("NSAccessibility");
        protocol_NSAccessibilityAdditions = objc_getProtocol("NSAccessibilityAdditions");
        protocol_NSApplicationDelegate = objc_getProtocol("NSApplicationDelegate");
        protocol_NSApplicationNotifications = objc_getProtocol("NSApplicationNotifications");
        protocol_NSColorPanelResponderMethod = objc_getProtocol("NSColorPanelResponderMethod");
        protocol_NSComboBoxNotifications = objc_getProtocol("NSComboBoxNotifications");
        protocol_NSDraggingDestination = objc_getProtocol("NSDraggingDestination");
        protocol_NSDraggingSource = objc_getProtocol("NSDraggingSource");
        protocol_NSFontManagerResponderMethod = objc_getProtocol("NSFontManagerResponderMethod");
        protocol_NSMenuDelegate = objc_getProtocol("NSMenuDelegate");
        protocol_NSOutlineViewDataSource = objc_getProtocol("NSOutlineViewDataSource");
        protocol_NSOutlineViewDelegate = objc_getProtocol("NSOutlineViewDelegate");
        protocol_NSOutlineViewNotifications = objc_getProtocol("NSOutlineViewNotifications");
        protocol_NSPasteboardOwner = objc_getProtocol("NSPasteboardOwner");
        protocol_NSSavePanelDelegate = objc_getProtocol("NSSavePanelDelegate");
        protocol_NSTabViewDelegate = objc_getProtocol("NSTabViewDelegate");
        protocol_NSTableDataSource = objc_getProtocol("NSTableDataSource");
        protocol_NSTableViewDelegate = objc_getProtocol("NSTableViewDelegate");
        protocol_NSTableViewNotifications = objc_getProtocol("NSTableViewNotifications");
        protocol_NSTextDelegate = objc_getProtocol("NSTextDelegate");
        protocol_NSTextInput = objc_getProtocol("NSTextInput");
        protocol_NSTextViewDelegate = objc_getProtocol("NSTextViewDelegate");
        protocol_NSToolTipOwner = objc_getProtocol("NSToolTipOwner");
        protocol_NSToolbarDelegate = objc_getProtocol("NSToolbarDelegate");
        protocol_NSToolbarNotifications = objc_getProtocol("NSToolbarNotifications");
        protocol_NSURLDownloadDelegate = objc_getProtocol("NSURLDownloadDelegate");
        protocol_NSWindowDelegate = objc_getProtocol("NSWindowDelegate");
        protocol_NSWindowNotifications = objc_getProtocol("NSWindowNotifications");
        protocol_WebDocumentRepresentation = objc_getProtocol("WebDocumentRepresentation");
        protocol_WebFrameLoadDelegate = objc_getProtocol("WebFrameLoadDelegate");
        protocol_WebOpenPanelResultListener = objc_getProtocol("WebOpenPanelResultListener");
        protocol_WebPolicyDecisionListener = objc_getProtocol("WebPolicyDecisionListener");
        protocol_WebPolicyDelegate = objc_getProtocol("WebPolicyDelegate");
        protocol_WebResourceLoadDelegate = objc_getProtocol("WebResourceLoadDelegate");
        protocol_WebUIDelegate = objc_getProtocol("WebUIDelegate");

        sel_abortEditing = sel_registerName("abortEditing");
        sel_absoluteString = sel_registerName("absoluteString");
        sel_acceptsFirstMouse_ = sel_registerName("acceptsFirstMouse:");
        sel_acceptsFirstResponder = sel_registerName("acceptsFirstResponder");
        sel_accessibilityActionDescription_ = sel_registerName("accessibilityActionDescription:");
        sel_accessibilityActionNames = sel_registerName("accessibilityActionNames");
        sel_accessibilityAttributeNames = sel_registerName("accessibilityAttributeNames");
        sel_accessibilityAttributeValue_ = sel_registerName("accessibilityAttributeValue:");
        sel_accessibilityAttributeValue_forParameter_ = sel_registerName("accessibilityAttributeValue:forParameter:");
        sel_accessibilityFocusedUIElement = sel_registerName("accessibilityFocusedUIElement");
        sel_accessibilityHitTest_ = sel_registerName("accessibilityHitTest:");
        sel_accessibilityIsAttributeSettable_ = sel_registerName("accessibilityIsAttributeSettable:");
        sel_accessibilityIsIgnored = sel_registerName("accessibilityIsIgnored");
        sel_accessibilityParameterizedAttributeNames = sel_registerName("accessibilityParameterizedAttributeNames");
        sel_accessibilityPerformAction_ = sel_registerName("accessibilityPerformAction:");
        sel_accessibilitySetOverrideValue_forAttribute_ = sel_registerName("accessibilitySetOverrideValue:forAttribute:");
        sel_accessibilitySetValue_forAttribute_ = sel_registerName("accessibilitySetValue:forAttribute:");
        sel_action = sel_registerName("action");
        sel_activateIgnoringOtherApps_ = sel_registerName("activateIgnoringOtherApps:");
        sel_addAttribute_value_range_ = sel_registerName("addAttribute:value:range:");
        sel_addButtonWithTitle_ = sel_registerName("addButtonWithTitle:");
        sel_addChildWindow_ordered_ = sel_registerName("addChildWindow:ordered:");
        sel_addClip = sel_registerName("addClip");
        sel_addEventListener_listener_useCapture_ = sel_registerName("addEventListener:listener:useCapture:");
        sel_addIndex_ = sel_registerName("addIndex:");
        sel_addItemWithObjectValue_ = sel_registerName("addItemWithObjectValue:");
        sel_addItemWithTitle_action_keyEquivalent_ = sel_registerName("addItemWithTitle:action:keyEquivalent:");
        sel_addItem_ = sel_registerName("addItem:");
        sel_addLayoutManager_ = sel_registerName("addLayoutManager:");
        sel_addObjectsFromArray_ = sel_registerName("addObjectsFromArray:");
        sel_addObject_ = sel_registerName("addObject:");
        sel_addObserver_selector_name_object_ = sel_registerName("addObserver:selector:name:object:");
        sel_addRepresentation_ = sel_registerName("addRepresentation:");
        sel_addSubview_ = sel_registerName("addSubview:");
        sel_addSubview_positioned_relativeTo_ = sel_registerName("addSubview:positioned:relativeTo:");
        sel_addTableColumn_ = sel_registerName("addTableColumn:");
        sel_addTabStop_ = sel_registerName("addTabStop:");
        sel_addTabViewItem_ = sel_registerName("addTabViewItem:");
        sel_addTemporaryAttribute_value_forCharacterRange_ = sel_registerName("addTemporaryAttribute:value:forCharacterRange:");
        sel_addTextContainer_ = sel_registerName("addTextContainer:");
        sel_addTimer_forMode_ = sel_registerName("addTimer:forMode:");
        sel_addToolTipRect_owner_userData_ = sel_registerName("addToolTipRect:owner:userData:");
        sel_addTypes_owner_ = sel_registerName("addTypes:owner:");
        sel_alertWithMessageText_defaultButton_alternateButton_otherButton_informativeTextWithFormat_ = sel_registerName("alertWithMessageText:defaultButton:alternateButton:otherButton:informativeTextWithFormat:");
        sel_alignment = sel_registerName("alignment");
        sel_allKeys = sel_registerName("allKeys");
        sel_alloc = sel_registerName("alloc");
        sel_allowsColumnReordering = sel_registerName("allowsColumnReordering");
        sel_allowsFloats = sel_registerName("allowsFloats");
        sel_alphaComponent = sel_registerName("alphaComponent");
        sel_alphaValue = sel_registerName("alphaValue");
        sel_alternateSelectedControlColor = sel_registerName("alternateSelectedControlColor");
        sel_alternateSelectedControlTextColor = sel_registerName("alternateSelectedControlTextColor");
        sel_altKey = sel_registerName("altKey");
        sel_alwaysShowsDecimalSeparator = sel_registerName("alwaysShowsDecimalSeparator");
        sel_appendAttributedString_ = sel_registerName("appendAttributedString:");
        sel_appendBezierPathWithArcWithCenter_radius_startAngle_endAngle_ = sel_registerName("appendBezierPathWithArcWithCenter:radius:startAngle:endAngle:");
        sel_appendBezierPathWithArcWithCenter_radius_startAngle_endAngle_clockwise_ = sel_registerName("appendBezierPathWithArcWithCenter:radius:startAngle:endAngle:clockwise:");
        sel_appendBezierPathWithGlyphs_count_inFont_ = sel_registerName("appendBezierPathWithGlyphs:count:inFont:");
        sel_appendBezierPathWithOvalInRect_ = sel_registerName("appendBezierPathWithOvalInRect:");
        sel_appendBezierPathWithRect_ = sel_registerName("appendBezierPathWithRect:");
        sel_appendBezierPathWithRoundedRect_xRadius_yRadius_ = sel_registerName("appendBezierPathWithRoundedRect:xRadius:yRadius:");
        sel_appendBezierPath_ = sel_registerName("appendBezierPath:");
        sel_appendString_ = sel_registerName("appendString:");
        sel_applicationDidBecomeActive_ = sel_registerName("applicationDidBecomeActive:");
        sel_applicationDidFinishLaunching_ = sel_registerName("applicationDidFinishLaunching:");
        sel_applicationDidResignActive_ = sel_registerName("applicationDidResignActive:");
        sel_applicationShouldTerminate_ = sel_registerName("applicationShouldTerminate:");
        sel_applicationWillFinishLaunching_ = sel_registerName("applicationWillFinishLaunching:");
        sel_applicationWillResignActive_ = sel_registerName("applicationWillResignActive:");
        sel_applicationWillTerminate_ = sel_registerName("applicationWillTerminate:");
        sel_archivedDataWithRootObject_ = sel_registerName("archivedDataWithRootObject:");
        sel_areCursorRectsEnabled = sel_registerName("areCursorRectsEnabled");
        sel_array = sel_registerName("array");
        sel_arrayWithCapacity_ = sel_registerName("arrayWithCapacity:");
        sel_arrayWithObject_ = sel_registerName("arrayWithObject:");
        sel_arrowCursor = sel_registerName("arrowCursor");
        sel_ascender = sel_registerName("ascender");
        sel_attributedStringValue = sel_registerName("attributedStringValue");
        sel_attributedStringWithAttachment_ = sel_registerName("attributedStringWithAttachment:");
        sel_attributedSubstringFromRange_ = sel_registerName("attributedSubstringFromRange:");
        sel_attributedTitle = sel_registerName("attributedTitle");
        sel_attributesAtIndex_longestEffectiveRange_inRange_ = sel_registerName("attributesAtIndex:longestEffectiveRange:inRange:");
        sel_autorelease = sel_registerName("autorelease");
        sel_availableFontFamilies = sel_registerName("availableFontFamilies");
        sel_availableFonts = sel_registerName("availableFonts");
        sel_availableMembersOfFontFamily_ = sel_registerName("availableMembersOfFontFamily:");
        sel_availableTypeFromArray_ = sel_registerName("availableTypeFromArray:");
        sel_baselineOffsetInLayoutManager_glyphIndex_ = sel_registerName("baselineOffsetInLayoutManager:glyphIndex:");
        sel_becomeFirstResponder = sel_registerName("becomeFirstResponder");
        sel_becomeKeyWindow = sel_registerName("becomeKeyWindow");
        sel_beginDocument = sel_registerName("beginDocument");
        sel_beginEditing = sel_registerName("beginEditing");
        sel_beginPageInRect_atPlacement_ = sel_registerName("beginPageInRect:atPlacement:");
        sel_beginSheetModalForWindow_modalDelegate_didEndSelector_contextInfo_ = sel_registerName("beginSheetModalForWindow:modalDelegate:didEndSelector:contextInfo:");
        sel_beginSheetWithPrintInfo_modalForWindow_delegate_didEndSelector_contextInfo_ = sel_registerName("beginSheetWithPrintInfo:modalForWindow:delegate:didEndSelector:contextInfo:");
        sel_beginSheet_modalForWindow_modalDelegate_didEndSelector_contextInfo_ = sel_registerName("beginSheet:modalForWindow:modalDelegate:didEndSelector:contextInfo:");
        sel_bestRepresentationForDevice_ = sel_registerName("bestRepresentationForDevice:");
        sel_bezierPath = sel_registerName("bezierPath");
        sel_bezierPathByFlatteningPath = sel_registerName("bezierPathByFlatteningPath");
        sel_bezierPathWithRect_ = sel_registerName("bezierPathWithRect:");
        sel_bitmapData = sel_registerName("bitmapData");
        sel_bitmapFormat = sel_registerName("bitmapFormat");
        sel_bitsPerPixel = sel_registerName("bitsPerPixel");
        sel_bitsPerSample = sel_registerName("bitsPerSample");
        sel_blackColor = sel_registerName("blackColor");
        sel_blueComponent = sel_registerName("blueComponent");
        sel_boolValue = sel_registerName("boolValue");
        sel_borderWidth = sel_registerName("borderWidth");
        sel_boundingRectForGlyphRange_inTextContainer_ = sel_registerName("boundingRectForGlyphRange:inTextContainer:");
        sel_bounds = sel_registerName("bounds");
        sel_bundleIdentifier = sel_registerName("bundleIdentifier");
        sel_bundlePath = sel_registerName("bundlePath");
        sel_bundleWithIdentifier_ = sel_registerName("bundleWithIdentifier:");
        sel_bundleWithPath_ = sel_registerName("bundleWithPath:");
        sel_button = sel_registerName("button");
        sel_buttonNumber = sel_registerName("buttonNumber");
        sel_bytes = sel_registerName("bytes");
        sel_bytesPerPlane = sel_registerName("bytesPerPlane");
        sel_bytesPerRow = sel_registerName("bytesPerRow");
        sel_calendarDate = sel_registerName("calendarDate");
        sel_canBecomeKeyView = sel_registerName("canBecomeKeyView");
        sel_canBecomeKeyWindow = sel_registerName("canBecomeKeyWindow");
        sel_cancel = sel_registerName("cancel");
        sel_cancelAuthenticationChallenge_ = sel_registerName("cancelAuthenticationChallenge:");
        sel_cancelButtonCell = sel_registerName("cancelButtonCell");
        sel_cancelTracking = sel_registerName("cancelTracking");
        sel_canDragRowsWithIndexes_atPoint_ = sel_registerName("canDragRowsWithIndexes:atPoint:");
        sel_canGoBack = sel_registerName("canGoBack");
        sel_canGoForward = sel_registerName("canGoForward");
        sel_canShowMIMEType_ = sel_registerName("canShowMIMEType:");
        sel_cascadeTopLeftFromPoint_ = sel_registerName("cascadeTopLeftFromPoint:");
        sel_cell = sel_registerName("cell");
        sel_cellClass = sel_registerName("cellClass");
        sel_cellSize = sel_registerName("cellSize");
        sel_cellSizeForBounds_ = sel_registerName("cellSizeForBounds:");
        sel_CGEvent = sel_registerName("CGEvent");
        sel_changeColor_ = sel_registerName("changeColor:");
        sel_changeFont_ = sel_registerName("changeFont:");
        sel_characterAtIndex_ = sel_registerName("characterAtIndex:");
        sel_characterIndexForGlyphAtIndex_ = sel_registerName("characterIndexForGlyphAtIndex:");
        sel_characterIndexForInsertionAtPoint_ = sel_registerName("characterIndexForInsertionAtPoint:");
        sel_characterIndexForPoint_ = sel_registerName("characterIndexForPoint:");
        sel_characterIsMember_ = sel_registerName("characterIsMember:");
        sel_characters = sel_registerName("characters");
        sel_charactersIgnoringModifiers = sel_registerName("charactersIgnoringModifiers");
        sel_charCode = sel_registerName("charCode");
        sel_chooseFilename_ = sel_registerName("chooseFilename:");
        sel_className = sel_registerName("className");
        sel_cleanUpOperation = sel_registerName("cleanUpOperation");
        sel_clearColor = sel_registerName("clearColor");
        sel_clearCurrentContext = sel_registerName("clearCurrentContext");
        sel_clearDrawable = sel_registerName("clearDrawable");
        sel_clearGLContext = sel_registerName("clearGLContext");
        sel_clickCount = sel_registerName("clickCount");
        sel_clickedColumn = sel_registerName("clickedColumn");
        sel_clickedRow = sel_registerName("clickedRow");
        sel_clientX = sel_registerName("clientX");
        sel_clientY = sel_registerName("clientY");
        sel_close = sel_registerName("close");
        sel_closePath = sel_registerName("closePath");
        sel_code = sel_registerName("code");
        sel_collapseItem_ = sel_registerName("collapseItem:");
        sel_collapseItem_collapseChildren_ = sel_registerName("collapseItem:collapseChildren:");
        sel_color = sel_registerName("color");
        sel_colorAtX_y_ = sel_registerName("colorAtX:y:");
        sel_colorSpaceName = sel_registerName("colorSpaceName");
        sel_colorUsingColorSpaceName_ = sel_registerName("colorUsingColorSpaceName:");
        sel_colorUsingColorSpace_ = sel_registerName("colorUsingColorSpace:");
        sel_colorWithDeviceRed_green_blue_alpha_ = sel_registerName("colorWithDeviceRed:green:blue:alpha:");
        sel_colorWithPatternImage_ = sel_registerName("colorWithPatternImage:");
        sel_columnAtPoint_ = sel_registerName("columnAtPoint:");
        sel_columnAutoresizingStyle = sel_registerName("columnAutoresizingStyle");
        sel_columnIndexesInRect_ = sel_registerName("columnIndexesInRect:");
        sel_columnWithIdentifier_ = sel_registerName("columnWithIdentifier:");
        sel_comboBoxSelectionDidChange_ = sel_registerName("comboBoxSelectionDidChange:");
        sel_comboBoxWillDismiss_ = sel_registerName("comboBoxWillDismiss:");
        sel_compare_ = sel_registerName("compare:");
        sel_concat = sel_registerName("concat");
        sel_conformsToProtocol_ = sel_registerName("conformsToProtocol:");
        sel_containerSize = sel_registerName("containerSize");
        sel_containsIndex_ = sel_registerName("containsIndex:");
        sel_containsObject_ = sel_registerName("containsObject:");
        sel_containsPoint_ = sel_registerName("containsPoint:");
        sel_contentRect = sel_registerName("contentRect");
        sel_contentRectForFrameRect_ = sel_registerName("contentRectForFrameRect:");
        sel_contentSize = sel_registerName("contentSize");
        sel_contentSizeForFrameSize_hasHorizontalScroller_hasVerticalScroller_borderType_ = sel_registerName("contentSizeForFrameSize:hasHorizontalScroller:hasVerticalScroller:borderType:");
        sel_contentView = sel_registerName("contentView");
        sel_contentViewMargins = sel_registerName("contentViewMargins");
        sel_context = sel_registerName("context");
        sel_controlBackgroundColor = sel_registerName("controlBackgroundColor");
        sel_controlContentFontOfSize_ = sel_registerName("controlContentFontOfSize:");
        sel_controlDarkShadowColor = sel_registerName("controlDarkShadowColor");
        sel_controlHighlightColor = sel_registerName("controlHighlightColor");
        sel_controlLightHighlightColor = sel_registerName("controlLightHighlightColor");
        sel_controlPointBounds = sel_registerName("controlPointBounds");
        sel_controlShadowColor = sel_registerName("controlShadowColor");
        sel_controlSize = sel_registerName("controlSize");
        sel_controlTextColor = sel_registerName("controlTextColor");
        sel_convertBaseToScreen_ = sel_registerName("convertBaseToScreen:");
        sel_convertFont_toHaveTrait_ = sel_registerName("convertFont:toHaveTrait:");
        sel_convertPointFromBase_ = sel_registerName("convertPointFromBase:");
        sel_convertPointToBase_ = sel_registerName("convertPointToBase:");
        sel_convertPoint_fromView_ = sel_registerName("convertPoint:fromView:");
        sel_convertPoint_toView_ = sel_registerName("convertPoint:toView:");
        sel_convertRectFromBase_ = sel_registerName("convertRectFromBase:");
        sel_convertRectToBase_ = sel_registerName("convertRectToBase:");
        sel_convertRect_fromView_ = sel_registerName("convertRect:fromView:");
        sel_convertRect_toView_ = sel_registerName("convertRect:toView:");
        sel_convertScreenToBase_ = sel_registerName("convertScreenToBase:");
        sel_convertSizeFromBase_ = sel_registerName("convertSizeFromBase:");
        sel_convertSizeToBase_ = sel_registerName("convertSizeToBase:");
        sel_convertSize_fromView_ = sel_registerName("convertSize:fromView:");
        sel_convertSize_toView_ = sel_registerName("convertSize:toView:");
        sel_cookies = sel_registerName("cookies");
        sel_cookiesForURL_ = sel_registerName("cookiesForURL:");
        sel_cookiesWithResponseHeaderFields_forURL_ = sel_registerName("cookiesWithResponseHeaderFields:forURL:");
        sel_copiesOnScroll = sel_registerName("copiesOnScroll");
        sel_copy = sel_registerName("copy");
        sel_copy_ = sel_registerName("copy:");
        sel_count = sel_registerName("count");
        sel_createContext = sel_registerName("createContext");
        sel_createFileAtPath_contents_attributes_ = sel_registerName("createFileAtPath:contents:attributes:");
        sel_credentialWithUser_password_persistence_ = sel_registerName("credentialWithUser:password:persistence:");
        sel_crosshairCursor = sel_registerName("crosshairCursor");
        sel_ctrlKey = sel_registerName("ctrlKey");
        sel_currentContext = sel_registerName("currentContext");
        sel_currentCursor = sel_registerName("currentCursor");
        sel_currentEditor = sel_registerName("currentEditor");
        sel_currentEvent = sel_registerName("currentEvent");
        sel_currentInputManager = sel_registerName("currentInputManager");
        sel_currentPoint = sel_registerName("currentPoint");
        sel_currentRunLoop = sel_registerName("currentRunLoop");
        sel_currentThread = sel_registerName("currentThread");
        sel_cursorUpdate_ = sel_registerName("cursorUpdate:");
        sel_curveToPoint_controlPoint1_controlPoint2_ = sel_registerName("curveToPoint:controlPoint1:controlPoint2:");
        sel_cut_ = sel_registerName("cut:");
        sel_dataCell = sel_registerName("dataCell");
        sel_dataForType_ = sel_registerName("dataForType:");
        sel_dataSource = sel_registerName("dataSource");
        sel_dataWithBytes_length_ = sel_registerName("dataWithBytes:length:");
        sel_dateValue = sel_registerName("dateValue");
        sel_dateWithCalendarFormat_timeZone_ = sel_registerName("dateWithCalendarFormat:timeZone:");
        sel_dateWithTimeIntervalSinceNow_ = sel_registerName("dateWithTimeIntervalSinceNow:");
        sel_dateWithYear_month_day_hour_minute_second_timeZone_ = sel_registerName("dateWithYear:month:day:hour:minute:second:timeZone:");
        sel_dayOfMonth = sel_registerName("dayOfMonth");
        sel_decimalDigitCharacterSet = sel_registerName("decimalDigitCharacterSet");
        sel_decimalSeparator = sel_registerName("decimalSeparator");
        sel_declareTypes_owner_ = sel_registerName("declareTypes:owner:");
        sel_defaultBaselineOffsetForFont_ = sel_registerName("defaultBaselineOffsetForFont:");
        sel_defaultButtonCell = sel_registerName("defaultButtonCell");
        sel_defaultCenter = sel_registerName("defaultCenter");
        sel_defaultFlatness = sel_registerName("defaultFlatness");
        sel_defaultLineHeightForFont_ = sel_registerName("defaultLineHeightForFont:");
        sel_defaultManager = sel_registerName("defaultManager");
        sel_defaultParagraphStyle = sel_registerName("defaultParagraphStyle");
        sel_defaultPrinter = sel_registerName("defaultPrinter");
        sel_defaultTimeZone = sel_registerName("defaultTimeZone");
        sel_delegate = sel_registerName("delegate");
        sel_deleteCookie_ = sel_registerName("deleteCookie:");
        sel_deliverResult = sel_registerName("deliverResult");
        sel_deltaX = sel_registerName("deltaX");
        sel_deltaY = sel_registerName("deltaY");
        sel_deminiaturize_ = sel_registerName("deminiaturize:");
        sel_depth = sel_registerName("depth");
        sel_descender = sel_registerName("descender");
        sel_description = sel_registerName("description");
        sel_deselectAll_ = sel_registerName("deselectAll:");
        sel_deselectItemAtIndex_ = sel_registerName("deselectItemAtIndex:");
        sel_deselectRow_ = sel_registerName("deselectRow:");
        sel_destroyContext = sel_registerName("destroyContext");
        sel_detail = sel_registerName("detail");
        sel_deviceDescription = sel_registerName("deviceDescription");
        sel_deviceRGBColorSpace = sel_registerName("deviceRGBColorSpace");
        sel_dictionary = sel_registerName("dictionary");
        sel_dictionaryWithCapacity_ = sel_registerName("dictionaryWithCapacity:");
        sel_dictionaryWithObject_forKey_ = sel_registerName("dictionaryWithObject:forKey:");
        sel_disableCursorRects = sel_registerName("disableCursorRects");
        sel_disabledControlTextColor = sel_registerName("disabledControlTextColor");
        sel_discardCursorRects = sel_registerName("discardCursorRects");
        sel_display = sel_registerName("display");
        sel_displayIfNeeded = sel_registerName("displayIfNeeded");
        sel_displayRectIgnoringOpacity_inContext_ = sel_registerName("displayRectIgnoringOpacity:inContext:");
        sel_distantFuture = sel_registerName("distantFuture");
        sel_doCommandBySelector_ = sel_registerName("doCommandBySelector:");
        sel_documentCursor = sel_registerName("documentCursor");
        sel_documentSource = sel_registerName("documentSource");
        sel_documentView = sel_registerName("documentView");
        sel_documentViewShouldHandlePrint = sel_registerName("documentViewShouldHandlePrint");
        sel_documentVisibleRect = sel_registerName("documentVisibleRect");
        sel_DOMDocument = sel_registerName("DOMDocument");
        sel_doubleClickAtIndex_ = sel_registerName("doubleClickAtIndex:");
        sel_doubleValue = sel_registerName("doubleValue");
        sel_download = sel_registerName("download");
        sel_download_decideDestinationWithSuggestedFilename_ = sel_registerName("download:decideDestinationWithSuggestedFilename:");
        sel_draggedImage = sel_registerName("draggedImage");
        sel_draggedImageLocation = sel_registerName("draggedImageLocation");
        sel_draggedImage_beganAt_ = sel_registerName("draggedImage:beganAt:");
        sel_draggedImage_endedAt_operation_ = sel_registerName("draggedImage:endedAt:operation:");
        sel_draggingDestinationWindow = sel_registerName("draggingDestinationWindow");
        sel_draggingEnded_ = sel_registerName("draggingEnded:");
        sel_draggingEntered_ = sel_registerName("draggingEntered:");
        sel_draggingExited_ = sel_registerName("draggingExited:");
        sel_draggingLocation = sel_registerName("draggingLocation");
        sel_draggingPasteboard = sel_registerName("draggingPasteboard");
        sel_draggingSequenceNumber = sel_registerName("draggingSequenceNumber");
        sel_draggingSource = sel_registerName("draggingSource");
        sel_draggingSourceOperationMask = sel_registerName("draggingSourceOperationMask");
        sel_draggingSourceOperationMaskForLocal_ = sel_registerName("draggingSourceOperationMaskForLocal:");
        sel_draggingUpdated_ = sel_registerName("draggingUpdated:");
        sel_dragImageForRowsWithIndexes_tableColumns_event_offset_ = sel_registerName("dragImageForRowsWithIndexes:tableColumns:event:offset:");
        sel_dragImage_at_offset_event_pasteboard_source_slideBack_ = sel_registerName("dragImage:at:offset:event:pasteboard:source:slideBack:");
        sel_dragSelectionWithEvent_offset_slideBack_ = sel_registerName("dragSelectionWithEvent:offset:slideBack:");
        sel_drawAtPoint_ = sel_registerName("drawAtPoint:");
        sel_drawAtPoint_fromRect_operation_fraction_ = sel_registerName("drawAtPoint:fromRect:operation:fraction:");
        sel_drawBackgroundForGlyphRange_atPoint_ = sel_registerName("drawBackgroundForGlyphRange:atPoint:");
        sel_drawFromPoint_toPoint_options_ = sel_registerName("drawFromPoint:toPoint:options:");
        sel_drawGlyphsForGlyphRange_atPoint_ = sel_registerName("drawGlyphsForGlyphRange:atPoint:");
        sel_drawImage_withFrame_inView_ = sel_registerName("drawImage:withFrame:inView:");
        sel_drawingRectForBounds_ = sel_registerName("drawingRectForBounds:");
        sel_drawInRect_ = sel_registerName("drawInRect:");
        sel_drawInRect_angle_ = sel_registerName("drawInRect:angle:");
        sel_drawInRect_fromRect_operation_fraction_ = sel_registerName("drawInRect:fromRect:operation:fraction:");
        sel_drawInteriorWithFrame_inView_ = sel_registerName("drawInteriorWithFrame:inView:");
        sel_drawRect_ = sel_registerName("drawRect:");
        sel_drawSortIndicatorWithFrame_inView_ascending_priority_ = sel_registerName("drawSortIndicatorWithFrame:inView:ascending:priority:");
        sel_drawStatusBarBackgroundInRect_withHighlight_ = sel_registerName("drawStatusBarBackgroundInRect:withHighlight:");
        sel_drawWithExpansionFrame_inView_ = sel_registerName("drawWithExpansionFrame:inView:");
        sel_elementAtIndex_associatedPoints_ = sel_registerName("elementAtIndex:associatedPoints:");
        sel_elementCount = sel_registerName("elementCount");
        sel_enableCursorRects = sel_registerName("enableCursorRects");
        sel_enableFreedObjectCheck_ = sel_registerName("enableFreedObjectCheck:");
        sel_endDocument = sel_registerName("endDocument");
        sel_endEditing = sel_registerName("endEditing");
        sel_endPage = sel_registerName("endPage");
        sel_endSheet_returnCode_ = sel_registerName("endSheet:returnCode:");
        sel_enterExitEventWithType_location_modifierFlags_timestamp_windowNumber_context_eventNumber_trackingNumber_userData_ = sel_registerName("enterExitEventWithType:location:modifierFlags:timestamp:windowNumber:context:eventNumber:trackingNumber:userData:");
        sel_enumeratorAtPath_ = sel_registerName("enumeratorAtPath:");
        sel_expandItem_ = sel_registerName("expandItem:");
        sel_expandItem_expandChildren_ = sel_registerName("expandItem:expandChildren:");
        sel_expansionFrameWithFrame_inView_ = sel_registerName("expansionFrameWithFrame:inView:");
        sel_familyName = sel_registerName("familyName");
        sel_fieldEditor_forObject_ = sel_registerName("fieldEditor:forObject:");
        sel_fileExistsAtPath_isDirectory_ = sel_registerName("fileExistsAtPath:isDirectory:");
        sel_filename = sel_registerName("filename");
        sel_filenames = sel_registerName("filenames");
        sel_fileSystemRepresentation = sel_registerName("fileSystemRepresentation");
        sel_fileURLWithPath_ = sel_registerName("fileURLWithPath:");
        sel_fill = sel_registerName("fill");
        sel_fillRect_ = sel_registerName("fillRect:");
        sel_finishLaunching = sel_registerName("finishLaunching");
        sel_firstIndex = sel_registerName("firstIndex");
        sel_firstRectForCharacterRange_ = sel_registerName("firstRectForCharacterRange:");
        sel_firstResponder = sel_registerName("firstResponder");
        sel_flagsChanged_ = sel_registerName("flagsChanged:");
        sel_floatValue = sel_registerName("floatValue");
        sel_flushBuffer = sel_registerName("flushBuffer");
        sel_flushGraphics = sel_registerName("flushGraphics");
        sel_font = sel_registerName("font");
        sel_fontName = sel_registerName("fontName");
        sel_fontWithFamily_traits_weight_size_ = sel_registerName("fontWithFamily:traits:weight:size:");
        sel_fontWithName_size_ = sel_registerName("fontWithName:size:");
        sel_frame = sel_registerName("frame");
        sel_frameOfCellAtColumn_row_ = sel_registerName("frameOfCellAtColumn:row:");
        sel_frameOfOutlineCellAtRow_ = sel_registerName("frameOfOutlineCellAtRow:");
        sel_frameRectForContentRect_ = sel_registerName("frameRectForContentRect:");
        sel_frameSizeForContentSize_hasHorizontalScroller_hasVerticalScroller_borderType_ = sel_registerName("frameSizeForContentSize:hasHorizontalScroller:hasVerticalScroller:borderType:");
        sel_fullPathForApplication_ = sel_registerName("fullPathForApplication:");
        sel_generalPasteboard = sel_registerName("generalPasteboard");
        sel_getBitmapDataPlanes_ = sel_registerName("getBitmapDataPlanes:");
        sel_getBytes_ = sel_registerName("getBytes:");
        sel_getBytes_length_ = sel_registerName("getBytes:length:");
        sel_getCharacters_ = sel_registerName("getCharacters:");
        sel_getCharacters_range_ = sel_registerName("getCharacters:range:");
        sel_getComponents_ = sel_registerName("getComponents:");
        sel_getCString_maxLength_encoding_ = sel_registerName("getCString:maxLength:encoding:");
        sel_getGlyphsInRange_glyphs_characterIndexes_glyphInscriptions_elasticBits_bidiLevels_ = sel_registerName("getGlyphsInRange:glyphs:characterIndexes:glyphInscriptions:elasticBits:bidiLevels:");
        sel_getGlyphs_range_ = sel_registerName("getGlyphs:range:");
        sel_getIndexes_maxCount_inIndexRange_ = sel_registerName("getIndexes:maxCount:inIndexRange:");
        sel_getInfoForFile_application_type_ = sel_registerName("getInfoForFile:application:type:");
        sel_getValues_forAttribute_forVirtualScreen_ = sel_registerName("getValues:forAttribute:forVirtualScreen:");
        sel_glyphIndexForCharacterAtIndex_ = sel_registerName("glyphIndexForCharacterAtIndex:");
        sel_glyphIndexForPoint_inTextContainer_fractionOfDistanceThroughGlyph_ = sel_registerName("glyphIndexForPoint:inTextContainer:fractionOfDistanceThroughGlyph:");
        sel_glyphRangeForCharacterRange_actualCharacterRange_ = sel_registerName("glyphRangeForCharacterRange:actualCharacterRange:");
        sel_glyphRangeForTextContainer_ = sel_registerName("glyphRangeForTextContainer:");
        sel_goBack = sel_registerName("goBack");
        sel_goForward = sel_registerName("goForward");
        sel_graphicsContext = sel_registerName("graphicsContext");
        sel_graphicsContextWithBitmapImageRep_ = sel_registerName("graphicsContextWithBitmapImageRep:");
        sel_graphicsContextWithGraphicsPort_flipped_ = sel_registerName("graphicsContextWithGraphicsPort:flipped:");
        sel_graphicsContextWithWindow_ = sel_registerName("graphicsContextWithWindow:");
        sel_graphicsPort = sel_registerName("graphicsPort");
        sel_greenComponent = sel_registerName("greenComponent");
        sel_handleEvent_ = sel_registerName("handleEvent:");
        sel_handleMouseEvent_ = sel_registerName("handleMouseEvent:");
        sel_hasAlpha = sel_registerName("hasAlpha");
        sel_hasMarkedText = sel_registerName("hasMarkedText");
        sel_hasPassword = sel_registerName("hasPassword");
        sel_hasShadow = sel_registerName("hasShadow");
        sel_headerCell = sel_registerName("headerCell");
        sel_headerRectOfColumn_ = sel_registerName("headerRectOfColumn:");
        sel_headerView = sel_registerName("headerView");
        sel_helpRequested_ = sel_registerName("helpRequested:");
        sel_hideOtherApplications_ = sel_registerName("hideOtherApplications:");
        sel_hide_ = sel_registerName("hide:");
        sel_highlightColorInView_ = sel_registerName("highlightColorInView:");
        sel_highlightColorWithFrame_inView_ = sel_registerName("highlightColorWithFrame:inView:");
        sel_highlightSelectionInClipRect_ = sel_registerName("highlightSelectionInClipRect:");
        sel_hitPart = sel_registerName("hitPart");
        sel_hitTestForEvent_inRect_ofView_ = sel_registerName("hitTestForEvent:inRect:ofView:");
        sel_hitTest_ = sel_registerName("hitTest:");
        sel_host = sel_registerName("host");
        sel_hourOfDay = sel_registerName("hourOfDay");
        sel_IBeamCursor = sel_registerName("IBeamCursor");
        sel_iconForFileType_ = sel_registerName("iconForFileType:");
        sel_iconForFile_ = sel_registerName("iconForFile:");
        sel_ignore = sel_registerName("ignore");
        sel_ignoreModifierKeysWhileDragging = sel_registerName("ignoreModifierKeysWhileDragging");
        sel_image = sel_registerName("image");
        sel_imageablePageBounds = sel_registerName("imageablePageBounds");
        sel_imageInterpolation = sel_registerName("imageInterpolation");
        sel_imageNamed_ = sel_registerName("imageNamed:");
        sel_imageRectForBounds_ = sel_registerName("imageRectForBounds:");
        sel_imageRepWithData_ = sel_registerName("imageRepWithData:");
        sel_increment = sel_registerName("increment");
        sel_indentationPerLevel = sel_registerName("indentationPerLevel");
        sel_indexOfItemWithTarget_andAction_ = sel_registerName("indexOfItemWithTarget:andAction:");
        sel_indexOfObjectIdenticalTo_ = sel_registerName("indexOfObjectIdenticalTo:");
        sel_indexOfSelectedItem = sel_registerName("indexOfSelectedItem");
        sel_infoDictionary = sel_registerName("infoDictionary");
        sel_init = sel_registerName("init");
        sel_initByReferencingFile_ = sel_registerName("initByReferencingFile:");
        sel_initListDescriptor = sel_registerName("initListDescriptor");
        sel_initWithAttributes_ = sel_registerName("initWithAttributes:");
        sel_initWithBitmapDataPlanes_pixelsWide_pixelsHigh_bitsPerSample_samplesPerPixel_hasAlpha_isPlanar_colorSpaceName_bitmapFormat_bytesPerRow_bitsPerPixel_ = sel_registerName("initWithBitmapDataPlanes:pixelsWide:pixelsHigh:bitsPerSample:samplesPerPixel:hasAlpha:isPlanar:colorSpaceName:bitmapFormat:bytesPerRow:bitsPerPixel:");
        sel_initWithBitmapDataPlanes_pixelsWide_pixelsHigh_bitsPerSample_samplesPerPixel_hasAlpha_isPlanar_colorSpaceName_bytesPerRow_bitsPerPixel_ = sel_registerName("initWithBitmapDataPlanes:pixelsWide:pixelsHigh:bitsPerSample:samplesPerPixel:hasAlpha:isPlanar:colorSpaceName:bytesPerRow:bitsPerPixel:");
        sel_initWithCapacity_ = sel_registerName("initWithCapacity:");
        sel_initWithCharacters_length_ = sel_registerName("initWithCharacters:length:");
        sel_initWithContainerSize_ = sel_registerName("initWithContainerSize:");
        sel_initWithContentRect_styleMask_backing_defer_ = sel_registerName("initWithContentRect:styleMask:backing:defer:");
        sel_initWithContentRect_styleMask_backing_defer_screen_ = sel_registerName("initWithContentRect:styleMask:backing:defer:screen:");
        sel_initWithContentsOfFile_ = sel_registerName("initWithContentsOfFile:");
        sel_initWithData_ = sel_registerName("initWithData:");
        sel_initWithDictionary_ = sel_registerName("initWithDictionary:");
        sel_initWithFileWrapper_ = sel_registerName("initWithFileWrapper:");
        sel_initWithFocusedViewRect_ = sel_registerName("initWithFocusedViewRect:");
        sel_initWithFormat_shareContext_ = sel_registerName("initWithFormat:shareContext:");
        sel_initWithFrame_ = sel_registerName("initWithFrame:");
        sel_initWithFrame_frameName_groupName_ = sel_registerName("initWithFrame:frameName:groupName:");
        sel_initWithFrame_pixelFormat_ = sel_registerName("initWithFrame:pixelFormat:");
        sel_initWithFrame_pullsDown_ = sel_registerName("initWithFrame:pullsDown:");
        sel_initWithIdentifier_ = sel_registerName("initWithIdentifier:");
        sel_initWithImage_hotSpot_ = sel_registerName("initWithImage:hotSpot:");
        sel_initWithIndexesInRange_ = sel_registerName("initWithIndexesInRange:");
        sel_initWithIndex_ = sel_registerName("initWithIndex:");
        sel_initWithItemIdentifier_ = sel_registerName("initWithItemIdentifier:");
        sel_initWithRect_options_owner_userInfo_ = sel_registerName("initWithRect:options:owner:userInfo:");
        sel_initWithSize_ = sel_registerName("initWithSize:");
        sel_initWithStartingColor_endingColor_ = sel_registerName("initWithStartingColor:endingColor:");
        sel_initWithString_ = sel_registerName("initWithString:");
        sel_initWithString_attributes_ = sel_registerName("initWithString:attributes:");
        sel_initWithTitle_ = sel_registerName("initWithTitle:");
        sel_initWithTitle_action_keyEquivalent_ = sel_registerName("initWithTitle:action:keyEquivalent:");
        sel_initWithTransform_ = sel_registerName("initWithTransform:");
        sel_initWithType_location_ = sel_registerName("initWithType:location:");
        sel_initWithURL_ = sel_registerName("initWithURL:");
        sel_insertItemWithItemIdentifier_atIndex_ = sel_registerName("insertItemWithItemIdentifier:atIndex:");
        sel_insertItemWithObjectValue_atIndex_ = sel_registerName("insertItemWithObjectValue:atIndex:");
        sel_insertItem_atIndex_ = sel_registerName("insertItem:atIndex:");
        sel_insertTabViewItem_atIndex_ = sel_registerName("insertTabViewItem:atIndex:");
        sel_insertText_ = sel_registerName("insertText:");
        sel_integerValue = sel_registerName("integerValue");
        sel_intercellSpacing = sel_registerName("intercellSpacing");
        sel_interpretKeyEvents_ = sel_registerName("interpretKeyEvents:");
        sel_intValue = sel_registerName("intValue");
        sel_invalidate = sel_registerName("invalidate");
        sel_invalidateShadow = sel_registerName("invalidateShadow");
        sel_invert = sel_registerName("invert");
        sel_isActive = sel_registerName("isActive");
        sel_isDocumentEdited = sel_registerName("isDocumentEdited");
        sel_isDrawingToScreen = sel_registerName("isDrawingToScreen");
        sel_isEmpty = sel_registerName("isEmpty");
        sel_isEnabled = sel_registerName("isEnabled");
        sel_isEqualToString_ = sel_registerName("isEqualToString:");
        sel_isEqualTo_ = sel_registerName("isEqualTo:");
        sel_isEqual_ = sel_registerName("isEqual:");
        sel_isFilePackageAtPath_ = sel_registerName("isFilePackageAtPath:");
        sel_isFileURL = sel_registerName("isFileURL");
        sel_isFlipped = sel_registerName("isFlipped");
        sel_isHidden = sel_registerName("isHidden");
        sel_isHiddenOrHasHiddenAncestor = sel_registerName("isHiddenOrHasHiddenAncestor");
        sel_isHighlighted = sel_registerName("isHighlighted");
        sel_isItemExpanded_ = sel_registerName("isItemExpanded:");
        sel_isKeyWindow = sel_registerName("isKeyWindow");
        sel_isKindOfClass_ = sel_registerName("isKindOfClass:");
        sel_isMainThread = sel_registerName("isMainThread");
        sel_isMiniaturized = sel_registerName("isMiniaturized");
        sel_isOpaque = sel_registerName("isOpaque");
        sel_isPlanar = sel_registerName("isPlanar");
        sel_isRowSelected_ = sel_registerName("isRowSelected:");
        sel_isRunning = sel_registerName("isRunning");
        sel_isSessionOnly = sel_registerName("isSessionOnly");
        sel_isSheet = sel_registerName("isSheet");
        sel_isVisible = sel_registerName("isVisible");
        sel_isZoomed = sel_registerName("isZoomed");
        sel_itemArray = sel_registerName("itemArray");
        sel_itemAtIndex_ = sel_registerName("itemAtIndex:");
        sel_itemAtRow_ = sel_registerName("itemAtRow:");
        sel_itemIdentifier = sel_registerName("itemIdentifier");
        sel_itemObjectValueAtIndex_ = sel_registerName("itemObjectValueAtIndex:");
        sel_itemTitleAtIndex_ = sel_registerName("itemTitleAtIndex:");
        sel_jobDisposition = sel_registerName("jobDisposition");
        sel_keyCode = sel_registerName("keyCode");
        sel_keyDown_ = sel_registerName("keyDown:");
        sel_keyEquivalent = sel_registerName("keyEquivalent");
        sel_keyEquivalentModifierMask = sel_registerName("keyEquivalentModifierMask");
        sel_keyUp_ = sel_registerName("keyUp:");
        sel_keyWindow = sel_registerName("keyWindow");
        sel_knobThickness = sel_registerName("knobThickness");
        sel_lastPathComponent = sel_registerName("lastPathComponent");
        sel_layoutManager = sel_registerName("layoutManager");
        sel_leading = sel_registerName("leading");
        sel_length = sel_registerName("length");
        sel_lengthOfBytesUsingEncoding_ = sel_registerName("lengthOfBytesUsingEncoding:");
        sel_levelForItem_ = sel_registerName("levelForItem:");
        sel_lineFragmentUsedRectForGlyphAtIndex_effectiveRange_ = sel_registerName("lineFragmentUsedRectForGlyphAtIndex:effectiveRange:");
        sel_lineFragmentUsedRectForGlyphAtIndex_effectiveRange_withoutAdditionalLayout_ = sel_registerName("lineFragmentUsedRectForGlyphAtIndex:effectiveRange:withoutAdditionalLayout:");
        sel_lineToPoint_ = sel_registerName("lineToPoint:");
        sel_linkTextAttributes = sel_registerName("linkTextAttributes");
        sel_loadHTMLString_baseURL_ = sel_registerName("loadHTMLString:baseURL:");
        sel_loadNibFile_externalNameTable_withZone_ = sel_registerName("loadNibFile:externalNameTable:withZone:");
        sel_loadRequest_ = sel_registerName("loadRequest:");
        sel_localizedDescription = sel_registerName("localizedDescription");
        sel_location = sel_registerName("location");
        sel_locationForGlyphAtIndex_ = sel_registerName("locationForGlyphAtIndex:");
        sel_locationInWindow = sel_registerName("locationInWindow");
        sel_lockFocus = sel_registerName("lockFocus");
        sel_lowercaseString = sel_registerName("lowercaseString");
        sel_mainBundle = sel_registerName("mainBundle");
        sel_mainFrame = sel_registerName("mainFrame");
        sel_mainMenu = sel_registerName("mainMenu");
        sel_mainRunLoop = sel_registerName("mainRunLoop");
        sel_mainScreen = sel_registerName("mainScreen");
        sel_makeCurrentContext = sel_registerName("makeCurrentContext");
        sel_makeFirstResponder_ = sel_registerName("makeFirstResponder:");
        sel_makeKeyAndOrderFront_ = sel_registerName("makeKeyAndOrderFront:");
        sel_markedRange = sel_registerName("markedRange");
        sel_markedTextAttributes = sel_registerName("markedTextAttributes");
        sel_maximum = sel_registerName("maximum");
        sel_maximumFractionDigits = sel_registerName("maximumFractionDigits");
        sel_maximumIntegerDigits = sel_registerName("maximumIntegerDigits");
        sel_maxValue = sel_registerName("maxValue");
        sel_menu = sel_registerName("menu");
        sel_menuDidClose_ = sel_registerName("menuDidClose:");
        sel_menuForEvent_ = sel_registerName("menuForEvent:");
        sel_menuNeedsUpdate_ = sel_registerName("menuNeedsUpdate:");
        sel_menuWillOpen_ = sel_registerName("menuWillOpen:");
        sel_menu_willHighlightItem_ = sel_registerName("menu:willHighlightItem:");
        sel_metaKey = sel_registerName("metaKey");
        sel_minFrameWidthWithTitle_styleMask_ = sel_registerName("minFrameWidthWithTitle:styleMask:");
        sel_miniaturize_ = sel_registerName("miniaturize:");
        sel_minimum = sel_registerName("minimum");
        sel_minimumSize = sel_registerName("minimumSize");
        sel_minSize = sel_registerName("minSize");
        sel_minuteOfHour = sel_registerName("minuteOfHour");
        sel_minValue = sel_registerName("minValue");
        sel_modifierFlags = sel_registerName("modifierFlags");
        sel_monthOfYear = sel_registerName("monthOfYear");
        sel_mouseDown_ = sel_registerName("mouseDown:");
        sel_mouseDragged_ = sel_registerName("mouseDragged:");
        sel_mouseEntered_ = sel_registerName("mouseEntered:");
        sel_mouseExited_ = sel_registerName("mouseExited:");
        sel_mouseLocation = sel_registerName("mouseLocation");
        sel_mouseLocationOutsideOfEventStream = sel_registerName("mouseLocationOutsideOfEventStream");
        sel_mouseMoved_ = sel_registerName("mouseMoved:");
        sel_mouseUp_ = sel_registerName("mouseUp:");
        sel_moveColumn_toColumn_ = sel_registerName("moveColumn:toColumn:");
        sel_moveToBeginningOfParagraph_ = sel_registerName("moveToBeginningOfParagraph:");
        sel_moveToEndOfParagraph_ = sel_registerName("moveToEndOfParagraph:");
        sel_moveToPoint_ = sel_registerName("moveToPoint:");
        sel_moveUp_ = sel_registerName("moveUp:");
        sel_mutableCopy = sel_registerName("mutableCopy");
        sel_mutableString = sel_registerName("mutableString");
        sel_name = sel_registerName("name");
        sel_namesOfPromisedFilesDroppedAtDestination_ = sel_registerName("namesOfPromisedFilesDroppedAtDestination:");
        sel_nextEventMatchingMask_untilDate_inMode_dequeue_ = sel_registerName("nextEventMatchingMask:untilDate:inMode:dequeue:");
        sel_nextObject = sel_registerName("nextObject");
        sel_nextState = sel_registerName("nextState");
        sel_nextWordFromIndex_forward_ = sel_registerName("nextWordFromIndex:forward:");
        sel_noResponderFor_ = sel_registerName("noResponderFor:");
        sel_noteNumberOfRowsChanged = sel_registerName("noteNumberOfRowsChanged");
        sel_numberOfColumns = sel_registerName("numberOfColumns");
        sel_numberOfComponents = sel_registerName("numberOfComponents");
        sel_numberOfGlyphs = sel_registerName("numberOfGlyphs");
        sel_numberOfItems = sel_registerName("numberOfItems");
        sel_numberOfPlanes = sel_registerName("numberOfPlanes");
        sel_numberOfRows = sel_registerName("numberOfRows");
        sel_numberOfRowsInTableView_ = sel_registerName("numberOfRowsInTableView:");
        sel_numberOfSelectedRows = sel_registerName("numberOfSelectedRows");
        sel_numberOfVisibleItems = sel_registerName("numberOfVisibleItems");
        sel_numberWithBool_ = sel_registerName("numberWithBool:");
        sel_numberWithDouble_ = sel_registerName("numberWithDouble:");
        sel_numberWithInteger_ = sel_registerName("numberWithInteger:");
        sel_numberWithInt_ = sel_registerName("numberWithInt:");
        sel_objCType = sel_registerName("objCType");
        sel_object = sel_registerName("object");
        sel_objectAtIndex_ = sel_registerName("objectAtIndex:");
        sel_objectEnumerator = sel_registerName("objectEnumerator");
        sel_objectForInfoDictionaryKey_ = sel_registerName("objectForInfoDictionaryKey:");
        sel_objectForKey_ = sel_registerName("objectForKey:");
        sel_objectValues = sel_registerName("objectValues");
        sel_openFile_withApplication_ = sel_registerName("openFile:withApplication:");
        sel_openGLContext = sel_registerName("openGLContext");
        sel_openPanel = sel_registerName("openPanel");
        sel_openURLs_withAppBundleIdentifier_options_additionalEventParamDescriptor_launchIdentifiers_ = sel_registerName("openURLs:withAppBundleIdentifier:options:additionalEventParamDescriptor:launchIdentifiers:");
        sel_openURL_ = sel_registerName("openURL:");
        sel_options = sel_registerName("options");
        sel_orderBack_ = sel_registerName("orderBack:");
        sel_orderedWindows = sel_registerName("orderedWindows");
        sel_orderFrontRegardless = sel_registerName("orderFrontRegardless");
        sel_orderFrontStandardAboutPanel_ = sel_registerName("orderFrontStandardAboutPanel:");
        sel_orderFront_ = sel_registerName("orderFront:");
        sel_orderOut_ = sel_registerName("orderOut:");
        sel_orderWindow_relativeTo_ = sel_registerName("orderWindow:relativeTo:");
        sel_orientation = sel_registerName("orientation");
        sel_otherEventWithType_location_modifierFlags_timestamp_windowNumber_context_subtype_data1_data2_ = sel_registerName("otherEventWithType:location:modifierFlags:timestamp:windowNumber:context:subtype:data1:data2:");
        sel_otherMouseDown_ = sel_registerName("otherMouseDown:");
        sel_otherMouseDragged_ = sel_registerName("otherMouseDragged:");
        sel_otherMouseUp_ = sel_registerName("otherMouseUp:");
        sel_outlineTableColumn = sel_registerName("outlineTableColumn");
        sel_outlineViewColumnDidMove_ = sel_registerName("outlineViewColumnDidMove:");
        sel_outlineViewColumnDidResize_ = sel_registerName("outlineViewColumnDidResize:");
        sel_outlineViewItemDidExpand_ = sel_registerName("outlineViewItemDidExpand:");
        sel_outlineViewSelectionDidChange_ = sel_registerName("outlineViewSelectionDidChange:");
        sel_outlineView_acceptDrop_item_childIndex_ = sel_registerName("outlineView:acceptDrop:item:childIndex:");
        sel_outlineView_child_ofItem_ = sel_registerName("outlineView:child:ofItem:");
        sel_outlineView_didClickTableColumn_ = sel_registerName("outlineView:didClickTableColumn:");
        sel_outlineView_isItemExpandable_ = sel_registerName("outlineView:isItemExpandable:");
        sel_outlineView_numberOfChildrenOfItem_ = sel_registerName("outlineView:numberOfChildrenOfItem:");
        sel_outlineView_objectValueForTableColumn_byItem_ = sel_registerName("outlineView:objectValueForTableColumn:byItem:");
        sel_outlineView_setObjectValue_forTableColumn_byItem_ = sel_registerName("outlineView:setObjectValue:forTableColumn:byItem:");
        sel_outlineView_shouldCollapseItem_ = sel_registerName("outlineView:shouldCollapseItem:");
        sel_outlineView_shouldExpandItem_ = sel_registerName("outlineView:shouldExpandItem:");
        sel_outlineView_validateDrop_proposedItem_proposedChildIndex_ = sel_registerName("outlineView:validateDrop:proposedItem:proposedChildIndex:");
        sel_outlineView_willDisplayCell_forTableColumn_item_ = sel_registerName("outlineView:willDisplayCell:forTableColumn:item:");
        sel_outlineView_writeItems_toPasteboard_ = sel_registerName("outlineView:writeItems:toPasteboard:");
        sel_owner = sel_registerName("owner");
        sel_pageDown_ = sel_registerName("pageDown:");
        sel_pageTitle = sel_registerName("pageTitle");
        sel_pageUp_ = sel_registerName("pageUp:");
        sel_panelConvertFont_ = sel_registerName("panelConvertFont:");
        sel_panel_shouldShowFilename_ = sel_registerName("panel:shouldShowFilename:");
        sel_paperSize = sel_registerName("paperSize");
        sel_paragraphs = sel_registerName("paragraphs");
        sel_parentWindow = sel_registerName("parentWindow");
        sel_password = sel_registerName("password");
        sel_pasteboardWithName_ = sel_registerName("pasteboardWithName:");
        sel_pasteboard_provideDataForType_ = sel_registerName("pasteboard:provideDataForType:");
        sel_paste_ = sel_registerName("paste:");
        sel_pathExtension = sel_registerName("pathExtension");
        sel_pathForResource_ofType_ = sel_registerName("pathForResource:ofType:");
        sel_performDragOperation_ = sel_registerName("performDragOperation:");
        sel_performSelectorOnMainThread_withObject_waitUntilDone_ = sel_registerName("performSelectorOnMainThread:withObject:waitUntilDone:");
        sel_pixelsHigh = sel_registerName("pixelsHigh");
        sel_pixelsWide = sel_registerName("pixelsWide");
        sel_pointingHandCursor = sel_registerName("pointingHandCursor");
        sel_pointSize = sel_registerName("pointSize");
        sel_pointValue = sel_registerName("pointValue");
        sel_pop = sel_registerName("pop");
        sel_popUpContextMenu_withEvent_forView_ = sel_registerName("popUpContextMenu:withEvent:forView:");
        sel_popUpStatusItemMenu_ = sel_registerName("popUpStatusItemMenu:");
        sel_port = sel_registerName("port");
        sel_postEvent_atStart_ = sel_registerName("postEvent:atStart:");
        sel_prependTransform_ = sel_registerName("prependTransform:");
        sel_preventDefault = sel_registerName("preventDefault");
        sel_previousFailureCount = sel_registerName("previousFailureCount");
        sel_printDocumentView = sel_registerName("printDocumentView");
        sel_printer = sel_registerName("printer");
        sel_printerNames = sel_registerName("printerNames");
        sel_printerWithName_ = sel_registerName("printerWithName:");
        sel_printOperationWithPrintInfo_ = sel_registerName("printOperationWithPrintInfo:");
        sel_printOperationWithView_printInfo_ = sel_registerName("printOperationWithView:printInfo:");
        sel_printPanel = sel_registerName("printPanel");
        sel_propertyListForType_ = sel_registerName("propertyListForType:");
        sel_proposedCredential = sel_registerName("proposedCredential");
        sel_protectionSpace = sel_registerName("protectionSpace");
        sel_push = sel_registerName("push");
        sel_rangeValue = sel_registerName("rangeValue");
        sel_realm = sel_registerName("realm");
        sel_recentSearches = sel_registerName("recentSearches");
        sel_rectArrayForCharacterRange_withinSelectedCharacterRange_inTextContainer_rectCount_ = sel_registerName("rectArrayForCharacterRange:withinSelectedCharacterRange:inTextContainer:rectCount:");
        sel_rectOfColumn_ = sel_registerName("rectOfColumn:");
        sel_rectOfRow_ = sel_registerName("rectOfRow:");
        sel_rectValue = sel_registerName("rectValue");
        sel_redComponent = sel_registerName("redComponent");
        sel_reflectScrolledClipView_ = sel_registerName("reflectScrolledClipView:");
        sel_registerForDraggedTypes_ = sel_registerName("registerForDraggedTypes:");
        sel_release = sel_registerName("release");
        sel_reloadData = sel_registerName("reloadData");
        sel_reloadItem_ = sel_registerName("reloadItem:");
        sel_reloadItem_reloadChildren_ = sel_registerName("reloadItem:reloadChildren:");
        sel_reload_ = sel_registerName("reload:");
        sel_removeAllItems = sel_registerName("removeAllItems");
        sel_removeAllPoints = sel_registerName("removeAllPoints");
        sel_removeAttribute_range_ = sel_registerName("removeAttribute:range:");
        sel_removeChildWindow_ = sel_registerName("removeChildWindow:");
        sel_removeFromSuperview = sel_registerName("removeFromSuperview");
        sel_removeItemAtIndex_ = sel_registerName("removeItemAtIndex:");
        sel_removeItemAtPath_error_ = sel_registerName("removeItemAtPath:error:");
        sel_removeItem_ = sel_registerName("removeItem:");
        sel_removeLastObject = sel_registerName("removeLastObject");
        sel_removeObjectAtIndex_ = sel_registerName("removeObjectAtIndex:");
        sel_removeObjectForKey_ = sel_registerName("removeObjectForKey:");
        sel_removeObjectIdenticalTo_ = sel_registerName("removeObjectIdenticalTo:");
        sel_removeObject_ = sel_registerName("removeObject:");
        sel_removeObserver_ = sel_registerName("removeObserver:");
        sel_removeRepresentation_ = sel_registerName("removeRepresentation:");
        sel_removeStatusItem_ = sel_registerName("removeStatusItem:");
        sel_removeTableColumn_ = sel_registerName("removeTableColumn:");
        sel_removeTabViewItem_ = sel_registerName("removeTabViewItem:");
        sel_removeTemporaryAttribute_forCharacterRange_ = sel_registerName("removeTemporaryAttribute:forCharacterRange:");
        sel_removeTrackingArea_ = sel_registerName("removeTrackingArea:");
        sel_replaceCharactersInRange_withString_ = sel_registerName("replaceCharactersInRange:withString:");
        sel_representation = sel_registerName("representation");
        sel_representations = sel_registerName("representations");
        sel_request = sel_registerName("request");
        sel_requestWithURL_ = sel_registerName("requestWithURL:");
        sel_resetCursorRects = sel_registerName("resetCursorRects");
        sel_resignFirstResponder = sel_registerName("resignFirstResponder");
        sel_resizeDownCursor = sel_registerName("resizeDownCursor");
        sel_resizeLeftCursor = sel_registerName("resizeLeftCursor");
        sel_resizeLeftRightCursor = sel_registerName("resizeLeftRightCursor");
        sel_resizeRightCursor = sel_registerName("resizeRightCursor");
        sel_resizeUpCursor = sel_registerName("resizeUpCursor");
        sel_resizeUpDownCursor = sel_registerName("resizeUpDownCursor");
        sel_resizingMask = sel_registerName("resizingMask");
        sel_resourcePath = sel_registerName("resourcePath");
        sel_respondsToSelector_ = sel_registerName("respondsToSelector:");
        sel_restoreGraphicsState = sel_registerName("restoreGraphicsState");
        sel_retain = sel_registerName("retain");
        sel_retainCount = sel_registerName("retainCount");
        sel_rightMouseDown_ = sel_registerName("rightMouseDown:");
        sel_rightMouseDragged_ = sel_registerName("rightMouseDragged:");
        sel_rightMouseUp_ = sel_registerName("rightMouseUp:");
        sel_rotateByDegrees_ = sel_registerName("rotateByDegrees:");
        sel_rowAtPoint_ = sel_registerName("rowAtPoint:");
        sel_rowForItem_ = sel_registerName("rowForItem:");
        sel_rowHeight = sel_registerName("rowHeight");
        sel_rowsInRect_ = sel_registerName("rowsInRect:");
        sel_run = sel_registerName("run");
        sel_runModal = sel_registerName("runModal");
        sel_runModalForDirectory_file_ = sel_registerName("runModalForDirectory:file:");
        sel_runModalForWindow_ = sel_registerName("runModalForWindow:");
        sel_runModalWithPrintInfo_ = sel_registerName("runModalWithPrintInfo:");
        sel_runMode_beforeDate_ = sel_registerName("runMode:beforeDate:");
        sel_runOperation = sel_registerName("runOperation");
        sel_samplesPerPixel = sel_registerName("samplesPerPixel");
        sel_saveGraphicsState = sel_registerName("saveGraphicsState");
        sel_savePanel = sel_registerName("savePanel");
        sel_scaleXBy_yBy_ = sel_registerName("scaleXBy:yBy:");
        sel_scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_ = sel_registerName("scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:");
        sel_screen = sel_registerName("screen");
        sel_screens = sel_registerName("screens");
        sel_scrollColumnToVisible_ = sel_registerName("scrollColumnToVisible:");
        sel_scrollerWidth = sel_registerName("scrollerWidth");
        sel_scrollerWidthForControlSize_ = sel_registerName("scrollerWidthForControlSize:");
        sel_scrollPoint_ = sel_registerName("scrollPoint:");
        sel_scrollRangeToVisible_ = sel_registerName("scrollRangeToVisible:");
        sel_scrollRectToVisible_ = sel_registerName("scrollRectToVisible:");
        sel_scrollRowToVisible_ = sel_registerName("scrollRowToVisible:");
        sel_scrollToPoint_ = sel_registerName("scrollToPoint:");
        sel_scrollWheel_ = sel_registerName("scrollWheel:");
        sel_searchButtonCell = sel_registerName("searchButtonCell");
        sel_searchTextRectForBounds_ = sel_registerName("searchTextRectForBounds:");
        sel_secondarySelectedControlColor = sel_registerName("secondarySelectedControlColor");
        sel_secondOfMinute = sel_registerName("secondOfMinute");
        sel_selectAll_ = sel_registerName("selectAll:");
        sel_selectedControlColor = sel_registerName("selectedControlColor");
        sel_selectedControlTextColor = sel_registerName("selectedControlTextColor");
        sel_selectedRange = sel_registerName("selectedRange");
        sel_selectedRow = sel_registerName("selectedRow");
        sel_selectedRowIndexes = sel_registerName("selectedRowIndexes");
        sel_selectedTabViewItem = sel_registerName("selectedTabViewItem");
        sel_selectedTextBackgroundColor = sel_registerName("selectedTextBackgroundColor");
        sel_selectedTextColor = sel_registerName("selectedTextColor");
        sel_selectItemAtIndex_ = sel_registerName("selectItemAtIndex:");
        sel_selectItem_ = sel_registerName("selectItem:");
        sel_selectRowIndexes_byExtendingSelection_ = sel_registerName("selectRowIndexes:byExtendingSelection:");
        sel_selectRow_byExtendingSelection_ = sel_registerName("selectRow:byExtendingSelection:");
        sel_selectTabViewItemAtIndex_ = sel_registerName("selectTabViewItemAtIndex:");
        sel_selectText_ = sel_registerName("selectText:");
        sel_sendAction_to_ = sel_registerName("sendAction:to:");
        sel_sender = sel_registerName("sender");
        sel_sendEvent_ = sel_registerName("sendEvent:");
        sel_separatorItem = sel_registerName("separatorItem");
        sel_set = sel_registerName("set");
        sel_setAcceptsMouseMovedEvents_ = sel_registerName("setAcceptsMouseMovedEvents:");
        sel_setAccessoryView_ = sel_registerName("setAccessoryView:");
        sel_setAction_ = sel_registerName("setAction:");
        sel_setAlertStyle_ = sel_registerName("setAlertStyle:");
        sel_setAlignment_ = sel_registerName("setAlignment:");
        sel_setAllowsColumnReordering_ = sel_registerName("setAllowsColumnReordering:");
        sel_setAllowsFloats_ = sel_registerName("setAllowsFloats:");
        sel_setAllowsMixedState_ = sel_registerName("setAllowsMixedState:");
        sel_setAllowsMultipleSelection_ = sel_registerName("setAllowsMultipleSelection:");
        sel_setAllowsUserCustomization_ = sel_registerName("setAllowsUserCustomization:");
        sel_setAlphaValue_ = sel_registerName("setAlphaValue:");
        sel_setAlpha_ = sel_registerName("setAlpha:");
        sel_setApplicationIconImage_ = sel_registerName("setApplicationIconImage:");
        sel_setApplicationNameForUserAgent_ = sel_registerName("setApplicationNameForUserAgent:");
        sel_setAttributedStringValue_ = sel_registerName("setAttributedStringValue:");
        sel_setAttributedString_ = sel_registerName("setAttributedString:");
        sel_setAttributedTitle_ = sel_registerName("setAttributedTitle:");
        sel_setAutoenablesItems_ = sel_registerName("setAutoenablesItems:");
        sel_setAutohidesScrollers_ = sel_registerName("setAutohidesScrollers:");
        sel_setAutoresizesOutlineColumn_ = sel_registerName("setAutoresizesOutlineColumn:");
        sel_setAutoresizesSubviews_ = sel_registerName("setAutoresizesSubviews:");
        sel_setAutoresizingMask_ = sel_registerName("setAutoresizingMask:");
        sel_setAutosaveExpandedItems_ = sel_registerName("setAutosaveExpandedItems:");
        sel_setBackgroundColor_ = sel_registerName("setBackgroundColor:");
        sel_setBackgroundLayoutEnabled_ = sel_registerName("setBackgroundLayoutEnabled:");
        sel_setBezelStyle_ = sel_registerName("setBezelStyle:");
        sel_setBordered_ = sel_registerName("setBordered:");
        sel_setBorderType_ = sel_registerName("setBorderType:");
        sel_setBorderWidth_ = sel_registerName("setBorderWidth:");
        sel_setBoxType_ = sel_registerName("setBoxType:");
        sel_setButtonType_ = sel_registerName("setButtonType:");
        sel_setCacheMode_ = sel_registerName("setCacheMode:");
        sel_setCachePolicy_ = sel_registerName("setCachePolicy:");
        sel_setCancelButtonCell_ = sel_registerName("setCancelButtonCell:");
        sel_setCanChooseDirectories_ = sel_registerName("setCanChooseDirectories:");
        sel_setCanChooseFiles_ = sel_registerName("setCanChooseFiles:");
        sel_setCanCreateDirectories_ = sel_registerName("setCanCreateDirectories:");
        sel_setCellClass_ = sel_registerName("setCellClass:");
        sel_setCell_ = sel_registerName("setCell:");
        sel_setClip = sel_registerName("setClip");
        sel_setColor_ = sel_registerName("setColor:");
        sel_setColumnAutoresizingStyle_ = sel_registerName("setColumnAutoresizingStyle:");
        sel_setCompositingOperation_ = sel_registerName("setCompositingOperation:");
        sel_setContainerSize_ = sel_registerName("setContainerSize:");
        sel_setContentViewMargins_ = sel_registerName("setContentViewMargins:");
        sel_setContentView_ = sel_registerName("setContentView:");
        sel_setControlSize_ = sel_registerName("setControlSize:");
        sel_setCookie_ = sel_registerName("setCookie:");
        sel_setCopiesOnScroll_ = sel_registerName("setCopiesOnScroll:");
        sel_setCurrentContext_ = sel_registerName("setCurrentContext:");
        sel_setCurrentOperation_ = sel_registerName("setCurrentOperation:");
        sel_setDataCell_ = sel_registerName("setDataCell:");
        sel_setDataSource_ = sel_registerName("setDataSource:");
        sel_setData_forType_ = sel_registerName("setData:forType:");
        sel_setDatePickerElements_ = sel_registerName("setDatePickerElements:");
        sel_setDatePickerStyle_ = sel_registerName("setDatePickerStyle:");
        sel_setDateValue_ = sel_registerName("setDateValue:");
        sel_setDefaultButtonCell_ = sel_registerName("setDefaultButtonCell:");
        sel_setDefaultFlatness_ = sel_registerName("setDefaultFlatness:");
        sel_setDefaultParagraphStyle_ = sel_registerName("setDefaultParagraphStyle:");
        sel_setDefaultTabInterval_ = sel_registerName("setDefaultTabInterval:");
        sel_setDelegate_ = sel_registerName("setDelegate:");
        sel_setDestination_allowOverwrite_ = sel_registerName("setDestination:allowOverwrite:");
        sel_setDictionary_ = sel_registerName("setDictionary:");
        sel_setDirectory_ = sel_registerName("setDirectory:");
        sel_setDisplayMode_ = sel_registerName("setDisplayMode:");
        sel_setDocumentCursor_ = sel_registerName("setDocumentCursor:");
        sel_setDocumentEdited_ = sel_registerName("setDocumentEdited:");
        sel_setDocumentView_ = sel_registerName("setDocumentView:");
        sel_setDoubleAction_ = sel_registerName("setDoubleAction:");
        sel_setDoubleValue_ = sel_registerName("setDoubleValue:");
        sel_setDownloadDelegate_ = sel_registerName("setDownloadDelegate:");
        sel_setDrawsBackground_ = sel_registerName("setDrawsBackground:");
        sel_setDropItem_dropChildIndex_ = sel_registerName("setDropItem:dropChildIndex:");
        sel_setDropRow_dropOperation_ = sel_registerName("setDropRow:dropOperation:");
        sel_setEditable_ = sel_registerName("setEditable:");
        sel_setEnabled_ = sel_registerName("setEnabled:");
        sel_setEnabled_forSegment_ = sel_registerName("setEnabled:forSegment:");
        sel_setFill = sel_registerName("setFill");
        sel_setFillColor_ = sel_registerName("setFillColor:");
        sel_setFireDate_ = sel_registerName("setFireDate:");
        sel_setFirstLineHeadIndent_ = sel_registerName("setFirstLineHeadIndent:");
        sel_setFloatValue_knobProportion_ = sel_registerName("setFloatValue:knobProportion:");
        sel_setFocusRingType_ = sel_registerName("setFocusRingType:");
        sel_setFont_ = sel_registerName("setFont:");
        sel_setFormatter_ = sel_registerName("setFormatter:");
        sel_setFrameLoadDelegate_ = sel_registerName("setFrameLoadDelegate:");
        sel_setFrameOrigin_ = sel_registerName("setFrameOrigin:");
        sel_setFrameSize_ = sel_registerName("setFrameSize:");
        sel_setFrame_ = sel_registerName("setFrame:");
        sel_setFrame_display_ = sel_registerName("setFrame:display:");
        sel_setFrame_display_animate_ = sel_registerName("setFrame:display:animate:");
        sel_setHasHorizontalScroller_ = sel_registerName("setHasHorizontalScroller:");
        sel_setHasShadow_ = sel_registerName("setHasShadow:");
        sel_setHasVerticalScroller_ = sel_registerName("setHasVerticalScroller:");
        sel_setHeaderCell_ = sel_registerName("setHeaderCell:");
        sel_setHeaderView_ = sel_registerName("setHeaderView:");
        sel_setHiddenUntilMouseMoves_ = sel_registerName("setHiddenUntilMouseMoves:");
        sel_setHidden_ = sel_registerName("setHidden:");
        sel_setHighlightedTableColumn_ = sel_registerName("setHighlightedTableColumn:");
        sel_setHighlighted_ = sel_registerName("setHighlighted:");
        sel_setHighlightMode_ = sel_registerName("setHighlightMode:");
        sel_setHorizontallyResizable_ = sel_registerName("setHorizontallyResizable:");
        sel_setHorizontalScroller_ = sel_registerName("setHorizontalScroller:");
        sel_setIcon_ = sel_registerName("setIcon:");
        sel_setIdentifier_ = sel_registerName("setIdentifier:");
        sel_setImageAlignment_ = sel_registerName("setImageAlignment:");
        sel_setImageInterpolation_ = sel_registerName("setImageInterpolation:");
        sel_setImagePosition_ = sel_registerName("setImagePosition:");
        sel_setImageScaling_ = sel_registerName("setImageScaling:");
        sel_setImage_ = sel_registerName("setImage:");
        sel_setImage_forSegment_ = sel_registerName("setImage:forSegment:");
        sel_setIncrement_ = sel_registerName("setIncrement:");
        sel_setIndentationPerLevel_ = sel_registerName("setIndentationPerLevel:");
        sel_setIndeterminate_ = sel_registerName("setIndeterminate:");
        sel_setIndicatorImage_inTableColumn_ = sel_registerName("setIndicatorImage:inTableColumn:");
        sel_setIntercellSpacing_ = sel_registerName("setIntercellSpacing:");
        sel_setJavaEnabled_ = sel_registerName("setJavaEnabled:");
        sel_setJavaScriptEnabled_ = sel_registerName("setJavaScriptEnabled:");
        sel_setJobDisposition_ = sel_registerName("setJobDisposition:");
        sel_setJobTitle_ = sel_registerName("setJobTitle:");
        sel_setKeyEquivalentModifierMask_ = sel_registerName("setKeyEquivalentModifierMask:");
        sel_setKeyEquivalent_ = sel_registerName("setKeyEquivalent:");
        sel_setLabel_ = sel_registerName("setLabel:");
        sel_setLabel_forSegment_ = sel_registerName("setLabel:forSegment:");
        sel_setLeaf_ = sel_registerName("setLeaf:");
        sel_setLength_ = sel_registerName("setLength:");
        sel_setLevel_ = sel_registerName("setLevel:");
        sel_setLineBreakMode_ = sel_registerName("setLineBreakMode:");
        sel_setLineCapStyle_ = sel_registerName("setLineCapStyle:");
        sel_setLineDash_count_phase_ = sel_registerName("setLineDash:count:phase:");
        sel_setLineFragmentPadding_ = sel_registerName("setLineFragmentPadding:");
        sel_setLineFragmentRect_forGlyphRange_usedRect_ = sel_registerName("setLineFragmentRect:forGlyphRange:usedRect:");
        sel_setLineJoinStyle_ = sel_registerName("setLineJoinStyle:");
        sel_setLineSpacing_ = sel_registerName("setLineSpacing:");
        sel_setLineWidth_ = sel_registerName("setLineWidth:");
        sel_setLinkTextAttributes_ = sel_registerName("setLinkTextAttributes:");
        sel_setMainMenu_ = sel_registerName("setMainMenu:");
        sel_setMarkedText_selectedRange_ = sel_registerName("setMarkedText:selectedRange:");
        sel_setMaximumFractionDigits_ = sel_registerName("setMaximumFractionDigits:");
        sel_setMaximumIntegerDigits_ = sel_registerName("setMaximumIntegerDigits:");
        sel_setMaximum_ = sel_registerName("setMaximum:");
        sel_setMaxSize_ = sel_registerName("setMaxSize:");
        sel_setMaxValue_ = sel_registerName("setMaxValue:");
        sel_setMenu_ = sel_registerName("setMenu:");
        sel_setMenu_forSegment_ = sel_registerName("setMenu:forSegment:");
        sel_setMessageText_ = sel_registerName("setMessageText:");
        sel_setMessage_ = sel_registerName("setMessage:");
        sel_setMinimumFractionDigits_ = sel_registerName("setMinimumFractionDigits:");
        sel_setMinimumIntegerDigits_ = sel_registerName("setMinimumIntegerDigits:");
        sel_setMinimum_ = sel_registerName("setMinimum:");
        sel_setMinSize_ = sel_registerName("setMinSize:");
        sel_setMinValue_ = sel_registerName("setMinValue:");
        sel_setMinWidth_ = sel_registerName("setMinWidth:");
        sel_setMiterLimit_ = sel_registerName("setMiterLimit:");
        sel_setNeedsDisplayInRect_ = sel_registerName("setNeedsDisplayInRect:");
        sel_setNeedsDisplay_ = sel_registerName("setNeedsDisplay:");
        sel_setNumberOfVisibleItems_ = sel_registerName("setNumberOfVisibleItems:");
        sel_setNumberStyle_ = sel_registerName("setNumberStyle:");
        sel_setObjectValue_ = sel_registerName("setObjectValue:");
        sel_setObject_forKey_ = sel_registerName("setObject:forKey:");
        sel_setOnMouseEntered_ = sel_registerName("setOnMouseEntered:");
        sel_setOpaque_ = sel_registerName("setOpaque:");
        sel_setOptions_ = sel_registerName("setOptions:");
        sel_setOrientation_ = sel_registerName("setOrientation:");
        sel_setOutlineTableColumn_ = sel_registerName("setOutlineTableColumn:");
        sel_setPaletteLabel_ = sel_registerName("setPaletteLabel:");
        sel_setPanelFont_isMultiple_ = sel_registerName("setPanelFont:isMultiple:");
        sel_setPartialStringValidationEnabled_ = sel_registerName("setPartialStringValidationEnabled:");
        sel_setPatternPhase_ = sel_registerName("setPatternPhase:");
        sel_setPixelFormat_ = sel_registerName("setPixelFormat:");
        sel_setPlaceholderString_ = sel_registerName("setPlaceholderString:");
        sel_setPolicyDelegate_ = sel_registerName("setPolicyDelegate:");
        sel_setPreferences_ = sel_registerName("setPreferences:");
        sel_setPrinter_ = sel_registerName("setPrinter:");
        sel_setPropertyList_forType_ = sel_registerName("setPropertyList:forType:");
        sel_setPullsDown_ = sel_registerName("setPullsDown:");
        sel_setReleasedWhenClosed_ = sel_registerName("setReleasedWhenClosed:");
        sel_setResizingMask_ = sel_registerName("setResizingMask:");
        sel_setResourceLoadDelegate_ = sel_registerName("setResourceLoadDelegate:");
        sel_setRichText_ = sel_registerName("setRichText:");
        sel_setRowHeight_ = sel_registerName("setRowHeight:");
        sel_setScrollable_ = sel_registerName("setScrollable:");
        sel_setSearchButtonCell_ = sel_registerName("setSearchButtonCell:");
        sel_setSegmentCount_ = sel_registerName("setSegmentCount:");
        sel_setSegmentStyle_ = sel_registerName("setSegmentStyle:");
        sel_setSelectable_ = sel_registerName("setSelectable:");
        sel_setSelectedRange_ = sel_registerName("setSelectedRange:");
        sel_setSelectedSegment_ = sel_registerName("setSelectedSegment:");
        sel_setSelected_forSegment_ = sel_registerName("setSelected:forSegment:");
        sel_setServicesMenu_ = sel_registerName("setServicesMenu:");
        sel_setShouldAntialias_ = sel_registerName("setShouldAntialias:");
        sel_setShowsPrintPanel_ = sel_registerName("setShowsPrintPanel:");
        sel_setShowsProgressPanel_ = sel_registerName("setShowsProgressPanel:");
        sel_setShowsResizeIndicator_ = sel_registerName("setShowsResizeIndicator:");
        sel_setShowsToolbarButton_ = sel_registerName("setShowsToolbarButton:");
        sel_setSize_ = sel_registerName("setSize:");
        sel_setState_ = sel_registerName("setState:");
        sel_setStringValue_ = sel_registerName("setStringValue:");
        sel_setString_ = sel_registerName("setString:");
        sel_setString_forType_ = sel_registerName("setString:forType:");
        sel_setStroke = sel_registerName("setStroke");
        sel_setSubmenu_ = sel_registerName("setSubmenu:");
        sel_setSubmenu_forItem_ = sel_registerName("setSubmenu:forItem:");
        sel_setTabStops_ = sel_registerName("setTabStops:");
        sel_setTabViewType_ = sel_registerName("setTabViewType:");
        sel_setTag_forSegment_ = sel_registerName("setTag:forSegment:");
        sel_setTarget_ = sel_registerName("setTarget:");
        sel_setTextColor_ = sel_registerName("setTextColor:");
        sel_setTextStorage_ = sel_registerName("setTextStorage:");
        sel_setTitleFont_ = sel_registerName("setTitleFont:");
        sel_setTitlePosition_ = sel_registerName("setTitlePosition:");
        sel_setTitle_ = sel_registerName("setTitle:");
        sel_setToolbar_ = sel_registerName("setToolbar:");
        sel_setToolTip_ = sel_registerName("setToolTip:");
        sel_setToolTip_forSegment_ = sel_registerName("setToolTip:forSegment:");
        sel_setTrackingMode_ = sel_registerName("setTrackingMode:");
        sel_setTransformStruct_ = sel_registerName("setTransformStruct:");
        sel_setUIDelegate_ = sel_registerName("setUIDelegate:");
        sel_setUpPrintOperationDefaultValues = sel_registerName("setUpPrintOperationDefaultValues");
        sel_setURL_ = sel_registerName("setURL:");
        sel_setUsesAlternatingRowBackgroundColors_ = sel_registerName("setUsesAlternatingRowBackgroundColors:");
        sel_setUsesThreadedAnimation_ = sel_registerName("setUsesThreadedAnimation:");
        sel_setValueWraps_ = sel_registerName("setValueWraps:");
        sel_setValue_forKey_ = sel_registerName("setValue:forKey:");
        sel_setVerticalScroller_ = sel_registerName("setVerticalScroller:");
        sel_setView_ = sel_registerName("setView:");
        sel_setVisible_ = sel_registerName("setVisible:");
        sel_setWidthTracksTextView_ = sel_registerName("setWidthTracksTextView:");
        sel_setWidth_ = sel_registerName("setWidth:");
        sel_setWidth_forSegment_ = sel_registerName("setWidth:forSegment:");
        sel_setWindingRule_ = sel_registerName("setWindingRule:");
        sel_setWorksWhenModal_ = sel_registerName("setWorksWhenModal:");
        sel_setWraps_ = sel_registerName("setWraps:");
        sel_sharedApplication = sel_registerName("sharedApplication");
        sel_sharedColorPanel = sel_registerName("sharedColorPanel");
        sel_sharedFontManager = sel_registerName("sharedFontManager");
        sel_sharedFontPanel = sel_registerName("sharedFontPanel");
        sel_sharedHTTPCookieStorage = sel_registerName("sharedHTTPCookieStorage");
        sel_sharedPrintInfo = sel_registerName("sharedPrintInfo");
        sel_sharedWorkspace = sel_registerName("sharedWorkspace");
        sel_shiftKey = sel_registerName("shiftKey");
        sel_shouldAntialias = sel_registerName("shouldAntialias");
        sel_shouldChangeTextInRange_replacementString_ = sel_registerName("shouldChangeTextInRange:replacementString:");
        sel_shouldDelayWindowOrderingForEvent_ = sel_registerName("shouldDelayWindowOrderingForEvent:");
        sel_size = sel_registerName("size");
        sel_sizeToFit = sel_registerName("sizeToFit");
        sel_sizeValue = sel_registerName("sizeValue");
        sel_skipDescendents = sel_registerName("skipDescendents");
        sel_smallSystemFontSize = sel_registerName("smallSystemFontSize");
        sel_sortIndicatorRectForBounds_ = sel_registerName("sortIndicatorRectForBounds:");
        sel_standardPreferences = sel_registerName("standardPreferences");
        sel_standardWindowButton_ = sel_registerName("standardWindowButton:");
        sel_startAnimation_ = sel_registerName("startAnimation:");
        sel_state = sel_registerName("state");
        sel_statusItemWithLength_ = sel_registerName("statusItemWithLength:");
        sel_stopAnimation_ = sel_registerName("stopAnimation:");
        sel_stopLoading_ = sel_registerName("stopLoading:");
        sel_stop_ = sel_registerName("stop:");
        sel_string = sel_registerName("string");
        sel_stringByAddingPercentEscapesUsingEncoding_ = sel_registerName("stringByAddingPercentEscapesUsingEncoding:");
        sel_stringByAppendingPathComponent_ = sel_registerName("stringByAppendingPathComponent:");
        sel_stringByAppendingString_ = sel_registerName("stringByAppendingString:");
        sel_stringByDeletingLastPathComponent = sel_registerName("stringByDeletingLastPathComponent");
        sel_stringByDeletingPathExtension = sel_registerName("stringByDeletingPathExtension");
        sel_stringByEvaluatingJavaScriptFromString_ = sel_registerName("stringByEvaluatingJavaScriptFromString:");
        sel_stringByReplacingOccurrencesOfString_withString_ = sel_registerName("stringByReplacingOccurrencesOfString:withString:");
        sel_stringForObjectValue_ = sel_registerName("stringForObjectValue:");
        sel_stringForType_ = sel_registerName("stringForType:");
        sel_stringValue = sel_registerName("stringValue");
        sel_stringWithCharacters_length_ = sel_registerName("stringWithCharacters:length:");
        sel_stringWithFormat_ = sel_registerName("stringWithFormat:");
        sel_stringWithUTF8String_ = sel_registerName("stringWithUTF8String:");
        sel_stroke = sel_registerName("stroke");
        sel_strokeRect_ = sel_registerName("strokeRect:");
        sel_styleMask = sel_registerName("styleMask");
        sel_submenu = sel_registerName("submenu");
        sel_substringWithRange_ = sel_registerName("substringWithRange:");
        sel_subviews = sel_registerName("subviews");
        sel_superclass = sel_registerName("superclass");
        sel_superview = sel_registerName("superview");
        sel_systemFontOfSize_ = sel_registerName("systemFontOfSize:");
        sel_systemFontSize = sel_registerName("systemFontSize");
        sel_systemFontSizeForControlSize_ = sel_registerName("systemFontSizeForControlSize:");
        sel_systemStatusBar = sel_registerName("systemStatusBar");
        sel_systemVersion = sel_registerName("systemVersion");
        sel_tableColumns = sel_registerName("tableColumns");
        sel_tableViewColumnDidMove_ = sel_registerName("tableViewColumnDidMove:");
        sel_tableViewColumnDidResize_ = sel_registerName("tableViewColumnDidResize:");
        sel_tableViewSelectionDidChange_ = sel_registerName("tableViewSelectionDidChange:");
        sel_tableView_acceptDrop_row_dropOperation_ = sel_registerName("tableView:acceptDrop:row:dropOperation:");
        sel_tableView_didClickTableColumn_ = sel_registerName("tableView:didClickTableColumn:");
        sel_tableView_objectValueForTableColumn_row_ = sel_registerName("tableView:objectValueForTableColumn:row:");
        sel_tableView_setObjectValue_forTableColumn_row_ = sel_registerName("tableView:setObjectValue:forTableColumn:row:");
        sel_tableView_shouldEditTableColumn_row_ = sel_registerName("tableView:shouldEditTableColumn:row:");
        sel_tableView_validateDrop_proposedRow_proposedDropOperation_ = sel_registerName("tableView:validateDrop:proposedRow:proposedDropOperation:");
        sel_tableView_willDisplayCell_forTableColumn_row_ = sel_registerName("tableView:willDisplayCell:forTableColumn:row:");
        sel_tableView_writeRowsWithIndexes_toPasteboard_ = sel_registerName("tableView:writeRowsWithIndexes:toPasteboard:");
        sel_tabStops = sel_registerName("tabStops");
        sel_tabStopType = sel_registerName("tabStopType");
        sel_tabViewItemAtPoint_ = sel_registerName("tabViewItemAtPoint:");
        sel_tabView_didSelectTabViewItem_ = sel_registerName("tabView:didSelectTabViewItem:");
        sel_tabView_shouldSelectTabViewItem_ = sel_registerName("tabView:shouldSelectTabViewItem:");
        sel_tabView_willSelectTabViewItem_ = sel_registerName("tabView:willSelectTabViewItem:");
        sel_target = sel_registerName("target");
        sel_terminate_ = sel_registerName("terminate:");
        sel_textBackgroundColor = sel_registerName("textBackgroundColor");
        sel_textColor = sel_registerName("textColor");
        sel_textContainer = sel_registerName("textContainer");
        sel_textDidChange_ = sel_registerName("textDidChange:");
        sel_textDidEndEditing_ = sel_registerName("textDidEndEditing:");
        sel_textStorage = sel_registerName("textStorage");
        sel_textViewDidChangeSelection_ = sel_registerName("textViewDidChangeSelection:");
        sel_textView_clickedOnLink_atIndex_ = sel_registerName("textView:clickedOnLink:atIndex:");
        sel_textView_willChangeSelectionFromCharacterRange_toCharacterRange_ = sel_registerName("textView:willChangeSelectionFromCharacterRange:toCharacterRange:");
        sel_threadDictionary = sel_registerName("threadDictionary");
        sel_TIFFRepresentation = sel_registerName("TIFFRepresentation");
        sel_tile = sel_registerName("tile");
        sel_timestamp = sel_registerName("timestamp");
        sel_timeZone = sel_registerName("timeZone");
        sel_title = sel_registerName("title");
        sel_titleCell = sel_registerName("titleCell");
        sel_titleFont = sel_registerName("titleFont");
        sel_titleOfSelectedItem = sel_registerName("titleOfSelectedItem");
        sel_titleRectForBounds_ = sel_registerName("titleRectForBounds:");
        sel_toggleToolbarShown_ = sel_registerName("toggleToolbarShown:");
        sel_toolbar = sel_registerName("toolbar");
        sel_toolbarAllowedItemIdentifiers_ = sel_registerName("toolbarAllowedItemIdentifiers:");
        sel_toolbarDefaultItemIdentifiers_ = sel_registerName("toolbarDefaultItemIdentifiers:");
        sel_toolbarDidRemoveItem_ = sel_registerName("toolbarDidRemoveItem:");
        sel_toolbarSelectableItemIdentifiers_ = sel_registerName("toolbarSelectableItemIdentifiers:");
        sel_toolbarWillAddItem_ = sel_registerName("toolbarWillAddItem:");
        sel_toolbar_itemForItemIdentifier_willBeInsertedIntoToolbar_ = sel_registerName("toolbar:itemForItemIdentifier:willBeInsertedIntoToolbar:");
        sel_trackingAreas = sel_registerName("trackingAreas");
        sel_traitsOfFont_ = sel_registerName("traitsOfFont:");
        sel_transform = sel_registerName("transform");
        sel_transformPoint_ = sel_registerName("transformPoint:");
        sel_transformSize_ = sel_registerName("transformSize:");
        sel_transformStruct = sel_registerName("transformStruct");
        sel_transformUsingAffineTransform_ = sel_registerName("transformUsingAffineTransform:");
        sel_translateXBy_yBy_ = sel_registerName("translateXBy:yBy:");
        sel_type = sel_registerName("type");
        sel_types = sel_registerName("types");
        sel_typesetter = sel_registerName("typesetter");
        sel_unarchiveObjectWithData_ = sel_registerName("unarchiveObjectWithData:");
        sel_undefined = sel_registerName("undefined");
        sel_unhideAllApplications_ = sel_registerName("unhideAllApplications:");
        sel_unlockFocus = sel_registerName("unlockFocus");
        sel_unmarkText = sel_registerName("unmarkText");
        sel_unregisterDraggedTypes = sel_registerName("unregisterDraggedTypes");
        sel_update = sel_registerName("update");
        sel_updateTrackingAreas = sel_registerName("updateTrackingAreas");
        sel_URL = sel_registerName("URL");
        sel_URLFromPasteboard_ = sel_registerName("URLFromPasteboard:");
        sel_URLWithString_ = sel_registerName("URLWithString:");
        sel_use = sel_registerName("use");
        sel_useCredential_forAuthenticationChallenge_ = sel_registerName("useCredential:forAuthenticationChallenge:");
        sel_usedRectForTextContainer_ = sel_registerName("usedRectForTextContainer:");
        sel_user = sel_registerName("user");
        sel_userInfo = sel_registerName("userInfo");
        sel_usesAlternatingRowBackgroundColors = sel_registerName("usesAlternatingRowBackgroundColors");
        sel_UTF8String = sel_registerName("UTF8String");
        sel_validateVisibleColumns = sel_registerName("validateVisibleColumns");
        sel_validAttributesForMarkedText = sel_registerName("validAttributesForMarkedText");
        sel_value = sel_registerName("value");
        sel_valueForKey_ = sel_registerName("valueForKey:");
        sel_valueWithPoint_ = sel_registerName("valueWithPoint:");
        sel_valueWithRange_ = sel_registerName("valueWithRange:");
        sel_valueWithRect_ = sel_registerName("valueWithRect:");
        sel_valueWithSize_ = sel_registerName("valueWithSize:");
        sel_view = sel_registerName("view");
        sel_viewDidMoveToWindow = sel_registerName("viewDidMoveToWindow");
        sel_view_stringForToolTip_point_userData_ = sel_registerName("view:stringForToolTip:point:userData:");
        sel_visibleFrame = sel_registerName("visibleFrame");
        sel_visibleRect = sel_registerName("visibleRect");
        sel_wantsPeriodicDraggingUpdates = sel_registerName("wantsPeriodicDraggingUpdates");
        sel_wantsToHandleMouseEvents = sel_registerName("wantsToHandleMouseEvents");
        sel_webFrame = sel_registerName("webFrame");
        sel_webScriptValueAtIndex_ = sel_registerName("webScriptValueAtIndex:");
        sel_webViewClose_ = sel_registerName("webViewClose:");
        sel_webViewFocus_ = sel_registerName("webViewFocus:");
        sel_webViewShow_ = sel_registerName("webViewShow:");
        sel_webViewUnfocus_ = sel_registerName("webViewUnfocus:");
        sel_webView_contextMenuItemsForElement_defaultMenuItems_ = sel_registerName("webView:contextMenuItemsForElement:defaultMenuItems:");
        sel_webView_createWebViewWithRequest_ = sel_registerName("webView:createWebViewWithRequest:");
        sel_webView_decidePolicyForMIMEType_request_frame_decisionListener_ = sel_registerName("webView:decidePolicyForMIMEType:request:frame:decisionListener:");
        sel_webView_decidePolicyForNavigationAction_request_frame_decisionListener_ = sel_registerName("webView:decidePolicyForNavigationAction:request:frame:decisionListener:");
        sel_webView_decidePolicyForNewWindowAction_request_newFrameName_decisionListener_ = sel_registerName("webView:decidePolicyForNewWindowAction:request:newFrameName:decisionListener:");
        sel_webView_didChangeLocationWithinPageForFrame_ = sel_registerName("webView:didChangeLocationWithinPageForFrame:");
        sel_webView_didCommitLoadForFrame_ = sel_registerName("webView:didCommitLoadForFrame:");
        sel_webView_didFailProvisionalLoadWithError_forFrame_ = sel_registerName("webView:didFailProvisionalLoadWithError:forFrame:");
        sel_webView_didFinishLoadForFrame_ = sel_registerName("webView:didFinishLoadForFrame:");
        sel_webView_didReceiveTitle_forFrame_ = sel_registerName("webView:didReceiveTitle:forFrame:");
        sel_webView_didStartProvisionalLoadForFrame_ = sel_registerName("webView:didStartProvisionalLoadForFrame:");
        sel_webView_identifierForInitialRequest_fromDataSource_ = sel_registerName("webView:identifierForInitialRequest:fromDataSource:");
        sel_webView_mouseDidMoveOverElement_modifierFlags_ = sel_registerName("webView:mouseDidMoveOverElement:modifierFlags:");
        sel_webView_printFrameView_ = sel_registerName("webView:printFrameView:");
        sel_webView_resource_didFailLoadingWithError_fromDataSource_ = sel_registerName("webView:resource:didFailLoadingWithError:fromDataSource:");
        sel_webView_resource_didFinishLoadingFromDataSource_ = sel_registerName("webView:resource:didFinishLoadingFromDataSource:");
        sel_webView_resource_didReceiveAuthenticationChallenge_fromDataSource_ = sel_registerName("webView:resource:didReceiveAuthenticationChallenge:fromDataSource:");
        sel_webView_resource_willSendRequest_redirectResponse_fromDataSource_ = sel_registerName("webView:resource:willSendRequest:redirectResponse:fromDataSource:");
        sel_webView_runJavaScriptAlertPanelWithMessage_ = sel_registerName("webView:runJavaScriptAlertPanelWithMessage:");
        sel_webView_runJavaScriptConfirmPanelWithMessage_ = sel_registerName("webView:runJavaScriptConfirmPanelWithMessage:");
        sel_webView_runOpenPanelForFileButtonWithResultListener_ = sel_registerName("webView:runOpenPanelForFileButtonWithResultListener:");
        sel_webView_setFrame_ = sel_registerName("webView:setFrame:");
        sel_webView_setResizable_ = sel_registerName("webView:setResizable:");
        sel_webView_setStatusBarVisible_ = sel_registerName("webView:setStatusBarVisible:");
        sel_webView_setStatusText_ = sel_registerName("webView:setStatusText:");
        sel_webView_setToolbarsVisible_ = sel_registerName("webView:setToolbarsVisible:");
        sel_webView_unableToImplementPolicyWithError_frame_ = sel_registerName("webView:unableToImplementPolicyWithError:frame:");
        sel_webView_windowScriptObjectAvailable_ = sel_registerName("webView:windowScriptObjectAvailable:");
        sel_weightOfFont_ = sel_registerName("weightOfFont:");
        sel_wheelDelta = sel_registerName("wheelDelta");
        sel_width = sel_registerName("width");
        sel_window = sel_registerName("window");
        sel_windowBackgroundColor = sel_registerName("windowBackgroundColor");
        sel_windowDidBecomeKey_ = sel_registerName("windowDidBecomeKey:");
        sel_windowDidMove_ = sel_registerName("windowDidMove:");
        sel_windowDidResignKey_ = sel_registerName("windowDidResignKey:");
        sel_windowDidResize_ = sel_registerName("windowDidResize:");
        sel_windowFrameColor = sel_registerName("windowFrameColor");
        sel_windowFrameTextColor = sel_registerName("windowFrameTextColor");
        sel_windowNumber = sel_registerName("windowNumber");
        sel_windows = sel_registerName("windows");
        sel_windowShouldClose_ = sel_registerName("windowShouldClose:");
        sel_windowWillClose_ = sel_registerName("windowWillClose:");
        sel_worksWhenModal = sel_registerName("worksWhenModal");
        sel_wraps = sel_registerName("wraps");
        sel_writeToPasteboard_ = sel_registerName("writeToPasteboard:");
        sel_yearOfCommonEra = sel_registerName("yearOfCommonEra");
        sel_zoom_ = sel_registerName("zoom:");

        kCFRunLoopCommonModes = new NSString (kCFRunLoopCommonModes_);
        NSAccessibilityButtonRole = new NSString (NSAccessibilityButtonRole_);
        NSAccessibilityCheckBoxRole = new NSString (NSAccessibilityCheckBoxRole_);
        NSAccessibilityChildrenAttribute = new NSString (NSAccessibilityChildrenAttribute_);
        NSAccessibilityColumnRole = new NSString (NSAccessibilityColumnRole_);
        NSAccessibilityComboBoxRole = new NSString (NSAccessibilityComboBoxRole_);
        NSAccessibilityConfirmAction = new NSString (NSAccessibilityConfirmAction_);
        NSAccessibilityContentsAttribute = new NSString (NSAccessibilityContentsAttribute_);
        NSAccessibilityDescriptionAttribute = new NSString (NSAccessibilityDescriptionAttribute_);
        NSAccessibilityDialogSubrole = new NSString (NSAccessibilityDialogSubrole_);
        NSAccessibilityEnabledAttribute = new NSString (NSAccessibilityEnabledAttribute_);
        NSAccessibilityExpandedAttribute = new NSString (NSAccessibilityExpandedAttribute_);
        NSAccessibilityFloatingWindowSubrole = new NSString (NSAccessibilityFloatingWindowSubrole_);
        NSAccessibilityFocusedAttribute = new NSString (NSAccessibilityFocusedAttribute_);
        NSAccessibilityFocusedUIElementChangedNotification = new NSString (NSAccessibilityFocusedUIElementChangedNotification_);
        NSAccessibilityGridRole = new NSString (NSAccessibilityGridRole_);
        NSAccessibilityGroupRole = new NSString (NSAccessibilityGroupRole_);
        NSAccessibilityHelpAttribute = new NSString (NSAccessibilityHelpAttribute_);
        NSAccessibilityHelpTagRole = new NSString (NSAccessibilityHelpTagRole_);
        NSAccessibilityHorizontalOrientationValue = new NSString (NSAccessibilityHorizontalOrientationValue_);
        NSAccessibilityHorizontalScrollBarAttribute = new NSString (NSAccessibilityHorizontalScrollBarAttribute_);
        NSAccessibilityImageRole = new NSString (NSAccessibilityImageRole_);
        NSAccessibilityIncrementorRole = new NSString (NSAccessibilityIncrementorRole_);
        NSAccessibilityInsertionPointLineNumberAttribute = new NSString (NSAccessibilityInsertionPointLineNumberAttribute_);
        NSAccessibilityLabelValueAttribute = new NSString (NSAccessibilityLabelValueAttribute_);
        NSAccessibilityLineForIndexParameterizedAttribute = new NSString (NSAccessibilityLineForIndexParameterizedAttribute_);
        NSAccessibilityLinkRole = new NSString (NSAccessibilityLinkRole_);
        NSAccessibilityLinkTextAttribute = new NSString (NSAccessibilityLinkTextAttribute_);
        NSAccessibilityListRole = new NSString (NSAccessibilityListRole_);
        NSAccessibilityMaxValueAttribute = new NSString (NSAccessibilityMaxValueAttribute_);
        NSAccessibilityMenuBarRole = new NSString (NSAccessibilityMenuBarRole_);
        NSAccessibilityMenuButtonRole = new NSString (NSAccessibilityMenuButtonRole_);
        NSAccessibilityMenuItemRole = new NSString (NSAccessibilityMenuItemRole_);
        NSAccessibilityMenuRole = new NSString (NSAccessibilityMenuRole_);
        NSAccessibilityMinValueAttribute = new NSString (NSAccessibilityMinValueAttribute_);
        NSAccessibilityNextContentsAttribute = new NSString (NSAccessibilityNextContentsAttribute_);
        NSAccessibilityNumberOfCharactersAttribute = new NSString (NSAccessibilityNumberOfCharactersAttribute_);
        NSAccessibilityOrientationAttribute = new NSString (NSAccessibilityOrientationAttribute_);
        NSAccessibilityOutlineRole = new NSString (NSAccessibilityOutlineRole_);
        NSAccessibilityOutlineRowSubrole = new NSString (NSAccessibilityOutlineRowSubrole_);
        NSAccessibilityParentAttribute = new NSString (NSAccessibilityParentAttribute_);
        NSAccessibilityPopUpButtonRole = new NSString (NSAccessibilityPopUpButtonRole_);
        NSAccessibilityPositionAttribute = new NSString (NSAccessibilityPositionAttribute_);
        NSAccessibilityPressAction = new NSString (NSAccessibilityPressAction_);
        NSAccessibilityPreviousContentsAttribute = new NSString (NSAccessibilityPreviousContentsAttribute_);
        NSAccessibilityProgressIndicatorRole = new NSString (NSAccessibilityProgressIndicatorRole_);
        NSAccessibilityRadioButtonRole = new NSString (NSAccessibilityRadioButtonRole_);
        NSAccessibilityRadioGroupRole = new NSString (NSAccessibilityRadioGroupRole_);
        NSAccessibilityRangeForIndexParameterizedAttribute = new NSString (NSAccessibilityRangeForIndexParameterizedAttribute_);
        NSAccessibilityRangeForLineParameterizedAttribute = new NSString (NSAccessibilityRangeForLineParameterizedAttribute_);
        NSAccessibilityRangeForPositionParameterizedAttribute = new NSString (NSAccessibilityRangeForPositionParameterizedAttribute_);
        NSAccessibilityRoleAttribute = new NSString (NSAccessibilityRoleAttribute_);
        NSAccessibilityRoleDescriptionAttribute = new NSString (NSAccessibilityRoleDescriptionAttribute_);
        NSAccessibilityRowRole = new NSString (NSAccessibilityRowRole_);
        NSAccessibilityRTFForRangeParameterizedAttribute = new NSString (NSAccessibilityRTFForRangeParameterizedAttribute_);
        NSAccessibilityScrollAreaRole = new NSString (NSAccessibilityScrollAreaRole_);
        NSAccessibilityScrollBarRole = new NSString (NSAccessibilityScrollBarRole_);
        NSAccessibilitySelectedAttribute = new NSString (NSAccessibilitySelectedAttribute_);
        NSAccessibilitySelectedChildrenAttribute = new NSString (NSAccessibilitySelectedChildrenAttribute_);
        NSAccessibilitySelectedChildrenChangedNotification = new NSString (NSAccessibilitySelectedChildrenChangedNotification_);
        NSAccessibilitySelectedTextAttribute = new NSString (NSAccessibilitySelectedTextAttribute_);
        NSAccessibilitySelectedTextChangedNotification = new NSString (NSAccessibilitySelectedTextChangedNotification_);
        NSAccessibilitySelectedTextRangeAttribute = new NSString (NSAccessibilitySelectedTextRangeAttribute_);
        NSAccessibilitySelectedTextRangesAttribute = new NSString (NSAccessibilitySelectedTextRangesAttribute_);
        NSAccessibilityServesAsTitleForUIElementsAttribute = new NSString (NSAccessibilityServesAsTitleForUIElementsAttribute_);
        NSAccessibilitySizeAttribute = new NSString (NSAccessibilitySizeAttribute_);
        NSAccessibilitySliderRole = new NSString (NSAccessibilitySliderRole_);
        NSAccessibilitySortButtonRole = new NSString (NSAccessibilitySortButtonRole_);
        NSAccessibilitySplitterRole = new NSString (NSAccessibilitySplitterRole_);
        NSAccessibilityStandardWindowSubrole = new NSString (NSAccessibilityStandardWindowSubrole_);
        NSAccessibilityStaticTextRole = new NSString (NSAccessibilityStaticTextRole_);
        NSAccessibilityStringForRangeParameterizedAttribute = new NSString (NSAccessibilityStringForRangeParameterizedAttribute_);
        NSAccessibilityStyleRangeForIndexParameterizedAttribute = new NSString (NSAccessibilityStyleRangeForIndexParameterizedAttribute_);
        NSAccessibilitySubroleAttribute = new NSString (NSAccessibilitySubroleAttribute_);
        NSAccessibilitySystemDialogSubrole = new NSString (NSAccessibilitySystemDialogSubrole_);
        NSAccessibilityTabGroupRole = new NSString (NSAccessibilityTabGroupRole_);
        NSAccessibilityTableRole = new NSString (NSAccessibilityTableRole_);
        NSAccessibilityTableRowSubrole = new NSString (NSAccessibilityTableRowSubrole_);
        NSAccessibilityTabsAttribute = new NSString (NSAccessibilityTabsAttribute_);
        NSAccessibilityTextAreaRole = new NSString (NSAccessibilityTextAreaRole_);
        NSAccessibilityTextFieldRole = new NSString (NSAccessibilityTextFieldRole_);
        NSAccessibilityTextLinkSubrole = new NSString (NSAccessibilityTextLinkSubrole_);
        NSAccessibilityTitleAttribute = new NSString (NSAccessibilityTitleAttribute_);
        NSAccessibilityTitleUIElementAttribute = new NSString (NSAccessibilityTitleUIElementAttribute_);
        NSAccessibilityToolbarRole = new NSString (NSAccessibilityToolbarRole_);
        NSAccessibilityTopLevelUIElementAttribute = new NSString (NSAccessibilityTopLevelUIElementAttribute_);
        NSAccessibilityUnknownRole = new NSString (NSAccessibilityUnknownRole_);
        NSAccessibilityUnknownSubrole = new NSString (NSAccessibilityUnknownSubrole_);
        NSAccessibilityValueAttribute = new NSString (NSAccessibilityValueAttribute_);
        NSAccessibilityValueChangedNotification = new NSString (NSAccessibilityValueChangedNotification_);
        NSAccessibilityValueDescriptionAttribute = new NSString (NSAccessibilityValueDescriptionAttribute_);
        NSAccessibilityValueIndicatorRole = new NSString (NSAccessibilityValueIndicatorRole_);
        NSAccessibilityVerticalOrientationValue = new NSString (NSAccessibilityVerticalOrientationValue_);
        NSAccessibilityVerticalScrollBarAttribute = new NSString (NSAccessibilityVerticalScrollBarAttribute_);
        NSAccessibilityVisibleCharacterRangeAttribute = new NSString (NSAccessibilityVisibleCharacterRangeAttribute_);
        NSAccessibilityVisibleChildrenAttribute = new NSString (NSAccessibilityVisibleChildrenAttribute_);
        NSAccessibilityWindowAttribute = new NSString (NSAccessibilityWindowAttribute_);
        NSAccessibilityWindowRole = new NSString (NSAccessibilityWindowRole_);
        NSApplicationDidChangeScreenParametersNotification = new NSString(NSApplicationDidChangeScreenParametersNotification_);
        NSBackgroundColorAttributeName = new NSString (NSBackgroundColorAttributeName_);
        NSBaselineOffsetAttributeName = new NSString (NSBaselineOffsetAttributeName_);
        NSCalibratedRGBColorSpace = new NSString (NSCalibratedRGBColorSpace_);
        NSDefaultRunLoopMode = new NSString (NSDefaultRunLoopMode_);
        NSDeviceResolution = new NSString (NSDeviceResolution_);
        NSDeviceRGBColorSpace = new NSString (NSDeviceRGBColorSpace_);
        NSDragPboard = new NSString (NSDragPboard_);
        NSErrorFailingURLStringKey = new NSString (NSErrorFailingURLStringKey_);
        NSEventTrackingRunLoopMode = new NSString (NSEventTrackingRunLoopMode_);
        NSFilenamesPboardType = new NSString (NSFilenamesPboardType_);
        NSFontAttributeName = new NSString (NSFontAttributeName_);
        NSForegroundColorAttributeName = new NSString (NSForegroundColorAttributeName_);
        NSHTMLPboardType = new NSString (NSHTMLPboardType_);
        NSLinkAttributeName = new NSString (NSLinkAttributeName_);
        NSObliquenessAttributeName = new NSString (NSObliquenessAttributeName_);
        NSParagraphStyleAttributeName = new NSString (NSParagraphStyleAttributeName_);
        NSPrintAllPages = new NSString (NSPrintAllPages_);
        NSPrintCopies = new NSString (NSPrintCopies_);
        NSPrintFirstPage = new NSString (NSPrintFirstPage_);
        NSPrintJobDisposition = new NSString (NSPrintJobDisposition_);
        NSPrintLastPage = new NSString (NSPrintLastPage_);
        NSPrintMustCollate = new NSString (NSPrintMustCollate_);
        NSPrintPreviewJob = new NSString (NSPrintPreviewJob_);
        NSPrintSaveJob = new NSString (NSPrintSaveJob_);
        NSPrintSavePath = new NSString (NSPrintSavePath_);
        NSPrintScalingFactor = new NSString (NSPrintScalingFactor_);
        NSPrintSpoolJob = new NSString (NSPrintSpoolJob_);
        NSRTFPboardType = new NSString (NSRTFPboardType_);
        NSStrikethroughColorAttributeName = new NSString (NSStrikethroughColorAttributeName_);
        NSStrikethroughStyleAttributeName = new NSString (NSStrikethroughStyleAttributeName_);
        NSStringPboardType = new NSString (NSStringPboardType_);
        NSStrokeWidthAttributeName = new NSString (NSStrokeWidthAttributeName_);
        NSSystemColorsDidChangeNotification = new NSString (NSSystemColorsDidChangeNotification_);
        NSTIFFPboardType = new NSString (NSTIFFPboardType_);
        NSToolbarCustomizeToolbarItemIdentifier = new NSString (NSToolbarCustomizeToolbarItemIdentifier_);
        NSToolbarDidRemoveItemNotification = new NSString (NSToolbarDidRemoveItemNotification_);
        NSToolbarFlexibleSpaceItemIdentifier = new NSString (NSToolbarFlexibleSpaceItemIdentifier_);
        NSToolbarPrintItemIdentifier = new NSString (NSToolbarPrintItemIdentifier_);
        NSToolbarSeparatorItemIdentifier = new NSString (NSToolbarSeparatorItemIdentifier_);
        NSToolbarShowColorsItemIdentifier = new NSString (NSToolbarShowColorsItemIdentifier_);
        NSToolbarShowFontsItemIdentifier = new NSString (NSToolbarShowFontsItemIdentifier_);
        NSToolbarSpaceItemIdentifier = new NSString (NSToolbarSpaceItemIdentifier_);
        NSToolbarWillAddItemNotification = new NSString (NSToolbarWillAddItemNotification_);
        NSUnderlineColorAttributeName = new NSString (NSUnderlineColorAttributeName_);
        NSUnderlineStyleAttributeName = new NSString (NSUnderlineStyleAttributeName_);
        NSURLPboardType = new NSString (NSURLPboardType_);
        NSViewGlobalFrameDidChangeNotification = new NSString (NSViewGlobalFrameDidChangeNotification_);
	}

	public static const int gestaltSystemVersion = ('s'<<24) + ('y'<<16) + ('s'<<8) + 'v';
	public static const int noErr = 0;
	public static const int kProcessTransformToForegroundApplication = 1;
	public static const int kAlertCautionIcon = ('c'<<24) + ('a'<<16) + ('u'<<8) + 't';
	public static const int kAlertNoteIcon = ('n'<<24) + ('o'<<16) + ('t'<<8) + 'e';
	public static const int kAlertStopIcon = ('s'<<24) + ('t'<<16) + ('o'<<8) + 'p';
	public static const int shiftKey = 1 << 9;
	public static const int kThemeMetricFocusRectOutset = 7;
	public static const int kHIThemeOrientationNormal = 0;
	public static const int kUIModeNormal = 0;
	public static const int kUIModeContentHidden = 2;
	public static const int kUIModeAllHidden = 3;

	public static const objc.SEL sel_sendSearchSelection;
	public static const objc.SEL sel_sendCancelSelection;
	public static const objc.SEL sel_sendSelection;
	public static const objc.SEL sel_sendSelection_;
	public static const objc.SEL sel_sendDoubleSelection;
	public static const objc.SEL sel_sendVerticalSelection;
	public static const objc.SEL sel_sendHorizontalSelection;
	public static const objc.SEL sel_timerProc_;
	public static const objc.SEL sel_handleNotification_;
	public static const objc.SEL sel_callJava;
	public static const objc.SEL sel_quitRequested_;
	public static const objc.SEL sel_systemSettingsChanged_;
	public static const objc.SEL sel_panelDidEnd_returnCode_contextInfo_;
	public static const objc.SEL sel_updateOpenGLContext_;

	public static const objc.SEL sel_overwriteExistingFileCheck;
	public static const objc.SEL sel_setShowsHiddenFiles_;

	public static const objc.SEL sel_setMovable_;

	public static const objc.SEL sel_contextID;

	public static const objc.SEL sel__drawThemeProgressArea_;

	public static const objc.SEL sel__setNeedsToUseHeartBeatWindow_;

	public static const objc.id class_WebPanelAuthenticationHandler;
	public static const objc.SEL sel_sharedHandler;
	public static const objc.SEL sel_startAuthentication;

	/* These are not generated in order to avoid creating static methods on all classes */
	public static const objc.SEL sel_isSelectorExcludedFromWebScript_;
	public static const objc.SEL sel_webScriptNameForSelector_;

/** JNI natives */

/** @method flags=jni */
public static void* NewGlobalRef (Object object)
{
    auto o = cast(void*) object;
    GC.addRoot(o);

    return o;
}
/**
 * @method flags=jni
 * @param globalRef cast=(jobject)
 */
public static void DeleteGlobalRef(void* globalRef)
{
    GC.removeRoot(globalRef);
}
/** @method flags=no_gen */
public static Object JNIGetObject (void* globalRef)
{
    return cast(Object) globalRef;
}

/** Carbon calls */

alias Carbon.Gestalt Gestalt;
/** @param psn cast=(ProcessSerialNumber *) */
alias Carbon.GetCurrentProcess GetCurrentProcess;
/** @param psn cast=(ProcessSerialNumber *) */
alias Carbon.SetFrontProcess SetFrontProcess;
/** @param psn cast=(ProcessSerialNumber *) */
alias Carbon.TransformProcessType TransformProcessType;
alias Carbon.CPSSetProcessName CPSSetProcessName;
/** @method flags=dynamic */
alias Carbon.SetThemeCursor SetThemeCursor;
/** @method flags=dynamic */
alias Carbon.GetCurrentButtonState GetCurrentButtonState;
/** @method flags=dynamic */
alias Carbon.GetDblTime GetDblTime;
/** @method flags=dynamic
    @param  cast=(CGContextRef) */
alias Cocoa.CGContextCopyPath CGContextCopyPath;
/** @method flags=dynamic */
alias Carbon.TISCopyCurrentKeyboardInputSource TISCopyCurrentKeyboardInputSource;
/** @method flags=dynamic
    @param  cast=(TISInputSourceRef)
    @param  cast=(CFStringRef) */
alias Carbon.TISGetInputSourceProperty TISGetInputSourceProperty;
/** @method flags=no_gen */
alias Carbon.kTISPropertyUnicodeKeyLayoutData kTISPropertyUnicodeKeyLayoutData;
/**
 * @method flags=dynamic
 * @param inMode cast=(UInt32)
 * @param inOptions cast=(UInt32)
 */
alias Carbon.SetSystemUIMode SetSystemUIMode;
/**
 * @method flags=dynamic
 * @param keyLayoutPtr cast=(const UCKeyboardLayout *)
 * @param virtualKeyCode cast=(UInt16)
 * @param keyAction cast=(UInt16)
 * @param modifierKeyState cast=(UInt32)
 * @param keyboardType cast=(UInt32)
 * @param keyTranslateOptions cast=(OptionBits)
 * @param deadKeyState cast=(UInt32 *)
 * @param maxStringLength cast=(UniCharCount)
 * @param actualStringLength cast=(UniCharCount *)
 * @param unicodeString cast=(UniChar *)
 */
alias Carbon.UCKeyTranslate UCKeyTranslate;
/**
 * @method flags=dynamic
 * @param metric cast=(SInt32 *)
*/
alias Carbon.GetThemeMetric GetThemeMetric;
/**
 * @method flags=dynamic
 * @param inContext cast=(CGContextRef)
*/
alias Carbon.HIThemeDrawFocusRect HIThemeDrawFocusRect;

public static final int kUCKeyActionDown = 0;
public static final int kUCKeyActionUp = 1;

public static const int kUCKeyActionDown = 0;
public static const int kUCKeyActionUp = 1;

public static const int kThemeCopyArrowCursor = 1;
public static const int kThemeNotAllowedCursor = 18;
public static const int kThemeAliasArrowCursor = 2;

/** @method flags=dynamic
 * @param iFile cast=(const FSRef *)
 * @param iContext cast=(ATSFontContext)
 * @param iFormat cast=(ATSFontFormat)
 * @param iReserved cast=(void *)
 * @param iOptions cast=(ATSOptionFlags)
 * @param oContainer cast=(ATSFontContainerRef *)
 */
alias Carbon.ATSFontActivateFromFileReference ATSFontActivateFromFileReference;

public static const int kATSFontContextLocal = 2;
public static const int kATSOptionFlagsDefault = 0;
public static const int kATSFontFormatUnspecified = 0;

/** @method flags=dynamic
 * @param path cast=(const UInt8 *)
 * @param ref cast=(FSRef *)
 * @param isDirectory cast=(Boolean *)
 */
alias Carbon.FSPathMakeRef FSPathMakeRef;

/** @method flags=dynamic */
alias Carbon.LMGetKbdType LMGetKbdType;

/** @method flags=dynamic */
alias Carbon.AcquireRootMenu AcquireRootMenu;
/** @method flags=dynamic */
alias Carbon.CancelMenuTracking CancelMenuTracking;

/** @method flags=dynamic
 * @param iFile cast=(const FSRef *)
 * @param iContext cast=(ATSFontContext)
 * @param iFormat cast=(ATSFontFormat)
 * @param iReserved cast=(void *)
 * @param iOptions cast=(ATSOptionFlags)
 * @param oContainer cast=(ATSFontContainerRef *)
 */
public static final native int ATSFontActivateFromFileReference(byte[] iFile, int iContext, int iFormat, int /*long*/ iReserved, int iOptions, int /*long*/ [] oContainer);

public static final int kATSFontContextLocal = 2;
public static final int kATSOptionFlagsDefault = 0;
public static final int kATSFontFormatUnspecified = 0;

/** @method flags=dynamic
 * @param path cast=(const UInt8 *)
 * @param ref cast=(FSRef *)
 * @param isDirectory cast=(Boolean *)
 */
public static final native int FSPathMakeRef (int /*long*/ path, byte[] ref, bool[] isDirectory);

/** @method flags=dynamic */
public static final native byte LMGetKbdType();

/** @method flags=dynamic */
public static final native int /*long*/ AcquireRootMenu ();
/** @method flags=dynamic */
public static final native int CancelMenuTracking (int /*long*/ inRootMenu, bool inImmediate, int inDismissalReason);

/** C calls */

alias unistd.getpid getpid;

void call (objc.IMP func, objc.id id, objc.SEL sel)
{
    // ((void (*)())arg0)(arg1, arg2);
    func(id, sel);
}

/** @method flags=no_gen */
version (BigEndian)
	public static const bool __BIG_ENDIAN__ = true;

else
	public static const bool __BIG_ENDIAN__ = false;

public static const int kCGBitmapByteOrderDefault = 0 << 12;
public static const int kCGBitmapByteOrder16Little = 1 << 12;
public static const int kCGBitmapByteOrder32Little = 2 << 12;
public static const int kCGBitmapByteOrder16Big = 3 << 12;
public static const int kCGBitmapByteOrder32Big = 4 << 12;
public static const int kCGBitmapByteOrder16Host = __BIG_ENDIAN__ ? kCGBitmapByteOrder16Big : kCGBitmapByteOrder16Little;
public static const int kCGBitmapByteOrder32Host = __BIG_ENDIAN__ ? kCGBitmapByteOrder32Big : kCGBitmapByteOrder32Little;

/**
 * @method flags=dynamic
 * @param destRect flags=struct
 * @param srcRect flags=struct
 */
alias Cocoa.CGContextCopyWindowContentsToRect CGContextCopyWindowContentsToRect;

public static final native void call(int /*long*/ proc, int /*long*/ id, int /*long*/ sel);

/** @method flags=no_gen */
public static final native bool __BIG_ENDIAN__();
public static final int kCGBitmapByteOrderDefault = 0 << 12;
public static final int kCGBitmapByteOrder16Little = 1 << 12;
public static final int kCGBitmapByteOrder32Little = 2 << 12;
public static final int kCGBitmapByteOrder16Big = 3 << 12;
public static final int kCGBitmapByteOrder32Big = 4 << 12;
public static final int kCGBitmapByteOrder16Host = __BIG_ENDIAN__() ? kCGBitmapByteOrder16Big : kCGBitmapByteOrder16Little;
public static final int kCGBitmapByteOrder32Host = __BIG_ENDIAN__() ? kCGBitmapByteOrder32Big : kCGBitmapByteOrder32Little;

/**
 * @method flags=dynamic
 * @param destRect flags=struct
 * @param srcRect flags=struct
 */
public static final native void CGContextCopyWindowContentsToRect(int /*long*/ context, CGRect destRect, int /*long*/ contextID, int /*long*/ windowNumber, CGRect srcRect);

/** QuickDraw calls */

/** @method flags=dynamic */
alias Carbon.NewRgn NewRgn;
/** @method flags=dynamic */
alias Carbon.RectRgn RectRgn;
/** @method flags=dynamic */
alias Carbon.OpenRgn OpenRgn;
/** @method flags=dynamic */
alias Carbon.OffsetRgn OffsetRgn;
/** @method flags=dynamic */
alias Carbon.MoveTo MoveTo;
/** @method flags=dynamic */
alias Carbon.LineTo LineTo;
/** @method flags=dynamic */
alias Carbon.UnionRgn UnionRgn;
/** @method flags=dynamic */
alias Carbon.CloseRgn CloseRgn;
/** @method flags=dynamic */
alias Carbon.DisposeRgn DisposeRgn;
/**
 * @method flags=dynamic
 * @param pt flags=struct,cast=(Point *)
 */
/** @method flags=dynamic */
alias Carbon.GetRegionBounds GetRegionBounds;
/** @method flags=dynamic */
alias Carbon.SectRgn SectRgn;
/** @method flags=dynamic */
alias Carbon.EmptyRgn EmptyRgn;
/** @method flags=dynamic */
alias Carbon.DiffRgn DiffRgn;
/** @method flags=dynamic */
alias Carbon.RectInRgn RectInRgn;
/** @method flags=dynamic */
alias Carbon.QDRegionToRects QDRegionToRects;
/** @method flags=dynamic */
alias Carbon.CopyRgn CopyRgn;
/** @method flags=dynamic */
alias Carbon.SetRect SetRect;
alias Carbon.kQDParseRegionFromTop kQDParseRegionFromTop;
alias Carbon.kQDParseRegionFromBottom kQDParseRegionFromBottom;
alias Carbon.kQDParseRegionFromLeft kQDParseRegionFromLeft;
alias Carbon.kQDParseRegionFromRight kQDParseRegionFromRight;
alias Carbon.kQDParseRegionFromTopLeft kQDParseRegionFromTopLeft;
alias Carbon.kQDRegionToRectsMsgParse kQDRegionToRectsMsgParse;

/** Custom callbacks */

/** @method flags=no_gen */
alias custom.isFlipped_CALLBACK isFlipped_CALLBACK;

/** Custom structure return */

/** @method flags=no_gen */
alias Cocoa.NSIntersectionRect NSIntersectionRect;
/**
 * @method flags=no_gen
 * @param display cast=(CGDirectDisplayID)
 */
alias Cocoa.CGDisplayBounds CGDisplayBounds;

/** Objective-C runtime */

/**
 * @param cls cast=(Class)
 * @param name cast=(const char *),flags=critical
 * @param types cast=(const char *),flags=critical
 */
alias objc.class_addIvar class_addIvar;
/**
 * @param cls cast=(Class)
 * @param name cast=(SEL)
 * @param imp cast=(IMP)
 */
alias objc.class_addMethod class_addMethod;
/**
 * @param cls cast=(Class)
 * @param protocol cast=(Protocol *)
 */
alias objc.class_addProtocol class_addProtocol;
/**
 * @param method cast=(Method)
 * @param aClass cast=(Class)
 * @param aSelector cast=(SEL)
 */
public static final native int /*long*/ class_getClassMethod(int /*long*/ aClass, int /*long*/ aSelector);
/**
 */
alias objc.class_getClassMethod class_getClassMethod;
/**
 * @param cls cast=(Class)
 * @param name cast=(SEL)
 */
public static final native int /*long*/ class_getInstanceMethod(int /*long*/ cls, int /*long*/ name);
/** @param cls cast=(Class) */
public static final native int /*long*/ class_getSuperclass(int /*long*/ cls);
/**
 * @param method cast=(Method)
 * @param imp cast=(IMP)
 */
public static final native int /*long*/ method_setImplementation(int /*long*/ method, int /*long*/ imp);
/**
 * @param cls cast=(Class)
 * @param extraBytes cast=(size_t)
 */
public static final native int /*long*/ class_createInstance(int /*long*/ cls, int /*long*/ extraBytes);

public static final native int /*long*/ objc_getMetaClass(String name);
 * @param cls cast=(Class)
 * @param name cast=(SEL)
alias objc.class_getMethodImplementation class_getMethodImplementation;
 * @param cls cast=(Class)
 * @param name cast=(SEL)
alias objc.class_getInstanceMethod class_getInstanceMethod;
/** @param cls cast=(Class) */
alias objc.class_getSuperclass class_getSuperclass;
/**
 * @param method cast=(Method)
 * @param imp cast=(IMP)
 */
alias objc.method_setImplementation method_setImplementation;
 * @param cls cast=(Class)
 * @param extraBytes cast=(size_t)
alias objc.class_createInstance class_createInstance;

/** @method flags=no_gen */
alias objc.class_getName class_getName;
/** @method flags=dynamic */
alias objc.instrumentObjcMessageSends instrumentObjcMessageSends;
/** @param superclass cast=(Class) */
alias objc.objc_allocateClassPair objc_allocateClassPair;
alias objc.objc_getClass objc_getClass;
alias objc.objc_getMetaClass objc_getMetaClass;
alias objc.objc_getProtocol objc_getProtocol;
alias objc.objc_lookUpClass objc_lookUpClass;
/** @param cls cast=(Class) */
alias objc.objc_registerClassPair objc_registerClassPair;
/** @param obj cast=(id) */
alias objc.object_getClassName object_getClassName;
/** @param obj cast=(id) */
alias objc.object_getClass object_getClass;

/**
 * @param obj cast=(id)
 * @param name cast=(const char*),flags=critical
 * @param outValue cast=(void **),flags=critical
 */
alias objc.object_getInstanceVariable object_getInstanceVariable;
/**
 * @param obj cast=(id)
 * @param name cast=(const char*),flags=critical
 * @param value cast=(void *),flags=critical
 */
alias objc.object_setInstanceVariable object_setInstanceVariable;
/**
 * @param obj cast=(id)
 * @param clazz cast=(Class)
 */
alias objc.object_setClass object_setClass;
alias objc.sel_registerName sel_registerName;
size_t objc_super_sizeof ()
{
    return objc.objc_super.sizeof;
}


/** This section is auto generated */

/** Custom callbacks */
/** @method callback_types=id;id;SEL;NSPoint;,callback_flags=none;none;none;struct; */
alias custom.CALLBACK_accessibilityHitTest_ CALLBACK_accessibilityHitTest_;
/** @method callback_types=NSAttributedString*;id;SEL;NSRange;,callback_flags=none;none;none;struct; */
alias custom.CALLBACK_attributedSubstringFromRange_ CALLBACK_attributedSubstringFromRange_;
/** @method callback_types=BOOL;id;SEL;NSIndexSet*;NSPoint;,callback_flags=none;none;none;none;struct; */
alias custom.CALLBACK_canDragRowsWithIndexes_atPoint_ CALLBACK_canDragRowsWithIndexes_atPoint_;
/** @method callback_types=NSSize;id;SEL;,callback_flags=struct;none;none; */
alias custom.CALLBACK_cellSize CALLBACK_cellSize;
/** @method callback_types=NSUInteger;id;SEL;NSPoint;,callback_flags=none;none;none;struct; */
alias custom.CALLBACK_characterIndexForPoint_ CALLBACK_characterIndexForPoint_;
/** @method callback_types=BOOL;id;SEL;NSEvent*;NSSize;BOOL;,callback_flags=none;none;none;none;struct;none; */
alias custom.CALLBACK_dragSelectionWithEvent_offset_slideBack_ CALLBACK_dragSelectionWithEvent_offset_slideBack_;
/** @method callback_types=void;id;SEL;NSImage*;NSPoint;,callback_flags=none;none;none;none;struct; */
alias custom.CALLBACK_draggedImage_beganAt_ CALLBACK_draggedImage_beganAt_;
/** @method callback_types=void;id;SEL;NSImage*;NSPoint;NSDragOperation;,callback_flags=none;none;none;none;struct;none; */
alias custom.CALLBACK_draggedImage_endedAt_operation_ CALLBACK_draggedImage_endedAt_operation_;
/** @method callback_types=void;id;SEL;NSImage*;NSRect;NSView*;,callback_flags=none;none;none;none;struct;none; */
alias custom.CALLBACK_drawImage_withFrame_inView_ CALLBACK_drawImage_withFrame_inView_;
/** @method callback_types=void;id;SEL;NSRect;NSView*;,callback_flags=none;none;none;struct;none; */
alias custom.CALLBACK_drawInteriorWithFrame_inView_ CALLBACK_drawInteriorWithFrame_inView_;
/** @method callback_types=void;id;SEL;NSRect;,callback_flags=none;none;none;struct; */
alias custom.CALLBACK_drawRect_ CALLBACK_drawRect_;
/** @method callback_types=void;id;SEL;NSRect;NSView*;,callback_flags=none;none;none;struct;none; */
alias custom.CALLBACK_drawWithExpansionFrame_inView_ CALLBACK_drawWithExpansionFrame_inView_;
/** @method callback_types=NSRect;id;SEL;NSRect;NSView*;,callback_flags=struct;none;none;struct;none; */
alias custom.CALLBACK_expansionFrameWithFrame_inView_ CALLBACK_expansionFrameWithFrame_inView_;
/** @method callback_types=NSRect;id;SEL;NSRange;,callback_flags=struct;none;none;struct; */
alias custom.CALLBACK_firstRectForCharacterRange_ CALLBACK_firstRectForCharacterRange_;
/** @method callback_types=void;id;SEL;NSRect;,callback_flags=none;none;none;struct; */
alias custom.CALLBACK_highlightSelectionInClipRect_ CALLBACK_highlightSelectionInClipRect_;
/** @method callback_types=NSView*;id;SEL;NSPoint;,callback_flags=none;none;none;struct; */
alias custom.CALLBACK_hitTest_ CALLBACK_hitTest_;
/** @method callback_types=NSUInteger;id;SEL;NSEvent*;NSRect;NSView*;,callback_flags=none;none;none;none;struct;none; */
alias custom.CALLBACK_hitTestForEvent_inRect_ofView_ CALLBACK_hitTestForEvent_inRect_ofView_;
/** @method callback_types=NSRect;id;SEL;NSRect;,callback_flags=struct;none;none;struct; */
alias custom.CALLBACK_imageRectForBounds_ CALLBACK_imageRectForBounds_;
/** @method callback_types=NSRange;id;SEL;,callback_flags=struct;none;none; */
alias custom.CALLBACK_markedRange CALLBACK_markedRange;
/** @method callback_types=NSRange;id;SEL;,callback_flags=struct;none;none; */
alias custom.CALLBACK_selectedRange CALLBACK_selectedRange;
/** @method callback_types=void;id;SEL;NSRect;,callback_flags=none;none;none;struct; */
alias custom.CALLBACK_setFrame_ CALLBACK_setFrame_;
/** @method callback_types=void;id;SEL;NSPoint;,callback_flags=none;none;none;struct; */
alias custom.CALLBACK_setFrameOrigin_ CALLBACK_setFrameOrigin_;
/** @method callback_types=void;id;SEL;NSSize;,callback_flags=none;none;none;struct; */
alias custom.CALLBACK_setFrameSize_ CALLBACK_setFrameSize_;
/** @method callback_types=void;id;SEL;id;NSRange;,callback_flags=none;none;none;none;struct; */
alias custom.CALLBACK_setMarkedText_selectedRange_ CALLBACK_setMarkedText_selectedRange_;
/** @method callback_types=void;id;SEL;NSRect;,callback_flags=none;none;none;struct; */
alias custom.CALLBACK_setNeedsDisplayInRect_ CALLBACK_setNeedsDisplayInRect_;
/** @method callback_types=BOOL;id;SEL;NSRange;NSString*;,callback_flags=none;none;none;struct;none; */
alias custom.CALLBACK_shouldChangeTextInRange_replacementString_ CALLBACK_shouldChangeTextInRange_replacementString_;
/** @method callback_types=NSRange;id;SEL;NSTextView*;NSRange;NSRange;,callback_flags=struct;none;none;none;struct;struct; */
alias custom.CALLBACK_textView_willChangeSelectionFromCharacterRange_toCharacterRange_ CALLBACK_textView_willChangeSelectionFromCharacterRange_toCharacterRange_;
/** @method callback_types=NSRect;id;SEL;NSRect;,callback_flags=struct;none;none;struct; */
alias custom.CALLBACK_titleRectForBounds_ CALLBACK_titleRectForBounds_;
/** @method callback_types=NSString*;id;SEL;NSView*;NSToolTipTag;NSPoint;void*;,callback_flags=none;none;none;none;none;struct;none; */
alias custom.CALLBACK_view_stringForToolTip_point_userData_ CALLBACK_view_stringForToolTip_point_userData_;
/** @method callback_types=void;id;SEL;WebView*;NSRect;,callback_flags=none;none;none;none;struct; */
alias custom.CALLBACK_webView_setFrame_ CALLBACK_webView_setFrame_;

/** Classes */
public static const objc.id class_DOMDocument;
public static const objc.id class_DOMEvent;
public static const objc.id class_DOMKeyboardEvent;
public static const objc.id class_DOMMouseEvent;
public static const objc.id class_DOMUIEvent;
public static const objc.id class_DOMWheelEvent;
public static const objc.id class_NSActionCell;
public static const objc.id class_NSAffineTransform;
public static const objc.id class_NSAlert;
public static const objc.id class_NSAppleEventDescriptor;
public static const objc.id class_NSApplication;
public static const objc.id class_NSArray;
public static const objc.id class_NSAttributedString;
public static const objc.id class_NSAutoreleasePool;
public static const objc.id class_NSBezierPath;
public static const objc.id class_NSBitmapImageRep;
public static const objc.id class_NSBox;
public static const objc.id class_NSBrowserCell;
public static const objc.id class_NSBundle;
public static const objc.id class_NSButton;
public static const objc.id class_NSButtonCell;
public static const objc.id class_NSCalendarDate;
public static const objc.id class_NSCell;
public static const objc.id class_NSCharacterSet;
public static const objc.id class_NSClipView;
public static const objc.id class_NSCoder;
public static const objc.id class_NSColor;
public static const objc.id class_NSColorPanel;
public static const objc.id class_NSColorSpace;
public static const objc.id class_NSComboBox;
public static const objc.id class_NSComboBoxCell;
public static const objc.id class_NSControl;
public static const objc.id class_NSCursor;
public static const objc.id class_NSData;
public static const objc.id class_NSDate;
public static const objc.id class_NSDatePicker;
public static const objc.id class_NSDictionary;
public static const objc.id class_NSDirectoryEnumerator;
public static const objc.id class_NSEnumerator;
public static const objc.id class_NSError;
public static const objc.id class_NSEvent;
public static const objc.id class_NSFileManager;
public static const objc.id class_NSFileWrapper;
public static const objc.id class_NSFont;
public static const objc.id class_NSFontManager;
public static const objc.id class_NSFontPanel;
public static const objc.id class_NSFormatter;
public static const objc.id class_NSGradient;
public static const objc.id class_NSGraphicsContext;
public static const objc.id class_NSHTTPCookie;
public static const objc.id class_NSHTTPCookieStorage;
public static const objc.id class_NSImage;
public static const objc.id class_NSImageRep;
public static const objc.id class_NSImageView;
public static const objc.id class_NSIndexSet;
public static const objc.id class_NSInputManager;
public static const objc.id class_NSKeyedArchiver;
public static const objc.id class_NSKeyedUnarchiver;
public static const objc.id class_NSLayoutManager;
public static const objc.id class_NSMenu;
public static const objc.id class_NSMenuItem;
public static const objc.id class_NSMutableArray;
public static const objc.id class_NSMutableAttributedString;
public static const objc.id class_NSMutableDictionary;
public static const objc.id class_NSMutableIndexSet;
public static const objc.id class_NSMutableParagraphStyle;
public static const objc.id class_NSMutableSet;
public static const objc.id class_NSMutableString;
public static const objc.id class_NSMutableURLRequest;
public static const objc.id class_NSNotification;
public static const objc.id class_NSNotificationCenter;
public static const objc.id class_NSNumber;
public static const objc.id class_NSNumberFormatter;
public static const objc.id class_NSObject;
public static const objc.id class_NSOpenGLContext;
public static const objc.id class_NSOpenGLPixelFormat;
public static const objc.id class_NSOpenGLView;
public static const objc.id class_NSOpenPanel;
public static const objc.id class_NSOutlineView;
public static const objc.id class_NSPanel;
public static const objc.id class_NSParagraphStyle;
public static const objc.id class_NSPasteboard;
public static const objc.id class_NSPopUpButton;
public static const objc.id class_NSPrintInfo;
public static const objc.id class_NSPrintOperation;
public static const objc.id class_NSPrintPanel;
public static const objc.id class_NSPrinter;
public static const objc.id class_NSProgressIndicator;
public static const objc.id class_NSResponder;
public static const objc.id class_NSRunLoop;
public static const objc.id class_NSSavePanel;
public static const objc.id class_NSScreen;
public static const objc.id class_NSScrollView;
public static const objc.id class_NSScroller;
public static const objc.id class_NSSearchField;
public static const objc.id class_NSSearchFieldCell;
public static const objc.id class_NSSecureTextField;
public static const objc.id class_NSSegmentedCell;
public static const objc.id class_NSSet;
public static const objc.id class_NSSlider;
public static const objc.id class_NSStatusBar;
public static const objc.id class_NSStatusItem;
public static const objc.id class_NSStepper;
public static const objc.id class_NSString;
public static const objc.id class_NSTabView;
public static const objc.id class_NSTabViewItem;
public static const objc.id class_NSTableColumn;
public static const objc.id class_NSTableHeaderCell;
public static const objc.id class_NSTableHeaderView;
public static const objc.id class_NSTableView;
public static const objc.id class_NSText;
public static const objc.id class_NSTextAttachment;
public static const objc.id class_NSTextContainer;
public static const objc.id class_NSTextField;
public static const objc.id class_NSTextFieldCell;
public static const objc.id class_NSTextStorage;
public static const objc.id class_NSTextTab;
public static const objc.id class_NSTextView;
public static const objc.id class_NSThread;
public static const objc.id class_NSTimeZone;
public static const objc.id class_NSTimer;
public static const objc.id class_NSToolbar;
public static const objc.id class_NSToolbarItem;
public static const objc.id class_NSTrackingArea;
public static const objc.id class_NSTypesetter;
public static const objc.id class_NSURL;
public static const objc.id class_NSURLAuthenticationChallenge;
public static const objc.id class_NSURLCredential;
public static const objc.id class_NSURLDownload;
public static const objc.id class_NSURLRequest;
public static const objc.id class_NSValue;
public static const objc.id class_NSView;
public static const objc.id class_NSWindow;
public static const objc.id class_NSWorkspace;
public static const objc.id class_WebDataSource;
public static const objc.id class_WebFrame;
public static const objc.id class_WebFrameView;
public static const objc.id class_WebPreferences;
public static const objc.id class_WebView;
public static const objc.id class_NSURLProtectionSpace;
public static const objc.id class_WebScriptObject;
public static const objc.id class_WebUndefined;

/** Protocols */
public static const objc.Protocol* protocol_NSAccessibility;
public static const objc.Protocol* protocol_NSAccessibilityAdditions;
public static const objc.Protocol* protocol_NSApplicationDelegate;
public static const objc.Protocol* protocol_NSApplicationNotifications;
public static const objc.Protocol* protocol_NSColorPanelResponderMethod;
public static const objc.Protocol* protocol_NSComboBoxNotifications;
public static const objc.Protocol* protocol_NSDraggingDestination;
public static const objc.Protocol* protocol_NSDraggingSource;
public static const objc.Protocol* protocol_NSFontManagerResponderMethod;
public static const objc.Protocol* protocol_NSMenuDelegate;
public static const objc.Protocol* protocol_NSOutlineViewDataSource;
public static const objc.Protocol* protocol_NSOutlineViewDelegate;
public static const objc.Protocol* protocol_NSOutlineViewNotifications;
public static const objc.Protocol* protocol_NSPasteboardOwner;
public static const objc.Protocol* protocol_NSSavePanelDelegate;
public static const objc.Protocol* protocol_NSTabViewDelegate;
public static const objc.Protocol* protocol_NSTableDataSource;
public static const objc.Protocol* protocol_NSTableViewDelegate;
public static const objc.Protocol* protocol_NSTableViewNotifications;
public static const objc.Protocol* protocol_NSTextDelegate;
public static const objc.Protocol* protocol_NSTextInput;
public static const objc.Protocol* protocol_NSTextViewDelegate;
public static const objc.Protocol* protocol_NSToolTipOwner;
public static const objc.Protocol* protocol_NSToolbarDelegate;
public static const objc.Protocol* protocol_NSToolbarNotifications;
public static const objc.Protocol* protocol_NSURLDownloadDelegate;
public static const objc.Protocol* protocol_NSWindowDelegate;
public static const objc.Protocol* protocol_NSWindowNotifications;
public static const objc.Protocol* protocol_WebDocumentRepresentation;
public static const objc.Protocol* protocol_WebFrameLoadDelegate;
public static const objc.Protocol* protocol_WebOpenPanelResultListener;
public static const objc.Protocol* protocol_WebPolicyDecisionListener;
public static const objc.Protocol* protocol_WebPolicyDelegate;
public static const objc.Protocol* protocol_WebResourceLoadDelegate;
public static const objc.Protocol* protocol_WebUIDelegate;

/** Selectors */
public static const objc.SEL sel_abortEditing;
public static const objc.SEL sel_absoluteString;
public static const objc.SEL sel_acceptsFirstMouse_;
public static const objc.SEL sel_acceptsFirstResponder;
public static const objc.SEL sel_accessibilityActionDescription_;
public static const objc.SEL sel_accessibilityActionNames;
public static const objc.SEL sel_accessibilityAttributeNames;
public static const objc.SEL sel_accessibilityAttributeValue_;
public static const objc.SEL sel_accessibilityAttributeValue_forParameter_;
public static const objc.SEL sel_accessibilityFocusedUIElement;
public static const objc.SEL sel_accessibilityHitTest_;
public static const objc.SEL sel_accessibilityIsAttributeSettable_;
public static const objc.SEL sel_accessibilityIsIgnored;
public static const objc.SEL sel_accessibilityParameterizedAttributeNames;
public static const objc.SEL sel_accessibilityPerformAction_;
public static const objc.SEL sel_accessibilitySetOverrideValue_forAttribute_;
public static const objc.SEL sel_accessibilitySetValue_forAttribute_;
public static const objc.SEL sel_action;
public static const objc.SEL sel_activateIgnoringOtherApps_;
public static const objc.SEL sel_addAttribute_value_range_;
public static const objc.SEL sel_addButtonWithTitle_;
public static const objc.SEL sel_addChildWindow_ordered_;
public static const objc.SEL sel_addClip;
public static const objc.SEL sel_addEventListener_listener_useCapture_;
public static const objc.SEL sel_addIndex_;
public static const objc.SEL sel_addItemWithObjectValue_;
public static const objc.SEL sel_addItemWithTitle_action_keyEquivalent_;
public static const objc.SEL sel_addItem_;
public static const objc.SEL sel_addLayoutManager_;
public static const objc.SEL sel_addObjectsFromArray_;
public static const objc.SEL sel_addObject_;
public static const objc.SEL sel_addObserver_selector_name_object_;
public static const objc.SEL sel_addRepresentation_;
public static const objc.SEL sel_addSubview_;
public static const objc.SEL sel_addSubview_positioned_relativeTo_;
public static const objc.SEL sel_addTableColumn_;
public static const objc.SEL sel_addTabStop_;
public static const objc.SEL sel_addTabViewItem_;
public static const objc.SEL sel_addTemporaryAttribute_value_forCharacterRange_;
public static const objc.SEL sel_addTextContainer_;
public static const objc.SEL sel_addTimer_forMode_;
public static const objc.SEL sel_addToolTipRect_owner_userData_;
public static const objc.SEL sel_addTypes_owner_;
public static const objc.SEL sel_alertWithMessageText_defaultButton_alternateButton_otherButton_informativeTextWithFormat_;
public static const objc.SEL sel_alignment;
public static const objc.SEL sel_allKeys;
public static const objc.SEL sel_alloc;
public static const objc.SEL sel_allowsColumnReordering;
public static const objc.SEL sel_allowsFloats;
public static const objc.SEL sel_alphaComponent;
public static const objc.SEL sel_alphaValue;
public static const objc.SEL sel_alternateSelectedControlColor;
public static const objc.SEL sel_alternateSelectedControlTextColor;
public static const objc.SEL sel_altKey;
public static const objc.SEL sel_alwaysShowsDecimalSeparator;
public static const objc.SEL sel_appendAttributedString_;
public static const objc.SEL sel_appendBezierPathWithArcWithCenter_radius_startAngle_endAngle_;
public static const objc.SEL sel_appendBezierPathWithArcWithCenter_radius_startAngle_endAngle_clockwise_;
public static const objc.SEL sel_appendBezierPathWithGlyphs_count_inFont_;
public static const objc.SEL sel_appendBezierPathWithOvalInRect_;
public static const objc.SEL sel_appendBezierPathWithRect_;
public static const objc.SEL sel_appendBezierPathWithRoundedRect_xRadius_yRadius_;
public static const objc.SEL sel_appendBezierPath_;
public static const objc.SEL sel_appendString_;
public static const objc.SEL sel_applicationDidBecomeActive_;
public static const objc.SEL sel_applicationDidFinishLaunching_;
public static const objc.SEL sel_applicationDidResignActive_;
public static const objc.SEL sel_applicationShouldTerminate_;
public static const objc.SEL sel_applicationWillFinishLaunching_;
public static const objc.SEL sel_applicationWillResignActive_;
public static const objc.SEL sel_applicationWillTerminate_;
public static const objc.SEL sel_archivedDataWithRootObject_;
public static const objc.SEL sel_areCursorRectsEnabled;
public static const objc.SEL sel_array;
public static const objc.SEL sel_arrayWithCapacity_;
public static const objc.SEL sel_arrayWithObject_;
public static const objc.SEL sel_arrowCursor;
public static const objc.SEL sel_ascender;
public static const objc.SEL sel_attributedStringValue;
public static const objc.SEL sel_attributedStringWithAttachment_;
public static const objc.SEL sel_attributedSubstringFromRange_;
public static const objc.SEL sel_attributedTitle;
public static const objc.SEL sel_attributesAtIndex_longestEffectiveRange_inRange_;
public static const objc.SEL sel_autorelease;
public static const objc.SEL sel_availableFontFamilies;
public static const objc.SEL sel_availableFonts;
public static const objc.SEL sel_availableMembersOfFontFamily_;
public static const objc.SEL sel_availableTypeFromArray_;
public static const objc.SEL sel_baselineOffsetInLayoutManager_glyphIndex_;
public static const objc.SEL sel_becomeFirstResponder;
public static const objc.SEL sel_becomeKeyWindow;
public static const objc.SEL sel_beginDocument;
public static const objc.SEL sel_beginEditing;
public static const objc.SEL sel_beginPageInRect_atPlacement_;
public static const objc.SEL sel_beginSheetModalForWindow_modalDelegate_didEndSelector_contextInfo_;
public static const objc.SEL sel_beginSheetWithPrintInfo_modalForWindow_delegate_didEndSelector_contextInfo_;
public static const objc.SEL sel_beginSheet_modalForWindow_modalDelegate_didEndSelector_contextInfo_;
public static const objc.SEL sel_bestRepresentationForDevice_;
public static const objc.SEL sel_bezierPath;
public static const objc.SEL sel_bezierPathByFlatteningPath;
public static const objc.SEL sel_bezierPathWithRect_;
public static const objc.SEL sel_bitmapData;
public static const objc.SEL sel_bitmapFormat;
public static const objc.SEL sel_bitsPerPixel;
public static const objc.SEL sel_bitsPerSample;
public static const objc.SEL sel_blackColor;
public static const objc.SEL sel_blueComponent;
public static const objc.SEL sel_boolValue;
public static const objc.SEL sel_borderWidth;
public static const objc.SEL sel_boundingRectForGlyphRange_inTextContainer_;
public static const objc.SEL sel_bounds;
public static const objc.SEL sel_bundleIdentifier;
public static const objc.SEL sel_bundlePath;
public static const objc.SEL sel_bundleWithIdentifier_;
public static const objc.SEL sel_bundleWithPath_;
public static const objc.SEL sel_button;
public static const objc.SEL sel_buttonNumber;
public static const objc.SEL sel_bytes;
public static const objc.SEL sel_bytesPerPlane;
public static const objc.SEL sel_bytesPerRow;
public static const objc.SEL sel_calendarDate;
public static const objc.SEL sel_canBecomeKeyView;
public static const objc.SEL sel_canBecomeKeyWindow;
public static const objc.SEL sel_cancel;
public static const objc.SEL sel_cancelAuthenticationChallenge_;
public static const objc.SEL sel_cancelButtonCell;
public static const objc.SEL sel_cancelTracking;
public static const objc.SEL sel_canDragRowsWithIndexes_atPoint_;
public static const objc.SEL sel_canGoBack;
public static const objc.SEL sel_canGoForward;
public static const objc.SEL sel_canShowMIMEType_;
public static const objc.SEL sel_cascadeTopLeftFromPoint_;
public static const objc.SEL sel_cell;
public static const objc.SEL sel_cellClass;
public static const objc.SEL sel_cellSize;
public static const objc.SEL sel_cellSizeForBounds_;
public static const objc.SEL sel_CGEvent;
public static const objc.SEL sel_changeColor_;
public static const objc.SEL sel_changeFont_;
public static const objc.SEL sel_characterAtIndex_;
public static const objc.SEL sel_characterIndexForGlyphAtIndex_;
public static const objc.SEL sel_characterIndexForInsertionAtPoint_;
public static const objc.SEL sel_characterIndexForPoint_;
public static const objc.SEL sel_characterIsMember_;
public static const objc.SEL sel_characters;
public static const objc.SEL sel_charactersIgnoringModifiers;
public static const objc.SEL sel_charCode;
public static const objc.SEL sel_chooseFilename_;
public static const objc.SEL sel_className;
public static const objc.SEL sel_cleanUpOperation;
public static const objc.SEL sel_clearColor;
public static const objc.SEL sel_clearCurrentContext;
public static const objc.SEL sel_clearDrawable;
public static const objc.SEL sel_clearGLContext;
public static const objc.SEL sel_clickCount;
public static const objc.SEL sel_clickedColumn;
public static const objc.SEL sel_clickedRow;
public static const objc.SEL sel_clientX;
public static const objc.SEL sel_clientY;
public static const objc.SEL sel_close;
public static const objc.SEL sel_closePath;
public static const objc.SEL sel_code;
public static const objc.SEL sel_collapseItem_;
public static const objc.SEL sel_collapseItem_collapseChildren_;
public static const objc.SEL sel_color;
public static const objc.SEL sel_colorAtX_y_;
public static const objc.SEL sel_colorSpaceName;
public static const objc.SEL sel_colorUsingColorSpaceName_;
public static const objc.SEL sel_colorUsingColorSpace_;
public static const objc.SEL sel_colorWithDeviceRed_green_blue_alpha_;
public static const objc.SEL sel_colorWithPatternImage_;
public static const objc.SEL sel_columnAtPoint_;
public static const objc.SEL sel_columnAutoresizingStyle;
public static const objc.SEL sel_columnIndexesInRect_;
public static const objc.SEL sel_columnWithIdentifier_;
public static const objc.SEL sel_comboBoxSelectionDidChange_;
public static const objc.SEL sel_comboBoxWillDismiss_;
public static const objc.SEL sel_compare_;
public static const objc.SEL sel_concat;
public static const objc.SEL sel_conformsToProtocol_;
public static const objc.SEL sel_containerSize;
public static const objc.SEL sel_containsIndex_;
public static const objc.SEL sel_containsObject_;
public static const objc.SEL sel_containsPoint_;
public static const objc.SEL sel_contentRect;
public static const objc.SEL sel_contentRectForFrameRect_;
public static const objc.SEL sel_contentSize;
public static const objc.SEL sel_contentSizeForFrameSize_hasHorizontalScroller_hasVerticalScroller_borderType_;
public static const objc.SEL sel_contentView;
public static const objc.SEL sel_contentViewMargins;
public static const objc.SEL sel_context;
public static const objc.SEL sel_controlBackgroundColor;
public static const objc.SEL sel_controlContentFontOfSize_;
public static const objc.SEL sel_controlDarkShadowColor;
public static const objc.SEL sel_controlHighlightColor;
public static const objc.SEL sel_controlLightHighlightColor;
public static const objc.SEL sel_controlPointBounds;
public static const objc.SEL sel_controlShadowColor;
public static const objc.SEL sel_controlSize;
public static const objc.SEL sel_controlTextColor;
public static const objc.SEL sel_convertBaseToScreen_;
public static const objc.SEL sel_convertFont_toHaveTrait_;
public static const objc.SEL sel_convertPointFromBase_;
public static const objc.SEL sel_convertPointToBase_;
public static const objc.SEL sel_convertPoint_fromView_;
public static const objc.SEL sel_convertPoint_toView_;
public static const objc.SEL sel_convertRectFromBase_;
public static const objc.SEL sel_convertRectToBase_;
public static const objc.SEL sel_convertRect_fromView_;
public static const objc.SEL sel_convertRect_toView_;
public static const objc.SEL sel_convertScreenToBase_;
public static const objc.SEL sel_convertSizeFromBase_;
public static const objc.SEL sel_convertSizeToBase_;
public static const objc.SEL sel_convertSize_fromView_;
public static const objc.SEL sel_convertSize_toView_;
public static const objc.SEL sel_cookies;
public static const objc.SEL sel_cookiesForURL_;
public static const objc.SEL sel_cookiesWithResponseHeaderFields_forURL_;
public static const objc.SEL sel_copiesOnScroll;
public static const objc.SEL sel_copy;
public static const objc.SEL sel_copy_;
public static const objc.SEL sel_count;
public static const objc.SEL sel_createContext;
public static const objc.SEL sel_createFileAtPath_contents_attributes_;
public static const objc.SEL sel_credentialWithUser_password_persistence_;
public static const objc.SEL sel_crosshairCursor;
public static const objc.SEL sel_ctrlKey;
public static const objc.SEL sel_currentContext;
public static const objc.SEL sel_currentCursor;
public static const objc.SEL sel_currentEditor;
public static const objc.SEL sel_currentEvent;
public static const objc.SEL sel_currentInputManager;
public static const objc.SEL sel_currentPoint;
public static const objc.SEL sel_currentRunLoop;
public static const objc.SEL sel_currentThread;
public static const objc.SEL sel_cursorUpdate_;
public static const objc.SEL sel_curveToPoint_controlPoint1_controlPoint2_;
public static const objc.SEL sel_cut_;
public static const objc.SEL sel_dataCell;
public static const objc.SEL sel_dataForType_;
public static const objc.SEL sel_dataSource;
public static const objc.SEL sel_dataWithBytes_length_;
public static const objc.SEL sel_dateValue;
public static const objc.SEL sel_dateWithCalendarFormat_timeZone_;
public static const objc.SEL sel_dateWithTimeIntervalSinceNow_;
public static const objc.SEL sel_dateWithYear_month_day_hour_minute_second_timeZone_;
public static const objc.SEL sel_dayOfMonth;
public static const objc.SEL sel_decimalDigitCharacterSet;
public static const objc.SEL sel_decimalSeparator;
public static const objc.SEL sel_declareTypes_owner_;
public static const objc.SEL sel_defaultBaselineOffsetForFont_;
public static const objc.SEL sel_defaultButtonCell;
public static const objc.SEL sel_defaultCenter;
public static const objc.SEL sel_defaultFlatness;
public static const objc.SEL sel_defaultLineHeightForFont_;
public static const objc.SEL sel_defaultManager;
public static const objc.SEL sel_defaultParagraphStyle;
public static const objc.SEL sel_defaultPrinter;
public static const objc.SEL sel_defaultTimeZone;
public static const objc.SEL sel_delegate;
public static const objc.SEL sel_deleteCookie_;
public static const objc.SEL sel_deliverResult;
public static const objc.SEL sel_deltaX;
public static const objc.SEL sel_deltaY;
public static const objc.SEL sel_deminiaturize_;
public static const objc.SEL sel_depth;
public static const objc.SEL sel_descender;
public static const objc.SEL sel_description;
public static const objc.SEL sel_deselectAll_;
public static const objc.SEL sel_deselectItemAtIndex_;
public static const objc.SEL sel_deselectRow_;
public static const objc.SEL sel_destroyContext;
public static const objc.SEL sel_detail;
public static const objc.SEL sel_deviceDescription;
public static const objc.SEL sel_deviceRGBColorSpace;
public static const objc.SEL sel_dictionary;
public static const objc.SEL sel_dictionaryWithCapacity_;
public static const objc.SEL sel_dictionaryWithObject_forKey_;
public static const objc.SEL sel_disableCursorRects;
public static const objc.SEL sel_disabledControlTextColor;
public static const objc.SEL sel_discardCursorRects;
public static const objc.SEL sel_display;
public static const objc.SEL sel_displayIfNeeded;
public static const objc.SEL sel_displayRectIgnoringOpacity_inContext_;
public static const objc.SEL sel_distantFuture;
public static const objc.SEL sel_doCommandBySelector_;
public static const objc.SEL sel_documentCursor;
public static const objc.SEL sel_documentSource;
public static const objc.SEL sel_documentView;
public static const objc.SEL sel_documentViewShouldHandlePrint;
public static const objc.SEL sel_documentVisibleRect;
public static const objc.SEL sel_DOMDocument;
public static const objc.SEL sel_doubleClickAtIndex_;
public static const objc.SEL sel_doubleValue;
public static const objc.SEL sel_download;
public static const objc.SEL sel_download_decideDestinationWithSuggestedFilename_;
public static const objc.SEL sel_draggedImage;
public static const objc.SEL sel_draggedImageLocation;
public static const objc.SEL sel_draggedImage_beganAt_;
public static const objc.SEL sel_draggedImage_endedAt_operation_;
public static const objc.SEL sel_draggingDestinationWindow;
public static const objc.SEL sel_draggingEnded_;
public static const objc.SEL sel_draggingEntered_;
public static const objc.SEL sel_draggingExited_;
public static const objc.SEL sel_draggingLocation;
public static const objc.SEL sel_draggingPasteboard;
public static const objc.SEL sel_draggingSequenceNumber;
public static const objc.SEL sel_draggingSource;
public static const objc.SEL sel_draggingSourceOperationMask;
public static const objc.SEL sel_draggingSourceOperationMaskForLocal_;
public static const objc.SEL sel_draggingUpdated_;
public static const objc.SEL sel_dragImageForRowsWithIndexes_tableColumns_event_offset_;
public static const objc.SEL sel_dragImage_at_offset_event_pasteboard_source_slideBack_;
public static const objc.SEL sel_dragSelectionWithEvent_offset_slideBack_;
public static const objc.SEL sel_drawAtPoint_;
public static const objc.SEL sel_drawAtPoint_fromRect_operation_fraction_;
public static const objc.SEL sel_drawBackgroundForGlyphRange_atPoint_;
public static const objc.SEL sel_drawFromPoint_toPoint_options_;
public static const objc.SEL sel_drawGlyphsForGlyphRange_atPoint_;
public static const objc.SEL sel_drawImage_withFrame_inView_;
public static const objc.SEL sel_drawingRectForBounds_;
public static const objc.SEL sel_drawInRect_;
public static const objc.SEL sel_drawInRect_angle_;
public static const objc.SEL sel_drawInRect_fromRect_operation_fraction_;
public static const objc.SEL sel_drawInteriorWithFrame_inView_;
public static const objc.SEL sel_drawRect_;
public static const objc.SEL sel_drawSortIndicatorWithFrame_inView_ascending_priority_;
public static const objc.SEL sel_drawStatusBarBackgroundInRect_withHighlight_;
public static const objc.SEL sel_drawWithExpansionFrame_inView_;
public static const objc.SEL sel_elementAtIndex_associatedPoints_;
public static const objc.SEL sel_elementCount;
public static const objc.SEL sel_enableCursorRects;
public static const objc.SEL sel_enableFreedObjectCheck_;
public static const objc.SEL sel_endDocument;
public static const objc.SEL sel_endEditing;
public static const objc.SEL sel_endPage;
public static const objc.SEL sel_endSheet_returnCode_;
public static const objc.SEL sel_enterExitEventWithType_location_modifierFlags_timestamp_windowNumber_context_eventNumber_trackingNumber_userData_;
public static const objc.SEL sel_enumeratorAtPath_;
public static const objc.SEL sel_expandItem_;
public static const objc.SEL sel_expandItem_expandChildren_;
public static const objc.SEL sel_expansionFrameWithFrame_inView_;
public static const objc.SEL sel_familyName;
public static const objc.SEL sel_fieldEditor_forObject_;
public static const objc.SEL sel_fileExistsAtPath_isDirectory_;
public static const objc.SEL sel_filename;
public static const objc.SEL sel_filenames;
public static const objc.SEL sel_fileSystemRepresentation;
public static const objc.SEL sel_fileURLWithPath_;
public static const objc.SEL sel_fill;
public static const objc.SEL sel_fillRect_;
public static const objc.SEL sel_finishLaunching;
public static const objc.SEL sel_firstIndex;
public static const objc.SEL sel_firstRectForCharacterRange_;
public static const objc.SEL sel_firstResponder;
public static const objc.SEL sel_flagsChanged_;
public static const objc.SEL sel_floatValue;
public static const objc.SEL sel_flushBuffer;
public static const objc.SEL sel_flushGraphics;
public static const objc.SEL sel_font;
public static const objc.SEL sel_fontName;
public static const objc.SEL sel_fontWithFamily_traits_weight_size_;
public static const objc.SEL sel_fontWithName_size_;
public static const objc.SEL sel_frame;
public static const objc.SEL sel_frameOfCellAtColumn_row_;
public static const objc.SEL sel_frameOfOutlineCellAtRow_;
public static const objc.SEL sel_frameRectForContentRect_;
public static const objc.SEL sel_frameSizeForContentSize_hasHorizontalScroller_hasVerticalScroller_borderType_;
public static const objc.SEL sel_fullPathForApplication_;
public static const objc.SEL sel_generalPasteboard;
public static const objc.SEL sel_getBitmapDataPlanes_;
public static const objc.SEL sel_getBytes_;
public static const objc.SEL sel_getBytes_length_;
public static const objc.SEL sel_getCharacters_;
public static const objc.SEL sel_getCharacters_range_;
public static const objc.SEL sel_getComponents_;
public static const objc.SEL sel_getCString_maxLength_encoding_;
public static const objc.SEL sel_getGlyphsInRange_glyphs_characterIndexes_glyphInscriptions_elasticBits_bidiLevels_;
public static const objc.SEL sel_getGlyphs_range_;
public static const objc.SEL sel_getIndexes_maxCount_inIndexRange_;
public static const objc.SEL sel_getInfoForFile_application_type_;
public static const objc.SEL sel_getValues_forAttribute_forVirtualScreen_;
public static const objc.SEL sel_glyphIndexForCharacterAtIndex_;
public static const objc.SEL sel_glyphIndexForPoint_inTextContainer_fractionOfDistanceThroughGlyph_;
public static const objc.SEL sel_glyphRangeForCharacterRange_actualCharacterRange_;
public static const objc.SEL sel_glyphRangeForTextContainer_;
public static const objc.SEL sel_goBack;
public static const objc.SEL sel_goForward;
public static const objc.SEL sel_graphicsContext;
public static const objc.SEL sel_graphicsContextWithBitmapImageRep_;
public static const objc.SEL sel_graphicsContextWithGraphicsPort_flipped_;
public static const objc.SEL sel_graphicsContextWithWindow_;
public static const objc.SEL sel_graphicsPort;
public static const objc.SEL sel_greenComponent;
public static const objc.SEL sel_handleEvent_;
public static const objc.SEL sel_handleMouseEvent_;
public static const objc.SEL sel_hasAlpha;
public static const objc.SEL sel_hasMarkedText;
public static const objc.SEL sel_hasPassword;
public static const objc.SEL sel_hasShadow;
public static const objc.SEL sel_headerCell;
public static const objc.SEL sel_headerRectOfColumn_;
public static const objc.SEL sel_headerView;
public static const objc.SEL sel_helpRequested_;
public static const objc.SEL sel_hideOtherApplications_;
public static const objc.SEL sel_hide_;
public static const objc.SEL sel_highlightColorInView_;
public static const objc.SEL sel_highlightColorWithFrame_inView_;
public static const objc.SEL sel_highlightSelectionInClipRect_;
public static const objc.SEL sel_hitPart;
public static const objc.SEL sel_hitTestForEvent_inRect_ofView_;
public static const objc.SEL sel_hitTest_;
public static const objc.SEL sel_host;
public static const objc.SEL sel_hourOfDay;
public static const objc.SEL sel_IBeamCursor;
public static const objc.SEL sel_iconForFileType_;
public static const objc.SEL sel_iconForFile_;
public static const objc.SEL sel_ignore;
public static const objc.SEL sel_ignoreModifierKeysWhileDragging;
public static const objc.SEL sel_image;
public static const objc.SEL sel_imageablePageBounds;
public static const objc.SEL sel_imageInterpolation;
public static const objc.SEL sel_imageNamed_;
public static const objc.SEL sel_imageRectForBounds_;
public static const objc.SEL sel_imageRepWithData_;
public static const objc.SEL sel_increment;
public static const objc.SEL sel_indentationPerLevel;
public static const objc.SEL sel_indexOfItemWithTarget_andAction_;
public static const objc.SEL sel_indexOfObjectIdenticalTo_;
public static const objc.SEL sel_indexOfSelectedItem;
public static const objc.SEL sel_infoDictionary;
public static const objc.SEL sel_init;
public static const objc.SEL sel_initByReferencingFile_;
public static const objc.SEL sel_initListDescriptor;
public static const objc.SEL sel_initWithAttributes_;
public static const objc.SEL sel_initWithBitmapDataPlanes_pixelsWide_pixelsHigh_bitsPerSample_samplesPerPixel_hasAlpha_isPlanar_colorSpaceName_bitmapFormat_bytesPerRow_bitsPerPixel_;
public static const objc.SEL sel_initWithBitmapDataPlanes_pixelsWide_pixelsHigh_bitsPerSample_samplesPerPixel_hasAlpha_isPlanar_colorSpaceName_bytesPerRow_bitsPerPixel_;
public static const objc.SEL sel_initWithCapacity_;
public static const objc.SEL sel_initWithCharacters_length_;
public static const objc.SEL sel_initWithContainerSize_;
public static const objc.SEL sel_initWithContentRect_styleMask_backing_defer_;
public static const objc.SEL sel_initWithContentRect_styleMask_backing_defer_screen_;
public static const objc.SEL sel_initWithContentsOfFile_;
public static const objc.SEL sel_initWithData_;
public static const objc.SEL sel_initWithDictionary_;
public static const objc.SEL sel_initWithFileWrapper_;
public static const objc.SEL sel_initWithFocusedViewRect_;
public static const objc.SEL sel_initWithFormat_shareContext_;
public static const objc.SEL sel_initWithFrame_;
public static const objc.SEL sel_initWithFrame_frameName_groupName_;
public static const objc.SEL sel_initWithFrame_pixelFormat_;
public static const objc.SEL sel_initWithFrame_pullsDown_;
public static const objc.SEL sel_initWithIdentifier_;
public static const objc.SEL sel_initWithImage_hotSpot_;
public static const objc.SEL sel_initWithIndexesInRange_;
public static const objc.SEL sel_initWithIndex_;
public static const objc.SEL sel_initWithItemIdentifier_;
public static const objc.SEL sel_initWithRect_options_owner_userInfo_;
public static const objc.SEL sel_initWithSize_;
public static const objc.SEL sel_initWithStartingColor_endingColor_;
public static const objc.SEL sel_initWithString_;
public static const objc.SEL sel_initWithString_attributes_;
public static const objc.SEL sel_initWithTitle_;
public static const objc.SEL sel_initWithTitle_action_keyEquivalent_;
public static const objc.SEL sel_initWithTransform_;
public static const objc.SEL sel_initWithType_location_;
public static const objc.SEL sel_initWithURL_;
public static const objc.SEL sel_insertItemWithItemIdentifier_atIndex_;
public static const objc.SEL sel_insertItemWithObjectValue_atIndex_;
public static const objc.SEL sel_insertItem_atIndex_;
public static const objc.SEL sel_insertTabViewItem_atIndex_;
public static const objc.SEL sel_insertText_;
public static const objc.SEL sel_integerValue;
public static const objc.SEL sel_intercellSpacing;
public static const objc.SEL sel_interpretKeyEvents_;
public static const objc.SEL sel_intValue;
public static const objc.SEL sel_invalidate;
public static const objc.SEL sel_invalidateShadow;
public static const objc.SEL sel_invert;
public static const objc.SEL sel_isActive;
public static const objc.SEL sel_isDocumentEdited;
public static const objc.SEL sel_isDrawingToScreen;
public static const objc.SEL sel_isEmpty;
public static const objc.SEL sel_isEnabled;
public static const objc.SEL sel_isEqualToString_;
public static const objc.SEL sel_isEqualTo_;
public static const objc.SEL sel_isEqual_;
public static const objc.SEL sel_isFilePackageAtPath_;
public static const objc.SEL sel_isFileURL;
public static const objc.SEL sel_isFlipped;
public static const objc.SEL sel_isHidden;
public static const objc.SEL sel_isHiddenOrHasHiddenAncestor;
public static const objc.SEL sel_isHighlighted;
public static const objc.SEL sel_isItemExpanded_;
public static const objc.SEL sel_isKeyWindow;
public static const objc.SEL sel_isKindOfClass_;
public static const objc.SEL sel_isMainThread;
public static const objc.SEL sel_isMiniaturized;
public static const objc.SEL sel_isOpaque;
public static const objc.SEL sel_isPlanar;
public static const objc.SEL sel_isRowSelected_;
public static const objc.SEL sel_isRunning;
public static const objc.SEL sel_isSessionOnly;
public static const objc.SEL sel_isSheet;
public static const objc.SEL sel_isVisible;
public static const objc.SEL sel_isZoomed;
public static const objc.SEL sel_itemArray;
public static const objc.SEL sel_itemAtIndex_;
public static const objc.SEL sel_itemAtRow_;
public static const objc.SEL sel_itemIdentifier;
public static const objc.SEL sel_itemObjectValueAtIndex_;
public static const objc.SEL sel_itemTitleAtIndex_;
public static const objc.SEL sel_jobDisposition;
public static const objc.SEL sel_keyCode;
public static const objc.SEL sel_keyDown_;
public static const objc.SEL sel_keyEquivalent;
public static const objc.SEL sel_keyEquivalentModifierMask;
public static const objc.SEL sel_keyUp_;
public static const objc.SEL sel_keyWindow;
public static const objc.SEL sel_knobThickness;
public static const objc.SEL sel_lastPathComponent;
public static const objc.SEL sel_layoutManager;
public static const objc.SEL sel_leading;
public static const objc.SEL sel_length;
public static const objc.SEL sel_lengthOfBytesUsingEncoding_;
public static const objc.SEL sel_levelForItem_;
public static const objc.SEL sel_lineFragmentUsedRectForGlyphAtIndex_effectiveRange_;
public static const objc.SEL sel_lineFragmentUsedRectForGlyphAtIndex_effectiveRange_withoutAdditionalLayout_;
public static const objc.SEL sel_lineToPoint_;
public static const objc.SEL sel_linkTextAttributes;
public static const objc.SEL sel_loadHTMLString_baseURL_;
public static const objc.SEL sel_loadNibFile_externalNameTable_withZone_;
public static const objc.SEL sel_loadRequest_;
public static const objc.SEL sel_localizedDescription;
public static const objc.SEL sel_location;
public static const objc.SEL sel_locationForGlyphAtIndex_;
public static const objc.SEL sel_locationInWindow;
public static const objc.SEL sel_lockFocus;
public static const objc.SEL sel_lowercaseString;
public static const objc.SEL sel_mainBundle;
public static const objc.SEL sel_mainFrame;
public static const objc.SEL sel_mainMenu;
public static const objc.SEL sel_mainRunLoop;
public static const objc.SEL sel_mainScreen;
public static const objc.SEL sel_makeCurrentContext;
public static const objc.SEL sel_makeFirstResponder_;
public static const objc.SEL sel_makeKeyAndOrderFront_;
public static const objc.SEL sel_markedRange;
public static const objc.SEL sel_markedTextAttributes;
public static const objc.SEL sel_maximum;
public static const objc.SEL sel_maximumFractionDigits;
public static const objc.SEL sel_maximumIntegerDigits;
public static const objc.SEL sel_maxValue;
public static const objc.SEL sel_menu;
public static const objc.SEL sel_menuDidClose_;
public static const objc.SEL sel_menuForEvent_;
public static const objc.SEL sel_menuNeedsUpdate_;
public static const objc.SEL sel_menuWillOpen_;
public static const objc.SEL sel_menu_willHighlightItem_;
public static const objc.SEL sel_metaKey;
public static const objc.SEL sel_minFrameWidthWithTitle_styleMask_;
public static const objc.SEL sel_miniaturize_;
public static const objc.SEL sel_minimum;
public static const objc.SEL sel_minimumSize;
public static const objc.SEL sel_minSize;
public static const objc.SEL sel_minuteOfHour;
public static const objc.SEL sel_minValue;
public static const objc.SEL sel_modifierFlags;
public static const objc.SEL sel_monthOfYear;
public static const objc.SEL sel_mouseDown_;
public static const objc.SEL sel_mouseDragged_;
public static const objc.SEL sel_mouseEntered_;
public static const objc.SEL sel_mouseExited_;
public static const objc.SEL sel_mouseLocation;
public static const objc.SEL sel_mouseLocationOutsideOfEventStream;
public static const objc.SEL sel_mouseMoved_;
public static const objc.SEL sel_mouseUp_;
public static const objc.SEL sel_moveColumn_toColumn_;
public static const objc.SEL sel_moveToBeginningOfParagraph_;
public static const objc.SEL sel_moveToEndOfParagraph_;
public static const objc.SEL sel_moveToPoint_;
public static const objc.SEL sel_moveUp_;
public static const objc.SEL sel_mutableCopy;
public static const objc.SEL sel_mutableString;
public static const objc.SEL sel_name;
public static const objc.SEL sel_namesOfPromisedFilesDroppedAtDestination_;
public static const objc.SEL sel_nextEventMatchingMask_untilDate_inMode_dequeue_;
public static const objc.SEL sel_nextObject;
public static const objc.SEL sel_nextState;
public static const objc.SEL sel_nextWordFromIndex_forward_;
public static const objc.SEL sel_noResponderFor_;
public static const objc.SEL sel_noteNumberOfRowsChanged;
public static const objc.SEL sel_numberOfColumns;
public static const objc.SEL sel_numberOfComponents;
public static const objc.SEL sel_numberOfGlyphs;
public static const objc.SEL sel_numberOfItems;
public static const objc.SEL sel_numberOfPlanes;
public static const objc.SEL sel_numberOfRows;
public static const objc.SEL sel_numberOfRowsInTableView_;
public static const objc.SEL sel_numberOfSelectedRows;
public static const objc.SEL sel_numberOfVisibleItems;
public static const objc.SEL sel_numberWithBool_;
public static const objc.SEL sel_numberWithDouble_;
public static const objc.SEL sel_numberWithInteger_;
public static const objc.SEL sel_numberWithInt_;
public static const objc.SEL sel_objCType;
public static const objc.SEL sel_object;
public static const objc.SEL sel_objectAtIndex_;
public static const objc.SEL sel_objectEnumerator;
public static const objc.SEL sel_objectForInfoDictionaryKey_;
public static const objc.SEL sel_objectForKey_;
public static const objc.SEL sel_objectValues;
public static const objc.SEL sel_openFile_withApplication_;
public static const objc.SEL sel_openGLContext;
public static const objc.SEL sel_openPanel;
public static const objc.SEL sel_openURLs_withAppBundleIdentifier_options_additionalEventParamDescriptor_launchIdentifiers_;
public static const objc.SEL sel_openURL_;
public static const objc.SEL sel_options;
public static const objc.SEL sel_orderBack_;
public static const objc.SEL sel_orderedWindows;
public static const objc.SEL sel_orderFrontRegardless;
public static const objc.SEL sel_orderFrontStandardAboutPanel_;
public static const objc.SEL sel_orderFront_;
public static const objc.SEL sel_orderOut_;
public static const objc.SEL sel_orderWindow_relativeTo_;
public static const objc.SEL sel_orientation;
public static const objc.SEL sel_otherEventWithType_location_modifierFlags_timestamp_windowNumber_context_subtype_data1_data2_;
public static const objc.SEL sel_otherMouseDown_;
public static const objc.SEL sel_otherMouseDragged_;
public static const objc.SEL sel_otherMouseUp_;
public static const objc.SEL sel_outlineTableColumn;
public static const objc.SEL sel_outlineViewColumnDidMove_;
public static const objc.SEL sel_outlineViewColumnDidResize_;
public static const objc.SEL sel_outlineViewItemDidExpand_;
public static const objc.SEL sel_outlineViewSelectionDidChange_;
public static const objc.SEL sel_outlineView_acceptDrop_item_childIndex_;
public static const objc.SEL sel_outlineView_child_ofItem_;
public static const objc.SEL sel_outlineView_didClickTableColumn_;
public static const objc.SEL sel_outlineView_isItemExpandable_;
public static const objc.SEL sel_outlineView_numberOfChildrenOfItem_;
public static const objc.SEL sel_outlineView_objectValueForTableColumn_byItem_;
public static const objc.SEL sel_outlineView_setObjectValue_forTableColumn_byItem_;
public static const objc.SEL sel_outlineView_shouldCollapseItem_;
public static const objc.SEL sel_outlineView_shouldExpandItem_;
public static const objc.SEL sel_outlineView_validateDrop_proposedItem_proposedChildIndex_;
public static const objc.SEL sel_outlineView_willDisplayCell_forTableColumn_item_;
public static const objc.SEL sel_outlineView_writeItems_toPasteboard_;
public static const objc.SEL sel_owner;
public static const objc.SEL sel_pageDown_;
public static const objc.SEL sel_pageTitle;
public static const objc.SEL sel_pageUp_;
public static const objc.SEL sel_panelConvertFont_;
public static const objc.SEL sel_panel_shouldShowFilename_;
public static const objc.SEL sel_paperSize;
public static const objc.SEL sel_paragraphs;
public static const objc.SEL sel_parentWindow;
public static const objc.SEL sel_password;
public static const objc.SEL sel_pasteboardWithName_;
public static const objc.SEL sel_pasteboard_provideDataForType_;
public static const objc.SEL sel_paste_;
public static const objc.SEL sel_pathExtension;
public static const objc.SEL sel_pathForResource_ofType_;
public static const objc.SEL sel_performDragOperation_;
public static const objc.SEL sel_performSelectorOnMainThread_withObject_waitUntilDone_;
public static const objc.SEL sel_pixelsHigh;
public static const objc.SEL sel_pixelsWide;
public static const objc.SEL sel_pointingHandCursor;
public static const objc.SEL sel_pointSize;
public static const objc.SEL sel_pointValue;
public static const objc.SEL sel_pop;
public static const objc.SEL sel_popUpContextMenu_withEvent_forView_;
public static const objc.SEL sel_popUpStatusItemMenu_;
public static const objc.SEL sel_port;
public static const objc.SEL sel_postEvent_atStart_;
public static const objc.SEL sel_prependTransform_;
public static const objc.SEL sel_preventDefault;
public static const objc.SEL sel_previousFailureCount;
public static const objc.SEL sel_printDocumentView;
public static const objc.SEL sel_printer;
public static const objc.SEL sel_printerNames;
public static const objc.SEL sel_printerWithName_;
public static const objc.SEL sel_printOperationWithPrintInfo_;
public static const objc.SEL sel_printOperationWithView_printInfo_;
public static const objc.SEL sel_printPanel;
public static const objc.SEL sel_propertyListForType_;
public static const objc.SEL sel_proposedCredential;
public static const objc.SEL sel_protectionSpace;
public static const objc.SEL sel_push;
public static const objc.SEL sel_rangeValue;
public static const objc.SEL sel_realm;
public static const objc.SEL sel_recentSearches;
public static const objc.SEL sel_rectArrayForCharacterRange_withinSelectedCharacterRange_inTextContainer_rectCount_;
public static const objc.SEL sel_rectOfColumn_;
public static const objc.SEL sel_rectOfRow_;
public static const objc.SEL sel_rectValue;
public static const objc.SEL sel_redComponent;
public static const objc.SEL sel_reflectScrolledClipView_;
public static const objc.SEL sel_registerForDraggedTypes_;
public static const objc.SEL sel_release;
public static const objc.SEL sel_reloadData;
public static const objc.SEL sel_reloadItem_;
public static const objc.SEL sel_reloadItem_reloadChildren_;
public static const objc.SEL sel_reload_;
public static const objc.SEL sel_removeAllItems;
public static const objc.SEL sel_removeAllPoints;
public static const objc.SEL sel_removeAttribute_range_;
public static const objc.SEL sel_removeChildWindow_;
public static const objc.SEL sel_removeFromSuperview;
public static const objc.SEL sel_removeItemAtIndex_;
public static const objc.SEL sel_removeItemAtPath_error_;
public static const objc.SEL sel_removeItem_;
public static const objc.SEL sel_removeLastObject;
public static const objc.SEL sel_removeObjectAtIndex_;
public static const objc.SEL sel_removeObjectForKey_;
public static const objc.SEL sel_removeObjectIdenticalTo_;
public static const objc.SEL sel_removeObject_;
public static const objc.SEL sel_removeObserver_;
public static const objc.SEL sel_removeRepresentation_;
public static const objc.SEL sel_removeStatusItem_;
public static const objc.SEL sel_removeTableColumn_;
public static const objc.SEL sel_removeTabViewItem_;
public static const objc.SEL sel_removeTemporaryAttribute_forCharacterRange_;
public static const objc.SEL sel_removeTrackingArea_;
public static const objc.SEL sel_replaceCharactersInRange_withString_;
public static const objc.SEL sel_representation;
public static const objc.SEL sel_representations;
public static const objc.SEL sel_request;
public static const objc.SEL sel_requestWithURL_;
public static const objc.SEL sel_resetCursorRects;
public static const objc.SEL sel_resignFirstResponder;
public static const objc.SEL sel_resizeDownCursor;
public static const objc.SEL sel_resizeLeftCursor;
public static const objc.SEL sel_resizeLeftRightCursor;
public static const objc.SEL sel_resizeRightCursor;
public static const objc.SEL sel_resizeUpCursor;
public static const objc.SEL sel_resizeUpDownCursor;
public static const objc.SEL sel_resizingMask;
public static const objc.SEL sel_resourcePath;
public static const objc.SEL sel_respondsToSelector_;
public static const objc.SEL sel_restoreGraphicsState;
public static const objc.SEL sel_retain;
public static const objc.SEL sel_retainCount;
public static const objc.SEL sel_rightMouseDown_;
public static const objc.SEL sel_rightMouseDragged_;
public static const objc.SEL sel_rightMouseUp_;
public static const objc.SEL sel_rotateByDegrees_;
public static const objc.SEL sel_rowAtPoint_;
public static const objc.SEL sel_rowForItem_;
public static const objc.SEL sel_rowHeight;
public static const objc.SEL sel_rowsInRect_;
public static const objc.SEL sel_run;
public static const objc.SEL sel_runModal;
public static const objc.SEL sel_runModalForDirectory_file_;
public static const objc.SEL sel_runModalForWindow_;
public static const objc.SEL sel_runModalWithPrintInfo_;
public static const objc.SEL sel_runMode_beforeDate_;
public static const objc.SEL sel_runOperation;
public static const objc.SEL sel_samplesPerPixel;
public static const objc.SEL sel_saveGraphicsState;
public static const objc.SEL sel_savePanel;
public static const objc.SEL sel_scaleXBy_yBy_;
public static const objc.SEL sel_scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_;
public static const objc.SEL sel_screen;
public static const objc.SEL sel_screens;
public static const objc.SEL sel_scrollColumnToVisible_;
public static const objc.SEL sel_scrollerWidth;
public static const objc.SEL sel_scrollerWidthForControlSize_;
public static const objc.SEL sel_scrollPoint_;
public static const objc.SEL sel_scrollRangeToVisible_;
public static const objc.SEL sel_scrollRectToVisible_;
public static const objc.SEL sel_scrollRowToVisible_;
public static const objc.SEL sel_scrollToPoint_;
public static const objc.SEL sel_scrollWheel_;
public static const objc.SEL sel_searchButtonCell;
public static const objc.SEL sel_searchTextRectForBounds_;
public static const objc.SEL sel_secondarySelectedControlColor;
public static const objc.SEL sel_secondOfMinute;
public static const objc.SEL sel_selectAll_;
public static const objc.SEL sel_selectedControlColor;
public static const objc.SEL sel_selectedControlTextColor;
public static const objc.SEL sel_selectedRange;
public static const objc.SEL sel_selectedRow;
public static const objc.SEL sel_selectedRowIndexes;
public static const objc.SEL sel_selectedTabViewItem;
public static const objc.SEL sel_selectedTextBackgroundColor;
public static const objc.SEL sel_selectedTextColor;
public static const objc.SEL sel_selectItemAtIndex_;
public static const objc.SEL sel_selectItem_;
public static const objc.SEL sel_selectRowIndexes_byExtendingSelection_;
public static const objc.SEL sel_selectRow_byExtendingSelection_;
public static const objc.SEL sel_selectTabViewItemAtIndex_;
public static const objc.SEL sel_selectText_;
public static const objc.SEL sel_sendAction_to_;
public static const objc.SEL sel_sender;
public static const objc.SEL sel_sendEvent_;
public static const objc.SEL sel_separatorItem;
public static const objc.SEL sel_set;
public static const objc.SEL sel_setAcceptsMouseMovedEvents_;
public static const objc.SEL sel_setAccessoryView_;
public static const objc.SEL sel_setAction_;
public static const objc.SEL sel_setAlertStyle_;
public static const objc.SEL sel_setAlignment_;
public static const objc.SEL sel_setAllowsColumnReordering_;
public static const objc.SEL sel_setAllowsFloats_;
public static const objc.SEL sel_setAllowsMixedState_;
public static const objc.SEL sel_setAllowsMultipleSelection_;
public static const objc.SEL sel_setAllowsUserCustomization_;
public static const objc.SEL sel_setAlphaValue_;
public static const objc.SEL sel_setAlpha_;
public static const objc.SEL sel_setApplicationIconImage_;
public static const objc.SEL sel_setApplicationNameForUserAgent_;
public static const objc.SEL sel_setAttributedStringValue_;
public static const objc.SEL sel_setAttributedString_;
public static const objc.SEL sel_setAttributedTitle_;
public static const objc.SEL sel_setAutoenablesItems_;
public static const objc.SEL sel_setAutohidesScrollers_;
public static const objc.SEL sel_setAutoresizesOutlineColumn_;
public static const objc.SEL sel_setAutoresizesSubviews_;
public static const objc.SEL sel_setAutoresizingMask_;
public static const objc.SEL sel_setAutosaveExpandedItems_;
public static const objc.SEL sel_setBackgroundColor_;
public static const objc.SEL sel_setBackgroundLayoutEnabled_;
public static const objc.SEL sel_setBezelStyle_;
public static const objc.SEL sel_setBordered_;
public static const objc.SEL sel_setBorderType_;
public static const objc.SEL sel_setBorderWidth_;
public static const objc.SEL sel_setBoxType_;
public static const objc.SEL sel_setButtonType_;
public static const objc.SEL sel_setCacheMode_;
public static const objc.SEL sel_setCachePolicy_;
public static const objc.SEL sel_setCancelButtonCell_;
public static const objc.SEL sel_setCanChooseDirectories_;
public static const objc.SEL sel_setCanChooseFiles_;
public static const objc.SEL sel_setCanCreateDirectories_;
public static const objc.SEL sel_setCellClass_;
public static const objc.SEL sel_setCell_;
public static const objc.SEL sel_setClip;
public static const objc.SEL sel_setColor_;
public static const objc.SEL sel_setColumnAutoresizingStyle_;
public static const objc.SEL sel_setCompositingOperation_;
public static const objc.SEL sel_setContainerSize_;
public static const objc.SEL sel_setContentViewMargins_;
public static const objc.SEL sel_setContentView_;
public static const objc.SEL sel_setControlSize_;
public static const objc.SEL sel_setCookie_;
public static const objc.SEL sel_setCopiesOnScroll_;
public static const objc.SEL sel_setCurrentContext_;
public static const objc.SEL sel_setCurrentOperation_;
public static const objc.SEL sel_setDataCell_;
public static const objc.SEL sel_setDataSource_;
public static const objc.SEL sel_setData_forType_;
public static const objc.SEL sel_setDatePickerElements_;
public static const objc.SEL sel_setDatePickerStyle_;
public static const objc.SEL sel_setDateValue_;
public static const objc.SEL sel_setDefaultButtonCell_;
public static const objc.SEL sel_setDefaultFlatness_;
public static const objc.SEL sel_setDefaultParagraphStyle_;
public static const objc.SEL sel_setDefaultTabInterval_;
public static const objc.SEL sel_setDelegate_;
public static const objc.SEL sel_setDestination_allowOverwrite_;
public static const objc.SEL sel_setDictionary_;
public static const objc.SEL sel_setDirectory_;
public static const objc.SEL sel_setDisplayMode_;
public static const objc.SEL sel_setDocumentCursor_;
public static const objc.SEL sel_setDocumentEdited_;
public static const objc.SEL sel_setDocumentView_;
public static const objc.SEL sel_setDoubleAction_;
public static const objc.SEL sel_setDoubleValue_;
public static const objc.SEL sel_setDownloadDelegate_;
public static const objc.SEL sel_setDrawsBackground_;
public static const objc.SEL sel_setDropItem_dropChildIndex_;
public static const objc.SEL sel_setDropRow_dropOperation_;
public static const objc.SEL sel_setEditable_;
public static const objc.SEL sel_setEnabled_;
public static const objc.SEL sel_setEnabled_forSegment_;
public static const objc.SEL sel_setFill;
public static const objc.SEL sel_setFillColor_;
public static const objc.SEL sel_setFireDate_;
public static const objc.SEL sel_setFirstLineHeadIndent_;
public static const objc.SEL sel_setFloatValue_knobProportion_;
public static const objc.SEL sel_setFocusRingType_;
public static const objc.SEL sel_setFont_;
public static const objc.SEL sel_setFormatter_;
public static const objc.SEL sel_setFrameLoadDelegate_;
public static const objc.SEL sel_setFrameOrigin_;
public static const objc.SEL sel_setFrameSize_;
public static const objc.SEL sel_setFrame_;
public static const objc.SEL sel_setFrame_display_;
public static const objc.SEL sel_setFrame_display_animate_;
public static const objc.SEL sel_setHasHorizontalScroller_;
public static const objc.SEL sel_setHasShadow_;
public static const objc.SEL sel_setHasVerticalScroller_;
public static const objc.SEL sel_setHeaderCell_;
public static const objc.SEL sel_setHeaderView_;
public static const objc.SEL sel_setHiddenUntilMouseMoves_;
public static const objc.SEL sel_setHidden_;
public static const objc.SEL sel_setHighlightedTableColumn_;
public static const objc.SEL sel_setHighlighted_;
public static const objc.SEL sel_setHighlightMode_;
public static const objc.SEL sel_setHorizontallyResizable_;
public static const objc.SEL sel_setHorizontalScroller_;
public static const objc.SEL sel_setIcon_;
public static const objc.SEL sel_setIdentifier_;
public static const objc.SEL sel_setImageAlignment_;
public static const objc.SEL sel_setImageInterpolation_;
public static const objc.SEL sel_setImagePosition_;
public static const objc.SEL sel_setImageScaling_;
public static const objc.SEL sel_setImage_;
public static const objc.SEL sel_setImage_forSegment_;
public static const objc.SEL sel_setIncrement_;
public static const objc.SEL sel_setIndentationPerLevel_;
public static const objc.SEL sel_setIndeterminate_;
public static const objc.SEL sel_setIndicatorImage_inTableColumn_;
public static const objc.SEL sel_setIntercellSpacing_;
public static const objc.SEL sel_setJavaEnabled_;
public static const objc.SEL sel_setJavaScriptEnabled_;
public static const objc.SEL sel_setJobDisposition_;
public static const objc.SEL sel_setJobTitle_;
public static const objc.SEL sel_setKeyEquivalentModifierMask_;
public static const objc.SEL sel_setKeyEquivalent_;
public static const objc.SEL sel_setLabel_;
public static const objc.SEL sel_setLabel_forSegment_;
public static const objc.SEL sel_setLeaf_;
public static const objc.SEL sel_setLength_;
public static const objc.SEL sel_setLevel_;
public static const objc.SEL sel_setLineBreakMode_;
public static const objc.SEL sel_setLineCapStyle_;
public static const objc.SEL sel_setLineDash_count_phase_;
public static const objc.SEL sel_setLineFragmentPadding_;
public static const objc.SEL sel_setLineFragmentRect_forGlyphRange_usedRect_;
public static const objc.SEL sel_setLineJoinStyle_;
public static const objc.SEL sel_setLineSpacing_;
public static const objc.SEL sel_setLineWidth_;
public static const objc.SEL sel_setLinkTextAttributes_;
public static const objc.SEL sel_setMainMenu_;
public static const objc.SEL sel_setMarkedText_selectedRange_;
public static const objc.SEL sel_setMaximumFractionDigits_;
public static const objc.SEL sel_setMaximumIntegerDigits_;
public static const objc.SEL sel_setMaximum_;
public static const objc.SEL sel_setMaxSize_;
public static const objc.SEL sel_setMaxValue_;
public static const objc.SEL sel_setMenu_;
public static const objc.SEL sel_setMenu_forSegment_;
public static const objc.SEL sel_setMessageText_;
public static const objc.SEL sel_setMessage_;
public static const objc.SEL sel_setMinimumFractionDigits_;
public static const objc.SEL sel_setMinimumIntegerDigits_;
public static const objc.SEL sel_setMinimum_;
public static const objc.SEL sel_setMinSize_;
public static const objc.SEL sel_setMinValue_;
public static const objc.SEL sel_setMinWidth_;
public static const objc.SEL sel_setMiterLimit_;
public static const objc.SEL sel_setNeedsDisplayInRect_;
public static const objc.SEL sel_setNeedsDisplay_;
public static const objc.SEL sel_setNumberOfVisibleItems_;
public static const objc.SEL sel_setNumberStyle_;
public static const objc.SEL sel_setObjectValue_;
public static const objc.SEL sel_setObject_forKey_;
public static const objc.SEL sel_setOnMouseEntered_;
public static const objc.SEL sel_setOpaque_;
public static const objc.SEL sel_setOptions_;
public static const objc.SEL sel_setOrientation_;
public static const objc.SEL sel_setOutlineTableColumn_;
public static const objc.SEL sel_setPaletteLabel_;
public static const objc.SEL sel_setPanelFont_isMultiple_;
public static const objc.SEL sel_setPartialStringValidationEnabled_;
public static const objc.SEL sel_setPatternPhase_;
public static const objc.SEL sel_setPixelFormat_;
public static const objc.SEL sel_setPlaceholderString_;
public static const objc.SEL sel_setPolicyDelegate_;
public static const objc.SEL sel_setPreferences_;
public static const objc.SEL sel_setPrinter_;
public static const objc.SEL sel_setPropertyList_forType_;
public static const objc.SEL sel_setPullsDown_;
public static const objc.SEL sel_setReleasedWhenClosed_;
public static const objc.SEL sel_setResizingMask_;
public static const objc.SEL sel_setResourceLoadDelegate_;
public static const objc.SEL sel_setRichText_;
public static const objc.SEL sel_setRowHeight_;
public static const objc.SEL sel_setScrollable_;
public static const objc.SEL sel_setSearchButtonCell_;
public static const objc.SEL sel_setSegmentCount_;
public static const objc.SEL sel_setSegmentStyle_;
public static const objc.SEL sel_setSelectable_;
public static const objc.SEL sel_setSelectedRange_;
public static const objc.SEL sel_setSelectedSegment_;
public static const objc.SEL sel_setSelected_forSegment_;
public static const objc.SEL sel_setServicesMenu_;
public static const objc.SEL sel_setShouldAntialias_;
public static const objc.SEL sel_setShowsPrintPanel_;
public static const objc.SEL sel_setShowsProgressPanel_;
public static const objc.SEL sel_setShowsResizeIndicator_;
public static const objc.SEL sel_setShowsToolbarButton_;
public static const objc.SEL sel_setSize_;
public static const objc.SEL sel_setState_;
public static const objc.SEL sel_setStringValue_;
public static const objc.SEL sel_setString_;
public static const objc.SEL sel_setString_forType_;
public static const objc.SEL sel_setStroke;
public static const objc.SEL sel_setSubmenu_;
public static const objc.SEL sel_setSubmenu_forItem_;
public static const objc.SEL sel_setTabStops_;
public static const objc.SEL sel_setTabViewType_;
public static const objc.SEL sel_setTag_forSegment_;
public static const objc.SEL sel_setTarget_;
public static const objc.SEL sel_setTextColor_;
public static const objc.SEL sel_setTextStorage_;
public static const objc.SEL sel_setTitleFont_;
public static const objc.SEL sel_setTitlePosition_;
public static const objc.SEL sel_setTitle_;
public static const objc.SEL sel_setToolbar_;
public static const objc.SEL sel_setToolTip_;
public static const objc.SEL sel_setToolTip_forSegment_;
public static const objc.SEL sel_setTrackingMode_;
public static const objc.SEL sel_setTransformStruct_;
public static const objc.SEL sel_setUIDelegate_;
public static const objc.SEL sel_setUpPrintOperationDefaultValues;
public static const objc.SEL sel_setURL_;
public static const objc.SEL sel_setUsesAlternatingRowBackgroundColors_;
public static const objc.SEL sel_setUsesThreadedAnimation_;
public static const objc.SEL sel_setValueWraps_;
public static const objc.SEL sel_setValue_forKey_;
public static const objc.SEL sel_setVerticalScroller_;
public static const objc.SEL sel_setView_;
public static const objc.SEL sel_setVisible_;
public static const objc.SEL sel_setWidthTracksTextView_;
public static const objc.SEL sel_setWidth_;
public static const objc.SEL sel_setWidth_forSegment_;
public static const objc.SEL sel_setWindingRule_;
public static const objc.SEL sel_setWorksWhenModal_;
public static const objc.SEL sel_setWraps_;
public static const objc.SEL sel_sharedApplication;
public static const objc.SEL sel_sharedColorPanel;
public static const objc.SEL sel_sharedFontManager;
public static const objc.SEL sel_sharedFontPanel;
public static const objc.SEL sel_sharedHTTPCookieStorage;
public static const objc.SEL sel_sharedPrintInfo;
public static const objc.SEL sel_sharedWorkspace;
public static const objc.SEL sel_shiftKey;
public static const objc.SEL sel_shouldAntialias;
public static const objc.SEL sel_shouldChangeTextInRange_replacementString_;
public static const objc.SEL sel_shouldDelayWindowOrderingForEvent_;
public static const objc.SEL sel_size;
public static const objc.SEL sel_sizeToFit;
public static const objc.SEL sel_sizeValue;
public static const objc.SEL sel_skipDescendents;
public static const objc.SEL sel_smallSystemFontSize;
public static const objc.SEL sel_sortIndicatorRectForBounds_;
public static const objc.SEL sel_standardPreferences;
public static const objc.SEL sel_standardWindowButton_;
public static const objc.SEL sel_startAnimation_;
public static const objc.SEL sel_state;
public static const objc.SEL sel_statusItemWithLength_;
public static const objc.SEL sel_stopAnimation_;
public static const objc.SEL sel_stopLoading_;
public static const objc.SEL sel_stop_;
public static const objc.SEL sel_string;
public static const objc.SEL sel_stringByAddingPercentEscapesUsingEncoding_;
public static const objc.SEL sel_stringByAppendingPathComponent_;
public static const objc.SEL sel_stringByAppendingString_;
public static const objc.SEL sel_stringByDeletingLastPathComponent;
public static const objc.SEL sel_stringByDeletingPathExtension;
public static const objc.SEL sel_stringByEvaluatingJavaScriptFromString_;
public static const objc.SEL sel_stringByReplacingOccurrencesOfString_withString_;
public static const objc.SEL sel_stringForObjectValue_;
public static const objc.SEL sel_stringForType_;
public static const objc.SEL sel_stringValue;
public static const objc.SEL sel_stringWithCharacters_length_;
public static const objc.SEL sel_stringWithFormat_;
public static const objc.SEL sel_stringWithUTF8String_;
public static const objc.SEL sel_stroke;
public static const objc.SEL sel_strokeRect_;
public static const objc.SEL sel_styleMask;
public static const objc.SEL sel_submenu;
public static const objc.SEL sel_substringWithRange_;
public static const objc.SEL sel_subviews;
public static const objc.SEL sel_superclass;
public static const objc.SEL sel_superview;
public static const objc.SEL sel_systemFontOfSize_;
public static const objc.SEL sel_systemFontSize;
public static const objc.SEL sel_systemFontSizeForControlSize_;
public static const objc.SEL sel_systemStatusBar;
public static const objc.SEL sel_systemVersion;
public static const objc.SEL sel_tableColumns;
public static const objc.SEL sel_tableViewColumnDidMove_;
public static const objc.SEL sel_tableViewColumnDidResize_;
public static const objc.SEL sel_tableViewSelectionDidChange_;
public static const objc.SEL sel_tableView_acceptDrop_row_dropOperation_;
public static const objc.SEL sel_tableView_didClickTableColumn_;
public static const objc.SEL sel_tableView_objectValueForTableColumn_row_;
public static const objc.SEL sel_tableView_setObjectValue_forTableColumn_row_;
public static const objc.SEL sel_tableView_shouldEditTableColumn_row_;
public static const objc.SEL sel_tableView_validateDrop_proposedRow_proposedDropOperation_;
public static const objc.SEL sel_tableView_willDisplayCell_forTableColumn_row_;
public static const objc.SEL sel_tableView_writeRowsWithIndexes_toPasteboard_;
public static const objc.SEL sel_tabStops;
public static const objc.SEL sel_tabStopType;
public static const objc.SEL sel_tabViewItemAtPoint_;
public static const objc.SEL sel_tabView_didSelectTabViewItem_;
public static const objc.SEL sel_tabView_shouldSelectTabViewItem_;
public static const objc.SEL sel_tabView_willSelectTabViewItem_;
public static const objc.SEL sel_target;
public static const objc.SEL sel_terminate_;
public static const objc.SEL sel_textBackgroundColor;
public static const objc.SEL sel_textColor;
public static const objc.SEL sel_textContainer;
public static const objc.SEL sel_textDidChange_;
public static const objc.SEL sel_textDidEndEditing_;
public static const objc.SEL sel_textStorage;
public static const objc.SEL sel_textViewDidChangeSelection_;
public static const objc.SEL sel_textView_clickedOnLink_atIndex_;
public static const objc.SEL sel_textView_willChangeSelectionFromCharacterRange_toCharacterRange_;
public static const objc.SEL sel_threadDictionary;
public static const objc.SEL sel_TIFFRepresentation;
public static const objc.SEL sel_tile;
public static const objc.SEL sel_timestamp;
public static const objc.SEL sel_timeZone;
public static const objc.SEL sel_title;
public static const objc.SEL sel_titleCell;
public static const objc.SEL sel_titleFont;
public static const objc.SEL sel_titleOfSelectedItem;
public static const objc.SEL sel_titleRectForBounds_;
public static const objc.SEL sel_toggleToolbarShown_;
public static const objc.SEL sel_toolbar;
public static const objc.SEL sel_toolbarAllowedItemIdentifiers_;
public static const objc.SEL sel_toolbarDefaultItemIdentifiers_;
public static const objc.SEL sel_toolbarDidRemoveItem_;
public static const objc.SEL sel_toolbarSelectableItemIdentifiers_;
public static const objc.SEL sel_toolbarWillAddItem_;
public static const objc.SEL sel_toolbar_itemForItemIdentifier_willBeInsertedIntoToolbar_;
public static const objc.SEL sel_trackingAreas;
public static const objc.SEL sel_traitsOfFont_;
public static const objc.SEL sel_transform;
public static const objc.SEL sel_transformPoint_;
public static const objc.SEL sel_transformSize_;
public static const objc.SEL sel_transformStruct;
public static const objc.SEL sel_transformUsingAffineTransform_;
public static const objc.SEL sel_translateXBy_yBy_;
public static const objc.SEL sel_type;
public static const objc.SEL sel_types;
public static const objc.SEL sel_typesetter;
public static const objc.SEL sel_unarchiveObjectWithData_;
public static const objc.SEL sel_undefined;
public static const objc.SEL sel_unhideAllApplications_;
public static const objc.SEL sel_unlockFocus;
public static const objc.SEL sel_unmarkText;
public static const objc.SEL sel_unregisterDraggedTypes;
public static const objc.SEL sel_update;
public static const objc.SEL sel_updateTrackingAreas;
public static const objc.SEL sel_URL;
public static const objc.SEL sel_URLFromPasteboard_;
public static const objc.SEL sel_URLWithString_;
public static const objc.SEL sel_use;
public static const objc.SEL sel_useCredential_forAuthenticationChallenge_;
public static const objc.SEL sel_usedRectForTextContainer_;
public static const objc.SEL sel_user;
public static const objc.SEL sel_userInfo;
public static const objc.SEL sel_usesAlternatingRowBackgroundColors;
public static const objc.SEL sel_UTF8String;
public static const objc.SEL sel_validateVisibleColumns;
public static const objc.SEL sel_validAttributesForMarkedText;
public static const objc.SEL sel_value;
public static const objc.SEL sel_valueForKey_;
public static const objc.SEL sel_valueWithPoint_;
public static const objc.SEL sel_valueWithRange_;
public static const objc.SEL sel_valueWithRect_;
public static const objc.SEL sel_valueWithSize_;
public static const objc.SEL sel_view;
public static const objc.SEL sel_viewDidMoveToWindow;
public static const objc.SEL sel_view_stringForToolTip_point_userData_;
public static const objc.SEL sel_visibleFrame;
public static const objc.SEL sel_visibleRect;
public static const objc.SEL sel_wantsPeriodicDraggingUpdates;
public static const objc.SEL sel_wantsToHandleMouseEvents;
public static const objc.SEL sel_webFrame;
public static const objc.SEL sel_webScriptValueAtIndex_;
public static const objc.SEL sel_webViewClose_;
public static const objc.SEL sel_webViewFocus_;
public static const objc.SEL sel_webViewShow_;
public static const objc.SEL sel_webViewUnfocus_;
public static const objc.SEL sel_webView_contextMenuItemsForElement_defaultMenuItems_;
public static const objc.SEL sel_webView_createWebViewWithRequest_;
public static const objc.SEL sel_webView_decidePolicyForMIMEType_request_frame_decisionListener_;
public static const objc.SEL sel_webView_decidePolicyForNavigationAction_request_frame_decisionListener_;
public static const objc.SEL sel_webView_decidePolicyForNewWindowAction_request_newFrameName_decisionListener_;
public static const objc.SEL sel_webView_didChangeLocationWithinPageForFrame_;
public static const objc.SEL sel_webView_didCommitLoadForFrame_;
public static const objc.SEL sel_webView_didFailProvisionalLoadWithError_forFrame_;
public static const objc.SEL sel_webView_didFinishLoadForFrame_;
public static const objc.SEL sel_webView_didReceiveTitle_forFrame_;
public static const objc.SEL sel_webView_didStartProvisionalLoadForFrame_;
public static const objc.SEL sel_webView_identifierForInitialRequest_fromDataSource_;
public static const objc.SEL sel_webView_mouseDidMoveOverElement_modifierFlags_;
public static const objc.SEL sel_webView_printFrameView_;
public static const objc.SEL sel_webView_resource_didFailLoadingWithError_fromDataSource_;
public static const objc.SEL sel_webView_resource_didFinishLoadingFromDataSource_;
public static const objc.SEL sel_webView_resource_didReceiveAuthenticationChallenge_fromDataSource_;
public static const objc.SEL sel_webView_resource_willSendRequest_redirectResponse_fromDataSource_;
public static const objc.SEL sel_webView_runJavaScriptAlertPanelWithMessage_;
public static const objc.SEL sel_webView_runJavaScriptConfirmPanelWithMessage_;
public static const objc.SEL sel_webView_runOpenPanelForFileButtonWithResultListener_;
public static const objc.SEL sel_webView_setFrame_;
public static const objc.SEL sel_webView_setResizable_;
public static const objc.SEL sel_webView_setStatusBarVisible_;
public static const objc.SEL sel_webView_setStatusText_;
public static const objc.SEL sel_webView_setToolbarsVisible_;
public static const objc.SEL sel_webView_unableToImplementPolicyWithError_frame_;
public static const objc.SEL sel_webView_windowScriptObjectAvailable_;
public static const objc.SEL sel_weightOfFont_;
public static const objc.SEL sel_wheelDelta;
public static const objc.SEL sel_width;
public static const objc.SEL sel_window;
public static const objc.SEL sel_windowBackgroundColor;
public static const objc.SEL sel_windowDidBecomeKey_;
public static const objc.SEL sel_windowDidMove_;
public static const objc.SEL sel_windowDidResignKey_;
public static const objc.SEL sel_windowDidResize_;
public static const objc.SEL sel_windowFrameColor;
public static const objc.SEL sel_windowFrameTextColor;
public static const objc.SEL sel_windowNumber;
public static const objc.SEL sel_windows;
public static const objc.SEL sel_windowShouldClose_;
public static const objc.SEL sel_windowWillClose_;
public static const objc.SEL sel_worksWhenModal;
public static const objc.SEL sel_wraps;
public static const objc.SEL sel_writeToPasteboard_;
public static const objc.SEL sel_yearOfCommonEra;
public static const objc.SEL sel_zoom_;

/** Constants */
public static const int NSAlertFirstButtonReturn = 1000;
public static const int NSAlertSecondButtonReturn = 1001;
public static const int NSAlertThirdButtonReturn = 1002;
public static const int NSAlphaFirstBitmapFormat = 1;
public static const int NSAlphaNonpremultipliedBitmapFormat = 2;
public static const int NSAlternateKeyMask = 524288;
public static const int NSApplicationDefined = 15;
public static const int NSAtTop = 2;
alias Cocoa.NSBackingStoreType.NSBackingStoreBuffered NSBackingStoreBuffered;
public static const int NSBackspaceCharacter = 8;
public static const int NSBevelLineJoinStyle = 2;
public static const int NSBezelBorder = 2;
public static const int NSBoldFontMask = 2;
public static const int NSBorderlessWindowMask = 0;
public static const int NSBottomTabsBezelBorder = 2;
public static const int NSBoxCustom = 4;
public static const int NSBoxSeparator = 2;
public static const int NSButtLineCapStyle = 0;
public static const int NSCancelButton = 0;
public static const int NSCarriageReturnCharacter = 13;
public static const int NSCenterTextAlignment = 2;
public static const int NSClockAndCalendarDatePickerStyle = 1;
public static const int NSClosableWindowMask = 2;
public static const int NSClosePathBezierPathElement = 3;
public static const int NSCommandKeyMask = 1048576;
public static const int NSCompositeClear = 0;
public static const int NSCompositeCopy = 1;
public static const int NSCompositeSourceOver = 2;
public static const int NSCompositeXOR = 10;
public static const int NSControlKeyMask = 262144;
public static const int NSCriticalAlertStyle = 2;
public static const int NSCurveToBezierPathElement = 2;
public static const int NSDeleteCharacter = 127;
public static const int NSDeviceIndependentModifierFlagsMask = -65536;
public static const int NSDragOperationCopy = 1;
public static const int NSDragOperationDelete = 32;
public static const int NSDragOperationEvery = -1;
public static const int NSDragOperationLink = 2;
public static const int NSDragOperationMove = 16;
public static const int NSDragOperationNone = 0;
public static const int NSEnterCharacter = 3;
public static const int NSEvenOddWindingRule = 1;
public static const int NSFileHandlingPanelOKButton = 1;
public static const int NSFlagsChanged = 12;
public static const int NSFocusRingTypeNone = 1;
public static const int NSHelpFunctionKey = 63302;
public static const int NSHelpKeyMask = 4194304;
public static const int NSHourMinuteDatePickerElementFlag = 12;
public static const int NSHourMinuteSecondDatePickerElementFlag = 14;
public static const int NSImageAbove = 5;
public static const int NSImageAlignCenter = 0;
public static const int NSImageAlignLeft = 4;
public static const int NSImageAlignRight = 8;
public static const int NSImageCacheNever = 3;
public static const int NSImageInterpolationDefault = 0;
public static const int NSImageInterpolationHigh = 3;
public static const int NSImageInterpolationLow = 2;
public static const int NSImageInterpolationNone = 1;
public static const int NSImageLeft = 2;
public static const int NSImageOnly = 1;
public static const int NSImageOverlaps = 6;
public static const int NSInformationalAlertStyle = 1;
public static const int NSItalicFontMask = 1;
public static const int NSJustifiedTextAlignment = 3;
public static const int NSKeyDown = 10;
public static const int NSKeyUp = 11;
public static const int NSLandscapeOrientation = 1;
public static const int NSLeftMouseDown = 1;
public static const int NSLeftMouseDownMask = 2;
public static const int NSLeftMouseDragged = 6;
public static const int NSLeftMouseDraggedMask = 64;
public static const int NSLeftMouseUp = 2;
public static const int NSLeftMouseUpMask = 4;
public static const int NSLeftTabStopType = 0;
public static const int NSLeftTextAlignment = 0;
public static const int NSLineBreakByClipping = 2;
public static const int NSLineBreakByWordWrapping = 0;
public static const int NSLineToBezierPathElement = 1;
public static const int NSMiniaturizableWindowMask = 4;
public static const int NSMiterLineJoinStyle = 0;
public static const int NSMixedState = -1;
public static const int NSMomentaryLightButton = 0;
public static const int NSMouseEntered = 8;
public static const int NSMouseExited = 9;
public static const int NSMouseMoved = 5;
public static const int NSMoveToBezierPathElement = 0;
public static const int NSNewlineCharacter = 10;
public static const int NSNoBorder = 0;
public static const int NSNoImage = 0;
public static const int NSNoTitle = 0;
public static const int NSNonZeroWindingRule = 0;
public static const int NSOffState = 0;
public static const int NSOnState = 1;
public static const int NSOpenGLPFAAccumSize = 14;
public static const int NSOpenGLPFAAlphaSize = 11;
public static const int NSOpenGLPFAColorSize = 8;
public static const int NSOpenGLPFADepthSize = 12;
public static const int NSOpenGLPFADoubleBuffer = 5;
public static const int NSOpenGLPFASampleBuffers = 55;
public static const int NSOpenGLPFASamples = 56;
public static const int NSOpenGLPFAStencilSize = 13;
public static const int NSOpenGLPFAStereo = 6;
public static const int NSOtherMouseDown = 25;
public static const int NSOtherMouseDragged = 27;
public static const int NSOtherMouseUp = 26;
public static const int NSOutlineViewDropOnItemIndex = -1;
public static const int NSPageDownFunctionKey = 63277;
public static const int NSPageUpFunctionKey = 63276;
public static const int NSPortraitOrientation = 0;
public static const int NSPrintPanelShowsPageSetupAccessory = 256;
public static const int NSProgressIndicatorPreferredThickness = 14;
public static const int NSPushOnPushOffButton = 1;
public static const int NSRadioButton = 4;
alias Cocoa.NSControlSize.NSRegularControlSize NSRegularControlSize;
public static const int NSResizableWindowMask = 8;
public static const int NSRightMouseDown = 3;
public static const int NSRightMouseDragged = 7;
public static const int NSRightMouseUp = 4;
public static const int NSRightTextAlignment = 1;
public static const int NSRoundLineCapStyle = 1;
public static const int NSRoundLineJoinStyle = 1;
public static const int NSRoundedBezelStyle = 1;
public static const int NSScaleNone = 2;
public static const int NSScrollWheel = 22;
public static const int NSScrollerDecrementLine = 4;
public static const int NSScrollerDecrementPage = 1;
public static const int NSScrollerIncrementLine = 5;
public static const int NSScrollerIncrementPage = 3;
public static const int NSScrollerKnob = 2;
public static const int NSShadowlessSquareBezelStyle = 6;
public static const int NSShiftKeyMask = 131072;
public static const int NSSmallControlSize = 1;
public static const int NSSquareLineCapStyle = 2;
public static const int NSStatusWindowLevel = 25;
public static const int NSSwitchButton = 3;
public static const int NSSystemDefined = 14;
public static const int NSTabCharacter = 9;
public static const int NSTableColumnNoResizing = 0;
public static const int NSTableColumnUserResizingMask = 2;
public static const int NSTableViewDropAbove = 1;
public static const int NSTableViewDropOn = 0;
public static const int NSTableViewNoColumnAutoresizing = 0;
public static const int NSTextFieldAndStepperDatePickerStyle = 0;
public static const int NSTitledWindowMask = 1;
public static const int NSUnderlineStyleDouble = 9;
public static const int NSUnderlineStyleNone = 0;
public static const int NSUnderlineStyleSingle = 1;
public static const int NSUnderlineStyleThick = 2;
public static const int NSViewHeightSizable = 16;
public static const int NSViewWidthSizable = 2;
public static const int NSWarningAlertStyle = 0;
public static const int NSWindowAbove = 1;
public static const int NSWindowBelow = -1;
public static const int NSYearMonthDatePickerElementFlag = 192;
public static const int NSYearMonthDayDatePickerElementFlag = 224;
public static const int kCFRunLoopBeforeWaiting = 32;
public static const int kCFStringEncodingUTF8 = 134217984;
public static const int kCGBlendModeDifference = 10;
alias Cocoa.CGEventFilterMask.kCGEventFilterMaskPermitLocalKeyboardEvents kCGEventFilterMaskPermitLocalKeyboardEvents;
alias Cocoa.CGEventFilterMask.kCGEventFilterMaskPermitLocalMouseEvents kCGEventFilterMaskPermitLocalMouseEvents;
alias Cocoa.CGEventFilterMask.kCGEventFilterMaskPermitSystemDefinedEvents kCGEventFilterMaskPermitSystemDefinedEvents;
alias Cocoa.CGEventSuppressionState.kCGEventSuppressionStateRemoteMouseDrag kCGEventSuppressionStateRemoteMouseDrag;
alias Cocoa.CGEventSuppressionState.kCGEventSuppressionStateSuppressionInterval kCGEventSuppressionStateSuppressionInterval;
public static const int kCGImageAlphaFirst = 4;
public static const int kCGImageAlphaLast = 3;
public static const int kCGImageAlphaNoneSkipFirst = 6;
public static const int kCGImageAlphaNoneSkipLast = 5;
public static const int kCGImageAlphaOnly = 7;
alias Cocoa.CGEventField.kCGKeyboardEventKeyboardType kCGKeyboardEventKeyboardType;
public static const int kCGLineCapButt = 0;
public static const int kCGLineCapRound = 1;
public static const int kCGLineCapSquare = 2;
public static const int kCGLineJoinBevel = 2;
public static const int kCGLineJoinMiter = 0;
public static const int kCGLineJoinRound = 1;
public static const int kCGPathElementAddCurveToPoint = 3;
public static const int kCGPathElementAddLineToPoint = 1;
public static const int kCGPathElementAddQuadCurveToPoint = 2;
public static const int kCGPathElementCloseSubpath = 4;
public static const int kCGPathElementMoveToPoint = 0;
public static const int kCGPathStroke = 2;
public static const int kCGSessionEventTap = 1;
public static const int NSAllApplicationsDirectory = 100;
public static const int NSAllDomainsMask = 65535;
alias Cocoa.NSNotFound NSNotFound;
public static const int NSOrderedSame = 0;
public static const int NSURLCredentialPersistenceForSession = 1;
public static const int NSURLErrorBadURL = -1000;
public static const int NSURLRequestReloadIgnoringLocalCacheData = 1;
public static const int NSUTF8StringEncoding = 4;

/*public static const Cocoa.NSInteger NSAlertFirstButtonReturn = 1000;
public static const Cocoa.NSInteger NSAlertSecondButtonReturn = 1001;
public static const Cocoa.NSInteger NSAlertThirdButtonReturn = 1002;
alias Cocoa.NSBitmapFormat.NSAlphaFirstBitmapFormat NSAlphaFirstBitmapFormat;
alias Cocoa.NSBitmapFormat.NSAlphaNonpremultipliedBitmapFormat NSAlphaNonpremultipliedBitmapFormat;
public static const int NSAlternateKeyMask = 524288;
alias Cocoa.NSEventType.NSApplicationDefined NSApplicationDefined;
alias Cocoa.NSTitlePosition.NSAtTop NSAtTop;
alias Cocoa.NSBackingStoreType.NSBackingStoreBuffered NSBackingStoreBuffered;
public static const int NSBackspaceCharacter = 8;
alias Cocoa.NSLineJoinStyle.NSBevelLineJoinStyle NSBevelLineJoinStyle;
alias NSBorderType.NSBezelBorder NSBezelBorder;
public static const int NSBoldFontMask = 2;
alias Cocoa.NSBorderlessWindowMask NSBorderlessWindowMask;
alias Cocoa.NSTabViewType.NSBottomTabsBezelBorder NSBottomTabsBezelBorder;
public static const int NSBoxCustom = 4;
public static const int NSBoxSeparator = 2;
alias Cocoa.NSLineCapStyle.NSButtLineCapStyle NSButtLineCapStyle;
public static const int NSCancelButton = 0;
public static const int NSCarriageReturnCharacter = 13;
alias Cocoa.NSTextAlignment.NSCenterTextAlignment NSCenterTextAlignment;
alias Cocoa.NSDatePickerStyle.NSClockAndCalendarDatePickerStyle NSClockAndCalendarDatePickerStyle;
public static const int NSClosableWindowMask = 2;
alias Cocoa.NSBezierPathElement.NSClosePathBezierPathElement NSClosePathBezierPathElement;
public static const int NSCommandKeyMask = 1048576;
alias Cocoa.NSCompositingOperation.NSCompositeClear NSCompositeClear;
public static const int NSCompositeCopy = 1;
alias Cocoa.NSCompositingOperation.NSCompositeSourceOver NSCompositeSourceOver;
alias Cocoa.NSCompositingOperation.NSCompositeXOR NSCompositeXOR;
public static const int NSControlKeyMask = 262144;
alias Cocoa.NSAlertStyle.NSCriticalAlertStyle NSCriticalAlertStyle;
alias Cocoa.NSBezierPathElement.NSCurveToBezierPathElement NSCurveToBezierPathElement;
public static const int NSDeleteCharacter = 127;
public static const int NSDeviceIndependentModifierFlagsMask = -65536;
public static const int NSDragOperationCopy = 1;
public static const int NSDragOperationDelete = 32;
public static const int NSDragOperationEvery = -1;
public static const int NSDragOperationLink = 2;
public static const int NSDragOperationMove = 16;
public static const int NSDragOperationNone = 0;
public static const int NSEnterCharacter = 3;
alias Cocoa.NSWindingRule.NSEvenOddWindingRule NSEvenOddWindingRule;
public static const int NSFileHandlingPanelOKButton = 1;
alias Cocoa.NSEventType.NSFlagsChanged NSFlagsChanged;
alias Cocoa.NSFocusRingType.NSFocusRingTypeNone NSFocusRingTypeNone;
public static const int NSHelpFunctionKey = 63302;
public static const int NSHelpKeyMask = 4194304;
alias Cocoa.NSDatePickerElementFlags.NSHourMinuteDatePickerElementFlag NSHourMinuteDatePickerElementFlag;
alias Cocoa.NSDatePickerElementFlags.NSHourMinuteSecondDatePickerElementFlag NSHourMinuteSecondDatePickerElementFlag;
alias Cocoa.NSCellImagePosition.NSImageAbove NSImageAbove;
alias NSImageAlignment.NSImageAlignCenter NSImageAlignCenter;
alias NSImageAlignment.NSImageAlignLeft NSImageAlignLeft;
alias NSImageAlignment.NSImageAlignRight NSImageAlignRight;
alias Cocoa.NSImageCacheMode.NSImageCacheNever NSImageCacheNever;
alias Cocoa.NSImageInterpolation.NSImageInterpolationDefault NSImageInterpolationDefault;
alias Cocoa.NSImageInterpolation.NSImageInterpolationHigh NSImageInterpolationHigh;
alias Cocoa.NSImageInterpolation.NSImageInterpolationLow NSImageInterpolationLow;
alias Cocoa.NSImageInterpolation.NSImageInterpolationNone NSImageInterpolationNone;
alias Cocoa.NSCellImagePosition.NSImageLeft NSImageLeft;
alias Cocoa.NSCellImagePosition.NSImageOnly NSImageOnly;
alias Cocoa.NSCellImagePosition.NSImageOverlaps NSImageOverlaps;
alias Cocoa.NSAlertStyle.NSInformationalAlertStyle NSInformationalAlertStyle;
public static const int NSItalicFontMask = 1;
alias Cocoa.NSTextAlignment.NSJustifiedTextAlignment NSJustifiedTextAlignment;
alias Cocoa.NSEventType.NSKeyDown NSKeyDown;
alias Cocoa.NSEventType.NSKeyUp NSKeyUp;
public static const int NSLandscapeOrientation = 1;
alias Cocoa.NSEventType.NSLeftMouseDown NSLeftMouseDown;
public static const int NSLeftMouseDownMask = 2;
alias Cocoa.NSEventType.NSLeftMouseDragged NSLeftMouseDragged;
public static const int NSLeftMouseDraggedMask = 64;
alias Cocoa.NSEventType.NSLeftMouseUp NSLeftMouseUp;
public static const int NSLeftMouseUpMask = 4;
alias Cocoa.NSTextTabType.NSLeftTabStopType NSLeftTabStopType;
alias Cocoa.NSTextAlignment.NSLeftTextAlignment NSLeftTextAlignment;
alias Cocoa.NSLineBreakMode.NSLineBreakByClipping NSLineBreakByClipping;
alias Cocoa.NSLineBreakMode.NSLineBreakByWordWrapping NSLineBreakByWordWrapping;
alias Cocoa.NSBezierPathElement.NSLineToBezierPathElement NSLineToBezierPathElement;
public static const int NSMiniaturizableWindowMask = 4;
alias Cocoa.NSLineJoinStyle.NSMiterLineJoinStyle NSMiterLineJoinStyle;
public static const int NSMixedState = -1;
alias Cocoa.NSButtonType.NSMomentaryLightButton NSMomentaryLightButton;
alias Cocoa.NSEventType.NSMouseEntered NSMouseEntered;
alias Cocoa.NSEventType.NSMouseExited NSMouseExited;
alias Cocoa.NSEventType.NSMouseMoved NSMouseMoved;
alias Cocoa.NSBezierPathElement.NSMoveToBezierPathElement NSMoveToBezierPathElement;
public static const int NSNewlineCharacter = 10;
alias NSBorderType.NSNoBorder NSNoBorder;
alias Cocoa.NSCellImagePosition.NSNoImage NSNoImage;
alias Cocoa.NSTitlePosition.NSNoTitle NSNoTitle;
alias Cocoa.NSWindingRule.NSNonZeroWindingRule NSNonZeroWindingRule;
public static const int NSOffState = 0;
public static const int NSOnState = 1;
public static const int NSOpenGLPFAAccumSize = 14;
public static const int NSOpenGLPFAAlphaSize = 11;
public static const int NSOpenGLPFAColorSize = 8;
public static const int NSOpenGLPFADepthSize = 12;
public static const int NSOpenGLPFADoubleBuffer = 5;
public static const int NSOpenGLPFASampleBuffers = 55;
public static const int NSOpenGLPFASamples = 56;
public static const int NSOpenGLPFAStencilSize = 13;
public static const int NSOpenGLPFAStereo = 6;
alias Cocoa.NSEventType.NSOtherMouseDown NSOtherMouseDown;
alias Cocoa.NSEventType.NSOtherMouseDragged NSOtherMouseDragged;
alias Cocoa.NSEventType.NSOtherMouseUp NSOtherMouseUp;
public static const int NSOutlineViewDropOnItemIndex = -1;
public static const int NSPageDownFunctionKey = 63277;
public static const int NSPageUpFunctionKey = 63276;
public static const int NSPortraitOrientation = 0;
alias Cocoa.NSPrintPanelOptions.NSPrintPanelShowsPageSetupAccessory NSPrintPanelShowsPageSetupAccessory;
public static const int NSProgressIndicatorPreferredThickness = 14;
alias Cocoa.NSButtonType.NSPushOnPushOffButton NSPushOnPushOffButton;
alias Cocoa.NSButtonType.NSRadioButton NSRadioButton;
public static const int NSRegularControlSize = 0;
public static const int NSResizableWindowMask = 8;
alias Cocoa.NSEventType.NSRightMouseDown NSRightMouseDown;
alias Cocoa.NSEventType.NSRightMouseDragged NSRightMouseDragged;
alias Cocoa.NSEventType.NSRightMouseUp NSRightMouseUp;
alias Cocoa.NSTextAlignment.NSRightTextAlignment NSRightTextAlignment;
alias Cocoa.NSLineCapStyle.NSRoundLineCapStyle NSRoundLineCapStyle;
alias Cocoa.NSLineJoinStyle.NSRoundLineJoinStyle NSRoundLineJoinStyle;
alias Cocoa.NSBezelStyle.NSRoundedBezelStyle NSRoundedBezelStyle;
alias Cocoa.NSImageScaling.NSScaleNone NSScaleNone;
alias Cocoa.NSEventType.NSScrollWheel NSScrollWheel;
alias NSScrollerPart.NSScrollerDecrementLine NSScrollerDecrementLine;
alias NSScrollerPart.NSScrollerDecrementPage NSScrollerDecrementPage;
alias NSScrollerPart.NSScrollerIncrementLine NSScrollerIncrementLine;
alias NSScrollerPart.NSScrollerIncrementPage NSScrollerIncrementPage;
alias NSScrollerPart.NSScrollerKnob NSScrollerKnob;
alias Cocoa.NSBezelStyle.NSShadowlessSquareBezelStyle NSShadowlessSquareBezelStyle;
public static const int NSShiftKeyMask = 131072;
public static const int NSSmallControlSize = 1;
alias Cocoa.NSLineCapStyle.NSSquareLineCapStyle NSSquareLineCapStyle;
public static const int NSStatusWindowLevel = 25;
alias Cocoa.NSButtonType.NSSwitchButton NSSwitchButton;
alias Cocoa.NSEventType.NSSystemDefined NSSystemDefined;
public static const int NSTabCharacter = 9;
public static const int NSTableColumnNoResizing = 0;
public static const int NSTableColumnUserResizingMask = 2;
public static const int NSTableViewDropAbove = 1;
public static const int NSTableViewDropOn = 0;
alias Cocoa.NSTableViewColumnAutoresizingStyle.NSTableViewNoColumnAutoresizing NSTableViewNoColumnAutoresizing;
alias Cocoa.NSDatePickerStyle.NSTextFieldAndStepperDatePickerStyle NSTextFieldAndStepperDatePickerStyle;
public static const int NSTitledWindowMask = 1;
public static const int NSUnderlineStyleDouble = 9;
public static const int NSUnderlineStyleNone = 0;
public static const int NSUnderlineStyleSingle = 1;
public static const int NSUnderlineStyleThick = 2;
public static const Cocoa.NSUInteger NSViewHeightSizable = 16;
public static const Cocoa.NSUInteger NSViewWidthSizable = 2;
alias Cocoa.NSAlertStyle.NSWarningAlertStyle NSWarningAlertStyle;
alias Cocoa.NSWindowOrderingMode.NSWindowAbove NSWindowAbove;
alias Cocoa.NSWindowOrderingMode.NSWindowBelow NSWindowBelow;
alias Cocoa.NSDatePickerElementFlags.NSYearMonthDatePickerElementFlag NSYearMonthDatePickerElementFlag;
alias Cocoa.NSDatePickerElementFlags.NSYearMonthDayDatePickerElementFlag NSYearMonthDayDatePickerElementFlag;
public static const int kCFRunLoopBeforeWaiting = 32;
public static const Carbon.CFStringEncoding kCFStringEncodingUTF8 = 134217984;
public static const int NSASCIIStringEncoding = 1;
public static const int kCGBlendModeDifference = 10;
public static const int kCGEventFilterMaskPermitLocalKeyboardEvents = 2;
public static const int kCGEventFilterMaskPermitLocalMouseEvents = 1;
public static const int kCGEventFilterMaskPermitSystemDefinedEvents = 4;
public static const int kCGEventSuppressionStateRemoteMouseDrag = 1;
public static const int kCGEventSuppressionStateSuppressionInterval = 0;
public static const int kCGImageAlphaFirst = 4;
public static const int kCGImageAlphaNoneSkipFirst = 6;
public static const int kCGImageAlphaOnly = 7;
public static const int kCGKeyboardEventKeyboardType = 10;
public static const int kCGLineCapButt = 0;
public static const int kCGLineCapRound = 1;
public static const int kCGLineCapSquare = 2;
public static const int kCGLineJoinBevel = 2;
public static const int kCGLineJoinMiter = 0;
public static const int kCGLineJoinRound = 1;
public static const int kCGPathElementAddCurveToPoint = 3;
public static const int kCGPathElementAddLineToPoint = 1;
public static const int kCGPathElementAddQuadCurveToPoint = 2;
public static const int kCGPathElementCloseSubpath = 4;
public static const int kCGPathElementMoveToPoint = 0;
public static const int kCGPathStroke = 2;
public static const int kCGSessionEventTap = 1;
public static const int NSCalculationDivideByZero = 4;
public static const int NSCalculationLossOfPrecision = 1;
public static const int NSNumberFormatterPercentStyle = 3;
public static const int NSPropertyListBinaryFormat_v1_0 = 200;
public static const int NSURLErrorDownloadDecodingFailedMidStream = -3006;
public static const int NSURLErrorHTTPTooManyRedirects = -1007;
public static const int NSUserDomainMask = 1;
public static const int NSWindowsCP1252StringEncoding = 12;*/
public static final int kCFRunLoopBeforeWaiting = 32;
public static final int kCGEventFilterMaskPermitSystemDefinedEvents = 4;
public static final int kCGEventSuppressionStateRemoteMouseDrag = 1;
public static final int kCGEventSuppressionStateSuppressionInterval = 0;
public static final int kCGImageAlphaFirst = 4;
public static final int kCGImageAlphaNoneSkipFirst = 6;
public static final int kCGImageAlphaOnly = 7;
public static final int kCGKeyboardEventKeyboardType = 10;
public static final int kCGLineCapButt = 0;
public static final int kCGLineCapRound = 1;
public static final int kCGLineCapSquare = 2;
public static final int kCGLineJoinBevel = 2;
public static final int kCGLineJoinMiter = 0;
public static final int kCGLineJoinRound = 1;
public static final int kCGPathElementAddCurveToPoint = 3;
public static final int kCGPathElementAddLineToPoint = 1;
public static final int kCGPathElementAddQuadCurveToPoint = 2;
public static final int kCGPathElementCloseSubpath = 4;
public static final int kCGPathElementMoveToPoint = 0;
public static final int kCGPathStroke = 2;
public static final int kCGSessionEventTap = 1;

/** Globals */
/** @method flags=const */
alias Cocoa.NSAccessibilityButtonRole NSAccessibilityButtonRole_;
public static const NSString NSAccessibilityButtonRole;
/** @method flags=const */
alias Cocoa.NSAccessibilityCheckBoxRole NSAccessibilityCheckBoxRole_;
public static const NSString NSAccessibilityCheckBoxRole;
/** @method flags=const */
alias Cocoa.NSAccessibilityChildrenAttribute NSAccessibilityChildrenAttribute_;
public static const NSString NSAccessibilityChildrenAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityColumnRole NSAccessibilityColumnRole_;
public static const NSString NSAccessibilityColumnRole;
/** @method flags=const */
alias Cocoa.NSAccessibilityComboBoxRole NSAccessibilityComboBoxRole_;
public static const NSString NSAccessibilityComboBoxRole;
/** @method flags=const */
alias Cocoa.NSAccessibilityConfirmAction NSAccessibilityConfirmAction_;
public static const NSString NSAccessibilityConfirmAction;
/** @method flags=const */
alias Cocoa.NSAccessibilityContentsAttribute NSAccessibilityContentsAttribute_;
public static const NSString NSAccessibilityContentsAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityDescriptionAttribute NSAccessibilityDescriptionAttribute_;
public static const NSString NSAccessibilityDescriptionAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityDialogSubrole NSAccessibilityDialogSubrole_;
public static const NSString NSAccessibilityDialogSubrole;
/** @method flags=const */
alias Cocoa.NSAccessibilityEnabledAttribute NSAccessibilityEnabledAttribute_;
public static const NSString NSAccessibilityEnabledAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityExpandedAttribute NSAccessibilityExpandedAttribute_;
public static const NSString NSAccessibilityExpandedAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityFloatingWindowSubrole NSAccessibilityFloatingWindowSubrole_;
public static const NSString NSAccessibilityFloatingWindowSubrole;
/** @method flags=const */
alias Cocoa.NSAccessibilityFocusedAttribute NSAccessibilityFocusedAttribute_;
public static const NSString NSAccessibilityFocusedAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityFocusedUIElementChangedNotification NSAccessibilityFocusedUIElementChangedNotification_;
public static const NSString NSAccessibilityFocusedUIElementChangedNotification;
/** @method flags=const */
alias Cocoa.NSAccessibilityGridRole NSAccessibilityGridRole_;
public static const NSString NSAccessibilityGridRole;
/** @method flags=const */
alias Cocoa.NSAccessibilityGroupRole NSAccessibilityGroupRole_;
public static const NSString NSAccessibilityGroupRole;
/** @method flags=const */
alias Cocoa.NSAccessibilityHelpAttribute NSAccessibilityHelpAttribute_;
public static const NSString NSAccessibilityHelpAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityHelpTagRole NSAccessibilityHelpTagRole_;
public static const NSString NSAccessibilityHelpTagRole;
/** @method flags=const */
alias Cocoa.NSAccessibilityHorizontalOrientationValue NSAccessibilityHorizontalOrientationValue_;
public static const NSString NSAccessibilityHorizontalOrientationValue;
/** @method flags=const */
alias Cocoa.NSAccessibilityHorizontalScrollBarAttribute NSAccessibilityHorizontalScrollBarAttribute_;
public static const NSString NSAccessibilityHorizontalScrollBarAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityImageRole NSAccessibilityImageRole_;
public static const NSString NSAccessibilityImageRole;
/** @method flags=const */
alias Cocoa.NSAccessibilityIncrementorRole NSAccessibilityIncrementorRole_;
public static const NSString NSAccessibilityIncrementorRole;
/** @method flags=const */
alias Cocoa.NSAccessibilityInsertionPointLineNumberAttribute NSAccessibilityInsertionPointLineNumberAttribute_;
public static const NSString NSAccessibilityInsertionPointLineNumberAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityLabelValueAttribute NSAccessibilityLabelValueAttribute_;
public static const NSString NSAccessibilityLabelValueAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityLineForIndexParameterizedAttribute NSAccessibilityLineForIndexParameterizedAttribute_;
public static const NSString NSAccessibilityLineForIndexParameterizedAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityLinkRole NSAccessibilityLinkRole_;
public static const NSString NSAccessibilityLinkRole;
/** @method flags=const */
alias Cocoa.NSAccessibilityLinkTextAttribute NSAccessibilityLinkTextAttribute_;
public static const NSString NSAccessibilityLinkTextAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityListRole NSAccessibilityListRole_;
public static const NSString NSAccessibilityListRole;
/** @method flags=const */
alias Cocoa.NSAccessibilityMaxValueAttribute NSAccessibilityMaxValueAttribute_;
public static const NSString NSAccessibilityMaxValueAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityMenuBarRole NSAccessibilityMenuBarRole_;
public static const NSString NSAccessibilityMenuBarRole;
/** @method flags=const */
alias Cocoa.NSAccessibilityMenuButtonRole NSAccessibilityMenuButtonRole_;
public static const NSString NSAccessibilityMenuButtonRole;
/** @method flags=const */
alias Cocoa.NSAccessibilityMenuItemRole NSAccessibilityMenuItemRole_;
public static const NSString NSAccessibilityMenuItemRole;
/** @method flags=const */
alias Cocoa.NSAccessibilityMenuRole NSAccessibilityMenuRole_;
public static const NSString NSAccessibilityMenuRole;
/** @method flags=const */
alias Cocoa.NSAccessibilityMinValueAttribute NSAccessibilityMinValueAttribute_;
public static const NSString NSAccessibilityMinValueAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityNextContentsAttribute NSAccessibilityNextContentsAttribute_;
public static const NSString NSAccessibilityNextContentsAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityNumberOfCharactersAttribute NSAccessibilityNumberOfCharactersAttribute_;
public static const NSString NSAccessibilityNumberOfCharactersAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityOrientationAttribute NSAccessibilityOrientationAttribute_;
public static const NSString NSAccessibilityOrientationAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityOutlineRole NSAccessibilityOutlineRole_;
public static const NSString NSAccessibilityOutlineRole;
/** @method flags=const */
alias Cocoa.NSAccessibilityOutlineRowSubrole NSAccessibilityOutlineRowSubrole_;
public static const NSString NSAccessibilityOutlineRowSubrole;
/** @method flags=const */
alias Cocoa.NSAccessibilityParentAttribute NSAccessibilityParentAttribute_;
public static const NSString NSAccessibilityParentAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityPopUpButtonRole NSAccessibilityPopUpButtonRole_;
public static const NSString NSAccessibilityPopUpButtonRole;
/** @method flags=const */
alias Cocoa.NSAccessibilityPositionAttribute NSAccessibilityPositionAttribute_;
public static const NSString NSAccessibilityPositionAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityPressAction NSAccessibilityPressAction_;
public static const NSString NSAccessibilityPressAction;
/** @method flags=const */
alias Cocoa.NSAccessibilityPreviousContentsAttribute NSAccessibilityPreviousContentsAttribute_;
public static const NSString NSAccessibilityPreviousContentsAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityProgressIndicatorRole NSAccessibilityProgressIndicatorRole_;
public static const NSString NSAccessibilityProgressIndicatorRole;
/** @method flags=const */
alias Cocoa.NSAccessibilityRTFForRangeParameterizedAttribute NSAccessibilityRTFForRangeParameterizedAttribute_;
public static const NSString NSAccessibilityRTFForRangeParameterizedAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityRadioButtonRole NSAccessibilityRadioButtonRole_;
public static const NSString NSAccessibilityRadioButtonRole;
/** @method flags=const */
alias Cocoa.NSAccessibilityRadioGroupRole NSAccessibilityRadioGroupRole_;
public static const NSString NSAccessibilityRadioGroupRole;
/** @method flags=const */
alias Cocoa.NSAccessibilityRangeForIndexParameterizedAttribute NSAccessibilityRangeForIndexParameterizedAttribute_;
public static const NSString NSAccessibilityRangeForIndexParameterizedAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityRangeForLineParameterizedAttribute NSAccessibilityRangeForLineParameterizedAttribute_;
public static const NSString NSAccessibilityRangeForLineParameterizedAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityRangeForPositionParameterizedAttribute NSAccessibilityRangeForPositionParameterizedAttribute_;
public static const NSString NSAccessibilityRangeForPositionParameterizedAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityRoleAttribute NSAccessibilityRoleAttribute_;
public static const NSString NSAccessibilityRoleAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityRoleDescriptionAttribute NSAccessibilityRoleDescriptionAttribute_;
public static const NSString NSAccessibilityRoleDescriptionAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityRowRole NSAccessibilityRowRole_;
public static const NSString NSAccessibilityRowRole;
/** @method flags=const */
alias Cocoa.NSAccessibilityScrollAreaRole NSAccessibilityScrollAreaRole_;
public static const NSString NSAccessibilityScrollAreaRole;
/** @method flags=const */
alias Cocoa.NSAccessibilityScrollBarRole NSAccessibilityScrollBarRole_;
public static const NSString NSAccessibilityScrollBarRole;
/** @method flags=const */
alias Cocoa.NSAccessibilitySelectedAttribute NSAccessibilitySelectedAttribute_;
public static const NSString NSAccessibilitySelectedAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilitySelectedChildrenAttribute NSAccessibilitySelectedChildrenAttribute_;
public static const NSString NSAccessibilitySelectedChildrenAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilitySelectedChildrenChangedNotification NSAccessibilitySelectedChildrenChangedNotification_;
public static const NSString NSAccessibilitySelectedChildrenChangedNotification;
/** @method flags=const */
alias Cocoa.NSAccessibilitySelectedTextAttribute NSAccessibilitySelectedTextAttribute_;
public static const NSString NSAccessibilitySelectedTextAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilitySelectedTextChangedNotification NSAccessibilitySelectedTextChangedNotification_;
public static const NSString NSAccessibilitySelectedTextChangedNotification;
/** @method flags=const */
alias Cocoa.NSAccessibilitySelectedTextRangeAttribute NSAccessibilitySelectedTextRangeAttribute_;
public static const NSString NSAccessibilitySelectedTextRangeAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilitySelectedTextRangesAttribute NSAccessibilitySelectedTextRangesAttribute_;
public static const NSString NSAccessibilitySelectedTextRangesAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityServesAsTitleForUIElementsAttribute NSAccessibilityServesAsTitleForUIElementsAttribute_;
public static const NSString NSAccessibilityServesAsTitleForUIElementsAttribute;
/** @method flags=const */
/** @method flags=const */
alias Cocoa.NSAccessibilitySizeAttribute NSAccessibilitySizeAttribute_;
public static const NSString NSAccessibilitySizeAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilitySliderRole NSAccessibilitySliderRole_;
public static const NSString NSAccessibilitySliderRole;
/** @method flags=const */
alias Cocoa.NSAccessibilitySortButtonRole NSAccessibilitySortButtonRole_;
public static const NSString NSAccessibilitySortButtonRole;
/** @method flags=const */
alias Cocoa.NSAccessibilitySplitterRole NSAccessibilitySplitterRole_;
public static const NSString NSAccessibilitySplitterRole;
/** @method flags=const */
alias Cocoa.NSAccessibilityStandardWindowSubrole NSAccessibilityStandardWindowSubrole_;
public static const NSString NSAccessibilityStandardWindowSubrole;
/** @method flags=const */
alias Cocoa.NSAccessibilityStaticTextRole NSAccessibilityStaticTextRole_;
public static const NSString NSAccessibilityStaticTextRole;
/** @method flags=const */
alias Cocoa.NSAccessibilityStringForRangeParameterizedAttribute NSAccessibilityStringForRangeParameterizedAttribute_;
public static const NSString NSAccessibilityStringForRangeParameterizedAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityStyleRangeForIndexParameterizedAttribute NSAccessibilityStyleRangeForIndexParameterizedAttribute_;
public static const NSString NSAccessibilityStyleRangeForIndexParameterizedAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilitySubroleAttribute NSAccessibilitySubroleAttribute_;
public static const NSString NSAccessibilitySubroleAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilitySystemDialogSubrole NSAccessibilitySystemDialogSubrole_;
public static const NSString NSAccessibilitySystemDialogSubrole;
/** @method flags=const */
alias Cocoa.NSAccessibilityTabGroupRole NSAccessibilityTabGroupRole_;
public static const NSString NSAccessibilityTabGroupRole;
/** @method flags=const */
alias Cocoa.NSAccessibilityTableRole NSAccessibilityTableRole_;
public static const NSString NSAccessibilityTableRole;
/** @method flags=const */
alias Cocoa.NSAccessibilityTableRowSubrole NSAccessibilityTableRowSubrole_;
public static const NSString NSAccessibilityTableRowSubrole;
/** @method flags=const */
alias Cocoa.NSAccessibilityTabsAttribute NSAccessibilityTabsAttribute_;
public static const NSString NSAccessibilityTabsAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityTextAreaRole NSAccessibilityTextAreaRole_;
public static const NSString NSAccessibilityTextAreaRole;
/** @method flags=const */
alias Cocoa.NSAccessibilityTextFieldRole NSAccessibilityTextFieldRole_;
public static const NSString NSAccessibilityTextFieldRole;
/** @method flags=const */
alias Cocoa.NSAccessibilityTextLinkSubrole NSAccessibilityTextLinkSubrole_;
public static const NSString NSAccessibilityTextLinkSubrole;
/** @method flags=const */
alias Cocoa.NSAccessibilityTitleAttribute NSAccessibilityTitleAttribute_;
public static const NSString NSAccessibilityTitleAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityTitleUIElementAttribute NSAccessibilityTitleUIElementAttribute_;
public static const NSString NSAccessibilityTitleUIElementAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityToolbarRole NSAccessibilityToolbarRole_;
public static const NSString NSAccessibilityToolbarRole;
/** @method flags=const */
alias Cocoa.NSAccessibilityTopLevelUIElementAttribute NSAccessibilityTopLevelUIElementAttribute_;
public static const NSString NSAccessibilityTopLevelUIElementAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityUnknownRole NSAccessibilityUnknownRole_;
public static const NSString NSAccessibilityUnknownRole;
/** @method flags=const */
alias Cocoa.NSAccessibilityUnknownSubrole NSAccessibilityUnknownSubrole_;
public static const NSString NSAccessibilityUnknownSubrole;
/** @method flags=const */
alias Cocoa.NSAccessibilityValueAttribute NSAccessibilityValueAttribute_;
public static const NSString NSAccessibilityValueAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityValueChangedNotification NSAccessibilityValueChangedNotification_;
public static const NSString NSAccessibilityValueChangedNotification;
/** @method flags=const */
alias Cocoa.NSAccessibilityValueDescriptionAttribute NSAccessibilityValueDescriptionAttribute_;
public static const NSString NSAccessibilityValueDescriptionAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityValueIndicatorRole NSAccessibilityValueIndicatorRole_;
public static const NSString NSAccessibilityValueIndicatorRole;
/** @method flags=const */
alias Cocoa.NSAccessibilityVerticalOrientationValue NSAccessibilityVerticalOrientationValue_;
public static const NSString NSAccessibilityVerticalOrientationValue;
/** @method flags=const */
alias Cocoa.NSAccessibilityVerticalScrollBarAttribute NSAccessibilityVerticalScrollBarAttribute_;
public static const NSString NSAccessibilityVerticalScrollBarAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityVisibleCharacterRangeAttribute NSAccessibilityVisibleCharacterRangeAttribute_;
public static const NSString NSAccessibilityVisibleCharacterRangeAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityVisibleChildrenAttribute NSAccessibilityVisibleChildrenAttribute_;
public static const NSString NSAccessibilityVisibleChildrenAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityWindowAttribute NSAccessibilityWindowAttribute_;
public static const NSString NSAccessibilityWindowAttribute;
/** @method flags=const */
alias Cocoa.NSAccessibilityWindowRole NSAccessibilityWindowRole_;
public static const NSString NSAccessibilityWindowRole;
/** @method flags=const */
/** @method flags=const */
alias Cocoa.NSApplicationDidChangeScreenParametersNotification NSApplicationDidChangeScreenParametersNotification_;
public static const NSString NSApplicationDidChangeScreenParametersNotification;
/** @method flags=const */
alias Cocoa.NSBackgroundColorAttributeName NSBackgroundColorAttributeName_;
public static const NSString NSBackgroundColorAttributeName;
/** @method flags=const */
alias Cocoa.NSBaselineOffsetAttributeName NSBaselineOffsetAttributeName_;
public static const NSString NSBaselineOffsetAttributeName;
/** @method flags=const */
alias Cocoa.NSCalibratedRGBColorSpace NSCalibratedRGBColorSpace_;
public static const NSString NSCalibratedRGBColorSpace;
/** @method flags=const */
alias Cocoa.NSDeviceRGBColorSpace NSDeviceRGBColorSpace_;
public static const NSString NSDeviceRGBColorSpace;
/** @method flags=const */
alias Cocoa.NSDeviceResolution NSDeviceResolution_;
public static const NSString NSDeviceResolution;
/** @method flags=const */
/** @method flags=const */
alias Cocoa.NSDragPboard NSDragPboard_;
public static const NSString NSDragPboard;
/** @method flags=const */
alias Cocoa.NSEventTrackingRunLoopMode NSEventTrackingRunLoopMode_;
public static const NSString NSEventTrackingRunLoopMode;
/** @method flags=const */
alias Cocoa.NSFilenamesPboardType NSFilenamesPboardType_;
public static const NSString NSFilenamesPboardType;
/** @method flags=const */
alias Cocoa.NSFontAttributeName NSFontAttributeName_;
public static const NSString NSFontAttributeName;
/** @method flags=const */
alias Cocoa.NSForegroundColorAttributeName NSForegroundColorAttributeName_;
public static const NSString NSForegroundColorAttributeName;
/** @method flags=const */
/** @method flags=const */
alias Cocoa.NSHTMLPboardType NSHTMLPboardType_;
public static const NSString NSHTMLPboardType;
/** @method flags=const */
alias Cocoa.NSLinkAttributeName NSLinkAttributeName_;
public static const NSString NSLinkAttributeName;
/** @method flags=const */
alias Cocoa.NSObliquenessAttributeName NSObliquenessAttributeName_;
public static const NSString NSObliquenessAttributeName;
/** @method flags=const */
alias Cocoa.NSParagraphStyleAttributeName NSParagraphStyleAttributeName_;
public static const NSString NSParagraphStyleAttributeName;
/** @method flags=const */
alias Cocoa.NSPrintAllPages NSPrintAllPages_;
public static const NSString NSPrintAllPages;
/** @method flags=const */
alias Cocoa.NSPrintCopies NSPrintCopies_;
public static const NSString NSPrintCopies;
/** @method flags=const */
alias Cocoa.NSPrintFirstPage NSPrintFirstPage_;
public static const NSString NSPrintFirstPage;
/** @method flags=const */
alias Cocoa.NSPrintJobDisposition NSPrintJobDisposition_;
public static const NSString NSPrintJobDisposition;
/** @method flags=const */
alias Cocoa.NSPrintLastPage NSPrintLastPage_;
public static const NSString NSPrintLastPage;
/** @method flags=const */
alias Cocoa.NSPrintMustCollate NSPrintMustCollate_;
public static const NSString NSPrintMustCollate;
/** @method flags=const */
/** @method flags=const */
alias Cocoa.NSPrintPreviewJob NSPrintPreviewJob_;
public static const NSString NSPrintPreviewJob;
/** @method flags=const */
alias Cocoa.NSPrintSaveJob NSPrintSaveJob_;
public static const NSString NSPrintSaveJob;
/** @method flags=const */
alias Cocoa.NSPrintSavePath NSPrintSavePath_;
public static const NSString NSPrintSavePath;
/** @method flags=const */
alias Cocoa.NSPrintScalingFactor NSPrintScalingFactor_;
public static const NSString NSPrintScalingFactor;
/** @method flags=const */
alias Cocoa.NSPrintSpoolJob NSPrintSpoolJob_;
public static const NSString NSPrintSpoolJob;
/** @method flags=const */
public static final native int /*long*/ NSSystemColorsDidChangeNotification();
public static final NSString NSSystemColorsDidChangeNotification = new NSString(NSSystemColorsDidChangeNotification());
/** @method flags=const */
/** @method flags=const */
alias Cocoa.NSRTFPboardType NSRTFPboardType_;
public static const NSString NSRTFPboardType;
/** @method flags=const */
public static final native int /*long*/ NSToolbarDidRemoveItemNotification();
public static final NSString NSToolbarDidRemoveItemNotification = new NSString(NSToolbarDidRemoveItemNotification());
/** @method flags=const */
public static final native int /*long*/ NSToolbarFlexibleSpaceItemIdentifier();
public static final NSString NSToolbarFlexibleSpaceItemIdentifier = new NSString(NSToolbarFlexibleSpaceItemIdentifier());
/** @method flags=const */
public static final native int /*long*/ NSToolbarPrintItemIdentifier();
public static final NSString NSToolbarPrintItemIdentifier = new NSString(NSToolbarPrintItemIdentifier());
/** @method flags=const */
public static final native int /*long*/ NSToolbarSeparatorItemIdentifier();
public static final NSString NSToolbarSeparatorItemIdentifier = new NSString(NSToolbarSeparatorItemIdentifier());
/** @method flags=const */
public static final native int /*long*/ NSToolbarShowColorsItemIdentifier();
public static final NSString NSToolbarShowColorsItemIdentifier = new NSString(NSToolbarShowColorsItemIdentifier());
/** @method flags=const */
public static final native int /*long*/ NSToolbarShowFontsItemIdentifier();
public static final NSString NSToolbarShowFontsItemIdentifier = new NSString(NSToolbarShowFontsItemIdentifier());
/** @method flags=const */
public static final native int /*long*/ NSToolbarSpaceItemIdentifier();
public static final NSString NSToolbarSpaceItemIdentifier = new NSString(NSToolbarSpaceItemIdentifier());
/** @method flags=const */
public static final native int /*long*/ NSToolbarWillAddItemNotification();
public static final NSString NSToolbarWillAddItemNotification = new NSString(NSToolbarWillAddItemNotification());
/** @method flags=const */
/** @method flags=const */
alias Cocoa.NSStrikethroughColorAttributeName NSStrikethroughColorAttributeName_;
public static const NSString NSStrikethroughColorAttributeName;
/** @method flags=const */
alias Cocoa.NSStrikethroughStyleAttributeName NSStrikethroughStyleAttributeName_;
public static const NSString NSStrikethroughStyleAttributeName;
/** @method flags=const */
alias Cocoa.NSStringPboardType NSStringPboardType_;
public static const NSString NSStringPboardType;
/** @method flags=const */
public static final native int /*long*/ kCFRunLoopCommonModes();
/** @method flags=const */
/** @method flags=const */
alias Cocoa.NSStrokeWidthAttributeName NSStrokeWidthAttributeName_;
public static const NSString NSStrokeWidthAttributeName;
/** @method flags=const */
alias Cocoa.NSSystemColorsDidChangeNotification NSSystemColorsDidChangeNotification_;
public static const NSString NSSystemColorsDidChangeNotification;
/** @method flags=const */
alias Cocoa.NSTIFFPboardType NSTIFFPboardType_;
public static const NSString NSTIFFPboardType;
/** @method flags=const */
alias Cocoa.NSToolbarCustomizeToolbarItemIdentifier NSToolbarCustomizeToolbarItemIdentifier_;
public static const NSString NSToolbarCustomizeToolbarItemIdentifier;
/** @method flags=const */
alias Cocoa.NSToolbarDidRemoveItemNotification NSToolbarDidRemoveItemNotification_;
public static const NSString NSToolbarDidRemoveItemNotification;
/** @method flags=const */
alias Cocoa.NSToolbarFlexibleSpaceItemIdentifier NSToolbarFlexibleSpaceItemIdentifier_;
public static const NSString NSToolbarFlexibleSpaceItemIdentifier;
/** @method flags=const */
alias Cocoa.NSToolbarPrintItemIdentifier NSToolbarPrintItemIdentifier_;
public static const NSString NSToolbarPrintItemIdentifier;
/** @method flags=const */
alias Cocoa.NSToolbarSeparatorItemIdentifier NSToolbarSeparatorItemIdentifier_;
public static const NSString NSToolbarSeparatorItemIdentifier;
/** @method flags=const */
alias Cocoa.NSToolbarShowColorsItemIdentifier NSToolbarShowColorsItemIdentifier_;
public static const NSString NSToolbarShowColorsItemIdentifier;
/** @method flags=const */
alias Cocoa.NSToolbarShowFontsItemIdentifier NSToolbarShowFontsItemIdentifier_;
public static const NSString NSToolbarShowFontsItemIdentifier;
/** @method flags=const */
alias Cocoa.NSToolbarSpaceItemIdentifier NSToolbarSpaceItemIdentifier_;
public static const NSString NSToolbarSpaceItemIdentifier;
/** @method flags=const */
alias Cocoa.NSToolbarWillAddItemNotification NSToolbarWillAddItemNotification_;
public static const NSString NSToolbarWillAddItemNotification;
/** @method flags=const */
alias Cocoa.NSURLPboardType NSURLPboardType_;
public static const NSString NSURLPboardType;
/** @method flags=const */
alias Cocoa.NSUnderlineColorAttributeName NSUnderlineColorAttributeName_;
public static const NSString NSUnderlineColorAttributeName;
/** @method flags=const */
alias Cocoa.NSUnderlineStyleAttributeName NSUnderlineStyleAttributeName_;
public static const NSString NSUnderlineStyleAttributeName;
/** @method flags=const */
alias Cocoa.NSViewGlobalFrameDidChangeNotification NSViewGlobalFrameDidChangeNotification_;
public static const NSString NSViewGlobalFrameDidChangeNotification;
/** @method flags=const */
alias Cocoa.kCFRunLoopCommonModes kCFRunLoopCommonModes_;
public static const NSString kCFRunLoopCommonModes;
/** @method flags=const */
alias Cocoa.NSDefaultRunLoopMode NSDefaultRunLoopMode_;
public static const NSString NSDefaultRunLoopMode;
/** @method flags=const */
alias Cocoa.NSErrorFailingURLStringKey NSErrorFailingURLStringKey_;
public static const NSString NSErrorFailingURLStringKey;
/** Functions */

/**
 * @param action cast=(NSString*)
 */
alias Cocoa.NSAccessibilityActionDescription NSAccessibilityActionDescription;
/**
 * @param element cast=(id)
 * @param notification cast=(NSString*)
 */
alias Cocoa.NSAccessibilityPostNotification NSAccessibilityPostNotification;
/**
* @param element cast=(id)
* @param attribute cast=(NSString*)
* @param value cast=(id)
*/
alias Cocoa.NSAccessibilityRaiseBadArgumentException NSAccessibilityRaiseBadArgumentException;
/**
* @param role cast=(NSString*)
* @param subrole cast=(NSString*)
*/
alias Cocoa.NSAccessibilityRoleDescription NSAccessibilityRoleDescription;
/**
* @param element cast=(id)
*/
alias Cocoa.NSAccessibilityRoleDescriptionForUIElement NSAccessibilityRoleDescriptionForUIElement;
/**
* @param element cast=(id)
*/
alias Cocoa.NSAccessibilityUnignoredAncestor NSAccessibilityUnignoredAncestor;
/**
* @param originalChildren cast=(NSArray*)
*/
alias Cocoa.NSAccessibilityUnignoredChildren NSAccessibilityUnignoredChildren;
/**
* @param originalChild cast=(id)
*/
alias Cocoa.NSAccessibilityUnignoredChildrenForOnlyChild NSAccessibilityUnignoredChildrenForOnlyChild;
/**
* @param element cast=(id)
*/
alias Cocoa.NSAccessibilityUnignoredDescendant NSAccessibilityUnignoredDescendant;
alias Cocoa.NSBeep NSBeep;
/**
* @param depth cast=(NSWindowDepth)
*/
alias Cocoa.NSBitsPerPixelFromDepth NSBitsPerPixelFromDepth;
/**
 * @param srcGState cast=(NSInteger)
 * @param srcRect flags=struct
 * @param destPoint flags=struct
 */
alias Cocoa.NSCopyBits NSCopyBits;
/**
 * @param colorSpaceName cast=(NSString*)
 */
alias Cocoa.NSNumberOfColorComponents NSNumberOfColorComponents;
/**
 * @param theData cast=(CFDataRef)
 */
alias Carbon.CFDataGetBytePtr CFDataGetBytePtr;
/**
 * @param theData cast=(CFDataRef)
 */
alias Carbon.CFDataGetLength CFDataGetLength;
/**
 * @param srcGState cast=(NSInteger)
 * @param srcRect flags=struct
 * @param destPoint flags=struct
 */
public static final native void NSCopyBits(int /*long*/ srcGState, NSRect srcRect, NSPoint destPoint);
/**
 * @param colorSpaceName cast=(NSString*)
 */
public static final native int /*long*/ NSNumberOfColorComponents(int /*long*/ colorSpaceName);
/**
 * @param theData cast=(CFDataRef)
 */
public static final native int /*long*/ CFDataGetBytePtr(int /*long*/ theData);
/**
 * @param theData cast=(CFDataRef)
 */
public static final native int /*long*/ CFDataGetLength(int /*long*/ theData);
/**
* @param cf cast=(CFTypeRef)
*/
alias Carbon.CFRelease CFRelease;
/**
 * @param rl cast=(CFRunLoopRef)
 * @param observer cast=(CFRunLoopObserverRef)
 * @param mode cast=(CFStringRef)
 */
public static final native void CFRunLoopAddObserver(int /*long*/ rl, int /*long*/ observer, int /*long*/ mode);
public static final native int /*long*/ CFRunLoopGetCurrent();
/**
 * @param allocator cast=(CFAllocatorRef)
 * @param activities cast=(CFOptionFlags)
 * @param repeats cast=(Boolean)
 * @param order cast=(CFIndex)
 * @param callout cast=(CFRunLoopObserverCallBack)
 * @param context cast=(CFRunLoopObserverContext*)
 */
public static final native int /*long*/ CFRunLoopObserverCreate(int /*long*/ allocator, int /*long*/ activities, bool repeats, int /*long*/ order, int /*long*/ callout, int /*long*/ context);
/**
 * @param observer cast=(CFRunLoopObserverRef)
 */
public static final native void CFRunLoopObserverInvalidate(int /*long*/ observer);
/**
 */
alias Carbon.CFRunLoopAddObserver CFRunLoopAddObserver;
alias Carbon.CFRunLoopGetCurrent CFRunLoopGetCurrent;
/**
 * @param allocator cast=(CFAllocatorRef)
 * @param activities cast=(CFOptionFlags)
 * @param repeats cast=(Boolean)
 * @param order cast=(CFIndex)
 * @param callout cast=(CFRunLoopObserverCallBack)
 * @param context cast=(CFRunLoopObserverContext*)
 */
alias Carbon.CFRunLoopObserverCreate CFRunLoopObserverCreate;
public static final native int /*long*/ CGBitmapContextCreate(int /*long*/ data, int /*long*/ width, int /*long*/ height, int /*long*/ bitsPerComponent, int /*long*/ bytesPerRow, int /*long*/ colorspace, int bitmapInfo);
/**
 * @param c cast=(CGContextRef)
 */
public static final native int /*long*/ CGBitmapContextCreateImage(int /*long*/ c);
/**
 * @param c cast=(CGContextRef)
 */
public static final native int /*long*/ CGBitmapContextGetData(int /*long*/ c);
public static final native int /*long*/ CGColorSpaceCreateDeviceRGB();
/**
 * @param space cast=(CGColorSpaceRef)
 */
public static final native void CGColorSpaceRelease(int /*long*/ space);
/**
 * @param context cast=(CGContextRef)
 * @param path cast=(CGPathRef)
 */
public static final native void CGContextAddPath(int /*long*/ context, int /*long*/ path);
/**
 * @param c cast=(CGContextRef)
 * @param rect flags=struct
 * @param image cast=(CGImageRef)
 */
public static final native void CGContextDrawImage(int /*long*/ c, CGRect rect, int /*long*/ image);
/**
 * @param c cast=(CGContextRef)
 */
public static final native void CGContextRelease(int /*long*/ c);
/**
 * @param c cast=(CGContextRef)
 */
public static final native void CGContextReplacePathWithStrokedPath(int /*long*/ c);
/**
 * @param c cast=(CGContextRef)
 */
public static final native void CGContextRestoreGState(int /*long*/ c);
/**
 * @param c cast=(CGContextRef)
 */
public static final native void CGContextSaveGState(int /*long*/ c);
/**
 * @param c cast=(CGContextRef)
 * @param sx cast=(CGFloat)
 * @param sy cast=(CGFloat)
 */
public static final native void CGContextScaleCTM(int /*long*/ c, float /*double*/ sx, float /*double*/ sy);
/**
 * @param context cast=(CGContextRef)
 * @param mode cast=(CGBlendMode)
 */
public static final native void CGContextSetBlendMode(int /*long*/ context, int mode);
/**
 * @param c cast=(CGContextRef)
 * @param cap cast=(CGLineCap)
 */
public static final native void CGContextSetLineCap(int /*long*/ c, int cap);
/**
 * @param c cast=(CGContextRef)
 * @param phase cast=(CGFloat)
 * @param lengths cast=(CGFloat*)
 * @param count cast=(size_t)
 */
public static final native void CGContextSetLineDash(int /*long*/ c, float /*double*/ phase, float[] lengths, int /*long*/ count);
/**
 * @param c cast=(CGContextRef)
 * @param join cast=(CGLineJoin)
 */
public static final native void CGContextSetLineJoin(int /*long*/ c, int join);
/**
 * @param c cast=(CGContextRef)
 * @param width cast=(CGFloat)
 */
public static final native void CGContextSetLineWidth(int /*long*/ c, float /*double*/ width);
/**
 * @param c cast=(CGContextRef)
 * @param limit cast=(CGFloat)
 */
public static final native void CGContextSetMiterLimit(int /*long*/ c, float /*double*/ limit);
/**
 * @param c cast=(CGContextRef)
 */
public static final native void CGContextStrokePath(int /*long*/ c);
/**
 * @param c cast=(CGContextRef)
 * @param tx cast=(CGFloat)
 * @param ty cast=(CGFloat)
 */
public static final native void CGContextTranslateCTM(int /*long*/ c, float /*double*/ tx, float /*double*/ ty);
/**
 * @param info cast=(void*)
 * @param data cast=(void*)
 * @param size cast=(size_t)
 * @param releaseData cast=(CGDataProviderReleaseDataCallback)
 */
public static final native int /*long*/ CGDataProviderCreateWithData(int /*long*/ info, int /*long*/ data, int /*long*/ size, int /*long*/ releaseData);
/**
 * @param provider cast=(CGDataProviderRef)
 */
public static final native void CGDataProviderRelease(int /*long*/ provider);
/**
 * @param display cast=(CGDirectDisplayID)
 */
public static final native int /*long*/ CGDisplayBaseAddress(int display);
/**
 * @param display cast=(CGDirectDisplayID)
 */
public static final native int /*long*/ CGDisplayBitsPerPixel(int display);
/**
 * @param display cast=(CGDirectDisplayID)
 */
public static final native int /*long*/ CGDisplayBitsPerSample(int display);
/**
 * @param display cast=(CGDirectDisplayID)
 */
public static final native int /*long*/ CGDisplayBytesPerRow(int display);
/**
 * @param display cast=(CGDirectDisplayID)
 */
public static final native int /*long*/ CGDisplayPixelsHigh(int display);
/**
 * @param display cast=(CGDirectDisplayID)
 */
public static final native int /*long*/ CGDisplayPixelsWide(int display);
/**
 * @param doCombineState cast=(bool_t)
 */
public static final native int CGEnableEventStateCombining(int doCombineState);
/**
 * @param source cast=(CGEventSourceRef)
 * @param virtualKey cast=(CGKeyCode)
 * @param keyDown cast=(_Bool)
 */
public static final native int /*long*/ CGEventCreateKeyboardEvent(int /*long*/ source, short virtualKey, bool keyDown);
/**
 * @param event cast=(CGEventRef)
 * @param field cast=(CGEventField)
 */
public static final native long CGEventGetIntegerValueField(int /*long*/ event, int field);
/**
 * @param event cast=(CGEventRef)
 * @param stringLength cast=(UniCharCount)
 * @param unicodeString cast=(UniChar*)
 */
public static final native void CGEventKeyboardSetUnicodeString(int /*long*/ event, int /*long*/ stringLength, char[] unicodeString);
/**
 * @param tap cast=(CGEventTapLocation)
 * @param event cast=(CGEventRef)
 */
public static final native void CGEventPost(int tap, int /*long*/ event);
/**
 * @param rect flags=struct
 * @param maxDisplays cast=(CGDisplayCount)
 * @param dspys cast=(CGDirectDisplayID*)
 * @param dspyCnt cast=(CGDisplayCount*)
 */
public static final native int CGGetDisplaysWithRect(CGRect rect, int maxDisplays, int /*long*/ dspys, int /*long*/ dspyCnt);
/**
 * @param width cast=(size_t)
 * @param height cast=(size_t)
 * @param bitsPerComponent cast=(size_t)
 * @param bitsPerPixel cast=(size_t)
 * @param bytesPerRow cast=(size_t)
 * @param colorspace cast=(CGColorSpaceRef)
 * @param bitmapInfo cast=(CGBitmapInfo)
 * @param provider cast=(CGDataProviderRef)
 * @param decode cast=(CGFloat*)
 * @param shouldInterpolate cast=(_Bool)
 * @param intent cast=(CGColorRenderingIntent)
 */
public static final native int /*long*/ CGImageCreate(int /*long*/ width, int /*long*/ height, int /*long*/ bitsPerComponent, int /*long*/ bitsPerPixel, int /*long*/ bytesPerRow, int /*long*/ colorspace, int bitmapInfo, int /*long*/ provider, int /*long*/ decode, bool shouldInterpolate, int intent);
/**
 * @param image cast=(CGImageRef)
 */
public static final native int /*long*/ CGImageGetHeight(int /*long*/ image);
/**
 * @param image cast=(CGImageRef)
 */
public static final native int /*long*/ CGImageGetWidth(int /*long*/ image);
/**
 * @param image cast=(CGImageRef)
 */
public static final native void CGImageRelease(int /*long*/ image);
/**
 * @param path cast=(CGMutablePathRef)
 * @param m cast=(CGAffineTransform*)
 * @param cp1x cast=(CGFloat)
 * @param cp1y cast=(CGFloat)
 * @param cp2x cast=(CGFloat)
 * @param cp2y cast=(CGFloat)
 * @param x cast=(CGFloat)
 * @param y cast=(CGFloat)
 */
public static final native void CGPathAddCurveToPoint(int /*long*/ path, int /*long*/ m, float /*double*/ cp1x, float /*double*/ cp1y, float /*double*/ cp2x, float /*double*/ cp2y, float /*double*/ x, float /*double*/ y);
/**
 * @param path cast=(CGMutablePathRef)
 * @param m cast=(CGAffineTransform*)
 * @param x cast=(CGFloat)
 * @param y cast=(CGFloat)
 */
public static final native void CGPathAddLineToPoint(int /*long*/ path, int /*long*/ m, float /*double*/ x, float /*double*/ y);
/**
 * @param path cast=(CGPathRef)
 * @param info cast=(void*)
 * @param function cast=(CGPathApplierFunction)
 */
public static final native void CGPathApply(int /*long*/ path, int /*long*/ info, int /*long*/ function);
/**
 * @param path cast=(CGMutablePathRef)
 */
public static final native void CGPathCloseSubpath(int /*long*/ path);
/**
 * @param path cast=(CGPathRef)
 */
public static final native int /*long*/ CGPathCreateCopy(int /*long*/ path);
public static final native int /*long*/ CGPathCreateMutable();
/**
 * @param path cast=(CGMutablePathRef)
 * @param m cast=(CGAffineTransform*)
 * @param x cast=(CGFloat)
 * @param y cast=(CGFloat)
 */
public static final native void CGPathMoveToPoint(int /*long*/ path, int /*long*/ m, float /*double*/ x, float /*double*/ y);
/**
 * @param path cast=(CGPathRef)
 */
public static final native void CGPathRelease(int /*long*/ path);
/**
 * @param keyChar cast=(CGCharCode)
 * @param virtualKey cast=(CGKeyCode)
 * @param keyDown cast=(bool_t)
 */
public static final native int CGPostKeyboardEvent(short keyChar, short virtualKey, bool keyDown);
/**
 * @param mouseCursorPosition flags=struct
 * @param updateMouseCursorPosition cast=(bool_t)
 * @param buttonCount cast=(CGButtonCount)
 * @param mouseButtonDown cast=(bool_t)
 */
public static final native int CGPostMouseEvent(CGPoint mouseCursorPosition, bool updateMouseCursorPosition, int buttonCount, bool mouseButtonDown, bool varArg0, bool varArg1, bool varArg2, bool varArg3);
/**
 * @param wheelCount cast=(CGWheelCount)
 * @param wheel1 cast=(int32_t)
 */
public static final native int CGPostScrollWheelEvent(int wheelCount, int wheel1);
/**
 * @param filter cast=(CGEventFilterMask)
 * @param state cast=(CGEventSuppressionState)
 */
public static final native int CGSetLocalEventsFilterDuringSuppressionState(int filter, int state);
/**
 * @param seconds cast=(CFTimeInterval)
 */
public static final native int CGSetLocalEventsSuppressionInterval(double seconds);
/**
 * @param newCursorPosition flags=struct
 */
/**
 * @param observer cast=(CFRunLoopObserverRef)
 * @param bRect flags=struct
 */
public static final native bool NSEqualRects(NSRect aRect, NSRect bRect);
/**
 */
alias Carbon.CFRunLoopObserverInvalidate CFRunLoopObserverInvalidate;
/**
* @param allocator cast=(CFAllocatorRef)
* @param originalString cast=(CFStringRef)
* @param charactersToLeaveUnescaped cast=(CFStringRef)
* @param legalURLCharactersToBeEscaped cast=(CFStringRef)
* @param encoding cast=(CFStringEncoding)
*/
alias Carbon.CFURLCreateStringByAddingPercentEscapes CFURLCreateStringByAddingPercentEscapes;
/**
 * @param data cast=(void*)
 * @param width cast=(size_t)
 * @param height cast=(size_t)
 * @param bitsPerComponent cast=(size_t)
 * @param bytesPerRow cast=(size_t)
 * @param colorspace cast=(CGColorSpaceRef)
 * @param bitmapInfo cast=(CGBitmapInfo)
 */
alias Cocoa.CGBitmapContextCreate CGBitmapContextCreate;
/** Super Sends */

/**
 * @method flags=cast
 * @param arg0 flags=struct
 */
public static final native bool objc_msgSendSuper_bool(objc_super superId, int /*long*/ sel, NSRange arg0, int /*long*/ arg1);
/** @method flags=cast */
public static final native int /*long*/ objc_msgSendSuper(objc_super superId, int /*long*/ sel);
/**
 * @method flags=cast
 * @param arg0 flags=struct
 */
public static final native int /*long*/ objc_msgSendSuper(objc_super superId, int /*long*/ sel, NSPoint arg0);
/**
 * @method flags=cast
 * @param arg0 flags=struct
 */
public static final native int /*long*/ objc_msgSendSuper(objc_super superId, int /*long*/ sel, NSRect arg0);
/**
 * @method flags=cast
 * @param arg0 flags=struct
 */
public static final native int /*long*/ objc_msgSendSuper(objc_super superId, int /*long*/ sel, NSRect arg0, int /*long*/ arg1);
/**
 * @method flags=cast
 * @param arg0 flags=struct
 */
public static final native int /*long*/ objc_msgSendSuper(objc_super superId, int /*long*/ sel, NSSize arg0);
/** @method flags=cast */
public static final native int /*long*/ objc_msgSendSuper(objc_super superId, int /*long*/ sel, bool arg0);
/** @method flags=cast */
public static final native int /*long*/ objc_msgSendSuper(objc_super superId, int /*long*/ sel, int /*long*/ arg0);
/**
 * @method flags=cast
 * @param arg1 flags=struct
 */
public static final native int /*long*/ objc_msgSendSuper(objc_super superId, int /*long*/ sel, int /*long*/ arg0, NSPoint arg1, int /*long*/ arg2);
/**
 * @method flags=cast
 * @param arg1 flags=struct
 */
public static final native int /*long*/ objc_msgSendSuper(objc_super superId, int /*long*/ sel, int /*long*/ arg0, NSRect arg1, int /*long*/ arg2);
/** @method flags=cast */
public static final native int /*long*/ objc_msgSendSuper(objc_super superId, int /*long*/ sel, int /*long*/ arg0, bool arg1);
/** @method flags=cast */
public static final native int /*long*/ objc_msgSendSuper(objc_super superId, int /*long*/ sel, int /*long*/ arg0, int /*long*/ arg1);
/** @method flags=cast */
public static final native int /*long*/ objc_msgSendSuper(objc_super superId, int /*long*/ sel, int /*long*/ arg0, int /*long*/ arg1, int /*long*/ arg2, bool arg3);
/** @method flags=cast */
public static final native int /*long*/ objc_msgSendSuper(objc_super superId, int /*long*/ sel, int /*long*/ arg0, int /*long*/ arg1, int /*long*/ arg2, int /*long*/ arg3);
/**
 * @method flags=cast
 * @param arg0 flags=struct
 */
public static final native void objc_msgSendSuper_stret(NSRect result, objc_super superId, int /*long*/ sel, NSRect arg0);
/**
 * @method flags=cast
 * @param arg0 flags=struct
 */
public static final native void objc_msgSendSuper_stret(NSRect result, objc_super superId, int /*long*/ sel, NSRect arg0, int /*long*/ arg1);
/** @method flags=cast */
public static final native void objc_msgSendSuper_stret(NSSize result, objc_super superId, int /*long*/ sel);

/**
 * @param c cast=(CGContextRef)
 */
alias Cocoa.CGBitmapContextCreateImage CGBitmapContextCreateImage;
/**
 * @param c cast=(CGContextRef)
 */
alias Cocoa.CGBitmapContextGetData CGBitmapContextGetData;
alias Cocoa.CGColorSpaceCreateDeviceRGB CGColorSpaceCreateDeviceRGB;
 * @method flags=cast
 * @param arg0 flags=struct
 */
/**
 * @method flags=cast
 * @param arg1 flags=struct
 */
public static final native bool objc_msgSend_bool(int /*long*/ id, int /*long*/ sel, int /*long*/ arg0, NSPoint arg1);
/**
 * @method flags=cast
 * @param arg1 flags=struct
 */
public static final native bool objc_msgSend_bool(int /*long*/ id, int /*long*/ sel, int /*long*/ arg0, NSSize arg1, bool arg2);
/**
 * @param space cast=(CGColorSpaceRef)
 */
alias Cocoa.CGColorSpaceRelease CGColorSpaceRelease;
/**
 * @param context cast=(CGContextRef)
 * @param path cast=(CGPathRef)
 */
alias Cocoa.CGContextAddPath CGContextAddPath;
/**
 * @param c cast=(CGContextRef)
 * @param rect flags=struct
 * @param image cast=(CGImageRef)
 */
alias Cocoa.CGContextDrawImage CGContextDrawImage;
/**
 * @param c cast=(CGContextRef)
 */
alias Cocoa.CGContextRelease CGContextRelease;
/**
 * @param c cast=(CGContextRef)
 */
alias Cocoa.CGContextReplacePathWithStrokedPath CGContextReplacePathWithStrokedPath;
/**
 * @param c cast=(CGContextRef)
 */
alias Cocoa.CGContextRestoreGState CGContextRestoreGState;
/**
 * @param c cast=(CGContextRef)
 */
alias Cocoa.CGContextSaveGState CGContextSaveGState;
/**
 * @param c cast=(CGContextRef)
 * @param sx cast=(CGFloat)
 * @param sy cast=(CGFloat)
 */
alias Cocoa.CGContextScaleCTM CGContextScaleCTM;
/**
 * @param context cast=(CGContextRef)
 * @param mode cast=(CGBlendMode)
 */
alias Cocoa.CGContextSetBlendMode CGContextSetBlendMode;
/**
 * @param c cast=(CGContextRef)
 * @param cap cast=(CGLineCap)
 */
alias Cocoa.CGContextSetLineCap CGContextSetLineCap;
/**
 * @param c cast=(CGContextRef)
 * @param phase cast=(CGFloat)
 * @param lengths cast=(CGFloat*)
 * @param count cast=(size_t)
public static final native int /*long*/ objc_msgSend(int /*long*/ id, int /*long*/ sel, NSRange arg0, NSRange arg1, int /*long*/ arg2, int /*long*/ arg3);
/**
 * @method flags=cast
 * @param arg0 flags=struct
 */
alias Cocoa.CGContextSetLineDash CGContextSetLineDash;
/**
 * @param c cast=(CGContextRef)
 * @param join cast=(CGLineJoin)
 */
alias Cocoa.CGContextSetLineJoin CGContextSetLineJoin;
/**
 * @method flags=cast
 * @param arg0 flags=struct
 */
/**
 * @param c cast=(CGContextRef)
 * @param width cast=(CGFloat)
 */
alias Cocoa.CGContextSetLineWidth CGContextSetLineWidth;
/**
 * @param c cast=(CGContextRef)
 * @param limit cast=(CGFloat)
 */
alias Cocoa.CGContextSetMiterLimit CGContextSetMiterLimit;
/**
 * @param c cast=(CGContextRef)
 */
alias Cocoa.CGContextStrokePath CGContextStrokePath;
/**
 * @param c cast=(CGContextRef)
 * @param tx cast=(CGFloat)
 * @param ty cast=(CGFloat)
 */
alias Cocoa.CGContextTranslateCTM CGContextTranslateCTM;
/**
 * @param info cast=(void*)
 * @param data cast=(void*)
 * @param size cast=(size_t)
 * @param releaseData cast=(CGDataProviderReleaseDataCallback)
 */
alias Cocoa.CGDataProviderCreateWithData CGDataProviderCreateWithData;
/**
 * @method flags=cast
 * @param arg0 flags=struct
 */
/**
 * @param provider cast=(CGDataProviderRef)
 */
alias Cocoa.CGDataProviderRelease CGDataProviderRelease;
/**
 * @param display cast=(CGDirectDisplayID)
 */
alias Cocoa.CGDisplayBaseAddress CGDisplayBaseAddress;
/**
 * @param display cast=(CGDirectDisplayID)
 */
alias Cocoa.CGDisplayBitsPerPixel CGDisplayBitsPerPixel;
/**
 * @param display cast=(CGDirectDisplayID)
 */
alias Cocoa.CGDisplayBitsPerSample CGDisplayBitsPerSample;
/**
 * @param display cast=(CGDirectDisplayID)
 */
alias Cocoa.CGDisplayBytesPerRow CGDisplayBytesPerRow;
/**
 * @param display cast=(CGDirectDisplayID)
 */
alias Cocoa.CGDisplayPixelsHigh CGDisplayPixelsHigh;
/**
 * @param display cast=(CGDirectDisplayID)
 */
alias Cocoa.CGDisplayPixelsWide CGDisplayPixelsWide;
/**
 * @method flags=cast
 * @param arg0 flags=struct
 */
/**
 * @param doCombineState cast=(bool_t)
 */
alias Cocoa.CGEnableEventStateCombining CGEnableEventStateCombining;
public static final native int /*long*/ objc_msgSend(int /*long*/ id, int /*long*/ sel, float /*double*/ arg0, int /*long*/ arg1);
/** @method flags=cast */
/**
 * @param source cast=(CGEventSourceRef)
 * @param virtualKey cast=(CGKeyCode)
 * @param keyDown cast=(_Bool)
 */
alias Cocoa.CGEventCreateKeyboardEvent CGEventCreateKeyboardEvent;
/**
 * @param event cast=(CGEventRef)
 * @param field cast=(CGEventField)
 */
alias Cocoa.CGEventGetIntegerValueField CGEventGetIntegerValueField;
/**
 * @param event cast=(CGEventRef)
 * @param stringLength cast=(UniCharCount)
 * @param unicodeString cast=(UniChar*)
 */
alias Cocoa.CGEventKeyboardSetUnicodeString CGEventKeyboardSetUnicodeString;
/**
 * @method flags=cast
 * @param arg1 flags=struct
 */
public static final native int /*long*/ objc_msgSend(int /*long*/ id, int /*long*/ sel, int /*long*/ arg0, NSPoint arg1, int /*long*/ arg2, double arg3, int /*long*/ arg4, int /*long*/ arg5, int /*long*/ arg6, int /*long*/ arg7, int /*long*/ arg8);
/**
 * @method flags=cast
 * @param arg1 flags=struct
 */
/**
 * @param tap cast=(CGEventTapLocation)
 * @param event cast=(CGEventRef)
 */
alias Cocoa.CGEventPost CGEventPost;
/**
 * @method flags=cast
 * @param arg1 flags=struct
 */
public static final native int /*long*/ objc_msgSend(int /*long*/ id, int /*long*/ sel, int /*long*/ arg0, NSRect arg1, int /*long*/ arg2);
/**
 * @param rect flags=struct
 * @param maxDisplays cast=(CGDisplayCount)
 * @param dspys cast=(CGDirectDisplayID*)
 * @param dspyCnt cast=(CGDisplayCount*)
 */
alias Cocoa.CGGetDisplaysWithRect CGGetDisplaysWithRect;
public static final native int /*long*/ objc_msgSend(int /*long*/ id, int /*long*/ sel, int /*long*/ arg0, int /*long*/ arg1, int /*long*/ arg2, float /*double*/ arg3);
/** @method flags=cast */
public static final native long objc_msgSend(long id, long sel, int[] arg0);
/** @method flags=cast */
public static final native long objc_msgSend(long id, long sel, long[] arg0, long arg1, long arg2);
/** @method flags=cast */
/**
 * @param width cast=(size_t)
 * @param height cast=(size_t)
 * @param bitsPerComponent cast=(size_t)
 * @param bitsPerPixel cast=(size_t)
 * @param bytesPerRow cast=(size_t)
 * @param colorspace cast=(CGColorSpaceRef)
 * @param bitmapInfo cast=(CGBitmapInfo)
 * @param provider cast=(CGDataProviderRef)
 * @param decode cast=(CGFloat*)
 * @param shouldInterpolate cast=(_Bool)
 * @param intent cast=(CGColorRenderingIntent)
 */
alias Cocoa.CGImageCreate CGImageCreate;
/**
 * @param image cast=(CGImageRef)
 */
alias Cocoa.CGImageGetHeight CGImageGetHeight;
/**
 * @param image cast=(CGImageRef)
 */
alias Cocoa.CGImageGetWidth CGImageGetWidth;
/**
 * @method flags=cast
 * @param arg0 flags=struct
 */
/**
 * @param image cast=(CGImageRef)
 */
alias Cocoa.CGImageRelease CGImageRelease;
/**
 * @param path cast=(CGMutablePathRef)
 * @param m cast=(CGAffineTransform*)
 * @param cp1x cast=(CGFloat)
 * @param cp1y cast=(CGFloat)
 * @param cp2x cast=(CGFloat)
 * @param cp2y cast=(CGFloat)
 * @param x cast=(CGFloat)
 * @param y cast=(CGFloat)
 */
alias Cocoa.CGPathAddCurveToPoint CGPathAddCurveToPoint;
/**
 * @param path cast=(CGMutablePathRef)
 * @param m cast=(CGAffineTransform*)
 * @param x cast=(CGFloat)
 * @param y cast=(CGFloat)
 */
alias Cocoa.CGPathAddLineToPoint CGPathAddLineToPoint;
/**
 * @param path cast=(CGPathRef)
 * @param info cast=(void*)
 * @param function cast=(CGPathApplierFunction)
 */
alias Cocoa.CGPathApply CGPathApply;
/**
 * @param path cast=(CGMutablePathRef)
 */
alias Cocoa.CGPathCloseSubpath CGPathCloseSubpath;
/**
 * @param path cast=(CGPathRef)
 */
alias Cocoa.CGPathCreateCopy CGPathCreateCopy;
alias Cocoa.CGPathCreateMutable CGPathCreateMutable;
/**
 * @param path cast=(CGMutablePathRef)
 * @param m cast=(CGAffineTransform*)
 * @param x cast=(CGFloat)
 * @param y cast=(CGFloat)
 */
alias Cocoa.CGPathMoveToPoint CGPathMoveToPoint;
public static final native int CGPathElement_sizeof();
/**
 * @param dest cast=(void *),flags=no_in critical
 * @param src cast=(void *),flags=critical
 */
public static final native void memmove(int /*long*/ dest, CGPathElement src, int /*long*/ size);
/**
 * @param dest cast=(void *),flags=no_in critical
 * @param src cast=(void *),flags=critical
 */
public static final native void memmove(CGPathElement dest, int /*long*/ src, int /*long*/ size);
/**
 * @param path cast=(CGPathRef)
 */
alias Cocoa.CGPathRelease CGPathRelease;
/**
 * @param keyChar cast=(CGCharCode)
 * @param virtualKey cast=(CGKeyCode)
 * @param keyDown cast=(bool_t)
 */
alias Cocoa.CGPostKeyboardEvent CGPostKeyboardEvent;
/**
 * @param mouseCursorPosition flags=struct
 * @param updateMouseCursorPosition cast=(bool_t)
 * @param buttonCount cast=(CGButtonCount)
 * @param mouseButtonDown cast=(bool_t)
 */
alias Cocoa.CGPostMouseEvent CGPostMouseEvent;
/**
 * @param wheelCount cast=(CGWheelCount)
 * @param wheel1 cast=(int32_t)
 */
alias Cocoa.CGPostScrollWheelEvent CGPostScrollWheelEvent;
/**
 * @param filter cast=(CGEventFilterMask)
 * @param state cast=(CGEventSuppressionState)
 */
alias Cocoa.CGSetLocalEventsFilterDuringSuppressionState CGSetLocalEventsFilterDuringSuppressionState;
/**
 * @param seconds cast=(CFTimeInterval)
 */
alias Cocoa.CGSetLocalEventsSuppressionInterval CGSetLocalEventsSuppressionInterval;
/**
 * @param newCursorPosition flags=struct
 */
/**
 * @param aRect flags=struct
 * @param bRect flags=struct
 */
alias Cocoa.NSEqualRects NSEqualRects;
/**
* @param hfsFileTypeCode cast=(OSType)
*/
alias Cocoa.NSFileTypeForHFSTypeCode NSFileTypeForHFSTypeCode;
/**
* @param typePtr cast=(char*)
* @param sizep cast=(NSUInteger*)
* @param alignp cast=(NSUInteger*)
*/
alias Cocoa.NSGetSizeAndAlignment NSGetSizeAndAlignment;
/**
 * @param aPoint flags=struct
 * @param aRect flags=struct
 */
alias Cocoa.NSPointInRect NSPointInRect;
/**
* @param directory cast=(NSSearchPathDirectory)
* @param domainMask cast=(NSSearchPathDomainMask)
* @param expandTilde cast=(BOOL)
*/
alias Cocoa.NSSearchPathForDirectoriesInDomains NSSearchPathForDirectoriesInDomains;
alias Cocoa.NSTemporaryDirectory NSTemporaryDirectory;

/** Super Sends */

/**
 * @method flags=cast
 * @param arg0 flags=struct
 */
alias objc.objc_msgSendSuper_bool objc_msgSendSuper_bool;
/** @method flags=cast */
alias objc.objc_msgSendSuper objc_msgSendSuper;
/**
 * @method flags=cast
 * @param arg0 flags=struct
 */
alias objc.objc_msgSendSuper_stret objc_msgSendSuper_stret;

/** Sends */

/** @method flags=cast */
alias objc.objc_msgSend_bool objc_msgSend_bool;
/**
 * @method flags=cast
 * @param arg0 flags=struct
 */
/** @method flags=cast */
alias objc.objc_msgSend_fpret objc_msgSend_fpret;
/** @method flags=cast */
alias objc.objc_msgSend objc_msgSend;
/** @method flags=cast */
alias objc.objc_msgSend_stret objc_msgSend_stret;

/** Sizeof natives */

/** Memmove natives */

/**
 * @param dest cast=(void *),flags=no_in critical
 * @param src cast=(void *),flags=critical
 */
alias stdc.memmove memmove;

/** This section is auto generated */
}
