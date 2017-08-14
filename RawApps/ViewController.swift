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
import Photos
import PhotosUI

class ViewController: UIViewController, UIPageViewControllerDataSource, UISearchBarDelegate {

	@IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var leadConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuSection: UIView!
    @IBOutlet weak var featLabel: UILabel!
	@IBOutlet weak var button: UIBarButtonItem!
	
	
	
    var menuOpen = false
    var pageViewController: UIPageViewController?
    var ref: DatabaseReference!
    var playerTeamArr = [String]()
	let storage = Storage.storage()
	
	var featImagesUIPhotos = [UIImage]()
    var featImages = [PHLivePhoto]()
	var featURL = [NSURL]()
	var featMovURL = [NSURL]()
	var searchClicked = false
	var searchInputText = ""
	
    override func viewDidLoad() {
        super.viewDidLoad()
		searchBar.delegate = self
        menuSection.tag = 1
        backgroundView.tag = 2
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureAction))
        view.addGestureRecognizer(tap)
        menuSection.layer.shadowOpacity = 1
		ref = Database.database().reference()
		self.setFeatImages{() -> () in
			self.createPageViewController()
		}
        setupPageControl()
    }
	
	@IBAction func downloadButton(_ sender: Any) {
		PHPhotoLibrary.shared().performChanges({
			
			let request = PHAssetCreationRequest.forAsset()
			let current = self.currentControllerIndex()
			
			request.addResource(with: .photo, fileURL: self.featURL[current] as URL, options: nil)
			request.addResource(with: .pairedVideo, fileURL: self.featMovURL[current] as URL, options: nil)
		})
		{ (success, error) in
			
			if success{
				let alert = UIAlertController(title: "Downloaded!", message: "", preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
				self.present(alert, animated: true, completion: nil)
			}
		}

	}
	
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		self.searchInputText = searchBar.text!
		self.searchClicked = true
		performSegue(withIdentifier: "PlayerSegue", sender: self)
	}
	
    @IBAction func playersClick(_ sender: Any) {
		if(searchClicked == true){
			let featuredRef = ref.child("Players")
			let featuredRef2 = ref.child("Teams")
			var playersTeamsArr = [String]()
			featuredRef.observeSingleEvent(of: .value, with: { (snapshot) in
				for child in snapshot.children{
					playersTeamsArr.append((child as AnyObject).key)
				}
			})
			featuredRef2.observeSingleEvent(of: .value, with: { (snapshot2) in
				for child2 in snapshot2.children{
					if(((child2 as AnyObject)).key.contains(self.searchInputText)){
						playersTeamsArr.append((child2 as AnyObject).key)
					}
				}
			})
			self.playerTeamArr = playersTeamsArr
			self.searchClicked = false
		}
		else{
			let featuredRef = ref.child("Players")
			var playersArr = [String]()
			featuredRef.observeSingleEvent(of: .value, with: { (snapshot) in
				for child in snapshot.children{
					playersArr.append((child as AnyObject).key)
				}
				self.playerTeamArr = playersArr
			})
		}
    }

    @IBAction func teamsClick(_ sender: Any) {
        let featuredRef = ref.child("Teams")
        var teamsArr = [String]()
        featuredRef.observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children{
                teamsArr.append((child as AnyObject).key)
            }
            self.playerTeamArr = teamsArr
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		self.searchBar.endEditing(true)
		if segue.identifier == "PlayerSegue"{
			if(self.searchClicked == true){
				let featuredRef = ref.child("Players")
				let featuredRef2 = ref.child("Teams")
				var playersTeamsArr = [String]()
				featuredRef.observeSingleEvent(of: .value, with: { (snapshot) in
					for child in snapshot.children{
						if(((child as AnyObject)).key.lowercased().contains(self.searchInputText.lowercased())){
							playersTeamsArr.append((child as AnyObject).key)
						}
					}
				})
				featuredRef2.observeSingleEvent(of: .value, with: { (snapshot2) in
					for child2 in snapshot2.children{
						if(((child2 as AnyObject)).key.lowercased().contains(self.searchInputText.lowercased())){
							playersTeamsArr.append((child2 as AnyObject).key)
						}
					}
					self.playerTeamArr = playersTeamsArr
					self.searchClicked = false
					let controller = segue.destination as! ListViewController
					controller.playerTeamList = self.playerTeamArr
					controller.viewDidLoad()
					controller.myTableView.reloadData()
				})
			}
			else{
				let featuredRef = ref.child("Players")
				var playersArr = [String]()
				featuredRef.observeSingleEvent(of: .value, with: { (snapshot) in
					for child in snapshot.children{
						playersArr.append((child as AnyObject).key)
					}
					self.playerTeamArr = playersArr
					let controller = segue.destination as! ListViewController
					controller.playerTeamList = self.playerTeamArr
					controller.myTableView.reloadData()
				})
			}
		}
			
		else if segue.identifier == "TeamsSegue"{
			let featuredRef = ref.child("Teams")
			var teamsArr = [String]()
			featuredRef.observeSingleEvent(of: .value, with: { (snapshot) in
				for child in snapshot.children{
					teamsArr.append((child as AnyObject).key)
				}
				self.playerTeamArr = teamsArr
				let controller = segue.destination as! ListViewController
				controller.playerTeamList = self.playerTeamArr
				controller.myTableView.reloadData()
			})
		}
    }
    
    func setFeatImages(handleComplete: @escaping (()->())){
		
		let featuredRef = ref.child("Featured")
		let featuredRef2 = ref.child("FeaturedMov")
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
									self.featImages.append(livePhoto)
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

    @IBAction func openMenu(_ sender: Any ) {
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
		self.searchBar.endEditing(true)
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
        let pageController = self.storyboard?.instantiateViewController(withIdentifier: "PageController") as! UIPageViewController
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
		self.view.bringSubview(toFront: featLabel)
		self.view.bringSubview(toFront: self.menuSection)
    }
    
    func setupPageControl(){
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.gray
        appearance.currentPageIndicatorTintColor = UIColor.white
        appearance.backgroundColor = UIColor.darkGray
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let ItemController = viewController as! FeatViewController
        
        if ItemController.itemIndex > 0 {
            return getItemController(ItemController.itemIndex-1)
        }
        return getItemController(featImages.count - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let ItemController = viewController as! FeatViewController
        
        if ItemController.itemIndex + 1 < featImages.count {
            return getItemController(ItemController.itemIndex+1)
        }
        return getItemController(0)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return featImages.count
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
        if itemIndex < featImages.count {
            let pageItemController = self.storyboard?.instantiateViewController(withIdentifier: "ItemController") as! FeatViewController
            
            pageItemController.itemIndex = itemIndex
            pageItemController.image = featImages[itemIndex]
            return pageItemController
        }
        
        return nil
    }
}

