//
//  AppSettings.swift
//  SChat
//
//  Created by can.khac.nguyen on 6/10/19.
//  Copyright © 2019 Can Khac Nguyen. All rights reserved.
//

import Foundation

struct AppSettings {
    static var currentUserNameKey = "CurrentUserName"
    static var currentUserName: String {
        get {
            return UserDefaults.standard.string(forKey: currentUserNameKey) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: currentUserNameKey)
        }
    }
}
