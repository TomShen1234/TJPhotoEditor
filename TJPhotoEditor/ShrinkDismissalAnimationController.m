//
//  ShrinkDismissalAnimationController.m
//  PoemGame
//
//  Created by Tom Shen on 2/29/16.
//  Copyright © 2016 Tom and Jerry. All rights reserved.
//

#import "ShrinkDismissalAnimationController.h"

@implementation ShrinkDismissalAnimationController

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.75;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    [UIView animateKeyframesWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^(void){
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
            fromView.transform = CGAffineTransformMakeScale(0, 0);
            fromView.alpha = 0.0;
        }];
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
    }];
}

@end
