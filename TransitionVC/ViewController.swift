//
//  ViewController.swift
//  TransitionVC
//
//  Created by Anton on 17/05/2022.
//

import UIKit

class ViewController: UIViewController {
    
    let animator = Animator()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Mint"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.delegate = self
    }
}

extension ViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.operation = operation
        return animator
    }
}
