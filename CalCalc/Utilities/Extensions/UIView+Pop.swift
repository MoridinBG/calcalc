//
//  UIView+Pop.swift
//  CalCalc
//
//  Created by Ivan Dilchovski on 11/22/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import UIKit

// Hides the view and then springly pops it
extension UIView {
    func popIn() {
        transform = CGAffineTransform(scaleX: 0, y: 0)
        self.isHidden = false
        UIView.animate(
            withDuration: Constants.UI.AnimationLongerDuration,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0,
            options: [],
            animations: {
                self.transform = .identity
                self.layoutIfNeeded()
        }, completion: nil)
    }
    
    // TODO: popOut
}

