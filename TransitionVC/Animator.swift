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
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        storedContext = transitionContext
     
    

        if operation == .push,
           let toVC = transitionContext.viewController(forKey: .to) as? RedViewController {
            
            transitionContext.containerView.addSubview(toVC.view)
            setupReplicator(toVC.view)
         
      
        } else if operation == .pop,
                  let fromVC = transitionContext.viewController(forKey: .from) as? RedViewController,
                  let toVC = transitionContext.viewController(forKey: .to) as? ViewController {
            transitionContext.containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
            setupHeartReplicator(fromVC.view)
        
        }
    }
}
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
