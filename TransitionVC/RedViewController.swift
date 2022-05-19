//
//  OrangeViewController.swift
//  TransitionVC
//
//  Created by Anton on 17/05/2022.
//

import UIKit

class RedViewController: UIViewController {

    weak var animator: Animator?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "Red"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
 
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
