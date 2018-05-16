//
//  ProcessViewController.swift
//  FaceApp
//
//  Created by Arco on 2018/5/13.
//  Copyright © 2018 c. All rights reserved.
//

import UIKit
import Alamofire

protocol Expression
{
    func changeExpression(expression: String)
}

class ProcessViewController: UIViewController, UIScrollViewDelegate, UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, Expression {

    var faceImg: UIImage?
    var needHide: Bool!
    var expression: String?
    weak var faceView: UIImageView!
    weak var scrollView: UIScrollView!
    var collectionView: UICollectionView?
    var images: [UIImage] = [UIImage(named: "neutral")!, UIImage(named: "happy")!, UIImage(named: "surprise")!,
                             UIImage(named: "sad")!, UIImage(named: "anger")!, UIImage(named: "fear")!, UIImage(named: "disgust")!]
    var captions: [String] = ["neutral", "happy", "surprise", "sad", "anger", "fear", "disgust"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.needHide = true
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.view.backgroundColor = UIColor.white
        
        let imageView = UIImageView(image: faceImg)
        imageView.contentMode = .scaleAspectFit
        self.faceView = imageView

        let mainView = UIScrollView()
        mainView.delegate = self
        
        self.scrollView = mainView
        mainView.minimumZoomScale=0.5;
        mainView.maximumZoomScale=6.0;
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
        
        imageView.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(mainView)
            make.height.equalTo(mainView)
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
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let imageViewSize = self.faceView.frame.size
        let scrollViewSize = scrollView.bounds.size
        let verticalInset = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalInset = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.faceView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func moreAction(){
        let tableViewController = TableViewController()
        tableViewController.delegate = self
        self.needHide = false
        self.navigationItem.backBarButtonItem?.title = "Done"
        self.navigationController?.pushViewController(tableViewController, animated: true)
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
    
    func uploadImg(img: UIImage){
        
        let orgiFace = UIImagePNGRepresentation(img)!
        Alamofire.upload(orgiFace, to: "http://127.0.0.1:8000/demo/upload/").responseData { response in
            if let data = response.result.value {
                let newFace = UIImage(data: data)
                self.faceView!.image = newFace
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
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
        print(self.captions[indexPath.row])
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
