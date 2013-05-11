module snippet152;

import dwt.DWT;
import dwt.widgets.Display;
import dwt.widgets.Shell;
import dwt.widgets.Event;
import dwt.widgets.Listener;
import dwt.widgets.Label;
import dwt.widgets.Menu;
import dwt.widgets.MenuItem;
import dwt.layout.FormLayout;
import dwt.layout.FormData;
import dwt.layout.FormAttachment;
import dwt.dwthelper.utils;

void main() {
    Display display = new Display();
    Shell shell = new Shell(display);
    FormLayout layout = new FormLayout();
    shell.setLayout(layout);
    Label label = new Label(shell, DWT.BORDER);
    Listener armListener = new class Listener {
        public void handleEvent(Event event) {
            MenuItem item = cast(MenuItem) event.widget;
            label.setText(item.getText());
            label.update();
        }
    };
    Listener showListener = new class Listener {
        public void handleEvent(Event event) {
            Menu menu = cast(Menu) event.widget;
            MenuItem item = menu.getParentItem();
            if (item !is null) {
                label.setText(item.getText());
                label.update();
            }
        }
    };
    Listener hideListener = new class Listener {
        public void handleEvent(Event event) {
            label.setText("");
            label.update();
        }
    };
    FormData labelData = new FormData();
    labelData.left = new FormAttachment(0);
    labelData.right = new FormAttachment(100);
    labelData.bottom = new FormAttachment(100);
    label.setLayoutData(labelData);
    Menu menuBar = new Menu(shell, DWT.BAR);
    shell.setMenuBar(menuBar);
    MenuItem fileItem = new MenuItem(menuBar, DWT.CASCADE);
    fileItem.setText("File");
    fileItem.addListener(DWT.Arm, armListener);
    MenuItem editItem = new MenuItem(menuBar, DWT.CASCADE);
    editItem.setText("Edit");
    editItem.addListener(DWT.Arm, armListener);
    Menu fileMenu = new Menu(shell, DWT.DROP_DOWN);
    fileMenu.addListener(DWT.Hide, hideListener);
    fileMenu.addListener(DWT.Show, showListener);
    fileItem.setMenu(fileMenu);
    String[] fileStrings = [ "New", "Close", "Exit" ];
    for (int i = 0; i < fileStrings.length; i++) {
        MenuItem item = new MenuItem(fileMenu, DWT.PUSH);
        item.setText(fileStrings[i]);
        item.addListener(DWT.Arm, armListener);
    }
    Menu editMenu = new Menu(shell, DWT.DROP_DOWN);
    editMenu.addListener(DWT.Hide, hideListener);
    editMenu.addListener(DWT.Show, showListener);
    String[] editStrings = [ "Cut", "Copy", "Paste" ];
    editItem.setMenu(editMenu);
    for (int i = 0; i < editStrings.length; i++) {
        MenuItem item = new MenuItem(editMenu, DWT.PUSH);
        item.setText(editStrings[i]);
        item.addListener(DWT.Arm, armListener);
    }
    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch()) display.sleep();
    }
    display.dispose();
}
