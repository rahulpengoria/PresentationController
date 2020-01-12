//
//  CommonPresentationController.swift
//  BlibliMobile-iOS
//
//  Created by Rahul Pengoria on 20/06/17.
//  Copyright © 2017 Coviam, PT. All rights reserved.
//

import UIKit

class CommonPresentationController: UIPresentationController {
    
    var isMaximized: Bool = false
    var customDimmingView: UIView?
    var visiblePercentage : CGFloat?
    var alignment: PresentationAlignment
    var horizontalPercentage : CGFloat?
    var verticalPercentage : CGFloat?
    var modalSize : CGSize?
    var isDismissOnBackgroundTouchEnabled:Bool = true
    var navigationBarIsHidden = false
    
    init(presentedViewController: UIViewController,
         presenting presentingViewController: UIViewController?,
         alignment: PresentationAlignment, visiblePercentage : CGFloat? = nil, horizontalPercentage : CGFloat? = nil, verticalPercentage : CGFloat? = nil, size:CGSize?=nil, isDismissBackground :Bool = true,navigationBarIsHidden : Bool = false ) {
        self.alignment = alignment
        self.visiblePercentage = visiblePercentage
        self.horizontalPercentage = horizontalPercentage
        self.verticalPercentage = verticalPercentage
        self.modalSize = size
        self.isDismissOnBackgroundTouchEnabled = isDismissBackground
        self.navigationBarIsHidden = navigationBarIsHidden
        super.init(presentedViewController: presentedViewController,
                   presenting: presentingViewController)
    }
    var dimmingView: UIView {
        var view = UIView()
        if let dimmedView = customDimmingView {
            view =  dimmedView
        }else {
            guard let containerHeight = containerView?.bounds.height, let containerWidth = containerView?.bounds.width else{
                return view
            }
            view = UIView(frame: CGRect(x: 0, y: 0, width: containerWidth, height: containerHeight))
            // Blur Effect
            view.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
            view.alpha = 0.5
            view.translatesAutoresizingMaskIntoConstraints = false
            customDimmingView = view
            customDimmingView?.isUserInteractionEnabled = true
            if isDismissOnBackgroundTouchEnabled == true {
                let dismissGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CommonPresentationController.dismiss))
                customDimmingView?.addGestureRecognizer(dismissGestureRecognizer)
            }
            
        }
        return view
    }
    
    @objc func dismiss() {
        self.presentingViewController.dismiss(animated: true, completion: nil)
    }
    
    
    func adjustScreen(percentage : CGFloat? = nil, modalSize:CGSize? = nil) {
        
        var changedframe: CGRect = .zero
        visiblePercentage  = percentage
        self.modalSize = modalSize
        
        if let presentedView = presentedView, let containerView = self.containerView {
            changedframe.size = size(forChildContentContainer: presentedViewController,
                                     withParentContainerSize: containerView.bounds.size)
            
            switch alignment {
            case .right:
                if let size = visiblePercentage, size != 0.0 {
                    changedframe.origin.x = (containerView.frame.width - containerView.frame.width*(size/100))
                }else if let horizontalSize = self.modalSize?.width, horizontalSize != 0.0 {
                    changedframe.origin.x = containerView.frame.width - horizontalSize
                }else{
                    changedframe.origin.x = containerView.frame.width*(1.0/3.0)
                }
            case .bottom:
                if let size = visiblePercentage, size != 0.0 {
                    changedframe.origin.y = (containerView.frame.height - containerView.frame.height*(size/100))
                }else if let verticalSize = self.modalSize?.height, verticalSize != 0.0 {
                    changedframe.origin.y = containerView.frame.height - verticalSize
                }else{
                    changedframe.origin.y = containerView.frame.height*(1.0/3.0)
                }
            case .center:
                if let size = visiblePercentage, size != 0.0 {
                    changedframe.origin.x = (containerView.frame.width - containerView.frame.width*(size/100)) / 2
                }else if let horizontalSize = horizontalPercentage, horizontalSize != 0.0 {
                    changedframe.origin.x = (containerView.frame.width - containerView.frame.width*(horizontalSize/100)) / 2
                }else if let horizontalSize = self.modalSize?.width, horizontalSize != 0.0 {
                    changedframe.origin.x = (containerView.frame.width - horizontalSize)/2
                }else{
                    changedframe.origin.x = containerView.frame.width*(1.0/3.0)
                }
                
                if let size = visiblePercentage, size != 0.0 {
                    
                    changedframe.origin.y = (containerView.frame.height - containerView.frame.height*(size/100)) / 2
                    
                }else if let verticalSize = verticalPercentage, verticalSize != 0.0 {
                    changedframe.origin.y = (containerView.frame.height - containerView.frame.height*(verticalSize/100)) / 2
                    
                }else if let verticalSize = self.modalSize?.height, verticalSize != 0.0 {
                    changedframe.origin.y = (containerView.frame.height - verticalSize)/2
                    
                }else{
                    
                    changedframe.origin.y = containerView.frame.height*(1.0/3.0)
                    
                }
                
                break
                
            default:
                
                changedframe.origin = .zero
                
            }
            
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: { () -> Void in
                presentedView.frame = changedframe
                if let navController = self.presentedViewController as? UINavigationController {
                    navController.setNeedsStatusBarAppearanceUpdate()
                    navController.isNavigationBarHidden = self.navigationBarIsHidden
                }
                
            }, completion: nil)
            
        }
        
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func size(forChildContentContainer container: UIContentContainer,
                       withParentContainerSize parentSize: CGSize) -> CGSize {
        var childSize = CGSize(width: parentSize.width, height: parentSize.height)
        switch alignment {
        case .left, .right:
            if let size = visiblePercentage, size != 0.0 {
                childSize =  CGSize(width: parentSize.width*(size/100), height: parentSize.height)
            }else if let horizontalSize = self.modalSize?.width, horizontalSize != 0.0 {
                childSize = CGSize(width: horizontalSize, height: parentSize.height)
            }else{
                childSize =  CGSize(width: parentSize.width*(2.0/3.0), height: parentSize.height)
            }
            break
        case .bottom, .top:
            if let size = visiblePercentage, size != 0.0 {
                childSize = CGSize(width: parentSize.width, height: parentSize.height*(size/100))
            }else if let verticalSize = self.modalSize?.height, verticalSize != 0.0 {
                childSize = CGSize(width: parentSize.width, height: verticalSize)
            }else {
                
                childSize = CGSize(width: parentSize.width, height: parentSize.height*(2.0/3.0))
            }
            break
        case .center:
            if let size = visiblePercentage, size != 0.0 {
                childSize = CGSize(width: parentSize.width*(size/100), height: parentSize.height*(size/100))
            }else if let horizontalSize = horizontalPercentage,let verticalSize = verticalPercentage, horizontalSize != 0.0 , verticalSize != 0.0 {
                childSize = CGSize(width: parentSize.width*(horizontalSize/100), height: parentSize.height*(verticalSize/100))
            }else if let verticalSize = self.modalSize?.height,let horizontalSize = self.modalSize?.width, horizontalSize != 0.0 , verticalSize != 0.0 {
                childSize = CGSize(width: horizontalSize, height: verticalSize)
                
            }else {
                childSize = CGSize(width: parentSize.width*(2.0/3.0), height: parentSize.height*(2.0/3.0))
            }
            break
        }
        
        return childSize
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        
        var frame: CGRect = .zero
        if let containView = containerView{
            frame.size = size(forChildContentContainer: presentedViewController,
                              withParentContainerSize: containView.bounds.size)
            switch alignment {
            case .right:
                if let size = visiblePercentage, size != 0.0 {
                    frame.origin.x = (containView.frame.width - containView.frame.width*(size/100))
                }else if let horizontalSize = self.modalSize?.width, horizontalSize != 0.0 {
                    frame.origin.x = (containView.frame.width - containView.frame.width*(horizontalSize/100)) / 2
                }else{
                    frame.origin.x = containView.frame.width*(1.0/3.0)
                }
            case .bottom:
                if let size = visiblePercentage, size != 0.0 {
                    frame.origin.y = (containView.frame.height - containView.frame.height*(size/100))
                }else if let verticalSize = self.modalSize?.height, verticalSize != 0.0 {
                    frame.origin.y = containView.frame.height - verticalSize
                }else{
                    frame.origin.y = containView.frame.height*(1.0/3.0)
                }
                
            case .center:
                if let size = visiblePercentage, size != 0.0 {
                    frame.origin.x = (containView.frame.width - containView.frame.width*(size/100)) / 2
                }else if let horizontalSize = horizontalPercentage, horizontalSize != 0.0 {
                    frame.origin.x = (containView.frame.width - containView.frame.width*(horizontalSize/100)) / 2
                }else if let horizontalSize = self.modalSize?.width, horizontalSize != 0.0 {
                    frame.origin.x = (containView.frame.width - horizontalSize)/2
                }else{
                    frame.origin.x = containView.frame.width*(1.0/3.0)
                }
                
                if let size = visiblePercentage, size != 0.0 {
                    frame.origin.y = (containView.frame.height - containView.frame.height*(size/100)) / 2
                }else if let verticalSize = verticalPercentage, verticalSize != 0.0 {
                    frame.origin.y = (containView.frame.height - containView.frame.height*(verticalSize/100)) / 2
                }else if let verticalSize = self.modalSize?.height, verticalSize != 0.0 {
                    frame.origin.y = (containView.frame.height - verticalSize)/2
                }else{
                    frame.origin.y = containView.frame.height*(1.0/3.0)
                }
                
                break
            default:
                frame.origin = .zero
            }
        }
        return frame
    }
    
    override func presentationTransitionWillBegin() {
        
        if let navController = self.presentedViewController as? UINavigationController {
            navController.setNeedsStatusBarAppearanceUpdate()
            navController.isNavigationBarHidden = self.navigationBarIsHidden
        }
        let dimmedView = dimmingView
        containerView?.insertSubview(dimmedView, at: 0)
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimmedView]|",
                                           options: [], metrics: nil, views: ["dimmedView": dimmingView]))
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[dimmedView]|",
                                           options: [], metrics: nil, views: ["dimmedView": dimmingView]))
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmedView.alpha = 1.0
            return
        }
        if alignment == .center {
            //-- added the corner radius
            self.presentedView?.layer.masksToBounds = true
            self.presentedView?.layer.cornerRadius = 4
        }
        coordinator.animate(alongsideTransition: { _ in
            dimmedView.alpha = 1.0
        })
    }
    
    override func dismissalTransitionWillBegin() {
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0.0
            return
        }
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
        })
    }
    
    
}

public protocol CommonPresenterChangeSize { }

public extension CommonPresenterChangeSize {
    func changed(sizeOfpresentationController viewController : UIViewController , percentage : CGFloat? = nil, size:CGSize? = nil) -> Void {
        if let presentation = viewController.navigationController?.presentationController as? CommonPresentationController {
            presentation.adjustScreen(percentage: percentage, modalSize: size)
        }
    }
}


