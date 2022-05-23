//
//  Animator.swift
//  TransitionVC
//
//  Created by Anton on 17/05/2022.
//

import UIKit

func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(
        deadline: .now() + seconds,
        execute: run)
}

class Animator: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {
    
    
    let animationDuration = 1.5
    var operation: UINavigationController.Operation = .push
    weak var storedContext: UIViewControllerContextTransitioning?
    var animator: UIViewPropertyAnimator?
    
 
    
   
    // MARK: - Replicator
    func setupReplicator(_ view: UIView) {
        let replicator = CAReplicatorLayer()
        let line = CAShapeLayer()
        replicator.frame = view.bounds
        let dotWidth = view.frame.width * 2
        let dotHeight = view.frame.height / 5
        line.frame = CGRect(x: view.frame.width , y: 0, width: dotWidth, height: dotHeight)

        line.backgroundColor = UIColor.white.cgColor
        line.cornerRadius = 20
        replicator.instanceCount = Int(view.frame.size.height / line.frame.height)

        replicator.instanceTransform = CATransform3DMakeTranslation(0, dotHeight , 0)
        replicator.instanceDelay = 0.05
        replicator.addSublayer(line)

        view.layer.mask = replicator

        let position = CABasicAnimation(keyPath: "position.x")
        position.toValue = 0

        let transition = CABasicAnimation(keyPath: "transform.scale")
        transition.fromValue = 0.01
        transition.toValue = 1.2

        let animGroup = CAAnimationGroup()
        animGroup.duration = animationDuration
        animGroup.delegate = self
        animGroup.timingFunction = CAMediaTimingFunction(controlPoints: 0.36, 0.25, 0, 0.7)
        animGroup.animations = [position, transition]
        line.add(animGroup, forKey: nil)
        afterDelay(animationDuration - 0.15) {
            view.layer.mask = nil
        }
    }
    
    func setupHeartReplicator(_ view: UIView) {
        let replicator = CAReplicatorLayer()
        let verticalReplicator = CAReplicatorLayer()
        let dot = CALayer()
        
        dot.contents = UIImage(systemName: "heart.fill")?.cgImage
        
        replicator.frame = view.bounds
        let dotWidth: CGFloat = 50
        let dotHeight: CGFloat = 50
        dot.frame = CGRect(x: 0 , y: 0, width: dotWidth, height: dotHeight)
        dot.setAffineTransform(CGAffineTransform(scaleX: 2.5, y: 2.7))
//        replicator.instanceCount = Int(view.frame.size.height / dot.frame.height)
        replicator.instanceCount = Int(10)
        
        replicator.instanceTransform = CATransform3DMakeTranslation(dotWidth, 0, 0)
        replicator.instanceDelay = 0.01
        replicator.addSublayer(dot)
        
        verticalReplicator.frame.size = view.frame.size
        verticalReplicator.instanceCount = 20
        verticalReplicator.instanceDelay = 0.01
        verticalReplicator.instanceTransform = CATransform3DMakeTranslation(0, dotHeight, 0)
        verticalReplicator.addSublayer(replicator)
        view.layer.mask = verticalReplicator
        
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.toValue = 0.01
        let position = CABasicAnimation(keyPath: "transform.rotation")
        position.fromValue = 0
        position.toValue = 2.0 * .pi 
        let gropeAnim = CAAnimationGroup()
        gropeAnim.duration = animationDuration
        gropeAnim.delegate = self
        gropeAnim.fillMode = .backwards
        gropeAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        gropeAnim.animations = [scale, position]
        dot.add(gropeAnim, forKey: nil)
        
        afterDelay(animationDuration - 0.15) {
            view.layer.mask = nil
        }
    }
    // MARK: - Transition
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        storedContext = transitionContext
     
    

        if operation == .push {
            if let toVC = transitionContext.viewController(forKey: .to) as? RedViewController {
            
            transitionContext.containerView.addSubview(toVC.view)
            setupReplicator(toVC.view)
            } else {
                transitionAnimationPresent(using: transitionContext).startAnimation()
            }
            
      
        } else if operation == .pop {
            if let fromVC = transitionContext.viewController(forKey: .from) as? RedViewController,
               let toVC = transitionContext.viewController(forKey: .to) as? ViewController {
                transitionContext.containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
                setupHeartReplicator(fromVC.view)
            } else {
                transitionAnimationDismiss(using: transitionContext).startAnimation()
            }
        }
    }
    // MARK: - Present
    func transitionAnimationPresent(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        let duration = 0.7
        let container = transitionContext.containerView
        
        guard let toView = transitionContext.view(forKey: .to) else { return UIViewPropertyAnimator() }
       
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut)
        var top = UIView()
        var bottom = UIView()
        
        if let topSnap = toView.resizableSnapshotView(from: CGRect(x: 0, y: 0, width: toView.frame.width, height: toView.frame.midY), afterScreenUpdates: true, withCapInsets: .zero) {

            topSnap.frame = CGRect(x: 0, y: -toView.frame.height / 2, width: toView.frame.width, height: toView.frame.height / 2)
            top = topSnap
        }
        if let bottomSnap = toView.resizableSnapshotView(from: CGRect(x: 0, y: toView.frame.midY, width: toView.frame.width, height: toView.frame.midY), afterScreenUpdates: true, withCapInsets: .zero) {
            bottomSnap.frame = CGRect(x: 0, y: toView.frame.height, width: toView.frame.width, height: toView.frame.height / 2)
            bottom = bottomSnap
        }
        container.addSubview(top)
        container.addSubview(bottom)
        
        animator.addAnimations {
            top.transform = CGAffineTransform(translationX: 0.0, y: toView.frame.midY)
            bottom.transform = CGAffineTransform(translationX: 0.0, y: -toView.frame.midY)
        }
        animator.addCompletion { position in
          switch position {
          case .end:
              container.addSubview(toView)
              top.removeFromSuperview()
              bottom.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
          default:
            transitionContext.completeTransition(false)
          }
        }
        self.animator = animator
        animator.addCompletion { [unowned self] _ in
            self.animator = nil
        }
        animator.isUserInteractionEnabled = true
        return animator
    }
    // MARK: - Dismiss
    func transitionAnimationDismiss(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        let duration = 0.7
        let container = transitionContext.containerView

        guard let fromView = transitionContext.view(forKey: .from), let toView = transitionContext.view(forKey: .to) else { return UIViewPropertyAnimator() }
        
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeIn)
        var leftView = UIView()
        var rightView = UIView()
        
        if let topSnap = fromView.resizableSnapshotView(from: CGRect(x: 0, y: 0, width: fromView.frame.width / 2, height: fromView.frame.height), afterScreenUpdates: true, withCapInsets: .zero) {

            topSnap.frame = CGRect(x: 0, y: 0, width: fromView.frame.width / 2, height: fromView.frame.height)
            leftView = topSnap
        }
        if let bottomSnap = fromView.resizableSnapshotView(from: CGRect(x: fromView.frame.midX, y: 0, width: fromView.frame.width / 2, height: fromView.frame.height), afterScreenUpdates: true, withCapInsets: .zero) {
            bottomSnap.frame = CGRect(x: fromView.frame.midX, y: 0, width: fromView.frame.width / 2, height: fromView.frame.height)
            rightView = bottomSnap
        }

        container.addSubview(leftView)
        container.addSubview(rightView)
        container.addSubview(toView)
        container.insertSubview(leftView, aboveSubview: toView)
        container.insertSubview(rightView, aboveSubview: toView)
        
        animator.addAnimations {
            leftView.transform = CGAffineTransform(translationX: -fromView.frame.width, y: 0.0)
            rightView.transform = CGAffineTransform(translationX: fromView.frame.width, y: 0.0)
        }

        animator.addCompletion { position in
          switch position {
          case .end:
              fromView.removeFromSuperview()
              leftView.removeFromSuperview()
              rightView.removeFromSuperview()
              
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
          default:
            transitionContext.completeTransition(false)
          }
        }
        self.animator = animator
        animator.addCompletion { [unowned self] _ in
            self.animator = nil
        }
        return animator
    }
}
// MARK: - CAAnimationDelegate
extension Animator: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let context = storedContext {
            switch operation {
            case .push:
                let toVC = context.viewController(forKey: .to) as? RedViewController
                toVC?.view.layer.mask = nil
             
                context.completeTransition(!context.transitionWasCancelled)
            case .pop:
                let fromVC = context.viewController(forKey: .from) as? RedViewController
                fromVC?.view.layer.mask = nil
                context.completeTransition(!context.transitionWasCancelled)
            default:
                break
                
            }
        }
        storedContext = nil
    }
}
