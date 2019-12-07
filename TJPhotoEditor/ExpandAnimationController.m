//
//  SmallToBigAnimationController.m
//  PoemGame
//
//  Created by Ming Shen on 6/21/15.
//  Copyright (c) 2015 Tom & Jerry. All rights reserved.
//

#import "ExpandAnimationController.h"

@implementation ExpandAnimationController

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.75;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toViewController = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = (UIView *)[transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *containerView = (UIView *)[transitionContext containerView];
    
    toView.frame = [transitionContext finalFrameForViewController:toViewController];
    [containerView addSubview:toView];
    toView.transform = CGAffineTransformMakeScale(0.0, 0.0);
    toView.alpha = 0;
    
    [UIView animateKeyframesWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.75 animations:^{
            toView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            toView.alpha = 1;
        }];
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
    }];
}

@end
