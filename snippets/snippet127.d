module snippet127;

import dwt.DWT;
import dwt.events.TraverseEvent;
import dwt.events.TraverseListener;
import dwt.widgets.Button;
import dwt.widgets.Display;
import dwt.widgets.Event;
import dwt.widgets.Listener;
import dwt.widgets.Shell;
import dwt.layout.RowLayout;

import dwt.dwthelper.utils;

void main () {
    Display display = new Display ();
    Shell shell = new Shell (display);
    shell.setLayout(new RowLayout ());
    Button button1 = new Button(shell, DWT.PUSH);
    button1.setText("Can't Traverse");
    button1.addTraverseListener(new class TraverseListener{
        public void keyTraversed(TraverseEvent e) {
            switch (e.detail) {
            case DWT.TRAVERSE_TAB_NEXT:
            case DWT.TRAVERSE_TAB_PREVIOUS:
                e.doit = false;
            default:
            }
        }
    });
    Button button2 = new Button (shell, DWT.PUSH);
    button2.setText("Can Traverse");
    shell.pack ();
    shell.open();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}