//
//  Toast+Extensions.swift
//  CalCalc
//
//  Created by Ivan Dilchovski on 11/22/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import UIKit
import Toast_Swift

extension UIView {
    func makeToast(_ message: String?,
                   position: ToastPosition = ToastManager.shared.position,
                   title: String? = nil,
                   image: UIImage? = nil) {
        
        self.makeToast(message,
                       duration: ToastManager.shared.duration,
                       position: position,
                       title: title,
                       image: image,
                       style: ToastManager.shared.style,
                       completion: nil)
    }
    
    func makeToastError(_ message: String) {
        self.makeToast(message, image: nil)
    }
    
    func makeToastActivity() {
        self.makeToastActivity(.center)
    }
}

