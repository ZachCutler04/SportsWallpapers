//
//  ViewController.swift
//  RawApps
//
//  Created by Zach on 7/13/17.
//  Copyright © 2017 Raw Software. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var leadConstraint: NSLayoutConstraint!
    
    var menuOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func openMenu(_ sender: Any) {
        if(menuOpen){
            leadConstraint.constant = -150
        }
        else{
            leadConstraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }
        menuOpen = !menuOpen
    }
}

