//
//  TypedNotification.swift
//  Peek
//
//  Created by Ivan Dilchovski on 8/10/17.
//  Copyright © 2017 Ivan Dilchovski. All rights reserved.
//

import Foundation

protocol TypedNotification {
    static var notificationName: String { get }

    var observedObject: Any? { get }
    var userInfo: [String : Any]? { get }

    init?(userInfo: [AnyHashable: Any]?, observedObject: Any?)
}

extension NotificationCenter {
    func postTypedNotification<T: TypedNotification>(_ notification: T) {
        post(name: Foundation.Notification.Name(rawValue: T.notificationName), object: notification.observedObject, userInfo: notification.userInfo)
    }

    func addObserver<T: TypedNotification>(forType type: T.Type, observingObject object: Any?, queue: OperationQueue?, onObserve: @escaping (T) -> Void) -> NSObjectProtocol {
        return self.addObserver(forName: NSNotification.Name(rawValue: type.notificationName), object: object, queue: queue) { (notification) in
            guard let value = T(userInfo: (notification as NSNotification).userInfo, observedObject: object) else {
                log.error("TypedNotification could not instantiate from userInfo")
                return
            }
            
            onObserve(value)
        }
    }
}

struct Notifications {
    struct LocationManager {}
    struct Networking {}
    struct AccountManager {}
}
