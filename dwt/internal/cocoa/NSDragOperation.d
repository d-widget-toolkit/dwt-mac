/**
 * Copyright: Copyright (c) 2008 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Aug 3, 2008
 * License: $(LINK2 http://opensource.org/licenses/bsd-license.php, BSD Style)
 *
 */
module dwt.internal.cocoa.NSDragOperation;

enum NSDragOperation : uint {
    NSDragOperationNone = 0,
    NSDragOperationCopy = 1,
    NSDragOperationLink = 2,
    NSDragOperationGeneric = 4,
    NSDragOperationPrivate = 8,
    NSDragOperationAll_Obsolete = 15,
    NSDragOperationMove = 16,
    NSDragOperationDelete = 32,
    NSDragOperationEvery = uint.max /*UINT_MAX*/
}

alias NSDragOperation.NSDragOperationNone NSDragOperationNone;
alias NSDragOperation.NSDragOperationCopy NSDragOperationCopy;
alias NSDragOperation.NSDragOperationLink NSDragOperationLink;
alias NSDragOperation.NSDragOperationGeneric NSDragOperationGeneric;
alias NSDragOperation.NSDragOperationPrivate NSDragOperationPrivate;
alias NSDragOperation.NSDragOperationAll_Obsolete NSDragOperationAll_Obsolete;
alias NSDragOperation.NSDragOperationMove NSDragOperationMove;
alias NSDragOperation.NSDragOperationDelete NSDragOperationDelete;
alias NSDragOperation.NSDragOperationEvery NSDragOperationEvery;