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
    var featImagesUIPhotos = [UIImage]()
    var doneImages = [PHLivePhoto]()
    var featURL = [NSURL]()
    var featMovURL = [NSURL]()
    
    override func viewDidLoad() {
        ref = Database.database().reference()
        self.setFeatImages{() -> () in
            self.createPageViewController()
        }
        setupPageControl()
    }
    
    
    
    func setFeatImages(handleComplete: @escaping (()->())){
        
        let featuredRef = ref.child(searchFor)
        let featuredRef2 = ref.child(searchFor + "mov")
        featuredRef.observeSingleEvent(of: .value, with: { (snapshot) in
            var counter = 0
            for rest in snapshot.children.allObjects as! [DataSnapshot]{
                let dbString = (rest.value as! String).description
                if let url = NSURL(string: dbString) {
                    if let data = NSData(contentsOf: url as URL) {
                        var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last
                        docURL = docURL?.appendingPathComponent("sample" + counter.description + ".jpg")
                        self.featURL.append(docURL! as NSURL)
                        data.write(to: docURL!, atomically: true)
                        self.featImagesUIPhotos.append(UIImage(data: data as Data)!)
                        counter += 1
                    }
                }
            }
            featuredRef2.observeSingleEvent(of: .value, with: { (snapshot2) in
                let maxCounter = snapshot2.childrenCount
                var counter2 = -1
                var counter3 = 0
                for rest in snapshot2.children.allObjects as! [DataSnapshot]{
                    let dbString = (rest.value as! String).description
                    if let url = NSURL(string: dbString) {
                        if let data = NSData(contentsOf: url as URL) {
                            var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last
                            docURL = docURL?.appendingPathComponent("sample2" + counter2.description + ".mov")
                            self.featMovURL.append(docURL! as NSURL)
                            data.write(to: docURL!, atomically: true)
                            counter2 += 1
                            self.makeLivePhotoFromItems(imageURL: self.featURL[counter2], videoURL: docURL! as NSURL, previewImage: self.featImagesUIPhotos[counter2]) { (livePhoto) in
                                counter3 += 1
                                if UInt(counter2) < maxCounter {
                                    self.doneImages.append(livePhoto)
                                }
                                if maxCounter == UInt(counter3) {
                                    handleComplete()
                                }
                            }
                        }
                    }
                }
            })
        })
    }
    
    private func makeLivePhotoFromItems(imageURL: NSURL, videoURL: NSURL, previewImage: UIImage, completion: @escaping (_ livePhoto: PHLivePhoto) -> Void) {
        PHLivePhoto.request(withResourceFileURLs: [imageURL as URL, videoURL as URL], placeholderImage: previewImage, targetSize: CGSize.zero, contentMode: .aspectFit) {
            (livePhoto, infoDict) -> Void in
            print (infoDict)
            if let canceled = infoDict[PHLivePhotoInfoCancelledKey] as? NSNumber,
                canceled == 0,
                let livePhoto = livePhoto
            {
                completion(livePhoto)
            }
        }
    }
    
    func createPageViewController(){
        let pageController = self.storyboard?.instantiateViewController(withIdentifier: "CellsPageController") as! UIPageViewController
        pageController.dataSource = self
        if self.doneImages.count > 0{
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
        return getItemController(doneImages.count-1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let ItemController = viewController as! ImagesViewController
        
        if ItemController.itemIndex < doneImages.count {
            return getItemController(ItemController.itemIndex+1)
        }
        return getItemController(0)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return doneImages.count
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
        if itemIndex < doneImages.count {
            let pageItemController = self.storyboard?.instantiateViewController(withIdentifier: "CellsItemController") as! ImagesViewController
            
            pageItemController.itemIndex = itemIndex
            pageItemController.image = doneImages[itemIndex]
            return pageItemController
        }
        
        return nil
    }
    
}
