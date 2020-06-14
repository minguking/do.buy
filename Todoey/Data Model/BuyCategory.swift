//
//  BuyCategory.swift
//  do.buy
//
//  Created by Mingu Kang on June/2020.
//  Copyright 2020 Mingu. All rights reserved.
//

import Foundation
import RealmSwift

class BuyCategory: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var orderPosition: Int = 0
    
    let item = List<BuyItem>()
}
