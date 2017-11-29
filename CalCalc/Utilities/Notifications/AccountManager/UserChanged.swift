//
//  UserChanged.swift
//  LogJog
//
//  Created by Ivan Dilchovski on 10/21/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import Foundation

extension Notifications.AccountManager {
    struct UserChanged: TypedNotification {

        static let notificationName = "accountManager.userChanged"

        fileprivate struct Keys {
            static let user = "user"
            static let loggedOut = "loggedOut"
            static let rebuildUI = "rebuildUI"
        }

        let observedObject: Any?
        var userInfo: [String : Any]? {
            var userInfo: [String : Any] = [
                Keys.loggedOut : loggedOut,
                Keys.rebuildUI : rebuildUI
            ]

            if let user = user {
                userInfo[Keys.user] = user
            }

            return userInfo
        }

        let user: User?
        let loggedOut: Bool
        let rebuildUI: Bool

        init?(userInfo: [AnyHashable: Any]?, observedObject: Any?) {
            self.observedObject = observedObject
            guard let loggedOut = userInfo?[Keys.loggedOut] as? Bool, let rebuildUI = userInfo?[Keys.rebuildUI] as? Bool else { return nil }

            self.user = userInfo?[Keys.user] as? User
            self.loggedOut = loggedOut
            self.rebuildUI = rebuildUI
        }

        init(user: User?, loggedOut: Bool, rebuildUI: Bool = true, observedObject: Any?) {
            self.user = user
            self.loggedOut = loggedOut
            self.rebuildUI = rebuildUI
            self.observedObject = observedObject
        }
    }

}
