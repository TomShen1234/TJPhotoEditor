//
//  CLBubbleTool.m
//  PhotoEditor
//
//  Created by Tom & Jerry on 2/23/15.
//  Copyright (c) 2015 Tom & Jerry. All rights reserved.
//

#import "CLBubbleTool.h"
#import "ShapeView.h"
#import <QuartzCore/QuartzCore.h>

@interface CLBubbleTool ()
@property (nonatomic, strong) ShapeView *myShapeView;
@end

@implementation CLBubbleTool
{
    UIPanGestureRecognizer *panRecognizer;
    UIPinchGestureRecognizer *pinchRecognizer;
    UIButton *button;
}

@synthesize myShapeView;

+ (NSArray*)subtools
{
    return nil;
}

+ (NSString*)defaultTitle
{
    return [CLImageEditorTheme localizedString:@"CLBubbleTool_DefaultTitle" withDefault:@"Text Bubble"];
}

+ (BOOL)isAvailable
{
    return YES;
}

- (CGFloat)defaultDockNumber
{
    return 1;
}

- (void)setup
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    // CGFloat screenScale = [[UIScreen scale] doubleValue];

    CGFloat x = screenWidth/2-160/2;
    CGFloat y = self.editor.imageView.height/2-130/2;

    [self.editor fixZoomScaleWithAnimated:YES];
    
    self.myShapeView = [[ShapeView alloc] initWithFrame:CGRectMake(x, y, 160, 130)];
    
    self.myShapeView.backgroundColor = [UIColor clearColor];

    panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panRecognizer.delegate = self;
    panRecognizer.maximumNumberOfTouches = 1;
    
    pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinchRecognizer.delegate = self;

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapRecognizer.numberOfTouchesRequired = 1;
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.delegate = nil;

    [self.myShapeView addGestureRecognizer:panRecognizer];
    [self.myShapeView addGestureRecognizer:pinchRecognizer];
    [self.myShapeView addGestureRecognizer:tapRecognizer];

    self.editor.imageView.userInteractionEnabled = YES;

    [self.editor.imageView addSubview:self.myShapeView];

    button = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 150, screenHeight - 50, 150, 30)];

    button.opaque = NO;
    button.backgroundColor=[UIColor clearColor];
    [button addTarget:self action:@selector(reset:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:[CLImageEditorTheme localizedString:@"CLBubbleTool_Reset" withDefault:@"Reset"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.editor.view addSubview:button];


}

- (void)reset:(UIButton *)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        self.myShapeView.center = CGPointMake(self.editor.imageView.bounds.size.width/2, self.editor.imageView.bounds.size.height/2);
    }];
}
- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.editor.imageView];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.editor.imageView];
    
}

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer
{
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer
{
    self.myShapeView.textView.hidden = NO;
    [self.myShapeView.textView becomeFirstResponder];
}

- (void)cleanup
{
    self.myShapeView.userInteractionEnabled = NO;
    self.editor.imageView.userInteractionEnabled = NO;
    [self.myShapeView removeFromSuperview];
    [button removeFromSuperview];
    [self.editor resetZoomScaleWithAnimated:YES];
    button = nil;
}

- (UIImage *)convertViewToImage:(UIView *)view
{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - Transform scale, rotation, translation

- (CGFloat)xscaleOnView:(UIView *)view
{
    CGAffineTransform t = view.transform;
    return sqrt(t.a * t.a + t.c * t.c);
}

- (CGFloat)yscaleOnView:(UIView *)view
{
    CGAffineTransform t = view.transform;
    return sqrt(t.b *t.b + t.d * t.d);
}

- (CGFloat)rotationOnView:(UIView *)view
{
    CGAffineTransform t = view.transform;
    return atan2f(t.b, t.a);
}

- (CGFloat)txOnView:(UIView *)view
{
    CGAffineTransform t = view.transform;
    return t.tx;
}

- (CGFloat)tyOnView:(UIView *)view
{
    CGAffineTransform t = view.transform;
    return t.ty;
}

#pragma mark -

- (UIImage*)buildImage:(UIImage*)image
{
    UIImage *shapeImage = [self convertViewToImage:self.myShapeView];
    CGFloat xtransformScale = [self xscaleOnView:self.myShapeView];
    CGFloat ytransformScale = [self yscaleOnView:self.myShapeView];
    CGFloat x = self.myShapeView.frame.origin.x;
    CGFloat y = self.myShapeView.frame.origin.y;
    CGFloat scaleX = self.editor.imageView.image.size.width / self.editor.imageView.bounds.size.width;
    CGFloat scaleY = self.editor.imageView.image.size.height / self.editor.imageView.bounds.size.height;
    UIImage *resultImage = [self addImage:self.editor.imageView.image toImage:shapeImage withX:x andY:y withScaleX:scaleX andScaleY:scaleY withTransformx:xtransformScale andTransformy:ytransformScale];

    return resultImage;
}

- (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2 withX:(CGFloat)x andY:(CGFloat)y withScaleX:(CGFloat)scaleX andScaleY:(CGFloat)scaleY withTransformx:(CGFloat)transformx andTransformy:(CGFloat)transformy
{
    UIGraphicsBeginImageContext(image1.size);

    // Draw image 1
    [image1 drawInRect:CGRectMake(0, 0, image1.size.width, image1.size.height)];

    // Draw image 2
    [image2 drawInRect:CGRectMake(x * scaleX, y * scaleY, image2.size.width * scaleX * transformx, image2.size.height * scaleY *transformy)];

    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return resultImage;
}

- (void)executeWithCompletionBlock:(void (^)(UIImage *, NSError *, NSDictionary *))completionBlock
{
    // CompletionBlock goes here

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self buildImage:self.editor.imageView.image];
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(image, nil, nil);
        });
    });

    // completionBlock(self.editor.imageView.image, nil, nil);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
@end
