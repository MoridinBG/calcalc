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
    
    
    private var authRequests: AuthRequests = DefaultAuthRequests()
    private var accountManager: AccountManager = AccountManager()
    
    
    class func initialize(authRequests: AuthRequests = DefaultAuthRequests(),
                          accountManager: AccountManager = AccountManager()) -> SignInViewController {
        let vc = SignInViewController.instantiate()
        vc.authRequests = authRequests
        vc.accountManager = accountManager
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        view.makeToastActivity()
        accountManager.tryAutoLogin() { result in
            switch result {
            case .failure(let error):
                self.view.hideToastActivity()
                if case .requestError = error {
                    self.view.makeToast(error.errorMessage)
                }
                
            case .success(let user):
                log.info("Logged in \(user.email)")
                self.view.hideToastActivity()
                
                self.logInUser(user: user)
            }
        }
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
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            view.makeToastError("Password is empty")
            passwordTextField.setValid(.invalid)
            return
        }
        passwordTextField.setValid(.valid)
        
        view.makeToastActivity()
        accountManager.login(
            username: email,
            password: password) { result in
                switch result {
                case .failure(let error):
                    self.view.hideToastActivity()
                    self.view.makeToast(error.errorMessage)
                    
                case .success(let user):
                    log.info("Logged in \(user.email)")
                    self.view.hideToastActivity()
                    self.view.makeToast("Logged in \(user.email)")
                    
                    self.logInUser(user: user)
                }
        }
    }
    
    @IBAction func signUpPressed() {
        let vc = EditAccountViewController.instantiate(mode: .newUser) { user in
            self.emailTextField.text = user.email
            self.passwordTextField.textField.becomeFirstResponder()
            self.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(vc, animated: true)    
    }
}

extension SignInViewController {
    fileprivate func logInUser(user: User) {
        view.makeToast("Logged in")
    }
}

