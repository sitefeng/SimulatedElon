//
//  ContactSupportCard.swift
//  SimulatedElon
//
//  Created by Si Te Feng on 3/24/18.
//  Copyright © 2018 Si Te Feng. All rights reserved.
//

import UIKit
import MessageUI
import Firebase

class ContactSupportCard: UIView, MFMailComposeViewControllerDelegate {
    
    weak var presentingVC: UIViewController?

    @IBOutlet weak var restorePurchasesButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    class func instanceFromNib() -> ContactSupportCard {
        return UINib(nibName: "ContactSupportCard", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ContactSupportCard
    }
    
    func updateButtonStates(isSignIn: Bool, isPremium: Bool) {
        if isSignIn {
            signInButton.setTitle("Sign In", for: .normal)
        } else {
            signInButton.setTitle("Sign Out", for: .normal)
        }
        
        if isPremium {
            restorePurchasesButton.setTitle("Manage Subscription", for: .normal)
        } else {
            restorePurchasesButton.setTitle("Restore Purchase", for: .normal)
        }
        
    }
    
    @IBAction func restoreButtonTapped(_ sender: Any) {
        
        if restorePurchasesButton.titleLabel?.text == "Manage Subscription" {
            let manageURLString = "https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions"
            if let manageURL = URL(string: manageURLString) {
                UIApplication.shared.open(manageURL, options: [:], completionHandler: nil)
            }
        } else {
            // Restore purchase
            let purchasesManager = InAppPurchasesManager.shared()
            purchasesManager.restorePurchases()
        }
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        if signInButton.titleLabel?.text == "Sign In" {
            let loginVC = LoginViewController(nibName: nil, bundle: nil)
            self.presentingVC?.navigationController?.pushViewController(loginVC, animated: true)
        } else {
            try? Auth.auth().signOut()
            let alertController = UIAlertController(title: "Signed Out", message:"You have signed out", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alertController.addAction(okayAction)
            self.presentingVC?.dismiss(animated: true, completion: {
                let appDelegate  = UIApplication.shared.delegate as! AppDelegate
                let rootViewController = appDelegate.window!.rootViewController
                rootViewController?.present(alertController, animated: true, completion: nil)
            })
        }
    }
    
    @IBAction func contactSupportButtonTapped(_ sender: Any) {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self

        // Configure the fields of the interface.
        composeVC.setToRecipients(["technochimera@gmail.com"])
        composeVC.setSubject("Simulated Elon Support")
        if let userId = Auth.auth().currentUser?.uid {
            composeVC.setMessageBody("Your UserID is [\(userId)] (Please keep, We use this ID in order to support you better)", isHTML: false)
        } else {
            composeVC.setMessageBody("", isHTML: false)
        }

        // Present the view controller modally.
        self.presentingVC?.present(composeVC, animated: true, completion: nil)
        
        // TO TEST REGISTRATION FLOW
//        let premiumOnboardVC = PremiumOnboardingViewController(nibName: nil, bundle: nil)
//        self.presentingVC?.navigationController?.pushViewController(premiumOnboardVC, animated: true)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) {
            if result != .sent {
                return
            }
            
            let title = "Message Sent!"
            let message = "We will get back to you as soon as possible"
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alertController.addAction(okayAction)
            self.presentingVC?.present(alertController, animated: true, completion: nil)
            
        }
        
    }
}
