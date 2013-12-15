module snippet142;

import dwt.DWT;
import dwt.graphics.Point;
import dwt.widgets.Button;
import dwt.widgets.Display;
import dwt.widgets.Event;
import dwt.widgets.Listener;
import dwt.widgets.Shell;

import dwt.dwthelper.utils;

import tango.core.Thread;
import tango.io.Stdout;
import tango.text.convert.Format;

void writeln(in char[] line) {
    Stdout(line)("\n").flush();
}

void main() {
    Display display = new Display();
    Shell shell = new Shell(display);
    Button button = new Button(shell,DWT.NONE);
    button.setSize(100,100);
    button.setText("Click");
    shell.pack();
    shell.open();
    button.addListener(DWT.MouseDown, dgListener( (Event e){
        writeln(Format("Mouse Down  (Button: {} x: {} y: {})", e.button, e.x, e.y));
    }));
    Point pt = display.map(shell, null, 50, 50);
    Thread thread = new Thread({
        Event event;
        try {
            Thread.sleep(0.3);
        } catch (InterruptedException e) {}
        event = new Event();
        event.type = DWT.MouseMove;
        event.x = pt.x;
        event.y = pt.y;
        display.post(event);
        try {
            Thread.sleep(0.3);
        } catch (InterruptedException e) {}
        event.type = DWT.MouseDown;
        event.button = 1;
        display.post(event);
        try {
            Thread.sleep(0.3);
        } catch (InterruptedException e) {}
        event.type = DWT.MouseUp;
        display.post(event);
    });
    thread.start();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch()) display.sleep();
    }
    display.dispose();
}

