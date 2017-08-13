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

class ListViewController: UITableViewController{

    var playerTeamList = [String]()
    
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        myTableView.dataSource = self
        myTableView.delegate = self
    }
    
    func clearCells(){
        for cells in myTableView.visibleCells {
            cells.delete(self)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let thisCell = tableView.dequeueReusableCell(withIdentifier: "MyCell")
        thisCell?.textLabel?.text = playerTeamList[indexPath.row]
        return thisCell!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playerTeamList.count;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Cells", sender: self)
    }
}
