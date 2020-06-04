//
//  DoCategoryTableViewCell.swift
//  Todoey
//
//  Created by Kang Mingu on 2020/06/04.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit

class DoCategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
