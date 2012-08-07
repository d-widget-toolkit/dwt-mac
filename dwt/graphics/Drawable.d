/*******************************************************************************
 * Copyright (c) 2000, 2009 IBM Corporation and others.
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
module dwt.graphics.Drawable;

import dwt.graphics.GCData;

import dwt.dwthelper.utils;
import objc = dwt.internal.objc.runtime;

/**
 * Implementers of <code>Drawable</code> can have a graphics context cast(GC)
 * created for them, and then they can be drawn on by sending messages to
 * their associated GC. DWT images, and device objects such as the Display
 * device and the Printer device, are drawables.
 * <p>
 * <b>IMPORTANT:</b> This interface is <em>not</em> part of the DWT
 * public API. It is marked public only so that it can be shared
 * within the packages provided by DWT. It should never be
 * referenced from application code.
 * </p>
 * 
 * @see Device
 * @see Image
 * @see GC
 */
public interface Drawable {

/**  
 * Invokes platform specific functionality to allocate a new GC handle.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>Drawable</code>. It is marked public only so that it
 * can be shared within the packages provided by DWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param data the platform specific GC data 
 * @return the platform specific GC handle
 */
 
public objc.id internal_new_GC (GCData data);

/**  
 * Invokes platform specific functionality to dispose a GC handle.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>Drawable</code>. It is marked public only so that it
 * can be shared within the packages provided by DWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param handle the platform specific GC handle
 * @param data the platform specific GC data 
 */
public void internal_dispose_GC (objc.id handle, GCData data);

}
