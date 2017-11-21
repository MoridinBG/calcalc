//
//  AppDelegate.swift
//  CalCalc
//
//  Created by Ivan Dilchovski on 11/21/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import XCGLogger
import Toast_Swift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        XCGLogger.setupAppLogging()
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = true
        
        setupUI()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate {
    fileprivate func setupUI() {
        setupToast()
        
        UINavigationBar.appearance().backIndicatorImage = UIImage(named: "BackBlackIcon")
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(named: "BackBlackIcon")
        UINavigationBar.appearance().tintColor = UIColor(red: 30/255, green: 38/255, blue: 34/255, alpha: 1)
        
        let mainVC = SignInViewController.instantiate()
        let navVC = UINavigationController(rootViewController: mainVC)
        navVC.navigationBar.barTintColor = .white
        navVC.navigationBar.isTranslucent = false
        
        window?.rootViewController = navVC
    }
    
    fileprivate func setupToast() {
        var style = ToastStyle()
        style.backgroundColor = Constants.UI.Colors.mainGreen
        style.messageColor = UIColor.white
        style.titleColor = UIColor.white
        
        style.shadowColor = UIColor.gray
        style.shadowOpacity = 0.4
        style.displayShadow = true
        
        // just set the shared style and there's no need to provide the style again
        ToastManager.shared.style = style
        ToastManager.shared.duration = 3.0
        ToastManager.shared.position = .bottom
    }
}
