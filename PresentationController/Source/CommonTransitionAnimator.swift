//
//  CommonTransitionAnimator.swift
//  CommonUIKit
//
//  Created by Rahul Pengoria on 20/06/17.
//  Copyright © 2017 Coviam. All rights reserved.
//

import UIKit

class CommonTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let direction: PresentationAlignment
    let isPresentation: Bool
    
    init(direction: PresentationAlignment, isPresentation: Bool) {
        self.direction = direction
        self.isPresentation = isPresentation
        super.init()
    }
    
    @objc func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let key = isPresentation ? UITransitionContextViewControllerKey.to
            : UITransitionContextViewControllerKey.from
        let controller = transitionContext.viewController(forKey: key)!
        transitionContext.containerView.addSubview(controller.view)
        let presentedFrame = transitionContext.finalFrame(for: controller)
        var dismissedFrame = presentedFrame
        switch direction {
        case .left:
            dismissedFrame.origin.x = -presentedFrame.width
            break
        case .right:
            dismissedFrame.origin.x = transitionContext.containerView.frame.size.width
            break
        case .top:
            dismissedFrame.origin.y = -presentedFrame.height
            break
        case .bottom:
            dismissedFrame.origin.y = transitionContext.containerView.frame.size.height
            break
        default :
            break
        }
        let initialFrame = isPresentation ? dismissedFrame : presentedFrame
        let finalFrame = isPresentation ? presentedFrame : dismissedFrame
        let animationDuration = transitionDuration(using: transitionContext)
        controller.view.frame = initialFrame
        
        if isPresentation && direction == .center {
            controller.view.transform = CGAffineTransform.identity.scaledBy(x: 0 , y: 0)
        }
        
        UIView.animate(withDuration: animationDuration, animations: {
            controller.view.frame = finalFrame
            if  self.direction == .center {
                controller.view.transform = self.isPresentation ? CGAffineTransform.identity.scaledBy(x: 1.0 , y: 1.0) : CGAffineTransform.identity.scaledBy(x: 0.1 , y: 0.1)
            }
        }) { finished in
            transitionContext.completeTransition(finished)
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
}

