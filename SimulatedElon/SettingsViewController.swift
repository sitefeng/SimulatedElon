//
//  SettingsViewController.swift
//  SimulatedElon
//
//  Created by Si Te Feng on 3/24/18.
//  Copyright © 2018 Si Te Feng. All rights reserved.
//

import UIKit
import PureLayout
import StoreKit
import Firebase

internal final class SettingsViewController: UIViewController, InAppPurchasesManagerDelegate {
    
    
    private let mainScrollView = UIScrollView()
    private var scrollContentView = UIView()
    
    let purchasesManager = InAppPurchasesManager.shared()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.mixpanel.track("settings_viewed")
        
        self.title = "Settings"
        
        NotificationCenter.default.addObserver(self, selector: #selector(inAppPurchasesManagerRestorePurchasesSuccess), name: InAppPurchasesManagerRestorePurchasesSuccessNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(inAppPurchasesManagerRestorePurchasesFail), name: InAppPurchasesManagerRestorePurchasesFailureNotification, object: nil)
        
        // Background view setup
        let backgroundImage = UIImageView(image: UIImage(named: "edgeBackground.jpg"))
        self.view.addSubview(backgroundImage)
        backgroundImage.autoPinEdgesToSuperviewEdges()
        
        let navItem = UIBarButtonItem(title: "Dismiss", style: .done, target: self, action: #selector(dismissButtonTapped))
        navItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.colorFromHex("4A9DB2")], for: .normal)
        self.navigationItem.leftBarButtonItem = navItem
        
        // SetupViews
        self.view.addSubview(mainScrollView)
        mainScrollView.backgroundColor = UIColor.clear
        
        var navBarHeight = CGFloat(44)
        if let barSize = self.navigationController?.navigationBar.frame.size {
            navBarHeight = barSize.height
        }
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        mainScrollView.autoPinEdge(toSuperviewEdge: .top, withInset: navBarHeight + statusBarHeight)
        mainScrollView.autoPinEdge(toSuperviewEdge: .left)
        mainScrollView.autoPinEdge(toSuperviewEdge: .right)
        mainScrollView.autoPinEdge(toSuperviewEdge: .bottom)
        
        // Add the rest of the dynamic UI interface
        self.reloadSubviews()
        
        // ********************************
        // Setup Logic
        purchasesManager.delegate = self
        purchasesManager.getProductPrices()
        
        let isPremium = purchasesManager.isPremium
        let isTrial = purchasesManager.isTrial
        
        // Remove premium user priviledge if not subscribed anymore
        if let userId = Auth.auth().currentUser?.uid {
            Database.database().reference(withPath: "users/\(userId)/premium").setValue(isPremium)
        }
        
        // Reload interface to account for user premium state change
        OperationQueue.main.addOperation {
            self.reloadSubviews()
        }
    }
    
    func reloadSubviews() {
        scrollContentView.removeFromSuperview()
        
        scrollContentView = UIView()
        scrollContentView.backgroundColor = UIColor.clear
        mainScrollView.addSubview(scrollContentView)
        scrollContentView.autoPinEdgesToSuperviewEdges()
        scrollContentView.autoMatch(.width, to: .width, of: view)
        
        var viewHeight = CGFloat(1400)
        if purchasesManager.isPremium {
            viewHeight = 700
        }
        scrollContentView.autoSetDimension(.height, toSize: viewHeight)
        
        let _ = "🛠⚙️🔬🚀"
        let upgradesLabel = UILabel()
        scrollContentView.addSubview(upgradesLabel)
        upgradesLabel.font = UIFont(name: "Futura-Medium", size: 26)
        upgradesLabel.textColor = UIColor.white
        upgradesLabel.text = "🛠 Upgrades"
        upgradesLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        upgradesLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        upgradesLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 30)
        
        let enhancedSimulation = EnhancedSimulationCard.instanceFromNib()
        let lifetime = LifetimeVIPCard.instanceFromNib()
        let premiumManagement = PremiumManagementCard.instanceFromNib()
        
        if purchasesManager.isPremium {
            scrollContentView.addSubview(premiumManagement)
            premiumManagement.presentingController = self
            premiumManagement.layer.borderColor = UIColor(red: 30, green: 30, blue: 30, alpha: 1).cgColor
            premiumManagement.layer.borderWidth = 4
            premiumManagement.layer.cornerRadius = 30
            premiumManagement.layer.masksToBounds = true
            premiumManagement.autoPinEdge(.top, to: .bottom, of: upgradesLabel, withOffset: 16)
            premiumManagement.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
            premiumManagement.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
            premiumManagement.autoSetDimension(.height, toSize: 200)
            
        } else {
            scrollContentView.addSubview(enhancedSimulation)
            enhancedSimulation.updateForLocalPrice(yearlyPriceString: purchasesManager.yearlyPriceString, yearlyConvertedMonthlyString: purchasesManager.yearlyConvertedMonthlyPriceString)
            enhancedSimulation.layer.borderColor = UIColor(red: 30, green: 30, blue: 30, alpha: 1).cgColor
            enhancedSimulation.layer.borderWidth = 4
            enhancedSimulation.layer.cornerRadius = 30
            enhancedSimulation.layer.masksToBounds = true
            enhancedSimulation.autoPinEdge(.top, to: .bottom, of: upgradesLabel, withOffset: 16)
            enhancedSimulation.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
            enhancedSimulation.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
            enhancedSimulation.autoSetDimension(.height, toSize: 363)
            
            let detailsLabel1 = UILabel()
            scrollContentView.addSubview(detailsLabel1)
            detailsLabel1.textColor = UIColor.white.withAlphaComponent(0.8)
            detailsLabel1.textAlignment = .center
            detailsLabel1.font = UIFont(name: "Futura-Medium", size: 10)
            detailsLabel1.numberOfLines = 10
            detailsLabel1.text = "Yearly subscription. Subscriptions may be managed by the user and auto-renewal may be turned off at any time by going to the user's Account Settings after purchase. Payment will be charged to to iTunes Account at confirmation of purchase. Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period. Account will be charged within 24-hours prior to the end of the current period, and identify the cost of the renewal. Any unused portion of a free trial period, if offered, will be forfeited when the user purchases a subscription to that publication, where applicable"
            detailsLabel1.autoPinEdge(toSuperviewEdge: .left, withInset: 32)
            detailsLabel1.autoPinEdge(toSuperviewEdge: .right, withInset: 32)
            detailsLabel1.autoPinEdge(.top, to: .bottom, of: enhancedSimulation, withOffset: 16)
            
            
            scrollContentView.addSubview(lifetime)
            lifetime.updateForLocalPrice(priceString: purchasesManager.lifetimePriceString)
            lifetime.layer.cornerRadius = 30
            lifetime.layer.masksToBounds = true
            lifetime.layer.borderColor = UIColor(red: 30, green: 30, blue: 30, alpha: 1).cgColor
            lifetime.layer.borderWidth = 4
            lifetime.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
            lifetime.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
            lifetime.autoPinEdge(.top, to: .bottom, of: detailsLabel1, withOffset: 32)
            lifetime.autoSetDimension(.height, toSize: 318)
            
            let detailsLabel2 = UILabel()
            scrollContentView.addSubview(detailsLabel2)
            detailsLabel2.textColor = UIColor.white.withAlphaComponent(0.8)
            detailsLabel2.textAlignment = .center
            detailsLabel2.font = UIFont(name: "Futura-Medium", size: 10)
            detailsLabel2.numberOfLines = 3
            detailsLabel2.text = "Payment will be charged to to iTunes Account at confirmation of purchase."
            detailsLabel2.autoPinEdge(toSuperviewEdge: .left, withInset: 32)
            detailsLabel2.autoPinEdge(toSuperviewEdge: .right, withInset: 32)
            detailsLabel2.autoPinEdge(.top, to: .bottom, of: lifetime, withOffset: 16)
        }
        
        let accountLabel = UILabel()
        scrollContentView.addSubview(accountLabel)
        accountLabel.font = UIFont(name: "Futura-Medium", size: 26)
        accountLabel.textColor = UIColor.white
        accountLabel.text = "⚙️ Account"
        accountLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        accountLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        if purchasesManager.isPremium {
            accountLabel.autoPinEdge(.top, to: .bottom, of: premiumManagement, withOffset: 30)
        } else {
            accountLabel.autoPinEdge(.top, to: .bottom, of: lifetime, withOffset: 60)
        }
        
        let contactSupport = ContactSupportCard.instanceFromNib()
        scrollContentView.addSubview(contactSupport)
        let shouldPromptSignIn = Auth.auth().currentUser?.uid == nil
        contactSupport.updateButtonStates(isSignIn: shouldPromptSignIn, isPremium: purchasesManager.isPremium)
        
        contactSupport.presentingVC = self
        contactSupport.layer.cornerRadius = 30
        contactSupport.layer.masksToBounds = true
        contactSupport.layer.borderColor = UIColor(red: 30, green: 30, blue: 30, alpha: 1).cgColor
        contactSupport.layer.borderWidth = 4
        contactSupport.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        contactSupport.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        contactSupport.autoPinEdge(.top, to: .bottom, of: accountLabel, withOffset: 16)
        contactSupport.autoSetDimension(.height, toSize: 251)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    @objc func dismissButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: inAppPurchasesManagerDelegate
    func inAppPurchasesManager(manager: InAppPurchasesManager, didEnablePlanOfType type: PremiumPlanType) {
        print("Enabled plan: \(type.rawValue)")
        if Auth.auth().currentUser?.uid != nil {
            let alertController = UIAlertController(title: "Upgrade Successful", message: "Premium features are now enabled", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alertController.addAction(okayAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            let premiumOnboardVC = PremiumOnboardingViewController(nibName: nil, bundle: nil)
            self.navigationController?.pushViewController(premiumOnboardVC, animated: true)
        }
        
    }
    
    func inAppPurchasesManagerTransactionDidFail(manager: InAppPurchasesManager) {
        let alertController = UIAlertController(title: "Upgrade Unsuccessful", message: "Premium features are not enabled", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertController.addAction(okayAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func inAppPurchasesManager(manager: InAppPurchasesManager, didGetYearlyPrice yearlyPrice: String, lifetimePrice: String) {
        OperationQueue.main.addOperation {
            self.reloadSubviews()
        }
    }
    
    // inAppPurchasesManager Restore Notification
    @objc func inAppPurchasesManagerRestorePurchasesSuccess() {
        let alertController = UIAlertController(title: "Restore Purchase Successful", message: "Premium features are now enabled", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertController.addAction(okayAction)
        self.present(alertController, animated: true) {
            OperationQueue.main.addOperation {
                self.reloadSubviews()
            }
        }
    }
    
    @objc func inAppPurchasesManagerRestorePurchasesFail(notification: NSNotification) {
        var reasonString = ""
        if let userInfo = notification.userInfo, let reason = userInfo["reason"] as? String {
            reasonString = reason
        }
        let alertController = UIAlertController(title: "Restore Purchase Unsuccessful", message: "Premium features are not enabled. \(reasonString)", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertController.addAction(okayAction)
        self.present(alertController, animated: true) {
            OperationQueue.main.addOperation {
                self.reloadSubviews()
            }
        }
    }
    
}
