//
//  UIViewController+Id.swift
//  CalCalc
//
//  Created by Ivan Dilchovski on 11/22/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import UIKit

// Gets the VC name as string for Storyboard IDs
extension UIViewController {
    static var id: String {
        return String(describing: self)
    }
}
