//
//  UserListTableViewCell.swift
//  CalCalc
//
//  Created by Ivan Dilchovski on 12/1/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import UIKit

class UserListTableViewCell: UITableViewCell {
    @IBOutlet private var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func setup(from user: User) {
        nameLabel.text = user.fullName
    }
}
