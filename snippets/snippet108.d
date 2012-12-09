module snippet108;

import tango.io.Stdout;

import dwt.DWT;
import dwt.widgets.Button;
import dwt.widgets.Display;
import dwt.widgets.Label;
import dwt.widgets.Shell;
import dwt.widgets.Text;
import dwt.events.SelectionAdapter;
import dwt.events.SelectionEvent;
import dwt.layout.RowLayout;
import dwt.layout.RowData;

void writeln(in char[] line) {
    Stdout(line)("\n").flush();
}

void main () {
    Display display = new Display ();
    Shell shell = new Shell (display);
    Label label = new Label (shell, DWT.NONE);
    label.setText ("Enter your name:");
    Text text = new Text (shell, DWT.BORDER);
    text.setLayoutData (new RowData (100, DWT.DEFAULT));
    Button ok = new Button (shell, DWT.PUSH);
    ok.setText ("OK");
    ok.addSelectionListener(new class SelectionAdapter {
        public void widgetSelected(SelectionEvent e) {
            writeln("OK");
        }
    });
    Button cancel = new Button (shell, DWT.PUSH);
    cancel.setText ("Cancel");
    cancel.addSelectionListener(new class SelectionAdapter {
        public void widgetSelected(SelectionEvent e) {
            writeln("Cancel");
        }
    });
    shell.setDefaultButton (cancel);
    shell.setLayout (new RowLayout ());
    shell.pack ();
    shell.open ();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}