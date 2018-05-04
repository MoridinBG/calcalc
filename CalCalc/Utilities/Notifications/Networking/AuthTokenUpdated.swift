//
//  AuthTokenUpdated.swift
//  Cowlines
//
//  Created by Ivan Dilchovski on 7.10.17.
//  Copyright © 2017 Ivan Dilchovski. All rights reserved.
//

import Foundation

extension Notifications.Networking {
    struct AuthTokenUpdated: TypedNotification {
        static let notificationName = "networking.authTokenUpdated"
        
        private struct Keys {
            static let accessToken = "accessToken"
        }
        
        let observedObject: Any?
        var userInfo: [String : Any]? {
            var userInfo = [String : Any]()
            userInfo[Keys.accessToken] = accessToken
            
            return userInfo
        }
        
        let accessToken: String?
        
        init?(userInfo: [AnyHashable: Any]?, observedObject: Any?) {
            self.observedObject = observedObject
            self.accessToken = userInfo?[Keys.accessToken] as? String
        }
        
        init(accessToken: String?, observedObject: Any? = nil) {
            self.accessToken = accessToken
            self.observedObject = observedObject
        }
    }
}
