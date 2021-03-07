//
//  Category.swift
//  taskapp
//
//  Created by 撫養航 on 2021/02/27.
//

import RealmSwift

class Category: Object {
    
    // ID（主キー）
    @objc dynamic var id = 0

    // カテゴリ
    @objc dynamic var name = ""

    // id をプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
