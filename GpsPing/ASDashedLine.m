//
//  ASDashedLine.m
//  GpsPing
//
//  Created by Pavel Ivanov on 31/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASDashedLine.h"

@implementation ASDashedLine
-(void)drawRect:(CGRect)rect
{
    //    [super drawRect:rect];
    //    NSLog(@"%s", __PRETTY_FUNCTION__);
    CGFloat thickness = 4.0;
    
    CGContextRef cx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(cx, thickness);
    CGContextSetStrokeColorWithColor(cx, [UIColor blackColor].CGColor);
    
    CGFloat ra[] = {4,2};
    CGContextSetLineDash(cx, 0.0, ra, 2); // nb "2" == ra count
    
    
    CGContextMoveToPoint(cx, self.center.x, self.center.y);
    CGContextAddLineToPoint(cx, self.userLocationPoint.x, self.userLocationPoint.y);
    CGContextStrokePath(cx);
}

@end
