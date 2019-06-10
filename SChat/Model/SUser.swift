//
//  User.swift
//  SChat
//
//  Created by can.khac.nguyen on 6/10/19.
//  Copyright © 2019 Can Khac Nguyen. All rights reserved.
//

import Foundation
import FirebaseFirestore


struct SUser {
    let id: String?
    let name: String
    let age: Int?

    init(name: String) {
        self.name = name
        id = nil
        age = nil
    }

    init(id: String, name: String, age: Int) {
        self.id = id
        self.name = name
        self.age = age
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let name = data["name"] as? String else {
            return nil
        }
        self.name = name
        if let age = data["age"] as? Int {
            self.age = age
        } else {
            self.age = nil
        }
        self.id = document.documentID
    }

}
