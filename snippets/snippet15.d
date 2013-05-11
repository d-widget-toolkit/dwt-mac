module snippet15;

import dwt.DWT;
import dwt.layout.FillLayout;
import dwt.widgets.Display;
import dwt.widgets.Shell;
import dwt.widgets.Tree;
import dwt.widgets.TreeItem;

import dwt.dwthelper.utils;

version(Tango){
    import tango.util.Convert;
} else { // Phobos
    import std.conv;
}

void main () {
    auto display = new Display ();
    auto shell = new Shell (display);
    shell.setLayout(new FillLayout());
    auto tree = new Tree (shell, DWT.BORDER);
    for (int i=0; i<4; i++) {
        auto iItem = new TreeItem (tree, 0);
        iItem.setText ("TreeItem (0) -" ~ to!(String)(i));
        for (int j=0; j<4; j++) {
            TreeItem jItem = new TreeItem (iItem, 0);
            jItem.setText ("TreeItem (1) -" ~ to!(String)(j));
            for (int k=0; k<4; k++) {
                TreeItem kItem = new TreeItem (jItem, 0);
                kItem.setText ("TreeItem (2) -" ~ to!(String)(k));
                for (int l=0; l<4; l++) {
                    TreeItem lItem = new TreeItem (kItem, 0);
                    lItem.setText ("TreeItem (3) -" ~ to!(String)(l));
                }
            }
        }
    }
    shell.setSize (200, 200);
    shell.open ();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}
