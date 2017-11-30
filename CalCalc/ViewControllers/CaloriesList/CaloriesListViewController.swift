//
//  CaloriesListViewController.swift
//  CalCalc
//
//  Created by Ivan Dilchovski on 11/30/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import UIKit

class CaloriesListViewController: UIViewController, StoryboardController {

    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension CaloriesListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
        return cell
    }
}
