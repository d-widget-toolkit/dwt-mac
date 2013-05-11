module snippet138;

import dwt.DWT;
import dwt.graphics.GC;
import dwt.graphics.Image;
import dwt.widgets.Display;
import dwt.widgets.Shell;

void main() {
    Display display = new Display();
		
    Image small = new Image(display, 16, 16);
    GC gc = new GC(small);
    gc.setBackground(display.getSystemColor(DWT.COLOR_RED));
    gc.fillArc(0, 0, 16, 16, 45, 270);
    gc.dispose();
		
    Image large = new Image(display, 32, 32);
    gc = new GC(large);
    gc.setBackground(display.getSystemColor(DWT.COLOR_RED));
    gc.fillArc(0, 0, 32, 32, 45, 270);
    gc.dispose();
		
    /* Provide different resolutions for icons to get
     * high quality rendering wherever the OS needs 
     * large icons. For example, the ALT+TAB window 
     * on certain systems uses a larger icon.
     */
    Shell shell = new Shell(display);
    shell.setText("Small and Large icons");
    shell.setImages([small, large]);

    /* No large icon: the OS will scale up the
     * small icon when it needs a large one.
     */
    Shell shell2 = new Shell(display);
    shell2.setText("Small icon");
    shell2.setImage(small);
		
    shell.open();
    shell2.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch())
            display.sleep();
    }
    small.dispose();
    large.dispose();
    display.dispose();
}