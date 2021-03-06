//
//  CLArrowTool.m
//  PhotoEditor
//
//  Created by yifeng shen on 3/7/15.
//  Copyright (c) 2015 Tom & Jerry. All rights reserved.
//

#import "CLArrowTool.h"
#import "ArrowView.h"

@interface CLArrowTool ()
@property (nonatomic, strong) ArrowView *myArrowView;
@end

@implementation CLArrowTool
{
    UIPanGestureRecognizer *panRecognizer;
    UIPinchGestureRecognizer *pinchRecognizer;
    UIRotationGestureRecognizer *rotateRecognizer;
    UIButton *button;
}

+ (NSArray*)subtools
{
    return nil;
}

+ (NSString*)defaultTitle
{
    return [CLImageEditorTheme localizedString:@"CLArrowTool_DefaultTitle" withDefault:@"Add Arrow"];
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

    self.myArrowView = [[ArrowView alloc] initWithFrame:CGRectMake(x, y, 160, 130)];

    self.myArrowView.backgroundColor = [UIColor clearColor];

    panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panRecognizer.delegate = self;
    panRecognizer.maximumNumberOfTouches = 1;

    pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinchRecognizer.delegate = self;

    rotateRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotate:)];
    rotateRecognizer.delegate = self;

    self.editor.imageView.userInteractionEnabled = YES;

    [self.myArrowView addGestureRecognizer:panRecognizer];
    [self.myArrowView addGestureRecognizer:pinchRecognizer];
    [self.myArrowView addGestureRecognizer:rotateRecognizer];

    [self.editor.imageView addSubview:self.myArrowView];

    button = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 150, screenHeight - 50, 150, 30)];

    button.opaque = NO;
    button.backgroundColor=[UIColor clearColor];
    [button addTarget:self action:@selector(reset:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:[CLImageEditorTheme localizedString:@"CLArrowTool_Reset" withDefault:@"Reset"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.editor.view addSubview:button];

}

- (void)reset:(UIButton *)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        self.myArrowView.center = CGPointMake(self.editor.imageView.bounds.size.width/2, self.editor.imageView.bounds.size.height/2);
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

- (void)handleRotate:(UIRotationGestureRecognizer *)recognizer {
    recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
    recognizer.rotation = 0;
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
/*
- (UIImage *)imageScaledWithX:(CGFloat)x y:(CGFloat)y withImage:(UIImage *)image
{

}
*/
- (UIImage *)imageRotatedByRadius:(CGFloat)radius withImage:(UIImage *)image
{
    // Calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(radius);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;

    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();

    // Move the origin to the middle of the image so we will rotate and scale around the center
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);

    // Move the origin to the middle of the image so we will rotate and scale around the center
    CGContextRotateCTM(bitmap, radius);

    // Draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-image.size.width/2, -image.size.height/2, image.size.width, image.size.height), [image CGImage]);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

    // End context
    UIGraphicsEndImageContext();

    // Return the new image
    return newImage;
}

#pragma mark -

- (UIImage*)buildImage:(UIImage*)image
{
    UIImage *shapeImage = [self convertViewToImage:self.myArrowView];
    CGFloat xtransformScale = [self xscaleOnView:self.myArrowView];
    CGFloat ytransformScale = [self yscaleOnView:self.myArrowView];
    CGFloat transformRadius = [self rotationOnView:self.myArrowView];
    CGFloat x = self.myArrowView.frame.origin.x;
    CGFloat y = self.myArrowView.frame.origin.y;
    CGFloat scaleX = self.editor.imageView.image.size.width / self.editor.imageView.bounds.size.width;
    CGFloat scaleY = self.editor.imageView.image.size.height / self.editor.imageView.bounds.size.height;
    UIImage *resultImage = [self addImage:self.editor.imageView.image toImage:shapeImage withX:x andY:y withScaleX:scaleX andScaleY:scaleY withTransformx:xtransformScale andTransformy:ytransformScale rotationRadius:transformRadius];

    return resultImage;
}

- (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2 withX:(CGFloat)x andY:(CGFloat)y withScaleX:(CGFloat)scaleX andScaleY:(CGFloat)scaleY withTransformx:(CGFloat)transformx andTransformy:(CGFloat)transformy rotationRadius:(CGFloat)radius
{
    UIGraphicsBeginImageContext(image1.size);

    // Draw image 1
    [image1 drawInRect:CGRectMake(0, 0, image1.size.width, image1.size.height)];

    // Draw image 2
    UIImage *image3 = [self imageRotatedByRadius:radius withImage:image2];
    [image3 drawInRect:CGRectMake(x * scaleX, y * scaleY, image3.size.width * scaleX * transformx, image3.size.height * scaleY *transformy)];

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

- (void)cleanup
{
    [self.myArrowView removeFromSuperview];
    self.myArrowView = nil;
    self.myArrowView.gestureRecognizers = nil;
    [button removeFromSuperview];
    button = nil;
    [self.editor resetZoomScaleWithAnimated:YES];
}

@end
