//
//  SignInViewController.swift
//  CalCalc
//
//  Created by Ivan Dilchovski on 11/22/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController, StoryboardController {

    @IBOutlet fileprivate var emailTextField: ValidatedTextfield!
    @IBOutlet fileprivate var passwordTextField: ValidatedTextfield!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func signInPressed() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        guard let email = emailTextField.text, email.isEmail, !email.isEmpty else {
            view.makeToastError("Email is invalid")
            emailTextField.setValid(.invalid)
            return
        }
        emailTextField.setValid(.valid)
        
        guard let _ = passwordTextField.text, !email.isEmpty else {
            view.makeToastError("Password is empty")
            passwordTextField.setValid(.invalid)
            return
        }
        passwordTextField.setValid(.valid)
        
        
    }
    
    @IBAction func signUpPressed() {
        let vc = EditAccountViewController.instantiate(mode: .newUser)
        navigationController?.pushViewController(vc, animated: true)    
    }
}

