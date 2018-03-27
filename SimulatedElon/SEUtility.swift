//
//  SEUtility.swift
//  SimulatedElon
//
//  Created by Si Te Feng on 3/22/18.
//  Copyright © 2018 Si Te Feng. All rights reserved.
//

import UIKit

class SEUtility: NSObject {
    
    class func isiPhoneX() -> Bool {
        var isiPhoneX = false
        if UIDevice.current.userInterfaceIdiom == .phone {
            let screenSize = UIScreen.main.bounds.size
            if screenSize.height == 812 {
                isiPhoneX = true
            }
        }
        return isiPhoneX
    }
    
}

