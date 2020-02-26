//
//  LoginViewController.swift
//  ChatApp
//
//  Created by 中野勇貴 on 2020/02/24.
//  Copyright © 2020 Nakano Yuki. All rights reserved.
//

import UIKit
import Firebase
import Lottie

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    let animationView = AnimationView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

   
    }
    

  
    @IBAction func login(_ sender: Any) {
        //animationのスタート
        startAnimation()
        
        //loginの処理
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            if error != nil {
                print("エラーです")
            } else {
                print("ログイン成功")
                self.stopAnimation()
                self.performSegue(withIdentifier: "chat", sender: nil)
            }
        }
        
    }
    
    //アニメーションの再生を再生させて埋め込む
    func startAnimation() {
        //アニメーションの種類を設定
        let animation = Animation.named("loading")
        
        //animationが行われる位置を指定する
        animationView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height / 1.5)
        
        //設定した場所に任意のアニメーションを入れる
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        //ループの設定
        animationView.loopMode = .loop
        //アニメーションの再生
        animationView.play()
        //再生したものをviewに埋め込む
        view.addSubview(animationView)
        
    }
    
    //アニメーションをストップさせる
    func stopAnimation() {
        //animationViewをそままゴミ箱に捨てる
        animationView.removeFromSuperview()
    }
    
}
