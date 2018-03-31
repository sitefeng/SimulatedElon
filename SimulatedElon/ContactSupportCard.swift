//
//  ContactSupportCard.swift
//  SimulatedElon
//
//  Created by Si Te Feng on 3/24/18.
//  Copyright © 2018 Si Te Feng. All rights reserved.
//

import UIKit
import MessageUI

class ContactSupportCard: UIView, MFMailComposeViewControllerDelegate {
    
    weak var presentingVC: UIViewController?

    class func instanceFromNib() -> ContactSupportCard {
        return UINib(nibName: "ContactSupportCard", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ContactSupportCard
    }
    
    @IBAction func restoreButtonTapped(_ sender: Any) {
        
        
    }
    
    @IBAction func contactSupportButtonTapped(_ sender: Any) {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.setToRecipients(["technochimera@gmail.com"])
        composeVC.setSubject("I need help!")
        composeVC.setMessageBody("", isHTML: false)
        
        // Present the view controller modally.
        self.presentingVC?.present(composeVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) {
            if result != .sent {
                return
            }
            
            var title = "Message Sent!"
            var message = "We will get back to you as soon as possible"
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alertController.addAction(okayAction)
            self.presentingVC?.present(alertController, animated: true, completion: nil)
            
        }
        
    }
}
