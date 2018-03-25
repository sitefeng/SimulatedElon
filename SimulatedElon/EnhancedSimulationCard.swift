//
//  EnhancedSimulationCard.swift
//  SimulatedElon
//
//  Created by Si Te Feng on 3/24/18.
//  Copyright © 2018 Si Te Feng. All rights reserved.
//

import UIKit

class EnhancedSimulationCard: UIView {

    class func instanceFromNib() -> UIView {
        return UINib(nibName: "EnhancedSimulationCard", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

}
