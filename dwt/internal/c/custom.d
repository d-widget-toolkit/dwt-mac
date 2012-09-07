module dwt.internal.c.custom;

import tango.stdc.stdlib;

import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSRange;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSSize;
import dwt.internal.objc.cocoa.Cocoa;
import dwt.internal.objc.runtime;

extern (C):

static IMP drawRect_1CALLBACK;

static void drawRect(id obj, SEL sel, NSRect rect)
{
	return drawRect_1CALLBACK(obj, sel, &rect);
}

IMP drawRect_CALLBACK (IMP func)
{
	drawRect_1CALLBACK = func;
	return cast(IMP) &drawRect;
}



static IMP drawInteriorWithFrame_1inView_1CALLBACK;

static void drawInteriorWithFrame_1inView(id obj, SEL sel, NSRect rect, id view)
{
	return drawInteriorWithFrame_1inView_1CALLBACK(obj, sel, &rect, view);
}

IMP drawInteriorWithFrame_inView_CALLBACK (IMP func)
{
	drawInteriorWithFrame_1inView_1CALLBACK = func;
	return cast(IMP) &drawInteriorWithFrame_1inView;
}



static IMP setFrame_1CALLBACK;

static void setFrame(id obj, SEL sel, NSRect rect)
{
	return setFrame_1CALLBACK(obj, sel, &rect);
}

IMP setFrame_CALLBACK (IMP func)
{
	setFrame_1CALLBACK = func;
	return cast(IMP) &setFrame;
}



static IMP setFrameOrigin_1CALLBACK;

static void setFrameOrigin(id obj, SEL sel, NSPoint point)
{
	return setFrameOrigin_1CALLBACK(obj, sel, &point);
}

IMP setFrameOrigin_CALLBACK (IMP func)
{
	setFrameOrigin_1CALLBACK = func;
	return cast(IMP) &setFrameOrigin;
}



static IMP setFrameSize_1CALLBACK;

static void setFrameSize(id obj, SEL sel, NSSize size)
{
	return setFrameSize_1CALLBACK(obj, sel, &size);
}

IMP setFrameSize_CALLBACK (IMP func)
{
    setFrameSize_1CALLBACK = func;
	return cast(IMP) &setFrameSize;
}



static IMP hitTest_1CALLBACK;

static void hitTest(id obj, SEL sel, NSPoint point)
{
	return hitTest_1CALLBACK(obj, sel, &point);
}

IMP hitTest_CALLBACK (IMP func)
{
    hitTest_1CALLBACK = func;
	return cast(IMP) &hitTest;
}



static IMP webView_1setFrame_1CALLBACK;

static void webView_1setFrame(id obj, SEL sel, id sender, NSRect rect)
{
	return webView_1setFrame_1CALLBACK(obj, sel, sender, &rect);
}

IMP webView_setFrame_CALLBACK (IMP func)
{
    webView_1setFrame_1CALLBACK = func;
	return cast(IMP) &webView_1setFrame;
}




static IMP markedRange_1CALLBACK;

static NSRange markedRangeProc(id obj, SEL sel)
{
	NSRange* ptr = cast(NSRange*) markedRange_1CALLBACK(obj, sel);
	NSRange range = *ptr;
	free(ptr);
	return range;
}

IMP markedRange_CALLBACK (IMP func)
{
    markedRange_1CALLBACK = func;
	return cast(IMP) &markedRangeProc;
}



static IMP selectedRange_1CALLBACK;

static NSRange selectedRangeProc(id obj, SEL sel)
{
	NSRange* ptr = cast(NSRange*) selectedRange_1CALLBACK(obj, sel);
	NSRange range = *ptr;
	free(ptr);
	return range;
}

IMP selectedRange_CALLBACK (IMP func)
{
    selectedRange_1CALLBACK = func;
	return cast(IMP) &selectedRangeProc;
}



static IMP highlightSelectionInClipRect_1CALLBACK;

static void highlightSelectionInClipRect(id obj, SEL sel, NSRect rect)
{
	return highlightSelectionInClipRect_1CALLBACK(obj, sel, &rect);
}

IMP highlightSelectionInClipRect_CALLBACK (IMP func)
{
    highlightSelectionInClipRect_1CALLBACK = func;
	return cast(IMP) &highlightSelectionInClipRect;
}



static IMP attributedSubstringFromRange_1CALLBACK;

static id attributedSubstringFromRangeProc(id obj, SEL sel, NSRange arg0)
{
	return attributedSubstringFromRange_1CALLBACK(obj, sel, &arg0);
}

IMP attributedSubstringFromRange_CALLBACK (IMP func)
{
    attributedSubstringFromRange_1CALLBACK = func;
	return cast(IMP) &attributedSubstringFromRangeProc;
}



static IMP setMarkedText_1selectedRange_1CALLBACK;

static void setMarkedText_1selectedRange(id obj, SEL sel, id* arg0, NSRange arg1)
{
	setMarkedText_1selectedRange_1CALLBACK(obj, sel, arg0, &arg1);
}

IMP setMarkedText_selectedRange_CALLBACK (IMP func)
{
    setMarkedText_1selectedRange_1CALLBACK = func;
	return cast(IMP) &setMarkedText_1selectedRange;
}



static IMP characterIndexForPoint_1CALLBACK;

static int characterIndexForPoint(id obj, SEL sel, NSPoint point)
{
	return cast(int) characterIndexForPoint_1CALLBACK(obj, sel, &point);
}

IMP characterIndexForPoint_CALLBACK (IMP func)
{
    characterIndexForPoint_1CALLBACK = func;
	return cast(IMP) &characterIndexForPoint;
}



static IMP firstRectForCharacterRange_1CALLBACK;

static NSRect firstRectForCharacterRangeProc(id obj, SEL sel, NSRange arg0)
{
	NSRect* ptr = cast(NSRect*) firstRectForCharacterRange_1CALLBACK(obj, sel, &arg0);
	NSRect result = *ptr;
	free(ptr);
	return result;
}

IMP firstRectForCharacterRange_CALLBACK (IMP func)
{
    firstRectForCharacterRange_1CALLBACK = func;
	return cast(IMP) &firstRectForCharacterRangeProc;
}



static IMP textView_1willChangeSelectionFromCharacterRange_1toCharacterRange_1CALLBACK;

static NSRange textView_1willChangeSelectionFromCharacterRange_1toCharacterRange(id obj, SEL sel, id aTextView, NSRange oldSelectedCharRange, NSRange newSelectedCharRange)
{
	NSRange* ptr = cast(NSRange*) textView_1willChangeSelectionFromCharacterRange_1toCharacterRange_1CALLBACK(obj, sel, aTextView, &oldSelectedCharRange, &newSelectedCharRange);
	NSRange result = *ptr;
	free(ptr);
	return result;
}

IMP textView_willChangeSelectionFromCharacterRange_toCharacterRange_CALLBACK (IMP func)
{
    textView_1willChangeSelectionFromCharacterRange_1toCharacterRange_1CALLBACK = func;
	return cast(IMP) &textView_1willChangeSelectionFromCharacterRange_1toCharacterRange;
}



// TODO
IMP draggedImage_movedTo_CALLBACK (IMP func)
{
    assert(false, "not implemented");
}



// TODO
IMP draggedImage_beganAt_CALLBACK (IMP func)
{
    assert(false, "not implemented");
}



static IMP draggedImage_1endedAt_1operation_1CALLBACK;

static void draggedImage_1endedAt_1operation(id obj, SEL sel, id image, NSPoint point, NSDragOperation op)
{
	return draggedImage_1endedAt_1operation_1CALLBACK(obj, sel, image, &point, op);
}

IMP draggedImage_endedAt_operation_CALLBACK (IMP func)
{
    draggedImage_1endedAt_1operation_1CALLBACK = func;
	return cast(IMP) &draggedImage_1endedAt_1operation;
}



static IMP accessibilityHitTest_1CALLBACK;

static void accessibilityHitTest(id obj, SEL sel, NSPoint point)
{
	return accessibilityHitTest_1CALLBACK(obj, sel, &point);
}

IMP accessibilityHitTest_CALLBACK (IMP func)
{
    accessibilityHitTest_1CALLBACK = func;
	return cast(IMP) &accessibilityHitTest;
}



// TODO
IMP dragSelectionWithEvent_offset_slideBack_CALLBACK (IMP func)
{
    assert(false, "not implemented");
}



IMP isFlipped_CALLBACK ()
{
    assert(false, "not implemented");
}



IMP CALLBACK_accessibilityHitTest_ (IMP func)
{
    assert(false, "not implemented");
}



IMP CALLBACK_attributedSubstringFromRange_ (IMP func)
{
    assert(false, "not implemented");
}



IMP CALLBACK_canDragRowsWithIndexes_atPoint_ (IMP func)
{
    assert(false, "not implemented");
}



IMP CALLBACK_cellSize (IMP func)
{
    assert(false, "not implemented");
}



IMP CALLBACK_characterIndexForPoint_ (IMP func)
{
    assert(false, "not implemented");
}



IMP CALLBACK_dragSelectionWithEvent_offset_slideBack_ (IMP func)
{
    assert(false, "not implemented");
}



IMP CALLBACK_draggedImage_beganAt_ (IMP func)
{
    assert(false, "not implemented");
}



IMP CALLBACK_draggedImage_endedAt_operation_ (IMP func)
{
    assert(false, "not implemented");
}



IMP CALLBACK_drawImage_withFrame_inView_ (IMP func)
{
    assert(false, "not implemented");
}



IMP CALLBACK_drawInteriorWithFrame_inView_ (IMP func)
{
    assert(false, "not implemented");
}



IMP CALLBACK_drawRect_ (IMP func)
{
    assert(false, "not implemented");
}



IMP CALLBACK_drawWithExpansionFrame_inView_ (IMP func)
{
    assert(false, "not implemented");
}



IMP CALLBACK_expansionFrameWithFrame_inView_ (IMP func)
{
    assert(false, "not implemented");
}



IMP CALLBACK_firstRectForCharacterRange_ (IMP func)
{
    assert(false, "not implemented");
}



IMP CALLBACK_highlightSelectionInClipRect_ (IMP func)
{
    assert(false, "not implemented");
}



IMP CALLBACK_hitTest_ (IMP func)
{
    assert(false, "not implemented");
}



IMP CALLBACK_hitTestForEvent_inRect_ofView_ (IMP func)
{
    assert(false, "not implemented");
}



IMP CALLBACK_imageRectForBounds_ (IMP func)
{
    assert(false, "not implemented");
}



IMP CALLBACK_markedRange (IMP func)
{
    assert(false, "not implemented");
}



IMP CALLBACK_selectedRange (IMP func)
{
    assert(false, "not implemented");
}



IMP CALLBACK_setFrame_ (IMP func)
{
    assert(false, "not implemented");
}



IMP CALLBACK_setFrameOrigin_ (IMP func)
{
    assert(false, "not implemented");
}



IMP CALLBACK_setFrameSize_ (IMP func)
{
    assert(false, "not implemented");
}



IMP CALLBACK_setMarkedText_selectedRange_ (IMP func)
{
    assert(false, "not implemented");
}



IMP CALLBACK_setNeedsDisplayInRect_ (IMP func)
{
    assert(false, "not implemented");
}



IMP CALLBACK_shouldChangeTextInRange_replacementString_ (IMP func)
{
    assert(false, "not implemented");
}



IMP CALLBACK_textView_willChangeSelectionFromCharacterRange_toCharacterRange_ (IMP func)
{
    assert(false, "not implemented");
}



IMP CALLBACK_titleRectForBounds_ (IMP func)
{
    assert(false, "not implemented");
}



IMP CALLBACK_view_stringForToolTip_point_userData_ (IMP func)
{
    assert(false, "not implemented");
}



IMP CALLBACK_webView_setFrame_ (IMP func)
{
    assert(false, "not implemented");
}


