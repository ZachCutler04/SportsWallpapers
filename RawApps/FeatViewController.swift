//
//  FeatViewController.swift
//  RawApps
//
//  Created by Zach on 7/15/17.
//  Copyright © 2017 Raw Software. All rights reserved.
//

import UIKit

class FeatViewController: UIViewController {
    
    var image: UIImage? = nil {
        didSet{
            if let imageView = featImage{
                imageView.image = image
            }
        }
    }
    var itemIndex: Int = 0
    
    
    @IBOutlet weak var featImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        featImage.image = image
        
    }

}
