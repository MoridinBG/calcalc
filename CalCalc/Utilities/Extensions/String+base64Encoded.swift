//
//  String+base64Encoded.swift
//  CalCalc
//
//  Created by Ivan Dilchovski on 11/28/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import Foundation

extension String {
    func base64Encoded() -> String? {
        let data = self.data(using: String.Encoding.utf8)
        return data?.base64EncodedString(options: [])
    }
}
