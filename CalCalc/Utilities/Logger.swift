//
//  Logger.swift
//  CalCalc
//
//  Created by Ivan Dilchovski on 11/21/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import Foundation
import XCGLogger

let log = XCGLogger(identifier: "Log", includeDefaultDestinations: false)
let netLog = XCGLogger(identifier: "Network", includeDefaultDestinations: false)

extension XCGLogger {
    static func setupAppLogging() {
        let logSystemDestination = AppleSystemLogDestination(identifier: "Log.systemDestination")
        let netSystemDestination = AppleSystemLogDestination(identifier: "Network.systemDestination")
        
        for systemDestination in [logSystemDestination, netSystemDestination] {
            systemDestination.outputLevel = .debug
            systemDestination.showLogIdentifier = true
            systemDestination.showFunctionName = true
            systemDestination.showThreadName = true
            systemDestination.showLevel = true
            systemDestination.showFileName = true
            systemDestination.showLineNumber = true
            systemDestination.showDate = true
        }
        
        log.add(destination: logSystemDestination)
        netLog.add(destination: netSystemDestination)
    }
}

