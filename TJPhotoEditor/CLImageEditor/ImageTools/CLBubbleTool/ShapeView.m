//
//  ShapeView.m
//  ShapeTest
//
//  Created by yifeng shen on 2/17/15.
//  Copyright (c) 2015 Tom and Jerry. All rights reserved.
//

#import "ShapeView.h"

@implementation ShapeView
{
    BOOL firstTime;
}

@synthesize boxSize;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        boxSize = CGSizeMake(160, 130);
        firstTime = YES;
    }
    return self;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    // Get the drawing context
    CGContextRef context = UIGraphicsGetCurrentContext();

    // Save the context
    CGContextSaveGState(context);


    // Make fill
    UIColor *fillColor = [UIColor whiteColor];
    [fillColor setFill];

    // Circle 1
    CGRect aRect = CGRectMake(0.0f, boxSize.height*87.5/100.0f, boxSize.width*12.5/100.0f, boxSize.height*12.5/100.0f);

    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:aRect];

    [path stroke];
    [path fill];

    // Circle 2
    aRect = CGRectMake(boxSize.width*8/100.0f, boxSize.height*68/100.0f, boxSize.width*3/16, boxSize.height*3/16);

    path = [UIBezierPath bezierPathWithOvalInRect:aRect];

    [path stroke];
    [path fill];

    // Circle 3
    aRect = CGRectMake(boxSize.width*20/100.0f, boxSize.height*42/100.0f, boxSize.width*25/100.0f, boxSize.height*25/100.0f);

    path = [UIBezierPath bezierPathWithOvalInRect:aRect];

    [path stroke];
    [path fill];

    // Rectangle
    aRect = CGRectMake(boxSize.width*40/100.0f, 0.0f, boxSize.width*60/100.0f, boxSize.height*40/100.0f);

    // path = [UIBezierPath bezierPathWithRect:aRect];
    path = [UIBezierPath bezierPathWithRoundedRect:aRect cornerRadius:10.0f];

    [path fill];

    [path stroke];

    UIFont *textViewFont = [UIFont systemFontOfSize:aRect.size.height/4];

    self.textView = [[UITextView alloc] initWithFrame:aRect];
    self.textView.hidden = YES;
    self.textView.delegate = self;
    self.textView.font = textViewFont;
    self.textView.backgroundColor = [UIColor clearColor];

    [self.textView setReturnKeyType:UIReturnKeyDone];

    [self addSubview:self.textView];

    // Restore context
    CGContextRestoreGState(context);
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self.textView resignFirstResponder];
        return NO;
    }
    return YES;
}

@end
