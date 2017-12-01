//
//  UserListViewController.swift
//  CalCalc
//
//  Created by Ivan Dilchovski on 12/1/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import UIKit

class UserListViewController: UIViewController, StoryboardController {
    
    @IBOutlet fileprivate var tableView: UITableView!
    
    fileprivate var currentUser: User!
    
    fileprivate var dataSource: DataSourceState<User> = .loaded([]) {
        didSet {
            switch dataSource {
            case .loading:
                view.makeToastActivity()
                
            case .error(let error):
                self.view.hideToastActivity()
                view.makeToastError(error)
                
            case .loaded:
                self.view.hideToastActivity()
            }
        }
    }
    fileprivate var usersRequests: UsersRequests!
    
    static func instantiate(currentUser: User, usersRequests: UsersRequests = DefaultUsersRequests()) -> UserListViewController {
        
        let vc = UserListViewController.instantiate()
        vc.usersRequests = usersRequests
        vc.currentUser = currentUser
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dataSource = .loading
        usersRequests.getAll { result in
            switch result {
            case .failure(let error):
                self.dataSource = .error(error.errorMessage)
                
            case .success(let users):
                self.dataSource = .loaded(users)
                self.tableView.reloadData()
            }
        }
    }
    
    func insert(user: User) {
        var users: [User]
        if case .loaded(let currentUsers) = dataSource {
            users = currentUsers
        } else {
            users = []
        }
        
        users.append(user)
        dataSource = .loaded(users)
        tableView.reloadData()
    }
}

extension UserListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard case .loaded(let users) = dataSource else { return 0 }
        
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UserListTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        guard case .loaded(let users) = dataSource, indexPath.row < users.count else { return cell }
        
        cell.setup(from: users[indexPath.row])
        return cell
    }
}

extension UserListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard case .loaded(var users) = dataSource, indexPath.row < users.count else { return }
        guard editingStyle == .delete else { return }
        
        self.view.makeToastActivity()
        usersRequests.delete(user: users[indexPath.row]) { result in
            self.view.hideToastActivity()
            switch result {
            case .failure(let error):
                self.view.makeToastError(error.errorMessage)
                
            case .success:
                users.remove(at: indexPath.row)
                self.dataSource = .loaded(users)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard case .loaded(var users) = dataSource, indexPath.row < users.count else { return }
        let editor = EditAccountViewController.instantiate(mode: .editUser(users[indexPath.row]), currentUser: currentUser) { user in
            users[indexPath.row] = user
            self.dataSource = .loaded(users)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            self.navigationController?.popViewController(animated: true)
        }
        
        self.navigationController?.pushViewController(editor, animated: true)
    }
}

