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
    
    @IBOutlet private var editBarButton: UIBarButtonItem!
    @IBOutlet private var cancelBarButton: UIBarButtonItem!
    @IBOutlet private var acceptBarButton: UIBarButtonItem!
    
    @IBOutlet private var firstNameLabel: UILabel!
    @IBOutlet private var firstNameTextField: ValidatedTextfield!
    
    @IBOutlet private var lastNameLabel: UILabel!
    @IBOutlet private var lastNameTextField: ValidatedTextfield!
    
    @IBOutlet private var caloriesLabel: UILabel!
    @IBOutlet private var caloriesTextField: ValidatedTextfield!
    
    @IBOutlet private var emailLabel: UILabel!
    @IBOutlet private var emailTextField: ValidatedTextfield!
    
    @IBOutlet private var passwordLabel: UILabel!
    @IBOutlet private var passwordTextField: ValidatedTextfield!
    
    @IBOutlet private var roleContainer: UIView!
    @IBOutlet private var roleTextField: ValidatedTextfield!
    
    private var mode: Mode! {
        didSet {
            change(mode: mode)
        }
    }
    
    private var currentUser: User?
    private var onRegister: ((User) -> ())?
    
    private var usersRequests: UsersRequests = DefaultUsersRequests()
    private var notificationCenter: NotificationCenter = NotificationCenter()
    
    
    
    static func instantiate(mode: Mode,
                            currentUser: User? = nil,
                            usersRequests: UsersRequests = DefaultUsersRequests(),
                            notificationCenter: NotificationCenter = NotificationCenter(),
                            onRegister: ((User) -> ())? = nil) -> EditAccountViewController {
        let vc = EditAccountViewController.instantiate()
        _ = vc.view // This will setup UI elements
        vc.mode = mode
        vc.currentUser = currentUser
        vc.onRegister = onRegister
        vc.usersRequests = usersRequests
        vc.notificationCenter = notificationCenter
        
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    @IBAction private func acceptPressed() {
        guard let user = buildUser() else { return }
        
        let setUpdateFailHandler: (RequestError) -> () = { error in
            self.view.makeToast(error.errorMessage)
            
            if error.isServerError(.userInvalidPassword) {
                self.passwordTextField.setValid(.invalid)
            }
            
            if error.isServerError(.userInvalidEmail) {
                self.emailTextField.setValid(.invalid)
            }
        }
        
        if case .newUser = mode! {
            guard let password = passwordTextField.text, password != "" else {
                view.makeToastError("You must provide a password")
                passwordTextField.setValid(.invalid)
                return
            }
            passwordTextField.setValid(.valid)
            
            usersRequests.register(
                user: user,
                withPassword: password) { result in
                    switch result {
                    case .failure(let error):
                        setUpdateFailHandler(error)
                        
                    case .success(let user):
                        self.onRegister?(user)
                    }
            }
        } else if case .editUser = mode! {
            guard let password = passwordTextField.text, password != "" else {
                view.makeToastError("You must provide a password")
                passwordTextField.setValid(.invalid)
                return
            }
            passwordTextField.setValid(.valid)
            
            usersRequests.update(user: user, withPassword: password) { result in
                switch result {
                case .failure(let error):
                    setUpdateFailHandler(error)
                    
                case .success(let user):
                    if self.currentUser?.id == user.id {
                        self.notificationCenter.postTypedNotification(Notifications.AccountManager.UserUpdated(user: user, observedObject: nil))
                    }
                }
            }
        }
        
        
    }
    
    @IBAction private func cancelPressed() {
        guard case .editUser(let user) = mode! else {
            return
        }
        
        mode = .showUser(user)
    }
    
    @IBAction private func editPressed() {
        guard case .showUser(let user) = mode! else {
            return
        }
        
        mode = .editUser(user)
    }
    
    @IBAction private func rolePressed() {
        guard let currentUser = currentUser, currentUser.role != .user else { return }
        
        let sheet = UIAlertController(title: "Choose user role", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "User", style: .default, handler: { _ in
            self.roleTextField.text = "User"
        }))
        
        sheet.addAction(UIAlertAction(title: "Manager", style: .default, handler: { _ in
            self.roleTextField.text = "Manager"
        }))
        
        if currentUser.role == .admin {
            sheet.addAction(UIAlertAction(title: "Admin", style: .default, handler: { _ in
                self.roleTextField.text = "Admin"
            }))
        }
        
        present(sheet, animated: true, completion: nil)
    }
}

extension EditAccountViewController {
    private func change(mode: Mode) {
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
        
        roleContainer.isHidden = currentUser?.role != .user
        
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
    
    private func fillIn(user: User?) {
        firstNameTextField.textField.text = user?.firstName
        lastNameTextField.textField.text = user?.lastName
        emailTextField.textField.text = user?.email
        
        if let calories = user?.calorieTarget {
            caloriesTextField.textField.text = "\(calories)"
        } else {
            caloriesTextField.textField.text = nil
        }
    }
    
    private func buildUser() -> User? {
        guard let firstName = firstNameTextField.textField.text, firstName != "" else {
            view.makeToastError("You must provide your first name")
            firstNameTextField.setValid(.invalid)
            return nil
        }
        firstNameTextField.setValid(.valid)
        
        guard let lastName = lastNameTextField.textField.text, lastName != "" else {
            view.makeToastError("You must provide your last name")
            lastNameTextField.setValid(.invalid)
            return nil
        }
        lastNameTextField.setValid(.valid)
        
        let calorieTarget: Int?
        if let caloriesText = caloriesTextField.textField.text, !caloriesText.isEmpty {
            guard let calories = Int(caloriesText), calories >= 0 else {
                view.makeToastError("You must provide a valid number of calories")
                caloriesTextField.setValid(.invalid)
                return nil
            }
            
            calorieTarget = calories
        } else {
            calorieTarget = nil
        }
        caloriesTextField.setValid(.valid)
        
        guard let email = emailTextField.textField.text, email != "", email.isEmail else {
            view.makeToastError("You must provide a valid email")
            emailTextField.setValid(.invalid)
            return nil
        }
        emailTextField.setValid(.valid)
        
        let id: Int
        if case .editUser(let user) = mode! {
            id = user.id
        } else {
            id = -1
        }
        
        let user = User(id: id,
                        firstName: firstName,
                        lastName: lastName,
                        email: email,
                        calorieTarget: calorieTarget)
        
        return user
    }
    
    private func setupUI() {
        for textField in [firstNameTextField, lastNameTextField, emailTextField, passwordTextField, caloriesTextField] {
            textField?.layer.cornerRadius = 5
        }
        
        passwordTextField.textField.isSecureTextEntry = true
    }
}
