//
//  InputViewController.swift
//  taskapp
//
//  Created by 撫養航 on 2021/02/20.
//

import UIKit
import RealmSwift
import UserNotifications //通知

class InputViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var pic_category: UIPickerView!
    @IBOutlet weak var txt_title: UITextField!
    @IBOutlet weak var txt_contents: UITextView!
    @IBOutlet weak var pic_date: UIDatePicker!
    
    let realm = try! Realm()
    var realmArrayCategory = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: true) //Realmのカテゴリ配列
    
    var task = Task()
    
    var intTmp: Int! //選択したカテゴリを一時的に保存する変数
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        realmArrayCategory = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: true)
        
        self.pic_category.delegate = self
        self.pic_category.dataSource = self
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        self.pic_category.selectRow(task.category_id, inComponent: 0, animated: false)
        
        self.intTmp = task.category_id
        self.txt_title.text = task.title
        self.txt_contents.text = task.contents
        self.pic_date.date = task.date
        
    }
    
    // 画面表示前
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewDidLoad()
    }
    
    // 画面消える前
    override func viewWillDisappear(_ animated: Bool) {
        // Realm操作
        try! realm.write {
            self.task.category_id = intTmp
            self.task.title = self.txt_title.text!
            self.task.contents = self.txt_contents.text
            self.task.date = self.pic_date.date
            self.realm.add(self.task, update: .modified)
        }
        setNotification(task: task)
        
        super.viewDidLoad()
        super.viewWillDisappear(animated)
    }
    
    // 画面遷移時
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let addCategoryViewController:addCategoryViewController = segue.destination as! addCategoryViewController
        
        let category = Category() //値渡し用
        let allCategorys = realm.objects(Category.self) //Realm内のタスクを束ねたオブジェクト
        if allCategorys.count != 0 { //データが０件の場合を回避
            category.id = allCategorys.max(ofProperty: "id")! + 1 //「最大id + 1」のidを設定
        }
        addCategoryViewController.category = category
        
    }
    
    // 通知の登録
    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        // タイトルと内容を設定(中身がない場合メッセージ無しで音だけの通知になるので「(xxなし)」を表示する)
        if task.title == "" {
            content.title = "(タイトルなし)"
        } else {
            content.title = task.title
        }
        if task.contents == "" {
            content.body = "(内容なし)"
        } else {
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default

        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)

        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
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
    
    // キーボードを閉じる
    @objc func dismissKeyboard(){
        view.endEditing(true)
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
        
        intTmp = row
        
    }
    
}
