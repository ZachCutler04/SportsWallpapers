//
//  FeatViewController.swift
//  RawApps
//
//  Created by Zach on 7/15/17.
//  Copyright © 2017 Raw Software. All rights reserved.
//

import UIKit
import PhotosUI
import Photos

class ImagesViewController: UIViewController {
    
    @IBOutlet weak var firstImage: UIImageView!
    @IBOutlet weak var secondImage: UIImageView!
    @IBOutlet weak var thirdImage: UIImageView!
    @IBOutlet weak var fourthImage: UIImageView!
    
    var image: UIImage? = nil {
        didSet{
            if let imageView = firstImage{
                imageView.image = image
            }
        }
    }
    
    var image2: UIImage? = nil {
        didSet{
            if let imageView = secondImage{
                imageView.image = image2
            }
        }
    }
    
    var image3: UIImage? = nil {
        didSet{
            if let imageView = thirdImage{
                imageView.image = image3
            }
        }
    }
    
    var image4: UIImage? = nil {
        didSet{
            if let imageView = fourthImage{
                imageView.image = image4
            }
        }
    }
    var itemIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstImage.image = image
        secondImage.image = image2
        thirdImage.image = image3
        fourthImage.image = image4
    }
    
}
