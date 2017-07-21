//
//  ViewController.swift
//  RawApps
//
//  Created by Zach on 7/13/17.
//  Copyright © 2017 Raw Software. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class ViewController: UIViewController, UIPageViewControllerDataSource {

    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var leadConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuSection: UIView!
    @IBOutlet weak var featLabel: UILabel!
    
    var menuOpen = false
    var pageViewController: UIPageViewController?
    var ref: DatabaseReference!
    
    var images = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuSection.tag = 1
        backgroundView.tag = 2
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureAction))
        view.addGestureRecognizer(tap)
        menuSection.layer.shadowOpacity = 1
        createPageViewController()
        setupPageControl()
        self.view.bringSubview(toFront: featLabel)
        self.view .bringSubview(toFront: self.menuSection)
    }
    
    @IBAction func openMenu(_ sender: Any) {
        if(menuOpen){
            leadConstraint.constant = -160
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }
        else{
            leadConstraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }
        menuOpen = !menuOpen
    }
    
    func tapClose(){
        if(menuOpen){
            openMenu(self)
        }
    }
    
    func tapGestureAction(sender: AnyObject){
        if let tap = sender as? UITapGestureRecognizer{
            let point = tap.location(in: menuSection)
            if menuSection.point(inside: point, with: nil) == false {
                tapClose()
            }
        }
        
    }
    func createPageViewController(){
        setFeatImages()
        let pageController = self.storyboard?.instantiateViewController(withIdentifier: "PageController") as! UIPageViewController
        pageController.dataSource = self
        if images.count > 0{
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
        let itemController = viewController as! FeatViewController
        
        if itemController.itemIndex > 0 {
            return getItemController(itemController.itemIndex-1)
        }
        return getItemController(images.count - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let itemController = viewController as! FeatViewController
        
        if itemController.itemIndex + 1 < images.count {
            return getItemController(itemController.itemIndex+1)
        }
        return getItemController(0)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return images.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func currentControllerIndex() -> Int {
        let pageItemController = self.currentController()
        if let controller = pageItemController as? FeatViewController {
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
    
    func getItemController(_ itemIndex: Int) -> FeatViewController? {
        if itemIndex < images.count {
            let pageItemController = self.storyboard?.instantiateViewController(withIdentifier: "ItemController") as! FeatViewController
            
            pageItemController.itemIndex = itemIndex
            pageItemController.imageName = "cool"
            return pageItemController
        }
        
        return nil
    }
    
    func setFeatImages(){
        ref = Database.database().reference()
        ref.observe(.value, with: { snapshot in
            for child in snapshot.children {
                self.images.append(child as! UIImage)
            }
        })
    }
}

