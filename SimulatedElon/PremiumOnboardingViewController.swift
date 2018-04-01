//
//  PremiumOnboardingViewController.swift
//  SimulatedElon
//
//  Created by Si Te Feng on 3/26/18.
//  Copyright © 2018 Si Te Feng. All rights reserved.
//

import UIKit
import PureLayout
import SkyFloatingLabelTextField
import Firebase

class PremiumOnboardingViewController: UIViewController, UITextFieldDelegate {
    
    let passwordTextFieldTag = 78
    private var passwordString: String = ""
    private var submitButtonTappedOnce = false
    
    var fbAuthListenerHandle: AuthStateDidChangeListenerHandle!
    
    let nameTextField = SkyFloatingLabelTextField()
    let emailTextField = SkyFloatingLabelTextField()
    let passwordTextField = SkyFloatingLabelTextField()
    let phoneTextField = SkyFloatingLabelTextField()
    
    let signupButton = UIButton(type: UIButtonType.custom)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fbAuthListenerHandle = Auth.auth().addStateDidChangeListener { (auth, user) in
            print("state did change: \(auth), \(user)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(fbAuthListenerHandle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Enhanced Simulation Setup"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)

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
        welcomeLabel.text = "🎉 Welcome!"
        welcomeLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        welcomeLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        welcomeLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 30)
        
        let welcomeDescriptionLabel = UILabel()
        scrollViewContainer.addSubview(welcomeDescriptionLabel)
        welcomeDescriptionLabel.font = UIFont(name: "Futura-Medium", size: 14)
        welcomeDescriptionLabel.textColor = UIColor.white
        welcomeDescriptionLabel.textAlignment = .left
        welcomeDescriptionLabel.text = "You've successfully upgraded to the Enhanced Simulation plan, let's create an account so that you can enjoy premium access across all your devices."
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
        fieldsContainer.autoSetDimension(.height, toSize: 340)
        
        fieldsContainer.addSubview(nameTextField)
        nameTextField.addTarget(self, action: #selector(textFieldTextDidChange), for: .editingChanged)
        nameTextField.placeholder = "First Name"
        nameTextField.title = "First Name"
        nameTextField.titleLabel.font = UIFont(name: "Futura-Medium", size: 13)
        nameTextField.errorColor = UIColor.orange
        nameTextField.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        nameTextField.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        nameTextField.autoPinEdge(toSuperviewEdge: .top, withInset: 30)
        
        fieldsContainer.addSubview(emailTextField)
        emailTextField.addTarget(self, action: #selector(textFieldTextDidChange), for: .editingChanged)
        emailTextField.keyboardType = .emailAddress
        emailTextField.placeholder = "Email"
        emailTextField.title = "Email"
        emailTextField.titleLabel.font = UIFont(name: "Futura-Medium", size: 13)
        emailTextField.errorColor = UIColor.orange
        emailTextField.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        emailTextField.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        emailTextField.autoPinEdge(.top, to: .bottom, of: nameTextField, withOffset: 16)
        
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
        
        fieldsContainer.addSubview(phoneTextField)
        phoneTextField.addTarget(self, action: #selector(textFieldTextDidChange), for: .editingChanged)
        phoneTextField.keyboardType = .phonePad
        phoneTextField.placeholder = "Phone number"
        phoneTextField.title = "Phone number"
        phoneTextField.titleLabel.font = UIFont(name: "Futura-Medium", size: 13)
        phoneTextField.errorColor = UIColor.orange
        phoneTextField.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        phoneTextField.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        phoneTextField.autoPinEdge(.top, to: .bottom, of: passwordTextField, withOffset: 16)
        
        fieldsContainer.addSubview(signupButton)
        signupButton.setTitle("Done", for: .normal)
        signupButton.titleLabel?.textColor = UIColor.white
        signupButton.titleLabel?.font = UIFont(name: "Futura-Medium", size: 16)
        signupButton.backgroundColor = UIColor.colorFromHex("#4A9DB2")
        signupButton.autoSetDimension(.width, toSize: 100)
        signupButton.autoSetDimension(.height, toSize: 44)
        signupButton.autoPinEdge(.top, to: .bottom, of: phoneTextField, withOffset: 30)
        signupButton.autoAlignAxis(toSuperviewAxis: .vertical)
        signupButton.addTarget(self, action: #selector(signupButtonTapped), for: .touchUpInside)
    }
    
    
    
    @objc func signupButtonTapped(button: UIButton) {
        submitButtonTappedOnce = true
        
        let firstName = (nameTextField.text ?? "").trimmingCharacters(in:CharacterSet(charactersIn: " "))
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let phone = phoneTextField.text ?? ""
        
        var hasError = false
        if (firstName.count < 1) {
            nameTextField.errorMessage = "Name should not be empty"
            hasError = true
        } else {
            nameTextField.errorMessage = ""
        }
        
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
        registerUser(firstName: firstName, email: email, password: password, phoneNumber: phone)
        
    }
    
    
    private func registerUser(firstName: String, email: String, password: String, phoneNumber: String) {
        print("registering user: \(firstName), \(email), \(password), \(phoneNumber)")
    
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            guard let user = user else {
                if let error = error {
                    print("Error User Signup: \(error)")
                }
                self.signupButton.titleLabel?.text = "Done"
                self.signupButton.isEnabled = true
                
                let alertController = UIAlertController(title: "Error Creating Account", message: "Please try again later, you can contact us if this issue persists", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alertController.addAction(okayAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            print("User signup successful")
            let newUserItem: [String: Any?] = [
                "email": email,
                "firstName": firstName,
                "phoneNumber": phoneNumber,
                "accountCreationDate": ISO8601DateFormatter().string(from: Date()),
                "lastVisited": ISO8601DateFormatter().string(from: Date()),
                "timezone": TimeZone.autoupdatingCurrent.identifier,
                "premium": true,
                "smsEnabled": true
            ]
            Database.database().reference(withPath: "users/").child(user.uid).setValue(newUserItem)
            
            if phoneNumber != "" {
                var properPhoneNumber = phoneNumber
                if (phoneNumber.count == 10) {
                    properPhoneNumber = "1" + phoneNumber
                }
                Database.database().reference(withPath: "phoneToUserId").child(properPhoneNumber).observeSingleEvent(of: .value, with: { (snap) in
                    if snap.value == nil {
                        Database.database().reference(withPath: "phoneToUserId/").child(properPhoneNumber).setValue(user.uid)
                    } else {
                        OperationQueue.main.addOperation {
                            self.signupButton.titleLabel?.text = "Done"
                            self.signupButton.isEnabled = true
                            
                            let alertController = UIAlertController(title: "Error Creating Account", message: "Phone number already taken", preferredStyle: .alert)
                            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                            alertController.addAction(okayAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                })
                
            }
            
            self.view.endEditing(true)
            self.navigationController?.dismiss(animated: true, completion: nil)
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
        
        let firstName = (nameTextField.text ?? "").trimmingCharacters(in:CharacterSet(charactersIn: " "))
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        if (firstName.count < 1) {
            nameTextField.errorMessage = "Name should not be empty"
        } else {
            nameTextField.errorMessage = ""
        }
        
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
