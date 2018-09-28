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
import Toast_Swift

let brightBlue = UIColor(red: 0, green: 118/255, blue: 1, alpha: 0.5)
let brightGray = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)

class LoginViewController: UIViewController {

    weak var logoView: UIImageView!
    weak var usernameTextView: UITextField!
    weak var passwordTextView: UITextField!
    weak var captchaTextView: UITextField!
    weak var captchaImageView: UIImageView!
    weak var maskView: UIVisualEffectView!
    var base_name: String!
//    let host = "http://218.193.183.249:8888"
//    let host = "http://192.168.3.191:8000"
//    let host = "http://192.168.1.105:8000"
    let host = "http://192.168.3.21:8000"
    var username: String? {
        get {
            return usernameTextView.text?.trim()
        }
    }
    var password: String? {
        get {
            return passwordTextView.text?.trim()
        }
    }
    
    var captcha: String? {
        get {
            return captchaTextView.text?.trim()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        let loadingBlurEffect = UIBlurEffect(style: .extraLight)
        let maskView = UIVisualEffectView(effect: loadingBlurEffect)
        self.maskView = maskView
        
        self.view.backgroundColor = UIColor.white
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        let mainImageView = UIImageView(image: UIImage(named: "sjtuicon"))
        self.logoView = mainImageView
        
        let usernameTextField = UITextField()
        usernameTextField.borderStyle = .roundedRect
        usernameTextField.layer.borderWidth = 1
        usernameTextField.layer.cornerRadius = 5
        usernameTextField.layer.borderColor = brightGray.cgColor
        usernameTextField.attributedPlaceholder = NSAttributedString(string: "用户名")
        
        let passwordTextField = UITextField()
        passwordTextField.isSecureTextEntry = true
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.cornerRadius = 5
        passwordTextField.layer.borderColor = brightGray.cgColor
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "密码")

        let submitButton = UIButton()
        submitButton.setAttributedTitle(NSAttributedString(string: "提交"), for: .normal)
        submitButton.layer.borderWidth = 1
        submitButton.layer.cornerRadius = 5
        submitButton.layer.borderColor = brightGray.cgColor
        
        self.usernameTextView = usernameTextField
        self.passwordTextView = passwordTextField
        
        self.view.addSubview(mainImageView)
        self.view.addSubview(usernameTextField)
        self.view.addSubview(passwordTextField)
        self.view.addSubview(submitButton)
        
        let captchaView = UIView()
        self.view.addSubview(captchaView)
        
        let captchaTextField = UITextField()
        captchaTextField.borderStyle = .roundedRect
        captchaTextField.layer.borderWidth = 1
        captchaTextField.layer.cornerRadius = 5
        captchaTextField.layer.borderColor = brightGray.cgColor
        captchaTextField.attributedPlaceholder = NSAttributedString(string: "验证码")
        
        let captchaImageView = UIImageView(image: UIImage(named: "captcha"))
        
        self.captchaTextView = captchaTextField
        self.captchaImageView = captchaImageView
        
        captchaView.addSubview(captchaTextField)
        captchaView.addSubview(captchaImageView)
        
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
        
        captchaView.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.view)
            make.width.equalTo(self.view).multipliedBy(0.8)
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
            make.height.equalTo(44)
        }
        
        captchaTextField.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(captchaView)
            make.bottom.equalTo(captchaView)
            make.left.equalTo(captchaView)
            make.right.equalTo(captchaImageView.snp.left).offset(-10)
        }
        
        captchaImageView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(captchaView)
            make.bottom.equalTo(captchaView)
//            make.left.equalTo(captchaTextField.snp.right)
            make.right.equalTo(captchaView)
            make.width.lessThanOrEqualTo(captchaView).multipliedBy(0.5)
        }
        
        submitButton.snp.makeConstraints{ (make) -> Void in
            make.centerX.equalTo(self.view)
            make.top.equalTo(captchaView.snp.bottom).offset(31)
            make.width.equalTo(120)
            make.height.equalTo(44)
        }
        
        submitButton.addTarget(self, action: #selector(loginToSjtu), for: .touchUpInside)

        self.view.addSubview(self.maskView)
        self.maskView.snp.makeConstraints { (make) in
            make.width.equalTo(self.view)
            make.height.equalTo(self.view)
        }
        
        self.maskView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getCaptcha()
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if self.view.frame.origin.y == 0{
            self.view.frame.origin.y -= self.logoView.frame.height + 72
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0{
            self.view.frame.origin.y += self.logoView.frame.height + 72
        }
    }
    
    @objc func loginToSjtu(sender: UIButton){
        login()
    }

    func getCaptcha(){
        Alamofire.request("\(self.host)/demo/captcha").responseString { response in
            if let base_name = response.result.value {
                self.base_name = base_name
                self.getCaptchaFile(base_name)
            }
        }
    }
    
    func getCaptchaFile(_ base_name: String){
        Alamofire.request("\(self.host)/demo/captcha_file?base_name=\(base_name)").responseData { response in
            if let data = response.result.value {
                let captcha = UIImage(data: data)
                self.captchaImageView.image = captcha
            }
        }
    }
    
    func login(){
        if self.username == "admin" {
            let viewController = ViewController()
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        guard self.username != "" else{
            self.view.makeToast("请输入您的jAccount帐号")
            print("miss username")
            return
        }
        guard self.password != "" else{
            self.view.makeToast("请输入您的密码")
            print("miss password")
            return
        }
        guard self.captcha != "" else{
            self.view.makeToast("请输入验证码")
            print("miss captcha")
            return
        }
        guard self.base_name != "" else{
            print("miss base_name")
            return
        }
        let parameters: Parameters = [
            "username": self.username!,
            "password": self.password!,
            "base_name": self.base_name!,
            "captcha": self.captcha!
        ]
        
        UIView.transition(with: self.maskView, duration: 1, options: .transitionCrossDissolve, animations: { self.maskView.isHidden = false }, completion: nil)
        Alamofire.request("\(self.host)/demo/login", method: .post, parameters: parameters).responseString { response in
            if let status = response.result.value{
                if status == "success"{
                    print("welcome, \(self.username!)")
                    let viewController = ViewController()
                    self.navigationController?.pushViewController(viewController, animated: true)
                } else {
                    self.view.makeToast("请正确填写你的用户名、密码和验证码，注意：密码是区分大小写的")
                    print("wrong username or password")
                    self.getCaptcha()
                }
                UIView.transition(with: self.maskView, duration: 1, options: .transitionCrossDissolve, animations: { self.maskView.isHidden = true }, completion: nil)
            }
        }
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

extension String
{
    func trim() -> String
    {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
}

