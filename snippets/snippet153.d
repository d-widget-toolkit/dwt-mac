module snippet153;

import dwt.DWT;
import dwt.events.MouseEvent;
import dwt.events.MouseMoveListener;
import dwt.graphics.Point;
import dwt.widgets.Display;
import dwt.widgets.Shell;
import dwt.widgets.ToolBar;
import dwt.widgets.ToolItem;
import dwt.widgets.Label;

import dwt.dwthelper.utils;

void main() {
    String statusText = "";
    
    Display display = new Display();
    Shell shell = new Shell(display);
    shell.setBounds(10, 10, 200, 200);
    ToolBar bar = new ToolBar(shell, DWT.BORDER);
    bar.setBounds(10, 10, 170, 50);
    Label statusLine = new Label(shell, DWT.BORDER);
    statusLine.setBounds(10, 90, 170, 30);
    (new ToolItem(bar, DWT.NONE)).setText("item 1");
    (new ToolItem(bar, DWT.NONE)).setText("item 2");
    (new ToolItem(bar, DWT.NONE)).setText("item 3");
    bar.addMouseMoveListener(new class MouseMoveListener {
        void mouseMove(MouseEvent e) {
            ToolItem item = bar.getItem(new Point(e.x, e.y));
            String name = "";
            if (item !is null) {
                name = item.getText();
            }
            if (statusText != name) {
                statusLine.setText(name);
                statusText = name;
            }
        }
    });
    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch()) display.sleep();
    }
    display.dispose();
}

