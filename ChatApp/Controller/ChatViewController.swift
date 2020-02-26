//
//  ChatViewController.swift
//  ChatApp
//
//  Created by 中野勇貴 on 2020/02/24.
//  Copyright © 2020 Nakano Yuki. All rights reserved.
//

import UIKit
import ChameleonFramework
import Firebase

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    //スクリーンサイズ
    let screenSize = UIScreen.main.bounds.size
    
    var chatArray = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        messageTextField.delegate = self
        //tableViewにCellを登録する
        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        //Cellの大体の高さを先に決めておく
        tableView.estimatedRowHeight = 80
        //messageの文字数が多くなったときのために行の高さを可変式にする
        tableView.rowHeight = UITableView.automaticDimension
        
        //キーボード
        //メッセージを入力する際にtextField+送信ボタンをキーボード分上に移動させたい
        //引数の”_ :”は引数を取れるよという意味 関数を呼び出す時に引数の方を書かなくて済む？
        //selectorの前にある"#" 中で呼んでいるメソッドの宣言時には前に"@objc"とつける必要がある
    //キーボードが出てきそうなタイミングで通知を受け取り(NotificationCenterで)そのタイミングでkeyboardWillShowメソッドを実行する
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    //キーボードが消えそうなタイミングで通知を受け取り(NotificationCenterで)そのタイミングでkeyboardWillShowメソッドを実行する
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //Firebaseからデータをfetch(取得)してくる
        fetchChatData()
        
        //cellとcellを区切っている線を消す
        tableView.separatorStyle = .none
        
    }
    
    //キーボード以外のところをタッチしたらキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        messageTextField.resignFirstResponder()
    }
    
    //returnキーを押したらキーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        //キーボードの高さを取得
        let keyboardHeight = ((notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as Any) as AnyObject).cgRectValue.height
        
        messageTextField.frame.origin.y = screenSize.height - keyboardHeight - messageTextField.frame.height
        
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        messageTextField.frame.origin.y = screenSize.height - messageTextField.frame.height
    
       //処理が行わなければメソッドを抜ける
        guard let rect = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue, let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }
        
        UIView.animate(withDuration: duration) {
            let tranceform = CGAffineTransform(translationX: 0, y: 0)
            self.view.transform = tranceform
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //messageの数
        return chatArray.count
    }
    
    //sectionの数
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomCell
        
        
        cell.messageLabel.text = chatArray[indexPath.row].message
        //画像の表示の仕方は後で変更するかも
        cell.iconImage.image = UIImage(named: "dogAvatarImage")
        
        //cellの背景色を設定する
        //自分のmessageだったら緑色
        //違う人だったら青
        if cell.userNameLabel.text == Auth.auth().currentUser?.email {
            cell.messageLabel.backgroundColor = UIColor.flatGreen()
        } else {
            cell.messageLabel.backgroundColor = UIColor.flatBlue()
        }
        
        //messageLabelの部分を角丸に
        cell.messageLabel.layer.cornerRadius = 20.0
        cell.messageLabel.layer.masksToBounds = true
        cell.userNameLabel.text = chatArray[indexPath.row].sender
        
        return cell
    }
    

    @IBAction func sendAction(_ sender: Any) {
        messageTextField.endEditing(true)
        messageTextField.isEnabled = false
        sendButton.isEnabled = false
        
        if messageTextField.text!.count > 15 {
            print("15文字以内で入力してください")
            return
        }
        
        let chatDB = Database.database().reference().child("chat")
        let messageInfo = [
            "sender": Auth.auth().currentUser?.email,
            "message": messageTextField.text
        ]
        
        chatDB.childByAutoId().setValue(messageInfo) { (error, result) in
            if error != nil {
                print(error)
            } else {
                print("送信完了")
                
                self.messageTextField.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextField.text = ""
            }
        }
    }
    
    //データを引っ張ってくる
    func fetchChatData() {
        //どこか引っ張ってくるか
        let fetchDataRef = Database.database().reference().child("chats")
        
        //新しく更新があったものだけ取得したい
        fetchDataRef.observe(.childAdded) { (snapShot) in
            let snapShotData = snapShot.value as AnyObject
            let text = snapShotData.value(forKey: "message")
            let sender = snapShotData.value(forKey: "sender")
            
            let message = Message()
            message.message = text as! String
            message.sender = sender as! String
            
            self.chatArray.append(message)
            //リロード
            self.tableView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
