//
//  SettingsViewController.swift
//  SimulatedElon
//
//  Created by Si Te Feng on 3/24/18.
//  Copyright © 2018 Si Te Feng. All rights reserved.
//

import UIKit
import PureLayout

class SettingsViewController: UIViewController {
    
    let mainScrollView = UIScrollView()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        //        UIColor(red: 210, green: 248, blue: 255, alpha: 1)
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "blueBackground.jpg")!)
        
        let navItem = UIBarButtonItem(title: "Dismiss", style: .done, target: self, action: #selector(dismissButtonTapped))
        self.navigationItem.leftBarButtonItem = navItem
        
        self.view.addSubview(mainScrollView)
        mainScrollView.backgroundColor = UIColor.clear
        mainScrollView.autoPinEdgesToSuperviewEdges()
        
        let scrollContentView = UIView()

        scrollContentView.backgroundColor = UIColor.clear
        mainScrollView.addSubview(scrollContentView)
        scrollContentView.autoPinEdgesToSuperviewEdges()
        scrollContentView.autoMatch(.width, to: .width, of: view)
        scrollContentView.autoSetDimension(.height, toSize: 900)
        
        let enhancedSimulation = EnhancedSimulationCard.instanceFromNib()
        scrollContentView.addSubview(enhancedSimulation)
        enhancedSimulation.layer.cornerRadius = 30
        enhancedSimulation.layer.masksToBounds = true
        enhancedSimulation.autoPinEdge(toSuperviewEdge: .top, withInset: 16)
        enhancedSimulation.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        enhancedSimulation.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        enhancedSimulation.autoSetDimension(.height, toSize: 323)
        
        let lifetime = LifetimeVIPCard.instanceFromNib()
        scrollContentView.addSubview(lifetime)
        lifetime.layer.cornerRadius = 30
        lifetime.layer.masksToBounds = true
        lifetime.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        lifetime.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        lifetime.autoPinEdge(.top, to: .bottom, of: enhancedSimulation, withOffset: 16)
        lifetime.autoSetDimension(.height, toSize: 278)
        
        let contactSupport = ContactSupportCard.instanceFromNib()
        scrollContentView.addSubview(contactSupport)
        contactSupport.layer.cornerRadius = 30
        contactSupport.layer.masksToBounds = true
        contactSupport.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        contactSupport.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        contactSupport.autoPinEdge(.top, to: .bottom, of: lifetime, withOffset: 16)
        contactSupport.autoSetDimension(.height, toSize: 160)
        
        
    }
    
    @objc func dismissButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}
