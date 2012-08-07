/**
 * Copyright: Copyright (c) 2008 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Jul 28, 2008
 * License: $(LINK2 http://opensource.org/licenses/bsd-license.php, BSD Style)
 *
 */
module dwt.internal.cocoa.NSComparisonResult;

enum NSComparisonResult
{
    NSOrderedAscending = -1,
    NSOrderedSame,
    NSOrderedDescending
}

alias NSComparisonResult.NSOrderedAscending NSOrderedAscending;
alias NSComparisonResult.NSOrderedSame NSOrderedSame;
alias NSComparisonResult.NSOrderedDescending NSOrderedDescending;
