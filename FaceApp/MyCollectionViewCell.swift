//
//  MyCollectionViewCell.swift
//  FaceApp
//
//  Created by Arco on 2018/5/15.
//  Copyright © 2018 c. All rights reserved.
//

import UIKit
import SnapKit

class MyCollectionViewCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    var labelView: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        self.backgroundColor = UIColor.white
        
        let topView = UIImageView()
        let bottomView = UILabel()
        
        self.imageView = topView
        self.labelView = bottomView
        self.labelView?.textAlignment = .center
        
        self.contentView.addSubview(topView)
        self.contentView.addSubview(bottomView)
        
        topView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.contentView)
            make.centerX.equalTo(self.contentView)
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        
        bottomView.snp.makeConstraints { (make) -> Void in
//            make.top.equalTo(topView)
            make.bottom.equalTo(self.contentView)
            make.width.equalTo(self.contentView)
            make.height.equalTo(20)
        }
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
}
