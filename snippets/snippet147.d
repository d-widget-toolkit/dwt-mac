module snippet147;

import dwt.DWT;
import dwt.events.SelectionAdapter;
import dwt.events.SelectionEvent;
import dwt.events.TraverseListener;
import dwt.events.TraverseEvent;
import dwt.layout.GridData;
import dwt.layout.GridLayout;
import dwt.widgets.Button;
import dwt.widgets.Combo;
import dwt.widgets.Display;
import dwt.widgets.Shell;

import dwt.dwthelper.utils;

version(Tango){
    import tango.io.Stdout;
    void writeln(in char[] line) {
        Stdout(line)("\n").flush();
    }
} else { // Phobos
    import std.stdio;
}

void main() {
    Display display = new Display();
    Shell shell = new Shell(display);
    shell.setLayout(new GridLayout());
    Combo combo = new Combo(shell, DWT.NONE);
    combo.setLayoutData(new GridData(GridData.FILL_HORIZONTAL));
    combo.setText("Here is some text");
    combo.addSelectionListener(new class SelectionAdapter{
        override
        public void widgetDefaultSelected(SelectionEvent e) {
            writeln("Combo default selected (overrides default button)");
        }
    });
    combo.addTraverseListener(new class TraverseListener{
        public void keyTraversed(TraverseEvent e) {
            if (e.detail == DWT.TRAVERSE_RETURN) {
                e.doit = false;
                e.detail = DWT.TRAVERSE_NONE;
            }
        }
    });
    Button button = new Button(shell, DWT.PUSH);
    button.setText("Ok");
    button.addSelectionListener(new class SelectionAdapter{
        override
        public void widgetSelected(SelectionEvent e) {
            writeln("Button selected");
        }
    });
    shell.setDefaultButton(button);
    shell.pack();
    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch())
            display.sleep();
    }
    display.dispose();
}

