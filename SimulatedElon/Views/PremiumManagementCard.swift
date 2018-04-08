//
//  PremiumManagementCard.swift
//  SimulatedElon
//
//  Created by Si Te Feng on 4/1/18.
//  Copyright © 2018 Si Te Feng. All rights reserved.
//

import UIKit
import Firebase
import PureLayout

class PremiumManagementCard: UIView {
    
    weak var presentingController: UIViewController?

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var smsEnabledSwitch: UISwitch!
    
    class func instanceFromNib() -> PremiumManagementCard {
        let mainView = UINib(nibName: "PremiumManagementCard", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! PremiumManagementCard
        
        if Auth.auth().currentUser?.uid == nil {
            let coverView = UIView()
            let tapRec = UITapGestureRecognizer(target: mainView, action: #selector(PremiumManagementCard.signInBackgroundTapped))
            coverView.addGestureRecognizer(tapRec)
            coverView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            mainView.addSubview(coverView)
            coverView.autoPinEdgesToSuperviewEdges()
            
            let label = UILabel()
            label.text = "Please sign in first to access controls"
            label.textAlignment = .center
            label.textColor = UIColor.white
            mainView.addSubview(label)
            label.autoAlignAxis(toSuperviewAxis: .horizontal)
            label.autoAlignAxis(toSuperviewAxis: .vertical)
        }
        
        return mainView
    }
    
    @objc func signInBackgroundTapped() {
        let loginVC = LoginViewController(nibName: nil, bundle: nil)
        presentingController?.navigationController?.pushViewController(loginVC, animated: true)
    }

    @IBAction func smsEnabledSwitchToggled(_ sender: UISwitch, forEvent event: UIEvent) {
        
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        Database.database().reference(withPath: "users").child(userId).child("smsEnabled").setValue(sender.isOn)
    }
    
}
