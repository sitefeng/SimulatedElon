//
//  QuestionViewController.swift
//  SimulatedElon
//
//  Created by Si Te Feng on 3/24/18.
//  Copyright © 2018 Si Te Feng. All rights reserved.
//

import UIKit
import PureLayout

class QuestionViewController: UIViewController {

    let mainScrollView = UIScrollView()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Things to say"
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "blueBackground.jpg")!)
        
        let navItem = UIBarButtonItem(title: "Dismiss", style: .done, target: self, action: #selector(dismissButtonTapped))
        navItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.colorFromHex("4A9DB2")], for: .normal)
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
        
        
        
        
    }
    
    @objc func dismissButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}
