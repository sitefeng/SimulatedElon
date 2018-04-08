//
//  QuestionTableViewCellHeader.swift
//  SimulatedElon
//
//  Created by Si Te Feng on 4/8/18.
//  Copyright © 2018 Si Te Feng. All rights reserved.
//

import UIKit
import PureLayout

class QuestionTableViewCellHeader: UITableViewHeaderFooterView {
    
    let titleLabel = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.addSubview(titleLabel)
        titleLabel.font = UIFont(name: "Futura-Medium", size: 26)
//        titleLabel.textColor = UIColor.colorFromHex("#224853")
        titleLabel.textColor = UIColor.white
        titleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 32)
        titleLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 32)
        titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 16)
        titleLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
   
    static func heightRequired() -> CGFloat {
        return CGFloat(70)
    }

}
