//
//  UIViewController+Instantiate.swift
//  CalCalc
//
//  Created by Ivan Dilchovski on 11/22/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import UIKit

// Allows type inferred instantiation without casting and strings - let vc = SomeViewController.instantiateFromStoryboard("Main")
extension UIViewController {
    class func instantiate<T: UIViewController>(fromStoryboard name: String) -> T {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! T
        return controller
    }
}
