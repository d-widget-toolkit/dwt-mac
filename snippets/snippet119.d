module snippet119;

import dwt.DWT;
import dwt.events.PaintEvent;
import dwt.events.PaintListener;
import dwt.graphics.Color;
import dwt.graphics.Cursor;
import dwt.graphics.GC;
import dwt.graphics.Image;
import dwt.graphics.ImageData;
import dwt.graphics.PaletteData;
import dwt.widgets.Display;
import dwt.widgets.Shell;

import dwt.dwthelper.utils;

auto srcData = [
        cast(byte)0x11, cast(byte)0x11, cast(byte)0x11, cast(byte)0x00, cast(byte)0x00, cast(byte)0x11, cast(byte)0x11, cast(byte)0x11,
        cast(byte)0x11, cast(byte)0x10, cast(byte)0x00, cast(byte)0x01, cast(byte)0x10, cast(byte)0x00, cast(byte)0x01, cast(byte)0x11,
        cast(byte)0x11, cast(byte)0x00, cast(byte)0x22, cast(byte)0x01, cast(byte)0x10, cast(byte)0x33, cast(byte)0x00, cast(byte)0x11,
        cast(byte)0x10, cast(byte)0x02, cast(byte)0x22, cast(byte)0x01, cast(byte)0x10, cast(byte)0x33, cast(byte)0x30, cast(byte)0x01,
        cast(byte)0x10, cast(byte)0x22, cast(byte)0x22, cast(byte)0x01, cast(byte)0x10, cast(byte)0x33, cast(byte)0x33, cast(byte)0x01,
        cast(byte)0x10, cast(byte)0x22, cast(byte)0x22, cast(byte)0x01, cast(byte)0x10, cast(byte)0x33, cast(byte)0x33, cast(byte)0x01,
        cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00,
        cast(byte)0x01, cast(byte)0x11, cast(byte)0x11, cast(byte)0x01, cast(byte)0x10, cast(byte)0x11, cast(byte)0x11, cast(byte)0x10,
        cast(byte)0x01, cast(byte)0x11, cast(byte)0x11, cast(byte)0x01, cast(byte)0x10, cast(byte)0x11, cast(byte)0x11, cast(byte)0x10,
        cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00,
        cast(byte)0x10, cast(byte)0x44, cast(byte)0x44, cast(byte)0x01, cast(byte)0x10, cast(byte)0x55, cast(byte)0x55, cast(byte)0x01,
        cast(byte)0x10, cast(byte)0x44, cast(byte)0x44, cast(byte)0x01, cast(byte)0x10, cast(byte)0x55, cast(byte)0x55, cast(byte)0x01,
        cast(byte)0x10, cast(byte)0x04, cast(byte)0x44, cast(byte)0x01, cast(byte)0x10, cast(byte)0x55, cast(byte)0x50, cast(byte)0x01,
        cast(byte)0x11, cast(byte)0x00, cast(byte)0x44, cast(byte)0x01, cast(byte)0x10, cast(byte)0x55, cast(byte)0x00, cast(byte)0x11,
        cast(byte)0x11, cast(byte)0x10, cast(byte)0x00, cast(byte)0x01, cast(byte)0x10, cast(byte)0x00, cast(byte)0x01, cast(byte)0x11,
        cast(byte)0x11, cast(byte)0x11, cast(byte)0x11, cast(byte)0x00, cast(byte)0x00, cast(byte)0x11, cast(byte)0x11, cast(byte)0x11,
];

auto mskData = [
        cast(byte)0x03, cast(byte)0xc0,
        cast(byte)0x1f, cast(byte)0xf8,
        cast(byte)0x3f, cast(byte)0xfc,
        cast(byte)0x7f, cast(byte)0xfe,
        cast(byte)0x7f, cast(byte)0xfe,
        cast(byte)0x7f, cast(byte)0xfe,
        cast(byte)0xff, cast(byte)0xff,
        cast(byte)0xfe, cast(byte)0x7f,
        cast(byte)0xfe, cast(byte)0x7f,
        cast(byte)0xff, cast(byte)0xff,
        cast(byte)0x7f, cast(byte)0xfe,
        cast(byte)0x7f, cast(byte)0xfe,
        cast(byte)0x7f, cast(byte)0xfe,
        cast(byte)0x3f, cast(byte)0xfc,
        cast(byte)0x1f, cast(byte)0xf8,
        cast(byte)0x03, cast(byte)0xc0
];

void main (String [] args) {
    Display display = new Display();
    Color white = display.getSystemColor (DWT.COLOR_WHITE);
    Color black = display.getSystemColor (DWT.COLOR_BLACK);
    Color yellow = display.getSystemColor (DWT.COLOR_YELLOW);
    Color red = display.getSystemColor (DWT.COLOR_RED);
    Color green = display.getSystemColor (DWT.COLOR_GREEN);
    Color blue = display.getSystemColor (DWT.COLOR_BLUE);

    //Create a source ImageData of depth 4
    PaletteData palette = new PaletteData ([black.getRGB(), white.getRGB(), yellow.getRGB(),
                                            red.getRGB(), blue.getRGB(), green.getRGB()]);
    ImageData sourceData = new ImageData (16, 16, 4, palette, 1, srcData[]);

    //Create a mask ImageData of depth 1 (monochrome)
    palette = new PaletteData ([black.getRGB(), white.getRGB()]);
    ImageData maskData = new ImageData (16, 16, 1, palette, 1, mskData[]);

    //Set mask
    sourceData.maskData = maskData.data;
    sourceData.maskPad = maskData.scanlinePad;

    //Create cursor
    Cursor cursor = new Cursor(display, sourceData, 10, 10);

    //Remove mask to draw them separately just to show what they look like
    sourceData.maskData = null;
    sourceData.maskPad = -1;

    Shell shell = new Shell(display);
    Image source = new Image (display,sourceData);
    Image mask = new Image (display, maskData);
    shell.addPaintListener(new class PaintListener{
        public void paintControl(PaintEvent e) {
            GC gc = e.gc;
            int x = 10, y = 10;
            String stringSource = "source: ";
            String stringMask = "mask: ";
            gc.drawString(stringSource, x, y);
            gc.drawString(stringMask, x, y + 30);
            x += Math.max(gc.stringExtent(stringSource).x, gc.stringExtent(stringMask).x);
            gc.drawImage(source, x, y);
            gc.drawImage(mask, x, y + 30);
        }
    });
    shell.setSize(150, 150);
    shell.open();
    shell.setCursor(cursor);

    while (!shell.isDisposed()) {
        if (!display.readAndDispatch())
            display.sleep();
    }
    cursor.dispose();
    source.dispose();
    mask.dispose();
    display.dispose();
}
