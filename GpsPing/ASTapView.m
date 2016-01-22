//
//  ASTapView.m
//  GpsPing
//
//  Created by Pavel Ivanov on 22/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASTapView.h"

@implementation ASTapView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:self]) {
        return NO;
    }
    return YES;
}

@end
