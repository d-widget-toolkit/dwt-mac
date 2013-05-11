module snippet16;

import dwt.graphics.Point;
import dwt.graphics.Rectangle;
import dwt.widgets.Display;
import dwt.widgets.Shell;

import dwt.dwthelper.Runnable;
import dwt.dwthelper.utils;

version(Tango){
    import tango.io.Stdout;
    void writeln(in char[] line) {
        Stdout(line)("\n").flush();
    }
} else { // Phobos
    import std.stdio;
}

void main (String [] args) {
    Display display = new Display ();
    Shell shell = new Shell (display);
    int time = 500;
    Runnable timer;
    timer = dgRunnable( {
        Point point = display.getCursorLocation ();
        Rectangle rect = shell.getBounds ();
        if (rect.contains (point)) {
            writeln("In");
        } else {
            writeln("Out");
        }
        display.timerExec (time, timer);
    });
    display.timerExec (time, timer);
    shell.setSize (200, 200);
    shell.open ();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose (); 
}
