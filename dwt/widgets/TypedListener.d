/*******************************************************************************
 * Copyright (c) 2000, 2008 IBM Corporation and others.
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
module dwt.widgets.TypedListener;

import dwt.dwthelper.utils;


import dwt.internal.SWTEventListener;



import dwt.widgets.Event;
import dwt.widgets.Listener;

/**
 * Instances of this class are <em>internal DWT implementation</em>
 * objects which provide a mapping between the typed and untyped
 * listener mechanisms that DWT supports.
 * <p>
 * <b>IMPORTANT:</b> This class is <em>not</em> part of the DWT
 * public API. It is marked public only so that it can be shared
 * within the packages provided by DWT. It should never be
 * referenced from application code.
 * </p>
 *
 * @see Listener
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class TypedListener : Listener {

    /**
     * The receiver's event listener
     */
    protected SWTEventListener eventListener;

/**
 * Constructs a new instance of this class for the given event listener.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the DWT
 * public API. It is marked public only so that it can be shared
 * within the packages provided by DWT. It should never be
 * referenced from application code.
 * </p>
 *
 * @param listener the event listener to store in the receiver
 */
public this (SWTEventListener listener) {
    eventListener = listener;
}

/**
 * Returns the receiver's event listener.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the DWT
 * public API. It is marked public only so that it can be shared
 * within the packages provided by DWT. It should never be
 * referenced from application code.
 * </p>
 *
 * @return the receiver's event listener
 */
public SWTEventListener getEventListener () {
    return eventListener;
}

/**
 * Handles the given event.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the DWT
 * public API. It is marked public only so that it can be shared
 * within the packages provided by DWT. It should never be
 * referenced from application code.
 * </p>
 * @param e the event to handle
 */
public void handleEvent (Event e) {
    switch (e.type) {
        case DWT.Activate: {
            (cast(ShellListener) eventListener).shellActivated(new ShellEvent(e));
            break;
        }
        case DWT.Arm: {
            (cast(ArmListener) eventListener).widgetArmed (new ArmEvent (e));
            break;
        }
        case DWT.Close: {
            /* Fields set by Decorations */
            ShellEvent event = new ShellEvent (e);
            (cast(ShellListener) eventListener).shellClosed(event);
            e.doit = event.doit;
            break;
        }
        case DWT.Collapse: {
            if (cast(TreeListener) eventListener) {
                (cast(TreeListener) eventListener).treeCollapsed(new TreeEvent(e));
            } else {
                (cast(ExpandListener) eventListener).itemCollapsed(new ExpandEvent(e));
            }
            break;
        }
        case DWT.Deactivate: {
            (cast(ShellListener) eventListener).shellDeactivated(new ShellEvent(e));
            break;
        }
        case DWT.Deiconify: {
            (cast(ShellListener) eventListener).shellDeiconified(new ShellEvent(e));
            break;
        }
        case DWT.DefaultSelection: {
            (cast(SelectionListener)eventListener).widgetDefaultSelected(new SelectionEvent(e));
            break;
        }
        case DWT.Dispose: {
            (cast(DisposeListener) eventListener).widgetDisposed(new DisposeEvent(e));
            break;
        }
        case DWT.DragDetect: {
            (cast(DragDetectListener) eventListener).dragDetected(new DragDetectEvent(e));
            break;
        }
        case DWT.Expand: {
            if (cast(TreeListener) eventListener) {
                (cast(TreeListener) eventListener).treeExpanded(new TreeEvent(e));
            } else {
                (cast(ExpandListener) eventListener).itemExpanded(new ExpandEvent(e));
            }
            break;
        }
        case DWT.FocusIn: {
            (cast(FocusListener) eventListener).focusGained(new FocusEvent(e));
            break;
        }
        case DWT.FocusOut: {
            (cast(FocusListener) eventListener).focusLost(new FocusEvent(e));
            break;
        }
        case DWT.Help: {
            (cast(HelpListener) eventListener).helpRequested (new HelpEvent (e));
            break;
        }
        case DWT.Hide: {
            (cast(MenuListener) eventListener).menuHidden(new MenuEvent(e));
            break;
        }
        case DWT.Iconify: {
            (cast(ShellListener) eventListener).shellIconified(new ShellEvent(e));
            break;
        }
        case DWT.KeyDown: {
            /* Fields set by Control */
            KeyEvent event = new KeyEvent(e);
            (cast(KeyListener) eventListener).keyPressed(event);
            e.doit = event.doit;
            break;
        }
        case DWT.KeyUp: {
            /* Fields set by Control */
            KeyEvent event = new KeyEvent(e);
            (cast(KeyListener) eventListener).keyReleased(event);
            e.doit = event.doit;
            break;
        }
        case DWT.Modify: {
            (cast(ModifyListener) eventListener).modifyText(new ModifyEvent(e));
            break;
        }
        case DWT.MenuDetect: {
            MenuDetectEvent event = new MenuDetectEvent(e);
            (cast(MenuDetectListener) eventListener).menuDetected(event);
            e.x = event.x;
            e.y = event.y;
            e.doit = event.doit;
            break;
        }
        case DWT.MouseDown: {
            (cast(MouseListener) eventListener).mouseDown(new MouseEvent(e));
            break;
        }
        case DWT.MouseDoubleClick: {
            (cast(MouseListener) eventListener).mouseDoubleClick(new MouseEvent(e));
            break;
        }
        case DWT.MouseEnter: {
            (cast(MouseTrackListener) eventListener).mouseEnter (new MouseEvent (e));
            break;
        }
        case DWT.MouseExit: {
            (cast(MouseTrackListener) eventListener).mouseExit (new MouseEvent (e));
            break;
        }
        case DWT.MouseHover: {
            (cast(MouseTrackListener) eventListener).mouseHover (new MouseEvent (e));
            break;
        }
        case DWT.MouseMove: {
            (cast(MouseMoveListener) eventListener).mouseMove(new MouseEvent(e));
            return;
        }
        case DWT.MouseWheel: {
            (cast(MouseWheelListener) eventListener).mouseScrolled(new MouseEvent(e));
            return;
        }
        case DWT.MouseUp: {
            (cast(MouseListener) eventListener).mouseUp(new MouseEvent(e));
            break;
        }
        case DWT.Move: {
            (cast(ControlListener) eventListener).controlMoved(new ControlEvent(e));
            break;
        }
        case DWT.Paint: {
            /* Fields set by Control */
            PaintEvent event = new PaintEvent (e);
            (cast(PaintListener) eventListener).paintControl (event);
            e.gc = event.gc;
            break;
        }
        case DWT.Resize: {
            (cast(ControlListener) eventListener).controlResized(new ControlEvent(e));
            break;
        }
        case DWT.Selection: {
            /* Fields set by Sash */
            SelectionEvent event = new SelectionEvent (e);
            (cast(SelectionListener) eventListener).widgetSelected (event);
            e.x = event.x;
            e.y = event.y;
            e.doit = event.doit;
            break;
        }
        case DWT.Show: {
            (cast(MenuListener) eventListener).menuShown(new MenuEvent(e));
            break;
        }
        case DWT.Traverse: {
            /* Fields set by Control */
            TraverseEvent event = new TraverseEvent (e);
            (cast(TraverseListener) eventListener).keyTraversed (event);
            e.detail = event.detail;
            e.doit = event.doit;
            break;
        }
        case DWT.Verify: {
            /* Fields set by Text, RichText */
            VerifyEvent event = new VerifyEvent (e);
            (cast(VerifyListener) eventListener).verifyText (event);
            e.text = event.text;
            e.doit = event.doit;
            break;
        }

        default:
    }
}

}
