/**
 * Copyright: Copyright (c) 2008 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Aug 3, 2008
 * License: $(LINK2 http://opensource.org/licenses/bsd-license.php, BSD Style)
 * 
 */
module dwt.internal.cocoa.NSAttributeType;

enum NSAttributeType {
    NSUndefinedAttributeType = 0,
    NSInteger16AttributeType = 100,
    NSInteger32AttributeType = 200,
    NSInteger64AttributeType = 300,
    NSDecimalAttributeType = 400,
    NSDoubleAttributeType = 500,
    NSFloatAttributeType = 600,
    NSStringAttributeType = 700,
    NSBooleanAttributeType = 800,
    NSDateAttributeType = 900,
    NSBinaryDataAttributeType = 1000,
    NSTransformableAttributeType = 1800
}

alias NSAttributeType.NSUndefinedAttributeType NSUndefinedAttributeType;
alias NSAttributeType.NSInteger16AttributeType NSInteger16AttributeType;
alias NSAttributeType.NSInteger32AttributeType NSInteger32AttributeType;
alias NSAttributeType.NSInteger64AttributeType NSInteger64AttributeType;
alias NSAttributeType.NSDecimalAttributeType NSDecimalAttributeType;
alias NSAttributeType.NSDoubleAttributeType NSDoubleAttributeType;
alias NSAttributeType.NSFloatAttributeType NSFloatAttributeType;
alias NSAttributeType.NSStringAttributeType NSStringAttributeType;
alias NSAttributeType.NSBooleanAttributeType NSBooleanAttributeType;
alias NSAttributeType.NSDateAttributeType NSDateAttributeType;
alias NSAttributeType.NSBinaryDataAttributeType NSBinaryDataAttributeType;
alias NSAttributeType.NSTransformableAttributeType NSTransformableAttributeType;