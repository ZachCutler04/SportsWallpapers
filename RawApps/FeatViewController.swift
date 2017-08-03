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

class FeatViewController: UIViewController {
    
    var image: PHLivePhoto? = nil {
        didSet{
            if let imageView = featImage{
                imageView.livePhoto = image
            }
        }
    }
    var itemIndex: Int = 0

    @IBOutlet weak var featImage: PHLivePhotoView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        featImage.livePhoto = image
        
    }

}
