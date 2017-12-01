//
//  UITableView+dequeue.swift
//  CalCalc
//
//  Created by Ivan Dilchovski on 12/1/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import UIKit

// Allows type inferred cell instantiation without casting and strings - let cell: SomeTableViewCell = tableView.dequeueReusableCell(for: indexPath)
extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseId, for: indexPath) as? T else {
            fatalError("Could not deque cell with id \(T.reuseId). Table View not set properly?")
        }
        
        return cell
    }
}
