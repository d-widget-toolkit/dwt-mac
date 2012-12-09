module snippet118;

import dwt.DWT;
import dwt.graphics.Cursor;
import dwt.graphics.ImageData;
import dwt.graphics.Point;
import dwt.widgets.Button;
import dwt.widgets.Display;
import dwt.widgets.FileDialog;
import dwt.widgets.Event;
import dwt.widgets.Listener;
import dwt.widgets.Shell;

import dwt.dwthelper.utils;

void main () {
    Display display = new Display();
    Shell shell = new Shell(display);
    shell.setSize(150, 150);
    Cursor[1] cursor;
    Button button = new Button(shell, DWT.PUSH);
    button.setText("Change cursor");
    Point size = button.computeSize(DWT.DEFAULT, DWT.DEFAULT);
    button.setSize(size);
    button.addListener(DWT.Selection, new class Listener{
        public void handleEvent(Event e) {
            FileDialog dialog = new FileDialog(shell);
            dialog.setFilterExtensions(["*.ico", "*.gif", "*.*"]);
            String name = dialog.open();
            if (name is null) return;
            ImageData image = new ImageData(name);
            Cursor oldCursor = cursor[0];
            cursor[0] = new Cursor(display, image, 0, 0);
            shell.setCursor(cursor[0]);
            if (oldCursor !is null) oldCursor.dispose();
        }
    });
    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch())
            display.sleep();
    }
    if (cursor[0] !is null) cursor[0].dispose();
    display.dispose();
}