//
//  User.swift
//  CalCalc
//
//  Created by Ivan Dilchovski on 11/22/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import Foundation

struct User: Codable {
    enum Role: String, Codable {
        case user
        case manager
        case admin
    }
    
    let id: Int
    
    let firstName: String
    let lastName: String
    let email: String
    let calorieTarget: Int?
    var role: Role
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    init(id: Int,
         firstName: String,
         lastName: String,
         email: String,
         calorieTarget:Int?,
         role: Role = .user) {
        
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.calorieTarget = calorieTarget
        self.role = role
    }
}

