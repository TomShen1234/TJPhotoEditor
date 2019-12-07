//
//  SettingPresentationController.m
//  PoemGame
//
//  Created by Ming Shen on 2/9/16.
//  Copyright © 2016 Tom and Jerry. All rights reserved.
//

#import "DimmingPresentationController.h"
#import "GradientView.h"

@implementation DimmingPresentationController {
    GradientView *gradientView;
}

- (BOOL)shouldRemovePresentersView {
    return NO;
}

- (void)presentationTransitionWillBegin {
    gradientView = [[GradientView alloc] initWithFrame:self.containerView.bounds];
   
    if (@available(iOS 11.0, *)) {
        gradientView.accessibilityIgnoresInvertColors = YES;
    }
    
    [self.containerView insertSubview:gradientView atIndex:0];
    
    self.containerView.alpha = 0.0f;
    
    id <UIViewControllerTransitionCoordinator> coordinator = [self.presentedViewController transitionCoordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.containerView.alpha = 1.0f;
    } completion:nil];
}

- (void)dismissalTransitionWillBegin {
    id <UIViewControllerTransitionCoordinator> coordinator = [self.presentedViewController transitionCoordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self->gradientView.alpha = 0.0f;
    } completion:nil];
}

@end
