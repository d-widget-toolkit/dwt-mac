/*******************************************************************************
 * Copyright (c) 2000, 2005 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     
 * Port to the D programming language:
 *     Jacob Carlborg <doob@me.com>
 *******************************************************************************/
module dwt.internal.DWTEventListener;

import dwt.dwthelper.utils : EventListener;

/**
 * This interface is the cross-platform version of the
 * java.util.EventListener interface.
 * <p>
 * It is part of our effort to provide support for both J2SE
 * and J2ME platforms. Under this scheme, classes need to 
 * implement DWTEventListener instead of java.util.EventListener.
 * </p>
 * <p>
 * Note: java.util.EventListener is not part of CDC and CLDC.
 * </p>
 */
public interface DWTEventListener : EventListener
{
}