//
//  Task.swift
//  taskapp
//
//  Created by 撫養航 on 2021/02/21.
//

import RealmSwift

class Task: Object {
    
    // ID（主キー）
    @objc dynamic var id = 0
    
    // カテゴリID（外部キー）
    @objc dynamic var category_id = 0
    
    // タイトル
    @objc dynamic var title = ""

    // 内容
    @objc dynamic var contents = ""

    // 日時
    @objc dynamic var date = Date()

    // id をプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
