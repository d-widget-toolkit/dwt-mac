/*******************************************************************************
 * Copyright (c) 2000, 2007 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *     Frank Benoit <benoit@tionex.de>
 *******************************************************************************/
module dwt.custom.MovementListener;

import dwt.internal.DWTEventListener;
import dwt.custom.MovementEvent;

/**
 * This listener is invoked when a new offset is required based on the current
 * offset and a movement type.
 *
 * @see dwt.DWT#MOVEMENT_WORD
 * @see dwt.DWT#MOVEMENT_WORD_END
 * @see dwt.DWT#MOVEMENT_WORD_START
 * @see dwt.DWT#MOVEMENT_CHAR
 * @see dwt.DWT#MOVEMENT_CLUSTER
 *
 * @since 3.3
 */
public interface MovementListener : DWTEventListener {
/**
 * This method is called when a new offset is required based on the current
 * offset and a movement type.
 *
 * <p>
 * The following event fields are used:<ul>
 * <li>event.lineOffset line start offset (input)</li>
 * <li>event.lineText line text (input)</li>
 * <li>event.movement the movement type (input)</li>
 * <li>event.offset the current offset (input)</li>
 * <li>event.newOffset the new offset (input, output)</li>
 * </ul>
 *
 * @param event the event
 *
 * @see MovementEvent
 * @see StyledText#addWordMovementListener(MovementListener)
 */
public void getNextOffset (MovementEvent event);
/**
 * This method is called when a new offset is required based on the current
 * offset and a movement type.
 *
 * <p>
 * The following event fields are used:<ul>
 * <li>event.lineOffset line start offset (input)</li>
 * <li>event.lineText line text (input)</li>
 * <li>event.movement the movement type (input)</li>
 * <li>event.offset the current offset (input)</li>
 * <li>event.newOffset the new offset (input, output)</li>
 * </ul>
 *
 * @param event the event
 *
 * @see MovementEvent
 * @see StyledText#addWordMovementListener(MovementListener)
 */
public void getPreviousOffset (MovementEvent event);

}
