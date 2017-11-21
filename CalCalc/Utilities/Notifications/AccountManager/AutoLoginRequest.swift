//
//  AutoLoginRequest.swift
//  Cowlines
//
//  Created by Ivan Dilchovski on 7.10.17.
//  Copyright © 2017 Ivan Dilchovski. All rights reserved.
//

import Foundation

extension Notifications.AccountManager {
    struct AutoLoginRequest: TypedNotification {
        static let notificationName = "accountManager.autologinRequest"
        
        fileprivate struct Keys {
            static let tokenExpired = "tokenExpired"
        }
        
        let observedObject: Any?
        var userInfo: [String : Any]? {
            return [
                Keys.tokenExpired : tokenExpired
            ]
        }
        
        let tokenExpired: Bool
        
        init?(userInfo: [AnyHashable: Any]?, observedObject: Any?) {
            guard let tokenExpired = userInfo?[Keys.tokenExpired] as? Bool else { return nil }
            
            self.observedObject = observedObject
            self.tokenExpired = tokenExpired
        }
        
        init(tokenExpired: Bool, observedObject: Any? = nil) {
            self.tokenExpired = tokenExpired
            self.observedObject = nil
        }
    }
}
