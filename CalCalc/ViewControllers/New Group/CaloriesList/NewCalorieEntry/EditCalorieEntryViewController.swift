//
//  EditCalorieEntryViewController.swift
//  CalCalc
//
//  Created by Ivan Dilchovski on 12/1/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import UIKit

class EditCalorieEntryViewController: UIViewController, StoryboardController {

    enum Mode {
        case newEntry
        case showEntry(CalorieEntry)
        case editEntry(CalorieEntry)
    }
    
    @IBOutlet private var editBarButton: UIBarButtonItem!
    @IBOutlet private var cancelBarButton: UIBarButtonItem!
    @IBOutlet private var acceptBarButton: UIBarButtonItem!
    
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var dateTextField: ValidatedTextfield!
    
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var descriptionTextField: ValidatedTextfield!
    
    @IBOutlet private var caloriesLabel: UILabel!
    @IBOutlet private var caloriesTextField: ValidatedTextfield!
    
    @IBOutlet private var userContainer: UIView!
    @IBOutlet private var userLabel: UILabel!
    @IBOutlet private var userTextField: ValidatedTextfield!
    
    private var mode: Mode! {
        didSet {
            change(mode: mode)
        }
    }
    
    private var currentUser: User!
    private var entryUser: User!
    private var allUsers: [User]?
    private var onEntrySaved: ((CalorieEntry) -> ())?
    
    private lazy var datePicker: DatePickerSheet = {
        let picker = DatePickerSheet()
        picker.datePicker.datePickerMode = .dateAndTime
        picker.datePicker.addTarget(self, action: #selector(self.dateChanged), for: .valueChanged)
        switch mode! {
        case .editEntry(let entry), .showEntry(let entry):
            picker.datePicker.date = entry.date
        case .newEntry:
            break
        }
        
        return picker
    }()
    
    
    static func instantiate(mode: Mode,
                            currentUser: User,
                            entryUser: User,
                            allUsers: [User]? = nil,
                            onEntrySaved: ((CalorieEntry) -> ())? = nil) -> EditCalorieEntryViewController {
        
        let vc = EditCalorieEntryViewController.instantiate()
        _ = vc.view // This will setup UI elements
        vc.currentUser = currentUser
        vc.entryUser = entryUser
        vc.allUsers = allUsers
        vc.mode = mode
        vc.onEntrySaved = onEntrySaved
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    @IBAction private func acceptPressed() {
        guard let _ = buildEntry() else { return }
        
        switch mode! {
        case .newEntry:
            if currentUser.id != entryUser.id {
                // TODO: Create entry for other user
            } else {
                // TODO: Create entry for self
            }
            
        case .editEntry:
            break;
            // TODO: Update entry
            
        case .showEntry:
            break
        }
    }
    
    @IBAction private func cancelPressed() {
        guard case .editEntry(let entry) = mode! else {
            return
        }
        
        mode = .showEntry(entry)
    }
    
    @IBAction private func editPressed() {
        guard case .showEntry(let entry) = mode! else {
            return
        }
        
        mode = .editEntry(entry)
    }
    
    @IBAction private func datePressed() {
        descriptionTextField.resignFirstResponder()
        caloriesTextField.resignFirstResponder()
        
        guard datePicker.superview == nil else { return }
        
        view.addSubview(datePicker)
        
        datePicker.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    @IBAction private func userPressed() {
        guard currentUser.role == .admin else {
            log.error("Not an admin")
            return
        }
        
        guard let allUsers = allUsers, allUsers.count > 0 else {
            log.error("No users loaded")
            return
        }
        
        let sheet = UIAlertController(title: "Choose user", message: nil, preferredStyle: .actionSheet)
        for user in allUsers {
            sheet.addAction(UIAlertAction(title: user.fullName, style: .default, handler: { _ in
                self.entryUser = user
                self.userLabel.text = self.entryUser.fullName
            }))
        }
        
        present(sheet, animated: true, completion: nil)
    }
    
    @objc private func dateChanged(picker: UIDatePicker) {
        dateTextField.text = Constants.DateFormatters.dateTime.string(from: picker.date)
    }
}

extension EditCalorieEntryViewController {
    private func change(mode: Mode) {
        let labelColor: UIColor
        let textFieldColor: UIColor
        let textFieldEnabled: Bool
    
        switch mode {
        case .newEntry, .editEntry:
            labelColor = UIColor(red: 30/255, green: 38/255, blue: 34/255, alpha: 1)
            textFieldColor = UIColor(red: 30/255, green: 38/255, blue: 34/255, alpha: 1)
            textFieldEnabled = true
            
        case .showEntry:
            labelColor = UIColor(red: 30/255, green: 38/255, blue: 34/255, alpha: 0.25)
            textFieldColor = UIColor(red: 30/255, green: 38/255, blue: 34/255, alpha: 0.25)
            textFieldEnabled = false
        }
        
        userContainer.isHidden = currentUser.role != .admin
        
        [ dateLabel, descriptionLabel, caloriesLabel, userLabel ]
            .forEach { $0?.textColor =  labelColor }
        [dateTextField, descriptionTextField, caloriesTextField, userTextField]
            .forEach {
                $0?.textField.textColor = textFieldColor
                $0?.isUserInteractionEnabled = textFieldEnabled
        }
        
        switch mode {
        case .editEntry(let entry):
            fillIn(entry: entry)
            navigationItem.rightBarButtonItems = [ acceptBarButton, cancelBarButton ]
            navigationItem.title = "Edit Entry"
            
        case .showEntry(let entry):
            fillIn(entry: entry)
            navigationItem.rightBarButtonItems = [ editBarButton ]
            navigationItem.title = "Entry"
            
        case .newEntry:
            fillIn(entry: nil)
            navigationItem.rightBarButtonItems = [ acceptBarButton ]
            navigationItem.title = "New Entry"
            
        }
    }
    
    private func fillIn(entry: CalorieEntry?) {
        descriptionLabel.text = entry?.description
        userLabel.text = entryUser.fullName
        
        if let entry = entry {
            dateLabel.text = Constants.DateFormatters.dateTime.string(from: entry.date)
            caloriesLabel.text = "\(entry.calories)"
        } else {
            dateLabel.text = nil
            caloriesLabel.text = nil
        }
    }
    
    private func buildEntry() -> CalorieEntry? {
        guard let dateText = dateTextField.text, !dateText.isEmpty, let date = Constants.DateFormatters.dateTime.date(from: dateText) else {
            view.makeToastError("You must provide a date")
            dateTextField.setValid(.invalid)
            return nil
        }
        dateTextField.setValid(.valid)
        
        guard let description = descriptionTextField.text, !description.isEmpty else {
            view.makeToastError("You must provide a description")
            descriptionTextField.setValid(.invalid)
            return nil
        }
        descriptionTextField.setValid(.valid)
        
        guard let caloriesText = caloriesTextField.text, !caloriesText.isEmpty, let calories = Int(caloriesText) else {
            view.makeToastError("You must provide a valid calories number")
            caloriesTextField.setValid(.invalid)
            return nil
        }
        caloriesTextField.setValid(.valid)
        
        let id: Int?
        if case .editEntry(let entry) = mode! {
            id = entry.id
        } else {
            id = nil
        }
        
        return CalorieEntry(id: id, date: date, description: description, calories: calories)
    }
    
    private func setupUI() {
        for textField in [dateTextField, descriptionTextField, caloriesTextField, userTextField] {
            textField?.textField.layer.cornerRadius = 5
            textField?.textField.delegate = self
        }
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.preservesSuperviewLayoutMargins = true
        datePicker.backgroundColor = Constants.UI.Colors.darkText
        datePicker.onDone = { [weak self] in
            self?.datePicker.removeFromSuperview()
        }
        
        datePicker.datePicker.setValue(UIColor.white, forKey: "textColor")
        datePicker.datePicker.tintColor = .white
        datePicker.datePicker.maximumDate = Date()
    }
}

extension EditCalorieEntryViewController: UITextFieldDelegate {
    // Hide the pickers when the keyboard appears
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if datePicker.superview != nil { datePicker.removeFromSuperview() }
    }
}
