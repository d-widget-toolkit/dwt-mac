/*******************************************************************************
 * Copyright (c) 2007, 2009 IBM Corporation and others.
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
module dwt.dnd.TreeDragSourceEffect;

import dwt.dwthelper.utils;

import dwt.DWT;
import dwt.dnd.DragSourceEffect;
import dwt.dnd.DragSourceEvent;
import dwt.graphics.Image;
import dwt.internal.cocoa.NSApplication;
import dwt.internal.cocoa.NSEvent;
import dwt.internal.cocoa.NSImage;
import dwt.internal.cocoa.NSPoint;
import dwt.internal.cocoa.NSTableView;
import dwt.internal.cocoa.OS;
import dwt.widgets.Tree;

/**
 * This class provides default implementations to display a source image
 * when a drag is initiated from a <code>Tree</code>.
 *
 * <p>Classes that wish to provide their own source image for a <code>Tree</code> can
 * extend <code>TreeDragSourceEffect</code> class and override the <code>TreeDragSourceEffect.dragStart</code>
 * method and set the field <code>DragSourceEvent.image</code> with their own image.</p>
 *
 * Subclasses that override any methods of this class must call the corresponding
 * <code>super</code> method to get the default drag under effect implementation.
 *
 * @see DragSourceEffect
 * @see DragSourceEvent
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.3
 */
public class TreeDragSourceEffect : DragSourceEffect {
    Image dragSourceImage = null;

    /**
     * Creates a new <code>TreeDragSourceEffect</code> to handle drag effect
     * from the specified <code>Tree</code>.
     *
     * @param tree the <code>Tree</code> that the user clicks on to initiate the drag
     */
    public this(Tree tree) {
        super(tree);
    }

    /**
     * This implementation of <code>dragFinished</code> disposes the image
     * that was created in <code>TreeDragSourceEffect.dragStart</code>.
     *
     * Subclasses that override this method should call <code>super.dragFinished(event)</code>
     * to dispose the image in the default implementation.
     *
     * @param event the information associated with the drag finished event
     */
    public void dragFinished(DragSourceEvent event) {
        if (dragSourceImage !is null) dragSourceImage.dispose();
        dragSourceImage = null;
    }

    /**
     * This implementation of <code>dragStart</code> will create a default
     * image that will be used during the drag. The image should be disposed
     * when the drag is completed in the <code>TreeDragSourceEffect.dragFinished</code>
     * method.
     *
     * Subclasses that override this method should call <code>super.dragStart(event)</code>
     * to use the image from the default implementation.
     *
     * @param event the information associated with the drag start event
     */
    public void dragStart(DragSourceEvent event) {
        event.image = getDragSourceImage(event);
    }

    Image getDragSourceImage(DragSourceEvent event) {
        if (dragSourceImage !is null) dragSourceImage.dispose();
        dragSourceImage = null;
        NSPoint point = NSPoint();
        NSEvent nsEvent = NSApplication.sharedApplication().currentEvent();
        NSTableView widget = cast(NSTableView)control.view;
        NSImage nsImage = widget.dragImageForRowsWithIndexes(widget.selectedRowIndexes(), widget.tableColumns(), nsEvent, &point);
        //TODO: Image representation wrong???
        Image image = Image.cocoa_new(control.getDisplay(), DWT.BITMAP, nsImage);
        dragSourceImage = image;
        nsImage.retain();
        event.offsetX = cast(int)point.x;
        event.offsetY = cast(int)point.y;
        return image;
    }
}
