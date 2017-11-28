//
//  ValidatedTextfield.swift
//  CalCalc
//
//  Created by Ivan Dilchovski on 11/22/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import UIKit

@IBDesignable
class ValidatedTextfield: BaseNIBView {
    enum ValidationResult {
        case undefined
        case valid
        case invalid
    }
    
    @IBOutlet var textField: FormTextField!
    @IBOutlet fileprivate var validationIcon: ValidationIndicator!
    @IBOutlet fileprivate var validationHiddenConstraint: NSLayoutConstraint!
    @IBOutlet var textfieldToIcon: NSLayoutConstraint!
    
    var text: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
        }
    }
    
    override func nibDidLoad() {
        super.nibDidLoad()
        
        view.backgroundColor = .clear
        validationIcon.image = nil
        validationHiddenConstraint.isActive = true
        textfieldToIcon.isActive = false
    }
    
    func setValid(_ result: ValidationResult) {
        switch result {
        case .undefined:
            validationIcon.image = nil
            validationHiddenConstraint.isActive = true
            textfieldToIcon.isActive = false
            
        case .valid:
            validationIcon.image = #imageLiteral(resourceName: "SuccessIcon")
            validationHiddenConstraint.isActive = false
            textfieldToIcon.isActive = true
            
        case .invalid:
            validationIcon.image = #imageLiteral(resourceName: "ErrorIcon")
            validationHiddenConstraint.isActive = false
            textfieldToIcon.isActive = true
        }
        
        self.textField.setNeedsLayout()
        UIView.animate(withDuration: Constants.UI.AnimationNormalDuration) {
            self.textField.layoutIfNeeded()
        }
    }
}
