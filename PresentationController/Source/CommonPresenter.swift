//
//  CommonPresenter.swift
//  CommonUIKit
//
//  Created by Rahul Pengoria on 20/06/17.
//  Copyright © 2017 Coviam. All rights reserved.
//

import UIKit

@objc public enum PresentationAlignment: Int {
    case left
    case top
    case right
    case bottom
    case center
}

@objc public class CommonPresenter : NSObject{
    var alignment = PresentationAlignment.bottom
    @objc var visiblePercentage : CGFloat = 0.0
    var horizontalPercentage : CGFloat = 0.0
    var verticalPercentage : CGFloat = 0.0
    var isDismissOnBackgroundTouchEnabled : Bool = true
    var navigationBarIsHidden = false
    var modalSize:CGSize = CGSize.zero
    
    @objc public init(alignment: PresentationAlignment, isDismissBackground : Bool = true, navigationBarIsHidden : Bool = false) {
        self.alignment = alignment
        self.isDismissOnBackgroundTouchEnabled = isDismissBackground
        self.navigationBarIsHidden = navigationBarIsHidden
        super.init()
    }
    
    public init(alignment: PresentationAlignment, visiblePercentage : CGFloat? = nil, horizontalPercentage : CGFloat? = nil, verticalPercentage : CGFloat? = nil,size:CGSize?=nil, isDismissBackground : Bool = true, navigationBarIsHidden : Bool = false  ) {
        
        self.alignment = alignment
        if let visiblePercentage = visiblePercentage {
            self.visiblePercentage = visiblePercentage
        }
        if let horizontalPercentage = horizontalPercentage {
            self.horizontalPercentage = horizontalPercentage
        }
        if let verticalPercentage = verticalPercentage {
            self.verticalPercentage = verticalPercentage
        }
        if let size = size {
            self.modalSize = size
        }
        self.isDismissOnBackgroundTouchEnabled = isDismissBackground
        self.navigationBarIsHidden = navigationBarIsHidden
        super.init()
    }
    
    @objc public func presentViewController(presentingViewController presentingVC: UIViewController, presentedViewController presentedVC: UIViewController, animated: Bool) {
        self.presentViewController(presentingViewController: presentingVC, presentedViewController: presentedVC, animated: animated, completion: nil)
    }
    
    @objc public func presentViewController(presentingViewController presentingVC: UIViewController, presentedViewController presentedVC: UIViewController, animated: Bool, completion: (() -> Void)?) {
        presentedVC.transitioningDelegate = self
        presentedVC.modalPresentationStyle = .custom
        presentingVC.present(presentedVC, animated: animated, completion: completion)
    }
}

extension CommonPresenter: UIViewControllerTransitioningDelegate {
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CommonTransitionAnimator(direction: alignment, isPresentation: false)
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        return CommonPresentationController.init(presentedViewController: presented, presenting: source, alignment: alignment,visiblePercentage: visiblePercentage,horizontalPercentage: horizontalPercentage,verticalPercentage: verticalPercentage,size: self.modalSize, isDismissBackground: isDismissOnBackgroundTouchEnabled,navigationBarIsHidden : self.navigationBarIsHidden)
        
    }
    
    public func animationController(forPresented presented: UIViewController,
                                    presenting: UIViewController,
                                    source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CommonTransitionAnimator(direction: alignment, isPresentation: true)
    }
    
}

public extension UIViewController {
    private static let association = ObjectAssociation<CommonPresenter>()
    var customPresenter : CommonPresenter? {
        get { return UIViewController.association[self] }
        set { UIViewController.association[self] = newValue }
    }
    
    func present(presenter: CommonPresenter, viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        presenter.presentViewController(presentingViewController: self,
                                        presentedViewController: viewController,
                                        animated: animated,
                                        completion: completion)
    }
    
}

public final class ObjectAssociation<T: AnyObject> {
    
    private let policy: objc_AssociationPolicy
    
    /// - Parameter policy: An association policy that will be used when linking objects.
    public init(policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        
        self.policy = policy
    }
    
    /// Accesses associated object.
    /// - Parameter index: An object whose associated object is to be accessed.
    public subscript(index: AnyObject) -> T? {
        
        get { return objc_getAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque()) as! T? }
        set { objc_setAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque(), newValue, policy) }
    }
}
