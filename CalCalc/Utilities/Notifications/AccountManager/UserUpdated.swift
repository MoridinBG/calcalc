//
//  UserUpdated.swift
//  CalCalc
//
//  Created by Ivan Dilchovski on 11/29/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import Foundation

extension Notifications.AccountManager {
    struct UserUpdated: TypedNotification {
        
        static let notificationName = "accountManager.userUpdated"
        
        fileprivate struct Keys {
            static let user = "user"
        }
        
        let observedObject: Any?
        var userInfo: [String : Any]? {
            var userInfo: [String : Any] = [:]
            
            if let user = user {
                userInfo[Keys.user] = user
            }
            
            return userInfo
        }
        
        let user: User?
        
        init?(userInfo: [AnyHashable: Any]?, observedObject: Any?) {
            self.observedObject = observedObject
            self.user = userInfo?[Keys.user] as? User

        }
        
        init(user: User?, observedObject: Any?) {
            self.user = user
            self.observedObject = observedObject
        }
    }
    
}
