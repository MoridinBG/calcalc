//
//  StoryboardController.swift
//  CalCalc
//
//  Created by Ivan Dilchovski on 11/22/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import UIKit

protocol StoryboardController {
}

// Allows type based instantiation without casting and strings - let vc = SomeViewController.instantiate() where vc will be of type SomeViewController
extension StoryboardController where Self: UIViewController {
    static func instantiate() -> Self {
        return instantiate(fromStoryboard: String(describing: self))
    }
}
