//
//  CaloriesDateFilter.swift
//  CalCalc
//
//  Created by Ivan Dilchovski on 11/30/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import Foundation

struct CaloriesDateFilter {
    var dateRange: (fromDate: Date?, toDate: Date?) = (nil, nil)
    var timeRange: (fromTime: Double?, toTime: Double?) = (nil, nil)
    
    func filter(entries: [CalorieEntry]) -> [CalorieEntry] {
        return entries.filter { entry in
            if let fromDate = self.dateRange.fromDate, fromDate > entry.date {
                return false
            } else if let toDate = self.dateRange.toDate, toDate < entry.date {
                return false
            } else {
                let calendar = Calendar.current
                let components = calendar.dateComponents([.hour, .minute], from: entry.date)
                let hours = Double(components.hour ?? 0)
                let minutes = Double(components.minute ?? 0)
                
                let entryTime = hours + minutes / 60
                
                if let fromTime = timeRange.fromTime, fromTime > entryTime {
                    return false
                } else if let toTime = timeRange.toTime, toTime < entryTime {
                    return false
                }
            }
            
            return true
        }
    }
}
