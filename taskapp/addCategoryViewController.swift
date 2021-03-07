//
//  addCategoryViewController.swift
//  taskapp
//
//  Created by 撫養航 on 2021/02/27.
//

import UIKit
import RealmSwift

class addCategoryViewController: UIViewController {
    
    let realm = try! Realm()
    var category: Category! //前画面から送られたカテゴリ情報
    var realmArrayCategory = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: true) //Realmのカテゴリ配列
    
    @IBOutlet weak var txt_category: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // 画面が消える前
    override func viewWillDisappear(_ animated: Bool) {
        if txt_category.text! != "" {
            // Realm操作
            try! realm.write {
                self.category.name = self.txt_category.text!
                self.realm.add(self.category, update: .modified)
            }
        }
    }
}
