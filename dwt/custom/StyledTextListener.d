/*******************************************************************************
 * Copyright (c) 2000, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *     Frank Benoit <benoit@tionex.de>
 *******************************************************************************/
module dwt.custom.StyledTextListener;

import dwt.dwthelper.System;
import dwt.dwthelper.Runnable;
import dwt.custom.BidiSegmentEvent;
import dwt.custom.BidiSegmentListener;
import dwt.custom.ExtendedModifyEvent;
import dwt.custom.ExtendedModifyListener;
import dwt.custom.LineBackgroundEvent;
import dwt.custom.LineBackgroundListener;
import dwt.custom.LineStyleEvent;
import dwt.custom.LineStyleListener;
import dwt.custom.MovementEvent;
import dwt.custom.MovementListener;
import dwt.custom.PaintObjectEvent;
import dwt.custom.PaintObjectListener;
import dwt.custom.StyledText;
import dwt.custom.StyledTextContent;
import dwt.custom.StyledTextEvent;
import dwt.custom.TextChangedEvent;
import dwt.custom.TextChangeListener;
import dwt.custom.TextChangingEvent;
import dwt.custom.VerifyKeyListener;
import dwt.custom.CaretListener;
import dwt.custom.CaretEvent;
import dwt.events.VerifyEvent;
import dwt.internal.SWTEventListener;
import dwt.widgets.Event;
import dwt.widgets.TypedListener;

class StyledTextListener : TypedListener {
/**
 */
this(SWTEventListener listener) {
    super(listener);
}
/**
 * Process StyledText events by invoking the event's handler.
 *
 * @param e the event to handle
 */
public override void handleEvent(Event e) {

    switch (e.type) {
        case StyledText.ExtendedModify:
            ExtendedModifyEvent extendedModifyEvent = new ExtendedModifyEvent(cast(StyledTextEvent) e);
            (cast(ExtendedModifyListener) eventListener).modifyText(extendedModifyEvent);
            break;
        case StyledText.LineGetBackground:
            LineBackgroundEvent lineBgEvent = new LineBackgroundEvent(cast(StyledTextEvent) e);
            (cast(LineBackgroundListener) eventListener).lineGetBackground(lineBgEvent);
            (cast(StyledTextEvent) e).lineBackground = lineBgEvent.lineBackground;
            break;
        case StyledText.LineGetSegments:
            BidiSegmentEvent segmentEvent = new BidiSegmentEvent(cast(StyledTextEvent) e);
            (cast(BidiSegmentListener) eventListener).lineGetSegments(segmentEvent);
            (cast(StyledTextEvent) e).segments = segmentEvent.segments;
            break;
        case StyledText.LineGetStyle:
            LineStyleEvent lineStyleEvent = new LineStyleEvent(cast(StyledTextEvent) e);
            (cast(LineStyleListener) eventListener).lineGetStyle(lineStyleEvent);
            (cast(StyledTextEvent) e).ranges = lineStyleEvent.ranges;
            (cast(StyledTextEvent) e).styles = lineStyleEvent.styles;
            (cast(StyledTextEvent) e).alignment = lineStyleEvent.alignment;
            (cast(StyledTextEvent) e).indent = lineStyleEvent.indent;
            (cast(StyledTextEvent) e).justify = lineStyleEvent.justify;
            (cast(StyledTextEvent) e).bullet = lineStyleEvent.bullet;
            (cast(StyledTextEvent) e).bulletIndex = lineStyleEvent.bulletIndex;
            break;
        case StyledText.PaintObject:
            PaintObjectEvent paintObjectEvent = new PaintObjectEvent(cast(StyledTextEvent) e);
            (cast(PaintObjectListener) eventListener).paintObject(paintObjectEvent);
            break;
        case StyledText.VerifyKey:
            VerifyEvent verifyEvent = new VerifyEvent(e);
            (cast(VerifyKeyListener) eventListener).verifyKey(verifyEvent);
            e.doit = verifyEvent.doit;
            break;
        case StyledText.TextChanged: {
            TextChangedEvent textChangedEvent = new TextChangedEvent(cast(StyledTextContent) e.data);
            (cast(TextChangeListener) eventListener).textChanged(textChangedEvent);
            break;
        }
        case StyledText.TextChanging:
            TextChangingEvent textChangingEvent = new TextChangingEvent(cast(StyledTextContent) e.data, cast(StyledTextEvent) e);
            (cast(TextChangeListener) eventListener).textChanging(textChangingEvent);
            break;
        case StyledText.TextSet: {
            TextChangedEvent textChangedEvent = new TextChangedEvent(cast(StyledTextContent) e.data);
            (cast(TextChangeListener) eventListener).textSet(textChangedEvent);
            break;
        }
        case StyledText.WordNext: {
            MovementEvent wordBoundaryEvent = new MovementEvent(cast(StyledTextEvent) e);
            (cast(MovementListener) eventListener).getNextOffset(wordBoundaryEvent);
            (cast(StyledTextEvent) e).end = wordBoundaryEvent.newOffset;
            break;
        }
        case StyledText.WordPrevious: {
            MovementEvent wordBoundaryEvent = new MovementEvent(cast(StyledTextEvent) e);
            (cast(MovementListener) eventListener).getPreviousOffset(wordBoundaryEvent);
            (cast(StyledTextEvent) e).end = wordBoundaryEvent.newOffset;
            break;
        }
        case StyledText.CaretMoved: {
            CaretEvent caretEvent = new CaretEvent(cast(StyledTextEvent) e);
            (cast(CaretListener) eventListener).caretMoved(caretEvent);
            (cast(StyledTextEvent) e).end = caretEvent.caretOffset;
            break;
        }
        default:
    }
}
}


