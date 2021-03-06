//
//  Constants.swift
//  CalCalc
//
//  Created by Ivan Dilchovski on 11/22/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import UIKit

struct Constants {
    struct URLs {
        static let backend = "http://localhost:8080/api/v1"
    }
    
    struct UI {
        struct Colors {
            static let mainGreen = UIColor(red: 47/255, green: 212/255, blue: 129/255, alpha: 1)
            static let darkText = UIColor(red: 30/255, green: 38/255, blue: 34/255, alpha: 1)
        }
        
        static let AnimationShortDuration = 0.25
        static let AnimationNormalDuration = 0.5
        static let AnimationLongerDuration = 0.75
        static let AnimationLongererDuration = 1.0
        static let AnimationLongerererDuration = 1.5
        static let AnimationLongerererestDuration = 2.0
    }
    
    struct DateFormatters {
        static var shortDate: DateFormatter = {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(secondsFromGMT: 0) // Avoid adjusting time
            formatter.dateStyle = .short
            return formatter
        }()
        
        static var mediumDate: DateFormatter = {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(secondsFromGMT: 0) // Avoid adjusting time
            formatter.dateStyle = .medium
            return formatter
        }()
        
        static var shortTime: DateFormatter = {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(secondsFromGMT: 0) // Avoid adjusting time
            formatter.timeStyle = .short
            return formatter
        }()
        
        static var serializationDate: DateFormatter = {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(secondsFromGMT: 0) // Avoid adjusting time
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()
        
        static var dateTime: DateFormatter = {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(secondsFromGMT: 0) // Avoid adjusting time
            formatter.dateFormat = "yyyy-MM-dd hh:mm"
            return formatter
        }()
    }
}
