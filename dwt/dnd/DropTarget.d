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
module dwt.dnd.DropTarget;

import dwt.dwthelper.utils;

import dwt.SWT;
import dwt.SWTError;
import dwt.SWTException;
import dwt.graphics.Point;
import dwt.dnd.DND;
import dwt.dnd.DNDEvent;
import dwt.dnd.DNDListener;
import dwt.dnd.DropTargetEffect;
import dwt.dnd.DropTargetListener;
import dwt.dnd.TableDropTargetEffect;
import dwt.dnd.Transfer;
import dwt.dnd.TransferData;
import dwt.dnd.TreeDropTargetEffect;
import dwt.internal.Callback;
import dwt.internal.cocoa.NSApplication;
import dwt.internal.cocoa.NSArray;
import dwt.internal.cocoa.NSCursor;
import dwt.internal.cocoa.NSEvent;
import dwt.internal.cocoa.NSMutableArray;
import dwt.internal.cocoa.NSObject;
import dwt.internal.cocoa.NSOutlineView;
import dwt.internal.cocoa.NSPasteboard;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSRect;
import dwt.internal.cocoa.NSScreen;
import dwt.internal.cocoa.NSString;
import dwt.internal.cocoa.NSTableView;
import dwt.internal.cocoa.NSURL;
import dwt.internal.cocoa.OS;
import dwt.internal.cocoa.id;
import dwt.internal.cocoa.objc_super;
import dwt.internal.objc.cocoa.Cocoa;
import objc = dwt.internal.objc.runtime;
import dwt.widgets.Control;
import dwt.widgets.Display;
import dwt.widgets.Event;
import dwt.widgets.Listener;
import dwt.widgets.Table;
import dwt.widgets.Tree;
import dwt.widgets.TreeItem;
import dwt.widgets.Widget;

import tango.core.Thread;

/**
 *
 * Class <code>DropTarget</code> defines the target object for a drag and drop transfer.
 *
 * <p>IMPORTANT: This class is <em>not</em> intended to be subclassed.</p>
 *
 * <p>This class identifies the <code>Control</code> over which the user must position the cursor
 * in order to drop the data being transferred.  It also specifies what data types can be dropped on
 * this control and what operations can be performed.  You may have several DropTragets in an
 * application but there can only be a one to one mapping between a <code>Control</code> and a <code>DropTarget</code>.
 * The DropTarget can receive data from within the same application or from other applications
 * (such as text dragged from a text editor like Word).</p>
 *
 * <code><pre>
 *  int operations = DND.DROP_MOVE | DND.DROP_COPY | DND.DROP_LINK;
 *  Transfer[] types = new Transfer[] {TextTransfer.getInstance()};
 *  DropTarget target = new DropTarget(label, operations);
 *  target.setTransfer(types);
 * </code></pre>
 *
 * <p>The application is notified of data being dragged over this control and of when a drop occurs by
 * implementing the interface <code>DropTargetListener</code> which uses the class
 * <code>DropTargetEvent</code>.  The application can modify the type of drag being performed
 * on this Control at any stage of the drag by modifying the <code>event.detail</code> field or the
 * <code>event.currentDataType</code> field.  When the data is dropped, it is the responsibility of
 * the application to copy this data for its own purposes.
 *
 * <code><pre>
 *  target.addDropListener (new DropTargetListener() {
 *      public void dragEnter(DropTargetEvent event) {};
 *      public void dragOver(DropTargetEvent event) {};
 *      public void dragLeave(DropTargetEvent event) {};
 *      public void dragOperationChanged(DropTargetEvent event) {};
 *      public void dropAccept(DropTargetEvent event) {}
 *      public void drop(DropTargetEvent event) {
 *          // A drop has occurred, copy over the data
 *          if (event.data is null) { // no data to copy, indicate failure in event.detail
 *              event.detail = DND.DROP_NONE;
 *              return;
 *          }
 *          label.setText ((String) event.data); // data copied to label text
 *      }
 *  });
 * </pre></code>
 *
 * <dl>
 *  <dt><b>Styles</b></dt> <dd>DND.DROP_NONE, DND.DROP_COPY, DND.DROP_MOVE, DND.DROP_LINK</dd>
 *  <dt><b>Events</b></dt> <dd>DND.DragEnter, DND.DragLeave, DND.DragOver, DND.DragOperationChanged,
 *                             DND.DropAccept, DND.Drop </dd>
 * </dl>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#dnd">Drag and Drop snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">DWT Example: DNDExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 * @noextend This class is not intended to be subclassed by clients.
 */
public class DropTarget : Widget {

    static objc.IMP proc2Args, proc3Args, proc6Args;

    static this () {
        proc2Args = cast(objc.IMP) &dropTargetProc2;
        proc3Args = cast(objc.IMP) &dropTargetProc3;
        proc6Args = cast(objc.IMP) &dropTargetProc6;
    }

    static bool dropNotAllowed = false;

    Control control;
    Listener controlListener;
    Transfer[] transferAgents;
    DropTargetEffect dropEffect;
    int feedback = DND.FEEDBACK_NONE;

    // Track application selections
    TransferData selectedDataType;
    int selectedOperation;

    // workaround - There is no event for "operation changed" so track operation based on key state
    int keyOperation = -1;

    static const String DEFAULT_DROP_TARGET_EFFECT = "DEFAULT_DROP_TARGET_EFFECT"; //$NON-NLS-1$

void addDragHandlers() {
    // Our strategy here is to dynamically add methods to the control's class that are required
    // by NSDraggingDestination. Then, when setTransfer is called, we just register
    // the types with the Control's NSView and AppKit will call the methods in the protocol
    // when a drag goes over the view.

    objc.Class cls = OS.object_getClass(control.view.id);

    if (cls is null) {
        DND.error(DND.ERROR_CANNOT_INIT_DROP);
    }

    // If we already added it, no need to do it again.
    objc.IMP procPtr = OS.class_getMethodImplementation(cls, OS.sel_draggingEntered_);
    if (procPtr is proc3Args) return;

    // Add the NSDraggingDestination callbacks
    OS.class_addMethod(cls, OS.sel_draggingEntered_, proc3Args, "@:@");
    OS.class_addMethod(cls, OS.sel_draggingUpdated_, proc3Args, "@:@");
    OS.class_addMethod(cls, OS.sel_draggingExited_, proc3Args, "@:@");
    OS.class_addMethod(cls, OS.sel_performDragOperation_, proc3Args, "@:@");
    OS.class_addMethod(cls, OS.sel_wantsPeriodicDraggingUpdates, proc2Args, "@:");

    if (OS.class_getSuperclass(cls) is OS.class_NSOutlineView) {
        OS.class_addMethod(cls, OS.sel_outlineView_acceptDrop_item_childIndex_, proc6Args, "@:@@@i");
        OS.class_addMethod(cls, OS.sel_outlineView_validateDrop_proposedItem_proposedChildIndex_, proc6Args, "@:@@@i");
    } else if (OS.class_getSuperclass(cls) is OS.class_NSTableView) {
        OS.class_addMethod(cls, OS.sel_tableView_acceptDrop_row_dropOperation_, proc6Args, "@:@@@i");
        OS.class_addMethod(cls, OS.sel_tableView_validateDrop_proposedRow_proposedDropOperation_, proc6Args, "@:@@@i");
    }
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when a drag and drop operation is in progress, by sending
 * it one of the messages defined in the <code>DropTargetListener</code>
 * interface.
 *
 * <p><ul>
 * <li><code>dragEnter</code> is called when the cursor has entered the drop target boundaries
 * <li><code>dragLeave</code> is called when the cursor has left the drop target boundaries and just before
 * the drop occurs or is cancelled.
 * <li><code>dragOperationChanged</code> is called when the operation being performed has changed
 * (usually due to the user changing the selected modifier key(s) while dragging)
 * <li><code>dragOver</code> is called when the cursor is moving over the drop target
 * <li><code>dropAccept</code> is called just before the drop is performed.  The drop target is given
 * the chance to change the nature of the drop or veto the drop by setting the <code>event.detail</code> field
 * <li><code>drop</code> is called when the data is being dropped
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
 * @see DropTargetListener
 * @see #getDropListeners
 * @see #removeDropListener
 * @see DropTargetEvent
 */
public void addDropListener(DropTargetListener listener) {
    if (listener is null) DND.error (DWT.ERROR_NULL_ARGUMENT);
    DNDListener typedListener = new DNDListener (listener);
    typedListener.dndWidget = this;
    addListener (DND.DragEnter, typedListener);
    addListener (DND.DragLeave, typedListener);
    addListener (DND.DragOver, typedListener);
    addListener (DND.DragOperationChanged, typedListener);
    addListener (DND.Drop, typedListener);
    addListener (DND.DropAccept, typedListener);
}

int /*long*/ callSuper (objc.id id, objc.SEL sel, int /*long*/ arg0) {
    objc_super super_struct = new objc_super();
    super_struct.receiver = id;
    super_struct.super_class = OS.objc_msgSend(id, OS.sel_superclass);
    return OS.objc_msgSendSuper(super_struct, sel, arg0);
}

static int checkStyle (int style) {
    if (style is DWT.NONE) return DND.DROP_MOVE;
    return style;
}

protected void checkSubclass () {
    String name = this.classinfo.name;
    String validName = DropTarget.classinfo.name;
    if (!validName.equals(name)) {
        DND.error (DWT.ERROR_INVALID_SUBCLASS);
    }
}

NSDragOperation draggingEntered(objc.id id, objc.SEL sel, NSObject sender) {
    if (sender is null) return OS.NSDragOperationNone;

    DNDEvent event = new DNDEvent();
    if (!setEventData(sender, event)) {
        keyOperation = -1;
        setDropNotAllowed();
        return OS.NSDragOperationNone;
    }

    int allowedOperations = event.operations;
    TransferData[] allowedDataTypes = new TransferData[event.dataTypes.length];
    System.arraycopy(event.dataTypes, 0, allowedDataTypes, 0, allowedDataTypes.length);

    selectedDataType = null;
    selectedOperation = DND.DROP_NONE;
    notifyListeners(DND.DragEnter, event);

    if (event.detail is DND.DROP_DEFAULT) {
        event.detail = (allowedOperations & DND.DROP_MOVE) !is 0 ? DND.DROP_MOVE : DND.DROP_NONE;
    }

    if (event.dataType !is null) {
        for (int i = 0; i < allowedDataTypes.length; i++) {
            if (allowedDataTypes[i].type is event.dataType.type) {
                selectedDataType = allowedDataTypes[i];
                break;
            }
        }
    }

    if (selectedDataType !is null && (allowedOperations & event.detail) !is 0) {
        selectedOperation = event.detail;
    }

    if ((selectedOperation is DND.DROP_NONE) && (OS.PTR_SIZEOF is 4)) {
        setDropNotAllowed();
    } else {
        clearDropNotAllowed();
    }

    if ((new NSObject(id)).isKindOfClass(OS.class_NSTableView)) {
        return callSuper(id, sel, sender.id);
    }
    return opToOsOp(selectedOperation);
}

void draggingExited(objc.id id, objc.SEL sel, NSObject sender) {
    clearDropNotAllowed();
    if (keyOperation is -1) return;
    keyOperation = -1;

    DNDEvent event = new DNDEvent();
    event.widget = this;
    event.time = cast(int)System.currentTimeMillis();
    event.detail = DND.DROP_NONE;
    notifyListeners(DND.DragLeave, event);

    if ((new NSObject(id)).isKindOfClass(OS.class_NSTableView)) {
        callSuper(id, sel, sender.id);
    }
}

NSDragOperation draggingUpdated(objc.id id, objc.SEL sel, NSObject sender) {
    if (sender is null) return OS.NSDragOperationNone;
    int oldKeyOperation = keyOperation;

    DNDEvent event = new DNDEvent();
    if (!setEventData(sender, event)) {
        keyOperation = -1;
        setDropNotAllowed();
        return OS.NSDragOperationNone;
    }

    int allowedOperations = event.operations;
    TransferData[] allowedDataTypes = new TransferData[event.dataTypes.length];
    System.arraycopy(event.dataTypes, 0, allowedDataTypes, 0, allowedDataTypes.length);

    if (keyOperation is oldKeyOperation) {
        event.type = DND.DragOver;
        event.dataType = selectedDataType;
        event.detail = selectedOperation;
    } else {
        event.type = DND.DragOperationChanged;
        event.dataType = selectedDataType;
    }

    selectedDataType = null;
    selectedOperation = DND.DROP_NONE;
    notifyListeners(event.type, event);
    if (event.detail is DND.DROP_DEFAULT) {
        event.detail = (allowedOperations & DND.DROP_MOVE) !is 0 ? DND.DROP_MOVE : DND.DROP_NONE;
    }

    if (event.dataType !is null) {
        for (int i = 0; i < allowedDataTypes.length; i++) {
            if (allowedDataTypes[i].type is event.dataType.type) {
                selectedDataType = allowedDataTypes[i];
                break;
            }
        }
    }

    if (selectedDataType !is null && (event.detail & allowedOperations) !is 0) {
        selectedOperation = event.detail;
    }

    if ((selectedOperation is DND.DROP_NONE) && (OS.PTR_SIZEOF is 4)) {
        setDropNotAllowed();
    } else {
        clearDropNotAllowed();
    }

    if ((new NSObject(id)).isKindOfClass(OS.class_NSTableView)) {
        return callSuper(id, sel, sender.id);
    }

    return opToOsOp(selectedOperation);
}

/**
 * Creates a new <code>DropTarget</code> to allow data to be dropped on the specified
 * <code>Control</code>.
 * Creating an instance of a DropTarget may cause system resources to be allocated
 * depending on the platform.  It is therefore mandatory that the DropTarget instance
 * be disposed when no longer required.
 *
 * @param control the <code>Control</code> over which the user positions the cursor to drop the data
 * @param style the bitwise OR'ing of allowed operations; this may be a combination of any of
 *         DND.DROP_NONE, DND.DROP_COPY, DND.DROP_MOVE, DND.DROP_LINK
 *
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 * @exception DWTError <ul>
 *    <li>ERROR_CANNOT_INIT_DROP - unable to initiate drop target; this will occur if more than one
 *        drop target is created for a control or if the operating system will not allow the creation
 *        of the drop target</li>
 * </ul>
 *
 * <p>NOTE: ERROR_CANNOT_INIT_DROP should be an DWTException, since it is a
 * recoverable error, but can not be changed due to backward compatibility.</p>
 *
 * @see Widget#dispose
 * @see DropTarget#checkSubclass
 * @see DND#DROP_NONE
 * @see DND#DROP_COPY
 * @see DND#DROP_MOVE
 * @see DND#DROP_LINK
 */
public this(Control control, int style) {
    super(control, checkStyle(style));
    this.control = control;

    if (control.getData(DND.DROP_TARGET_KEY) !is null) {
        DND.error(DND.ERROR_CANNOT_INIT_DROP);
    }

    control.setData(DND.DROP_TARGET_KEY, this);

    controlListener = new class () Listener {
        public void handleEvent (Event event) {
            if (!this.outer.isDisposed()) {
                this.outer.dispose();
            }
        }
    };
    control.addListener (DWT.Dispose, controlListener);

    this.addListener(DWT.Dispose, new class () Listener {
        public void handleEvent (Event event) {
            onDispose();
        }
    });

    Object effect = control.getData(DEFAULT_DROP_TARGET_EFFECT);
    if (auto e = cast(DropTargetEffect) effect) {
        dropEffect = e;
    } else if (auto c = cast(Table) control) {
        dropEffect = new TableDropTargetEffect(c);
    } else if (auto c = cast(Tree) control) {
        dropEffect = new TreeDropTargetEffect(c);
    }

    addDragHandlers();
}
extern (C) {
static objc.id dropTargetProc2(objc.id id, objc.SEL sel) {
    Display display = Display.findDisplay(Thread.getThis());
    if (display is null || display.isDisposed()) return null;
    Widget widget = display.findWidget(id);
    if (widget is null) return null;
    DropTarget dt = cast(DropTarget)widget.getData(DND.DROP_TARGET_KEY);
    if (dt is null) return null;

    if (sel is OS.sel_wantsPeriodicDraggingUpdates) {
        return dt.wantsPeriodicDraggingUpdates(id, sel) ? cast(objc.id) 1 : null;
    }

    return null;
}

static objc.id dropTargetProc3(objc.id id, objc.SEL sel, objc.id arg0) {
    Display display = Display.findDisplay(Thread.getThis());
    if (display is null || display.isDisposed()) return null;
    Widget widget = display.findWidget(id);
    if (widget is null) return null;
    DropTarget dt = cast(DropTarget)widget.getData(DND.DROP_TARGET_KEY);
    if (dt is null) return null;

    // arg0 is _always_ the sender, and implements NSDraggingInfo.
    // Looks like an NSObject for our purposes, though.
    NSObject sender = new NSObject(arg0);

    if (sel is OS.sel_draggingEntered_) {
        return cast(objc.id) dt.draggingEntered(id, sel, sender);
    } else if (sel is OS.sel_draggingUpdated_) {
        return cast(objc.id) dt.draggingUpdated(id, sel, sender);
    } else if (sel is OS.sel_draggingExited_) {
        dt.draggingExited(id, sel, sender);
    } else if (sel is OS.sel_performDragOperation_) {
        return dt.performDragOperation(id, sel, sender) ? cast(objc.id) 1 : null;
    }

    return null;
}

static objc.id dropTargetProc6(objc.id id, objc.SEL sel, objc.id arg0, objc.id arg1, objc.id arg2, objc.id arg3) {
    Display display = Display.findDisplay(Thread.currentThread());
    if (display is null || display.isDisposed()) return null;
    Widget widget = display.findWidget(id);
    if (widget is null) return null;
    DropTarget dt = (DropTarget)widget.getData(DND.DROP_TARGET_KEY);
    if (dt is null) return null;

    if (sel is OS.sel_outlineView_acceptDrop_item_childIndex_) {
        return dt.outlineView_acceptDrop_item_childIndex(id, sel, arg0, arg1, arg2, arg3) ? cast(objc.id) 1 : null;
    } else if (sel is OS.sel_outlineView_validateDrop_proposedItem_proposedChildIndex_) {
        return dt.outlineView_validateDrop_proposedItem_proposedChildIndex(id, sel, arg0, arg1, arg2, arg3);
    } else if (sel is OS.sel_tableView_acceptDrop_row_dropOperation_) {
        return dt.tableView_acceptDrop_row_dropOperation(id, sel, arg0, arg1, arg2, arg3) ? cast(objc.id) 1 : null;
    } else if (sel is OS.sel_tableView_validateDrop_proposedRow_proposedDropOperation_) {
        return dt.tableView_validateDrop_proposedRow_proposedDropOperation(id, sel, arg0, arg1, arg2, arg3);
    }

    return null;
}}

/**
 * Returns the Control which is registered for this DropTarget.  This is the control over which the
 * user positions the cursor to drop the data.
 *
 * @return the Control which is registered for this DropTarget
 */
public Control getControl () {
    return control;
}

/**
 * Returns an array of listeners who will be notified when a drag and drop
 * operation is in progress, by sending it one of the messages defined in
 * the <code>DropTargetListener</code> interface.
 *
 * @return the listeners who will be notified when a drag and drop
 * operation is in progress
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see DropTargetListener
 * @see #addDropListener
 * @see #removeDropListener
 * @see DropTargetEvent
 *
 * @since 3.4
 */
public DropTargetListener[] getDropListeners() {
    Listener[] listeners = getListeners(DND.DragEnter);
    int length_ = listeners.length;
    DropTargetListener[] dropListeners = new DropTargetListener[length_];
    int count = 0;
    for (int i = 0; i < length_; i++) {
        Listener listener = listeners[i];
        if (auto li = cast(DNDListener) listener) {
            dropListeners[count] = cast(DropTargetListener) (li).getEventListener();
            count++;
        }
    }
    if (count is length_) return dropListeners;
    DropTargetListener[] result = new DropTargetListener[count];
    System.arraycopy(dropListeners, 0, result, 0, count);
    return result;
}

/**
 * Returns the drop effect for this DropTarget.  This drop effect will be
 * used during a drag and drop to display the drag under effect on the
 * target widget.
 *
 * @return the drop effect that is registered for this DropTarget
 *
 * @since 3.3
 */
public DropTargetEffect getDropTargetEffect() {
    return dropEffect;
}

int getOperationFromKeyState() {
    // The NSDraggingInfo object already combined the modifier keys with the
    // drag source's allowed events. This might be better accomplished by diffing
    // the base drag source mask with the active drag state mask instead of snarfing
    // the current event.

    // See documentation on [NSDraggingInfo draggingSourceOperationMask] for the
    // correct Cocoa behavior.  Control + Option or Command is NSDragOperationGeneric,
    // or DND.DROP_DEFAULT in the DWT.
    NSEvent currEvent = NSApplication.sharedApplication().currentEvent();
    NSUInteger modifiers = currEvent.modifierFlags();
    bool option = (modifiers & OS.NSAlternateKeyMask) is OS.NSAlternateKeyMask;
    bool control = (modifiers & OS.NSControlKeyMask) is OS.NSControlKeyMask;
    if (control && option) return DND.DROP_DEFAULT;
    if (control) return DND.DROP_LINK;
    if (option) return DND.DROP_COPY;
    return DND.DROP_DEFAULT;
}

/**
 * Returns a list of the data types that can be transferred to this DropTarget.
 *
 * @return a list of the data types that can be transferred to this DropTarget
 */
public Transfer[] getTransfer() {
    return transferAgents;
}

void onDispose () {
    if (control is null)
        return;
    if (controlListener !is null)
        control.removeListener(DWT.Dispose, controlListener);
    controlListener = null;
    control.setData(DND.DROP_TARGET_KEY, null);
    transferAgents = null;

    // Unregister the control as a drop target.
    control.view.unregisterDraggedTypes();
    control = null;
}

NSDragOperation opToOsOp(int operation) {
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
    return osOperation;
}

NSDragOperation osOpToOp(NSDragOperation osOperation){
    NSDragOperation operation = 0;
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

bool drop(NSObject sender) {
    clearDropNotAllowed();
    DNDEvent event = new DNDEvent();
    event.widget = this;
    event.time = cast(int)System.currentTimeMillis();

    if (dropEffect !is null) {
        NSPoint mouseLocation = sender.draggingLocation();
        NSPoint globalLoc = sender.draggingDestinationWindow().convertBaseToScreen(mouseLocation);
        event.item = dropEffect.getItem(cast(int)globalLoc.x, cast(int)globalLoc.y);
    }

    event.detail = DND.DROP_NONE;
    notifyListeners(DND.DragLeave, event);

    event = new DNDEvent();
    if (!setEventData(sender, event)) {
        return false;
    }

    keyOperation = -1;
    int allowedOperations = event.operations;
    TransferData[] allowedDataTypes = new TransferData[event.dataTypes.length];
    System.arraycopy(event.dataTypes, 0, allowedDataTypes, 0, event.dataTypes.length);
    event.dataType = selectedDataType;
    event.detail = selectedOperation;
    notifyListeners(DND.DropAccept, event);

    selectedDataType = null;
    if (event.dataType !is null) {
        for (int i = 0; i < allowedDataTypes.length; i++) {
            if (allowedDataTypes[i].type is event.dataType.type) {
                selectedDataType = allowedDataTypes[i];
                break;
            }
        }
    }

    selectedOperation = DND.DROP_NONE;
    if (selectedDataType !is null && (event.detail & allowedOperations) !is 0) {
        selectedOperation = event.detail;
    }

    if (selectedOperation is DND.DROP_NONE) {
        return false;
    }

    // ask drag source for dropped data
    NSPasteboard pasteboard = sender.draggingPasteboard();
    NSObject data = null;
    NSMutableArray types = NSMutableArray.arrayWithCapacity(10);

    for (int i = 0; i < transferAgents.length; i++){
        Transfer transfer = transferAgents[i];
        String[] typeNames = transfer.getTypeNames();
        int[] typeIds = transfer.getTypeIds();

        for (int j = 0; j < typeNames.length; j++) {
            if (selectedDataType.type is typeIds[j]) {
                types.addObject(NSString.stringWith(typeNames[j]));
                break;
            }
        }
    }

    NSString type = pasteboard.availableTypeFromArray(types);
    TransferData tdata = new TransferData();

    if (type !is null) {
        tdata.type = Transfer.registerType(type.getString());
        if (type.isEqual(OS.NSStringPboardType) ||
                type.isEqual(OS.NSHTMLPboardType) ||
                type.isEqual(OS.NSRTFPboardType)) {
            tdata.data = pasteboard.stringForType(type);
        } else if (type.isEqual(OS.NSURLPboardType)) {
            tdata.data = NSURL.URLFromPasteboard(pasteboard);
        } else if (type.isEqual(OS.NSFilenamesPboardType)) {
            tdata.data = new NSArray(pasteboard.propertyListForType(type).id);
        } else {
            tdata.data = pasteboard.dataForType(type);
        }
    }

    if (tdata.data !is null) {
        data = tdata.data;
    }

    // Get Data in a Java format
    Object object = null;
    for (int i = 0; i < transferAgents.length; i++) {
        Transfer transfer = transferAgents[i];
        if (transfer !is null && transfer.isSupportedType(selectedDataType)) {
            selectedDataType.data = data;
            object = transfer.nativeToJava(selectedDataType);
            break;
        }
    }

    if (object is null) {
        selectedOperation = DND.DROP_NONE;
    }

    event.dataType = selectedDataType;
    event.detail = selectedOperation;
    event.data = object;
    notifyListeners(DND.Drop, event);
    selectedOperation = DND.DROP_NONE;
    if ((allowedOperations & event.detail) is event.detail) {
        selectedOperation = event.detail;
    }
    //notify source of action taken
    return (selectedOperation !is DND.DROP_NONE);
}

bool performDragOperation(objc.id id, objc.SEL sel, NSObject sender) {
    if ((new NSObject(id)).isKindOfClass(OS.class_NSTableView)) {
        return callSuper(id, sel, sender.id) !is 0;
    }

    return drop (sender);
}

bool outlineView_acceptDrop_item_childIndex(objc.id id, objc.SEL sel, objc.id outlineView, objc.id info, objc.id item, objc.id index) {
    return drop(new NSObject(info));
}

NSDragOperation outlineView_validateDrop_proposedItem_proposedChildIndex(objc.id id, objc.SEL sel, objc.id outlineView, objc.id info, objc.id item, objc.id index) {
    //TODO stop scrolling and expansion when app does not set FEEDBACK_SCROLL and/or FEEDBACK_EXPAND
    //TODO expansion animation and auto collapse not working because of outlineView:shouldExpandItem:
    NSOutlineView widget = new NSOutlineView(outlineView);
    NSObject sender = new NSObject(info);
    NSPoint pt = sender.draggingLocation();
    pt = widget.convertPoint_fromView_(pt, null);
    Tree tree = cast(Tree)getControl();
    TreeItem childItem = tree.getItem(new Point((int)pt.x, (int)pt.y));
    if (feedback is 0 || childItem is null) {
        widget.setDropItem(null, -1);
    } else {
        if ((feedback & DND.FEEDBACK_SELECT) !is 0) {
            widget.setDropItem(childItem.handle, -1);
        } else {
            TreeItem parentItem = childItem.getParentItem();
            int childIndex;
            id parentID = null;
            if (parentItem !is null) {
                parentID = parentItem.handle;
                childIndex = parentItem.indexOf(childItem);
            } else {
                childIndex = ((Tree)getControl()).indexOf(childItem);
            }
            if ((feedback & DND.FEEDBACK_INSERT_AFTER) !is 0) {
                widget.setDropItem(parentID, childIndex + 1);
            }
            if ((feedback & DND.FEEDBACK_INSERT_BEFORE) !is 0) {
                widget.setDropItem(parentID, childIndex);
            }
        }
    }

    return opToOsOp(selectedOperation);
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
 * @see DropTargetListener
 * @see #addDropListener
 * @see #getDropListeners
 */
public void removeDropListener(DropTargetListener listener) {
    if (listener is null) DND.error (DWT.ERROR_NULL_ARGUMENT);
    removeListener (DND.DragEnter, listener);
    removeListener (DND.DragLeave, listener);
    removeListener (DND.DragOver, listener);
    removeListener (DND.DragOperationChanged, listener);
    removeListener (DND.Drop, listener);
    removeListener (DND.DropAccept, listener);
}

/**
 * Specifies the drop effect for this DropTarget.  This drop effect will be
 * used during a drag and drop to display the drag under effect on the
 * target widget.
 *
 * @param effect the drop effect that is registered for this DropTarget
 *
 * @since 3.3
 */
public void setDropTargetEffect(DropTargetEffect effect) {
    dropEffect = effect;
}

bool setEventData(NSObject draggingState, DNDEvent event) {
    if (draggingState is null) return false;

    // get allowed operations
    int style = getStyle();
    NSDragOperation allowedActions = draggingState.draggingSourceOperationMask();
    int operations = osOpToOp(allowedActions) & style;
    if (operations is DND.DROP_NONE) return false;

    // get current operation
    int operation = getOperationFromKeyState();
    keyOperation = operation;
    if (operation is DND.DROP_DEFAULT) {
         if ((style & DND.DROP_DEFAULT) is 0) {
            operation = (operations & DND.DROP_MOVE) !is 0 ? DND.DROP_MOVE : DND.DROP_NONE;
         }
    } else {
        if ((operation & operations) is 0) operation = DND.DROP_NONE;
    }


    // get allowed transfer types
    NSPasteboard dragPBoard = draggingState.draggingPasteboard();
    NSArray draggedTypes = dragPBoard.types();
    if (draggedTypes is null) return false;

    NSUInteger draggedTypeCount = draggedTypes.count();

    TransferData[] dataTypes = new TransferData[draggedTypeCount];
    int index = -1;
    for (int i = 0; i < draggedTypeCount; i++) {
        id draggedType = draggedTypes.objectAtIndex(i);
        NSString nativeDataType = new NSString(draggedType);
        TransferData data = new TransferData();
        data.type = Transfer.registerType(nativeDataType.getString());

        for (int j = 0; j < transferAgents.length; j++) {
            Transfer transfer = transferAgents[j];
            if (transfer !is null && transfer.isSupportedType(data)) {
                dataTypes[++index] = data;
                break;
            }
        }
    }
    if (index is -1) return false;

    if (index < dataTypes.length - 1) {
        TransferData[] temp = new TransferData[index + 1];
        System.arraycopy(dataTypes, 0, temp, 0, index + 1);
        dataTypes = temp;
    }

    // Convert from window-relative to global coordinates, and flip it.
    NSPoint mouse = draggingState.draggingLocation();
    NSPoint globalMouse = draggingState.draggingDestinationWindow().convertBaseToScreen(mouse);
    NSArray screens = NSScreen.screens();
    NSRect screenRect = (new NSScreen(screens.objectAtIndex(0))).frame();
    globalMouse.y = screenRect.height - globalMouse.y;

    event.widget = this;
    event.x = cast(int)globalMouse.x;
    event.y = cast(int)globalMouse.y;
    event.time = cast(int)System.currentTimeMillis();
    event.feedback = DND.FEEDBACK_SELECT;
    event.dataTypes = dataTypes;
    event.dataType = dataTypes[0];
    event.operations = operations;
    event.detail = operation;
    if (dropEffect !is null) {
        event.item = dropEffect.getItem(event.x, event.y);
    }

    return true;
}

/**
 * Specifies the data types that can be transferred to this DropTarget.  If data is
 * being dragged that does not match one of these types, the drop target will be notified of
 * the drag and drop operation but the currentDataType will be null and the operation
 * will be DND.NONE.
 *
 * @param transferAgents a list of Transfer objects which define the types of data that can be
 *                       dropped on this target
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if transferAgents is null</li>
 * </ul>
 */
public void setTransfer(Transfer[] transferAgents){
    if (transferAgents is null) DND.error(DWT.ERROR_NULL_ARGUMENT);
    this.transferAgents = transferAgents;


    // Register the types as valid drop types in Cocoa.
    // Accumulate all of the transfer types into a list.
    String[] typeStrings;

    for (int i = 0; i < this.transferAgents.length; i++) {
        String[] types = transferAgents[i].getTypeNames();

        for (int j = 0; j < types.length; j++) {
            typeStrings.add(types[j]);
        }
    }

    // Convert to an NSArray of NSStrings so we can register with the Control.
    int typeStringCount = typeStrings.size();
    NSMutableArray nsTypeStrings = NSMutableArray.arrayWithCapacity(typeStringCount);

    for (int i = 0; i < typeStringCount; i++) {
        nsTypeStrings.addObject(NSString.stringWith(typeStrings.get(i)));
    }

    control.view.registerForDraggedTypes(nsTypeStrings);

}

void setDropNotAllowed() {
    if (!dropNotAllowed) {
        NSCursor.currentCursor().push();
        if (OS.PTR_SIZEOF is 4) OS.SetThemeCursor(OS.kThemeNotAllowedCursor);
        dropNotAllowed = true;
    }
}

void clearDropNotAllowed() {
    if (dropNotAllowed) {
        NSCursor.pop();
        dropNotAllowed = false;
    }
}

bool tableView_acceptDrop_row_dropOperation(objc.id id, objc.SEL sel, objc.id tableView, objc.id info, objc.id row, objc.id operation) {
    return drop(new NSObject(info));
}

NSDragOperation tableView_validateDrop_proposedRow_proposedDropOperation(objc.id id, objc.SEL sel, objc.id tableView, objc.id info, objc.id row, objc.id operation) {
    //TODO stop scrolling and expansion when app does not set FEEDBACK_SCROLL and/or FEEDBACK_EXPAND
    NSTableView widget = new NSTableView(tableView);
    if (0 <= row && row < widget.numberOfRows()) {
        widget.setDropRow(row, OS.NSTableViewDropOn);
    }
    return opToOsOp(selectedOperation);
}

// By returning true we get draggingUpdated messages even when the mouse isn't moving.
bool wantsPeriodicDraggingUpdates(objc.id id, objc.SEL sel) {
    return true;
}

}
