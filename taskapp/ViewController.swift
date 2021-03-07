//
//  ViewController.swift
//  taskapp
//
//  Created by 撫養航 on 2021/02/20.
//

import UIKit
import RealmSwift
import UserNotifications //通知

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var pic_category: UIPickerView!
    @IBOutlet weak var tbl_list: UITableView!
    
    let realm = try! Realm() //Realmインスタンス
    var realmArrayCategory = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: true) //Realmのカテゴリ配列
    var realmArrayTask = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)//Realmのカテゴリ配列
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pic_category.delegate = self
        self.pic_category.dataSource = self
        self.tbl_list.delegate = self
        self.tbl_list.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.realmArrayTask = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
        
        self.viewDidLoad()
        self.tbl_list.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" { //Cell選択で画面遷移する場合
            let indexPath = self.tbl_list.indexPathForSelectedRow
            inputViewController.task = realmArrayTask[indexPath!.row]
        } else {
            let task = Task() //値渡し用
            let allTasks = realm.objects(Task.self) //Realm内のタスクを束ねたオブジェクト
            if allTasks.count != 0 { //データが０件の場合を回避
                task.id = allTasks.max(ofProperty: "id")! + 1 //「最大id + 1」のidを設定
            }
            
            inputViewController.task = task
        }
        
    }
    
    //----- pickerView -----//
    
    // 選択する数（？）
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // データの数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return realmArrayCategory.count
    }
    
    // 表示データの内容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "---"
        }else{
            return realmArrayCategory[row].name //row番目のカテゴリ名
        }
    }
    
    // データが選択された時の処理
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if row == 0 {
            realmArrayTask = try! Realm().objects(Task.self)
        }else{
            realmArrayTask = try! Realm().objects(Task.self).filter("category_id == %@", row)
        }
        
        self.viewDidLoad()
        // 変更したタスクの情報をTableViewに反映
        tbl_list.reloadData()
        
    }
    
    //----- tableView -----//
    
    // Cellの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return realmArrayTask.count
    }

    // Cellの内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) // 再利用可能な cell を得る
        let realmTask = realmArrayTask[indexPath.row]
        let formatter:DateFormatter = DateFormatter() //使用準備
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm" //フォーマット設定
        
        cell.textLabel?.text = realmTask.title
        cell.detailTextLabel?.text = formatter.string(from: realmTask.date)
        
        return cell
    }

    // Cell選択
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // "cellSegue"という名前のsegueを実行し画面遷移
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }

    // セルが削除が可能なことを伝えるメソッド（？）
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }

    // Cell削除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // 削除するタスクを取得する
            let task = self.realmArrayTask[indexPath.row]

            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])

            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }

            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }


}

