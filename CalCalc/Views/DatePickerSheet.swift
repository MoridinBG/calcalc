//
//  DatePickerSheet.swift
//  CalCalc
//
//  Created by Ivan Dilchovski on 12/1/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import UIKit

class DatePickerSheet: PickerSheetView {
    let datePicker: UIDatePicker
    
    override init(frame: CGRect) {
        datePicker = UIDatePicker()
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        datePicker = UIDatePicker()
        super.init(coder: aDecoder)
    }
    
    override func setup() {
        super.setup()
        
        container.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.embedInSuperview()
    }
}
