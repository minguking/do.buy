//
//  BuyCategory.swift
//  Todoey
//
//  Created by Kang Mingu on 2020/06/01.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class BuyCategory: Object {
    @objc dynamic var name: String = ""
    
    let item = List<BuyItem>()
}
