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
module dwt.custom.ControlEditor;

import dwt.dwthelper.utils;

/**
*
* A ControlEditor is a manager for a Control that appears above a composite and tracks with the
* moving and resizing of that composite.  It can be used to display one control above
* another control.  This could be used when editing a control that does not have editing
* capabilities by using a text editor or for launching a dialog by placing a button
* above a control.
*
* <p> Here is an example of using a ControlEditor:
*
* <code><pre>
* Canvas canvas = new Canvas(shell, DWT.BORDER);
* canvas.setBounds(10, 10, 300, 300);
* Color color = new Color(null, 255, 0, 0);
* canvas.setBackground(color);
* ControlEditor editor = new ControlEditor (canvas);
* // The editor will be a button in the bottom right corner of the canvas.
* // When selected, it will launch a Color dialog that will change the background
* // of the canvas.
* Button button = new Button(canvas, DWT.PUSH);
* button.setText("Select Color...");
* button.addSelectionListener (new SelectionAdapter() {
*   public void widgetSelected(SelectionEvent e) {
*       ColorDialog dialog = new ColorDialog(shell);
*       dialog.open();
*       RGB rgb = dialog.getRGB();
*       if (rgb !is null) {
*           if (color !is null) color.dispose();
*           color = new Color(null, rgb);
*           canvas.setBackground(color);
*       }
*
*   }
* });
*
* editor.horizontalAlignment = DWT.RIGHT;
* editor.verticalAlignment = DWT.BOTTOM;
* editor.grabHorizontal = false;
* editor.grabVertical = false;
* Point size = button.computeSize(DWT.DEFAULT, DWT.DEFAULT);
* editor.minimumWidth = size.x;
* editor.minimumHeight = size.y;
* editor.setEditor (button);
* </pre></code>
*
* @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
*/
public class ControlEditor {

    /**
    * Specifies how the editor should be aligned relative to the control.  Allowed values
    * are DWT.LEFT, DWT.RIGHT and DWT.CENTER.  The default value is DWT.CENTER.
    */
    public int horizontalAlignment = DWT.CENTER;

    /**
    * Specifies whether the editor should be sized to use the entire width of the control.
    * True means resize the editor to the same width as the cell.  False means do not adjust
    * the width of the editor.  The default value is false.
    */
    public bool grabHorizontal = false;

    /**
    * Specifies the minimum width the editor can have.  This is used in association with
    * a true value of grabHorizontal.  If the cell becomes smaller than the minimumWidth, the
    * editor will not made smaller than the minimum width value.  The default value is 0.
    */
    public int minimumWidth = 0;

    /**
    * Specifies how the editor should be aligned relative to the control.  Allowed values
    * are DWT.TOP, DWT.BOTTOM and DWT.CENTER.  The default value is DWT.CENTER.
    */
    public int verticalAlignment = DWT.CENTER;

    /**
    * Specifies whether the editor should be sized to use the entire height of the control.
    * True means resize the editor to the same height as the underlying control.  False means do not adjust
    * the height of the editor. The default value is false.
    */
    public bool grabVertical = false;

    /**
    * Specifies the minimum height the editor can have.  This is used in association with
    * a true value of grabVertical.  If the control becomes smaller than the minimumHeight, the
    * editor will not made smaller than the minimum height value.  The default value is 0.
    */
    public int minimumHeight = 0;

    Composite parent;
    Control editor;
    private bool hadFocus;
    private Listener controlListener;
    private Listener scrollbarListener;

    private final static int [] EVENTS = [DWT.KeyDown, DWT.KeyUp, DWT.MouseDown, DWT.MouseUp, DWT.Resize];
/**
* Creates a ControlEditor for the specified Composite.
*
* @param parent the Composite above which this editor will be displayed
*
*/
public this (Composite parent) {
    this.parent = parent;

    controlListener = new class(this) Listener {
        ControlEditor ce;

        this (ControlEditor ce) {
            this.ce = ce;
        }

        public void handleEvent(Event e) {
            ce.layout ();
        }
    };
    for (int i=0; i<EVENTS.length; i++) {
        parent.addListener (EVENTS [i], controlListener);
    }

    scrollbarListener = new class(this) Listener {
        ControlEditor ce;

        this (ControlEditor ce) {
            this.ce = ce;
        }

        public void handleEvent(Event e) {
            ce.scroll (e);
        }
    };
    ScrollBar hBar = parent.getHorizontalBar ();
    if (hBar !is null) hBar.addListener (DWT.Selection, scrollbarListener);
    ScrollBar vBar = parent.getVerticalBar ();
    if (vBar !is null) vBar.addListener (DWT.Selection, scrollbarListener);
}
Rectangle computeBounds () {
    Rectangle clientArea = parent.getClientArea();
    Rectangle editorRect = new Rectangle(clientArea.x, clientArea.y, minimumWidth, minimumHeight);

    if (grabHorizontal)
        editorRect.width = Math.max(clientArea.width, minimumWidth);

    if (grabVertical)
        editorRect.height = Math.max(clientArea.height, minimumHeight);

    switch (horizontalAlignment) {
        case DWT.RIGHT:
            editorRect.x += clientArea.width - editorRect.width;
            break;
        case DWT.LEFT:
            // do nothing - clientArea.x is the right answer
            break;
        default:
            // default is CENTER
            editorRect.x += (clientArea.width - editorRect.width)/2;
    }

    switch (verticalAlignment) {
        case DWT.BOTTOM:
            editorRect.y += clientArea.height - editorRect.height;
            break;
        case DWT.TOP:
            // do nothing - clientArea.y is the right answer
            break;
        default :
            // default is CENTER
            editorRect.y += (clientArea.height - editorRect.height)/2;
    }


    return editorRect;

}
/**
 * Removes all associations between the Editor and the underlying composite.  The
 * composite and the editor Control are <b>not</b> disposed.
 */
public void dispose () {
    if (parent !is null && !parent.isDisposed()) {
        for (int i=0; i<EVENTS.length; i++) {
            parent.removeListener (EVENTS [i], controlListener);
        }
        ScrollBar hBar = parent.getHorizontalBar ();
        if (hBar !is null) hBar.removeListener (DWT.Selection, scrollbarListener);
        ScrollBar vBar = parent.getVerticalBar ();
        if (vBar !is null) vBar.removeListener (DWT.Selection, scrollbarListener);
    }

    parent = null;
    editor = null;
    hadFocus = false;
    controlListener = null;
    scrollbarListener = null;
}
/**
* Returns the Control that is displayed above the composite being edited.
*
* @return the Control that is displayed above the composite being edited
*/
public Control getEditor () {
    return editor;
}
/**
 * Lays out the control within the underlying composite.  This
 * method should be called after changing one or more fields to
 * force the Editor to resize.
 *
 * @since 2.1
 */
public void layout () {
    if (editor is null || editor.isDisposed()) return;
    if (editor.getVisible ()) {
        hadFocus = editor.isFocusControl();
    } // this doesn't work because
      // resizing the column takes the focus away
      // before we get here
    editor.setBounds (computeBounds ());
    if (hadFocus) {
        if (editor is null || editor.isDisposed()) return;
        editor.setFocus ();
    }
}
void scroll (Event e) {
    if (editor is null || editor.isDisposed()) return;
    layout();
}
/**
* Specify the Control that is to be displayed.
*
* <p>Note: The Control provided as the editor <b>must</b> be created with its parent
* being the Composite specified in the ControlEditor constructor.
*
* @param editor the Control that is displayed above the composite being edited
*/
public void setEditor (Control editor) {

    if (editor is null) {
        // this is the case where the caller is setting the editor to be blank
        // set all the values accordingly
        this.editor = null;
        return;
    }

    this.editor = editor;
    layout();
    if (this.editor is null || this.editor.isDisposed()) return;
    editor.setVisible(true);
}
}
