//
//  PickerSheetView.swift
//  CalCalc
//
//  Created by Ivan Dilchovski on 12/1/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import UIKit

//* Convenience container for pickers *//
class PickerSheetView: UIView {
    var onDone: (() -> ())?
    let container: UIView
    
    override init(frame: CGRect) {
        container = UIView()
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        container = UIView()
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup() {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .lightGray
        
        addSubview(separator)
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        separator.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        separator.trailingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        separator.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        let done = UIButton()
        done.setTitle("Done", for: .normal)
        done.addTarget(self, action: #selector(self.done), for: .touchUpInside)
        done.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(done)
        done.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true
        done.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        
        addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.topAnchor.constraint(equalTo: done.bottomAnchor, constant: 4).isActive = true
        container.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        container.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        container.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    @objc private func done() {
        onDone?()
    }
}

