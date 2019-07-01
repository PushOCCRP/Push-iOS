//
//  ArticleTableViewHelper.swift
//  Push
//
//  Created by Christopher Guess on 4/8/19.
//  Copyright © 2019 OCCRP. All rights reserved.
//

import UIKit
import Masonry

class ArticleTableViewHelper: UIView {

    var categoryName : String?
    
    private let categoryNameLabel = UILabel()
    
    init(top: Bool) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.addViewsWithTop(top: top)
    }
    
    private func addViewsWithTop(top: Bool) {
//        self.backgroundColor = [UIColor whiteColor];
        self.backgroundColor = UIColor.white
        
//        self.categoryNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        
        self.categoryNameLabel.font = UIFont(name: "AmericanTypewriter", size: 16.0)
//        self.categoryNameLabel.font = [UIFont fontWithName:@"AmericanTypewriter" size:16.0f];
        self.categoryNameLabel.textColor = UIColor.darkText
//        self.categoryNameLabel.textColor = [UIColor darkTextColor];
        let topView = SectionSplit.init(top: top)!
//        UIView * topView = [[SectionSplit alloc] initWithTop:top];
        let horizontalRuleBottom = HorizontalRule()
//        UIView * horizontalRuleBottom = [[HorizontalRule alloc] init];
//
        self.addSubview(topView)
//        [self addSubview:topView];
        self.addSubview(self.categoryNameLabel)
//        [self addSubview:self.categoryNameLabel];
        self.addSubview(horizontalRuleBottom)
//        [self addSubview:horizontalRuleBottom];
//
  
        //TODO: Import Masonry's swift version too
//        topView.mas_makeConstraints { (make) in
//            make.top.
//        }
//        [topView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self);
//        make.left.equalTo(self);
//        make.right.equalTo(self);
//        if(top){
//        make.height.equalTo(@1);
//        } else {
//        make.height.equalTo(@5 );
//        }
//        }];
//
//        [self.categoryNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(topView.mas_bottom).offset(8.0f);
//        make.left.equalTo(self.mas_leftMargin).offset(20.0f);
//        make.right.equalTo(self.mas_rightMargin).offset(20.0f);
//        }];
//
//        [horizontalRuleBottom mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.categoryNameLabel.mas_bottom).offset(5.0f);
//        make.left.equalTo(self).offset(15.0f);
//        make.right.equalTo(self).offset(-15.0f);
//        make.height.equalTo(@1);
//        make.bottom.equalTo(self).offset(-10.0f);
//        }];
        

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
