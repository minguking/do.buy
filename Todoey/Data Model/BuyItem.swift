//
//  BuyItem.swift
//  Todoey
//
//  Created by Kang Mingu on 2020/06/01.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class BuyItem: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    
    var parentCategory = LinkingObjects(fromType: BuyCategory.self, property: "item")
}
