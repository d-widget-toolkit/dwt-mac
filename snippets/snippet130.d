module snippet130;

import dwt.DWT;
import dwt.events.SelectionAdapter;
import dwt.events.SelectionEvent;
import dwt.layout.GridLayout;
import dwt.layout.GridData;
import dwt.widgets.Shell;
import dwt.widgets.Button;
import dwt.widgets.Display;
import dwt.widgets.Shell;
import dwt.widgets.Text;


import dwt.custom.BusyIndicator;

import dwt.dwthelper.Runnable;
import dwt.dwthelper.utils;

import tango.text.convert.Format;
import tango.core.Thread;

void main() {
    Display display = new Display();
    Shell shell = new Shell(display);
    shell.setLayout(new GridLayout());
    Text text = new Text(shell, DWT.MULTI | DWT.BORDER | DWT.V_SCROLL);
    text.setLayoutData(new GridData(GridData.FILL_BOTH));
    int[] nextId = new int[1];
    Button b = new Button(shell, DWT.PUSH);
    b.setText("invoke long running job");
    b.addSelectionListener(new class SelectionAdapter {
        public void widgetSelected(SelectionEvent e) {
            Runnable longJob = new class Runnable {
                bool done = false;
                int id;
                public void run() {
					Thread thread = new Thread({
						id = nextId[0]++;
						display.syncExec(new class Runnable {
							public void run() {
								if (text.isDisposed()) return;
								text.append(Format("\nStart long running task {}", id));
							}
						});
						for (int i = 0; i < 100000; i++) {
							if (display.isDisposed()) return;
							println("do task that takes a long time in a separate thread ", id);
						}
						if (display.isDisposed()) return;
						display.syncExec(new class Runnable {
							public void run() {
								if (text.isDisposed()) return;
								text.append(Format("\nCompleted long running task {}", id));
							}
						});
						done = true;
						display.wake();
					});
					thread.start();
					while (!done && !shell.isDisposed()) {
						if (!display.readAndDispatch())
							display.sleep();
					}
                }
            };
            BusyIndicator.showWhile(display, longJob);
        }
    });
    shell.setSize(250, 150);
    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch())
            display.sleep();
    }
    display.dispose();
}

/*void printStart(Text text, int id ) {
    if (text.isDisposed()) return;
    getDwtLogger().info( __FILE__, __LINE__, "Start long running task {}", id );
    text.append(Format("\nStart long running task {}", id));
}

void printEnd(Text text, int id ) {
    if (text.isDisposed()) return;
    getDwtLogger().info( __FILE__, __LINE__, "Completed long running task {}", id );
    text.append(Format("\nCompleted long running task {}", id));
}
*/