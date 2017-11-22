//
//  UIView+embedInSuperview.swift
//  CalCalc
//
//  Created by Ivan Dilchovski on 11/22/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import UIKit

extension UIView {
    func embedInSuperview(respectMargins: Bool = false) {
        guard let superview = superview else {
            fatalError("View not added to superview")
        }
        
        let superTopAnchor = respectMargins ? superview.layoutMarginsGuide.topAnchor : superview.topAnchor
        let superBottomAnchor = respectMargins ? superview.layoutMarginsGuide.bottomAnchor : superview.bottomAnchor
        let superLeadingAnchor = respectMargins ? superview.layoutMarginsGuide.leadingAnchor : superview.leadingAnchor
        let superTrailingAnchor = respectMargins ? superview.layoutMarginsGuide.trailingAnchor : superview.trailingAnchor
        
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: superTopAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superBottomAnchor).isActive = true
        leadingAnchor.constraint(equalTo: superLeadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superTrailingAnchor).isActive = true
    }
}

