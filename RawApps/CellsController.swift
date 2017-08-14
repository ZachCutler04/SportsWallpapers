//
//  CellsController.swift
//  RawApps
//
//  Created by KACEY CUTLER on 8/13/17.
//  Copyright © 2017 Raw Software. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import Photos
import PhotosUI

class CellsController: UIViewController, UIPageViewControllerDataSource{
    
    var ref: DatabaseReference!
    var pageViewController: UIPageViewController?
    
    var searchFor = ""
    var featImages = [UIImage]()
    
    override func viewDidLoad() {
        ref = Database.database().reference()
        createPageViewController()
        self.setFeatImages{() -> () in
            self.createPageViewController()
        }
        setupPageControl()
    }
    
    
    
    func setFeatImages(handleComplete: @escaping (()->())){
        
        let featuredRef = ref.child(searchFor)
        featuredRef.observeSingleEvent(of: .value, with: { (snapshot) in
            for rest in snapshot.children.allObjects as! [DataSnapshot]{
                let dbString = (rest.value as! String).description
                
                if let url = NSURL(string: dbString) {
                    if let data = NSData(contentsOf: url as URL) {
                        self.featImages.append(UIImage(data: data as Data)!)
                        
                    }
                }
            }
            handleComplete()
        })
    }
//    private func makeLivePhotoFromItems(imageURL: NSURL, videoURL: NSURL, previewImage: UIImage, completion: @escaping (_ livePhoto: PHLivePhoto) -> Void) {
//        PHLivePhoto.request(withResourceFileURLs: [imageURL as URL, videoURL as URL], placeholderImage: previewImage, targetSize: CGSize.zero, contentMode: .aspectFit) {
//            (livePhoto, infoDict) -> Void in
//            if let lp = livePhoto {
//                completion(lp)
//            }
//        }
//    }
    
    func createPageViewController(){
        let pageController = self.storyboard?.instantiateViewController(withIdentifier: "CellsPageController") as! UIPageViewController
        pageController.dataSource = self
        if self.featImages.count > 0{
            let firstController = getItemController(0)!
            let startingViewControllers = [firstController]
            pageController.setViewControllers(startingViewControllers, direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        }
        pageViewController = pageController
        addChildViewController(pageViewController!)
        
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMove(toParentViewController: self)
    }
    
    func setupPageControl(){
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.gray
        appearance.currentPageIndicatorTintColor = UIColor.white
        appearance.backgroundColor = UIColor.darkGray
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let ItemController = viewController as! ImagesViewController
        
        if ItemController.itemIndex > 0 {
            return getItemController(ItemController.itemIndex-1)
        }
        return getItemController((featImages.count-1) / 4)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let ItemController = viewController as! ImagesViewController
        
        if ItemController.itemIndex * 4 < featImages.count {
            return getItemController(ItemController.itemIndex+1)
        }
        return getItemController(0)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return ((featImages.count) / 4) + 1
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func currentControllerIndex() -> Int {
        let pageItemController = self.currentController()
        if let controller = pageItemController as? ImagesViewController {
            return controller.itemIndex
        }
        return -1
    }
    
    func currentController() -> UIViewController? {
        if (self.pageViewController?.viewControllers?.count)! > 0 {
            return self.pageViewController?.viewControllers![0]
        }
        
        return nil
    }
    
    func getItemController(_ itemIndex: Int) -> ImagesViewController? {
        if itemIndex * 4 < featImages.count {
            let pageItemController = self.storyboard?.instantiateViewController(withIdentifier: "CellsItemController") as! ImagesViewController
            
            pageItemController.itemIndex = itemIndex
            pageItemController.image = featImages[itemIndex * 4]
            if(featImages.count > (itemIndex * 4) + 1){
                pageItemController.image2 = featImages[(itemIndex * 4) + 1]
            }
            if(featImages.count > (itemIndex * 4) + 2){
                pageItemController.image3 = featImages[(itemIndex * 4) + 2]
            }
            if(featImages.count > (itemIndex * 4) + 3){
                pageItemController.image4 = featImages[(itemIndex * 4) + 3]
            }
            return pageItemController
        }
        
        return nil
    }
    
}
