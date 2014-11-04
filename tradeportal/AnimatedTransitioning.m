//
//  AnimatedTransitioning.m
//  CustomTransitionExample
//
//  Created by Blanche Faur on 10/24/13.
//  Copyright (c) 2013 Blanche Faur. All rights reserved.
//

#import "AnimatedTransitioning.h"
#import "DataModel.h"

@implementation AnimatedTransitioning

//===================================================================
// - UIViewControllerAnimatedTransitioning
//===================================================================

DataModel *dm;

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
   
    
    UIView *inView = [transitionContext containerView];
//    ChangePasswordViewController *toVC = (ChangePasswordViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    dm.toView=[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    dm.fromView=[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//    LoginViewController *fromVC = (LoginViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [inView addSubview:dm.toView.view];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [dm.toView.view setFrame:CGRectMake(0, screenRect.size.height, dm.fromView.view.frame.size.width, dm.fromView.view.frame.size.height)];
    
    [UIView animateWithDuration:0.25f
                     animations:^{
                         
                         [dm.toView.view setFrame:CGRectMake(0, 0, dm.fromView.view.frame.size.width, dm.fromView.view.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [transitionContext completeTransition:YES];
                     }];
}


@end
