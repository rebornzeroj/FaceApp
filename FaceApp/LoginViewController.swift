//
//  ViewController.swift
//  FaceApp
//
//  Created by Arco on 2018/5/6.
//  Copyright © 2018 c. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire

let brightBlue = UIColor(red: 0, green: 118/255, blue: 1, alpha: 0.5)
let brightGray = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)

class LoginViewController: UIViewController {

    weak var usernameTextView: UITextField!
    weak var passwordTextView: UITextField!
    weak var logoView: UIImageView!
    
    var username: String? {
        get {
            return usernameTextView.text
        }
    }
    var password: String? {
        get {
            return passwordTextView.text
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.white
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        let mainImageView = UIImageView(image: UIImage(named: "sjtuicon"))
        self.logoView = mainImageView
        
        let usernameTextField = UITextField()
        usernameTextField.borderStyle = .roundedRect
        usernameTextField.layer.borderWidth = 1
        usernameTextField.layer.cornerRadius = 10
        usernameTextField.layer.borderColor = brightGray.cgColor
        usernameTextField.attributedPlaceholder = NSAttributedString(string: "用户名")
        
        let passwordTextField = UITextField()
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.cornerRadius = 10
        passwordTextField.layer.borderColor = brightGray.cgColor
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "密码")
        
        let submitButton = UIButton()
        submitButton.setAttributedTitle(NSAttributedString(string: "提交"), for: .normal)
        submitButton.layer.borderWidth = 1
        submitButton.layer.cornerRadius = 10
        submitButton.layer.borderColor = brightGray.cgColor
        
        self.usernameTextView = usernameTextField
        self.passwordTextView = passwordTextField
        
        self.view.addSubview(mainImageView)
        self.view.addSubview(usernameTextField)
        self.view.addSubview(passwordTextField)
        self.view.addSubview(submitButton)
        
        mainImageView.snp.makeConstraints{ (make) -> Void in
            make.centerX.equalTo(self.view)
            make.top.equalTo(self.view).offset(72)
            make.width.equalTo(self.view).multipliedBy(0.5)
            make.height.equalTo(mainImageView.snp.width)
        }
        
        usernameTextField.snp.makeConstraints{ (make) -> Void in
            make.centerX.equalTo(self.view)
            make.top.equalTo(mainImageView.snp.bottom).offset(51)
            make.width.equalTo(self.view).multipliedBy(0.8)
            make.height.equalTo(44)
        }
        
        passwordTextField.snp.makeConstraints{ (make) -> Void in
            make.centerX.equalTo(self.view)
            make.top.equalTo(usernameTextField.snp.bottom).offset(20)
            make.width.equalTo(self.view).multipliedBy(0.8)
            make.height.equalTo(44)
        }
        
        submitButton.snp.makeConstraints{ (make) -> Void in
            make.centerX.equalTo(self.view)
            make.top.equalTo(passwordTextField.snp.bottom).offset(31)
            make.width.equalTo(120)
            make.height.equalTo(44)
        }
        
        submitButton.addTarget(self, action: #selector(loginToSjtu), for: .touchUpInside)
    }
    
    @objc func loginToSjtu(sender: UIButton){
//        if self.username?.trimmingCharacters(in: .whitespacesAndNewlines) == "sjtu" && self.password?.trimmingCharacters(in: .whitespacesAndNewlines) == "sjtu"{
//            let mainViewController = MainViewController()
//            self.present(mainViewController, animated: true)
//        }
//        else {
//            print("You have entered an invalid username or password")
//        }
        let mainViewController = MainViewController()
        self.navigationController?.pushViewController(mainViewController, animated: true)
        
//        uploadImg(img: UIImage(named: "Trigger")!)
    }

    func uploadImg(img: UIImage){
        
        let orgiFace = UIImagePNGRepresentation(img)!
        Alamofire.upload(orgiFace, to: "http://127.0.0.1:8000/demo/upload/").responseData { response in
            if let data = response.result.value {
                let newFace = UIImage(data: data)
                self.logoView.image = newFace
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

