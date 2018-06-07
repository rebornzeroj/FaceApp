//
//  ProcessViewController.swift
//  FaceApp
//
//  Created by Arco on 2018/5/13.
//  Copyright © 2018 c. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toast_Swift

protocol Expression
{
    func changeExpression(expression: String)
}

class ProcessViewController: UIViewController, UIScrollViewDelegate, UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, Expression {

    let api_key = "NeSGlSk3KBueWp-K6Cr18I_-MiuZ4l2u"
    let api_secret = "j22uKoQLiIw-5sazuu0lzCkYdNQEn_OQ"
    
    var scaleRect: CGRect?
    var faceImg: UIImage!
    var needHide: Bool!
    var expression: String?
    weak var faceView: UIImageView!
    weak var scrollView: UIScrollView!
    var collectionView: UICollectionView?
    var expressionImages: [String:UIImage] = [:]
    var confidences: [String: String] = [:]
    var images: [UIImage] = [UIImage(named: "neutral")!, UIImage(named: "happy")!, UIImage(named: "surprise")!,
                             UIImage(named: "sad")!, UIImage(named: "anger")!]
    var captions: [String] = ["neutral", "happy", "surprise", "sad", "anger"]
    var maskView: UIVisualEffectView!
    var loadingFlag = false
//    let host = "http://218.193.183.249:8888"
    let host = "http://192.168.3.191:8000"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.needHide = true

        let loadingBlurEffect = UIBlurEffect(style: .extraLight)
        self.maskView = UIVisualEffectView(effect: loadingBlurEffect)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.view.backgroundColor = UIColor.white
        
        if let scale = self.scaleRect {
            self.faceImg = self.faceImg.crop(rect: scale)
            self.faceImg = self.faceImg.imageWithImage(scaledToSize: CGSize(width: 128, height: 128))
            self.faceImg = self.faceImg.fixOrientation()
        }
        else {
            self.faceImg = self.faceImg.imageWithImage(scaledToSize: CGSize(width: 128, height: 128))
        }
        self.expressionImages["neutral"] = self.faceImg
        
        let imageView = UIImageView(image: faceImg)
        imageView.contentMode = .scaleAspectFit
        self.faceView = imageView

        let mainView = UIScrollView()
        mainView.delegate = self
        
        self.scrollView = mainView
        mainView.minimumZoomScale = 0.5;
        mainView.maximumZoomScale = 4.0;
        mainView.showsHorizontalScrollIndicator = false
        mainView.showsVerticalScrollIndicator = false
        
        mainView.addSubview(imageView)
        self.view.addSubview(mainView)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let selectionPanel = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        
        self.collectionView = selectionPanel
        
        selectionPanel.dataSource = self
        selectionPanel.delegate = self
        
        selectionPanel.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: "collectionViewCell")
        
        self.view.addSubview(selectionPanel)
        
        mainView.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(self.view)
            make.height.equalTo(self.view)
            make.center.equalTo(self.view)
        }
        
        let imageAspect =  self.faceImg.size.height / self.faceImg.size.width
        
        imageView.snp.makeConstraints { (make) -> Void in
            make.width.equalToSuperview().multipliedBy(1.0)
            make.height.equalTo(imageView.snp.width).multipliedBy(imageAspect)
        }

        selectionPanel.snp.makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(100)
        }
        
        let selectBtn = UIBarButtonItem(image: UIImage(named: "more"), style: .plain, target: self, action: #selector(moreAction))
        
        self.navigationItem.rightBarButtonItem = selectBtn
        
        selectionPanel.backgroundColor = UIColor.clear
        
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = selectionPanel.frame
        selectionPanel.backgroundView = blurEffectView
        
        mainView.isScrollEnabled = true
        
        self.view.addSubview(self.maskView)
        maskView.snp.makeConstraints { (make) in
            make.width.equalTo(self.view)
            make.height.equalTo(self.view)
        }
        
        self.maskView.isHidden = true
        
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let imageViewSize = self.faceView.frame.size
        let scrollViewSize = scrollView.bounds.size
        let verticalInset = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 5
        let horizontalInset = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 5
        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.faceView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func compareFace(faceOrg: UIImage, faceChanged: UIImage, expression: String) {
        let imageDataOrg = UIImagePNGRepresentation(faceOrg)!
        let encodeStringOrg = imageDataOrg.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
        let imageDataChanged = UIImagePNGRepresentation(faceChanged)!
        let encodeStringChanged = imageDataChanged.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
        let parameters: Parameters = [
            "api_key": api_key,
            "api_secret": api_secret,
            "image_base64_1": encodeStringOrg,
            "image_base64_2": encodeStringChanged
        ]
        Alamofire.request("https://api-cn.faceplusplus.com/facepp/v3/compare", method: .post, parameters: parameters)
//            .responseString { response in
//                print(response.result.value)
//            }
            .responseJSON { response in
                if response.data != nil {
                    do {
                        let json = try JSON(data: response.data!)
                        let rawConfidence = json["confidence"].rawString()
                        if rawConfidence != nil{
                            print(rawConfidence)
    //                        self.confidences[expression] = confidence
                            self.view.makeToast("confidence: \(rawConfidence!)")
    //                        self.navigationItem.title = confidence
                        }
                    }
                    catch {
                        print("json praser error")
                
                    }
                }
        }
    }
    
    @objc func moreAction(){
//        self.faceImg = self.faceImg?.crop(rect: CGRect(x: 0, y: 0, width: 50, height: 50))
//        self.faceView.image = self.faceImg
//        let tableViewController = TableViewController()
//        tableViewController.delegate = self
//        self.needHide = false
//        self.navigationItem.backBarButtonItem?.title = "Done"
//        self.navigationController?.pushViewController(tableViewController, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.needHide {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("\(expression ?? "no expression") is selected")
    }
    
    func changeExpression(expression: String) {
        self.expression = expression
    }
    
    func uploadImg(img: UIImage, expression: String){
        self.navigationItem.title = expression
        self.loadingFlag = true
        UIView.transition(with: self.maskView, duration: 1, options: .transitionCrossDissolve, animations: { self.maskView.isHidden = false }, completion: nil)
//        self.maskView.isHidden = false
        let orgiFace = UIImagePNGRepresentation(img)!
        Alamofire.upload(orgiFace, to: self.host + "/demo/\(expression)").responseData { response in
            if let data = response.result.value {
                let newFace = UIImage(data: data)
                self.expressionImages[expression] = newFace
                self.faceView!.image = newFace
                self.loadingFlag = false
//                    self.maskView.isHidden = true
                self.compareFace(faceOrg: self.faceImg, faceChanged: newFace!, expression: expression)
                UIView.transition(with: self.maskView, duration: 1, options: .transitionCrossDissolve, animations: { self.maskView.isHidden = true }, completion: nil)
            }
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.captions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! MyCollectionViewCell
        //        cell.backgroundColor = self.bgColor[indexPath.row]
        cell.imageView.image = self.images[indexPath.row]
        cell.labelView.text = self.captions[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //        return CGSize(width: self.view.frame.size.width * 0.3, height: self.view.frame.size.width * 0.4)
        return CGSize(width: 80, height: 75)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.loadingFlag {
            return
        }
        let expression = self.captions[indexPath.row]
        if let newFaceImg = self.expressionImages[expression] {
            if self.navigationItem.title == expression{
                uploadImg(img: self.faceImg, expression: expression)
            }
            self.faceView.image = newFaceImg
            self.navigationItem.title = expression
//            self.navigationItem.title = self.confidences[expression]
        } else {
            uploadImg(img: self.faceImg, expression: expression)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIImage {
    func fixOrientation() -> UIImage {
        if self.imageOrientation == UIImageOrientation.up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        } else {
            return self
        }
    }
    
    func imageWithImage(scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}
