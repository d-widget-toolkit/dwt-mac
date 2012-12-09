module snippet133;

import tango.stdc.stdlib;

import dwt.DWT;
// dwt.graphics
import dwt.graphics.Color,
       dwt.graphics.Font,
       dwt.graphics.FontData,
       dwt.graphics.GC,
       dwt.graphics.Point,
       dwt.graphics.Rectangle,
       dwt.graphics.RGB;
// dwt.widgets
import dwt.widgets.Display,
       dwt.widgets.ColorDialog,
       dwt.widgets.FileDialog,
       dwt.widgets.FontDialog,
       dwt.widgets.Menu,
       dwt.widgets.MenuItem,
       dwt.widgets.MessageBox,
       dwt.widgets.Shell,
       dwt.widgets.Text;
// dwt.events
import dwt.events.SelectionAdapter, 
       dwt.events.SelectionEvent;
// dwt.layout
import dwt.layout.FillLayout;
// dwt.printing
import dwt.printing.PrintDialog,
       dwt.printing.Printer,
       dwt.printing.PrinterData;
// java
import dwt.dwthelper.utils;

// tango
import tango.core.Thread;
import tango.io.device.File;
import tango.text.Unicode;

void main(){
    (new Snippet133).open();
}

class Snippet133{
    Display display;
    Shell shell;
    Text text;
    Font font;
    Color foregroundColor, backgroundColor;

    Printer printer;
    GC gc;
    FontData[] printerFontData;
    RGB printerForeground, printerBackground;

    int lineHeight = 0;
    int tabWidth = 0;
    int leftMargin, rightMargin, topMargin, bottomMargin;
    int x, y;
    int index, end;
    String textToPrint;
    String tabs;
    StringBuffer wordBuffer;

    public void 
        open(){
            display = new Display();
            shell = new Shell(display);
            shell.setLayout(new FillLayout());
            shell.setText("Print Text");
            text = new Text(shell, DWT.BORDER | DWT.MULTI | DWT.V_SCROLL | DWT.H_SCROLL);

            Menu menuBar = new Menu(shell, DWT.BAR);
            shell.setMenuBar(menuBar);
            MenuItem item = new MenuItem(menuBar, DWT.CASCADE);
            item.setText("&File");
            Menu fileMenu = new Menu(shell, DWT.DROP_DOWN);
            item.setMenu(fileMenu);
            item = new MenuItem(fileMenu, DWT.PUSH);
            item.setText("&Open...");
            item.setAccelerator(DWT.CTRL + 'O');
            item.addSelectionListener(new class SelectionAdapter{
                public void widgetSelected(SelectionEvent event) {
                    menuOpen();
                }
            });
            item = new MenuItem(fileMenu, DWT.PUSH);
            item.setText("Font...");
            item.addSelectionListener(new class SelectionAdapter{
                public void widgetSelected(SelectionEvent event){
                    menuFont();
                }
            });
            item = new MenuItem(fileMenu, DWT.PUSH);
            item.setText("Foreground Color...");
            item.addSelectionListener(new class SelectionAdapter{
                public void widgetSelected(SelectionEvent event){
                    menuForegroundColor();
                }
            });
            item = new MenuItem(fileMenu, DWT.PUSH);
            item.setText("Background Color...");
            item.addSelectionListener(new class SelectionAdapter{
                public void widgetSelected(SelectionEvent event) {
                    menuBackgroundColor();
                }
            });
            item = new MenuItem(fileMenu, DWT.PUSH);
            item.setText("&Print...");
            item.setAccelerator(DWT.CTRL + 'P');
            item.addSelectionListener(new class SelectionAdapter{
                public void widgetSelected(SelectionEvent event) {
                    menuPrint();
                }
            });
            new MenuItem(fileMenu, DWT.SEPARATOR);
            item = new MenuItem(fileMenu, DWT.PUSH);
            item.setText("E&xit");
            item.addSelectionListener(new class SelectionAdapter{
                public void widgetSelected(SelectionEvent event){
                    exit(0);
                }
            });

            shell.open();
            while (!shell.isDisposed()) {
                if (!display.readAndDispatch()) display.sleep();
            }
            if (font !is null) font.dispose();
            if (foregroundColor !is null) foregroundColor.dispose();
            if (backgroundColor !is null) backgroundColor.dispose();
            display.dispose();
        }

    private void menuOpen(){
        String textString;
        FileDialog dialog = new FileDialog(shell, DWT.OPEN);
        dialog.setFilterExtensions(["*.java", "*.*"]);
        String name = dialog.open();
        if(name is null) return;

        try{
            try{
                version(Tango){
                    textString = cast(char[])File.get(name);
                } else { // Phobos
                    textString = cast(String)std.file.read(name);
                }
            }
            catch (IOException e){
                MessageBox box = new MessageBox(shell, DWT.ICON_ERROR);
                box.setMessage("Error reading file:\n" ~ name);
                box.open();
                return;
            }
        }
        catch(Exception e){
            MessageBox box = new MessageBox(shell, DWT.ICON_ERROR);
            box.setMessage("File not found:\n" ~ name);
            box.open();
            return;
        }	
        text.setText(textString);
    }

    private void 
        menuFont(){
            FontDialog fontDialog = new FontDialog(shell);
            fontDialog.setFontList(text.getFont().getFontData());
            FontData fontData = fontDialog.open();
            if(fontData !is null){
                if(font !is null) font.dispose();
                font = new Font(display, fontData);
                text.setFont(font);
            }
        }

    private void 
        menuForegroundColor(){
            ColorDialog colorDialog = new ColorDialog(shell);
            colorDialog.setRGB(text.getForeground().getRGB());
            RGB rgb = colorDialog.open();
            if(rgb !is null){
                if(foregroundColor !is null) foregroundColor.dispose();
                foregroundColor = new Color(display, rgb);
                text.setForeground(foregroundColor);
            }
        }

    private void 
        menuBackgroundColor(){
            ColorDialog colorDialog = new ColorDialog(shell);
            colorDialog.setRGB(text.getBackground().getRGB());
            RGB rgb = colorDialog.open();
            if(rgb !is null){
                if(backgroundColor !is null) backgroundColor.dispose();
                backgroundColor = new Color(display, rgb);
                text.setBackground(backgroundColor);
            }
        }

    private void 
        menuPrint(){
            PrintDialog dialog = new PrintDialog(shell, DWT.NONE);
            PrinterData data = dialog.open();
            if(data is null) return;
            if(data.printToFile){
                data.fileName = "print.out"; // you probably want to ask the user for a filename
            }

            /* Get the text to print from the Text widget (you could get it from anywhere, i.e. your java model) */
            textToPrint = text.getText();

            /* Get the font & foreground & background data. */
            printerFontData = text.getFont().getFontData();
            printerForeground = text.getForeground().getRGB();
            printerBackground = text.getBackground().getRGB();

            /* Do the printing in a background thread so that spooling does not freeze the UI. */
            printer = new Printer(data);
            Thread printingThread = new class ("Printing") Thread{
                private void 
                    run(){
                        print(printer);
                        printer.dispose();
                    }
                public 
                    this(String o_name){
                        //this.name = o_name;
                        super(&run);
                    }
            };
            printingThread.start();
        }

    private void 
        print(Printer printer){
            if(printer.startJob("Text")){   // the string is the job name - shows up in the printer's job list
                Rectangle clientArea = printer.getClientArea();
                Rectangle trim = printer.computeTrim(0, 0, 0, 0);
                Point dpi = printer.getDPI();
                leftMargin = dpi.x + trim.x; // one inch from left side of paper
                rightMargin = clientArea.width - dpi.x + trim.x + trim.width; // one inch from right side of paper
                topMargin = dpi.y + trim.y; // one inch from top edge of paper
                bottomMargin = clientArea.height - dpi.y + trim.y + trim.height; // one inch from bottom edge of paper

                /* Create a buffer for computing tab width. */
                int tabSize = 4; // is tab width a user setting in your UI?
                StringBuffer tabBuffer = new StringBuffer(tabSize);
                for (int i = 0; i < tabSize; i++) tabBuffer.append(' ');
                tabs = tabBuffer.toString();

                /* Create printer GC, and create and set the printer font & foreground color. */
                gc = new GC(printer);
                Font printerFont = new Font(printer, printerFontData);
                Color printerForegroundColor = new Color(printer, printerForeground);
                Color printerBackgroundColor = new Color(printer, printerBackground); 

                gc.setFont(printerFont);
                gc.setForeground(printerForegroundColor);
                gc.setBackground(printerBackgroundColor);
                tabWidth = gc.stringExtent(tabs).x;
                lineHeight = gc.getFontMetrics().getHeight();

                /* Print text to current gc using word wrap */
                printText();
                printer.endJob();

                /* Cleanup graphics resources used in printing */
                printerFont.dispose();
                printerForegroundColor.dispose();
                printerBackgroundColor.dispose();
                gc.dispose();
            }
        }

    private void 
        printText(){
            printer.startPage();
            wordBuffer = new StringBuffer();
            x = leftMargin;
            y = topMargin;
            index = 0;
            end = textToPrint.length;
            while(index < end){
                char c = textToPrint.charAt(index);
                index++;
                if(c != 0){
                    if(c == 0x0a || c == 0x0d){
                        if(c == 0x0d && index < end && textToPrint.charAt(index) == 0x0a){
                            index++; // if this is cr-lf, skip the lf
                        }
                        printWordBuffer();
                        newline();
                    } 
                    else{
                        if(c != '\t'){
                            wordBuffer.append(c);
                        }
                        if(isPrintable(c)){
                            printWordBuffer();
                            if (c == '\t'){
                                x += tabWidth;
                            }
                        }
                    }
                }
            }
            if (y + lineHeight <= bottomMargin) {
                printer.endPage();
            }
        }

    private void 
        printWordBuffer(){
            if(wordBuffer.length > 0){
                String word = wordBuffer.toString();
                int wordWidth = gc.stringExtent(word).x;
                if(x + wordWidth > rightMargin){
                    /* word doesn't fit on current line, so wrap */
                    newline();
                }
                gc.drawString(word, x, y, false);
                x += wordWidth;
                wordBuffer = new StringBuffer();
            }
        }

    private void 
        newline(){
            x = leftMargin;
            y += lineHeight;
            if(y + lineHeight > bottomMargin){
                printer.endPage();
                if(index + 1 < end){
                    y = topMargin;
                    printer.startPage();
                }
            }
        }
}

