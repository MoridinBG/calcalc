//
//  FormTextField.swift
//  CalCalc
//
//  Created by Ivan Dilchovski on 11/22/17.
//  Copyright © 2017 techlight. All rights reserved.
//

// https://stackoverflow.com/a/27553283/343155
import UIKit

class FormTextField: UITextField {
    
    
    @IBInspectable var inset: CGFloat = 16
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
}

