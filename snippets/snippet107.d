module snippet107;

import dwt.DWT;
import dwt.graphics.Rectangle;
import dwt.layout.FormAttachment;
import dwt.layout.FormData;
import dwt.layout.FormLayout;
import dwt.widgets.Button;
import dwt.widgets.Display;
import dwt.widgets.Event;
import dwt.widgets.Listener;
import dwt.widgets.Sash;
import dwt.widgets.Shell;

void main () {
    auto display = new Display ();
    auto shell = new Shell (display);
    auto button1 = new Button (shell, DWT.PUSH);
    button1.setText ("Button 1");
    auto sash = new Sash (shell, DWT.VERTICAL);
    auto button2 = new Button (shell, DWT.PUSH);
    button2.setText ("Button 2");
    
    auto form = new FormLayout ();
    shell.setLayout (form);
    
    auto button1Data = new FormData ();
    button1Data.left = new FormAttachment (0, 0);
    button1Data.right = new FormAttachment (sash, 0);
    button1Data.top = new FormAttachment (0, 0);
    button1Data.bottom = new FormAttachment (100, 0);
    button1.setLayoutData (button1Data);

    int limit = 20, percent = 50;
    auto sashData = new FormData ();
    sashData.left = new FormAttachment (percent, 0);
    sashData.top = new FormAttachment (0, 0);
    sashData.bottom = new FormAttachment (100, 0);
    sash.setLayoutData (sashData);
    sash.addListener (DWT.Selection, new class Listener {
        public void handleEvent (Event e) {
            auto sashRect = sash.getBounds ();
            auto shellRect = shell.getClientArea ();
            int right = shellRect.width - sashRect.width - limit;
            e.x = Math.max (Math.min (e.x, right), limit);
            if (e.x !is sashRect.x)  {
                sashData.left = new FormAttachment (0, e.x);
                shell.layout ();
            }
        }
    });
    
    auto button2Data = new FormData ();
    button2Data.left = new FormAttachment (sash, 0);
    button2Data.right = new FormAttachment (100, 0);
    button2Data.top = new FormAttachment (0, 0);
    button2Data.bottom = new FormAttachment (100, 0);
    button2.setLayoutData (button2Data);
    
    shell.pack ();
    shell.open ();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}
