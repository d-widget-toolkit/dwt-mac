/*******************************************************************************
 * Copyright (c) 2003, 2007 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *      John Reimer <terminal.node@gmail.com>
 *******************************************************************************/
module dwt.browser.PromptDialog;

import Math = tango.math.Math;
import dwt.dwthelper.utils;

import dwt.*;
import dwt.layout.*;
import dwt.widgets.*;

class PromptDialog : Dialog {

    this(Shell parent, int style) {
        super(parent, style);
    }

    this(Shell parent) {
        this(parent, 0);
    }

    void alertCheck(String title, String text, String check, ref int checkValue) {
        Shell parent = getParent();
        /* final */ Shell shell = new Shell(parent, DWT.DIALOG_TRIM | DWT.APPLICATION_MODAL);
        if (title !is null) shell.setText(title);
        GridLayout gridLayout = new GridLayout();
        shell.setLayout(gridLayout);
        Label label = new Label(shell, DWT.WRAP);
        label.setText(text);
        GridData data = new GridData();
        dwt.widgets.Monitor.Monitor monitor = parent.getMonitor();
        int maxWidth = monitor.getBounds().width * 2 / 3;
        int width = label.computeSize(DWT.DEFAULT, DWT.DEFAULT).x;
        data.widthHint = Math.min(width, maxWidth);
        data.horizontalAlignment = GridData.FILL;
        data.grabExcessHorizontalSpace = true;
        label.setLayoutData (data);

        final Button checkButton = check !is null ? new Button(shell, DWT.CHECK) : null;
        if (checkButton !is null) {
            checkButton.setText(check);
            checkButton.setSelection(checkValue !is 0);
            data = new GridData ();
            data.horizontalAlignment = GridData.BEGINNING;
            checkButton.setLayoutData (data);
        }
        Button okButton = new Button(shell, DWT.PUSH);
        okButton.setText("OK");  // TODO: Need to do this through Resource Bundle
        //okButton.setText(DWT.getMessage("SWT_OK")); //$NON-NLS-1$
        data = new GridData ();
        data.horizontalAlignment = GridData.CENTER;
        okButton.setLayoutData (data);
        okButton.addListener(DWT.Selection, new class() Listener {
            public void handleEvent(Event event) {
                if (checkButton !is null) checkValue = checkButton.getSelection() ? 1 : 0;
                shell.close();
            }
        });

        shell.pack();
        shell.open();
        Display display = parent.getDisplay();
        while (!shell.isDisposed()) {
            if (!display.readAndDispatch()) display.sleep();
        }
    }

    void confirmEx(String title, String text, String check, String button0, String button1, String button2, int defaultIndex, ref int checkValue, ref int result) {
        Shell parent = getParent();
        /* final */ Shell shell = new Shell(parent, DWT.DIALOG_TRIM | DWT.APPLICATION_MODAL);
        shell.setText(title);
        GridLayout gridLayout = new GridLayout();
        shell.setLayout(gridLayout);
        Label label = new Label(shell, DWT.WRAP);
        label.setText(text);
        GridData data = new GridData();
        dwt.widgets.Monitor.Monitor monitor = parent.getMonitor();
        int maxWidth = monitor.getBounds().width * 2 / 3;
        int width = label.computeSize(DWT.DEFAULT, DWT.DEFAULT).x;
        data.widthHint = Math.min(width, maxWidth);
        data.horizontalAlignment = GridData.FILL;
        data.grabExcessHorizontalSpace = true;
        label.setLayoutData (data);

        final Button[] buttons = new Button[4];
        Listener listener = new class() Listener {
            public void handleEvent(Event event) {
                if (buttons[0] !is null) checkValue = buttons[0].getSelection() ? 1 : 0;
                Widget widget = event.widget;
                for (int i = 1; i < buttons.length; i++) {
                    if (widget is buttons[i]) {
                        result = i - 1;
                        break;
                    }
                }
                shell.close();
            }
        };
        if (check !is null) {
            buttons[0] = new Button(shell, DWT.CHECK);
            buttons[0].setText(check);
            buttons[0].setSelection(checkValue !is 0);
            data = new GridData ();
            data.horizontalAlignment = GridData.BEGINNING;
            buttons[0].setLayoutData (data);
        }
        Composite composite = new Composite(shell, DWT.NONE);
        data = new GridData();
        data.horizontalAlignment = GridData.CENTER;
        composite.setLayoutData (data);
        GridLayout layout = new GridLayout();
        layout.makeColumnsEqualWidth = true;
        composite.setLayout(layout);
        int buttonCount = 0;
        if (button0 !is null) {
            buttons[1] = new Button(composite, DWT.PUSH);
            buttons[1].setText(button0);
            buttons[1].addListener(DWT.Selection, listener);
            buttons[1].setLayoutData(new GridData(GridData.FILL_HORIZONTAL));
            buttonCount++;
        }
        if (button1 !is null) {
            buttons[2] = new Button(composite, DWT.PUSH);
            buttons[2].setText(button1);
            buttons[2].addListener(DWT.Selection, listener);
            buttons[2].setLayoutData(new GridData(GridData.FILL_HORIZONTAL));
            buttonCount++;
        }
        if (button2 !is null) {
            buttons[3] = new Button(composite, DWT.PUSH);
            buttons[3].setText(button2);
            buttons[3].addListener(DWT.Selection, listener);
            buttons[3].setLayoutData(new GridData(GridData.FILL_HORIZONTAL));
            buttonCount++;
        }
        layout.numColumns = buttonCount;
        Button defaultButton = buttons [defaultIndex + 1];
        if (defaultButton !is null) shell.setDefaultButton (defaultButton);

        shell.pack();
        shell.open();
        Display display = parent.getDisplay();
        while (!shell.isDisposed()) {
            if (!display.readAndDispatch()) display.sleep();
        }
    }

    void prompt(String title, String text, String check, /* final */ref String value, /* final */ ref int checkValue, /* final */ref int result) {
        Shell parent = getParent();
        /* final */ Shell shell = new Shell(parent, DWT.DIALOG_TRIM | DWT.APPLICATION_MODAL);
        if (title !is null) shell.setText(title);
        GridLayout gridLayout = new GridLayout();
        shell.setLayout(gridLayout);
        Label label = new Label(shell, DWT.WRAP);
        label.setText(text);
        GridData data = new GridData();
        dwt.widgets.Monitor.Monitor monitor = parent.getMonitor();
        int maxWidth = monitor.getBounds().width * 2 / 3;
        int width = label.computeSize(DWT.DEFAULT, DWT.DEFAULT).x;
        data.widthHint = Math.min(width, maxWidth);
        data.horizontalAlignment = GridData.FILL;
        data.grabExcessHorizontalSpace = true;
        label.setLayoutData (data);

        final Text valueText = new Text(shell, DWT.BORDER);
        if (value !is null) valueText.setText(value);
        data = new GridData();
        width = valueText.computeSize(DWT.DEFAULT, DWT.DEFAULT).x;
        if (width > maxWidth) data.widthHint = maxWidth;
        data.horizontalAlignment = GridData.FILL;
        data.grabExcessHorizontalSpace = true;
        valueText.setLayoutData(data);

        final Button[] buttons = new Button[3];
        Listener listener = new class() Listener {
            public void handleEvent(Event event) {
                if (buttons[0] !is null) checkValue = buttons[0].getSelection() ? 1 : 0;
                value = valueText.getText();
                result = event.widget is buttons[1] ? 1 : 0;
                shell.close();
            }
        };
        if (check !is null) {
            buttons[0] = new Button(shell, DWT.CHECK);
            buttons[0].setText(check);
            buttons[0].setSelection(checkValue !is 0);
            data = new GridData ();
            data.horizontalAlignment = GridData.BEGINNING;
            buttons[0].setLayoutData (data);
        }
        Composite composite = new Composite(shell, DWT.NONE);
        data = new GridData();
        data.horizontalAlignment = GridData.CENTER;
        composite.setLayoutData (data);
        composite.setLayout(new GridLayout(2, true));
        buttons[1] = new Button(composite, DWT.PUSH);
        //buttons[1].setText(DWT.getMessage("SWT_OK")); //$NON-NLS-1$
        buttons[1].setText("OK");
        buttons[1].setLayoutData(new GridData(GridData.FILL_HORIZONTAL));
        buttons[1].addListener(DWT.Selection, listener);
        buttons[2] = new Button(composite, DWT.PUSH);
        //buttons[2].setText(DWT.getMessage("SWT_Cancel")); //$NON-NLS-1$
        buttons[2].setText("Cancel");
        buttons[2].setLayoutData(new GridData(GridData.FILL_HORIZONTAL));
        buttons[2].addListener(DWT.Selection, listener);

        shell.pack();
        shell.open();
        Display display = parent.getDisplay();
        while (!shell.isDisposed()) {
            if (!display.readAndDispatch()) display.sleep();
        }
    }

    void promptUsernameAndPassword(String title, String text, String check, ref String user, ref String pass, ref int checkValue, ref int result) {
        Shell parent = getParent();
        /* final */ Shell shell = new Shell(parent, DWT.DIALOG_TRIM | DWT.APPLICATION_MODAL);
        shell.setText(title);
        GridLayout gridLayout = new GridLayout();
        shell.setLayout(gridLayout);
        Label label = new Label(shell, DWT.WRAP);
        label.setText(text);
        GridData data = new GridData();
        dwt.widgets.Monitor.Monitor monitor = parent.getMonitor();
        int maxWidth = monitor.getBounds().width * 2 / 3;
        int width = label.computeSize(DWT.DEFAULT, DWT.DEFAULT).x;
        data.widthHint = Math.min(width, maxWidth);
        data.horizontalAlignment = GridData.FILL;
        data.grabExcessHorizontalSpace = true;
        label.setLayoutData (data);

        Label userLabel = new Label(shell, DWT.NONE);
        //userLabel.setText(DWT.getMessage("SWT_Username")); //$NON-NLS-1$
        userLabel.setText("Username:");
        final Text userText = new Text(shell, DWT.BORDER);
        if (user !is null) userText.setText(user);
        data = new GridData();
        data.horizontalAlignment = GridData.FILL;
        data.grabExcessHorizontalSpace = true;
        userText.setLayoutData(data);

        Label passwordLabel = new Label(shell, DWT.NONE);
        //passwordLabel.setText(DWT.getMessage("SWT_Password")); //$NON-NLS-1$
        passwordLabel.setText("Password:");
        final Text passwordText = new Text(shell, DWT.PASSWORD | DWT.BORDER);
        if (pass !is null) passwordText.setText(pass);
        data = new GridData();
        data.horizontalAlignment = GridData.FILL;
        data.grabExcessHorizontalSpace = true;
        passwordText.setLayoutData(data);

        final Button[] buttons = new Button[3];
        Listener listener = new class() Listener {
            public void handleEvent(Event event) {
                if (buttons[0] !is null) checkValue = buttons[0].getSelection() ? 1 : 0;
                user = userText.getText();
                pass = passwordText.getText();
                result = event.widget is buttons[1] ? 1 : 0;
                shell.close();
            }
        };
        if (check !is null) {
            buttons[0] = new Button(shell, DWT.CHECK);
            buttons[0].setText(check);
            buttons[0].setSelection(checkValue !is 0);
            data = new GridData ();
            data.horizontalAlignment = GridData.BEGINNING;
            buttons[0].setLayoutData (data);
        }
        Composite composite = new Composite(shell, DWT.NONE);
        data = new GridData();
        data.horizontalAlignment = GridData.CENTER;
        composite.setLayoutData (data);
        composite.setLayout(new GridLayout(2, true));
        buttons[1] = new Button(composite, DWT.PUSH);
        //buttons[1].setText(DWT.getMessage("SWT_OK")); //$NON-NLS-1$
        buttons[1].setText("OK");
        buttons[1].setLayoutData(new GridData(GridData.FILL_HORIZONTAL));
        buttons[1].addListener(DWT.Selection, listener);
        buttons[2] = new Button(composite, DWT.PUSH);
        //buttons[2].setText(DWT.getMessage("SWT_Cancel")); //$NON-NLS-1$
        buttons[2].setText("Cancel");
        buttons[2].setLayoutData(new GridData(GridData.FILL_HORIZONTAL));
        buttons[2].addListener(DWT.Selection, listener);

        shell.setDefaultButton(buttons[1]);
        shell.pack();
        shell.open();
        Display display = parent.getDisplay();
        while (!shell.isDisposed()) {
            if (!display.readAndDispatch()) display.sleep();
        }
    }
}
