module snippet122;

import dwt.DWT;
import dwt.dnd.Clipboard;
import dwt.dnd.TextTransfer;
import dwt.dnd.Transfer;
import dwt.dnd.TransferData;
import dwt.events.MenuAdapter;
import dwt.events.MenuEvent;
import dwt.events.SelectionAdapter;
import dwt.events.SelectionEvent;
import dwt.events.SelectionListener;
import dwt.layout.FillLayout;
import dwt.widgets.Display;
import dwt.widgets.Menu;
import dwt.widgets.MenuItem;
import dwt.widgets.Shell;
import dwt.widgets.Text;

import dwt.dwthelper.utils;

void main() {
    Display display = new Display();
    Clipboard cb = new Clipboard(display);
    Shell shell = new Shell(display);
    shell.setLayout(new FillLayout());
    Text text = new Text(shell, DWT.BORDER | DWT.MULTI | DWT.WRAP);
    Menu menu = new Menu(shell, DWT.POP_UP);
    MenuItem copyItem = new MenuItem(menu, DWT.PUSH);
    copyItem.setText("Copy");
    copyItem.addSelectionListener(new class SelectionAdapter{
        public void widgetSelected(SelectionEvent e) {
            String selection = text.getSelectionText();
            if (selection.length == 0) return;
            Object[] data = [ new ArrayWrapperString(selection) ];
            Transfer[] types = [ TextTransfer.getInstance() ];
            cb.setContents(data, types);
        }
    });
    MenuItem pasteItem = new MenuItem(menu, DWT.PUSH);
    pasteItem.setText ("Paste");
    pasteItem.addSelectionListener(new class SelectionAdapter{
        public void widgetSelected(SelectionEvent e) {
            String string = stringcast(cb.getContents(TextTransfer.getInstance()));
            if (string !is null) text.insert(string);
        }
    });
    menu.addMenuListener(new class MenuAdapter{
        public void menuShown(MenuEvent e) {
            // is copy valid?
            String selection = text.getSelectionText();
            copyItem.setEnabled(selection.length > 0);
            // is paste valid?
            TransferData[] available = cb.getAvailableTypes();
            bool enabled = false;
            for (int i = 0; i < available.length; i++) {
                if (TextTransfer.getInstance().isSupportedType(available[i])) {
                    enabled = true;
                    break;
                }
            }
            pasteItem.setEnabled(enabled);
        }
    });

    text.setMenu (menu);
    shell.setSize(200, 200);
    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch())
            display.sleep();
    }
    cb.dispose();
    display.dispose();
}