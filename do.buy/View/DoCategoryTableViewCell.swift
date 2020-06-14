//
//  DoCategoryTableViewCell.swift
//  do.buy
//
//  Created by Mingu Kang on June/2020.
//  Copyright 2020 Mingu. All rights reserved.
//

import UIKit
import RealmSwift

class DoCategoryTableViewCell: UITableViewCell {
    
    let realm = try! Realm()

    @IBOutlet weak var dot: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var title: UITextField!
    
    override func awakeFromNib() { 
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
