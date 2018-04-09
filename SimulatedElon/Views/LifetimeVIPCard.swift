//
//  lifetimeVIPCard.swift
//  SimulatedElon
//
//  Created by Si Te Feng on 3/24/18.
//  Copyright © 2018 Si Te Feng. All rights reserved.
//

import UIKit

class LifetimeVIPCard: UIView {

    @IBOutlet weak var priceLabel: UILabel!
    
    class func instanceFromNib() -> LifetimeVIPCard {
        return UINib(nibName: "LifetimeVIPCard", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! LifetimeVIPCard
    }
    
    func updateForLocalPrice(priceString: String) {
        priceLabel.text = "One time payment of \(priceString)"
    }
    
    
    @IBAction func purchaseButtonTapped(_ sender: Any) {
        InAppPurchasesManager.shared().purchaseLifetime()
    }
    
}
