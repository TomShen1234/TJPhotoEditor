//
//  ArrowView.m
//  ArrowTest
//
//  Created by yifeng shen on 3/1/15.
//  Copyright (c) 2015 Tom and Jerry. All rights reserved.
//

#import "ArrowView.h"

@implementation ArrowView

- (void)drawRect:(CGRect)rect
{

    UIBezierPath *path = [UIBezierPath bezierPath];

    [path moveToPoint:CGPointZero];
    [path addLineToPoint:CGPointMake(0.6 * self.bounds.size.width, 0)];
    [path addLineToPoint:CGPointMake(0.4 * self.bounds.size.width, 0.2 * self.bounds.size.height)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width, 0.8 * self.bounds.size.height)];
    [path addLineToPoint:CGPointMake(0.8 * self.bounds.size.width, self.bounds.size.height)];
    [path addLineToPoint:CGPointMake(0.2 * self.bounds.size.width, 0.4 * self.bounds.size.height)];
    [path addLineToPoint:CGPointMake(0, 0.6 * self.bounds.size.height)];
    [path closePath];


    UIColor *fill = [UIColor redColor];
    [fill setFill];
    [path stroke];
    [path fill];

}

@end
