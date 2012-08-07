/*******************************************************************************
 * Copyright (c) 2003, 2005 IBM Corporation and others.
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
module dwt.browser.TitleListener;

import dwt.browser.TitleEvent;
//import dwt.dwthelper.utils;

import dwt.internal.DWTEventListener;

/**
 * This listener interface may be implemented in order to receive
 * a {@link TitleEvent} notification when the title of the document
 * displayed in a {@link Browser} is known or has been changed.
 * 
 * @see Browser#addTitleListener(TitleListener)
 * @see Browser#removeTitleListener(TitleListener)
 * 
 * @since 3.0
 */
public interface TitleListener : DWTEventListener {

/**
 * This method is called when the title of the current document
 * is available or has changed.
 * <p>
 *
 * <p>The following fields in the <code>TitleEvent</code> apply:
 * <ul>
 * <li>(in) title the title of the current document
 * <li>(in) widget the <code>Browser</code> whose current document's
 * title is known or modified
 * </ul>
 * 
 * @param event the <code>TitleEvent</code> that contains the title
 * of the document currently displayed in a <code>Browser</code>
 * 
 * @since 3.0
 */
public void changed(TitleEvent event);
}
