//
//  AppDelegate.swift
//  SChat
//
//  Created by Can Khac Nguyen on 6/1/19.
//  Copyright © 2019 Can Khac Nguyen. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        FirebaseApp.configure()
        
        // check auth
        if let _ = Auth.auth().currentUser {
            let nav = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "nav")
            window?.rootViewController = nav
        }
        return true
    }
}

