//
//  DismissMenuAnimator.swift
//  InteractiveSlideoutMenu
//
//  Created by Robert Chen on 2/7/16.
//
//  Copyright (c) 2016 Thorn Technologies LLC
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

class DismissMenuAnimator : NSObject {
}

extension DismissMenuAnimator : UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else {
                return
        }
        let containerView = transitionContext.containerView
        let snapshot = containerView.viewWithTag(MenuHelper.snapshotNumber)
        let darkenView = containerView.viewWithTag(MenuHelper.darkenNumber)
        
        toVC.view.frame = snapshot!.frame
        
        //Only animate alpha if interactive dragging transition
        if transitionContext.isInteractive {
            snapshot?.alpha = 1
            darkenView?.alpha = 1
        } else {
            snapshot?.alpha = 0
            darkenView?.alpha = 0
        }
        
        containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
        
        toVC.view.layer.shadowOpacity = 0.5
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseOut, animations: {
            toVC.view.frame = CGRect(origin: CGPoint.zero, size: UIScreen.main.bounds.size)
            snapshot?.frame = toVC.view.frame
            darkenView?.frame = toVC.view.frame
            darkenView?.alpha = 0
            snapshot?.alpha = 0
            },
            completion: { _ in
                let didTransitionComplete = !transitionContext.transitionWasCancelled
                if didTransitionComplete {
                    snapshot?.removeFromSuperview()
                    darkenView?.removeFromSuperview()
                } else {
                    snapshot?.alpha = 1
                    darkenView?.alpha = 1
                    toVC.view.removeFromSuperview()
                }
                toVC.view.layer.shadowOpacity = 0
                transitionContext.completeTransition(didTransitionComplete)
            }
        )
    }
}