/*******************************************************************************
 * Copyright (c) 2000, 2009 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *
 * Port to the D programming language:
 *     Jacob Carlborg <doob@me.com>
 *******************************************************************************/
module dwt.dnd.DragSource;

import dwt.dwthelper.utils;








import tango.core.Thread;

import dwt.dnd.DND;
import dwt.dnd.DNDEvent;
import dwt.dnd.DNDListener;
import dwt.dnd.DragSourceEffect;
import dwt.dnd.DragSourceListener;
import dwt.dnd.TableDragSourceEffect;
import dwt.dnd.Transfer;
import dwt.dnd.TransferData;
import dwt.dnd.TreeDragSourceEffect;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;

/**
 *
 * <code>DragSource</code> defines the source object for a drag and drop transfer.
 *
 * <p>IMPORTANT: This class is <em>not</em> intended to be subclassed.</p>
 *
 * <p>A drag source is the object which originates a drag and drop operation. For the specified widget,
 * it defines the type of data that is available for dragging and the set of operations that can
 * be performed on that data.  The operations can be any bit-wise combination of DND.MOVE, DND.COPY or
 * DND.LINK.  The type of data that can be transferred is specified by subclasses of Transfer such as
 * TextTransfer or FileTransfer.  The type of data transferred can be a predefined system type or it
 * can be a type defined by the application.  For instructions on how to define your own transfer type,
 * refer to <code>ByteArrayTransfer</code>.</p>
 *
 * <p>You may have several DragSources in an application but you can only have one DragSource
 * per Control.  Data dragged from this DragSource can be dropped on a site within this application
 * or it can be dropped on another application such as an external Text editor.</p>
 *
 * <p>The application supplies the content of the data being transferred by implementing the
 * <code>DragSourceListener</code> and associating it with the DragSource via DragSource#addDragListener.</p>
 *
 * <p>When a successful move operation occurs, the application is required to take the appropriate
 * action to remove the data from its display and remove any associated operating system resources or
 * internal references.  Typically in a move operation, the drop target makes a copy of the data
 * and the drag source deletes the original.  However, sometimes copying the data can take a long
 * time (such as copying a large file).  Therefore, on some platforms, the drop target may actually
 * move the data in the operating system rather than make a copy.  This is usually only done in
 * file transfers.  In this case, the drag source is informed in the DragEnd event that a
 * DROP_TARGET_MOVE was performed.  It is the responsibility of the drag source at this point to clean
 * up its displayed information.  No action needs to be taken on the operating system resources.</p>
 *
 * <p> The following example shows a Label widget that allows text to be dragged from it.</p>
 *
 * <code><pre>
 *  // Enable a label as a Drag Source
 *  Label label = new Label(shell, DWT.NONE);
 *  // This example will allow text to be dragged
 *  Transfer[] types = new Transfer[] {TextTransfer.getInstance()};
 *  // This example will allow the text to be copied or moved to the drop target
 *  int operations = DND.DROP_MOVE | DND.DROP_COPY;
 *
 *  DragSource source = new DragSource(label, operations);
 *  source.setTransfer(types);
 *  source.addDragListener(new DragSourceListener() {
 *      public void dragStart(DragSourceEvent e) {
 *          // Only start the drag if there is actually text in the
 *          // label - this text will be what is dropped on the target.
 *          if (label.getText().length() is 0) {
 *              event.doit = false;
 *          }
 *      };
 *      public void dragSetData(DragSourceEvent event) {
 *          // A drop has been performed, so provide the data of the
 *          // requested type.
 *          // (Checking the type of the requested data is only
 *          // necessary if the drag source supports more than
 *          // one data type but is shown here as an example).
 *          if (TextTransfer.getInstance().isSupportedType(event.dataType)){
 *              event.data = label.getText();
 *          }
 *      }
 *      public void dragFinished(DragSourceEvent event) {
 *          // A Move operation has been performed so remove the data
 *          // from the source
 *          if (event.detail is DND.DROP_MOVE)
 *              label.setText("");
 *      }
 *  });
 * </pre></code>
 *
 *
 * <dl>
 *  <dt><b>Styles</b></dt> <dd>DND.DROP_NONE, DND.DROP_COPY, DND.DROP_MOVE, DND.DROP_LINK</dd>
 *  <dt><b>Events</b></dt> <dd>DND.DragStart, DND.DragSetData, DND.DragEnd</dd>
 * </dl>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#dnd">Drag and Drop snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">DWT Example: DNDExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 * @noextend This class is not intended to be subclassed by clients.
 */
public class DragSource : Widget {

    static int size = C.PTR_SIZEOF, align = C.PTR_SIZEOF is 4 ? 2 : 3;

    static Callback dragSource2Args, dragSource3Args, dragSource4Args, dragSource5Args, dragSource6Args;
    static final byte[] DWT_OBJECT = {'S', 'W', 'T', '_', 'O', 'B', 'J', 'E', 'C', 'T', '\0'};
    static int /*long*/ proc2 = 0, proc3 = 0, proc4 = 0, proc5 = 0, proc6 = 0;
    // TODO: These should either move out of Display or be accessible to this class.
    static byte[] types = {'*','\0'};
    static int size = C.PTR_SIZEOF, align = C.PTR_SIZEOF is 4 ? 2 : 3;
    static Callback dragSource2Args, dragSource3Args, dragSource4Args, dragSource5Args, dragSource6Args;
    static final byte[] DWT_OBJECT = {'S', 'W', 'T', '_', 'O', 'B', 'J', 'E', 'C', 'T', '\0'};
    static int /*long*/ proc2 = 0, proc3 = 0, proc4 = 0, proc5 = 0, proc6 = 0;

    static this () {
        String className = "SWTDragSourceDelegate";

        int size = C.PTR_SIZEOF, align_ = C.PTR_SIZEOF is 4 ? 2 : 3;

        objc.IMP proc2 = cast(objc.IMP) &dragSourceProc2;
        objc.IMP proc3 = cast(objc.IMP) &dragSourceProc3;
        objc.IMP proc4 = cast(objc.IMP) &dragSourceProc4;
        objc.IMP proc5 = cast(objc.IMP) &dragSourceProc5;

        dragSource6Args = new Callback(clazz, "dragSourceProc", 6);
        proc6 = dragSource6Args.getAddress();
        if (proc6 is 0) DWT.error (DWT.ERROR_NO_MORE_CALLBACKS);

        objc.Class cls = OS.objc_allocateClassPair(cast(objc.Class) OS.class_NSObject, className, 0);
        OS.class_addIvar(cls, DWT_OBJECT, size, cast(byte)align_, types);
        if (proc6 is 0) DWT.error (DWT.ERROR_NO_MORE_CALLBACKS);


        objc.IMP draggedImage_endedAt_operationProc = OS.draggedImage_endedAt_operation_CALLBACK(proc5);

        // Add the NSDraggingSource callbacks
        OS.class_addMethod(cls, OS.sel_draggingSourceOperationMaskForLocal_, proc3, "@:I");

        static if ((void*).sizeof > int.sizeof) /* 64bit target */
        {
            OS.class_addMethod(cls, OS.sel_draggedImage_beganAt_, proc4, "@:@{NSPoint=dd}");
            OS.class_addMethod(cls, OS.sel_draggedImage_endedAt_operation_, draggedImage_endedAt_operationProc, "@:@{NSPoint=dd}Q");
        }

        else
        {
            OS.class_addMethod(cls, OS.sel_draggedImage_beganAt_, proc4, "@:@{NSPoint=ff}");
            OS.class_addMethod(cls, OS.sel_draggedImage_endedAt_operation_, draggedImage_endedAt_operationProc, "@:@{NSPoint=ff}I");
        }

        OS.class_addMethod(cls, OS.sel_ignoreModifierKeysWhileDragging, proc3, "@:");

        // Add the NSPasteboard delegate callback
        OS.class_addMethod(cls, OS.sel_pasteboard_provideDataForType_, proc4, "@:@@");

        OS.objc_registerClassPair(cls);
    }

    // info for registering as a drag source
    Control control;
    Listener controlListener;
    Transfer[] transferAgents;
    DragSourceEffect dragEffect;
    Image dragImageFromListener;
    private int dragOperations;
    SWTDragSourceDelegate dragSourceDelegate;

    static final String DEFAULT_DRAG_SOURCE_EFFECT = "DEFAULT_DRAG_SOURCE_EFFECT"; //$NON-NLS-1$

    private void* delegateJniRef;
    private Point dragOffset;
    private Point dragOffset;

/**
 * Creates a new <code>DragSource</code> to handle dragging from the specified <code>Control</code>.
 * Creating an instance of a DragSource may cause system resources to be allocated depending on the platform.
 * It is therefore mandatory that the DragSource instance be disposed when no longer required.
 *
 * @param control the <code>Control</code> that the user clicks on to initiate the drag
 * @param style the bitwise OR'ing of allowed operations; this may be a combination of any of
 *                  DND.DROP_NONE, DND.DROP_COPY, DND.DROP_MOVE, DND.DROP_LINK
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 * @exception DWTError <ul>
 *    <li>ERROR_CANNOT_INIT_DRAG - unable to initiate drag source; this will occur if more than one
 *        drag source is created for a control or if the operating system will not allow the creation
 *        of the drag source</li>
 * </ul>
 *
 * <p>NOTE: ERROR_CANNOT_INIT_DRAG should be an DWTException, since it is a
 * recoverable error, but can not be changed due to backward compatibility.</p>
 *
 * @see Widget#dispose
 * @see DragSource#checkSubclass
 * @see DND#DROP_NONE
 * @see DND#DROP_COPY
 * @see DND#DROP_MOVE
 * @see DND#DROP_LINK
 */
public this(Control control, int style) {
    transferAgents = new Transfer[0];

    super (control, checkStyle(style));
    this.control = control;
    if (control.getData(DND.DRAG_SOURCE_KEY) !is null) {
        DND.error(DND.ERROR_CANNOT_INIT_DRAG);
    }
    control.setData(DND.DRAG_SOURCE_KEY, this);

    controlListener = new class () Listener {
        public void handleEvent (Event event) {
            if (event.type is DWT.Dispose) {
                if (!this.outer.isDisposed()) {
                    this.outer.dispose();
                }
            }
            if (event.type is DWT.DragDetect) {
                if (!this.outer.isDisposed()) {
                    if (cast(Table) event.widget || cast(Tree) event.widget) {
                        this.outer.dragOutlineViewStart(event);
                    } else {
                        this.outer.drag(event);
                    }
                    }
                }
            }
        }
    };
    control.addListener (DWT.Dispose, controlListener);
    control.addListener (DWT.DragDetect, controlListener);

    this.addListener(DWT.Dispose, new class () Listener {
        public void handleEvent(Event e) {
            onDispose();
        }
    });

    Object effect = control.getData(DEFAULT_DRAG_SOURCE_EFFECT);
    if (cast(DragSourceEffect) effect) {
        dragEffect = cast(DragSourceEffect) effect;
    } else if (cast(Tree) control) {
        dragEffect = new TreeDragSourceEffect(cast(Tree) control);
    } else if (cast(Table) control) {
        dragEffect = new TableDragSourceEffect(cast(Table) control);
    }

    delegateJniRef = OS.NewGlobalRef(this);
    if (delegateJniRef is null) DWT.error(DWT.ERROR_NO_HANDLES);

    // The dragSourceDelegate implements the pasteboard callback to provide the dragged data, so we always need
    // to create it. NSDraggingSource methods are ignored in the table and tree case.
    dragSourceDelegate = (SWTDragSourceDelegate)new SWTDragSourceDelegate().alloc().init();
    OS.object_setInstanceVariable(dragSourceDelegate.id, DWT_OBJECT, delegateJniRef);

    // Tables and trees already implement dragging, so we need to override their drag methods instead of creating a dragging source.
    if (control instanceof Tree || control instanceof Table) {
        int /*long*/ cls = OS.object_getClass(control.view.id);

        if (cls is 0) {
            DND.error(DND.ERROR_CANNOT_INIT_DRAG);
        }

        // If we already added it, no need to do it again.
        int /*long*/ procPtr = OS.class_getMethodImplementation(cls, OS.sel_draggingSourceOperationMaskForLocal_);
        if (procPtr is proc3) return;

        int /*long*/ draggedImage_endedAt_operationProc = OS.CALLBACK_draggedImage_endedAt_operation_(proc5);

        // Add the NSDraggingSource overrides.
        OS.class_addMethod(cls, OS.sel_draggingSourceOperationMaskForLocal_, proc3, "@:I");
        OS.class_addMethod(cls, OS.sel_draggedImage_beganAt_, proc4, "@:@{NSPoint=ff}");
        OS.class_addMethod(cls, OS.sel_draggedImage_endedAt_operation_, draggedImage_endedAt_operationProc, "@:@{NSPoint=ff}I");
        OS.class_addMethod(cls, OS.sel_ignoreModifierKeysWhileDragging, proc3, "@:");

        // Override to return the drag effect's image.
        OS.class_addMethod(cls, OS.sel_dragImageForRowsWithIndexes_tableColumns_event_offset_, proc6, "@:@@@^NSPoint");
    }

}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when a drag and drop operation is in progress, by sending
 * it one of the messages defined in the <code>DragSourceListener</code>
 * interface.
 *
 * <p><ul>
 * <li><code>dragStart</code> is called when the user has begun the actions required to drag the widget.
 * This event gives the application the chance to decide if a drag should be started.
 * <li><code>dragSetData</code> is called when the data is required from the drag source.
 * <li><code>dragFinished</code> is called when the drop has successfully completed (mouse up
 * over a valid target) or has been terminated (such as hitting the ESC key). Perform cleanup
 * such as removing data from the source side on a successful move operation.
 * </ul></p>
 *
 * @param listener the listener which should be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see DragSourceListener
 * @see #getDragListeners
 * @see #removeDragListener
 * @see DragSourceEvent
 */
public void addDragListener(DragSourceListener listener) {
    if (listener is null) DND.error (DWT.ERROR_NULL_ARGUMENT);
    DNDListener typedListener = new DNDListener (listener);
    typedListener.dndWidget = this;
    addListener (DND.DragStart, typedListener);
    addListener (DND.DragSetData, typedListener);
    addListener (DND.DragEnd, typedListener);
}

void callSuper(int /*long*/ id, int /*long*/ sel, int /*long*/ arg0, NSPoint arg1, int /*long*/ arg2) {
    objc_super super_struct = new objc_super();
    super_struct.receiver = id;
    super_struct.super_class = OS.objc_msgSend(id, OS.sel_superclass);
    OS.objc_msgSendSuper(super_struct, sel, arg0, arg1, arg2);
}

void callSuper(int /*long*/ id, int /*long*/ sel, int /*long*/ arg0, int /*long*/ arg1) {
    objc_super super_struct = new objc_super();
    super_struct.receiver = id;
    super_struct.super_class = OS.objc_msgSend(id, OS.sel_superclass);
    OS.objc_msgSendSuper(super_struct, sel, arg0, arg1);
}

int /*long*/ callSuperObject(int /*long*/ id, int /*long*/ sel, int /*long*/ arg0, int /*long*/ arg1, int /*long*/ arg2, int /*long*/ arg3) {
    objc_super super_struct = new objc_super();
    super_struct.receiver = id;
    super_struct.super_class = OS.objc_msgSend(id, OS.sel_superclass);
    return OS.objc_msgSendSuper(super_struct, sel, arg0, arg1, arg2, arg3);
}

protected void checkSubclass () {
    String name = this.classinfo.name;
    String validName = DragSource.classinfo.name;
    if (!validName.equals(name)) {
        DND.error (DWT.ERROR_INVALID_SUBCLASS);
    }
}

static int checkStyle (int style) {
    if (style is DWT.NONE) return DND.DROP_MOVE;
    return style;
}

void drag(Event dragDetectEvent) {

    DNDEvent event = startDrag(dragDetectEvent);
    if (event is null) return;

    // Start the drag here from the Control's view.
    NSEvent currEvent = NSApplication.sharedApplication().currentEvent();
    NSPoint pt = currEvent.locationInWindow();
    NSPoint viewPt = control.view.convertPoint_fromView_(pt, null);

    // Get the image for the drag. The drag should happen from the middle of the image.
    NSImage dragImage = null;
    Image defaultDragImage = null;
    try {
        Image image = event.image;

        // If no image was provided, just create a trivial image. dragImage requires a non-null image.
        if (image is null) {
            int width = 20, height = 20;
            Image newDragImage = new Image(Display.getCurrent(), width, height);
            GC imageGC = new GC(newDragImage);
            Color grayColor = new Color(Display.getCurrent(), 50, 50, 50);
            imageGC.setForeground(grayColor);
            imageGC.drawRectangle(0, 0, 19, 19);
            imageGC.dispose();
            ImageData newImageData = newDragImage.getImageData();
            newImageData.alpha = (int)(255 * .4);
            defaultDragImage = new Image(Display.getCurrent(), newImageData);
            newDragImage.dispose();
            grayColor.dispose();
            image = defaultDragImage;
            event.offsetX = width / 2;
            event.offsetY = height / 2;
        }

        dragImage = image.handle;

        NSSize imageSize = dragImage.size();
        viewPt.x -= event.offsetX;

        if (control.view.isFlipped())
            viewPt.y += imageSize.height - event.offsetY;
        else
            viewPt.y -= event.offsetY;

        // The third argument to dragImage is ignored as of 10.4.
        NSSize ignored = NSSize();

        control.view.dragImage(dragImage, viewPt, ignored, NSApplication.sharedApplication().currentEvent(), NSPasteboard.pasteboardWithName(OS.NSDragPboard), dragSourceDelegate, true);

    } finally {
        if (defaultDragImage !is null) defaultDragImage.dispose();
    }
}

void dragOutlineViewStart(Event dragDetectEvent) {
    DNDEvent event = startDrag(dragDetectEvent);
    if (event is null) return;

    // Save off the custom image, if any.
    dragImageFromListener = event.image;

    // Save the computed offset for the image.  This needs to be passed back in dragImageForRowsWithIndexes
    // so the proxy image originates from the selection and not centered under the mouse.
    dragOffset = new Point(event.offsetX, event.offsetY);
}

void draggedImage_beganAt(int /*long*/ id, int /*long*/ sel, int /*long*/ arg0, int /*long*/ arg1) {
    if (new NSObject(id).isKindOfClass(OS.class_NSTableView)) {
        callSuper(id, sel, arg0, arg1);
    }
}

void draggedImage_endedAt_operation(int /*long*/ id, int /*long*/ sel, int /*long*/ arg0, NSPoint arg1, int /*long*/ arg2) {
    int swtOperation = osOpToOp(arg2);
    Event event = new DNDEvent();
    event.widget = this;
    event.time = cast(int)System.currentTimeMillis();
    event.doit = swtOperation !is DND.DROP_NONE;
    event.detail = swtOperation;
    notifyListeners(DND.DragEnd, event);
    dragImageFromListener = null;

    if (new NSObject(id).isKindOfClass(OS.class_NSTableView)) {
        callSuper(id, sel, arg0, arg1, arg2);
    }
}

int /*long*/ dragImageForRowsWithIndexes_tableColumns_event_offset(int /*long*/ id, int /*long*/ sel, int /*long*/ arg0, int /*long*/ arg1, int /*long*/ arg2, int /*long*/ arg3) {
    if (dragImageFromListener !is null) {
        NSPoint point = new NSPoint();
        point.x = dragOffset.x;
        point.y = dragOffset.y;
        OS.memmove(arg3, point, NSPoint.sizeof);
        return dragImageFromListener.handle.id;
    } else {
        return callSuperObject(id, sel, arg0, arg1, arg2, arg3);
    }
}

/**
 * Cocoa NSDraggingSource implementations
 */
int /*long*/ draggingSourceOperationMaskForLocal(int /*long*/ id, int /*long*/ sel, int /*long*/ arg0) {
    // Drag operations are same for local or remote drags.
    return dragOperations;
}
extern (C) {
static objc.id dragSourceProc2(objc.id id, objc.SEL sel) {
    Display display = Display.findDisplay(Thread.getThis());
    if (display is null || display.isDisposed()) return null;
    Widget widget = display.findWidget(id);
    if (widget is null) return null;
    DragSource ds = null;

    if (widget instanceof DragSource) {
        ds = (DragSource)widget;
    } else {
        ds = (DragSource)widget.getData(DND.DRAG_SOURCE_KEY);
    }

    if (ds is null) return 0;

    if (sel is OS.sel_ignoreModifierKeysWhileDragging) {
        return (ds.ignoreModifierKeysWhileDragging(id, sel) ? cast(objc.id ) 1 : null);
    }

    return null;
}

static objc.id dragSourceProc3(objc.id id, objc.SEL sel, objc.id arg0) {
    Display display = Display.findDisplay(Thread.getThis());
    if (display is null || display.isDisposed()) return null;
    Widget widget = display.findWidget(id);
    if (widget is null) return null;
    DragSource ds = null;

    if (cast(DragSource) widget) {
        ds = cast(DragSource)widget;
    } else {
        ds = (DragSource)widget.getData(DND.DRAG_SOURCE_KEY);
    }

    if (ds is null) return null;

    if (sel is OS.sel_draggingSourceOperationMaskForLocal_) {
        return ds.draggingSourceOperationMaskForLocal(id, sel, arg0);
    }

    return null;
}

static objc.id dragSourceProc4(objc.id id, objc.SEL sel, objc.id arg0, objc.id arg1) {
    Display display = Display.findDisplay(Thread.getThis());
    if (display is null || display.isDisposed()) return null;
    Widget widget = display.findWidget(id);
    if (widget is null) return null;
    DragSource ds = null;

    if (cast(DragSource) widget) {
        ds = cast(DragSource)widget;
    } else {
        ds = (DragSource)widget.getData(DND.DRAG_SOURCE_KEY);
    }

    if (ds is null) return null;

    if (sel is OS.sel_draggedImage_beganAt_) {
        ds.draggedImage_beganAt(id, sel, arg0, arg1);
    } else if (sel is OS.sel_pasteboard_provideDataForType_) {
        ds.pasteboard_provideDataForType(id, sel, arg0, arg1);
    }

    return null;
}

static objc.id dragSourceProc5(objc.id id, objc.SEL sel, objc.id arg0, objc.id arg1, NSDragOperation arg2) {
    Display display = Display.findDisplay(Thread.getThis());
    if (display is null || display.isDisposed()) return null;
    Widget widget = display.findWidget(id);
    if (widget is null) return null;
    DragSource ds = null;

    if (cast(DragSource) widget) {
        ds = cast(DragSource)widget;
    } else {
        ds = (DragSource)widget.getData(DND.DRAG_SOURCE_KEY);
    }

    if (ds is null) return null;

    if (sel is OS.sel_draggedImage_endedAt_operation_) {
        NSPoint point = NSPoint();
        OS.memmove(&point, arg1, NSPoint.sizeof);
        ds.draggedImage_endedAt_operation(id, sel, arg0, point, arg2);
    }

    return 0;
}

static int /*long*/ dragSourceProc(int /*long*/ id, int /*long*/ sel, int /*long*/ arg0, int /*long*/ arg1, int /*long*/ arg2, int /*long*/ arg3) {
    Display display = Display.findDisplay(Thread.currentThread());
    if (display is null || display.isDisposed()) return 0;
    Widget widget = display.findWidget(id);
    if (widget is null) return 0;
    DragSource ds = null;

    if (widget instanceof DragSource) {
        ds = (DragSource)widget;
    } else {
        ds = (DragSource)widget.getData(DND.DRAG_SOURCE_KEY);
    }

    if (ds is null) return 0;

    if (sel is OS.sel_dragImageForRowsWithIndexes_tableColumns_event_offset_) {
        return ds.dragImageForRowsWithIndexes_tableColumns_event_offset(id, sel, arg0, arg1, arg2, arg3);
    }

    return 0;
}

static int /*long*/ dragSourceProc(int /*long*/ id, int /*long*/ sel, int /*long*/ arg0, int /*long*/ arg1, int /*long*/ arg2, int /*long*/ arg3) {
    Display display = Display.findDisplay(Thread.currentThread());
    if (display is null || display.isDisposed()) return 0;
    Widget widget = display.findWidget(id);
    if (widget is null) return 0;
    DragSource ds = null;

    if (widget instanceof DragSource) {
        ds = (DragSource)widget;
    } else {
        ds = (DragSource)widget.getData(DND.DRAG_SOURCE_KEY);
    }

    if (ds is null) return 0;

    if (sel is OS.sel_dragImageForRowsWithIndexes_tableColumns_event_offset_) {
        return ds.dragImageForRowsWithIndexes_tableColumns_event_offset(id, sel, arg0, arg1, arg2, arg3);
    }

    return null;
}}

/**
 * Returns the Control which is registered for this DragSource.  This is the control that the
 * user clicks in to initiate dragging.
 *
 * @return the Control which is registered for this DragSource
 */
public Control getControl () {
    return control;
}

/**
 * Returns an array of listeners who will be notified when a drag and drop
 * operation is in progress, by sending it one of the messages defined in
 * the <code>DragSourceListener</code> interface.
 *
 * @return the listeners who will be notified when a drag and drop
 * operation is in progress
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see DragSourceListener
 * @see #addDragListener
 * @see #removeDragListener
 * @see DragSourceEvent
 *
 * @since 3.4
 */
public DragSourceListener[] getDragListeners() {
    Listener[] listeners = getListeners(DND.DragStart);
    int length_ = listeners.length;
    DragSourceListener[] dragListeners = new DragSourceListener[length_];
    int count = 0;
    for (int i = 0; i < length_; i++) {
        Listener listener = listeners[i];
        if (cast(DNDListener) listener) {
            dragListeners[count] = cast(DragSourceListener) (cast(DNDListener) listener).getEventListener();
            count++;
        }
    }
    if (count is length_) return dragListeners;
    DragSourceListener[] result = new DragSourceListener[count];
    SimpleType!(DragSourceListener).arraycopy(dragListeners, 0, result, 0, count);
    return result;
}

/**
 * Returns the drag effect that is registered for this DragSource.  This drag
 * effect will be used during a drag and drop operation.
 *
 * @return the drag effect that is registered for this DragSource
 *
 * @since 3.3
 */
public DragSourceEffect getDragSourceEffect() {
    return dragEffect;
}

/**
 * Returns the list of data types that can be transferred by this DragSource.
 *
 * @return the list of data types that can be transferred by this DragSource
 */
public Transfer[] getTransfer(){
    return transferAgents;
}

/**
 * We always want the modifier keys to potentially update the drag.
 */
bool ignoreModifierKeysWhileDragging(int /*long*/ id, int /*long*/ sel) {
    return false;
}

void onDispose() {
    if (control is null)
        return;

    if (controlListener !is null) {
        control.removeListener(DWT.Dispose, controlListener);
        control.removeListener(DWT.DragDetect, controlListener);
    }
    controlListener = null;
    control.setData(DND.DRAG_SOURCE_KEY, null);
    control = null;
    transferAgents = null;

    //if (delegateJniRef !is null) OS.DeleteGlobalRef(delegateJniRef);
    delegateJniRef = 0;

    if (dragSourceDelegate !is null) {
        OS.object_setInstanceVariable(dragSourceDelegate.id, DWT_OBJECT, 0);
        dragSourceDelegate.release();
    }
}

int opToOsOp(int operation) {
    NSDragOperation osOperation;
    if ((operation & DND.DROP_COPY) !is 0){
        osOperation |= OS.NSDragOperationCopy;
    }
    if ((operation & DND.DROP_LINK) !is 0) {
        osOperation |= OS.NSDragOperationLink;
    }
    if ((operation & DND.DROP_MOVE) !is 0) {
        osOperation |= OS.NSDragOperationMove;
    }
    if ((operation & DND.DROP_TARGET_MOVE) !is 0) {
        osOperation |= OS.NSDragOperationDelete;
    }
    return cast(int) osOperation;
}

int osOpToOp(NSDragOperation osOperation){
    int operation = 0;
    if ((osOperation & OS.NSDragOperationCopy) !is 0){
        operation |= DND.DROP_COPY;
    }
    if ((osOperation & OS.NSDragOperationLink) !is 0) {
        operation |= DND.DROP_LINK;
    }
    if ((osOperation & OS.NSDragOperationDelete) !is 0) {
        operation |= DND.DROP_TARGET_MOVE;
    }
    if ((osOperation & OS.NSDragOperationMove) !is 0) {
        operation |= DND.DROP_MOVE;
    }
    if (osOperation is OS.NSDragOperationEvery) {
        operation = DND.DROP_COPY | DND.DROP_MOVE | DND.DROP_LINK;
    }
    return operation;
}

void pasteboard_provideDataForType(int /*long*/ id, int /*long*/ sel, int /*long*/ arg0, int /*long*/ arg1) {
    NSPasteboard pasteboard = new NSPasteboard(arg0);
    NSString dataType = new NSString(arg1);
    if (pasteboard is null || dataType is null) return;
    TransferData transferData = new TransferData();
    transferData.type = Transfer.registerType(dataType.getString());
    DNDEvent event = new DNDEvent();
    event.widget = this;
    event.time = cast(int)System.currentTimeMillis();
    event.dataType = transferData;
    notifyListeners(DND.DragSetData, event);
    if (!event.doit) return;
    Transfer transfer = null;
    for (int i = 0; i < transferAgents.length; i++) {
        Transfer transferAgent = transferAgents[i];
        if (transferAgent !is null && transferAgent.isSupportedType(transferData)) {
            transfer = transferAgent;
            break;
        }
    }
    if (transfer is null) return;
    transfer.javaToNative(event.data, transferData);
    if (transferData.data is null) return;

    NSObject tdata = transferData.data;

    if (dataType.isEqual(OS.NSStringPboardType) ||
            dataType.isEqual(OS.NSHTMLPboardType) ||
            dataType.isEqual(OS.NSRTFPboardType)) {
        pasteboard.setString(cast(NSString) tdata, dataType);
    } else if (dataType.isEqual(OS.NSURLPboardType)) {
        NSURL url = cast(NSURL) tdata;
        url.writeToPasteboard(pasteboard);
    } else if (dataType.isEqual(OS.NSFilenamesPboardType)) {
        pasteboard.setPropertyList(cast(NSArray) tdata, dataType);
    } else {
        pasteboard.setData(cast(NSData) tdata, dataType);
    }
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when a drag and drop operation is in progress.
 *
 * @param listener the listener which should no longer be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see DragSourceListener
 * @see #addDragListener
 * @see #getDragListeners
 */
public void removeDragListener(DragSourceListener listener) {
    if (listener is null) DND.error (DWT.ERROR_NULL_ARGUMENT);
    removeListener (DND.DragStart, listener);
    removeListener (DND.DragSetData, listener);
    removeListener (DND.DragEnd, listener);
}

/**
 * Specifies the drag effect for this DragSource.  This drag effect will be
 * used during a drag and drop operation.
 *
 * @param effect the drag effect that is registered for this DragSource
 *
 * @since 3.3
 */
public void setDragSourceEffect(DragSourceEffect effect) {
    dragEffect = effect;
}
/**
 * Specifies the list of data types that can be transferred by this DragSource.
 * The application must be able to provide data to match each of these types when
 * a successful drop has occurred.
 *
 * @param transferAgents a list of Transfer objects which define the types of data that can be
 * dragged from this source
 */
public void setTransfer(Transfer[] transferAgents){
    this.transferAgents = transferAgents;
}

DNDEvent startDrag(Event dragEvent) {
    DNDEvent event = new DNDEvent();
    event.widget = this;
    event.x = dragEvent.x;
    event.y = dragEvent.y;
    event.time = dragEvent.time;
    event.doit = true;
    notifyListeners(DND.DragStart, event);
    if (!event.doit || transferAgents is null || transferAgents.length is 0) return null;

    NSPasteboard dragBoard = NSPasteboard.pasteboardWithName(OS.NSDragPboard);
    NSMutableArray nativeTypeArray = NSMutableArray.arrayWithCapacity(10);
    Transfer fileTrans = null;

    for (int i = 0; i < transferAgents.length; i++) {
        Transfer transfer = transferAgents[i];
        if (transfer !is null) {
            String[] typeNames = transfer.getTypeNames();

            for (int j = 0; j < typeNames.length; j++) {
                nativeTypeArray.addObject(NSString.stringWith(typeNames[j]));
            }

            if (transfer instanceof FileTransfer) {
                fileTrans = transfer;
            }
        }
    }

    if (nativeTypeArray !is null)
        dragBoard.declareTypes(nativeTypeArray, dragSourceDelegate);

    if (fileTrans !is null) {
        int[] types = fileTrans.getTypeIds();
        TransferData transferData = new TransferData();
        transferData.type = types[0];
        DNDEvent event2 = new DNDEvent();
        event2.widget = this;
        event2.time = (int)System.currentTimeMillis();
        event2.dataType = transferData;
        notifyListeners(DND.DragSetData, event2);
        if (event2.data !is null) {
            for (int j = 0; j < types.length; j++) {
                transferData.type = types[j];
                fileTrans.javaToNative(event2.data, transferData);
                if (transferData.data !is null) {
                    dragBoard.setPropertyList(transferData.data, OS.NSFilenamesPboardType);
                }
            }
        }
    }

    // Save off the drag operations -- AppKit will call back to us to request them during the drag.
    dragOperations = opToOsOp(getStyle());

    return event;
}
}
