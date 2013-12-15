module snippet146;

import dwt.DWT;
import dwt.widgets.Display;
import dwt.widgets.Event;
import dwt.widgets.Shell;
import dwt.widgets.Text;

import dwt.dwthelper.utils;

version(Tango){
    import tango.core.Thread;
    import tango.text.Unicode;
} else {
    import std.string;
    import std.uni;
}

void main() {
    Display display = new Display();
    Shell shell = new Shell(display);
    Text text = new Text(shell, DWT.BORDER);
    text.setSize(text.computeSize(150, DWT.DEFAULT));
    shell.pack();
    shell.open();
    Thread thread = new Thread({
        String string = "Love the method.";
        String lstring;
        version(Tango){
            lstring. length = string.length;
            toLower(string, lstring);
        } else {
            lstring = toLower(string);
        }
        for (int i = 0; i < string.length; i++) {
            char ch = string.charAt(i);
            bool shift = cast(bool) isUpper(ch);
            ch = lstring.charAt(i);
            if (shift) {
                Event event = new Event();
                event.type = DWT.KeyDown;
                event.keyCode = DWT.SHIFT;
                display.post(event);    
            }
            Event event = new Event();
            event.type = DWT.KeyDown;
            event.character = ch;
            display.post(event);
            try {
                Thread.sleep(0.01);
            } catch (InterruptedException e) {}
            event.type = DWT.KeyUp;
            display.post(event);
            try {
                Thread.sleep(0.1);
            } catch (InterruptedException e) {}
            if (shift) {
                event = new Event();
                event.type = DWT.KeyUp;
                event.keyCode = DWT.SHIFT;
                display.post(event);    
            }
        }
    });
    thread.start();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch()) display.sleep();
    }
    display.dispose();
}

