//
//  Category.swift
//  ToDo-Realm
//
//  Created by Sergey on 1/6/21.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
}
