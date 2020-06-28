//
//  LegendViewController.swift
//  SimpleCoreMLDemo
//
//  Created by Chamin Morikawa on 2020/06/26.
//  Copyright © 2020 Chamin Morikawa. All rights reserved.
//

import Foundation
import UIKit

class LegendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableViewLegend: UITableView!
    
    var classTitles: [String] = getDeepLabV3Labels()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cellClassLabel")
        let imgViewColor: UIImageView = cell?.contentView.viewWithTag(100) as! UIImageView
        let lblClassLabel: UILabel = cell?.contentView.viewWithTag(101) as! UILabel
        imgViewColor.backgroundColor = getDeepLabUIColorForSegmentIndex(i: indexPath.row)
        lblClassLabel.text = classTitles[indexPath.row]
        
        return cell!
    }
    
    override func viewDidLoad() {
        tableViewLegend.reloadData()
    }
}
