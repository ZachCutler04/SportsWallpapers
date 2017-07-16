//
//  FeatViewController.swift
//  RawApps
//
//  Created by Zach on 7/15/17.
//  Copyright © 2017 Raw Software. All rights reserved.
//

import UIKit

class FeatViewController: UIViewController {
    
    
    var itemIndex: Int = 0
    var imageName: String = ""{
     
        didSet{
            if let imageView = featImage{
                imageView.image = UIImage(named: imageName)
            }
        }
        
    }
    
    
    
    @IBOutlet weak var featImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        featImage.image = UIImage(named: imageName)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
