//
//  CaloriesFilterView.swift
//  CalCalc
//
//  Created by Ivan Dilchovski on 11/30/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import UIKit
import NMRangeSlider

class CaloriesFilterView: BaseNIBView {
    @IBOutlet var dateRangeSlider: NMRangeSlider!
    @IBOutlet var minDateLabel: UILabel!
    @IBOutlet var maxDateLabel: UILabel!
    
    @IBOutlet var timeRangeSlider: NMRangeSlider!
    @IBOutlet var minTimeLabel: UILabel!
    @IBOutlet var maxTimeLabel: UILabel!
    
    private var filter = CaloriesDateFilter()
    
    override func nibDidLoad() {
        super.nibDidLoad()
    }

    
    @IBAction func dateSliderChanged(_ sender: NMRangeSlider) {
        let fromDate: Date?
        if sender.lowerValue > sender.minimumValue {
            fromDate = Date(timeIntervalSince1970: Double(sender.lowerValue * 100))
            minDateLabel.text = Constants.DateFormatters.shortDate.string(from: fromDate!)
        } else {
            fromDate = nil
            minDateLabel.text = "Any"
        }
        
        let toDate: Date?
        if sender.upperValue < sender.maximumValue {
            toDate = Date(timeIntervalSince1970: Double(sender.upperValue * 100))
            maxDateLabel.text = Constants.DateFormatters.shortDate.string(from: toDate!)
        } else {
            toDate = nil
            maxDateLabel.text = "Any"
        }
        
        filter.dateRange = (fromDate, toDate)
    }
    
    @IBAction func timeSliderChanged(_ sender: NMRangeSlider) {
        let fromTime: Double?
        if sender.lowerValue > sender.minimumValue {
            fromTime = Double(sender.lowerValue)
            let minutes = Int((Double(sender.lowerValue).truncatingRemainder(dividingBy: 1)) * 60)
            minTimeLabel.text = "\(Int(sender.lowerValue)):\(minutes)"
        } else {
            fromTime = nil
            minTimeLabel.text = "Any"
        }
        
        let toTime: Double?
        if sender.upperValue < sender.maximumValue {
            toTime = Double(sender.upperValue)
            let minutes = Int((Double(sender.upperValue).truncatingRemainder(dividingBy: 1)) * 60)
            maxTimeLabel.text = "\(Int(sender.upperValue)):\(minutes)"
        } else {
            toTime = nil
            maxTimeLabel.text = "Any"
        }
        
        filter.timeRange = (fromTime, toTime)
    }
    
    func setDateLimits(minDate: Date, maxDate: Date) {
        dateRangeSlider.minimumValue = Float(minDate.timeIntervalSince1970 / 100 - 1)
        dateRangeSlider.maximumValue = Float(maxDate.timeIntervalSince1970 / 100 + 1)
        readjustSliderLimits(slider: dateRangeSlider)
    }
    
    func setTimeLimits(min: Double, max: Double) {
        timeRangeSlider.minimumValue = Float(min - 1)
        timeRangeSlider.maximumValue = Float(max + 1)
        readjustSliderLimits(slider: timeRangeSlider)
    }
}

extension CaloriesFilterView {
    private func readjustSliderLimits(slider: NMRangeSlider) {
        if slider.lowerValue < slider.minimumValue { slider.lowerValue = slider.minimumValue }
        if slider.lowerValue > slider.maximumValue { slider.lowerValue = slider.maximumValue }
        
        if slider.upperValue > slider.maximumValue { slider.upperValue = slider.maximumValue }
        if slider.upperValue < slider.minimumValue { slider.upperValue = slider.maximumValue }
        
        let lower = slider.lowerValue
        let upper = slider.upperValue
        
        slider.lowerValue = lower
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            slider.upperValue = upper + 10
        }
    }
}
