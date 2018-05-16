//
//  HorizontalViewController.swift
//  FaceApp
//
//  Created by Arco on 2018/5/15.
//  Copyright © 2018 c. All rights reserved.
//

import UIKit

class HorizontalViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    var collectionView: UICollectionView?
    var bgColor: [UIColor] = [UIColor.green, UIColor.black, UIColor.yellow]
    var images: [UIImage] = [UIImage(named: "neutral")!, UIImage(named: "happy")!, UIImage(named: "surprise")!,
                             UIImage(named: "sad")!, UIImage(named: "anger")!, UIImage(named: "fear")!, UIImage(named: "disgust")!]
    var captions: [String] = ["neutral", "happy", "surprise", "sad", "anger", "fear", "disgust"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let bottomView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        bottomView.backgroundColor = UIColor.clear
        self.collectionView = bottomView
    
        bottomView.collectionViewLayout = layout
        bottomView.dataSource = self
        bottomView.delegate = self
        
        bottomView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: "collectionViewCell")

        self.view.addSubview(bottomView)
        bottomView.snp.makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(80)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        return CGSize(width: 80, height: 80)
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
