//
//  DataSource.swift
//  CalCalc
//
//  Created by Ivan Dilchovski on 12/1/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import Foundation

enum DataSourceUpdate {
    case insert(IndexPath, reloadSection: Bool)
    case delete(IndexPath, reloadSection: Bool)
    case reload(IndexPath, reloadSection: Bool)
}

enum DataSourceState<T> {
    case loading
    case loaded([T])
    case error(String)
}
