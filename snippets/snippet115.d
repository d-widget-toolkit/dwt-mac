module snippet115;

import tango.text.convert.Format;

import dwt.DWT;
import dwt.widgets.Button;
import dwt.widgets.Composite;
import dwt.widgets.Control;
import dwt.widgets.Display;
import dwt.widgets.Event;
import dwt.widgets.Listener;
import dwt.widgets.Shell;
import dwt.layout.RowLayout;

import dwt.dwthelper.utils;

void main () {
    Display display = new Display ();
    Shell shell = new Shell (display);
    shell.setLayout (new RowLayout (DWT.VERTICAL));
    Composite c1 = new Composite (shell, DWT.BORDER | DWT.NO_RADIO_GROUP);
    c1.setLayout (new RowLayout ());
    Composite c2 = new Composite (shell, DWT.BORDER | DWT.NO_RADIO_GROUP);
    c2.setLayout (new RowLayout ());
    Composite [] composites = [c1, c2];
    Listener radioGroup = new class Listener{
        public void handleEvent (Event event) {
            for (int i=0; i<composites.length; i++) {
                Composite composite = composites [i];
                Control [] children = composite.getChildren ();
                for (int j=0; j<children.length; j++) {
                    Control child = children [j];
                    if (cast(Button)child !is  null) {
                        Button button = cast(Button) child;
                        if ((button.getStyle () & DWT.RADIO) != 0) button.setSelection (false);
                    }
                }
            }
            Button button = cast(Button) event.widget;
            button.setSelection (true);
        }
    };
    for (int i=0; i<4; i++) {
        Button button = new Button (c1, DWT.RADIO);
        button.setText (Format("Button {}",i));
        button.addListener (DWT.Selection, radioGroup);
    }
    for (int i=0; i<4; i++) {
        Button button = new Button (c2, DWT.RADIO);
        button.setText (Format("Button {}",(i + 4)));
        button.addListener (DWT.Selection, radioGroup);
    }
    shell.pack ();
    shell.open ();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}
