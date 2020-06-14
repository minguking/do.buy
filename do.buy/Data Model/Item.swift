//
//  Item.swift
//  do.buy
//
//  Created by Mingu Kang on June/2020.
//  Copyright 2020 Mingu. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var orderPosition: Int = 0
    
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
