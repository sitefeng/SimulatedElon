//
//  LoginViewController.swift
//  SimulatedElon
//
//  Created by Si Te Feng on 4/1/18.
//  Copyright © 2018 Si Te Feng. All rights reserved.
//

import UIKit
import PureLayout
import Firebase
import SkyFloatingLabelTextField

class LoginViewController: UIViewController {

    let passwordTextFieldTag = 78
    private var passwordString: String = ""
    private var submitButtonTappedOnce = false

    
    let nameTextField = SkyFloatingLabelTextField()
    let emailTextField = SkyFloatingLabelTextField()
    let passwordTextField = SkyFloatingLabelTextField()
    let phoneTextField = SkyFloatingLabelTextField()
    
    let signupButton = UIButton(type: UIButtonType.custom)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Login"
        
        
        // Setup Views
        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor.clear
        self.view.addSubview(scrollView)
        var navBarHeight = CGFloat(44)
        if let barSize = self.navigationController?.navigationBar.frame.size {
            navBarHeight = barSize.height
        }
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        scrollView.autoPinEdge(toSuperviewEdge: .top, withInset: navBarHeight + statusBarHeight)
        scrollView.autoPinEdge(toSuperviewEdge: .left)
        scrollView.autoPinEdge(toSuperviewEdge: .right)
        scrollView.autoPinEdge(toSuperviewEdge: .bottom)
        
        let scrollViewContainer = UIView()
        scrollView.addSubview(scrollViewContainer)
        scrollViewContainer.backgroundColor = UIColor.clear
        let tapRec1 = UITapGestureRecognizer(target: self, action: #selector(backgroundViewTapped))
        scrollViewContainer.addGestureRecognizer(tapRec1)
        
        scrollViewContainer.autoPinEdgesToSuperviewEdges()
        scrollViewContainer.autoMatch(.width, to: .width, of: view)
        scrollViewContainer.autoSetDimension(.height, toSize: 840)
        
        let welcomeLabel = UILabel()
        scrollViewContainer.addSubview(welcomeLabel)
        welcomeLabel.font = UIFont(name: "Futura-Bold", size: 26)
        welcomeLabel.textColor = UIColor.white
        welcomeLabel.text = "🚀 Login"
        welcomeLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        welcomeLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        welcomeLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 30)
        
        let welcomeDescriptionLabel = UILabel()
        scrollViewContainer.addSubview(welcomeDescriptionLabel)
        welcomeDescriptionLabel.font = UIFont(name: "Futura-Medium", size: 14)
        welcomeDescriptionLabel.textColor = UIColor.white
        welcomeDescriptionLabel.textAlignment = .left
        welcomeDescriptionLabel.text = "If you have signed up before, you may sign in below"
        welcomeDescriptionLabel.numberOfLines = 3
        welcomeDescriptionLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        welcomeDescriptionLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        welcomeDescriptionLabel.autoPinEdge(.top, to: .bottom, of: welcomeLabel, withOffset: 12)
        
        let fieldsContainer = UIView()
        scrollViewContainer.addSubview(fieldsContainer)
        let tapRec2 = UITapGestureRecognizer(target: self, action: #selector(backgroundViewTapped))
        fieldsContainer.addGestureRecognizer(tapRec2)
        fieldsContainer.backgroundColor = UIColor.white
        fieldsContainer.layer.cornerRadius = 30
        fieldsContainer.layer.masksToBounds = true
        fieldsContainer.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        fieldsContainer.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        fieldsContainer.autoPinEdge(.top, to: .bottom, of: welcomeDescriptionLabel, withOffset: 30)
        fieldsContainer.autoSetDimension(.height, toSize: 240)
        
        fieldsContainer.addSubview(emailTextField)
        emailTextField.addTarget(self, action: #selector(textFieldTextDidChange), for: .editingChanged)
        emailTextField.keyboardType = .emailAddress
        emailTextField.placeholder = "Email"
        emailTextField.title = "Email"
        emailTextField.titleLabel.font = UIFont(name: "Futura-Medium", size: 13)
        emailTextField.errorColor = UIColor.orange
        emailTextField.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        emailTextField.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        emailTextField.autoPinEdge(toSuperviewEdge: .top, withInset: 30)
        
        fieldsContainer.addSubview(passwordTextField)
        passwordTextField.addTarget(self, action: #selector(textFieldTextDidChange), for: .editingChanged)
        passwordTextField.isSecureTextEntry = true
        passwordTextField.tag = passwordTextFieldTag
        passwordTextField.placeholder = "Password"
        passwordTextField.title = "Password"
        passwordTextField.titleLabel.font = UIFont(name: "Futura-Medium", size: 13)
        passwordTextField.errorColor = UIColor.orange
        passwordTextField.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        passwordTextField.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        passwordTextField.autoPinEdge(.top, to: .bottom, of: emailTextField, withOffset: 16)
        
        fieldsContainer.addSubview(signupButton)
        signupButton.setTitle("Login", for: .normal)
        signupButton.titleLabel?.textColor = UIColor.white
        signupButton.titleLabel?.font = UIFont(name: "Futura-Medium", size: 16)
        signupButton.backgroundColor = UIColor.colorFromHex("#4A9DB2")
        signupButton.autoSetDimension(.width, toSize: 100)
        signupButton.autoSetDimension(.height, toSize: 44)
        signupButton.autoPinEdge(.top, to: .bottom, of: passwordTextField, withOffset: 30)
        signupButton.autoAlignAxis(toSuperviewAxis: .vertical)
        signupButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    
    @objc func loginButtonTapped(button: UIButton) {
        submitButtonTappedOnce = true
        
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        var hasError = false
        
        if (password.count < 8) {
            passwordTextField.errorMessage = "Password must be 8 characters or more"
            hasError = true
        } else {
            passwordTextField.errorMessage = ""
        }
        
        if (!SEUtility.isValidEmail(testStr: email)) {
            emailTextField.errorMessage = "Please enter a valid email"
            hasError = true
        } else {
            emailTextField.errorMessage = ""
        }
        
        if (hasError) {
            return
        }
        
        signupButton.titleLabel?.text = "Sending..."
        signupButton.isEnabled = false
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            guard let _ = user else {
                self.signupButton.titleLabel?.text = "Done"
                self.signupButton.isEnabled = true
                
                var errorMessage = "Please try again. "
                if let error = error {
                    errorMessage += error.localizedDescription
                }
                let alertController = UIAlertController(title: "Error Logging in", message: errorMessage, preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alertController.addAction(okayAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            self.view.endEditing(true)
            
            var successMessage = "Welcome back!"
            if let userName = user?.displayName {
                successMessage = "Welcome back, \(userName)!"
            }
            let alertController = UIAlertController(title: "Logged In", message: successMessage, preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (alertAction) in
                self.navigationController?.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(okayAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
        
    }
    
    
    @objc func backgroundViewTapped() {
        self.view.endEditing(true)
    }
    
    // UITextFieldDelegate
    @objc func textFieldTextDidChange(textField: UITextField) {
        if !submitButtonTappedOnce {
            return
        }
        
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        if (password.count < 8) {
            passwordTextField.errorMessage = "Password must be 8 characters or more"
        } else {
            passwordTextField.errorMessage = ""
        }
        
        if (!SEUtility.isValidEmail(testStr: email)) {
            emailTextField.errorMessage = "Please enter a valid email"
        } else {
            emailTextField.errorMessage = ""
        }
    }

}
