module snippet140;

import dwt.DWT;
import dwt.graphics.Point;
import dwt.graphics.Rectangle;
import dwt.widgets.Display;
import dwt.widgets.Shell;
import dwt.widgets.Menu;
import dwt.widgets.MenuItem;
import dwt.widgets.ToolBar;
import dwt.widgets.ToolItem;
import dwt.widgets.CoolBar;
import dwt.widgets.CoolItem;
import dwt.events.SelectionEvent;
import dwt.events.SelectionAdapter;
import dwt.layout.GridLayout;
import dwt.layout.GridData;

import dwt.dwthelper.utils;
import tango.util.Convert;


void main () {
    Menu chevronMenu = null;
    
    auto display = new Display ();
    auto shell = new Shell (display);
    shell.setLayout(new GridLayout());
    auto coolBar = new CoolBar(shell, DWT.FLAT | DWT.BORDER);
    coolBar.setLayoutData(new GridData(GridData.FILL_BOTH));
    ToolBar toolBar = new ToolBar(coolBar, DWT.FLAT | DWT.WRAP);
    int minWidth = 0;
    for (int j = 0; j < 5; j++) {
        int width = 0;
        ToolItem item = new ToolItem(toolBar, DWT.PUSH);
        item.setText("B" ~ to!(String)(j));
        width = item.getWidth();
        /* find the width of the widest tool */
        if (width > minWidth) minWidth = width;
    }
    CoolItem coolItem = new CoolItem(coolBar, DWT.DROP_DOWN);
    coolItem.setControl(toolBar);
    Point size = toolBar.computeSize(DWT.DEFAULT, DWT.DEFAULT);
    Point coolSize = coolItem.computeSize (size.x, size.y);
    coolItem.setMinimumSize(minWidth, coolSize.y);
    coolItem.setPreferredSize(coolSize);
    coolItem.setSize(coolSize);
    coolItem.addSelectionListener(new class SelectionAdapter {
        public void widgetSelected(SelectionEvent event) {
            if (event.detail == DWT.ARROW) {
                CoolItem item = cast(CoolItem) event.widget;
                Rectangle itemBounds = item.getBounds ();
                Point pt = coolBar.toDisplay(new Point(itemBounds.x, itemBounds.y));
                itemBounds.x = pt.x;
                itemBounds.y = pt.y;
                ToolBar bar = cast(ToolBar) item.getControl ();
                ToolItem[] tools = bar.getItems ();

                int i = 0;
                while (i < tools.length) {
                    Rectangle toolBounds = tools[i].getBounds ();
                    pt = bar.toDisplay(new Point(toolBounds.x, toolBounds.y));
                    toolBounds.x = pt.x;
                    toolBounds.y = pt.y;

                    /* Figure out the visible portion of the tool by looking at the
                     * intersection of the tool bounds with the cool item bounds.
                     */
                    Rectangle intersection = itemBounds.intersection (toolBounds);

                    /* If the tool is not completely within the cool item bounds, then it
                     * is partially hidden, and all remaining tools are completely hidden.
                     */
                    if (intersection != toolBounds) break;
                    i++;
                }

                /* Create a menu with items for each of the completely hidden buttons. */
                if (chevronMenu !is null) chevronMenu.dispose();
                chevronMenu = new Menu (coolBar);
                for (int j = i; j < tools.length; j++) {
                    MenuItem menuItem = new MenuItem (chevronMenu, DWT.PUSH);
                    menuItem.setText (tools[j].getText());
                }

                /* Drop down the menu below the chevron, with the left edges aligned. */
                pt = coolBar.toDisplay(new Point(event.x, event.y));
                chevronMenu.setLocation (pt.x, pt.y);
                chevronMenu.setVisible (true);
            }
        }
    });

    shell.pack();
    shell.open ();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}