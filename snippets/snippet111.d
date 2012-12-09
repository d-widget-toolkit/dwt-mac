module snippet111;

import tango.text.convert.Format;

import dwt.DWT;
import dwt.graphics.Color;
import dwt.graphics.Rectangle;
import dwt.graphics.GC;
import dwt.widgets.Display;
import dwt.widgets.Shell;
import dwt.widgets.Widget;
import dwt.widgets.Composite;
import dwt.widgets.Tree;
import dwt.widgets.TreeItem;
import dwt.widgets.Text;
import dwt.widgets.Listener;
import dwt.widgets.Event;
import dwt.graphics.Point;
import dwt.layout.FillLayout;
import dwt.custom.TreeEditor;
import dwt.dwthelper.utils;

void main () {

    Tree tree;
    Color black;
    void handleResize (Event e, Composite composite, Text text, int inset ) {
        Rectangle rect = composite.getClientArea ();
        text.setBounds (rect.x + inset, rect.y + inset, rect.width - inset * 2, rect.height - inset * 2);
    }
    void handleTextEvent (Event e, Composite composite, TreeItem item, TreeEditor editor,Text text, int inset ) {
        switch (e.type) {
        case DWT.FocusOut: {
            item.setText (text.getText ());
            composite.dispose ();
        }
        break;
        case DWT.Verify: {
            String newText = text.getText ();
            String leftText = newText.substring (0, e.start);
            String rightText = newText.substring (e.end, newText.length);
            GC gc = new GC (text);
            Point size = gc.textExtent (leftText ~ e.text ~ rightText);
            gc.dispose ();
            size = text.computeSize (size.x, DWT.DEFAULT);
            editor.horizontalAlignment = DWT.LEFT;
            Rectangle itemRect = item.getBounds (), rect = tree.getClientArea ();
            editor.minimumWidth = Math.max (size.x, itemRect.width) + inset* 2;
            int left = itemRect.x, right = rect.x + rect.width;
            editor.minimumWidth = Math.min (editor.minimumWidth, right - left);
            editor.minimumHeight = size.y + inset* 2;
            editor.layout ();
        }
        break;
        case DWT.Traverse: {
            switch (e.detail) {
            case DWT.TRAVERSE_RETURN:
                item.setText (text.getText ());
                //FALL THROUGH
            case DWT.TRAVERSE_ESCAPE:
                composite.dispose ();
                e.doit = false;
            default:
                //no-op
            }
            break;
        }
        default:
        // no-op
        }
    }
    void handleSelection (Event event, TreeItem[] lastItem, TreeEditor editor ) {
        TreeItem item = cast(TreeItem) event.item;
        if (item !is null && item is lastItem [0]) {
            bool showBorder = true;
            Composite composite = new Composite (tree, DWT.NONE);
            if (showBorder) composite.setBackground (black);
            Text text = new Text (composite, DWT.NONE);
            int inset = showBorder ? 1 : 0;
            composite.addListener (DWT.Resize, dgListener( &handleResize, composite, text, inset ));
            Listener textListener = dgListener( &handleTextEvent, composite, item, editor, text, inset);
            text.addListener (DWT.FocusOut, textListener);
            text.addListener (DWT.Traverse, textListener);
            text.addListener (DWT.Verify, textListener);
            editor.setEditor (composite, item);
            text.setText (item.getText ());
            text.selectAll ();
            text.setFocus ();
        }
        lastItem [0] = item;
    }

    Display display = new Display ();
    black = display.getSystemColor (DWT.COLOR_BLACK);
    Shell shell = new Shell (display);
    shell.setLayout (new FillLayout ());
    tree = new Tree (shell, DWT.BORDER);
    for (int i=0; i<16; i++) {
        TreeItem itemI = new TreeItem (tree, DWT.NONE);
        itemI.setText (Format("Item {}", i));
        for (int j=0; j<16; j++) {
            TreeItem itemJ = new TreeItem (itemI, DWT.NONE);
            itemJ.setText ( Format("Item {}", j) );
        }
    }
    TreeItem [] lastItem = new TreeItem [1];
    TreeEditor editor = new TreeEditor (tree);
    tree.addListener (DWT.Selection, dgListener( &handleSelection, lastItem, editor ));
    shell.pack ();
    shell.open ();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}