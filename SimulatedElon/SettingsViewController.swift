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

class SettingsViewController: UIViewController, InAppPurchasesManagerDelegate {
    
    let mainScrollView = UIScrollView()
    let purchasesManager = InAppPurchasesManager.shared()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        
        let backgroundImage = UIImageView(image: UIImage(named: "edgeBackground.jpg"))
        self.view.addSubview(backgroundImage)
        backgroundImage.autoPinEdgesToSuperviewEdges()
        
        let navItem = UIBarButtonItem(title: "Dismiss", style: .done, target: self, action: #selector(dismissButtonTapped))
        navItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.colorFromHex("4A9DB2")], for: .normal)
        self.navigationItem.leftBarButtonItem = navItem
        
        // Logic
        purchasesManager.delegate = self
        purchasesManager.getProducts()
        
        
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
        
        let scrollContentView = UIView()

        scrollContentView.backgroundColor = UIColor.clear
        mainScrollView.addSubview(scrollContentView)
        scrollContentView.autoPinEdgesToSuperviewEdges()
        scrollContentView.autoMatch(.width, to: .width, of: view)
        scrollContentView.autoSetDimension(.height, toSize: 1200)
        
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
        scrollContentView.addSubview(enhancedSimulation)
        enhancedSimulation.layer.borderColor = UIColor(red: 30, green: 30, blue: 30, alpha: 1).cgColor
        enhancedSimulation.layer.borderWidth = 4
        enhancedSimulation.layer.cornerRadius = 30
        enhancedSimulation.layer.masksToBounds = true
        enhancedSimulation.autoPinEdge(.top, to: .bottom, of: upgradesLabel, withOffset: 16)
        enhancedSimulation.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        enhancedSimulation.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        enhancedSimulation.autoSetDimension(.height, toSize: 343)
        
        let lifetime = LifetimeVIPCard.instanceFromNib()
        scrollContentView.addSubview(lifetime)
        lifetime.layer.cornerRadius = 30
        lifetime.layer.masksToBounds = true
        lifetime.layer.borderColor = UIColor(red: 30, green: 30, blue: 30, alpha: 1).cgColor
        lifetime.layer.borderWidth = 4
        lifetime.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        lifetime.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        lifetime.autoPinEdge(.top, to: .bottom, of: enhancedSimulation, withOffset: 16)
        lifetime.autoSetDimension(.height, toSize: 298)
        
        let accountLabel = UILabel()
        scrollContentView.addSubview(accountLabel)
        accountLabel.font = UIFont(name: "Futura-Medium", size: 26)
        accountLabel.textColor = UIColor.white
        accountLabel.text = "⚙️ Account"
        accountLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        accountLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        accountLabel.autoPinEdge(.top, to: .bottom, of: lifetime, withOffset: 30)
        
        let contactSupport = ContactSupportCard.instanceFromNib()
        scrollContentView.addSubview(contactSupport)
        contactSupport.presentingVC = self
        contactSupport.layer.cornerRadius = 30
        contactSupport.layer.masksToBounds = true
        contactSupport.layer.borderColor = UIColor(red: 30, green: 30, blue: 30, alpha: 1).cgColor
        contactSupport.layer.borderWidth = 4
        contactSupport.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        contactSupport.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        contactSupport.autoPinEdge(.top, to: .bottom, of: accountLabel, withOffset: 16)
        contactSupport.autoSetDimension(.height, toSize: 251)
        
        
        // Setup Logic
        purchasesManager.verifySubscription { (success, value) in
            print("Was success? \(success), value: \(value)")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        
    }
    
    @objc func dismissButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: inAppPurchasesManagerDelegate
    func inAppPurchasesManager(manager: InAppPurchasesManager, didEnablePlanOfType type: PremiumPlanType) {
        print("did enable plan of type \(type.rawValue)")
        
        let premiumOnboardVC = PremiumOnboardingViewController(nibName: nil, bundle: nil)
        self.navigationController?.pushViewController(premiumOnboardVC, animated: true)
    }
    
    func inAppPurchasesManagerTransactionDidFail(manager: InAppPurchasesManager) {
//        let alertController = UIAlertController(title: "Purchases Unsuccessful", message: "Upgrade was not enabled", preferredStyle: .alert)
//        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
//        alertController.addAction(okayAction)
//        self.present(alertController, animated: true, completion: nil)
        
        let premiumOnboardVC = PremiumOnboardingViewController(nibName: nil, bundle: nil)
        self.navigationController?.pushViewController(premiumOnboardVC, animated: true)
    }
}
