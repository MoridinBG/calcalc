//
//  ValidationIndicator.swift
//  CalCalc
//
//  Created by Ivan Dilchovski on 11/22/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import UIKit

class ValidationIndicator: UIImageView {
    init() {
        super.init(image: #imageLiteral(resourceName: "ErrorIcon"))
        
        isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func popError(autohide: Bool = true) {
        self.image = #imageLiteral(resourceName: "ErrorIcon")
        popIn()
        
        if autohide {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                self.isHidden = true
            }
        }
    }
}

