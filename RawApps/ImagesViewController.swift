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
    
    
    
    var image: PHLivePhoto? = nil {
        didSet{
            if let imageView = imageShowing{
                imageView.livePhoto = image
            }
        }
    }
    
    var itemIndex = 0
    
    @IBOutlet weak var imageShowing: PHLivePhotoView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageShowing.livePhoto = image

    }
    
}
