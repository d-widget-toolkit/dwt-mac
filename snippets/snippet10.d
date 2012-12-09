module snippet10;

import dwt.DWT;
import dwt.graphics.GC;
import dwt.graphics.Path;
import dwt.graphics.Transform;
import dwt.graphics.Font;
import dwt.graphics.FontData;
import dwt.graphics.Image;
import dwt.graphics.Rectangle;
import dwt.widgets.Display;
import dwt.widgets.Shell;
import dwt.widgets.Listener;
import dwt.widgets.Event;

void main() {
    Display display = new Display();
    Shell shell = new Shell(display);
    shell.setText("Advanced Graphics");
    FontData fd = shell.getFont().getFontData()[0];
    Font font = new Font(display, fd.getName(), 60., DWT.BOLD | DWT.ITALIC);
    Image image = new Image(display, 640, 480);
    Rectangle rect = image.getBounds();
    GC gc = new GC(image);
    gc.setBackground(display.getSystemColor(DWT.COLOR_RED));
    gc.fillOval(rect.x, rect.y, rect.width, rect.height);
    gc.dispose();
    shell.addListener(DWT.Paint, new class Listener {
            public void handleEvent(Event event) {
                GC gc = event.gc;               
                Transform tr = new Transform(display);
                tr.translate(50, 120);
                tr.rotate(-30);
                gc.drawImage(image, 0, 0, rect.width, rect.height, 0, 0, rect.width / 2, rect.height / 2);
                gc.setAlpha(100);
                gc.setTransform(tr);
                Path path = new Path(display);
                path.addString("DWT", 0, 0, font);
                gc.setBackground(display.getSystemColor(DWT.COLOR_GREEN));
                gc.setForeground(display.getSystemColor(DWT.COLOR_BLUE));
                gc.fillPath(path);
                gc.drawPath(path);
                tr.dispose();
                path.dispose();
            }           
        });
    shell.setSize(shell.computeSize(rect.width / 2, rect.height / 2));
    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch())
            display.sleep();
    }
    image.dispose();
    font.dispose();
    display.dispose();
}

