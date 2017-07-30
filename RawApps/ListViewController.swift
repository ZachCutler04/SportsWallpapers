//
//  ListViewController.swift
//  RawApps
//
//  Created by Zach on 7/26/17.
//  Copyright © 2017 Raw Software. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class ListViewController: UITableViewController {
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet var myTableViewCells: UITableView!

    var playerTeamList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableViewCells = UITableView()
        myTableViewCells.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        myTableViewCells.dataSource = self
        myTableViewCells.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.clearCells()
        self.myTableViewCells.reloadData()
    }
    
    func clearCells(){
        for cells in myTableViewCells.visibleCells {
            cells.delete(self)
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for:indexPath as IndexPath)
        cell.contentView.button = playerTeamList[indexPath.row]
        return cell
    }
    
    cla
}
