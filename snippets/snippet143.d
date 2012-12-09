module snippet143;

import dwt.DWT;
import dwt.graphics.Image;
import dwt.widgets.Shell;
import dwt.widgets.Display;
import dwt.widgets.Menu;
import dwt.widgets.MenuItem;
import dwt.widgets.Tray;
import dwt.widgets.TrayItem;
import dwt.widgets.Listener;
import dwt.widgets.Event;

import dwt.dwthelper.utils;
import tango.io.Stdout;
import tango.text.convert.Format;

void writeln(in char[] line) {
    Stdout(line)("\n").flush();
}

void main() {
    TrayItem item;
    Menu menu;

    Display display = new Display ();
    Shell shell = new Shell (display);
    Image image = new Image (display, 16, 16);
    Tray tray = display.getSystemTray ();
    if (tray is null) {
        writeln("The system tray is not available");
    } else {
        item = new TrayItem (tray, DWT.NONE);
        item.setToolTipText("DWT TrayItem");
        item.addListener (DWT.Show, new class Listener {
            public void handleEvent (Event event) {
                writeln("show");
            }
        });
        item.addListener (DWT.Hide, new class Listener {
            public void handleEvent (Event event) {
                writeln("hide");
            }
        });
        item.addListener (DWT.Selection, new class Listener {
            public void handleEvent (Event event) {
                writeln("selection");
            }
        });
        item.addListener (DWT.DefaultSelection, new class Listener {
            public void handleEvent (Event event) {
                writeln("default selection");
            }
        });
        menu = new Menu (shell, DWT.POP_UP);
        for (int i = 0; i < 8; i++) {
            MenuItem mi = new MenuItem (menu, DWT.PUSH);
            mi.setText ( Format( "Item{}", i ));
            mi.addListener (DWT.Selection, new class Listener {
                public void handleEvent (Event event) {
                    writeln ( Format( "selection {}", event.widget ) );
                }
            });
            if (i == 0) menu.setDefaultItem(mi);
        }
        item.addListener (DWT.MenuDetect, new class Listener {
            public void handleEvent (Event event) {
                menu.setVisible (true);
            }
        });
        item.setImage (image);
    }
    shell.setBounds(50, 50, 300, 200);
    shell.open ();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    image.dispose ();
    display.dispose ();
}