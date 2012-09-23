module dwt.internal.c.custom;

import tango.stdc.stdlib;
import tango.stdc.string;

import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSRange;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSSize;
import dwt.internal.objc.cocoa.Cocoa;
import dwt.internal.objc.runtime;

extern (C):

static IMP CALLBACK_1drawRect_1;

static void proc_CALLBACK_1drawRect_1(id obj, SEL sel, NSRect rect)
{
	alias extern (C) void function (id, SEL, NSRect*) Fp;
	(cast(Fp) CALLBACK_1drawRect_1)(obj, sel, &rect);
}

IMP CALLBACK_drawRect_ (IMP func)
{
	CALLBACK_1drawRect_1 = func;
	return cast(IMP) &proc_CALLBACK_1drawRect_1;
}



static IMP CALLBACK_1drawInteriorWithFrame_1inView_1;

static void proc_CALLBACK_1drawInteriorWithFrame_1inView_1(id obj, SEL sel, NSRect rect, id view)
{
	alias extern (C) void function (id, SEL, NSRect*, id) Fp;
	(cast(Fp) CALLBACK_1drawInteriorWithFrame_1inView_1)(obj, sel, &rect, view);
}

IMP CALLBACK_drawInteriorWithFrame_inView_ (IMP func)
{
	CALLBACK_1drawInteriorWithFrame_1inView_1 = func;
	return cast(IMP) &proc_CALLBACK_1drawInteriorWithFrame_1inView_1;
}



static IMP CALLBACK_1setFrame_1;

static void proc_CALLBACK_1setFrame_1(id obj, SEL sel, NSRect rect)
{
	alias extern (C) void function (id, SEL, NSRect*) Fp;
	(cast(Fp) CALLBACK_1setFrame_1)(obj, sel, &rect);
}

IMP CALLBACK_setFrame_ (IMP func)
{
	CALLBACK_1setFrame_1 = func;
	return cast(IMP) &proc_CALLBACK_1setFrame_1;
}



static IMP CALLBACK_1setFrameOrigin_1;

static void proc_CALLBACK_1setFrameOrigin_1(id obj, SEL sel, NSPoint point)
{
	alias extern (C) void function (id, SEL, NSPoint*) Fp;
	(cast(Fp) CALLBACK_1setFrameOrigin_1)(obj, sel, &point);
}

IMP CALLBACK_setFrameOrigin_ (IMP func)
{
	CALLBACK_1setFrameOrigin_1 = func;
	return cast(IMP) &proc_CALLBACK_1setFrameOrigin_1;
}



static IMP CALLBACK_1setFrameSize_1;

static void proc_CALLBACK_1setFrameSize_1(id obj, SEL sel, NSSize size)
{
	alias extern (C) void function (id, SEL, NSSize*) Fp;
	(cast(Fp) CALLBACK_1setFrameSize_1)(obj, sel, &size);
}

IMP CALLBACK_setFrameSize_ (IMP func)
{
    CALLBACK_1setFrameSize_1 = func;
	return cast(IMP) &proc_CALLBACK_1setFrameSize_1;
}



static IMP CALLBACK_1hitTest_1;

static void proc_CALLBACK_1hitTest_1(id obj, SEL sel, NSPoint point)
{
	alias extern (C) id function (id, SEL, NSPoint*) Fp;
	(cast(Fp) CALLBACK_1hitTest_1)(obj, sel, &point);
}

IMP CALLBACK_hitTest_ (IMP func)
{
    CALLBACK_1hitTest_1 = func;
	return cast(IMP) &proc_CALLBACK_1hitTest_1;
}



static IMP CALLBACK_1webView_1setFrame_1;

static void proc_CALLBACK_1webView_1setFrame_1(id obj, SEL sel, id sender, NSRect rect)
{
	alias extern (C) void function (id, SEL, id, NSRect*) Fp;
	(cast(Fp) CALLBACK_1webView_1setFrame_1)(obj, sel, sender, &rect);
}

IMP CALLBACK_webView_setFrame_ (IMP func)
{
    CALLBACK_1webView_1setFrame_1 = func;
	return cast(IMP) &proc_CALLBACK_1webView_1setFrame_1;
}




static IMP CALLBACK_1markedRange;

static NSRange proc_CALLBACK_1markedRange(id obj, SEL sel)
{
	alias extern (C) NSRange* function (id, SEL) Fp;

	NSRange* lprc = (cast(Fp) CALLBACK_1markedRange)(obj, sel);
	NSRange rc = void;
	if (lprc) {
		rc = *lprc;
		free(lprc);
	} else {
		memset(&rc, 0, NSRange.sizeof);
	}
	return rc;
}

IMP CALLBACK_markedRange (IMP func)
{
    CALLBACK_1markedRange = func;
	return cast(IMP) &proc_CALLBACK_1markedRange;
}



static IMP CALLBACK_1selectedRange;

static NSRange proc_CALLBACK_1selectedRange(id obj, SEL sel)
{
	alias extern (C) NSRange* function (id, SEL) Fp;

	NSRange* lprc = (cast(Fp) CALLBACK_1selectedRange)(obj, sel);
	NSRange rc = void;
	if (lprc) {
		rc = *lprc;
		free(lprc);
	} else {
		memset(&rc, 0, NSRange.sizeof);
	}
	return rc;
}

IMP CALLBACK_selectedRange (IMP func)
{
    CALLBACK_1selectedRange = func;
	return cast(IMP) &proc_CALLBACK_1selectedRange;
}



static IMP CALLBACK_1highlightSelectionInClipRect_1;

static void proc_CALLBACK_1highlightSelectionInClipRect_1(id obj, SEL sel, NSRect rect)
{
	alias extern (C) void function (id, SEL, NSRect*) Fp;
	(cast(Fp) CALLBACK_1highlightSelectionInClipRect_1)(obj, sel, &rect);
}

IMP CALLBACK_highlightSelectionInClipRect_ (IMP func)
{
    CALLBACK_1highlightSelectionInClipRect_1 = func;
	return cast(IMP) &proc_CALLBACK_1highlightSelectionInClipRect_1;
}



static IMP CALLBACK_1attributedSubstringFromRange_1;

static id proc_CALLBACK_1attributedSubstringFromRange_1(id obj, SEL sel, NSRange arg0)
{
	alias extern (C) id function (id, SEL, NSRange*) Fp;
	return (cast(Fp) CALLBACK_1attributedSubstringFromRange_1)(obj, sel, &arg0);
}

IMP CALLBACK_attributedSubstringFromRange_ (IMP func)
{
    CALLBACK_1attributedSubstringFromRange_1 = func;
	return cast(IMP) &proc_CALLBACK_1attributedSubstringFromRange_1;
}



static IMP CALLBACK_1setMarkedText_1selectedRange_1;

static void proc_CALLBACK_1setMarkedText_1selectedRange_1(id obj, SEL sel, id arg0, NSRange arg1)
{
	alias extern (C) void function (id, SEL, id, NSRange*) Fp;
	(cast(Fp) CALLBACK_1setMarkedText_1selectedRange_1)(obj, sel, arg0, &arg1);
}

IMP CALLBACK_setMarkedText_selectedRange_ (IMP func)
{
    CALLBACK_1setMarkedText_1selectedRange_1 = func;
	return cast(IMP) &proc_CALLBACK_1setMarkedText_1selectedRange_1;
}



static IMP CALLBACK_1characterIndexForPoint_1;

static NSUInteger proc_CALLBACK_1characterIndexForPoint_1(id obj, SEL sel, NSPoint point)
{
	alias extern (C) NSUInteger function (id, SEL, NSPoint*) Fp;
	return (cast(Fp) CALLBACK_1characterIndexForPoint_1)(obj, sel, &point);
}

IMP CALLBACK_characterIndexForPoint_ (IMP func)
{
    CALLBACK_1characterIndexForPoint_1 = func;
	return cast(IMP) &proc_CALLBACK_1characterIndexForPoint_1;
}



static IMP CALLBACK_1firstRectForCharacterRange_1;

static NSRect proc_CALLBACK_1firstRectForCharacterRange_1(id obj, SEL sel, NSRange arg0)
{
	alias extern (C) NSRect* function (id, SEL, NSRange*) Fp;

	NSRect* lprc = (cast(Fp) CALLBACK_1firstRectForCharacterRange_1)(obj, sel, &arg0);
	NSRect rc = void;
	if (lprc) {
		rc = *lprc;
		free(lprc);
	} else {
		memset(&rc, 0, NSRect.sizeof);
	}
	return rc;
}

IMP CALLBACK_firstRectForCharacterRange_ (IMP func)
{
    CALLBACK_1firstRectForCharacterRange_1 = func;
	return cast(IMP) &proc_CALLBACK_1firstRectForCharacterRange_1;
}



static IMP CALLBACK_1textView_1willChangeSelectionFromCharacterRange_1toCharacterRange_1;

static NSRange proc_CALLBACK_1textView_1willChangeSelectionFromCharacterRange_1toCharacterRange_1(id obj, SEL sel, id aTextView, NSRange oldSelectedCharRange, NSRange newSelectedCharRange)
{
	alias extern (C) NSRange* function (id, SEL, id, NSRange*, NSRange*) Fp;
	NSRange* lprc = (cast(Fp) CALLBACK_1textView_1willChangeSelectionFromCharacterRange_1toCharacterRange_1)(obj, sel, aTextView, &oldSelectedCharRange, &newSelectedCharRange);
	NSRange rc;
	if (lprc) {
		rc = *lprc;
		free(lprc);
	} else {
		memset(&rc, 0, NSRange.sizeof);
	}
	return rc;
}

IMP CALLBACK_textView_willChangeSelectionFromCharacterRange_toCharacterRange_ (IMP func)
{
    CALLBACK_1textView_1willChangeSelectionFromCharacterRange_1toCharacterRange_1 = func;
	return cast(IMP) &proc_CALLBACK_1textView_1willChangeSelectionFromCharacterRange_1toCharacterRange_1;
}



static IMP CALLBACK_1draggedImage_1beganAt_1;

static void proc_CALLBACK_1draggedImage_1beganAt_1 (id obj, SEL sel, id anImage, NSPoint aPoint)
{
	alias extern (C) void function (id, SEL, id, NSPoint*) Fp;
	(cast(Fp) CALLBACK_1draggedImage_1beganAt_1)(obj, sel, anImage, &aPoint);
}

IMP CALLBACK_draggedImage_beganAt_ (IMP func)
{
    CALLBACK_1draggedImage_1beganAt_1 = func;
	return cast(IMP) &proc_CALLBACK_1draggedImage_1beganAt_1;
}



static IMP CALLBACK_1draggedImage_1endedAt_1operation_1;

static void proc_CALLBACK_1draggedImage_1endedAt_1operation_1(id obj, SEL sel, id image, NSPoint point, NSDragOperation op)
{
	alias extern (C) void function (id, SEL, id, NSPoint*, NSDragOperation) Fp;
	return (cast(Fp) CALLBACK_1draggedImage_1endedAt_1operation_1)(obj, sel, image, &point, op);
}

IMP CALLBACK_draggedImage_endedAt_operation_ (IMP func)
{
    CALLBACK_1draggedImage_1endedAt_1operation_1 = func;
	return cast(IMP) &proc_CALLBACK_1draggedImage_1endedAt_1operation_1;
}



static IMP CALLBACK_1accessibilityHitTest_1;

static void proc_CALLBACK_1accessibilityHitTest_1(id obj, SEL sel, NSPoint point)
{
	alias extern (C) void function (id, SEL, NSPoint*) Fp;
	(cast(Fp) CALLBACK_1accessibilityHitTest_1)(obj, sel, &point);
}

IMP CALLBACK_accessibilityHitTest_ (IMP func)
{
    CALLBACK_1accessibilityHitTest_1 = func;
	return cast(IMP) &proc_CALLBACK_1accessibilityHitTest_1;
}



static IMP CALLBACK_1dragSelectionWithEvent_1offset_1slideBack_1;

bool proc_CALLBACK_1dragSelectionWithEvent_1offset_1slideBack_1 (id obj, SEL sel, id event, NSSize mouseOffset, bool slideBack)
{
	alias extern (C) bool function (id, SEL, id, NSSize*, bool) Fp;
	return (cast(Fp) CALLBACK_1dragSelectionWithEvent_1offset_1slideBack_1)(obj, sel, event, &mouseOffset, slideBack);
}

IMP CALLBACK_dragSelectionWithEvent_offset_slideBack_ (IMP func)
{
	CALLBACK_1dragSelectionWithEvent_1offset_1slideBack_1 = func;
	return cast (IMP) &proc_CALLBACK_1dragSelectionWithEvent_1offset_1slideBack_1;
}



static bool isFlippedProc(id obj, SEL sel)
{
	return true;
}

IMP isFlipped_CALLBACK ()
{
	return cast(IMP) &isFlippedProc;
}



static IMP CALLBACK_1canDragRowsWithIndexes_1atPoint_1;

static bool proc_CALLBACK_1canDragRowsWithIndexes_1atPoint_1 (id arg0, SEL arg1, id arg2, NSPoint arg3) {
	alias extern (C) bool function (id, SEL, id, NSPoint*) Fp;
	return (cast(Fp) CALLBACK_1canDragRowsWithIndexes_1atPoint_1)(arg0, arg1, arg2, &arg3);
}

static IMP CALLBACK_canDragRowsWithIndexes_atPoint_(IMP func) {
	CALLBACK_1canDragRowsWithIndexes_1atPoint_1 = func;
	return cast(IMP) &proc_CALLBACK_1canDragRowsWithIndexes_1atPoint_1;
}



static IMP CALLBACK_1cellSize;

static NSSize proc_CALLBACK_1cellSize(id arg0, SEL arg1) {
	alias extern (C) NSSize* function (id, SEL) Fp;

	NSSize* lprc = (cast(Fp) CALLBACK_1cellSize)(arg0, arg1);
	NSSize rc = void;
	if (lprc) {
		rc = *lprc;
		free(lprc);
	} else {
		memset(&rc, 0, NSSize.sizeof);
	}
	return rc;
}

static IMP CALLBACK_cellSize(IMP func) {
	CALLBACK_1cellSize = func;
	return cast(IMP) &proc_CALLBACK_1cellSize;
}



static IMP CALLBACK_1drawImage_1withFrame_1inView_1;

static void proc_CALLBACK_1drawImage_1withFrame_1inView_1(id arg0, SEL arg1, id arg2, NSRect arg3, id arg4) {
	alias extern (C) void function (id, SEL, id, NSRect*, id) Fp;
	(cast(Fp) CALLBACK_1drawImage_1withFrame_1inView_1)(arg0, arg1, arg2, &arg3, arg4);
}

static IMP CALLBACK_drawImage_withFrame_inView_(IMP func) {
	CALLBACK_1drawImage_1withFrame_1inView_1 = func;
	return cast(IMP) &proc_CALLBACK_1drawImage_1withFrame_1inView_1;
}



static IMP CALLBACK_1drawWithExpansionFrame_1inView_1;

static void proc_CALLBACK_1drawWithExpansionFrame_1inView_1(id arg0, SEL arg1, NSRect arg2, id arg3) {
	alias extern (C) void function (id, SEL, NSRect*, id) Fp;
	(cast(Fp) CALLBACK_1drawWithExpansionFrame_1inView_1)(arg0, arg1, &arg2, arg3);
}

static IMP CALLBACK_drawWithExpansionFrame_inView_(IMP func) {
	CALLBACK_1drawWithExpansionFrame_1inView_1 = func;
	return cast(IMP) &proc_CALLBACK_1drawWithExpansionFrame_1inView_1;
}



static IMP CALLBACK_1expansionFrameWithFrame_1inView_1;

static NSRect proc_CALLBACK_1expansionFrameWithFrame_1inView_1(id arg0, SEL arg1, NSRect arg2, id arg3) {
	alias extern (C) NSRect* function (id, SEL, NSRect*, id) Fp;

	NSRect* lprc = (cast(Fp) CALLBACK_1expansionFrameWithFrame_1inView_1)(arg0, arg1, &arg2, arg3);
	NSRect rc = void;
	if (lprc) {
		rc = *lprc;
		free(lprc);
	} else {
		memset(&rc, 0, NSRect.sizeof);
	}
	return rc;
}

static IMP CALLBACK_expansionFrameWithFrame_inView_(IMP func) {
	CALLBACK_1expansionFrameWithFrame_1inView_1 = func;
	return cast(IMP) &proc_CALLBACK_1expansionFrameWithFrame_1inView_1;
}



static IMP CALLBACK_1hitTestForEvent_1inRect_1ofView_1;

static NSUInteger proc_CALLBACK_1hitTestForEvent_1inRect_1ofView_1(id arg0, SEL arg1, id arg2, NSRect arg3, id arg4) {
	alias extern (C) NSUInteger function (id, SEL, id, NSRect*, id) Fp;
	return (cast(Fp) CALLBACK_1hitTestForEvent_1inRect_1ofView_1)(arg0, arg1, arg2, &arg3, arg4);
}

static IMP CALLBACK_hitTestForEvent_inRect_ofView_(IMP func) {
	CALLBACK_1hitTestForEvent_1inRect_1ofView_1 = func;
	return cast(IMP) &proc_CALLBACK_1hitTestForEvent_1inRect_1ofView_1;
}



static IMP CALLBACK_1imageRectForBounds_1;

static NSRect proc_CALLBACK_1imageRectForBounds_1(id arg0, SEL arg1, NSRect arg2) {
	alias extern (C) NSRect* function (id, SEL, NSRect*) Fp;

	NSRect* lprc = (cast(Fp) CALLBACK_1imageRectForBounds_1)(arg0, arg1, &arg2);
	NSRect rc = void;
	if (lprc) {
		rc = *lprc;
		free(lprc);
	} else {
		memset(&rc, 0, NSRect.sizeof);
	}
	return rc;
}

static IMP CALLBACK_imageRectForBounds_(IMP func) {
	CALLBACK_1imageRectForBounds_1 = func;
	return cast(IMP) &proc_CALLBACK_1imageRectForBounds_1;
}



static IMP CALLBACK_1setNeedsDisplayInRect_1;

static void proc_CALLBACK_1setNeedsDisplayInRect_1(id arg0, SEL arg1, NSRect arg2) {
	alias extern (C) void function (id, SEL, NSRect*) Fp;
	(cast(Fp)CALLBACK_1setNeedsDisplayInRect_1)(arg0, arg1, &arg2);
}

static IMP CALLBACK_setNeedsDisplayInRect_(IMP func) {
	CALLBACK_1setNeedsDisplayInRect_1 = func;
	return cast(IMP) &proc_CALLBACK_1setNeedsDisplayInRect_1;
}



static IMP CALLBACK_1shouldChangeTextInRange_1replacementString_1;

static bool proc_CALLBACK_1shouldChangeTextInRange_1replacementString_1(id arg0, SEL arg1, NSRange arg2, id arg3) {
	alias extern (C) bool function (id, SEL, NSRange*, id) Fp;
	return (cast(Fp)CALLBACK_1shouldChangeTextInRange_1replacementString_1)(arg0, arg1, &arg2, arg3);
}

static IMP CALLBACK_shouldChangeTextInRange_replacementString_(IMP func) {
	CALLBACK_1shouldChangeTextInRange_1replacementString_1 = func;
	return cast(IMP) &proc_CALLBACK_1shouldChangeTextInRange_1replacementString_1;
}



static IMP CALLBACK_1titleRectForBounds_1;

static NSRect proc_CALLBACK_1titleRectForBounds_1(id arg0, SEL arg1, NSRect arg2) {
	alias extern (C) NSRect* function (id, SEL, NSRect*) Fp;

	NSRect* lprc = (cast(Fp)CALLBACK_1titleRectForBounds_1)(arg0, arg1, &arg2);
	NSRect rc = void;
	if (lprc) {
		rc = *lprc;
		free(lprc);
	} else {
		memset(&rc, 0, NSRect.sizeof);
	}
	return rc;
}

static IMP CALLBACK_titleRectForBounds_(IMP func) {
	CALLBACK_1titleRectForBounds_1 = func;
	return cast(IMP) &proc_CALLBACK_1titleRectForBounds_1;
}



static IMP CALLBACK_1view_1stringForToolTip_1point_1userData_1;

static id proc_CALLBACK_1view_1stringForToolTip_1point_1userData_1(id arg0, SEL arg1, id arg2, NSToolTipTag arg3, NSPoint arg4, void* arg5) {
	alias extern (C) id function (id, SEL, id, NSToolTipTag, NSPoint*, void*) Fp;
	return (cast(Fp)CALLBACK_1view_1stringForToolTip_1point_1userData_1)(arg0, arg1, arg2, arg3, &arg4, arg5);
}

static IMP CALLBACK_view_stringForToolTip_point_userData_(IMP func) {
	CALLBACK_1view_1stringForToolTip_1point_1userData_1 = func;
	return cast(IMP) &proc_CALLBACK_1view_1stringForToolTip_1point_1userData_1;
}