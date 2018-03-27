//
//  EnhancedSimulationCard.swift
//  SimulatedElon
//
//  Created by Si Te Feng on 3/24/18.
//  Copyright © 2018 Si Te Feng. All rights reserved.
//

import UIKit

class EnhancedSimulationCard: UIView {

    @IBOutlet weak var priceLabel: UILabel!
    
    class func instanceFromNib() -> EnhancedSimulationCard {
        return UINib(nibName: "EnhancedSimulationCard", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! EnhancedSimulationCard
    }
    
    @IBAction func purchaseButtonTapped(_ sender: Any) {
        InAppPurchasesManager.shared().purchaseYearly()
    }
    
}
