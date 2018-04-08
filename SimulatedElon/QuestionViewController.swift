//
//  QuestionViewController.swift
//  SimulatedElon
//
//  Created by Si Te Feng on 3/24/18.
//  Copyright © 2018 Si Te Feng. All rights reserved.
//

import UIKit
import PureLayout

let SimulatedElonDidAskQuestionNotification = Notification.Name(rawValue: "SimulatedElonDidAskQuestionNotification")

class QuestionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let mainScrollView = UIScrollView()
    let mainTableView = UITableView(frame: .zero, style: UITableViewStyle.grouped)
    
    let questionSections = ["Try Saying...", "Mentorship & Advice", "SpaceX", "Tesla", "Others"]
    let questionStrings = [["How are you doing today?", "How many kids do you have?"], ["How to create a great company?"], ["What's the difference between a Falcon 9 and a Falcon Heavy"], ["What's the your goal for Tesla"], ["What is a Hyperloop?", "How long does it take to get to Mars?"]]
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Examples"

        let backgroundImage = UIImage(named: "edgeBackground.jpg")!
        let backgroundImageView = UIImageView(image: backgroundImage)
        backgroundImageView.contentMode = .scaleAspectFill
        self.view.addSubview(backgroundImageView)
        backgroundImageView.autoPinEdgesToSuperviewEdges()
        
        let navItem = UIBarButtonItem(title: "Dismiss", style: .done, target: self, action: #selector(dismissButtonTapped))
        navItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.colorFromHex("4A9DB2")], for: .normal)
        self.navigationItem.leftBarButtonItem = navItem
        
        self.view.addSubview(mainTableView)
        mainTableView.separatorStyle = .none
        mainTableView.backgroundColor = UIColor.clear
        mainTableView.autoPinEdgesToSuperviewEdges()
        mainTableView.register(UINib(nibName: "QuestionTableViewCell", bundle: nil) , forCellReuseIdentifier: "QuestionTableViewCell")
        mainTableView.register(QuestionTableViewCellHeader.self, forHeaderFooterViewReuseIdentifier: "QuestionTableViewCellHeader")
        mainTableView.delegate = self
        mainTableView.dataSource = self
        
    }
    
    @objc func dismissButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // TableView data source and delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return questionSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionStrings[section].count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionTitleView = mainTableView.dequeueReusableHeaderFooterView(withIdentifier: "QuestionTableViewCellHeader") as! QuestionTableViewCellHeader
        sectionTitleView.titleLabel.text = questionSections[section]
        return sectionTitleView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mainTableView.dequeueReusableCell(withIdentifier: "QuestionTableViewCell", for: indexPath) as! QuestionTableViewCell
        cell.questionLabel.text = questionStrings[indexPath.section][indexPath.row]
        cell.questionIcon.image = UIImage(named: "question.png")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let questionText = questionStrings[indexPath.section][indexPath.row]
        NotificationCenter.default.post(name: SimulatedElonDidAskQuestionNotification, object: nil, userInfo: ["question": questionText])
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return QuestionTableViewCell.heightRequired()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return QuestionTableViewCellHeader.heightRequired()
    }
    
    
    
    
}
