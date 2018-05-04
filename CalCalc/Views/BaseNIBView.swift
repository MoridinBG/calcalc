//
//  BaseNIBView.swift
//  CalCalc
//
//  Created by Ivan Dilchovski on 11/22/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import UIKit

extension UIView {
    var nibName: String {
        return String(describing: type(of: self))
    }
}

class BaseNIBView: UIView {
    private(set) var view: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibDidLoad()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibDidLoad()
    }
    
    func nibDidLoad() {
        view = loadViewFromNib()
        addSubview(view)
        view.embedInSuperview()
    }
}

extension BaseNIBView {
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: self.nibName, bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return nibView
    }
}

