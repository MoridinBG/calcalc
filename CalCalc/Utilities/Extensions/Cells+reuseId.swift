//
//  Cells+reuseId.swift
//  CalCalc
//
//  Created by Ivan Dilchovski on 12/1/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import UIKit

extension UITableViewCell
{
    static var reuseId: String {
        return String(describing: self)
    }
}

extension UICollectionViewCell
{
    static var reuseId: String {
        return String(describing: self)
    }
}
