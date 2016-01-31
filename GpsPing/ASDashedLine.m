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
    CGFloat thickness = 2.0;
    
    CGContextRef cx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(cx, thickness);
    CGContextSetStrokeColorWithColor(cx, [UIColor colorWithRed:0.9684 green:0.0 blue:0.0447 alpha:0.5].CGColor);
    
    CGFloat ra[] = {10,4};
    CGContextSetLineDash(cx, 0.0, ra, 2); // nb "2" == ra count
    
    
    CGContextMoveToPoint(cx, self.center.x, self.center.y);
    CGContextAddLineToPoint(cx, self.userLocationPoint.x, self.userLocationPoint.y);
    CGContextStrokePath(cx);
}

@end
