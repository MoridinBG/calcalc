//
//  EditAccountViewController.swift
//  CalCalc
//
//  Created by Ivan Dilchovski on 11/22/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import UIKit

class EditAccountViewController: UIViewController, StoryboardController {
    enum Mode {
        case newUser
        case showUser(User)
        case editUser(User)
    }
    
    @IBOutlet fileprivate var editBarButton: UIBarButtonItem!
    @IBOutlet fileprivate var cancelBarButton: UIBarButtonItem!
    @IBOutlet fileprivate var acceptBarButton: UIBarButtonItem!
    
    @IBOutlet fileprivate var firstNameLabel: UILabel!
    @IBOutlet fileprivate var firstNameTextField: ValidatedTextfield!
    
    @IBOutlet fileprivate var lastNameLabel: UILabel!
    @IBOutlet fileprivate var lastNameTextField: ValidatedTextfield!
    
    @IBOutlet fileprivate var caloriesLabel: UILabel!
    @IBOutlet fileprivate var caloriesTextField: ValidatedTextfield!
    
    @IBOutlet fileprivate var emailLabel: UILabel!
    @IBOutlet fileprivate var emailTextField: ValidatedTextfield!
    
    @IBOutlet fileprivate var passwordLabel: UILabel!
    @IBOutlet fileprivate var passwordTextField: ValidatedTextfield!
    
    
    fileprivate var mode: Mode! {
        didSet {
            change(mode: mode)
        }
    }
    
    
    static func instantiate(mode: Mode) -> EditAccountViewController {
        let vc = EditAccountViewController.instantiate()
        _ = vc.view // This will setup UI elements
        vc.mode = mode
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    @IBAction func acceptPressed() {
        guard let user = buildUser() else { return }
        
        if case .newUser = mode! {
            guard let password = passwordTextField.textField.text, password != "" else {
                view.makeToastError("You must provide a password")
                return
            }
        }
        
    }
    
    @IBAction func cancelPressed() {
        guard case .editUser(let user) = mode! else {
            return
        }
        
        mode = .showUser(user)
    }
    
    @IBAction func editPressed() {
        guard case .showUser(let user) = mode! else {
            return
        }
        
        mode = .editUser(user)
    }
}

extension EditAccountViewController {
    fileprivate func change(mode: Mode) {
        let labelColor: UIColor
        let textFieldColor: UIColor
        let textFieldEnabled: Bool
        
        switch mode {
        case .newUser, .editUser:
            labelColor = UIColor(red: 30/255, green: 38/255, blue: 34/255, alpha: 0.25)
            textFieldColor = UIColor(red: 30/255, green: 38/255, blue: 34/255, alpha: 1)
            textFieldEnabled = true
        case .showUser:
            labelColor = UIColor(red: 30/255, green: 38/255, blue: 34/255, alpha: 1)
            textFieldColor = UIColor(red: 30/255, green: 38/255, blue: 34/255, alpha: 0.25)
            textFieldEnabled = false
        }
        
        lastNameLabel.layer.borderColor = UIColor.white.cgColor
        [ firstNameLabel, lastNameLabel, emailLabel, passwordLabel, caloriesLabel ]
            .forEach { $0?.textColor =  labelColor }
        [firstNameTextField, lastNameTextField, emailTextField, passwordTextField, caloriesTextField]
            .forEach {
                $0?.textField.textColor = textFieldColor
                $0?.isUserInteractionEnabled = textFieldEnabled
        }
        
        switch mode {
        case .editUser(let user):
            fillIn(user: user)
            navigationItem.rightBarButtonItems = [ acceptBarButton, cancelBarButton ]
            
        case .showUser(let user):
            fillIn(user: user)
            navigationItem.rightBarButtonItems = [ editBarButton ]
            
        case .newUser:
            fillIn(user: nil)
            navigationItem.rightBarButtonItems = [ acceptBarButton ]
            
        }
    }
    
    fileprivate func fillIn(user: User?) {
        firstNameTextField.textField.text = user?.firstName
        lastNameTextField.textField.text = user?.lastName
        emailTextField.textField.text = user?.email
        
        if let calories = user?.calorieTarget {
            caloriesTextField.textField.text = "\(calories)"
        } else {
            caloriesTextField.textField.text = nil
        }
    }
    
    fileprivate func buildUser() -> User? {
        guard let firstName = firstNameTextField.textField.text, firstName != "" else {
            view.makeToastError("You must provide your first name")
            firstNameTextField.setValidation(.invalid)
            return nil
        }
        firstNameTextField.setValidation(.valid)
        
        guard let lastName = lastNameTextField.textField.text, lastName != "" else {
            view.makeToastError("You must provide your last name")
            lastNameTextField.setValidation(.invalid)
            return nil
        }
        lastNameTextField.setValidation(.valid)
        
        let calorieTarget: Int?
        if let caloriesText = caloriesTextField.textField.text, !caloriesText.isEmpty {
            guard let calories = Int(caloriesText), calories >= 0 else {
                view.makeToastError("You must provide a valid number of calories")
                caloriesTextField.setValidation(.invalid)
                return nil
            }
            
            calorieTarget = calories
        } else {
            calorieTarget = nil
        }
        caloriesTextField.setValidation(.valid)
        
        guard let email = emailTextField.textField.text, email != "", email.isEmail else {
            view.makeToastError("You must provide a valid email")
            emailTextField.setValidation(.invalid)
            return nil
        }
        emailTextField.setValidation(.valid)
        
        let user = User(id: -1,
                        firstName: firstName,
                        lastName: lastName,
                        email: email,
                        calorieTarget: calorieTarget)
        
        return user
    }
    
    fileprivate func setupUI() {
        for textField in [firstNameTextField, lastNameTextField, emailTextField, passwordTextField, caloriesTextField] {
            textField?.layer.cornerRadius = 5
        }
    }
}
