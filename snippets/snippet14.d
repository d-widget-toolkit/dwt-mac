module snippet14;

import dwt.DWT;
import dwt.widgets.Display;
import dwt.widgets.Event;
import dwt.widgets.Listener;
import dwt.widgets.Shell;

import dwt.dwthelper.utils;

import tango.io.Stdout;
void writeln(in char[] line) {
    Stdout(line)("\n").flush();
}

void main () {
    Display display = new Display ();
    Shell shell = new Shell (display);
    shell.setSize (100, 100);
    shell.addListener (DWT.MouseEnter, new class Listener{
        public void handleEvent (Event e) {
            writeln("ENTER");
        }
    });
    shell.addListener (DWT.MouseExit, new class Listener{
        public void handleEvent (Event e) {
            writeln("EXIT");
        }
    });
    shell.addListener (DWT.MouseHover, new class Listener{
        public void handleEvent (Event e) {
            writeln("HOVER");
        }
    });
    shell.open ();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}