//
//  DashboardViewController.swift
//  CalCalc
//
//  Created by Ivan Dilchovski on 11/29/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, StoryboardController {
    enum DashboardSource {
        case calorie
        case users
    }
    
    @IBOutlet fileprivate var reportButton: UIBarButtonItem!
    @IBOutlet fileprivate var addButton: UIBarButtonItem!
    @IBOutlet fileprivate var dashboardTypeSegment: UISegmentedControl!
    @IBOutlet fileprivate var containerView: UIView!
    
    fileprivate var currentUser: User!
    fileprivate var source: DashboardSource = .calorie
    
    
    fileprivate var accountManager: AccountManager!
    
    static func initialize(user: User,
                           accountManager: AccountManager = AccountManager()) -> DashboardViewController {
        
        let vc = DashboardViewController.instantiate()
        vc.currentUser = user
        vc.accountManager = accountManager
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        segmentChanged(dashboardTypeSegment)
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            source = .calorie
            reportButton.tintColor = .white
            reportButton.isEnabled = true
            
        case 1:
            source = .users
            reportButton.tintColor = .clear
            reportButton.isEnabled = false
            
        default:
            source = .calorie
            log.error("Segment index not handled")
        }
    }
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        accountManager.logout()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func reportPressed(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        switch source {
        case .calorie:
            break
            
        case .users:
            break
        }
    }
}

extension DashboardViewController {
    fileprivate func setupUI() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        if case .user = currentUser.role {
            dashboardTypeSegment.removeFromSuperview()
        }
    }
}