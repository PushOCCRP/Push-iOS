//
//  SectionSplitNew.swift
//  Push
//
//  Created by Christopher Guess on 6/30/19.
//  Copyright © 2019 OCCRP. All rights reserved.
//

import UIKit
import SnapKit

@objc class SectionSplitNew: UIView {
    
    @objc init(top: Bool) {
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        
        if(top) {
            self.addShadow()
        } else {
            self.addBottomLine()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addShadow() {
        let darkLineTop = UIView()
        darkLineTop.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        
        self.addSubview(darkLineTop)
        
        darkLineTop.snp_makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(1)
        }
        
        self.addBottomLine()
    }
    
    func addBottomLine() {
        let darkLineBottom = UIView()
        darkLineBottom.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        
        self.addSubview(darkLineBottom)
        darkLineBottom.snp_makeConstraints { (make) in
            make.bottom.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(1)
        }
    }
}
