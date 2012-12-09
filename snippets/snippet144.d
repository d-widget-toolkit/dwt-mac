module snippet144;

import dwt.DWT;
import dwt.widgets.Button;
import dwt.widgets.Display;
import dwt.widgets.Event;
import dwt.widgets.Label;
import dwt.widgets.Listener;
import dwt.widgets.Shell;
import dwt.widgets.Table;
import dwt.widgets.TableItem;
import dwt.layout.RowLayout;
import dwt.layout.RowData;

import dwt.dwthelper.utils;

import tango.io.Stdout;
import tango.time.StopWatch;
import tango.util.Convert;

void writeln(in char[] line) {
    Stdout(line)("\n").flush();
}

const int COUNT = 1000000;

void main() {
    auto display = new Display ();
    auto shell = new Shell (display);
    shell.setLayout (new RowLayout (DWT.VERTICAL));
    auto table = new Table (shell, DWT.VIRTUAL | DWT.BORDER);
    table.addListener (DWT.SetData, new class Listener {
        public void handleEvent (Event event) {
            auto item = cast(TableItem) event.item;
            auto index = table.indexOf (item);
            item.setText ("Item " ~ to!(String)(index));
            writeln(item.getText ());
        }
    });
    table.setLayoutData (new RowData (200, 200));
    auto button = new Button (shell, DWT.PUSH);
    button.setText ("Add Items");
    auto label = new Label(shell, DWT.NONE);
    button.addListener (DWT.Selection, new class Listener {
        public void handleEvent (Event event) {
            StopWatch elapsed; //Tango or Phobos StopWatch
            elapsed.start();
            table.setItemCount (COUNT);
            version(Tango){
                auto t = elapsed.stop() * 1_000;
            } else { // Phobos
                elapsed.stop();
                auto t = elapsed.peek.msecs;
            }
            label.setText ("Items: " ~ to!(String)(COUNT) ~
                           ", Time: " ~ to!(String)(t) ~ " (msec)");
            shell.layout ();
        }
    });
    shell.pack ();
    shell.open ();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}