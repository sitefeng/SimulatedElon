//
//  QuestionTableViewCell.swift
//  SimulatedElon
//
//  Created by Si Te Feng on 4/8/18.
//  Copyright © 2018 Si Te Feng. All rights reserved.
//

import UIKit

class QuestionTableViewCell: UITableViewCell {

    @IBOutlet weak var questionIcon: UIImageView!
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.backgroundView?.backgroundColor = UIColor.clear
        self.containerView.backgroundColor = UIColor.clear
        
        self.selectionStyle = .none
        
        questionLabel.text = ""
        
        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = 20
        containerView.layer.masksToBounds = true
    }

    static func heightRequired() -> CGFloat {
        return CGFloat(80)
    }
    
}
