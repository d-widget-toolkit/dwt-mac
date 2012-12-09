module snippet132;

import dwt.DWT;
// dwt.widgets
import dwt.widgets.Display,
       dwt.widgets.MessageBox,
       dwt.widgets.Shell;
// dwt.graphics
import dwt.graphics.Color,
       dwt.graphics.GC,
       dwt.graphics.Point,
       dwt.graphics.Rectangle;
// dwt.printing
import dwt.printing.PrintDialog, 
       dwt.printing.Printer, 
       dwt.printing.PrinterData;
// java
import dwt.dwthelper.utils;

void main(){
    Display display = new Display();
    Shell shell = new Shell(display);
    shell.open();
    PrinterData data = Printer.getDefaultPrinterData();
    if(data is null){
        MessageBox.showWarning("Warning: No default printer.");
        return;
    }
    Printer printer = new Printer(data);
    if(printer.startJob("DWT Printing Snippet")){
        Color black = printer.getSystemColor(DWT.COLOR_BLACK);
        Color white = printer.getSystemColor(DWT.COLOR_WHITE);
        Color red = printer.getSystemColor(DWT.COLOR_RED);
        Rectangle trim = printer.computeTrim(0, 0, 0, 0);
        Point dpi = printer.getDPI();
        int leftMargin = dpi.x + trim.x; // one inch from left side of paper
        int topMargin = dpi.y / 2 + trim.y; // one-half inch from top edge of paper
        GC gc = new GC(printer);
        if(printer.startPage()){
            gc.setBackground(white);
            gc.setForeground(black);
            String testString = "Hello World!";
            Point extent = gc.stringExtent(testString);
            gc.drawString(testString, leftMargin, topMargin);
            gc.setForeground(red);
            gc.drawRectangle(leftMargin, topMargin, extent.x, extent.y);
            printer.endPage();
        }
        gc.dispose();
        printer.endJob();
    }
    printer.dispose();
    while(!shell.isDisposed()){
      if(!display.readAndDispatch()) display.sleep();
    }
    display.dispose();
}
