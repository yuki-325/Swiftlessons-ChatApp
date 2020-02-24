//
//  RegisterViewController.swift
//  ChatApp
//
//  Created by 中野勇貴 on 2020/02/24.
//  Copyright © 2020 Nakano Yuki. All rights reserved.
//

import UIKit
import Firebase
import Lottie

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    let animationView = AnimationView()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    //Firebaseにユーザを新規登録する
    @IBAction func registerNewUser(_ sender: Any) {
   
        //アニメーションのスタート
        
        //新規登録処理
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            
            if error != nil {
                print(error as Any)
            } else {
                print("ユーザの作成が成功しました")
                
                //アニメーションのストップ
                
                //画面をチャット画面に遷移させる
                
            }
        }
    }
    
    func startAnimation() {
        //アニメーションの種類を設定
        let animation = Animation.named("Loading")
        
        //animationが行われる位置を指定する
        animationView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height / 1.5)
        
        //設定した場所に任意のアニメーションを入れる
        animationView.animation = animation
        
    }
    
    
}
